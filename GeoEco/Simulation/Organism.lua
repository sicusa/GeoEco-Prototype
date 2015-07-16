local class = require "lib.middleclass"

--[[
[CONTROL]
FRAME 0
PRODUCE GEPT-ELEM-0000 REGIN_1
CONNECT SPRINT $ELASTIC $REST_LEN $MAX_LEN $MIN_LEN

[REGIN_1]
CALL #CONTROL
RETURN
]]

local Organism = class("Organism")

function Organism:initialize(name, code)
    self.name = name
    self.code = code
end

function Organism:getName()
    return self.name
end

function Organism:setName(name)
    self.name = name
end

function Organism:getCode()
    return self.code
end

function Organism:update()

end
