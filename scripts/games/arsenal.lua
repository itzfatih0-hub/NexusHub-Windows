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
    ║              ARSENAL SCRIPT — NEXUS EDITION              ║
    ║          AUTHOR: PROFESOR_FATIH + NEXUS 1.0             ║
    ║          VERSION: 2.1 — OVERPOWER 2026                  ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝
--]]

-- ============================================================
-- CONFIGURATION
-- ============================================================

local Config = {
    AimBot = {
        Enabled = true,
        FOV = 200,                    -- Field of View
        Smoothness = 15,              -- Aim smoothing (lower = faster)
        AimPart = "Head",             -- "Head", "Torso", "HumanoidRootPart"
        VisibleCheck = true,          -- Only aim at visible players
        TeamCheck = true,             -- Don't aim at teammates
        HitChance = 100,              -- 0-100, chance to hit
        Prediction = true,            -- Predict enemy movement
        PredictionAmount = 0.2,       -- Prediction multiplier
    },
    ESP = {
        Enabled = true,
        Box = true,                   -- Draw box around players
        BoxColor = {1, 0, 0},         -- Red
        Tracer = true,                -- Line from you to player
        TracerColor = {0, 1, 0},      -- Green
        Name = true,                  -- Show player name
        NameColor = {1, 1, 1},        -- White
        HealthBar = true,             -- Show health bar
        HealthBarColor = {0, 1, 0},   -- Green
        Distance = true,              -- Show distance
        DistanceColor = {1, 1, 0},    -- Yellow
        VisibleOnly = false,          -- Only show visible players
        TeamCheck = true,             -- Don't show teammates
    },
    TriggerBot = {
        Enabled = false,
        Delay = 0.1,                  -- Delay between shots (seconds)
        OnlyHead = true,              -- Only trigger on head
        Keybind = "MouseButton1",     -- MouseButton1 = Left Click
    },
    SilentAim = {
        Enabled = false,              -- Send fake packets
        HitChance = 85,               -- Chance to hit
        FakeLag = 50,                 -- Fake lag in ms
    },
    Movement = {
        Bhop = false,                 -- Auto bunny hop
        Speed = 16,                   -- Speed multiplier
        NoFallDamage = true,          -- Prevent fall damage
        AntiStun = true,              -- Prevent stun
    },
    Visuals = {
        NoRecoil = true,
        NoSpread = true,
        NoBloom = true,
        NoFog = true,
        FullBright = false,
        Chams = false,                -- Highlight players
        ChamsColor = {0, 1, 0},       -- Green
    },
    Misc = {
        AutoReload = true,
        AutoSwitch = true,
        AntiAfk = true,
        FOVChanger = false,
        FOV = 120,
        RainbowGun = false,
    },
    GUI = {
        Keybind = "F1",                -- Open GUI
        ThemeColor = {0, 1, 0},       -- Green theme
    }
}

-- ============================================================
-- SERVICES
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================

local function GetClosestPlayer()
    local closest = nil
    local closestDistance = Config.AimBot.FOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            -- Team check
            if Config.AimBot.TeamCheck and player.Team == LocalPlayer.Team then
                continue
            end
            
            local character = player.Character
            local head = character:FindFirstChild("Head")
            if not head then continue end
            
            local headPos = head.Position
            local screenPos, onScreen = Camera:WorldToScreenPoint(headPos)
            
            if not onScreen then continue end
            
            local distance = (Mouse.X - screenPos.X)^2 + (Mouse.Y - screenPos.Y)^2
            if distance < closestDistance then
                closestDistance = distance
                closest = player
            end
        end
    end
    
    return closest
end

local function IsVisible(player)
    if not Config.AimBot.VisibleCheck then return true end
    
    local character = player.Character
    if not character then return false end
    
    local head = character:FindFirstChild("Head")
    if not head then return false end
    
    local origin = Camera.CFrame.Position
    local direction = (head.Position - origin).Unit * 1000
    local ray = Ray.new(origin, direction)
    
    local hit, position = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
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

local AimBot = {
    Target = nil,
    Active = false,
}

