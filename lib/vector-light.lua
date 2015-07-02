--[[
Copyright (c) 2012-2013 Matthias Richter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

local Misc = require "lib.misc"

local sqrt, cos, sin, atan2 = math.sqrt, math.cos, math.sin, math.atan2
local deg2rad = Misc.deg2rad
local vectorlight = {}

function vectorlight.str(x,y)
	return "("..tonumber(x)..","..tonumber(y)..")"
end

function vectorlight.mul(s, x,y)
	return s*x, s*y
end

function vectorlight.div(s, x,y)
	return x/s, y/s
end

function vectorlight.add(x1,y1, x2,y2)
	return x1+x2, y1+y2
end

function vectorlight.sub(x1,y1, x2,y2)
	return x1-x2, y1-y2
end

function vectorlight.permul(x1,y1, x2,y2)
	return x1*x2, y1*y2
end

function vectorlight.dot(x1,y1, x2,y2)
	return x1*x2 + y1*y2
end

function vectorlight.det(x1,y1, x2,y2)
	return x1*y2 - y1*x2
end

function vectorlight.eq(x1,y1, x2,y2)
	return x1 == x2 and y1 == y2
end

function vectorlight.lt(x1,y1, x2,y2)
	return x1 < x2 or (x1 == x2 and y1 < y2)
end

function vectorlight.le(x1,y1, x2,y2)
	return x1 <= x2 and y1 <= y2
end

function vectorlight.len2(x,y)
	return x*x + y*y
end

function vectorlight.len(x,y)
	return sqrt(x*x + y*y)
end

function vectorlight.dist2(x1,y1, x2,y2)
	return len2(x1-x2, y1-y2)
end

function vectorlight.dist(x1,y1, x2,y2)
	return len(x1-x2, y1-y2)
end

function vectorlight.normalize(x,y)
	local l = len(x,y)
	if l > 0 then
		return x/l, y/l
	end
	return x,y
end

function vectorlight.rotate(phi, x,y)
	local c, s = cos(phi), sin(phi)
	return c*x - s*y, s*x + c*y
end

function vectorlight.perpendicular(x,y)
	return -y, x
end

function vectorlight.project(x,y, u,v)
	local s = (x*u + y*v) / (u*u + v*v)
	return s*u, s*v
end

function vectorlight.mirror(x,y, u,v)
	local s = 2 * (x*u + y*v) / (u*u + v*v)
	return s*u - x, s*v - y
end

-- ref.: http://blog.signalsondisplay.com/?p=336
function vectorlight.trim(maxLen, x, y)
	local s = maxLen * maxLen / len2(x, y)
	s = s < 1 and 1 or math.sqrt(s)
	return x * s, y * s
end

function vectorlight.angleTo(x,y, u,v)
	return atan2(y - (v or 0), x - (u or 0))
end

function vectorlight.fromAngle(angle)
	return math.sin(angle * deg2rad), -math.cos(angle * deg2rad)
end

-- the module
return vectorlight
