-- TLDRGarrison.lua
-- Global debug mode toggle
local debugMode = true

-- ===========================================
-- Global Variables Declaration
-- ===========================================
TLDRGarrison = _G.TLDRGarrison or {}


-- DebugPrint helper function
function TLDRGarrison.DebugPrint(...)
    if debugMode then
        print(...)  -- This will print all the arguments separated by spaces
    end
end


-- ===========================================
-- Module Loading Section
-- ===========================================

-- Check if the GUI module has been loaded
if not TLDRGarrison.GUI or not TLDRGarrison.GUI.CreateMainFrame then
    print("Failed to load GUI or CreateMainFrame function is missing")
    return
else
    print("GUI module loaded successfully")
end

-- Call the CreateMainFrame function to ensure the frame is created
local garrisonFrame = TLDRGarrison.GUI.CreateMainFrame()

-- Check if the garrisonFrame is properly initialized
if not garrisonFrame then
    print("Failed to create or reference mainFrame")
    return
else
    print("mainFrame successfully created or referenced")
end

-- Register Garrison events for interaction
-- This part would go in the handler where the events are registered for opening/closing the frame
