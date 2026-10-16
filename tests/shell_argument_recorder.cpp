#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <string>

// Test fixture only: verifies CreateProcess's actual argv without launching WPF.
int wmain(int argc, wchar_t** argv)
{
    wchar_t report[32768]{};
    if (!GetEnvironmentVariableW(L"WINPEBBLE_SHELL_TEST_REPORT", report, 32768)) return 2;
    const std::wstring argument = argc == 2 ? argv[1] : L"INVALID_ARGUMENT_COUNT";
    HANDLE file = CreateFileW(report, GENERIC_WRITE, 0, nullptr, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, nullptr);
    if (file == INVALID_HANDLE_VALUE) return 3;
    DWORD written = 0;
    const auto bytes = static_cast<DWORD>(argument.size() * sizeof(wchar_t));
    const BOOL ok = WriteFile(file, argument.data(), bytes, &written, nullptr);
    CloseHandle(file);
    return ok && written == bytes ? 0 : 4;
}
