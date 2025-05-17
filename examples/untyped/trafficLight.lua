--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local flux = require(ReplicatedStorage.Shared.flux)

-- Define a type-safe state machine instance
local trafficLight: flux.unit = flux.unit("Red")

-- Add states with lifecycle callbacks
trafficLight:addState("Red",
    function()
        print("🚦 Red light on")
    end,
    function()
        print("🔴 Turning off red")
    end
)

trafficLight:addState("Green",
    function()
        print("🚦 Green light on")
    end,
    function()
        print("🟢 Turning off green")
    end
)

-- Add lifecycle hooks
trafficLight:beforeChange(function(oldState: string, newState: string): boolean?
    if newState == "Error" then
        return false -- Prevent invalid transitions
    end
end)

trafficLight:onEnter(function(state: string)
    print(`✅ Entered state: {state}`)
end)

trafficLight:onExit(function(state: string)
    print(`🚪 Exiting state: {state}`)
end)

-- Run the state machine loop
while true do
    task.wait(5)
    if trafficLight.state == "Red" then
        trafficLight:changeState("Green")
    else
        trafficLight:changeState("Red")
    end
end
