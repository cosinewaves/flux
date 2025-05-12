--!strict
-- util.lua

local internalTypings = require(script.Parent.internalTypings)

local util = {}

function util.deferInitialEnter(self: internalTypings.unit)
	task.defer(function()
		local stateData = self.states[self.state]
		if stateData and stateData.onEnter then
			stateData.onEnter()
		end
	end)
end

return table.freeze(util)
