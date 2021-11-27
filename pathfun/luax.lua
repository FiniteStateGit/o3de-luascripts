local path = (...):gsub("[^%.]*$", "")
local M = require(path .. 'master')
local Vec2
Vec2 = M.Vec2
local floor
floor = math.floor
local xtype, xmath, round, clamp
xtype = function(x)
  local t = type(x)
  if t ~= "table" then
    return t
  else
    do
      local cls = x.__class
      if cls then
        return cls
      else
        return t
      end
    end
  end
end
xmath = { }
M.math = xmath
xmath.sgn = function(x)
  return x > 0 and 1 or x < 0 and -1 or 0
end
round = function(a)
  if xtype(a) == Vec2 then
    return Vec2(round(a.x), round(a.y))
  else
    return floor(a + 0.5)
  end
end
xmath.round = round
clamp = function(a, min, max)
  if xtype(a) == Vec2 then
    return Vec2(clamp(a.x, min, max), clamp(a.y, min, max))
  else
    return (a < min and min) or (a > max and max) or a
  end
end
xmath.clamp = clamp
