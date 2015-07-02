local class = require "lib.middleclass"
local setSelector = require "GeoEco.EntitySelectorSetter"

local PhyInteractionApplier = class("PhyInteractionApplier")

function PhyInteractionApplier:initialize(interaction, e1selector, e2selector)
    self.interaction = interaction
    setSelector(self, "e1selector", e1selector)
    setSelector(self, "e2selector", e2selector)
end

function PhyInteractionApplier:getInteraction()
    return self.interaction
end

function PhyInteractionApplier:setInteraction(interaction)
    self.interaction = interaction
end

function PhyInteractionApplier:onUpdate(world)
    local interaction = self.interaction
    local e1s = self.e1selector
    local e2s = self.e2selector

    e1s(function(e1)
        e2s(function(e2)
            interaction:apply(e1, e2)
        end)
    end)
end

return PhyInteractionApplier
