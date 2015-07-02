local class = require "lib.middleclass"
local Component = require "component"
local PhysicalWorld = require "components.physicalWorld"

local Physics = class("Physics")
Physics:include(Component)

Physics.static.shapeHandler = {
	circle = {
		creator = function(node, shapeInfo)
			return love.physics.newCircleShape(shapeInfo.radius)
		end,
		remover = function(node)

		end
	},
	rectangle = function(node, shapeInfo)
		
	end
}

function Physics:initialize(shapeInfo, density, bodyType)
	self.shapeInfo = shapeInfo
	self.shapeHandler = Physics.shapeHandler[self.shapeInfo.shape or "circle"]
	self.density = density or 1
	self.bodyType = bodyType or "dynamic"
end

-- Override
function Physics:onAdded(node)
	Component.onAdded(self, node)

	local pos = node:getPosition()
	self.phyBody = love.physics.newBody(PhysicalWorld.main:getWorld(), pos.x, pos.y, self.bodyType)
	self.phyShape = self.shapeHandler.creator(node, self.shapeInfo)
	self.phyFixture = love.physics.newFixture(self.phyBody, self.phyShape, self.density)
	self.phyFixture:setUserData(self)

	self.old_setPosition = node.setPosition
	self.old_setRotation = node.setRotation

	node.setPosition = function(n, x, y)
		self.old_setPosition(n, x, y)
		self.phyBody:setPosition(n:getPosition():unpack())
	end

	node.setWorldPosition = function(n, x, y)
		self.old_setGlobalPosition(n, x, y)
		self.phyBody:setPosition(x, y)
	end

	node.setRotation = function(n, r)
		self.old_setRotation(n, r)
		n:updateWorldTransform()
		self.phyBody:setAngle(n:getRotation())
	end

	node.setWorldRotation = function(n, r)
		self.old_setRotation(n, r)
		self.phyBody:setAngle(r)
	end

	function node.getPhyBody(n)
		return self.phyBody
	end

	function node.getPhyShape(n)
		return self.phyShape
	end

	function node.getPhyFixture(n)
		return self.phyFixture
	end
end

-- Override
function Physics:onRemoved()
	local node = self.node
	node.setPosition = self.old_setPosition
	node.setRotation = self.old_setRotation

	self.old_setPosition = nil
	self.old_setRotation = nil
end

function Physics:getPhyBody()
	return self.phyBody
end

function Physics:getPhyShape()
	return self.phyShape
end

function Physics:getPhyFixture()
	return self.phyFixture
end

-- Override
function Physics:update(dt)
	local phyBody = self.phyBody

	if phyBody and phyBody:isActive() then
		local x, y = phyBody:getPosition()
		self.old_setPosition(self.node, x, y)
		self.old_setRotation(self.node, phyBody:getAngle())
	end
end

return Physics