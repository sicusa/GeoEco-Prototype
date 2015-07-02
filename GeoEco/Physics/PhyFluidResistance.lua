local class = require "lib.middleclass"
local setSelector = require "GeoEco.EntitySelectorSetter"

local PhyFluidResistance = class("PhyFluidResistance")

function PhyFluidResistance:initialize(coefficient, density_getter, selector)
    self.coefficient = coefficient
    self:setDensityGetter(density_getter)
    setSelector(self, "selector", selector)
end

function PhyFluidResistance:getDensityGetter()
    return self.density_getter
end

function PhyFluidResistance:setDensityGetter(density_getter)
    if type(density_getter) == "number" then
        self.density_getter = function(...) return density_getter end
    elseif type(density_getter) == "function" then
        self.density_getter = density_getter
    else
        assert(false, "density_getter must be a number or a function")
    end
end

function PhyFluidResistance:getCoefficient()
    return self.coefficient
end

function PhyFluidResistance:setCoefficient(coefficient)
    self.coefficient = coefficient
end

function PhyFluidResistance:getSelector()
    return self.selector
end

function PhyFluidResistance:setSelector(selector)
    if selector == nil then
        self.selector = function(world) return world:getEntities() end
    elseif type(selector) == "function" then
        self.selector = selector
    elseif type(selector) == "table" then
        self.selector = function(...) return selector end
    else
        assert(false, "selector has invalid type")
    end
end

function PhyFluidResistance:onUpdate(world)
    self.selector(function(entity)
        local density = self.density_getter(world, entity)
        local speed = entity.velocity:len()
        entity:applyResistance(self.coefficient * speed * speed * density)
    end)
end

return PhyFluidResistance
