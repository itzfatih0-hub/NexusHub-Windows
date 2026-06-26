// ============================================================
// NEXUS EXECUTOR — MAIN ENTRY POINT (C++)
// AUTHOR: PROFESOR_FATIH + NEXUS 1.0
// ============================================================

#include <windows.h>
#include <iostream>
#include "core/executor.h"

int main() {
    std::cout << "╔═══════════════════════════════════════════════╗" << std::endl;
    std::cout << "║    NEXUS EXECUTOR V1.0 — C++ CORE           ║" << std::endl;
    std::cout << "║    AUTHOR: PROFESOR_FATIH + NEXUS 1.0        ║" << std::endl;
    std::cout << "╚═══════════════════════════════════════════════╝" << std::endl;
    std::cout << std::endl;

    // Inisialisasi executor
    NexusExecutor executor;
    
    if (!executor.Initialize()) {
        std::cerr << "[ERROR] Failed to initialize executor!" << std::endl;
        return 1;
    }

    std::cout << "[✓] Executor initialized successfully!" << std::endl;
    std::cout << "[✓] Ready to inject into Roblox process." << std::endl;

    // Di sini nanti akan terintegrasi dengan Python GUI
    // atau berjalan sebagai service background.

    system("pause");
    return 0;
}