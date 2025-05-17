--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local flux = require(ReplicatedStorage.Shared.flux)

-- Define a type-safe state machine for an NPC
local npcState: flux.unit = flux.unit("Idle")

npcState:addState("Idle",
    function()
        print("🤖 NPC is idle")
        -- Play idle animation here
    end,
    function()
        print("🏃 NPC leaving idle state")
    end
)

npcState:addState("Walking",
    function()
        print("🚶 NPC is walking")
        -- Start walk animation or move the NPC
    end,
    function()
        print("⏹ NPC stopped walking")
    end
)

npcState:addState("Attacking",
    function()
        print("⚔️ NPC is attacking")
        -- Trigger attack animation or damage logic
    end,
    function()
        print("🛑 NPC stopped attacking")
    end
)

-- Lifecycle hooks
npcState:beforeChange(function(oldState: string, newState: string): boolean?
    print(`🔄 Transitioning from {oldState} to {newState}`)
    -- Prevent attacking if NPC is already attacking
    if oldState == "Attacking" and newState == "Attacking" then
        return false
    end
end)

npcState:onEnter(function(state: string)
    print(`✅ NPC entered state: {state}`)
end)

npcState:onExit(function(state: string)
    print(`🚪 NPC exited state: {state}`)
end)

-- Simulate NPC behavior loop
while true do
    task.wait(math.random(3, 7))
    if npcState.state == "Idle" then
        npcState:changeState("Walking")
    elseif npcState.state == "Walking" then
        npcState:changeState("Attacking")
    else
        npcState:changeState("Idle")
    end
end
