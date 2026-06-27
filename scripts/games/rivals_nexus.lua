--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║    ██████╗  ██╗██╗   ██╗ █████╗ ██╗     ███████╗        ║
    ║    ██╔══██╗██║██║   ██║██╔══██╗██║     ██╔════╝        ║
    ║    ██████╔╝██║██║   ██║███████║██║     ███████╗        ║
    ║    ██╔══██╗██║╚██╗ ██╔╝██╔══██║██║     ╚════██║        ║
    ║    ██║  ██║██║ ╚████╔╝ ██║  ██║███████╗███████║        ║
    ║    ╚═╝  ╚═╝╚═╝  ╚═══╝  ╚═╝  ╚═╝╚══════╝╚══════╝        ║
    ║                                                           ║
    ║                 NEXUS RIVALS SCRIPT                      ║
    ║          FPS — AIMBOT + ESP + RAGE MODE                 ║
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

_G.NexusRivals = {
    Aimbot = false,
    SilentAim = false,
    TriggerBot = false,
    ESP = false,
    NoRecoil = false,
    InfiniteJump = false,
    SpeedHack = false,
    SpeedValue = 24,
    FOV = 200,
    Smoothness = 5,
    AimPart = "Head",
}

-- ============================================================
-- AIMBOT
-- ============================================================

local function GetClosestPlayer()
    local closest, closestDist = nil, _G.NexusRivals.FOV
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = player
                    end
                end
            end
        end
    end
    return closest
end

local function AimbotLoop()
    while _G.NexusRivals.Aimbot and task.wait() do
        pcall(function()
            local target = GetClosestPlayer()
            if not target then return end
            local aimPart = target.Character:FindFirstChild(_G.NexusRivals.AimPart) or target.Character:FindFirstChild("HumanoidRootPart")
            if not aimPart then return end
            local screenPos, onScreen = Camera:WorldToScreenPoint(aimPart.Position)
            if not onScreen then return end
            local delta = Vector2.new(screenPos.X - Mouse.X, screenPos.Y - Mouse.Y)
            mousemoverel(delta.X / _G.NexusRivals.Smoothness, delta.Y / _G.NexusRivals.Smoothness)
        end)
    end
end

-- ============================================================
-- TRIGGERBOT
-- ============================================================

local function TriggerBotLoop()
    while _G.NexusRivals.TriggerBot and task.wait(0.05) do
        pcall(function()
            local target = GetClosestPlayer()
            if not target then return end
            local aimPart = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
            if not aimPart then return end
            local screenPos, onScreen = Camera:WorldToScreenPoint(aimPart.Position)
            if onScreen then
                local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if dist < 50 then
                    VirtualUser:CaptureController()
                    VirtualUser:Button1Down(Vector2.new(1280, 672))
                    task.wait(0.05)
                    VirtualUser:Button1Up(Vector2.new(1280, 672))
                end
            end
        end)
    end
end

-- ============================================================
-- ESP
-- ============================================================

local ESPObjects = {}

local function ESPLoop()
    while _G.NexusRivals.ESP and task.wait(0.1) do
        pcall(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        if not ESPObjects[player] then
                            local box = Drawing.new("Square")
                            box.Color = Color3.new(1, 0, 0)
                            box.Thickness = 2
                            box.Filled = false
                            box.Transparency = 0.5
                            local name = Drawing.new("Text")
                            name.Text = player.Name
                            name.Color = Color3.new(1, 1, 1)
                            name.Size = 14
                            name.Center = true
                            name.Outline = true
                            name.OutlineColor = Color3.new(0, 0, 0)
                            ESPObjects[player] = {box = box, name = name}
                        end
                        local pos, onScreen = Camera:WorldToScreenPoint(hrp.Position)
                        if onScreen then
                            ESPObjects[player].box.Size = Vector2.new(50, 100)
                            ESPObjects[player].box.Position = Vector2.new(pos.X - 25, pos.Y - 50)
                            ESPObjects[player].box.Visible = true
                            ESPObjects[player].name.Position = Vector2.new(pos.X, pos.Y - 60)
                            ESPObjects[player].name.Visible = true
                        else
                            ESPObjects[player].box.Visible = false
                            ESPObjects[player].name.Visible = false
                        end
                    end
                end
            end
        end)
    end
    for _, objects in pairs(ESPObjects) do
        objects.box:Remove()
        objects.name:Remove()
    end
    ESPObjects = {}
