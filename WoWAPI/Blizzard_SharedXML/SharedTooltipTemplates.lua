local envTable = GetCurrentEnvironment();

local function SetupTextFont(fontString, fontObject)
	if fontString and fontObject then
		fontString:SetFontObject(fontObject);
	end
end

function SharedTooltip_OnLoad(self)
	NineSliceUtil.DisableSharpening(self.NineSlice);
	local style = nil;
	local isEmbedded = false;
	SharedTooltip_SetBackdropStyle(self, style, isEmbedded);
	self:SetClampRectInsets(0, 0, 15, 0);

	SetupTextFont(self.TextLeft1, self.textLeft1Font);
	SetupTextFont(self.TextRight1, self.textRight1Font);
	SetupTextFont(self.TextLeft2, self.textLeft2Font);
	SetupTextFont(self.TextRight2, self.textRight2Font);
end

function SharedTooltip_OnHide(self)
	self:SetPadding(0, 0, 0, 0);
end

local DEFAULT_TOOLTIP_OFFSET_X = -17;
local DEFAULT_TOOLTIP_OFFSET_Y = 70;

function SharedTooltip_SetDefaultAnchor(tooltip, parent)
	tooltip:SetOwner(parent or GetAppropriateTopLevelParent(), "ANCHOR_NONE");
	tooltip:SetPoint("BOTTOMRIGHT", GetAppropriateTopLevelParent(), "BOTTOMRIGHT", DEFAULT_TOOLTIP_OFFSET_X, DEFAULT_TOOLTIP_OFFSET_Y);
end

function SharedTooltip_ClearInsertedFrames(self)
	if self.insertedFrames then
		for i = 1, #self.insertedFrames do
			self.insertedFrames[i]:Hide();
		end
	end
	self.insertedFrames = nil;
end

function SharedTooltip_SetBackdropStyle(self, style, embedded)
	if embedded or self.IsEmbedded then
		self.NineSlice:Hide();
	else
		local layoutName = style and style.layoutType or "TooltipDefaultLayout";
		local layout = NineSliceUtil.GetLayout(layoutName);
		NineSliceUtil.ApplyLayout(self.NineSlice, layout);
		self.NineSlice:Show();
	end

	local bgR, bgG, bgB = TOOLTIP_DEFAULT_BACKGROUND_COLOR:GetRGB();
	self.NineSlice:SetCenterColor(bgR, bgG, bgB, 1);

	if self.TopOverlay then
		if style and style.overlayAtlasTop then
			self.TopOverlay:SetAtlas(style.overlayAtlasTop, true);
			self.TopOverlay:SetScale(style.overlayAtlasTopScale or 1.0);
			self.TopOverlay:SetPoint("CENTER", self, "TOP", style.overlayAtlasTopXOffset or 0, style.overlayAtlasTopYOffset or 0);
			self.TopOverlay:Show();
		else
			self.TopOverlay:Hide();
		end
	end

	if self.BottomOverlay then
		if style and style.overlayAtlasBottom then
			self.BottomOverlay:SetAtlas(style.overlayAtlasBottom, true);
			self.BottomOverlay:SetScale(style.overlayAtlasBottomScale or 1.0);
			self.BottomOverlay:SetPoint("CENTER", self, "BOTTOM", style.overlayAtlasBottomXOffset or 0, style.overlayAtlasBottomYOffset or 0);
			self.BottomOverlay:Show();
		else
			self.BottomOverlay:Hide();
		end
	end

	if style and style.padding then
		self:SetPadding(style.padding.right, style.padding.bottom, style.padding.left, style.padding.top);
	end
end

