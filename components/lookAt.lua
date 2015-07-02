local class = require "lib.middleclass"
local VectorLight = require "lib.vector-light"
local Misc = require "lib.misc"
local Component = require "component"

local LookAt = class("LookAt")
LookAt:include(Component)

function LookAt:initialize(lookat)
	assert(lookat, "Unexpected type: lookat is not allowed to be nil")
	self.lookat = lookat
end

function LookAt:lookAt(lookat)
	self.lookat = lookat
end

function LookAt:getLookAt()
	return self.lookat
end

-- Override
function LookAt:update(dt)
	local x, y = self.node:getGlobalPosition():unpack()
	local lax, lay = self.lookat:getGlobalPosition():unpack()
	self.node:setWorldRotation(VectorLight.angleTo(x, y, lax, lay) - 90 * Misc.deg2rad)
end

return LookAt