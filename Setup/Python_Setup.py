#!/usr/bin/env python3
# ============================================================
# PYTHON SETUP — NEXUS EXECUTOR DEPENDENCIES INSTALLER
# AUTHOR: PROFESOR_FATIH + NEXUS 1.0
# ============================================================

import os
import sys
import subprocess
import platform
import ctypes
import webbrowser
import time

# ============================================================
# KONFIGURASI
# ============================================================

VERSION = "1.0.0"
AUTHOR = "PROFESOR_FATIH + NEXUS 1.0"
PYTHON_VERSION = "3.12.0"
REQUIRED_PACKAGES = [
    "requests",
    "pillow",
    "pyinstaller",
    "tkinter"
]

# ============================================================
# UTILITY FUNCTIONS
# ============================================================

def is_admin():
    """Check if running as admin"""
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False

def run_as_admin():
    """Re-run script as admin"""
    ctypes.windll.shell32.ShellExecuteW(
        None,
        "runas",
        sys.executable,
        " ".join(sys.argv),
        None,
        1
    )
    sys.exit()

def print_banner():
    """Print nice banner"""
    print("""
    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║    ██████╗ ██╗   ██╗████████╗██╗  ██╗ ██████╗ ███╗   ██╗ ║
    ║    ██╔══██╗╚██╗ ██╔╝╚══██╔══╝██║  ██║██╔═══██╗████╗  ██║ ║
    ║    ██████╔╝ ╚████╔╝    ██║   ███████║██║   ██║██╔██╗ ██║ ║
    ║    ██╔═══╝   ╚██╔╝     ██║   ██╔══██║██║   ██║██║╚██╗██║ ║
    ║    ██║        ██║      ██║   ██║  ██║╚██████╔╝██║ ╚████║ ║
    ║    ╚═╝        ╚═╝      ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ ║
    ║                                                           ║
    ║              PYTHON SETUP — NEXUS EDITION               ║
    ║          AUTHOR: PROFESOR_FATIH + NEXUS 1.0             ║
    ║          VERSION: 1.0.0 — OVERPOWER 2026                ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝
    """)

def print_step(step, message):
    """Print step with nice formatting"""
    print(f"\n[✓] {step}: {message}")

def print_error(message):
    """Print error message"""
    print(f"\n[✗] ERROR: {message}")

def print_success(message):
    """Print success message"""
    print(f"\n[✓] SUCCESS: {message}")

# ============================================================
# CHECK FUNCTIONS
# ============================================================

def check_python():
    """Check if Python is installed"""
    try:
        result = subprocess.run(
            ["python", "--version"],
            capture_output=True,
            text=True
        )
        if result.returncode == 0:
            version = result.stdout.strip() or result.stderr.strip()
            print_step("Python", f"Found: {version}")
            return True
        return False
    except:
        return False

def check_pip():
    """Check if pip is installed"""
    try:
        result = subprocess.run(
            ["python", "-m", "pip", "--version"],
            capture_output=True,
            text=True
        )
        if result.returncode == 0:
            print_step("Pip", "Found!")
            return True
        return False
    except:
        return False

def check_package(package):
    """Check if a Python package is installed"""
    try:
        result = subprocess.run(
            ["python", "-c", f"import {package}"],
            capture_output=True,
            text=True
        )
        return result.returncode == 0
    except:
        return False

# ============================================================
# INSTALL FUNCTIONS
# ============================================================

def install_python():
    """Download and install Python"""
    print_step("Installing", "Python not found! Downloading...")
    
    # Deteksi sistem operasi
    system = platform.system()
    
    if system == "Windows":
        # Download Python installer
        python_installer = f"python-{PYTHON_VERSION}-amd64.exe"
        url = f"https://www.python.org/ftp/python/{PYTHON_VERSION}/{python_installer}"
        
        print(f"[✓] Downloading Python from: {url}")
        webbrowser.open(url)
        
        print("\n⚠️ SILAHKAN DOWNLOAD DAN INSTALL PYTHON MANUAL!")
        print("📌 JANGAN LUPA CENTANG 'Add Python to PATH' SAAT INSTALL!")
        print("📌 SETELAH INSTALL, RESTART TERMINAL INI!")
        
        input("\nTekan ENTER setelah Python selesai diinstall...")
        
        # Cek lagi
        if check_python():
            print_success("Python installed!")
            return True
        else:
            print_error("Python still not found! Please install manually.")
            return False
    
    elif system == "Linux" or system == "Darwin":
        print("[✓] Using package manager to install Python...")
        try:
            if system == "Linux":
                subprocess.run(["sudo", "apt", "update"], check=True)
                subprocess.run(["sudo", "apt", "install", "-y", "python3", "python3-pip"], check=True)
            elif system == "Darwin":
                subprocess.run(["brew", "install", "python"], check=True)
            return True
        except:
            print_error("Failed to install Python via package manager.")
            return False
    else:
        print_error(f"Unsupported system: {system}")
        return False

