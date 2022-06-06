---
sidebar_position: 1
---

# Tutorial Intro

This is a template


### Example

Some test code

```luau
local ServerScriptService = game:GetService("ServerScriptService")
local ProStore3 = require(ServerScriptService.ProStore3)

string a = "hello";

local a : string = "hello"
local b : number = 3
local localPlayer : Player.Nested = "uwu"
local array : {string} = {}
local c = array[1]
gang

--this is a comment
**hello

ProStore3.PlayerLeft:Connect(function(player : Player, playerData : table)
    print(player.Name, " left the game.")
    print("Player data: ", playerData)
end)
```