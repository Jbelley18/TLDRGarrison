
local type = type;
local setmetatable = setmetatable;

-- NOTE: This is only using a single set of PVPQuery timers.  There's no reason to have a different set per-instance.
PVPAFK_QUERY_DELAY_SECONDS = 5;
local pvpAFKQueryTimers = {}


local Private_UnitAppearanceData = {};
setmetatable(Private_UnitAppearanceData, { __metatable = false });

local function GetOrCreateUnitAppearanceData(frame, unitType)
	-- Global access should be avoided to expose as few attack vectors as possible.
	local UNIT_POSITION_FRAME_DEFAULT_PIN_SIZE = 40;
	local UNIT_POSITION_FRAME_DEFAULT_SUBLEVEL = 7;
	local UNIT_POSITION_FRAME_DEFAULT_TEXTURE = "WhiteCircle-RaidBlips";
	local UNIT_POSITION_FRAME_DEFAULT_SHOULD_SHOW_UNITS = true;
	local UNIT_POSITION_FRAME_DEFAULT_USE_CLASS_COLOR = true;

	if Private_UnitAppearanceData[frame] == nil then
		local newUnitAppearanceData = {};
		setmetatable(newUnitAppearanceData, { __metatable = false });
		Private_UnitAppearanceData[frame] = newUnitAppearanceData;
	end

	local data = Private_UnitAppearanceData[frame][unitType];
	if data == nil then
		-- Note: We only allow changes to existing keys with values that match the type of the default value.
		-- We should not add any function or table values to this default set.
		data = {
			size = UNIT_POSITION_FRAME_DEFAULT_PIN_SIZE,
			sublevel = UNIT_POSITION_FRAME_DEFAULT_SUBLEVEL,
			texture = UNIT_POSITION_FRAME_DEFAULT_TEXTURE,
			shouldShow = UNIT_POSITION_FRAME_DEFAULT_SHOULD_SHOW_UNITS,
			useClassColor = unitType ~= "player", -- UNIT_POSITION_FRAME_DEFAULT_USE_CLASS_COLOR
			showRotation = unitType == "player"; -- There's no point in trying to show rotation for anything except the local player.
		};

		setmetatable(data, { __metatable = false });

		Private_UnitAppearanceData[frame][unitType] = data;
	end

	return data;
end


function SetPVPAFKQueryDelaySeconds(seconds)
	PVPAFK_QUERY_DELAY_SECONDS = seconds;
end

function GetIsPVPInactive(unit, timeNowSeconds)
	if not UnitExists(unit) then
		return false;
	end

	local cachedData = pvpAFKQueryTimers[unit];
	if not cachedData then
		local inactive = PlayerIsPVPInactive(unit);
		pvpAFKQueryTimers[unit] = { inactive = inactive, nextQueryTimeSeconds = timeNowSeconds + PVPAFK_QUERY_DELAY_SECONDS };
		return inactive;
	end

	 if timeNowSeconds >= cachedData.nextQueryTimeSeconds then
		cachedData.inactive = PlayerIsPVPInactive(unit);
		cachedData.nextQueryTimeSeconds = timeNowSeconds + PVPAFK_QUERY_DELAY_SECONDS;
	 end

	 return cachedData.inactive;
end

function CheckColorOverrideForPVPInactive(unit, timeNow, r, g, b)
	if GetIsPVPInactive(unit, timeNow) then
		return 0.5, 0.2, 0.8;
	end

	return r, g, b;
end

UnitPositionFrameMixin = {}

function UnitPositionFrameMixin:OnLoad()
	self:ResetCurrentMouseOverUnits();
	self:SetupSecureData();

	self.excludedMouseOverUnits = {};

	self:SetNeedsFullUpdate();
	self:SetNeedsPeriodicUpdate(true); -- by default allow periodic updates (for style changes only!)
	self:UpdateAppearanceData();
end

function UnitPositionFrameMixin:OnShow()
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:SetNeedsFullUpdate();
end

function UnitPositionFrameMixin:OnHide()
	self:UnregisterEvent("GROUP_ROSTER_UPDATE");
	self:ResetCurrentMouseOverUnits();
end

function UnitPositionFrameMixin:OnEvent(event, ...)
	if event == "GROUP_ROSTER_UPDATE" then
		self:UpdateAppearanceData();
	end
end

function UnitPositionFrameMixin:UpdateAppearanceData()
	self:SetPinTexture("raid", "WhiteCircle-RaidBlips");
	self:SetPinTexture("party", IsInRaid() and "WhiteDotCircle-RaidBlips" or "WhiteCircle-RaidBlips");
