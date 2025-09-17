local flux = require("../lib")
local stateMachine = flux("Green")

stateMachine:use({
	beforeChange = function() end,
	afterChange = function() end,
})
