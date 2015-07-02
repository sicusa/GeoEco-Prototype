local ffi = require "ffi"
local Vector = require "lib.vector"

ffi.cdef [[
    typedef struct { double a, k, sqrtAP; } Line;
]]

local Line = {}
local line_mt = {
    __index = {}
}

local sqrt, abs = math.sqrt, math.abs

local function getParameters(xa, ya, xb, yb)
    local a = (ya - yb) / (xa - xb)
    local k = ya - xa * a
    return a, k, sqrt(a * a + 1)
end

local function getParametersByVectors(v1, v2)
    return getParameters(v1.x, v1.y, v2.x, v2.y)
end

function line_mt.__index:perpendicularLine(v)
    local a = -1 / self.a
    local k = v.y - a * v.x
    return Line:new(a, k)
end

function line_mt.__index:distanceToPoint(v)
    return abs(self.a * v.x - v.y + self.k) / self.sqrtAP
end

function line_mt.__index:distanceToPointRestricted(v, rv1, rv2)
    local dist1 = Vector:dist(v, rv1)
    local dist2 = Vector:dist(v, rv2)
    local dist_seg = Vector:dist(rv1, rv2)

    if dist1 > dist_seg then
        return dist2
    elseif dist2 > dist_seg then
        return dist1
    end

    return self:distanceToPoint(v)
end

function line_mt.__index:updateParameters(v1, v2)
    self.a, self.k, self.sqrtAP = getParametersByVectors(v1, v2)
end

Line.creator = ffi.metatype("Line", line_mt)

function Line:new(a, k)
    return self.creator(a, k, sqrt(a * a + 1))
end

function Line:fromPoints(v1, v2)
    local a, k, sqrt_AP = getParametersByVectors(v1, v2)
    return self.creator(a, k, sqrt_AP)
end

function Line:intersectionPoint(l1, l2)
    local x = (l2.k - l1.k) / (l1.a - l2.a)
    local y = l1.a * x + l1.k
    return Vector:new(x, y)
end

return Line
