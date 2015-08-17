local class = require "lib.middleclass"
local Vector = require "lib.vector"
local Rectangle = require "lib.rectangle"

local PhyEntity = require "GeoEco.Physics.PhyEntity"
local Env = require "GeoEco.Environment"

local Particle = class("Particle", PhyEntity)

function Particle:initialize(pos, mass, category)
    assert(category ~= nil, "category cannot be nil")
    PhyEntity.initialize(self, pos, mass)

    self.heat = 0
    self.life_count = 0
    self.generation = 1
    self.pulse = 0
    self.pulse_resistance = 0.01

    self.ranged_interactions = category.ranged_interactions
    self.behaviours = category.behaviours
    self.category = category

    if self.ranged_interactions == nil then
        return
    end
    local max_dis = 0
    for _, ab in pairs(self.ranged_interactions) do
        if ab.range > max_dis then
            maxDis = ab.range
        end
    end
    self.maxDis = maxDis
    self:updateInteractionRect()
end

function Particle:getCode()
    return self.code
end

function Particle:setCode(code)
    self.code = code
end

function Particle:updateInteractionRect()
    local pos = self:getPosition()
    local x, y = pos.x, pos.y
    local maxDis = self.maxDis
    self.rect = Rectangle:new(x - maxDis, y - maxDis, x + maxDis, y + maxDis)
end

function Particle:getCategory()
    return self.category
end

function Particle:setCategory(c)
    self.category = c
end

function Particle:getHeat()
    return self.heat
end

function Particle:setHeat(heat)
    self.heat = heat
end

function Particle:getLifeCount()
    return self.life_count
end

function Particle:getGeneration()
    return self.generation
end

function Particle:setGeneration(g)
    self.generation = g
end

function Particle:setLifeCount(life_count)
    self.life_count = life_count
end

function Particle:getPulse()
    return self.pulse
end

function Particle:setPulse(pulse)
    self.pulse = math.min(pulse, 1)
end

function Particle:applyPulse(pulse)
    self.pulse = math.min(self.pulse + pulse, 1)
end

function Particle:clone()
    local new_particle = Particle:new(
        self:getPosition():clone(), self:getMass(), self.category)
    new_particle.heat = self.heat
    new_particle.life_count = self.life_count
    new_particle.generation = self.generation
    new_particle.pulse = self.pulse
    return newParticle
end

-- Override
function Particle:update()
    PhyEntity.update(self)

    self.life_count = self.life_count + 1

    if self.code then
        self.code:update(self)
    end

    if self.behaviours then
        for _, behaviour in pairs(self.behaviours) do
            behaviour:update(self)
        end
    end

    -- apply Interactions
    local rbs = self.ranged_interactions
    if rbs == nil or #rbs == 0 then
        return
    end

    local pos = self:getPosition()
    local pulse = self.pulse
    self:updateInteractionRect()

    Env:findAll(self.rect, function(obj, dis)
        local entity = obj.data
        if entity == self then
            return
        end

        local dir = pos - entity:getPosition()
        local len = dir:len()
        dir:normalize_inplace()

        for _, rb in pairs(rbs) do
            if len < rb.range then
                rb.interaction:applyImpl(self, entity, dir, len, 0)
            end
        end
    end)

    for con, _ in pairs(self.connections) do
        con:applyReinforce(self.pulse)
    end

    if pulse > 0 then
        self.pulse = pulse - self.pulse_resistance
    end
end

return Particle
