--[[
    Contains relevant types to the ProStore3 module
]]

local ProStore3 = require(script.Parent)
local Event = require(script.Parent.classes.Event)

export type eventList = {
    PlayerJoined : Event.Event,
    PlayerLeft : Event.Event,
    DataUpdated : Event.Event,
}

export type ProStore3 = typeof(ProStore3) | eventList

return nil