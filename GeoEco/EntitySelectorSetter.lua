local Env = require "GeoEco.Environment"

local function setSelector(obj, attr, selector)
    local seltype = type(selector)
    if seltype == "table" then
        obj[attr] = function(func)
            for _, entity in pairs(selector) do
                func(entity)
            end
        end
    elseif seltype == "function" then
        obj[attr] = selector
    elseif selector == nil then
        obj[attr] = function(func) Env:foreachParticle(func) end
    else
        assert(false, "selector has invalid type")
    end
end

return setSelector
