require "lib.template"

local class = require "lib.middleclass"
local Vector = require "lib.vector"

local Node = class("Node")

function Node:initialize()
	self.tag = nil

	self.layers = {}
	self.children = {}
	self.parentNode = nil

	self.components = {}
	self.disabledComponents = {}

	self.anchorPoint = Vector:new()
	self.position = Vector:new()
	self.rotation = 0
	self.localRotated = false
	self.scale = Vector:new(1, 1)

	self.globalPosition = Vector:new()
	self.globalRotation = 0
	self.globalScale = Vector:new(1, 1)
	self.transformDirty = false

	self.visible = true
	self.enabled = true
end

function Node:getInformation()
	local info = {
		"anchorPoint: "..tostring(self.anchorPoint),
		"position:    "..tostring(self:getGlobalPosition()),
		"rotation:    "..tostring(self:getGlobalRotation()),
		"scale:       "..tostring(self:getGlobalScale()),
		"visible:     "..tostring(self.visible),
		"position:    "..tostring(self.enabled)
	}
	return info
end

function Node:getTag()
	return self.tag
end

function Node:setTag(tag)
	if self.tag then
		if self.tag == tag then
			return
		else
			Node.taggedNodes[self.tag][self] = nil
		end
	end

	if tag == nil then
		local nodes = Node.taggedNodes[self.tag]
		nodes[self] = nil
	else
		local nodes = Node.taggedNodes[tag]
		if nodes == nil then
			nodes = {}
			Node.taggedNodes[tag] = nodes
		end

		nodes[self] = true
	end

	self.tag = tag
end

function Node:isVisible()
	return self.visible
end

function Node:setVisible(v)
	if self.visible == v then
		return
	end

	self.visible = v
	if self.enabled == false then
		return
	end

	if v then
		self.render = self.class.render
		self.transformDirty = true
	else
		self.render = self.class._emptyRender
	end
end

function Node:isEnabled()
	return self.enabled
end

function Node:enable()
	if self.enabled then
		return
	end

	self.enabled = true
	self.update = Node.update

	if self.visible then
		self.render = Node.render
		self.transformDirty = true
	end
end

function Node:disable()
	if self.enabled == false then
		return
	end

	self.enabled = false

	self._oldUpdate = self.update
	self._oldRender = self.render

	self.update = Node._emptyUpdate
	self.render = Node._emptyRender
end

function Node:getAnchorPoint()
	return self.anchorPoint
end

function Node:setAnchorPoint(x, y)
	if self.anchorPoint:equal(x, y) then
		return
	end
	self.anchorPoint:set(x, y)
	self.transformDirty = true
end

function Node:getPosition()
	return self.position
end

function Node:setPosition(x, y)
	if self.position:equal(x, y) then
		return
	end
	self.position:set(x, y)
	self.transformDirty = true
end

function Node:getRotation()
	return self.rotation
end

function Node:setRotation(r)
	if self.rotation == r then
		return
	end
	self.rotation = r
	self.transformDirty = true
end

function Node:isLocalRotated()
	return self.localRotated
end

function Node:setLocalRotated(lr)
	if self.localRotated == lr then
		return
	end
	self.localRotated = lr
	self.transformDirty = true
end

function Node:getScale()
	return self.scale
end

function Node:setScale(sx, sy)
	sy = sy or sx

	if self.scale:equal(sx, sy) then
		return
	end

	self.scale:set(sx, sy)
	self.transformDirty = false
end

function Node:updateGlobalTransform(ignoreChildren)
	if self.transformDirty == false then
		return
	end
	self.transformDirty = true

	local parent = self:getParent()
	if parent then
		parent:updateGlobalTransform(true)
		self.globalPosition = self.position:clone() + parent.globalPosition
		self.globalRotation = self.rotation + parent.globalRotation
		self.globalScale = self.scale:clone() * parent.globalScale
	else
		self.globalPosition = self.position:clone()
		self.globalRotation = self.rotation
		self.globalScale = self.scale:clone()
	end

	ignoreChildren = ignoreChildren or false
	if ignoreChildren == false then
		self:updateChildrenGlobalTransform()
	end
end

function Node:updateChildrenGlobalTransform()
	for _, child in ipairs(self.children) do
		child.transformDirty = true
		child:updateGlobalTransform()
	end
end

function Node:handleGlobalTransform()
	local parent = self:getParent()

	if parent and parent.transformDirty then
		parent:updateGlobalTransform()
	elseif self.transformDirty then
		self:updateGlobalTransform()
	end
end

function Node:getGlobalPosition()
	self:handleGlobalTransform()
	return self.globalPosition
end

function Node:setGlobalPosition(x, y)
	if self.globalPosition:equal(x, y) then
		return
	end
	self.globalPosition:set(x, y)

	local parent = self:getParent()

	if parent then
		local gp = parent:getGlobalPosition()
		x, y = x - gp.x, y - gp.y
	end

	self:setPosition(x, y)
	self.transformDirty = false

	self:updateChildrenGlobalTransform()
end

function Node:getGlobalRotation()
	self:handleGlobalTransform()
	return self.globalRotation
end

function Node:setGlobalRotation(r)
	if self.globalRotation == r then
		return
	end
	self.globalRotation = r

	local parent = self:getParent()

	if parent then
		local gr = parent:globalRotation()
		r = r - gr
	end

	self:setRotation(r)
	self.transformDirty = false

	self:updateChildrenGlobalTransform()
end

function Node:getGlobalScale()
	self:handleGlobalTransform()
	return self.globalScale
