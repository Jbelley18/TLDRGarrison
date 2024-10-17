-- Reference the global TLDRG tables
local _, FT = ...
TLDRG.FollowerTraits = FT
local FT = TLDRG.FollowerTraits or {}
-- Reference other tables from TLDRG
local FL = TLDRG.FilterLogic or {}
local ML = TLDRG.MissionLogic or {}
local GH = TLDRG.GUIHandler or {}


-- Mapping of mechanics to counter abilities, traits, and specializations
FT.MechanicCounterMapping = {
    [2] = { -- Massive Strike
        counterAbilityNames = {"Divine Shield", "Evasion", "Ice Block"},
        counterAbilityIDs = {123, 456, 789},  -- Replace with actual ability IDs.
        traitsRequired = {"Resilient", "Iron Will"},
        specModifiers = {
            ["Protection Paladin"] = 10,
            ["Fury Warrior"] = 5
        }
    },
    [7] = { -- Minion Swarms
        counterAbilityNames = {"Cleave", "Divine Storm", "Fan of Knives"},
        counterAbilityIDs = {321, 654, 987},
        traitsRequired = {"Leader of Men", "Savage"},
        specModifiers = {
            ["Arms Warrior"] = 10,
            ["Retribution Paladin"] = 5
        }
    }
}

-- Environment bonuses mapping
FT.EnvironmentBonuses = {
    ["Mountainous"] = {
        bonus = 5,
        traits = {"Mountaineer", "Survivalist"},
    },
    ["Swamp"] = {
        bonus = 5,
        traits = {"Marshwalker"},
    },
    ["Forest"] = {
        bonus = 3,
        traits = {"Nature's Ally", "Tracker"},
    }
}

--- Function to get the mechanics of a mission by missionID
function FT.GetMissionMechanics(missionID)
    local missionDeployment = C_Garrison.GetMissionDeploymentInfo(missionID)
    if missionDeployment and missionDeployment.enemies then
        local mechanics = {}
        for _, enemy in ipairs(missionDeployment.enemies) do
            if enemy.mechanics then
                for _, mechanic in pairs(enemy.mechanics) do
                    table.insert(mechanics, {
                        mechanicTypeID = mechanic.mechanicTypeID,
                        name = mechanic.name,
                        description = mechanic.description,
                        icon = mechanic.icon
                    })
                end
            end
        end
        if #mechanics > 0 then
            print("Mission Mechanics:")
            for _, mechanic in ipairs(mechanics) do
                print("Mechanic Type ID:", mechanic.mechanicTypeID, "Name:", mechanic.name, "Description:", mechanic.description)
            end
        else
            print("No mechanics found.")
        end
        return mechanics
    end
    print("No mechanics found.")
    return nil
end

