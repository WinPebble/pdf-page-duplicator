#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <shobjidl.h>
#include <shlwapi.h>
#include <wrl.h>
#include <atomic>
#include <memory>
#include <string>
#include <vector>
#include "ShellIds.h"

using Microsoft::WRL::ComPtr;
using Microsoft::WRL::Make;
using Microsoft::WRL::RuntimeClass;
using Microsoft::WRL::RuntimeClassFlags;
using Microsoft::WRL::ClassicCom;

namespace
{
    HMODULE module = nullptr;
    std::atomic<long> objects{0}, locks{0};

    std::wstring ModuleDirectory()
    {
        std::wstring path(32768, L'\0');
        DWORD length = GetModuleFileNameW(module, path.data(), static_cast<DWORD>(path.size()));
        if (length == 0 || length >= path.size()) return {};
        path.resize(length);
        const auto slash = path.find_last_of(L"\\/");
        return slash == std::wstring::npos ? std::wstring{} : path.substr(0, slash);
    }

    HRESULT SelectedPdf(IShellItemArray* items, std::wstring& path)
    {
        if (!items) return E_INVALIDARG;
        DWORD count = 0;
        HRESULT hr = items->GetCount(&count);
        if (FAILED(hr)) return hr;
        // v1 opens one options window for exactly one PDF, not a batch operation.
        if (count != 1) return E_INVALIDARG;
        ComPtr<IShellItem> item;
        hr = items->GetItemAt(0, &item);
        if (FAILED(hr)) return hr;
        SFGAOF attributes = SFGAO_FILESYSTEM | SFGAO_FOLDER;
        hr = item->GetAttributes(attributes, &attributes);
        if (FAILED(hr)) return hr;
        if (!(attributes & SFGAO_FILESYSTEM) || (attributes & SFGAO_FOLDER)) return E_INVALIDARG;
        PWSTR value = nullptr;
        hr = item->GetDisplayName(SIGDN_FILESYSPATH, &value);
        std::unique_ptr<wchar_t, decltype(&CoTaskMemFree)> owned(value, CoTaskMemFree);
        if (FAILED(hr)) return hr;
        if (!value || _wcsicmp(PathFindExtensionW(value), L".pdf") != 0) return E_INVALIDARG;
        path = value;
        return S_OK;
    }

    HRESULT LaunchOptions(const std::wstring& pdf)
    {
        const DWORD attributes = GetFileAttributesW(pdf.c_str());
        if (attributes == INVALID_FILE_ATTRIBUTES || (attributes & FILE_ATTRIBUTE_DIRECTORY))
            return HRESULT_FROM_WIN32(ERROR_FILE_NOT_FOUND);
        const auto directory = ModuleDirectory();
        if (directory.empty()) return E_FAIL;
        const auto exe = directory + L"\\WinPebble.PDFPageDuplicator.exe";
        // Both arguments are absolute filesystem paths ending in .exe/.pdf:
        // Windows filenames cannot contain quotes or end in a path separator.
        // No shell/cmd interpreter is involved, so &, apostrophes etc. stay literal.
        const auto command = L"\"" + exe + L"\" \"" + pdf + L"\"";
        if (command.size() >= 32767) return HRESULT_FROM_WIN32(ERROR_BUFFER_OVERFLOW);
        std::vector<wchar_t> mutableCommand(command.begin(), command.end());
        mutableCommand.push_back(L'\0');
        STARTUPINFOW startup{};
        startup.cb = sizeof(startup);
        PROCESS_INFORMATION process{};
        if (!CreateProcessW(exe.c_str(), mutableCommand.data(), nullptr, nullptr, FALSE,
                            CREATE_UNICODE_ENVIRONMENT, nullptr, directory.c_str(), &startup, &process))
            return HRESULT_FROM_WIN32(GetLastError());
        CloseHandle(process.hThread);
        CloseHandle(process.hProcess);
        return S_OK;
    }