end

function Node:setGlobalScale(sx, sy)
	if self.globalPosition:equal(sx, sy) then
		return
	end
	self.globalScale:set(sx, sy)

	local parent = self:getParent()

	if parent then
		local gs = parent:getGlobalScale()
		sx, sy = sx / gs.x, sy / gs.y
	end

	self:setScale(sx, sy)
	self.transformDirty = false

	self:updateChildrenGlobalTransform()
end

function Node:getParent()
	return self.parentNode
end

function Node:setParent(node)
	if self.parentNode == node then
		return
	end
	self.parentNode = node
	self.transformDirty = false
end

function Node:childrenCount()
	return #self.children
end

function Node:getChildren()
	return self.children
end

function Node:getLayers()
	return self.layers
end

function Node:addChild(child, layer)
	assert(child == nil or child:isInstanceOf(Node), "Unexpected type: child must be a instance of Node class or nil")

	layer = layer or 0
	if self:onAddChild(child, layer) == false then
		return false
	end

	for i, v in ipairs(self.children) do
		if self.layers[v] >= layer then
			table.insert(self.children, i, child)
			return
		end
	end
	self.children[#self.children+1] = child
end

function Node:onAddChild(child, layer)
	self.layers[child] = layer
	child:setParent(self)
	return true
end

function Node:removeChild(indexOrRef)
	if type(indexOrRef) == "number" then
		assert(indexOrRef <= self:childrenCount(), "Out of range")
		self:onRemoveChild(self.children[indexOrRef])
		table.remove(self.children, indexOrRef)
		return
	end

	for i, v in ipairs(self.children) do
		if v == indexOrRef then
			self:onRemoveChild(indexOrRef)
			table.remove(self.children, i)
			return
		end
	end
end

function Node:onRemoveChild(child)
	child:onRemoved()
	child.setParent(nil)
	self.layers[child] = nil
end

function Node:onRemoved()
	self:clearComponents()
	self:clearChildren()
end

function Node:createChild(layer)
	local newNode = Node:new()
	self:addChild(newNode, layer)
	return newNode
end

function Node:removeSelf()
	local pn = self.parentNode
	if pn then
		pn:removeChild(self)
	else
		self:onRemoved()
	end
end

function Node:clearChildren()
	for _, node in ipairs(self.children) do
		self:onRemoveChild(node)
	end
	self.children = {}
end

function Node:getComponents()
	return self.components
end

function Node:addComponent(c)
	assert(c, "Component is not allowed to be nil")

	if self:onAddComponent(c) == false then
		return
	end

	local name = c.class.name
	assert(self.components[name] == nil, "Registered type of component")
	self.components[name] = c
end

function Node:onAddComponent(c)
	c:onAdded(self)
	return true
end

function Node:getComponent(type)
	return self.components[type]
end

function Node:removeComponent(type)
	local com = self.components[type]
	if com == nil then return end

	self:onRemoveComponent(com)
	self.components[type] = nil
end

function Node:onRemoveComponent(c)
	c:onRemoved()
end

function Node:onComponentEnabled(com)
	self.disabledComponents[com] = nil
	self.components[com.class] = com
end

function Node:onComponentDisabled(com)
	self.disabledComponents[com] = true
	self.components[com.class] = nil
end

function Node:clearComponents()
	for _, com in pairs(self.components) do
		self:onRemoveComponent(com)
	end
	for _, com in pairs(self.disabledComponents) do
		self:onRemoveComponent(com)
	end
	self.components = {}
	self.disabledComponents = {}
end

function Node:localPointToGlobal(x, y)
	local wp = self:getGlobalPosition()
	return x + wp.x, y + wp.y
end

function Node:worldPointToLocal(x, y)
	local wp = self:getGlobalPosition()
	return x - wp.x, y - wp.y
end

function Node:_emptyRender()
end

function Node:pushTranslateAndRotation()
	local pos = self.position

	if self:isLocalRotated() then
		love.graphics.rotate(self.rotation)
		love.graphics.translate(pos.x, pos.y)
	else
		love.graphics.translate(pos.x, pos.y)
		love.graphics.rotate(self.rotation)
	end
end

function Node:pushTransform()
	local scale = self.scale
	love.graphics.push()

	self:pushTranslateAndRotation()
	love.graphics.scale(scale.x, scale.y)
end

function Node:pushOriginalTransform()
	local scale = self.scale

	love.graphics.push()
	love.graphics.origin()

	self:pushTranslateAndRotation()

	love.graphics.scale(scale.x, scale.y)
end

function Node:popTransform()
	love.graphics.pop()
end

function Node:render()
	self:pushTransform()
	self:onRender()
	self:popTransform()
end

function Node:onRender()
	for _, com in pairs(self.components) do
		com:render()
	end
	for _, v in ipairs(self.children) do
		v:render()
	end
end

function Node:_emptyUpdate(dt)
end

function Node:update(dt)
	for _, com in pairs(self.components) do
		com:update(dt)
	end
	for _, v in ipairs(self.children) do
		v:update(dt)
	end
end

Node.static.root = Node:new()
Node.static.taggedNodes = {}

function Node.static:getNodeByTag(tag)
	local nodes = Node.taggedNodes[tag]
	for node, _ in pairs(nodes) do
		return node
	end
end

function Node.static:getNodesByTag(tag)
	local tags = {}
	local nodes = Node.taggedNodes[tag]
	for node, _ in pairs(nodes) do
		tags[#tags+1] = node
	end

	return tags
end

return Node
