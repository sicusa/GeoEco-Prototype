local class  = require "lib.middleclass"
local Vector = require "lib.vector"
local Rectangle = require "lib.rectangle"

local PhyEntity = class("PhyEntity")

function PhyEntity:initialize(pos, mass)
    self.position = pos or Vector:new(0, 0)
    self.lastpos = self.position:clone()
    self.mass = mass or 1

    self.velocity = Vector:new()
    self.acceleration = Vector:new()

    self.connections = {}
    self.connection_count = 0

    self.self_removed = false
    self.fixed = false
    self.freezed = false
end

function PhyEntity:getLastPosition()
    return self.lastpos
end

function PhyEntity:getPosition()
    return self.position
end

function PhyEntity:setPosition(x, y)
    local pos = self.position
    pos.x = x
    pos.y = y
end

function PhyEntity:getMass()
    return self.mass
end

function PhyEntity:setMass(mass)
    self.mass = mass
end

function PhyEntity:getVelocity()
    return self.velocity
end

function PhyEntity:setVelocity(x, y)
    local velocity = self.velocity
    velocity.x = x
    velocity.y = y
    self.freezed = false
end

function PhyEntity:getAcceleration()
    return self.acceleration
end

function PhyEntity:setAcceleration(x, y)
    local acc = self.acceleration
    acc.x = x
    acc.y = y
    self.freezed = false
end

function PhyEntity:isFreezed()
    return self.freezed
end

function PhyEntity:setIsFreezed(freezed)
    self.freezed = freezed
end

function PhyEntity:setIsFixed(fixed)
    if self.fixed == fixed then
        return
    end
    self.fixed = fixed
    self.acceleration:set(0, 0)
    self.velocity:set(0, 0)
end

function PhyEntity:isFixed()
    return self.fixed
end

function PhyEntity:removeSelf()
    self.self_removed = true
end

function PhyEntity:addConnection(con)
    self.connections[con] = true
    self.connection_count = self.connection_count + 1
end

function PhyEntity:removeConnection(con)
    self.connections[con] = false
    self.connection_count = self.connection_count - 1
end

function PhyEntity:getConnections()
    return self.connections
end

function PhyEntity:getConnectionCount()
    return self.connection_count
end

function PhyEntity:applyForce(force)
    self.acceleration:add(force / self.mass)
    self.freezed = false
end

function PhyEntity:applyResistance(force_mag)
    if self.freezed then
        return
    end

    local v = force_mag / self.mass
    local velocity = self.velocity
    local vlen = velocity:len()
    if v > vlen then
        velocity.x = 0
        velocity.y = 0
    else
        v = vlen - v
        velocity:normalize_inplace()
        velocity:mul(v)
    end
end

function PhyEntity:update()
    if self.freezed or self.fixed then
        return
    end

    local acc = self.acceleration
    local vel = self.velocity

    vel:add(acc)
    acc:set(0, 0)

    local pos = self.position
    local lastpos = self.lastpos

    pos:add(vel)

    if pos == lastpos then
        self.freezed = true
        return
    end

    lastpos:set(pos.x, pos.y)
end

function PhyEntity:getBoundedRect()
    local pos = self.position
    return Rectangle:new(pos.x, pos.y, pos.x, pos.y)
end

function PhyEntity:circulatedEdge(ex, ey, ew, eh)
    local x, y = self.position:unpack()
    if x > ew then
        self.position.x = 0
    elseif x < ex then
        self.position.x = ew
    end
    if y > eh then
        self.position.y = 0
    elseif y < ex then
        self.position.y = eh
    end
end

local absorb_factor = 0.1

function PhyEntity:checkEdge(ex, ey, ew, eh)
    local x, y = self.position:unpack()
    local vel = self.velocity
    if x > ew then
        self.position.x = ew
        -- self:setVelocity(0, 0)
        vel.x = -vel.x * absorb_factor
    elseif x < ex then
        self.position.x = 0
        -- self:setVelocity(0, 0)
        vel.x = -vel.x * absorb_factor
    end
    if y > eh then
        self.position.y = eh
        -- self:setVelocity(0, 0)
        vel.y = -vel.y * absorb_factor
    elseif y < ex then
        self.position.y = 0
        -- self:setVelocity(0, 0)
        vel.y = -vel.y * absorb_factor
    end
end

function PhyEntity:checkCircle(cirpos, r)
    local pos = self.position
    pos:sub(cirpos)

    if pos:len() > r then
        self:setVelocity(0, 0)
        pos:normalize_inplace(5)
        pos:mul(r)
    end
    pos:add(cirpos)
end

return PhyEntity
