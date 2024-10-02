-- debug.lua
_G.FUNCTION_DEBUG = {
    GetFollowerTraits = true,   -- Enable debugging for this specific function
    SomeOtherFunction = false,   -- Disable debugging for this function
    CheckRewards = true  -- Use just the function name as a string key
}


function FunctionDebugPrint(funcName, message)
    if _G.FUNCTION_DEBUG[funcName] then
        print(funcName .. ": " .. message)
    end
end




