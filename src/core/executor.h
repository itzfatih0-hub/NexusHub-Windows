// ============================================================
// executor.h — NEXUS EXECUTOR CORE
// ============================================================

#pragma once
#include <windows.h>
#include <string>
#include <vector>

class NexusExecutor {
public:
    NexusExecutor();
    ~NexusExecutor();

    bool Initialize();
    bool Inject(DWORD processId);
    bool ExecuteScript(const std::string& script);
    bool Eject();

private:
    HANDLE hRobloxProcess;
    DWORD dwRobloxPID;
    bool bInjected;

    DWORD FindRobloxProcess();
    bool LoadInjectorDLL();
};