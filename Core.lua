local addonName, ns = ...
ns.TLDRGarrison = {}
local TLDG = ns.TLDRGarrison

-- Addon initialization
function TLDG:OnLoad()
    self.db = TLDRGarrisonDB or {}
    TLDRGarrisonDB = self.db
    
    self:InitializeConfig()
    
    -- Initialize modules in correct order
    if self.FollowerData then
        self.FollowerData:Initialize()
    end
    
    if self.MissionData then
        self.MissionData:Initialize()
    end
    
    if self.UI then
        self.UI:Initialize()
    end
    
    if self.FollowerList then
        self.FollowerList:Initialize()
    end
    
    if self.AutoComplete then
        self.AutoComplete:Initialize()
    end
    
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
    if self.UI and self.UI.UpdateDisplay then
        self.UI:UpdateDisplay()
    end
end

function TLDG:GARRISON_MISSION_LIST_UPDATE()
    if self.UI and self.UI.UpdateDisplay then
        self.UI:UpdateDisplay()
    end
end

function TLDG:GARRISON_FOLLOWER_LIST_UPDATE()
    if self.UI and self.UI.UpdateDisplay then
        self.UI:UpdateDisplay()
    end
end

-- Initialize addon
local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function()
    TLDG:OnLoad()
end)