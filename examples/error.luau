local flux = require("../lib")

type states = "Green" | "Amber" | "Red"

-- Define all states
local allStates: { states } = { "Green", "Amber", "Red" }
local trafficLight: flux.Unit<states> = flux("Green")

print("=== Adding states ===")
for _, state in allStates do
	trafficLight:addState({
		name = state,
		onEnter = function()
			print("[onEnter]", state)
		end,
		onExit = function()
			print("[onExit]", state)
		end,
		onBeforeEnter = function()
			print("[onBeforeEnter]", state)
		end,
		onBeforeExit = function()
			print("[onBeforeExit]", state)
		end,
		onAfterExit = function()
			print("[onAfterExit]", state)
		end,
		onAfterEnter = function()
			print("[onAfterEnter]", state, "(will error if Red)")
			if state == "Red" then
				error("Simulated failure in Red:onAfterEnter") -- i get this in studio
			end
		end,
	})
end

-- Attach middleware
trafficLight:use({
	onError = function(err: string): ()
		print("[onError caught]:", err)
	end,
})

-- Run a transition test
print("=== Transitioning to Amber ===")
trafficLight:changeState("Amber")

print("=== Transitioning to Red (should trigger error) ===")
trafficLight:changeState("Red")

print("=== Transitioning back to Green ===")
trafficLight:changeState("Green")
