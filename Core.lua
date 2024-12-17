local addonName, ns = ...
ns.TLDRGarrison = {}
local TLDG = ns.TLDRGarrison

-- Addon initialization
function TLDG:OnLoad()
    self.db = TLDRGarrisonDB or {}
    TLDRGarrisonDB = self.db
    
    self:InitializeConfig()
    self:InitializeUI()
    
    -- Register events
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("GARRISON_MISSION_NPC_OPENED")
    frame:RegisterEvent("GARRISON_MISSION_LIST_UPDATE")
    frame:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE")
    
    frame:SetScript("OnEvent", function(_, event, ...)
        if self[event] then
            self[event](self, ...)
        end
    end)
    
    self.frame = frame
end

-- Core event handlers
function TLDG:GARRISON_MISSION_NPC_OPENED()
    self:UpdateMissionList()
end

function TLDG:GARRISON_MISSION_LIST_UPDATE()
    self:UpdateMissionList()
end

function TLDG:GARRISON_FOLLOWER_LIST_UPDATE()
    self:UpdateFollowerList()
end

-- Initialize addon
local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function()
    TLDG:OnLoad()
end)