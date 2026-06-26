--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║    ██████╗ ███████╗██████╗ ██╗    ██╗ █████╗ ██████╗ ███████╗║
    ║    ██╔══██╗██╔════╝██╔══██╗██║    ██║██╔══██╗██╔══██╗██╔════╝║
    ║    ██████╔╝█████╗  ██████╔╝██║ █╗ ██║███████║██████╔╝███████╗║
    ║    ██╔══██╗██╔══╝  ██╔══██╗██║███╗██║██╔══██║██╔══██╗╚════██║║
    ║    ██████╔╝███████╗██║  ██║╚███╔███╔╝██║  ██║██║  ██║███████║║
    ║    ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝║
    ║                                                           ║
    ║                 NEXUS BEDWARS SCRIPT                      ║
    ║          BED WARS — RUSH POINT EDITION                   ║
    ║          AUTHOR: PROFESOR_FATIH + NEXUS 1.0             ║
    ║          VERSION: 2.0 — OVERPOWER 2026                  ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝
--]]

-- ============================================================
-- KONFIGURASI
-- ============================================================

local Nexus = {
    Version = "2.0",
    Author = "PROFESOR_FATIH + NEXUS 1.0",
    GUIKey = Enum.KeyCode.F1,
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

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ============================================================
-- VARIABLES GLOBAL
-- ============================================================

_G.NexusBW = {
    AutoFarm = false,
    KillAura = false,
    AutoClick = false,
    SpeedHack = false,
    Fly = false,
    Noclip = false,
    ESP = false,
    GodMode = false,
    FullBright = false,
    AutoWin = false,
    BreakAllBeds = false,
    AntiKnockback = false,
    SpeedValue = 24,
    JumpPower = 50,
    AuraRange = 20,
    SelectedWeapon = nil,
}

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================

local function GetNearestEnemy(range)
    local closest, distance = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local dist = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if dist < distance and dist <= range then
                closest, distance = player, dist
            end
        end
    end
    return closest
end

local function EquipWeapon(toolName)
    local character, backpack = LocalPlayer.Character, LocalPlayer.Backpack
    if character and character:FindFirstChild(toolName) then return true end
    if backpack and backpack:FindFirstChild(toolName) then
        task.wait(0.3)
        character.Humanoid:EquipTool(backpack[toolName])
        return true
    end
    return false
end

local function GetWeapons()
    local weapons = {}
    local character, backpack = LocalPlayer.Character, LocalPlayer.Backpack
    if character then
        for _, v in pairs(character:GetChildren()) do
            if v:IsA("Tool") then table.insert(weapons, v.Name) end
        end
    end
    if backpack then
        for _, v in pairs(backpack:GetChildren()) do
            if v:IsA("Tool") then table.insert(weapons, v.Name) end
        end
    end
    return weapons
end

local function TeleportTo(cframe)
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = cframe
    end
end

local function GetClosestBed()
    local closest, distance = nil, math.huge
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "Bed" and v:IsA("BasePart") then
            local dist = (v.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if dist < distance then
                closest, distance = v, dist
            end
        end
    end
    return closest
end

-- ============================================================
-- AUTO CLICK
-- ============================================================

local function AutoClickLoop()
    while _G.NexusBW.AutoClick and task.wait(0.05) do
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(1280, 672))
            task.wait(0.01)
            VirtualUser:Button1Up(Vector2.new(1280, 672))
        end)
    end
end

-- ============================================================
-- KILL AURA
-- ============================================================

local function KillAuraLoop()
    while _G.NexusBW.KillAura and task.wait(0.1) do
        pcall(function()
            local target = GetNearestEnemy(_G.NexusBW.AuraRange)
            if target then
                local character = target.Character
                if character then
                    TeleportTo(character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5))
                    VirtualUser:CaptureController()
                    VirtualUser:Button1Down(Vector2.new(1280, 672))
                end
            end
        end)
    end
end

-- ============================================================
-- SPEED HACK
-- ============================================================

local function SpeedHackLoop()
    while _G.NexusBW.SpeedHack and task.wait(0.1) do
        pcall(function()
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = _G.NexusBW.SpeedValue
            end
        end)
    end
end

-- ============================================================
-- FLY
-- ============================================================

