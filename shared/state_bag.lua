local StateBagLib = {}

local function Initialize()
    if not StateBagLib.initialized then
        StateBagLib = {
            AddChangeHandler = function(keyFilter, bagFilter, handler)
                local cookie = AddStateBagChangeHandler(keyFilter, bagFilter, function(bagName, key, value, reserved, replicated)
                    handler(bagName, key, value, reserved, replicated)
                end)
                return cookie
            end,
            
            RemoveChangeHandler = function(cookie)
                RemoveStateBagChangeHandler(cookie)
                return cookie
            end,

            EnsureEntityStateBag = function(entity)
                EnsureEntityStateBag(entity)
            end,

            GetEntityFromBag = function(bagName)
                return GetEntityFromStateBagName(bagName)
            end,

            GetPlayerFromBag = function(bagName)
                return GetPlayerFromStateBagName(bagName)
            end,

            GetBagValue = function(bagName, key)
                return GetStateBagValue(bagName, key)
            end,

            SetBagValue = function(bagName, keyName, valueData, replicated)
                SetStateBagValue(bagName, keyName, valueData, string.len(valueData), replicated)
            end,

            GetClientBagValue = function(key)
                return LocalPlayer.state[key]
            end
        }

        -- Register as events to allow usage with TriggerEvent
        RegisterNetEvent("StateBagLib:AddChangeHandler", StateBagLib.AddChangeHandler)
        RegisterNetEvent("StateBagLib:RemoveChangeHandler", StateBagLib.RemoveChangeHandler)
        RegisterNetEvent("StateBagLib:EnsureEntityStateBag", StateBagLib.EnsureEntityStateBag)
        RegisterNetEvent("StateBagLib:GetEntityFromBag", StateBagLib.GetEntityFromBag)
        RegisterNetEvent("StateBagLib:GetPlayerFromBag", StateBagLib.GetPlayerFromBag)
        RegisterNetEvent("StateBagLib:GetBagValue", StateBagLib.GetBagValue)
        RegisterNetEvent("StateBagLib:SetBagValue", StateBagLib.SetBagValue)
        RegisterNetEvent("StateBagLib:GetClientBagValue", StateBagLib.GetClientBagValue)

        -- Register exports to allow usage with exports['StateBagLib']
        exports('AddChangeHandler', StateBagLib.AddChangeHandler)
        exports('RemoveChangeHandler', StateBagLib.RemoveChangeHandler)
        exports('EnsureEntityStateBag', StateBagLib.EnsureEntityStateBag)
        exports('GetEntityFromBag', StateBagLib.GetEntityFromBag)
        exports('GetPlayerFromBag', StateBagLib.GetPlayerFromBag)
        exports('GetBagValue', StateBagLib.GetBagValue)
        exports('SetBagValue', StateBagLib.SetBagValue)
        exports('GetClientBagValue', StateBagLib.GetClientBagValue)

        StateBagLib.initialized = true
    end
    
    return StateBagLib
end

return Initialize()


--[[ 
    Example usage with oxlib:

    -- Loading the library using oxlib's require
    local StateBagLib = lib.require('@your_resource_name.shared.state_bag')

    -- 1. Add a handler to detect changes in the "isDead" state for all players
    local deathCookie = StateBagLib.AddChangeHandler("isDead", nil, function(bagName, key, value)
        local player = StateBagLib.GetPlayerFromBag(bagName)
        if player ~= 0 then
            print("Player: " .. GetPlayerName(player) .. (value and " has died!" or " is alive!"))
        end
    end)

    -- 2. Example of waiting for player login using state bag
    CreateThread(function()
        repeat
            Wait(1000)
        until StateBagLib.GetBagValue("player:" .. GetPlayerServerId(PlayerId()), "isLoggedIn") == true
        print("Player is logged in!")
    end)

    -- 3. Setting entity state
    local entityId = 12345
    StateBagLib.EnsureEntityStateBag(entityId)
    StateBagLib.SetBagValue("entity:" .. entityId, "isImmortal", "true", true)

    -- 4. Monitoring entity state changes
    local blockTasksCookie = StateBagLib.AddChangeHandler("blockTasks", "entity:" .. entityId, function(bagName, key, value)
        local entity = StateBagLib.GetEntityFromBag(bagName)
        if entity ~= 0 then
            SetEntityInvincible(entity, value)
            FreezeEntityPosition(entity, value)
            TaskSetBlockingOfNonTemporaryEvents(entity, value)
        end
    end)


    local StateBag = exports['StateBagLib']

    local playerId = PlayerId()
    local serverId = GetPlayerServerId(playerId)

    local states = {
        localPlayer = LocalPlayer.state.isLoggedIn,
        bagLocal = StateBag:GetBagValue("LocalPlayer.state", "isLoggedIn"),
        bagClient = StateBag:GetClientBagValue("isLoggedIn"),
        bagPlayer = StateBag:GetBagValue("player:" .. serverId, "isLoggedIn"),
        bagPlayerState = StateBag:GetBagValue("player:state", "isLoggedIn"),
        bagPlayerSource = StateBag:GetBagValue("player:source", "isLoggedIn")
    }

    print(
        'localPlayer',states.localPlayer,
        'bagLocal',states.bagLocal,
        'bagClient',states.bagClient,
        'bagPlayer',states.bagPlayer
    )
]]

-- Explanation:
-- This script is intended to be used in a shared context, meaning it works both on the server and client sides.
-- The functions in this script manage state bags, but note that state bags created on the client side remain client-side unless
-- a server function creates the same state bag on the server with the same properties. This means that if you need to pass 
-- information from the server to the client, or vice versa, you should ensure that the state bag is created in both locations 
-- where needed. Functions like `AddChangeHandler` allow you to listen for changes in state values, while `SetBagValue` 
-- can be used to modify these values. For communication between different scripts or between server and client, 
-- the script provides `exports` and `TriggerEvent` registration for cross-resource compatibility and event-driven interaction.
