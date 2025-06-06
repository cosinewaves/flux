--!strict
-- unit.lua

-- dependencies
local internalTypings = require(script.Parent.internalTypings :: ModuleScript)
local util = require(script.Parent.util :: ModuleScript)
local StateRegistry = require(script.Parent.stateRegistry :: ModuleScript)
local errors = require(script.Parent.errors :: ModuleScript)

-- internal metatable
local unit = {}
unit.__index = unit

-- primary function to create a state-machine
-- https://en.wikipedia.org/wiki/Finite-state_machine
function unit.new(initialState: string): internalTypings.unit
	if typeof(initialState) ~= "string" or initialState == "" then
		errors.new("unit", "Initial state must be a non-empty string", 4)
	end

	local self: internalTypings.unit = setmetatable({
		state = initialState,
		__subscribers = {},
		__onceSubscribers = {},
		__beforeChangeHooks = {},
		__onEnterMiddleware = {},
		__onExitMiddleware = {},
	}, unit)

	StateRegistry.init(self)
	util.deferInitialEnter(self)

	return self
end

function unit:subscribe(callback: (oldState: string, newState: string) -> ())
	table.insert(self.__subscribers, callback)
end

function unit:unsubscribe(callback: (oldState: string, newState: string) -> ())
	for i, cb in ipairs(self.__subscribers) do
		if cb == callback then
			table.remove(self.__subscribers, i)
			break
		end
	end
end

-- lifecycle functions
function unit:once(callback: (oldState: string, newState: string) -> ())
	table.insert(self.__onceSubscribers, callback)
	return
end

function unit:beforeChange(callback: (oldState: string, newState: string) -> boolean?)
	table.insert(self.__beforeChangeHooks, callback)
	return
end

function unit:onEnter(callback: (state: string) -> ())
	table.insert(self.__onEnterMiddleware, callback)
	return
end

function unit:onExit(callback: (state: string) -> ())
	table.insert(self.__onExitMiddleware, callback)
	return
end

local function notifySubscribers(self: internalTypings.unit, oldState: string, newState: string)
	for _, callback in ipairs(self.__subscribers) do
		task.spawn(callback, oldState, newState)
	end
	for _, callback in ipairs(self.__onceSubscribers) do
		task.spawn(callback, oldState, newState)
	end
	self.__onceSubscribers = {}
	return
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
	return
end

function unit:changeState(newState: string): ()
	if typeof(newState) ~= "string" or newState == "" then
		errors.new("unit", "New state must be a non-empty string", 4)
	end

	if self.state == newState then return end

	for _, hook in ipairs(self.__beforeChangeHooks) do
		local result = hook(self.state, newState)
		if result == false then return end
	end

	local states = StateRegistry.get(self)

	local current = states[self.state]
	if current and current.onExit then
		for _, middleware in ipairs(self.__onExitMiddleware) do
			task.spawn(middleware, self.state)
		end
		pcall(current.onExit)
	end

	local oldState = self.state
	self.state = newState

	local next = states[newState]
	if not next then
		errors.new("unit", `Target state '{newState}' does not exist`, 4)
	end

	if next.onEnter then
		for _, middleware in ipairs(self.__onEnterMiddleware) do
			task.spawn(middleware, newState)
		end
		pcall(next.onEnter)
	end

	notifySubscribers(self, oldState, newState)
	return
end

setmetatable(unit, {
	__call = function(_, ...)
		return unit.new(...)
	end,
})

return table.freeze(unit)
