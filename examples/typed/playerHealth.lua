--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local flux = require(ReplicatedStorage.Shared.flux)

-- Define a type-safe health state machine
local healthState: flux.unit = flux.unit("Healthy")

healthState:addState("Healthy",
    function()
        print("❤️ Player is fully healed.")
    end,
    function()
        print("⚠️ Player taking damage...")
    end
)

healthState:addState("Injured",
    function()
        print("🤕 Player is injured.")
    end,
    function()
        print("💉 Player recovering from injury...")
    end
)

healthState:addState("Dead",
    function()
        print("☠️ Player is dead.")
    end,
    function()
        print("👻 Respawn sequence initialized...")
    end
)

healthState:beforeChange(function(oldState: string, newState: string): boolean?
    print(`⚡ Health Transition: {oldState} ➝ {newState}`)
    if oldState == "Dead" and newState == "Healthy" then
        print("❌ Cannot revive directly, must recover first!")
        return false
    end
end)

healthState:onEnter(function(state: string)
    print(`✅ Player entered state: {state}`)
end)

healthState:onExit(function(state: string)
    print(`🚪 Player exited state: {state}`)
end)

-- Simulating health transitions
task.wait(1)
healthState:changeState("Injured")
task.wait(2)
healthState:changeState("Dead")
task.wait(3)
healthState:changeState("Healthy") -- Invalid transition (should be prevented)
healthState:changeState("Injured") -- Allowed transition
