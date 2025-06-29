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

local LocalizedClassList = LocalizedClassList or function()  -- Deprecated in 10.2.5
	local classes = {}
	FillLocalizedClassList(classes)
	return classes
end

-- Deprecated in 5.5.0
local GetSpecialization = C_SpecializationInfo.GetSpecialization or GetSpecialization
-- Deprecated in 5.5.0
local GetSpecializationInfo = C_SpecializationInfo.GetSpecializationInfo or GetSpecializationInfo

local LibTalentInfo = LibStub("LibTalentInfo-1.0")

--- @class ClickedInternal
local Addon = select(2, ...)

--- @type integer[]
local allRaces = {}

--- @type string[]
local allClasses = {}

--- @type table<integer,TalentInfo[]>
local allTalents = {}

--- @type table<integer,TalentInfo[]>
local allPvpTalents = {}

do
	--- @param race integer
	--- @param expansion ExpansionLevel
	local function AddRace(race, expansion)
		if Addon.EXPANSION_LEVEL >= expansion then
			table.insert(allRaces, race)
		end
	end

	--- @param class string
	--- @param expansion ExpansionLevel
	local function AddClass(class, expansion)
		if Addon.EXPANSION_LEVEL >= expansion then
			table.insert(allClasses, class)
		end
	end

	-- Since we compare races based on the englishRaceName, we only have to register one variant of each race,
	-- for example Pandaran has three race IDs: 24, 25, 26 for neutral, alliance and horde respectively, but we
	-- only need to register 24 as they all have the same englishRaceName.

	AddRace(1, Addon.Expansion.CLASSIC) -- Human
	AddRace(2, Addon.Expansion.CLASSIC) -- Orc
	AddRace(3, Addon.Expansion.CLASSIC) -- Dwarf
	AddRace(4, Addon.Expansion.CLASSIC) -- NightElf
	AddRace(5, Addon.Expansion.CLASSIC) -- Scourge
	AddRace(6, Addon.Expansion.CLASSIC) -- Tauren
	AddRace(7, Addon.Expansion.CLASSIC) -- Gnome
	AddRace(8, Addon.Expansion.CLASSIC) -- Troll
	AddRace(10, Addon.Expansion.BC) -- BloodElf
	AddRace(11, Addon.Expansion.BC) -- Draenei
	AddRace(9, Addon.Expansion.CATA) -- Goblin
	AddRace(22, Addon.Expansion.CATA) -- Worgen
	AddRace(24, Addon.Expansion.MOP) -- Pandaren
	AddRace(27, Addon.Expansion.BFA) -- Nightborne
	AddRace(28, Addon.Expansion.BFA) -- HighmountainTauren
	AddRace(29, Addon.Expansion.BFA) -- VoidElf
	AddRace(30, Addon.Expansion.BFA) -- LightforgedDraenei
	AddRace(31, Addon.Expansion.BFA) -- ZandalariTroll
	AddRace(32, Addon.Expansion.BFA) -- KulTiran
	AddRace(34, Addon.Expansion.BFA) -- DarkIronDwarf
	AddRace(35, Addon.Expansion.BFA) -- Vulpera
	AddRace(36, Addon.Expansion.BFA) -- MagharOrc
	AddRace(37, Addon.Expansion.BFA) -- Mechagnome
	AddRace(52, Addon.Expansion.DF) -- Dracthyr
	AddRace(84, Addon.Expansion.TWW) -- EarthenDwarf

	AddClass("WARRIOR", Addon.Expansion.CLASSIC)
	AddClass("PALADIN", Addon.Expansion.CLASSIC)
	AddClass("HUNTER", Addon.Expansion.CLASSIC)
	AddClass("ROGUE", Addon.Expansion.CLASSIC)
	AddClass("PRIEST", Addon.Expansion.CLASSIC)
	AddClass("SHAMAN", Addon.Expansion.CLASSIC)
	AddClass("MAGE", Addon.Expansion.CLASSIC)
	AddClass("WARLOCK", Addon.Expansion.CLASSIC)
	AddClass("DRUID", Addon.Expansion.CLASSIC)
	AddClass("DEATHKNIGHT", Addon.Expansion.WOTLK)
	AddClass("MONK", Addon.Expansion.MOP)
	AddClass("DEMONHUNTER", Addon.Expansion.LEGION)
	AddClass("EVOKER", Addon.Expansion.DF)
