local ReplicatedStorage = game:GetService("ReplicatedStorage")
local flux = require(ReplicatedStorage.flux)

local unit = flux.unit("Idle")
unit:addState("Idle", function() print("Entered Idle") end, function() print("Exited Idle") end)
unit:addState("Run", function() print("Entered Run") end, function() print("Exited Run") end)

unit:addGuard("Run", function(old, new)
    print("Guard: Checking transition from", old, "to", new)
    return old ~= "Idle" -- ❌ Should block transition from 'Idle' to 'Run'
end)

print("Attempting to change state to 'Run'...")
unit:changeState("Run") -- ❌ Should be blocked
print("Expected State: 'Idle', Actual State:", unit.state) -- ✅ Should still be 'Idle'

unit.state = "Active" -- Manually override state for test purposes

print("Attempting to change state to 'Run' again...")
unit:changeState("Run") -- ✅ Should succeed
print("Expected State: 'Run', Actual State:", unit.state) -- ✅ Should be 'Run'
