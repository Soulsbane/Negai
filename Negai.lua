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

function Addon:HideTalentAlert()
    MainMenuMicroButton_SetAlertsEnabled(false, " ")
end
