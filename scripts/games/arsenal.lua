--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║    █████╗ ██████╗ ███████╗███████╗███╗   ██╗ █████╗ ██╗  ║
    ║   ██╔══██╗██╔══██╗██╔════╝██╔════╝████╗  ██║██╔══██╗██║  ║
    ║   ███████║██████╔╝███████╗███████╗██╔██╗ ██║███████║██║  ║
    ║   ██╔══██║██╔══██╗╚════██║╚════██║██║╚██╗██║██╔══██║██║  ║
    ║   ██║  ██║██║  ██║███████║███████║██║ ╚████║██║  ██║███████╗║
    ║   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝║
    ║                                                           ║
    ║                 NEXUS ARSENAL SCRIPT                      ║
    ║          FPS — AIMBOT + ESP + RAGE MODE                 ║
    ║          AUTHOR: PROFESOR_FATIH + NEXUS 1.0             ║
    ║          VERSION: 3.0 — OVERPOWER 2026                  ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝
--]]

-- ============================================================
-- KONFIGURASI
-- ============================================================

local Nexus = {
    Version = "3.0",
    Author = "PROFESOR_FATIH + NEXUS 1.0",
}

-- ============================================================
-- SERVICES
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService('VirtualUser')
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================================================
-- VARIABLES GLOBAL
-- ============================================================

_G.NexusArsenal = {
    Aimbot = false,
    SilentAim = false,
    TriggerBot = false,
    ESP = false,
    FOV = 200,
    Smoothness = 5,
    AimPart = "Head",
    VisibleCheck = true,
    TeamCheck = true,
    HitChance = 100,
    Prediction = true,
    PredictionAmount = 0.2,
    NoRecoil = false,
    NoSpread = false,
    FullBright = false,
    SpeedHack = false,
    SpeedValue = 24,
    Bhop = false,
}

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================

local function GetClosestPlayer()
    local closest, closestDistance = nil, _G.NexusArsenal.FOV
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if _G.NexusArsenal.TeamCheck and player.Team == LocalPlayer.Team then
                continue
            end
            
            local head = player.Character:FindFirstChild("Head")
            if not head then continue end
            
            local headPos = head.Position
            local screenPos, onScreen = Camera:WorldToScreenPoint(headPos)
            if not onScreen then continue end
            
            local distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closest = player
            end
        end
    end
    return closest
end

local function IsVisible(player)
    if not _G.NexusArsenal.VisibleCheck then return true end
    
    local character = player.Character
    if not character then return false end
    
    local head = character:FindFirstChild("Head")
    if not head then return false end
    
    local origin = Camera.CFrame.Position
    local direction = (head.Position - origin).Unit * 1000
    local ray = Ray.new(origin, direction)
    
    local hit = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
    if hit then
        local hitPlayer = hit.Parent and hit.Parent.Parent and hit.Parent.Parent:FindFirstChild("Humanoid")
        if hitPlayer and hitPlayer.Parent == player.Character then
            return true
        end
    end
    return false
end

-- ============================================================
-- AIMBOT
-- ============================================================

local function AimbotLoop()
    while _G.NexusArsenal.Aimbot and task.wait() do
        pcall(function()
            local target = GetClosestPlayer()
            if not target then continue end
            
            local character = target.Character
            if not character then continue end
            
            local aimPart = character:FindFirstChild(_G.NexusArsenal.AimPart)
            if not aimPart then
                aimPart = character:FindFirstChild("HumanoidRootPart")
            end
            if not aimPart then continue end
            
            local aimPos = aimPart.Position
            if _G.NexusArsenal.Prediction then
                local velocity = aimPart.Velocity or Vector3.new()
                aimPos = aimPos + velocity * _G.NexusArsenal.PredictionAmount
            end
            
            local screenPos, onScreen = Camera:WorldToScreenPoint(aimPos)
            if not onScreen then continue end
            
            local delta = Vector2.new(screenPos.X - Mouse.X, screenPos.Y - Mouse.Y)
            local smoothness = _G.NexusArsenal.Smoothness or 1
            
            mousemoverel(delta.X / smoothness, delta.Y / smoothness)
        end)
    end
