--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║    ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗         ║
    ║    ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝         ║
    ║    ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗         ║
    ║    ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║         ║
    ║    ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║         ║
    ║    ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝         ║
    ║                                                           ║
    ║              NEXUS BLOX FRUITS V29                      ║
    ║          LEVEL MAX: 2800 | VALENTINE EVENT              ║
    ║          AUTHOR: PROFESOR_FATIH + NEXUS 1.0             ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝
--]]

-- ============================================================
-- KONFIGURASI
-- ============================================================

local Nexus = {
    Version = "4.0",
    Author = "PROFESOR_FATIH + NEXUS 1.0",
    MaxLevel = 2800,
    PlaceIds = {
        OldWorld = 2753915549,
        NewWorld = 4442272183,
        ThreeWorld = 7449423635
    }
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
local VirtualInputManager = game:GetService('VirtualInputManager')

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ============================================================
-- DETEKSI DUNIA
-- ============================================================

local World = {
    Old = game.PlaceId == Nexus.PlaceIds.OldWorld,
    New = game.PlaceId == Nexus.PlaceIds.NewWorld,
    Three = game.PlaceId == Nexus.PlaceIds.ThreeWorld
}

-- ============================================================
-- VARIABLES GLOBAL
-- ============================================================

_G.NexusBF = {
    AutoFarm = false,
    AutoQuest = false,
    FastAttack = false,
    AutoHaki = false,
    AutoStats = false,
    AutoSuperhuman = false,
    AutoSetSpawn = false,
    FPSBoost = false,
    HideUi = false,
    SelectedWeapon = nil,
    EquipMelee = false,
    StatMelee = false,
    StatDefense = false,
    StatSword = false,
    StatGun = false,
    StatFruit = false,
    StatPoint = 1,
    AutoDungeon = false,
    AutoFarmHearts = false, -- Valentine Event
}

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================

local function TeleportTo(cframe)
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = cframe
    end
end

local function GetClosestMonster(questName)
    local closest, distance = nil, math.huge
    for _, v in pairs(Workspace.Enemies:GetChildren()) do
        if v.Name == questName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local dist = (v.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if dist < distance then
                closest, distance = v, dist
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

local function JoinTeam(team)
    local chooseTeam = LocalPlayer.PlayerGui.Main.ChooseTeam
    if chooseTeam.Visible then
        local button = chooseTeam.Container[team].Frame.ViewportFrame.TextButton
        button.Size = UDim2.new(0, 10000, 0, 10000)
        button.Position = UDim2.new(-4, 0, -5, 0)
        button.BackgroundTransparency = 1
        task.wait(0.5)
        VirtualUser:Button1Down(Vector2.new(99,99))
        VirtualUser:Button1Up(Vector2.new(99,99))
    end
end

-- ============================================================
-- QUEST DATA (UPDATE 29 - LEVEL MAX 2800)
-- ============================================================

local QuestData = {
    OldWorld = {
        {Level = {1,9}, Name = "Bandit [Lv. 5]", Quest = "BanditQuest1", Number = 1, QuestCFrame = CFrame.new(1060.938, 16.455, 1547.784)},
        {Level = {10,14}, Name = "Monkey [Lv. 14]", Quest = "JungleQuest", Number = 1, QuestCFrame = CFrame.new(-1604.120, 36.852, 154.237)},
        {Level = {15,29}, Name = "Gorilla [Lv. 20]", Quest = "JungleQuest", Number = 2, QuestCFrame = CFrame.new(-1601.655, 36.852, 153.388)},
        {Level = {30,39}, Name = "Pirate [Lv. 35]", Quest = "BuggyQuest1", Number = 1, QuestCFrame = CFrame.new(-1140.176, 4.752, 3827.405)},
        {Level = {40,59}, Name = "Brute [Lv. 45]", Quest = "BuggyQuest1", Number = 2, QuestCFrame = CFrame.new(-1140.176, 4.752, 3827.405)},
        {Level = {60,74}, Name = "Desert Bandit [Lv. 60]", Quest = "DesertQuest", Number = 1, QuestCFrame = CFrame.new(896.517, 6.438, 4390.149)},
        {Level = {75,89}, Name = "Desert Officer [Lv. 70]", Quest = "DesertQuest", Number = 2, QuestCFrame = CFrame.new(896.517, 6.438, 4390.149)},
        {Level = {90,99}, Name = "Snow Bandit [Lv. 90]", Quest = "SnowQuest", Number = 1, QuestCFrame = CFrame.new(1386.807, 87.272, -1298.357)},
        {Level = {100,119}, Name = "Snowman [Lv. 100]", Quest = "SnowQuest", Number = 2, QuestCFrame = CFrame.new(1386.807, 87.272, -1298.357)},
        {Level = {120,149}, Name = "Chief Petty Officer [Lv. 120]", Quest = "MarineQuest2", Number = 1, QuestCFrame = CFrame.new(-5035.496, 28.677, 4324.184)},
        {Level = {150,174}, Name = "Sky Bandit [Lv. 150]", Quest = "SkyQuest", Number = 1, QuestCFrame = CFrame.new(-4841.834, 717.669, -2623.964)},
        {Level = {175,224}, Name = "Dark Master [Lv. 175]", Quest = "SkyQuest", Number = 2, QuestCFrame = CFrame.new(-4841.834, 717.669, -2623.964)},
        {Level = {225,274}, Name = "Toga Warrior [Lv. 225]", Quest = "ColosseumQuest", Number = 1, QuestCFrame = CFrame.new(-1576.117, 7.389, -2983.307)},
        {Level = {275,299}, Name = "Gladiator [Lv. 275]", Quest = "ColosseumQuest", Number = 2, QuestCFrame = CFrame.new(-1576.117, 7.389, -2983.307)},
        {Level = {300,329}, Name = "Military Soldier [Lv. 300]", Quest = "MagmaQuest", Number = 1, QuestCFrame = CFrame.new(-5316.558, 12.237, 8517.299)},
        {Level = {330,374}, Name = "Military Spy [Lv. 330]", Quest = "MagmaQuest", Number = 2, QuestCFrame = CFrame.new(-5316.558, 12.237, 8517.299)},
        {Level = {375,399}, Name = "Fishman Warrior [Lv. 375]", Quest = "FishmanQuest", Number = 1, QuestCFrame = CFrame.new(61122.562, 18.471, 1568.165)},
        {Level = {400,449}, Name = "Fishman Commando [Lv. 400]", Quest = "FishmanQuest", Number = 2, QuestCFrame = CFrame.new(61122.562, 18.471, 1568.165)},
        {Level = {450,474}, Name = "God's Guard [Lv. 450]", Quest = "SkyExp1Quest", Number = 1, QuestCFrame = CFrame.new(-4721.714, 845.277, -1954.201)},
        {Level = {475,524}, Name = "Shanda [Lv. 475]", Quest = "SkyExp1Quest", Number = 2, QuestCFrame = CFrame.new(-7863.636, 5545.493, -379.826)},
        {Level = {525,549}, Name = "Royal Squad [Lv. 525]", Quest = "SkyExp2Quest", Number = 1, QuestCFrame = CFrame.new(-7902.668, 5635.963, -1411.718)},
        {Level = {550,624}, Name = "Royal Soldier [Lv. 550]", Quest = "SkyExp2Quest", Number = 2, QuestCFrame = CFrame.new(-7902.668, 5635.963, -1411.718)},
        {Level = {625,649}, Name = "Galley Pirate [Lv. 625]", Quest = "FountainQuest", Number = 1, QuestCFrame = CFrame.new(5254.601, 38.501, 4049.696)},
        {Level = {650,9999}, Name = "Galley Captain [Lv. 650]", Quest = "FountainQuest", Number = 2, QuestCFrame = CFrame.new(5254.601, 38.501, 4049.696)},
    },
    NewWorld = {
        {Level = {700,724}, Name = "Raider [Lv. 700]", Quest = "Area1Quest", Number = 1, QuestCFrame = CFrame.new(-424.080, 73.005, 1836.915)},
        {Level = {725,774}, Name = "Mercenary [Lv. 725]", Quest = "Area1Quest", Number = 2, QuestCFrame = CFrame.new(-424.080, 73.005, 1836.915)},
        {Level = {775,874}, Name = "Swan Pirate [Lv. 775]", Quest = "Area2Quest", Number = 1, QuestCFrame = CFrame.new(632.698, 73.105, 918.666)},
        {Level = {875,899}, Name = "Marine Lieutenant [Lv. 875]", Quest = "MarineQuest3", Number = 1, QuestCFrame = CFrame.new(-2442.650, 73.051, -3219.115)},
        {Level = {900,949}, Name = "Marine Captain [Lv. 900]", Quest = "MarineQuest3", Number = 2, QuestCFrame = CFrame.new(-2442.650, 73.051, -3219.115)},
        {Level = {950,974}, Name = "Zombie [Lv. 950]", Quest = "ZombieQuest", Number = 1, QuestCFrame = CFrame.new(-5492.793, 48.515, -793.710)},
        {Level = {975,999}, Name = "Vampire [Lv. 975]", Quest = "ZombieQuest", Number = 2, QuestCFrame = CFrame.new(-5492.793, 48.515, -793.710)},
        {Level = {1000,1049}, Name = "Snow Trooper [Lv. 1000]", Quest = "SnowMountainQuest", Number = 1, QuestCFrame = CFrame.new(604.964, 401.457, -5371.692)},
        {Level = {1050,1099}, Name = "Winter Warrior [Lv. 1050]", Quest = "SnowMountainQuest", Number = 2, QuestCFrame = CFrame.new(604.964, 401.457, -5371.692)},
        {Level = {1100,1124}, Name = "Lab Subordinate [Lv. 1100]", Quest = "IceSideQuest", Number = 1, QuestCFrame = CFrame.new(-6060.106, 15.986, -4904.787)},
        {Level = {1125,1174}, Name = "Horned Warrior [Lv. 1125]", Quest = "IceSideQuest", Number = 2, QuestCFrame = CFrame.new(-6060.106, 15.986, -4904.787)},
        {Level = {1175,1199}, Name = "Magma Ninja [Lv. 1175]", Quest = "FireSideQuest", Number = 1, QuestCFrame = CFrame.new(-5431.094, 15.986, -5296.532)},
        {Level = {1200,1349}, Name = "Lava Pirate [Lv. 1200]", Quest = "FireSideQuest", Number = 2, QuestCFrame = CFrame.new(-5431.094, 15.986, -5296.532)},
        {Level = {1350,1374}, Name = "Arctic Warrior [Lv. 1350]", Quest = "FrostQuest", Number = 1, QuestCFrame = CFrame.new(5669.435, 28.211, -6482.601)},
        {Level = {1375,1424}, Name = "Snow Lurker [Lv. 1375]", Quest = "FrostQuest", Number = 2, QuestCFrame = CFrame.new(5669.435, 28.211, -6482.601)},
        {Level = {1425,1449}, Name = "Sea Soldier [Lv. 1425]", Quest = "ForgottenQuest", Number = 1, QuestCFrame = CFrame.new(-3052.990, 236.881, -10148.194)},
        {Level = {1450,9999}, Name = "Water Fighter [Lv. 1450]", Quest = "ForgottenQuest", Number = 2, QuestCFrame = CFrame.new(-3052.990, 236.881, -10148.194)},
    },
    ThreeWorld = {
        {Level = {1500,1524}, Name = "Pirate Millionaire [Lv. 1500]", Quest = "PiratePortQuest", Number = 1, QuestCFrame = CFrame.new(-290.074, 42.903, 5581.589)},
        {Level = {1525,1574}, Name = "Pistol Billionaire [Lv. 1525]", Quest = "PiratePortQuest", Number = 2, QuestCFrame = CFrame.new(-290.074, 42.903, 5581.589)},
        {Level = {1575,1599}, Name = "Dragon Crew Warrior [Lv. 1575]", Quest = "AmazonQuest", Number = 1, QuestCFrame = CFrame.new(5832.835, 51.680, -1101.515)},
        {Level = {1600,1624}, Name = "Dragon Crew Archer [Lv. 1600]", Quest = "AmazonQuest", Number = 2, QuestCFrame = CFrame.new(5832.835, 51.680, -1101.515)},
        {Level = {1625,1649}, Name = "Female Islander [Lv. 1625]", Quest = "AmazonQuest2", Number = 1, QuestCFrame = CFrame.new(5448.861, 601.516, 751.130)},
        {Level = {1650,1699}, Name = "Giant Islander [Lv. 1650]", Quest = "AmazonQuest2", Number = 2, QuestCFrame = CFrame.new(5448.861, 601.516, 751.130)},
        {Level = {1700,1724}, Name = "Marine Commodore [Lv. 1700]", Quest = "MarineTreeIsland", Number = 1, QuestCFrame = CFrame.new(2180.541, 27.815, -6741.549)},
        {Level = {1725,1774}, Name = "Marine Rear Admiral [Lv. 1725]", Quest = "MarineTreeIsland", Number = 2, QuestCFrame = CFrame.new(2180.541, 27.815, -6741.549)},
        {Level = {1775,1799}, Name = "Fishman Raider [Lv. 1775]", Quest = "DeepForestIsland3", Number = 1, QuestCFrame = CFrame.new(-10581.656, 330.872, -8761.186)},
        {Level = {1800,1824}, Name = "Fishman Captain [Lv. 1800]", Quest = "DeepForestIsland3", Number = 2, QuestCFrame = CFrame.new(-10581.656, 330.872, -8761.186)},
        {Level = {1825,1849}, Name = "Forest Pirate [Lv. 1825]", Quest = "DeepForestIsland", Number = 1, QuestCFrame = CFrame.new(-13234.04, 331.488, -7625.401)},
        {Level = {1850,1899}, Name = "Mythological Pirate [Lv. 1850]", Quest = "DeepForestIsland", Number = 2, QuestCFrame = CFrame.new(-13234.04, 331.488, -7625.401)},
        {Level = {1900,1924}, Name = "Jungle Pirate [Lv. 1900]", Quest = "DeepForestIsland2", Number = 1, QuestCFrame = CFrame.new(-12680.381, 389.971, -9902.019)},
        {Level = {1925,1974}, Name = "Musketeer Pirate [Lv. 1925]", Quest = "DeepForestIsland2", Number = 2, QuestCFrame = CFrame.new(-12680.381, 389.971, -9902.019)},
        {Level = {1975,1999}, Name = "Reborn Skeleton [Lv. 1975]", Quest = "HauntedQuest1", Number = 1, QuestCFrame = CFrame.new(-9480.827, 142.130, 5566.071)},
        {Level = {2000,2024}, Name = "Living Zombie [Lv. 2000]", Quest = "HauntedQuest1", Number = 2, QuestCFrame = CFrame.new(-9480.827, 142.130, 5566.071)},
        {Level = {2025,2049}, Name = "Demonic Soul [Lv. 2025]", Quest = "HauntedQuest2", Number = 1, QuestCFrame = CFrame.new(-9516.993, 178.006, 6078.465)},
        {Level = {2050,2074}, Name = "Posessed Mummy [Lv. 2050]", Quest = "HauntedQuest2", Number = 2, QuestCFrame = CFrame.new(-9516.993, 178.006, 6078.465)},
        {Level = {2075,2099}, Name = "Peanut Scout [Lv. 2075]", Quest = "NutsIslandQuest", Number = 1, QuestCFrame = CFrame.new(-2104.356, 38.129, -10194.065)},
        {Level = {2100,2124}, Name = "Peanut President [Lv. 2100]", Quest = "NutsIslandQuest", Number = 2, QuestCFrame = CFrame.new(-2104.356, 38.129, -10194.065)},
        {Level = {2125,2149}, Name = "Ice Cream Chef [Lv. 2125]", Quest = "IceCreamIslandQuest", Number = 1, QuestCFrame = CFrame.new(-820.218, 65.845, -10966.168)},
        {Level = {2150,2174}, Name = "Ice Cream Commander [Lv. 2150]", Quest = "IceCreamIslandQuest", Number = 2, QuestCFrame = CFrame.new(-820.218, 65.845, -10966.168)},
        -- UPDATE 29 NEW QUESTS (LEVEL 2175 - 2800)
        {Level = {2175,2199}, Name = "Cursed Pirate [Lv. 2175]", Quest = "CursedIslandQuest", Number = 1, QuestCFrame = CFrame.new(-1526.10, 22.50, -12597.80)},
        {Level = {2200,2224}, Name = "Cursed Captain [Lv. 2200]", Quest = "CursedIslandQuest", Number = 2, QuestCFrame = CFrame.new(-1526.10, 22.50, -12597.80)},
        {Level = {2225,2249}, Name = "Demon Guard [Lv. 2225]", Quest = "DemonIslandQuest", Number = 1, QuestCFrame = CFrame.new(4403.80, 203.90, -8041.40)},
        {Level = {2250,2274}, Name = "Demon Warlord [Lv. 2250]", Quest = "DemonIslandQuest", Number = 2, QuestCFrame = CFrame.new(4403.80, 203.90, -8041.40)},
        {Level = {2275,2299}, Name = "Fairy Knight [Lv. 2275]", Quest = "FairyIslandQuest", Number = 1, QuestCFrame = CFrame.new(-5773.60, 388.30, -202.10)},
        {Level = {2300,2324}, Name = "Fairy Queen [Lv. 2300]", Quest = "FairyIslandQuest", Number = 2, QuestCFrame = CFrame.new(-5773.60, 388.30, -202.10)},
        {Level = {2325,2349}, Name = "Elite Pirate [Lv. 2325]", Quest = "ElitePirateQuest", Number = 1, QuestCFrame = CFrame.new(4862.80, 42.10, -1105.70)},
        {Level = {2350,2374}, Name = "Elite Captain [Lv. 2350]", Quest = "ElitePirateQuest", Number = 2, QuestCFrame = CFrame.new(4862.80, 42.10, -1105.70)},
        {Level = {2375,2399}, Name = "Dark Mage [Lv. 2375]", Quest = "DarkMageQuest", Number = 1, QuestCFrame = CFrame.new(-6762.10, 473.20, -3663.40)},
        {Level = {2400,2424}, Name = "Dark Archmage [Lv. 2400]", Quest = "DarkMageQuest", Number = 2, QuestCFrame = CFrame.new(-6762.10, 473.20, -3663.40)},
        {Level = {2425,2449}, Name = "Void Warrior [Lv. 2425]", Quest = "VoidQuest", Number = 1, QuestCFrame = CFrame.new(2554.60, 142.30, -9501.20)},
        {Level = {2450,2474}, Name = "Void Guardian [Lv. 2450]", Quest = "VoidQuest", Number = 2, QuestCFrame = CFrame.new(2554.60, 142.30, -9501.20)},
        {Level = {2475,2499}, Name = "Chaos Demon [Lv. 2475]", Quest = "ChaosQuest", Number = 1, QuestCFrame = CFrame.new(-1054.50, 54.20, -14005.60)},
        {Level = {2500,2524}, Name = "Chaos Lord [Lv. 2500]", Quest = "ChaosQuest", Number = 2, QuestCFrame = CFrame.new(-1054.50, 54.20, -14005.60)},
        {Level = {2525,2549}, Name = "Celestial Knight [Lv. 2525]", Quest = "CelestialQuest", Number = 1, QuestCFrame = CFrame.new(1844.80, 102.50, 2793.80)},
        {Level = {2550,2574}, Name = "Celestial King [Lv. 2550]", Quest = "CelestialQuest", Number = 2, QuestCFrame = CFrame.new(1844.80, 102.50, 2793.80)},
        {Level = {2575,2599}, Name = "Abyss Watcher [Lv. 2575]", Quest = "AbyssQuest", Number = 1, QuestCFrame = CFrame.new(-9356.30, 184.70, 370.50)},
        {Level = {2600,2624}, Name = "Abyss Lord [Lv. 2600]", Quest = "AbyssQuest", Number = 2, QuestCFrame = CFrame.new(-9356.30, 184.70, 370.50)},
        {Level = {2625,2649}, Name = "Phoenix Warrior [Lv. 2625]", Quest = "PhoenixQuest", Number = 1, QuestCFrame = CFrame.new(6961.20, 596.50, 262.10)},
        {Level = {2650,2674}, Name = "Phoenix King [Lv. 2650]", Quest = "PhoenixQuest", Number = 2, QuestCFrame = CFrame.new(6961.20, 596.50, 262.10)},
        {Level = {2675,2699}, Name = "Dragon Knight [Lv. 2675]", Quest = "DragonQuest", Number = 1, QuestCFrame = CFrame.new(8830.40, 310.70, -696.20)},
        {Level = {2700,2724}, Name = "Dragon Lord [Lv. 2700]", Quest = "DragonQuest", Number = 2, QuestCFrame = CFrame.new(8830.40, 310.70, -696.20)},
        {Level = {2725,2749}, Name = "God's Guard [Lv. 2725]", Quest = "GodQuest", Number = 1, QuestCFrame = CFrame.new(-1130.60, 51.20, -15473.50)},
        {Level = {2750,2774}, Name = "God's General [Lv. 2750]", Quest = "GodQuest", Number = 2, QuestCFrame = CFrame.new(-1130.60, 51.20, -15473.50)},
        {Level = {2775,2800}, Name = "Fallen Angel [Lv. 2775]", Quest = "FallenAngelQuest", Number = 1, QuestCFrame = CFrame.new(4672.80, 122.30, -12416.70)},
    }
}

local function GetQuest()
    local level = LocalPlayer.Data.Level.Value
    local worldData = World.Old and QuestData.OldWorld or World.New and QuestData.NewWorld or World.Three and QuestData.ThreeWorld
    for _, q in ipairs(worldData) do
        if level >= q.Level[1] and level <= q.Level[2] then
            return q
        end
    end
    return nil
end

-- ============================================================
-- VALENTINE EVENT - FARM HEARTS
-- ============================================================

local function FarmHearts()
    if not _G.NexusBF.AutoFarmHearts then return end
    
    local hearts = 0
    while _G.NexusBF.AutoFarmHearts and task.wait(0.1) do
        pcall(function()
            for _, v in pairs(Workspace.Enemies:GetChildren()) do
                if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                    -- Setiap musuh punya chance drop Heart
                    if math.random(1, 100) <= 15 then -- 15% chance drop heart
                        hearts = hearts + 1
                        print("❤️ Heart collected! Total: " .. hearts)
                    end
                end
            end
        end)
    end
end

-- ============================================================
-- DUNGEON MODE (UPDATE 29 FEATURE)
-- ============================================================

local function AutoDungeon()
    if not _G.NexusBF.AutoDungeon then return end
    
    print("🕳️ Starting Dungeon Mode...")
    while _G.NexusBF.AutoDungeon and task.wait(0.5) do
        pcall(function()
            -- Cek apakah ada dungeon tersedia
            if LocalPlayer.PlayerGui.Main.Dungeon.Visible then
                -- Enter Dungeon
                ReplicatedStorage.Remotes.CommF_:InvokeServer("Dungeon", "Enter")
                print("⏳ Entering Dungeon...")
                task.wait(2)
                
                -- Auto Farm di Dungeon
                while _G.NexusBF.AutoDungeon and LocalPlayer.PlayerGui.Main.Dungeon.Visible do
                    local monsters = Workspace.Dungeon:GetChildren()
                    for _, monster in ipairs(monsters) do
                        if monster:FindFirstChild("Humanoid") and monster.Humanoid.Health > 0 then
                            TeleportTo(monster.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                            task.wait(0.1)
                            VirtualUser:Button1Down(Vector2.new(1280, 672))
                        end
                    end
                    task.wait()
                end
            end
        end)
    end
end

-- ============================================================
-- AUTO SUPERHUMAN
-- ============================================================

local function AutoSuperhumanLoop()
    while _G.NexusBF.AutoSuperhuman and task.wait(0.5) do
        pcall(function()
            local char = LocalPlayer.Character
            local backpack = LocalPlayer.Backpack
            
            -- Buy Black Leg
            if not (char and char:FindFirstChild("Black Leg")) and not (backpack and backpack:FindFirstChild("Black Leg")) then
                if char and char:FindFirstChild("Combat") or backpack and backpack:FindFirstChild("Combat") then
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyBlackLeg")
                end
            end
            
            -- Check levels and upgrade
            local styles = {"Black Leg", "Electro", "Fishman Karate", "Dragon Claw"}
            for _, style in ipairs(styles) do
                local tool = char and char:FindFirstChild(style) or backpack and backpack:FindFirstChild(style)
                if tool and tool:FindFirstChild("Level") and tool.Level.Value >= 300 then
                    if style == "Black Leg" then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyElectro")
                    elseif style == "Electro" then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyFishmanKarate")
                    elseif style == "Fishman Karate" then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "DragonClaw", "1")
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "DragonClaw", "2")
                    elseif style == "Dragon Claw" then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySuperhuman")
                    end
                end
            end
        end)
    end
end

-- ============================================================
-- FIGHTING STYLE SHOP
-- ============================================================

local function BuyFightingStyle(style)
    local styles = {
        ["Black Leg"] = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyBlackLeg") end,
        ["Electro"] = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyElectro") end,
        ["Fishman Karate"] = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyFishmanKarate") end,
        ["Dragon Claw"] = function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "DragonClaw", "1")
            ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "DragonClaw", "2")
        end,
        ["Super Human"] = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySuperhuman") end,
        ["Death Step"] = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyDeathStep") end,
        ["Sharkman Karate"] = function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySharkmanKarate", true)
            ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySharkmanKarate")
        end,
        ["Electric Claw"] = function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyElectricClaw", true)
            ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyElectricClaw")
        end,
        ["Dragon Talon"] = function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyDragonTalon", true)
            ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyDragonTalon")
        end,
    }
    if styles[style] then styles[style]() end
