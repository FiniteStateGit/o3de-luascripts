local path = (...):gsub("[^%.]*$", "")
local M = require(path .. 'master')
local __next
__next = function(t, key)
  local k, _ = next(t, key)
  return k
end
local Set = M.class({
  __init = function(self, t)
    if t == nil then
      t = { }
    end
    local n, items = 0, { }
    for _index_0 = 1, #t do
      local value = t[_index_0]
      n = n + 1
      items[value] = true
    end
    self.n = n
    self.items = items
  end,
  add = function(self, value)
    if not (self:contains(value)) then
      self.n = self.n + 1
      self.items[value] = true
    end
  end,
  remove = function(self, value)
    if self:contains(value) then
      self.n = self.n - 1
      self.items[value] = nil
    end
  end,
  size = function(self)
    return self.n
  end,
  iterator = function(self)
    return __next, self.items, nil
  end,
  contains = function(self, element)
    return self.items[element] or false
  end
})
M.Set = Set
