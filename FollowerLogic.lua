-- FollowerLogic.lua

TLDRGarrison = TLDRGarrison or {}
TLDRGarrison.FollowerLogic = TLDRGarrison.FollowerLogic or {}

local FollowerLogic = TLDRGarrison.FollowerLogic
local FollowerTraits = TLDRGarrison.FollowerTraits

-- Function to retrieve mission threats (mechanics)
local function GetMissionThreats(missionID)
    local missions = C_Garrison.GetAvailableMissions(1)  -- Use follower type ID 1 for WoD
    local missionInfo = nil

    -- Find the mission with the specified missionID
    for _, mission in ipairs(missions) do
        if mission.missionID == missionID then
            missionInfo = mission
            break
        end
    end

    if missionInfo and missionInfo.mechanics then
        return missionInfo.mechanics, missionInfo
    else
        print("No threats found for mission ID:", missionID)
        return nil, missionInfo
    end
end

-- Function to find followers for a mission
function FollowerLogic.FindFollowersForMission(missionID)
    print("Finding followers for mission ID:", missionID)
    local threats, missionInfo = GetMissionThreats(missionID)
    if not threats then
        print("No threats to counter for mission ID:", missionID)
        return {}
    end

    -- Print threats for debugging
    print("Threats for Mission ID:", missionID)
    for threatID, threatInfo in pairs(threats) do
        print("  Threat ID:", threatID, "Name:", threatInfo.name)
    end

    -- Get all available followers for WoD (followerTypeID = 1)
    local followers = C_Garrison.GetFollowers(1)
    local availableFollowers = {}
    for _, follower in ipairs(followers) do
        if follower.isCollected and not follower.status then
            availableFollowers[follower.followerID] = follower
        end
    end

    local assignedFollowers = {}
    local usedFollowers = {}

    -- Assign followers to counter threats
    for threatID, threatInfo in pairs(threats) do
        local found = false
        for followerID, follower in pairs(availableFollowers) do
            if FollowerTraits.CanFollowerCounter(followerID, tonumber(threatID)) then
                table.insert(assignedFollowers, follower)
                availableFollowers[followerID] = nil -- Remove follower to prevent reuse
                usedFollowers[followerID] = true
                found = true
                print("Assigned follower:", follower.name, "to counter threat:", threatInfo.name)
                break
            end
        end
        if not found then
            print("No follower found to counter threat:", threatInfo.name, "(ID:", threatID, ")")
            -- Decide how to handle this case
            -- For example, you might proceed without countering all threats or skip the mission
        end
    end

    -- If fewer followers are assigned than required, fill the rest
    local numFollowersRequired = missionInfo.numFollowers or 3
    while #assignedFollowers < numFollowersRequired and next(availableFollowers) do
        local followerID, follower = next(availableFollowers)
        table.insert(assignedFollowers, follower)
        availableFollowers[followerID] = nil
        print("Assigned follower:", follower.name, "to fill empty slot.")
    end

    -- Return the list of assigned followers
    return assignedFollowers
end

-- Return the FollowerLogic table if needed
-- return FollowerLogic