end

--- Attempt to retrieve cached talent data for the specified specialization.
---
--- @param specId integer
--- @return TalentInfo[]?
local function GetTalentsForSpecialization(specId)
	if allTalents[specId] ~= nil then
		return allTalents[specId]
	end

	C_ClassTalents.InitializeViewLoadout(specId, 70)
	C_ClassTalents.ViewLoadout({})

	local configId = Constants.TraitConsts.VIEW_TRAIT_CONFIG_ID
	local configInfo = C_Traits.GetConfigInfo(configId)

	if configInfo == nil then
		return nil
	end

	allTalents[specId] = {}

	for _, treeId in ipairs(configInfo.treeIDs) do
		local nodes = C_Traits.GetTreeNodes(treeId)

		for _, nodeId in ipairs(nodes) do
			local node = C_Traits.GetNodeInfo(configId, nodeId)

			if node ~= nil and node.ID ~= 0 then
				for _, talentId in ipairs(node.entryIDs) do
					local entryInfo = C_Traits.GetEntryInfo(configId, talentId)
					local definitionInfo = C_Traits.GetDefinitionInfo(entryInfo.definitionID)
					local spellName = Addon:StripColorCodes(TalentUtil.GetTalentNameFromInfo(definitionInfo))

					if not Addon:IsNilOrEmpty(spellName) then
						table.insert(allTalents[specId], {
							spellId = definitionInfo.spellID,
							text = spellName,
							icon = TalentButtonUtil.CalculateIconTexture(definitionInfo),
							specId = specId
						})
					end
				end
			end
		end
	end

	return allTalents[specId]
end

--- Attempt to retrieve cached PvP talent data for the specified specialization.
---
--- @param specId integer
--- @return TalentInfo[]?
local function GetPvPTalentsForSpecialization(specId)
	if allPvpTalents[specId] ~= nil then
		return allPvpTalents[specId]
	end

	local pvpTalents = LibTalentInfo:GetPvpTalents(specId)
	if #pvpTalents == 0 then
		return nil
	end

	allPvpTalents[specId] = {}

	for _, talent in ipairs(pvpTalents) do
		local _, name, texture, _, _, spellId = GetPvpTalentInfoByID(talent.id)

		if not Addon:IsNilOrEmpty(name) then
			table.insert(allPvpTalents[specId], {
				spellId = spellId,
				text = name,
				icon = texture,
				specId = specId
			})
		end
	end

	return allPvpTalents[specId]
end

-- Private addon API

--- Stip color codes from a string
---
--- @param str string
--- @return string
function Addon:StripColorCodes(str)
	str = string.gsub(str, "|c%x%x%x%x%x%x%x%x", "")
	str = string.gsub(str, "|c%x%x %x%x%x%x%x", "") -- the trading parts colour has a space instead of a zero for some weird reason
	str = string.gsub(str, "|r", "")

	return str
end

--- Construct a localized string with a summary of the target setting.
---
--- For example:
--- - Friendly Mouseover target
--- - Friendly Dead Target
--- - Hostile Alive Target
---
--- @param target Binding.Target
--- @return string
function Addon:GetLocalizedTargetString(target)
	--- @type string[]
	local result = {}

	if Addon:CanUnitBeHostile(target.unit) and target.hostility ~= Addon.TargetHostility.ANY then
		local hostility = Addon:GetLocalizedTargetHostility()
		table.insert(result, hostility[target.hostility])
	end

	if Addon:CanUnitBeDead(target.unit) and target.vitals ~= Addon.TargetVitals.ANY then
		local vitals = Addon:GetLocalizedTargetVitals()
		table.insert(result, vitals[target.vitals])
	end

	if target.unit ~= nil then
		local units = Addon:GetLocalizedTargetUnits()
		table.insert(result, units[target.unit])
	end

	return table.concat(result, " ")
