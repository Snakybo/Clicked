local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")
local LibTalentInfo = LibStub("LibTalentInfo-1.0")

-- /run local a,b,c=table.concat,{},{};for d=1,GetNumShapeshiftForms() do local _,_,_,f=GetShapeshiftFormInfo(d);local e=GetSpellInfo(f);b[#b+1]=e;c[#c+1]=f;end print("{ "..a(c, ",").." }, --"..a(b,", "))
local shapeshiftForms = {
	-- Arms Warrior
	-- Fury Warrior
	-- Protection Warrior
	[71] = {},
	[72] = {},
	[73] = {},

	-- Holy Paladin
	-- Protection Paladin
	-- Retribution Paladin
	[65] = { 32223, 465, 183435 }, -- Crusader Aura, Devotion Aura, Retribution Aura
	[66] = { 32223, 465, 183435 }, -- Crusader Aura, Devotion Aura, Retribution Aura
	[70] = { 32223, 465, 183435 }, -- Crusader Aura, Devotion Aura, Retribution Aura

	-- Beast Mastery Hunter
	-- Marksmanship Hunter
	-- Survival Hunter
	[253] = {},
	[254] = {},
	[255] = {},

	-- Assassination Rogue
	-- Outlaw Rogue
	-- Subtlety Rogue
	[259] = { 1784 }, -- Stealth
	[260] = { 1784 }, -- Stealth
	[261] = { 1784 }, -- Stealth

	-- Discipline Priest
	-- Holy Priest
	-- Shadow Priest
	[256] = {},
	[257] = {},
	[258] = { 232698 }, -- Shadowform

	-- Blood Death Knight
	-- Frost Death Knight
	-- Unholy Death Knight
	[250] = {},
	[251] = {},
	[252] = {},

	-- Elemental Shaman
	-- Enhancement Shaman
	-- Restoration Shaman
	[262] = {},
	[263] = {},
	[264] = {},

	-- Arcane Mage
	-- Fire Mage
	-- Frost Mage
	[62] = {},
	[63] = {},
	[64] = {},

	-- Afflication Warlock
	-- Demonology Warlock
	-- Destruction Warlock
	[265] = {},
	[266] = {},
	[267] = {},

	-- Brewmaster Monk
	-- Mistweaver Monk
	-- Windwalker Monk
	[268] = {},
	[270] = {},
	[269] = {},

	-- Balance Druid
	-- Feral Druid
	-- Guardian Druid
	-- Restoration Druid
	[102] = { 5487, 768, 783, 197625, 114282, 210053 }, -- Bear Form, Cat Form, Travel Form, Moonkin Form, Treant Form, Mount Form
	[103] = { 5487, 768, 783, 197625, 114282, 210053 }, -- Bear Form, Cat Form, Travel Form, Moonkin Form, Treant Form, Mount Form
	[104] = { 5487, 768, 783, 197625, 114282, 210053 }, -- Bear Form, Cat Form, Travel Form, Moonkin Form, Treant Form, Mount Form
	[105] = { 5487, 768, 783, 197625, 114282, 210053 }, -- Bear Form, Cat Form, Travel Form, Moonkin Form, Treant Form, Mount Form

	-- Havoc Demon Hunter
	-- Vengeance Demon Hunter
	[577] = {},
	[581] = {}
}

local races

if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
	races = {
		-- Alliance
		1, -- Human
		3, -- Dwarf
		4, -- NightElf
		7, -- Gnome
		11, -- Draenei
		22, -- Worgen
		29, -- VoidElf
		30, -- LightforgedDraenei
		32, -- KulTiran
		34, -- DarkIronDwarf
		37, -- Mechagnome

		-- Horde
		2, -- Orc
		5, -- Scourge
		6, -- Tauren
		8, -- Troll
		9, -- Goblin
		10, -- BloodElf
		27, -- Nightborne
		28, -- HighmountainTauren
		31, -- ZandalariTroll
		35, -- Vulpera
		36, -- MagharOrc

		-- Neutral
		24, -- Pandaren
	}
elseif WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
	races = {
		-- Alliance
		1, -- Human
		3, -- Dwarf
		4, -- NightElf
		7, -- Gnome

		-- Horde
		2, -- Orc
		5, -- Scourge
		6, -- Tauren
		8, -- Troll
	}
end

function Clicked:ShowAddonIncompatibilityPopup(addon)
	StaticPopupDialogs["ClickedAddonIncompatibilityMessage"] = {
		text = L["ERR_ADDON_INCOMPAT_MESSAGE"]:format(addon),
		button1 = L["ERR_ADDON_INCOMPAT_BUTTON_KEEP_X"]:format(L["ADDON_NAME"]),
		button2 = L["ERR_ADDON_INCOMPAT_BUTTON_KEEP_X"]:format(addon),
		OnAccept = function()
			DisableAddOn(addon)
			ReloadUI()
		end,
		OnCancel = function()
			DisableAddOn("Clicked")
			ReloadUI()
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = false,
		preferredIndex = 3
	}

	StaticPopup_Show("ClickedAddonIncompatibilityMessage")
end

function Clicked:ShowInformationPopup(text)
	StaticPopupDialogs["ClickedInformationMessage"] = {
		text = text,
		button1 = L["MSG_POPUP_BUTTON_CONTINUE"],
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3
	}

	StaticPopup_Show("ClickedInformationMessage")
end

function Clicked:ShowConfirmationPopup(message, func, ...)
	StaticPopupDialogs["ClickedConfirmationMessage"] = {
		text = message,
		button1 = L["MSG_POPUP_BUTTON_YES"],
		button2 = L["MSG_POPUP_BUTTON_NO"],
		OnAccept = func,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3
	}

	StaticPopup_Show("ClickedConfirmationMessage")
end

function Clicked:DeepCopyTable(original)
	if original == nil then
		return nil
	end

	local result = {}

	for k, v in pairs(original) do
		if type(v) == "table" then
			v = self:DeepCopyTable(v)
		end

		result[k] = v
	end

	return result
end

function Clicked:GetDataFromString(string, keyword)
	if self:IsStringNilOrEmpty(string) or self:IsStringNilOrEmpty(keyword) then
		return nil
	end

	local pattern = string.format("<%s=(.-)>", keyword)
	local match = string.match(string, pattern)

	return match
end

function Clicked:IsStringNilOrEmpty(string)
	return string == nil or #string == 0
end

function Clicked:IsClassic()
	return WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
end

function Clicked:GetTriStateLoadOptionValue(option)
	if option.selected == 1 then
		return { option.single }
	elseif option.selected == 2 then
		return { unpack(option.multiple) }
	end

	return nil
end

function Clicked:GetShapeshiftFormsForSpecId(specId)
	return { unpack(shapeshiftForms[specId]) }
end

-- Check if the specified keybind is "restricted", a restricted keybind
-- is not allowed to do various actions as it is required for core game
-- input (such as left and right mouse buttons).
--
-- Restricted keybinds can still be used for bindings, but they will
-- have limited functionality.
function Clicked:IsRestrictedKeybind(keybind)
	return keybind == "BUTTON1" or keybind == "BUTTON2"
end

-- Check if a binding's target unit can have a hostility.
-- This will be false when, for example, PARTY_2 is passed
-- in because party members are by definition always friendly.
-- (at the time of configuration at least, i.e. don't take
-- potential mind controls into account)
function Clicked:CanUnitBeHostile(unit)
	if unit == Clicked.TargetUnits.TARGET then
		return true
	end

	if unit == Clicked.TargetUnits.TARGET_OF_TARGET then
		return true
	end

	if unit == Clicked.TargetUnits.FOCUS then
		return true
	end

	if unit == Clicked.TargetUnits.MOUSEOVER then
		return true
	end

	if unit == Clicked.TargetUnits.HOVERCAST then
		return true
	end

	if unit == Clicked.TargetUnits.PET_TARGET then
		return true
	end

	return false
end

function Clicked:CanUnitBeDead(unit)
	if unit == Clicked.TargetUnits.TARGET then
		return true
	end

	if unit == Clicked.TargetUnits.TARGET_OF_TARGET then
		return true
	end

	if unit == Clicked.TargetUnits.FOCUS then
		return true
	end

	if unit == Clicked.TargetUnits.PARTY_1 then
		return true
	end

	if unit == Clicked.TargetUnits.PARTY_2 then
		return true
	end

	if unit == Clicked.TargetUnits.PARTY_3 then
		return true
	end

	if unit == Clicked.TargetUnits.PARTY_4 then
		return true
	end

	if unit == Clicked.TargetUnits.PARTY_5 then
		return true
	end

	if unit == Clicked.TargetUnits.MOUSEOVER then
		return true
	end

	if unit == Clicked.TargetUnits.HOVERCAST then
		return true
	end

	if unit == Clicked.TargetUnits.PET then
		return true
	end

	if unit == Clicked.TargetUnits.PET_TARGET then
		return true
	end

	return false
end

-- Check if a binding's target unit can have a follow up target.
-- This will be the case for most targets, but some targets act
-- as a stop sign in macro code as they will always be valid.
-- For example [@player] or [@cursor] will always be 'true' and
-- thus it doesn't make sense to allow targets beyond.
function Clicked:CanUnitHaveFollowUp(unit)
	if unit == Clicked.TargetUnits.PLAYER then
		return false
	end

	if unit == Clicked.TargetUnits.CURSOR then
		return false
	end

	if unit == Clicked.TargetUnits.HOVERCAST then
		return false
	end

	if unit == Clicked.TargetUnits.DEFAULT then
		return false
	end

	return true
end

function Clicked:GetActiveBindingAction(binding)
	if binding.type == Clicked.BindingTypes.SPELL then
		return binding.actions.spell
	end

	if binding.type == Clicked.BindingTypes.ITEM then
		return binding.actions.item
	end

	if binding.type == Clicked.BindingTypes.MACRO then
		return binding.actions.macro
	end

	if binding.type == Clicked.BindingTypes.UNIT_SELECT then
		return binding.actions.unitSelect
	end

	if binding.type == Clicked.BindingTypes.UNIT_MENU then
		return binding.actions.unitMenu
	end

	return nil
end

function Clicked:GetLocalizedTargetUnits(excludeHovercast)
	local items = {
		[Clicked.TargetUnits.DEFAULT] = L["BINDING_UI_PAGE_TARGETS_UNIT_DEFAULT"],
		[Clicked.TargetUnits.PLAYER] = L["BINDING_UI_PAGE_TARGETS_UNIT_PLAYER"],
		[Clicked.TargetUnits.TARGET] = L["BINDING_UI_PAGE_TARGETS_UNIT_TARGET"],
		[Clicked.TargetUnits.TARGET_OF_TARGET] = L["BINDING_UI_PAGE_TARGETS_UNIT_TARGETTARGET"],
		[Clicked.TargetUnits.HOVERCAST] = L["BINDING_UI_PAGE_TARGETS_UNIT_HOVERCAST"],
		[Clicked.TargetUnits.MOUSEOVER] = L["BINDING_UI_PAGE_TARGETS_UNIT_MOUSEOVER"],
		[Clicked.TargetUnits.FOCUS] = L["BINDING_UI_PAGE_TARGETS_UNIT_FOCUS"],
		[Clicked.TargetUnits.CURSOR] = L["BINDING_UI_PAGE_TARGETS_UNIT_CURSOR"],
		[Clicked.TargetUnits.PET] = L["BINDING_UI_PAGE_TARGETS_UNIT_PET"],
		[Clicked.TargetUnits.PET_TARGET] = L["BINDING_UI_PAGE_TARGETS_UNIT_PET_TARGET"],
		[Clicked.TargetUnits.PARTY_1] = L["BINDING_UI_PAGE_TARGETS_UNIT_PARTY"]:format("1"),
		[Clicked.TargetUnits.PARTY_2] = L["BINDING_UI_PAGE_TARGETS_UNIT_PARTY"]:format("2"),
		[Clicked.TargetUnits.PARTY_3] = L["BINDING_UI_PAGE_TARGETS_UNIT_PARTY"]:format("3"),
		[Clicked.TargetUnits.PARTY_4] = L["BINDING_UI_PAGE_TARGETS_UNIT_PARTY"]:format("4"),
		[Clicked.TargetUnits.PARTY_5] = L["BINDING_UI_PAGE_TARGETS_UNIT_PARTY"]:format("5")
	}

	local order = {
		Clicked.TargetUnits.DEFAULT,
		Clicked.TargetUnits.PLAYER,
		Clicked.TargetUnits.TARGET,
		Clicked.TargetUnits.TARGET_OF_TARGET,
		Clicked.TargetUnits.HOVERCAST,
		Clicked.TargetUnits.MOUSEOVER,
		Clicked.TargetUnits.FOCUS,
		Clicked.TargetUnits.CURSOR,
		Clicked.TargetUnits.PET,
		Clicked.TargetUnits.PET_TARGET,
		Clicked.TargetUnits.PARTY_1,
		Clicked.TargetUnits.PARTY_2,
		Clicked.TargetUnits.PARTY_3,
		Clicked.TargetUnits.PARTY_4,
		Clicked.TargetUnits.PARTY_5
	}

	if excludeHovercast then
		table.remove(order, 5)
	end

	return items, order
end

function Clicked:GetLocalizedTargetHostility()
	local items = {
		[Clicked.TargetHostility.ANY] = L["BINDING_UI_PAGE_TARGETS_HOSTILITY_ANY"],
		[Clicked.TargetHostility.HELP] = L["BINDING_UI_PAGE_TARGETS_HOSTILITY_FRIEND"],
		[Clicked.TargetHostility.HARM] = L["BINDING_UI_PAGE_TARGETS_HOSTILITY_HARM"]
	}

	local order = {
		Clicked.TargetHostility.ANY,
		Clicked.TargetHostility.HELP,
		Clicked.TargetHostility.HARM
	}

	return items, order
end

function Clicked:GetLocalizedTargetVitals()
	local items = {
		[Clicked.TargetVitals.ANY] = L["BINDING_UI_PAGE_TARGETS_VITALS_ANY"],
		[Clicked.TargetVitals.ALIVE] = L["BINDING_UI_PAGE_TARGETS_VITALS_ALIVE"],
		[Clicked.TargetVitals.DEAD] = L["BINDING_UI_PAGE_TARGETS_VITALS_DEAD"]
	}

	local order = {
		Clicked.TargetVitals.ANY,
		Clicked.TargetVitals.ALIVE,
		Clicked.TargetVitals.DEAD
	}

	return items, order
end

function Clicked:GetLocalizedTargetString(target)
	local result = {}

	if Clicked:CanUnitBeHostile(target.unit) and target.hostility ~= Clicked.TargetHostility.ANY then
		local hostility = self:GetLocalizedTargetHostility()
		table.insert(result, hostility[target.hostility])
	end

	if Clicked:CanUnitBeDead(target.unit) and target.vitals ~= Clicked.TargetVitals.ANY then
		local vitals = self:GetLocalizedTargetVitals()
		table.insert(result, vitals[target.vitals])
	end

	local units = self:GetLocalizedTargetUnits()
	table.insert(result, units[target.unit])

	return table.concat(result, " ")
end

function Clicked:GetLocalizedClasses()
	local items = {}
	local order = {}

	local classes = {}
	FillLocalizedClassList(classes)

	for classId, className in pairs(classes) do
		local _, _, _, color = GetClassColor(classId)
		local name = string.format("|c%s%s|r", color, className)

		items[classId] = string.format("<text=%s>", name)
		table.insert(order, classId)
	end

	table.sort(order)

	return items, order
end

function Clicked:GetLocalizedRaces()
	local items = {}
	local order = {}

	for _, raceId in ipairs(races) do
		local raceInfo = C_CreatureInfo.GetRaceInfo(raceId)

		items[raceInfo.clientFileString] = string.format("<text=%s>", raceInfo.raceName)
		table.insert(order, raceInfo.clientFileString)
	end

	table.sort(order)

	return items, order
end

function Clicked:GetLocalizedSpecializations(classNames)
	local items = {}
	local order = {}

	if classNames == nil then
		classNames = {}
		classNames[1] = select(2, UnitClass("player"))
	end

	if #classNames == 1 then
		local class = classNames[1]
		local specs = LibTalentInfo:GetClassSpecIDs(class) or {}

		for i = 1, #specs do
			local _, name, _, icon = GetSpecializationInfoByID(specs[i])
			local key = i

			items[key] = string.format("<icon=%d><text=%s>", icon, name)
			table.insert(order, key)
		end
	else
		local max = 0

		-- Find class with the most specializations out of all available classes
		if #classNames == 0 then
			for _, specs in LibTalentInfo:AllClasses() do
				if #specs > max then
					max = #specs
				end
			end
		-- Find class with the most specializations out of the selected classes
		else
			for i = 1, #classNames do
				local class = classNames[i]
				local specs = LibTalentInfo:GetClassSpecIDs(class) or {}

				if #specs > max then
					max = #specs
				end
			end
		end

		for i = 1, max do
			local key = i

			items[key] = string.format("<text=%s>", L["BINDING_UI_PAGE_LOAD_OPTIONS_N_SPECIALIZATION"]:format(i))
			table.insert(order, key)
		end
	end

	return items, order
end

function Clicked:GetLocalizedTalents(specializations)
	local items = {}
	local order = {}

	if specializations == nil then
		specializations = {}
		specializations[1] = GetSpecializationInfo(GetSpecialization())
	end

	if #specializations == 1 then
		local spec = specializations[1]

		for tier = 1, MAX_TALENT_TIERS do
			for column = 1, NUM_TALENT_COLUMNS do
				local _, name, texture = LibTalentInfo:GetTalentInfo(spec, tier, column)
				local key = #order + 1

				items[key] = string.format("<icon=%d><text=%s>", texture, name)
				table.insert(order, key)
			end
		end
	else
		for tier = 1, MAX_TALENT_TIERS do
			for column = 1, NUM_TALENT_COLUMNS do
				local key = #order + 1

				items[key] = string.format("<text=%s>", L["BINDING_UI_PAGE_LOAD_OPTIONS_N_TALENT"]:format(tier, column))
				table.insert(order, key)
			end
		end
	end

	return items, order
end

function Clicked:GetLocalizedPvPTalents(specializations)
	local items = {}
	local order = {}

	if specializations == nil then
		specializations = {}
		specializations[1] = GetSpecializationInfo(GetSpecialization())
	end

	if #specializations == 1 then
		local spec = specializations[1]
		local numTalents = LibTalentInfo:GetNumPvPTalentsForSpec(spec, 1)

		for i = 1, numTalents do
			local _, name, texture = LibTalentInfo:GetPvPTalentInfo(spec, 1, i)
			local key = #order + 1

			items[key] = string.format("<icon=%d><text=%s>", texture, name)
			table.insert(order, key)
		end
	else
		local max = 0

		-- Find specialization with the highest number of PvP talents
		if #specializations == 0 then
			for _, specs in LibTalentInfo:AllClasses() do
				for _, spec in ipairs(specs) do
					local numTalents = LibTalentInfo:GetNumPvPTalentsForSpec(spec, 1)

					if numTalents > max then
						max = numTalents
					end
				end
			end
		-- Find specialization with the highest number of PvP talents out of the selected specializations
		else
			for _, spec in ipairs(specializations) do
				local numTalents = LibTalentInfo:GetNumPvPTalentsForSpec(spec, 1)

				if numTalents > max then
					max = numTalents
				end
			end
		end

		for i = 1, max do
			local key = #order + 1

			items[key] = string.format("<text=%s>", L["BINDING_UI_PAGE_LOAD_OPTIONS_N_PVP_TALENT"]:format(i))
			table.insert(order, key)
		end
	end

	return items, order
end

function Clicked:GetLocalizedForms(specializations)
	local items = {}
	local order = {}

	if specializations == nil then
		specializations = {}
		specializations[1] = GetSpecializationInfo(GetSpecialization())
	end

	if #specializations == 1 then
		local spec = specializations[1]
		local defaultForm = L["BINDING_UI_PAGE_LOAD_OPTIONS_STANCE_NONE"]

		-- Balance Druid, Feral Druid, Guardian Druid, Restoration Druid
		if spec == 102 or spec == 103 or spec == 104 or spec == 105 then
			defaultForm = L["BINDING_UI_PAGE_LOAD_OPTIONS_STANCE_HUMANOID"]
		end

		do
			local key = #order + 1

			items[key] = string.format("<text=%s>", defaultForm)
			table.insert(order, key)
		end

		for i = 1, #shapeshiftForms[spec] do
			local name, _, icon = GetSpellInfo(shapeshiftForms[spec][i])
			local key = #order + 1

			items[key] = string.format("<icon=%d><text=%s>", icon, name)
			table.insert(order, key)
		end
	else
		local max = 0

		-- Find specialization with the highest number of forms
		if #specializations == 0 then
			for _, forms in pairs(shapeshiftForms) do
				if #forms > max then
					max = #forms
				end
			end
		-- Find specialization with the highest number of forms out of the selected specializations
		else
			for _, spec in ipairs(specializations) do
				if #shapeshiftForms[spec] > max then
					max = #shapeshiftForms[spec]
				end
			end
		end

		-- start at 0 because [form:0] is no form
		for i = 0, max do
			local key = #order + 1

			items[key] = string.format("<text=%s>", L["BINDING_UI_PAGE_LOAD_OPTIONS_N_STANCE"]:format(i))
			table.insert(order, key)
		end
	end

	return items, order
end
