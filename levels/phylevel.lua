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
local PhyFluidResistance = require "GeoEco.Physics.PhyFluidResistance"
local PhyInteractionAppliers = require "GeoEco.Physics.PhyInteractionAppliers"
local PhyRandomForceField = require "GeoEco.Physics.PhyRandomForceField"

local Env = require "GeoEco.Environment"
local Particle = require "GeoEco.Simulation.Particle"
local LifeCode = require "GeoEco.Simulation.LifeCode"
local PtlBehaviours = require "GeoEco.Simulation.PtlBehaviours"
local PtlInteractions = require "GeoEco.Simulation.PtlInteractions"

local PhyLevel = {}

local w, h = 0, 0
local center = Vector:new()
local ghosts = {}

function PhyLevel:init()
end

function PhyLevel:createStructure(num, elastic, rest_len, add_len)
    local group = {}

    local v = math.pi * 2 / num
    local curr = 0
    -- local x = w / 2
    -- local y = h / 2
    local x = lmath.random(0, w)
    local y = lmath.random(0, h)

    for i = 1, num do
        local entity = Env:createParticle(
            Vector:new(x + math.cos(curr) * 10, y + math.sin(curr) * 10), 3,
            "GEPT-ELEM-0001"
        )
        curr = curr + v
        table.insert(group, entity)
    end

    for i = 1, num do
        for j = 1, num do
            if i ~= j then
                Env:createConnection(
                    group[i], group[j],
                    PhyInteractions.spring:new(elastic, rest_len, add_len)
                )
            end
        end
    end
    return group
end