end

--- Get a localized list of all available target units for a binding.
---
--- @return table<string,string> items
--- @return string[] order
function Addon:GetLocalizedTargetUnits()
	--- @type table<string,string>
	local items = {}

	--- @type string[]
	local order

	items[Addon.TargetUnit.DEFAULT] = Addon.L["Default"]
	items[Addon.TargetUnit.PLAYER] = Addon.L["Player (you)"]
	items[Addon.TargetUnit.TARGET] = Addon.L["Target"]
	items[Addon.TargetUnit.TARGET_OF_TARGET] = Addon.L["Target of target"]
	items[Addon.TargetUnit.MOUSEOVER] = Addon.L["Mouseover"]
	items[Addon.TargetUnit.MOUSEOVER_TARGET] = Addon.L["Target of mouseover"]
	items[Addon.TargetUnit.CURSOR] = Addon.L["Cursor"]
	items[Addon.TargetUnit.PET] = Addon.L["Pet"]
	items[Addon.TargetUnit.PET_TARGET] = Addon.L["Pet target"]
	items[Addon.TargetUnit.PARTY_1] = Addon.L["Party %s"]:format("1")
	items[Addon.TargetUnit.PARTY_2] = Addon.L["Party %s"]:format("2")
	items[Addon.TargetUnit.PARTY_3] = Addon.L["Party %s"]:format("3")
	items[Addon.TargetUnit.PARTY_4] = Addon.L["Party %s"]:format("4")
	items[Addon.TargetUnit.PARTY_5] = Addon.L["Party %s"]:format("5")

	order = {
		Addon.TargetUnit.DEFAULT,
		Addon.TargetUnit.PLAYER,
		Addon.TargetUnit.TARGET,
		Addon.TargetUnit.TARGET_OF_TARGET,
		Addon.TargetUnit.MOUSEOVER,
		Addon.TargetUnit.MOUSEOVER_TARGET,
		Addon.TargetUnit.CURSOR,
		Addon.TargetUnit.PET,
		Addon.TargetUnit.PET_TARGET,
		Addon.TargetUnit.PARTY_1,
		Addon.TargetUnit.PARTY_2,
		Addon.TargetUnit.PARTY_3,
		Addon.TargetUnit.PARTY_4,
		Addon.TargetUnit.PARTY_5
	}

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.BC then
		items[Addon.TargetUnit.FOCUS] = Addon.L["Focus"]
		table.insert(order, 7, Addon.TargetUnit.FOCUS)
	end

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.CATA then
		items[Addon.TargetUnit.ARENA_1] = Addon.L["Arena %s"]:format("1")
		items[Addon.TargetUnit.ARENA_2] = Addon.L["Arena %s"]:format("2")
		items[Addon.TargetUnit.ARENA_3] = Addon.L["Arena %s"]:format("3")
		table.insert(order, Addon.TargetUnit.ARENA_1)
		table.insert(order, Addon.TargetUnit.ARENA_2)
		table.insert(order, Addon.TargetUnit.ARENA_3)
	end

	return items, order
end

--- Get a localized list of all available target hostility settings.
---
--- @return table<string,string> items
--- @return string[] order
function Addon:GetLocalizedTargetHostility()
	--- @type table<string,string>
	local items = {
		[Addon.TargetHostility.ANY] = Addon.L["Friendly, Hostile"],
		[Addon.TargetHostility.HELP] = Addon.L["Friendly"],
		[Addon.TargetHostility.HARM] = Addon.L["Hostile"]
	}

	--- @type string[]
	local order = {
		Addon.TargetHostility.ANY,
		Addon.TargetHostility.HELP,
		Addon.TargetHostility.HARM
	}

	return items, order
