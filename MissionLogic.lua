-- Initialize the MissionLogic table
local ML = TLDRG.MissionLogic or {}
TLDRG.MissionLogic = ML

-- Fetches and prints available missions
function ML.FetchAndPrintMissions()
    local missions = C_Garrison.GetAvailableMissions(1)  -- Use the appropriate followerTypeID for your case
    if type(missions) ~= "table" then
        TLDRG.DebugPrint("No missions available.")
        return nil
    end

    TLDRG.DebugPrint("Available Missions:")
    for _, mission in ipairs(missions) do
        if mission and mission.missionID then
            TLDRG.DebugPrint("Mission ID:", mission.missionID)
        else
            TLDRG.DebugPrint("Invalid mission entry found.")
        end
    end

    return missions
end

-- Fetch detailed mission information with filtering logic
function ML.FetchDetailedMissionInfo(missions, filterCriteria)
    local detailedMissions = {}

    for _, mission in ipairs(missions) do
        if mission and mission.missionID then
            local missionInfo = C_Garrison.GetBasicMissionInfo(mission.missionID)

            if missionInfo then
                local includeMission = false

                -- Check rewards based on the filter criteria using the new options system
                if missionInfo.rewards then
                    for _, reward in pairs(missionInfo.rewards) do
                        -- Match criteria based on selected filters from the options page (Ace3 settings)
                        if filterCriteria == "followerXP" and reward.followerXP then
                            includeMission = true
                            break
                        elseif filterCriteria == "garrisonResources" and reward.currencyID == 824 then
                            includeMission = true
                            break
                        elseif filterCriteria == "armorUpgrades" and reward.itemID and tContains({118531, 118529}, reward.itemID) then
                            includeMission = true
                            break
                        -- Add more criteria as needed
                        end
                    end
                end

                if includeMission then
                    print("Mission ID:", missionInfo.missionID, "Name:", missionInfo.name)

                    -- Debug output for rewards
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
            TLDRG.DebugPrint("Invalid mission entry found in FetchDetailedMissionInfo.")
        end
    end

    return detailedMissions
end
