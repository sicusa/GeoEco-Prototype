local class = require "lib.middleclass"
local Vector = require "lib.vector"

local PhyInteractions = require "GeoEco.Physics.PhyInteractions"

local PtlCombinativeInteraction = class("PtlCombinativeInteraction")
PtlCombinativeInteraction:include(PhyInteractions.base)

function PtlCombinativeInteraction:initialize(max_mass, min_TF)
    self.max_mass = max_mass
    self.min_TFactor = min_TF
end

function PtlCombinativeInteraction:applyImpl(e1, e2, dir, len)
    if e1:getGeneration() ~= e2:getGeneration()
            or e1.category ~= e2.category then
        return
    end

    local final_mass = e1:getMass() + e2:getMass()
    if final_mass > self.max_mass then
        return
    end

    local finalTemperature = e1:getTemperature() + e2:getTemperature()
    if finalTemperature < self.min_TFactor * final_mass then
        return
    end

    e1:setGeneration(e1:getGeneration() + 1)
    e1:setLifeCount(0)
    e1:setMass(final_mass)
    e1:setTemperature(finalTemperature)
    e2:removeSelf()
end

local PtlConnectiveInteraction = class("PtlConnectiveInteraction")
PtlConnectiveInteraction:include(PhyInteractions.base)

function PtlConnectiveInteraction:initialize(min_mass, min_TF, max_interaction_count)
    self.min_mass = min_mass
    self.min_TFactor = min_TF
    self.max_interaction_count = max_interaction_count
end

function PtlConnectiveInteraction:applyImpl(e1, e2, dir, len)
    if e1:getConnectionCount() >= self.max_interaction_count or
        e2:getConnectionCount() ~= 0 then
        return
    end

    local final_mass = e1:getMass() + e2:getMass()
    if final_mass < self.min_mass then
        return
    end

    local total_temp = e1:getTemperature() + e2:getTemperature()
    if total_temp < self.min_TFactor * final_mass then
        return
    end

    local dist = Vector:dist(e1:getPosition(), e2:getPosition())

    if Env == nil then
        Env = require "GeoEco.Environment"
    end
    Env:createConnection(e1, e2, PhyInteractions.fixedDistance:new(dist))
end

return {
    combine = PtlCombinativeInteraction,
    connect = PtlConnectiveInteraction
}