function AimBot:Update()
    if not Config.AimBot.Enabled then return end
    
    local target = GetClosestPlayer()
    if not target then return end
    
    self.Target = target
    self.Active = true
    
    local character = target.Character
    if not character then return end
    
    local aimPart = character:FindFirstChild(Config.AimBot.AimPart)
    if not aimPart then
        aimPart = character:FindFirstChild("HumanoidRootPart")
    end
    if not aimPart then return end
    
    local aimPos = aimPart.Position
    if Config.AimBot.Prediction then
        local velocity = aimPart.Velocity or Vector3.new()
        aimPos = aimPos + velocity * Config.AimBot.PredictionAmount
    end
    
    local screenPos, onScreen = Camera:WorldToScreenPoint(aimPos)
    if not onScreen then return end
    
    -- Smooth aim
    local delta = Vector2.new(screenPos.X - Mouse.X, screenPos.Y - Mouse.Y)
    local smoothness = Config.AimBot.Smoothness or 1
    local newPos = Mouse.X + delta.X / smoothness
    local newPosY = Mouse.Y + delta.Y / smoothness
    
    mousemoverel(delta.X / smoothness, delta.Y / smoothness)
end

-- ============================================================
-- ESP
-- ============================================================

local ESP = {
    Connections = {},
    Objects = {},
}

function ESP:CreateEsp(player)
    if not Config.ESP.Enabled then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    
    -- Team check
    if Config.ESP.TeamCheck and player.Team == LocalPlayer.Team then
        return
    end
    
    -- Create box
    if Config.ESP.Box then
        local box = Drawing.new("Square")
        box.Color = Color3.fromRGB(Config.ESP.BoxColor[1] * 255, Config.ESP.BoxColor[2] * 255, Config.ESP.BoxColor[3] * 255)
        box.Thickness = 2
        box.Filled = false
        box.Transparency = 0.5
        self.Objects[player] = box
    end
    
    -- Create tracer
    if Config.ESP.Tracer then
        local tracer = Drawing.new("Line")
        tracer.Color = Color3.fromRGB(Config.ESP.TracerColor[1] * 255, Config.ESP.TracerColor[2] * 255, Config.ESP.TracerColor[3] * 255)
        tracer.Thickness = 1
        self.Objects[player .. "_tracer"] = tracer
    end
    
    -- Create name
    if Config.ESP.Name then
        local nameLabel = Drawing.new("Text")
        nameLabel.Text = player.Name
        nameLabel.Color = Color3.fromRGB(Config.ESP.NameColor[1] * 255, Config.ESP.NameColor[2] * 255, Config.ESP.NameColor[3] * 255)
        nameLabel.Size = 14
        nameLabel.Center = true
        nameLabel.Outline = true
        nameLabel.OutlineColor = Color3.new(0, 0, 0)
        self.Objects[player .. "_name"] = nameLabel
    end
    
    -- Create health bar
    if Config.ESP.HealthBar then
        local healthBar = Drawing.new("Line")
        healthBar.Color = Color3.fromRGB(Config.ESP.HealthBarColor[1] * 255, Config.ESP.HealthBarColor[2] * 255, Config.ESP.HealthBarColor[3] * 255)
        healthBar.Thickness = 4
        self.Objects[player .. "_health"] = healthBar
    end
end

function ESP:Update()
    for player, object in pairs(self.Objects) do
        if type(player) == "string" then
            -- Handle tracer, name, health
            local p = string.gsub(player, "_tracer", "")
            p = string.gsub(p, "_name", "")
            p = string.gsub(p, "_health", "")
            
            local actualPlayer = Players:FindFirstChild(p)
            if not actualPlayer or not actualPlayer.Character then
                object.Visible = false
                continue
            end
            
            local character = actualPlayer.Character
            local humanoid = character:FindFirstChild("Humanoid")
            if not humanoid or humanoid.Health <= 0 then
                object.Visible = false
                continue
            end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart then continue end
            
            local headPos = rootPart.Position + Vector3.new(0, 2.5, 0)
            local footPos = rootPart.Position - Vector3.new(0, 2.5, 0)
            
            local headScreen, headOn = Camera:WorldToScreenPoint(headPos)
            local footScreen, footOn = Camera:WorldToScreenPoint(footPos)
            
            if not headOn or not footOn then
                object.Visible = false
                continue
            end
            
            local height = headScreen.Y - footScreen.Y
            local width = height / 2
            
            if player:find("_tracer") then
                -- Update tracer
                local tracer = object
                tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                tracer.To = Vector2.new(headScreen.X, headScreen.Y)
                tracer.Visible = true
            elseif player:find("_name") then
                -- Update name
                local name = object
                name.Position = Vector2.new(headScreen.X, headScreen.Y - height - 15)
                name.Visible = true
            elseif player:find("_health") then
                -- Update health
                local health = object
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                local startPos = Vector2.new(headScreen.X - width - 5, headScreen.Y)
                local endPos = Vector2.new(headScreen.X - width - 5, headScreen.Y + height * healthPercent)
                health.From = startPos
                health.To = endPos
                health.Visible = true
            end
        else
            -- Handle box
            local character = player.Character
            if not character then
                object.Visible = false
                continue
            end
            
            local humanoid = character:FindFirstChild("Humanoid")
            if not humanoid or humanoid.Health <= 0 then
                object.Visible = false
                continue
            end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart then continue end
            
            local headPos = rootPart.Position + Vector3.new(0, 2.5, 0)
            local footPos = rootPart.Position - Vector3.new(0, 2.5, 0)
            
            local headScreen, headOn = Camera:WorldToScreenPoint(headPos)
            local footScreen, footOn = Camera:WorldToScreenPoint(footPos)
            
            if not headOn or not footOn then
                object.Visible = false
                continue
            end
            
            local height = headScreen.Y - footScreen.Y
            local width = height / 2
            
            object.Size = Vector2.new(width, height)
            object.Position = Vector2.new(headScreen.X - width / 2, headScreen.Y)
            object.Visible = true
        end
    end
