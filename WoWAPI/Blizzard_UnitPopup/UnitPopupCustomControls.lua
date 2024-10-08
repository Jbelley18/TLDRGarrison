UnitPopupAttachableFrameMixin = {};

function UnitPopupAttachableFrameMixin:GetDesiredSize()
	return self:GetWidth(), self:GetHeight();
end

function UnitPopupAttachableFrameMixin:SetContextData(contextData)
	self.contextData = contextData;
end

function UnitPopupAttachableFrameMixin:GetContextData()
	return self.contextData;
end

function UnitPopupAttachableFrameMixin:OnAttach()
	-- Derive. Called after the context data is assigned and the frame is shown.
end

UnitPopupVoiceMemberInfoMixin = {};

function UnitPopupVoiceMemberInfoMixin:GetPlayerLocation()
	return self:GetParent():GetContextData().playerLocation;
end

function UnitPopupVoiceMemberInfoMixin:CallAccessor(...)
	return self.accessor(self:GetPlayerLocation(), ...);
end

function UnitPopupVoiceMemberInfoMixin:CallMutator(...)
	return self.mutator(self:GetPlayerLocation(), ...);
end

UnitPopupVoiceToggleButtonMixin = {};

function UnitPopupVoiceToggleButtonMixin:OnEnter()
	PropertyBindingMixin.OnEnter(self);
	ExecuteFrameScript(self:GetParent():GetParent(), "OnEnter");
end

function UnitPopupVoiceToggleButtonMixin:OnLeave()
	PropertyBindingMixin.OnLeave(self);
	ExecuteFrameScript(self:GetParent():GetParent(), "OnLeave");
end

UnitPopupVoiceLevelsMixin = CreateFromMixins(UnitPopupAttachableFrameMixin);

function UnitPopupVoiceLevelsMixin:GetVoiceChannelID()
	return self:GetContextData().voiceChannelID;
end

function UnitPopupVoiceLevelsMixin:GetVoiceMemberID()
	return self:GetContextData().voiceMemberID;
end

function UnitPopupVoiceLevelsMixin:GetVoiceChannel()
	return self:GetContextData().voiceChannel;
end

function UnitPopupVoiceLevelsMixin:OnLoad()
	local function UpdateText(slider, value, isMouse)
		self.Text:SetText(FormatPercentage(value / 100, true))
	end

	self.Slider:RegisterPropertyChangeHandler("OnValueChanged", UpdateText);
end

function UnitPopupVoiceLevelsMixin:OnShow()
	self.Toggle:RegisterEvents();
end

function UnitPopupVoiceLevelsMixin:OnHide()
	self.Toggle:UnregisterEvents();
end

function UnitPopupVoiceLevelsMixin:OnAttach()
	self.Toggle:UpdateVisibleState();
	self.Slider:UpdateVisibleState();
end

UnitPopupToggleMuteMixin = {};

function UnitPopupToggleMuteMixin:IsForPublicChannel()
	local voiceChannel = self:GetParent():GetVoiceChannel();
	return voiceChannel and IsPublicVoiceChannel(voiceChannel);
end

function UnitPopupToggleMuteMixin:OnLoad()
	VoiceToggleButtonMixin.OnLoad(self);

	VoiceToggleMuteMixin.SetupMuteButton(self);

	self:AddStateAtlas(MUTE_SILENCE_STATE_NONE, "voicechat-icon-mic");
	self:AddStateAtlas(MUTE_SILENCE_STATE_MUTE, "voicechat-icon-mic-mute");
	self:AddStateAtlas(MUTE_SILENCE_STATE_SILENCE, "voicechat-icon-mic-silenced");
	self:AddStateAtlas(MUTE_SILENCE_STATE_MUTE_AND_SILENCE, "voicechat-icon-mic-mutesilenced");
	self:AddStateAtlas(MUTE_SILENCE_STATE_PARENTAL_MUTE, "voicechat-icon-mic-silenced");
	self:AddStateAtlas(MUTE_SILENCE_STATE_MUTE_AND_PARENTAL_MUTE, "voicechat-icon-mic-mutesilenced");

	self:SetUseIconAsHighlight(true);
end

function UnitPopupToggleMuteMixin:RegisterEvents()
	self:RegisterStateUpdateEvent("VOICE_CHAT_MUTED_CHANGED");
	self:RegisterStateUpdateEvent("VOICE_CHAT_SILENCED_CHANGED");
end

function UnitPopupToggleMuteMixin:UnregisterEvents()
	self:UnregisterStateUpdateEvent("VOICE_CHAT_MUTED_CHANGED");
	self:UnregisterStateUpdateEvent("VOICE_CHAT_SILENCED_CHANGED");
end

