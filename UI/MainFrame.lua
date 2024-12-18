local _, ns = ...
local TLDG = ns.TLDRGarrison

TLDG.UI = {}
local UI = TLDG.UI

function UI:Initialize()
    -- Wait for Blizzard_GarrisonUI to load
    if not C_Garrison then
        return
    end
    
    local isLoaded = C_AddOns and C_AddOns.IsAddOnLoaded("Blizzard_GarrisonUI") or IsAddOnLoaded and IsAddOnLoaded("Blizzard_GarrisonUI")
    
    if isLoaded then
        self:OnGarrisonUILoaded()
    else
        local frame = CreateFrame("Frame")
        frame:RegisterEvent("ADDON_LOADED")
        frame:SetScript("OnEvent", function(_, _, addonName)
            if addonName == "Blizzard_GarrisonUI" then
                self:OnGarrisonUILoaded()
                frame:UnregisterAllEvents()
            end
        end)
    end
end

function UI:OnGarrisonUILoaded()
    if not GarrisonMissionFrame then return end
    self:CreateMainFrame()
    self:CreateMissionList()
    self:RegisterEvents()
end

function UI:UpdateDisplay()
    -- Check if mainFrame exists
    if not self.mainFrame or not self.mainFrame:IsShown() then return end
    
    -- Clear existing mission entries
    for _, child in ipairs({self.missionList:GetChildren()}) do
        child:Hide()
    end
    
    -- Get prioritized missions
    local missions = TLDG.MissionData:GetTopMissions(10)
    
    -- Create/update mission entries
    local previousButton
    for i, mission in ipairs(missions) do
        local button = self.missionList:GetChildren()[i] or self:CreateMissionEntry(mission)
        button:Show()
        
        if previousButton then
            button:SetPoint("TOPLEFT", previousButton, "BOTTOMLEFT", 0, -5)
        else
            button:SetPoint("TOPLEFT", 5, -5)
        end
        
        -- Update success chance if we have a team calculated
        local team = TLDG.FollowerData:GetOptimalTeam(mission)
        if team then
            local chance = C_Garrison.GetMissionSuccessChance(mission.id)
            button.successText:SetText(chance .. "%")
            button.successText:SetTextColor(chance >= 90 and 0 or 1, chance >= 90 and 1 or 0, 0)
        else
            button.successText:SetText("")
        end
        
        previousButton = button
    end
    
    -- Update scrollchild height
    if previousButton then
        self.missionList:SetHeight(previousButton:GetBottom() * -1 + 10)
    end
    
    -- Update status text
    local numMissions = #missions
    local numFollowers = #(TLDG.FollowerData:GetAvailableFollowers() or {})
    self.mainFrame.statusText:SetText(string.format("%d missions available\n%d followers ready", numMissions, numFollowers))
end

-- Add these helper functions at the end
function UI:IsReady()
    return self.mainFrame ~= nil
end

function UI:EnsureLoaded()
    if not self:IsReady() then
        self:Initialize()
    end
end

-- Rest of your MainFrame.lua code remains the same...
function UI:CreateMainFrame()
    local frame = CreateFrame("Frame", "TLDRGarrisonFrame", GarrisonMissionFrame, "BackdropTemplate")
    frame:SetSize(250, 500)
    frame:SetPoint("TOPLEFT", GarrisonMissionFrame, "TOPRIGHT", 5, 0)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    
    -- Create background
    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetAllPoints()
    frame.bg:SetColorTexture(0, 0, 0, 0.8)
    
    -- Create border
    frame:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
    
    -- Create header
    local header = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", 10, -10)
    header:SetText("TLDR Garrison")
    
    -- Create control buttons
    local startButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    startButton:SetSize(100, 25)
    startButton:SetPoint("TOPLEFT", 10, -40)
    startButton:SetText("Start Auto")
    startButton:SetScript("OnClick", function()
        self:StartAutoMissions()
    end)
    
    local settingsButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    settingsButton:SetSize(100, 25)
    settingsButton:SetPoint("TOPRIGHT", -10, -40)
    settingsButton:SetText("Settings")
    settingsButton:SetScript("OnClick", function()
        self:ToggleSettings()
    end)
    
    -- Create status text
    frame.statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.statusText:SetPoint("TOP", 0, -70)
    frame.statusText:SetWidth(230)
    frame.statusText:SetJustifyH("CENTER")
    
    -- Store reference to main frame
    self.mainFrame = frame
    
    -- Show/hide with mission frame
    frame:SetScript("OnShow", function()
        self:UpdateDisplay()
    end)
    
    -- Hook the garrison mission frame
    local function OnGarrisonFrameShow()
        frame:Show()
        self:UpdateDisplay()
    end
    
    local function OnGarrisonFrameHide()
        frame:Hide()
    end
    
    GarrisonMissionFrame:HookScript("OnShow", OnGarrisonFrameShow)
    GarrisonMissionFrame:HookScript("OnHide", OnGarrisonFrameHide)
end

-- Empty stub functions that will be implemented later
function UI:CreateMissionList()
end

function UI:RegisterEvents()
end

function UI:UpdateDisplay()
end

function UI:StartAutoMissions()
end

function UI:ToggleSettings()
end

-- Initialize UI when the addon loads
TLDG:RegisterCallback("OnInitialize", function()
    UI:Initialize()
end)

-- Rest of your MainFrame.lua code remains the same...
function UI:CreateMissionList()
    local frame = self.mainFrame
    
    -- Create scrollframe for mission list
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -100)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)
    
    local scrollChild = CreateFrame("Frame")
    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetWidth(scrollFrame:GetWidth())
    scrollChild:SetHeight(1) -- Will be adjusted dynamically
    
    self.missionList = scrollChild
    self.scrollFrame = scrollFrame
