---
sidebar_position: 1
---

# Get
Returns a request parameter of the user. It's read-only.

**Parameters:**

| Name  |Type      | Description                             |
|-------|----------|-----------------------------------------|
|player |``player``| The player whose data we want to access |
|path   |``string``| The path to the user data               |

**Returns:**

|Name  |Type    |Description  |
|------|--------|----------------------------------|
|value |``any`` | The requested data from the path |

**Example:**
```luau
local ServerScriptService = game:GetService("ServerScriptService")
local ProStore3 = require(ServerScriptService.ProStore3)

ProStore3.PlayerJoined:Connect(function(player : Player)
    local level : number = ProStore3.Get(player, "Level")
    local currency : number = ProStore3.Get(player, "Profile.Currency")

    print("Level: ", level, " Currency: ", currency)
end)
```