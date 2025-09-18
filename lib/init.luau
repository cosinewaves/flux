--!strict
--!native

--- @type StateCallback (...any) -> ()?
--- @within Unit
--- A function called during a lifecycle event.
--- Can optionally return another function or nil.
export type StateCallback = (...any) -> ()?

--- @type TransitionCallback<S> (oldState: S, newState: S) -> ()
--- @within Unit
--- A function called whenever the Unit transitions between states.
--- Receives the previous state and the new state as parameters.
export type TransitionCallback<S> = (oldState: S, newState: S) -> ()

--- @type TransitionCheck<S> (oldState: S, newState: S) -> boolean
--- @within Unit
--- A predicate function called before transitioning between states.
--- If it returns false, the transition is aborted.
export type TransitionCheck<S> = (oldState: S, newState: S) -> boolean

--- @interface State<S>
--- @within Unit
--- @field name S -- The unique name of the state
--- @field onEnter StateCallback? -- Called when entering the state
--- @field onExit StateCallback? -- Called when exiting the state
--- @field onBeforeEnter StateCallback? -- Called immediately before entering the state
--- @field onAfterEnter StateCallback? -- Called immediately after entering the state
--- @field onBeforeExit StateCallback? -- Called immediately before leaving the state
--- @field onAfterExit StateCallback? -- Called immediately after leaving the state
export type State<S> = {
	name: S,
	onEnter: StateCallback?,
	onExit: StateCallback?,
	onBeforeEnter: StateCallback?, -- runs before entering a state
	onAfterEnter: StateCallback?, -- runs after entering a state
	onBeforeExit: StateCallback?, -- runs before leaving a state
	onAfterExit: StateCallback?, -- runs after leaving a state
}

--- @interface Middleware<S>
--- @within Unit
--- @field beforeChange TransitionCallback<S>? -- Called before changing any state
--- @field afterChange TransitionCallback<S>? -- Called after changing any state
--- @field canTransition TransitionCallback<S>? -- Predicate function before changing any state
--- @field onError (error: string) -> ()?, -- -- Called whenever a lifecycle hook, subscriber, or middleware throws an error
export type Middleware<S> = {
	beforeChange: TransitionCallback<S>?,
	afterChange: TransitionCallback<S>?,
	canTransition: TransitionCheck<S>?,
	onError: (error: string) -> ()?,
}

--- @interface Unit<S>
--- @within Unit
--- @field state S -- The current state of the Unit
--- @field addState (self: Unit<S>, state: State<S>) -> () -- Register a new state with optional lifecycle callbacks
--- @field removeState (self: Unit<S>, stateName: S) -> () -- Unregister a state by its name
--- @field changeState (self: Unit<S>, newState: S, eager: boolean?) -> () -- Transition to a new state (eager = force transition even if same)
--- @field subscribe (self: Unit<S>, callback: TransitionCallback<S>) -> () -- Register a callback fired on every state transition
--- @field unsubscribe (self: Unit<S>, callback: TransitionCallback<S>) -> () -- Remove a previously registered transition callback
--- @field getStates (self: Unit<S>) -> { S } -- Returns all registered state names
--- @field hasState (self: Unit<S>, stateName: S) -> boolean -- Returns true if a given state is registered
--- @field reset (self: Unit<S>) -> () -- Resets the Unit back to its initial state
--- @field use (self: Unit<S>, middleware: Middleware<S>) -- Middleware functions which act per machine, instead of per state

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

	use: (self: Unit<S>, middleware: Middleware<S>) -> (),

	__states: { [S]: State<S> },
	__subscribers: { TransitionCallback<S> },
	__middleware: { Middleware<S> },
}

--[=[
	@class Unit

	Unit's serve as a state machine within Flux. They contain internal tables holding state and subscribers,
	and also handle functions like subscription callbacks and changing states. 
]=]

-- receives the full error message and traceback (captured via `xpcall`)
-- the error is suppressed from roblox's default runtime error output, so the machine continues running
-- multiple `onError` middleware functions may be registered; all will be invoked.
local function safeCall(self: Unit<any>, fn, ...) -- safely call a function with traceback
	if not fn then
		return
	end
	local ok, result = xpcall(fn, debug.traceback, ...)
	if not ok then
		for _, mw in self.__middleware do
			if mw.onError then
				mw.onError(result) -- full traceback
			end
		end
	end
end

