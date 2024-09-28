-- Initialize FollowerLogic if not already initialized
TLDRGarrison = TLDRGarrison or {}
TLDRGarrison.FollowerLogic = TLDRGarrison.FollowerLogic or {}

local FollowerTraits = TLDRGarrison.FollowerTraits

-- Simplified function to get the required counters for a mission
local function GetMissionCounters(missionID)
    -- Replace G.GetCounterInfo with C_Garrison.GetMissionEncounterIconInfo for testing
    local counters = C_Garrison.GetMissionEncounterIconInfo(missionID)
    if not counters then
        print("No counters found for mission ID:", missionID)
        return nil
    end
    return counters
end

-- Function to print follower abilities for debugging purposes
local function PrintFollowerAbilities(follower)
    print("Follower ID:", follower.followerID, "Name:", follower.name, "Abilities:")
    local ability1 = C_Garrison.GetFollowerAbilityAtIndex(follower.followerID, 1)
    local ability2 = C_Garrison.GetFollowerAbilityAtIndex(follower.followerID, 2)
    print("  Ability 1:", ability1)
    print("  Ability 2:", ability2)
end

-- Function to find followers with counters that match the mission requirements
function TLDRGarrison.FollowerLogic.FindFollowersForMission(missionID, missionType)
    print("Finding followers for mission ID:", missionID, "with mission type:", missionType)  -- Debug print

    -- Get the required counters for the mission
    local counters = FollowerTraits.GetFollowersForCounter(missionType)
    if not counters or #counters == 0 then
        print("No valid counters for mission type:", missionType)
        return {}
    end

    -- Find followers that can counter the mission
    local matchingFollowers = {}
    local followers = C_Garrison.GetFollowers(1)  -- Assuming 1 is the followerTypeID for garrison

    for _, follower in ipairs(followers) do
        if follower.isCollected and FollowerTraits.CanFollowerCounter(follower.followerID, missionType) then
            table.insert(matchingFollowers, follower)
        end
    end

    return matchingFollowers
end
