local ReplicatedStorage = game:GetService("ReplicatedStorage")
local flux = require(ReplicatedStorage.Shared.flux)

local weather = flux.unit("Sunny")

weather:addState("Sunny",
    function() print("☀️ It's a bright, sunny day!") end,
    function() print("🌥 Clouds forming...") end
)

weather:addState("Rainy",
    function() print("🌧 It's raining!") end,
    function() print("🌤 Rain clearing up...") end
)

weather:addState("Stormy",
    function() print("⛈ A storm is raging!") end,
    function() print("🌥 Storm is subsiding...") end
)

weather:beforeChange(function(oldState, newState)
    print(`⚡ Weather shift: {oldState} ➝ {newState}`)
    if oldState == "Stormy" and newState == "Sunny" then
        print("❌ Can't go directly from Stormy to Sunny!")
        return false
    end
end)

weather:onEnter(function(state)
    print(`✅ Current weather: {state}`)
end)

weather:onExit(function(state)
    print(`🌍 Previous weather: {state}`)
end)

-- Simulating weather changes
task.wait(5)
weather:changeState("Rainy")
task.wait(3)
weather:changeState("Stormy")
task.wait(4)
weather:changeState("Sunny") -- Invalid transition
weather:changeState("Rainy") -- Valid transition
