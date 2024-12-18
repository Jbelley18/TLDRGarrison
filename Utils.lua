local _, ns = ...
local TLDG = ns.TLDRGarrison

TLDG.Utils = {}
local Utils = TLDG.Utils

-- Event handling system
do
    local events = {}
    local eventFrame = CreateFrame("Frame")
    
    function Utils:RegisterEvent(event, callback)
        if not events[event] then
            events[event] = {}
            eventFrame:RegisterEvent(event)
        end
        table.insert(events[event], callback)
    end
    
    eventFrame:SetScript("OnEvent", function(_, event, ...)
        if events[event] then
            for _, callback in ipairs(events[event]) do
                callback(...)
            end
        end
    end)
end

-- Basic frame creation helper
function Utils:CreateFrame(frameType, name, parent, template, id)
    parent = parent or UIParent
    local frame = CreateFrame(frameType, name, parent, template, id)
    if parent and parent.GetFrameLevel then
        frame:SetFrameStrata("MEDIUM")
        frame:SetFrameLevel(parent:GetFrameLevel() + 1)
    end
    return frame
end

-- Callback registration system
do
    local callbacks = {}
    
    function TLDG:RegisterCallback(event, callback)
        if not callbacks[event] then
            callbacks[event] = {}
        end
        table.insert(callbacks[event], callback)
    end
    
    function TLDG:TriggerCallback(event, ...)
        if callbacks[event] then
            for _, callback in ipairs(callbacks[event]) do
                callback(...)
            end
        end
    end
end

-- Debug logging
do
    function Utils:Debug(...)
        if TLDG:GetConfig("debug") then
            print("|cFF00FF00TLDR Garrison|r:", ...)
        end
    end
end

-- Table utilities
do
    function Utils:ShallowCopy(t)
        local copy = {}
        for k, v in pairs(t) do
            copy[k] = v
        end
        return copy
    end
    
    function Utils:DeepCopy(orig)
        local orig_type = type(orig)
        local copy
        if orig_type == 'table' then
            copy = {}
            for orig_key, orig_value in next, orig, nil do
                copy[Utils:DeepCopy(orig_key)] = Utils:DeepCopy(orig_value)
            end
            setmetatable(copy, Utils:DeepCopy(getmetatable(orig)))
        else
            copy = orig
        end
        return copy
    end
end

-- Time utilities
do
    function Utils:FormatTime(seconds)
        if seconds < 60 then
            return string.format("%ds", seconds)
        elseif seconds < 3600 then
            return string.format("%dm %ds", seconds/60, seconds%60)
        elseif seconds < 86400 then
            return string.format("%dh %dm", seconds/3600, (seconds%3600)/60)
        else
            return string.format("%dd %dh", seconds/86400, (seconds%86400)/3600)
        end
    end
    
    function Utils:GetTimestamp()
        return time()
    end
end

-- String utilities
do
    function Utils:TruncateString(str, length)
        if #str > length then
            return str:sub(1, length - 3) .. "..."
        end
        return str
    end
    
    function Utils:FormatNumber(number)
        if number >= 1000000 then
            return string.format("%.1fM", number/1000000)
        elseif number >= 1000 then
            return string.format("%.1fK", number/1000)
        end
        return tostring(number)
    end
end

-- Money utilities
do
    function Utils:FormatMoney(copper)
        local gold = math.floor(copper / 10000)
        local silver = math.floor((copper % 10000) / 100)
        local copper = copper % 100
        
        if gold > 0 then
            return string.format("%dg %ds %dc", gold, silver, copper)
        elseif silver > 0 then
            return string.format("%ds %dc", silver, copper)
        else
            return string.format("%dc", copper)
        end
    end
end

-- UI utilities
do
    function Utils:CreateTooltip(parent, title, description)
        parent:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(title)
            if description then
                GameTooltip:AddLine(description, 1, 1, 1, true)
            end
            GameTooltip:Show()
        end)
        parent:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end
    
    function Utils:CreateFrame(frameType, name, parent, template, id)
        local frame = CreateFrame(frameType, name, parent, template, id)
        frame:SetFrameStrata("MEDIUM")
        frame:SetFrameLevel(parent:GetFrameLevel() + 1)
        return frame
    end
end

-- Performance utilities
do
    local function ThrottleFunction(fn, limit)
        local lastRun = 0
        return function(...)
            local now = GetTime()
            if now - lastRun >= limit then
                lastRun = now
                return fn(...)
            end
        end
    end
    
    function Utils:Throttle(fn, limit)
        return ThrottleFunction(fn, limit or 0.1)
    end
end

-- Minimap button creation
do
    local minimapButton
    function Utils:CreateMinimapButton()
        if minimapButton then return minimapButton end
        
        local button = CreateFrame("Button", "TLDRGarrisonMinimapButton", Minimap)
        button:SetSize(32, 32)
        button:SetFrameStrata("MEDIUM")
        button:SetPoint("TOPLEFT", Minimap, "TOPLEFT")
        
        local icon = button:CreateTexture(nil, "BACKGROUND")
        icon:SetSize(24, 24)
        icon:SetPoint("CENTER")
        icon:SetTexture("Interface\\Icons\\Achievement_GarrisonQuests_01")
        
        local overlay = button:CreateTexture(nil, "OVERLAY")
        overlay:SetSize(53, 53)
        overlay:SetPoint("CENTER")
        overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
        
        button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        button:SetScript("OnClick", function(self, button)
            if button == "LeftButton" then
                -- Toggle main window when implemented
            else
                TLDG.UI:ToggleSettings()
            end
        end)
        
        Utils:CreateTooltip(button, "TLDR Garrison", "Left Click: Toggle Window\nRight Click: Settings")
        
        minimapButton = button
        return button
    end
end

-- Achievement tracking utilities
do
    local function IsAchievementComplete(achievementID)
        local _, _, _, completed = GetAchievementInfo(achievementID)
        return completed
    end
    
    function Utils:UnlockState()
        local data = {
            hasLevel3 = IsAchievementComplete(9100), -- Garrison Administrator
            hasBarracks = IsAchievementComplete(9129), -- Raising the Standard
            hasInn = IsAchievementComplete(9150), -- Stay Awhile and Listen
            hasBunker = IsAchievementComplete(9132), -- Time for an Upgrade
        }
        return data
    end
end