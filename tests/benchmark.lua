--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local flux = require(ReplicatedStorage.flux)
local HttpService = game:GetService("HttpService") -- For random state names

local function generateRandomState(): string
    return `State_{HttpService:GenerateGUID(false)}` -- Unique state names
end

local function benchmarkFluxMachine()
    local startTime = tick() -- Start timing

    -- Create 1000 machines
    local machines = {}
    for i = 1, 1000 do
        local machine = flux.unit(generateRandomState())
        for j = 1, 10 do
            local stateName = generateRandomState()
            machine:addState(stateName, function() end, function() end)
        end
        table.insert(machines, machine)
    end

    -- Simulate 10,000 state changes
    for _, machine in ipairs(machines) do
        for _ = 1, 10 do
            local randomState = generateRandomState()
            machine:changeState(randomState) -- Perform transition
        end
    end

    local endTime = tick() -- End timing
    local duration = endTime - startTime
    print(`🔥 Flux Benchmark Completed in {duration} seconds`)
end

benchmarkFluxMachine()
