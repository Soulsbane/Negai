local AddonName, Addon = ...

--auto repair and sell trash when visiting a vendor
function Addon:OnInitialize()
	--self:RegisterEvent("MERCHANT_SHOW")
	self:RegisterEvent("DELETE_ITEM_CONFIRM")
	self:SetupCVars()
	self:MoveChatTabs()
	--self:HideMicroButtons()
	self:HideMiniMapButtons()
    self:HideTalentAlert()
	self:StartTimer(3)
end

function Addon:HideOrderHallCommandBar()
	local b = OrderHallCommandBar
	b:UnregisterAllEvents()
	b:SetScript("OnShow", b.Hide)
	b:Hide()
end

function Addon:HideTalkingHead()
	--TalkingHeadFrame:SetScript("OnShow", StoreMicroButton.Hide)
	--TalkingHeadFrame.Show = function() end
	TalkingHeadFrame:Hide()
end

function Addon:OnAddonLoaded(addon)
	if addon == "Blizzard_TalkingHeadUI" then
		print("Hiding TalkingHeadFrame")
		hooksecurefunc("TalkingHeadFrame_PlayCurrent", function()
			TalkingHeadFrame:Hide()
		end)
	end
	--self:HideTalkingHead()

	if addon == "Blizzard_OrderHallUI" then
		print("Hiding OrderHallCommandBar")
		self:HideOrderHallCommandBar()
	end

	--[[ if addon == "MountSpy" then
		MountSpy_MainFrame:Hide()
	end]]
end

function Addon:MERCHANT_SHOW()
	if CanMerchantRepair() then
		--INFO: Auto repair items
		local repairAllCost, canRepair = GetRepairAllCost()

		if canRepair then
			RepairAllItems()
		end

		--INFO: Sell trash items
		for bag=0,4 do
			for slot=0,GetContainerNumSlots(bag) do
				local link = GetContainerItemLink(bag, slot)

				if link and select(3, GetItemInfo(link)) == 0 then
					ShowMerchantSellCursor(1)
					UseContainerItem(bag, slot)
				end
			end
		end
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

			--'colorblindMode 1',
			--'colorblindshader 3' --deuteranopia,
			-- Keep this at one until wine handles multiple cores better.
			-- timingmethod 1 is generally for systems where the cores do not synchronize.
			-- timingmethod 2 is a higher resolution timing method and you won't hit the
			-- cap with that.
			--'timingMethod 0',

			-- How the camera should move between saved positions (1: smooth, 2: instant).
			'cameraViewBlendStyle 2',

			-- http://forums.worldofwarcraft.com/thread.html?topicId=1778017311&sid=1&pageNo=5#96
			-- ╔════════╤════════╤════════╤════════╤════════╤════════╤════════╤════════╗
			-- ║ Core 8 │ Core 7 │ Core 6 │ Core 5 │ Core 4 │ Core 3 │ Core 2 │ Core 1 ║
			-- ╠════════╪════════╪════════╪════════╪════════╪════════╪════════╪════════╣
			-- ║  +128  │  +64   │  +32   │  +16   │   +8   │   +4   │   +2   │   +1   ║
			-- ╚════════╧════════╧════════╧════════╧════════╧════════╧════════╧════════╝
			--'processAffinityMask 15',

			--0 tells WoW to automatically handle cache sizes. I never was particularly fond of this behavior, so I'd normally put in my own values on D3D9ex. I've found that using about 75-80% of your video card's RAM worked best. The value can modified --by putting this in the Config.wtf folder:
			--Also note don't use less than 32 or greater than 2047. DX9 only.
			--'gxTextureCacheSize 1024',
			--[['gxApi d3d9',
			'gxFixLag 1',
			'gxCursor 1',
			'gxWindow 1',]]

			--Enable better tab targeting.
			--'TargetNearestUseOld 0',

			'NameplatePersonalShowAlways 0',
			'NameplatePersonalShowInCombat 0',
			'NameplatePersonalShowWithTarget 0',
			'nameplateMaxDistance 40',
			'namePlateMinScale 1',
			'namePlateMaxScale 1',
			'worldPreloadNonCritical 0',
		}
		do
			SetCVar(string.split(' ', cvarData))
		end
end

-- INFO: This puts the chat tabs on the bottom of the chat frame
function Addon:MoveChatTabs()
	GENERAL_CHAT_DOCK:ClearAllPoints()
	GENERAL_CHAT_DOCK:SetPoint("TOPLEFT", ChatFrame1, "BOTTOMLEFT", 0, -1)
	GENERAL_CHAT_DOCK:SetWidth(ChatFrame1:GetWidth())
	hooksecurefunc("FCF_SetTabPosition", function(chatFrame, x)

	local chatTab = _G[chatFrame:GetName().."Tab"];
	chatTab:ClearAllPoints();
	chatTab:SetPoint("BOTTOMLEFT", chatFrame:GetName().."Background", "TOPLEFT", x+2, -179)
	end)

end

function Addon:HideMicroButtons()
	for _, button in ipairs(MICRO_BUTTONS) do
		_G[button]:Hide()
	end

	-- INFO: Ensures the store button stays hidden
	StoreMicroButton:SetScript("OnShow", StoreMicroButton.Hide)
	StoreMicroButton.Show = function() end
	StoreMicroButton:Hide()

	-- INFO: Fixes error AchievementMicroButton_Update a nil value
	if not AchievementMicroButton_Update then
	 AchievementMicroButton_Update = function() end
	end
end

function Addon:HideTalentAlert()
    MainMenuMicroButton_SetAlertsEnabled(false)
end

function Addon:HideMiniMapButtons()
	GarrisonLandingPageMinimapButton:SetScript("OnShow", GarrisonLandingPageMinimapButton.Hide)
	GarrisonLandingPageMinimapButton.Show = function() end
	GarrisonLandingPageMinimapButton:Hide()
end

function Addon:OnTimer()
	--lsClockInfoBar:SetScript("OnShow", lsClockInfoBar.Hide)
	--lsClockInfoBar.Show = function() end
	--lsClockInfoBar:Hide()
	--MountSpy_MainFrame:Hide()
end