end

function UnitPositionFrameMixin:ResetCurrentMouseOverUnits()
	self.currentMouseOverUnits = {};
	self.currentMouseOverUnitCount = 0;
end

function UnitPositionFrameMixin:SetPinSize(unitType, size)
	self:SetAppearanceField(unitType, "size", size);
end

function UnitPositionFrameMixin:SetPinTexture(unitType, texture)
	self:SetAppearanceField(unitType, "texture", texture);
end

function UnitPositionFrameMixin:SetPinSubLevel(unitType, sublevel)
	self:SetAppearanceField(unitType, "sublevel", sublevel);
end

function UnitPositionFrameMixin:SetShouldShowUnits(unitType, show)
	self:SetAppearanceField(unitType, "shouldShow", show);
end

function UnitPositionFrameMixin:SetUseClassColor(unitType, useClassColor)
	self:SetAppearanceField(unitType, "useClassColor", useClassColor);
end

function UnitPositionFrameMixin:GetCurrentMouseOverUnits()
	return self.currentMouseOverUnits;
end

function UnitPositionFrameMixin:IsMouseOverUnitExcluded(unit)
	return self.excludedMouseOverUnits[unit];
end

function UnitPositionFrameMixin:SetMouseOverUnitExcluded(unit, excluded)
	if excluded then
		self.excludedMouseOverUnits[unit] = excluded;
	else
		self.excludedMouseOverUnits[unit] = nil;
	end
end

local function UpdateMouseOverUnits(self, ...)
	local mouseOverUnitsChanged = false;
	local newMouseOverUnitCount = select("#", ...);

	-- If the counts match, the entire list needs to be checked
	-- Otherwise, the new list should just completely replace the old
	if (newMouseOverUnitCount == self.currentMouseOverUnitCount) then
		for i = 1, newMouseOverUnitCount do
			local unit = select(i, ...);
			if not self.currentMouseOverUnits[unit] then
				mouseOverUnitsChanged = true;
				break;
			end
		end
	else
		mouseOverUnitsChanged = true;
	end

	if mouseOverUnitsChanged then
		wipe(self.currentMouseOverUnits);
		self.currentMouseOverUnitCount = newMouseOverUnitCount;

		for i = 1, newMouseOverUnitCount do
			local unit = select(i, ...);
			self.currentMouseOverUnits[unit] = true;
		end
	end

	return mouseOverUnitsChanged;
end

function UnitPositionFrameMixin:UpdateUnitTooltips(tooltipFrame)
	local tooltipText = "";
	local prefix = "";
	local timeNow = GetTime();

	for unit in pairs(self.currentMouseOverUnits) do
		local unitName = UnitName(unit);
		if not self:IsMouseOverUnitExcluded(unit) then
			local formattedUnitName = GetIsPVPInactive(unit, timeNow) and format(PLAYER_IS_PVP_AFK, unitName) or unitName;
			tooltipText = tooltipText .. prefix .. formattedUnitName;

			prefix = "\n";
		end
	end

	if tooltipText ~= "" then
		self.previousOwner = tooltipFrame:GetOwner();
		tooltipFrame:SetOwner(self, "ANCHOR_CURSOR_RIGHT");
		tooltipFrame:SetText(tooltipText);
	elseif tooltipFrame:GetOwner() == self then
		tooltipFrame:ClearLines();
		tooltipFrame:Hide();
		if self.previousOwner and self.previousOwner ~= self and self.previousOwner:IsVisible() and self.previousOwner:IsMouseOver() then
			local func = self.previousOwner:HasScript("OnEnter") and self.previousOwner:GetScript("OnEnter");
			if func then
				func(self.previousOwner);
			end
		end
		self.previousOwner = nil;
	end
end

function UnitPositionFrameMixin:UpdateTooltips(tooltipFrame)
	if UpdateMouseOverUnits(self, self:GetMouseOverUnits()) or (self:GetMouseOverUnits() and tooltipFrame:GetOwner() ~= self) then
		self:UpdateUnitTooltips(tooltipFrame);
	end
end

function UnitPositionFrameMixin:GetUnitColor(timeNow, unit, appearanceData)
	if appearanceData.shouldShow then
		local r, g, b  = 1, 1, 1;

		if appearanceData.useClassColor then
			local class = select(2, UnitClass(unit));
			r, g, b = GetClassColor(class);
		end

		return true, CheckColorOverrideForPVPInactive(unit, timeNow, r, g, b);
	end

	return false;
