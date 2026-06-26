// ============================================================
// hooks.cpp — API HOOKING IMPLEMENTATION
// AUTHOR: PROFESOR_FATIH + NEXUS 1.0
// ============================================================

#include "hooks.h"
#include "../utils/utils.h"
#include <iostream>
#include <detours.h>

// ============================================================
// HOOK MANAGER IMPLEMENTATION
// ============================================================

HookManager& HookManager::GetInstance() {
    static HookManager instance;
    return instance;
}

HookManager::HookManager() 
    : OriginalMessageBoxW(MessageBoxW), 
      OriginalCreateProcessW(CreateProcessW),
      bHooked(false) {}

HookManager::~HookManager() {
    if (bHooked) UninstallHooks();
}

bool HookManager::InstallHooks() {
    if (bHooked) return true;
    
    std::cout << "[✓] Installing hooks..." << std::endl;
    
    if (!InitializeDetours()) {
        std::cerr << "[ERROR] Failed to initialize detours!" << std::endl;
        return false;
    }
    
    if (!HookMessageBoxW()) {
        std::cerr << "[ERROR] Failed to hook MessageBoxW!" << std::endl;
        return false;
    }
    
    if (!HookCreateProcessW()) {
        std::cerr << "[ERROR] Failed to hook CreateProcessW!" << std::endl;
        return false;
    }
    
    if (!FinalizeDetours()) {
        std::cerr << "[ERROR] Failed to finalize detours!" << std::endl;
        return false;
    }
    
    bHooked = true;
    Utils::Log("Hooks installed successfully.");
    std::cout << "[✓] Hooks installed successfully!" << std::endl;
    
    return true;
}

bool HookManager::UninstallHooks() {
    if (!bHooked) return true;
    
    std::cout << "[✓] Uninstalling hooks..." << std::endl;
    
    DetourTransactionBegin();
    DetourUpdateThread(GetCurrentThread());
    
    DetourDetach(&(PVOID&)OriginalMessageBoxW, HookedMessageBoxW);
    DetourDetach(&(PVOID&)OriginalCreateProcessW, HookedCreateProcessW);
    
    if (DetourTransactionCommit() != NO_ERROR) {
        std::cerr << "[ERROR] Failed to uninstall hooks!" << std::endl;
        return false;
    }
    
    bHooked = false;
    Utils::Log("Hooks uninstalled successfully.");
    std::cout << "[✓] Hooks uninstalled successfully!" << std::endl;
    
    return true;
}

bool HookManager::InitializeDetours() {
    DetourTransactionBegin();
    DetourUpdateThread(GetCurrentThread());
    return true;
}

bool HookManager::FinalizeDetours() {
    return DetourTransactionCommit() == NO_ERROR;
}

bool HookManager::HookMessageBoxW() {
    std::cout << "[✓] Hooking MessageBoxW..." << std::endl;
    DetourAttach(&(PVOID&)OriginalMessageBoxW, HookedMessageBoxW);
    return true;
}

bool HookManager::HookCreateProcessW() {
    std::cout << "[✓] Hooking CreateProcessW..." << std::endl;
    DetourAttach(&(PVOID&)OriginalCreateProcessW, HookedCreateProcessW);
    return true;
}

// ============================================================
// HOOKED FUNCTIONS
// ============================================================

int WINAPI HookManager::HookedMessageBoxW(HWND hWnd, LPCWSTR lpText, 
                                           LPCWSTR lpCaption, UINT uType) {
    // Log panggilan MessageBox
    std::string text = "MessageBox called: " + std::string(lpText, lpText + wcslen(lpText));
    Utils::Log(text);
    
    // Ubah caption jadi branded
    std::wstring newCaption = L"[NEXUS] " + std::wstring(lpCaption);
    
    // Ubah teks (opsional)
    std::wstring newText = L"NEXUS EXECUTOR says: " + std::wstring(lpText);
    
    // Panggil original dengan parameter yang dimodifikasi
    return OriginalMessageBoxW(hWnd, newText.c_str(), newCaption.c_str(), uType);
}