--- Function to find potential followers that can counter a mission's mechanics
function FT.GetPotentialFollowerMatches(missionID)
    local potentialMatches = {}
    local missionMechanics = FT.GetMissionMechanics(missionID)
    local missionEnvironment = C_Garrison.GetMissionDeploymentInfo(missionID).locTextureKit

    -- Validate the mission mechanics
    if not missionMechanics or #missionMechanics == 0 then
        print("No mechanics found for mission ID:", missionID)
        return potentialMatches
    end

    -- Retrieve all collected followers
    local followers = C_Garrison.GetFollowers(1)

    for _, follower in ipairs(followers) do
        if follower.isCollected then
            local abilities = C_Garrison.GetFollowerAbilities(follower.followerID)
            local traits = FT.GetFollowerTraits(follower.followerID)

            for _, mechanic in ipairs(missionMechanics) do
                local counterInfo = FT.MechanicCounterMapping[mechanic.mechanicTypeID]

                if counterInfo then
                    for _, ability in ipairs(abilities) do
                        if tContains(counterInfo.counterAbilityNames, ability.name) then
                            -- Check for trait bonuses
                            local hasTraitBonus = false
                            for _, requiredTrait in ipairs(counterInfo.traitsRequired or {}) do
                                if tContains(traits, requiredTrait) then
                                    hasTraitBonus = true
                                    break
                                end
                            end

                            -- Check for environment bonuses
                            local envBonus = 0
                            local envInfo = FT.EnvironmentBonuses[missionEnvironment]
                            if envInfo and tContains(traits, envInfo.traits) then
                                envBonus = envInfo.bonus
                            end

                            -- Add the follower as a potential match
                            table.insert(potentialMatches, {
                                followerName = follower.name,
                                abilityName = ability.name,
                                mechanicName = mechanic.name,
                                hasTraitBonus = hasTraitBonus,
                                environmentBonus = envBonus
                            })
                            print("Match found for mechanic:", mechanic.name)
                            print("  Follower:", follower.name, "| Ability:", ability.name)
                        else
                            print("No match for this counter.")
                        end
                    end
                end
            end
        end
    end

    -- Display the results
    if #potentialMatches == 0 then
        print("No followers found that can counter mechanics for mission ID:", missionID)
    else
        print("Potential matches for mission ID:", missionID)
        for _, match in ipairs(potentialMatches) do
            print("Follower:", match.followerName, "| Ability:", match.abilityName, "| Counters:", match.mechanicName)
            print("  Trait Bonus:", match.hasTraitBonus and "Yes" or "No", "| Environment Bonus:", match.environmentBonus)
        end
    end

    return potentialMatches
end

-- Function to filter missions, get their mechanics, and find potential followers
function FL.FilterAndMatchMissions(missions, selectedRewardTypes)
    -- Step 1: Filter the missions based on selected reward types
    local filteredMissions = FL.FilterMissionsByRewardType(missions, selectedRewardTypes)

    -- Step 2: Iterate over the filtered missions
    for _, mission in ipairs(filteredMissions) do
        print("Filtered Mission ID:", mission.missionID)

        -- Step 3: Get the mechanics of the mission
        local mechanics = FT.GetMissionMechanics(mission.missionID)
        
        if mechanics and #mechanics > 0 then
            print("Mission Mechanics:")
            for _, mechanic in ipairs(mechanics) do
                print("Mechanic Name:", mechanic.name, "Description:", mechanic.description)
            end

            -- Step 4: Get potential followers that can counter the mission mechanics
            local potentialMatches = FT.GetPotentialFollowerMatches(mission.missionID)
            
            if #potentialMatches > 0 then
                print("Potential matches for mission ID:", mission.missionID)
                for _, match in ipairs(potentialMatches) do
                    print("Follower:", match.followerName, "| Ability:", match.abilityName, "| Counters:", match.mechanicName)
                end
            else
                print("No followers found that can counter mechanics for mission ID:", mission.missionID)
            end
        else
            print("No mechanics found for Mission ID:", mission.missionID)
        end
    end
end

if not GH.GetSelectedCheckboxes then
    print("GetSelectedCheckboxes is nil in FollowerTraits.lua")
else
    print("GetSelectedCheckboxes is available in FollowerTraits.lua")
end


-- Adjust the slash command to use the new logic
SLASH_TLDRMATCH1 = "/tldrmatch"
SlashCmdList["TLDRMATCH"] = function(msg)
    local missionID = tonumber(msg)
    if not missionID then
        print("Please provide a valid mission ID. Usage: /tldrmatch <missionID>")
        return
    end

    -- Get the selected reward types from the checkboxes
    local selectedRewardTypes = GH.GetSelectedCheckboxes()

    -- Fetch available missions using the existing mission fetching logic
    local missions = ML.FetchAndPrintMissions()

    -- Validate the missions and selected reward types
    if missions and #missions > 0 then
        if next(selectedRewardTypes) then
            -- Run the integrated flow to filter missions and find matches
            FL.FilterAndMatchMissions(missions, selectedRewardTypes)
        else
            print("No reward types selected. Please select at least one reward type.")
        end
    else
        print("No available missions found.")
    end
end
