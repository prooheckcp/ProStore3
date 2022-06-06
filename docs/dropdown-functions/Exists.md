---
sidebar_position: 3
---

# Exists
Returns whether a given path exists or not in the users data. Used when working with dynamic arrays.

**Parameters:**

| Name    |Type      | Description                                 |
|---------|----------|---------------------------------------------|
|player   |``player``| The player whose data we want to access     |
|path     |``string``| The path to the user data                   |

**Returns:**

| Name     |Type        |Description                     |
|----------|------------|--------------------------------|
|foundPath |``boolean`` |Returns true if the path exists |

**Example:**
```luau
local ServerScriptService = game:GetService("ServerScriptService")
local ProStore3 = require(ServerScriptService.ProStore3)

ProStore3.PlayerJoined:Connect(function(player : Player)
    print("Exist: ", ProStore3.Exists(player, "DynamicArray.test")) --false
    ProStore3.Set(player, "DynamicArray.test", 2)
    print("Exist: ", ProStore3.Exists(player, "DynamicArray.test")) --true
end)
```