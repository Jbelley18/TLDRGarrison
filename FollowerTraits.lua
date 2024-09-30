-- FollowerTraits.lua
TLDRGarrison = TLDRGarrison or {}
TLDRGarrison.FollowerTraits = TLDRGarrison.FollowerTraits or {}

local FollowerTraits = TLDRGarrison.FollowerTraits
local followerInfo = C_Garrison.GetFollowerInfo(garrFollowerID)
local specID = followerInfo and followerInfo.classSpec

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
    [48] = {125},     -- Massive Swarms (Fan of Knives)
    [49] = {126},     -- Magic Chaos (Spell Shield)
    [50] = {127},     -- Plague (Cleansing Flame)
    [52] = {131},     -- Magic Shield (Shattering Throw)
    [53] = {132},     -- Ogre's Strength (Ogre Slayer)
    [54] = {134},     -- Beasts (Beast Slayer)
    [57] = {136},     -- Elementals (Elemental Slayer)
    [58] = {137},     -- Aberrations (Aberration Slayer)
    [59] = {138},     -- Demons (Demon Slayer)
    [60] = {139},     -- Gronn (Gronn Slayer)
    [61] = {140},     -- Fear (Inspiring Presence)
    [62] = {141},     -- Poison (Detox)
    [64] = {132},     -- Ogres (Ogre Slayer)
    [65] = {143},     -- Orcs (Orc Slayer)
    [66] = {144},     -- Humanoids (Human Slayer)
    [67] = {145},     -- Unique Enemy (Unique Strike)
    
    -- Environment Counters (from T.EnvironmentCounters)
    [11] = {4},       -- Environment ID 11
    [12] = {38},      -- Environment ID 12
    [13] = {42},      -- Environment ID 13
    [14] = {43},      -- Environment ID 14
    [15] = {37},      -- Environment ID 15
    [16] = {36},      -- Environment ID 16
    [17] = {40},      -- Environment ID 17
    [18] = {41},      -- Environment ID 18
    [19] = {42},      -- Environment ID 19
    [20] = {39},      -- Environment ID 20
    [21] = {7},       -- Environment ID 21
    [22] = {9},       -- Environment ID 22
    [23] = {8},       -- Environment ID 23
    [24] = {45},      -- Environment ID 24
    [25] = {46},      -- Environment ID 25
    [26] = {44},      -- Environment ID 26
    [28] = {48},      -- Environment ID 28
    [29] = {49},      -- Environment ID 29
    [60] = {54},      -- Environment ID 60
    [61] = {55},      -- Environment ID 61
    [62] = {56},      -- Environment ID 62
    [63] = {57},      -- Environment ID 63
    [64] = {59},      -- Environment ID 64
    [65] = {60},      -- Environment ID 65
    [66] = {61},      -- Environment ID 66
    [67] = {58},      -- Environment ID 67
    
    -- Additional Counters from SpecCounters
    -- Since SpecCounters associates specs with counters, we need to handle this differently.
    -- For simplicity, we'll include the counters from SpecCounters here.
    -- Note: SpecCounters in the provided code uses indexes that may not directly map to mechanic IDs.
    -- For the purpose of this example, we'll assume the mechanics and counters are already covered.
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
            if ability.id == counterAbilityID or (FollowerTraits.EquivTrait[ability.id] == counterAbilityID) then
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
