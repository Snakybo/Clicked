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
local SpellLibrary = {}

--- @class SpellLibrary.Spell
--- @field public name string
--- @field public spellId integer
--- @field public icon integer
--- @field public tabName string
--- @field public tabIcon integer
--- @field public specId integer

--- @return table<integer,SpellLibrary.Spell>
local function GetSpells_v2()
	local result = {}
	local activeTabName, activetabIcon

	local function ParseSpellBookItem(spell, tab)
		if spell.spellID == nil then
			return
		end

		if not spell.isPassive then
			if spell.itemType == Enum.SpellBookItemType.Spell or spell.itemType == Enum.SpellBookItemType.FutureSpell or spell.itemType == Enum.SpellBookItemType.PetAction then
				result[spell.spellID] = {
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
						result[spellId] = {
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

		for i = 1, count do
			local spell = C_SpellBook.GetSpellBookItemInfo(i, Enum.SpellBookSpellBank.Pet)
			ParseSpellBookItem(spell)
		end
	end

	for _, talent in ipairs(Addon:GetLocalizedTalents()) do
		if not C_Spell.IsSpellPassive(talent.spellId) then
			result[talent.spellId] = result[talent.spellId] or {
				name = talent.text,
				spellId = talent.spellId,
				icon = talent.icon,
				tabName = activeTabName,
				tabIcon = activetabIcon,
				specId = talent.specId
			}
		end
	end

	for _, talent in ipairs(Addon:GetLocalizedPvPTalents()) do
		if not C_Spell.IsSpellPassive(talent.spellId) then
			result[talent.spellId] = result[talent.spellId] or {
				name = talent.text,
				spellId = talent.spellId,
				icon = talent.icon,
				tabName = activeTabName,
				tabIcon = activetabIcon,
				specId = talent.specId
			}
		end
	end

	return result
end

--- @return table<integer,SpellLibrary.Spell>
local function GetSpells_v1()
	local result = {}
	local activeTabName, activetabIcon

	local function ParseSpellBookItem(type, id, tabName, tabIcon, specId)
		if not IsPassiveSpell(id) then
			if type == "SPELL" or type == "FUTURESPELL" or type == "PETACTION" then
				local spell = Addon:GetSpellInfo(id, false)

				if spell ~= nil then
					result[id] = {
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
						result[spellId] = {
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

		if specId == GetSpecializationInfo(GetSpecialization()) then
			activeTabName = tabName
			activetabIcon = tabIcon
		end

		for j = offset + 1, offset + count do
			local type, id = GetSpellBookItemInfo(j, BOOKTYPE_SPELL)
			ParseSpellBookItem(type, id, tabName, tabIcon, specId)
		end
	end

	do
		local count = HasPetSpells()

		for i = 1, count do
			local type, id = GetSpellBookItemInfo(i, BOOKTYPE_PET)
			ParseSpellBookItem(type, id)
		end
	end

	if Addon.EXPANSION_LEVEL >= Addon.EXPANSION.CATA then
		for _, talent in ipairs(Addon:Cata_GetLocalizedTalents()) do
			if not IsPassiveSpell(talent.spellId) then
				result[talent.spellId] = result[talent.spellId] or {
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

--- @return table<integer,SpellLibrary.Spell>
local function GetSpells()
	if Addon.EXPANSION_LEVEL >= Addon.EXPANSION.TWW then
		return GetSpells_v2()
	else
		return GetSpells_v1()
	end
end

--- @param spellId integer
--- @return SpellLibrary.Spell?
function SpellLibrary:GetSpellById(spellId)
	return GetSpells()[spellId]
end

--- @param name string
--- @return SpellLibrary.Spell?
function SpellLibrary:GetSpellByName(name)
	for _, spell in pairs(GetSpells()) do
		if spell.name == name then
			return spell
		end
	end

	return nil
end

function SpellLibrary:GetSpells()
	return pairs(GetSpells())
end

Addon.SpellLibrary = SpellLibrary
