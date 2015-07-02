local class = require "lib.middleclass"

local ParticleDecomposeBehaviour = class("ParticleDecomposeBehaviour")

function ParticleDecomposeBehaviour:initialize(delay_factor, min_HF, min_mass)
    self.delay_factor = delay_factor
    self.min_HFactor = min_HF
    self.min_mass = min_mass
end

function ParticleDecomposeBehaviour:update(entity)
    local generation = entity:getGeneration()
    if generation < 7 then
        return
    end

    local mass = entity:getMass()

    local t = entity:getHeat()
    if t < self.min_HFactor / mass then
        return
    end

    local life_count = entity:getLifeCount()
    if life_count < self.delay_factor / mass then
        return
    end

    entity:setMass(mass / 2)
    entity:setHeat(t / 2)
    entity:setLifeCount(0)
    entity:setGeneration(generation - 1)
    entity:breakConnections()

    local new_particle = entity:clone()

    if env == nil then
        env = require "GeoEco.Environment"
    end
    env:addParticle(new_particle)
end

local ParticleDeconnectiveBehaviour = class("ParticleDeconnectiveBehaviour")

function ParticleDeconnectiveBehaviour:initialize(delay_factor, min_HF)
    self.delay_factor = delay_factor
    self.min_HFactor = min_HF
end

function ParticleDeconnectiveBehaviour:update(entity)
    if #entity.connections == 0 then
        return
    end

    local mass = entity:getMass()

    local t = entity:getTemperature()
    if t < self.min_HFactor / mass then
        return
    end

    local life_count = entity:getLifeCount()
    if life_count < self.delay_factor / mass then
        return
    end

    entity:setLifeCount(0)
    entity:breakConnections()
end

return {
    decompose = ParticleDecomposeBehaviour,
    deconnect = ParticleDeconnectiveBehaviour
}
