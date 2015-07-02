local class = require "lib.middleclass"
local Vector = require "lib.vector"

local min, max, abs = math.min, math.max, math.abs

local PhyInteraction = {}

function PhyInteraction:apply(e1, e2)
    local dif = e1:getPosition() - e2:getPosition()
    local len = dif:len()
    dif:normalize_inplace()
    self:applyImpl(e1, e2, dif, len)
end

local PhySpringInteraction = class("PhySpringInteraction")
PhySpringInteraction:include(PhyInteraction)

function PhySpringInteraction:initialize(info)
    self.elastic = info.elastic
    self.rest_len = info.rest_len
    self.min_len  = info.min_len or 0
    self.max_len  = info.max_len or 100000000
end

function PhySpringInteraction:getElasticCoefficient()
    return self.elastic
end

function PhySpringInteraction:setElasticCoefficient(elastic)
    self.elastic = elastic
end

function PhySpringInteraction:getRestLength()
    return self.rest_len
end

function PhySpringInteraction:setRestLength(rest_len)
  self.rest_len = rest_len
end

function PhySpringInteraction:getMinimumLength()
    return self.min_len
end

function PhySpringInteraction:setMinimumLength(min_len)
    self.min_len = min_len
end

function PhySpringInteraction:getMaximumLength()
    return self.max_len
end

function PhySpringInteraction:setMaximumLength(max_len)
    self.max_len = max_len
end

function PhySpringInteraction:applyImpl(e1, e2, dir, len)
    local elastic = self.elastic
    local min_len, max_len = self.min_len, self.max_len
    local x = self.rest_len - len

    if len < min_len then
        local e1m, e2m = e1:getMass(), e2:getMass()
        local tm = e1m + e2m
        local exten = dir * (min_len - len)

        e1.position:add(exten * (e1m / tm))
        exten:mul(-1)
        e2.position:add(exten * (e2m / tm))

        e1:setVelocity(0, 0)
        e2:setVelocity(0, 0)
    elseif len > max_len then
        local e1m, e2m = e1:getMass(), e2:getMass()
        local tm = e1m + e2m
        local exten = dir * (len - max_len)

        e1.position:sub(exten * (e1m / tm))
        exten:mul(-1)
        e2.position:sub(exten * (e2m / tm))

        e1:setVelocity(0, 0)
        e2:setVelocity(0, 0)
    end

    local force = dir * (-elastic * x)

    e2:applyForce(force)
    force:mul(-1)
    e1:applyForce(force)
end

local PhyGravityInteraction = class("PhyGravityInteraction")
PhyGravityInteraction:include(PhyInteraction)

function PhyGravityInteraction:initialize(coefficient)
    self.coefficient = coefficient or 6.6
end

function PhyGravityInteraction:applyImpl(e1, e2, dir, len)
    if len < 1 then
        return
    end

    local distance = math.max(len, 10)

    local force = dir:clone()
    force:mul(self.coefficient * (e1.mass * e2.mass) / (distance * distance))

    e2:applyForce(force)
    if not e1:isFixed() then
        force:mul(-1)
        e1:applyForce(force)
    end
end

local PhyFixedDistanceInteraction = class("PhyFixedDistanceInteraction")
PhyFixedDistanceInteraction:include(PhyInteraction)

function PhyFixedDistanceInteraction:initialize(distance)
    self.distance = distance
end

function PhyFixedDistanceInteraction:applyImpl(e1, e2, dir, len)
    local e1m, e2m = e1:getMass(), e2:getMass()
    local tm = e1m + e2m
    local stddis = self.distance

    local dis = dir * abs(self.distance - len)

    if len > stddis then
        e1.position:sub(dis * (e1m / tm))
        dis:mul(-1)
        e2.position:sub(dis * (e2m / tm))
    else
        e1.position:add(dis * (e1m / tm))
        dis:mul(-1)
        e2.position:add(dis * (e2m / tm))
    end
end

local CallbackInteraction = class("CallbackInteraction")
CallbackInteraction:include(PhyInteraction)

function CallbackInteraction:initialize(callback)
    self.callback = callback
end

function CallbackInteraction:apply(e1, e2, dir, len)
    self.callback(e1, e2, dir, len)
end

local MultiInteraction = class("MultiInteraction")
MultiInteraction:include(PhyInteraction)

function MultiInteraction:initialize(...)
    self.interactions = ...
end

function MultiInteraction:apply(e1, d2, dir, len)
    for _, i in pairs(self.interactions) do
        i:apply(e1, e2, dir, len)
    end
end

return {
    base    = PhyInteraction,
    spring  = PhySpringInteraction,
    gravity = PhyGravityInteraction,
    fixedDistance = PhyFixedDistanceInteraction,
    callback = CallbackInteraction,
    multi = MultiInteraction
}
