---
sidebar_position: 2
---

# PlayerLeft

Gets called whenever a user leaves the experience.

**Parameters:**

|Name       |Type      | Description                                       |
|-----------|----------|---------------------------------------------------|
|player     |``player``| The player instance of whoever just left the game |
|playerData |``table`` | All of users current data                         |

**Example:**
```luau
local ServerScriptService = game:GetService("ServerScriptService")
local ProStore3 = require(ServerScriptService.ProStore3)

ProStore3.PlayerLeft:Connect(function(player : Player, playerData : table)
    print(player.Name, " left the game.")
    print("Player data: ", playerData)
end)
```