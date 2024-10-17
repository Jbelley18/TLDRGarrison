local G = TLDRG.GUI  -- Reference the global TLDRG.GUI table

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

-- Function to create the main frame
function G.CreateMainFrame()
    if G.mainFrame then
        return G.mainFrame
    end

    -- Create the main frame
    local mainFrame = CreateDraggableFrame("TLDRGarrisonFrame", UIParent, 300, 250, {"CENTER", UIParent, "CENTER"})
    G.mainFrame = mainFrame

    -- Create the Start/Complete button
    G.StartCompleteButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    G.StartCompleteButton:SetSize(120, 30)
    G.StartCompleteButton:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 10, 10)
    G.StartCompleteButton:SetText("Start/Complete All")
    print("StartCompleteButton created:", G.StartCompleteButton ~= nil)

    -- Create the Debug Button (optional)
    local debugButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    debugButton:SetSize(100, 30)
    debugButton:SetPoint("BOTTOMRIGHT", G.StartCompleteButton, "TOPRIGHT", 0, 20)
    debugButton:SetText("Debug")
    G.debugButton = debugButton

    -- Close button for the main frame
    local closeButton = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT")

    print("Main frame and debug button created successfully")

    return mainFrame
end
