-- FollowerLogic.lua

-- Initialize FollowerLogic if not already initialized
TLDRGarrison = TLDRGarrison or {}
TLDRGarrison.FollowerLogic = TLDRGarrison.FollowerLogic or {}

local FollowerTraits = TLDRGarrison.FollowerTraits

-- Function to find followers for a mission
function TLDRGarrison.FollowerLogic.FindFollowersForMission(missionID)
    print("Finding followers for mission ID:", missionID)
    local mission = C_Garrison.GetBasicMissionInfo(missionID)
    if not mission then
        print("Mission not found for mission ID:", missionID)
        return {}
    end

    local mechanics = mission.mechanics
    if not mechanics or next(mechanics) == nil then
        print("No mechanics found for mission ID:", missionID)
        return {}
    end

    -- Get all available followers
    local followers = C_Garrison.GetFollowers(Enum.GarrisonFollowerType.FollowerType_6_0)
    local matchingFollowers = {}

    -- Track followers who can counter mechanics
    local availableFollowers = {}
    for _, follower in ipairs(followers) do
        if follower.isCollected and not follower.status then
            table.insert(availableFollowers, follower)
        end
    end

    -- For each mechanic, find followers who can counter it
    for mechanicID, mechanicInfo in pairs(mechanics) do
        local counterFound = false
        for index, follower in ipairs(availableFollowers) do
            if FollowerTraits.CanFollowerCounter(follower.followerID, tonumber(mechanicID)) then
                table.insert(matchingFollowers, follower)
                table.remove(availableFollowers, index)  -- Remove the follower to prevent reuse
                counterFound = true
                break  -- Move to the next mechanic
            end
        end
        if not counterFound then
            print("No follower found to counter mechanic:", mechanicInfo.name, "(ID:", mechanicID, ")")
            -- You can decide how to handle this case; perhaps return an empty table
            return {}
        end
    end

    return matchingFollowers
end
