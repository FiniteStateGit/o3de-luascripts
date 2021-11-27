local path = (...):gsub("[^%.]*$", "")
local M = require(path .. 'master')
local excluded_keys = {
  ['__init'] = true,
  ['__extends'] = true,
  ['__index'] = true,
  ['__class'] = true
}
M.class = function(tbl)
  assert(type(tbl) == 'table', "An initialisation table must be provided for the class")
  local parent = tbl.__extends
  local base
  do
    local _tbl_0 = { }
    for k, v in pairs(parent and parent.__base or { }) do
      if not excluded_keys[k] and tbl[k] == nil then
        _tbl_0[k] = v
      end
    end
    base = _tbl_0
  end
  local c = {
    __parent = parent,
    __base = base,
    __index = tbl.__index or (parent and parent.__index),
    __init = tbl.__init or (parent and parent.__init) or function(self) end
  }
  for k, v in pairs(tbl) do
    if not excluded_keys[k] then
      base[k] = v
    end
  end
  base.__class = c
  do
    local __index = c.__index
    if __index then
      base.__index = function(t, key)
        local olditem = base[key]
        if not (olditem == nil) then
          return olditem
        end
        local item
        local _exp_0 = type(__index)
        if "table" == _exp_0 then
          item = __index[key]
        elseif "function" == _exp_0 then
          item = __index(t, key)
        end
        return item
      end
    else
      base.__index = base
    end
  end
  return setmetatable(c, {
    __call = function(self, ...)
      local __newindex = base.__newindex
      base.__newindex = nil
      local obj = setmetatable({ }, base)
      self.__init(obj, ...)
      base.__newindex = __newindex
      return obj
    end,
    __index = base
  })
end
