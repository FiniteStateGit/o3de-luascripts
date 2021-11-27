local path = (...):gsub(".init$", "") .. '.'
local modules = {
  'class',
  'vectors',
  'luax',
  'cyclic',
  'matrices',
  'sets',
  'navigation'
}
for _index_0 = 1, #modules do
  local m = modules[_index_0]
  require(path .. m)
end
local M = require(path .. 'master')
return {
  Navigation = M.Navigation
}
