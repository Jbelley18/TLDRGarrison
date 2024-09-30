-- TLDRGarrison.lua
-- Global debug mode toggle
_G.DEBUG_MODE = true  -- Set global debug mode for easy access in all files

-- ===========================================
-- Global Variables Declaration
-- ===========================================
TLDRGarrison = _G.TLDRGarrison or {}

-- DebugPrint helper function
function TLDRGarrison.DebugPrint(...)
    if _G.DEBUG_MODE then  -- Use global debug mode toggle here
        print(...)  -- This will print all the arguments separated by spaces
    end
end

-- In Game Debugging Toggle

SLASH_TLDRDEBUG1 = "/tldrdebug"
SlashCmdList["TLDRDEBUG"] = function()
    _G.DEBUG_MODE = not _G.DEBUG_MODE
    print("Debug mode set to:", _G.DEBUG_MODE)
end


-- ===========================================
-- Module Loading Section
-- ===========================================

-- Check if the GUI module has been loaded
if not TLDRGarrison.GUI or not TLDRGarrison.GUI.CreateMainFrame then
    TLDRGarrison.DebugPrint("Failed to load GUI or CreateMainFrame function is missing")
    return
else
    TLDRGarrison.DebugPrint("GUI module loaded successfully")
end

-- Call the CreateMainFrame function to ensure the frame is created
local garrisonFrame = TLDRGarrison.GUI.CreateMainFrame()

-- Check if the garrisonFrame is properly initialized
if not garrisonFrame then
    TLDRGarrison.DebugPrint("Failed to create or reference mainFrame")
    return
else
    TLDRGarrison.DebugPrint("mainFrame successfully created or referenced")
end

-- ===========================================
-- Garrison Events Registration (should be placed in GUIHandler.lua or another relevant file)
-- This part would go in the handler where the events are registered for opening/closing the frame
