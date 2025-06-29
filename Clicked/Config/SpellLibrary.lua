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

-- Deprecated in 5.5.0
local GetSpecialization = C_SpecializationInfo.GetSpecialization or GetSpecialization
-- Deprecated in 5.5.0
local GetSpecializationInfo = C_SpecializationInfo.GetSpecializationInfo or GetSpecializationInfo

--- @class ClickedInternal
local Addon = select(2, ...)

--- @class SpellLibrary
Addon.SpellLibrary = {}

--- @alias SpellLibraryResultType
--- | "SPELL"
--- | "ITEM"
--- | "MACRO"

--- @class SpellLibraryResult
--- @field public type SpellLibraryResultType
--- @field public key? string

--- @class SpellLibrarySpellResult : SpellLibraryResult
--- @field public name string
--- @field public icon integer
--- @field public spellId integer
--- @field public tabName? string
--- @field public tabIcon? string|integer
--- @field public specId? integer

--- @class SpellLibraryItemResult : SpellLibraryResult
--- @field public name string
--- @field public icon integer
--- @field public itemId integer

--- @class SpellLibraryMacroResult : SpellLibraryResult
--- @field public name string
--- @field public icon integer
--- @field public content string

--- @type table<integer, SpellLibrarySpellResult>?
local cached = nil

--- @type number?
local cachedTime = nil

--- @return table<integer, SpellLibrarySpellResult>
local function GetSpells_TWW()
	--- @type table<integer, SpellLibrarySpellResult>
	local result = {}

	--- @type string?, integer?
	local activeTabName, activetabIcon

	--- @param spell SpellBookItemInfo
	--- @param tab? SpellBookSkillLineInfo
	local function ParseSpellBookItem(spell, tab)
		if not spell.isPassive then
			if spell.itemType == Enum.SpellBookItemType.Spell or spell.itemType == Enum.SpellBookItemType.FutureSpell or spell.itemType == Enum.SpellBookItemType.PetAction then
				if spell.spellID ~= nil then
					--- @type SpellLibrarySpellResult
					result[spell.spellID] = {
						type = "SPELL",
						name = spell.name,
						spellId = spell.spellID,
						icon = spell.iconID,
						tabName = tab and tab.name,
						tabIcon = tab and tab.iconID,
						specId = tab and tab.specID
					}
				end
			elseif spell.itemType == Enum.SpellBookItemType.Flyout then
				local _, _, spellCount = GetFlyoutInfo(spell.actionID)

				for k = 1, spellCount do
					local spellId, _, isKnown = GetFlyoutSlotInfo(spell.actionID, k)
					local info = Addon:GetSpellInfo(spellId, false)

					if isKnown and info ~= nil and not C_Spell.IsSpellPassive(spellId) then
						--- @type SpellLibrarySpellResult
						result[spellId] = {
							type = "SPELL",
							name = info.name,
							spellId = spellId,
							icon = info.iconID,
							tabName = tab and tab.name,
							tabIcon = tab and tab.iconID,
							specId = tab and tab.specID
						}
					end
				end
			end
		end
	end

	for i = 1, C_SpellBook.GetNumSpellBookSkillLines() do
		local tab = C_SpellBook.GetSpellBookSkillLineInfo(i)

		if tab.specID == GetSpecializationInfo(GetSpecialization()) then
			activeTabName = tab.name
			activetabIcon = tab.iconID
		end

		for j = tab.itemIndexOffset + 1, tab.itemIndexOffset + tab.numSpellBookItems do
			local spell = C_SpellBook.GetSpellBookItemInfo(j, Enum.SpellBookSpellBank.Player)
			ParseSpellBookItem(spell, tab)
		end
	end

	do
		local professions = { GetProfessions() }

		--- @type SpellBookSkillLineInfo
		local professionsParent = nil

		for _, i in pairs(professions) do
			local tab = C_SpellBook.GetSpellBookSkillLineInfo(i)
			professionsParent = professionsParent or CopyTable(tab)
			professionsParent.name = TRADE_SKILLS

			for j = tab.itemIndexOffset + 1, tab.itemIndexOffset + tab.numSpellBookItems do
				local spell = C_SpellBook.GetSpellBookItemInfo(j, Enum.SpellBookSpellBank.Player)
				ParseSpellBookItem(spell, professionsParent)
			end
		end
	end

	do
		local count = C_SpellBook.HasPetSpells()

		if count ~= nil then
			for i = 1, count do
				local spell = C_SpellBook.GetSpellBookItemInfo(i, Enum.SpellBookSpellBank.Pet)
				ParseSpellBookItem(spell)
			end
		end
	end

	for _, talent in ipairs(Addon:GetLocalizedTalents()) do
		if not C_Spell.IsSpellPassive(talent.spellId) then
			if result[talent.spellId] == nil then
				--- @type SpellLibrarySpellResult
				result[talent.spellId] = {
					type = "SPELL",
					name = talent.text,
					spellId = talent.spellId,
					icon = talent.icon,
					tabName = activeTabName,
					tabIcon = activetabIcon,
					specId = talent.specId
				}
			end
		end
	end

	for _, talent in ipairs(Addon:GetLocalizedPvPTalents()) do
		if not C_Spell.IsSpellPassive(talent.spellId) then
			if result[talent.spellId] == nil then
				--- @type SpellLibrarySpellResult
				result[talent.spellId] = {
					type = "SPELL",
					name = talent.text,
					spellId = talent.spellId,
					icon = talent.icon,
					tabName = activeTabName,
					tabIcon = activetabIcon,
					specId = talent.specId
				}
			end
		end
	end

	return result