UnitPopupVoiceMicrophoneVolumeSliderMixin = {};

function UnitPopupVoiceMicrophoneVolumeSliderMixin:OnLoad()
	self:SetAccessorFunction(C_VoiceChat.GetInputVolume);
	self:SetMutatorFunction(C_VoiceChat.SetInputVolume);
end

UnitPopupToggleDeafenMixin = {};

function UnitPopupToggleDeafenMixin:OnLoad()
	VoiceToggleButtonMixin.OnLoad(self);

	self:SetAccessorFunction(C_VoiceChat.IsDeafened);
	self:SetMutatorFunction(C_VoiceChat.SetDeafened);
	self:AddStateAtlas(false, "voicechat-icon-speaker");
	self:AddStateAtlas(true, "voicechat-icon-speaker-mute");
	self:AddStateTooltipString(false, VOICE_TOOLTIP_DEAFEN);
   	self:AddStateTooltipString(true, VOICE_TOOLTIP_UNDEAFEN);
	self:SetUseIconAsHighlight(true);
end

function UnitPopupToggleDeafenMixin:RegisterEvents()
	self:RegisterStateUpdateEvent("VOICE_CHAT_DEAFENED_CHANGED");
end

function UnitPopupToggleDeafenMixin:UnregisterEvents()
	self:UnregisterStateUpdateEvent("VOICE_CHAT_DEAFENED_CHANGED");
end

UnitPopupVoiceSpeakerVolumeSliderMixin = {};

function UnitPopupVoiceSpeakerVolumeSliderMixin:OnLoad()
	self:SetAccessorFunction(C_VoiceChat.GetOutputVolume);
	self:SetMutatorFunction(C_VoiceChat.SetOutputVolume);
end

UnitPopupToggleUserMuteMixin = {};

function UnitPopupToggleUserMuteMixin:IsMuted()
	local contextData = self:GetParent():GetContextData();
	if contextData.playerLocation then
		return C_VoiceChat.IsMemberMuted(contextData.playerLocation);
	end
	return false;
end

function UnitPopupToggleUserMuteMixin:IsSilenced()
	local voiceChannelID = self:GetParent():GetVoiceChannelID();
	if voiceChannelID then
		local voiceMemberID = self:GetParent():GetVoiceMemberID();	
		return C_VoiceChat.IsMemberSilenced(voiceChannelID, voiceMemberID);
	end
	return false;
end

function UnitPopupToggleUserMuteMixin:ToggleMuted()
	local contextData = self:GetParent():GetContextData();
	if contextData.playerLocation then
		C_VoiceChat.ToggleMemberMuted(contextData.playerLocation);
	end
end

function UnitPopupToggleUserMuteMixin:OnLoad()
	VoiceToggleButtonMixin.OnLoad(self);
	RosterMemberMuteButtonMixin.SetupMuteButton(self);

	self:AddStateAtlas(MUTE_SILENCE_STATE_NONE, "voicechat-icon-speaker");
	self:AddStateAtlas(MUTE_SILENCE_STATE_MUTE, "voicechat-icon-speaker-mute");
	self:AddStateAtlas(MUTE_SILENCE_STATE_SILENCE, "voicechat-icon-speaker-silenced");
	self:AddStateAtlas(MUTE_SILENCE_STATE_MUTE_AND_SILENCE, "voicechat-icon-speaker-mutesilenced");
	self:SetUseIconAsHighlight(true);
end

function UnitPopupToggleUserMuteMixin:RegisterEvents()
	self:RegisterStateUpdateEvent("VOICE_CHAT_CHANNEL_MEMBER_MUTE_FOR_ME_CHANGED");
	self:RegisterStateUpdateEvent("VOICE_CHAT_CHANNEL_MEMBER_MUTE_FOR_ALL_CHANGED");
	self:RegisterStateUpdateEvent("VOICE_CHAT_CHANNEL_MEMBER_SILENCED_CHANGED");
end

function UnitPopupToggleUserMuteMixin:UnregisterEvents()
	self:UnregisterStateUpdateEvent("VOICE_CHAT_CHANNEL_MEMBER_MUTE_FOR_ME_CHANGED");
	self:UnregisterStateUpdateEvent("VOICE_CHAT_CHANNEL_MEMBER_MUTE_FOR_ALL_CHANGED");
	self:UnregisterStateUpdateEvent("VOICE_CHAT_CHANNEL_MEMBER_SILENCED_CHANGED");
end

UnitPopupVoiceUserVolumeSliderMixin = {};

function UnitPopupVoiceUserVolumeSliderMixin:OnLoad()
	self:SetAccessorFunction(C_VoiceChat.GetMemberVolume);
	self:SetMutatorFunction(C_VoiceChat.SetMemberVolume);
end
