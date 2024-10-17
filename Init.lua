-- Init.lua - This file is loaded first to handle all global initializations

-- Initialize the global table if it doesn't exist yet
_G.TLDRG = _G.TLDRG or {}

-- Ensure that each module is properly initialized
-- Ensure that each module is properly initialized
TLDRG.GUI = TLDRG.GUI or {}
TLDRG.FilterLogic = TLDRG.FilterLogic or {}
TLDRG.MissionLogic = TLDRG.MissionLogic or {}
TLDRG.FollowerLogic = TLDRG.FollowerLogic or {}
TLDRG.FollowerTraits = TLDRG.FollowerTraits or {}
TLDRG.GUIHandler = TLDRG.GUIHandler or {}

-- You can also initialize any global settings, default values, or debugging functions here
_G.DEBUG_MODE = _G.DEBUG_MODE or false

-- DebugPrint helper function
function TLDRG.DebugPrint(...)
    if _G.DEBUG_MODE then
        print(...)
    end
end


local function PrintFollowerInfo()
    for _, follower in ipairs(C_Garrison.GetFollowers(1)) do
        -- Check if the follower is collected (meaning you have them)
        if follower.isCollected then
            print("Follower Name:", follower.name)
            print("  Follower ID:", follower.followerID)

            local abilities = C_Garrison.GetFollowerAbilities(follower.followerID)
            print("  Abilities:")
            for _, ability in pairs(abilities) do
                print("    Ability Name:", ability.name)
                print("    Ability Description:", ability.description)
                if ability.counters then
                    print("    Counters:")
                    for _, counter in pairs(ability.counters) do
                        print("      Counter Name:", counter.name)
                        print("      Counter Description:", counter.description)
                        print("      Counter ID:", counter.mechanicTypeID or "nil")
                    end
                end
            end
        end
    end
end

SLASH_FOLLOWERINFO1 = "/followerinfo"
SlashCmdList["FOLLOWERINFO"] = PrintFollowerInfo


-- Define the slash command
SLASH_KENZI1 = "/Kenzi"
SlashCmdList["KENZI"] = function(msg, editbox)
    -- Step 1: Get all your Garrison followers
    local followerTypeID = 1 -- 1 for Garrison Followers (Warlords of Draenor)
    local followers = C_Garrison.GetFollowers(followerTypeID)

    -- Step 2: Find Kenzi Solo and get his follower ID
    local kenziFollowerID = nil

    for _, follower in ipairs(followers) do
        if follower.name == "Kenzi Solo" then
            kenziFollowerID = follower.followerID
            break
        end
    end

    if kenziFollowerID then
        -- Step 3: Get Kenzi Solo's follower information
        local followerInfo = C_Garrison.GetFollowerInfo(kenziFollowerID)
        if followerInfo then
            -- Step 4: Get his specialization ID
            local specID = followerInfo.classSpec
            print("Kenzi Solo's Specialization ID:", specID)

            -- Step 5: Get the class name instead
            local className = followerInfo.className
            print("Kenzi Solo's Class Name:", className)
        else
            print("Could not retrieve information for Kenzi Solo.")
        end
    else
        print("Kenzi Solo is not among your followers.")
    end
end



