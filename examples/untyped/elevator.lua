local ReplicatedStorage = game:GetService("ReplicatedStorage")
local flux = require(ReplicatedStorage.Shared.flux)

local elevator = flux.unit("Idle")

elevator:addState("Idle",
    function() print("🚪 Elevator is idle") end,
    function() print("🏗 Preparing to move") end
)

elevator:addState("Moving",
    function() print("⬆️ Elevator is moving") end,
    function() print("🛑 Elevator has stopped") end
)

elevator:addState("DoorOpen",
    function() print("🚪 Doors are open") end,
    function() print("🚪 Closing doors") end
)

elevator:beforeChange(function(oldState, newState)
    print(`🔄 Changing from {oldState} to {newState}`)
    if oldState == "Moving" and newState == "Moving" then
        print("❌ Already moving!")
        return false
    end
end)

elevator:onEnter(function(state)
    print(`✅ Entered: {state}`)
end)

elevator:onExit(function(state)
    print(`🚪 Exited: {state}`)
end)

-- Simulating elevator movement
task.wait(2)
elevator:changeState("Moving")
task.wait(3)
elevator:changeState("Idle")
task.wait(1)
elevator:changeState("DoorOpen")
