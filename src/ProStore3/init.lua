--[[
    This library was created at the 4/29/2022 MM/DD/YYYY by Prooheckcp

    Contact:
        Discord: Prooheckcp#1906
        Twitter: @prooheckcp

    Prooheckcp is a full-time Portuguese game developer that works mainly with Roblox Studio and Unity.

    Updated: 09/23/2022

    Doccumentation: https://prooheckcp.github.io/ProStore3
]]

--Services
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

--Depencies
local DeepCopy = require(script.DeepCopy)
local Schema = require(script.Schema)
local Settings = require(script.Settings)
local Event = require(script.classes.Event)
local PlayerObject = require(script.PlayerObject)

--Constant
local META_PROPERTIES : Dictionary<string | string> = {
    Dynamic = "__Dynamic"
}
local KEY_SEPERATOR : string = "." 
local USER_KEY_FORMAT : string = "userData_"

--Variables
local DataStore = DataStoreService:GetDataStore(Settings)
local playerSocket : Dictionary<string | table> = {}
local storePaths : Dictionary<Player | Dictionary<string | table>> = {} --Stores tables memory addresses in relation to their paths
local playerFirstTime : Dictionary<Player | boolean> = {}

local ProStore3 = {}
ProStore3.PlayerJoined = Event.new()
ProStore3.PlayerLeft = Event.new()
ProStore3.DataUpdated = Event.new()

--Simple algorithm to browse thru all direcorties of a given function
local function binarySearchTree(object : table, callback : (parentTableReference : table, index : string, value : any)->nil) : nil
    local function browseNode(_object : table)
        local tableValues : {table} = {}
        for index : string, value : any in pairs(_object) do
            if typeof(value) == "table" then
                table.insert(tableValues, value)
                continue
            else
                callback(_object, index, value)
            end
        end
        for _, newTable : table in pairs(tableValues) do
            browseNode(newTable)
        end
    end
    browseNode(object)
end

--Generates the key that is used to store in the dataStore
local function generateUserKey(userID : number) : string
    return USER_KEY_FORMAT..tostring(userID)
end

local function warnWrapper(... : {string}) : nil
    if RunService:IsStudio() and not Settings.OutputWarnings.inStudio then
        return
    elseif not RunService:IsStudio() and RunService:IsServer() and not Settings.OutputWarnings.inReleased then
        return
    end
    warn(...)
end

--Returns if the player exists in the socket or not
local function userExists(player : Player) : boolean
    if not player then
       return false, warnWrapper("The given player nil!")
    end

    local userKey : string = generateUserKey(player.UserId)
    local userExists : boolean = not (playerSocket[userKey] == nil)
    if not userExists then
        warnWrapper("The given user: ", player.Name, " does not exist in the socket")
    end
    return userExists
end

--[[
    Returns a tuple with the user data as the first element
    and whether it is the first time or not for this user joining
    the experience
]]
local function getUserData(userID : number) : (table , boolean)
    local userKey : string = generateUserKey(userID)
    local success : boolean, userData : table  = pcall(function()
        return DataStore:GetAsync(userKey)
    end)

    if (RunService:IsStudio() and not Settings.LoadInStudio) or not success or typeof(userData) ~= "table" then
        warnWrapper("Failed to load: "..tostring(userID).."'s data")
        return DeepCopy(Schema), true
    else
        return userData, false
    end 
end

local function saveData(userID : number)
    if RunService:IsStudio() and not Settings.SaveInStudio then
        return
    end

    local userKey : string = generateUserKey(userID)
    local userData = playerSocket[userKey]

    if not userData then
        return warnWrapper("The given user by the ID of: "..tostring(userID).." is not in the player socket!")
    end

    binarySearchTree(userData, function(parentTable : table, index : string)
        local firstTwoLetters : string = string.sub(index, 1, 2)
        if firstTwoLetters == "__" then
            parentTable[index] = nil
        end
    end)

    local success : boolean, errorMessage : string = pcall(function()
        DataStore:SetAsync(userKey, userData)
    end)

    if not success then
        warnWrapper(errorMessage)
    end
end

