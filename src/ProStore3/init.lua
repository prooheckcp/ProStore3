--[[
    This library was created at the 4/29/2022 MM/DD/YYYY by Prooheckcp

    Contact:
        Discord: Prooheckcp#1906
        Twitter: @prooheckcp

    Prooheckcp is a full-time Portuguese game developer that works mainly with Roblox Studio and Unity.
]]

--Services
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

--Depencies
local DeepCopy = require(script.DeepCopy)
local Schema = require(script.Schema)
local Settings = require(script.Settings)
local EventSystem = require(script.EventSystem)

--Constant
local KEY_SEPERATOR : string = "." 
local USER_KEY_FORMAT : string = "userData_"
local EVENT_LIST : Dictionary<string | string> = {
    PlayerJoined = "PlayerJoined",
    PlayerLeft = "PlayerLeft",
    DataUpdated = "DataUpdated"
}

--Variables
local DataStore = DataStoreService:GetDataStore(Settings)

local playerSocket : Dictionary<string | table> = {}
local storePaths : Dictionary<Player | Dictionary<string | table>> = {} --Stores tables memory addresses in relation to their paths

local function loadEvents() : nil
    for _, eventIndex : string in pairs(EVENT_LIST) do
        EventSystem.newEvent(eventIndex)
    end
end


--Helper methods
--Generates the key that is used to store in the dataStore
local function generateUserKey(userID : number)
    return USER_KEY_FORMAT..tostring(userID)
end

--Returns if the player exists in the socket or not
local function userExists(player : Player) : boolean
    local userKey : string = generateUserKey(player.UserId)
    local userExists : boolean = not (playerSocket[userKey] == nil)
    if not userExists then
        warn("The given user: ", player.Name, " does not exist in the socket")
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

    if not success or typeof(userData) ~= "table" then
        warn("Failed to load: "..tostring(userID).."'s data")
        return DeepCopy(Schema), true
    else
        return userData, false
    end 
end

--[[
    Saves the given user data
]]
local function saveData(userID : number)
    local userKey : string = generateUserKey(userID)
    local userData = playerSocket[userKey]

    if not userData then
        return warn("The given user by the ID of: "..tostring(userID).." is not in the player socket!")
    end

    local success : boolean, errorMessage : string = pcall(function()
        DataStore:SetAsync(userKey, userData)
    end)

    if not success then
        warn(errorMessage)
    end
end

--[[
    Assure that the given data is respecting the schema
    in usage
]]
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
            warn("Autosaving: ", player.Name, "'s data")
        end
        saveData(player.UserId)
        periodicalSave(player.userID)
    end
end

--[[
    Handle a player that just joined the experience
]]
local function playerJoined(player : Player)
    storePaths[player] = {}
    local playerData : table, firstTime : boolean = getUserData(player.UserId)
    local userKey : string = generateUserKey(player.UserId)
    cleanData(playerData)
    playerSocket[userKey] = playerData

    if Settings.AutoSave.Enabled then
        task.spawn(periodicalSave, player)
    end

    EventSystem.fireEvent(EVENT_LIST.PlayerJoined, player, playerData, firstTime)
end

--[[
    Handle a player that just left the experience
]]
local function playerLeft(player : Player)
    storePaths[player] = nil
    saveData(player.UserId)
    local userKey : string = generateUserKey(player.UserId)
    EventSystem.fireEvent(EVENT_LIST.PlayerLeft, player, playerSocket[userKey])
    playerSocket[userKey] = nil
end

--[[
    Handle when a server closes
]]
local function serverClosed()
    for userKey, userData in pairs(playerSocket) do
        pcall(function()
            DataStore:SetAsync(userKey, userData)
        end)
    end
end

-- Returns: value, success, parentTable
local function recursiveFind(mainTable : table, arguments : {string}, index) : (any, boolean, table)
    index = index or 1

    local value : any = mainTable[arguments[index]]
    if not value then
        if mainTable.__Dynamic then
            if index == #arguments then
                return nil , true, mainTable
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

