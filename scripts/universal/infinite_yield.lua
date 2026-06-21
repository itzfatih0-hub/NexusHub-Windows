--[[
    INFINITE YIELD — UNIVERSAL ADMIN SCRIPT
    AUTHOR: EdgeIY
    VERSION: 2.0
    DESCRIPTION: Over 100+ commands for Roblox games
--]]

local InfiniteYield = loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()

-- Load with custom prefix
InfiniteYield:Load({
    Prefix = ";",
    SaveLocation = "InfiniteYield"
})

print("Infinite Yield Loaded! Use ;cmds to see all commands.")