end

-- ============================================================
-- SILENT AIM
-- ============================================================

local function SilentAimLoop()
    while _G.NexusArsenal.SilentAim and task.wait() do
        pcall(function()
            local target = GetClosestPlayer()
            if not target then continue end
            
            local character = target.Character
            if not character then continue end
            
            local aimPart = character:FindFirstChild(_G.NexusArsenal.AimPart)
            if not aimPart then
                aimPart = character:FindFirstChild("HumanoidRootPart")
            end
            if not aimPart then continue end
            
            local aimPos = aimPart.Position
            if _G.NexusArsenal.Prediction then
                local velocity = aimPart.Velocity or Vector3.new()
                aimPos = aimPos + velocity * _G.NexusArsenal.PredictionAmount
            end
            
            -- Silent aim: modify bullet direction without moving mouse
            local direction = (aimPos - Camera.CFrame.Position).Unit
            -- This would require hooking the weapon's fire function
            -- Simplified version: just move mouse smoothly
            local screenPos, onScreen = Camera:WorldToScreenPoint(aimPos)
            if not onScreen then continue end
            
            local delta = Vector2.new(screenPos.X - Mouse.X, screenPos.Y - Mouse.Y)
            mousemoverel(delta.X / 2, delta.Y / 2)
        end)
    end
end

-- ============================================================
-- TRIGGERBOT
-- ============================================================

local function TriggerBotLoop()
    while _G.NexusArsenal.TriggerBot and task.wait(0.05) do
        pcall(function()
            local target = GetClosestPlayer()
            if not target then continue end
            
            local character = target.Character
            if not character then continue end
            
            local aimPart = character:FindFirstChild("Head")
            if not aimPart then
                aimPart = character:FindFirstChild("HumanoidRootPart")
            end
            if not aimPart then continue end
            
            local screenPos, onScreen = Camera:WorldToScreenPoint(aimPart.Position)
            if not onScreen then continue end
            
            local distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
            if distance < 50 then
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(1280, 672))
                task.wait(0.05)
                VirtualUser:Button1Up(Vector2.new(1280, 672))
            end
        end)
    end
end

-- ============================================================
-- ESP
-- ============================================================

local ESPObjects = {}

local function CreateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp and not ESPObjects[player] then
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
                
                local health = Drawing.new("Line")
                health.Color = Color3.new(0, 1, 0)
                health.Thickness = 4
                
                ESPObjects[player] = {box = box, name = name, health = health}
            end
        end
    end
end

local function UpdateESP()
    for player, objects in pairs(ESPObjects) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local pos, onScreen = Camera:WorldToScreenPoint(hrp.Position)
            
            if onScreen then
                local height = 100
                local width = 50
                
                objects.box.Size = Vector2.new(width, height)
                objects.box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
                objects.box.Visible = true
                
                objects.name.Position = Vector2.new(pos.X, pos.Y - height/2 - 15)
                objects.name.Visible = true
                
                if humanoid then
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    local healthHeight = height * healthPercent
                    objects.health.From = Vector2.new(pos.X + width/2 + 5, pos.Y - height/2)
                    objects.health.To = Vector2.new(pos.X + width/2 + 5, pos.Y - height/2 + healthHeight)
                    objects.health.Visible = true
                end
            else
                objects.box.Visible = false
                objects.name.Visible = false
                objects.health.Visible = false
            end
        else
            objects.box.Visible = false
            objects.name.Visible = false
            objects.health.Visible = false
        end
    end
end

local function ClearESP()
    for _, objects in pairs(ESPObjects) do
        objects.box:Remove()
        objects.name:Remove()
        objects.health:Remove()
    end
    ESPObjects = {}
end

local function ESPLoop()
    while _G.NexusArsenal.ESP and task.wait(0.1) do
        pcall(function()
            CreateESP()
            UpdateESP()
        end)
    end
    ClearESP()
end

-- ============================================================
-- NO RECOIL
-- ============================================================

