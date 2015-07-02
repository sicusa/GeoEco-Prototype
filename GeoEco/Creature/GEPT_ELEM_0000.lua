local class = require "lib.middleclass"
local PhyEntity = require "GeoEco.Physics.PhyEntity"

local GEPT_ELEM_0000 = class("GEPT_ELEM_0000", PhyEntity)

function GEPT_ELEM_0000:initialize(pos, mass)
    PhyEntity.initialize(self, pos, mass)

    self.temperature = 0
    self.lifeCount = 0
end

function GEPT_ELEM_0000:getTemperature()
    return self.temperature
end

function GEPT_ELEM_0000:setTemperature(temp)
    self.temperature = temp
end

function GEPT_ELEM_0000:getLifeCount()
    return self.lifeCount
end

function GEPT_ELEM_0000:setLifeCount(lifeCount)
    self.lifeCount = lifeCount
end

-- Override
function GEPT_ELEM_0000:update()
    PhyEntity.update(self)
    self.lifeCount = self.lifeCount + 1
end
