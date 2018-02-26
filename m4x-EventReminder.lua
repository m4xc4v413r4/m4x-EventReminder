m4xEventReminderDB = m4xEventReminderDB or {}
m4xEventReminderSettings = m4xEventReminderSettings or {}

local f = CreateFrame("Frame")
local warnframe

f:RegisterEvent("PLAYER_ENTERING_WORLD")

local function AnimateFrame(type)
	warnframe.ag = warnframe:CreateAnimationGroup()
	warnframe.ag.a1 = warnframe.ag:CreateAnimation("Translation")
	warnframe.ag.a1:SetDuration(0.8)
	warnframe.ag.a2 = warnframe.ag:CreateAnimation("Alpha")
	warnframe.ag.a2:SetDuration(0.8)
	if type == "in" then
		warnframe.ag.a1:SetOffset(50,0)
		warnframe.ag.a1:SetSmoothing("OUT")
		warnframe.ag.a2:SetFromAlpha(0)
		warnframe.ag.a2:SetToAlpha(1)
		warnframe.ag.a2:SetSmoothing("IN")
		warnframe.ag:SetScript("OnFinished",function(self)
			warnframe:SetPoint("LEFT", 50, 10)
			warnframe:SetAlpha(1)
		end)
	elseif type == "out" then
		warnframe.ag.a1:SetOffset(-50,0)
		warnframe.ag.a1:SetSmoothing("IN")
		warnframe.ag.a2:SetFromAlpha(1)
		warnframe.ag.a2:SetToAlpha(0)
		warnframe.ag.a2:SetSmoothing("OUT")
		warnframe.ag:SetScript("OnFinished",function(self)
			warnframe:SetPoint("LEFT", 0, 10)
			warnframe:SetAlpha(0)
			warnframe:Hide()
		end)
	end
	warnframe.ag:Play()
end

local function MakeWarnFrame(eventI)
	warnframe = CreateFrame("Frame", "m4xERWarnFrame", UIParent, "AdventureJournal_SecondaryTemplate")
	local warnframebtn1 = CreateFrame("Button", "m4xERWarnBtn1", warnframe.centerDisplay, "UIPanelButtonTemplate")
	local warnframebtn2 = CreateFrame("Button", "m4xERWarnBtn2", warnframe.centerDisplay, "UIPanelButtonTemplate")

	warnframe.reward:Hide()
	warnframe.centerDisplay.button:Hide()

	warnframe:SetFrameStrata("DIALOG")
	warnframe:SetPoint("LEFT", 0, 10)
	warnframe:SetAlpha(0)

	if EncounterJournalSuggestFrame["Suggestion" .. eventI].reward.data and m4xEventReminderDB["OptBtn-Reward1-Enabled"] then
		warnframe.reward.data = EncounterJournalSuggestFrame["Suggestion" .. eventI].reward.data
		warnframe.reward.icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask")
		warnframe.reward.icon:SetTexture(warnframe.reward.data.itemIcon or warnframe.reward.data.currencyIcon or "Interface\\Icons\\achievement_guildperk_mobilebanking")
		warnframe.reward:SetScript("OnMouseDown", function(self) end)
		warnframe.reward:Show()
	end

	warnframe.icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask")
	warnframe.icon:SetTexture(EncounterJournalSuggestFrame.suggestions[eventI].iconPath)

	warnframe.centerDisplay.title.text:SetText(EncounterJournalSuggestFrame.suggestions[eventI].title)
	warnframe.centerDisplay.title:SetHeight(warnframe.centerDisplay.title.text:GetHeight())

	warnframe.centerDisplay.description.text:SetText(EncounterJournalSuggestFrame.suggestions[eventI].description)
	warnframe.centerDisplay.description:SetHeight(warnframe.centerDisplay.description.text:GetHeight())

	warnframebtn1:SetPoint("TOPLEFT", warnframe.centerDisplay.description, "BOTTOMLEFT", 0, -6)
	warnframebtn1:SetText("Get Quest")
	warnframebtn1:SetSize(warnframebtn1:GetTextWidth() + 36, warnframebtn1:GetTextHeight() + 12)
	warnframebtn1:SetScript("OnClick", function(self)
		f:RegisterEvent("QUEST_DETAIL")
		if eventI > 1 then
			EncounterJournalSuggestFrame["Suggestion" .. eventI].centerDisplay.button:Click()
		else
			EncounterJournalSuggestFrame.Suggestion1.button:Click()
		end
		AnimateFrame("out")
	end)

	warnframebtn2:SetPoint("LEFT", warnframebtn1, "RIGHT", 6, 0)
	warnframebtn2:SetText("Dismiss")
	warnframebtn2:SetSize(warnframebtn1:GetSize())
	warnframebtn2:SetScript("OnClick", function(self)
		AnimateFrame("out")
	end)

	warnframe.centerDisplay:SetHeight(warnframe.centerDisplay.title:GetHeight() + 4 + warnframe.centerDisplay.description:GetHeight() + 6 + warnframebtn1:GetHeight())

	AnimateFrame("in")
