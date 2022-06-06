---
sidebar_position: 2
---

# Set
Overwrites the value at the given path by the new value.

**Parameters:**

| Name    |Type      | Description                                 |
|---------|----------|---------------------------------------------|
|player   |``player``| The player whose data we want to access     |
|path     |``string``| The path to the user data                   |
|newValue |``any``   | The value that will overwrite the old value |

**Returns:**

| Name    |Type   |Description                                             |
|---------|-------|--------------------------------------------------------|
|oldValue |``any``|Returns the old value that existed before the overwrite |

**Example:**
```luau
local ServerScriptService = game:GetService("ServerScriptService")
local ProStore3 = require(ServerScriptService.ProStore3)

ProStore3.PlayerJoined:Connect(function(player : Player)
    ProStore3.Set(player, "Level", 3)
    print("Level after set: ", ProStore3.Get(player, "Level"))
end)
```