--[[
    Exposed methods
]]
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

--[[
    Gets a specific element of the players data
]]
local function _get(player : Player, argument : string)
    if not userExists(player) then
        return
    end

    local value : any, success : boolean = recursiveFindWrapper(player, argument)

    if not success then
        return warn("The given path is not valid: "..argument)
    end

    return value
end

--[[
    Sets a specific element of the players data
]]
local function _set(player : Player, argument : string, newValue : any)
    if not userExists(player) then
        return
    end

    local value : any, success : boolean, parentTable : table, valueIndex : string = recursiveFindWrapper(player, argument)

    if not success then
        return warn("The given path is not valid: "..argument)
    elseif value ~= nil and typeof(value) ~= typeof(newValue) then
        return warn("Invalid type. Expected <"..typeof(value).."> got <"..typeof(newValue).."> instead")
    end

    if newValue ~= value then
        parentTable[valueIndex] = newValue
        EventSystem.fireEvent(EVENT_LIST.DataUpdated, player, playerSocket[generateUserKey(player.UserId)])        
    end

    return value
end

--[[
    Increments a value of the players schema
]]
local function _increment(player : Player, argument : string, amount : number)
    local value : any, success : boolean, parentTable : table, valueIndex : string = recursiveFindWrapper(player, argument)

    if not success then
        return warn("The given path is not valid: "..argument)
    end

    if typeof(value) ~= "number" then
        return warn("Increment can only be used on numerical values!")
    end

    parentTable[valueIndex] = value + amount
    EventSystem.fireEvent(EVENT_LIST.DataUpdated, player, playerSocket[generateUserKey(player.UserId)])
end

local function _wipeData(player : Player)
    if not userExists(player) then
        return
    end

    local userKey : string = generateUserKey(player.UserId)
    playerSocket[userKey] = DeepCopy(Schema)
    EventSystem.fireEvent(EVENT_LIST.DataUpdated, player, playerSocket[userKey])
    saveData(player.UserId)
end

--[[
    Gets the whole data table of the player
]]
local function _getTable(player : Player)
    if not userExists(player) then
        return
    end

    return playerSocket[generateUserKey(player.UserId)]
end

--[[
    Adds element to an array
]]
local function _addElement(player : Player, argument : string, element : any)
    if not userExists(player) then
        return
    end

    local value : any, success : boolean, parentTable : table = recursiveFindWrapper(player, argument)
    
    if not success then
        return warn("The given path is not valid: "..argument)
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
        return warn("The chosen path is not an array")
    end

    table.insert(value, element)
end

--[[
    Forces a player data to be saved
]]
local function _forcedSave(player : Player)
    saveData(player.UserId)
end

--Load systems
loadEvents()

--Events
Players.PlayerAdded:Connect(playerJoined)
Players.PlayerRemoving:Connect(playerLeft)

if not RunService:IsStudio() then
    game:BindToClose(serverClosed)
end

local exposedMethods : table = {
    Get = _get,
    Set = _set,
    Increment = _increment,
    AddElement = _addElement,
    GetTable = _getTable,
    ForcedSave = _forcedSave,
    WipeData = _wipeData
}

--Player object for chained events
local PlayerObject = {}
PlayerObject.__index = PlayerObject
PlayerObject.player = nil

function PlayerObject.new(player : Player)
    local playerObject = setmetatable({}, PlayerObject)
    playerObject.player = player

    for methodName : string, methodBody in pairs(exposedMethods) do
        playerObject[methodName] = function(self, ...)
            return methodBody(self.player, ...)
        end
    end

    return playerObject
end

exposedMethods.GetPlayer = function(player : Player)
    if not userExists(player) then
        return
    end

    return PlayerObject.new(player)
end

for eventName : string, eventConstructor : table in pairs(EventSystem.eventConstructors) do
    exposedMethods[eventName] = eventConstructor
end

return exposedMethods