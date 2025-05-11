local ReplicatedStorage = game:GetService("ReplicatedStorage")
local flux = require(ReplicatedStorage.Shared.flux)

local unit = flux.unit("Off") -- create a state machine and initialise the first state

unit:addState("Off",

  function() -- onEnter function
    print("Transitioning to 'off' state.")
  end),

  function() -- onExit
    print("Leaving 'off' state.")
  end)

)

unit:addState("On",

  function() -- onEnter function
    print("Transitioning to 'on' state.")
  end),

  function() -- onExit
    print("Leaving 'on' state.")
  end)

)

while task.wait(5) do
  math.random(1, 2) == 1 and unit:changeState("Off") or unit:changeState("On") -- keep randomly updating the state
end
