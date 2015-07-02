local class = require "lib.middleclass"
local Component = require "component"
local Node = require "node"

local PhysicalWorld = class("PhysicalWorld")
PhysicalWorld:include(Component)

-- Override
function PhysicalWorld:onAdded(node)
	Component.onAdded(self, node)

	self.world = love.physics.newWorld(0, 0, true)
	node.getWorld = function(n)
		return self.world
	end
end

-- Override
function PhysicalWorld:onRemoved()
	node.getWorld = nil
end

function PhysicalWorld:getWorld()
	return self.world
end

-- Override
function PhysicalWorld:update(dt)
	self.world:update(dt)
end

PhysicalWorld.static.main = PhysicalWorld:new()

function PhysicalWorld.static:initMainWorld()
	local pw = PhysicalWorld.main
	if pw:getNode() == nil then
		Node.root:addComponent(pw)
	end
end

function PhysicalWorld.static:pixelToMeter(p)
	return p / love.physics.getMeter()
end

function PhysicalWorld.static:meterToPixel(m)
	return m * love.physics.getMeter()
end

return PhysicalWorld