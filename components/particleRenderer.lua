local class = require "lib.middleclass"
local Component = require "component"
local Camera = require "camera"

local ParticleRenderer = class("ParticleRenderer")
ParticleRenderer:include(Component)

function loadPSFile(name, image)
    local ps_data = require(name)
    local particle_settings = {}
    particle_settings["colors"] = {}
    particle_settings["sizes"] = {}
    for k, v in pairs(ps_data) do
        if k == "colors" then
            local j = 1
            for i = 1, #v , 4 do
                local color = {v[i], v[i+1], v[i+2], v[i+3]}
                particle_settings["colors"][j] = color
                j = j + 1
            end
        elseif k == "sizes" then
            for i = 1, #v do particle_settings["sizes"][i] = v[i] end
        else particle_settings[k] = v end
    end
    local ps = love.graphics.newParticleSystem(image, particle_settings["buffer_size"])
    ps:setAreaSpread(string.lower(particle_settings["area_spread_distribution"]), particle_settings["area_spread_dx"] or 0 , particle_settings["area_spread_dy"] or 0)
    ps:setBufferSize(particle_settings["buffer_size"] or 1)
    local colors = {}
    for i = 1, 8 do 
        if particle_settings["colors"][i][1] ~= 0 or particle_settings["colors"][i][2] ~= 0 or particle_settings["colors"][i][3] ~= 0 or particle_settings["colors"][i][4] ~= 0 then
            table.insert(colors, particle_settings["colors"][i][1] or 0)
            table.insert(colors, particle_settings["colors"][i][2] or 0)
            table.insert(colors, particle_settings["colors"][i][3] or 0)
            table.insert(colors, particle_settings["colors"][i][4] or 0)
        end
    end
    ps:setColors(unpack(colors))
    ps:setColors(unpack(colors))
    ps:setDirection(math.rad(particle_settings["direction"] or 0))
    ps:setEmissionRate(particle_settings["emission_rate"] or 0)
    ps:setEmitterLifetime(particle_settings["emitter_lifetime"] or 0)
    ps:setInsertMode(string.lower(particle_settings["insert_mode"]))
    ps:setLinearAcceleration(particle_settings["linear_acceleration_xmin"] or 0, particle_settings["linear_acceleration_ymin"] or 0, 
                             particle_settings["linear_acceleration_xmax"] or 0, particle_settings["linear_acceleration_ymax"] or 0)
    if particle_settings["offsetx"] ~= 0 or particle_settings["offsety"] ~= 0 then
        ps:setOffset(particle_settings["offsetx"], particle_settings["offsety"])
    end
    ps:setParticleLifetime(particle_settings["plifetime_min"] or 0, particle_settings["plifetime_max"] or 0)
    ps:setRadialAcceleration(particle_settings["radialacc_min"] or 0, particle_settings["radialacc_max"] or 0)
    ps:setRotation(math.rad(particle_settings["rotation_min"] or 0), math.rad(particle_settings["rotation_max"] or 0))
    ps:setSizeVariation(particle_settings["size_variation"] or 0)
    local sizes = {}
    local sizes_i = 1 
    for i = 1, 8 do 
        if particle_settings["sizes"][i] == 0 then
            if i < 8 and particle_settings["sizes"][i+1] == 0 then
                sizes_i = i
                break
            end
        end
    end
    if sizes_i > 1 then
        for i = 1, sizes_i do table.insert(sizes, particle_settings["sizes"][i] or 0) end
        ps:setSizes(unpack(sizes))
    end
    ps:setSpeed(particle_settings["speed_min"] or 0, particle_settings["speed_max"] or 0)
    ps:setSpin(math.rad(particle_settings["spin_min"] or 0), math.rad(particle_settings["spin_max"] or 0))
    ps:setSpinVariation(particle_settings["spin_variation"] or 0)
    ps:setSpread(math.rad(particle_settings["spread"] or 0))
    ps:setTangentialAcceleration(particle_settings["tangential_acceleration_min"] or 0, particle_settings["tangential_acceleration_max"] or 0)
    return ps
end

function ParticleRenderer:initialize(ps, blendMode, simulationSpace)
	if type(ps) == "table" then
		self:setParticleSystem(loadPSFile(ps[1], love.graphics.newImage(ps[2])))
	else
		self:setParticleSystem(ps)
	end
	
	self.blendMode = blendMode or "additive"
	self.simulationSpace = simulationSpace or "world"

	self.emitDelay = 0
	self.delayTimer = 0
end

function ParticleRenderer:getEmitDelay()
	return self.emitDelay
end

function ParticleRenderer:setEmitDelay(d)
	self.emitDelay = d
	if d ~= 0 then
		self.render = self.class.render
		self.update = self.class.update
	end
end

function ParticleRenderer:getParticleSystem()
	return self.ps
end

function ParticleRenderer:setParticleSystem(ps)
	assert(ps, "Particle System is not allowed to be nil!")
	self.ps = ps
end

function ParticleRenderer:getBlendMode()
	return self.blendMode
end

function ParticleRenderer:setBlendMode(bm)
	assert(bm == "additive" or bm == "alpha", "The Blend mode can only be set as 'additive' or 'alpha'")
	self.blendMode = bm
end

function ParticleRenderer:getSimulationSpace()
	return self.simulationSpace
end

function ParticleRenderer:setSimulationSpace(ss)
	assert(ss == "world" or ss == "local", "The simulation space can only be set as 'world' or 'local'")
	self.simulationSpace = ss
	self:_setRenderFuncBySS()
end

-- Override
function ParticleRenderer:onAdded(node)
	Component.onAdded(self, node)
	self.ps:setPosition(self.node:getGlobalPosition():unpack())
end

function ParticleRenderer:_renderWorldSpace()
	local mc = Camera.main

	mc:pushCameraTransform()
	self.ps:setPosition(self.node:getGlobalPosition():unpack())
	self:_renderLocalSpace()
	mc:popTransform()
end

function ParticleRenderer:_renderLocalSpace()
	local oldbm = love.graphics.getBlendMode()

	love.graphics.setBlendMode(self.blendMode)
	love.graphics.draw(self.ps, 0, 0)
	love.graphics.setBlendMode(oldbm)
end

function ParticleRenderer:_setRenderFuncBySS()
	if self.simulationSpace == "local" then
		self.ps:setPosition(0, 0)
		self.render = self.class._renderLocalSpace
	else
		self.render = self.class._renderWorldSpace
	end
end

function ParticleRenderer:_update(dt)
	self.ps:update(dt)
end

-- Override
function ParticleRenderer:update(dt)
	self.delayTimer = self.delayTimer + dt
	if self.delayTimer >= self.emitDelay then
		self.update = self.class._update
		self:_setRenderFuncBySS()
	end
end

return ParticleRenderer