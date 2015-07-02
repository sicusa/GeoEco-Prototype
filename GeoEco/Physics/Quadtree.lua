local class = require "lib.middleclass"
local Rectangle = require "lib.rectangle"

local insert, remove = table.insert, table.remove

local Quadtree = class("Quadtree")

local function createQuadNode(x1, y1, x2, y2, level)
    local node = {}
    node.rect = Rectangle:new(x1, y1, x2, y2)
    node.level = level
    node.children = {}
    node.objects = {}
    return node
end

local function splitNode(node)
    local rect = node.rect
    local ltx, lty = rect.ltx, rect.lty
    local rbx, rby = rect.rbx, rect.rby
    local midx, midy = rect:centerPoint()

    local nlevel = node.level + 1
    node.children[1] = createQuadNode(midx, lty,  rbx,  midy, nlevel)
    node.children[2] = createQuadNode(ltx,  lty,  midx, midy, nlevel)
    node.children[3] = createQuadNode(ltx,  midy, midx, rby,  nlevel)
    node.children[4] = createQuadNode(midx, midy, rbx,  rby,  nlevel)
end

local function getRectQuadrant(node, rect)
    local midx, midy = node.rect:centerPoint()

    if rect.rby < midy then
        if rect.rbx < midx then
            return 2
        elseif rect.ltx > midx then
            return 1
        end
    elseif rect.lty > midy then
        if rect.rbx < midx then
            return 3
        elseif rect.ltx > midx then
            return 4
        end
    end

    return -1
end

local function searchRectInNode(node, rect, func)
    for _, obj in pairs(node.objects) do
        if obj.rect:collidesRect(rect) then
            func(obj)
        end
    end

    if #node.children == 0 or node.subnodesObjectCount == 0 then
        return
    end

    local index = getRectQuadrant(node, rect)
    if index ~= -1 then
        searchRectInNode(node.children[index], rect, func)
    else
        for _, child in pairs(node.children) do
            if child.rect:collidesRect(rect) then
                searchRectInNode(child, rect, func)
            end
        end
    end

    return searched
end

local function foreachObject(node, func)
    local objects = node.objects
    local i = 1
    while i <= #objects do
        local obj = objects[i]
        if func(obj) then
            table.remove(objects, i)
        else
            i = i + 1
        end
    end

    for _, child in pairs(node.children) do
        foreachObject(child, func)
    end
end

local function clearEmptyNodes(node)
    if #node.children == 0 then
        return #node.objects
    end

    local total = 0
    for _, child in pairs(node.children) do
        total = total + clearEmptyNodes(child)
    end

    if total == 0 then
        node.children = {}
        return #node.objects
    end

    return #node.objects + total
end

function Quadtree:initialize(width, height, max_objects, max_levels)
    assert(type(width) == "number", "width must be a number")
    assert(type(height) == "number", "height must be a number")

    self.root = createQuadNode(0, 0, width, height, 0)
    self.max_objects = max_objects or 4
    self.max_levels = max_levels or 6
end

function Quadtree:clearEmptyNodes()
    clearEmptyNodes(self.root)
end

function Quadtree:foreach(func)
    foreachObject(self.root, func)
end

function Quadtree:getObjectQuadrant(object)
    local parent_node = object.parent
    if #parent_node.children == 0 then
        return 5
    end
    return getRectQuadrant(parent_node, object.rect)
end

function Quadtree:insert(rect, data)
    local object = {
        rect = rect, data = data
    }
    return self:__insert(self.root, object)
end

function Quadtree:search(rect, func)
    searchRectInNode(self.root, rect, func)
end

local function insertObject(node, object)
    object.parent = node
    object.quadrant = getRectQuadrant(node, object.rect)
    insert(node.objects, object)
end

function Quadtree:__insert(node, object)
    local objects  = node.objects
    local children = node.children

    if node.level >= self.max_levels or #objects < self.max_objects then
        insertObject(node, object)
        return
    end

    if #children == 0 then
        splitNode(node)
        local i = 1
        while i <= #objects do
            local obj = objects[i]
            local new_index = getRectQuadrant(node, obj.rect)
            if new_index ~= -1 then
                self:__insert(children[new_index], obj)
                remove(objects, i)
            else
                i = i + 1
            end
        end
    end

    local index = getRectQuadrant(node, object.rect)
    if index ~= -1 then
        self:__insert(children[index], object)
        return
    end
    insertObject(node, object)
end

return Quadtree