function GameTooltip_SetDefaultAnchor(tooltip, parent)
	tooltip:SetOwner(parent, "ANCHOR_NONE");

	local point, relativeTo, relativePoint, offsetX, offsetY = SharedTooltipDefaultContainer:GetPoint(1);
	--If GameTooltipDefaultContainer exists, use that instead
	if GameTooltipDefaultContainer then
		point, relativeTo, relativePoint, offsetX, offsetY = GameTooltipDefaultContainer:GetPoint(1);
	end
	-- If DefaultContainer isn't corner anchored then find the nearest corner to anchor to
	if not (point == "BOTTOMRIGHT" or point == "BOTTOMLEFT" or point == "TOPRIGHT" or point == "TOPLEFT") then
		if point == "TOP" or point == "BOTTOM" then
			point = offsetX > 0 and point.."RIGHT" or point.."LEFT";
		elseif point =="LEFT" or point == "RIGHT" then
			point = offsetY > 0 and "TOP"..point or "BOTTOM"..point;
		else -- CENTER
			local topBottom = offsetY > 0 and "TOP" or "BOTTOM";
			local rightLeft = offsetX > 0 and "RIGHT" or "LEFT";
			point = topBottom..rightLeft;
		end
	end

	-- Anchor tooltip to corner
	if GameTooltipDefaultContainer then
		tooltip:SetPoint(point, GameTooltipDefaultContainer);
	else
		tooltip:SetPoint(point, SharedTooltipDefaultContainer);
	end
end

function GameTooltip_AddBlankLinesToTooltip(tooltip, numLines)
	if numLines ~= nil then
		for i = 1, numLines do
			tooltip:AddLine(" ");
		end
	end
end

function GameTooltip_AddBlankLineToTooltip(tooltip)
	GameTooltip_AddBlankLinesToTooltip(tooltip, 1);
end

function GameTooltip_SetTitle(tooltip, text, overrideColor, wrap)
	tooltip:ClearLines();
	GameTooltip_AddColoredLine(tooltip, text, overrideColor or HIGHLIGHT_FONT_COLOR, wrap)
end

function GameTooltip_ShowDisabledTooltip(tooltip, owner, text, tooltipAnchor)
	tooltip:SetOwner(owner, tooltipAnchor);

	local wrap = true;
	GameTooltip_SetTitle(tooltip, text, RED_FONT_COLOR, wrap);

	tooltip:Show();
end

function GameTooltip_AddNormalLine(tooltip, text, wrap, leftOffset)
	GameTooltip_AddColoredLine(tooltip, text, NORMAL_FONT_COLOR, wrap, leftOffset);
end

function GameTooltip_AddBodyLine(...)
	GameTooltip_AddNormalLine(...);
end

function GameTooltip_AddHighlightLine(tooltip, text, wrap, leftOffset)
	GameTooltip_AddColoredLine(tooltip, text, HIGHLIGHT_FONT_COLOR, wrap, leftOffset);
end

function GameTooltip_AddInstructionLine(tooltip, text, wrap, leftOffset)
	GameTooltip_AddColoredLine(tooltip, text, GREEN_FONT_COLOR, wrap, leftOffset);
end

function GameTooltip_AddErrorLine(tooltip, text, wrap, leftOffset)
	GameTooltip_AddColoredLine(tooltip, text, RED_FONT_COLOR, wrap, leftOffset);
end

function GameTooltip_AddDisabledLine(tooltip, text, wrap, leftOffset)
	GameTooltip_AddColoredLine(tooltip, text, DISABLED_FONT_COLOR, wrap, leftOffset);
end

function GameTooltip_AddColoredLine(tooltip, text, color, wrap, leftOffset)
	local r, g, b = color:GetRGB();
	if wrap == nil then
		wrap = true;
	end
	tooltip:AddLine(text, r, g, b, wrap, leftOffset);
end

function GameTooltip_AddColoredDoubleLine(tooltip, leftText, rightText, leftColor, rightColor, wrap, leftOffset)
	local leftR, leftG, leftB = leftColor:GetRGB();
	local rightR, rightG, rightB = rightColor:GetRGB();
	if wrap == nil then
		wrap = true;
	end
	tooltip:AddDoubleLine(leftText, rightText, leftR, leftG, leftB, rightR, rightG, rightB, wrap, leftOffset);
end

-- Common defaults when using GameTooltip_ShowSimpleTooltip
SimpleTooltipConstants = {
	NoOverrideColor = nil;

	WrapText = true;
	DoNotWrapText = false;
}

function GameTooltip_ShowSimpleTooltip(tooltip, text, overrideColor, wrap, owner, point, offsetX, offsetY)
	tooltip:SetOwner(owner, point, offsetX, offsetY);
	GameTooltip_SetTitle(tooltip, text, overrideColor, wrap);
	tooltip:Show();
end

