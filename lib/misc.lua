require "lib.template"

local misc = {}

function misc.pixelsToMeters(pxl)
	return pxl/20
end

local function vectorDet(x1,y1, x2,y2)
	return x1*y2 - y1*x2
end
local function vectorCross(V, W)
	return V.x*W.y - V.y*W.x
end
function misc.areColinear(p, q, r, eps)
	return math.abs(vectorDet(q.x-p.x, q.y-p.y,  r.x-p.x,r.y-p.y)) <= (eps or 1e-32)
end

-- test wether a and b lie on the same side of the line c->d
local function onSameSide(a,b, c,d)
	local px, py = d.x-c.x, d.y-c.y
	local l = vectorDet(px,py,  a.x-c.x, a.y-c.y)
	local m = vectorDet(px,py,  b.x-c.x, b.y-c.y)
	return l*m >= 0
end

function misc.pointInTriangle(p, a,b,c)
	return onSameSide(p,a, b,c) and onSameSide(p,b, a,c) and onSameSide(p,c, a,b)
end
local function vectorDot(x1,y1, x2,y2)
	return x1*x2 + y1*y2
end

function misc.angBetweenPoints( a, b, c )
	--print("new")
	--tablePrint(a)
	--tablePrint(b)
	--tablePrint(c)
	local d = distance(a, b)*distance(b, c)
	local ang = math.acos( vectorDot(a.x-b.x, a.y-b.y, c.x-b.x, c.y-b.y)/d)
	if ang ~= ang then
		return math.pi
	end
	return ang
end

misc.rad2deg = 180 / math.pi
misc.deg2rad = math.pi / 180

function misc.round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function misc.fpart( num ) -- return fractional part of num:
	return num - math.floor(num)
end
function misc.rfpart( num ) -- return fractional part of num:
	return 1 - fpart( num )
end

----------------------------------
-- line segment intersections:

-- two segments given by M1 to M2 and K1 to K2:
--[[function segmentIntersections( M1, M2, K1, K2 )
	local d1 = M2 - M1
	local d2 = K2 - K1

	local denom = vectorDet( d1, d2 )
	if denom == 0 then	-- parallel!
		return nil
	end
	local numer1 = vectorDet((M1 - K1), d1)
	if numer1 == 0 then
		return M1
	end
	local numer2 = vectorDet((M1 - K1), d2)
	if numer2 == 0 then
		return K1
	end
	local t1 =  number1 / (denom)
	local t2 =  number2 / (denom)

	if t1 >= 0 and t1 <= 1 and t2 >= 0 and t2 <= 1 then
		return M1 + (d1*t1)
	end
end]]--

function misc.segmentIntersections( P, P2, Q, Q2 )
	local r = P2 - P
	local s = Q2 - Q

	local denom = vectorCross( r, s )
	if denom == 0 then	-- parallel!
		return nil
	end
	local numer1 = vectorCross( Q-P, s )
	local t1 =  numer1 / (denom)
	local numer2 = vectorCross( Q-P, r )
	local t2 =  numer2 / (denom)

	if t1 >= 0 and t1 <= 1 and t2 >= 0 and t2 <= 1 then
		local x = P + (r*t1)
		return x
	end
end

function misc.lineIntersections( P, P2, Q, Q2 )
	local r = P2 - P
	local s = Q2 - Q

	local denom = vectorCross( r, s )
	if denom == 0 then	-- parallel!
		return nil
	end
	local numer1 = vectorCross( Q-P, s )
	local t1 =  numer1 / (denom)
	local x = P + (r*t1)

	return x
end


----------------------------------

function misc.dropAlpha(x,y,r,g,b,a)
	return r,g,b,255
end

function misc.screenshot(path)
	screen = love.graphics.newScreenshot()
	screen:mapPixel(dropAlpha)
	screen:encode(path)
end

return misc
