-- PrismLib - A Lua Library
-- Main module for PrismLib

local PrismLib = {}
PrismLib.version = "1.0.0"

--- Initialize PrismLib
function PrismLib.init()
    print("PrismLib v" .. PrismLib.version .. " initialized!")
    return true
end

--- Simple utility function
function PrismLib.hello(name)
    return "Hello, " .. (name or "World") .. "!"
end

--- Get library version
function PrismLib.getVersion()
    return PrismLib.version
end

return PrismLib
