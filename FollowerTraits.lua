-- FollowerTraits.lua
TLDRGarrison = TLDRGarrison or {}
TLDRGarrison.FollowerTraits = TLDRGarrison.FollowerTraits or {}

local FollowerTraits = TLDRGarrison.FollowerTraits

-- Mapping of follower traits to counters or abilities
-- Example: Danger Zones, Massive Strike, etc.
FollowerTraits.Counters = {
    ["Danger Zones"] = {
        121,  -- Trait IDs or ability IDs that counter Danger Zones
        122,
        -- Add more as needed
    },
    ["Massive Strike"] = {
        100,  -- Trait IDs or ability IDs that counter Massive Strike
        101,
        -- Add more as needed
    },
    ["Deadly Minions"] = {
        133,
        134,
        -- Add more as needed
    },
    -- Continue adding counters here based on the mission threats
}

-- Function to return followers that can counter a specific mission threat
function FollowerTraits.GetFollowersForCounter(counter)
    return FollowerTraits.Counters[counter] or {}
end

-- Function to get the traits of a follower
-- Documentation: WoWAPI/Blizzard_GarrisonUI.lua
function FollowerTraits.GetFollowerTraits(followerID)
    local traits = {}
    local abilities = C_Garrison.GetFollowerAbilities(followerID)
    for _, ability in ipairs(abilities) do
        table.insert(traits, ability.id)
    end
    return traits
end

-- Function to check if a follower can counter a specific mission threat
-- Documentation: WoWAPI/Blizzard_GarrisonUI.lua
function FollowerTraits.CanFollowerCounter(followerID, counter)
    local traits = FollowerTraits.GetFollowerTraits(followerID)
    local counterTraits = FollowerTraits.GetFollowersForCounter(counter)
    for _, trait in ipairs(traits) do
        for _, counterTrait in ipairs(counterTraits) do
            if trait == counterTrait then
                return true
            end
        end
    end
    return false
end
