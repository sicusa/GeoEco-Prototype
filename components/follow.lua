local class = require "lib.middleclass"
local Vector = require "lib.vector"
local Component = require "component"
local Node = require "node"

local Follow = class("Follow")
Follow:include(Component)

function Follow:initialize(follow)
	assert(follow, "Unexpected type")
	self.follow = follow
	self.lastPos = Vector:new()
end

function Follow:follow(follow)
	self.follow = follow
end

function Follow:getFollow()
	return self.follow
end

-- Override
function Follow:update(dt)
	local pos = self.follow:getGlobalPosition()
	
	if (self.lastPos:equal(pos.x, pos.y) == false) then
		self.node:setGlobalPosition(pos.x, pos.y)
	end
end

return Follow