_G.TLDRGarrison = _G.TLDRGarrison or {}
TLDRGarrison.GUI = {}

-- Helper function to create draggable frames
local function CreateDraggableFrame(name, parent, width, height, point, backdropSettings)
    local frame = CreateFrame("Frame", name, parent, "BackdropTemplate")
    frame:SetSize(width, height)
    frame:SetPoint(unpack(point))
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(100) 
    frame:SetBackdrop(backdropSettings or {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },

    })
    frame:Hide()  -- Hide the frame initially
    return frame
end

-- Helper function to create checkboxes
local function CreateCheckbox(parent, label, x, y)
    local checkbox = CreateFrame("CheckButton", nil, parent, "ChatConfigCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    checkbox.Text:SetText(label)
    checkbox:SetChecked(false)
    return checkbox
end

-- Function to create the main frame, but it won't be created until this function is called
function TLDRGarrison.GUI.CreateMainFrame()
    if TLDRGarrison.GUI.mainFrame then
        return TLDRGarrison.GUI.mainFrame
    end

    -- Create the main frame
    local mainFrame = CreateDraggableFrame("TLDRGarrisonFrame", UIParent, 300, 550, {"CENTER", UIParent, "CENTER"})
    TLDRGarrison.GUI.mainFrame = mainFrame

    -- Create the advanced frame dynamically
    local advancedFrame = CreateDraggableFrame("TLDRGarrisonAdvancedFrame", UIParent, 300, 500, {"TOPLEFT", mainFrame, "TOPRIGHT", 10, 0})
    TLDRGarrison.GUI.AdvancedFrame = advancedFrame

    -- Create the Advanced Toggle Button
    local advancedToggleButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    advancedToggleButton:SetSize(100, 30)
    advancedToggleButton:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -10, 10)
    advancedToggleButton:SetText("Advanced")
    TLDRGarrison.GUI.advancedToggleButton = advancedToggleButton

    -- Close button for the main frame
    local closeButton = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT")

    -- Main frame checkboxes
    local checkboxDetails = {
        {text = "Garrison Resources", y = -40},
        {text = "Armor/Weapon Upgrades", y = -70},
        {text = "Scribe Rush Order", y = -100},
        {text = "Follower XP", y = -130},
        {text = "Rare Items (Mounts, Pets, etc.)", y = -160}
    }
    TLDRGarrison.GUI.checkboxes = {}
    for i, cb in ipairs(checkboxDetails) do
        TLDRGarrison.GUI.checkboxes[i] = CreateCheckbox(mainFrame, cb.text, 10, cb.y)
    end

    -- Start/Complete button
    local startCompleteButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    startCompleteButton:SetSize(120, 30)
    startCompleteButton:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 10, 10)
    startCompleteButton:SetText("Start/Complete All")
    TLDRGarrison.GUI.StartCompleteButton = startCompleteButton -- Fix the reference here

    -- Create the Debug Button
    local debugButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    debugButton:SetSize(100, 30)
    debugButton:SetPoint("BOTTOMRIGHT", advancedToggleButton, "TOPRIGHT", 0, 20)  -- Adjust position if needed
    debugButton:SetText("Debug")
    TLDRGarrison.GUI.debugButton = debugButton

    -- Show the main frame (optional, depends on your logic)
    mainFrame:Show()

    -- Print a message to confirm
    print("Main frame and debug button created successfully")

    return mainFrame
end
