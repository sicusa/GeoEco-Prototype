local class = require "lib.middleclass"
local Component = require "component"
local EventListener = require "components.eventListener"

local Scaler = class("Scaler", EventListener)

-- Override
function Scaler:onAdded(node)
	EventListener.onAdded(self, node)

	self.times = 0
	self.bigger = true
	self.step = 0.05
	self.defstep = 0.05

	self:registerCallback("mousepressed", function(x, y, button)
		if button == "wd" and self.times == 0 then
			self.times = 5
			self.bigger = true
		elseif button == "wu" and self.times == 0 then
			self.times = 5
			self.bigger = false
		end
	end)
end

-- Override
function Scaler:update(dt)
	if self.times ~= 0 then
		local node = self.node
		local scale = node:getScale()

		if self.bigger then
			if scale < 1.25 then node:setScale(scale + 0.05) end
		elseif scale > 0.25 then
			node:setScale(scale - 0.05)
		end
		self.times = self.times - 1
	end
end

return Scaler
