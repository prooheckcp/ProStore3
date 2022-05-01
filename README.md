# ProStore3
## A small Roblox DataStore manager
ProStore3 is a simple library used to easily manage  and dynamically update a Roblox's game database. It uses a session lock approach on which it stores and manipulates the users data from the moment they join the session to the moment that they leave.

It was heavily inspired in the popular library [DataStore2](https://kampfkarren.github.io/Roblox/)

**Pros:** 
- Simple
- Low amount of lines
- Very easy to learn and apply
- Enforces a schema similar to SQL databases

## Introduction
This library is composed by 5 different files.

![](https://cdn.discordapp.com/attachments/670023265455964198/970425407084056607/unknown.png)

From these files there are two that you should be looking at: the schema and the settings. These 2 files are what will decide the database format that you want and the settings that will go along with it.

ProStore is supposed to offer you a simple and fast way of setting up your dataStore. All you have to do is drag it into whatever root directory you want in Roblox (E.g ServerScriptService), edit the schema to your need, change the settings, and require it from whatever file you want.

#### Schema
The schema is essentially the format that you will want your data to look like for the game. ProStore3 is prepared for changes so there will be no lost data in case you decide to add a new parameter in the future. The given value (E.g Level = 1) will be the default value for this parameter in case the user that joined does not have it in his data yet.

![](https://cdn.discordapp.com/attachments/670023265455964198/970426108568809623/unknown.png)

#### Settings
The settings file is just a file that allows you to change some of the behaviors from ProStore.

| Setting           |Description                      |
|----------------|---------------------------------|
|AutoSave.Enabled|      Whether you want the users data to be saved every X amount of minute during his session.       |
|AutoSave.TimeGap          |How often do you want the users data to be saved (In minutes).            |
|AutoSave.Notifications          |If you want a notification to be be printed into the console whenever a users data gets saved.|
| DatabasePrivateKey | The key that will be used to create your dataStore and access it.

## API (Functions) 🧊
For all of the examples on the API we will be assuming that the schema of our DataBase looks something like this.
```lua
return {
    Level = 1,
    Inventory = {},
    Profile = {
        SomeInt = 2,
        Currency = 100,
        NestedProfile = {
            MoreNested = {
                Another = {
                    value = 3
                }
            }
        }
    }
}
```

### ProStore3.Get
Returns a request parameter of the user. It's read-only.

**Parameters**
| Name           |Type                      | Description |
|----------------|---------------------------------|--|
| playerInstance | ``player``| The player whose data we want to access |
|   path       |      ``string``| The path to the user data

**Returns**
| Name           |Type                      | Description |
|----------------|---------------------------------|--|
| value | ``any``| The requested data from the path |
**Example:**
```lua
local ProStore3 = game:GetService("ServerScriptService")

local level : number = ProStore3.Get(player, "Level")
local currency : number = ProStore3.Get(player, "Profile.Currency")

print("Level: ", level, " Currency: ", currency)
```

### ProStore3.Set
Overwrites the value at the given path by the new value.

**Parameters**
| Name           |Type                      | Description |
|----------------|---------------------------------|--|
| player | ``player``| The player whose data we want to access |
|   path       |      ``string``| The path to the user data |
| newValue | ``any`` | The value that will overwrite the old value |

**Returns**
| Name           |Type                      | Description |
|----------------|---------------------------------|--|
| oldValue | ``any``| Returns the old value that existed before the overwrite |
**Example:**
```lua
local ProStore3 = game:GetService("ServerScriptService")

ProStore3.Set(player, "Level", 3)
print("Level after set: ", ProStore3.Get(player, "Level"))
```

### ProStore3.Increment
Increments a value by the given amount. It only works on number type variables.

**Parameters**
| Name           |Type                      | Description |
|----------------|---------------------------------|--|
| player | ``player``| The player whose data we want to access |
|   path       |      ``string``| The path to the user data |
| amount | ``number``|The amount that we wish to increment into the value|

**Returns**
| Name           |Type                      | Description |
|----------------|---------------------------------|--|
|| ``void``||
**Example:**
```lua
local ProStore3 = game:GetService("ServerScriptService")

print(ProStore3.Get("Level")) -- Output: 1
ProStore3.Increment(player, "Level", 2)
print(ProStore3.Get(player, "Level")) -- Output: 3
```

### ProStore3.AddElement
Adds an object into an array. Will fail if you attempt to use it an a non-array value.

**Parameters**
| Name           |Type                      | Description |
|----------------|---------------------------------|--|
| player | ``player``| The player whose data we want to access |
| path   |``string``| The path to the user data |
| element |``any`` | The element that we want to add into the players array|

**Returns**
| Name           |Type                      | Description |
|----------------|---------------------------------|--|
|| ``void``||
**Example:**
```lua
local ProStore3 = game:GetService("ServerScriptService")

print(ProStore3.Get(player, "Inventory"))
ProStore3.AddElement(player, "Inventory", {id = "sword", damage = 2})
print(ProStore3.Get(player, "Inventory"))
ProStore3.AddElement(player, "Inventory", {id = "knife", damage = 3})
print(ProStore3.Get(player, "Inventory"))
```

### ProStore3.GetTable
Returns the whole table of the users data by reference.

**Parameters**
| Name           |Type                      | Description |
|----------------|---------------------------------|--|
| player | ``player``| The player whose data we want to access |

**Returns**
| Name           |Type                      | Description |
|----------------|---------------------------------|--|
| usersData | ``table``| The whole data of the user |
**Example:**
```lua
local ProStore3 = game:GetService("ServerScriptService")

local fullData : table = ProStore3.GetTable(player)
print(fullData)
```

### ProStore3.ForcedSave
Forces a users data to get saved. By default the data gets saved when a user leaves but for extra security you can also force it after an important action (E.g purchase done with robux).
**Parameters**
| Name           |Type                      | Description |
|----------------|---------------------------------|--|
| player | ``player``| The target player for the data save|

**Returns**
| Name           |Type                      | Description |
|----------------|---------------------------------|--|
|| ``void``||
**Example:**
```lua
local ProStore3 = game:GetService("ServerScriptService")

ProStore3.ForcedSave(player)
```

### ProStore3.WipeData
This function completely resets all of the users data returning it back to the original schema (as if he was a user user).

**Parameters**
| Name           |Type                      | Description |
|----------------|---------------------------------|--|
| player | ``player``| The target player for the data wipe|

**Returns**
| Name           |Type                      | Description |
|----------------|---------------------------------|--|
|| ``void``||

**Example:**
```lua
local ProStore3 = game:GetService("ServerScriptService")

ProStore3.WipeData(player)
print(ProStore3.GetTable(player)) -- will print the same as  in the schema.lua
```

## API (Events) ⚡
### ProStore3.PlayerJoined
Gets called whenever a user joins the experience (will only get called once his data gets retrieved from the DataStore).
**Parameters**
| Name           |Type                      | Description |
|----------------|---------------------------------|--|
| player | ``player``| The player instance of whoever just joined the game|
|   playerData       |      ``table``| All of users current data|
| firstTime|``boolean`` |Whether it is teh first time of this user in this experience |
```lua
local ProStore3 = game:GetService("ServerScriptService")
ProStore3.PlayerJoined:Connect(function(player : Player, playerData : table, firstTime : boolean)
    print(player.Name, " joined the game.")
    print("Player data: ", playerData)
    print("First Time: ", firstTime)
end)
```
### ProStore3.PlayerLeft
Gets called whenever a user leaves the experience.
**Parameters**
| Name           |Type                      | Description |
|----------------|---------------------------------|--|
| player | ``player``| The player instance of whoever just left the game|
|   playerData       |      ``table``| All of users current data|
```lua
local ProStore3 = game:GetService("ServerScriptService")
ProStore3.PlayerLeft:Connect(function(player : Player, playerData : table)
    print(player.Name, " left the game.")
    print("Player data: ", playerData)
end)
```

### ProStore3.DataUpdated
Gets called whenever a users data gets updated.
**Parameters**
| Name           |Type                      | Description |
|----------------|---------------------------------|--|
| player | ``player``| The player instance of whoevers data just changed|
|   playerData       |      ``table``| All of users current data|

```lua
local ProStore3 = game:GetService("ServerScriptService")
ProStore3.DataUpdated:Connect(function(player : Player, playerData : table)
    print(player.Name, "'s data has been updated.")
    print("Player data: ", playerData)
end)
```

## Installation

To download the library you can either fork it into your Rojo project or download it from here.
[ProStore3](https://www.roblox.com/library/9521046169/ProStore3)

## Contact

Found any problem or simply wanna give some feedback regarding the library? Just hit me up!

Discord: Prooheckcp#1906
Twitter: https://twitter.com/Prooheckcp


**100% free and open source**
