local path = (...):gsub("[^%.]*$", "")
local M = require(path .. 'master')
local CyclicList, Set, SymmetricMatrix, Vec2
CyclicList, Set, SymmetricMatrix, Vec2 = M.CyclicList, M.Set, M.SymmetricMatrix, M.Vec2
local wedge
wedge = Vec2.wedge
local round
round = M.math.round
local geometry = require(path .. 'geometry')
local bounding_box, centroid, closest_edge_point, is_point_in_triangle
bounding_box, centroid, closest_edge_point, is_point_in_triangle = geometry.bounding_box, geometry.centroid, geometry.closest_edge_point, geometry.is_point_in_triangle
local ConvexPolygon, Navigation, string_pull, orientation
ConvexPolygon = M.class({
  __init = function(self, vertices, name, hidden)
    assert(#vertices > 2, "A polygon must have a least 3 points.", 2)
    self.vertices = CyclicList(vertices)
    self.name = name
    self.hidden = hidden
    self.n = #vertices
    self.min, self.max = bounding_box(vertices)
    self.centroid = centroid(vertices)
    do
      local _accum_0 = { }
      local _len_0 = 1
      for i = 1, self.n do
        _accum_0[_len_0] = false
        _len_0 = _len_0 + 1
      end
      self.connections = _accum_0
    end
  end,
  len = function(self)
    return self.n
  end,
  ipairs = function(self)
    return ipairs(self.vertices.items)
  end,
  __index = function(self, key)
    return self.vertices[key]
  end,
  get_edge = function(self, i)
    return self.vertices[i], self.vertices[i + 1]
  end,
  get_connection = function(self, i)
    local c = self.connections[i]
    if c and not c.polygon.hidden then
      return c.polygon, c.edge
    end
  end,
  is_point_inside = function(self, P)
    if not (P.x < self.min.x or P.y < self.min.y or P.x > self.max.x or P.y > self.max.y) then
      for i = 2, self.n - 1 do
        if is_point_in_triangle(P, self.vertices[1], self.vertices[i], self.vertices[i + 1]) then
          return true
        end
      end
    end
    return false
  end,
  is_point_inside_connected = function(self, P, visited)
    if visited == nil then
      visited = { }
    end
    visited[self] = true
    if self:is_point_inside(P) then
      return self
    end
    local _list_0 = self.connections
    for _index_0 = 1, #_list_0 do
      local t = _list_0[_index_0]
      if t and not t.polygon.hidden and not visited[t.polygon] then
        do
          local poly = t.polygon:is_point_inside_connected(P, visited)
          if poly then
            return poly
          end
        end
      end
    end
    return nil
  end,
  closest_edge_point = function(self, P, edge_idx)
    local A, B = self:get_edge(edge_idx)
    return closest_edge_point(P, A, B)
  end,
  closest_boundary_point_connected = function(self, P, visited)
    if visited == nil then
      visited = { }
    end
    visited[self] = true
    local C, poly
    local d = math.huge
    for i = 1, self.n do
      if not self.connections[i] or self.connections[i].polygon.hidden then
        local tmp_C = self:closest_edge_point(P, i)
        local tmp_d = (P - tmp_C):lenS()
        if tmp_d < d then
          d = tmp_d
          C = tmp_C
          poly = self
        end
      else
        local neighbour = self.connections[i].polygon
        if not visited[neighbour] then
          local tmp_C, tmp_poly, tmp_d = neighbour:closest_boundary_point_connected(P, visited)
          if tmp_d < d then
            d = tmp_d
            C = tmp_C
            poly = tmp_poly
          end
        end
      end
    end
    return C, poly, d
  end
})
Navigation = M.class({
  __init = function(self, pmaps)
    if pmaps == nil then
      pmaps = { }
    end
    local vertices, vertex_idxs, polygons, name_groups = { }, {
      n = 0
    }, { }, { }
    for _index_0 = 1, #pmaps do
      local pmap = pmaps[_index_0]
      local name_group = pmap.name and { }
      if pmap.name then
        name_groups[pmap.name] = name_group
      end
      for _index_1 = 1, #pmap do
        local poly = pmap[_index_1]
        local tmp = { }
        for _index_2 = 1, #poly do
          local v = poly[_index_2]
          local x, y = unpack(v)
          local label = tostring(x) .. ';' .. tostring(y)
          if not vertices[label] then
            v = Vec2(x, y)
            vertices[label] = v
            vertex_idxs.n = vertex_idxs.n + 1
            vertex_idxs[v] = vertex_idxs.n
          end
          tmp[#tmp + 1] = vertices[label]
        end
        local cp = ConvexPolygon(tmp, pmap.name, pmap.hidden)
        polygons[#polygons + 1] = cp
        if name_group then
          name_group[#name_group + 1] = cp
        end
      end
    end
    self.polygons = polygons
    self.vertex_idxs = vertex_idxs
    self.name_groups = name_groups
  end,
  set_visibility = function(self, name, bool)
    local _list_0 = (self.name_groups[name] or { })
    for _index_0 = 1, #_list_0 do
      local p = _list_0[_index_0]
      p.hidden = not bool
    end
  end,
  toggle_visibility = function(self, name)
    local _list_0 = (self.name_groups[name] or { })
    for _index_0 = 1, #_list_0 do
      local p = _list_0[_index_0]
      p.hidden = not p.hidden
    end
  end,
  initialize = function(self)
    self.initialized = true
    local edges_matrix = SymmetricMatrix(self.vertex_idxs.n)
    for k, p in ipairs(self.polygons) do
      for i = 1, p.n do
        local A, B = p:get_edge(i)
        local A_idx, B_idx = self.vertex_idxs[A], self.vertex_idxs[B]
        if not edges_matrix[A_idx][B_idx] then
          edges_matrix[A_idx][B_idx] = { }
        end
        local t = edges_matrix[A_idx][B_idx]
        t[#t + 1] = {
          edge = i,
          polygon = p
        }
      end
    end
    for i = 1, self.vertex_idxs.n do
      for j = i + 1, self.vertex_idxs.n do
        do
          local t = edges_matrix[i][j]
          if t then
            local A, B = unpack(t)
            A.polygon.connections[A.edge] = B or false
            if B then
              B.polygon.connections[B.edge] = A
            end
          end
        end
      end
    end
  end,
  _is_point_inside = function(self, P)
    if not self.initialized then
      self:initialize()
    end
    local visited = { }
    local _list_0 = self.polygons
    for _index_0 = 1, #_list_0 do
      local poly = _list_0[_index_0]
      if not visited[poly] and not poly.hidden then
        do
          local p = poly:is_point_inside_connected(P, visited)
          if p then
            return p
          end
        end
      end
    end
  end,
  _closest_boundary_point = function(self, P)
    if not self.initialized then
      self:initialize()
    end
    local d = math.huge
    local C, piece, poly
    local _list_0 = self.polygons
    for _index_0 = 1, #_list_0 do
      local p = _list_0[_index_0]
      if not (p.hidden) then
        for i = 1, p.n do
          if not p.connections[i] or p.connections[i].polygon.hidden then
            local tmp_C = p:closest_edge_point(P, i)
            local tmp_d = (P - tmp_C):lenS()
            if tmp_d < d then
              d = tmp_d
              C = tmp_C
              poly = p
            end
          end
        end
      end
    end
    return C, poly
  end,
  _shortest_path = function(self, A, B)
    if not self.initialized then
      self:initialize()
    end
    if self.n == 0 then
      return { }
    end
    A, B = round(A), round(B)
    local node_A, node_B
    node_A = self:_is_point_inside(A)
    if not node_A then
      A, node_A = self:_closest_boundary_point(A)
      A = round(A)
    end
    node_B = node_A:is_point_inside_connected(B)
    if not node_B then
      B, node_B = node_A:closest_boundary_point_connected(B)
      B = round(B)
    end
    if node_A == node_B then
      return {
        A,
        B
      }
    end
    local found_path = false
    local _list_0 = self.polygons
    for _index_0 = 1, #_list_0 do
      local p = _list_0[_index_0]
      p.prev_edge = nil
    end
    local polylist = Set()
    node_B.entry = B
    node_B.distance = 0
    polylist:add(node_B)
    while not found_path do
      if polylist:size() == 0 then
        break
      end
      local least_cost_poly
      local least_cost = math.huge
      for p in polylist:iterator() do
        local cost = p ~= node_B and p.distance + (p.centroid - A):len() or 0
        if cost < least_cost then
          least_cost_poly = p
          least_cost = cost
        end
      end
      local p = least_cost_poly
      for i = 1, p.n do
        local q, c_edge = p:get_connection(i)
        if q then
          local entry = p:closest_edge_point(p.entry, i)
          local distance = p.distance + (p.entry - entry):len()
          if q.prev_edge then
            if q.distance > distance then
              q.prev_edge = c_edge
              q.distance = distance
              q.entry = entry
            end
          else
            q.prev_edge = c_edge
            q.distance = distance
            q.entry = entry
            polylist:add(q)
            if q == node_A then
              local found = true
              break
            end
          end
        end
      end
      if found_path then
        break
      end
      polylist:remove(p)
    end
    local portals = {
      {
        A,
        A
      }
    }
    local p = node_A
    while p ~= node_B and p.prev_edge do
      local C, D = p:get_edge(p.prev_edge)
      local L, R = unpack(portals[#portals])
      local sign = orientation(C, L, D)
      sign = sign == 0 and orientation(C, R, D) or sign
      portals[#portals + 1] = sign > 0 and {
        C,
        D
      } or {
        D,
        C
      }
      p = p:get_connection(p.prev_edge)
    end
    portals[#portals + 1] = {
      B,
      B
    }
    return string_pull(portals)
  end,
  is_point_inside = function(self, x, y)
    return not not self:_is_point_inside(Vec2(x, y))
  end,
  closest_boundary_point = function(self, x, y)
    local P = self:_closest_boundary_point(Vec2(x, y))
    return P.x, P.y
  end,
  shortest_path = function(self, x1, y1, x2, y2)
    path = self:_shortest_path(Vec2(x1, y1), Vec2(x2, y2))
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #path do
      local v = path[_index_0]
      _accum_0[_len_0] = {
        v.x,
        v.y
      }
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end
})
M.Navigation = Navigation
string_pull = function(portals)
  local portal_left, portal_right = unpack(portals[1])
  local l_idx, r_idx = 1, 1
  local apex = portal_left
  path = {
    apex
  }
  local i = 1
  while i < #portals do
    i = i + 1
    local left, right = unpack(portals[i])
    local skip = false
    if orientation(portal_right, apex, right) <= 0 then
      if apex == portal_right or orientation(portal_left, apex, right) > 0 then
        portal_right = right
        r_idx = i
      else
        if path[#path] ~= portal_left then
          path[#path + 1] = portal_left
        end
        apex = portal_left
        portal_right = apex
        r_idx = l_idx
        i = l_idx
        skip = true
      end
    end
    if not skip and orientation(portal_left, apex, left) >= 0 then
      if apex == portal_left or orientation(portal_right, apex, left) < 0 then
        portal_left = left
        l_idx = i
      else
        if path[#path] ~= portal_right then
          path[#path + 1] = portal_right
        end
        apex = portal_right
        portal_left = apex
        l_idx = r_idx
        i = r_idx
      end
    end
  end
  local A = portals[#portals][1]
  if path[#path] ~= A or #path == 1 then
    path[#path + 1] = A
  end
  return path
end
orientation = function(L, P, R)
  return wedge(R - P, L - P)
end
