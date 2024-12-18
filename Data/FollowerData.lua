local _, ns = ...
local TLDG = ns.TLDRGarrison

TLDG.FollowerData = {
    -- Constants
    MAX_FOLLOWER_LEVEL = 100,
    MAX_FOLLOWER_ITEM_LEVEL = 675,
    FOLLOWER_ITEM_LEVEL_BASE = 600,
    
    -- Cache of follower data
    followers = {},
    missionFollowers = {},
}

local FD = TLDG.FollowerData

-- Initialize follower data management
function FD:Initialize()
    self:RegisterEvents()
    self:RefreshFollowerData()
end

function FD:RegisterEvents()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE")
    frame:RegisterEvent("GARRISON_FOLLOWER_XP_CHANGED")
    frame:RegisterEvent("GARRISON_FOLLOWER_UPGRADED")
    frame:SetScript("OnEvent", function(_, event, ...)
        if self[event] then
            self[event](self, ...)
        end
    end)
end

-- Event handlers
function FD:GARRISON_FOLLOWER_LIST_UPDATE()
    self:RefreshFollowerData()
end

function FD:GARRISON_FOLLOWER_XP_CHANGED(followerId, xpChange, oldXP, oldLevel)
    self:UpdateFollowerXP(followerId, xpChange, oldXP, oldLevel)
end

function FD:GARRISON_FOLLOWER_UPGRADED(followerId)
    self:RefreshFollowerData(followerId)
end

-- Data management functions
function FD:RefreshFollowerData(specificFollowerId)
    -- Get followers of type 6.0 (WoD Garrison)
    local rawFollowers = C_Garrison.GetFollowers(Enum.GarrisonFollowerType.FollowerType_6_0)
    
    if not rawFollowers then
        -- If we can't get followers yet, try again in a moment
        C_Timer.After(0.5, function() self:RefreshFollowerData(specificFollowerId) end)
        return
    end
    
    if specificFollowerId then
        -- Update specific follower
        for _, follower in ipairs(rawFollowers) do
            if follower.followerID == specificFollowerId then
                self:ProcessFollowerData(follower)
                break
            end
        end
    else
        -- Update all followers
        wipe(self.followers)
        for _, follower in ipairs(rawFollowers) do
            if follower then -- Safety check for nil followers
                self:ProcessFollowerData(follower)
            end
        end
    end
    
    self:UpdateMissionTeams()
end

function FD:ProcessFollowerData(follower)
    if not follower or not follower.isCollected or not follower.followerID then return end
    
    local followerId = follower.followerID
    local data = {
        id = followerId,
        level = follower.level or 0,
        iLevel = follower.iLevel or 0,
        quality = follower.quality or 0,
        status = follower.status,
        name = follower.name or "Unknown",
        abilities = {},
        counters = {},
        traits = {},
    }
    
    -- Process abilities
    for i=1, 4 do
        local abilityId = C_Garrison.GetFollowerAbilityAtIndex(followerId, i)
        if abilityId then
            if C_Garrison.GetFollowerAbilityIsTrait(abilityId) then
                table.insert(data.traits, abilityId)
            else
                local counterInfo = C_Garrison.GetFollowerAbilityCounterMechanicInfo(abilityId)
                if counterInfo then
                    table.insert(data.counters, counterInfo)
                end
                table.insert(data.abilities, abilityId)
            end
        end
    end
    
    -- Calculate effectiveness scores
    data.effectiveLevel = self:CalculateEffectiveLevel(data)
    data.counterScore = self:CalculateCounterScore(data)
    
    self.followers[followerId] = data
end

function FD:CalculateEffectiveLevel(followerData)
    if not followerData then return 0 end
    if followerData.level < self.MAX_FOLLOWER_LEVEL then
        return followerData.level
    else
        return self.FOLLOWER_ITEM_LEVEL_BASE + followerData.iLevel
    end
end

