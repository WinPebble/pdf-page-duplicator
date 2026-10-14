#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <shobjidl.h>
#include <shlobj.h>
#include <wrl.h>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>
#include "ShellIds.h"

using Microsoft::WRL::ComPtr;
void Require(bool condition, const char* message)
{ if (!condition) throw std::runtime_error(message); }

ComPtr<IShellItemArray> Selection(const std::vector<std::wstring>& paths)
{
    std::vector<PIDLIST_ABSOLUTE> ids;
    for (const auto& path : paths)
    {
        PIDLIST_ABSOLUTE id = nullptr;
        Require(SUCCEEDED(SHParseDisplayName(path.c_str(), nullptr, &id, 0, nullptr)), "Parse shell item");
        ids.push_back(id);
    }
    ComPtr<IShellItemArray> items;
    std::vector<PCIDLIST_ABSOLUTE> constIds(ids.begin(), ids.end());
    const HRESULT hr = SHCreateShellItemArrayFromIDLists(static_cast<UINT>(ids.size()),
        constIds.data(), &items);
    for (auto id : ids) CoTaskMemFree(id);
    Require(SUCCEEDED(hr), "Create selection");
    return items;
}

void Touch(const std::wstring& path)
{
    HANDLE file = CreateFileW(path.c_str(), GENERIC_WRITE, 0, nullptr, CREATE_NEW, FILE_ATTRIBUTE_NORMAL, nullptr);
    Require(file != INVALID_HANDLE_VALUE, "Create fixture");
    CloseHandle(file);
}

int wmain(int argc, wchar_t** argv)
{
    std::wstring directory, pdf, text, report;
    HMODULE dll = nullptr;
    HRESULT init = CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
    if (FAILED(init)) return 2;
    int result = 1;
    try
    {
        Require(argc == 2, "DLL argument required");
        wchar_t temp[32768]{};
        Require(GetTempPathW(32768, temp) != 0, "Temp path");
        GUID unique{};
        Require(SUCCEEDED(CoCreateGuid(&unique)), "Test GUID");
        wchar_t guid[40]{};
        StringFromGUID2(unique, guid, 40);
        directory = std::wstring(temp) + L"WinPebble Menu Test " + guid;
        Require(CreateDirectoryW(directory.c_str(), nullptr) != FALSE, "Test directory");
        pdf = directory + L"\\Tài liệu & O'Brien (1).PDF";
        text = directory + L"\\other.txt";
        report = directory + L"\\received-argument.txt";
        Touch(pdf); Touch(text);
        Require(SetEnvironmentVariableW(L"WINPEBBLE_SHELL_TEST_REPORT", report.c_str()) != FALSE, "Report environment");
        dll = LoadLibraryW(argv[1]);
        Require(dll != nullptr, "Load shell DLL");
        using GetClass = HRESULT(STDAPICALLTYPE*)(REFCLSID, REFIID, void**);
        using CanUnload = HRESULT(STDAPICALLTYPE*)();
#pragma warning(push)
#pragma warning(disable:4191)
        auto getClass = reinterpret_cast<GetClass>(GetProcAddress(dll, "DllGetClassObject"));
        auto canUnload = reinterpret_cast<CanUnload>(GetProcAddress(dll, "DllCanUnloadNow"));
#pragma warning(pop)
        Require(getClass && canUnload, "COM exports");
        Require(canUnload() == S_OK, "Initially unloadable");
        {
            ComPtr<IClassFactory> factory;
            Require(getClass(CLSID_NULL, IID_PPV_ARGS(&factory)) == CLASS_E_CLASSNOTAVAILABLE, "Foreign CLSID rejected");
            Require(SUCCEEDED(getClass(PageDuplicatorClsid, IID_PPV_ARGS(&factory))), "Create factory");
            ComPtr<IExplorerCommand> command;
            Require(SUCCEEDED(factory->CreateInstance(nullptr, IID_PPV_ARGS(&command))), "Create command");
            Require(canUnload() == S_FALSE, "Live objects prevent unload");
            PWSTR title = nullptr;
            Require(SUCCEEDED(command->GetTitle(nullptr, &title)), "Command title");
            const bool titleCorrect = std::wstring(title) == L"Page Duplicator";
            CoTaskMemFree(title);
            Require(titleCorrect, "Exact menu label");
            GUID canonical{};
            Require(SUCCEEDED(command->GetCanonicalName(&canonical)) && IsEqualGUID(canonical, PageDuplicatorClsid), "Canonical CLSID");
            auto one = Selection({pdf});
            auto wrong = Selection({text});
            auto multiple = Selection({pdf, text});
            auto folder = Selection({directory});
            EXPCMDSTATE state{};
            Require(SUCCEEDED(command->GetState(one.Get(), FALSE, &state)) && state == ECS_ENABLED, "Single PDF enabled");
            for (IShellItemArray* selection : {wrong.Get(), multiple.Get(), folder.Get(), static_cast<IShellItemArray*>(nullptr)})
                Require(SUCCEEDED(command->GetState(selection, FALSE, &state)) && state == ECS_HIDDEN, "Non-PDF/multiple/folder/null hidden");
            Require(FAILED(command->Invoke(wrong.Get(), nullptr)), "Non-PDF invocation rejected");
            Require(FAILED(command->Invoke(multiple.Get(), nullptr)), "Multiple selection rejected");
            Require(SUCCEEDED(command->Invoke(one.Get(), nullptr)), "Launch UI recorder");
            bool matched = false;
            for (int attempt = 0; attempt < 100 && !matched; ++attempt)
            {
                Sleep(50);
                HANDLE file = CreateFileW(report.c_str(), GENERIC_READ, FILE_SHARE_READ | FILE_SHARE_WRITE,
                    nullptr, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr);
                if (file == INVALID_HANDLE_VALUE) continue;
                std::wstring received(32768, L'\0');
                DWORD read = 0;
                if (ReadFile(file, received.data(), static_cast<DWORD>(received.size() * sizeof(wchar_t)), &read, nullptr))
                { received.resize(read / sizeof(wchar_t)); matched = received == pdf; }
                CloseHandle(file);
            }
            Require(matched, "Child receives exactly one unchanged Unicode/spaced/metacharacter path");
            factory->LockServer(TRUE);
            command.Reset(); factory.Reset();
            Require(canUnload() == S_FALSE, "Server lock prevents unload");
            Require(SUCCEEDED(getClass(PageDuplicatorClsid, IID_PPV_ARGS(&factory))), "Unlock factory");
            factory->LockServer(FALSE); factory.Reset();
        }
        Require(canUnload() == S_OK, "All references released");
        std::cout << "PASS: COM lifecycle, PDF-only single selection and exact Unicode argument launch.\n";
        result = 0;
    }
    catch (const std::exception& error) { std::cerr << "FAIL: " << error.what() << '\n'; }
    if (dll) FreeLibrary(dll);
    SetEnvironmentVariableW(L"WINPEBBLE_SHELL_TEST_REPORT", nullptr);
    // Only these files created by this test are removed; never recurse into Temp.
    if (!report.empty()) DeleteFileW(report.c_str());
    if (!pdf.empty()) DeleteFileW(pdf.c_str());
    if (!text.empty()) DeleteFileW(text.c_str());
    if (!directory.empty()) RemoveDirectoryW(directory.c_str());
    CoUninitialize();
    return result;
}
