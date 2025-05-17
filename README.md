# ⚙️ Flux - A Minimal State Machine Library for Roblox

**Flux** is a lightweight and type-safe finite state machine utility built for Roblox. It helps you manage simple or complex stateful behaviors with clear transitions, lifecycle hooks, and built-in safety.

## 📦 Features

- 🔁 **Declarative states** with `onEnter` and `onExit` callbacks
- ⚡ **Instant transitions** with idempotent logic
- 🧠 **Type-safe API** with optional guard clauses and hooks
- 🔄 **Lifecycle support**, including middleware for enter/exit events
- 🔒 Simple to test, extend, and debug

---

## 🛠️ Installation

> Place the `flux` module (along with `internalTypings.lua`) inside **ReplicatedStorage** or another shared location in your game.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local flux = require(ReplicatedStorage.Shared.flux)
```

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

---

### `unit:changeState(newState: string) -> ()`

Changes the current state to `newState`. If the new state is the same as the current one, nothing happens (idempotent behavior).
This method automatically calls the `onExit` function of the current state (if defined) and then `onEnter` of the new state.

```lua
machine:changeState("Idle")
```

---

### Lifecycle Hooks

Flux now includes new lifecycle capabilities:

#### `unit:beforeChange(callback: (oldState: string, newState: string) -> boolean?)`

Registers a hook that executes **before** the state changes. If the callback returns `false`, the state change is **prevented**.

```lua
machine:beforeChange(function(oldState, newState)
	if newState == "Error" then
		return false -- prevent entering the error state
	end
end)
```

#### `unit:onEnter(callback: (state: string) -> ())`

Registers a middleware function that runs **when entering a new state**.

```lua
machine:onEnter(function(state)
	print("Transitioned to:", state)
end)
```

#### `unit:onExit(callback: (state: string) -> ())`

Registers a middleware function that runs **before exiting a state**.

```lua
machine:onExit(function(state)
	print("Leaving state:", state)
end)
```

---

## 🔄 Example: Traffic Light System

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

trafficLight:beforeChange(function(oldState, newState)
	if oldState == "Red" and newState == "Green" then
		print("⚠️ Transitioning from Red to Green")
	end
end)

trafficLight:onEnter(function(state)
	print("✅ Entered:", state)
end)

while true do
	task.wait(5)
	if trafficLight.state == "Red" then
		trafficLight:changeState("Green")
	else
		trafficLight:changeState("Red")
	end
end
```
