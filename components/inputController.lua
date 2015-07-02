local class = require "lib.middleclass"
local Component = require "component"

local InputController = class("InputController")
InputController:include(Component)

function InputController:initialize(speed, isApplyForce)
	self.speed = speed or 500
	self:setIsApplyForce(isApplyForce or false)
end

function InputController:setSpeed(speed)
	self.speed = speed
end

function InputController:getSpeed()
	return self.speed
end

function InputController:setIsApplyForce(iaf)
	if iaf == false then
		self.update = self._update
	end
end

function InputController:_update(dt)
	local node = self.node
	
	local ischanged = false
	local speed     = self.speed * dt
	local x, y      = node:getPosition():unpack()
	local s, _      = node:getScale():unpack()
	local rotation  = node:getRotation()

	if love.keyboard.isDown("a") then
		x = x - speed
		ischanged = true
	elseif love.keyboard.isDown("d") then
		x = x + speed
		ischanged = true
	end

	if love.keyboard.isDown("s") then
		y = y + speed
		ischanged = true
	elseif love.keyboard.isDown("w") then
		y = y - speed
		ischanged = true
	end
	
	if love.keyboard.isDown("q") then
		rotation = rotation - speed * 0.01
		ischanged = true
	elseif love.keyboard.isDown("e") then
		rotation = rotation + speed * 0.01
		ischanged = true
	end

	if love.keyboard.isDown("-") then
		s = s - speed * 0.01
		ischanged = true
	elseif love.keyboard.isDown("=") then
		s = s + speed * 0.01
		ischanged = true
	end

	if ischanged then
		node:setPosition(x, y)
		node:setRotation(rotation)
		node:setScale(s)
	end
end

-- Override
function InputController:update(dt)
	local body = self.node:getPhyBody()
	local speed = self.speed

	if love.keyboard.isDown("a") then
		body:applyForce(-speed, 0)
	elseif love.keyboard.isDown("d") then
		body:applyForce(speed, 0)
	end
	if love.keyboard.isDown("w") then
		body:applyForce(0, -speed)
	elseif love.keyboard.isDown("s") then
		body:applyForce(0, speed)
	end
end

return InputController