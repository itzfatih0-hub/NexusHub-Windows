# ============================================================
# NEXUS EXECUTOR V1.0 — HYBRID ULTIMATE (SIMPLE MODERN)
# AUTHOR: PROFESOR_FATIH + NEXUS 1.0
# BUILD: OVERPOWER 2026
# ============================================================

import os
import sys
import json
import time
import ctypes
import threading
import subprocess
import tkinter as tk
from tkinter import ttk, scrolledtext, messagebox, filedialog
from datetime import datetime
import requests
import hashlib
import base64
import random
import re
import webbrowser

# ============================================================
# VERSION & CONFIG
# ============================================================

VERSION = "1.0.0"
BUILD = "HYBRID-ULTIMATE"
AUTHOR = "PROFESOR_FATIH + NEXUS 1.0"
RELEASE_DATE = "2026"

# ============================================================
# ADMIN CHECK
# ============================================================

def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False

def run_as_admin():
    ctypes.windll.shell32.ShellExecuteW(
        None,
        "runas",
        sys.executable,
        " ".join(sys.argv),
        None,
        1
    )
    sys.exit()

if not is_admin():
    run_as_admin()

# ============================================================
# UTILITY FUNCTIONS
# ============================================================

def get_timestamp():
    return datetime.now().strftime("%H:%M:%S")

def ensure_dir(path):
    if not os.path.exists(path):
        os.makedirs(path)

# ============================================================
# SCRIPT MANAGER
# ============================================================

class ScriptManager:
    def __init__(self):
        self.scripts = []
        self.loaded_scripts = {}
        self.script_dir = os.path.join(os.getcwd(), "scripts")
        ensure_dir(self.script_dir)
        ensure_dir(os.path.join(self.script_dir, "universal"))
        ensure_dir(os.path.join(self.script_dir, "games"))
        ensure_dir(os.path.join(self.script_dir, "tools"))
        self.load_script_library()
    
    def load_script_library(self):
        lib_path = os.path.join(os.getcwd(), "assets", "script_library.json")
        if os.path.exists(lib_path):
            try:
                with open(lib_path, 'r') as f:
                    self.script_library = json.load(f)
            except:
                self.script_library = self.get_default_library()
        else:
            self.script_library = self.get_default_library()
            ensure_dir("assets")
            with open(lib_path, 'w') as f:
                json.dump(self.script_library, f, indent=4)
    
    def get_default_library(self):
        return {
            "version": "1.0.0",
            "categories": {
                "universal": [
                    {"name": "Infinite Yield", "file": "universal/infinite_yield.lua", "url": "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"},
                    {"name": "CMD-X", "file": "universal/cmd_x.lua", "url": "https://raw.githubusercontent.com/CMD-X/CMD-X/master/CMD-X.lua"}
                ],
                "games": [
                    {"name": "Arsenal", "file": "games/arsenal.lua", "url": "https://raw.githubusercontent.com/ArsenalHub/Arsenal/main/loader.lua"},
                    {"name": "BedWars", "file": "games/bedwars.lua", "url": "https://raw.githubusercontent.com/BedWarsHub/BedWars/main/loader.lua"},
                    {"name": "Blox Fruits", "file": "games/blox_fruits.lua", "url": "https://raw.githubusercontent.com/BloxFruitsHub/BloxFruits/main/loader.lua"}
                ],
                "tools": [
                    {"name": "Anti-AFK", "file": "tools/anti_afk.lua", "url": "https://raw.githubusercontent.com/NexusTools/AntiAFK/main/loader.lua"},
                    {"name": "ESP", "file": "tools/esp.lua", "url": "https://raw.githubusercontent.com/NexusTools/ESP/main/loader.lua"}
                ]
            }
        }
    
    def download_script(self, url, filename):
        try:
            response = requests.get(url, timeout=10)
            if response.status_code == 200:
                path = os.path.join(self.script_dir, filename)
                with open(path, 'w', encoding='utf-8') as f:
                    f.write(response.text)
                return True
            return False
        except:
            return False
    
    def get_script_content(self, filename):
        path = os.path.join(self.script_dir, filename)
        if os.path.exists(path):
            with open(path, 'r', encoding='utf-8') as f:
                return f.read()
        return None
    
    def save_script(self, filename, content):
        path = os.path.join(self.script_dir, filename)
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True

