local ReplicatedStorage = game:GetService("ReplicatedStorage")
local flux = require(ReplicatedStorage.Shared.flux)

local unit = flux.unit("Off") -- create a state machine and initialise the first state

-- Add "Off" state
unit:addState(
	"Off",
	function() -- onEnter
		print("Transitioning to 'Off' state.")
	end,
	function() -- onExit
		print("Leaving 'Off' state.")
	end
)

-- Add "On" state
unit:addState(
	"On",
	function() -- onEnter
		print("Transitioning to 'On' state.")
	end,
	function() -- onExit
		print("Leaving 'On' state.")
	end
)

-- Loop that randomly changes states
while task.wait(5) do
	if math.random(1, 2) == 1 then
		unit:changeState("Off")
	else
		unit:changeState("On")
	end
end
