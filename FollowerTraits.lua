-- Reference the global TLDRG tables
local _, FT = ...
local FT = TLDRG.FollowerTraits or {}
TLDRG.FollowerTraits = FT

-- Reference other tables from TLDRG
local FL = TLDRG.FilterLogic or {}
local ML = TLDRG.MissionLogic or {}
local GH = TLDRG.GUIHandler or {}

-- Mapping of mechanics to counter abilities, traits, and specializations
FT.MechanicCounterMapping = {
    [2] = { -- Massive Strike
        counterAbilityNames = {"Divine Shield", "Evasion", "Ice Block"},
        traitsRequired = {"Resilient", "Iron Will"},
        specModifiers = {
            ["Protection Paladin"] = 10,
            ["Fury Warrior"] = 5
        }
    },
    [7] = { -- Minion Swarms
        counterAbilityNames = {"Cleave", "Divine Storm", "Fan of Knives"},
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
        return mechanics
    end
    return nil
end

--- Function to find potential followers that can counter a mission's mechanics
function FT.GetPotentialFollowerMatches(missionID)
    local potentialMatches = {}
    local missionMechanics = FT.GetMissionMechanics(missionID)
    local missionEnvironment = C_Garrison.GetMissionDeploymentInfo(missionID).locTextureKit

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

                            table.insert(potentialMatches, {
                                followerName = follower.name,
                                abilityName = ability.name,
                                mechanicName = mechanic.name,
                                hasTraitBonus = hasTraitBonus,
                                environmentBonus = envBonus
                            })
                            print("Match found for mechanic:", mechanic.name)
                            print("  Follower:", follower.name, "| Ability:", ability.name)
                        end
                    end
                end
            end
        end
    end

    return potentialMatches
end

-- Adjust the slash command to use the new logic
SLASH_TLDRMATCH1 = "/tldrmatch"
SlashCmdList["TLDRMATCH"] = function(msg)
    local missionID = tonumber(msg)
    if not missionID then
        print("Please provide a valid mission ID. Usage: /tldrmatch <missionID>")
        return
    end

    local selectedRewardTypes = TLDRG_SavedSettings.filterMissions  -- Use saved settings for reward types
    local missions = ML.FetchAndPrintMissions()

    if missions and #missions > 0 then
        FL.FilterAndMatchMissions(missions, selectedRewardTypes)
    else
        print("No available missions found.")
    end
end