end

function UnitPositionFrameMixin:AddUnitInternal(timeNow, unit, appearanceData)
	local isValid, r, g, b = self:GetUnitColor(timeNow, unit, appearanceData);
	if isValid then
		self:AddUnit(unit, appearanceData.texture, appearanceData.size, appearanceData.size, r, g, b, 1, appearanceData.sublevel, appearanceData.showRotation);
	end
end

function UnitPositionFrameMixin:SetUnitAppearanceInternal(timeNow, unit, appearanceData)
	local isValid, r, g, b = self:GetUnitColor(timeNow, unit, appearanceData);
	if isValid then
		self:SetUnitColor(unit, r, g, b, 1);
	end
end

function UnitPositionFrameMixin:GetMemberCountAndUnitTokenPrefix()
	if IsInRaid() then
		return MAX_RAID_MEMBERS, "raid";
	elseif IsInGroup() then
		return MAX_PARTY_MEMBERS, "party";
	end

	return 0, "";
end

function UnitPositionFrameMixin:UpdateFull(timeNow)
	assert(self:NeedsFullUpdate());
	self:ClearUnits();
	self:AddUnitInternal(timeNow, "player", GetOrCreateUnitAppearanceData(self, "player"));

	local memberCount, unitBase = self:GetMemberCountAndUnitTokenPrefix();
	local overridePartyType = (C_PvP.IsActiveBattlefield() and IsInRaid() and IsInGroup(LE_PARTY_CATEGORY_HOME)) and LE_PARTY_CATEGORY_HOME or nil;
	local partyAppearance = GetOrCreateUnitAppearanceData(self, "party");
	local raidAppearance = GetOrCreateUnitAppearanceData(self, "raid");

	for i = 1, memberCount do
		local unit = unitBase..i;
		if UnitExists(unit) and not UnitIsUnit(unit, "player") then
			local appearance = UnitInSubgroup(unit, overridePartyType) and partyAppearance or raidAppearance;
			self:AddUnitInternal(timeNow, unit, appearance);
		end
	end

	self:FinalizeUnits();
	self.needsFullUpdate = false;
end

function UnitPositionFrameMixin:UpdatePeriodic(timeNow)
	self:SetUnitAppearanceInternal(timeNow, "player", GetOrCreateUnitAppearanceData(self, "player"));

	local memberCount, unitBase = self:GetMemberCountAndUnitTokenPrefix();
	local overridePartyType = (C_PvP.IsActiveBattlefield() and IsInRaid() and IsInGroup(LE_PARTY_CATEGORY_HOME)) and LE_PARTY_CATEGORY_HOME or nil;
	local partyAppearance = GetOrCreateUnitAppearanceData(self, "party");
	local raidAppearance = GetOrCreateUnitAppearanceData(self, "raid");

	for i = 1, memberCount do
		local unit = unitBase..i;
		if UnitExists(unit) and not UnitIsUnit(unit, "player") then
			local appearance = UnitInSubgroup(unit, overridePartyType) and partyAppearance or raidAppearance;
			self:SetUnitAppearanceInternal(timeNow, unit, appearance);
		end
	end
end

function UnitPositionFrameMixin:SetNeedsFullUpdate()
	self.needsFullUpdate = true;
end

function UnitPositionFrameMixin:NeedsFullUpdate()
	return self.needsFullUpdate;
end

function UnitPositionFrameMixin:SetNeedsPeriodicUpdate(needsPeriodicUpdate)
	self.needsPeriodicUpdate = needsPeriodicUpdate;
end

function UnitPositionFrameMixin:NeedsPeriodicUpdate()
	return self.needsPeriodicUpdate;
end

UnitPositionFrameUpdateSecureMixin = {};

function UnitPositionFrameUpdateSecureMixin:SetupSecureData()
	self.unitAppearanceData = {};
end

function UnitPositionFrameUpdateSecureMixin:UpdatePlayerPins()
	if self:NeedsFullUpdate()then
		self:UpdateFull(GetTime());	
	elseif self:NeedsPeriodicUpdate() then
		self:UpdatePeriodic(GetTime());
	end
end

function UnitPositionFrameUpdateSecureMixin:SetAppearanceField(unitType, fieldName, fieldValue)
	local data = GetOrCreateUnitAppearanceData(self, unitType);
	if type(data[fieldName]) ~= type(fieldValue) then
		return;
	end

	data[fieldName] = fieldValue;
	self:SetNeedsFullUpdate();
end