local function NoRecoilLoop()
    while _G.NexusArsenal.NoRecoil and task.wait(0.1) do
        pcall(function()
            local weapon = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if weapon then
                weapon:SetAttribute("Recoil", 0)
            end
        end)
    end
end

-- ============================================================
-- NO SPREAD
-- ============================================================

local function NoSpreadLoop()
    while _G.NexusArsenal.NoSpread and task.wait(0.1) do
        pcall(function()
            local weapon = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if weapon then
                weapon:SetAttribute("Spread", 0)
            end
        end)
    end
end

-- ============================================================
-- FULL BRIGHT
-- ============================================================

local function FullBrightLoop()
    while _G.NexusArsenal.FullBright and task.wait(0.5) do
        pcall(function()
            Lighting.Brightness = 10
            Lighting.ClockTime = 12
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.GlobalShadows = false
        end)
    end
end

-- ============================================================
-- SPEED HACK
-- ============================================================

local function SpeedHackLoop()
    while _G.NexusArsenal.SpeedHack and task.wait(0.1) do
        pcall(function()
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = _G.NexusArsenal.SpeedValue
            end
        end)
    end
end

-- ============================================================
-- BHOP
-- ============================================================

local function BhopLoop()
    while _G.NexusArsenal.Bhop and task.wait(0.05) do
        pcall(function()
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
                humanoid.Jump = true
            end
        end)
    end
end

-- ============================================================
-- LOAD UI (RAYFIELD)
-- ============================================================