end

function ESP:Clear()
    for _, object in pairs(self.Objects) do
        object:Remove()
    end
    self.Objects = {}
end

-- ============================================================
-- TRIGGERBOT
-- ============================================================

local TriggerBot = {
    Active = false,
}

function TriggerBot:Shoot()
    if not Config.TriggerBot.Enabled then return end
    
    local target = GetClosestPlayer()
    if not target then return end
    
    local character = target.Character
    if not character then return end
    
    local aimPart = character:FindFirstChild("Head")
    if Config.TriggerBot.OnlyHead and not aimPart then return end
    if not aimPart then
        aimPart = character:FindFirstChild("HumanoidRootPart")
    end
    
    if not aimPart then return end
    
    local screenPos, onScreen = Camera:WorldToScreenPoint(aimPart.Position)
    if not onScreen then return end
    
    local distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
    if distance > 50 then return end
    
    mouse1click()
    task.wait(Config.TriggerBot.Delay)
end

-- ============================================================
-- MOVEMENT
-- ============================================================

local Movement = {}

function Movement:Bhop()
    if not Config.Movement.Bhop then return end
    
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if humanoid.FloorMaterial ~= Enum.Material.Air then
        humanoid.Jump = true
    end
end

function Movement:NoFallDamage()
    if not Config.Movement.NoFallDamage then return end
    
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    humanoid.FallDamage = false
end

-- ============================================================
-- VISUALS
-- ============================================================

local Visuals = {}

function Visuals:NoRecoil()
    if not Config.Visuals.NoRecoil then return end
    
    local weapon = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if weapon then
        weapon:SetAttribute("Recoil", 0)
    end
end

function Visuals:NoSpread()
    if not Config.Visuals.NoSpread then return end
    
    local weapon = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if weapon then
        weapon:SetAttribute("Spread", 0)
    end
end

function Visuals:FullBright()
    if not Config.Visuals.FullBright then return end
    
    Lighting.Brightness = 10
    Lighting.ClockTime = 12
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    Lighting.Ambient = Color3.new(1, 1, 1)
end

-- ============================================================
-- GUI
-- ============================================================

local GUI = {
    ScreenGui = nil,
    MainFrame = nil,
}

