--!strict
-- util.lua

local internalTypings = require(script.Parent.internalTypings)
local StateRegistry = require(script.Parent.stateRegistry)

local util = {}

function util.deferInitialEnter(self: internalTypings.unit)
	task.defer(function()
		local states = StateRegistry.get(self)
		local stateData = states[self.state]
		if stateData and stateData.onEnter then
			stateData.onEnter()
		end
	end)
end

return table.freeze(util)
