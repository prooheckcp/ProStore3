---
sidebar_position: 6
---

# GetTable
Returns the whole table of the users data by reference.

**Parameters:**

| Name  |Type       |Description                              |
|-------|-----------|-----------------------------------------|
|player |``player`` | The player whose data we want to access |

**Returns:**

| Name     |Type      |Description                |
|----------|----------|---------------------------|
|usersData |``table`` |The whole data of the user |

**Example:**
```luau
local ServerScriptService = game:GetService("ServerScriptService")
local ProStore3 = require(ServerScriptService.ProStore3)

ProStore3.PlayerJoined:Connect(function(player : Player)
    local fullData : table = ProStore3.GetTable(player)
    print(fullData)
end)
```