local class = require "lib.middleclass"
local Vector = require "lib.vector"
local Node = require "node"

local cos, sin = math.cos, math.sin

local Camera = class("Camera", Node)

function Camera:initialize()
	Node.initialize(self)
	
	self.cameraRotation = 0
	self.cameraScale = Vector:new(1, 1)
end

function Camera:getCameraRotation()
	return self.cameraRotation
end

function Camera:setCameraRotation(cr)
	if self.cameraRotation == cr then
		return
	end
	self.cameraRotation = cr
end

function Camera:getCameraScale()
	return self.cameraScale
end

function Camera:setCameraScale(csx, csy)
	csy = csy or csx
	if self.cameraScale:equal(csx, csy) then
		return
	end
	self.cameraScale:set(csx, csy)
end

function Camera:pushCameraTransform()
	local x, y = self:getGlobalPosition():unpack()
	local cs = self:getCameraScale()
	local cr = self:getCameraRotation()
	local cx,cy = love.window.getWidth() / (2 * cs.x), love.window.getHeight() / (2 * cs.y)

	love.graphics.push()
	love.graphics.origin()
	
	love.graphics.translate(cx, cy)

	if self:isLocalRotated() then
		love.graphics.rotate(cr)
		love.graphics.translate(-x, -y)
	else
		love.graphics.translate(-x, -y)
		love.graphics.rotate(cr)
	end
	love.graphics.scale(cs.x, cs.y)
end

function Camera:screenPointToWorld(x, y)
	local w,h = love.window.getWidth() / 2, love.window.getHeight() / 2
	local pos = self:getGlobalPosition()
	return x - pos.x, y - pos.y
end

function Camera:worldPointToScreen(x, y)
	local w,h = love.window.getWidth() / 2, love.window.getHeight() / 2
	local pos = self:getGlobalPosition()
	return x + pos.x, y + pos.y
end

local mc = Camera:new()
Camera.static.main = mc

return Camera
