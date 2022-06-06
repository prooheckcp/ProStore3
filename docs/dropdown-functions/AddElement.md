---
sidebar_position: 5
---

# AddElement
Adds an object into an array. Will fail if you attempt to use it an a non-array value.

**Parameters:**

| Name   |Type       |Description                                            |
|--------|-----------|-------------------------------------------------------|
|player  |``player`` |The player whose data we want to access                |
|path    |``string`` |The path to the user data                              |
|element |``any``    |The element that we want to add into the players array |

**Returns:**

|Name |Type    |Description |
|-----|--------|------------|
|     |``void``|            |

**Example:**
```luau
local ServerScriptService = game:GetService("ServerScriptService")
local ProStore3 = require(ServerScriptService.ProStore3)

ProStore3.PlayerJoined:Connect(function(player : Player)
    print(ProStore3.Get(player, "Inventory"))
    ProStore3.AddElement(player, "Inventory", {id = "sword", damage = 2})
    print(ProStore3.Get(player, "Inventory"))
    ProStore3.AddElement(player, "Inventory", {id = "knife", damage = 3})
    print(ProStore3.Get(player, "Inventory"))
end)

```