--[[
    This file is used to test ProStore3
]]

--Services
local ServerScriptService = game:GetService("ServerScriptService")

--Dependencies
local ProStore3 = require(ServerScriptService.ProStore3)

local function testChainedData(player : Player)
    local playerObject = ProStore3.GetPlayer(player)
    local level : number = playerObject:Get("Level")
    print("Level, ", level)
    playerObject:Set("Level", 3)
    print(playerObject:Get("Level"))
    playerObject:Increment("Level", 2)
    print(playerObject:Get("Level"))
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

    ProStore3.ForcedSave(player)
end

local function testEvents()
   
    ProStore3.PlayerJoined:Connect(function(...)
        print("Player joined: ", ...)
        task.wait(2)
        ProStore3.Increment(({...})[1], "Profile.Currency", 3)
        task.wait(2)
        ProStore3.GetPlayer(({...})[1]):Set("Profile.Currency", 5)

    end)

    ProStore3.PlayerLeft:Connect(function(...)
        print("Player left: ", ...)
    end)

    ProStore3.DataUpdated:Connect(function(...)
        print("Data updated: ", ...)
    end)        
end

local function changeDynamicArrays(player : Player)
    print("Exist: ", ProStore3.Exists(player, "DynamicArray.test"))
    ProStore3.Set(player, "DynamicArray.test", 2)
    print("Exist: ", ProStore3.Exists(player, "DynamicArray.test"))
end

local function testDynamicData()
    ProStore3.PlayerJoined:Connect(function(player : Player, playerData : table, firstTime : boolean)
        print(ProStore3.GetTable(player))
        changeDynamicArrays(player)
        print(ProStore3.GetTable(player))
    end)
end

local function Main()
    testEvents()
  
end

Main()