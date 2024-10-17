-- Initialize the FilterLogic table
local FL = TLDRG.FilterLogic or {}
TLDRG.FilterLogic = FL

-- Reward type mapping for filtering logic
local rewardTypeMapping = {
    ["Armor/Weapon Upgrades"] = function(reward)
        local upgradeItemIDs = {118531, 118529, 120301, 120302}
        return reward.itemID and tContains(upgradeItemIDs, reward.itemID)
    end,
    ["Rare Items (Mounts, Pets, etc.)"] = function(reward)
        local rareItemIDs = {116763, 118516, 118100}
        return reward.itemID and tContains(rareItemIDs, reward.itemID)
    end,
    ["Garrison Resources"] = function(reward)
        return reward.currencyID == 824  -- Map "Garrison Resources" to the actual currency ID.
    end,
    ["Follower XP"] = function(reward)
        return reward.followerXP and reward.followerXP > 0
    end,
    ["Scribe Rush Order"] = function(reward)
        return reward.itemID == 122592  -- Item ID for Scribe's Quarters Work Order
    end,
}

-- Function to filter missions based on selected reward types from options
function FL.FilterMissionsByRewardType(missions)
    local selectedRewardTypes = TLDRG_SavedSettings.filterMissions  -- Fetch selected reward types from Ace3 options
    local filteredMissions = {}
    
    for _, mission in ipairs(missions) do
        local missionInfo = C_Garrison.GetBasicMissionInfo(mission.missionID)
        if missionInfo and missionInfo.rewards then
            local hasValidReward = FL.CheckRewards(missionInfo.rewards, selectedRewardTypes)
            if hasValidReward then
                table.insert(filteredMissions, missionInfo)
            end
        end
    end

    return filteredMissions
end

-- Function to check if a mission's rewards match selected reward types
function FL.CheckRewards(rewards, selectedRewardTypes)
    for _, reward in pairs(rewards) do
        for rewardType, isSelected in pairs(selectedRewardTypes) do
            if isSelected and rewardTypeMapping[rewardType] and rewardTypeMapping[rewardType](reward) then
                FunctionDebugPrint("CheckRewards", "Reward Type: " .. rewardType)
                return true
            end
        end
    end
    return false
end
