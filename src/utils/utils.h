// ============================================================
// utils.h — UTILITY FUNCTIONS
// ============================================================

#pragma once
#include <string>
#include <vector>
#include <windows.h>

namespace Utils {
    std::string GetCurrentDirectory();
    bool FileExists(const std::string& path);
    std::vector<BYTE> ReadFileToBytes(const std::string& path);
    void Log(const std::string& message);
}