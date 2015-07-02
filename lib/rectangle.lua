local ffi = require "ffi"

ffi.cdef [[
    typedef struct { double ltx, lty, rbx, rby; } Rectangle;
]]

local min = math.min
local max = math.max

local Rectangle = {}

local rect_mt = {
    __index = {}
}

function rect_mt:__tostring()
    return "[" .. tonumber(self.ltx) .. "," .. tonumber(self.lty) ..
           "," .. tonumber(self.rbx) .. "," .. tonumber(self.rby) .. "]"
end

function rect_mt.__index:containsPoint(x, y)
    return self.ltx < x and x < self.rbx and
           self.lty < y and y < self.rby
end

function rect_mt.__index:containsRect(rect)
    return self.ltx < rect.ltx and self.rbx > rect.rbx and
           self.lty < rect.lty and self.rby > rect.rby
end

function rect_mt.__index:collidesRect(rect)
    return rect.ltx < self.rbx and rect.rbx > self.ltx and
           rect.lty < self.rby and rect.rby > self.lty
end

function rect_mt.__index:centerPoint()
    return (self.ltx + self.rbx) / 2, (self.lty + self.rby) / 2
end

Rectangle.creator = ffi.metatype("Rectangle", rect_mt)

function Rectangle:new(ltx, lty, rbx, rby)
    return self.creator(ltx, lty, rbx, rby)
end

function Rectangle:fromPoints(v1, v2)
    local ltx, lty = 0, 0
    local rbx, rby = 0, 0
    local x1, y1 = v1.x, v1.y
    local x2, y2 = v2.x, v2.y

    if x1 > x2 then
        ltx = x2
        rbx = x1
    else
        ltx = x1
        rbx = x2
    end

    if y1 > y2 then
        lty = y2
        rby = y1
    else
        lty = y1
        rby = y2
    end

    return self.creator(ltx, lty, rbx, rby)
end

return Rectangle