function GUI:Create()
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Parent = LocalPlayer.PlayerGui
    self.ScreenGui.Name = "NexusArsenalGUI"
    
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Parent = self.ScreenGui
    self.MainFrame.Size = UDim2.new(0, 400, 0, 500)
    self.MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    self.MainFrame.BackgroundTransparency = 0.1
    self.MainFrame.BorderSizePixel = 2
    self.MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Parent = self.MainFrame
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(0, 30, 0)
    title.Text = "☠️ NEXUS ARSENAL V2.1 ☠️"
    title.TextColor3 = Color3.fromRGB(0, 255, 0)
    title.TextSize = 18
    title.Font = Enum.Font.SourceSansBold
    
    -- Tabs
    local tabs = {"Aimbot", "ESP", "Trigger", "Movement", "Visuals", "Misc"}
    local tabY = 45
    for i, tab in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Parent = self.MainFrame
        btn.Size = UDim2.new(1/6, 0, 0, 30)
        btn.Position = UDim2.new((i-1)/6, 0, 0, tabY)
        btn.BackgroundColor3 = Color3.fromRGB(0, 40, 0)
        btn.Text = tab
        btn.TextColor3 = Color3.fromRGB(0, 255, 0)
        btn.TextSize = 12
        btn.Font = Enum.Font.SourceSansBold
        btn.BorderColor3 = Color3.fromRGB(0, 255, 0)
        btn.BorderSizePixel = 1
        
        -- Add toggle buttons
        if tab == "Aimbot" then
            local toggle = Instance.new("TextButton")
            toggle.Parent = self.MainFrame
            toggle.Size = UDim2.new(0.8, 0, 0, 30)
            toggle.Position = UDim2.new(0.1, 0, 0.2, 0)
            toggle.BackgroundColor3 = Color3.fromRGB(0, 40, 0)
            toggle.Text = "Aimbot: " .. (Config.AimBot.Enabled and "ON" or "OFF")
            toggle.TextColor3 = Color3.fromRGB(0, 255, 0)
            toggle.TextSize = 14
            toggle.Font = Enum.Font.SourceSansBold
            toggle.BorderColor3 = Color3.fromRGB(0, 255, 0)
            toggle.BorderSizePixel = 1
            
            toggle.MouseButton1Click:Connect(function()
                Config.AimBot.Enabled = not Config.AimBot.Enabled
                toggle.Text = "Aimbot: " .. (Config.AimBot.Enabled and "ON" or "OFF")
                toggle.TextColor3 = Config.AimBot.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            end)
        end
        
        if tab == "ESP" then
            local toggle = Instance.new("TextButton")
            toggle.Parent = self.MainFrame
            toggle.Size = UDim2.new(0.8, 0, 0, 30)
            toggle.Position = UDim2.new(0.1, 0, 0.2, 0)
            toggle.BackgroundColor3 = Color3.fromRGB(0, 40, 0)
            toggle.Text = "ESP: " .. (Config.ESP.Enabled and "ON" or "OFF")
            toggle.TextColor3 = Color3.fromRGB(0, 255, 0)
            toggle.TextSize = 14
            toggle.Font = Enum.Font.SourceSansBold
            toggle.BorderColor3 = Color3.fromRGB(0, 255, 0)
            toggle.BorderSizePixel = 1
            
            toggle.MouseButton1Click:Connect(function()
                Config.ESP.Enabled = not Config.ESP.Enabled
                toggle.Text = "ESP: " .. (Config.ESP.Enabled and "ON" or "OFF")
                toggle.TextColor3 = Config.ESP.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                if not Config.ESP.Enabled then
                    ESP:Clear()
                end
            end)
        end
        
        if tab == "Trigger" then
            local toggle = Instance.new("TextButton")
            toggle.Parent = self.MainFrame
            toggle.Size = UDim2.new(0.8, 0, 0, 30)
            toggle.Position = UDim2.new(0.1, 0, 0.2, 0)
            toggle.BackgroundColor3 = Color3.fromRGB(0, 40, 0)
            toggle.Text = "TriggerBot: " .. (Config.TriggerBot.Enabled and "ON" or "OFF")
            toggle.TextColor3 = Color3.fromRGB(0, 255, 0)
            toggle.TextSize = 14
            toggle.Font = Enum.Font.SourceSansBold
            toggle.BorderColor3 = Color3.fromRGB(0, 255, 0)
            toggle.BorderSizePixel = 1
            
            toggle.MouseButton1Click:Connect(function()
                Config.TriggerBot.Enabled = not Config.TriggerBot.Enabled
                toggle.Text = "TriggerBot: " .. (Config.TriggerBot.Enabled and "ON" or "OFF")
                toggle.TextColor3 = Config.TriggerBot.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            end)
        end
        
        if tab == "Movement" then
            local toggle = Instance.new("TextButton")
            toggle.Parent = self.MainFrame
            toggle.Size = UDim2.new(0.8, 0, 0, 30)
            toggle.Position = UDim2.new(0.1, 0, 0.2, 0)
            toggle.BackgroundColor3 = Color3.fromRGB(0, 40, 0)
            toggle.Text = "Bhop: " .. (Config.Movement.Bhop and "ON" or "OFF")
            toggle.TextColor3 = Color3.fromRGB(0, 255, 0)
            toggle.TextSize = 14
            toggle.Font = Enum.Font.SourceSansBold
            toggle.BorderColor3 = Color3.fromRGB(0, 255, 0)
            toggle.BorderSizePixel = 1
            
            toggle.MouseButton1Click:Connect(function()
                Config.Movement.Bhop = not Config.Movement.Bhop
                toggle.Text = "Bhop: " .. (Config.Movement.Bhop and "ON" or "OFF")
                toggle.TextColor3 = Config.Movement.Bhop and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            end)
        end
        
        if tab == "Visuals" then
            local toggle = Instance.new("TextButton")
            toggle.Parent = self.MainFrame
            toggle.Size = UDim2.new(0.8, 0, 0, 30)
            toggle.Position = UDim2.new(0.1, 0, 0.2, 0)
            toggle.BackgroundColor3 = Color3.fromRGB(0, 40, 0)
            toggle.Text = "No Recoil: " .. (Config.Visuals.NoRecoil and "ON" or "OFF")
            toggle.TextColor3 = Color3.fromRGB(0, 255, 0)
            toggle.TextSize = 14
            toggle.Font = Enum.Font.SourceSansBold
            toggle.BorderColor3 = Color3.fromRGB(0, 255, 0)
            toggle.BorderSizePixel = 1
            
            toggle.MouseButton1Click:Connect(function()
                Config.Visuals.NoRecoil = not Config.Visuals.NoRecoil
                toggle.Text = "No Recoil: " .. (Config.Visuals.NoRecoil and "ON" or "OFF")
                toggle.TextColor3 = Config.Visuals.NoRecoil and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            end)
        end
        
        if tab == "Misc" then
            local toggle = Instance.new("TextButton")
            toggle.Parent = self.MainFrame
            toggle.Size = UDim2.new(0.8, 0, 0, 30)
            toggle.Position = UDim2.new(0.1, 0, 0.2, 0)
            toggle.BackgroundColor3 = Color3.fromRGB(0, 40, 0)
            toggle.Text = "Auto Reload: " .. (Config.Misc.AutoReload and "ON" or "OFF")
            toggle.TextColor3 = Color3.fromRGB(0, 255, 0)
            toggle.TextSize = 14
            toggle.Font = Enum.Font.SourceSansBold
            toggle.BorderColor3 = Color3.fromRGB(0, 255, 0)
            toggle.BorderSizePixel = 1
            
            toggle.MouseButton1Click:Connect(function()
                Config.Misc.AutoReload = not Config.Misc.AutoReload
                toggle.Text = "Auto Reload: " .. (Config.Misc.AutoReload and "ON" or "OFF")
                toggle.TextColor3 = Config.Misc.AutoReload and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            end)
        end
    end
    
    -- Close button
    local close = Instance.new("TextButton")
    close.Parent = self.MainFrame
    close.Size = UDim2.new(0, 30, 0, 30)
    close.Position = UDim2.new(1, -35, 0, 5)
    close.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
    close.Text = "✕"
    close.TextColor3 = Color3.fromRGB(255, 0, 0)
    close.TextSize = 18
    close.Font = Enum.Font.SourceSansBold
    close.BorderColor3 = Color3.fromRGB(255, 0, 0)
    close.BorderSizePixel = 1
    
    close.MouseButton1Click:Connect(function()
        self.ScreenGui:Destroy()
        GUI:ToggleGUI()
    end)