local function LoadUI()
    local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()
    
    local Window = Rayfield:CreateWindow({
        Name = "☠️ NEXUS ARSENAL ☠️",
        LoadingTitle = "NEXUS EXECUTOR",
        LoadingSubtitle = "by PROFESOR_FATIH + NEXUS 1.0",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "NexusArsenal",
            FileName = "Settings"
        },
        KeySystem = false,
    })
    
    -- ============================================================
    -- AIMBOT TAB
    -- ============================================================
    local AimbotTab = Window:CreateTab("🎯 Aimbot", 4483362458)
    local AimSection = AimbotTab:CreateSection("Aimbot Settings")
    
    AimSection:CreateToggle({
        Name = "🎯 Aimbot",
        CurrentValue = false,
        Flag = "Aimbot",
        Callback = function(Value)
            _G.NexusArsenal.Aimbot = Value
            if Value then task.spawn(AimbotLoop) end
        end,
    })
    
    AimSection:CreateToggle({
        Name = "🤫 Silent Aim",
        CurrentValue = false,
        Flag = "SilentAim",
        Callback = function(Value)
            _G.NexusArsenal.SilentAim = Value
            if Value then task.spawn(SilentAimLoop) end
        end,
    })
    
    AimSection:CreateToggle({
        Name = "🔫 TriggerBot",
        CurrentValue = false,
        Flag = "TriggerBot",
        Callback = function(Value)
            _G.NexusArsenal.TriggerBot = Value
            if Value then task.spawn(TriggerBotLoop) end
        end,
    })
    
    AimSection:CreateSlider({
        Name = "👁️ FOV",
        Range = {50, 500},
        Increment = 10,
        Suffix = " px",
        CurrentValue = 200,
        Flag = "FOV",
        Callback = function(Value)
            _G.NexusArsenal.FOV = Value
        end,
    })
    
    AimSection:CreateSlider({
        Name = "🔄 Smoothness",
        Range = {1, 20},
        Increment = 1,
        Suffix = "",
        CurrentValue = 5,
        Flag = "Smoothness",
        Callback = function(Value)
            _G.NexusArsenal.Smoothness = Value
        end,
    })
    
    AimSection:CreateDropdown({
        Name = "🎯 Aim Part",
        Options = {"Head", "Torso", "HumanoidRootPart"},
        CurrentOption = "Head",
        Flag = "AimPart",
        Callback = function(Option)
            _G.NexusArsenal.AimPart = Option
        end,
    })
    
    AimSection:CreateToggle({
        Name = "👤 Visible Check",
        CurrentValue = true,
        Flag = "VisibleCheck",
        Callback = function(Value)
            _G.NexusArsenal.VisibleCheck = Value
        end,
    })
    
    AimSection:CreateToggle({
        Name = "🔮 Prediction",
        CurrentValue = true,
        Flag = "Prediction",
        Callback = function(Value)
            _G.NexusArsenal.Prediction = Value
        end,
    })
    
    -- ============================================================
    -- ESP TAB
    -- ============================================================
    local ESPTab = Window:CreateTab("👁️ ESP", 4483362458)
    local ESPSection = ESPTab:CreateSection("ESP Settings")
    
    ESPSection:CreateToggle({
        Name = "👤 ESP",
        CurrentValue = false,
        Flag = "ESP",
        Callback = function(Value)
            _G.NexusArsenal.ESP = Value
            if Value then task.spawn(ESPLoop) else ClearESP() end
        end,
    })
    
    -- ============================================================
    -- VISUALS TAB
    -- ============================================================
    local VisualTab = Window:CreateTab("👁️ Visuals", 4483362458)
    local VisualSection = VisualTab:CreateSection("Visuals")
    
    VisualSection:CreateToggle({
        Name = "🔫 No Recoil",
        CurrentValue = false,
        Flag = "NoRecoil",
        Callback = function(Value)
            _G.NexusArsenal.NoRecoil = Value
            if Value then task.spawn(NoRecoilLoop) end
        end,
    })
    
    VisualSection:CreateToggle({
        Name = "🎯 No Spread",
        CurrentValue = false,
        Flag = "NoSpread",
        Callback = function(Value)
            _G.NexusArsenal.NoSpread = Value
            if Value then task.spawn(NoSpreadLoop) end
        end,
    })
    
    VisualSection:CreateToggle({
        Name = "☀️ Full Bright",
        CurrentValue = false,
        Flag = "FullBright",
        Callback = function(Value)
            _G.NexusArsenal.FullBright = Value
            if Value then task.spawn(FullBrightLoop) end
        end,
    })
    
    -- ============================================================
    -- MOVEMENT TAB
    -- ============================================================
    local MoveTab = Window:CreateTab("🏃 Movement", 4483362458)
    local MoveSection = MoveTab:CreateSection("Movement")
    
    MoveSection:CreateToggle({
        Name = "💨 Speed Hack",
        CurrentValue = false,
        Flag = "SpeedHack",
        Callback = function(Value)
            _G.NexusArsenal.SpeedHack = Value
            if Value then task.spawn(SpeedHackLoop)
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
        Flag = "SpeedValue",
        Callback = function(Value)
            _G.NexusArsenal.SpeedValue = Value
        end,
    })
    
    MoveSection:CreateToggle({
        Name = "🦘 Bhop",
        CurrentValue = false,
        Flag = "Bhop",
        Callback = function(Value)
            _G.NexusArsenal.Bhop = Value
            if Value then task.spawn(BhopLoop) end
        end,
    })
    
    -- ============================================================
    -- NOTIFIKASI
    -- ============================================================
    Rayfield:Notify({
        Title = "☠️ NEXUS ARSENAL",
        Content = "Script loaded successfully!",
        Duration = 5,
    })
end

-- ============================================================
-- ANTI AFK
-- ============================================================

local function AntiAFK()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame)
    end)
end

-- ============================================================
-- MAIN EXECUTION
-- ============================================================

task.spawn(function()
    AntiAFK()
    
    local success, err = pcall(LoadUI)
    if not success then
        warn("Failed to load UI: " .. tostring(err))
        print("☠️ NEXUS ARSENAL SCRIPT LOADED!")
        print("📌 Features: Aimbot, Silent Aim, TriggerBot, ESP, No Recoil")
    end
end)

print("✅ NEXUS ARSENAL SCRIPT LOADED!")
print("📌 Fitur: Aimbot, Silent Aim, TriggerBot, ESP, No Recoil")
print("⚡ AUTHOR: PROFESOR_FATIH + NEXUS 1.0")