end

-- ============================================================
-- INFINITE JUMP
-- ============================================================

local function InfiniteJumpLoop()
    while _G.NexusRivals.InfiniteJump and task.wait(0.05) do
        pcall(function()
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.JumpPower = 50
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            end
            UserInputService.JumpRequest:Fire()
        end)
    end
end

-- ============================================================
-- LOAD UI
-- ============================================================

local function LoadUI()
    local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()
    local Window = Rayfield:CreateWindow({
        Name = "☠️ NEXUS RIVALS ☠️",
        LoadingTitle = "NEXUS EXECUTOR",
        LoadingSubtitle = "by PROFESOR_FATIH + NEXUS 1.0",
        KeySystem = false,
    })

    local MainTab = Window:CreateTab("🎯 Combat", 4483362458)
    local MainSection = MainTab:CreateSection("Combat")

    MainSection:CreateToggle({
        Name = "🎯 Aimbot",
        CurrentValue = false,
        Callback = function(v) _G.NexusRivals.Aimbot = v if v then task.spawn(AimbotLoop) end end,
    })

    MainSection:CreateToggle({
        Name = "🔫 TriggerBot",
        CurrentValue = false,
        Callback = function(v) _G.NexusRivals.TriggerBot = v if v then task.spawn(TriggerBotLoop) end end,
    })

    MainSection:CreateSlider({
        Name = "👁️ FOV",
        Range = {50, 500},
        Increment = 10,
        Suffix = " px",
        CurrentValue = 200,
        Callback = function(v) _G.NexusRivals.FOV = v end,
    })

    MainSection:CreateSlider({
        Name = "🔄 Smoothness",
        Range = {1, 20},
        Increment = 1,
        CurrentValue = 5,
        Callback = function(v) _G.NexusRivals.Smoothness = v end,
    })

    local VisualTab = Window:CreateTab("👁️ Visuals", 4483362458)
    local VisualSection = VisualTab:CreateSection("Visuals")

    VisualSection:CreateToggle({
        Name = "👤 ESP",
        CurrentValue = false,
        Callback = function(v) _G.NexusRivals.ESP = v if v then task.spawn(ESPLoop) end end,
    })

    VisualSection:CreateToggle({
        Name = "🔫 No Recoil",
        CurrentValue = false,
        Callback = function(v)
            _G.NexusRivals.NoRecoil = v
            if v then
                task.spawn(function()
                    while _G.NexusRivals.NoRecoil and task.wait(0.1) do
                        pcall(function()
                            local weapon = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                            if weapon then weapon:SetAttribute("Recoil", 0) end
                        end)
                    end
                end)
            end
        end,
    })

    local MoveTab = Window:CreateTab("🏃 Movement", 4483362458)
    local MoveSection = MoveTab:CreateSection("Movement")

    MoveSection:CreateToggle({
        Name = "🦘 Infinite Jump",
        CurrentValue = false,
        Callback = function(v) _G.NexusRivals.InfiniteJump = v if v then task.spawn(InfiniteJumpLoop) end end,
    })

    MoveSection:CreateToggle({
        Name = "💨 Speed Hack",
        CurrentValue = false,
        Callback = function(v)
            _G.NexusRivals.SpeedHack = v
            if v then
                task.spawn(function()
                    while _G.NexusRivals.SpeedHack and task.wait(0.1) do
                        pcall(function()
                            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                            if humanoid then humanoid.WalkSpeed = _G.NexusRivals.SpeedValue end
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
        Callback = function(v) _G.NexusRivals.SpeedValue = v end,
    })

    Rayfield:Notify({Title = "☠️ NEXUS RIVALS", Content = "Script loaded!", Duration = 3})
end

task.spawn(LoadUI)
print("✅ NEXUS RIVALS SCRIPT LOADED!")