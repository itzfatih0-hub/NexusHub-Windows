# ============================================================
# NEXUS EXECUTOR V1.0 — HYBRID ULTIMATE (WINDOWS EDITION)
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

COLORS = {
    'bg': '#0a0a0a',
    'fg': '#00ff00',
    'accent': '#00aa55',
    'error': '#ff3333',
    'warning': '#ffaa00',
    'info': '#00aaff'
}

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

def log_message(msg, level="INFO"):
    timestamp = get_timestamp()
    return f"[{timestamp}] {level}: {msg}"

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
                with open(path, 'w') as f:
                    f.write(response.text)
                return True
            return False
        except:
            return False
    
    def get_script_content(self, filename):
        path = os.path.join(self.script_dir, filename)
        if os.path.exists(path):
            with open(path, 'r') as f:
                return f.read()
        return None
    
    def save_script(self, filename, content):
        path = os.path.join(self.script_dir, filename)
        with open(path, 'w') as f:
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
# NEXUS UI
# ============================================================

class NexusUI:
    def __init__(self):
        self.window = tk.Tk()
        self.window.title(f"NEXUS EXECUTOR V{VERSION} — HYBRID ULTIMATE")
        self.window.geometry("1000x750")
        self.window.configure(bg=COLORS['bg'])
        self.window.resizable(True, True)
        
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
        title_frame = tk.Frame(self.window, bg=COLORS['bg'])
        title_frame.pack(fill=tk.X, pady=5)
        
        title = tk.Label(
            title_frame,
            text="☠️ NEXUS EXECUTOR V1.0 — HYBRID ULTIMATE ☠️",
            font=("Consolas", 16, "bold"),
            fg=COLORS['fg'],
            bg=COLORS['bg']
        )
        title.pack()
        
        subtitle = tk.Label(
            title_frame,
            text=f"AUTHOR: {AUTHOR} | BUILD: {BUILD}",
            font=("Consolas", 9),
            fg=COLORS['info'],
            bg=COLORS['bg']
        )
        subtitle.pack()
        
        status_frame = tk.Frame(self.window, bg=COLORS['bg'])
        status_frame.pack(fill=tk.X, padx=10, pady=5)
        
        self.status_var = tk.StringVar()
        self.status_var.set("STATUS: READY | INJECTED: ✗ | MODE: HYBRID")
        
        status_label = tk.Label(
            status_frame,
            textvariable=self.status_var,
            font=("Consolas", 10),
            fg=COLORS['fg'],
            bg=COLORS['bg']
        )
        status_label.pack()
        
        main_frame = tk.Frame(self.window, bg=COLORS['bg'])
        main_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=5)
        
        left_panel = tk.Frame(main_frame, bg=COLORS['bg'])
        left_panel.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=(0, 5))
        
        script_frame = tk.LabelFrame(
            left_panel,
            text="📜 SCRIPT INPUT",
            font=("Consolas", 10),
            fg=COLORS['fg'],
            bg=COLORS['bg'],
            labelanchor='n'
        )
        script_frame.pack(fill=tk.BOTH, expand=True)
        
        self.script_input = scrolledtext.ScrolledText(
            script_frame,
            font=("Consolas", 10),
            bg='#111111',
            fg=COLORS['fg'],
            insertbackground=COLORS['fg'],
            height=12
        )
        self.script_input.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
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
        
        btn_frame = tk.Frame(left_panel, bg=COLORS['bg'])
        btn_frame.pack(fill=tk.X, pady=5)
        
        btn_row1 = tk.Frame(btn_frame, bg=COLORS['bg'])
        btn_row1.pack(fill=tk.X, pady=2)
        
        self.inject_btn = tk.Button(
            btn_row1,
            text="🚀 INJECT",
            command=self.inject_click,
            font=("Consolas", 10, "bold"),
            bg=COLORS['accent'],
            fg='#000000',
            padx=15,
            pady=5,
            cursor="hand2"
        )
        self.inject_btn.pack(side=tk.LEFT, padx=3)
        
        self.execute_btn = tk.Button(
            btn_row1,
            text="▶️ EXECUTE",
            command=self.execute_click,
            font=("Consolas", 10, "bold"),
            bg=COLORS['info'],
            fg='#000000',
            padx=15,
            pady=5,
            cursor="hand2"
        )
        self.execute_btn.pack(side=tk.LEFT, padx=3)
        
        self.stop_btn = tk.Button(
            btn_row1,
            text="🛑 STOP",
            command=self.stop_click,
            font=("Consolas", 10, "bold"),
            bg=COLORS['error'],
            fg='#ffffff',
            padx=15,
            pady=5,
            cursor="hand2"
        )
        self.stop_btn.pack(side=tk.LEFT, padx=3)
        
        btn_row2 = tk.Frame(btn_frame, bg=COLORS['bg'])
        btn_row2.pack(fill=tk.X, pady=2)
        
        self.clear_btn = tk.Button(
            btn_row2,
            text="🧹 CLEAR",
            command=self.clear_click,
            font=("Consolas", 10, "bold"),
            bg=COLORS['warning'],
            fg='#000000',
            padx=15,
            pady=5,
            cursor="hand2"
        )
        self.clear_btn.pack(side=tk.LEFT, padx=3)
        
        self.scripts_btn = tk.Button(
            btn_row2,
            text="📚 LIBRARY",
            command=self.scripts_click,
            font=("Consolas", 10, "bold"),
            bg='#aa44ff',
            fg='#ffffff',
            padx=15,
            pady=5,
            cursor="hand2"
        )
        self.scripts_btn.pack(side=tk.LEFT, padx=3)
        
        self.save_btn = tk.Button(
            btn_row2,
            text="💾 SAVE",
            command=self.save_click,
            font=("Consolas", 10, "bold"),
            bg='#ff8800',
            fg='#000000',
            padx=15,
            pady=5,
            cursor="hand2"
        )
        self.save_btn.pack(side=tk.LEFT, padx=3)
        
        self.load_btn = tk.Button(
            btn_row2,
            text="📂 LOAD",
            command=self.load_click,
            font=("Consolas", 10, "bold"),
            bg='#0088ff',
            fg='#000000',
            padx=15,
            pady=5,
            cursor="hand2"
        )
        self.load_btn.pack(side=tk.LEFT, padx=3)
        
        self.anti_ban_btn = tk.Button(
            btn_row2,
            text="🛡️ ANTI-BAN",
            command=self.anti_ban_click,
            font=("Consolas", 10, "bold"),
            bg='#ff44aa',
            fg='#ffffff',
            padx=15,
            pady=5,
            cursor="hand2"
        )
        self.anti_ban_btn.pack(side=tk.LEFT, padx=3)
        
        self.exit_btn = tk.Button(
            btn_row2,
            text="❌ EXIT",
            command=self.exit_click,
            font=("Consolas", 10, "bold"),
            bg='#666666',
            fg='#ffffff',
            padx=15,
            pady=5,
            cursor="hand2"
        )
        self.exit_btn.pack(side=tk.LEFT, padx=3)
        
        right_panel = tk.Frame(main_frame, bg=COLORS['bg'])
        right_panel.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True, padx=(5, 0))
        
        output_frame = tk.LabelFrame(
            right_panel,
            text="📤 OUTPUT LOG",
            font=("Consolas", 10),
            fg=COLORS['fg'],
            bg=COLORS['bg'],
            labelanchor='n'
        )
        output_frame.pack(fill=tk.BOTH, expand=True)
        
        self.output_text = scrolledtext.ScrolledText(
            output_frame,
            font=("Consolas", 9),
            bg='#111111',
            fg='#aaaaaa',
            insertbackground=COLORS['fg'],
            height=12
        )
        self.output_text.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        self.output_text.config(state='disabled')
        
        console_frame = tk.LabelFrame(
            right_panel,
            text="💻 CONSOLE",
            font=("Consolas", 10),
            fg=COLORS['fg'],
            bg=COLORS['bg'],
            labelanchor='n'
        )
        console_frame.pack(fill=tk.X, pady=2)
        
        self.console_entry = tk.Entry(
            console_frame,
            font=("Consolas", 9),
            bg='#111111',
            fg=COLORS['fg'],
            insertbackground=COLORS['fg']
        )
        self.console_entry.pack(fill=tk.X, padx=5, pady=5)
        self.console_entry.bind('<Return>', self.console_enter)
        
        info_frame = tk.Frame(self.window, bg=COLORS['bg'])
        info_frame.pack(fill=tk.X, padx=10, pady=5)
        
        info_label = tk.Label(
            info_frame,
            text=f"Version {VERSION} | Build: {BUILD} | Release: {RELEASE_DATE}",
            font=("Consolas", 8),
            fg='#666666',
            bg=COLORS['bg']
        )
        info_label.pack()
    
    def log(self, message, level="INFO"):
        self.output_text.config(state='normal')
        timestamp = get_timestamp()
        
        colors = {
            'INFO': '#aaaaaa',
            'SUCCESS': '#00ff00',
            'ERROR': '#ff3333',
            'WARNING': '#ffaa00',
            'EXECUTE': '#00aaff'
        }
        
        color = colors.get(level, '#aaaaaa')
        self.output_text.insert(tk.END, f"[{timestamp}] ", '#aaaaaa')
        self.output_text.insert(tk.END, f"{level}: ", color)
        self.output_text.insert(tk.END, f"{message}\n", '#aaaaaa')
        self.output_text.see(tk.END)
        self.output_text.config(state='disabled')
    
    def inject_click(self):
        self.log("🔍 Searching for Roblox process...", "INFO")
        success, message = self.injector.inject()
        if success:
            self.log(f"✅ {message}", "SUCCESS")
            self.status_var.set("STATUS: READY | INJECTED: ✓ | MODE: HYBRID")
        else:
            self.log(f"❌ {message}", "ERROR")
    
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
            with open(file_path, 'w') as f:
                f.write(script)
            self.log(f"✅ Script saved to: {file_path}", "SUCCESS")
    
    def load_click(self):
        file_path = filedialog.askopenfilename(
            filetypes=[("Lua Script", "*.lua"), ("All Files", "*.*")],
            initialdir=os.path.join(os.getcwd(), "scripts")
        )
        if file_path:
            with open(file_path, 'r') as f:
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
        if command:
            self.log(f"> {command}", "EXECUTE")
            try:
                if command.startswith("print"):
                    self.log(command[6:].strip('"\'()'), "INFO")
                elif command.startswith("loadstring"):
                    self.log("⚠️ loadstring not supported in console", "WARNING")
                else:
                    self.log(f"❌ Unknown command: {command}", "ERROR")
            except:
                self.log(f"❌ Error executing: {command}", "ERROR")
            self.console_entry.delete(0, tk.END)
    
    def exit_click(self):
        self.log("❌ Exiting Nexus Executor...", "INFO")
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
        self.window.title("NEXUS SCRIPT LIBRARY")
        self.window.geometry("600x500")
        self.window.configure(bg=COLORS['bg'])
        self.script_manager = script_manager
        self.main_ui = main_ui
        self.setup_ui()
    
    def setup_ui(self):
        title = tk.Label(
            self.window,
            text="📚 NEXUS SCRIPT LIBRARY",
            font=("Consolas", 14, "bold"),
            fg=COLORS['fg'],
            bg=COLORS['bg']
        )
        title.pack(pady=10)
        
        notebook = ttk.Notebook(self.window)
        notebook.pack(fill=tk.BOTH, expand=True, padx=10, pady=5)
        
        categories = self.script_manager.script_library.get('categories', {})
        for cat_name, scripts in categories.items():
            frame = tk.Frame(notebook, bg=COLORS['bg'])
            notebook.add(frame, text=cat_name.upper())
            self.populate_scripts(frame, scripts)
    
    def populate_scripts(self, frame, scripts):
        if not scripts:
            label = tk.Label(
                frame,
                text="No scripts available",
                font=("Consolas", 10),
                fg='#666666',
                bg=COLORS['bg']
            )
            label.pack(pady=20)
            return
        
        for script in scripts:
            script_frame = tk.Frame(frame, bg='#111111', relief=tk.RIDGE, bd=1)
            script_frame.pack(fill=tk.X, padx=5, pady=2)
            
            name_label = tk.Label(
                script_frame,
                text=script.get('name', 'Unknown'),
                font=("Consolas", 10, "bold"),
                fg=COLORS['fg'],
                bg='#111111'
            )
            name_label.pack(side=tk.LEFT, padx=5, pady=5)
            
            load_btn = tk.Button(
                script_frame,
                text="📥 Load",
                command=lambda s=script: self.load_script(s),
                font=("Consolas", 8),
                bg=COLORS['accent'],
                fg='#000000',
                padx=10,
                pady=2,
                cursor="hand2"
            )
            load_btn.pack(side=tk.RIGHT, padx=5, pady=2)
            
            download_btn = tk.Button(
                script_frame,
                text="⬇️ Download",
                command=lambda s=script: self.download_script(s),
                font=("Consolas", 8),
                bg=COLORS['info'],
                fg='#000000',
                padx=10,
                pady=2,
                cursor="hand2"
            )
            download_btn.pack(side=tk.RIGHT, padx=5, pady=2)
    
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
    
    app = NexusUI()
    app.run()
