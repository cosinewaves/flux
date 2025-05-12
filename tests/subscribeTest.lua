local ReplicatedStorage = game:GetService("ReplicatedStorage")
local flux = require(ReplicatedStorage.flux)

local unit = flux.unit("Off") -- getting error saying it's an empty string? possible: work on metatable __call function or something good luck future me

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

while task.wait(2) do
	if math.random(1, 2) == 1 then unit:changeState("Off") else unit:changeState("On") end
end
