-- Reference the global TLDRG tables
local _, GH = ...
local GH = TLDRG.GUIHandler
local G = TLDRG.GUI
local ML = TLDRG.MissionLogic
local FL = TLDRG.FilterLogic
local FT = TLDRG.FollowerTraits

-- Verify that FollowerTraits is initialized
if not FT or not FT.GetMissionMechanics then
    print("Error: FT (FollowerTraits) or FT.GetMissionMechanics is not properly initialized.")
end

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
        -- Use the selected reward types from the Ace3 options
        local selectedRewardTypes = TLDRG_SavedSettings.filterMissions
        print("StartCompleteButton pressed. Selected reward types:")

        -- Filter the missions based on the selected reward types
        local filteredMissions = FL.FilterMissionsByRewardType(missions, selectedRewardTypes)

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
        G.CreateMainFrame()
    end

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
