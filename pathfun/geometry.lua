local path = (...):gsub("[^%.]*$", "")
local M = require(path .. 'master')
local CyclicList, Vec2
CyclicList, Vec2 = M.CyclicList, M.Vec2
local dot, wedge
dot, wedge = Vec2.dot, Vec2.wedge
local clamp, sgn
do
  local _obj_0 = M.math
  clamp, sgn = _obj_0.clamp, _obj_0.sgn
end
local geometry = { }
geometry.closest_edge_point = function(P, A, B)
  local u = B - A
  local t = clamp(dot(P - A, u) / u:lenS(), 0, 1)
  return A + t * u
end
geometry.bounding_box = function(points)
  local minx, miny, maxx, maxy = math.huge, math.huge, -math.huge, -math.huge
  for _index_0 = 1, #points do
    local v = points[_index_0]
    minx = math.min(minx, v.x)
    miny = math.min(miny, v.y)
    maxx = math.max(maxx, v.x)
    maxy = math.max(maxy, v.y)
  end
  return {
    x = minx,
    y = miny
  }, {
    x = maxx,
    y = maxy
  }
end
geometry.is_point_in_triangle = function(P, A, B, C)
  local sda = wedge(A - C, B - C)
  local s = sgn(sda)
  local a = wedge(P - C, B - C)
  local b = wedge(P - C, C - A)
  return s * a >= 0 and s * b >= 0 and s * (a + b) <= math.abs(sda)
end
geometry.centroid = function(points)
  local P = CyclicList(points)
  local W = 0
  local C = Vec2()
  for i = 1, #points do
    local tmp = wedge(P[i], P[i + 1])
    W = W + tmp
    C = C + ((P[i] + P[i + 1]) * tmp)
  end
  return C / (3 * W)
end
return geometry
