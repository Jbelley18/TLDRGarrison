-- Initialize the MissionLogic table
local ML = TLDRG.MissionLogic or {}
TLDRG.MissionLogic = ML

-- Fetches and prints available missions
function ML.FetchAndPrintMissions()
    local missions = C_Garrison.GetAvailableMissions(1)  -- Replace 1 with appropriate followerTypeID for your case
    if type(missions) ~= "table" then
        TLDRG.DebugPrint("No missions available.")
        return nil
    end

    TLDRG.DebugPrint("Available Missions:")
    for _, mission in ipairs(missions) do
        if mission and mission.missionID then  -- Ensure mission and mission.missionID are valid
            TLDRG.DebugPrint("Mission ID:", mission.missionID)
        else
            TLDRG.DebugPrint("Invalid mission entry found.")  -- Optional: debug for invalid entries
        end
    end

    return missions
end

-- Fetch detailed mission information with filtering logic
function ML.FetchDetailedMissionInfo(missions, filterCriteria)
    local detailedMissions = {}

    for _, mission in ipairs(missions) do
        if mission and mission.missionID then  -- Ensure the mission object and missionID exist
            local missionInfo = C_Garrison.GetBasicMissionInfo(mission.missionID)

            if missionInfo then
                local includeMission = false  -- Flag to decide if this mission should be included based on criteria

                -- Check rewards based on the filter criteria (e.g., Follower XP)
                if missionInfo.rewards then
                    for _, reward in pairs(missionInfo.rewards) do
                        if filterCriteria == "followerXP" and reward.followerXP then
                            includeMission = true
                            break
                        end
                    end
                end

                if includeMission then
                    print("Mission ID:", missionInfo.missionID, "Name:", missionInfo.name)

                    -- Optional: Debug output for rewards
                    for rewardID, reward in pairs(missionInfo.rewards) do
                        print("  Reward ID:", rewardID)
                        print("    Title:", reward.title or "N/A")
                        print("    Item ID:", reward.itemID or "N/A")
                        print("    Currency ID:", reward.currencyID or "N/A")
                        print("    Follower XP:", reward.followerXP or "N/A")
                    end

                    -- Add mission to the filtered list
                    table.insert(detailedMissions, missionInfo)
                end
            end
        else
            TLDRG.DebugPrint("Invalid mission entry found in FetchDetailedMissionInfo.")  -- Optional: debug for invalid entries
        end
    end

    -- Return filtered missions
    return detailedMissions
end
