local class = require "lib.middleclass"
local Line = require "GeoEco.Geometry.Line"
local Rectangle = require "lib.rectangle"

local PhyConnection = class("PhyConnection")
local sqrt, abs = math.sqrt, math.abs

function PhyConnection:initialize(entityA, entityB, interaction)
    self.entityA = entityA
    self.entityB = entityB
    self.interaction = interaction

    self.bounded_rect_dirty = true
    self.line_info_dirty = false

    self.line = Line:fromPoints(entityA:getPosition(), entityB:getPosition())
    self.self_removed = false
end

function PhyConnection:getEntityA()
    return self.entityA
end

function PhyConnection:getEntityB()
    return self.entityB
end

function PhyConnection:setEntityA(entity)
    self.entityA = entity
end

function PhyConnection:setEntityB(entity)
    self.entityB = entity
end

function PhyConnection:getInteraction()
    return self.interaction
end

function PhyConnection:setInteraction(i)
    self.interaction = i
end

function PhyConnection:update()
    local eA, eB = self.entityA, self.entityB
    self.interaction:apply(eA, eB)
    self.bounded_rect_dirty = true
    self.line_info_dirty = true
end

function PhyConnection:getBoundedRect()
    if self.bounded_rect_dirty then
        local posA, posB = self.entityA:getPosition(), self.entityB:getPosition()
        self.boundedRect = Rectangle:fromPoints(posA, posB)
        self.bounded_rect_dirty = false
    end
    return self.boundedRect
end

function PhyConnection:updateLineInfo()
    local posA, posB = self.entityA:getPosition(), self.entityB:getPosition()
    self.line:updateParameters(posA, posB)
end

function PhyConnection:getLine()
    if self.line_info_dirty then
        self:updateLineInfo()
        self.line_info_dirty = false
    end
    return self.line
end

function PhyConnection:removeSelf()
    self.self_removed = true
end

function PhyConnection:onEntityCollided(entity, intersect)
    -- empty event
end

function PhyConnection:distanceToPoint(v)
    local line = self:getLine()
    local posA, posB = self.entityA:getPosition(), self.entityB:getPosition()
    return line:distanceToPointRestricted(v, posA, posB)
end

function PhyConnection:intersectionPoint(line, v1, v2, out_vec)
    local sl = self:getLine()
    local posA, posB = self.entityA:getPosition(), self.entityB:getPosition()

    local r1 = sl.a * v1.x + sl.k - v1.y
    local r2 = sl.a * v2.x + sl.k - v2.y

    if (r1 > 0 and r2 > 0) or (r1 < 0 and r2 < 0) then
        return false
    end

    r1 = line.a * posA.x + line.k - posA.y
    r2 = line.a * posB.x + line.k - posB.y

    if (r1 > 0 and r2 > 0) or (r1 < 0 and r2 < 0) then
        return false
    end

    local vec = Line:intersectionPoint(sl, line)
    out_vec.x = vec.x
    out_vec.y = vec.y
    return true
end

return PhyConnection