end

--- @return table<integer, SpellLibrarySpellResult>
local function GetSpells_Classic()
	local result = {}

	--- @param type string
	--- @param id integer
	--- @param tabName? string
	--- @param tabIcon? string|integer
	--- @param specId? integer
	local function ParseSpellBookItem(type, id, tabName, tabIcon, specId)
		if not IsPassiveSpell(id) then
			if type == "SPELL" or type == "FUTURESPELL" or type == "PETACTION" then
				local spell = Addon:GetSpellInfo(id, Addon.EXPANSION_LEVEL <= Addon.Expansion.WOTLK)

				if spell ~= nil then
					--- @type SpellLibrarySpellResult
					result[id] = {
						type = "SPELL",
						name = spell.name,
						spellId = id,
						icon = spell.iconID,
						tabName = tabName,
						tabIcon = tabIcon,
						specId = specId
					}
				end
			elseif type == "FLYOUT" then
				local _, _, spellCount = GetFlyoutInfo(id)

				for k = 1, spellCount do
					local spellId, _, isKnown = GetFlyoutSlotInfo(id, k)
					local spell = Addon:GetSpellInfo(spellId, false)

					if isKnown and spell ~= nil and not IsPassiveSpell(spellId) then
						--- @type SpellLibrarySpellResult
						result[spellId] = {
							type = "SPELL",
							name = spell.name,
							spellId = spellId,
							icon = spell.iconID,
							tabName = tabName,
							tabIcon = tabIcon,
							specId = specId
						}
					end
				end
			end
		end
	end

	local runesTabName = nil
	local runesTabIcon = nil

	for i = 1, GetNumSpellTabs() do
		local tabName, tabIcon, offset, count, _, specId = GetSpellTabInfo(i)

		if tabIcon ~= 134419 then
			for j = offset + 1, offset + count do
				local type, id = GetSpellBookItemInfo(j, BOOKTYPE_SPELL)
				ParseSpellBookItem(type, id, tabName, tabIcon, specId)
			end
		else
			runesTabName = tabName
			runesTabIcon = tabIcon
		end
	end

	do
		local professions = { GetProfessions() }

		local tabName, tabIcon

		for _, i in pairs(professions) do
			local name, icon, offset, count = GetSpellTabInfo(i)
			tabName = tabName or name
			tabIcon = tabIcon or icon

			for j = offset + 1, offset + count do
				local type, id = GetSpellBookItemInfo(j, BOOKTYPE_SPELL)
				ParseSpellBookItem(type, id, tabName, tabIcon)
			end
		end
	end

	do
		local count = HasPetSpells()

		if count ~= nil then
			for i = 1, count do
				local name = GetSpellBookItemName(i, BOOKTYPE_PET)
				local info = C_Spell.GetSpellInfo(name)

				if info ~= nil then
					ParseSpellBookItem("PETACTION", info.spellID)
				end
			end
		end
	end

	if C_Engraving ~= nil then
		C_Engraving:ClearAllCategoryFilters();
		C_Engraving.RefreshRunesList()

		for _, category in ipairs(C_Engraving.GetRuneCategories(false, false)) do
			for _, engraving in ipairs(C_Engraving.GetRunesForCategory(category, false)) do
				for _, spellId in ipairs(engraving.learnedAbilitySpellIDs) do
					ParseSpellBookItem("SPELL", spellId, runesTabName, runesTabIcon)
				end
			end
		end
	end

	return result
end

--- @return table<integer, SpellLibrarySpellResult>
local function GetSpells()
	if cached ~= nil and cachedTime == GetTime() then
		return cached
	end

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.TWW then
		cached = GetSpells_TWW()
	else
		cached = GetSpells_Classic()
	end

	cachedTime = GetTime()
	return cached
end

-- Private addon API

--- Get a spell by its spell ID from the spellbook.
---
--- @param spellId integer
--- @return SpellLibrarySpellResult?
function Addon.SpellLibrary:GetSpellById(spellId)
	return GetSpells()[spellId]
end

--- Get a spell by its name from the spellbook.
---
--- @param name string
--- @return SpellLibrarySpellResult?
function Addon.SpellLibrary:GetSpellByName(name)
	for _, spell in pairs(GetSpells()) do
		if spell.name == name then
			return spell
		end
	end

	return nil
end

--- Get all castable spells in the player's spellbook.
---
--- This includes spells from:
--- - The player's spellbook.
--- - The player's pet spellbook.
---
--- @return table<integer, SpellLibrarySpellResult>
function Addon.SpellLibrary:GetSpells()
	return GetSpells()
end

