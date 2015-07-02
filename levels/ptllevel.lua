require "lib.debug"

local laudio = love.audio
local lfilesys = love.filesystem
local lfont = love.font
local lgraph = love.graphics
local limage = love.image
local ljoystick = love.joystick
local lkeyboard = love.keyboard
local lmath = love.math
local lmouse = love.mouse
local lphy = love.physics
local lsound = love.sound
local lsys = love.system
local lthread = love.thread
local lwindow = love.window
local ltimer = love.timer

local class = require "lib.middleclass"
local GameState = require "lib.gamestate"
local Signal = require "lib.signal"

local Vector = require "lib.vector"
local Rectangle = require "lib.rectangle"
local Color  = require "lib.color"
local Timer  = require "lib.timer"
local Misc   = require "lib.misc"

local PhyEntity = require "GeoEco.Physics.PhyEntity"
local PhyInteractions = require "GeoEco.Physics.PhyInteractions"
local PhyWorld = require "GeoEco.Physics.PhyWorld"
local PhyFluidResistance = require "GeoEco.Physics.PhyFluidResistance"
local PhyInteractionApplier = require "GeoEco.Physics.PhyInteractionApplier"
local PhyRandomForceField = require "GeoEco.Physics.PhyRandomForceField"

local PtlLevel = {}

local w, h = 0, 0
local center = Vector:new()

function PtlLevel:init()
end

function PtlLevel:enter()
    w, h = lwindow.getWidth(), lwindow.getHeight()
    center.x = w / 2
    center.y = h / 2
end

function PtlLevel:update()
end

function PtlLevel:draw()
end

return PtlLevel
