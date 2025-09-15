local flux = require("../lib")

type states = "Green" | "Amber" | "Red"

local states: { states } = { "Green", "Amber", "Red" }
local trafficLight: flux.Unit<states> = flux("Green")

print("creating states")
for _, state in states do
	trafficLight:addState({
		name = state,
		onEnter = function()
			print("Entered state:", state)
		end,
		onExit = function()
			print("Entered state:", state)
		end,
	})
end

print("looping through")
while task.wait(1) do
	local chosenState: states = states[math.random(1, #states)]
	trafficLight:changeState(chosenState)
end
