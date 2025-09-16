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
		onBeforeEnter = function()
			print("Before enter:", state)
		end,
		onBeforeExit = function()
			print("Before exit:", state)
		end,
		onAfterExit = function()
			print("After exit:", state)
		end,
		onAfterEnter = function()
			print("After enter:", state)
		end,
	})
end

print("looping through")
while task.wait(1) do
	local chosenState: states = states[math.random(1, #states)]
	trafficLight:changeState(chosenState)
end
