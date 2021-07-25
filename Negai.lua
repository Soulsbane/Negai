local AddonName, Addon = ...

function Addon:OnInitialize()
	--self:RegisterEvent("DELETE_ITEM_CONFIRM")
	self:SetupCVars()
    self:HideTalentAlert()
end

function Addon:HideOrderHallCommandBar()
	local b = OrderHallCommandBar
	b:UnregisterAllEvents()
	b:SetScript("OnShow", b.Hide)
	b:Hide()
end

function Addon:HideTalkingHead()
	hooksecurefunc("TalkingHeadFrame_PlayCurrent", function()
		TalkingHeadFrame_CloseImmediately
	end)
end

function Addon:OnAddonLoaded(addon)
	self:HideTalkingHead()

	if addon == "Blizzard_OrderHallUI" then
		print("Hiding OrderHallCommandBar")
		self:HideOrderHallCommandBar()
	end
end

function Addon:DELETE_ITEM_CONFIRM()
	if InCombatLockdown() then return end -- only out-of combat is safe to simulate clicks

	if(StaticPopup_Visible("DELETE_GOOD_ITEM")) then
		StaticPopup1EditBox:SetText("delete")
	end

	for i = 1, 10 do
		local frame = _G["StaticPopup" .. i]

		if frame and frame.IsShown and frame:IsShown() and frame.which then
			local button = _G["StaticPopup" .. i .. "Button1"]

			if button and button.IsShown and button:IsShown() then
				if button.Click then
					button:Click("LeftButton")
				end
			end
		end
	end
end

function Addon:SetupCVars()
	for _, cvarData in pairs{
			'autoLootDefault 1 AUTO_LOOT_DEFAULT_TEXT',
			'advancedWatchFrame 1 ADVANCED_OBJECTIVES_TEXT',
			'profanityFilter 0 PROFANITY_FILTER',
			'chatBubbles 0 CHAT_BUBBLES_TEXT',
			'chatBubblesParty 0 PARTY_CHAT_BUBBLES_TEXT',
			'cameraWaterCollision 0 WATER_COLLISION',
			'scriptErrors 1 SHOW_LUA_ERRORS',
			'ffxGlow 0',

			-- How the camera should move between saved positions (1: smooth, 2: instant).
			'cameraViewBlendStyle 2',
			'worldPreloadNonCritical 0',
		}
		do
			SetCVar(string.split(' ', cvarData))
		end
end

function Addon:HideTalentAlert()
    MainMenuMicroButton_SetAlertsEnabled(false, " ")
end
