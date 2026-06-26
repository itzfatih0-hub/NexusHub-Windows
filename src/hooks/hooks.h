// ============================================================
// hooks.h — API HOOKING
// AUTHOR: PROFESOR_FATIH + NEXUS 1.0
// ============================================================

#pragma once
#include <windows.h>
#include <string>
#include <map>

// ============================================================
// DETOURS HOOKING (Menggunakan Microsoft Detours)
// ============================================================

// Forward declaration untuk menghindari linker error
typedef int (WINAPI *MessageBoxW_t)(HWND, LPCWSTR, LPCWSTR, UINT);
typedef BOOL (WINAPI *CreateProcessW_t)(
    LPCWSTR, LPWSTR, LPSECURITY_ATTRIBUTES, LPSECURITY_ATTRIBUTES,
    BOOL, DWORD, LPVOID, LPCWSTR, LPSTARTUPINFOW, LPPROCESS_INFORMATION
);

class HookManager {
public:
    static HookManager& GetInstance();
    
    // Install/Uninstall hooks
    bool InstallHooks();
    bool UninstallHooks();
    
    // Hook individual functions
    bool HookMessageBoxW();
    bool HookCreateProcessW();
    
    // Check if hooks are active
    bool IsHooked() const { return bHooked; }

private:
    HookManager();
    ~HookManager();
    
    // Singleton pattern
    HookManager(const HookManager&) = delete;
    HookManager& operator=(const HookManager&) = delete;
    
    // Hooked functions
    static int WINAPI HookedMessageBoxW(HWND hWnd, LPCWSTR lpText, 
                                         LPCWSTR lpCaption, UINT uType);
    static BOOL WINAPI HookedCreateProcessW(
        LPCWSTR lpApplicationName, LPWSTR lpCommandLine,
        LPSECURITY_ATTRIBUTES lpProcessAttributes,
        LPSECURITY_ATTRIBUTES lpThreadAttributes,
        BOOL bInheritHandles, DWORD dwCreationFlags,
        LPVOID lpEnvironment, LPCWSTR lpCurrentDirectory,
        LPSTARTUPINFOW lpStartupInfo,
        LPPROCESS_INFORMATION lpProcessInformation
    );
    
    // Original function pointers
    MessageBoxW_t OriginalMessageBoxW;
    CreateProcessW_t OriginalCreateProcessW;
    
    bool bHooked;
    
    // Gunakan detours untuk hooking
    bool InitializeDetours();
    bool FinalizeDetours();
};

// ============================================================
// INLINE HOOKING (Tanpa Detours)
// ============================================================

class InlineHook {
public:
    InlineHook();
    ~InlineHook();
    
    bool InstallHook(LPVOID targetFunction, LPVOID hookFunction);
    bool RemoveHook();
    
    LPVOID GetOriginal() const { return pOriginal; }
    
private:
    LPVOID pTarget;
    LPVOID pHook;
    LPVOID pOriginal;
    BYTE originalBytes[5];
    BYTE hookBytes[5];
    bool bHooked;
    
    bool WriteJump(LPVOID address, LPVOID jumpTo);
    bool WriteBytes(LPVOID address, BYTE* bytes, SIZE_T size);
};