end

--- Get a localized list of all available target vitals settings.
---
--- @return table<string,string> items
--- @return string[] order
function Addon:GetLocalizedTargetVitals()
	--- @type table<string,string>
	local items = {
		[Addon.TargetVitals.ANY] = Addon.L["Alive, Dead"],
		[Addon.TargetVitals.ALIVE] = Addon.L["Alive"],
		[Addon.TargetVitals.DEAD] = Addon.L["Dead"]
	}

	--- @type string[]
	local order = {
		Addon.TargetVitals.ANY,
		Addon.TargetVitals.ALIVE,
		Addon.TargetVitals.DEAD
	}

	return items, order
end

--- Get a localized list of all available classes, this will
--- return the correct value for both Retail and Classic.
---
--- @return table<ClassFile,string> items
--- @return integer[] order
function Addon:GetLocalizedClasses()
	--- @type table<string,string>
	local items = {}

	--- @type string[]
	local order = {}

	--- @type table<ClassFile,string>
	local classes = LocalizedClassList()

	for classId, className in pairs(classes) do
		if classId ~= "Adventurer" then
			local _, _, _, color = GetClassColor(classId)
			items[classId] = string.format("|c%s%s|r", color, className)
			table.insert(order, classId)
		end
	end

	table.sort(order)

	return items, order
end

--- Get a localized list of all available races, this will
--- return the correct value for both Retail and Classic.
---
--- @return table<string,string> items
--- @return string[] order
function Addon:GetLocalizedRaces()
	--- @type table<string,string>
	local items = {}

	--- @type string[]
	local order = {}

	for _, raceId in ipairs(allRaces) do
		local raceInfo = C_CreatureInfo.GetRaceInfo(raceId)

		if raceInfo ~= nil then
			items[raceInfo.clientFileString] = raceInfo.raceName
			table.insert(order, raceInfo.clientFileString)
		end
	end

	table.sort(order)

	return items, order
end

--- Get a localized list of all available specializations for the
--- given class names. If the `classNames` parameter is `nil` it
--- will return results for the player's current class.
---
--- @param classNames? string[]
--- @return table<integer,string> items
--- @return integer[] order
function Addon:GetLocalizedSpecializations(classNames)
	--- @type table<integer,string>
	local items = {}

	--- @type integer[]
	local order = {}

	if classNames == nil then
		classNames = {}
		classNames[1] = select(2, UnitClass("player"))
	end

	if #classNames == 1 then
		local class = classNames[1]
		local specs = LibTalentInfo:GetSpecializations(class)

		for specIndex, spec in pairs(specs) do
			items[specIndex] = Addon:GetTextureString(spec.name, spec.icon)
			table.insert(order, specIndex)
		end
	else
		local max = 0

		-- Find class with the most specializations out of all available classes
		if #classNames == 0 then
			for _, class in ipairs(allClasses) do
				max = math.max(max, LibTalentInfo:GetNumSpecializations(class))
			end
		-- Find class with the most specializations out of the selected classes
		else
			for i = 1, #classNames do
				local class = classNames[i]
				max = math.max(max, LibTalentInfo:GetNumSpecializations(class))
			end
		end

		for i = 1, max do
			local key = i

			items[key] = string.format(Addon.L["Specialization %s"], i)
			table.insert(order, key)
		end
	end

	return items, order
end

