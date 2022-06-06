---
sidebar_position: 7
---

# ForcedSave
Forces a users data to get saved. By default the data gets saved when a user leaves but for extra security you can also force it after an important action (E.g purchase done with robux).

**Parameters:**

| Name  |Type       |Description                         |
|-------|-----------|------------------------------------|
|player |``player`` |The target player for the data save |

**Returns:**

|Name |Type    |Description |
|-----|--------|------------|
|     |``void``|            |

**Example:**
```luau
local ServerScriptService = game:GetService("ServerScriptService")
local ProStore3 = require(ServerScriptService.ProStore3)

ProStore3.PlayerJoined:Connect(function(player : Player)
    --Do some data changes here
    ProStore3.Set(player, "level", 100)
    ---------------------------

    ProStore3.ForcedSave(player)
end)

```