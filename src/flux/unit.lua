-- TO:DO add internal update function after unit.new
local internalTypings = require(script.Parent.internalTypings)

local unit = {}
unit.__index = unit

function unit.new(initialState: string): internalTypings.unit

	-- create the class
	local self: internalTypings.unit = setmetatable({
		state = initialState, -- skip setting the state manually by doing it on creation
		states = {} -- internal list of all states // MAKE PRIVATE
	}, unit)

	return self

end

function unit:addState(
	name: string,
	onEnter: (self: component?) -> ()?,
	onExit: (self: component?) -> ()?
): ()

	self.states[name] = {
		onEnter = onEnter or function() end,
		onExit = onExit or function() end
	}

	return
end

function unit:changeState(newState: string): ()
	-- https://en.wikipedia.org/wiki/Idempotence
	-- https://en.wikipedia.org/wiki/Guard_(computer_science)
	if self.state == newState then return end

	local current = self.states[self.state] :: internalTypings.component
	if current then current.onExit() end

	self.state = newState

	local nextState = self.states[newState] :: internalTypings.component
	if nextState then
		nextState.onEnter()
	end

	return

end


setmetatable(unit, {__call = unit.new})
return table.freeze(unit)
