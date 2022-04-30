--Variables
local EventContainer : Dictionary<string | {(any)->nil}> = {}

local EventSystem = {}
EventSystem.eventConstructors = {}

function EventSystem.newEvent(eventName : string)
    local callbacksArray : {(any)->nil}= {}
    EventContainer[eventName] = callbacksArray

    local newEventConstructor : table = {}
    function newEventConstructor:Connect(method : (any)-> nil)
        if not (typeof(method) == "function") then
            return warn("Cannot only attach callbacks of type <Function>!")
        end
        table.insert(callbacksArray, method)
    end
    EventSystem.eventConstructors[eventName] = newEventConstructor
end

function EventSystem.fireEvent(eventName : string, ...)
    local callbacks : Array<(any)->nil> = EventContainer[eventName]
    if not eventName then
        return warn("No event by the name of ", eventName, " exists")
    end
    for _, method : (any) -> nil in pairs(callbacks) do
        method(...)
    end
end

return EventSystem