local _, ns = ...
local TLDG = ns.TLDRGarrison
local Utils = TLDG.Utils

TLDG.FollowerList = {}
local FL = TLDG.FollowerList

function FL:Initialize()
    self:CreateFollowerListFrame()
    self:RegisterEvents()
end

function FL:CreateFollowerListFrame()
    local frame = Utils:CreateFrame("Frame", "TLDRGarrisonFollowerList", GarrisonMissionFrame)
    frame:SetSize(300, 500)
    frame:SetPoint("TOPRIGHT", GarrisonMissionFrame, "TOPLEFT", -5, 0)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    
    -- Background and border
    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetAllPoints()
    frame.bg:SetColorTexture(0, 0, 0, 0.8)
    
    frame:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
    
    -- Header
    local header = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", 10, -10)
    header:SetText("TLDR Followers")
    
    -- Search box
    local searchBox = CreateFrame("EditBox", nil, frame, "SearchBoxTemplate")
    searchBox:SetSize(150, 20)
    searchBox:SetPoint("TOPRIGHT", -10, -10)
    searchBox:SetScript("OnTextChanged", function(self)
        FL:UpdateFilter(self:GetText())
    end)
    
    -- Sort dropdown
    local sortDropdown = CreateFrame("Frame", "TLDRGarrisonFollowerSort", frame, "UIDropDownMenuTemplate")
    sortDropdown:SetPoint("TOPLEFT", header, "BOTTOMLEFT", -16, -10)
    
    UIDropDownMenu_SetWidth(sortDropdown, 100)
    UIDropDownMenu_SetText(sortDropdown, "Sort by")
    
    UIDropDownMenu_Initialize(sortDropdown, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        
        local options = {
            {text = "Level", value = "level"},
            {text = "Item Level", value = "ilevel"},
            {text = "Name", value = "name"},
            {text = "Quality", value = "quality"},
            {text = "Status", value = "status"},
        }
        
        for _, option in ipairs(options) do
            info.text = option.text
            info.value = option.value
            info.checked = FL.currentSort == option.value
            info.func = function()
                FL.currentSort = option.value
                FL:UpdateSort()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    
    -- Filter buttons
    local filterContainer = CreateFrame("Frame", nil, frame)
    filterContainer:SetSize(280, 30)
    filterContainer:SetPoint("TOPLEFT", sortDropdown, "BOTTOMLEFT", 16, -5)
    
    local function CreateFilterButton(text, filter)
        local button = CreateFrame("Button", nil, filterContainer, "UIPanelButtonTemplate")
        button:SetSize(80, 22)
        button:SetText(text)
        button.filter = filter
        button:SetScript("OnClick", function(self)
            FL.currentFilter = self.filter
            FL:UpdateFilter()
        end)
        return button
    end
    
    local allButton = CreateFilterButton("All", "all")
    local availableButton = CreateFilterButton("Available", "available")
    local missionButton = CreateFilterButton("On Mission", "mission")
    
    allButton:SetPoint("LEFT", 0, 0)
    availableButton:SetPoint("LEFT", allButton, "RIGHT", 5, 0)
    missionButton:SetPoint("LEFT", availableButton, "RIGHT", 5, 0)
    
    -- Follower list scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", filterContainer, "BOTTOMLEFT", 0, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)
    
    local scrollChild = CreateFrame("Frame")
    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetWidth(scrollFrame:GetWidth())
    scrollChild:SetHeight(1) -- Will be adjusted dynamically
    
    -- Store references
    self.frame = frame
    self.scrollChild = scrollChild
    self.searchBox = searchBox
    self.currentSort = "level"
    self.currentFilter = "all"
    
    -- Create follower buttons pool
    self.followerPool = CreateFramePool("Button", scrollChild, nil, 
        function(pool, frame)
            frame:Hide()
            frame.follower = nil
        end
    )
end

function FL:CreateFollowerButton(follower)
    local button = CreateFrame("Button", nil, self.scrollChild)
    button:SetSize(260, 50)
    
    -- Portrait
    local portrait = button:CreateTexture(nil, "BORDER")
    portrait:SetSize(40, 40)
    portrait:SetPoint("LEFT", 5, 0)
    
    -- Level text
    local level = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    level:SetPoint("TOPLEFT", portrait, "TOPRIGHT", 5, -2)
    
    -- Name text
    local name = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    name:SetPoint("TOPLEFT", level, "BOTTOMLEFT", 0, -2)
    
    -- Status text
    local status = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    status:SetPoint("BOTTOMLEFT", portrait, "BOTTOMRIGHT", 5, 2)
    
    -- Counters
    local counters = CreateFrame("Frame", nil, button)
    counters:SetSize(100, 20)
    counters:SetPoint("RIGHT", -5, 0)
    
    -- Click handler
    button:SetScript("OnClick", function(self)
        FL:SelectFollower(self.follower)
    end)
    
    -- Highlight
    button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    
    -- Store references
    button.portrait = portrait
    button.level = level
    button.name = name
    button.status = status
    button.counters = counters
    
    return button
end

function FL:UpdateFollowerButton(button, follower)
    -- Set basic info
    button.follower = follower
    button.portrait:SetTexture(C_Garrison.GetFollowerPortraitIconID(follower.followerID))
    
    -- Set level text
    if follower.level == TLDG.FollowerData.MAX_FOLLOWER_LEVEL then
        button.level:SetText(string.format("iLvl %d", follower.iLevel))
    else
        button.level:SetText(string.format("Level %d", follower.level))
    end
    
    -- Set name with quality color
    local color = ITEM_QUALITY_COLORS[follower.quality]
    button.name:SetText(color.hex .. follower.name .. "|r")
    
    -- Set status
    if follower.status then
        button.status:SetText(follower.status)
        button.status:SetTextColor(0.8, 0.8, 0)
    else
        button.status:SetText("Available")
        button.status:SetTextColor(0, 1, 0)
    end
    
    -- Update counters
    self:UpdateFollowerCounters(button, follower)
end

function FL:UpdateFollowerCounters(button, follower)
    -- Clear existing counter icons
    for _, child in pairs({button.counters:GetChildren()}) do
        child:Hide()
    end
    
    -- Create counter icons
    local xOffset = 0
    for i, counterId in ipairs(follower.counters) do
        local icon = button.counters:CreateTexture(nil, "ARTWORK")
        icon:SetSize(20, 20)
        icon:SetPoint("LEFT", xOffset, 0)
        
        local counterInfo = C_Garrison.GetFollowerAbilityCounterMechanicInfo(counterId)
        if counterInfo then
            icon:SetTexture(counterInfo.icon)
        end
        
        xOffset = xOffset + 22
    end
end

function FL:UpdateFilter(searchText)
    self.followerPool:ReleaseAll()
    
    local followers = TLDG.FollowerData:GetFollowerList()
    local filtered = {}
    
    -- Apply filters
    for _, follower in pairs(followers) do
        local matches = true
        
        -- Status filter
        if self.currentFilter == "available" then
            matches = not follower.status
        elseif self.currentFilter == "mission" then
            matches = follower.status == GARRISON_FOLLOWER_ON_MISSION
        end
        
        -- Search filter
        if matches and searchText and searchText ~= "" then
            local search = searchText:lower()
            matches = follower.name:lower():find(search)
        end
        
        if matches then
            table.insert(filtered, follower)
        end
    end
    
    -- Sort followers
    self:SortFollowers(filtered)
    
    -- Create buttons
    local previousButton
    for i, follower in ipairs(filtered) do
        local button = self.followerPool:Acquire()
        button:Show()
        
        if previousButton then
            button:SetPoint("TOPLEFT", previousButton, "BOTTOMLEFT", 0, -5)
        else
            button:SetPoint("TOPLEFT", 5, -5)
        end
        
        self:UpdateFollowerButton(button, follower)
        previousButton = button
    end
    
    -- Update scroll child height
    if previousButton then
        self.scrollChild:SetHeight(previousButton:GetBottom() * -1 + 10)
    end
end

function FL:SortFollowers(followers)
    table.sort(followers, function(a, b)
        if self.currentSort == "level" then
            if a.level == b.level then
                return a.iLevel > b.iLevel
            end
            return a.level > b.level
        elseif self.currentSort == "ilevel" then
            return a.iLevel > b.iLevel
        elseif self.currentSort == "name" then
            return a.name < b.name
        elseif self.currentSort == "quality" then
            return a.quality > b.quality
        elseif self.currentSort == "status" then
            if (a.status or "") == (b.status or "") then
                return a.name < b.name
            end
            return (a.status or "") < (b.status or "")
        end
    end)
end

function FL:SelectFollower(follower)
    if not follower then return end
    
    -- Show follower in default UI
    GarrisonMissionFrame.FollowerList:ShowFollower(follower.followerID)
    
    -- Highlight optimization opportunities
    self:HighlightOptimization(follower)
end

function FL:HighlightOptimization(follower)
    -- Check for upgrade opportunities
    local suggestions = {
        needsLeveling = follower.level < TLDG.FollowerData.MAX_FOLLOWER_LEVEL,
        needsGear = follower.level == TLDG.FollowerData.MAX_FOLLOWER_LEVEL and follower.iLevel < TLDG.FollowerData.MAX_FOLLOWER_ITEM_LEVEL,
        suboptimalTraits = self:CheckForSuboptimalTraits(follower),
    }
    
    -- Show optimization tooltip
    GameTooltip:SetOwner(self.frame, "ANCHOR_CURSOR")
    GameTooltip:AddLine(follower.name, 1, 1, 1)
    GameTooltip:AddLine("Optimization Suggestions:", 0.9, 0.9, 0.3)
    
    if suggestions.needsLeveling then
        GameTooltip:AddLine("• Needs leveling to 100", 1, 0.5, 0)
    end
    if suggestions.needsGear then
        GameTooltip:AddLine("• Can be equipped with better gear", 1, 0.5, 0)
    end
    if suggestions.suboptimalTraits then
        GameTooltip:AddLine("• Has suboptimal traits that could be rerolled", 1, 0.5, 0)
    end
    
    if not (suggestions.needsLeveling or suggestions.needsGear or suggestions.suboptimalTraits) then
        GameTooltip:AddLine("• Follower is optimized", 0, 1, 0)
    end
    
    GameTooltip:Show()
end

function FL:CheckForSuboptimalTraits(follower)
    -- List of particularly valuable traits
    local valuableTraits = {
        [79] = true,  -- Epic Mount
        [221] = true, -- Burst of Power
        [236] = true, -- Extra Training
    }
    
    -- Check if follower has any valuable traits
    local hasValuableTrait = false
    for _, trait in ipairs(follower.traits) do
        if valuableTraits[trait] then
            hasValuableTrait = true
            break
        end
    end
    
    return not hasValuableTrait and follower.quality >= 4
end

function FL:RegisterEvents()
    local events = {
        "GARRISON_FOLLOWER_LIST_UPDATE",
        "GARRISON_FOLLOWER_UPGRADED",
        "GARRISON_FOLLOWER_XP_CHANGED",
    }
    
    for _, event in ipairs(events) do
        TLDG.Utils:RegisterEvent(event, function()
            if self.frame:IsShown() then
                self:UpdateFilter()
            end
        end)
    end
end

-- Initialize module
TLDG:RegisterCallback("OnInitialize", function()
    FL:Initialize()
end)