end

function UI:CreateMissionEntry(mission)
    local button = CreateFrame("Button", nil, self.missionList)
    button:SetSize(200, 50)
    
    -- Background highlight
    button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    
    -- Mission name
    local name = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    name:SetPoint("TOPLEFT", 5, -5)
    name:SetText(mission.name)
    
    -- Mission info (level, followers, duration)
    local info = button:CreateFontString(nil, "OVERLAY", "GameFontSmall")
    info:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -2)
    info:SetTextColor(0.8, 0.8, 0.8)
    
    local duration = SecondsToTime(mission.duration)
    local levelText = mission.iLevel and ("i"..mission.iLevel) or ("Lvl "..mission.level)
    info:SetText(string.format("%s | %d followers | %s", levelText, mission.numFollowers, duration))
    
    -- Rewards summary
    local rewards = button:CreateFontString(nil, "OVERLAY", "GameFontSmall")
    rewards:SetPoint("BOTTOMLEFT", 5, 5)
    rewards:SetTextColor(1, 0.82, 0)
    rewards:SetText(self:GetRewardsSummary(mission))
    
    -- Success chance
    local success = button:CreateFontString(nil, "OVERLAY", "GameFontSmall")
    success:SetPoint("BOTTOMRIGHT", -5, 5)
    success:SetTextColor(0, 1, 0)
    
    -- Click handler
    button:SetScript("OnClick", function()
        self:SelectMission(mission)
    end)
    
    -- Store references
    button.mission = mission
    button.successText = success
    
    return button
end

function UI:GetRewardsSummary(mission)
    local summary = {}
    for _, reward in ipairs(mission.rewards) do
        if reward.type == TLDG.MissionData.REWARD_TYPE.GOLD then
            table.insert(summary, GetMoneyString(reward.quantity))
        elseif reward.type == TLDG.MissionData.REWARD_TYPE.RESOURCES then
            table.insert(summary, reward.quantity .. " GR")
        elseif reward.type == TLDG.MissionData.REWARD_TYPE.FOLLOWER_XP then
            table.insert(summary, reward.quantity .. " XP")
        elseif reward.type == TLDG.MissionData.REWARD_TYPE.ITEM then
            local itemName = C_Item.GetItemNameByID(reward.itemID) or "Item"
            table.insert(summary, itemName)
        end
    end
    return table.concat(summary, " | ")
end

function UI:UpdateDisplay()
    if not self.mainFrame:IsShown() then return end
    
    -- Clear existing mission entries
    for _, child in ipairs({self.missionList:GetChildren()}) do
        child:Hide()
    end
    
    -- Get prioritized missions
    local missions = TLDG.MissionData:GetTopMissions(10)
    
    -- Create/update mission entries
    local previousButton
    for i, mission in ipairs(missions) do
        local button = self.missionList:GetChildren()[i] or self:CreateMissionEntry(mission)
        button:Show()
        
        if previousButton then
            button:SetPoint("TOPLEFT", previousButton, "BOTTOMLEFT", 0, -5)
        else
            button:SetPoint("TOPLEFT", 5, -5)
        end
        
        -- Update success chance if we have a team calculated
        local team = TLDG.FollowerData:GetOptimalTeam(mission)
        if team then
            local chance = C_Garrison.GetMissionSuccessChance(mission.id)
            button.successText:SetText(chance .. "%")
            button.successText:SetTextColor(chance >= 90 and 0 or 1, chance >= 90 and 1 or 0, 0)
        else
            button.successText:SetText("")
        end
        
        previousButton = button
    end
    
    -- Update scrollchild height
    if previousButton then
        self.missionList:SetHeight(previousButton:GetBottom() * -1 + 10)
    end
    
    -- Update status text
    local numMissions = #missions
    local numFollowers = #TLDG.FollowerData:GetAvailableFollowers()
    self.mainFrame.statusText:SetText(string.format("%d missions available\n%d followers ready", numMissions, numFollowers))
end

function UI:SelectMission(mission)
    -- Show the mission in the default UI
    GarrisonMissionFrame:ShowMission(mission.id)
    
    -- Get and assign optimal team
    local team = TLDG.FollowerData:GetOptimalTeam(mission)
    if team then
        for i, follower in ipairs(team) do
            C_Garrison.AddFollowerToMission(mission.id, follower.id)
        end
    end
end

function UI:StartAutoMissions()
    local missions = TLDG.MissionData:GetTopMissions(5)
    local startedCount = 0
    
    for _, mission in ipairs(missions) do
        local team = TLDG.FollowerData:GetOptimalTeam(mission)
        if team then
            local chance = C_Garrison.GetMissionSuccessChance(mission.id)
            if chance >= TLDG:GetConfig("minimumSuccessChance") then
                -- Assign team
                for _, follower in ipairs(team) do
                    C_Garrison.AddFollowerToMission(mission.id, follower.id)
                end
                
                -- Start mission
                C_Garrison.StartMission(mission.id)
                startedCount = startedCount + 1
            end
        end
    end
    
    -- Update status
    self.mainFrame.statusText:SetText(string.format("Started %d missions", startedCount))
    self:UpdateDisplay()
end

function UI:RegisterEvents()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("GARRISON_MISSION_LIST_UPDATE")
    frame:RegisterEvent("GARRISON_MISSION_STARTED")
    frame:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE")
    
    frame:SetScript("OnEvent", function(_, event)
        if self.mainFrame:IsShown() then
            self:UpdateDisplay()
        end
    end)
end

-- Initialize UI when the addon loads
TLDG:RegisterCallback("OnInitialize", function()
    UI:Initialize()
end)