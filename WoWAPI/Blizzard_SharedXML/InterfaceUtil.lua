function ReloadUI()
	C_UI.Reload();
end

function PrintToDebugWindow(msg)
	if C_Debug and C_Debug.PrintToDebugWindow then
		C_Debug.PrintToDebugWindow(msg);
	end
end

function ViewInDebugWindow(...)
	if C_Debug and C_Debug.ViewInDebugWindow then
		C_Debug.ViewInDebugWindow(...);
	end
end

StoreInterfaceUtil = {};

-- Returns true if there is a subscription product available and the store was toggled.
function StoreInterfaceUtil.OpenToSubscriptionProduct()
	if C_StorePublic.DoesGroupHavePurchaseableProducts(WOW_SUBSCRIPTION_CATEGORY_ID) then
		StoreFrame_SelectSubscriptionProduct()
		ToggleStoreUI();
		return true;
	elseif C_StorePublic.DoesGroupHavePurchaseableProducts(WOW_GAME_TIME_CATEGORY_ID) then
		StoreFrame_SelectGameTimeProduct()
		ToggleStoreUI();
		return true;
	end

	PlaySound(SOUNDKIT.GS_LOGIN_NEW_ACCOUNT);
	LoadURLIndex(22);
	return false;
end
