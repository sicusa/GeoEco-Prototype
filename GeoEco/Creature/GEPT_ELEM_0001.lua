local class = require "lib.middleclass"
local GEPT_ELEM_0000 = require "GeoEco.Creature.GEPT_ELEM_0000"

local GEPT_ELEM_0001 = class("GEPT_ELEM_0001", GEPT_ELEM_0000)

function GEPT_ELEM_0001:initialize(pos, emptyMass)
    LifeEntity.initialize(self, pos, emptyMass)
end

-- Override
function GEPT_ELEM_0001:update()
    GEPT_ELEM_0000.update(self)

end

return GEPT_ELEM_0001
