local ffi = require("ffi")
ffi.cdef[[
	typedef struct { double x, y; } Vector2;
]]

require "lib.misc"

local assert = assert
local sqrt, cos, sin, atan2 = math.sqrt, math.cos, math.sin, math.atan2

local Vector = {}

local vector_mt = {
	__index = {}
}

function vector_mt:__tostring()
	return "("..tonumber(self.x)..","..tonumber(self.y)..")"
end

function vector_mt.__unm(a)
	return Vector:new(-a.x, -a.y)
end

function vector_mt.__index:unm()
    self.x = -self.y
    self.y = -self.y
    return self
end

function vector_mt.__add(a,b)
	return Vector:new(a.x+b.x, a.y+b.y)
end

function vector_mt.__index:add(a)
    self.x = self.x + a.x
    self.y = self.y + a.y
    return self
end

function vector_mt.__sub(a,b)
	return Vector:new(a.x-b.x, a.y-b.y)
end

function vector_mt.__index:sub(a)
    self.x = self.x - a.x
    self.y = self.y - a.y
    return self
end

function vector_mt.__mul(a,b)
	return Vector:new(a.x*b, a.y*b)
end

function vector_mt.__index:mul(a)
    self.x = self.x * a
    self.y = self.y * a
    return self
end

function vector_mt.__div(a,b)
	return Vector:new(a.x/b, a.y/b)
end

function vector_mt.__index:div(a)
    self.x = self.x / a
    self.y = self.y / a
    return self
end

function vector_mt.__eq(a,b)
	return a.x == b.x and a.y == b.y
end

function vector_mt.__lt(a,b)
	return a.x < b.x or (a.x == b.x and a.y < b.y)
end

function vector_mt.__le(a,b)
	return a.x <= b.x and a.y <= b.y
end

function vector_mt.__len(a)
	return a:len()
end

function vector_mt.__index:len2()
	return self.x * self.x + self.y * self.y
end

function vector_mt.__index:len()
	return sqrt(self.x * self.x + self.y * self.y)
end

function vector_mt.__index:clone()
	return Vector:new(self.x, self.y)
end

function vector_mt.__index:unpack()
	return self.x, self.y
end

function vector_mt.__index:normalize_inplace()
	local l = self:len()
	if l > 0 then
		self.x, self.y = self.x / l, self.y / l
	end
	return self
end

function vector_mt.__index:normalized()
	return self:clone():normalize_inplace()
end

function vector_mt.__index:rotate_inplace(phi)
	local c, s = cos(phi), sin(phi)
	self.x, self.y = c * self.x - s * self.y, s * self.x + c * self.y
	return self
end

function vector_mt.__index:rotated(phi)
	local c, s = cos(phi), sin(phi)
	return Vector:new(c * self.x - s * self.y, s * self.x + c * self.y)
end

function vector_mt.__index:perpendicular()
	return Vector:new(-self.y, self.x)
end

function vector_mt.__index:projectOn(v)
	-- (self * v) * v / v:len2()
	local s = (self.x * v.x + self.y * v.y) / (v.x * v.x + v.y * v.y)
	return Vector:new(s * v.x, s * v.y)
end

function vector_mt.__index:mirrorOn(v)
	-- 2 * self:projectOn(v) - self
	local s = 2 * (self.x * v.x + self.y * v.y) / (v.x * v.x + v.y * v.y)
	return Vector:new(s * v.x - self.x, s * v.y - self.y)
end

function vector_mt.__index:cross(v)
	return self.x * v.y - self.y * v.x
end

-- ref.: http://blog.signalsondisplay.com/?p=336
function vector_mt.__index:trim_inplace(maxLen)
	local s = maxLen * maxLen / self:len2()
	s = s < 1 and 1 or sqrt(s)
	self.x, self.y = self.x * s, self.y * s
	return self
end

function vector_mt.__index:angleTo(other)
	other = other or Vector.zero
	return atan2(self.y - other.y, self.x - other.x)
end

function vector_mt.__index:angle()
    return atan2(self.y, self.x)
end

function vector_mt.__index:trimmed(maxLen)
	return self:clone():trim_inplace(maxLen)
end

function vector_mt.__index:set(x, y)
	self.x, self.y = x, y
    return self
end

function vector_mt.__index:equal(x, y)
	return self.x == x and self.y == y
end

Vector.creator = ffi.metatype("Vector2", vector_mt)

function Vector:new(x, y)
	return self.creator(x or 0, y or 0)
end

function Vector:dist(a, b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	return sqrt(dx * dx + dy * dy)
end

function Vector:dist2(a, b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	return (dx * dx + dy * dy)
end

function Vector:fromAngle(angle)
	return self.creator(sin(angle), -cos(angle));
end

function Vector:permul(a,b)
	return self.creator(a.x*b.x, a.y*b.y)
end

Vector.zero = Vector:new(0, 0)

return Vector
