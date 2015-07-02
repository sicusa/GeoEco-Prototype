local ffi = require("ffi")
ffi.cdef[[
	typedef struct { uint8_t r, g, b, a; } Color;
]]

local color_mt = {
	__index = {}
}

function color_mt:__tostring()
	return
		"("..tonumber(self.r)..
		","..tonumber(self.g)..
		","..tonumber(self.b)..
		","..tonumber(self.a)..")"
end

function color_mt.__add(a,b)
	return Color:new(a.r + b.r, a.g + b.g, a.b + b.b, a.a + b.a)
end

function color_mt.__sub(a,b)
	return Color:new(a.r - b.r, a.g - b.g, a.b - b.b, a.a - b.a)
end

function color_mt.__eq(a,b)
	return
		a.r == b.r and a.g == b.g and
		a.b == b.b and a.a == b.a
end

function color_mt.__index:clone()
	return Color:new(self.r, self.g, self.b, self.a)
end

function color_mt.__index:unpack()
	return self.r, self.g, self.b, self.a
end

local Color = {
	creator = ffi.metatype("Color", color_mt)
}

Colors = {}

Colors.White 	= {255, 255, 255}
Colors.Black 	= {  0,   0,   0}
Colors.Red 		= {255,   0,   0}
Colors.Green 	= {  0, 255,   0}
Colors.Blue 	= {  0,   0, 255}
Colors.Yellow 	= {255, 255,   0}
Colors.Cyan 	= {  0, 255, 255}
Colors.Magenta 	= {255,   0, 255}

Colors.BeachSand	= {255, 249, 157}
Colors.DesertSand	= {250, 205, 135}

Colors.LightGreen	= { 60, 184, 120}
Colors.PureGreen	= {  0, 166,  81}
Colors.DarkGreen	= {  0, 114,  54}

Colors.LightYellowGreen	= {124, 197, 118}
Colors.PureYellowGreen	= { 57, 181,  74}
Colors.DarkYellowGreen	= { 25, 123,  48}

Colors.LightBrown	= {198, 156, 109}
Colors.DarkBrown	= {115, 100,  87}

function Color:new(r_or_table_or_str, g, b, a)
	if type(r_or_table_or_str) == "table" then
		return self:create(unpack(r_or_table_or_str))
	elseif type(r_or_table_or_str) == "string" then
		return self:create(unpack(Colors[r_or_table_or_str]))
	else
		return self:create(r_or_table_or_str, g, b, a)
	end
end

function Color:create(r, g, b, a)
	return self.creator(r or 0, g or 0, b or 0, a or 255)
end

return Color