if Addon.EXPANSION_LEVEL >= Addon.Expansion.DF then
	--- Get a localized list of all available talents for the
	--- given specialization IDs. If the `specializations` parameter
	--- is `nil` it will return results for the player's current specialization.
	---
	--- @param specializations? integer[]
	--- @return TalentInfo[]
	function Addon:GetLocalizedTalents(specializations)
		--- @type TalentInfo[]
		local result = {}

		if specializations == nil then
			specializations = {}
			specializations[1] = GetSpecializationInfo(GetSpecialization())
		end

		--- @type table<string,boolean>
		local found = {}

		for _, specialization in ipairs(specializations) do
			local talents = GetTalentsForSpecialization(specialization)

			if talents ~= nil then
				for i = 1, #talents do
					local talent = talents[i]

					if not found[talent.text] then
						found[talent.text] = true
						table.insert(result, talents[i])
					end
				end
			end
		end

		return result
	end
elseif Addon.EXPANSION_LEVEL >= Addon.Expansion.CATA then
	--- Get a localized list of all available talents for the
	--- given specialization IDs. If the `specializations` parameter
	--- is `nil` it will return results for the player's current specialization.
	---
	--- @param specializations? integer[]
	--- @return TalentInfo[]
	function Addon:GetLocalizedTalents(specializations)
		--- @type TalentInfo[]
		local result = {}

		if specializations == nil then
			specializations = {}
			specializations[1] = GetSpecializationInfo(GetSpecialization())
		end

		--- @type table<string,boolean>
		local found = {}

		for _, specialization in ipairs(specializations) do
			local talents = LibTalentInfo:GetTalents(specialization)

			if talents ~= nil then
				for i = 1, #talents do
					local talent = talents[i]

					if not found[talent.name] then
						found[talent.name] = true
						table.insert(result, {
							text = talent.name,
							icon = talent.icon,
							specId = specialization
						})
					end
				end
			end
		end

		return result
	end
else
	--- Get a localized list of all available talents for the
	--- given specialization IDs. If the `specializations` parameter
	--- is `nil` it will return results for the player's current specialization.
	---
	--- @param classes? string[]
	--- @return TalentInfo[]
	function Addon:GetLocalizedTalents(classes)
		--- @type TalentInfo[]
		local result = {}

		if classes == nil then
			classes = {}
			classes[1] = select(2, UnitClass("player"))
		end

		--- @type table<string,boolean>
		local found = {}

		for _, class in ipairs(classes) do
			local talents = LibTalentInfo:GetTalents(class)

			for i = 1, #talents do
				local talent = talents[i]

				if not found[talent.name] then
					found[talent.name] = true
					table.insert(result, {
						text = talent.name,
						icon = talent.icon
					})
				end
			end
		end

		return result
	end
end

--- Get a localized list of all available PvP talents for the
--- given specialization IDs. If the `specializations` parameter
--- is `nil` it will return results for the player's current specialization.
---
--- @param specializations? integer[]
--- @return TalentInfo[]
function Addon:GetLocalizedPvPTalents(specializations)
	--- @type TalentInfo[]
	local result = {}

	if specializations == nil then
		specializations = {}
		specializations[1] = GetSpecializationInfo(GetSpecialization())
	end

	--- @type table<string,boolean>
	local found = {}

	for _, specialization in ipairs(specializations) do
		local talents = GetPvPTalentsForSpecialization(specialization)

		if talents ~= nil then
			for i = 1, #talents do
				local talent = talents[i]

				if not found[talent.text] then
					found[talent.text] = true
					table.insert(result, talents[i])
				end
			end
		end
	end

	return result
end

