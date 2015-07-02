require "lib.debug"

local class = require "lib.middleclass"

local Node = require "node"
local Camera = require "camera"

local GameState = require "lib.gamestate"
local Vector2 = require "lib.vector"
local Color = require "lib.color"
local Timer = require "lib.timer"
local Misc = require "lib.misc"

local ShapeRenderer = require "components.shapeRenderer"
local ParticleRenderer = require "components.particleRenderer"
local Orbiter = require "components.orbiter"
local Rotator = require "components.rotator"
local Scaler = require "components.scaler"
local GridRenderer = require "components.gridRenderer"
local InputController = require "components.inputController"
local LookAt = require "components.lookAt"
local Follow = require "components.follow"
local PhysicalWorld = require "components.physicalWorld"
local Physics = require "components.physics"

local TestLevel = {}

local largeFont = love.graphics.newFont("assets/fonts/GeosansLight.ttf", 25)
local agencyFont = love.graphics.newFont("assets/fonts/agency.ttf", 25)
local codeFont = love.graphics.newFont("assets/fonts/SourceCodePro-Regular.ttf", 15)
local codeLightFont = love.graphics.newFont("assets/fonts/SourceCodePro-Light.ttf", 15)
local ischanged = false

local rootNode = Node.root
local mainCamera = Camera.main

local function createParticle()
	-- created from hit.psi
	
	local img = love.graphics.newImage("assets/images/star1.png")
	local ps = love.graphics.newParticleSystem( img, 500 )

	ps:setEmissionRate( 60 )
	ps:setEmitterLifetime( -1 ) -- forever
	ps:setParticleLifetime( 0.31746, 0.952381 )
	ps:setDirection( -1.5708 )

	ps:setSpread( 6.28319 )
	-- ps:setRelative( false )
	ps:setSpeed( 166.667, 300 )
	ps:setLinearAcceleration( 0, 0 )
	ps:setRadialAcceleration( -71.4286, -71.4286 )
	ps:setTangentialAcceleration( 0, 0 )
	ps:setSizes( 0.988839, 0.301339 )
	ps:setSizeVariation( 0 )
	ps:setSpin( 19.8413, 19.8413, 0.52381 )
	ps:setColors( 24, 204, 91, 255, 105, 40, 226, 72 )
	-- ps:setColorVariation( 0.206349 )
	-- ps:setAlphaVariation( 0 )

	return ps
end

local function createParticle2()
   -- created from save_demo.psi

    local img = love.graphics.newImage("assets/images/star2.png")
    local ps = love.graphics.newParticleSystem(img, 500)

    ps:setEmissionRate(200)
    ps:setEmitterLifetime(-1) -- forever
    ps:setParticleLifetime(0.15873, 0.634921)
    ps:setDirection(-1.5708)
    ps:setSpread(6.28319)
    -- ps:setRelative(false)
    ps:setSpeed(0, 0)
    ps:setLinearAcceleration(-28.5714, 0)
    ps:setRadialAcceleration(0, 0)
    ps:setTangentialAcceleration(0, 0)
    ps:setSizes(1.5, 0.2)
    ps:setSizeVariation( 0.357143)
    ps:setSpin(-0.158731, -0.158731, 0)
    ps:setColors(255, 255, 255, 255, 85, 40, 200, 0)
    -- ps:setColorVariation( 0.277778 )
    -- ps:setAlphaVariation( 0.880952 )

    return ps
end

local function createParticle3()
   -- created from save_demo.psi

    local img = love.graphics.newImage("assets/images/star2.png")
    local ps = love.graphics.newParticleSystem(img, 5000)

    ps:setEmissionRate(100)
    ps:setEmitterLifetime(-1) -- forever
    ps:setParticleLifetime(--[[2]] 2)
    ps:setDirection(4.71239)
    ps:setSpread(6.28319)
    -- ps:setRelative(false)
    ps:setSpeed(-0.158731, -0.158731)
    --ps:setLinearAcceleration(-0.476191, -0.476191)
    ps:setRadialAcceleration( -7.61905, -0.476191 )
    ps:setTangentialAcceleration( -0.476191, 0 )
    ps:setSizes( 0.767857, 0.178571 )
    ps:setSizeVariation( 0.468254 )
    ps:setSpin( -0.793652, 6.34921, 0.460317 )
    ps:setColors( 44, 157, 42, 236, 149, 210, 147, 0 )
    -- ps:setColorVariation( 0.190476 )
    -- ps:setAlphaVariation( 0.468254 )

    return ps
end

local sunr = 200

local function _addStar(parent, r, dis, op, sp, color)
	local sop = 360 / (op / 365) / 20
	local ssp = 360 / (sp / 365) / 20

	local star = parent:createChild()
	star:addComponent(ShapeRenderer:new(r / 4, color))
	star:addComponent(Orbiter:new(sop * Misc.deg2rad, sunr * 2 + dis * 149))
	star:addComponent(Rotator:new(ssp * Misc.deg2rad))

	return star
end

function TestLevel:init()
	PhysicalWorld:initMainWorld()
	PhysicalWorld.main:getWorld():setGravity(0, 0)

	local sun = rootNode:createChild()
	sun:setPosition(0, 0)
	sun:addComponent(ShapeRenderer:new(100, Color:new("BeachSand")))
	sun:addComponent(Physics:new({
		shape = "circle",
		radius = 1.0
	}))
	
	local earth = sun:createChild()
	earth:setPosition(0, 0)
	earth:addComponent(ShapeRenderer:new(20, Color:new("Blue")))
	earth:addComponent(Orbiter:new(2, 200))
	
	local moon = earth:createChild()
	local particleRenderer = ParticleRenderer:new(createParticle3())
	moon:addComponent(particleRenderer)
	moon:addComponent(Orbiter:new(9, 50))

	rootNode:addComponent(GridRenderer:new(30))

	rootNode:addChild(mainCamera, 100000)
	mainCamera:setPosition(100, 0)
	mainCamera:addComponent(InputController:new(20, true))
	mainCamera:addComponent(ShapeRenderer:new(5, Color:new("Red")))
end

function TestLevel:enter()
end

function TestLevel:draw()
	love.graphics.setFont(codeFont)
	love.graphics.setColor(255, 255, 255, 255)

	local iy = 25
	local info = mainCamera:getInformation()
	for _, k in pairs(info) do
		love.graphics.print(k, 30, iy)
		iy = iy + 25
	end
	love.graphics.print(love.timer.getFPS(), 30, 0)
	
	mainCamera:pushCameraTransform()
	rootNode:render()
	mainCamera:popTransform()
end

function TestLevel:update(dt)
	rootNode:update(dt)
end

return TestLevel
