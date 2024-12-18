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
    if not C_Garrison then return end
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
    if missionId then
        self:RemoveMission(missionId)
    end
end

function MD:GARRISON_MISSION_COMPLETE_RESPONSE(missionId, success)
    if missionId then
        self:RemoveMission(missionId)
    end
end

-- Mission management functions
-- Only changing the RefreshMissions function, rest remains the same
function MD:RefreshMissions()
    -- Get available missions with proper follower type
    -- Garrison follower type ID 1 is for WoD Garrisons
    local missions = C_Garrison.GetAvailableMissions(1)  -- Changed this line
    if not missions then return end
    
    wipe(self.missions)
    
    for _, mission in ipairs(missions) do
        if mission and mission.missionID then
            self:ProcessMissionData(mission)
        end
    end
    
    self:UpdateMissionPriorities()
end

function MD:ProcessMissionData(mission)
    if not mission or not mission.missionID then return end
    
    local data = {
        id = mission.missionID,
        name = mission.name or "Unknown Mission",
        level = mission.level or 0,
        iLevel = mission.iLevel or 0,
        cost = mission.cost or 0,
        duration = mission.durationSeconds or 0,
        numFollowers = mission.numFollowers or 0,
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
    
    if type(rewards) ~= "table" then return processed end
    
    for _, reward in pairs(rewards) do
        if reward then
            local rewardData = {
                type = self:DetermineRewardType(reward),
                quantity = reward.quantity or 0,
                itemID = reward.itemID,
                currencyID = reward.currencyID,
                followerXP = reward.followerXP,
            }
            table.insert(processed, rewardData)
        end
    end
    
    return processed
end

function MD:DetermineRewardType(reward)
    if not reward then return self.REWARD_TYPE.XP end
    
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
    
    if type(enemies) ~= "table" then return processed end
    
    for _, enemy in ipairs(enemies) do
        if enemy and enemy.mechanics then
            local enemyData = {
                mechanics = {},
            }
            
            for _, mechanic in ipairs(enemy.mechanics) do
                if mechanic then
                    table.insert(enemyData.mechanics, {
                        mechanicID = mechanic.mechanicID,
                        counter = mechanic.counter,
                    })
                end
            end
            
            table.insert(processed, enemyData)
        end
    end
    
    return processed
end

function MD:CalculateBasePriority(missionData)
    if not missionData then return 0 end
    
    local priority = 0
    
    -- Base priority from mission level/ilevel
    priority = priority + (missionData.iLevel or missionData.level or 0)
    
    -- Adjust based on rewards
    if missionData.rewards then
        for _, reward in ipairs(missionData.rewards) do
            local rewardMult = self:GetRewardMultiplier(reward.type)
            priority = priority + (reward.quantity or 1) * rewardMult
        end
    end
    
    -- Adjust based on duration (prefer shorter missions slightly)
    local duration = missionData.duration or (24 * 60 * 60)
    priority = priority * (1 - (duration / (24 * 60 * 60)) * 0.1)
    
    return priority
end

function MD:GetRewardMultiplier(rewardType)
    -- Configure reward type priorities with safe defaults
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
        if mission and mission.priority then
            table.insert(prioritized, mission)
        end
    end
    
    -- Sort by priority
    table.sort(prioritized, function(a, b)
        return (a.priority or 0) > (b.priority or 0)
    end)
    
    self.priorities = prioritized
end

function MD:GetTopMissions(count)
    local result = {}
    count = count or 5
    
    if not self.priorities then
        self:UpdateMissionPriorities()
    end
    
    for i=1, min(count, #self.priorities) do
        table.insert(result, self.priorities[i])
    end
    
    return result
end

function MD:RemoveMission(missionId)
    if not missionId then return end
    self.missions[missionId] = nil
    self:UpdateMissionPriorities()
end

-- Initialize mission data management
TLDG:RegisterCallback("OnInitialize", function()
    MD:Initialize()
end)