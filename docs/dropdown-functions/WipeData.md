---
sidebar_position: 8
---

# WipeData
This function completely resets all of the users data returning it back to the original schema (as if he was a user user).

**Parameters:**

| Name  |Type       |Description                         |
|-------|-----------|------------------------------------|
|player |``player`` | The target player for the data wipe|

**Returns:**

|Name |Type    |Description |
|-----|--------|------------|
|     |``void``|            |

**Example:**
```luau
local ServerScriptService = game:GetService("ServerScriptService")
local ProStore3 = require(ServerScriptService.ProStore3)

ProStore3.PlayerJoined:Connect(function(player : Player)
    ProStore3.WipeData(player)
    print(ProStore3.GetTable(player)) -- will print the same as  in the schema.lua
end)
```