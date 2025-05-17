local internalTypings = require(script.Parent.internalTypings)
local StateRegistry = require(script.Parent.stateRegistry)
local util = require(script.Parent.util)
local errors = require(script.Parent.errors)

local unit = {}
unit.__index = unit

-- Subscribers for state change
local stateChangeSubscribers = {}

function unit.new(initialState: string): internalTypings.unit
	if typeof(initialState) ~= "string" or initialState == "" then
		errors.new("unit", "Initial state must be a non-empty string", 4)
	end

	local self: internalTypings.unit = setmetatable({
		state = initialState,
	}, unit)

	util.deferInitialEnter(self)
	StateRegistry.init(self)

	return self
end

function unit:subscribe(callback: (oldState: string, newState: string) -> ())
	table.insert(stateChangeSubscribers, callback)
end

function unit:unsubscribe(callback: (oldState: string, newState: string) -> ())
	for i, subscriber in ipairs(stateChangeSubscribers) do
		if subscriber == callback then
			table.remove(stateChangeSubscribers, i)
			break
		end
	end
end

local function notifySubscribers(oldState: string, newState: string)
	for _, callback in ipairs(stateChangeSubscribers) do
		callback(oldState, newState)
	end
end

function unit:addState(
	name: string,
	onEnter: (self: internalTypings.component?) -> ()?,
	onExit: (self: internalTypings.component?) -> ()?
): ()
	if typeof(name) ~= "string" or name == "" then
		errors.new("unit", "State name must be a non-empty string", 4)
	end

	local states = StateRegistry.get(self)

	if states[name] then
		errors.new("unit", `State '{name}' is already defined`, 3)
	end

	StateRegistry.setState(self, name, onEnter, onExit)
end

function unit:changeState(newState: string): ()
	if typeof(newState) ~= "string" or newState == "" then
		errors.new("unit", "New state must be a non-empty string", 4)
	end

	if self.state == newState then
		return
	end

	local states = StateRegistry.get(self)

	local current = states[self.state]
	if current and current.onExit then
		pcall(current.onExit)
	end

	local oldState = self.state
	self.state = newState

	local next = states[newState]
	if not next then
		errors.new("unit", `Target state '{newState}' does not exist`, 4)
	end

	if next.onEnter then
		pcall(next.onEnter)
	end

	notifySubscribers(oldState, newState)
end

-- ✅ This makes unit("Off") work!
return setmetatable(unit, {
	__call = function(_, ...)
		return unit.new(...)
	end,
})
