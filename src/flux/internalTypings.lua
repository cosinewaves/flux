--!strict
-- internalTypings.lua

export type unit = {
  __index: unit,
  state: string,
  states: { [string]: component },

  -- Methods
  addState: (
    self: unit,
    name: string,
    onEnter: (self: component?) -> ()?,
    onExit: (self: component?) -> ()?
  ) -> (),

  changeState: (self: unit, newState: string) -> (),

  -- Subscription methods
  subscribe: (self: unit, callback: (oldState: string, newState: string) -> ()) -> (),
  unsubscribe: (self: unit, callback: (oldState: string, newState: string) -> ()) -> ()
}

export type component = {
  onEnter: (self: component?) -> ()?,
  onExit: (self: component?) -> ()?
}

return "internalTypings"
