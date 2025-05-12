# ⚙️ Flux - A Minimal State Machine Library for Roblox

**Flux** is a lightweight and type-safe finite state machine utility built for Roblox. It helps you manage simple or complex stateful behaviors with clear transitions, lifecycle hooks, and built-in safety.

---

## 📦 Features

* 🔁 **Declarative states** with `onEnter` and `onExit` callbacks
* ⚡ **Instant transitions** with idempotent logic
* 🧠 **Type-safe API** with optional guard clauses and hooks
* 🔒 Simple to test, extend, and debug

---

## 🛠️ Installation

> Place the `flux` module (with `internalTypings.lua`) inside `ReplicatedStorage` or another shared location in your game.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local flux = require(ReplicatedStorage.Shared.flux)
```

---

## 🔧 API

### `flux.unit(initialState: string) -> unit`

Creates a new state machine instance, initialized to the given `initialState`.
This instance can then have states added and transitioned between.

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

---

### `unit:changeState(newState: string) -> ()`

Changes the current state to `newState`. If the new state is the same as the current one, nothing happens (idempotent behavior).
This method automatically calls the `onExit` function of the current state (if defined) and then `onEnter` of the new state.

```lua
machine:changeState("Idle")
```

---

## 🔄 Example

```lua
local flux = require(ReplicatedStorage.Shared.flux)

local trafficLight = flux.unit("Red")

trafficLight:addState("Red",
	function() print("🚦 Red light on") end,
	function() print("🔴 Turning off red") end
)

trafficLight:addState("Green",
	function() print("🚦 Green light on") end,
	function() print("🟢 Turning off green") end
)

while true do
	task.wait(5)
	if trafficLight.state == "Red" then
		trafficLight:changeState("Green")
	else
		trafficLight:changeState("Red")
	end
end
```
