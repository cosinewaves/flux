local ReplicatedStorage = game:GetService("ReplicatedStorage")
local flux = require(ReplicatedStorage.flux)

local u1 = flux.unit("Idle")
local u2 = flux.unit("Off")

u1:subscribe(function(old, new)
	print("u1:", old, "→", new)
end)

u2:subscribe(function(old, new)
	print("u2:", old, "→", new)
end)

u1:addState("Idle", function() end, function() end)
u1:addState("Run", function() end, function() end)
u1:changeState("Run") -- ✅ only u1 subscribers are notified

u2:addState("Off", function() end, function() end)
u2:addState("On", function() end, function() end)
u2:changeState("On") -- ✅ only u2 subscribers are notified
