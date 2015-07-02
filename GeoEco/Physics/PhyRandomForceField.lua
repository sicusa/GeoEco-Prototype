local class = require "lib.middleclass"
local Vector = require "lib.vector"

local PhyRandomForceField = class("PhyRandomForceField")

local noise = love.math.noise
local pi2 = math.pi * 2
local sin = math.sin
local cos = math.cos
local max = math.max

function PhyRandomForceField:initialize(coefficient, scale, selector, frame)
    self.coefficient = coefficient or 1
    self.scale = scale or 1
    self.frame = frame or 0
    self:setSelector(selector)
end

function PhyRandomForceField:setSelector(selector)
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

function PhyRandomForceField:getCoefficient()
    return self.coefficient
end

function PhyRandomForceField:setCoefficient(coefficient)
    self.coefficient = coefficient
end

function PhyRandomForceField:getScale()
    return self.sacle
end

function PhyRandomForceField:setScale(scale)
    self.scale = scale
end

function PhyRandomForceField:getFrame()
    return self.frame
end

function PhyRandomForceField:setFrame(frame)
    self.frame = frame or 0
end

function PhyRandomForceField:nextFrame()
    self.frame = self.frame + 1
end

function PhyRandomForceField:getSelector()
    return self.selector
end

local random = math.random

function PhyRandomForceField:getForce(x, y)
    local scale = self.scale

    -- local theta = noise(x / scale, y / scale) * pi2
    -- local force = Vector:new(cos(theta), sin(theta))
    local force = Vector:new(random(-1, 1), random(-1, 1))

    -- force:rotate_inplace(self.rotation)
    force:normalize_inplace()
    force:mul(self.coefficient)
    return force
end

function PhyRandomForceField:onUpdate(world)
    -- self.rotation = -noise(self.frame) * pi2

    for _, entity in pairs(self.selector(world)) do
        local pos = entity:getPosition()
        local force = self:getForce(pos.x, pos.y)
        entity:applyForce(force)
    end
end

return PhyRandomForceField
