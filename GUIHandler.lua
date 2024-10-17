-- Reference the global TLDRG tables
local _, GH = ...
local GH = TLDRG.GUIHandler
local G = TLDRG.GUI
local ML = TLDRG.MissionLogic
local FL = TLDRG.FilterLogic
local FT = TLDRG.FollowerTraits -- Ensure that this is correctly referencing the FollowerTraits

-- Verify that FT is initialized
if not FT or not FT.GetMissionMechanics then
    print("Error: FT (FollowerTraits) or FT.GetMissionMechanics is not properly initialized.")
end

-- ========================
-- Checkbox Handling Section
-- ========================

-- Attach the OnClick handlers to the checkboxes after they are created
local function AttachCheckboxHandlers()
    -- Ensure G.checkboxes is initialized
    if not G.checkboxes then
        print("Error: G.checkboxes is not initialized.")
        return
    end

    -- Attach OnClick handlers to checkboxes
    for _, checkbox in ipairs(G.checkboxes) do
        checkbox:SetScript("OnClick", function(self)
            local isChecked = self:GetChecked()
            print("Checkbox '" .. checkbox.Text:GetText() .. "' clicked. State: " .. tostring(isChecked))
        end)
    end
end

-- Define the function normally
local function GetSelectedCheckboxes()
    local selected = {}
    for _, checkbox in ipairs(G.checkboxes) do
        if checkbox:GetChecked() then
            selected[checkbox.Text:GetText()] = true
        end
    end

    -- Debug output to verify selected checkboxes
    print("Selected checkboxes after pressing start:")
    for key, value in pairs(selected) do
        print("  " .. key .. " -> " .. tostring(value))
    end

    return selected
end

-- Make it globally accessible via G table
G.GetSelectedCheckboxes = GetSelectedCheckboxes
print("GetSelectedCheckboxes has been defined and attached to G")

-- Initialize the checkbox handlers (ensure G.checkboxes exists before calling this)
AttachCheckboxHandlers()


-- ========================
-- Garrison Events Section
-- ========================

local function ShowTLDRGarrisonFrame()
    if not G.mainFrame then
        G.CreateMainFrame()
    end

    if G.mainFrame then
        G.mainFrame:Show()
    else
        print("TLDRGarrison frame not available")
    end
end

local function HideTLDRGarrisonFrame()
    if G.mainFrame then
        G.mainFrame:Hide()
        if G.AdvancedFrame and G.AdvancedFrame:IsShown() then
            G.AdvancedFrame:Hide()
        end
    else
        print("TLDRGarrison frame not available to hide")
    end
end

local function RegisterGarrisonEvents()
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("GARRISON_MISSION_NPC_OPENED")
    eventFrame:RegisterEvent("GARRISON_MISSION_NPC_CLOSED")
    eventFrame:SetScript("OnEvent", function(_, event)
        if event == "GARRISON_MISSION_NPC_OPENED" then
            ShowTLDRGarrisonFrame()
        elseif event == "GARRISON_MISSION_NPC_CLOSED" then
            HideTLDRGarrisonFrame()
        end
    end)
end

-- ========================
-- Button Handling Section
-- ========================

local function OnStartCompleteButtonClick()
    -- Fetch all available missions
    local missions = ML.FetchAndPrintMissions()

    if missions then
        -- Get selected checkboxes (reward types)
        local selectedCheckboxes = GetSelectedCheckboxes()
        print("StartCompleteButton pressed. Selected checkboxes:")

        -- Filter the missions based on the selected reward types
        local filteredMissions = FL.FilterMissionsByRewardType(missions, selectedCheckboxes)

        -- Loop through filtered missions and fetch mechanics using FT
        for _, mission in ipairs(filteredMissions) do
            print("Filtered Mission ID:", mission.missionID)
            local mechanics = FT.GetMissionMechanics(mission.missionID)
            if mechanics and #mechanics > 0 then
                print("Mission Mechanics:")
                for _, mechanic in ipairs(mechanics) do
                    print("Mechanic Name:", mechanic.name, "Description:", mechanic.description)
                end
            else
                print("No mechanics found for Mission ID:", mission.missionID)
            end
        end
    else
        print("No missions fetched.")
    end
end




local function SetButtonHandlers()
    -- Ensure the main frame is created by the GUI module (TLDRG.GUI)
    if not G.mainFrame then
        G.CreateMainFrame()  -- Make sure to call the function from TLDRG.GUI
    end

    -- Attach checkbox handlers only after the main frame and checkboxes are created
    AttachCheckboxHandlers()

    local startCompleteButton = G.StartCompleteButton  -- Reference the StartCompleteButton from G (GUI)
    print("StartCompleteButton in SetButtonHandlers:", startCompleteButton ~= nil)
    if startCompleteButton then
        startCompleteButton:SetScript("OnClick", OnStartCompleteButtonClick)
    else
        print("StartCompleteButton is not available.")
    end
end



-- Call this function to set button handlers during initialization
SetButtonHandlers()
RegisterGarrisonEvents()
