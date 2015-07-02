local class = require "lib.middleclass"

local PhyInteractions = require "GeoEco.Physics.PhyInteractions"
local PhyWorld = require "GeoEco.Physics.PhyWorld"

local PtlBehaviours = require "GeoEco.Simulation.PtlBehaviours"
local PtlInteractions = require "GeoEco.Simulation.PtlInteractions"

local sysparams = {
    PtlGravity_Coefficient = 6.6,
    PtlGravity_Range = 50,

    PtlCombine_MinimumTemperatureFactor = 0.2,
    PtlCombine_MaximumMass = 25,
    PtlCombine_Range = 10,

    PtlDecompose_DelayFactor = 10,
    PtlDecompose_MinimumTemperatureFactor = 10,
    PtlDecompose_MinimumMass = 0,

    PtlConnect_MinimumMass = 25,
    PtlConnect_MinimumTemperatureFactor = 0.2,
    PtlConnect_MaximumInteractionCount = 4,
    PtlConnect_Range = 50,

    PtlDeconnect_DelayFactor = 2000,
    PtlDeconnect_MinimumTemperatureFactor = 10
}

local stdRangedGravityInteraction = {
    interaction = PhyInteractions.gravity:new(
        sysparams.PtlGravity_Coefficient
    ),
    range = sysparams.PtlGravity_Range
}
local stdRangedAntiGravityInteraction = {
    interaction = PhyInteractions.gravity:new(
        -sysparams.PtlGravity_Coefficient
    ),
    range = sysparams.PtlGravity_Range
}
local stdRangedCombinativeInteraction = {
    interaction = PtlInteractions.combine:new(
        sysparams.PtlCombine_MaximumMass,
        sysparams.PtlCombine_MinimumTemperatureFactor
    ),
    range = sysparams.PtlCombine_Range
}
local stdRangedConnectiveInteraction = {
    interaction = PtlInteractions.connect:new(
        sysparams.PtlConnect_MinimumMass,
        sysparams.PtlConnect_MinimumTemperatureFactor,
        sysparams.PtlConnect_MaximumInteractionCount
    ),
    range = sysparams.PtlConnect_Range
}
local stdRangedLineConnectiveInteraction = {
    interaction = PtlInteractions.connect:new(
        0, 0, 3
    ),
    range = sysparams.PtlConnect_Range
}
local stdDecomposeBehaviour = PtlBehaviours.decompose:new(
    sysparams.PtlDecompose_DelayFactor,
    sysparams.PtlDecompose_MinimumTemperatureFactor,
    sysparams.PtlDecompose_MinimumMass
)
local stdDeconnectiveBehaviour = PtlBehaviours.deconnect:new(
    sysparams.PtlDeconnect_DelayFactor,
    sysparams.PtlDeconnect_MinimumTemperatureFactor
)

local categories = {
    {
        name = "GEPT-ELEM-0000"
    },
    {
        name = "GEPT-ELEM-0001",
        ranged_interactions = { stdRangedGravityInteraction }
    },
    {
        name = "GEPT-ELEM-0002",
        ranged_interactions = { stdRangedAntiGravityInteraction }
    },
    {
        name = "GEPT-ELEM-0003",
        ranged_interactions = { stdRangedLineConnectiveInteraction }
    },
    {
        name = "GEPT-ELEM-0004",
        ranged_interactions = { stdRangedConnectiveInteraction }
    },
    {
        name = "GEPT-ELEM-0005",
        behaviours = { stdDecomposeBehaviour }
    },
    {
        name = "GEPT-ELEM-0006",
        ranged_interactions = {
            stdRangedGravityInteraction,
            stdRangedCombinativeInteraction,
            stdRangedConnectiveInteraction
        },
        behaviours = { stdDeconnectiveBehaviour }
    }
}

local Environment = class("Environment", PhyWorld)

Environment._createEntity = PhyWorld.createEntity
Environment._addEntity = PhyWorld.addEntity
Environment.foreachParticle = PhyWorld.foreachEntity
Environment.getParticleCount = PhyWorld.getEntityCount

function Environment:createEntity(...)
    assert(false, "unimplemented")
end
function Environment:addEntity(...)
    assert(false, "unimplemented")
end
function Environment:foreachEntity(...)
    assert(false, "unimplemented")
end
function Environment:getEntityCount(...)
    assert(false, "unimplemented")
end

function Environment:initialize()
    self.parameters = sysparams
    self.ptl_categories = {}

    for _, category in pairs(categories) do
        self.ptl_categories[category.name] = category
    end
end

function Environment:initWorld(w, h)
    PhyWorld.initialize(self, w, h)

end

function Environment:getParameters()
    return self.parameters
end

function Environment:getParameter(name)
    return self.parameters[name]
end

function Environment:setParameter(name, value)
    assert(type(name) == "string" and type(value) == "number",
           "invalid name or value")
    self.parameter[name] = value
end

function Environment:addParticleCategory(category)
    assert(category ~= nil, "category cannot be nil")
    self.ptl_categories[category.name] = category
end

function Environment:removeParticleCategory(name)
    self.ptl_categories[name] = nil
end

function Environment:getParticleCategory(name)
    return self.ptl_categories[name]
end

function Environment:createParticle(pos, mass, category_name)
    if Particle == nil then
        Particle = require "GeoEco.Simulation.Particle"
    end
    category_name = category_name or "GEPT-ELEM-0000"
    local category = self.ptl_categories[category_name]
    if category == nil then
        print("unidentified particle category: "..category_name)
        return nil
    end
    local ptl = Particle:new(pos, mass, category)
    self:_addEntity(ptl)
    return ptl
end

local instance = Environment:new()

return instance
