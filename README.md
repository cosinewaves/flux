# ⚙️ Flux - A Minimal State Machine Library

**Flux** is a lightweight and type-safe finite state machine.

## 📦 Features

- 🔁 **Declarative states** with `onEnter` and `onExit` callbacks
- ⚡ **Instant transitions** with idempotent logic
- 🧠 **Type-safe API** 
- 🔄 **Lifecycle support**, including middleware for enter/exit events
- 🔒 Simple to test, extend, and debug

---

## 🔧 API

### `flux.unit(initialState: string) -> unit`

Creates a new state machine instance, initialized to the given `initialState`. This instance can then have states added and transitioned between.

```lua
local machine = flux.unit("Idle")
```

---

### `unit:addState(name: string, onEnter: () -> ()?, onExit: () -> ()?) -> ()`

Adds a named state to the state machine. Both `onEnter` and `onExit` are optional lifecycle callbacks that run when transitioning **to** or **from** the state.

```lua
machine:addState("Idle",
	function()
		print("Entering Idle")
	end,
	function()
		print("Exiting Idle")
	end
)
```
or
```lua
machine:addState({
		name = "Idle",
		onEnter = function()
			print("Entering Idle")
		end,
		onExit = function()
			print("Exiting Idle")
		end,
	})
```

---

### `unit:changeState(newState: string) -> ()`

Changes the current state to `newState`. If the new state is the same as the current one, nothing happens (idempotent behavior).
This method automatically calls the `onExit` function of the current state (if defined) and then `onEnter` of the new state.

```lua
machine:changeState("Idle")
```

