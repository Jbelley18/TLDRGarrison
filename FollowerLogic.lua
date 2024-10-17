local F = TLDRG.FollowerLogic  -- Reference the initialized global table


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
function F.FindFollowersForMission(missionID)
    print("Finding followers for mission ID:", missionID)
    local threats, missionInfo = GetMissionThreats(missionID)
    if not missionInfo then
        print("Mission not found for mission ID:", missionID)
        return {}
    end

    if not threats or next(threats) == nil then
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
            if FT.CanFollowerCounter(followerID, tonumber(threatID)) then
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

    return assignedFollowers
end

-- Function to fetch abilities for collected followers
function F.GetFollowerAbilities()
    local followers = C_Garrison.GetFollowers()
    local followerAbilities = {}

    for _, follower in ipairs(followers) do
        if follower.isCollected then
            local abilities = C_Garrison.GetFollowerAbilities(follower.followerID)
            followerAbilities[follower.followerID] = abilities
            -- Debug print for followers and abilities
            FunctionDebugPrint("GetFollowerAbilities", "Follower: " .. follower.name .. " Follower ID: " .. follower.followerID)
            for _, ability in ipairs(abilities) do
                FunctionDebugPrint("GetFollowerAbilities", " - Ability: " .. ability.name .. " ID: " .. ability.id)
            end
        end
    end

    return followers, followerAbilities
end

-- Function to find followers that can counter mission mechanics
function F.MatchFollowersToMechanics(missionMechanics, followers, followerAbilities)
    for _, mechanic in ipairs(missionMechanics) do
        local mechanicID = mechanic.mechanicTypeID
        local counters = FT.Counters[mechanicID]

        if counters then
            FunctionDebugPrint("MatchFollowersToMechanics", "Checking for counters to mechanic: " .. mechanic.name)
            for followerID, abilities in pairs(followerAbilities) do
                for _, ability in ipairs(abilities) do
                    if tContains(counters, ability.id) then
                        local followerName = ""
                        for _, follower in ipairs(followers) do
                            if follower.followerID == followerID then
                                followerName = follower.name
                                break
                            end
                        end
                        FunctionDebugPrint("MatchFollowersToMechanics", "Follower: " .. followerName .. " can counter: " .. mechanic.name .. " with ability: " .. ability.name)
                    end
                end
            end
        else
            FunctionDebugPrint("MatchFollowersToMechanics", "No counters found for mechanic: " .. mechanic.name)
        end
    end
end
