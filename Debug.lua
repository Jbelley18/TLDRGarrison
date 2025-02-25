-- debug.lua
_G.FUNCTION_DEBUG = {
    GetFollowerTraits = false,
    SomeOtherFunction = false,
    CheckRewards = false,
    GetMissionMechanics = false,
    MatchFollowersToMechanics = false
}


function FunctionDebugPrint(funcName, message)
    if _G.FUNCTION_DEBUG[funcName] then
        print(funcName .. ": " .. message)
    end
end
