-- Initialize the FilterLogic table
TLDRGarrison = TLDRGarrison or {}
TLDRGarrison.FilterLogic = TLDRGarrison.FilterLogic or {}

-- Reward type mapping for filtering logic
local rewardTypeMapping = {
    ["Armor/Weapon Upgrades"] = function(reward)
        local upgradeItemIDs = {118531, 118529, 120301, 120302} -- Add all relevant item IDs
        return reward.itemID and tContains(upgradeItemIDs, reward.itemID)
    end,
    ["Rare Items (Mounts, Pets, etc.)"] = function(reward)
        local rareItemIDs = {116763, 118516, 118100} -- Add all relevant item IDs
        return reward.itemID and tContains(rareItemIDs, reward.itemID)
    end,
    ["Garrison Resources"] = function(reward)
        return reward.currencyID == 824 -- 824 is the currency ID for Garrison Resources
    end,
    ["Follower XP"] = function(reward)
        return reward.followerXP and reward.followerXP > 0
    end,
    ["Scribe Rush Order"] = function(reward)
        return reward.itemID == 122592 -- Item ID for Scribe's Quarters Work Order
    end,
    -- ["Follower XP"] = function(reward)
    --     return reward.followerXP and reward.followerXP > 500 -- Only include missions giving more than 500 XP
    -- end
}

-- Function to filter missions based on selected reward types
function TLDRGarrison.FilterLogic.FilterMissionsByRewardType(missions, selectedRewardTypes)
    local filteredMissions = {}

    for _, mission in ipairs(missions) do
        local missionInfo = C_Garrison.GetBasicMissionInfo(mission.missionID)
        if missionInfo and missionInfo.rewards then
            local hasValidReward = TLDRGarrison.FilterLogic.CheckRewards(missionInfo.rewards, selectedRewardTypes)
            if hasValidReward then
                table.insert(filteredMissions, missionInfo)
            end
        end
    end

    return filteredMissions
end

-- Check if the rewards of a mission match the selected reward types
function TLDRGarrison.FilterLogic.CheckRewards(rewards, selectedRewardTypes)
    for _, reward in pairs(rewards) do
        for rewardType, isSelected in pairs(selectedRewardTypes) do
            if isSelected and rewardTypeMapping[rewardType] and rewardTypeMapping[rewardType](reward) then
                return true  -- Found a valid reward
            end
        end
    end
    return false  -- No valid rewards found
end

-- Debug function to print Filtered Missions Counter info
