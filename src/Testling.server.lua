--[[
    This file is used to test ProStore3
]]

--Services
local ServerScriptService = game:GetService("ServerScriptService")

--Dependencies
local ProStore3 = require(ServerScriptService.ProStore3)

local function testChainedData()
    
end

--[[
    Get/Set/Increment/GetTable/WipeData

    Data:
    Level = 1,
    Inventory = {},
    Profile = {
        SomeInt = 2,
        Currency = 100,
        NestedProfile = {
            MoreNested = {
                Another = {
                    value = 3
                }
            }
        }
    }
]]
local function testDataManipulators(player : Player)
    local level : number = ProStore3.Get(player, "Level")
    local currency : number = ProStore3.Get(player, "Profile.Currency")
    print("Level: ", level, " Currency: ", currency)

    ProStore3.Increment(player, "Profile.Currency", 10)
    print("Currency after increment: ", ProStore3.Get(player, "Profile.Currency"))

    ProStore3.Set(player, "Level", 3)
    print("Level after set: ", ProStore3.Get(player, "Level"))

    local fullData : Player = ProStore3.GetTable(player)
    print(fullData) -- Check users full data after testing all setters

    ProStore3.WipeData(player)
    print(ProStore3.GetTable(player))

    --Test the add element
    print(ProStore3.Get(player, "Inventory"))
    ProStore3.AddElement(player, "Inventory", {id = "sword", damage = 2})
    print(ProStore3.Get(player, "Inventory"))
    ProStore3.AddElement(player, "Inventory", {id = "knife", damage = 3})
    print(ProStore3.Get(player, "Inventory"))
end

local function testEvents()
    ProStore3.PlayerJoined:Connect(function(player : Player, playerData : table, firstTime : boolean)
        print(player.Name, " joined the game.")
        print("Player data: ", playerData)
        print("First Time: ", firstTime)
        print("")

        testDataManipulators(player)
    end)

    ProStore3.PlayerLeft:Connect(function(player : Player, playerData : table)
        print(player.Name, " left the game.")
        print("Player data: ", playerData)
        print("")
    end)

    --[[
    ProStore3.DataUpdated:Connect(function(player : Player, playerData :table)
        print(player.Name, "'s data has been updated.")
        print("Player data: ", playerData)
        print("")
    end)        
    ]]
end

local function Main()
    testEvents()
end

Main()