BOOL WINAPI HookManager::HookedCreateProcessW(
    LPCWSTR lpApplicationName, LPWSTR lpCommandLine,
    LPSECURITY_ATTRIBUTES lpProcessAttributes,
    LPSECURITY_ATTRIBUTES lpThreadAttributes,
    BOOL bInheritHandles, DWORD dwCreationFlags,
    LPVOID lpEnvironment, LPCWSTR lpCurrentDirectory,
    LPSTARTUPINFOW lpStartupInfo,
    LPPROCESS_INFORMATION lpProcessInformation) {
    
    // Log pembuatan proses
    std::string appName = lpApplicationName ? 
        std::string(lpApplicationName, lpApplicationName + wcslen(lpApplicationName)) : "NULL";
    Utils::Log("CreateProcessW called: " + appName);
    
    // Panggil original
    return OriginalCreateProcessW(
        lpApplicationName, lpCommandLine,
        lpProcessAttributes, lpThreadAttributes,
        bInheritHandles, dwCreationFlags,
        lpEnvironment, lpCurrentDirectory,
        lpStartupInfo, lpProcessInformation
    );
}

// ============================================================
// INLINE HOOK IMPLEMENTATION
// ============================================================

InlineHook::InlineHook() 
    : pTarget(nullptr), pHook(nullptr), pOriginal(nullptr), bHooked(false) {
    // JMP opcode (x86)
    hookBytes[0] = 0xE9;
    for (int i = 1; i < 5; ++i) hookBytes[i] = 0x90; // NOP
}

InlineHook::~InlineHook() {
    if (bHooked) RemoveHook();
}

bool InlineHook::InstallHook(LPVOID targetFunction, LPVOID hookFunction) {
    if (bHooked) return false;
    
    pTarget = targetFunction;
    pHook = hookFunction;
    
    // Backup bytes original
    if (!ReadBytes(pTarget, originalBytes, 5)) {
        return false;
    }
    
    // Hitung offset jump
    DWORD_PTR offset = (DWORD_PTR)hookFunction - (DWORD_PTR)targetFunction - 5;
    *(DWORD*)(hookBytes + 1) = (DWORD)offset;
    
    // Tulis jump
    if (!WriteJump(pTarget, pHook)) {
        return false;
    }
    
    bHooked = true;
    pOriginal = pTarget;
    
    return true;
}

bool InlineHook::RemoveHook() {
    if (!bHooked) return false;
    
    // Restore bytes original
    if (!WriteBytes(pTarget, originalBytes, 5)) {
        return false;
    }
    
    bHooked = false;
    return true;
}

bool InlineHook::WriteJump(LPVOID address, LPVOID jumpTo) {
    DWORD oldProtect = 0;
    VirtualProtect(address, 5, PAGE_EXECUTE_READWRITE, &oldProtect);
    
    BYTE jump[5];
    jump[0] = 0xE9;
    DWORD_PTR offset = (DWORD_PTR)jumpTo - (DWORD_PTR)address - 5;
    *(DWORD*)(jump + 1) = (DWORD)offset;
    
    memcpy(address, jump, 5);
    
    VirtualProtect(address, 5, oldProtect, &oldProtect);
    return true;
}

bool InlineHook::WriteBytes(LPVOID address, BYTE* bytes, SIZE_T size) {
    DWORD oldProtect = 0;
    VirtualProtect(address, size, PAGE_EXECUTE_READWRITE, &oldProtect);
    
    memcpy(address, bytes, size);
    
    VirtualProtect(address, size, oldProtect, &oldProtect);
    return true;
}

bool InlineHook::ReadBytes(LPVOID address, BYTE* buffer, SIZE_T size) {
    DWORD oldProtect = 0;
    VirtualProtect(address, size, PAGE_EXECUTE_READWRITE, &oldProtect);
    
    memcpy(buffer, address, size);
    
    VirtualProtect(address, size, oldProtect, &oldProtect);
    return true;
}