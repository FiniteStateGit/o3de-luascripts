local path = (...):gsub("[^%.]*$", "")
local M = require(path .. 'master')
local Vec2
Vec2 = M.class({
  __init = function(self, x, y)
    if x == nil then
      x = 0
    end
    if y == nil then
      y = 0
    end
    self.x, self.y = x, y
  end,
  __add = function(u, v)
    return Vec2(u.x + v.x, u.y + v.y)
  end,
  __sub = function(u, v)
    return Vec2(u.x - v.x, u.y - v.y)
  end,
  __unm = function(self)
    return Vec2(-self.x, -self.y)
  end,
  __mul = function(a, b)
    if type(a) == "number" then
      return Vec2(a * b.x, a * b.y)
    elseif type(b) == "number" then
      return Vec2(b * a.x, b * a.y)
    else
      return error("attempt to multiply a vector with a non-scalar value", 2)
    end
  end,
  __div = function(self, a)
    return self.__class(self.x / a, self.y / a)
  end,
  __eq = function(u, v)
    return u.x == v.x and u.y == v.y
  end,
  __tostring = function(v)
    return "(" .. tostring(v.x) .. ", " .. tostring(v.y) .. ")"
  end,
  __index = function(self, key)
    return key == 1 and self.x or key == 2 and self.y or nil
  end,
  dot = function(u, v)
    return u.x * v.x + u.y * v.y
  end,
  wedge = function(u, v)
    return u.x * v.y - u.y * v.x
  end,
  lenS = function(v)
    return Vec2.dot(v, v)
  end,
  len = function(self)
    return math.sqrt(self:lenS())
  end,
  unpack = function(self)
    return self.x, self.y
  end
})
M.Vec2 = Vec2