    class ExplorerCommand final : public RuntimeClass<RuntimeClassFlags<ClassicCom>, IExplorerCommand>
    {
    public:
        ExplorerCommand() { ++objects; }
        ~ExplorerCommand() { --objects; }
        IFACEMETHODIMP GetTitle(IShellItemArray*, PWSTR* title) override
        { return title ? SHStrDupW(L"Page Duplicator", title) : E_POINTER; }
        IFACEMETHODIMP GetIcon(IShellItemArray*, PWSTR* icon) override
        {
            if (!icon) return E_POINTER;
            *icon = nullptr;
            try { return SHStrDupW((ModuleDirectory() + L"\\WinPebble.PDFPageDuplicator.exe,0").c_str(), icon); }
            catch (...) { return E_OUTOFMEMORY; }
        }
        IFACEMETHODIMP GetToolTip(IShellItemArray*, PWSTR* tip) override
        { return tip ? SHStrDupW(L"Open duplication options for this PDF", tip) : E_POINTER; }
        IFACEMETHODIMP GetCanonicalName(GUID* id) override
        { if (!id) return E_POINTER; *id = PageDuplicatorClsid; return S_OK; }
        IFACEMETHODIMP GetState(IShellItemArray* items, BOOL, EXPCMDSTATE* state) override
        {
            if (!state) return E_POINTER;
            *state = ECS_HIDDEN;
            try
            {
                std::wstring path;
                // Only inspect selection metadata. Never parse PDFs on the menu path.
                if (SUCCEEDED(SelectedPdf(items, path))) *state = ECS_ENABLED;
            }
            catch (...) { /* remain hidden; no exceptions across COM */ }
            return S_OK;
        }
        IFACEMETHODIMP Invoke(IShellItemArray* items, IBindCtx*) override
        {
            try
            {
                std::wstring path;
                HRESULT hr = SelectedPdf(items, path);
                return FAILED(hr) ? hr : LaunchOptions(path);
            }
            catch (const std::bad_alloc&) { return E_OUTOFMEMORY; }
            catch (...) { return E_FAIL; }
        }
        IFACEMETHODIMP GetFlags(EXPCMDFLAGS* flags) override
        { if (!flags) return E_POINTER; *flags = ECF_DEFAULT; return S_OK; }
        IFACEMETHODIMP EnumSubCommands(IEnumExplorerCommand** commands) override
        { if (!commands) return E_POINTER; *commands = nullptr; return E_NOTIMPL; }
    };

    class CommandFactory final : public RuntimeClass<RuntimeClassFlags<ClassicCom>, IClassFactory>
    {
    public:
        CommandFactory() { ++objects; }
        ~CommandFactory() { --objects; }
        IFACEMETHODIMP CreateInstance(IUnknown* outer, REFIID iid, void** object) override
        {
            if (!object) return E_POINTER;
            *object = nullptr;
            if (outer) return CLASS_E_NOAGGREGATION;
            auto command = Make<ExplorerCommand>();
            return command ? command.CopyTo(iid, object) : E_OUTOFMEMORY;
        }
        IFACEMETHODIMP LockServer(BOOL lock) override
        { if (lock) ++locks; else --locks; return S_OK; }
    };
}

BOOL WINAPI DllMain(HINSTANCE instance, DWORD reason, LPVOID)
{ if (reason == DLL_PROCESS_ATTACH) module = instance; return TRUE; }

STDAPI DllCanUnloadNow()
{ return objects.load() == 0 && locks.load() == 0 ? S_OK : S_FALSE; }

STDAPI DllGetClassObject(REFCLSID clsid, REFIID iid, void** object)
{
    if (!object) return E_POINTER;
    *object = nullptr;
    if (!IsEqualCLSID(clsid, PageDuplicatorClsid)) return CLASS_E_CLASSNOTAVAILABLE;
    auto factory = Make<CommandFactory>();
    return factory ? factory.CopyTo(iid, object) : E_OUTOFMEMORY;
}