local function cleanData(data : table)
    local function assertTable(mainTable : table, secondaryTable : table)
        for mainIndex : string, mainValue : any in pairs(mainTable) do
            local dataValue : any = secondaryTable[mainIndex]
            if not dataValue then
                if typeof(mainValue) == "table" then
                    secondaryTable[mainIndex] = DeepCopy(mainValue)
                else
                    secondaryTable[mainIndex] = mainValue
                end
            elseif typeof(mainValue) == "table" then
                assertTable(mainValue, dataValue)
            end
        end 
    end
    assertTable(Schema, data)
end

local function periodicalSave(player : Player)
    task.wait(Settings.AutoSave.TimeGap * 60)
    local userKey : string = generateUserKey(player.UserId)
    if playerSocket[userKey] then
        if Settings.AutoSave.Notifications then
            warnWrapper("Autosaving: ", player.Name, "'s data")
        end
        saveData(player.UserId)
        periodicalSave(player)
    end
end

local function playerJoined(player : Player)
    storePaths[player] = {}

    local playerData : table, firstTime : boolean = getUserData(player.UserId)
    local userKey : string = generateUserKey(player.UserId)
    cleanData(playerData)
    playerSocket[userKey] = playerData

    if Settings.AutoSave.Enabled then
        task.spawn(periodicalSave, player)
    end

    playerFirstTime[player] = firstTime
    ProStore3.PlayerJoined:Fire(player, playerData, firstTime)
end

local function playerLeft(player : Player)
    storePaths[player] = nil
    saveData(player.UserId)
    local userKey : string = generateUserKey(player.UserId)
    ProStore3.PlayerLeft:Fire(player, playerSocket[userKey])
    playerSocket[userKey] = nil
end

local function serverClosed()
    if RunService:IsStudio() and not Settings.SaveInStudio then
        return
    end

    for _, player : Player in pairs(Players:GetPlayers()) do
        saveData(player.UserId)
    end
end

-- Returns: value, success, parentTable
local function recursiveFind(mainTable : table, arguments : {string}, index) : (any, boolean, table)
    index = index or 1

    local value : any = mainTable[arguments[index]]
    if not value then
        if mainTable[META_PROPERTIES.Dynamic] then
            if index == #arguments then
                return nil , true, mainTable, arguments[index]
            end
        end

        return nil, false
    else
        if index >= #arguments then
            return value, true, mainTable, arguments[index]
        end
        if typeof(value) == "table" then
            return recursiveFind(value, arguments, index + 1)
        else
            return nil, false
        end
    end
end

