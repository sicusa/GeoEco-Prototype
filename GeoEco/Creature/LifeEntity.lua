local class = require "lib.middleclass"
local PhyEntity = require "GeoEco.Physics.PhyEntity"

local LifeEntity = class("LifeEntity", PhyEntity)

function LifeEntity:initialize(pos, emptyMass)
    PhyEntity.initialize(self, pos, emptyMass)

    self.emptyMass = emptyMass
    self.energy = 0
    self.temperature = 0
    self.age = 0
end

function LifeEntity:getEnergy()
    return self.energy
end

function LifeEntity:setEnergy(energy)
    assert(type(energy) == "number", "energy must be a number")
    self.energy = energy
    self:setMass(self.emptyMass + energy)
end

function LifeEnergy:getEmtpyMass()
    return self.emtpyMass
end

function LifeEnergy:setEmptyMass(emptyMass)
    assert(type(emptyMass) == "number", "emptyMass must be a number")
    self.emptyMass = emptyMass
end

function LifeEnergy:getTemperature()
    return self.temperature
end

function LifeEnergy:setTemperature(temp)
    assert(type(temp) == "number", "temperature must be a number")
    self.temperature = temp
end

function LifeEnergy:getAge()
    return self.age
end

function LifeEnergy:setAge(age)
    assert(type(age) == "number", "age must be a number")
    self.age = age
end

-- Override
function LifeEnergy:update()
    PhyEntity.update(self)
    self.age = self.age + 1
end