end

local function CheckBonusEvents()
	m4xEventReminderDB["FirstConfig"] = 1
	EncounterJournal_LoadUI()
	EJSuggestFrame_RefreshDisplay()
	local eventIndex = 4
	while eventIndex > 0 do
		eventIndex = eventIndex - 1
		if eventIndex == 0 then
			if EncounterJournalSuggestFrameNextButton:IsEnabled() then
				eventIndex = 1
				EncounterJournalSuggestFrameNextButton:Click()
			else
				break
			end
		end
		local eventName = EncounterJournalSuggestFrame.suggestions[eventIndex].title
		if strmatch(eventName, "Bonus Event:") then
			for k, v in pairs(m4xEventReminderDB) do
				local arg1 = strsub(eventName, 14)
				local arg2 = strsub(k, 16)
				if arg1 == arg2 then
					if tostring(v) == "true" then
						if m4xEventReminderDB["OptBtn-Warn1-Enabled"] then
							MakeWarnFrame(eventIndex)
						else
							f:RegisterEvent("QUEST_DETAIL")
							if eventIndex > 1 then
								EncounterJournalSuggestFrame["Suggestion" .. eventIndex].centerDisplay.button:Click()
							else
								EncounterJournalSuggestFrame.Suggestion1.button:Click()
							end
						end
					end
					break
				end
			end
			break
		end
	end
end

local function MakeOpt(type, name, text, pos1, pos2, pos3, pos4, pos5, extra)
if type == "btn" then
		local optbtn = CreateFrame("CheckButton", "m4xEROptBtn" .. name, m4xEventReminderSettings.OptMenu, "InterfaceOptionsCheckButtonTemplate")
		optbtn:SetPoint(pos1, pos2, pos3, pos4, pos5)
		_G[optbtn:GetName() .. "Text"]:SetText(text)
		if extra then
			optbtn.tooltipText = text
			optbtn.tooltipRequirement = extra
		end
		if not m4xEventReminderDB["FirstConfig"] then
			m4xEventReminderDB["OptBtn-" .. name .. "-" .. text] = true
		end
		optbtn:SetChecked(m4xEventReminderDB["OptBtn-" .. name .. "-" .. text])
		optbtn:SetScript("OnClick", function()
			if optbtn:GetChecked() then
				m4xEventReminderDB["OptBtn-" .. name .. "-" .. text] = true
			else
				m4xEventReminderDB["OptBtn-" .. name .. "-" .. text] = false
			end
			optbtn:SetChecked(m4xEventReminderDB["OptBtn-" .. name .. "-" .. text])
		end)
	elseif type == "title" then
		local opttitle = m4xEventReminderSettings.OptMenu:CreateFontString("m4xEROptTitle" .. name, "OVERLAY", "GameFont" .. extra)
		opttitle:SetPoint(pos1, pos2, pos3, pos4, pos5)
		opttitle:SetText(text)
	end
end

