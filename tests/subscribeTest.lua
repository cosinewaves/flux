local ReplicatedStorage = game:GetService("ReplicatedStorage")
local flux = require(ReplicatedStorage.Shared.flux)

local unit = flux.unit("Off")

-- Subscribe to state changes
unit:subscribe(function(oldState, newState)
	print(`State changed from '{oldState}' to '{newState}'`)
end)

unit:addState("Off",
  function() print("Entering 'Off' state") end,
  function() print("Exiting 'Off' state") end
)

unit:addState("On",
  function() print("Entering 'On' state") end,
  function() print("Exiting 'On' state") end
)

while task.wait(5) do
	math.random(1, 2) == 1 and unit:changeState("Off") or unit:changeState("On")
end
