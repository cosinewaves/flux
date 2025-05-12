--!strict
-- unit.lua

local internalTypings = require(script.Parent.internalTypings)
local util = require(script.Parent.util)
local stateRegistry = require(script.Parent.stateRegistry)

local unit = {}
unit.__index = unit

function unit.new(initialState: string): internalTypings.unit
	local self: internalTypings.unit = setmetatable({
		state = initialState,
	}, unit)

	StateRegistry.init(self)
	util.deferInitialEnter(self)

	return self
end

function unit:addState(
	name: string,
	onEnter: (self: internalTypings.component?) -> ()?,
	onExit: (self: internalTypings.component?) -> ()?
): ()
	StateRegistry.setState(self, name, onEnter, onExit)
end

function unit:changeState(newState: string): ()
	if self.state == newState then return end

	local states = StateRegistry.get(self)

	local current = states[self.state]
	if current then current.onExit() end

	self.state = newState

	local next = states[self.state]
	if next then next.onEnter() end
end

setmetatable(unit, { __call = unit.new })
return table.freeze(unit)
