local path = (...):gsub("[^%.]*$", "")
local M = require(path .. 'master')
M.CyclicList = M.class({
  __init = function(self, t)
    self.n = #t
    self.items = t
  end,
  __index = function(self, key)
    return type(key) == 'number' and self.items[((key - 1) % self.n) + 1]
  end
})
