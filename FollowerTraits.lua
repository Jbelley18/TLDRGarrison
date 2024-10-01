-- FollowerTraits.lua
TLDRGarrison = TLDRGarrison or {}
TLDRGarrison.FollowerTraits = TLDRGarrison.FollowerTraits or {}

local FollowerTraits = TLDRGarrison.FollowerTraits

-- Mapping of mission mechanics (threats) to the ability IDs that counter them
FollowerTraits.Counters = {
    -- Standard Threat Counters
    [36] = {108},     -- Timed Battle (Burst of Power)
    [37] = {116},     -- Powerful Spell (Magic Debuff)
    [38] = {114},     -- Deadly Minions (Blind)
    [39] = {102},     -- Massive Strike (Taunt)
    [40] = {120},     -- Danger Zones (Environmental Suit)
    [41] = {100},     -- Wild Aggression (Shield Wall)
    [42] = {112},     -- Group Damage (Group Heal)
    [44] = {122},     -- Magic Debuff (Dispel Magic)
    [45] = {104},     -- Powerful Enemy (Execute)
    [46] = {110},     -- Minion Swarms (Multi-Shot)
    -- Add more mappings as needed
}

-- Equivalence mapping for traits
FollowerTraits.EquivTrait = {
    [244] = 4,     -- Trait 244 is equivalent to 4
    [250] = 221,   -- Trait 250 is equivalent to 221
    [228] = 48,    -- Trait 228 is equivalent to 48
    [227] = 48,    -- Trait 227 is equivalent to 48
    [303] = 202,   -- Trait 303 is equivalent to 202
    [286] = 283,   -- Trait 286 is equivalent to 283
    [293] = 292,   -- Trait 293 is equivalent to 292
}

-- Specialization counters
FollowerTraits.SpecCounters = {
    [2] = {1, 2, 7, 8, 10},
    [3] = {1, 4, 7, 8, 10},
    [4] = {1, 2, 7, 8, 10},
    -- Add more mappings as needed
}

-- Function to get the traits of a follower
function FollowerTraits.GetFollowerTraits(garrFollowerID)
    local abilities = C_Garrison.GetFollowerAbilities(garrFollowerID)
    if not abilities then
        print("No abilities found for follower ID:", garrFollowerID)
        return {}
    end
    local traits = {}
    for _, ability in pairs(abilities) do
        table.insert(traits, ability.id)
    end
    return traits
end

-- Function to check if a follower can counter a specific mission threat
function FollowerTraits.CanFollowerCounter(garrFollowerID, mechanicID)
    local abilities = C_Garrison.GetFollowerAbilities(garrFollowerID)
    local followerInfo = C_Garrison.GetFollowerInfo(garrFollowerID)
    local specID = followerInfo and followerInfo.classSpec
    if not abilities or not specID then return false end

    local counterAbilities = FollowerTraits.Counters[mechanicID] or {}
    local specCounters = FollowerTraits.SpecCounters[specID] or {}

    -- Check abilities and traits
    for _, ability in pairs(abilities) do
        for _, counterAbilityID in ipairs(counterAbilities) do
            if ability.id == counterAbilityID or FollowerTraits.EquivTrait[ability.id] == counterAbilityID then
                return true
            end
        end
    end

    -- Check specialization counters
    for _, specCounterID in ipairs(specCounters) do
        if specCounterID == mechanicID then
            return true
        end
    end

    return false
end

-- Additional tables and functions as needed...


FollowerTraits.SpecCounters = {
    [2] = {1, 2, 7, 8, 10},
    [3] = {1, 4, 7, 8, 10},
    [4] = {1, 2, 7, 8, 10},
    [5] = {6, 7, 9, 10},
    [7] = {1, 2, 6, 10},
    [8] = {1, 2, 6, 9},
    [9] = {3, 4, 7, 9},
    [10] = {1, 6, 7, 9, 10},
    [12] = {6, 7, 8, 9, 10},
    [13] = {2, 6, 7, 9, 10},
    [14] = {6, 8, 9, 10},
    [15] = {6, 7, 8, 9, 10},
    [16] = {2, 7, 8, 9, 10},
    [17] = {1, 2, 3, 6, 9},
    [18] = {3, 4, 6, 8},
    [19] = {1, 6, 8, 9, 10},
    [20] = {3, 4, 8, 9},
    [21] = {1, 2, 4, 8, 9},
    [22] = {2, 7, 8, 9, 10},
    [23] = {3, 4, 6, 9},
    [24] = {3, 4, 6, 7},
    [25] = {4, 6, 7, 9, 10},
    [26] = {2, 6, 8, 9, 10},
    [27] = {6, 7, 8, 9, 10},
    [28] = {2, 6, 7, 8, 9},
    [29] = {3, 7, 8, 9, 10},
    [30] = {3, 6, 7, 9, 10},
    [31] = {3, 4, 7, 8},
    [32] = {4, 7, 8, 9, 10},
    [33] = {2, 7, 8, 10, 10},
    [34] = {3, 8, 9, 10, 10},
    [35] = {1, 6, 7, 8, 10},
    [37] = {2, 6, 7, 8, 10},
    [38] = {1, 2, 6, 7, 8}
}


-- Equivalence mapping for traits (from T.EquivTrait)
FollowerTraits.EquivTrait = {
    [244] = 4,     -- Trait 244 is equivalent to 4
    [250] = 221,   -- Trait 250 is equivalent to 221
    [228] = 48,    -- Trait 228 is equivalent to 48
    [227] = 48,    -- Trait 227 is equivalent to 48
    [303] = 202,   -- Trait 303 is equivalent to 202
    [286] = 283,   -- Trait 286 is equivalent to 283
    [293] = 292,   -- Trait 293 is equivalent to 292
}

-- Trait cost mapping (from T.TraitCost)
FollowerTraits.TraitCost = {
    [47] = 4,    -- High cost trait
    [248] = 3,
    [256] = 3,
    [79] = 2,
    [80] = 1,
    [236] = 1,
    [287] = -5,  -- Negative cost indicates undesirable traits
    [290] = -5,
    [305] = -3,
    [315] = 1,
    [327] = 1,
    [275] = -1,
    [283] = 2,
    [286] = 2,
}

-- Lock traits mapping (from T.LockTraits)
FollowerTraits.LockTraits = {
    [47] = true,
    [231] = true,
    [227] = true,
    [228] = true,
    [244] = true,
    [248] = true,
    [324] = true,
    [325] = true,
    [326] = true,
    [201] = true,
    [303] = true,
}

-- Always active traits (from T.AlwaysTraits)
FollowerTraits.AlwaysTraits = {
    [221] = true,
    [201] = true,
    [202] = true,
    [47]  = true,
}

-- Additional tables from the addon code can be included as needed.
-- For example, if you need to handle environment bonuses or mission interests,
-- you can integrate them here following the same pattern.

-- If you need to map equipment counters or ship-related mechanics, you can add those as well.
-- However, since your addon focuses on garrison missions and followers, we can omit ship-related data.

-- You can also include the SpecCounters if needed, but it requires careful mapping to ensure correctness.
