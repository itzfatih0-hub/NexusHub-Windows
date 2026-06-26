// ============================================================
// utils.cpp — UTILITY FUNCTIONS IMPLEMENTATION
// AUTHOR: PROFESOR_FATIH + NEXUS 1.0
// ============================================================

#include "utils.h"
#include <windows.h>
#include <fstream>
#include <iostream>
#include <chrono>
#include <iomanip>
#include <sstream>

namespace Utils {

std::string GetCurrentDirectory() {
    char buffer[MAX_PATH];
    GetCurrentDirectoryA(MAX_PATH, buffer);
    return std::string(buffer);
}

bool FileExists(const std::string& path) {
    DWORD attrib = GetFileAttributesA(path.c_str());
    return (attrib != INVALID_FILE_ATTRIBUTES && 
            !(attrib & FILE_ATTRIBUTE_DIRECTORY));
}

std::vector<BYTE> ReadFileToBytes(const std::string& path) {
    std::vector<BYTE> bytes;
    std::ifstream file(path, std::ios::binary);
    if (file.is_open()) {
        file.seekg(0, std::ios::end);
        size_t size = file.tellg();
        file.seekg(0, std::ios::beg);
        bytes.resize(size);
        file.read(reinterpret_cast<char*>(bytes.data()), size);
        file.close();
    }
    return bytes;
}

void Log(const std::string& message) {
    auto now = std::chrono::system_clock::now();
    auto time = std::chrono::system_clock::to_time_t(now);
    std::tm tm;
    localtime_s(&tm, &time);
    
    std::stringstream ss;
    ss << std::put_time(&tm, "[%Y-%m-%d %H:%M:%S] ") << message << std::endl;
    
    std::string logPath = GetCurrentDirectory() + "\\logs\\execution.log";
    std::ofstream logFile(logPath, std::ios::app);
    if (logFile.is_open()) {
        logFile << ss.str();
        logFile.close();
    }
    
    // Juga tampilkan di console
    std::cout << ss.str();
}

std::string GetProcessName(DWORD pid) {
    HANDLE hProcess = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, pid);
    if (hProcess) {
        char processName[MAX_PATH];
        DWORD size = sizeof(processName);
        if (QueryFullProcessImageNameA(hProcess, 0, processName, &size)) {
            CloseHandle(hProcess);
            // Ambil nama file dari path lengkap
            std::string fullPath(processName);
            size_t pos = fullPath.find_last_of("\\/");
            if (pos != std::string::npos) {
                return fullPath.substr(pos + 1);
            }
            return fullPath;
        }
        CloseHandle(hProcess);
    }
    return "Unknown";
}

bool IsProcessRunning(const std::string& processName) {
    HANDLE snap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (snap == INVALID_HANDLE_VALUE) return false;
    
    PROCESSENTRY32 entry;
    entry.dwSize = sizeof(entry);
    
    if (Process32First(snap, &entry)) {
        do {
            if (_stricmp(entry.szExeFile, processName.c_str()) == 0) {
                CloseHandle(snap);
                return true;
            }
        } while (Process32Next(snap, &entry));
    }
    CloseHandle(snap);
    return false;
}

std::string GenerateRandomString(size_t length) {
    const char charset[] = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    std::string result;
    result.reserve(length);
    
    srand(static_cast<unsigned>(time(nullptr)));
    for (size_t i = 0; i < length; ++i) {
        result += charset[rand() % (sizeof(charset) - 1)];
    }
    return result;
}

} // namespace Utils