--!strict
-- internalTypings.lua

export type unit = {
  __index: unit,
  state: string,
  addState: (
    self: unit, name: string,
    onEnter: (self: component?) -> ()?,
    onExit: (self: component?) -> ()?
  ) -> (),
  changeState: (self: unit, newState: string) -> (),
  subscribe: (self: unit, callback: (oldState: string, newState: string) -> ()) -> (),
  unsubscribe: (self: unit, callback: (oldState: string, newState: string) -> ()) -> (),

  -- Internal
  __subscribers: { (old: string, new: string) -> () },
}


export type component = {
  onEnter: (self: component?) -> ()?,
  onExit: (self: component?) -> ()?
}

return "internalTypings"