function PhyLevel:createMembrane(num)
    local x = lmath.random(0, w)
    local y = lmath.random(0, h)
    local v = math.pi * 2 / num
    local curr = 0

    local group = {}

    for i = 1, num do
        local entity = Env:createParticle(
            Vector:new(x + math.cos(curr) * 10, y + math.sin(curr) * 10), 1,
            "GEPT-ELEM-0001"
        )
        curr = curr + v
        table.insert(group, entity)
    end

    for i = 1, num - 1 do
        Env:createConnection(
            group[i], group[i+1],
            PhyInteractions.spring(0.01, 5, 20)
        )
    end
    Env:createConnection(
        group[#group], group[1],
        PhyInteractions.spring(0.01, 5, 20)
    )
    return group
end

function PhyLevel:enter()
    w, h = lwindow.getWidth(), lwindow.getHeight()
    center.x = w / 2
    center.y = h / 2

    self.canvas = lgraph.newCanvas(w, h, "normal", 8)
    Env:initWorld(w, h)
    self.attractors = {}

    for i = 1, 0 do
        local x = lmath.random(0, w)
        local y = lmath.random(0, h)
        local mass = lmath.random(5, 10)

        local entity = Env:createParticle(Vector:new(x, y), mass)
        entity:setIsFixed(true)
        -- entity.ghost = true
        self.attractors[i] = entity
    end

    self.attracted = {}

    local log_listener = {
        log = function(self, code, head, msg)
            print(head, msg)
        end
    }

    -- for i = 1, 1 do
    --     local x = lmath.random(0, w)
    --     local y = lmath.random(0, h)
    --     local mass = lmath.random(1000, 1000)
    --
    --     local particle = Env:createParticle(
    --         Vector:new(x, y), mass, "GEPT-ELEM-0000"
    --     )
    --     -- entity.ghost = true
    --     particle:setHeat(1000)
    --
    --     local code = LifeCode:new()
    --     code:setLogListener(log_listener)
    --     code:loadString([[
    --         [CONTROL]
    --         THREAD REGIN_2
    --         MAX_GENERATION 3
    --         CALL REGIN_0
    --
    --         [REGIN_0]
    --         SLEEP 60
    --         __PRODUCE GEPT-ELEM-0002 REGIN_1 10
    --         CONNECT SPRING 0.1 10 5
    --         CALL REGIN_0
    --
    --         [REGIN_1]
    --         SLEEP 120
    --         CALL CONTROL
    --
    --         [REGIN_2]
    --         SLEEP 600
    --         CLEAR_CONNECTIONS
    --         REMOVE_SELF
    --     ]])
    --     code:createThread("CONTROL")
    --     particle:setCode(code)
    -- end

    for i = 1, 00 do
        local x = lmath.random(0, w)
        local y = lmath.random(0, h)
        local mass = lmath.random(1, 1)

        local entity = Env:createParticle(
            Vector:new(x, y), mass, "GEPT-ELEM-0001"
        )
        entity.ghost = true
        table.insert(self.attracted, entityB)
    end

    for i = 1, 10 do
        local elastic = 0.01
        local rest_len = lmath.random(50, 50)
        local add_len = lmath.random(rest_len / 2, rest_len)
        local group = self:createStructure(10, elastic, rest_len, add_len)
        local wait = math.random(0, 60)
        for _, ptl in ipairs(group) do
            local code = LifeCode:new()
            code:loadString([[
                [CONTROL]
                SLEEP ]]..wait.."\n"..[[
                CALL LOOP

                [LOOP]
                SET_PULSE 1
                SLEEP 10
                SET_PULSE 0
                SLEEP 50
                CALL LOOP
            ]])
            code:createThread("CONTROL")
            ptl:setCode(code)
        end
        -- self:createStructure(4)
    end
    for i = 1, 0 do
        self:createMembrane(math.random(5, 20))
    end

    for i = 1, 0 do
        local e1 = self:randomEntity()
        local e2 = self:randomEntity()
        e1.ghost = true
        e2.ghost = true
        Env:createConnection(e1, e2, PhyInteractions.fixedDistance(100))
    end

    -- Env:addComponent(
    --      PhyInteractionApplier:new(
    --         PhyInteractions.gravity:new(100.8),
    --         self.attractors
    --     )
    -- )
    -- Env:addComponent(
    --     PhyInteractionAppliers.global:new(
    --         PtlInteractions.heat_conductive:new(1)
    --     )
    -- )
    Env:addComponent(PhyRandomForceField:new(1, 1))
    Env:addComponent(PhyFluidResistance:new(1, 0.1))

    -- initialize shaders
    self.shader = lgraph.newShader [[
        vec4 effect(vec4 color, Image texture, vec2 texture_coords,
                    vec2 pixel_coords) {
            vec4 texcolor = Texel(texture, texture_coords);
            return texcolor * color - vec4(0, 0, 0, 0.1);
        }
    ]]
end

function PhyLevel:randomEntity()
    local x = lmath.random(0, w)
    local y = lmath.random(0, h)
    local mass = lmath.random(10, 10)
    return self:createEntity(x, y, mass)
end

function PhyLevel:createEntity(x, y, mass)
    local pos = Vector:new(x, y)
    local entity = Env:createEntity(pos, mass)
    return entity
end

function PhyLevel:mousepressed(x, y, button)
    if button ~= "l" then
        local mx, my = lmouse.getX(), lmouse.getY()
        local pos = self.attractors[1].position
        pos.x, pos.y = mx, my
        return
    end

    local mpos = Vector:new(w/2 - lmouse.getX(), h/2 - lmouse.getY())
    mpos:normalize_inplace()
    mpos:mul(-500)

    local entity = Env:createParticle(
        Vector:new(w/2, h/2), 10, "GEPT-ELEM-0003"
    )
    entity:applyForce(mpos)
    entity:setHeat(1000)
    table.insert(ghosts, entity)
end

function drawRect(rect)
    local x, y = rect.ltx, rect.lty
    lgraph.rectangle("line", x, y, rect.rbx - x, rect.rby - y)
end

function drawNode(node)
    drawRect(node.rect)
    for _, child in pairs(node.children) do
        drawNode(child)
    end
end

local frame = 0
local updated = 0

function PhyLevel:update()
    Env:update()
    -- Env:getComponent(PhyRandomForceField):setFrame(ltimer.getTime())
end

function PhyLevel:draw()
    -- visulize the nodes of quadtree
    lgraph.setColor(0, 255, 0, 10)
    drawNode(Env.quadtree.root)

    -- -- display ghost canvas
    -- lgraph.setColor(255, 255, 255, 255)
    -- lgraph.draw(self.canvas)
    --
    -- -- render ghosts
    -- lgraph.setCanvas(self.canvas)
    -- lgraph.setBlendMode("alpha")
    -- lgraph.setColor(255, 255, 255, 255)
    --
    -- for _, entity in pairs(ghosts) do
    --     local pos = entity.position
    --     local lastpos = entity.lastpos
    --     lgraph.line(lastpos.x, lastpos.y, pos.x, pos.y)
    -- end
    --
    -- lgraph.setBlendMode("subtractive")
    -- lgraph.setColor(0, 0, 0, 50)
    -- lgraph.rectangle("fill", 0, 0, w, h)
    --
    -- -- reset
    -- lgraph.setCanvas()

    -- render connections
    lgraph.setBlendMode("additive")
    lgraph.setColor(255, 255, 255, 20)

    for bie, _ in pairs(Env:getConnections()) do
        local eA, eB = bie:getEntityA(), bie:getEntityB()
        local posA, posB = eA.position, eB.position
        -- lgraph.setColor(255, 255, 255, math.min(255, eA:getHeat()))
        lgraph.line(posA.x, posA.y, posB.x, posB.y)
    end

    lgraph.setBlendMode("alpha")
    lgraph.setColor(255, 255, 255, 255)

    -- render entities
    for _, entity in pairs(Env:getEntities()) do
        local pos = entity.position
        -- lgraph.setColor(255, 255, 255, math.min(255, entity:getHeat()))
        lgraph.point(pos.x, pos.y)
    end

    -- render circles for attractors
    for _, attractor in pairs(self.attractors) do
        local pos = attractor.position
        lgraph.circle("line", pos.x, pos.y, 10, 50)
    end

    -- show updating information of quadtree
    lgraph.setColor(255, 255, 255, 255)
    lgraph.print(tostring(Env:getParticleCount())..", "..ltimer.getFPS(), 10, 10)
end

return PhyLevel
