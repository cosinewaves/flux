--!strict
--!native

export type StateCallback = () -> ()?
export type TransitionCallback<S> = (oldState: S, newState: S) -> ()

export type State<S> = {
	name: S,
	onEnter: StateCallback?,
	onExit: StateCallback?,
	onBeforeEnter: StateCallback?, -- runs before entering a state
	onAfterEnter: StateCallback?, -- runs after entering a state
	onBeforeExit: StateCallback?, -- runs before leaving a state
	onAfterExit: StateCallback?, -- runs after leaving a state
}

export type Unit<S> = {
	state: S,

	addState: (self: Unit<S>, state: State<S>) -> (),
	removeState: (self: Unit<S>, stateName: S) -> (),
	changeState: (self: Unit<S>, newState: S, eager: boolean?) -> (),

	subscribe: (self: Unit<S>, callback: TransitionCallback<S>) -> (),
	unsubscribe: (self: Unit<S>, callback: TransitionCallback<S>) -> (),

	getStates: (self: Unit<S>) -> { S },
	hasState: (self: Unit<S>, stateName: S) -> boolean,
	reset: (self: Unit<S>) -> (),

	__states: { [S]: State<S> },
	__subscribers: { TransitionCallback<S> },
}

local function safeCall(cb: StateCallback?): ()
	if cb then
		cb()
	end
	return
end

return function<S>(initialState: S): Unit<S>
	assert(initialState, "(flux) initialState resolved to false or nil")

	local self = {} :: Unit<S>
	self.state = initialState
	self.__states = {}
	self.__subscribers = {}

	self.addState = function(self: Unit<S>, state: State<S>): ()
		self.__states[state.name] = state -- add the state to the internal state table
		return
	end

	self.removeState = function(self: Unit<S>, stateName: S): ()
		self.__states[stateName] = nil -- reove
		return
	end

	self.changeState = function(self: Unit<S>, newState: S, eager: boolean?): ()
		local old = self.state
		if not eager and old == newState then
			return
		end

		local oldState: State<S>? = self.__states[old]
		local newStateObj: State<S>? = self.__states[newState]

		-- exit sequence
		if oldState then
			safeCall(oldState.onBeforeExit)
			safeCall(oldState.onExit)
			safeCall(oldState.onAfterExit)
		end

		-- update
		self.state = newState :: S

		-- enter sequence
		if newStateObj then
			safeCall(newStateObj.onBeforeEnter)
			safeCall(newStateObj.onEnter)
			safeCall(newStateObj.onAfterEnter)
		end

		-- notify subscribers
		for _, callback in self.__subscribers do
			callback(old, newState)
		end

		return
	end

	self.subscribe = function(self: Unit<S>, callback: TransitionCallback<S>): ()
		table.insert(self.__subscribers, callback)
		return
	end

	self.unsubscribe = function(self: Unit<S>, callback: TransitionCallback<S>): ()
		for i, cb in self.__subscribers do
			if cb == callback then
				table.remove(self.__subscribers, i)
				break
			end
		end
		return
	end

	self.getStates = function(self: Unit<S>): { S }
		local list = {}
		for name in self.__states do
			table.insert(list, name)
		end
		return list :: { S }
	end

	self.hasState = function(self: Unit<S>, stateName: S): boolean
		return self.__states[stateName] ~= nil
	end

	self.reset = function(self: Unit<S>): ()
		self:changeState(initialState)
		return
	end

	-- defer initial state onEnter
	task.defer(function(): ()
		local initStateObj: State<S> = self.__states[self.state]
		if initStateObj and initStateObj.onEnter then
			initStateObj.onEnter()
		end
		return
	end)

	return self
end
