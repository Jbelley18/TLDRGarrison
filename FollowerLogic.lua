-- FollowerLogic.lua

TLDRGarrison = TLDRGarrison or {}
TLDRGarrison.FollowerLogic = TLDRGarrison.FollowerLogic or {}

local FollowerLogic = TLDRGarrison.FollowerLogic
local FollowerTraits = TLDRGarrison.FollowerTraits

local function GetMissionThreats(missionID)
    local missionInfo = C_Garrison.GetBasicMissionInfo(missionID)
    if not missionInfo then
        print("Mission not found for mission ID:", missionID)
        return nil, nil
    end

    -- Get mission deployment info to access enemies and their mechanics
    local _, _, _, _, _, _, _, enemies = C_Garrison.GetMissionDeploymentInfo(missionID)
    local mechanics = {}

    if enemies then
        for _, enemy in ipairs(enemies) do
            if enemy.mechanics then
                for _, mechanicInfo in pairs(enemy.mechanics) do
                    local mechanicID = mechanicInfo.mechanicTypeID
                    if mechanicID then
                        mechanics[mechanicID] = mechanicInfo
                    end
                end
            end
        end
    end

    if next(mechanics) ~= nil then
        return mechanics, missionInfo
    else
        print("No threats found for mission ID:", missionID)
        return nil, missionInfo
    end
end


-- Function to find followers for a mission
function FollowerLogic.FindFollowersForMission(missionID)
    print("Finding followers for mission ID:", missionID)
    local threats, missionInfo = GetMissionThreats(missionID)
    if not missionInfo then
        print("Mission not found for mission ID:", missionID)
        return {}
    end

    if not threats or next(threats) == nil then
        print("No threats to counter for mission ID:", missionID)
        -- Proceed to assign followers based on other criteria if desired
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