return function<S>(initialState: S): Unit<S>
	assert(initialState, "(flux) initialState resolved to false or nil")

	local self = {} :: Unit<S>
	self.state = initialState
	self.__states = {}
	self.__subscribers = {}
	self.__middleware = {}

	--[=[
		You can add a state to the state machine, which can then be entered and exited with optional lifecycle events.
		
		@method addState
		@within Unit
		@param state State<S> 
		@return ()
	]=]
	self.addState = function(self: Unit<S>, state: State<S>): ()
		self.__states[state.name] = state -- add the state to the internal state table
		return
	end

	--[=[
		Removes a state from the internal registry
		
		@method removeState
		@within Unit
		@param stateName S 
		@return ()
	]=]
	self.removeState = function(self: Unit<S>, stateName: S): ()
		self.__states[stateName] = nil -- reove
		return
	end

	--[=[
	Transitions the Unit from its current state to a new state.

	**Sequence**:
	1. Runs all middleware `canTransition` checks.  
	   - If any returns `false`, the transition is aborted.  
	2. Calls old state's lifecycle hooks (safely wrapped in `pcall`):  
	   `onBeforeExit → onExit → onAfterExit`  
	3. Updates the Unit's `state` field.  
	4. Calls new state's lifecycle hooks (safely wrapped in `pcall`):  
	   `onBeforeEnter → onEnter → onAfterEnter`  
	5. Notifies all subscribers of the transition.  
	6. If any lifecycle or subscriber throws, middleware `onError` hooks are invoked.

	**Note**:  
	- If the new state is not registered, lifecycle hooks are skipped, 
	  but the `state` value is still updated.  
	- `onError` middleware provides centralized error handling.  

	@method changeState
	@within Unit
	@param newState S -- The state to transition into
	@param eager? boolean -- true = force transition even if old == new, false = lazy (default)
	@return ()
]=]
	self.changeState = function(self: Unit<S>, newState: S, eager: boolean?): ()
		local old = self.state

		-- lazy evaluation: skip if state unchanged and not eager
		if not eager and old == newState then
			return
		end

		-- check guard middleware
		for _, mw in self.__middleware do
			if mw.canTransition and not mw.canTransition(old, newState) then
				return -- blocked
			end
		end

		-- run beforeChange middleware
		for _, mw in self.__middleware do
			if mw.beforeChange then
				safeCall(self, mw.beforeChange, old, newState)
			end
		end

		-- perform transition safely
		local oldStateObj = self.__states[old]
		local newStateObj = self.__states[newState]

		-- exit old state
		if oldStateObj then
			if oldStateObj.onBeforeExit then
				safeCall(self, oldStateObj.onBeforeExit, self)
			end
			if oldStateObj.onExit then
				safeCall(self, oldStateObj.onExit, self)
			end
			if oldStateObj.onAfterExit then
				safeCall(self, oldStateObj.onAfterExit, self)
			end
		end

		-- update current state
		self.state = newState :: S

		-- enter new state
		if newStateObj then
			if newStateObj.onBeforeEnter then
				safeCall(self, newStateObj.onBeforeEnter, self)
			end
			if newStateObj.onEnter then
				safeCall(self, newStateObj.onEnter, self)
			end
			if newStateObj.onAfterEnter then
				safeCall(self, newStateObj.onAfterEnter, self)
			end
		end

		-- notify subscribers
		for _, callback in self.__subscribers do
			safeCall(self, callback, old, newState)
		end

		-- run afterChange middleware
		for _, mw in self.__middleware do
			if mw.afterChange then
				safeCall(self, mw.afterChange, old, newState)
			end
		end
	end

	--[=[
		Registers a callback to be invoked whenever the Unit changes state.

		**Sequence**:
		- After every successful state transition, the callback is called with 
		  `(oldState, newState)`.

		**Note**: Callbacks should be pure functions without side effects that 
		modify the Unit directly, to avoid unintended recursion.

		@method subscribe
		@within Unit
		@param callback TransitionCallback<S> 
		@return ()
	]=]
	self.subscribe = function(self: Unit<S>, callback: TransitionCallback<S>): ()
		table.insert(self.__subscribers, callback)
		return
	end

	--[=[
		Unregisters a previously subscribed transition callback.

		**Sequence**:
		- Removes the first matching callback reference from the subscriber list.
		- If the callback was not registered, nothing happens.

		**Note**: The callback reference must be the same function object 
		that was passed to `subscribe`.

		@method unsubscribe
		@within Unit
		@param callback TransitionCallback<S> -- function(old: S, new: S) -> ()
		@return ()
	]=]
	self.unsubscribe = function(self: Unit<S>, callback: TransitionCallback<S>): ()
		for i, cb in self.__subscribers do
			if cb == callback then
				table.remove(self.__subscribers, i)
				break
			end
		end
		return
	end

	--[=[
		Returns a list of all registered state names in the Unit.

		**Note**: The order of states in the returned list is not guaranteed.

		@method getStates
		@within Unit
		@return { S } -- array of state names
	]=]
	self.getStates = function(self: Unit<S>): { S }
		local list = {}
		for name in self.__states do
			table.insert(list, name)
		end
		return list :: { S }
	end

	--[=[
		Checks whether a state with the given name is registered in the Unit.

		@method hasState
		@within Unit
		@param stateName S -- the state name to check
		@return boolean -- true if the state is registered, false otherwise
	]=]
	self.hasState = function(self: Unit<S>, stateName: S): boolean
		return self.__states[stateName] ~= nil
	end

	--[=[
		Resets the Unit back to its initial state.

		**Sequence**:
		- Calls `changeState(initialState)` internally, 
		  triggering lifecycle hooks and subscriber notifications.

		@method reset
		@within Unit
		@return ()
	]=]
	self.reset = function(self: Unit<S>): ()
		self:changeState(initialState)
		return
	end

	--[=[
		Inserts a table of middleware into the machine. Middleware is different from lifecycles
		because it behaves per-machine, whereas lifecycle events behave per state.


		@method use
		@within Unit
		@param middleware Middleware<S>
		@return ()
	]=]
	self.use = function(self: Unit<S>, middleware: Middleware<S>): ()
		table.insert(self.__middleware, middleware)
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
