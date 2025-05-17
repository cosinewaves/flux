--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local flux = require(ReplicatedStorage.Shared.flux)

-- Define a security alarm system state machine
local alarmState: flux.unit = flux.unit("Inactive")

alarmState:addState("Inactive",
    function()
        print("🔕 Alarm is OFF")
    end,
    function()
        print("🔄 Preparing to activate alarm...")
    end
)

alarmState:addState("Active",
    function()
        print("🚨 Alarm is ON!")
    end,
    function()
        print("🔇 Deactivating alarm...")
    end
)

alarmState:beforeChange(function(oldState: string, newState: string): boolean?
    print(`🔄 Attempting transition: {oldState} ➝ {newState}`)
    if oldState == "Active" and newState == "Active" then
        print("❌ Alarm is already active!")
        return false
    end
end)

alarmState:onEnter(function(state: string)
    print(`✅ Entered state: {state}`)
end)

alarmState:onExit(function(state: string)
    print(`🚪 Exited state: {state}`)
end)

-- Simulating alarm behavior
task.wait(1)
alarmState:changeState("Active")
task.wait(2)
alarmState:changeState("Inactive")
task.wait(3)
alarmState:changeState("Active") -- Valid
alarmState:changeState("Active") -- Invalid transition (should be prevented)
