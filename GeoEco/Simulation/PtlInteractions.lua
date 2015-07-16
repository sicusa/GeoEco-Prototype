local class = require "lib.middleclass"
local Vector = require "lib.vector"

local PhyInteractions = require "GeoEco.Physics.PhyInteractions"

local PtlCombinativeInteraction = class("PtlCombinativeInteraction")
PtlCombinativeInteraction:include(PhyInteractions.base)

function PtlCombinativeInteraction:initialize(max_mass, min_HF)
    self.max_mass = max_mass
    self.min_HFactor = min_HF
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

    local final_heat = e1:getHeat() + e2:getHeat()
    if final_heat < self.min_HFactor * final_mass then
        return
    end

    e1:setGeneration(e1:getGeneration() + 1)
    e1:setLifeCount(0)
    e1:setMass(final_mass)
    e1:setTemperature(final_heat)
    e2:removeSelf()
end

local PtlConnectiveInteraction = class("PtlConnectiveInteraction")
PtlConnectiveInteraction:include(PhyInteractions.base)

function PtlConnectiveInteraction:initialize(min_mass, min_HF, max_interaction_count)
    self.min_mass = min_mass
    self.min_HFactor = min_HF
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

    local total_heat = e1:getHeat() + e2:getHeat()
    if total_heat < self.min_HFactor * final_mass then
        return
    end

    local dist = Vector:dist(e1:getPosition(), e2:getPosition())

    if Env == nil then
        Env = require "GeoEco.Environment"
    end
    Env:createConnection(e1, e2, PhyInteractions.fixed:new(dist))
end

local PtlHeatConductiveInteraction = class("PtlHeatConductiveInteraction")
PtlHeatConductiveInteraction:include(PhyInteractions.base)

function PtlHeatConductiveInteraction:initialize(default_coefficient)
    self.default_coefficient = default_coefficient
end

function PtlHeatConductiveInteraction:applyImpl(e1, e2, dir, len)
    local t1, t2 = e1:getHeat(), e2:getHeat()
    local diff = t1 - t2

    if diff == 0 then
        return
    end

    local defco = self.default_coefficient
    -- local co_e1 = e1:getCategory().thermal_conductivity or defco
    -- local co_e2 = e2:getCategory().thermal_conductivity or defco

    -- local t = math.min(co_e1, co_e2) * (diff / len / len)
    local t = defco * (diff / len / len)
    local mid = (t1 + t2) / 2

    t1 = t1 - t
    t2 = t2 + t

    if diff > 0 then
        if t1 < mid then
            t1 = mid
            t2 = mid
        end
    elseif t2 < mid then
        t1 = mid
        t2 = mid
    end

    e1:setHeat(t1)
    e2:setHeat(t2)
end

return {
    combine = PtlCombinativeInteraction,
    connect = PtlConnectiveInteraction,
    heat_conductive = PtlHeatConductiveInteraction
}
