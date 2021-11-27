-- heightmap_demo.lua 

local heightmap_demo = 
{
    Properties =
    {
        -- Property definitions
    }
}

local heightmap = require "Scripts/heightmap"

function heightmap_demo:OnActivate()

Debug.Log('Creating 32x32 Heightmap...')
-- create 32x32 heightmap

map = heightmap.create(self, 32, 32)

Debug.Log('Printing 32x32 Heightmap...')
-- examine each height value
for x = 0, map.w do
    for y = 0, map.h do
        Debug.Log(tostring(map[x][y]))
    end
end

Debug.Log('Scaling map by 2: creating 64x64 Heightmap...')
-- define a custom height function
-- (reusing the default but scaling it)
local function f(map, x, y, d, h)
    return 2 * heightmap.defaultf(self, map, x, y, d, h)
end

Debug.Log('Trimming heightmap to 32x64...')
-- use it to create a larger non-square heightmap
map = heightmap.create(self, 32, 64, f)

Debug.Log('Printing 32x64 Heightmap...')
-- examine each height value
for x = 0, map.w do
    for y = 0, map.h do
        Debug.Log(tostring(map[x][y]))
    end
end

end

function heightmap_demo:OnDeactivate()
     -- Deactivation Code
end

return heightmap_demo