-- ===========================================
-- Global Variables Declaration
-- ===========================================
-- TLDRG is initialized globally in init.lua

-- ===========================================
-- Module Loading Section
-- ===========================================

-- Check if the GUI module has been loaded
if not TLDRG.GUI or not TLDRG.GUI.CreateMainFrame then
    print("Failed to load GUI or CreateMainFrame function is missing")
    return
end

-- Call the CreateMainFrame function to ensure the frame is created
local garrisonFrame = TLDRG.GUI.CreateMainFrame()

-- Check if the garrisonFrame is properly initialized
if not garrisonFrame then
    print("Failed to create or reference mainFrame")
    return
end

-- ===========================================
-- Garrison Events Registration
-- (This part would go in the handler where the events are registered for opening/closing the frame)
