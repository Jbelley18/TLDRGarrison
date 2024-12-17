local _, ns = ...
local TLDG = ns.TLDRGarrison

TLDG.MissionData = {
    -- Cache of current missions
    missions = {},
    
    -- Mission reward types
    REWARD_TYPE = {
        GOLD = 1,
        RESOURCES = 2,
        XP = 3,
        ITEM = 4,
        FOLLOWER_XP = 5,
    },
    
    -- Mission priorities
    priorities = {},
}

local MD = TLDG.MissionData

function MD:Initialize()
    self:RegisterEvents()
    self:RefreshMissions()
end

function MD:RegisterEvents()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("GARRISON_MISSION_LIST_UPDATE")
    frame:RegisterEvent("GARRISON_MISSION_STARTED")
    frame:RegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE")
    frame:SetScript("OnEvent", function(_, event, ...)
        if self[event] then
            self[event](self, ...)
        end
    end)
end

-- Event handlers
function MD:GARRISON_MISSION_LIST_UPDATE()
    self:RefreshMissions()
end

function MD:GARRISON_MISSION_STARTED(missionId)
    self:RemoveMission(missionId)
end

function MD:GARRISON_MISSION_COMPLETE_RESPONSE(missionId, success)
    self:RemoveMission(missionId)
end

-- Mission management functions
function MD:RefreshMissions()
    local missions = C_Garrison.GetAvailableMissions(Enum.GarrisonFollowerType.FollowerType_6_0)
    self.missions = {}
    
    for _, mission in ipairs(missions) do
        self:ProcessMissionData(mission)
    end
    
    self:UpdateMissionPriorities()
end

function MD:ProcessMissionData(mission)
    local data = {
        id = mission.missionID,
        name = mission.name,
        level = mission.level,
        iLevel = mission.iLevel,
        cost = mission.cost,
        duration = mission.durationSeconds,
        numFollowers = mission.numFollowers,
        rewards = self:ProcessRewards(mission.rewards),
        enemies = self:ProcessEnemies(mission.enemies),
        type = mission.type,
    }
    
    -- Calculate base priority score
    data.priority = self:CalculateBasePriority(data)
    
    self.missions[data.id] = data
end

function MD:ProcessRewards(rewards)
    local processed = {}
    
    for _, reward in pairs(rewards) do
        local rewardData = {
            type = self:DetermineRewardType(reward),
            quantity = reward.quantity,
            itemID = reward.itemID,
            currencyID = reward.currencyID,
            followerXP = reward.followerXP,
        }
        table.insert(processed, rewardData)
    end
    
    return processed
end

function MD:DetermineRewardType(reward)
    if reward.currencyID == 0 then
        return self.REWARD_TYPE.GOLD
    elseif reward.currencyID == 824 then -- Garrison Resources
        return self.REWARD_TYPE.RESOURCES
    elseif reward.followerXP then
        return self.REWARD_TYPE.FOLLOWER_XP
    elseif reward.itemID then
        return self.REWARD_TYPE.ITEM
    end
    return self.REWARD_TYPE.XP
end

function MD:ProcessEnemies(enemies)
    local processed = {}
    
    for _, enemy in ipairs(enemies) do
        local enemyData = {
            mechanics = {},
        }
        
        -- Process enemy mechanics (abilities that need to be countered)
        for _, mechanic in ipairs(enemy.mechanics) do
            table.insert(enemyData.mechanics, {
                mechanicID = mechanic.mechanicID,
                counter = mechanic.counter,
            })
        end
        
        table.insert(processed, enemyData)
    end
    
    return processed
end

function MD:CalculateBasePriority(missionData)
    local priority = 0
    
    -- Base priority from mission level/ilevel
    priority = priority + (missionData.iLevel or missionData.level)
    
    -- Adjust based on rewards
    for _, reward in ipairs(missionData.rewards) do
        local rewardMult = self:GetRewardMultiplier(reward.type)
        priority = priority + (reward.quantity or 1) * rewardMult
    end
    
    -- Adjust based on duration (prefer shorter missions slightly)
    priority = priority * (1 - (missionData.duration / (24 * 60 * 60)) * 0.1)
    
    return priority
end

function MD:GetRewardMultiplier(rewardType)
    -- Configure reward type priorities
    local multipliers = {
        [self.REWARD_TYPE.GOLD] = TLDG:GetConfig("prioritizeGold") and 2 or 1,
        [self.REWARD_TYPE.RESOURCES] = TLDG:GetConfig("prioritizeResources") and 2 or 1,
        [self.REWARD_TYPE.XP] = 1,
        [self.REWARD_TYPE.FOLLOWER_XP] = TLDG:GetConfig("prioritizeXP") and 1.5 or 1,
        [self.REWARD_TYPE.ITEM] = 1.5,
    }
    return multipliers[rewardType] or 1
end

function MD:UpdateMissionPriorities()
    local prioritized = {}
    
    -- Convert missions table to array for sorting
    for _, mission in pairs(self.missions) do
        table.insert(prioritized, mission)
    end
    
    -- Sort by priority
    table.sort(prioritized, function(a, b)
        return a.priority > b.priority
    end)
    
    self.priorities = prioritized
end

function MD:GetTopMissions(count)
    local result = {}
    count = count or 5
    
    for i=1, min(count, #self.priorities) do
        table.insert(result, self.priorities[i])
    end
    
    return result
end

function MD:RemoveMission(missionId)
    self.missions[missionId] = nil
    self:UpdateMissionPriorities()
end

-- Initialize mission data management
TLDG:RegisterCallback("OnInitialize", function()
    MD:Initialize()
end)