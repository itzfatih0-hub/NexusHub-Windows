// ============================================================
// memory.h — MEMORY MANIPULATION
// AUTHOR: PROFESOR_FATIH + NEXUS 1.0
// ============================================================

#pragma once
#include <windows.h>
#include <vector>
#include <string>

class MemoryManager {
public:
    MemoryManager();
    ~MemoryManager();

    // Membuka proses berdasarkan PID
    bool OpenProcess(DWORD pid);
    
    // Menutup proses
    void CloseProcess();

    // Membaca memori dari alamat tertentu
    bool ReadMemory(LPVOID address, LPVOID buffer, SIZE_T size);
    
    // Menulis memori ke alamat tertentu
    bool WriteMemory(LPVOID address, LPVOID buffer, SIZE_T size);

    // Mencari pola byte di memori
    LPVOID ScanMemory(LPVOID startAddress, SIZE_T size, 
                      const std::vector<BYTE>& pattern, 
                      const std::string& mask = "");

    // Membaca nilai dari pointer (multi-level)
    template<typename T>
    T ReadPointer(LPVOID baseAddress, const std::vector<DWORD>& offsets);

    // Menulis nilai ke pointer (multi-level)
    template<typename T>
    bool WritePointer(LPVOID baseAddress, const std::vector<DWORD>& offsets, T value);

    // Mendapatkan handle proses
    HANDLE GetProcessHandle() const { return hProcess; }
    
    // Mendapatkan PID
    DWORD GetProcessId() const { return dwPid; }

private:
    HANDLE hProcess;
    DWORD dwPid;

    // Membaca nilai dari alamat virtual (digunakan oleh template)
    template<typename T>
    T ReadVirtualMemory(LPVOID address);
    
    template<typename T>
    bool WriteVirtualMemory(LPVOID address, T value);
};

// Implementasi template (harus di header)
template<typename T>
T MemoryManager::ReadVirtualMemory(LPVOID address) {
    T value = T();
    ReadMemory(address, &value, sizeof(T));
    return value;
}

template<typename T>
bool MemoryManager::WriteVirtualMemory(LPVOID address, T value) {
    return WriteMemory(address, &value, sizeof(T));
}

template<typename T>
T MemoryManager::ReadPointer(LPVOID baseAddress, const std::vector<DWORD>& offsets) {
    if (!hProcess || offsets.empty()) return T();
    
    LPVOID currentAddress = baseAddress;
    for (size_t i = 0; i < offsets.size() - 1; ++i) {
        DWORD ptr = ReadVirtualMemory<DWORD>(currentAddress);
        if (ptr == 0) return T();
        currentAddress = (LPVOID)(ptr + offsets[i]);
    }
    
    DWORD finalPtr = ReadVirtualMemory<DWORD>(currentAddress);
    if (finalPtr == 0) return T();
    currentAddress = (LPVOID)(finalPtr + offsets.back());
    
    return ReadVirtualMemory<T>(currentAddress);
}

template<typename T>
bool MemoryManager::WritePointer(LPVOID baseAddress, const std::vector<DWORD>& offsets, T value) {
    if (!hProcess || offsets.empty()) return false;
    
    LPVOID currentAddress = baseAddress;
    for (size_t i = 0; i < offsets.size() - 1; ++i) {
        DWORD ptr = ReadVirtualMemory<DWORD>(currentAddress);
        if (ptr == 0) return false;
        currentAddress = (LPVOID)(ptr + offsets[i]);
    }
    
    DWORD finalPtr = ReadVirtualMemory<DWORD>(currentAddress);
    if (finalPtr == 0) return false;
    currentAddress = (LPVOID)(finalPtr + offsets.back());
    
    return WriteVirtualMemory<T>(currentAddress, value);
}