FlightMap_FlightPathDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

local function IsVindicaarTextureKit(textureKit)
	-- TODO: remove
	return textureKit == "FlightMaster_VindicaarArgus" or textureKit == "FlightMaster_VindicaarStygianWake" or textureKit == "FlightMaster_VindicaarMacAree";
end

function FlightMap_FlightPathDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("FlightMap_FlightPointPinTemplate");
	self:GetMap():ResetTitleAndPortraitIcon();
	if self.highlightLinePool then
		self.highlightLinePool:ReleaseAll();
	end
	if self.backgroundLinePool then
		self.backgroundLinePool:ReleaseAll();
	end
end

function FlightMap_FlightPathDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	self.slotIndexToPin = {};

	self:CalculateLineThickness();

	local bastionNodeFound = false;
	local mapID = self:GetMap():GetMapID();

	if not self.startingMapID then
		self.startingMapID = mapID;
	end
	self.isMapLayerTransition = self.startingMapID ~= mapID;

	local taxiNodes = C_TaxiMap.GetAllTaxiNodes(mapID);
	for i, taxiNodeData in ipairs(taxiNodes) do
		-- Only show map transition points when on a different map from the one you started viewing.
		if (self.isMapLayerTransition or not taxiNodeData.isMapLayerTransition) then
			self:AddFlightNode(taxiNodeData);

			if taxiNodeData.textureKit == "FlightMaster_Bastion" then
				bastionNodeFound = true;
			end
		end
	end

	if bastionNodeFound then
		self:GetMap():UpdateTitleAndPortraitIcon(FLIGHT_MAP_BASTION, [[Interface/Icons/achievement_guildperk_havegroup willtravel]]);
	end

	self:ShowBackgroundRoutesFromCurrent();
end

function FlightMap_FlightPathDataProviderMixin:OnHide()
	self.startingMapID = nil;
	self.isMapLayerTransition = nil;
end

local function OnRelease(framePool, frame)
	frame.RevealAnim:Stop();
	if frame.FadeAnim then
		frame.FadeAnim:Stop();
	end
	frame:Hide();
end

function FlightMap_FlightPathDataProviderMixin:HighlightRouteToPin(pin)
	self:ClearBackgroundRoutes();

	if not self.highlightLinePool then
		self.highlightLinePool = CreateFramePool("FRAME", self:GetMap():GetCanvas(), "FlightMap_BackgroundFlightLineTemplate", OnRelease);
	end

	local slotIndex = pin.taxiNodeData.slotIndex;
	for routeIndex = 1, GetNumRoutes(slotIndex) do
		local sourceSlotIndex = TaxiGetNodeSlot(slotIndex, routeIndex, true);
		local destinationSlotIndex = TaxiGetNodeSlot(slotIndex, routeIndex, false);

		local startPin = self.slotIndexToPin[sourceSlotIndex];
		local destinationPin = self.slotIndexToPin[destinationSlotIndex];

		-- Exit-only flight points don't show a preview.
		-- Map transition routes should skip over original map nodes, since they cannot be shown on current map.
		if startPin == nil and not self.isMapLayerTransition then
			return;
		end

		if startPin ~= nil and destinationPin ~= nil then
			local lineContainer = self.highlightLinePool:Acquire();
			lineContainer.Fill:SetThickness(self.lineThickness);

			lineContainer.Fill:SetStartPoint("CENTER", startPin);
			lineContainer.Fill:SetEndPoint("CENTER", destinationPin);

			lineContainer:Show();

			startPin:Show();
			destinationPin:Show();
		end
	end
end

function FlightMap_FlightPathDataProviderMixin:RemoveRouteToPin(pin)
	if self.highlightLinePool then
		self.highlightLinePool:ReleaseAll();
	end

	local slotIndex = pin.taxiNodeData.slotIndex;
	for routeIndex = 1, GetNumRoutes(slotIndex) do
		local sourceSlotIndex = TaxiGetNodeSlot(slotIndex, routeIndex, true);
		local destinationSlotIndex = TaxiGetNodeSlot(slotIndex, routeIndex, false);

		local startPin = self.slotIndexToPin[sourceSlotIndex];

		-- Exit-only flight points don't show a preview.
		-- Map transition routes should skip over original map nodes, since they cannot be shown on current map.
		if startPin == nil and not self.isMapLayerTransition then
			return;
		end

		if startPin ~= nil then
			startPin:SetShown(startPin:GetTaxiNodeState() ~= Enum.FlightPathState.Unreachable or startPin.taxiNodeData.isMapLayerTransition);
		end;

		local destinationPin = self.slotIndexToPin[destinationSlotIndex];
		if destinationPin ~= nil then
			destinationPin:SetShown(destinationPin:GetTaxiNodeState() ~= Enum.FlightPathState.Unreachable or destinationPin.taxiNodeData.isMapLayerTransition);
		end
	end
end