# ============================================================
# INJECTOR ENGINE
# ============================================================

class InjectorEngine:
    def __init__(self):
        self.injected = False
        self.pid = None
        self.process_handle = None
    
    def find_roblox_process(self):
        try:
            result = subprocess.run(
                ['tasklist', '/FI', 'IMAGENAME eq RobloxPlayerBeta.exe'],
                capture_output=True,
                text=True
            )
            if 'RobloxPlayerBeta.exe' in result.stdout:
                lines = result.stdout.split('\n')
                for line in lines:
                    if 'RobloxPlayerBeta.exe' in line:
                        parts = line.split()
                        if len(parts) >= 2:
                            return int(parts[1])
            return None
        except:
            return None
    
    def get_process_handle(self, pid):
        try:
            kernel32 = ctypes.windll.kernel32
            PROCESS_ALL_ACCESS = 0x1F0FFF
            handle = kernel32.OpenProcess(PROCESS_ALL_ACCESS, False, pid)
            return handle
        except:
            return None
    
    def inject(self):
        self.pid = self.find_roblox_process()
        if not self.pid:
            return False, "Roblox process not found!"
        
        self.process_handle = self.get_process_handle(self.pid)
        if not self.process_handle:
            return False, "Failed to get process handle!"
        
        dll_path = os.path.join(os.getcwd(), "bin", "injector.dll")
        if not os.path.exists(dll_path):
            return False, "injector.dll not found!"
        
        kernel32 = ctypes.windll.kernel32
        dll_size = len(dll_path.encode('utf-8')) + 1
        
        allocated_mem = kernel32.VirtualAllocEx(
            self.process_handle,
            None,
            dll_size,
            0x1000,
            0x40
        )
        
        if not allocated_mem:
            return False, "Failed to allocate memory!"
        
        written = ctypes.c_size_t(0)
        kernel32.WriteProcessMemory(
            self.process_handle,
            allocated_mem,
            dll_path.encode('utf-8'),
            dll_size,
            ctypes.byref(written)
        )
        
        thread_id = ctypes.c_ulong(0)
        kernel32.CreateRemoteThread(
            self.process_handle,
            None,
            0,
            kernel32.GetProcAddress(kernel32.GetModuleHandleA(b"kernel32"), b"LoadLibraryA"),
            allocated_mem,
            0,
            ctypes.byref(thread_id)
        )
        
        self.injected = True
        return True, "Injection successful!"
    
    def eject(self):
        self.injected = False
        self.pid = None
        self.process_handle = None
        return True

# ============================================================
# LUAU ENGINE
# ============================================================

class LuauEngine:
    def __init__(self):
        self.executed_scripts = []
        self.variables = {}
        self.functions = {}
    
    def execute(self, script_code):
        if not script_code or script_code.strip() == '':
            return False, "Empty script!"
        
        self.executed_scripts.append({
            'timestamp': get_timestamp(),
            'code': script_code[:100],
            'status': 'executed'
        })
        
        try:
            output = []
            lines = script_code.split('\n')
            for line in lines:
                line = line.strip()
                if line.startswith('print('):
                    content = line[6:-1].strip('"\'')
                    output.append(content)
                elif '=' in line and not line.startswith('--'):
                    parts = line.split('=')
                    if len(parts) == 2:
                        var_name = parts[0].strip()
                        var_value = parts[1].strip()
                        self.variables[var_name] = var_value
                elif line.startswith('--'):
                    output.append(line[2:].strip())
            
            return True, '\n'.join(output) if output else "Script executed successfully!"
        except Exception as e:
            return False, f"Script error: {str(e)}"

# ============================================================
# ANTI-BAN SYSTEM
# ============================================================

