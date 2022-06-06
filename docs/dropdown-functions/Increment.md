---
sidebar_position: 4
---

# Increment
Increments a value by the given amount. It only works on number type variables.

**Parameters:**

| Name  |Type       |Description                                        |
|-------|-----------|---------------------------------------------------|
|player |``player`` | The player whose data we want to access           |
|path   |``string`` | The path to the user data                         |
|amount |``number`` |The amount that we wish to increment into the value|

**Returns:**

|Name |Type    |Description |
|-----|--------|------------|
|     |``void``|            |

**Example:**
```luau
local ServerScriptService = game:GetService("ServerScriptService")
local ProStore3 = require(ServerScriptService.ProStore3)

ProStore3.PlayerJoined:Connect(function(player : Player)
    print(ProStore3.Get(player, "Level")) -- Output: 1
    ProStore3.Increment(player, "Level", 2)
    print(ProStore3.Get(player, "Level")) -- Output: 3
end)
```