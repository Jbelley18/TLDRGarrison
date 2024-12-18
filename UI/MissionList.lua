local _, ns = ...
local TLDG = ns.TLDRGarrison

TLDG.MissionList = {}
local ML = TLDG.MissionList

function ML:Initialize()
    -- Will be implemented later
end

function ML:UpdateDisplay()
    -- Will be implemented later
end

-- Initialize module
TLDG:RegisterCallback("OnInitialize", function()
    ML:Initialize()
end)