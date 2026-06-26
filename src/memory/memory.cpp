// ============================================================
// memory.cpp — MEMORY MANIPULATION IMPLEMENTATION
// AUTHOR: PROFESOR_FATIH + NEXUS 1.0
// ============================================================

#include "memory.h"
#include <iostream>
#include <algorithm>

MemoryManager::MemoryManager() 
    : hProcess(NULL), dwPid(0) {}

MemoryManager::~MemoryManager() {
    CloseProcess();
}

bool MemoryManager::OpenProcess(DWORD pid) {
    if (hProcess) CloseProcess();
    
    dwPid = pid;
    hProcess = ::OpenProcess(
        PROCESS_VM_READ | PROCESS_VM_WRITE | PROCESS_VM_OPERATION,
        FALSE,
        pid
    );
    
    if (!hProcess) {
        std::cerr << "[ERROR] Failed to open process with PID: " << pid << std::endl;
        return false;
    }
    
    std::cout << "[✓] Opened process with PID: " << pid << std::endl;
    return true;
}

void MemoryManager::CloseProcess() {
    if (hProcess) {
        CloseHandle(hProcess);
        hProcess = NULL;
    }
    dwPid = 0;
}

bool MemoryManager::ReadMemory(LPVOID address, LPVOID buffer, SIZE_T size) {
    if (!hProcess) return false;
    
    SIZE_T bytesRead = 0;
    BOOL result = ReadProcessMemory(hProcess, address, buffer, size, &bytesRead);
    
    if (!result || bytesRead != size) {
        std::cerr << "[ERROR] Failed to read memory at 0x" << std::hex << address << std::endl;
        return false;
    }
    
    return true;
}

bool MemoryManager::WriteMemory(LPVOID address, LPVOID buffer, SIZE_T size) {
    if (!hProcess) return false;
    
    DWORD oldProtect = 0;
    VirtualProtectEx(hProcess, address, size, PAGE_EXECUTE_READWRITE, &oldProtect);
    
    SIZE_T bytesWritten = 0;
    BOOL result = WriteProcessMemory(hProcess, address, buffer, size, &bytesWritten);
    
    VirtualProtectEx(hProcess, address, size, oldProtect, &oldProtect);
    
    if (!result || bytesWritten != size) {
        std::cerr << "[ERROR] Failed to write memory at 0x" << std::hex << address << std::endl;
        return false;
    }
    
    return true;
}

LPVOID MemoryManager::ScanMemory(LPVOID startAddress, SIZE_T size, 
                                 const std::vector<BYTE>& pattern, 
                                 const std::string& mask) {
    if (!hProcess || pattern.empty()) return nullptr;
    
    std::vector<BYTE> buffer(size);
    if (!ReadMemory(startAddress, buffer.data(), size)) {
        return nullptr;
    }
    
    size_t patternSize = pattern.size();
    for (size_t i = 0; i <= size - patternSize; ++i) {
        bool found = true;
        for (size_t j = 0; j < patternSize; ++j) {
            if (mask.empty() || mask[j] == 'x') {
                if (buffer[i + j] != pattern[j]) {
                    found = false;
                    break;
                }
            }
        }
        if (found) {
            return (LPVOID)((DWORD_PTR)startAddress + i);
        }
    }
    
    return nullptr;
}