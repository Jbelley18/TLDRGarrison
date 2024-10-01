-- Debug.lua
_G.Debug = _G.Debug or {}

function _G.Debug.PrintMissionInfo(missionID)
    -- Retrieve all available missions for WoD (followerTypeID = 1)
    local missions = C_Garrison.GetAvailableMissions(1)
    local missionInfo = nil

    -- Find the mission with the specified missionID
    for _, mission in ipairs(missions) do
        if mission.missionID == missionID then
            missionInfo = mission
            break
        end
    end

    if missionInfo then
        print("Mission Info:")
        for key, value in pairs(missionInfo) do
            if type(value) ~= "table" then
                print("  " .. tostring(key) .. ": " .. tostring(value))
            end
        end

        -- Print rewards
        if missionInfo.rewards then
            print("Rewards:")
            for _, reward in pairs(missionInfo.rewards) do
                if reward.itemID then
                    local itemName, itemLink = GetItemInfo(reward.itemID)
                    print(" - Item Reward:", itemName or "Unknown Item", itemLink or "")
                elseif reward.currencyID then
                    local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(reward.currencyID)
                    local currencyName = currencyInfo and currencyInfo.name or "Unknown Currency"
                    print(" - Currency Reward:", currencyName)
                elseif reward.followerXP then
                    print(" - Follower XP Reward:", reward.followerXP)
                else
                    print(" - Other Reward:", reward.title or "Unknown Reward")
                end
            end
        else
            print("No rewards found for this mission.")
        end

        -- Print mechanics (threats)
        if missionInfo.mechanics then
            print("Mechanics:")
            for mechanicID, mechanicInfo in pairs(missionInfo.mechanics) do
                print(" - Mechanic ID:", mechanicID)
                for mKey, mValue in pairs(mechanicInfo) do
                    print("    " .. tostring(mKey) .. ": " .. tostring(mValue))
                end
            end
        else
            print("No mechanics found for this mission.")
        end
    else
        print("Mission not found for mission ID:", missionID)
    end
end
