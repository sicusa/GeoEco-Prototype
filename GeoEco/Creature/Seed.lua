local class = require "lib.middleclass"
local LifeEntity = require "GeoEco.Creature.LifeEntity"

local Seed = class("Seed", LifeEntity)

function Seed:initialize(pos, emptyMass)
    LifeEntity.initialize(self, pos, emptyMass)
    self.gene = ""
end

function Seed:getGene()
    return self.gene
end

function Seed:setGene(gene)
    assert(type(gene) == "string", "gene must be a string")
    self.gene = gene
end

return Seed
