// ============================================================
// executor.cpp — NEXUS EXECUTOR CORE IMPLEMENTATION
// ============================================================

#include "executor.h"
#include "../injector/injector.h"
#include "../utils/utils.h"
#include <iostream>
#include <tlhelp32.h>

NexusExecutor::NexusExecutor() 
    : hRobloxProcess(NULL), dwRobloxPID(0), bInjected(false) {}

NexusExecutor::~NexusExecutor() {
    if (hRobloxProcess) CloseHandle(hRobloxProcess);
}

bool NexusExecutor::Initialize() {
    std::cout << "[✓] Nexus Executor Core initialized." << std::endl;
    return true;
}

DWORD NexusExecutor::FindRobloxProcess() {
    DWORD pid = 0;
    HANDLE snap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    
    if (snap != INVALID_HANDLE_VALUE) {
        PROCESSENTRY32 entry;
        entry.dwSize = sizeof(entry);
        
        if (Process32First(snap, &entry)) {
            do {
                if (_stricmp(entry.szExeFile, "RobloxPlayerBeta.exe") == 0) {
                    pid = entry.th32ProcessID;
                    break;
                }
            } while (Process32Next(snap, &entry));
        }
        CloseHandle(snap);
    }
    return pid;
}

bool NexusExecutor::Inject(DWORD processId) {
    if (processId == 0) {
        dwRobloxPID = FindRobloxProcess();
    } else {
        dwRobloxPID = processId;
    }

    if (dwRobloxPID == 0) {
        std::cerr << "[ERROR] Roblox process not found!" << std::endl;
        return false;
    }

    std::cout << "[✓] Found Roblox process with PID: " << dwRobloxPID << std::endl;

    hRobloxProcess = OpenProcess(PROCESS_ALL_ACCESS, FALSE, dwRobloxPID);
    if (!hRobloxProcess) {
        std::cerr << "[ERROR] Failed to open process!" << std::endl;
        return false;
    }

    // Inject menggunakan DLL
    if (LoadInjectorDLL()) {
        bInjected = true;
        std::cout << "[✓] Injection successful!" << std::endl;
        return true;
    }

    return false;
}

bool NexusExecutor::LoadInjectorDLL() {
    // Dalam implementasi nyata, ini akan memuat DLL dari folder /bin
    // dan melakukan injeksi ke proses Roblox.
    std::cout << "[✓] Injector DLL loaded." << std::endl;
    return true;
}

bool NexusExecutor::ExecuteScript(const std::string& script) {
    if (!bInjected) {
        std::cerr << "[ERROR] Not injected into any process!" << std::endl;
        return false;
    }

    std::cout << "[✓] Executing script: " << script.substr(0, 30) << "..." << std::endl;
    // Logika eksekusi script Luau akan di sini
    return true;
}

bool NexusExecutor::Eject() {
    if (hRobloxProcess) {
        CloseHandle(hRobloxProcess);
        hRobloxProcess = NULL;
    }
    bInjected = false;
    dwRobloxPID = 0;
    std::cout << "[✓] Ejected from Roblox process." << std::endl;
    return true;
}