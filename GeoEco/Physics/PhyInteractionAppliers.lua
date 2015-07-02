local class = require "lib.middleclass"
local Env = require "GeoEco.Environment"

local PhyGroupedInteractionApplier = class("PhyGroupedInteractionApplier")

function PhyGroupedInteractionApplier:initialize(interaction, e1s, e2s)
    self.interaction = interaction
    self.e1s = e1s
    self.e2s = e2s
end

function PhyGroupedInteractionApplier:onUpdate(world)
    local interaction = self.interaction

    for _, e1 in pairs(self.e1s) do
        for _, e2 in pairs(self.e2s) do
            interaction:apply(e1, e2)
        end
    end
end

local PhyGlobalInteractionApplier = class("PhyGlobalInteractionApplier")

function PhyGlobalInteractionApplier:initialize(interaction)
    self.interaction = interaction
end

function PhyGlobalInteractionApplier:onUpdate(world)
    local interaction = self.interaction
    local entities = world:getEntities()

    for i, e in pairs(entities) do
        for i = 1, i do
            interaction:apply(e, entities[i])
        end
    end
end

return {
    grouped = PhyGroupedInteractionApplier,
    global = PhyGlobalInteractionApplier
}
