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

local Line = require "GeoEco.Geometry.Line"

local Vector = require "lib.vector"
local Rectangle = require "lib.rectangle"
local Color  = require "lib.color"
local Timer  = require "lib.timer"
local Misc   = require "lib.misc"

local GeoLevel = {}

function GeoLevel:init()
    self.lp1 = Vector:new(10, 50)
    self.lp2 = Vector:new(700,600)
    self.mousePos = Vector:new(0, 0)
    self.line = Line:fromPoints(self.lp1, self.lp2)
    self:updateIntersectionPoint()
end

function GeoLevel:updateIntersectionPoint()
    local ip = Line:intersectionPoint(self.line, self.line:perpendicularLine(self.mousePos))
    local x, y = ip.x, ip.y
    local lp1, lp2 = self.lp1, self.lp2

    if lp1.x > x or lp1.y > y then
        self.ip = lp1
        return
    elseif lp2.x < x or lp2.y < y then
        self.ip = lp2
        return
    end

    self.ip = ip
end

function GeoLevel:enter()
end

function GeoLevel:update()
    local mousePos = self.mousePos
    mousePos.x, mousePos.y = lmouse.getX(), lmouse.getY()
    self:updateIntersectionPoint()
end

function GeoLevel:mousepressed(x, y, button)
end

function GeoLevel:draw()
    local lp1, lp2 = self.lp1, self.lp2
    local mpos = self.mousePos
    local ip = self.ip

    lgraph.line(lp1.x, lp1.y, lp2.x, lp2.y)
    lgraph.line(mpos.x, mpos.y, ip.x, ip.y)
end

return GeoLevel