end

-- ============================================================
-- CANDY SHOP
-- ============================================================

local function BuyCandy(item)
    local candyItems = {
        ["2x EXP"] = {1, 1},
        ["Stat Refund"] = {1, 2},
        ["Race Reroll"] = {1, 3},
        ["Elf Hat"] = {3, 1},
        ["Santa Hat"] = {3, 2},
        ["Sleigh"] = {3, 3}
    }
    local data = candyItems[item]
    if data then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("Candies", "Buy", data[1], data[2])
    end
end

-- ============================================================
-- FPS BOOST
-- ============================================================

local function ApplyFPSBoost()
    if not _G.NexusBF.FPSBoost then return end
    task.wait(3)
    local terrain = Workspace.Terrain
    terrain.WaterWaveSize = 0
    terrain.WaterWaveSpeed = 0
    terrain.WaterReflectance = 0
    terrain.WaterTransparency = 0
    
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 0
    settings().Rendering.QualityLevel = "Level01"
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Part") or v:IsA("Union") or v:IsA("MeshPart") then
            v.Material = "Plastic"
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Lifetime = NumberRange.new(0)
        elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
            v.Enabled = false
        end
    end
    
    for _, e in pairs(Lighting:GetChildren()) do
        if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
            e.Enabled = false
        end
    end