def install_pip():
    """Install pip if missing"""
    print_step("Installing", "Pip not found! Installing...")
    try:
        subprocess.run(
            ["python", "-m", "ensurepip", "--upgrade"],
            check=True
        )
        print_success("Pip installed!")
        return True
    except:
        print_error("Failed to install pip.")
        return False

def install_packages():
    """Install required Python packages"""
    print_step("Installing", "Checking required packages...")
    
    installed = []
    failed = []
    
    for package in REQUIRED_PACKAGES:
        print(f"  - {package}...", end=" ")
        if check_package(package):
            print("✅ Already installed")
            installed.append(package)
        else:
            print("⬇️ Installing...")
            try:
                subprocess.run(
                    ["python", "-m", "pip", "install", package],
                    capture_output=True,
                    check=True
                )
                print("  ✅ Installed!")
                installed.append(package)
            except:
                print("  ❌ Failed!")
                failed.append(package)
    
    return installed, failed

# ============================================================
# CREATE REQUIREMENTS.TXT
# ============================================================

def create_requirements():
    """Create requirements.txt file"""
    print_step("Creating", "requirements.txt...")
    with open("requirements.txt", "w") as f:
        for package in REQUIRED_PACKAGES:
            f.write(f"{package}\n")
    print_success("requirements.txt created!")

# ============================================================
# MAIN
# ============================================================

def main():
    # Admin check (Windows only)
    if platform.system() == "Windows" and not is_admin():
        print("[✓] Restarting as Administrator...")
        run_as_admin()
        return
    
    # Print banner
    print_banner()
    time.sleep(1)
    
    print("="*60)
    print("📌 PYTHON SETUP — NEXUS EXECUTOR")
    print(f"📌 VERSION: {VERSION}")
    print(f"📌 AUTHOR: {AUTHOR}")
    print("="*60)
    print()
    
    # STEP 1: Check Python
    print("[1/5] CHECKING PYTHON...")
    if not check_python():
        if not install_python():
            print_error("Python setup failed! Exiting...")
            input("\nTekan ENTER untuk keluar...")
            sys.exit(1)
    else:
        print_success("Python is installed!")
    
    # STEP 2: Check Pip
    print("\n[2/5] CHECKING PIP...")
    if not check_pip():
        if not install_pip():
            print_error("Pip setup failed! Exiting...")
            input("\nTekan ENTER untuk keluar...")
            sys.exit(1)
    else:
        print_success("Pip is installed!")
    
    # STEP 3: Install Packages
    print("\n[3/5] INSTALLING PACKAGES...")
    installed, failed = install_packages()
    if failed:
        print_error(f"Failed to install: {', '.join(failed)}")
        print("⚠️ Silakan install manual dengan: pip install <package>")
    else:
        print_success(f"All {len(installed)} packages installed!")
    
    # STEP 4: Create requirements.txt
    print("\n[4/5] CREATING REQUIREMENTS.TXT...")
    create_requirements()
    
    # STEP 5: Done
    print("\n[5/5] SETUP COMPLETE!")
    print("="*60)
    print("""
    ✅ PYTHON SETUP COMPLETE!
    
    📌 Yang sudah diinstall:
    - Python 3.12+
    - Pip
    - Requests
    - Pillow
    - PyInstaller
    - Tkinter
    
    📌 Next steps:
    1. Buka folder NexusExecutor
    2. Jalankan: python NexusExecutor.py
    3. Atau build EXE: pyinstaller --onefile --windowed NexusExecutor.py
    
    ⚠️ Jangan lupa: 
    - Pastikan Roblox sedang berjalan
    - Jalankan sebagai Administrator
    """)
    print("="*60)
    
    input("\nTekan ENTER untuk keluar...")

if __name__ == "__main__":
    main()