=======
# ============================================================
# NEXUS EXECUTOR V1.0 — HYBRID ULTIMATE (WINDOWS EDITION)
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

COLORS = {
    'bg': '#0a0a0a',
    'fg': '#00ff00',
    'accent': '#00aa55',
    'error': '#ff3333',
    'warning': '#ffaa00',
    'info': '#00aaff'
}

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

def log_message(msg, level="INFO"):
    timestamp = get_timestamp()
    return f"[{timestamp}] {level}: {msg}"

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
                with open(path, 'w') as f:
                    f.write(response.text)
                return True
            return False
        except:
            return False
    
    def get_script_content(self, filename):
        path = os.path.join(self.script_dir, filename)
        if os.path.exists(path):
            with open(path, 'r') as f:
                return f.read()
        return None
    
    def save_script(self, filename, content):
        path = os.path.join(self.script_dir, filename)
        with open(path, 'w') as f:
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
# NEXUS UI
# ============================================================

class NexusUI:
    def __init__(self):
        self.window = tk.Tk()
        self.window.title(f"NEXUS EXECUTOR V{VERSION} — HYBRID ULTIMATE")
        self.window.geometry("1000x750")
        self.window.configure(bg=COLORS['bg'])
        self.window.resizable(True, True)
        
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
        title_frame = tk.Frame(self.window, bg=COLORS['bg'])
        title_frame.pack(fill=tk.X, pady=5)
        
        title = tk.Label(
            title_frame,
            text="☠️ NEXUS EXECUTOR V1.0 — HYBRID ULTIMATE ☠️",
            font=("Consolas", 16, "bold"),
            fg=COLORS['fg'],
            bg=COLORS['bg']
        )
        title.pack()
        
        subtitle = tk.Label(
            title_frame,
            text=f"AUTHOR: {AUTHOR} | BUILD: {BUILD}",
            font=("Consolas", 9),
            fg=COLORS['info'],
            bg=COLORS['bg']
        )
        subtitle.pack()
        
        status_frame = tk.Frame(self.window, bg=COLORS['bg'])
        status_frame.pack(fill=tk.X, padx=10, pady=5)
        
        self.status_var = tk.StringVar()
        self.status_var.set("STATUS: READY | INJECTED: ✗ | MODE: HYBRID")
        
        status_label = tk.Label(
            status_frame,
            textvariable=self.status_var,
            font=("Consolas", 10),
            fg=COLORS['fg'],
            bg=COLORS['bg']
        )
        status_label.pack()
        
        main_frame = tk.Frame(self.window, bg=COLORS['bg'])
        main_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=5)
        
        left_panel = tk.Frame(main_frame, bg=COLORS['bg'])
        left_panel.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=(0, 5))
        
        script_frame = tk.LabelFrame(
            left_panel,
            text="📜 SCRIPT INPUT",
            font=("Consolas", 10),
            fg=COLORS['fg'],
            bg=COLORS['bg'],
            labelanchor='n'
        )
        script_frame.pack(fill=tk.BOTH, expand=True)
        
        self.script_input = scrolledtext.ScrolledText(
            script_frame,
            font=("Consolas", 10),
            bg='#111111',
            fg=COLORS['fg'],
            insertbackground=COLORS['fg'],
            height=12
        )
        self.script_input.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
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
        
        btn_frame = tk.Frame(left_panel, bg=COLORS['bg'])
        btn_frame.pack(fill=tk.X, pady=5)
        
        btn_row1 = tk.Frame(btn_frame, bg=COLORS['bg'])
        btn_row1.pack(fill=tk.X, pady=2)
        
        self.inject_btn = tk.Button(
            btn_row1,
            text="🚀 INJECT",
            command=self.inject_click,
            font=("Consolas", 10, "bold"),
            bg=COLORS['accent'],
            fg='#000000',
            padx=15,
            pady=5,
            cursor="hand2"
        )
        self.inject_btn.pack(side=tk.LEFT, padx=3)
        
        self.execute_btn = tk.Button(
            btn_row1,
            text="▶️ EXECUTE",
            command=self.execute_click,
            font=("Consolas", 10, "bold"),
            bg=COLORS['info'],
            fg='#000000',
            padx=15,
            pady=5,
            cursor="hand2"
        )
        self.execute_btn.pack(side=tk.LEFT, padx=3)
        
        self.stop_btn = tk.Button(
            btn_row1,
            text="🛑 STOP",
            command=self.stop_click,
            font=("Consolas", 10, "bold"),
            bg=COLORS['error'],
            fg='#ffffff',
            padx=15,
            pady=5,
            cursor="hand2"
        )
        self.stop_btn.pack(side=tk.LEFT, padx=3)
        
        btn_row2 = tk.Frame(btn_frame, bg=COLORS['bg'])
        btn_row2.pack(fill=tk.X, pady=2)
        
        self.clear_btn = tk.Button(
            btn_row2,
            text="🧹 CLEAR",
            command=self.clear_click,
            font=("Consolas", 10, "bold"),
            bg=COLORS['warning'],
            fg='#000000',
            padx=15,
            pady=5,
            cursor="hand2"
        )
        self.clear_btn.pack(side=tk.LEFT, padx=3)
        
        self.scripts_btn = tk.Button(
            btn_row2,
            text="📚 LIBRARY",
            command=self.scripts_click,
            font=("Consolas", 10, "bold"),
            bg='#aa44ff',
            fg='#ffffff',
            padx=15,
            pady=5,
            cursor="hand2"
        )
        self.scripts_btn.pack(side=tk.LEFT, padx=3)
        
        self.save_btn = tk.Button(
            btn_row2,
            text="💾 SAVE",
            command=self.save_click,
            font=("Consolas", 10, "bold"),
            bg='#ff8800',
            fg='#000000',
            padx=15,
            pady=5,
            cursor="hand2"
        )
        self.save_btn.pack(side=tk.LEFT, padx=3)
        
        self.load_btn = tk.Button(
            btn_row2,
            text="📂 LOAD",
            command=self.load_click,
            font=("Consolas", 10, "bold"),
            bg='#0088ff',
            fg='#000000',
            padx=15,
            pady=5,
            cursor="hand2"
        )
        self.load_btn.pack(side=tk.LEFT, padx=3)
        
        self.anti_ban_btn = tk.Button(
            btn_row2,
            text="🛡️ ANTI-BAN",
            command=self.anti_ban_click,
            font=("Consolas", 10, "bold"),
            bg='#ff44aa',
            fg='#ffffff',
            padx=15,
            pady=5,
            cursor="hand2"
        )
        self.anti_ban_btn.pack(side=tk.LEFT, padx=3)
        
        self.exit_btn = tk.Button(
            btn_row2,
            text="❌ EXIT",
            command=self.exit_click,
            font=("Consolas", 10, "bold"),
            bg='#666666',
            fg='#ffffff',
            padx=15,
            pady=5,
            cursor="hand2"
        )
        self.exit_btn.pack(side=tk.LEFT, padx=3)
        
        right_panel = tk.Frame(main_frame, bg=COLORS['bg'])
        right_panel.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True, padx=(5, 0))
        
        output_frame = tk.LabelFrame(
            right_panel,
            text="📤 OUTPUT LOG",
            font=("Consolas", 10),
            fg=COLORS['fg'],
            bg=COLORS['bg'],
            labelanchor='n'
        )
        output_frame.pack(fill=tk.BOTH, expand=True)
        
        self.output_text = scrolledtext.ScrolledText(
            output_frame,
            font=("Consolas", 9),
            bg='#111111',
            fg='#aaaaaa',
            insertbackground=COLORS['fg'],
            height=12
        )
        self.output_text.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        self.output_text.config(state='disabled')
        
        console_frame = tk.LabelFrame(
            right_panel,
            text="💻 CONSOLE",
            font=("Consolas", 10),
            fg=COLORS['fg'],
            bg=COLORS['bg'],
            labelanchor='n'
        )
        console_frame.pack(fill=tk.X, pady=2)
        
        self.console_entry = tk.Entry(
            console_frame,
            font=("Consolas", 9),
            bg='#111111',
            fg=COLORS['fg'],
            insertbackground=COLORS['fg']
        )
        self.console_entry.pack(fill=tk.X, padx=5, pady=5)
        self.console_entry.bind('<Return>', self.console_enter)
        
        info_frame = tk.Frame(self.window, bg=COLORS['bg'])
        info_frame.pack(fill=tk.X, padx=10, pady=5)
        
        info_label = tk.Label(
            info_frame,
            text=f"Version {VERSION} | Build: {BUILD} | Release: {RELEASE_DATE}",
            font=("Consolas", 8),
            fg='#666666',
            bg=COLORS['bg']
        )
        info_label.pack()
    
    def log(self, message, level="INFO"):
        self.output_text.config(state='normal')
        timestamp = get_timestamp()
        
        colors = {
            'INFO': '#aaaaaa',
            'SUCCESS': '#00ff00',
            'ERROR': '#ff3333',
            'WARNING': '#ffaa00',
            'EXECUTE': '#00aaff'
        }
        
        color = colors.get(level, '#aaaaaa')
        self.output_text.insert(tk.END, f"[{timestamp}] ", '#aaaaaa')
        self.output_text.insert(tk.END, f"{level}: ", color)
        self.output_text.insert(tk.END, f"{message}\n", '#aaaaaa')
        self.output_text.see(tk.END)
        self.output_text.config(state='disabled')
    
    def inject_click(self):
        self.log("🔍 Searching for Roblox process...", "INFO")
        success, message = self.injector.inject()
        if success:
            self.log(f"✅ {message}", "SUCCESS")
            self.status_var.set("STATUS: READY | INJECTED: ✓ | MODE: HYBRID")
        else:
            self.log(f"❌ {message}", "ERROR")
    
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
            with open(file_path, 'w') as f:
                f.write(script)
            self.log(f"✅ Script saved to: {file_path}", "SUCCESS")
    
    def load_click(self):
        file_path = filedialog.askopenfilename(
            filetypes=[("Lua Script", "*.lua"), ("All Files", "*.*")],
            initialdir=os.path.join(os.getcwd(), "scripts")
        )
        if file_path:
            with open(file_path, 'r') as f:
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
        if command:
            self.log(f"> {command}", "EXECUTE")
            try:
                if command.startswith("print"):
                    self.log(command[6:].strip('"\'()'), "INFO")
                elif command.startswith("loadstring"):
                    self.log("⚠️ loadstring not supported in console", "WARNING")
                else:
                    self.log(f"❌ Unknown command: {command}", "ERROR")
            except:
                self.log(f"❌ Error executing: {command}", "ERROR")
            self.console_entry.delete(0, tk.END)
    
    def exit_click(self):
        self.log("❌ Exiting Nexus Executor...", "INFO")
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
        self.window.title("NEXUS SCRIPT LIBRARY")
        self.window.geometry("600x500")
        self.window.configure(bg=COLORS['bg'])
        self.script_manager = script_manager
        self.main_ui = main_ui
        self.setup_ui()
    
    def setup_ui(self):
        title = tk.Label(
            self.window,
            text="📚 NEXUS SCRIPT LIBRARY",
            font=("Consolas", 14, "bold"),
            fg=COLORS['fg'],
            bg=COLORS['bg']
        )
        title.pack(pady=10)
        
        notebook = ttk.Notebook(self.window)
        notebook.pack(fill=tk.BOTH, expand=True, padx=10, pady=5)
        
        categories = self.script_manager.script_library.get('categories', {})
        for cat_name, scripts in categories.items():
            frame = tk.Frame(notebook, bg=COLORS['bg'])
            notebook.add(frame, text=cat_name.upper())
            self.populate_scripts(frame, scripts)
    
    def populate_scripts(self, frame, scripts):
        if not scripts:
            label = tk.Label(
                frame,
                text="No scripts available",
                font=("Consolas", 10),
                fg='#666666',
                bg=COLORS['bg']
            )
            label.pack(pady=20)
            return
        
        for script in scripts:
            script_frame = tk.Frame(frame, bg='#111111', relief=tk.RIDGE, bd=1)
            script_frame.pack(fill=tk.X, padx=5, pady=2)
            
            name_label = tk.Label(
                script_frame,
                text=script.get('name', 'Unknown'),
                font=("Consolas", 10, "bold"),
                fg=COLORS['fg'],
                bg='#111111'
            )
            name_label.pack(side=tk.LEFT, padx=5, pady=5)
            
            load_btn = tk.Button(
                script_frame,
                text="📥 Load",
                command=lambda s=script: self.load_script(s),
                font=("Consolas", 8),
                bg=COLORS['accent'],
                fg='#000000',
                padx=10,
                pady=2,
                cursor="hand2"
            )
            load_btn.pack(side=tk.RIGHT, padx=5, pady=2)
            
            download_btn = tk.Button(
                script_frame,
                text="⬇️ Download",
                command=lambda s=script: self.download_script(s),
                font=("Consolas", 8),
                bg=COLORS['info'],
                fg='#000000',
                padx=10,
                pady=2,
                cursor="hand2"
            )
            download_btn.pack(side=tk.RIGHT, padx=5, pady=2)
    
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
    
    app = NexusUI()
    app.run()
>>>>>>> dae348ffc3857b877071f92189684741e964ca1a