local function FlyLoop()
    while _G.NexusBW.Fly and task.wait(0.05) do
        pcall(function()
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local moveDirection = Vector3.new(
                    (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0),
                    (UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 1 or 0),
                    (UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
                )
                hrp.Velocity = moveDirection * 50
                hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 0.5
            end
        end)
    end
end

-- ============================================================
-- NOCLIP
-- ============================================================

local function NoclipLoop()
    while _G.NexusBW.Noclip and task.wait(0.1) do
        pcall(function()
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    end
end

-- ============================================================
-- GOD MODE
-- ============================================================

local function GodModeLoop()
    while _G.NexusBW.GodMode and task.wait(0.1) do
        pcall(function()
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.MaxHealth = 9999
                humanoid.Health = 9999
            end
        end)
    end
end

-- ============================================================
-- BREAK ALL BEDS
-- ============================================================

local function BreakAllBedsLoop()
    while _G.NexusBW.BreakAllBeds and task.wait(0.5) do
        pcall(function()
            local bed = GetClosestBed()
            if bed then
                TeleportTo(bed.CFrame * CFrame.new(0, 0, -3))
                task.wait(0.1)
                VirtualUser:Button1Down(Vector2.new(1280, 672))
                task.wait(0.5)
                VirtualUser:Button1Up(Vector2.new(1280, 672))
            end
        end)
    end
end

-- ============================================================
-- ANTI KNOCKBACK
-- ============================================================

local function AntiKnockbackLoop()
    while _G.NexusBW.AntiKnockback and task.wait(0.1) do
        pcall(function()
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
            end
        end)
    end
end

-- ============================================================
-- FULL BRIGHT
-- ============================================================

local function FullBrightLoop()
    while _G.NexusBW.FullBright and task.wait(0.5) do
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
-- AUTO WIN
-- ============================================================

local function AutoWinLoop()
    while _G.NexusBW.AutoWin and task.wait(1) do
        pcall(function()
            BreakAllBedsLoop()
            KillAuraLoop()
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
                
                ESPObjects[player] = {box = box, name = name}
            end
        end
    end
end

local function UpdateESP()
    for player, objects in pairs(ESPObjects) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToScreenPoint(hrp.Position)
            if onScreen then
                objects.box.Size = Vector2.new(50, 100)
                objects.box.Position = Vector2.new(pos.X - 25, pos.Y - 50)
                objects.box.Visible = true
                
                objects.name.Position = Vector2.new(pos.X, pos.Y - 60)
                objects.name.Visible = true
            else
                objects.box.Visible = false
                objects.name.Visible = false
            end
        else
            objects.box.Visible = false
            objects.name.Visible = false
        end
    end
end

local function ClearESP()
    for _, objects in pairs(ESPObjects) do
        objects.box:Remove()
        objects.name:Remove()
    end
    ESPObjects = {}
end

local function ESPLoop()
    while _G.NexusBW.ESP and task.wait(0.1) do
        pcall(function()
            CreateESP()
            UpdateESP()
        end)
    end
    ClearESP()
end

-- ============================================================
-- LOAD UI (RAYFIELD)
-- ============================================================

local function LoadUI()
    local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()
    
    local Window = Rayfield:CreateWindow({
        Name = "☠️ NEXUS BEDWARS ☠️",
        LoadingTitle = "NEXUS EXECUTOR",
        LoadingSubtitle = "by PROFESOR_FATIH + NEXUS 1.0",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "NexusBedwars",
            FileName = "Settings"
        },
        KeySystem = false,
    })
    
    -- MAIN TAB
    local MainTab = Window:CreateTab("⚔️ Combat", 4483362458)
    local CombatSection = MainTab:CreateSection("Combat")
    
    CombatSection:CreateToggle({
        Name = "💀 Kill Aura",
        CurrentValue = false,
        Flag = "KillAura",
        Callback = function(Value)
            _G.NexusBW.KillAura = Value
            if Value then task.spawn(KillAuraLoop) end
        end,
    })
    
    CombatSection:CreateToggle({
        Name = "🖱️ Auto Click",
        CurrentValue = false,
        Flag = "AutoClick",
        Callback = function(Value)
            _G.NexusBW.AutoClick = Value
            if Value then task.spawn(AutoClickLoop) end
        end,
    })
    
    CombatSection:CreateSlider({
        Name = "🎯 Aura Range",
        Range = {5, 50},
        Increment = 1,
        Suffix = " studs",
        CurrentValue = 20,
        Flag = "AuraRange",
        Callback = function(Value)
            _G.NexusBW.AuraRange = Value
        end,
    })
    
    -- MOVEMENT TAB
    local MoveTab = Window:CreateTab("🏃 Movement", 4483362458)
    local MoveSection = MoveTab:CreateSection("Movement")
    
    MoveSection:CreateToggle({
        Name = "💨 Speed Hack",
        CurrentValue = false,
        Flag = "SpeedHack",
        Callback = function(Value)
            _G.NexusBW.SpeedHack = Value
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
            _G.NexusBW.SpeedValue = Value
        end,
    })
    
    MoveSection:CreateToggle({
        Name = "🕊️ Fly",
        CurrentValue = false,
        Flag = "Fly",
        Callback = function(Value)
            _G.NexusBW.Fly = Value
            if Value then task.spawn(FlyLoop) end
        end,
    })
    
    MoveSection:CreateToggle({
        Name = "🌀 Noclip",
        CurrentValue = false,
        Flag = "Noclip",
        Callback = function(Value)
            _G.NexusBW.Noclip = Value
            if Value then task.spawn(NoclipLoop) end
        end,
    })
    
    MoveSection:CreateToggle({
        Name = "🛡️ Anti Knockback",
        CurrentValue = false,
        Flag = "AntiKnockback",
        Callback = function(Value)
            _G.NexusBW.AntiKnockback = Value
            if Value then task.spawn(AntiKnockbackLoop) end
        end,
    })
    
    -- FARM TAB
    local FarmTab = Window:CreateTab("🏆 Farm", 4483362458)
    local FarmSection = FarmTab:CreateSection("Auto Farm")
    
    FarmSection:CreateToggle({
        Name = "🛏️ Break All Beds",
        CurrentValue = false,
        Flag = "BreakBeds",
        Callback = function(Value)
            _G.NexusBW.BreakAllBeds = Value
            if Value then task.spawn(BreakAllBedsLoop) end
        end,
    })
    
    FarmSection:CreateToggle({
        Name = "👑 Auto Win",
        CurrentValue = false,
        Flag = "AutoWin",
        Callback = function(Value)
            _G.NexusBW.AutoWin = Value
            if Value then task.spawn(AutoWinLoop) end
        end,
    })
    
    FarmSection:CreateToggle({
        Name = "💎 Auto Farm",
        CurrentValue = false,
        Flag = "AutoFarm",
        Callback = function(Value)
            _G.NexusBW.AutoFarm = Value
            if Value then
                _G.NexusBW.AutoClick = true
                _G.NexusBW.KillAura = true
                task.spawn(KillAuraLoop)
                task.spawn(AutoClickLoop)
            end
        end,
    })
    
    -- VISUAL TAB
    local VisualTab = Window:CreateTab("👁️ Visuals", 4483362458)
    local VisualSection = VisualTab:CreateSection("Visuals")
    
    VisualSection:CreateToggle({
        Name = "👤 ESP",
        CurrentValue = false,
        Flag = "ESP",
        Callback = function(Value)
            _G.NexusBW.ESP = Value
            if Value then task.spawn(ESPLoop) else ClearESP() end
        end,
    })
    
    VisualSection:CreateToggle({
        Name = "☀️ Full Bright",
        CurrentValue = false,
        Flag = "FullBright",
        Callback = function(Value)
            _G.NexusBW.FullBright = Value
            if Value then task.spawn(FullBrightLoop) end
        end,
    })
    
    -- MISC TAB
    local MiscTab = Window:CreateTab("⚙️ Misc", 4483362458)
    local MiscSection = MiscTab:CreateSection("Misc")
    
    MiscSection:CreateToggle({
        Name = "🧬 God Mode",
        CurrentValue = false,
        Flag = "GodMode",
        Callback = function(Value)
            _G.NexusBW.GodMode = Value
            if Value then task.spawn(GodModeLoop) end
        end,
    })
    
    -- Weapon Dropdown
    local weapons = GetWeapons()
    local WeaponDropdown = MiscSection:CreateDropdown({
        Name = "🔫 Select Weapon",
        Options = weapons,
        CurrentOption = "None",
        Flag = "WeaponSelect",
        Callback = function(Option)
            _G.NexusBW.SelectedWeapon = Option
            EquipWeapon(Option)
        end,
    })
    
    MiscSection:CreateButton({
        Name = "🔄 Refresh Weapons",
        Callback = function()
            WeaponDropdown:Refresh(GetWeapons())
        end,
    })
    
    Rayfield:Notify({
        Title = "☠️ NEXUS BEDWARS",
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
        print("☠️ NEXUS BEDWARS SCRIPT LOADED!")
        print("📌 Features: Kill Aura, Speed Hack, Fly, ESP, Auto Win")
    end
end)

print("✅ NEXUS BEDWARS SCRIPT LOADED!")
print("📌 Fitur: Kill Aura, Speed Hack, Fly, ESP, Auto Win, Break Beds")
print("⚡ AUTHOR: PROFESOR_FATIH + NEXUS 1.0")