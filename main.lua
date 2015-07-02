local GameState = require "lib.gamestate"
local Signal = require "lib.signal"

local TestLevel = require "levels.testlevel"
local PhyLevel  = require "levels.phylevel"
local GeoLevel  = require "levels.geolevel"

-- require "lib.lovedebug"

function love.load()
	if arg[#arg] == "-debug" then require("mobdebug").start() end
	
	local isWindow = true

	if isWindow then
		love.window.setMode(1024, 768, {
			resizable	= false,
			vsync		= true,
			minwidth	= 400,
			minheight	= 300,
			fsaa		= 8
		})
	else
		love.window.setMode(1920, 1080, {
			resizable	= false,
			vsync		= true,
			minwidth	= 400,
			minheight	= 300,
			fsaa		= 8,
			fullscreen = true
		})
	end
	love.graphics.setBackgroundColor(39,39,39)

	GameState.registerEvents()
    GameState.switch(PhyLevel)

    -- SoundTrigger.loadSounds()
    -- SoundTrigger.enable()
end

function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.quit()
	end
	Signal.emit("keypressed", key, unicode)
end

function love.keyreleased(key)
	Signal.emit("keyreleased", key)
end

function love.mousepressed(x, y, button)
	Signal.emit("mousepressed", x, y, button)
end

function love.mousereleased(x, y, button)
	Signal.emit("mousereleased", x, y, button)
end

function love.joystickpressed(joystick, button)
	Signal.emit("joystickpressed", joystick, button)
end

function love.joystickreleased(joystick, button)
	Signal.emit("joystickreleased", joystick, button)
end
