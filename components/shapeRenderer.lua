local class = require "lib.middleclass"
local Color = require "lib.color"
local Component = require "component"

local ShapeRenderer = class("ShapeRenderer")
ShapeRenderer:include(Component)

function ShapeRenderer:initialize(size, color)
	self.size = size or 100
	self.color = color or Color:new("White")
end

-- Override
function ShapeRenderer:render()
	local r, g, b = self.color:unpack()
	local size = self.size
	local scale = self.node:getScale()
	local segments = math.max(scale.x, scale.y) * size
	
	segments = math.max(segments, 50)
	love.graphics.setLineWidth(1 / math.min(scale.x, scale.y))

	love.graphics.setColor(r, g, b, 100)
	love.graphics.circle('fill', 0, 0, size, segments)
	love.graphics.setColor(r, g, b)
	love.graphics.circle('line', 0, 0, size, segments)
	love.graphics.line(0, 0, 0, -size)
end

return ShapeRenderer