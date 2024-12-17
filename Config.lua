local _, ns = ...
local TLDG = ns.TLDRGarrison

-- Default configuration settings
local defaults = {
    enabled = true,
    autoComplete = true,
    minimumSuccessChance = 90,
    prioritizeResources = true,
    prioritizeGold = false,
    prioritizeXP = false,
    showMinimapButton = true,
}

function TLDG:InitializeConfig()
    -- Initialize saved variables with defaults
    if not TLDRGarrisonDB then
        TLDRGarrisonDB = {}
    end
    
    -- Merge defaults with saved settings
    for k, v in pairs(defaults) do
        if TLDRGarrisonDB[k] == nil then
            TLDRGarrisonDB[k] = v
        end
    end
    
    self.config = TLDRGarrisonDB
end

-- Configuration getters/setters
function TLDG:GetConfig(key)
    return self.config[key]
end

function TLDG:SetConfig(key, value)
    self.config[key] = value
    self:OnConfigChanged(key, value)
end

function TLDG:OnConfigChanged(key, value)
    -- Handle configuration changes
    if key == "showMinimapButton" then
        self:UpdateMinimapButton()
    end
    
    -- Trigger UI updates
    self:UpdateUI()
end