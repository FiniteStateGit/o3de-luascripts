local type = type
local setmetatable = setmetatable

-- compact class implementation
function class(cls_name)
    local cls = { __name = cls_name }
    cls.__index = cls
    cls.__call = function (cls, ...)
        local call = cls[cls_name]
        if call then
            return call(cls, ...)
        end
        return
    end
    cls.new = function (c, ...)
        if cls ~= c then
            return Debug.Log("Please use ':' to create new object :)")
        end
        local t = {}
        local ctor = c.ctor
        if type(ctor) ~= 'function' then
            Debug.Log("Can't find ctor to init.")
        else
            ctor(t, ...)
        end
        return setmetatable(t, cls)
    end
    return cls
end

return class
