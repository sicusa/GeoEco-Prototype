local class = require "lib.middleclass"
local Color = require "lib.color"
local Component = require "component"

local Rotator = class("Rotator")
Rotator:include(Component)

function Rotator:initialize(speed)
	self.speed = speed or 0
end

function Rotator:getSpeed()
	return self.speed
end

function Rotator:setSpeed(speed)
	self.speed = speed
end

-- Override
function Rotator:update(dt)
	local node = self.node
	node:setRotation(node.rotation + dt * self.speed)
end

return Rotator
