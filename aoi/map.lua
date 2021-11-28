local class = require "class"

local new_tab = function (asize, hsize) return {} end
local ok, sys = pcall(require, "sys")
if ok and type(sys) == table then
  new_tab = sys.new_tab or function (asize, hsize) return {} end
end

local type = type
local error = error
local pairs = pairs
local print = print
local ipairs = ipairs
local assert = assert

local abs = math.abs
local toint = math.tointeger

local tadd = table.insert
local tremove = table.remove

-- Pack and unpack location information, mainly used to reduce the memory usage of the hash table
local Bit = 16
local xBit, yBit = Bit, Bit - Bit
local function XY_TO_POS (x, y)
  return (x << xBit) | (y << yBit)
end

local function POS_TO_XY (pos)
  return (pos >> xBit) & (2 ^ Bit - 1), (pos >> yBit) & (2 ^ Bit - 1)
end

-- Unit management
local function add_unit (units, unit, x, y)
  units[unit] = XY_TO_POS(x, y)
end

local function get_unit (units, unit)
  local pos = units[unit]
  if not pos then
    return
  end
  return POS_TO_XY(pos)
end

local function update_unit (units, unit, x, y)
  units[unit] = XY_TO_POS(x, y)
end

local function remove_unit (units, unit)
  units[unit] = nil
end


-- Map management: creating, adding, and deleting objects, range calculation and search
local units = -1

-- Create new map
local function new_map (X, Y)
  local map = new_tab(Y, 0)
  for y = 0, Y - 1 do
    map[y] = {[units] = 0}
  end
  return map
end

-- Add unit
local function add_map(map, unit, x, y)
  local xMap = map[y]
  xMap[units] = xMap[units] + 1 -- increment counter
  local mesh = xMap[x]
  if mesh then
    return tadd(mesh, unit)
  end
  xMap[x] = {unit}
end

-- Remove unit
local function remove_map(map, unit, x, y)
  local xMap = map[y]
  xMap[units] = xMap[units] - 1 -- decrement counter
  local mesh = xMap[x]
  if mesh then
    if #mesh == 1 then
      local u = tremove(mesh)
      xMap[x] = nil
      return u
    end
    for index, u in ipairs(mesh) do
      if u == unit then
        return tremove(mesh, index)
      end
    end
  end
  return error("Object not found.")
end

-- Update unit
local function update_map (map, unit, oldX, oldY, newX, newY)
  return remove_map(map, unit, oldX, oldY), add_map(map, unit, newX, newY)
end

-- Get list of units within unit's range
local function range_by_unit (self, unit, x, y, r)
  local map = self.map
  local radius = r or self.radius
  local MinX, MaxX = x - radius > 0 and x - radius or 0, x + radius < self.X and x + radius or self.X - 1
  local MinY, MaxY = y - radius > 0 and y - radius or 0, y + radius < self.Y and y + radius or self.Y - 1
  local units = {}
  for Y = MinY, MaxY do
    for X, mesh in pairs(map[Y]) do
      if X >= MinX and X <= MaxX then
        for _, u in ipairs(mesh) do
          if u ~= unit then
            tadd(units, {unit = u, x = X, y = Y})
          end
        end
      end
    end
  end
  return units
end



-- Out of bounds check
local function outRange (A, B)
  local a, b = toint(A), toint(B)
  if not a or not b then
    return true
  end
  if a < 0 or a >= b then
    return true
  end
  return false
end

local Map = class("__Map__")

function Map:ctor (opt)
  self.radius = assert(opt and opt.radius and toint(opt.radius) or 15, "Need integer value for radius/range.")
  self.X = assert(opt.x and toint(opt.x) and toint(opt.x) > 0 and toint(opt.x), "Need integer value for X.")
  self.Y = assert(opt.y and toint(opt.y) and toint(opt.y) > 0 and toint(opt.y), "Need integer value for Y.")
  self.units = new_tab(0, 1024)
  self.map = new_map(self.X, self.Y)
end

-- Get unit location
function Map:get_pos_by_unit (unit)
  if not unit then
    return error("Unit not a valid type [table/string/integer]")
  end
  local X, Y = get_unit(self.units, unit)
  if not X or not Y then
    return nil, "Unit location not found."
  end
  return X, Y
end

-- Get units within range of location
function Map:get_pos_by_range (x, y, radius)
  if outRange(x, self.X) or outRange(y, self.Y) then
    return error("X or Y value not in map's boundaries.")
  end
  return range_by_unit(self, nil, x, y, radius)
end

-- Add unit to map
function Map:enter (unit, x, y)
  if outRange(x, self.X) or outRange(y, self.Y) then
    return error("X or Y value not in map's boundaries.")
  end
  if self.units[unit] then
    return error("Unit already exists.")
  end
  add_unit(self.units, unit, x, y)
  add_map(self.map, unit, x, y)
  return range_by_unit(self, unit, x, y)
end

-- Move unit
function Map:move (unit, newX, newY)
  if outRange(newX, self.X) or outRange(newY, self.Y) then
    return error("Move error: move location not in map boundaries")
  end
  local oldX, oldY = get_unit(self.units, unit)
  if not oldX or not oldY then
    return error("Move error: unit out of bounds.")
  end
  update_unit(self.units, unit, newX, newY)
  update_map(self.map, unit, oldX, oldY, newX, newY)
  return range_by_unit(self, unit, newX, newY, self.radius + (abs(newX - oldX) > abs(newY - oldY) and abs(newX - oldX) or abs(newY - oldY)))
end

-- Remove unit from map
function Map:leave (unit)
  local x, y = get_unit(self.units, unit)
  if not x or not y then
    return error("Unit not found.")
  end
  remove_map(self.map, unit, x, y)
  remove_unit(self.units, unit)
  return range_by_unit(self, unit, x, y)
end

-- Unit count
function Map:members ()
  local count = 0
  local map = self.map
  for index = 0, self.Y - 1 do
    count = count + map[index][units]
  end
  return count
end

-- Prints location of all units on map
function Map:dumps ()
  local map = self.map
  for Y = 0, self.Y - 1 do
    for X, mesh in pairs(map[Y]) do
      if X > 0 then
        for _, u in ipairs(mesh) do
          Debug.Log(tostring("unit = ["..u.."], Y = ["..Y.."], X = ["..X.."]"))
        end
      end
    end
  end
end

return Map