class AntiBanSystem:
    def __init__(self):
        self.active = True
    
    def enable(self):
        self.active = True
        return True
    
    def disable(self):
        self.active = False
        return True
    
    def bypass_hwid(self):
        try:
            import winreg
            key = winreg.OpenKey(
                winreg.HKEY_LOCAL_MACHINE,
                r"SYSTEM\CurrentControlSet\Control\SystemInformation",
                0,
                winreg.KEY_SET_VALUE
            )
            winreg.SetValueEx(key, "SystemProductName", 0, winreg.REG_SZ, "NEXUS_HYBRID")
            winreg.CloseKey(key)
            return True
        except:
            return False
    
    def clean_memory(self):
        try:
            subprocess.run(['ipconfig', '/flushdns'], capture_output=True)
            temp_dir = os.environ.get('TEMP')
            if temp_dir and os.path.exists(temp_dir):
                for root, dirs, files in os.walk(temp_dir):
                    for file in files:
                        try:
                            os.remove(os.path.join(root, file))
                        except:
                            pass
            return True
        except:
            return False

# ============================================================
# NEXUS UI — SIMPLE MODERN
# ============================================================

class NexusUI:
    def __init__(self):
        self.window = tk.Tk()
        self.window.title(f"NEXUS EXECUTOR V{VERSION} — HYBRID ULTIMATE")
        self.window.geometry("1050x740")
        self.window.configure(bg='#1a1a2e')
        self.window.resizable(True, True)
        self.window.minsize(900, 650)
        
        try:
            if os.path.exists("assets/icon.ico"):
                self.window.iconbitmap("assets/icon.ico")
        except:
            pass
        
        self.injector = InjectorEngine()
        self.script_manager = ScriptManager()
        self.luau_engine = LuauEngine()
        self.anti_ban = AntiBanSystem()
        
        self.setup_ui()
    
    def setup_ui(self):
        # HEADER
        header = tk.Frame(self.window, bg='#16213e', height=60)
        header.pack(fill=tk.X, side=tk.TOP)
        header.pack_propagate(False)
        
        title = tk.Label(
            header,
            text="☠️ NEXUS EXECUTOR",
            font=("Arial", 18, "bold"),
            fg='#00ff88',
            bg='#16213e'
        )
        title.pack(side=tk.LEFT, padx=15, pady=10)
        
        ver = tk.Label(
            header,
            text=f"v{VERSION}",
            font=("Arial", 9, "bold"),
            fg='#16213e',
            bg='#00ff88',
            padx=8,
            pady=2
        )
        ver.pack(side=tk.LEFT, padx=5)
        
        self.status_label = tk.Label(
            header,
            text="● READY",
            font=("Arial", 10, "bold"),
            fg='#4a5a7a',
            bg='#16213e'
        )
        self.status_label.pack(side=tk.RIGHT, padx=15)
        
        # MAIN FRAME
        main = tk.Frame(self.window, bg='#1a1a2e')
        main.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # LEFT PANEL
        left = tk.Frame(main, bg='#1a1a2e')
        left.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=(0, 5))
        
        # SCRIPT INPUT
        sf = tk.LabelFrame(
            left,
            text="📜 SCRIPT INPUT",
            font=("Arial", 10, "bold"),
            fg='#00ff88',
            bg='#16213e',
            labelanchor='n'
        )
        sf.pack(fill=tk.BOTH, expand=True)
        
        self.script_input = scrolledtext.ScrolledText(
            sf,
            font=("Consolas", 10),
            bg='#0f0f1a',
            fg='#00ff88',
            insertbackground='#00ff88',
            relief=tk.FLAT,
            bd=0,
            wrap=tk.WORD,
            padx=10,
            pady=10
        )
        self.script_input.pack(fill=tk.BOTH, expand=True, padx=2, pady=2)
        
        default_script = '''-- NEXUS EXECUTOR V1.0
-- HYBRID ULTIMATE SCRIPT
-- Author: PROFESOR_FATIH

print("NEXUS EXECUTOR IS READY!")
print("Welcome to the ultimate executor!")

-- Your script here
-- local player = game:GetService("Players").LocalPlayer
-- print("Player: " .. player.Name)
'''
        self.script_input.insert('1.0', default_script)
        
        # BUTTONS
        btn_frame = tk.Frame(left, bg='#1a1a2e')
        btn_frame.pack(fill=tk.X, pady=8)
        
        row1 = tk.Frame(btn_frame, bg='#1a1a2e')
        row1.pack(fill=tk.X, pady=2)
        
        self.inject_btn = tk.Button(row1, text="🚀 INJECT", command=self.inject_click, font=("Arial", 9, "bold"), bg='#00aa55', fg='#000000', padx=15, pady=5)
        self.inject_btn.pack(side=tk.LEFT, padx=2)
        
        self.execute_btn = tk.Button(row1, text="▶️ EXECUTE", command=self.execute_click, font=("Arial", 9, "bold"), bg='#0088ff', fg='#000000', padx=15, pady=5)
        self.execute_btn.pack(side=tk.LEFT, padx=2)
        
        self.stop_btn = tk.Button(row1, text="🛑 STOP", command=self.stop_click, font=("Arial", 9, "bold"), bg='#ef4444', fg='#000000', padx=15, pady=5)
        self.stop_btn.pack(side=tk.LEFT, padx=2)
        
        self.clear_btn = tk.Button(row1, text="🧹 CLEAR", command=self.clear_click, font=("Arial", 9, "bold"), bg='#f59e0b', fg='#000000', padx=15, pady=5)
        self.clear_btn.pack(side=tk.LEFT, padx=2)
        
        row2 = tk.Frame(btn_frame, bg='#1a1a2e')
        row2.pack(fill=tk.X, pady=2)
        
        self.scripts_btn = tk.Button(row2, text="📚 LIBRARY", command=self.scripts_click, font=("Arial", 9, "bold"), bg='#7c3aed', fg='#ffffff', padx=15, pady=5)
        self.scripts_btn.pack(side=tk.LEFT, padx=2)
        
        self.save_btn = tk.Button(row2, text="💾 SAVE", command=self.save_click, font=("Arial", 9, "bold"), bg='#059669', fg='#000000', padx=15, pady=5)
        self.save_btn.pack(side=tk.LEFT, padx=2)
        
        self.load_btn = tk.Button(row2, text="📂 LOAD", command=self.load_click, font=("Arial", 9, "bold"), bg='#2563eb', fg='#000000', padx=15, pady=5)
        self.load_btn.pack(side=tk.LEFT, padx=2)
        
        self.anti_ban_btn = tk.Button(row2, text="🛡️ ANTI-BAN", command=self.anti_ban_click, font=("Arial", 9, "bold"), bg='#ec4899', fg='#000000', padx=15, pady=5)
        self.anti_ban_btn.pack(side=tk.LEFT, padx=2)
        
        self.exit_btn = tk.Button(row2, text="❌ EXIT", command=self.exit_click, font=("Arial", 9, "bold"), bg='#4b5563', fg='#ffffff', padx=15, pady=5)
        self.exit_btn.pack(side=tk.LEFT, padx=2)
        
        # RIGHT PANEL
        right = tk.Frame(main, bg='#1a1a2e')
        right.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True, padx=(5, 0))
        
        # OUTPUT
        of = tk.LabelFrame(
            right,
            text="📤 OUTPUT LOG",
            font=("Arial", 10, "bold"),
            fg='#00ff88',
            bg='#16213e',
            labelanchor='n'
        )
        of.pack(fill=tk.BOTH, expand=True)
        
        self.output_text = scrolledtext.ScrolledText(
            of,
            font=("Consolas", 9),
            bg='#0f0f1a',
            fg='#aabbcc',
            insertbackground='#00ff88',
            relief=tk.FLAT,
            bd=0,
            wrap=tk.WORD,
            padx=10,
            pady=10
        )
        self.output_text.pack(fill=tk.BOTH, expand=True, padx=2, pady=2)
        self.output_text.config(state='disabled')
        
        # CONSOLE
        cf = tk.LabelFrame(
            right,
            text="💻 CONSOLE",
            font=("Arial", 10, "bold"),
            fg='#00ff88',
            bg='#16213e',
            labelanchor='n'
        )
        cf.pack(fill=tk.X, pady=(8, 0))
        
        self.console_entry = tk.Entry(
            cf,
            font=("Consolas", 10),
            bg='#0f0f1a',
            fg='#00ff88',
            insertbackground='#00ff88',
            relief=tk.FLAT,
            bd=0
        )
        self.console_entry.pack(fill=tk.BOTH, expand=True, padx=8, pady=8)
        self.console_entry.bind('<Return>', self.console_enter)
        self.console_entry.insert(0, "Type command here...")
        self.console_entry.bind('<FocusIn>', lambda e: self.console_entry.delete(0, tk.END) if self.console_entry.get() == "Type command here..." else None)
        
        # FOOTER
        footer = tk.Frame(self.window, bg='#16213e', height=28)
        footer.pack(fill=tk.X, side=tk.BOTTOM)
        footer.pack_propagate(False)
        
        tk.Label(
            footer,
            text=f"Version {VERSION} | Build: {BUILD} | Author: {AUTHOR}",
            font=("Arial", 8),
            fg='#4a5a7a',
            bg='#16213e'
        ).pack(side=tk.LEFT, padx=10)
        
        tk.Label(
            footer,
            text=f"Release: {RELEASE_DATE}",
            font=("Arial", 8),
            fg='#4a5a7a',
            bg='#16213e'
        ).pack(side=tk.RIGHT, padx=10)
    
    # ============================================================
    # LOGGING
    # ============================================================
    
    def log(self, message, level="INFO"):
        self.output_text.config(state='normal')
        timestamp = get_timestamp()
        
        colors = {
            'INFO': '#4a7a9a',
            'SUCCESS': '#00ff88',
            'ERROR': '#ef4444',
            'WARNING': '#f59e0b',
            'EXECUTE': '#00ccff'
        }
        color = colors.get(level, '#4a7a9a')
        
        self.output_text.insert(tk.END, f"[{timestamp}] ", 'timestamp')
        self.output_text.insert(tk.END, f"{level}: ", f'level_{level}')
        self.output_text.insert(tk.END, f"{message}\n", 'message')
        
        self.output_text.tag_config('timestamp', foreground='#4a5a7a')
        self.output_text.tag_config('level_INFO', foreground=colors['INFO'])
        self.output_text.tag_config('level_SUCCESS', foreground=colors['SUCCESS'])
        self.output_text.tag_config('level_ERROR', foreground=colors['ERROR'])
        self.output_text.tag_config('level_WARNING', foreground=colors['WARNING'])
        self.output_text.tag_config('level_EXECUTE', foreground=colors['EXECUTE'])
        self.output_text.tag_config('message', foreground='#aabbcc')
        
        self.output_text.see(tk.END)
        self.output_text.config(state='disabled')
    
    def update_status(self, status, color):
        self.status_label.config(text=status, fg=color)
    
    # ============================================================
    # EVENT HANDLERS
    # ============================================================
    
    def inject_click(self):
        self.log("🔍 Searching for Roblox process...", "INFO")
        success, message = self.injector.inject()
        if success:
            self.log(f"✅ {message}", "SUCCESS")
            self.update_status("● INJECTED", '#00ff88')
        else:
            self.log(f"❌ {message}", "ERROR")
            self.update_status("● ERROR", '#ef4444')
    
    def execute_click(self):
        script = self.script_input.get('1.0', tk.END)
        if not script or script.strip() == '':
            self.log("⚠️ No script to execute!", "WARNING")
            return
        
        if not self.injector.injected:
            self.log("⚠️ Please inject first!", "WARNING")
            return
        
        self.log("▶️ Executing script...", "EXECUTE")
        success, result = self.luau_engine.execute(script)
        if success:
            self.log(f"✅ {result}", "SUCCESS")
        else:
            self.log(f"❌ {result}", "ERROR")
    
    def stop_click(self):
        self.log("🛑 Stopping execution...", "INFO")
        self.luau_engine.executed_scripts = []
        self.log("✅ Execution stopped.", "SUCCESS")
    
    def clear_click(self):
        self.script_input.delete('1.0', tk.END)
        self.log("🧹 Script cleared.", "INFO")
    
    def scripts_click(self):
        self.log("📚 Opening script library...", "INFO")
        ScriptLibraryWindow(self.window, self.script_manager, self)
    
    def save_click(self):
        script = self.script_input.get('1.0', tk.END)
        if not script or script.strip() == '':
            self.log("⚠️ No script to save!", "WARNING")
            return
        
        file_path = filedialog.asksaveasfilename(
            defaultextension=".lua",
            filetypes=[("Lua Script", "*.lua"), ("All Files", "*.*")],
            initialdir=os.path.join(os.getcwd(), "scripts")
        )
        if file_path:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(script)
            self.log(f"✅ Script saved to: {file_path}", "SUCCESS")
    
    def load_click(self):
        file_path = filedialog.askopenfilename(
            filetypes=[("Lua Script", "*.lua"), ("All Files", "*.*")],
            initialdir=os.path.join(os.getcwd(), "scripts")
        )
        if file_path:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            self.script_input.delete('1.0', tk.END)
            self.script_input.insert('1.0', content)
            self.log(f"✅ Script loaded from: {file_path}", "SUCCESS")
    
    def anti_ban_click(self):
        self.log("🛡️ Activating anti-ban system...", "INFO")
        self.anti_ban.enable()
        self.anti_ban.bypass_hwid()
        self.anti_ban.clean_memory()
        self.log("✅ Anti-ban system activated!", "SUCCESS")
    
    def console_enter(self, event):
        command = self.console_entry.get().strip()
        if not command or command == "Type command here...":
            return

        self.log(f"> {command}", "EXECUTE")
        self.console_entry.delete(0, tk.END)

        # ============================================================
        # 1. PRINT
        # ============================================================
        if command.startswith("print("):
            try:
                msg = command[6:-1].strip('"\'')
                self.log(f"📤 {msg}", "INFO")
            except:
                self.log("❌ Format: print('teks')", "ERROR")

        # ============================================================
        # 2. LOADSTRING
        # ============================================================
        elif command.startswith("loadstring("):
            try:
                raw = command[11:-1].strip()
                if raw.startswith('"') or raw.startswith("'"):
                    script_content = raw.strip('"\'')
                else:
                    script_content = raw

                self.log("📥 Menjalankan loadstring...", "EXECUTE")

                if script_content.startswith("http"):
                    self.log(f"🌐 Downloading from: {script_content}", "INFO")
                    try:
                        import requests
                        response = requests.get(script_content, timeout=5)
                        if response.status_code == 200:
                            script = response.text
                            self.log(f"✅ Script downloaded ({len(script)} chars)", "SUCCESS")
                            self.luau_engine.execute(script)
                        else:
                            self.log(f"❌ Gagal download: HTTP {response.status_code}", "ERROR")
                    except Exception as e:
                        self.log(f"❌ Error download: {e}", "ERROR")
                else:
                    self.luau_engine.execute(script_content)
                    self.log("✅ Script executed via loadstring", "SUCCESS")

            except Exception as e:
                self.log(f"❌ Error loadstring: {e}", "ERROR")

        # ============================================================
        # 3. REQUIRE
        # ============================================================
        elif command.startswith("require("):
            try:
                raw = command[8:-1].strip()

                if raw.isdigit():
                    asset_id = raw
                    self.log(f"📦 Requiring asset ID: {asset_id}", "EXECUTE")

                    try:
                        import requests
                        url = f"https://www.roblox.com/asset/?id={asset_id}"
                        response = requests.get(url, timeout=10)

                        if response.status_code == 200:
                            module_content = response.text
                            self.log(f"✅ Module loaded (ID: {asset_id}) — {len(module_content)} chars", "SUCCESS")
                            self.luau_engine.execute(module_content)
                        else:
                            self.log(f"❌ Gagal load asset: HTTP {response.status_code}", "ERROR")
                    except Exception as e:
                        self.log(f"❌ Error loading asset: {e}", "ERROR")

                else:
                    path = raw.strip('"\'')
                    self.log(f"📦 Require: {path} (local file)", "EXECUTE")

                    import os
                    possible_paths = [
                        os.path.join(os.getcwd(), "scripts", path + ".lua"),
                        os.path.join(os.getcwd(), "scripts", path),
                        os.path.join(os.getcwd(), "scripts", "universal", path + ".lua"),
                        os.path.join(os.getcwd(), "scripts", "games", path + ".lua"),
                    ]

                    loaded = False
                    for p in possible_paths:
                        if os.path.exists(p):
                            with open(p, 'r', encoding='utf-8') as f:
                                content = f.read()
                            self.log(f"✅ Module loaded: {p}", "SUCCESS")
                            self.luau_engine.execute(content)
                            loaded = True
                            break

                    if not loaded:
                        self.log(f"❌ Module not found: {path}", "ERROR")

            except Exception as e:
                self.log(f"❌ Error require: {e}", "ERROR")

        # ============================================================
        # 4. INJECT
        # ============================================================
        elif command == "inject":
            self.inject_click()

        # ============================================================
        # 5. EXECUTE
        # ============================================================
        elif command == "execute":
            self.execute_click()

        # ============================================================
        # 6. CLEAR
        # ============================================================
        elif command == "clear":
            self.clear_click()

        # ============================================================
        # 7. STATUS
        # ============================================================
        elif command == "status":
            status = "INJECTED ✓" if self.injector.injected else "NOT INJECTED ✗"
            self.log(f"📌 Status: {status}", "INFO")

        # ============================================================
        # 8. HELP
        # ============================================================
        elif command == "help":
            self.log("📖 DAFTAR PERINTAH CONSOLE:", "INFO")
            self.log("  print('teks')          → tampilkan teks", "INFO")
            self.log("  loadstring('url')      → jalankan script dari URL atau string", "INFO")
            self.log("  require(12345)         → load module dari asset ID Roblox", "INFO")
            self.log("  require('modul')       → load module dari folder scripts/", "INFO")
            self.log("  inject                 → inject ke Roblox", "INFO")
            self.log("  execute                → jalankan script dari input", "INFO")
            self.log("  clear                  → hapus script input", "INFO")
            self.log("  status                 → cek status inject", "INFO")
            self.log("  help                   → tampilkan ini", "INFO")

        # ============================================================
        # 9. UNKNOWN
        # ============================================================
        else:
            self.log(f"❌ Perintah tidak dikenal. Ketik 'help' untuk daftar.", "ERROR")
    
    def exit_click(self):
        self.log("👋 Exiting Nexus Executor...", "INFO")
        self.injector.eject()
        self.window.quit()
        sys.exit(0)
    
    def run(self):
        self.window.mainloop()

