-- Options.lua
-- Define the global table for your addon if it doesn't already exist
_G.TLDRG = _G.TLDRG or {}
TLDRG.Options = TLDRG.Options or {}

-- Create a table to store settings if it doesn't exist
TLDRG_SavedSettings = TLDRG_SavedSettings or {}

-- Function to create the options panel
local function CreateOptionsPanel()
    local panel = CreateFrame("Frame", "TLDRGOptionsPanel", UIParent)
    panel.name = "TLDRGarrison"

    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("TLDR Garrison Options")

    -- Checkbox for Auto Start
    local autoStartCheckbox = CreateFrame("CheckButton", "TLDRGOptionAutoStartCheckbox", panel, "ChatConfigCheckButtonTemplate")
    autoStartCheckbox:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -16)
    autoStartCheckbox.Text:SetText("Enable Auto Start Missions")
    autoStartCheckbox:SetChecked(TLDRG_SavedSettings.autoStartMissions or false)

    -- Save the setting when checkbox is clicked
    autoStartCheckbox:SetScript("OnClick", function(self)
        TLDRG_SavedSettings.autoStartMissions = self:GetChecked()
        print("Auto Start Missions set to", TLDRG_SavedSettings.autoStartMissions)
    end)

    -- Add more options as needed...

    -- Register the panel in WoW's Interface Options
    InterfaceOptions_AddCategory(panel)
end

-- Call the function to create the panel
CreateOptionsPanel()
