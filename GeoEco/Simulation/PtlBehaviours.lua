local class = require "lib.middleclass"

local ParticleDecomposeBehaviour = class("ParticleDecomposeBehaviour")

function ParticleDecomposeBehaviour:initialize(delay_factor, minTF, min_mass)
    self.delay_factor = delay_factor
    self.min_TFactor = minTF
    self.min_mass = min_mass
end

function ParticleDecomposeBehaviour:update(entity)
    local generation = entity:getGeneration()
    if generation < 7 then
        return
    end

    local mass = entity:getMass()

    local t = entity:getTemperature()
    if t < self.min_TFactor / mass then
        return
    end

    local life_count = entity:getLifeCount()
    if life_count < self.delay_factor / mass then
        return
    end

    entity:setMass(mass / 2)
    entity:setTemperature(t / 2)
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

function ParticleDeconnectiveBehaviour:initialize(delay_factor, minTF)
    self.delay_factor = delay_factor
    self.min_TFactor = minTF
end

function ParticleDeconnectiveBehaviour:update(entity)
    if #entity.connections == 0 then
        return
    end

    local mass = entity:getMass()

    local t = entity:getTemperature()
    if t < self.min_TFactor / mass then
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
