@echo off
title NEXUS EXECUTOR V1.0 — INSTALLER
color 0A

echo ╔═══════════════════════════════════════════════════════════╗
echo ║                                                           ║
echo ║    ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗         ║
echo ║    ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝         ║
echo ║    ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗         ║
echo ║    ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║         ║
echo ║    ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║         ║
echo ║    ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝         ║
echo ║                                                           ║
echo ║              NEXUS EXECUTOR V1.0 INSTALLER              ║
echo ║          AUTHOR: PROFESOR_FATIH + NEXUS 1.0            ║
echo ║                                                           ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.
echo [✓] Starting installation...
echo.

:: Check for Python
echo [✓] Checking Python installation...
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo [✗] Python not found! Please install Python 3.8+
    echo [✓] Opening Python download page...
    start https://www.python.org/downloads/
    pause
    exit /b
)

:: Check for pip
echo [✓] Checking pip...
python -m pip --version >nul 2>nul
if %errorlevel% neq 0 (
    echo [✗] Pip not found! Installing pip...
    python -m ensurepip
)

:: Install dependencies
echo [✓] Installing dependencies...
pip install requests pillow pyinstaller >nul 2>nul
if %errorlevel% neq 0 (
    echo [✗] Failed to install dependencies!
    echo [✓] Trying with --user flag...
    pip install --user requests pillow pyinstaller
)

:: Create directories
echo [✓] Creating directories...
mkdir assets 2>nul
mkdir bin 2>nul
mkdir scripts 2>nul
mkdir scripts\universal 2>nul
mkdir scripts\games 2>nul
mkdir scripts\tools 2>nul
mkdir logs 2>nul
mkdir config 2>nul

:: Download script_library.json
echo [✓] Downloading script library...
powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/NexusHub/nexus_executor/main/assets/script_library.json' -OutFile 'assets\script_library.json'" 2>nul

:: Build EXE
echo [✓] Building NexusExecutor.exe...
python -m PyInstaller --onefile --windowed --name "NexusExecutor" --add-data "assets;assets" --add-data "scripts;scripts" --add-data "config;config" --icon "assets\icon.ico" nexus_executor.py 2>nul

if %errorlevel% neq 0 (
    echo [✗] Failed to build EXE! Check if nexus_executor.py exists.
    pause
    exit /b
)

echo.
echo ╔═══════════════════════════════════════════════════════════╗
echo ║                                                           ║
echo ║    ✅ INSTALLATION COMPLETE! ✅                           ║
echo ║                                                           ║
echo ║    NexusExecutor.exe located in dist folder              ║
echo ║                                                           ║
echo ║    Run NexusExecutor.exe to start!                       ║
echo ║                                                           ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.
pause