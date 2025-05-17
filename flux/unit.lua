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
        __guards = {},
        __history = {},
        __timeouts = {},
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

-- Add timed transitions
function unit:setTimeout(targetState: string, delay: number)
    if typeof(targetState) ~= "string" or targetState == "" or typeof(delay) ~= "number" then
        errors.new("unit", "Invalid timeout parameters", 4)
    end

    local timeoutTask = task.delay(delay, function()
        self:changeState(targetState)
    end)
    table.insert(self.__timeouts, timeoutTask)
end

-- Modify state change for conditional guards
function unit:addGuard(state: string, condition: (oldState: string, newState: string) -> boolean)
    if not StateRegistry.get(self)[state] then
        errors.new("unit", `State '{state}' does not exist`, 3)
    end

    self.__guards[state] = condition
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

    -- Check conditional guards
    if self.__guards[newState] then
        local result = self.__guards[newState](self.state, newState)
        if not result then return end
    end

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

    -- Store previous state for rollback
    table.insert(self.__history, oldState)

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

-- Rollback state
function unit:rollback()
    if #self.__history == 0 then return end

    local lastState = table.remove(self.__history)
    self:changeState(lastState)
end

setmetatable(unit, {
    __call = function(_, ...)
        return unit.new(...)
    end,
})

return table.freeze(unit)
