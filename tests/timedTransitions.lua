local ReplicatedStorage = game:GetService("ReplicatedStorage")
local flux = require(ReplicatedStorage.flux)

local unit = flux.unit("Idle")
unit:addState("Idle", function() print("Entered Idle") end, function() print("Exited Idle") end)
unit:addState("Run", function() print("Entered Run") end, function() print("Exited Run") end)

print("Setting a timed transition to 'Run' in 2 seconds...")
unit:setTimeout("Run", 2)

task.wait(2.5) -- Wait slightly longer to ensure transition happens
print("Expected State: 'Run', Actual State:", unit.state) -- ✅ Should be 'Run'
