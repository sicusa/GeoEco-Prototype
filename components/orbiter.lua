local class = require "lib.middleclass"
local Component = require "component"

local Orbiter = class("Orbiter")
Orbiter:include(Component)

function Orbiter:initialize(speed, distance)
	self.speed = speed
	self.dist = distance
	self.angle = 0
	self.posX, self.posY = 0, 0
end

function Orbiter:getSpeed()
	return self.speed
end

function Orbiter:setSpeed(speed)
	self.speed = speed
end

function Orbiter:getDistance()
	return self.dict
end

function Orbiter:setDistance(dist)
	self.dist = dist
end

function Orbiter:getAngle()
	return self.angle
end

function Orbiter:setAngle(angle)
	self.angle = angle
end

-- Override
function Orbiter:onAdded(node)
	Component.onAdded(self, node)
	self.posX, self.posY = node:getPosition():unpack()
end

-- Override
function Orbiter:update(dt)
	local angle = self.angle
	local dist  = self.dist

	self.angle = angle + self.speed * dt

	local x, y = math.sin(angle), -math.cos(angle)
	self.node:setPosition(self.posX + x * dist, self.posY + y * dist)
end

return Orbiter
