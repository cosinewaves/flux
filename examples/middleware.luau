local lib = require("../lib")

local stateMachine = lib("Idle")
stateMachine:use({
	beforeChange = function()
		print("Before change")
	end,
	afterChange = function()
		print("After change")
	end,
	canTransition = function()
		return true
	end,
	onError = function(error)
		print("Error: " .. error)
	end,
})

-- continuing from your snippet
stateMachine:addState({ name = "Idle" })
stateMachine:addState({ name = "Run" })
stateMachine:addState({
	name = "Fail",
	onEnter = function()
		error("Boom!") -- trigger onError middleware
	end,
})

-- ✅ should print "Before change", then "After change"
print("== Transition Idle → Run ==")
stateMachine:changeState("Run")

-- ✅ should block transition (canTransition = false)
print("== Transition Run → Blocked ==")
stateMachine:use({
	canTransition = function(old, new)
		print("Blocking transition", old, "→", new)
		return false
	end,
})
stateMachine:changeState("Idle") -- won't succeed

-- ✅ should trigger error middleware
print("== Transition Run → Fail ==")
stateMachine:changeState("Fail")
