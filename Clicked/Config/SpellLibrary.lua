-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2022  Kevin Krol
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

--- @class ClickedInternal
local Addon = select(2, ...)

--- @class SpellLibrary
Addon.SpellLibrary = {}

--- @enum SpellLibraryResultType
Addon.SpellLibrary.ResultType = {
	SPELL = 0,
	ITEM = 1,
	MACRO = 2
}

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

--- @return table<integer, SpellLibrarySpellResult>
local function GetSpells_v2()
	--- @type table<integer, SpellLibrarySpellResult>
	local result = {}

	--- @type string?, integer?
	local activeTabName, activetabIcon

	--- @param spell SpellBookItemInfo
	--- @param tab? SpellBookSkillLineInfo
	local function ParseSpellBookItem(spell, tab)
		if spell.spellID == nil then
			return
		end

		if not spell.isPassive then
			if spell.itemType == Enum.SpellBookItemType.Spell or spell.itemType == Enum.SpellBookItemType.FutureSpell or spell.itemType == Enum.SpellBookItemType.PetAction then
				--- @type SpellLibrarySpellResult
				result[spell.spellID] = {
					type = Addon.SpellLibrary.ResultType.SPELL,
					name = spell.name,
					spellId = spell.spellID,
					icon = spell.iconID,
					tabName = tab and tab.name,
					tabIcon = tab and tab.iconID,
					specId = tab and tab.specID
				}
			elseif spell.itemType == Enum.SpellBookItemType.Flyout then
				local _, _, spellCount = GetFlyoutInfo(spell.actionID)

				for k = 1, spellCount do
					local spellId = GetFlyoutSlotInfo(spell.actionID, k)
					local info = Addon:GetSpellInfo(spellId, false)

					if info ~= nil then
						--- @type SpellLibrarySpellResult
						result[spellId] = {
							type = Addon.SpellLibrary.ResultType.SPELL,
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
					type = Addon.SpellLibrary.ResultType.SPELL,
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
					type = Addon.SpellLibrary.ResultType.SPELL,
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
local function GetSpells_v1()
	local result = {}

	--- @param type string
	--- @param id integer
	--- @param tabName? string
	--- @param tabIcon? string
	--- @param specId? integer
	local function ParseSpellBookItem(type, id, tabName, tabIcon, specId)
		if not IsPassiveSpell(id) then
			if type == "SPELL" or type == "FUTURESPELL" or type == "PETACTION" then
				local spell = Addon:GetSpellInfo(id, false)

				if spell ~= nil then
					--- @type SpellLibrarySpellResult
					result[id] = {
						type = Addon.SpellLibrary.ResultType.SPELL,
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
					local spellId = GetFlyoutSlotInfo(id, k)
					local spell = Addon:GetSpellInfo(spellId, false)

					if spell ~= nil then
						--- @type SpellLibrarySpellResult
						result[spellId] = {
							type = Addon.SpellLibrary.ResultType.SPELL,
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

	for i = 1, GetNumSpellTabs() do
		local tabName, tabIcon, offset, count, _, specId = GetSpellTabInfo(i)

		for j = offset + 1, offset + count do
			local type, id = GetSpellBookItemInfo(j, BOOKTYPE_SPELL)
			ParseSpellBookItem(type, id, tabName, tabIcon, specId)
		end
	end

	do
		local count = HasPetSpells()

		if count ~= nil then
			for i = 1, count do
				local name = GetSpellBookItemName(i, BOOKTYPE_PET)
				local id = select(7, GetSpellInfo(name))

				if id ~= nil then
					ParseSpellBookItem("PETACTION", id)
				end
			end
		end
	end

	return result
end

--- @return table<integer, SpellLibrarySpellResult>
local function GetSpells()
	if Addon.EXPANSION_LEVEL >= Addon.EXPANSION.TWW then
		return GetSpells_v2()
	else
		return GetSpells_v1()
	end
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