function FD:CalculateCounterScore(followerData)
    if not followerData then return 0 end
    local score = 0
    local uniqueCounters = {}
    
    -- Score based on number and variety of counters
    for _, counter in ipairs(followerData.counters or {}) do
        if not uniqueCounters[counter] then
            uniqueCounters[counter] = true
            score = score + 1
        else
            score = score + 0.5 -- Reduced value for duplicate counters
        end
    end
    
    -- Bonus for certain valuable traits
    for _, trait in ipairs(followerData.traits or {}) do
        if self:IsValuableTrait(trait) then
            score = score + 0.5
        end
    end
    
    return score
end

function FD:IsValuableTrait(traitId)
    -- List of particularly valuable traits
    local valuableTraits = {
        [79] = true,  -- Extra Training
        [236] = true, -- Epic Mount
        [221] = true, -- Burst of Power
    }
    return valuableTraits[traitId] or false
end

function FD:GetAvailableFollowers()
    local available = {}
    for id, data in pairs(self.followers) do
        if data and (data.status == nil or data.status == GARRISON_FOLLOWER_IN_PARTY) then
            table.insert(available, data)
        end
    end
    return available
end

function FD:GetFollowersByCounter(mechanicId)
    local matching = {}
    for _, data in pairs(self.followers) do
        if data and data.counters then
            for _, counter in ipairs(data.counters) do
                if counter == mechanicId then
                    table.insert(matching, data)
                    break
                end
            end
        end
    end
    return matching
end

-- Team composition functions
function FD:UpdateMissionTeams()
    self.missionFollowers = {}
    local available = self:GetAvailableFollowers()
    
    -- Sort by effectiveness
    table.sort(available, function(a, b)
        if a.effectiveLevel == b.effectiveLevel then
            return a.counterScore > b.counterScore
        end
        return a.effectiveLevel > b.effectiveLevel
    end)
    
    -- Store top performers for quick access
    for i=1, min(#available, 20) do
        table.insert(self.missionFollowers, available[i])
    end
end

function FD:GetOptimalTeam(mission, requiredCounters)
    if not mission then return {} end
    local team = {}
    local available = self:GetAvailableFollowers()
    local neededCounters = requiredCounters or {}
    
    -- First pass: match required counters
    for counterId in pairs(neededCounters) do
        local bestFollower = self:GetBestFollowerForCounter(available, counterId)
        if bestFollower then
            table.insert(team, bestFollower)
            self:RemoveFollowerFromAvailable(available, bestFollower.id)
        end
    end
    
    -- Second pass: fill remaining slots with highest effectiveness
    while #team < (mission.numFollowers or 0) and #available > 0 do
        table.insert(team, table.remove(available, 1))
    end
    
    return team
end

function FD:GetBestFollowerForCounter(availableFollowers, counterId)
    if not availableFollowers or not counterId then return nil end
    local best = nil
    local bestScore = -1
    
    for _, follower in ipairs(availableFollowers) do
        if follower and follower.counters then
            for _, counter in ipairs(follower.counters) do
                if counter == counterId then
                    local score = follower.effectiveLevel + follower.counterScore
                    if score > bestScore then
                        best = follower
                        bestScore = score
                    end
                    break
                end
            end
        end
    end
    
    return best
end

function FD:RemoveFollowerFromAvailable(available, followerId)
    if not available or not followerId then return end
    for i, follower in ipairs(available) do
        if follower.id == followerId then
            table.remove(available, i)
            break
        end
    end
end

-- Helper functions for external use
function FD:GetFollowerInfo(followerId)
    if followerId then
        return self.followers[followerId]
    end
    return self.followers
end

function FD:GetFollowerList()
    local list = {}
    for _, follower in pairs(self.followers) do
        if follower then
            table.insert(list, follower)
        end
    end
    return list
end

-- Initialize follower data management
TLDG:RegisterCallback("OnInitialize", function()
    FD:Initialize()
end)