if Addon.EXPANSION_LEVEL >= Addon.Expansion.MOP then
	--- Get a localized list of all available shapeshift forms for the given specialization IDs.
	--- If the `specializations` parameter is `nil` it will return results for the player's current specialization.
	---
	--- @param specializations integer[]
	--- @return table<integer,string> items
	--- @return integer[] order
	function Addon:GetLocalizedForms(specializations)
		--- @type table<integer,string>
		local items = {
			Addon.L["None"]
		}

		--- @type integer[]
		local order = {
			1
		}

		if #specializations == 1 then
			local specId = specializations[1]

			for _, spellId in Addon:IterateShapeshiftForms(specId) do
				local spell = Addon:GetSpellInfo(spellId, true)
				local key = #order + 1

				local icon = spell ~= nil and spell.iconID or nil
				local name = spell ~= nil and spell.name or nil

				items[key] = Addon:GetTextureString(name, icon)
				table.insert(order, key)
			end
		else
			--- @type { [integer]: { name: string, icon: integer, seen: integer }}
			local found = {}

			for _, spec in ipairs(specializations) do
				for index, spellId in ipairs(Addon:GetShapeshiftForms(spec)) do
					local spell = Addon:GetSpellInfo(spellId, true)
					local name = spell ~= nil and spell.name or nil
					local icon = spell ~= nil and spell.iconID or nil

					local current = found[index]

					if current == nil then
						found[index] = {
							name = name,
							icon = icon,
							seen = 1
						}
					elseif current.name == name and current.icon == icon then
						current.seen = current.seen + 1
					end
				end
			end

			for i = 1, #found do
				local key = #order + 1
				local current = found[i]

				if current.seen == #specializations then
					items[key] = Addon:GetTextureString(current.name, current.icon)
				else
					items[key] = string.format(Addon.L["Stance %s"], i)
				end

				table.insert(order, key)
			end
		end

		return items, order
	end
else
	--- Get a localized list of all available classic shapeshift forms for the  given class names.
	--- If the `classNames` parameter is `nil` it will return results for the player's current class.
	---
	--- @param classes? string[]
	--- @return table<integer,string> items
	--- @return integer[] order
	function Addon:GetLocalizedForms(classes)
		--- @type table<integer,string>
		local items = {}

		--- @type integer[]
		local order = {}

		if classes == nil then
			classes = {}
			classes[1] = select(2, UnitClass("player"))
		end

		if #classes == 1 then
			local className = classes[1]
			local defaultForm = Addon.L["None"]

			if className == "DRUID" then
				defaultForm = Addon.L["Humanoid Form"]
			end

			do
				local key = #order + 1

				items[key] = defaultForm
				table.insert(order, key)
			end

			for _, spellIds in Addon:IterateShapeshiftForms(className) do
				local key = #order + 1
				local targetSpellId = spellIds[#spellIds]

				-- Find first available form to set name
				for _, spellId in ipairs(spellIds) do
					if IsSpellKnown(spellId) then
						targetSpellId = spellId
						break
					end
				end

				local spell = Addon:GetSpellInfo(targetSpellId, false)
				local icon = spell ~= nil and spell.iconID or nil
				local name = spell ~= nil and spell.name or nil

				items[key] = Addon:GetTextureString(name, icon)

				table.insert(order, key)
			end
		else
			local max = 0

			-- Find specialization with the highest number of forms
			if #classes == 0 then
				for _, forms in Addon:IterateShapeshiftClasses() do
					if #forms > max then
						max = #forms
					end
				end
			-- Find specialization with the highest number of forms out of the selected specializations
			else
				for _, className in ipairs(classes) do
					local forms = Addon:GetShapeshiftForms(className)

					if #forms > max then
						max = #forms
					end
				end
			end

			-- start at 0 because [form:0] is no form
			for i = 0, max do
				local key = #order + 1

				items[key] = string.format(Addon.L["Stance %s"], i)
				table.insert(order, key)
			end
		end

		return items, order
	end
end

--- @param scope DataObjectScope
function Addon:GetLocalizedScope(scope)
	if scope == Clicked.DataObjectScope.GLOBAL then
		return Addon.L["Global"]
	end

	if scope == Clicked.DataObjectScope.PROFILE then
		local defaultProfiles = {
			["Default"] = Addon.L["Default"],
			[Addon.db.keys.char] = Addon.db.keys.char,
			[Addon.db.keys.realm] = Addon.db.keys.realm,
			[Addon.db.keys.class] = UnitClass("player")
		}

		local profile = Addon.db:GetCurrentProfile()
		return defaultProfiles[profile] or profile
	end

	error("Unknown binding scope: " .. scope)
end