local function recursiveFindWrapper(player : Player, argument : string)
    local userKey = generateUserKey(player.UserId)
    local arguments : {string} = string.split(argument, KEY_SEPERATOR)
    local userData : table = playerSocket[userKey]

    local parentInstance : table = storePaths[player][argument]
    if parentInstance then
        return parentInstance[arguments[#arguments]], true, parentInstance, arguments[#arguments]
    end

    local response = {recursiveFind(userData, arguments)}
    table.insert(response, arguments[#arguments])
    if response[2] then
        storePaths[player][argument] = response[3]
    end
    return table.unpack(response)
end

--[=[
    @param Player, ArgumentPath

    @return Whatever value the player currently has in the given path

    ```lua
    local ServerScriptService = game:GetService("ServerScriptService")
    local ProStore3 = require(ServerScriptService.ProStore3)

    ProStore3.PlayerJoined:Connect(function(player : Player)
        local level : number = ProStore3.Get(player, "Level")
        local currency : number = ProStore3.Get(player, "Profile.Currency")

        print("Level: ", level, " Currency: ", currency)
    end)
    ```
]=]
function ProStore3.Get(player : Player, argumentPath : string) : any
    assert(typeof(argumentPath) == 'string', 'The path must be of type String, received {'..typeof(argumentPath)..'} instead')
    if not userExists(player) then
        return
    end

    local value : any, success : boolean = recursiveFindWrapper(player, argumentPath)

    if not success then
        return warnWrapper("The given path is not valid: "..argumentPath)
    end

    return value
end

--[=[
    Sets a specific element of the players data.

    @param Player, ArgumentPath, newValue

    @return OldValue before the change was made

    ```lua
    local ServerScriptService = game:GetService("ServerScriptService")
    local ProStore3 = require(ServerScriptService.ProStore3)

    ProStore3.PlayerJoined:Connect(function(player : Player)
        local oldValue = ProStore3.Set(player, "Level", 3)
        print("Level after set: ", ProStore3.Get(player, "Level"))
    end)
    ```
]=]
function ProStore3.Set(player : Player, argumentPath : string, newValue : any) : any
    assert(typeof(argumentPath) == 'string', 'The path must be of type String, received {'..typeof(argumentPath)..'} instead')
    if not userExists(player) then
        return
    end

    local value : any, success : boolean, parentTable : table, valueIndex : string = recursiveFindWrapper(player, argumentPath)

    if not success then
        return warnWrapper("The given path is not valid: "..argumentPath)
    elseif value ~= nil and typeof(value) ~= typeof(newValue) then
        return warnWrapper("Invalid type. Expected <"..typeof(value).."> got <"..typeof(newValue).."> instead")
    end

    if newValue ~= value then
        parentTable[valueIndex] = newValue
        ProStore3.DataUpdated:Fire(player, valueIndex, newValue, argumentPath)        
    end

    return value
end

--[=[
    Checks if the given path value exists.

    [WARN] Should only be used on dynamic tables

    @param Player, ArgumentPath

    @return Exists : boolean

    ```lua
    local ServerScriptService = game:GetService("ServerScriptService")
    local ProStore3 = require(ServerScriptService.ProStore3)

    ProStore3.PlayerJoined:Connect(function(player : Player)
        print("Exist: ", ProStore3.Exists(player, "DynamicArray.test")) --false
        ProStore3.Set(player, "DynamicArray.test", 2)
        print("Exist: ", ProStore3.Exists(player, "DynamicArray.test")) --true
    end)
    ```
]=]
function ProStore3.Exists(player : Player, argumentPath : string) : boolean
    assert(typeof(argumentPath) == 'string', 'The path must be of type String, received {'..typeof(argumentPath)..'} instead')
    if not userExists(player) then
        return
    end

    local response = {recursiveFindWrapper(player, argumentPath)}

    return (response[2] and response[3][response[4]] ~= nil)
end

--[=[
    Increments a value of the players schema with a given path.
    Only works in numerical values

    @param Player, ArgumentPath, amount

    @return Void

    ```lua
    local ServerScriptService = game:GetService("ServerScriptService")
    local ProStore3 = require(ServerScriptService.ProStore3)

    ProStore3.PlayerJoined:Connect(function(player : Player)
        print(ProStore3.Get(player, "Level")) -- Output: 1
        ProStore3.Increment(player, "Level", 2)
        print(ProStore3.Get(player, "Level")) -- Output: 3
    end)
    ```
]=]
function ProStore3.Increment(player : Player, argumentPath : string, amount : number) : nil
    assert(typeof(argumentPath) == 'string', 'The path must be of type String, received {'..typeof(argumentPath)..'} instead')
    assert(typeof(amount) == 'number', 'The amount to be added must be of type number, received {'..typeof(amount)..'} instead')
    
    local value : any, success : boolean, parentTable : table, valueIndex : string = recursiveFindWrapper(player, argumentPath)

    if not success then
        return warnWrapper("The given path is not valid: "..argumentPath)
    end

    parentTable[valueIndex] = value + amount
    ProStore3.DataUpdated:Fire(player, valueIndex, parentTable[valueIndex], argumentPath)
end

--[=[
    Resets the player's data. Will turn the player data
    into the given data on a default Schema

    @param Player

    @return Void

    ```lua
    local ServerScriptService = game:GetService("ServerScriptService")
    local ProStore3 = require(ServerScriptService.ProStore3)

    ProStore3.PlayerJoined:Connect(function(player : Player)
        ProStore3.WipeData(player)
        print(ProStore3.GetTable(player)) -- will print the same as  in the schema.lua
    end)
    ```
]=]
function ProStore3.WipeData(player : Player) : nil
    if not userExists(player) then
        return
    end

    local userKey : string = generateUserKey(player.UserId)
    playerSocket[userKey] = DeepCopy(Schema)
    ProStore3.DataUpdated:Fire(player)
    saveData(player.UserId)
end

--[=[
    Returns the whole table holding the data of the given player

    @param Player

    @return Table

    ```lua
    local ServerScriptService = game:GetService("ServerScriptService")
    local ProStore3 = require(ServerScriptService.ProStore3)

    ProStore3.PlayerJoined:Connect(function(player : Player)
        local fullData : table = ProStore3.GetTable(player)
        print(fullData)
    end)
    ```
]=]
function ProStore3.GetTable(player : Player) : table
    if not userExists(player) then
        return
    end

    return playerSocket[generateUserKey(player.UserId)]
end

--[=[
    This method adds a new element into an array within the players
    data. This can be of native lua type of custom object created

    @param Player, ArgumentPath, Element

    @return Void

    ```lua
    local ServerScriptService = game:GetService("ServerScriptService")
    local ProStore3 = require(ServerScriptService.ProStore3)

    ProStore3.PlayerJoined:Connect(function(player : Player)
        print(ProStore3.Get(player, "Inventory"))
        ProStore3.AddElement(player, "Inventory", {id = "sword", damage = 2})
        print(ProStore3.Get(player, "Inventory"))
        ProStore3.AddElement(player, "Inventory", {id = "knife", damage = 3})
        print(ProStore3.Get(player, "Inventory"))
    end)
    ```
]=]
function ProStore3.AddElement(player : Player, argumentPath : string, element : any) : nil
    assert(typeof(argumentPath) == 'string', 'The path must be of type String, received {'..typeof(argumentPath)..'} instead')
    assert(element ~= nil, 'The element to be added to the array must be different from {nil}')
    if not userExists(player) then
        return
    end

    local value : any, success : boolean = recursiveFindWrapper(player, argumentPath)
    
    if not success then
        return warnWrapper("The given path is not valid: "..argumentPath)
    end

    local isTable : boolean = typeof(value) == "table"

    if isTable then
        local counter : number = 0
        for _, _ in pairs(value) do
            counter += 1
        end

        if counter > #value then
            isTable = false
        end
    end

    if not isTable then
        return warnWrapper("The chosen path is not an array")
    end

    table.insert(value, element)
end

--[=[
    Forces a player data to be saved. This method also
    gets automatically called every x amount of time if the
    auto-save is enabled and when the player leaves the experience

    @param Player

    @return Void

    ```lua
    local ServerScriptService = game:GetService("ServerScriptService")
    local ProStore3 = require(ServerScriptService.ProStore3)

    ProStore3.PlayerJoined:Connect(function(player : Player)
        --Do some data changes here
        ProStore3.Set(player, "level", 100)
        ---------------------------

        ProStore3.ForcedSave(player)
    end)
    ```
]=]
function ProStore3.ForcedSave(player : Player) : nil
    saveData(player.UserId)
end

--[=[
    Returns a new PlayerObject referencing the given player

    ```lua
    local playerObject : ProStore3.PlayerObject = ProStore3.GetPlayer(player)
    local level : number = playerObject:Get("Level")

    print("Level, ", level) -- 1
    playerObject:Set("Level", 3)
    print(playerObject:Get("Level")) -- 3
    playerObject:Increment("Level", 2)
    print(playerObject:Get("Level")) -- 2
    ```
]=]
function ProStore3.GetPlayer(player : Player)
    if not userExists(player) then
        return
    end

    return PlayerObject.new(player)    
end

--Setting up PlayerObject
function PlayerObject:Get(...) return ProStore3.Get(self.player, ...) end
function PlayerObject:Set(...) return ProStore3.Set(self.player, ...) end
function PlayerObject:Exists(...) return ProStore3.Exists(self.player, ...) end
function PlayerObject:Increment(...) return ProStore3.Increment(self.player, ...) end
function PlayerObject:AddElement(...) return ProStore3.AddElement(self.player, ...) end
function PlayerObject:GetTable(...) return ProStore3.GetTable(self.player, ...) end
function PlayerObject:ForcedSave(...) return ProStore3.ForcedSave(self.player, ...) end
function PlayerObject:WipeData(...) return ProStore3.WipeData(self.player, ...) end

ProStore3.PlayerObject = PlayerObject

--Events
Players.PlayerAdded:Connect(playerJoined)
Players.PlayerRemoving:Connect(playerLeft)
game:BindToClose(serverClosed)
ProStore3.PlayerJoined:AddMiddleWare(function()
    for _, player : Player in pairs(Players:GetPlayers()) do
        ProStore3.PlayerJoined:Fire(player, ProStore3.GetTable(player), playerFirstTime[player])
    end
end)

return ProStore3