local class = require "lib.middleclass"
local Color = require "lib.color"
local Node = require "node"
local Component = require "component"
local Camera = require "camera"

local GridRenderer = class("GridRenderer")
GridRenderer:include(Component)

function GridRenderer:initialize(gridSize, lineColor, heavyLineColor)
	self.gridSize = gridSize or 20
	self.lineColor = lineColor or Color:new("White")
	self.heavyLineColor = heavyLineColor or Color:new("Green")
end

function GridRenderer:getGridSize()
	return self.gridSize
end

function GridRenderer:setGridSize(gs)
	self.gs = gs
end

function GridRenderer:getLineColor()
	return self.lineColor
end

function GridRenderer:setLineColor(lc)
	self.lineColor = lc
end

function GridRenderer:getHeavyLineColor()
	return self.heavyLineColor
end

function GridRenderer:setHeavyLineColor(hlc)
	self.heavyLineColor = hlc
end

local function _drawGrids(wx, wy, winH, winW, gs)
	local x, y = wx, wy
	while x > 0 do
		love.graphics.line(x, 0, x, winH)
		x = x - gs
	end
	while y > 0 do
		love.graphics.line(0, y, winW, y)
		y = y - gs
	end

	x, y = wx, wy
	while x < winW do
		x = x + gs
		love.graphics.line(x, 0, x, winH)
	end
	while y < winH do
		y = y + gs
		love.graphics.line(0, y, winW, y)
	end
end

-- Override
function GridRenderer:render()
	local mc = Camera.main
	local cameraScale = mc:getScale().x
	local winW, winH = love.window.getWidth(), love.window.getHeight()

	local gs = self.gridSize * cameraScale

	local wx, wy = mc:getPosition():unpack()
	wx, wy = -wx * cameraScale + winW / 2, -wy * cameraScale + winH / 2
	wx, wy = wx % winW, wy % winH

	love.graphics.push()
	love.graphics.origin()

	love.graphics.setLineWidth(1)
	local r, g, b = self.lineColor:unpack()
	love.graphics.setColor(r, g, b, 20)
	_drawGrids(wx, wy, winH, winW, gs)

	love.graphics.setLineWidth(2)
	r, g, b = self.heavyLineColor:unpack()
	love.graphics.setColor(r, g, b, 20)
	_drawGrids(wx, wy, winH, winW, gs * 5)

	love.graphics.pop()
end

return GridRenderer