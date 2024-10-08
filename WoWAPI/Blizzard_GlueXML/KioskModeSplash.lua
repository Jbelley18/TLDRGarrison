-- This table cannot override hard Kiosk Mode locks (i.e. Death Knights being disabled), this is merely to lock down character create based on which creation mode was chosen.
local kioskModeData = {
	["highlevel"] = {
		["races"] = {
			["HUMAN"] = true,
			["DWARF"] = true,
			["NIGHTELF"] = true,
			["GNOME"] = true,
			["DRAENEI"] = true,
			["WORGEN"] = true,
			["PANDAREN"] = true,
			["ORC"] = true,
			["SCOURGE"] = true,
			["TAUREN"] = true,
			["TROLL"] = true,
			["BLOODELF"] = true,
			["GOBLIN"] = true,
		},
		["classes"] = {
			["WARRIOR"] = true,
			["PALADIN"] = true,
			["HUNTER"] = true,
			["ROGUE"] = true,
			["PRIEST"] = true,
			["SHAMAN"] = true,
			["MAGE"] = true,
			["WARLOCK"] = true,
			["MONK"] = true,
			["DRUID"] = true,
			["DEMONHUNTER"] = true,
			["DEATHKNIGHT"] = true,
		},
		["alliedRaces"] = { 
			["LIGHTFORGEDDRAENEI"] = true,
			["HIGHMOUNTAINTAUREN"] = true,
			["NIGHTBORNE"] = true,
			["VOIDELF"] = true,
			["DARKIRONDWARF"] = true,
			["KULTIRAN"] = true,
			["MECHAGNOME"] = true,
			["MAGHARORC"] = true,
			["ZANDALARITROLL"] = true,
			["VULPERA"] = true,
		},
		["template"] = { ["enabled"] = true, ["index"] = 1, ["ignoreClasses"] = { } },
	},
	["newcharacter"] = {
		["races"] = {
			["HUMAN"] = true,
			["DWARF"] = true,
			["NIGHTELF"] = true,
			["GNOME"] = true,
			["DRAENEI"] = true,
			["WORGEN"] = true,
			["PANDAREN"] = true,
			["ORC"] = true,
			["SCOURGE"] = true,
			["TAUREN"] = true,
			["TROLL"] = true,
			["BLOODELF"] = true,
			["GOBLIN"] = true,
		},
		["classes"] = {
			["WARRIOR"] = true,
			["PALADIN"] = true,
			["HUNTER"] = true,
			["ROGUE"] = true,
			["PRIEST"] = true,
			["SHAMAN"] = true,
			["MAGE"] = true,
			["WARLOCK"] = true,
			["MONK"] = true,
			["DRUID"] = true,
			["DEMONHUNTER"] = false,
			["DEATHKNIGHT"] = false,
		},
		["alliedRaces"] = { 
			["LIGHTFORGEDDRAENEI"] = false,
			["HIGHMOUNTAINTAUREN"] = false,
			["NIGHTBORNE"] = false,
			["VOIDELF"] = false,
			["DARKIRONDWARF"] = false,
			["KULTIRAN"] = false,
			["MECHAGNOME"] = false,
			["MAGHARORC"] = false,
			["ZANDALARITROLL"] = false,
			["VULPERA"] = false,
		},
	}
}

KioskModeSplashMixin = {}

function KioskModeSplashMixin:OnLoad()
	self.autoEnterWorld = false;
	self.mode = nil;
end

function KioskModeSplashMixin:OnShow()
	self.mode = nil;

	self.BG:SetAtlas("kiosk-BG");
	self.NewExpansionButton.Button:SetAtlas("kiosk-button");
	self.NewExpansionButton.Highlight:SetAtlas("kiosk-button");
end

function KioskModeSplashMixin:SetMode(mode)
	KioskModeSplash.mode = mode;
end

function KioskModeSplashMixin:GetModeData()
	return kioskModeData[KioskModeSplash.mode];
end

function KioskModeSplashMixin:GetMode()
	return KioskModeSplash.mode;
end

function KioskModeSplashMixin:GetIDForSelection(type, selection)
	if (type == "races") then
		return C_CharacterCreation.GetRaceIDFromName(selection);
	elseif (type == "classes") then
		return C_CharacterCreation.GetClassIDFromName(selection);
	end

	return nil;
end

function KioskModeSplashMixin:SetAutoEnterWorld(value)
	KioskModeSplash.autoEnterWorld = value;
end

function KioskModeSplashMixin:GetAutoEnterWorld()
	return KioskModeSplash.autoEnterWorld;
end

function KioskModeSplashMixin:StartSession()
	Kiosk.StartSession();
end

NewCharacterButtonMixin = {}

function NewCharacterButtonMixin:OnClick(button, down)
	KioskModeSplashMixin:StartSession();

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	KioskModeSplashMixin:SetMode("newcharacter");
end

NewExpansionButtonMixin = {}

function NewExpansionButtonMixin:OnClick(button, down)
	KioskModeSplashMixin:StartSession();

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	KioskModeSplashMixin:SetMode("highlevel");
	GlueParent_SetScreen("charcreate");
end
