-- aoi_demo.lua 

local aoi_demo = 
{
    Properties =
    {
        -- Property definitions
    }
}

local Map = require "Scripts.aoi.map"
local m = Map:new {
	x = 512,
	y = 512,
	radius = 10,
}

function aoi_demo:OnActivate()

    Debug.Log("-----")

    Debug.Log("10000 enter [1], [1], The number of units within the radius is: "..#m:enter(10000, 1, 1))
    
    Debug.Log("The total number of people in the map is: "..m:members())m:dumps()
    
    Debug.Log("-----")
    
    Debug.Log("10001 enter [10], [10], The number of units within the radius is: "..#m:enter(10001, 10, 10))
    
    Debug.Log("The total number of people in the map is: "..m:members())m:dumps()
    
    Debug.Log("-----")
    
    Debug.Log("10002 enter [25], [25], The number of units within the radius is: "..#m:enter(10002, 25, 25))
    
    Debug.Log("The total number of people in the map is: "..m:members())m:dumps()
    
    Debug.Log("-----")
    
    Debug.Log("10001 move to [15], [15], The number of units within the radius is: "..#m:move(10001, 15, 15))
    
    Debug.Log("The total number of people in the map is: "..m:members())m:dumps()
    
    Debug.Log("-----")
    
    Debug.Log("10000 leave from [1], [1], The number of units within the radius is: "..#m:leave(10000))
    
    Debug.Log("The total number of people in the map is: "..m:members())m:dumps()
    
    Debug.Log("-----")
    
    Debug.Log("10001 leave from [15], [15], The number of units within the radius is: "..#m:leave(10001))
    
    Debug.Log("The total number of people in the map is: "..m:members())m:dumps()
    
    Debug.Log("-----")
    
    Debug.Log("10002 leave from [25], [25], The number of units within the radius is: "..#m:leave(10002))
    
    Debug.Log("The total number of people in the map is: "..m:members())m:dumps()
    
    Debug.Log("-----")
end

function aoi_demo:OnDeactivate()
     -- Deactivation Code
end

return aoi_demo