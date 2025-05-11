export type unit = {
  __index: unit,
  state: string,
  states: { [string]: component },
  addState: (
    self: unit, name: string, onEnter: (self: component?) -> ()?, onExit: (self: component?) -> ()?
  ) -> (),
  changeState: (self: unit, newState: string) -> ()
}

export type component = {
  onEnter: (self: component?) -> ()?,
  onExit: (self: component?) -> ()?
}

return "internalTypings"
