--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local flux = require(ReplicatedStorage.flux)

-- Define a type-safe state machine for a door security system
local doorState: flux.unit = flux.unit("Locked")

doorState:addState("Locked",
    function()
        print("🔒 Door is locked")
        -- Play lock sound, disable door interactions
    end,
    function()
        print("🔓 Unlocking door...")
    end
)

doorState:addState("Unlocked",
    function()
        print("🚪 Door is unlocked")
        -- Allow interactions but prevent opening directly
    end,
    function()
        print("🔒 Locking the door again")
    end
)

doorState:addState("Open",
    function()
        print("🚪 Door is open")
        -- Play open animation and allow entry
    end,
    function()
        print("🚪 Closing the door...")
    end
)

-- Lifecycle hooks
doorState:beforeChange(function(oldState: string, newState: string): boolean?
    print(`⚡ Attempting transition: {oldState} ➝ {newState}`)

    -- Prevent opening the door directly from "Locked"
    if oldState == "Locked" and newState == "Open" then
        print("❌ Can't open a locked door!")
        return false
    end
end)

doorState:onEnter(function(state: string)
    print(`✅ Door entered state: {state}`)
end)

doorState:onExit(function(state: string)
    print(`🚪 Door exited state: {state}`)
end)

-- Simulate door interactions
task.wait(2)
doorState:changeState("Unlocked") -- Unlock the door
task.wait(1)
doorState:changeState("Open") -- Open the door
task.wait(3)
doorState:changeState("Locked") -- Lock the door again
