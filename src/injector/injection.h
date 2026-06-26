// ============================================================
// injector.h — DLL INJECTOR
// ============================================================

#pragma once
#include <windows.h>
#include <string>

class Injector {
public:
    static bool InjectDLL(DWORD processId, const std::string& dllPath);
    static bool EjectDLL(DWORD processId, const std::string& dllName);
};