function FlightMap_FlightPathDataProviderMixin:ShowBackgroundRoutesFromCurrent()
	if not self.backgroundLinePool then
		self.backgroundLinePool = CreateFramePool("FRAME", self:GetMap():GetCanvas(), "FlightMap_BackgroundFlightLineTemplate", OnRelease);
	end

	for slotIndex, pin in pairs(self.slotIndexToPin) do
		if pin:GetTaxiNodeState() == Enum.FlightPathState.Reachable then
			for routeIndex = 1, 1 do
				local sourceSlotIndex = TaxiGetNodeSlot(slotIndex, routeIndex, true);
				local destinationSlotIndex = TaxiGetNodeSlot(slotIndex, routeIndex, false);
				local startPin = self.slotIndexToPin[sourceSlotIndex];
				local destinationPin = self.slotIndexToPin[destinationSlotIndex];

				if not startPin or not destinationPin then
					return; -- Incorrect flight data, will look broken until the data is adjusted
				end

				if startPin:ShouldShowOutgoingFlightPathPreviews() and destinationPin:GetTaxiNodeState() == Enum.FlightPathState.Reachable and not startPin.linkedPins[destinationPin] and not destinationPin.linkedPins[startPin] then
					startPin.linkedPins[destinationPin] = true;
					destinationPin.linkedPins[startPin] = true;

					local lineContainer = self.backgroundLinePool:Acquire();
					lineContainer.Fill:SetThickness(self.lineThickness);

					lineContainer.Fill:SetStartPoint("CENTER", startPin);
					lineContainer.Fill:SetEndPoint("CENTER", destinationPin);

					lineContainer:Show();

					startPin:Show();
					destinationPin:Show();
				end
			end
		end
	end
end

function FlightMap_FlightPathDataProviderMixin:ClearBackgroundRoutes()
	self.backgroundLinePool:ReleaseAll();
end

local function OnHighlightLineFadeFinish(anim)
	anim.releasePool:Release(anim:GetParent());
end

function FlightMap_FlightPathDataProviderMixin:AddFlightNode(taxiNodeData)
	local playAnim = taxiNodeData.state ~= Enum.FlightPathState.Unreachable;
	local pin = self:GetMap():AcquirePin("FlightMap_FlightPointPinTemplate", playAnim);
	self.slotIndexToPin[taxiNodeData.slotIndex] = pin;

	pin:SetPosition(taxiNodeData.position:GetXY());
	pin.taxiNodeData = taxiNodeData;
	pin.owner = self;
	pin.linkedPins = {};
	pin.textureKit = taxiNodeData.textureKit;
	pin.useSpecialReachableIcon = taxiNodeData.useSpecialIcon and taxiNodeData.textureKit and not IsVindicaarTextureKit(taxiNodeData.textureKit);
	pin.isMapLayerTransition = taxiNodeData.isMapLayerTransition;

	pin:SetFlightPathStyle(taxiNodeData.state);
	pin:UpdatePinSize(taxiNodeData.state);

	-- Only show if part of a route or a layer transition point, handled in the route building functions
	pin:SetShown(taxiNodeData.state ~= Enum.FlightPathState.Unreachable or taxiNodeData.isMapLayerTransition);
end

function FlightMap_FlightPathDataProviderMixin:CalculateLineThickness()
	self.lineThickness = Lerp(1, 2, Saturate(1 - self:GetMap():GetCanvasZoomPercent())) * 45;
end

function FlightMap_FlightPathDataProviderMixin:OnCanvasScaleChanged()
	self:CalculateLineThickness();

	if self.backgroundLinePool then
		for lineContainer in self.backgroundLinePool:EnumerateActive() do
			lineContainer.Fill:SetThickness(self.lineThickness);
		end
	end

	if self.highlightLinePool then
		for lineContainer in self.highlightLinePool:EnumerateActive() do
			lineContainer.Fill:SetThickness(self.lineThickness);
		end
	end
end

--[[ Flight Point Pin ]]--
FlightMap_FlightPointPinMixin = CreateFromMixins(MapCanvasPinMixin);

function FlightMap_FlightPointPinMixin:OnLoad()
	self:SetScalingLimits(1.25, 0.9625, 1.275);

	self:UseFrameLevelType("PIN_FRAME_LEVEL_FLIGHT_POINT");
end

function FlightMap_FlightPointPinMixin:OnAcquired(playAnim)
	if playAnim then
		self.OnAddAnim:Play();
	else
		self:SetAlpha(1);
	end
end

function FlightMap_FlightPointPinMixin:OnClick(button)
	-- Map layer transition points are not valid flight targets.
	if button == "LeftButton" and not self.isMapLayerTransition then
		TakeTaxiNode(self.taxiNodeData.slotIndex);
	end
end

