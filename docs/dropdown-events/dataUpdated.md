---
sidebar_position: 3
---

# DataUpdated

Gets called whenever a users data gets updated.

**Parameters:**

| Name      |Type      | Description                                        |
|-----------|----------|----------------------------------------------------|
|player     |``player``| The player instance of whoever's data just changed |
|changedKey |``string``| The key that was updated                           |
|newValue   |``any``   | The new value to which this has been changed       |
|fullPath   |``string``| The full path to the value that has been changed   |
**Example:**
```luau
local ServerScriptService = game:GetService("ServerScriptService")
local ProStore3 = require(ServerScriptService.ProStore3)

ProStore3.DataUpdated:Connect(function(player : Player, changedKey : string, newValue : any, fullPath : string)
    print(player.Name, "'s data has been updated.")
    print(changedKey, "has been changed to: ", newValue, "at the following path:", fullPath)
end)
```