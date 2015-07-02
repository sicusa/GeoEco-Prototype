local class = require "lib.middleclass"
local Vector = require "lib.vector"
local Rectangle = require "lib.rectangle"
local Line = require "GeoEco.Geometry.Line"

local PhyEntity = require "GeoEco.Physics.PhyEntity"
local PhyConnection = require "GeoEco.Physics.PhyConnection"
local Quadtree = require "GeoEco.Physics.Quadtree"
local CComponentSupport = require "GeoEco.CComponentSupport"

local insert, remove = table.insert, table.remove

function findAndRemove(t, v)
    for i, x in pairs(t) do
        if x == v then
            remove(t, i)
            return true
        end
    end
    return false
end

local PhyWorld = class("PhyWorld")
PhyWorld:include(CComponentSupport)

function PhyWorld:initialize(width, height)
    self.width = width
    self.height = height
    self.quadtree = Quadtree:new(width, height)
    self.frame_time = 0
    self.empty_nodes_clear_delay = 60

    self.entities = {}

    self.connections = {}
    self.connection_count = 0
    self.removed_cons = {}

    self:initComponentSupport()
end

function PhyWorld:getEntityCount()
    return #self.entities
end

function PhyWorld:createEntity(pos, mass)
    local entity = PhyEntity:new(pos, mass)
    return self:addEntity(entity)
end

function PhyWorld:createConnection(e1, e2, behaviour)
    local con = PhyConnection:new(e1, e2, behaviour)
    return self:addConnection(con)
end

function PhyWorld:addEntity(entity)
    local pos = entity:getPosition()
    local rect = Rectangle:new(pos.x, pos.y, pos.x, pos.y)
    self.quadtree:insert(rect, entity)
    insert(self.entities, entity)
    return entity
end

function PhyWorld:getEntities()
    return self.entities
end

function PhyWorld:addConnection(con)
    con:getEntityA():addConnection(con)
    con:getEntityB():addConnection(con)
    self.connections[con] = true
    self.connection_count = self.connection_count + 1
    return con
end

function PhyWorld:removeConnection(con)
    con:getEntityA():removeConnection(con)
    con:getEntityB():removeConnection(con)
    self.removed_cons[con] = true
end

function PhyWorld:getConnections()
    return self.connections
end

function PhyWorld:getFrameTime()
    return self.frame_time
end

function PhyWorld:getEmptyNodesClearDelay()
    return self.empty_nodes_clear_delay
end

function PhyWorld:setEmptyNodesClearDelay(delay)
    self.empty_nodes_clear_delay = delay
end

function PhyWorld:findAll(rect, func)
    self.quadtree:search(rect, func)
end

function PhyWorld:findAllInRadius(pos, radius, func)
    local x, y = pos.x, pos.y
    local rect = Rectangle:new(x - radius, y - radius, x + radus, y + radus)
    local res = self:searchEntities(rect)
    for _, entity in pairs(res) do
        local dis = Vector.dist(pos, entity:getPosition())
        if dis <= radius then
            func(entity, dis)
        end
    end
end

function PhyWorld:getConnections()
    return self.connections
end

local tmpLine = Line:new(0, 0)
local tmpVec = Vector:new(0, 0)

function PhyWorld:processCollide(con, entity)
    local epos, elastpos = entity:getPosition(), entity:getLastPosition()
    tmpLine:updateParameters(epos, elastpos)

    local intersect = con:intersectionPoint(tmpLine, epos, elastpos, tmpVec)
    if not intersect then
        return
    end

    -- self:invokeComponents("onEntityCollided", entity, con, intersect)
    con:onEntityCollided(entity, intersect)
end

function PhyWorld:update()
    self:updateComponents()
    self:invokeComponents("onUpdate")

    local w, h = self.width, self.height

    local tree = self.quadtree
    local cons = self.connections

    for con, _ in pairs(cons) do
        local e1, e2 = con.entityA, con.entityB
        con:update()

        if con.selfRemoved then
            self:removeConnection(con)
        else
            local rect = con:getBoundedRect()
            tree:search(rect, function(obj)
                local entity = obj.data
                if e1 == entity or e2 == entity then
                    return
                end
                self:processCollide(con, entity)
             end)
        end
    end

    for con, _ in pairs(self.removed_cons) do
        cons[con] = nil
        self.connection_count = self.connection_count - 1
    end
    self.removed_cons = {}

    local ready_to_insert = {}

    tree:foreach(function(obj)
        local entity = obj.data

        if entity.selfRemoved == true then
            findAndRemove(self.entities, entity)
            return true
        end

        entity:update()

        if entity:isFreezed() then
            return false
        end

        entity:checkEdge(0, 0, w, h)
        obj.rect = entity:getBoundedRect()

        if not obj.parent.rect:containsRect(obj.rect)
           or tree:getObjectQuadrant(obj) ~= obj.quadrant then
            insert(ready_to_insert, obj)
            return true
        end

        return false
    end)

    for _, obj in pairs(ready_to_insert) do
        tree:insert(obj.rect, obj.data)
    end

    self.frame_time = self.frame_time + 1
    if self.frame_time % self.empty_nodes_clear_delay == 0 then
        self.quadtree:clearEmptyNodes()
    end
end

return PhyWorld
