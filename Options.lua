-- Initialize Ace3
local AceAddon = LibStub("AceAddon-3.0"):NewAddon("TLDRGarrison", "AceConsole-3.0", "AceEvent-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDB = LibStub("AceDB-3.0")

-- Initialize saved variables using AceDB
TLDRG_SavedSettings = TLDRG_SavedSettings or {}
AceAddon.db = AceDB:New("TLDRG_SavedSettings", {
    profile = {
        autoStartMissions = false,
        filterMissions = {
            garrisonResources = false,
            followerXP = false,
            rareItems = false,
        },
        debugMode = false,
    }
}, true)

-- Options table for the config panel
local options = {
    name = "TLDR Garrison Options",
    handler = AceAddon,
    type = 'group',
    args = {
        autoStartMissions = {
            type = 'toggle',
            name = "Enable Auto Start Missions",
            desc = "Automatically start all missions that match filters.",
            get = function(info) return AceAddon.db.profile.autoStartMissions end,
            set = function(info, value) AceAddon.db.profile.autoStartMissions = value end,
        },
        filterMissions = {
            type = 'multiselect',
            name = "Filter Mission Types",
            desc = "Select which mission types to prioritize.",
            values = {
                garrisonResources = "Garrison Resources",
                followerXP = "Follower XP",
                rareItems = "Rare Items",
            },
            get = function(info, key) return AceAddon.db.profile.filterMissions[key] end,
            set = function(info, key, value) AceAddon.db.profile.filterMissions[key] = value end,
        },
        debugMode = {
            type = 'toggle',
            name = "Enable Debug Mode",
            desc = "Toggle debug information for troubleshooting.",
            get = function(info) return AceAddon.db.profile.debugMode end,
            set = function(info, value) AceAddon.db.profile.debugMode = value end,
        },
        -- Add more settings as needed
    },
}

-- Register the options table with AceConfig
AceConfig:RegisterOptionsTable("TLDRGarrison", options)

-- Add the options panel to the Blizzard AddOn interface using AceConfigDialog
AceConfigDialog:AddToBlizOptions("TLDRGarrison", "TLDR Garrison")

-- Set up slash command to open the options window
AceAddon:RegisterChatCommand("tldrg", function()
    AceConfigDialog:Open("TLDRGarrison")
end)
