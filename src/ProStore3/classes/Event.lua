--[[
    Event system written by @Prooheckcp
]]

local Players = game:GetService("Players")

export type Connection = {Disconnect : (self : Connection) -> nil}
export type Callback = {(callback : any) -> any}

local Event : Event = {}
Event.attachedCallbacks = {}

function Event.new() : Event
    local self : Event = setmetatable({
        attachedCallbacks = {}
    }, {__index = Event})

    self.new = nil

    return self
end

function Event:Fire(...) : nil
    for _, callback : Callback in pairs(self.attachedCallbacks) do
        pcall(callback, ...)
    end
end

function Event:Connect(callback : Callback) : Connection
    if typeof(callback) ~= "function" then
        return error("Callbacks must be of type: function!", 3)
    end

    local attachedCallbacks : {Callback} = self.attachedCallbacks
    table.insert(attachedCallbacks, callback)

    local connection : Connection = {}
    function connection:Disconnect()
        for index, _callback in pairs(attachedCallbacks) do
            if _callback == callback then
                table.remove(attachedCallbacks, index)
                break
            end 
        end
    end
    return connection
end

export type Event = typeof(Event)

return Event