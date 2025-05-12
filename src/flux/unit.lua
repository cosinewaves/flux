--!strict
-- unit.lua

local internalTypings = require(script.Parent.internalTypings)
local util = require(script.Parent.util)
local StateRegistry = require(script.Parent.stateRegistry)
local errors = require(script.Parent.errors)

local unit = {}
unit.__index = unit

-- Holds all the subscribed callbacks for state changes
local stateChangeSubscribers = {}

function unit.new(initialState: string): internalTypings.unit
	if typeof(initialState) ~= "string" or initialState == "" then
		errors.new("unit", "Initial state must be a non-empty string", 4)
	end

	local self: internalTypings.unit = setmetatable({
		state = initialState,
	}, unit)

	StateRegistry.init(self)
	util.deferInitialEnter(self)

	return self
end

-- Subscribe to state changes
function unit:subscribe(callback: (oldState: string, newState: string) -> ())
	table.insert(stateChangeSubscribers, callback)
end

-- Unsubscribe from state changes
function unit:unsubscribe(callback: (oldState: string, newState: string) -> ())
	for i, subscriber in ipairs(stateChangeSubscribers) do
		if subscriber == callback then
			table.remove(stateChangeSubscribers, i)
			break
		end
	end
end

-- Notify all subscribers about state change
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
		return -- No-op: already in desired state
	end

	local states = StateRegistry.get(self)

	local current = states[self.state]
	if current and current.onExit then
		pcall(function()
			current.onExit()
		end)
	else
		errors.new("unit", `No onExit for current state '{self.state}'`, 2)
	end

	local oldState = self.state
	self.state = newState

	local next = states[self.state]
	if not next then
		errors.new("unit", `Target state '{self.state}' does not exist`, 4)
	end

	if next.onEnter then
		pcall(function()
			next.onEnter()
		end)
	else
		errors.new("unit", `No onEnter for new state '{self.state}'`, 2)
	end

	-- Notify all subscribers about the state change
	notifySubscribers(oldState, newState)
end

setmetatable(unit, { __call = unit.new })
return table.freeze(unit)