local function InitSettings()
	m4xEventReminderSettings.OptMenu = CreateFrame("Frame", "m4xEROpt", UIParent)
	m4xEventReminderSettings.OptMenu.name = "m4x Event Reminder"
	InterfaceOptions_AddCategory(m4xEventReminderSettings.OptMenu)

	local optname = MakeOpt("title", "Main", "m4x Event Reminder", "TOPLEFT", "m4xEROpt", "TOPLEFT", 15, -15, "NormalLarge")

	local filtertitle = MakeOpt("title", "Filter", "Bonus Event Filter", "TOPLEFT", "m4xEROptTitleMain", "BOTTOMLEFT", 0, -15, "Normal")
	local filtersubtitle = MakeOpt("title", "SubFilter", "Choose the Events you want to do.", "TOPLEFT", "m4xEROptTitleFilter", "BOTTOMLEFT", 0, -5, "HighlightSmall")

	local filter1 = MakeOpt("btn", "Filter1", "Battlegrounds", "TOPLEFT", "m4xEROptTitleSubFilter", "BOTTOMLEFT", 0, -10, "Win 4 Battleground matches.") -- Confirmed
	local filter2 = MakeOpt("btn", "Filter2", "Dungeons", "LEFT", "m4xEROptBtnFilter1", "RIGHT", 100, 0, "Complete 4 dungeons on Mythic difficulty.") -- Confirmed
	local filter3 = MakeOpt("btn", "Filter3", "Pet Battles", "LEFT", "m4xEROptBtnFilter2", "RIGHT", 100, 0, "Defeat 5 players through Find Battle with a team of level 25 pets.") -- Confirmed
	local filter4 = MakeOpt("btn", "Filter4", "World Quests", "TOPLEFT", "m4xEROptBtnFilter1", "BOTTOMLEFT", 0, -10, "Complete 20 World Quests in the Broken Isles.") -- Confirmed
	local filter5 = MakeOpt("btn", "Filter5", "Timewalking", "LEFT", "m4xEROptBtnFilter4", "RIGHT", 100, 0, "Complete 5 Timewalking dungeons.") -- Confirmed
	local filter6 = MakeOpt("btn", "Filter6", "Skirmishes", "LEFT", "m4xEROptBtnFilter5", "RIGHT", 100, 0, "Win 10 Arena Skirmish battles.") -- Confirmed

	local warntitle = MakeOpt("title", "Warn", "Bonus Event Warning", "TOPLEFT", "m4xEROptBtnFilter4", "BOTTOMLEFT", 0, -15, "Normal")
	local warnsubtitle = MakeOpt("title", "SubWarn", "Warn on chosen Events.", "TOPLEFT", "m4xEROptTitleWarn", "BOTTOMLEFT", 0, -5, "HighlightSmall")
	local warn1 = MakeOpt("btn", "Warn1", "Enabled", "TOPLEFT", "m4xEROptTitleSubWarn", "BOTTOMLEFT", 0, -10)

	local questtitle = MakeOpt("title", "Quest", "Bonus Event Quest", "TOPLEFT", "m4xEROptBtnWarn1", "BOTTOMLEFT", 0, -15, "Normal")
	local questsubtitle = MakeOpt("title", "SubQuest", "Auto-Accept quest on chosen Events. If the Warning is Enabled, you will still be warned before accepting the quest.", "TOPLEFT", "m4xEROptTitleQuest", "BOTTOMLEFT", 0, -5, "HighlightSmall")
	local quest1 = MakeOpt("btn", "Quest1", "Auto-Accept", "TOPLEFT", "m4xEROptTitleSubQuest", "BOTTOMLEFT", 0, -10)

	local rewardtitle = MakeOpt("title", "Reward", "Bonus Event Reward", "TOPLEFT", "m4xEROptBtnQuest1", "BOTTOMLEFT", 0, -15, "Normal")
	local rewardsubtitle = MakeOpt("title", "SubReward", "Show the Event reward on the Event Warning.", "TOPLEFT", "m4xEROptTitleReward", "BOTTOMLEFT", 0, -5, "HighlightSmall")
	local reward1 = MakeOpt("btn", "Reward1", "Enabled", "TOPLEFT", "m4xEROptTitleSubReward", "BOTTOMLEFT", 0, -10)

	if UnitLevel("player") == GetMaxPlayerLevel() then
		C_Timer.After(20, CheckBonusEvents)
	end
end

f:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		InitSettings()
		f:UnregisterEvent("PLAYER_ENTERING_WORLD")
	elseif event == "QUEST_DETAIL" then
		if m4xEventReminderDB["OptBtn-Quest1-Auto-Accept"] then
			AcceptQuest()
		end
		f:UnregisterEvent("QUEST_DETAIL")
	end
end)