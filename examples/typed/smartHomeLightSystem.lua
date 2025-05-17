--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local flux = require(ReplicatedStorage.Shared.flux)

-- Define a state machine for a smart light
local lightState: flux.unit = flux.unit("Off")

lightState:addState("Off",
    function()
        print("💡 Light is OFF")
    end,
    function()
        print("🌓 Light transitioning from OFF")
    end
)

lightState:addState("On",
    function()
        print("🔆 Light is ON")
    end,
    function()
        print("⚫ Light transitioning from ON")
    end
)

lightState:beforeChange(function(oldState: string, newState: string): boolean?
    print(`🔄 Attempting transition: {oldState} ➝ {newState}`)
    if oldState == "Off" and newState == "Off" then
        print("❌ Light is already OFF, ignoring request.")
        return false
    end
end)

lightState:onEnter(function(state: string)
    print(`✅ Entered state: {state}`)
end)

lightState:onExit(function(state: string)
    print(`🚪 Exited state: {state}`)
end)

-- Simulate toggling the light
task.wait(1)
lightState:changeState("On")
task.wait(2)
lightState:changeState("Off")
