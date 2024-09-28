-- GUIHandler.lua

-- ========================
-- Checkbox Handling Section
-- ========================

local function GetSelectedCheckboxes()
    local selected = {}
    for _, checkbox in ipairs(TLDRGarrison.GUI.checkboxes) do
        if checkbox:GetChecked() then
            selected[checkbox.Text:GetText()] = true  -- Add checked checkbox label to selected table
        end
    end

    -- Debug: Print selected checkboxes
    if next(selected) then
        print("Selected Checkboxes:")
        for text in pairs(selected) do
            print("  " .. text)
        end
    else
        print("No checkboxes selected.")
    end

    return selected
end


local function LoadCheckboxStates()
    if TLDRGarrisonGlobalSavedVars and TLDRGarrisonGlobalSavedVars.CheckboxStates then
        for _, checkbox in ipairs(TLDRGarrison.GUI.Checkboxes) do
            local text = checkbox.Text:GetText()
            if TLDRGarrisonGlobalSavedVars.CheckboxStates[text] ~= nil then
                checkbox:SetChecked(TLDRGarrisonGlobalSavedVars.CheckboxStates[text])
            end
        end
    end
end

local function SaveCheckboxStates()
    TLDRGarrisonGlobalSavedVars = TLDRGarrisonGlobalSavedVars or {}
    TLDRGarrisonGlobalSavedVars.CheckboxStates = {}

    for _, checkbox in ipairs(TLDRGarrison.GUI.Checkboxes) do
        TLDRGarrisonGlobalSavedVars.CheckboxStates[checkbox.Text:GetText()] = checkbox:GetChecked()
    end
    print("Checkbox states saved.")
end

-- Initialize and load checkbox states
local function InitializeGUI()
    LoadCheckboxStates()
end

-- ========================
-- Garrison Events Section
-- ========================

-- Show the Garrison frame when interacting with the Garrison NPC
local function ShowTLDRGarrisonFrame()
    -- Create the main frame if it's not created yet
    if not TLDRGarrison.GUI.mainFrame then
        TLDRGarrison.GUI.CreateMainFrame()
    end

    if TLDRGarrison.GUI.mainFrame then
        TLDRGarrison.GUI.mainFrame:Show()
    else
        print("TLDRGarrison frame not available")
    end
end

local function HideTLDRGarrisonFrame()
    if TLDRGarrison.GUI.mainFrame then
        TLDRGarrison.GUI.mainFrame:Hide()
        if TLDRGarrison.GUI.AdvancedFrame and TLDRGarrison.GUI.AdvancedFrame:IsShown() then
            TLDRGarrison.GUI.AdvancedFrame:Hide()
        end
    else
        print("TLDRGarrison frame not available to hide")
    end
end

-- Event handler setup remains the same...



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
-- Function to handle the "Start/Complete All" button click in GUIHandler.lua
local function OnStartCompleteButtonClick()
    local missions = TLDRGarrison.MissionLogic.FetchAndPrintMissions()

    if missions then
        -- Get selected checkboxes (filters)
        local selectedCheckboxes = GetSelectedCheckboxes()

        -- Use FilterLogic to filter missions based on the selected reward types
        local filteredMissions = TLDRGarrison.FilterLogic.FilterMissionsByRewardType(missions, selectedCheckboxes)

        -- Debug output for filtered missions
        if filteredMissions and #filteredMissions > 0 then
            print("Filtered Missions:")
            for _, mission in ipairs(filteredMissions) do
                print("Filtered Mission ID:", mission.missionID)

                -- Call follower selection for each filtered mission
                TLDRGarrison.FollowerLogic.FindFollowersForMission(mission.missionID, mission.type)
            end
        else
            print("No missions match the selected reward types.")
        end
    else
        print("No missions fetched.")
    end
end

-- Set the Start/Complete button click event
local function SetButtonHandlers()
    local startCompleteButton = TLDRGarrison.GUI.StartCompleteButton -- Correct reference
    if startCompleteButton then
        startCompleteButton:SetScript("OnClick", OnStartCompleteButtonClick)
    else
        print("StartCompleteButton is not available.")
    end
end

-- Call this function to set button handlers during initialization
SetButtonHandlers()



-- ========================
-- Advanced Frame Handling Section
-- ========================

local function ToggleAdvancedFrame()
    local advancedToggleButton = TLDRGarrison.GUI.advancedToggleButton
    local advancedFrame = TLDRGarrison.GUI.AdvancedFrame

    if advancedToggleButton and advancedFrame then
        advancedToggleButton:SetScript("OnClick", function()
            if advancedFrame:IsShown() then
                advancedFrame:Hide()
                advancedToggleButton:SetText("Advanced")
            else
                advancedFrame:Show()
                advancedToggleButton:SetText("Hide Advanced")
            end
        end)
    else
        print("Advanced toggle button or advanced frame not found.")
    end
end

-- ========================
-- Slash Command Section
-- ========================

SLASH_TLDRGARRISON1 = "/TLDRGarrison"
SlashCmdList["TLDRGARRISON"] = function()
    if TLDRGarrison.GUI.Frame then
        TLDRGarrison.GUI.Frame:Show()
    else
        print("TLDRGarrison frame not initialized")
    end
end

-- ========================
-- Initializing Handlers Section
-- ========================

-- Ensure the mission logic file is loaded (only once)
local function LoadMissionLogic()
    local success, err = pcall(function() LoadAddOn("MissionLogic") end)
    if not success then
        print("Failed to load mission logic: " .. err)
    else
        print("Mission logic successfully loaded")
    end
end

local function InitializeGUIHandler()
    LoadMissionLogic()  -- Load mission logic first

    if not TLDRGarrison.GUI or not TLDRGarrison.GUI.mainFrame then
        print("Failed to load GUI or mainFrame is missing")
        return
    else
        print("GUI and mainFrame successfully loaded")
    end

    RegisterGarrisonEvents()  -- Set up Garrison events
    SetButtonHandlers()       -- Set Start/Complete button handler
    ToggleAdvancedFrame()     -- Set up advanced frame toggle logic
end

-- Call the Initialize GUI Handler function
InitializeGUIHandler()
