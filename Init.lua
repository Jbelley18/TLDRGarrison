-- Init.lua - This file is loaded first to handle all global initializations
-- Initialize the global table if it doesn't exist yet
-- Initialize the global table if it doesn't exist yet
_G.TLDRG = _G.TLDRG or {}


-- Ensure that each module is properly initialized
TLDRG.GUI = TLDRG.GUI or {}
TLDRG.FilterLogic = TLDRG.FilterLogic or {}
TLDRG.MissionLogic = TLDRG.MissionLogic or {}
TLDRG.FollowerLogic = TLDRG.FollowerLogic or {}
TLDRG.FollowerTraits = TLDRG.FollowerTraits or {}
TLDRG.GUIHandler = TLDRG.GUIHandler or {}
TLDRG.Options = TLDRG.Options or {}  -- Add this line to initialize the Options module


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

-- Gets missions for GARRISON RESOURCES ONLY

SLASH_TLDRGMISSIONS1 = "/tldrgmissions"
SlashCmdList["TLDRGMISSIONS"] = function()
    print("Fetching missions that reward Garrison Resources...")

    local missions = TLDRG.MissionLogic.FetchAndPrintMissions()
    local garrisonMissions = TLDRG.FilterLogic.FilterMissionsForGarrisonResources(missions)

    if #garrisonMissions > 0 then
        print("Garrison Resource Missions Found:", #garrisonMissions)
        for _, mission in ipairs(garrisonMissions) do
            print("Mission:", mission.name, "| ID:", mission.missionID, "| Duration:", mission.duration)
        end
    else
        print("No Garrison Resource missions available.")
    end
end

-- finds compatible followers to mission.

SLASH_TLDRGASSIGN1 = "/tldrgassign"
SlashCmdList["TLDRGASSIGN"] = function()
    print("Assigning followers to Garrison Resource missions...")
    TLDRG.FollowerLogic.AssignFollowersToGarrisonMissions()
end

SLASH_TLDRGCONFIRM1 = "/tldrgconfirm"
SlashCmdList["TLDRGCONFIRM"] = function()
    if #TLDRG.FollowerLogic.pendingMissions == 0 then
        print("No pending missions to start. Run /tldrgassign first.")
        return
    end

    print("Starting assigned missions...")

    for _, data in ipairs(TLDRG.FollowerLogic.pendingMissions) do
        local missionID = data.missionID
        local missionInfo = C_Garrison.GetBasicMissionInfo(missionID)
        
        if missionInfo then
            local assignedFollowers = data.followers -- Retrieve stored followers from assignment step
            if assignedFollowers and #assignedFollowers == missionInfo.numFollowers then
                print("Assigning followers to mission:", missionInfo.name, "(ID:", missionID, ")")
                
                for _, follower in ipairs(assignedFollowers) do
                    C_Garrison.AddFollowerToMission(missionID, follower.followerID)
                    print(" - Added follower:", follower.name, "(ID:", follower.followerID, ")")
                end
                
                print("Attempting to start mission:", missionInfo.name, "(ID:", missionID, ")")
                
                C_Timer.After(0.2, function()
                    local success = C_Garrison.StartMission(missionID)

                    if not success then
                        print("⚠️ Failed to start mission:", missionID, "- Check if UI is fully loaded or mission is still valid.")
                    else
                        print("✅ Mission Started:", missionInfo.name)
                    end
                end)
            else
                print("⚠️ Mission", missionID, "does not have the correct number of followers assigned.")
            end
        else
            print("⚠️ Mission", missionID, "not found. It may have expired.")
        end
    end

    -- Clear pending missions after execution
    TLDRG.FollowerLogic.pendingMissions = {}
end



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


if not TLDRG.FollowerTraits then
    TLDRG.FollowerTraits = {
        GetMissionMechanics = function() return {} end  -- Prevent crashes
    }
end

-- ===========================================
-- Ace3 Framework Test
-- ===========================================
-- if LibStub then
--     print("LibStub is available.")
-- else
--     print("LibStub is NOT available.")
-- end

-- if LibStub("AceAddon-3.0") then
--     print("AceAddon-3.0 is loaded.")
-- else
--     print("AceAddon-3.0 is NOT loaded.")
-- end