end

function GUI:ToggleGUI()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
        self.ScreenGui = nil
        self.MainFrame = nil
    else
        self:Create()
    end
end

-- ============================================================
-- KEYBIND HANDLING
-- ============================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Toggle GUI
    if input.KeyCode == Enum.KeyCode[Config.GUI.Keybind] then
        GUI:ToggleGUI()
    end
    
    -- TriggerBot
    if Config.TriggerBot.Enabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
        TriggerBot:Shoot()
    end
end)

-- ============================================================
-- MAIN LOOP
-- ============================================================

RunService.RenderStepped:Connect(function()
    -- AIMBOT
    AimBot:Update()
    
    -- ESP
    if Config.ESP.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                ESP:CreateEsp(player)
            end
        end
        ESP:Update()
    end
    
    -- MOVEMENT
    Movement:Bhop()
    Movement:NoFallDamage()
    
    -- VISUALS
    Visuals:NoRecoil()
    Visuals:NoSpread()
    Visuals:FullBright()
end)

-- ============================================================
-- CLEANUP
-- ============================================================

LocalPlayer.CharacterRemoving:Connect(function()
    ESP:Clear()
end)

print("✅ NEXUS ARSENAL V2.1 LOADED!")
print("📌 Press F1 to open GUI")
print("⚡ AUTHOR: PROFESOR_FATIH + NEXUS 1.0")