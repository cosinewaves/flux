--!strict
-- stateRegistry.lua

local internalTypings = require(script.Parent.internalTypings)

local registry: {
	[internalTypings.unit]: { [string]: internalTypings.component }
} = {}

local stateRegistry = {}

function stateRegistry.init(self: internalTypings.unit)
	registry[self] = {}
end

function stateRegistry.get(self: internalTypings.unit)
	return registry[self]
end

function stateRegistry.setState(
	self: internalTypings.unit,
	name: string,
	onEnter: (self: internalTypings.component?) -> ()?,
	onExit: (self: internalTypings.component?) -> ()?
)
	registry[self][name] = {
		onEnter = onEnter or function() end,
		onExit = onExit or function() end
	}
end

function stateRegistry.cleanup(self: internalTypings.unit)
	registry[self] = nil
end

return table.freeze(stateRegistry)