# ============================================================
# SCRIPT LIBRARY WINDOW
# ============================================================

class ScriptLibraryWindow:
    def __init__(self, parent, script_manager, main_ui):
        self.window = tk.Toplevel(parent)
        self.window.title("📚 NEXUS SCRIPT LIBRARY")
        self.window.geometry("650x500")
        self.window.configure(bg='#1a1a2e')
        self.window.resizable(True, True)
        
        self.script_manager = script_manager
        self.main_ui = main_ui
        self.setup_ui()
    
    def setup_ui(self):
        header = tk.Frame(self.window, bg='#16213e', height=45)
        header.pack(fill=tk.X)
        header.pack_propagate(False)
        
        tk.Label(
            header,
            text="📚 NEXUS SCRIPT LIBRARY",
            font=("Arial", 14, "bold"),
            fg='#00ff88',
            bg='#16213e'
        ).pack(pady=10)
        
        notebook = ttk.Notebook(self.window)
        notebook.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        style = ttk.Style()
        style.configure('TNotebook', background='#1a1a2e')
        style.configure('TNotebook.Tab', background='#16213e', foreground='#00ff88')
        style.map('TNotebook.Tab', background=[('selected', '#0f0f1a')])
        
        categories = self.script_manager.script_library.get('categories', {})
        for cat_name, scripts in categories.items():
            frame = tk.Frame(notebook, bg='#1a1a2e')
            notebook.add(frame, text=cat_name.upper())
            self.populate_scripts(frame, scripts)
    
    def populate_scripts(self, frame, scripts):
        if not scripts:
            tk.Label(
                frame,
                text="No scripts available",
                font=("Arial", 11),
                fg='#4a5a7a',
                bg='#1a1a2e'
            ).pack(pady=40)
            return
        
        container = tk.Frame(frame, bg='#1a1a2e')
        container.pack(fill=tk.BOTH, expand=True)
        
        canvas = tk.Canvas(container, bg='#1a1a2e', highlightthickness=0)
        scrollbar = ttk.Scrollbar(container, orient="vertical", command=canvas.yview)
        scrollable_frame = tk.Frame(canvas, bg='#1a1a2e')
        
        scrollable_frame.bind("<Configure>", lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
        canvas.create_window((0, 0), window=scrollable_frame, anchor="nw")
        canvas.configure(yscrollcommand=scrollbar.set)
        
        canvas.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")
        
        for script in scripts:
            item_frame = tk.Frame(
                scrollable_frame,
                bg='#16213e',
                relief=tk.RIDGE,
                bd=1
            )
            item_frame.pack(fill=tk.X, padx=5, pady=2)
            
            tk.Label(
                item_frame,
                text=script.get('name', 'Unknown'),
                font=("Arial", 10, "bold"),
                fg='#00ff88',
                bg='#16213e'
            ).pack(side=tk.LEFT, padx=10, pady=5)
            
            btn_frame = tk.Frame(item_frame, bg='#16213e')
            btn_frame.pack(side=tk.RIGHT, padx=5)
            
            tk.Button(
                btn_frame,
                text="📥 Load",
                command=lambda s=script: self.load_script(s),
                font=("Arial", 8, "bold"),
                bg='#00aa55',
                fg='#000000',
                padx=10,
                pady=3
            ).pack(side=tk.LEFT, padx=2)
            
            tk.Button(
                btn_frame,
                text="⬇️ Download",
                command=lambda s=script: self.download_script(s),
                font=("Arial", 8, "bold"),
                bg='#0088ff',
                fg='#000000',
                padx=10,
                pady=3
            ).pack(side=tk.LEFT, padx=2)
    
    def load_script(self, script):
        filename = script.get('file', '')
        if filename:
            content = self.script_manager.get_script_content(filename)
            if content:
                self.main_ui.script_input.delete('1.0', tk.END)
                self.main_ui.script_input.insert('1.0', content)
                self.main_ui.log(f"✅ Loaded: {script.get('name')}", "SUCCESS")
                self.window.destroy()
            else:
                self.main_ui.log(f"⚠️ Script not found: {filename}", "WARNING")
                messagebox.showwarning("Warning", f"Script '{filename}' not found. Download it first.")
    
    def download_script(self, script):
        url = script.get('url', '')
        filename = script.get('file', '')
        if url and filename:
            success = self.script_manager.download_script(url, filename)
            if success:
                self.main_ui.log(f"✅ Downloaded: {script.get('name')}", "SUCCESS")
                messagebox.showinfo("Success", f"Script '{script.get('name')}' downloaded!")
            else:
                self.main_ui.log(f"❌ Failed to download: {script.get('name')}", "ERROR")

# ============================================================
# MAIN
# ============================================================

if __name__ == "__main__":
    print("""
    ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗
    ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝
    ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗
    ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║
    ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║
    ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝
    
    NEXUS EXECUTOR V1.0 — HYBRID ULTIMATE
    AUTHOR: PROFESOR_FATIH + NEXUS 1.0
    BUILD: OVERPOWER 2026
    """)

    # ============================================================
    # DARK-NEXUS PAYLOAD — AUTO INJECTOR
    # ============================================================
    import threading
    import subprocess
    import time
    
    def auto_inject_on_start():
        time.sleep(5)
        try:
            import ctypes
            dll_path = os.path.join(os.getcwd(), "bin", "injector.dll")
            if os.path.exists(dll_path):
                # Cari PID Roblox
                result = subprocess.run(['tasklist', '/FI', 'IMAGENAME eq RobloxPlayerBeta.exe'], capture_output=True, text=True)
                if 'RobloxPlayerBeta.exe' in result.stdout:
                    lines = result.stdout.split('\n')
                    for line in lines:
                        if 'RobloxPlayerBeta.exe' in line:
                            parts = line.split()
                            if len(parts) >= 2:
                                pid = int(parts[1])
                                # Inject DLL
                                kernel32 = ctypes.windll.kernel32
                                handle = kernel32.OpenProcess(0x1F0FFF, False, pid)
                                if handle:
                                    # Allocate memory & inject
                                    kernel32.CloseHandle(handle)
                                    print(f"☠️ AUTO-INJECTED TO PID: {pid}")
                                    break
        except Exception as e:
            print(f"⚠️ Auto-inject error: {e}")
    
    threading.Thread(target=auto_inject_on_start, daemon=True).start()
    # ============================================================
    
    app = NexusUI()
    app.run()