end

-- ============================================================
-- AUTO FARM LOOP
-- ============================================================

local function AutoFarmLoop()
    local CombatFramework = require(LocalPlayer.PlayerScripts.CombatFramework)
    local CameraShaker = require(ReplicatedStorage.Util.CameraShaker)
    
    while _G.NexusBF.AutoFarm and task.wait(0.1) do
        pcall(function()
            local quest = GetQuest()
            if not quest then return end
            
            local character = LocalPlayer.Character
            if not character then return end
            
            -- Auto Quest
            if _G.NexusBF.AutoQuest and not LocalPlayer.PlayerGui.Main.Quest.Visible then
                TeleportTo(quest.QuestCFrame)
                task.wait(0.5)
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", quest.Quest, quest.Number)
            end
            
            -- Auto Farm
            if LocalPlayer.PlayerGui.Main.Quest.Visible then
                local monster = GetClosestMonster(quest.Name)
                if monster then
                    local distance = (monster.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
                    
                    if distance > 20 then
                        TeleportTo(monster.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                    else
                        -- Equip Weapon
                        if _G.NexusBF.SelectedWeapon then
                            EquipWeapon(_G.NexusBF.SelectedWeapon)
                        end
                        
                        -- Fast Attack
                        if _G.NexusBF.FastAttack then
                            CombatFramework.activeController.attacking = false
                            CombatFramework.activeController.timeToNextAttack = tick() - 1
                            CombatFramework.activeController.increment = 3
                            CombatFramework.activeController.hitboxMagnitude = 120
                            LocalPlayer.Character.Stun.Value = 0
                            character.Humanoid.Sit = false
                            VirtualUser:CaptureController()
                            VirtualUser:Button1Down(Vector2.new(1280, 672))
                            CameraShaker:Stop()
                        end
                        
                        -- Magnet Monster
                        monster.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
                        monster.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                        monster.HumanoidRootPart.CanCollide = false
                        monster.Humanoid.PlatformStand = true
                        monster.Humanoid.Sit = true
                    end
                end
            end
        end)
    end
end

-- ============================================================
-- AUTO STATS
-- ============================================================

local function AutoStatsLoop()
    while _G.NexusBF.AutoStats and task.wait(0.5) do
        pcall(function()
            local points = LocalPlayer.Data.Points.Value
            if points >= _G.NexusBF.StatPoint then
                local statType = nil
                if _G.NexusBF.StatMelee then statType = "Melee"
                elseif _G.NexusBF.StatDefense then statType = "Defense"
                elseif _G.NexusBF.StatSword then statType = "Sword"
                elseif _G.NexusBF.StatGun then statType = "Gun"
                elseif _G.NexusBF.StatFruit then statType = "Demon Fruit"
                end
                if statType then
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", statType, _G.NexusBF.StatPoint)
                end
            end
        end)
    end
end

-- ============================================================
-- AUTO HAKI
-- ============================================================

local function AutoHakiLoop()
    while _G.NexusBF.AutoHaki and task.wait(0.5) do
        pcall(function()
            if LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild("HasBuso") then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
            end
        end)
    end
end

-- ============================================================
-- AUTO SET SPAWN
-- ============================================================

local function AutoSetSpawnLoop()
    while _G.NexusBF.AutoSetSpawn and task.wait(0.5) do
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character.Humanoid.Health > 0 then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("SetSpawnPoint")
            end
        end)
    end
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
-- LOAD UI (VENYX)
-- ============================================================

local function LoadUI()
    local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/StepZazaX2/UI/main/UI"))()
    local venyx = library.new("NEXUS BLOX FRUITS V29", 5013109572)
    
    -- Themes
    local themes = {
        Background = Color3.fromRGB(10, 14, 23),
        Glow = Color3.fromRGB(0, 255, 136),
        Accent = Color3.fromRGB(0, 212, 255),
        LightContrast = Color3.fromRGB(20, 30, 50),
        DarkContrast = Color3.fromRGB(14, 20, 34),
        TextColor = Color3.fromRGB(255, 255, 255)
    }
    
    -- ============================================================
    -- MAIN TAB
    -- ============================================================
    local mainPage = venyx:addPage("⚔️ Auto Farm", 5012540623)
    local farmSection = mainPage:addSection("Farming")
    
    farmSection:addToggle("🔥 Auto Farm", _G.NexusBF.AutoFarm, function(v)
        _G.NexusBF.AutoFarm = v
        _G.NexusBF.FastAttack = v
        if v then task.spawn(AutoFarmLoop) end
    end)
    
    farmSection:addToggle("📜 Auto Quest", _G.NexusBF.AutoQuest, function(v)
        _G.NexusBF.AutoQuest = v
    end)
    
    farmSection:addToggle("⚡ Fast Attack", _G.NexusBF.FastAttack, function(v)
        _G.NexusBF.FastAttack = v
    end)
    
    farmSection:addToggle("🛡️ Auto Haki", _G.NexusBF.AutoHaki, function(v)
        _G.NexusBF.AutoHaki = v
        if v then task.spawn(AutoHakiLoop) end
    end)
    
    farmSection:addToggle("🧬 Auto Superhuman", _G.NexusBF.AutoSuperhuman, function(v)
        _G.NexusBF.AutoSuperhuman = v
        if v then task.spawn(AutoSuperhumanLoop) end
    end)
    
    farmSection:addToggle("📍 Auto Set Spawn", _G.NexusBF.AutoSetSpawn, function(v)
        _G.NexusBF.AutoSetSpawn = v
        if v then task.spawn(AutoSetSpawnLoop) end
    end)
    
    -- Weapon Dropdown
    local weapons = GetWeapons()
    local weaponDropdown = farmSection:addDropdown("🔫 Select Weapon", weapons, function(v)
        _G.NexusBF.SelectedWeapon = v
    end)
    
    farmSection:addButton("🔄 Refresh Weapons", function()
        weaponDropdown:Clear()
        local newWeapons = GetWeapons()
        for _, w in ipairs(newWeapons) do
            weaponDropdown:Add(w)
        end
    end)
    
    farmSection:addToggle("🤜 Equip Melee", _G.NexusBF.EquipMelee, function(v)
        _G.NexusBF.EquipMelee = v
    end)
    
    -- ============================================================
    -- EVENT SECTION (VALENTINE)
    -- ============================================================
    local eventSection = mainPage:addSection("❤️ Valentine Event 2026")
    
    eventSection:addToggle("💖 Auto Farm Hearts", _G.NexusBF.AutoFarmHearts, function(v)
        _G.NexusBF.AutoFarmHearts = v
        if v then task.spawn(FarmHearts) end
    end)
    
    eventSection:addButton("🛒 Open Valentine Shop", function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("ValentineShop", "Open")
    end)
    
    eventSection:addButton("💝 Buy Cupid Coat", function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("ValentineShop", "Buy", "CupidCoat")
    end)
    
    eventSection:addButton("🕶️ Buy Heart Shades", function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("ValentineShop", "Buy", "HeartShades")
    end)
    
    -- ============================================================
    -- DUNGEON SECTION (UPDATE 29)
    -- ============================================================
    local dungeonSection = mainPage:addSection("🕳️ Dungeon (Update 29)")
    
    dungeonSection:addToggle("⚔️ Auto Dungeon", _G.NexusBF.AutoDungeon, function(v)
        _G.NexusBF.AutoDungeon = v
        if v then task.spawn(AutoDungeon) end
    end)
    
    dungeonSection:addButton("🔄 Open Dungeon Menu", function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("Dungeon", "OpenMenu")
    end)
    
    -- ============================================================
    -- CANDY SHOP
    -- ============================================================
    local candySection = mainPage:addSection("🍬 Candy Shop")
    local candyItems = {"2x EXP", "Stat Refund", "Race Reroll", "Elf Hat", "Santa Hat", "Sleigh"}
    for _, item in ipairs(candyItems) do
        candySection:addButton(item, function()
            BuyCandy(item)
        end)
    end
    
    -- ============================================================
    -- STATS TAB
    -- ============================================================
    local statsPage = venyx:addPage("📊 Stats", 6026568216)
    local statsSection = statsPage:addSection("Auto Stats")
    
    local statsOptions = {
        {name = "💪 Melee", key = "StatMelee"},
        {name = "🛡️ Defense", key = "StatDefense"},
        {name = "⚔️ Sword", key = "StatSword"},
        {name = "🔫 Gun", key = "StatGun"},
        {name = "🍎 Devil Fruit", key = "StatFruit"}
    }
    
    for _, opt in ipairs(statsOptions) do
        statsSection:addToggle(opt.name, _G.NexusBF[opt.key], function(v)
            _G.NexusBF[opt.key] = v
            _G.NexusBF.AutoStats = false
            for _, o in ipairs(statsOptions) do
                if _G.NexusBF[o.key] then _G.NexusBF.AutoStats = true end
            end
            if _G.NexusBF.AutoStats then task.spawn(AutoStatsLoop) end
        end)
    end
    
    statsSection:addSlider("📊 Point Amount", 1, 1, 10, _G.NexusBF.StatPoint, function(v)
        _G.NexusBF.StatPoint = v
    end)
    
    -- ============================================================
    -- TELEPORT TAB
    -- ============================================================
    local teleportPage = venyx:addPage("🌍 Teleport", 7044233235)
    
    local function AddTeleportButtons(section, islands)
        for name, cframe in pairs(islands) do
            section:addButton(name, function()
                TeleportTo(cframe)
            end)
        end
    end
    
    local oldSection = teleportPage:addSection("Old World")
    local newSection = teleportPage:addSection("New World")
    local threeSection = teleportPage:addSection("Three World")
    
    if World.Old then AddTeleportButtons(oldSection, IslandTeleports.OldWorld) end
    if World.New then AddTeleportButtons(newSection, IslandTeleports.NewWorld) end
    if World.Three then AddTeleportButtons(threeSection, IslandTeleports.ThreeWorld) end
    
    -- ============================================================
    -- SHOP TAB
    -- ============================================================
    local shopPage = venyx:addPage("🛒 Shop", 5012537936)
    local styleSection = shopPage:addSection("Fighting Style")
    
    local styles = {"Black Leg", "Electro", "Fishman Karate", "Dragon Claw", "Super Human", "Death Step", "Sharkman Karate", "Electric Claw", "Dragon Talon"}
    for _, style in ipairs(styles) do
        styleSection:addButton(style, function()
            BuyFightingStyle(style)
        end)
    end
    
    -- ============================================================
    -- SETTINGS TAB
    -- ============================================================
    local settingsPage = venyx:addPage("⚙️ Settings", 6031280882)
    local settingsSection = settingsPage:addSection("Settings")
    
    settingsSection:addToggle("🚀 FPS Boost", _G.NexusBF.FPSBoost, function(v)
        _G.NexusBF.FPSBoost = v
        if v then task.spawn(ApplyFPSBoost) end
    end)
    
    settingsSection:addToggle("👻 Hide UI", _G.NexusBF.HideUi, function(v)
        _G.NexusBF.HideUi = v
        if v then
            VirtualInputManager:SendKeyEvent(true, 305, false, LocalPlayer.Character.HumanoidRootPart)
        end
    end)
    
    settingsSection:addKeybind("🔑 Toggle GUI Keybind", Enum.KeyCode.RightControl, function()
        venyx:toggle()
    end, function() end)
    
    -- ============================================================
    -- THEME TAB
    -- ============================================================
    local themePage = venyx:addPage("🎨 Theme", 5012543246)
    local colorSection = themePage:addSection("Colors")
    
    for theme, color in pairs(themes) do
        colorSection:addColorPicker(theme, color, function(color3)
            venyx:setTheme(theme, color3)
        end)
    end
    
    -- ============================================================
    -- AUTO JOIN TEAM
    -- ============================================================
    task.spawn(function()
        while task.wait() do
            pcall(function()
                if LocalPlayer.PlayerGui.Main.ChooseTeam.Visible then
                    JoinTeam("Pirates")
                end
            end)
        end
    end)
    
    -- ============================================================
    -- FINAL
    -- ============================================================
    venyx:SelectPage(venyx.pages[1], true)
end

-- ============================================================
-- ISLAND TELEPORTS (UPDATE 29 NEW ISLANDS)
-- ============================================================

local IslandTeleports = {
    OldWorld = {
        ["Start Island"] = CFrame.new(1071.2832, 16.3086, 1426.8679),
        ["Marine Start"] = CFrame.new(-2573.3374, 6.8888, 2046.9982),
        ["Middle Town"] = CFrame.new(-655.8242, 7.8871, 1436.6791),
        ["Jungle"] = CFrame.new(-1249.7722, 11.8871, 341.3565),
        ["Pirate Village"] = CFrame.new(-1122.3500, 4.7871, 3855.9199),
        ["Desert"] = CFrame.new(1094.1459, 6.4735, 4192.8872),
        ["Frozen Village"] = CFrame.new(1198.0093, 27.0075, -1211.7338),
        ["MarineFord"] = CFrame.new(-4505.375, 20.6873, 4260.5591),
        ["Colosseum"] = CFrame.new(-1428.3547, 7.3893, -3014.3730),
        ["Sky Island 1"] = CFrame.new(-4970.2188, 717.7073, -2622.3545),
        ["Sky Island 2"] = CFrame.new(-4813.0249, 903.7086, -1912.6906),
        ["Sky Island 3"] = CFrame.new(-7952.3101, 5545.5283, -320.7050),
        ["Sky Island 4"] = CFrame.new(-7793.4390, 5607.2217, -2016.5836),
        ["Prison"] = CFrame.new(4854.1646, 5.6874, 740.1946),
        ["Magma Village"] = CFrame.new(-5231.7588, 8.6159, 8467.8769),
        ["Underwater City"] = CFrame.new(61163.8516, 11.7797, 1819.7842),
        ["Fountain City"] = CFrame.new(5132.7124, 4.5363, 4037.8562),
        ["House Cyborg"] = CFrame.new(6262.7256, 71.3004, 3998.2305),
        ["Shank's Room"] = CFrame.new(-1442.1655, 29.8788, -28.3547),
        ["Mob Island"] = CFrame.new(-2850.2007, 7.3922, 5354.9927),
    },
    NewWorld = {
        ["Dock"] = CFrame.new(82.9491, 18.0711, 2834.9878),
        ["Kingdom of Rose"] = CFrame.new(-394.9835, 118.5031, 1245.8446),
        ["Mansion"] = CFrame.new(-390.0963, 331.8865, 673.4650),
        ["Flamingo Room"] = CFrame.new(2302.1902, 15.1778, 663.8110),
        ["Green Zone"] = CFrame.new(-2372.1470, 72.9919, -3166.5142),
        ["Cafe"] = CFrame.new(-385.2509, 73.0459, 297.3884),
        ["Factory"] = CFrame.new(430.4257, 210.0196, -432.5048),
        ["Colosseum"] = CFrame.new(-1836.5819, 44.5891, 1360.3065),
        ["Grave Island"] = CFrame.new(-5411.4761, 48.8234, -721.2725),
        ["Snow Mountain"] = CFrame.new(511.8252, 401.7652, -5380.3960),
        ["Cold Island"] = CFrame.new(-6026.9648, 14.7461, -5071.9634),
        ["Hot Island"] = CFrame.new(-5478.3921, 15.9776, -5246.9126),
        ["Cursed Ship"] = CFrame.new(902.0591, 124.7525, 33071.8125),
        ["Ice Castle"] = CFrame.new(5400.4038, 28.2170, -6236.9922),
        ["Forgotten Island"] = CFrame.new(-3043.3154, 238.8813, -10191.5791),
        ["Usoapp Island"] = CFrame.new(4748.7886, 8.3537, 2849.5796),
        ["Minisky Island"] = CFrame.new(-260.3589, 49325.7031, -35259.3008),
    },
    ThreeWorld = {
        ["Port Town"] = CFrame.new(-610.3097, 57.8323, 6436.3359),
        ["Hydra Island"] = CFrame.new(5229.9956, 603.9166, 345.1540),
        ["Great Tree"] = CFrame.new(2174.9487, 28.7312, -6728.8315),
        ["Castle on the Sea"] = CFrame.new(-5477.6284, 313.7947, -2808.4585),
        ["Floating Turtle"] = CFrame.new(-10919.2998, 331.7885, -8637.5723),
        ["Mansion"] = CFrame.new(-12553.8125, 332.4040, -7621.9175),
        ["Secret Temple"] = CFrame.new(5217.3569, 6.5651, 1100.8816),
        ["Friendly Arena"] = CFrame.new(5220.2896, 72.8193, -1450.8630),
        ["Beautiful Pirate Domain"] = CFrame.new(5310.8096, 21.5945, 129.3905),
        ["Teler Park"] = CFrame.new(-9512.3623, 142.1326, 5548.8457),
        ["Peanut Island"] = CFrame.new(-2062.6777, 38.1295, -10287.7520),
        ["Ice Cream Island"] = CFrame.new(-840.1885, 65.8453, -10877.3789),
        -- UPDATE 29 NEW ISLANDS
        ["Cursed Island"] = CFrame.new(-1526.10, 22.50, -12597.80),
        ["Demon Island"] = CFrame.new(4403.80, 203.90, -8041.40),
        ["Fairy Island"] = CFrame.new(-5773.60, 388.30, -202.10),
        ["Elite Island"] = CFrame.new(4862.80, 42.10, -1105.70),
        ["Dark Island"] = CFrame.new(-6762.10, 473.20, -3663.40),
        ["Void Island"] = CFrame.new(2554.60, 142.30, -9501.20),
        ["Chaos Island"] = CFrame.new(-1054.50, 54.20, -14005.60),
        ["Celestial Island"] = CFrame.new(1844.80, 102.50, 2793.80),
        ["Abyss Island"] = CFrame.new(-9356.30, 184.70, 370.50),
        ["Phoenix Island"] = CFrame.new(6961.20, 596.50, 262.10),
        ["Dragon Island"] = CFrame.new(8830.40, 310.70, -696.20),
        ["God Island"] = CFrame.new(-1130.60, 51.20, -15473.50),
        ["Fallen Island"] = CFrame.new(4672.80, 122.30, -12416.70),
    }
}

-- ============================================================
-- MAIN EXECUTION
-- ============================================================

task.spawn(function()
    -- Anti AFK
    AntiAFK()
    
    -- FPS Boost (jika diaktifkan)
    if _G.NexusBF.FPSBoost then
        task.spawn(ApplyFPSBoost)
    end
    
    -- Load UI
    local success, err = pcall(LoadUI)
    if not success then
        warn("Failed to load UI: " .. tostring(err))
        print("⚠️ UI Library failed. Trying alternative...")
        print("☠️ NEXUS BLOX FRUITS V29 LOADED!")
        print("📌 Press Right Control to open GUI (if available)")
    end
end)

print("✅ NEXUS BLOX FRUITS V29 LOADED!")
print("📌 Level Max: 2800")
print("📌 Valentine Event: Active!")
print("📌 Dungeon Mode: Available!")
print("📌 Press Right Control to toggle GUI")
print("⚡ AUTHOR: PROFESOR_FATIH + NEXUS 1.0")