---
sidebar_position: 3
---

# DataUpdated

Gets called whenever a users data gets updated.

**Parameters:**

| Name      |Type      | Description                                        |
|-----------|----------|----------------------------------------------------|
|player     |``player``| The player instance of whoever's data just changed |
|playerData |``table`` | All of users current data                          |

**Example:**
```luau
local ServerScriptService = game:GetService("ServerScriptService")
local ProStore3 = require(ServerScriptService.ProStore3)

ProStore3.DataUpdated:Connect(function(player : Player, playerData : table)
    print(player.Name, "'s data has been updated.")
    print("Player data: ", playerData)
end)
```