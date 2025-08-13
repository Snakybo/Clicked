-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2024  Kevin Krol
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

local AceGUI = LibStub("AceGUI-3.0")

-- Deprecated in 5.5.0
local GetSpecialization = C_SpecializationInfo.GetSpecialization or GetSpecialization
-- Deprecated in 5.5.0
local GetSpecializationInfo = C_SpecializationInfo.GetSpecializationInfo or GetSpecializationInfo

--- @class ClickedInternal
local Addon = select(2, ...)

Addon.TOOLTIP_SHOW_DELAY = 0.3

--- @type TickerCallback?
local tooltipTimer = nil

local KEYBIND_ORDER_LIST = {
	"BUTTON1", "BUTTON2", "BUTTON3", "BUTTON4", "BUTTON5", "MOUSEWHEELUP", "MOUSEWHEELDOWN",
	"`", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "-", "=",
	"NUMPAD0", "NUMPAD1", "NUMPAD2", "NUMPAD3", "NUMPAD4", "NUMPAD5", "NUMPAD6", "NUMPAD7", "NUMPAD8", "NUMPAD9", "NUMPADDIVIDE", "NUMPADMULTIPLY", "NUMPADMINUS", "NUMPADPLUS", "NUMPADDECIMAL",
	"F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12", "F13",
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
	"TAB", "CAPSLOCK", "INSERT", "DELETE", "HOME", "END", "PAGEUP", "PAGEDOWN", "[", "]", "\\", ";", "'", ",", ".", "/"
}

--- @type { [integer]: integer[] } | { [string]: integer[][] }
local shapeshiftForms

