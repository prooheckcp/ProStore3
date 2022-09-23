local PlayerObject = {}
PlayerObject.__index = PlayerObject
PlayerObject.player = nil

function PlayerObject.new(player : Player) : PlayerObject
    assert(typeof(player) == "Instance" and player:IsA("Player"), "In order to create a PlayerObject an object of type Player must be given")
    local playerObject = setmetatable({}, PlayerObject)
    playerObject.player = player

    return playerObject
end

export type PlayerObject = {
    Get : (self : PlayerObject, path : string) -> any,
    Set : (self : PlayerObject, path : string, newValue  : any) -> any,
    Exists : (self : PlayerObject, path : string) -> boolean,
    Increment : (self : PlayerObject, path : string, amount : number) -> nil,
    AddElement : (self : PlayerObject, path : string, element : table) -> nil,
    GetTable : (self : PlayerObject)->table,
    ForcedSave : (self : PlayerObject) -> nil,
    WipeData : (self : PlayerObject) -> nil,
}

return PlayerObject