function FlightMap_FlightPointPinMixin:OnMouseEnter()
	GameTooltip:SetOwner(self, "ANCHOR_PRESERVE");
	GameTooltip:ClearAllPoints();
	GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 0, 0);

	GameTooltip_AddNormalLine(GameTooltip, self.taxiNodeData.name, true);

	if self.taxiNodeData.state == Enum.FlightPathState.Current then
		GameTooltip_AddHighlightLine(GameTooltip, TAXINODEYOUAREHERE, true);
	elseif self.taxiNodeData.state == Enum.FlightPathState.Reachable then
		local cost = TaxiNodeCost(self.taxiNodeData.slotIndex);
		if cost > 0 then
			SetTooltipMoney(GameTooltip, cost);
		elseif self.taxiNodeData.specialIconCostString then
			if self.taxiNodeData.useSpecialIcon then
				GameTooltip_AddHighlightLine(GameTooltip, self.taxiNodeData.specialIconCostString, true);
			else
				GameTooltip_AddErrorLine(GameTooltip, self.taxiNodeData.specialIconCostString, true);
			end
		end

		self.Icon:SetAtlas(self.atlasFormat:format("Taxi_Frame_Yellow"));

		self.owner:HighlightRouteToPin(self);
	elseif self.taxiNodeData.state == Enum.FlightPathState.Unreachable and not self.isMapLayerTransition then
		GameTooltip_AddErrorLine(GameTooltip, TAXI_PATH_UNREACHABLE, true);
	end

	GameTooltip:Show();
end

function FlightMap_FlightPointPinMixin:OnMouseLeave()
	if self.taxiNodeData.state == Enum.FlightPathState.Reachable then
		if self.useSpecialReachableIcon then
			self.Icon:SetAtlas(self.atlasFormat:format("Taxi_Frame_Special"));
		else
			self.Icon:SetAtlas(self.atlasFormat:format("Taxi_Frame_Gray"));
		end
		self.owner:RemoveRouteToPin(self);
	end
	GameTooltip_Hide();
end

function FlightMap_FlightPointPinMixin:GetTaxiNodeState()
	return self.taxiNodeData.state;
end

function FlightMap_FlightPointPinMixin:UpdatePinSize(pinType)
	if IsVindicaarTextureKit(self.textureKit) then
		self:SetSize(39, 42);
	elseif self.textureKit == "FlightMaster_Argus" then
		self:SetSize(34, 28);
	elseif self.textureKit == "FlightMaster_Bastion" then
		if pinType == Enum.FlightPathState.Current then
			self:SetSize(26, 26);
		elseif pinType == Enum.FlightPathState.Reachable or pinType == Enum.FlightPathState.Unreachable then
			self:SetSize(24, 24);
		end
	elseif self.textureKit == "FlightMaster_Ferry" then
		if pinType == Enum.FlightPathState.Current then
			self:SetSize(36, 24);
		elseif pinType == Enum.FlightPathState.Reachable or pinType == Enum.FlightPathState.Unreachable then
			self:SetSize(28, 19);
		end
	elseif self.isMapLayerTransition then
		self:SetSize(20, 20);
	elseif pinType == Enum.FlightPathState.Current then
		self:SetSize(28, 28);
	elseif pinType == Enum.FlightPathState.Reachable then
		self:SetSize(20, 20);
	elseif pinType == Enum.FlightPathState.Unreachable then
		self:SetSize(14, 14);
	end
end

function FlightMap_FlightPointPinMixin:SetFlightPathStyle(taxiNodeType)
	self:SetNudgeSourceRadius(1);
	self:SetNudgeSourceMagnitude(1, 2);
	if self.textureKit then
		self.atlasFormat = self.textureKit.."-%s";

		if IsVindicaarTextureKit(self.textureKit) then
			self:SetNudgeSourceRadius(2);
			self:SetNudgeSourceMagnitude(1.5, 3.65);
		elseif self.textureKit == "FlightMaster_Argus" then
			self:SetNudgeSourceRadius(1.5);
			self:SetNudgeSourceMagnitude(1, 2);
		end
	else
		self.atlasFormat = "%s";
	end

	if self.isMapLayerTransition then
		self.Icon:SetAtlas(self.atlasFormat:format("Taxi_Frame_Gray"));
		self.IconHighlight:SetAtlas(self.atlasFormat:format("Taxi_Frame_Gray"));
	elseif taxiNodeType == Enum.FlightPathState.Current then
		self.Icon:SetAtlas(self.atlasFormat:format("Taxi_Frame_Green"));
		self.IconHighlight:SetAtlas(self.atlasFormat:format("Taxi_Frame_Gray"));
	elseif taxiNodeType == Enum.FlightPathState.Unreachable then
		self.Icon:SetAtlas(self.atlasFormat:format("UI-Taxi-Icon-Nub"));
		self.IconHighlight:SetAtlas(self.atlasFormat:format("UI-Taxi-Icon-Nub"));
	elseif taxiNodeType == Enum.FlightPathState.Reachable then
		if self.useSpecialReachableIcon then
			self.Icon:SetAtlas(self.atlasFormat:format("Taxi_Frame_Special"));
		else
			self.Icon:SetAtlas(self.atlasFormat:format("Taxi_Frame_Gray"));
		end
		self.IconHighlight:SetAtlas(self.atlasFormat:format("Taxi_Frame_Gray"));
	end
end

function FlightMap_FlightPointPinMixin:ShouldShowOutgoingFlightPathPreviews()
	local isArgus = IsVindicaarTextureKit(self.textureKit) or self.textureKit == "FlightMaster_Argus";
	return not isArgus;
end
