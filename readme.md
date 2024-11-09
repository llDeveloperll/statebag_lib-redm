# StateBag Library for RedM

A lightweight and efficient library for managing state bags in RedM, providing a clean interface for state management across your resources.

## Features

- Easy-to-use state bag management
- Support for both client and server-side operations
- Multiple ways to interact with the library (exports or events)
- Entity state tracking and management
- Player state monitoring
- Change handlers with callback support

## Installation

1. Download or clone this repository into your resources folder
2. Rename the folder to `statebag_lib`
3. Add `ensure statebag_lib` to your `server.cfg`
4. Make sure to load it before any resources that depend on it

```cfg
# server.cfg
ensure statebag_lib
```

## Usage

### Using Exports (Recommended)

```lua
local StateBag = exports['statebag_lib']

-- Get a value from state bag
local isLoggedIn = StateBag:GetBagValue("player:source", "isLoggedIn")

-- Set a value in state bag
StateBag:SetBagValue("entity:123", "isImmortal", "true", true)

-- Monitor state changes
local cookie = StateBag:AddChangeHandler("isDead", nil, function(bagName, key, value)
    local player = StateBag:GetPlayerFromBag(bagName)
    if player ~= 0 then
        print(GetPlayerName(player) .. (value and " died!" or " respawned!"))
    end
end)

-- Remove change handler when done
StateBag:RemoveChangeHandler(cookie)
```

### Using Events

```lua
-- Get a value
TriggerEvent('StateBagLib:GetBagValue', "player:source", "isLoggedIn")

-- Set a value
TriggerEvent('StateBagLib:SetBagValue', "entity:123", "isImmortal", "true", true)
```

## API Reference

### Methods

#### AddChangeHandler(keyFilter, bagFilter, handler)
Adds a handler for state bag changes.
- `keyFilter`: The key to monitor for changes
- `bagFilter`: Optional filter for specific state bags
- `handler`: Callback function receiving (bagName, key, value, reserved, replicated)
- Returns: cookie for removing handler

```lua
local cookie = StateBag:AddChangeHandler("health", nil, function(bagName, key, value)
    print("Health changed to: " .. value)
end)
```

#### RemoveChangeHandler(cookie)
Removes a previously added change handler.
- `cookie`: The cookie returned from AddChangeHandler

```lua
StateBag:RemoveChangeHandler(cookie)
```

#### EnsureEntityStateBag(entity)
Ensures an entity has a state bag.
- `entity`: Entity ID

```lua
StateBag:EnsureEntityStateBag(entityId)
```

#### GetEntityFromBag(bagName)
Gets entity ID from a state bag name.
- `bagName`: Name of the state bag
- Returns: Entity ID or 0 if not found

```lua
local entity = StateBag:GetEntityFromBag("entity:123")
```

#### GetPlayerFromBag(bagName)
Gets player ID from a state bag name.
- `bagName`: Name of the state bag
- Returns: Player ID or 0 if not found

```lua
local player = StateBag:GetPlayerFromBag("player:1")
```

#### GetBagValue(bagName, key)
Gets a value from a state bag.
- `bagName`: Name of the state bag
- `key`: Key to get value for
- Returns: Value or nil if not found

```lua
local value = StateBag:GetBagValue("player:source", "isLoggedIn")
```

#### SetBagValue(bagName, keyName, valueData, replicated)
Sets a value in a state bag.
- `bagName`: Name of the state bag
- `keyName`: Key to set
- `valueData`: Value to set
- `replicated`: Whether to replicate to other players

```lua
StateBag:SetBagValue("entity:123", "isImmortal", "true", true)
```

## Examples

### Monitor Player Login State

```lua
CreateThread(function()
    local StateBag = exports['statebag_lib']
    
    local function checkPlayerState()
        local serverId = GetPlayerServerId(PlayerId())
        return StateBag:GetBagValue("player:" .. serverId, "isLoggedIn")
    end
    
    while true do
        Wait(1000)
        if checkPlayerState() then
            print("Player logged in!")
            break
        end
    end
end)
```

### Entity State Management

```lua
local StateBag = exports['statebag_lib']

-- Setup entity state
local entity = 12345
StateBag:EnsureEntityStateBag(entity)

-- Set initial state
StateBag:SetBagValue("entity:" .. entity, "isProtected", "true", true)

-- Monitor state changes
local cookie = StateBag:AddChangeHandler("isProtected", "entity:" .. entity, function(bagName, key, value)
    local entity = StateBag:GetEntityFromBag(bagName)
    if entity ~= 0 then
        SetEntityInvincible(entity, value == "true")
    end
end)
```

## License

This project is licensed under the MIT License - see the LICENSE file for details

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

If you need help or found a bug, please create an issue in the GitHub repository.