-- /run local a,b,c=table.concat,{},{};for d=1,GetNumShapeshiftForms() do local _,_,_,f=GetShapeshiftFormInfo(d);local e=C_Spell.GetSpellInfo(f).name;b[#b+1]=e;c[#c+1]=f;end print("{ "..a(c, ", ").." }, -- " ..a(b,", "))
if Addon.EXPANSION_LEVEL >= Addon.Expansion.DF then
	--- @type { [integer]: integer[] }
	shapeshiftForms = {
		-- Holy Paladin
		-- Protection Paladin
		-- Retribution Paladin
		-- Initial Paladin
		[65] = { 32223, 465, 183435, 317920 }, -- Crusader Aura, Devotion Aura, Retribution Aura, Concentration Aura
		[66] = { 32223, 465, 183435, 317920 }, -- Crusader Aura, Devotion Aura, Retribution Aura, Concentration Aura
		[70] = { 32223, 465, 183435, 317920 }, -- Crusader Aura, Devotion Aura, Retribution Aura, Concentration Aura
		[1451] = { 32223, 465, 183435, 317920 }, -- Crusader Aura, Devotion Aura, Retribution Aura, Concentration Aura

		-- Arms Warrior
		-- Fury Warrior
		-- Protection Warrior
		[71] = { 386208, 386164 }, -- Defensive Stance, Battle Stance
		[72] = { 386196 }, -- Beserker Stance
		[73] = { 386208, 386164 }, -- Defensive Stance, Battle Stance

		-- Balance Druid
		-- Feral Druid
		-- Guardian Druid
		-- Restoration Druid
		-- Initial Druid
		[102] = { 5487, 768, 783, 24858, 114282, 210053 }, -- Bear Form, Cat Form, Travel Form, Moonkin Form, Treant Form, Mount Form
		[103] = { 5487, 768, 783, 24858, 114282, 210053 }, -- Bear Form, Cat Form, Travel Form, Moonkin Form, Treant Form, Mount Form
		[104] = { 5487, 768, 783, 24858, 114282, 210053 }, -- Bear Form, Cat Form, Travel Form, Moonkin Form, Treant Form, Mount Form
		[105] = { 5487, 768, 783, 24858, 114282, 210053 }, -- Bear Form, Cat Form, Travel Form, Moonkin Form, Treant Form, Mount Form
		[1447] = { 5487, 768, 783, 114282, 210053 }, -- Bear Form, Cat Form, Travel Form, Treant Form, Mount Form

		-- Shadow Priest
		[258] = { 232698 }, -- Shadowform

		-- Assassination Rogue
		-- Outlaw Rogue
		-- Subtlety Rogue
		-- Initial Rogue
		[259] = { 1784 }, -- Stealth
		[260] = { 1784 }, -- Stealth
		[261] = { 1784, 185422 }, -- Stealth, Shadow Dance
		[1453] = { 1784 },  -- Stealth
	}
elseif Addon.EXPANSION_LEVEL >= Addon.Expansion.MOP then
	--- @type { [integer]: integer[] }
	shapeshiftForms = {
		-- Holy Paladin
		-- Protection Paladin
		-- Retribution Paladin
		-- Initial Paladin
		[65] = { 31801, 20154, 20165 }, -- Seal of Truth, Seal of Righteousness, Seal of Insight
		[66] = { 31801, 20154, 20165 }, -- Seal of Truth, Seal of Righteousness, Seal of Insight
		[70] = { 31801, 20154, 20164, 20165 }, -- Seal of Truth, Seal of Righteousness, Seal of Justice, Seal of Insight
		[1451] = { 31801, 20154, 20165 }, -- Seal of Truth, Seal of Righteousness, Seal of Insight

		-- Arms Warrior
		-- Fury Warrior
		-- Protection Warrior
		-- Initial Warrior
		[71] = { 2457, 71, 2458 }, -- Battle Stance, Defensive Stance, Berserker Stance
		[72] = { 2457, 71, 2458 }, -- Battle Stance, Defensive Stance, Berserker Stance
		[73] = { 2457, 71, 2458 }, -- Battle Stance, Defensive Stance, Berserker Stance
		[1446] = { 2457, 71, 2458 }, -- Battle Stance, Defensive Stance, Berserker Stance

		-- Balance Druid
		-- Feral Druid
		-- Guardian Druid
		-- Restoration Druid
		-- Initial Druid
		[102] = { 5487, 1066, 768, 783, 24858, 40120 }, -- Bear Form, Aquatic Form, Cat Form, Travel Form, Moonkin Form, Swift Flight Form
		[103] = { 5487, 1066, 768, 783, 40120 }, -- Bear Form, Aquatic Form, Cat Form, Travel Form, Swift Flight Form
		[104] = { 5487, 1066, 768, 783, 40120 }, -- Bear Form, Aquatic Form, Cat Form, Travel Form, Swift Flight Form
		[105] = { 5487, 1066, 768, 783, 40120 }, -- Bear Form, Aquatic Form, Cat Form, Travel Form, Swift Flight Form
		[1447] = { 5487, 1066, 768, 783, 40120 }, -- Bear Form, Aquatic Form, Cat Form, Travel Form, Swift Flight Form

		-- Beast Mastery Hunter
		-- Marksmanship Hunter
		-- Survival Hunter
		-- Initial Hunter
		[253] = { 13165, 5118, 13159 }, -- Aspect of the Hawk, Aspect of the Cheetah, Aspect of the Pack
		[254] = { 13165, 5118, 13159 }, -- Aspect of the Hawk, Aspect of the Cheetah, Aspect of the Pack
		[255] = { 13165, 5118, 13159 }, -- Aspect of the Hawk, Aspect of the Cheetah, Aspect of the Pack
		[1448] = { 13165, 5118, 13159 }, -- Aspect of the Hawk, Aspect of the Cheetah, Aspect of the Pack

		-- Assassination Rogue
		-- Outlaw Rogue
		-- Subtlety Rogue
		-- Initial Rogue
		[259] = { 1784 }, -- Stealth
		[260] = { 1784 }, -- Stealth
		[261] = { 1784, 51713 }, -- Stealth, Shadow Dance
		[1453] = { 1784 }, -- Stealth

		-- Shadow Priest
		[258] = { 15473 }, -- Shadowform

		-- Demonology Warlock
		[266] = { 103958 }, -- Metamorphosis

		-- Blood Death Knight
		-- Frost Death Knight
		-- Unholy Death Knight
		-- Initial Death Knight
		[250] = { 48263, 48266, 48265 }, -- Blood Presence, Frost Presence, Unholy Presence
		[251] = { 48263, 48266, 48265 }, -- Blood Presence, Frost Presence, Unholy Presence
		[252] = { 48263, 48266, 48265 }, -- Blood Presence, Frost Presence, Unholy Presence
		[1455] = { 48263, 48266, 48265 }, -- Blood Presence, Frost Presence, Unholy Presence

		-- Brewmaster Monk
		-- Windwalker Monk
		-- Mistweaver Monk
		-- Initial Monk
		[268] = { 115069, 103985 }, -- Stance of the Sturdy Ox, Stance of the Fierce Tiger
		[269] = { 103985 }, -- Stance of the Fierce Tiger
		[270] = { 115070, 103985 }, -- Stance of the Wise Serpent, Stance of the Fierce Tiger
		[1450] = { 103985 }, -- Stance of the Fierce Tiger
	}
else
	--- @type { [string]: integer[][] }
	shapeshiftForms = {
		WARRIOR = {
			{ 2457 }, -- Battle Stance
			{ 71 }, -- Defensive Stance
			{ 2458 } -- Beserker Stance
		},
		PALADIN = {
			{ 27149 }, -- Devotion Aura
			{ 27150 }, -- Retribution Aura
			{ 19746 }, -- Concentration Aura
			{ 27151 }, -- Shadow Resistance Aura
			{ 27152 }, -- Frost Resistance Aura
			{ 27153 }, -- Fire Resistance Aura
			{ 32223 } -- Crusader Aura
		},
		HUNTER = {},
		ROGUE = {
			{ 1784 } -- Stealth
		},
		PRIEST = {
			{ 15473 } -- Shadowform
		},
		SHAMAN = {},
		MAGE = {},
		WARLOCK = {},
		DRUID = {
			{ 9634, 5487 }, -- Dire Bear Form, Bear Form
			{ 1066 }, -- Aquatic Form
			{ 768 }, -- Cat Form
			{ 783 }, -- Travel Form
			{ 24858 }, -- Moonkin Form
		}
	}

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.BC then
		local DRUID = "DRUID"
		table.insert(shapeshiftForms[DRUID], { 33891 }) -- Tree of Life
		table.insert(shapeshiftForms[DRUID], { 40120, 33943 }) -- Swift Flight Form, Flight Form
	end

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.WOTLK then
		local DEATHKNIGHT = "DEATHKNIGHT"
		shapeshiftForms[DEATHKNIGHT] = {
			{ 48266 }, -- Blood Presence
			{ 48263 }, -- Frost Presence
			{ 48265 } -- Unholy Presence
		}
	end

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.CATA then
		local PALADIN = "PALADIN"
		shapeshiftForms[PALADIN] = {
			{ 465 }, -- Devotion Aura
			{ 7294 }, -- Retribution Aura
			{ 19746 }, -- Concentration Aura
			{ 32223 } -- Crusader Aura
		}
	end
end

--- @type string[]
local modifierKeyCombinations = {}

do
	local modifiers = { "ALT", "CTRL", "SHIFT", "META" }

	for i = 1, #modifiers do
		local args = {}

		for j = i, #modifiers do
			local modifier = modifiers[j]

			table.insert(args, modifier)
			table.insert(modifierKeyCombinations, table.concat(args, "-"))
		end
	end
end

-- Local support functions

---@param keybind string
---@return integer
local function GetKeybindIndex(keybind)
	local mods = {}
	local result = ""

	for match in string.gmatch(keybind, "[^-]+") do
		table.insert(mods, match)
		result = match
	end

	table.remove(mods, #mods)

	local index = #KEYBIND_ORDER_LIST + 1
	local found = false

	for i = 1, #KEYBIND_ORDER_LIST do
		if KEYBIND_ORDER_LIST[i] == result then
			index = i
			found = true
			break
		end
	end

	-- register this unknown keybind for this session
	if not found then
		table.insert(KEYBIND_ORDER_LIST, result)
	end

	for i = 1, #mods do
		if mods[i] == "CTRL" then
			index = index + 1000
		end

		if mods[i] == "ALT" then
			index = index + 10000
		end

		if mods[i] == "SHIFT" then
			index = index + 100000
		end

		if mods[i] == "META" then
			index = index + 1000000
		end
	end

	return index
end

StaticPopupDialogs["CLICKED_INCOMPATIBLE_ADDON"] = {
	text = "",
	button1 = string.format(Addon.L["Keep %s"], Addon.L["Clicked"]),
	button2 = "",
	OnShow = function(self)
		-- deprecated in 11.2.0
		if self.text ~= nil then
			self.text:SetFormattedText(Addon.L["Clicked is not compatible with %s and requires one of the two to be disabled."], self.data.addon)
			self.button2:SetFormattedText(Addon.L["Keep %s"],self.data.addon)
		else
			self:GetTextFontString():SetFormattedText(Addon.L["Clicked is not compatible with %s and requires one of the two to be disabled."], self.data.addon)
			self:GetButton2():SetFormattedText(Addon.L["Keep %s"],self.data.addon)
		end
	end,
	OnAccept = function(self)
		C_AddOns.DisableAddOn(self.data.addon)
		ReloadUI()
	end,
	OnCancel = function()
		C_AddOns.DisableAddOn("Clicked")
		ReloadUI()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = false
}

StaticPopupDialogs["CLICKED_MESSAGE"] = {
	text = "",
	button1 = Addon.L["Continue"],
	OnShow = function(self)
		if self.text ~= nil then
			self.text:SetText(self.data.text)
		else
			self:GetTextFontString():SetText(self.data.text)
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true
}

StaticPopupDialogs["CLICKED_CONFIRM"] = {
	text = "",
	button1 = Addon.L["Yes"],
	button2 = Addon.L["No"],
	OnShow = function(self)
		if self.text ~= nil then
			self.text:SetText(self.data.text)
		else
			self:GetTextFontString():SetText(self.data.text)
		end
	end,
	OnAccept = function(self)
		Addon:SafeCall(self.data.onAccept)
	end,
	OnCancel = function(self)
		Addon:SafeCall(self.data.onCancel)
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true
}

-- Private addon API

--- @param addon string
function Addon:ShowAddonIncompatibilityPopup(addon)
	StaticPopup_Show("CLICKED_INCOMPATIBLE_ADDON", "", "", { addon = addon })
end

--- @param text string
function Addon:ShowInformationPopup(text)
	StaticPopup_Show("CLICKED_MESSAGE", "", "", { text = text })
end

--- @param message string
--- @param onAccept function
--- @param onCancel? function
function Addon:ShowConfirmationPopup(message, onAccept, onCancel)
	StaticPopup_Show("CLICKED_CONFIRM", "", "", {
		text = message,
		onAccept = onAccept,
		onCancel = onCancel
	})
end

--- @param text string?
--- @param icon integer|string?
--- @param iconSize integer?
--- @return string
function Addon:GetTextureString(text, icon, iconSize)
	if iconSize == nil then
		iconSize = 16
	end

	if text == nil and icon == nil then
		return ""
	elseif text ~= nil and icon == nil then
		return text
	elseif text == nil and icon ~= nil then
		return string.format("|T%s:%d|t", icon, iconSize)
	else
		return string.format("|T%s:%d|t %s", tostring(icon), iconSize, text)
	end
end

--- @param unit string
--- @param addPrefix? boolean
--- @return string unit
--- @return boolean needsExistsCheck
function Addon:GetWoWUnitFromUnit(unit, addPrefix)
	local units = {
		[Addon.TargetUnit.PLAYER] = "player",
		[Addon.TargetUnit.TARGET] = "target",
		[Addon.TargetUnit.TARGET_OF_TARGET] = "targettarget",
		[Addon.TargetUnit.MOUSEOVER] = "mouseover",
		[Addon.TargetUnit.MOUSEOVER_TARGET] = "mouseovertarget",
		[Addon.TargetUnit.PET] = "pet",
		[Addon.TargetUnit.PET_TARGET] = "pettarget",
		[Addon.TargetUnit.PARTY_1] = "party1",
		[Addon.TargetUnit.PARTY_2] = "party2",
		[Addon.TargetUnit.PARTY_3] = "party3",
		[Addon.TargetUnit.PARTY_4] = "party4",
		[Addon.TargetUnit.PARTY_5] = "party5",
		[Addon.TargetUnit.ARENA_1] = "arena1",
		[Addon.TargetUnit.ARENA_2] = "arena2",
		[Addon.TargetUnit.ARENA_3] = "arena3",
		[Addon.TargetUnit.FOCUS] = "focus",
		[Addon.TargetUnit.CURSOR] = "cursor"
	}

	local needsExistsCheck = {
		[Addon.TargetUnit.TARGET] = true,
		[Addon.TargetUnit.TARGET_OF_TARGET] = true,
		[Addon.TargetUnit.MOUSEOVER] = true,
		[Addon.TargetUnit.MOUSEOVER_TARGET] = true,
		[Addon.TargetUnit.PET] = true,
		[Addon.TargetUnit.PET_TARGET] = true,
		[Addon.TargetUnit.PARTY_1] = true,
		[Addon.TargetUnit.PARTY_2] = true,
		[Addon.TargetUnit.PARTY_3] = true,
		[Addon.TargetUnit.PARTY_4] = true,
		[Addon.TargetUnit.PARTY_5] = true,
		[Addon.TargetUnit.ARENA_1] = true,
		[Addon.TargetUnit.ARENA_2] = true,
		[Addon.TargetUnit.ARENA_3] = true,
		[Addon.TargetUnit.FOCUS] = true
	}

	local target = units[unit]
	if target ~= nil and addPrefix then
		target = "@" .. target
	end

	return target, needsExistsCheck[unit] or false
end

--- @param binding Binding
--- @return string?
function Addon:GetBindingValue(binding)
	assert(type(binding) == "table", "bad argument #1, expected table but got " .. type(binding))

	if binding.actionType == Clicked.ActionType.SPELL then
		local spell = binding.action.spellValue
		if spell == nil then
			return nil
		end

		--- @type string?
		local name

		if type(spell) == "number" then
			if Addon.EXPANSION_LEVEL >= Addon.Expansion.TWW then
				name = C_Spell.GetSpellName(spell)
			else
				local data = C_Spell.GetSpellInfo(spell)
				name = data ~= nil and data.name or nil
			end
		else
			--- @cast spell string
			name = spell
		end

		if Addon.EXPANSION_LEVEL <= Addon.Expansion.WOTLK and not binding.action.spellMaxRank and C_Spell.IsSpellDataCached(spell) then
			local rank = C_Spell.GetSpellSubtext(spell)

			if not self:IsNilOrEmpty(rank) then
				name = string.format("%s(%s)", name, rank)
			end
		end

		return name
	end

	if binding.actionType == Clicked.ActionType.ITEM then
		local item = binding.action.itemValue
		if item == nil then
			return nil
		end

		if type(item) == "number" then
			if item < 20 then
				item = GetInventoryItemID("player", item) or item
			end

			return C_Item.GetItemNameByID(item)
		end

		--- @cast item string
		return item
	end

	if binding.actionType == Clicked.ActionType.CANCELAURA then
		local aura = binding.action.auraName
		if aura == nil then
			return nil
		end

		--- @type string?
		local name

		if type(aura) == "number" then
			if Addon.EXPANSION_LEVEL >= Addon.Expansion.TWW then
				name = C_Spell.GetSpellName(aura)
			else
				local data = C_Spell.GetSpellInfo(aura)
				name = data ~= nil and data.name or nil
			end
		else
			--- @cast aura string
			name = aura
		end

		return name
	end

	if binding.actionType == Clicked.ActionType.MACRO or binding.actionType == Clicked.ActionType.APPEND then
		return binding.action.macroValue
	end

	if binding.actionType == Clicked.ActionType.UNIT_SELECT or binding.actionType == Clicked.ActionType.UNIT_MENU then
		return binding.actionType
	end

	return nil
end

--- @param binding Binding
--- @return string? name
--- @return string|integer? icon
--- @return number? id
function Addon:GetSimpleSpellOrItemInfo(binding)
	assert(type(binding) == "table", "bad argument #1, expected table but got " .. type(binding))

	if binding.actionType == Clicked.ActionType.SPELL then
		local spell = Addon:GetSpellInfo(binding.action.spellValue, not binding.action.spellMaxRank)
		if spell == nil then
			return nil, nil, nil
		end

		return spell.name, spell.iconID, spell.spellID
	end

	if binding.actionType == Clicked.ActionType.ITEM then
		local name, _, _, _, _, _, _, _, _, icon = Addon:GetItemInfo(binding.action.itemValue)

		if name == nil then
			return nil, nil, nil
		end

		return name, icon, self:GetItemId(name)
	end

	if binding.actionType == Clicked.ActionType.CANCELAURA then
		local spell = Addon:GetSpellInfo(binding.action.auraName, true)
		if spell == nil then
			return nil, nil, nil
		end

		return spell.name, spell.iconID, spell.spellID
	end

	return nil, nil, nil
end

--- @param binding Binding
--- @return string name
--- @return string|number icon
function Addon:GetBindingNameAndIcon(binding)
	local function IsValidIcon(icon)
		if icon == nil then
			return false
		end

		if type(icon) == "string" and #icon == 0 then
			return false
		end

		if tonumber(icon) ~= nil and tonumber(icon) <= 0 then
			return false
		end

		return true
	end

	local name = ""

	--- @type string|integer
	local icon = "Interface\\ICONS\\INV_Misc_QuestionMark"

	if binding.actionType == Clicked.ActionType.SPELL or binding.actionType == Clicked.ActionType.ITEM then
		local label = binding.actionType == Clicked.ActionType.SPELL and Addon.L["Cast %s"] or Addon.L["Use %s"]

		local spellName, spellIcon = Addon:GetSimpleSpellOrItemInfo(binding)
		local value = Addon:GetBindingValue(binding)

		if spellName ~= nil or value ~= nil then
			name = string.format(label, spellName or value)
		end

		if IsValidIcon(spellIcon) then
			icon = spellIcon --[[@as string|integer]]
		end
	elseif binding.actionType == Clicked.ActionType.MACRO or binding.actionType == Clicked.ActionType.APPEND then
		if Addon:IsNilOrEmpty(binding.action.macroName) then
			name = Addon.L["Run custom macro"]
		else
			name = binding.action.macroName
		end

		if IsValidIcon(binding.action.macroIcon) then
			icon = binding.action.macroIcon
		end
	elseif binding.actionType == Clicked.ActionType.CANCELAURA then
		local spellName, spellIcon = Addon:GetSimpleSpellOrItemInfo(binding)
		local value = Addon:GetBindingValue(binding)

		if spellName ~= nil or value ~= nil then
			name = string.format(Addon.L["Cancel %s"], spellName or value)
		end

		if IsValidIcon(spellIcon) then
			icon = spellIcon --[[@as string|integer]]
		end
	elseif binding.actionType == Clicked.ActionType.UNIT_SELECT then
		name = Addon.L["Target the unit"]
	elseif binding.actionType == Clicked.ActionType.UNIT_MENU then
		name = Addon.L["Open the unit menu"]
	end

	return name, icon
end

--- Get the name and icon of a group for display purposes.
---
--- If the group does not have a name or icon, a default will be returned.
---
--- @param group Group
--- @return string
--- @return string|integer
function Addon:GetGroupNameAndIcon(group)
	local name = Addon.L["New Group"]

	--- @type string|integer
	local icon = "Interface\\ICONS\\INV_Misc_QuestionMark"

	if not Addon:IsNilOrEmpty(group.name) then
		name = group.name
	end

	if (type(group.displayIcon) == "string" and not Addon:IsNilOrEmpty(group.displayIcon --[[@as string]])) or
	   (type(group.displayIcon) == "number" and group.displayIcon > 0) then
		icon = group.displayIcon
	end

	return name, icon
end

--- @param input string|integer
--- @return string? itemName
--- @return string? itemLink
--- @return number? itemQuality
--- @return number? itemLevel
--- @return number? itemMinLevel
--- @return string? itemType
--- @return string? itemSubType
--- @return number? itemStackCount
--- @return string? itemEquipLoc
--- @return number? itemTexture
--- @return number? sellPrice
--- @return number? classID
--- @return number? subclassID
--- @return number? bindType
--- @return number? expacID
--- @return number? setID
--- @return boolean? isCraftingReagent
function Addon:GetItemInfo(input)
	assert(type(input) == "string" or type(input) == "number", "bad argument #1, expected string or number but got " .. type(input))

	local itemId = tonumber(input)

	if itemId ~= nil then
		input = itemId

		if itemId >= 0 and itemId <= 19 then
			input = GetInventoryItemID("player", itemId)

			if input == nil then
				return
			end
		end
	end

	return C_Item.GetItemInfo(input)
end

--- @param input string|integer
--- @param addSubText boolean
--- @return SpellInfo?
function Addon:GetSpellInfo(input, addSubText)
	assert(type(input) == "string" or type(input) == "number", "bad argument #1, expected string or number but got " .. type(input))

	local spell = C_Spell.GetSpellInfo(input)

	if spell ~= nil and Addon.EXPANSION_LEVEL <= Addon.Expansion.WOTLK and addSubText and C_Spell.IsSpellDataCached(spell.spellID) then
		local subtext = C_Spell.GetSpellSubtext(spell.spellID)

		if not self:IsNilOrEmpty(subtext) then
			spell.name = string.format("%s(%s)", spell.name, subtext)
		end
	end

	return spell
end

--- Get the ID for the specified item name.
---
--- @param name string
--- @return integer?
function Addon:GetItemId(name)
	assert(type(name) == "string", "bad argument #1, expected string but got " .. type(name))

	local itemName, link = Addon:GetItemInfo(name)

	if itemName == nil then
		return nil
	end

	--- @cast link string
	local _, _, _, _, id = string.find(link, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
	return tonumber(id)
end

--- Get the spell ID for the specified spell name.
---
--- @param name string
--- @return integer?
function Addon:GetSpellId(name)
	assert(type(name) == "string", "bad argument #1, expected string but got " .. type(name))

	local spell = self:GetSpellInfo(name, true)
	if spell == nil then
		return nil
	end

	return spell.spellID
end

--- @param keybind string
--- @return string[] modifiers
--- @return string key
function Addon:GetKeybindModifiersAndKey(keybind)
	local modifiers = {}
	local current = ""

	for i = 1, #keybind do
		local char = string.sub(keybind, i, i)

		if char == "-" and #current > 0 then
			table.insert(modifiers, current)
			current = ""
		else
			current = current .. char
		end
	end

	return modifiers, current
end

--- Generate an attribute identifier for a key. This will
--- separate the keybind into two parts: a prefix, and a suffix.
---
--- The prefix is always an empty string unless the key is a mouse
--- button _and_ the `hovercast` parameter has been set to `true`.
---
--- That will allow for the generation of proper frame attribute keys:
---
--- * `"BUTTON1"` == `"", "1"` == `"type1"`
--- * `"SHIFT-BUTTON1"` == `"shift", "1"` == `"shift-type1"`
--- * etc.
---
--- For any keys that are _not_ mouse buttons, or the `hovercast`
--- parameter has been set to `false`, a custom identifier will
--- be generated, generally prefixed by `ccmbtn-` or `ccbtn-`
--- for mouse buttons and all other buttons respectively.
---
--- * `"T"` == `"", "ccbtn-t"` == `"type-ccbtn-t"`
--- * `"SHIFT-T"` == `"", "ccbtn-shiftt"` == `"type-ccbtn-shiftt"`
--- * `"BUTTON3"` == `"", "ccmbtn-3"` == `"type-ccmbtn-3"`
--- * `"SHIFT-BUTTON3"` == `"", "ccmbtn-shift3"` == `"type-ccmbtn-shift3"`
---
--- @param keybind string
--- @param hovercast boolean
--- @return string prefix
--- @return string suffix
function Addon:CreateAttributeIdentifier(keybind, hovercast)
	local modifiers, key = self:GetKeybindModifiersAndKey(keybind)
	local buttonIndex = string.match(key, "^BUTTON(%d+)$")

	-- convert the parts to lowercase so it fits the attribute naming style
	local mods = string.lower(table.concat(modifiers, "-"))
	key = string.lower(key)

	if buttonIndex ~= nil and hovercast then
		key = buttonIndex
	elseif buttonIndex ~= nil then
		key = "clicked-mouse-" .. tostring(mods) .. tostring(buttonIndex)
		mods = ""
	else
		key = "clicked-button-" .. tostring(mods) .. tostring(key)
		mods = ""
	end

	return mods, key
end

--- Check if an object is `nil` or has a length of `0`.
---
--- @param value? any
--- @return boolean
function Addon:IsNilOrEmpty(value)
	if value == nil then
		return true
	end

	if type(value) == "string" then
		return #value == 0
	elseif type(value) == "table" then
		return next(value) == nil
	end

	return false
end

--- Compare two bindings, for use in a comparison function such as `table.sort`
--- This function is stable and will return the opposite result if called with inverted parameters
---
--- @param left Binding
--- @param right Binding
--- @param leftCanLoad? boolean
--- @param rightCanLoad? boolean
--- @return boolean
function Addon:CompareBindings(left, right, leftCanLoad, rightCanLoad)
	assert(type(left) == "table", "bad argument #1, expected table but got " .. type(left))
	assert(type(right) == "table", "bad argument #2, expected table but got " .. type(right))

	do
		if leftCanLoad == nil then
			leftCanLoad = Clicked:IsBindingLoaded(left)
		end

		if rightCanLoad == nil then
			rightCanLoad = Clicked:IsBindingLoaded(right)
		end

		if leftCanLoad and not rightCanLoad then
			return true
		end

		if not leftCanLoad and rightCanLoad then
			return false
		end
	end

	if left.keybind == "" and right.keybind ~= "" then
		return false
	end

	if left.keybind ~= "" and right.keybind == "" then
		return true
	end

	if left.keybind == right.keybind then
		local leftValue = Addon:GetBindingNameAndIcon(left)
		local rightValue = Addon:GetBindingNameAndIcon(right)

		if leftValue == rightValue then
			return left.uid < right.uid
		end

		return leftValue < rightValue
	end

	return GetKeybindIndex(left.keybind) < GetKeybindIndex(right.keybind)
end

if Addon.EXPANSION_LEVEL >= Addon.Expansion.MOP then
	--- Get all available shapeshift forms for the specified spec ID.
	--- Note that this does not mean _currently available_ shapeshift forms,
	--- just all possible shapeshift forms.
	---
	--- It is important that we use this instead of `GetNumShapeshiftForms` and
	--- `GetShapeshiftFormInfo` as those will dynamically change depending on what
	--- the player currently knows, which can vary depending on talents or level.
	---
	--- To ensure that shapeshift form data does not get corrupted when switching
	--- talents, we store all available shapeshift forms manually.
	---
	--- @param specId integer
	--- @return integer[]
	function Addon:GetShapeshiftForms(specId)
		local forms = shapeshiftForms[specId] or {}
		return { unpack(forms) }
	end

	--- Iterate through all available shapeshift specalizations.
	function Addon:IterateShapeshiftSpecs()
		return pairs(shapeshiftForms)
	end

	--- Iterate through all available shapeshift forms for the specified specialization.
	---
	--- @param specId integer
	function Addon:IterateShapeshiftForms(specId)
		return ipairs(shapeshiftForms[specId] or {})
	end
else
	--- Get all available shapeshift forms for the specified class name.
	--- Note that this does not mean _currently available_ shapeshift forms,
	--- just all possible shapeshift forms.
	---
	--- It is important that we use this instead of `GetNumShapeshiftForms` and
	--- `GetShapeshiftFormInfo` as those will dynamically change depending on what
	--- the player currently knows, which can vary depending on talents or level.
	---
	--- To ensure that shapeshift form data does not get corrupted when switching
	--- talents, we store all available shapeshift forms manually.
	---
	--- @param class string
	--- @return integer[][]
	function Addon:GetShapeshiftForms(class)
		local forms = shapeshiftForms[class] or {}
		return { unpack(forms) }
	end

	--- Iterate through all available shapeshift classes.
	function Addon:IterateShapeshiftClasses()
		return pairs(shapeshiftForms)
	end

	--- Iterate through all available shapeshift forms for the specified class.
	---
	--- @param class string
	function Addon:IterateShapeshiftForms(class)
		return ipairs(shapeshiftForms[class])
	end
end

---@param binding Binding
---@return integer[]
function Addon:GetAvailableShapeshiftForms(binding)
	local form = binding.load.form

	--- @type integer[]
	local forms = {}

	-- Forms need to be zero-indexed
	if form.selected == 1 then
		forms[1] = form.single - 1
	elseif form.selected == 2 then
		for i = 1, #form.multiple do
			forms[i] = form.multiple[i] - 1
		end
	end

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.DF then
		if select(2, UnitClass("player")) == "DRUID" then
			local specId = GetSpecializationInfo(GetSpecialization())
			local all = Addon:GetShapeshiftForms(specId)
			local available = {}
			local result = {}

			for _, spellId in ipairs(all) do
				if IsSpellKnown(spellId) then
					table.insert(available, spellId)
				end
			end

			for i = 1, #forms do
				local formId = forms[i]

				-- 0 is [form:0] aka humanoid
				if formId == 0 then
					table.insert(result, formId)

					-- Incarnation: Tree of Life does not show up as a shapeshift form,
					-- but it will always be NUM_SHAPESHIFT_FORMS + 1 (See: #9)

					if IsSpellKnown(33891) then
						table.insert(result, GetNumShapeshiftForms() + 1)
					end
				else
					for j = 1, #available do
						if available[j] == all[formId] then
							table.insert(result, j)
							break
						end
					end
				end
			end

			forms = result
		end
	end

	return forms
end

--- Show a tooltip on the specified frame after a short delay.
---
--- @param frame table
--- @param text string
--- @param subText string?
--- @param anchorPoint? string
--- @param anchorRelativePoint? string
function Addon:ShowTooltip(frame, text, subText, anchorPoint, anchorRelativePoint)
	if tooltipTimer ~= nil then
		tooltipTimer:Cancel()
	end

	anchorPoint = anchorPoint or "BOTTOMLEFT"
	anchorRelativePoint = anchorRelativePoint or "TOPLEFT"

	tooltipTimer = C_Timer.NewTimer(Addon.TOOLTIP_SHOW_DELAY, function()
		local tooltip = AceGUI.tooltip

		if subText ~= nil then
			text = text .. "\n|cffffffff" .. subText .. "|r"
		end

		tooltip:SetOwner(frame, "ANCHOR_NONE")
		tooltip:ClearAllPoints()
		tooltip:SetPoint(anchorPoint, frame, anchorRelativePoint)
		tooltip:SetText(text, true)
		tooltip:Show()
	end)
end

--- Hide the tooltip shown on the specified frame.
function Addon:HideTooltip()
	if tooltipTimer ~= nil then
		tooltipTimer:Cancel()
		AceGUI.tooltip:Hide()
	end
end


--- Check if an item set bonus is active.
---
--- @param setItemIds integer[]
--- @param numSetPieces integer
--- @return boolean
function Addon:IsSetBonusActive(setItemIds, numSetPieces)
	local count = 0

	for _, itemId in ipairs(setItemIds) do
		if C_Item.IsEquippedItem(itemId) then
			count = count + 1

			if count >= numSetPieces then
				return true
			end
		end
	end

	return false
end

--- Get the specialization index from the specified spec ID.
---
--- @param specId integer
--- @return integer?
function Addon:GetSpecIndexFromId(specId)
	if Addon.EXPANSION_LEVEL < Addon.Expansion.MOP then
		return nil
	end

	for i = 1, GetNumSpecializations() do
		local id = GetSpecializationInfo(i)

		if id == specId then
			return i
		end
	end

	return nil
end

--- Open the settings menu to the specified tab.
---
--- @param category string|integer
function Addon:OpenSettingsMenu(category)
	Settings.OpenToCategory(category)
end

--- Check if the specified keybind is "restricted", a restricted keybind
--- is not allowed to do various actions as it is required for core game
--- input (such as left and right mouse buttons).
---
--- Restricted keybinds can still be used for bindings, but they will
--- have limited functionality.
---
--- @param keybind string
--- @return boolean
function Addon:IsRestrictedKeybind(keybind)
	return keybind == "BUTTON1" or keybind == "BUTTON2"
end

--- Check if the specified keybind is a mouse button. This will also
--- return `true` if the mouse button has been modified with alt/shift/ctrl.
---
--- @param keybind string
--- @return boolean
function Addon:IsMouseButton(keybind)
	if Addon:IsNilOrEmpty(keybind) then
		return false
	end

	local _, key = self:GetKeybindModifiersAndKey(keybind)
	local buttonIndex = string.match(key, "^BUTTON(%d+)$")

	return buttonIndex ~= nil
end

--- Check if the specified keybind is using no modifier buttons.
---
--- @param keybind string
--- @return boolean
function Addon:IsUnmodifiedKeybind(keybind)
	if Addon:IsNilOrEmpty(keybind) then
		return false
	end

	local modifiers = self:GetKeybindModifiersAndKey(keybind)
	return #modifiers == 0
end

--- Get a list of unused modifier key keybinds.
---
--- @param keybind string
--- @param bindings Binding[]
--- @returns string[]
function Addon:GetUnusedModifierKeyKeybinds(keybind, bindings)
	local combinations = {}

	for _, modifier in ipairs(modifierKeyCombinations) do
		table.insert(combinations, modifier .. "-" .. keybind)
	end

	local function ValidateKeybind(input)
		if input == nil then
			return
		end

		for i = 1, #combinations do
			if combinations[i] == input then
				table.remove(combinations, i)
				break
			end
		end
	end

	for _, binding in ipairs(bindings) do
		ValidateKeybind(binding.keybind)
	end

	for i = 1, GetNumBindings() do
		local _, _, key1, key2 = GetBinding(i);

		ValidateKeybind(key1)
		ValidateKeybind(key2)
	end

	return combinations
end

--- Check if the hovercast targeting mode should be enabled for a binding.
---
--- @param binding Binding
--- @return boolean
function Addon:IsHovercastEnabled(binding)
	if binding.actionType == Clicked.ActionType.CANCELAURA then
		return false
	end

	return binding.targets.hovercastEnabled
end

--- Check if the regular/macro targeting mode should be enabled for a binding.
---
--- @param binding Binding
--- @return boolean
function Addon:IsMacroCastEnabled(binding)
	if binding.actionType == Clicked.ActionType.CANCELAURA then
		return true
	end

	if binding.actionType == Clicked.ActionType.UNIT_MENU or binding.actionType == Clicked.ActionType.UNIT_SELECT then
		return false
	end

	if Addon:IsRestrictedKeybind(binding.keybind) then
		return false
	end

	return binding.targets.regularEnabled
end

--- Check if a binding's target unit can have a hostility. This will be
--- `false` when, for example, `PARTY_2` is passed in because party members
--- are by definition always friendly during the configuration phase.
---
--- @param unit? string
--- @return boolean
function Addon:CanUnitBeHostile(unit)
	local valid = {
		[Addon.TargetUnit.TARGET] = true,
		[Addon.TargetUnit.TARGET_OF_TARGET] = true,
		[Addon.TargetUnit.PET_TARGET] = true,
		[Addon.TargetUnit.ARENA_1] = true,
		[Addon.TargetUnit.ARENA_2] = true,
		[Addon.TargetUnit.ARENA_3] = true,
		[Addon.TargetUnit.FOCUS] = true,
		[Addon.TargetUnit.MOUSEOVER] = true,
		[Addon.TargetUnit.MOUSEOVER_TARGET] = true
	}

	return valid[unit] == true
end

--- Check if a binding's target unit supports `dead` and `nodead` modifiers.
--- This will be `false` when, for example, `CURSOR` is passed in, but also
--- when `PLAYER` is passed in. The player can technically be dead, but we cannot
--- cast anything while dead so it is a condition that can never be reached.
---
--- @param unit? string
--- @return boolean
function Addon:CanUnitBeDead(unit)
	local valid = {
		[Addon.TargetUnit.TARGET] = true,
		[Addon.TargetUnit.TARGET_OF_TARGET] = true,
		[Addon.TargetUnit.PET] = true,
		[Addon.TargetUnit.PET_TARGET] = true,
		[Addon.TargetUnit.PARTY_1] = true,
		[Addon.TargetUnit.PARTY_2] = true,
		[Addon.TargetUnit.PARTY_3] = true,
		[Addon.TargetUnit.PARTY_4] = true,
		[Addon.TargetUnit.PARTY_5] = true,
		[Addon.TargetUnit.ARENA_1] = true,
		[Addon.TargetUnit.ARENA_2] = true,
		[Addon.TargetUnit.ARENA_3] = true,
		[Addon.TargetUnit.FOCUS] = true,
		[Addon.TargetUnit.MOUSEOVER] = true,
		[Addon.TargetUnit.MOUSEOVER_TARGET] = true
	}

	return valid[unit] == true
end

--- Colorize the specified string. This will enclose the string
--- in WoW color tags (`|c` and `|r`).
---
--- @param string string
--- @param color string
--- @return string
function Addon:GetColorizedString(string, color)
	return "|c" .. color .. string .. "|r"
end

--- Prefix the specified string with `Clicked:`.
---
--- @param message string
--- @return string
function Addon:AppendClickedMessagePrefix(message)
	return Addon:GetColorizedString(Addon.L["Clicked"], "ffe31919") .. ": " .. message
end

--- Run `string.format` on the specified string, and prefix the resulting string with `Clicked:`.
---
--- @param format string|number
--- @param ... any
--- @return string
function Addon:GetPrefixedAndFormattedString(format, ...)
	local message = string.format(format, ...)
	return Addon:AppendClickedMessagePrefix(message)
end

--- Sanitize the keybind to make it display properly for the current game platform (Windows, Mac)
--- @param keybind string
function Addon:SanitizeKeybind(keybind)
	if IsMacClient() then
		return string.gsub(keybind, "META%-", "CMD%-")
	end

	return keybind
end

--- Get the UID for the specified scope.
---
--- This is mainly a hack to allow us to treat a scope in the same manner as a binding in the binding list.
---
--- @param scope DataObjectScope
--- @return integer
function Addon:GetScopeUid(scope)
	return -100 + scope
end

--- Convert a UID back to a scope.
---
--- This is mainly a hack to allow us to treat a scope in the same manner as a binding in the binding list.
---
--- @param uid integer
--- @return DataObjectScope?
function Addon:GetScopeFromUid(uid)
	if uid < 0 then
		return uid + 100
	end

	return nil
end

--- Check if the table contains the specified value.
---
--- @generic T
--- @param tbl T[]
--- @param element T
--- @return boolean
function Addon:TableContains(tbl, element)
	for i = 1, #tbl do
		if tbl[i] == element then
			return true
		end
	end

	return false
end

--- Remove the specified element from the table.
---
--- @generic T
--- @param tbl T[]
--- @param element T
--- @return boolean `true` if the element was removed; `false` otherwise.
function Addon:TableRemoveItem(tbl, element)
	for i = 1, #tbl do
		if tbl[i] == element then
			table.remove(tbl, i)
			return true
		end
	end

	return false
end

--- Check if the two arrays are equivalent. This will return `true` if the arrays are functionally the same, but are not necessarily in the same order.
---
--- @generic T
--- @param tbl1 T[]
--- @param tbl2 T[]
--- @return boolean `true` if the arrays are equivalent; `false` otherwise.
function Addon:TableEquivalent(tbl1, tbl2)
	if #tbl1 ~= #tbl2 then
		return false
	end

	--- @type table<any,boolean>
	local set = {}

	for i = 1, #tbl1 do
		local element = tbl1[i]
		set[element] = true
	end

	for i = 1, #tbl2 do
		local element = tbl2[i]

		if set[element] == nil then
			return false
		end
	end

	return true
end

--- Construct a table containing only the specified elements.
---
--- @generic T
--- @generic U
--- @param tbl T[]
--- @param selector fun(item: T): U
--- @return U[]
function Addon:TableSelect(tbl, selector)
	local result = {}

	for i = 1, #tbl do
		local value = selector(tbl[i])

		if value ~= nil then
			table.insert(result, value)
		end
	end

	return result
end

--- Get the character at the specified index in the string.
---
--- @param str string
--- @param index integer
function Addon:CharAt(str, index)
	assert(type(str) == "string", "bad argument #1, expected string but got " .. type(str))
	assert(type(index) == "number", "bad argument #2, expected string but got " .. type(index))

	return string.sub(str, index, index)
end