function GameTooltip_InsertFrame(tooltipFrame, frame, verticalPadding)
	verticalPadding = verticalPadding or 0;

	local textSpacing = tooltipFrame:GetCustomLineSpacing() or 2;
	local textHeight = Round(envTable[tooltipFrame:GetName().."TextLeft2"]:GetLineHeight());
	local neededHeight = Round(frame:GetHeight() + verticalPadding);
	local numLinesNeeded = math.ceil(neededHeight / (textHeight + textSpacing));
	local currentLine = tooltipFrame:NumLines();
	GameTooltip_AddBlankLinesToTooltip(tooltipFrame, numLinesNeeded);
	frame:SetParent(tooltipFrame);
	frame:ClearAllPoints();
	frame:SetPoint("TOPLEFT", tooltipFrame:GetName().."TextLeft"..(currentLine + 1), "TOPLEFT", 0, -verticalPadding);
	if not tooltipFrame.insertedFrames then
		tooltipFrame.insertedFrames = { };
	end
	local frameWidth = frame:GetWidth();
	if tooltipFrame:GetMinimumWidth() < frameWidth then
		tooltipFrame:SetMinimumWidth(frameWidth);
	end
	frame:Show();
	tinsert(tooltipFrame.insertedFrames, frame);
	-- return space taken so inserted frame can resize if needed
	return (numLinesNeeded * textHeight) + (numLinesNeeded - 1) * textSpacing;
end

function GameTooltip_AddNewbieTip(frame, normalText, r, g, b, newbieText, noNormalText)
	-- Nothing to do, this was added for Glue support.
end

TooltipBackdropTemplateMixin = {};

function TooltipBackdropTemplateMixin:TooltipBackdropOnLoad()
	NineSliceUtil.DisableSharpening(self.NineSlice);

	local bgColor = self.backdropColor or TOOLTIP_DEFAULT_BACKGROUND_COLOR;
	local bgAlpha = self.backdropColorAlpha or 1;
	local bgR, bgG, bgB = bgColor:GetRGB();
	self:SetBackdropColor(bgR, bgG, bgB, bgAlpha);

	if self.backdropBorderColor then
		local borderR, borderG, borderB = self.backdropBorderColor:GetRGB();
		local borderAlpha = self.backdropBorderColorAlpha or 1;
		self:SetBackdropBorderColor(borderR, borderG, borderB, borderAlpha);
	end
end

function TooltipBackdropTemplateMixin:SetBackdropColor(r, g, b, a)
	self.NineSlice:SetCenterColor(r, g, b, a);
end

function TooltipBackdropTemplateMixin:GetBackdropColor()
	return self.NineSlice:GetCenterColor();
end

function TooltipBackdropTemplateMixin:SetBackdropBorderColor(r, g, b, a)
	self.NineSlice:SetBorderColor(r, g, b, a);
end

function TooltipBackdropTemplateMixin:GetBackdropBorderColor()
	return self.NineSlice:GetBorderColor();
end

function TooltipBackdropTemplateMixin:SetBorderBlendMode(blendMode)
	self.NineSlice:SetBorderBlendMode(blendMode);
end

DisabledTooltipButtonMixin = {};

function DisabledTooltipButtonMixin:OnEnter()
	if not self:IsEnabled() then
		local disabledTooltip, disabledTooltipAnchor = self:GetDisabledTooltip();
		if disabledTooltip ~= nil then
			GameTooltip_ShowDisabledTooltip(GetAppropriateTooltip(), self, disabledTooltip, disabledTooltipAnchor);
		end
	end
end

function DisabledTooltipButtonMixin:OnLeave()
	local tooltip = GetAppropriateTooltip();
	tooltip:Hide();
end

function DisabledTooltipButtonMixin:SetDisabledTooltip(disabledTooltip, disabledTooltipAnchor)
	self.disabledTooltip = disabledTooltip;
	self.disabledTooltipAnchor = disabledTooltipAnchor;
end

function DisabledTooltipButtonMixin:GetDisabledTooltip()
	return self.disabledTooltip, self.disabledTooltipAnchor;
end

function DisabledTooltipButtonMixin:SetDisabledState(disabled, disabledTooltip, disabledTooltipAnchor)
	self:SetEnabled(not disabled);
	self:SetDisabledTooltip(disabledTooltip, disabledTooltipAnchor);
end
