--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║    ██╗   ██╗██████╗ ███████╗                           ║
    ║    ██║   ██║██╔══██╗██╔════╝                           ║
    ║    ██║   ██║██████╔╝███████╗                           ║
    ║    ██║   ██║██╔══██╗╚════██║                           ║
    ║    ╚██████╔╝██║  ██║███████║                           ║
    ║     ╚═════╝ ╚═╝  ╚═╝╚══════╝                           ║
    ║                                                           ║
    ║         NEXUS JUJUTSU SHENANIGANS SCRIPT                ║
    ║          ANIME FIGHTER — AUTO BLOCK + COMBO             ║
    ║          AUTHOR: PROFESOR_FATIH + NEXUS 1.0             ║
    ║          VERSION: 1.0 — OVERPOWER 2026                  ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝
--]]

-- ============================================================
-- SERVICES
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService('VirtualUser')
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================================================
-- VARIABLES
-- ============================================================

_G.NexusJJS = {
    AutoBlock = false,
    AutoCombo = false,
    SpeedHack = false,
    SpeedValue = 24,
    Fly = false,
    Noclip = false,
    ESP = false,
    HitboxExpand = false,
}

-- ============================================================
-- AUTO BLOCK
-- ============================================================

local function AutoBlockLoop()
    while _G.NexusJJS.AutoBlock and task.wait(0.05) do
        pcall(function()
            -- Cari mekanik block di JJS (biasanya pake keybind atau input)
            UserInputService:SendKeyEvent(true, Enum.KeyCode.F, false, nil)
            task.wait(0.02)
            UserInputService:SendKeyEvent(false, Enum.KeyCode.F, false, nil)
        end)
    end
end

-- ============================================================
-- AUTO COMBO
-- ============================================================

local function AutoComboLoop()
    while _G.NexusJJS.AutoCombo and task.wait(0.2) do
        pcall(function()
            -- Simulasi combo: M1 + skill (biasanya key 1-4 atau Q,E,R)
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(1280, 672))
            task.wait(0.05)
            VirtualUser:Button1Up(Vector2.new(1280, 672))
            
            task.wait(0.1)
            UserInputService:SendKeyEvent(true, Enum.KeyCode.Q, false, nil)
            task.wait(0.05)
            UserInputService:SendKeyEvent(false, Enum.KeyCode.Q, false, nil)
            
            task.wait(0.1)
            UserInputService:SendKeyEvent(true, Enum.KeyCode.E, false, nil)
            task.wait(0.05)
            UserInputService:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
        end)
    end
end

-- ============================================================
-- FLY
-- ============================================================

local function FlyLoop()
    while _G.NexusJJS.Fly and task.wait(0.05) do
        pcall(function()
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local move = Vector3.new(
                    (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0),
                    (UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 1 or 0),
                    (UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
                )
                hrp.Velocity = move * 50
                hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 0.5
            end
        end)
    end
end

-- ============================================================
-- HITBOX EXPAND
-- ============================================================

local function HitboxExpandLoop()
    while _G.NexusJJS.HitboxExpand and task.wait(0.1) do
        pcall(function()
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Size = Vector3.new(10, 10, 10)
                hrp.CanCollide = false
            end
        end)
    end
    -- Reset hitbox
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Size = Vector3.new(2, 1, 1)
        hrp.CanCollide = true
    end
end

-- ============================================================
-- LOAD UI
-- ============================================================

local function LoadUI()
    local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()
    local Window = Rayfield:CreateWindow({
        Name = "☠️ NEXUS JJS ☠️",
        LoadingTitle = "NEXUS EXECUTOR",
        LoadingSubtitle = "by PROFESOR_FATIH + NEXUS 1.0",
        KeySystem = false,
    })

    local CombatTab = Window:CreateTab("⚔️ Combat", 4483362458)
    local CombatSection = CombatTab:CreateSection("Combat")

    CombatSection:CreateToggle({
        Name = "🛡️ Auto Block",
        CurrentValue = false,
        Callback = function(v) _G.NexusJJS.AutoBlock = v if v then task.spawn(AutoBlockLoop) end end,
    })

    CombatSection:CreateToggle({
        Name = "🌀 Auto Combo",
        CurrentValue = false,
        Callback = function(v) _G.NexusJJS.AutoCombo = v if v then task.spawn(AutoComboLoop) end end,
    })

    CombatSection:CreateToggle({
        Name = "💥 Hitbox Expand",
        CurrentValue = false,
        Callback = function(v) _G.NexusJJS.HitboxExpand = v if v then task.spawn(HitboxExpandLoop) end end,
    })

    local MoveTab = Window:CreateTab("🏃 Movement", 4483362458)
    local MoveSection = MoveTab:CreateSection("Movement")

    MoveSection:CreateToggle({
        Name = "🕊️ Fly",
        CurrentValue = false,
        Callback = function(v) _G.NexusJJS.Fly = v if v then task.spawn(FlyLoop) end end,
    })

    MoveSection:CreateToggle({
        Name = "🌀 Noclip",
        CurrentValue = false,
        Callback = function(v)
            _G.NexusJJS.Noclip = v
            if v then
                task.spawn(function()
                    while _G.NexusJJS.Noclip and task.wait(0.1) do
                        pcall(function()
                            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                        end)
                    end
                end)
            end
        end,
    })

    MoveSection:CreateToggle({
        Name = "💨 Speed Hack",
        CurrentValue = false,
        Callback = function(v)
            _G.NexusJJS.SpeedHack = v
            if v then
                task.spawn(function()
                    while _G.NexusJJS.SpeedHack and task.wait(0.1) do
                        pcall(function()
                            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                            if humanoid then humanoid.WalkSpeed = _G.NexusJJS.SpeedValue end
                        end)
                    end
                end)
            else
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid.WalkSpeed = 16 end
            end
        end,
    })

    MoveSection:CreateSlider({
        Name = "⚡ Speed Value",
        Range = {16, 100},
        Increment = 1,
        Suffix = " studs/s",
        CurrentValue = 24,
        Callback = function(v) _G.NexusJJS.SpeedValue = v end,
    })

    Rayfield:Notify({Title = "☠️ NEXUS JJS", Content = "Script loaded!", Duration = 3})
end

task.spawn(LoadUI)
print("✅ NEXUS JUJUTSU SHENANIGANS SCRIPT LOADED!")