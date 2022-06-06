---
sidebar_position: 1
---

# PlayerJoined

Gets called whenever a user joins the experience (will only get called once his data gets retrieved from the DataStore).


**Parameters:**

| Name      |Type        |Description                                                   |
|-----------|------------|--------------------------------------------------------------|
|player     |``player``  | The player instance of whoever just joined the game          |
|playerData |``table``   | All of users current data                                    |
|firstTime  |``boolean`` | Whether it is the first time of this user in this experience |

**Example:**
```luau
local ServerScriptService = game:GetService("ServerScriptService")
local ProStore3 = require(ServerScriptService.ProStore3)

ProStore3.PlayerJoined:Connect(function(player : Player, playerData : table, firstTime : boolean)
    print(player.Name, " joined the game.")
    print("Player data: ", playerData)
    print("First Time: ", firstTime)
end)
```