--- Get all abilities that are currently on the player's action bars.
---
--- This includes abilities of the following types:
--- - Spells
--- - Items
--- - Macros
---
--- @return SpellLibraryResult[]
function Addon.SpellLibrary:GetActionBarSpells()
	--- @type table<integer, SpellLibraryResult>
	local result = {}

	--- @param key? string
	--- @param type? string
	--- @param id? string|integer
	local function Register(key, type, id)
		if type == nil or id == nil or id == 0 then
			return
		end

		-- TODO: Add support for importing of summonmount, summonpet, equipmentset

		if type == "spell" then
			--- @cast id integer

			local spell = self:GetSpellById(id)

			if spell ~= nil then
				spell = CopyTable(spell)
				spell.key = key
				table.insert(result, spell)
			end
		elseif type == "item" then
			--- @cast id integer
			--- @type SpellLibraryItemResult
			table.insert(result, {
				type = "ITEM",
				key = key,
				name = C_Item.GetItemNameByID(id),
				icon = C_Item.GetItemIconByID(id),
				itemId = id
			})
		elseif type == "macro" then
			--- @cast id integer
			local name, icon, content = GetMacroInfo(id)

			--- @type SpellLibraryMacroResult
			table.insert(result, {
				type = "MACRO",
				key = key,
				name = name,
				icon = icon,
				content = content
			})
		end
	end

	--- @param uid string
	--- @param slot integer
	local function RegisterActionButton(uid, slot)
		-- TODO: Add support for multiple keys, maybe?
		local key = GetBindingKey(uid)

		local type, id = GetActionInfo(slot)
		if type == nil or id == nil then
			return
		end

		-- Since 10.2.0 this doesn't provide the macro ID anymore, but instead returns the computed spell or item ID
		-- TODO: Check if this is also the case on Classic
		if type == "macro" then
			local text = GetActionText(slot)
			id = text ~= nil and GetMacroIndexByName(text) or 0
		end

		Register(key, type, id)
	end

	if _G["Dominos"] then
		for i = 1, 168 do
			local uid = "CLICK DominosActionButton" .. i .. ":HOTKEY"
			RegisterActionButton(uid, i)
		end
	elseif _G["Bartender4"] then
		for i = 1, 180 do
			local uid = "CLICK BT4Button" .. i .. ":Keybind"
			RegisterActionButton(uid, i)
		end
	elseif _G["ElvUI"] and _G["ElvUI_Bar1Button1"] then
		for i = 1, 180 do
			local bar = math.ceil(i / 12)
			local button = 1 + (i - 1) % 12
			local frame = _G["ElvUI_Bar" .. bar .. "Button" .. button]

			if frame ~= nil and _G["ElvUI_Bar" .. bar] and _G["ElvUI_Bar" .. bar].db.enabled then
				local uid = frame.bindstring or frame.keyBoundTarget or ("CLICK " .. frame:GetName() .. ":LeftButton")
				local action = tonumber(frame._state_action)

				if action ~= nil then
					RegisterActionButton(uid, action)
				end
			end
		end
	else
		for i = 1, 180 do
			local button = 1 + (i - 1) % 12
			--- @type string
			local uid

			if i <= 24 then
				uid = "ACTIONBUTTON" .. button
			elseif i <= 36 then
				uid = "MULTIACTIONBAR3BUTTON" .. button
			elseif i <= 48 then
				uid = "MULTIACTIONBAR4BUTTON" .. button
			elseif i <= 60 then
				uid = "MULTIACTIONBAR2BUTTON" .. button
			elseif i <= 72 then
				uid = "MULTIACTIONBAR1BUTTON" .. button
			elseif i <= 144 then
				uid = "ACTIONBUTTON" .. button
			elseif i < 157 then
				uid = "MULTIACTIONBAR5BUTTON" .. button
			elseif i < 169 then
				uid = "MULTIACTIONBAR6BUTTON" .. button
			elseif i < 181 then
				uid = "MULTIACTIONBAR7BUTTON" .. button
			end

			RegisterActionButton(uid, i)
		end

		-- Shapeshift forms
		for i = 1, GetNumShapeshiftForms() do
			local uid = "SHAPESHIFTBUTTON" .. i
			local spell = select(4, GetShapeshiftFormInfo(i))
			Register(GetBindingKey(uid), "spell", spell)
		end

		-- Pet buttons
		for i = 1, NUM_PET_ACTION_SLOTS do
			local uid = "BONUSACTIONBUTTON" .. i
			local spell = select(7, GetPetActionInfo(i))

			if spell ~= nil then
				Register(GetBindingKey(uid), "spell", spell)
			end
		end
	end

	return result
end

--- @return SpellLibraryMacroResult[]
function Addon.SpellLibrary:GetMacroSpells()
	--- @type SpellLibraryMacroResult[]
	local result = {}

	for i = 1, GetNumMacros() do
		local name, icon, content = GetMacroInfo(i)

		--- @type SpellLibraryMacroResult
		table.insert(result, {
			type = "MACRO",
			name = name,
			icon = icon,
			content = content
		})
	end

	return result
end
