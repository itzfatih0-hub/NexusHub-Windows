--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║    ███████╗ ██████╗ ██████╗ ███████╗ █████╗ ██╗  ██╗    ║
    ║    ██╔════╝██╔═══██╗██╔══██╗██╔════╝██╔══██╗██║ ██╔╝    ║
    ║    █████╗  ██║   ██║██████╔╝███████╗███████║█████╔╝     ║
    ║    ██╔══╝  ██║   ██║██╔══██╗╚════██║██╔══██║██╔═██╗     ║
    ║    ██║     ╚██████╔╝██║  ██║███████║██║  ██║██║  ██╗    ║
    ║    ╚═╝      ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝    ║
    ║                                                           ║
    ║                 NEXUS FORSAKEN SCRIPT                    ║
    ║          SURVIVOR VS KILLER — ESP + AUTO GEN            ║
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
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService('VirtualUser')
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- VARIABLES
-- ============================================================

_G.NexusForsaken = {
    ESP = false,
    AutoGenerator = false,
    GeneratorDistance = 30,
    AntiStun = false,
    Immunity = false,
    SpeedHack = false,
    SpeedValue = 24,
}

-- ============================================================
-- ESP
-- ============================================================

local ESPObjects = {}

local function CreateForsakenESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp and not ESPObjects[player] then
                local box = Drawing.new("Square")
                box.Color = player.Team and player.TeamColor and player.TeamColor.Color or Color3.new(1, 1, 1)
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

local function UpdateForsakenESP()
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

local function ClearForsakenESP()
    for _, objects in pairs(ESPObjects) do
        objects.box:Remove()
        objects.name:Remove()
    end
    ESPObjects = {}
end

local function ESPLoop()
    while _G.NexusForsaken.ESP and task.wait(0.1) do
        pcall(function()
            CreateForsakenESP()
            UpdateForsakenESP()
        end)
    end
    ClearForsakenESP()
end

-- ============================================================
-- AUTO GENERATOR
-- ============================================================

local function AutoGeneratorLoop()
    while _G.NexusForsaken.AutoGenerator and task.wait(0.5) do
        pcall(function()
            local map = Workspace:FindFirstChild("Map")
            if map then
                local ingame = map:FindFirstChild("Ingame")
                if ingame then
                    local mapGen = ingame:FindFirstChild("Map")
                    if mapGen then
                        for _, obj in pairs(mapGen:GetChildren()) do
                            if obj.Name == "Generator" and obj:IsA("Model") then
                                local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("PrimaryPart")
                                if hrp then
                                    local distance = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                                    if distance < _G.NexusForsaken.GeneratorDistance then
                                        VirtualUser:Button1Down(Vector2.new(1280, 672))
                                        task.wait(0.1)
                                        VirtualUser:Button1Up(Vector2.new(1280, 672))
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end

-- ============================================================
-- LOAD UI
-- ============================================================

local function LoadUI()
    local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()
    local Window = Rayfield:CreateWindow({
        Name = "☠️ NEXUS FORSAKEN ☠️",
        LoadingTitle = "NEXUS EXECUTOR",
        LoadingSubtitle = "by PROFESOR_FATIH + NEXUS 1.0",
        KeySystem = false,
    })

    local MainTab = Window:CreateTab("👁️ Visuals", 4483362458)
    local MainSection = MainTab:CreateSection("Visuals")

    MainSection:CreateToggle({
        Name = "👤 ESP",
        CurrentValue = false,
        Callback = function(v) _G.NexusForsaken.ESP = v if v then task.spawn(ESPLoop) end end,
    })

    local GenTab = Window:CreateTab("⚡ Auto", 4483362458)
    local GenSection = GenTab:CreateSection("Auto Generator")

    GenSection:CreateToggle({
        Name = "🔄 Auto Generator",
        CurrentValue = false,
        Callback = function(v) _G.NexusForsaken.AutoGenerator = v if v then task.spawn(AutoGeneratorLoop) end end,
    })

    GenSection:CreateSlider({
        Name = "📏 Generator Distance",
        Range = {5, 100},
        Increment = 1,
        Suffix = " studs",
        CurrentValue = 30,
        Callback = function(v) _G.NexusForsaken.GeneratorDistance = v end,
    })

    local MoveTab = Window:CreateTab("🏃 Movement", 4483362458)
    local MoveSection = MoveTab:CreateSection("Movement")

    MoveSection:CreateToggle({
        Name = "💨 Speed Hack",
        CurrentValue = false,
        Callback = function(v)
            _G.NexusForsaken.SpeedHack = v
            if v then
                task.spawn(function()
                    while _G.NexusForsaken.SpeedHack and task.wait(0.1) do
                        pcall(function()
                            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                            if humanoid then humanoid.WalkSpeed = _G.NexusForsaken.SpeedValue end
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
        Callback = function(v) _G.NexusForsaken.SpeedValue = v end,
    })

    Rayfield:Notify({Title = "☠️ NEXUS FORSAKEN", Content = "Script loaded!", Duration = 3})
end

task.spawn(LoadUI)
print("✅ NEXUS FORSAKEN SCRIPT LOADED!")