local class = require "lib.middleclass"
local Vector = require "lib.vector"

local min, max, abs = math.min, math.max, math.abs

local PhyInteraction = {}

function PhyInteraction:apply(e1, e2, reinforce)
    local dif = e1:getPosition() - e2:getPosition()
    local len = dif:len()
    dif:normalize_inplace()
    self:applyImpl(e1, e2, dif, len, reinforce)
end

local PhySpringInteraction = class("PhySpringInteraction")
PhySpringInteraction:include(PhyInteraction)

function PhySpringInteraction:initialize(elastic, rest_len, add_len)
    self.elastic = elastic
    self.rest_len = rest_len
    self.add_len = add_len or self.rest_len
end

function PhySpringInteraction:applyImpl(e1, e2, dir, len, reinforce)

    -- if len < min_len then
    --     local e1m, e2m = e1:getMass(), e2:getMass()
    --     local tm = e1m + e2m
    --     local exten = dir * (min_len - len)
    --
    --     e1:applyForce(exten * (e1m / tm))
    --     exten:mul(-1)
    --     e2:applyForce(exten * (e2m / tm))
    --
    --     e1:setVelocity(0, 0)
    --     e2:setVelocity(0, 0)
    -- elseif len > max_len then
    --     local e1m, e2m = e1:getMass(), e2:getMass()
    --     local tm = e1m + e2m
    --     local exten = dir * (len - max_len)
    --
    --     e1:applyForce(exten * (e1m / tm))
    --     exten:mul(-1)
    --     e2:applyForce(exten * (e2m / tm))
    --
    --     e1:setVelocity(0, 0)
    --     e2:setVelocity(0, 0)
    -- end

    local rest_len = self.rest_len
    local x = rest_len + self.add_len * reinforce - len
    local force = dir * (-self.elastic * x)

    e2:applyForce(force)
    force:mul(-1)
    e1:applyForce(force)
end

local PhyGravityInteraction = class("PhyGravityInteraction")
PhyGravityInteraction:include(PhyInteraction)

function PhyGravityInteraction:initialize(coefficient, additive)
    self.coefficient = coefficient or 6.6
    self.additive = additive or self.coefficient
end

function PhyGravityInteraction:applyImpl(e1, e2, dir, len, reinforce)
    if len < 1 then
        return
    end

    local distance = math.max(len, 10)
    local coefficient = self.coefficient + reinforce * self.additive

    local force = dir:clone()
    force:mul(coefficient * (e1.mass * e2.mass) / (distance * distance))

    e2:applyForce(force)
    if not e1:isFixed() then
        force:mul(-1)
        e1:applyForce(force)
    end
end

local PhyFixedDistanceInteraction = class("PhyFixedDistanceInteraction")
PhyFixedDistanceInteraction:include(PhyInteraction)

function PhyFixedDistanceInteraction:initialize(distance, additive)
    self.distance = distance
    self.additive = additive or self.distance
end

function PhyFixedDistanceInteraction:applyImpl(e1, e2, dir, len, reinforce)
    local e1m, e2m = e1:getMass(), e2:getMass()
    local tm = e1m + e2m

    local dis = self.distance + self.additive * reinforce - len
    local vec = dir * abs(dis)

    if dis < 0 then
        e1.position:sub(vec * (e1m / tm))
        vec:mul(-1)
        e2.position:sub(vec * (e2m / tm))
    else
        e1.position:add(vec * (e1m / tm))
        vec:mul(-1)
        e2.position:add(vec * (e2m / tm))
    end
end

local CallbackInteraction = class("CallbackInteraction")
CallbackInteraction:include(PhyInteraction)

function CallbackInteraction:initialize(callback)
    self.callback = callback
end

function CallbackInteraction:apply(e1, e2, dir, len, reinforce)
    self.callback(e1, e2, dir, len, reinforce)
end

local MultiInteraction = class("MultiInteraction")
MultiInteraction:include(PhyInteraction)

function MultiInteraction:initialize(...)
    self.interactions = ...
end

function MultiInteraction:applyImpl(e1, d2, dir, len, reinforce)
    for _, i in pairs(self.interactions) do
        i:applyImpl(e1, e2, dir, len, reinforce)
    end
end

return {
    base    = PhyInteraction,
    spring  = PhySpringInteraction,
    gravity = PhyGravityInteraction,
    fixed = PhyFixedDistanceInteraction,
    callback = CallbackInteraction,
    multi = MultiInteraction
}
