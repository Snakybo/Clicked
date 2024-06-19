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

local LocalizedClassList = LocalizedClassList or function()  -- Deprecated in 10.2.5
	local classes = {}
	FillLocalizedClassList(classes)
	return classes
end

local LibTalentInfo = LibStub("LibTalentInfo-1.0")
local LibTalentInfoClassic = LibStub("LibTalentInfoClassic-1.0")

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

	AddRace(1, Addon.EXPANSION.CLASSIC) -- Human
	AddRace(2, Addon.EXPANSION.CLASSIC) -- Orc
	AddRace(3, Addon.EXPANSION.CLASSIC) -- Dwarf
	AddRace(4, Addon.EXPANSION.CLASSIC) -- NightElf
	AddRace(5, Addon.EXPANSION.CLASSIC) -- Scourge
	AddRace(6, Addon.EXPANSION.CLASSIC) -- Tauren
	AddRace(7, Addon.EXPANSION.CLASSIC) -- Gnome
	AddRace(8, Addon.EXPANSION.CLASSIC) -- Troll
	AddRace(10, Addon.EXPANSION.BC) -- BloodElf
	AddRace(11, Addon.EXPANSION.BC) -- Draenei
	AddRace(9, Addon.EXPANSION.CATA) -- Goblin
	AddRace(22, Addon.EXPANSION.CATA) -- Worgen
	AddRace(24, Addon.EXPANSION.MOP) -- Pandaren
	AddRace(27, Addon.EXPANSION.BFA) -- Nightborne
	AddRace(28, Addon.EXPANSION.BFA) -- HighmountainTauren
	AddRace(29, Addon.EXPANSION.BFA) -- VoidElf
	AddRace(30, Addon.EXPANSION.BFA) -- LightforgedDraenei
	AddRace(31, Addon.EXPANSION.BFA) -- HighmountainTauren
	AddRace(32, Addon.EXPANSION.BFA) -- KulTiran
	AddRace(34, Addon.EXPANSION.BFA) -- DarkIronDwarf
	AddRace(35, Addon.EXPANSION.BFA) -- Vulpera
	AddRace(36, Addon.EXPANSION.BFA) -- MagharOrc
	AddRace(37, Addon.EXPANSION.BFA) -- Mechagnome
	AddRace(70, Addon.EXPANSION.DF) -- Dracthyr

	AddClass("WARRIOR", Addon.EXPANSION.CLASSIC)
	AddClass("PALADIN", Addon.EXPANSION.CLASSIC)
	AddClass("HUNTER", Addon.EXPANSION.CLASSIC)
	AddClass("ROGUE", Addon.EXPANSION.CLASSIC)
	AddClass("PRIEST", Addon.EXPANSION.CLASSIC)
	AddClass("SHAMAN", Addon.EXPANSION.CLASSIC)
	AddClass("MAGE", Addon.EXPANSION.CLASSIC)
	AddClass("WARLOCK", Addon.EXPANSION.CLASSIC)
	AddClass("DRUID", Addon.EXPANSION.CLASSIC)
	AddClass("DEATHKNIGHT", Addon.EXPANSION.WOTLK)
	AddClass("MONK", Addon.EXPANSION.MOP)
	AddClass("DEMONHUNTER", Addon.EXPANSION.LEGION)
	AddClass("EVOKER", Addon.EXPANSION.DF)
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

					if not Addon:IsStringNilOrEmpty(spellName) then
						table.insert(allTalents[specId], {
							entryId = talentId,
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

	local numTalents = LibTalentInfo:GetNumPvPTalentsForSpec(specId)

	if numTalents == 0 then
		return nil
	end

	allPvpTalents[specId] = {}

	for i = 1, numTalents do
		local talentId = LibTalentInfo:GetPvpTalentAt(specId, i)

		if talentId ~= nil then
			local _, name, texture, _, _, spellId = GetPvpTalentInfoByID(talentId)

			if not Addon:IsStringNilOrEmpty(name) then
				table.insert(allPvpTalents[specId], {
					entryId = talentId,
					spellId = spellId,
					text = name,
					icon = texture,
					specId = specId
				})
			end
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

	items[Addon.TargetUnits.DEFAULT] = Addon.L["Default"]
	items[Addon.TargetUnits.PLAYER] = Addon.L["Player (you)"]
	items[Addon.TargetUnits.TARGET] = Addon.L["Target"]
	items[Addon.TargetUnits.TARGET_OF_TARGET] = Addon.L["Target of target"]
	items[Addon.TargetUnits.MOUSEOVER] = Addon.L["Mouseover"]
	items[Addon.TargetUnits.MOUSEOVER_TARGET] = Addon.L["Target of mouseover"]
	items[Addon.TargetUnits.CURSOR] = Addon.L["Cursor"]
	items[Addon.TargetUnits.PET] = Addon.L["Pet"]
	items[Addon.TargetUnits.PET_TARGET] = Addon.L["Pet target"]
	items[Addon.TargetUnits.PARTY_1] = Addon.L["Party %s"]:format("1")
	items[Addon.TargetUnits.PARTY_2] = Addon.L["Party %s"]:format("2")
	items[Addon.TargetUnits.PARTY_3] = Addon.L["Party %s"]:format("3")
	items[Addon.TargetUnits.PARTY_4] = Addon.L["Party %s"]:format("4")
	items[Addon.TargetUnits.PARTY_5] = Addon.L["Party %s"]:format("5")

	order = {
		Addon.TargetUnits.DEFAULT,
		Addon.TargetUnits.PLAYER,
		Addon.TargetUnits.TARGET,
		Addon.TargetUnits.TARGET_OF_TARGET,
		Addon.TargetUnits.MOUSEOVER,
		Addon.TargetUnits.MOUSEOVER_TARGET,
		Addon.TargetUnits.CURSOR,
		Addon.TargetUnits.PET,
		Addon.TargetUnits.PET_TARGET,
		Addon.TargetUnits.PARTY_1,
		Addon.TargetUnits.PARTY_2,
		Addon.TargetUnits.PARTY_3,
		Addon.TargetUnits.PARTY_4,
		Addon.TargetUnits.PARTY_5
	}

	if Addon.EXPANSION_LEVEL >= Addon.EXPANSION.BC then
		items[Addon.TargetUnits.FOCUS] = Addon.L["Focus"]
		table.insert(order, 7, Addon.TargetUnits.FOCUS)
	end

	-- TODO: Check if this was available in WOTLK
	if Addon.EXPANSION_LEVEL >= Addon.EXPANSION.CATA then
		items[Addon.TargetUnits.ARENA_1] = Addon.L["Arena %s"]:format("1")
		items[Addon.TargetUnits.ARENA_2] = Addon.L["Arena %s"]:format("2")
		items[Addon.TargetUnits.ARENA_3] = Addon.L["Arena %s"]:format("3")
		table.insert(order, Addon.TargetUnits.ARENA_1)
		table.insert(order, Addon.TargetUnits.ARENA_2)
		table.insert(order, Addon.TargetUnits.ARENA_3)
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
			local name = string.format("|c%s%s|r", color, className)

			items[classId] = string.format("<text=%s>", name)
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
			items[raceInfo.clientFileString] = string.format("<text=%s>", raceInfo.raceName)
			table.insert(order, raceInfo.clientFileString)
		end
	end

	table.sort(order)

	return items, order
end

if Addon:IsGameVersionAtleast("RETAIL") then
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
			local specs = LibTalentInfo:GetClassSpecIDs(class)

			for specIndex, specId in pairs(specs) do
				local _, name, _, icon = GetSpecializationInfoByID(specId)
				local key = specIndex

				if not Addon:IsStringNilOrEmpty(name) then
					items[key] = string.format("<icon=%d><text=%s>", icon, name)
					table.insert(order, key)
				end
			end
		else
			--- @param specs table<integer,integer>
			--- @return integer
			local function CountSpecs(specs)
				local count = 0

				for _, specId in pairs(specs) do
					local _, name = GetSpecializationInfoByID(specId)

					if not Addon:IsStringNilOrEmpty(name) then
						count = count + 1
					end
				end

				return count
			end

			local max = 0

			-- Find class with the most specializations out of all available classes
			if #classNames == 0 then
				for _, class in ipairs(allClasses) do
					local specs = LibTalentInfo:GetClassSpecIDs(class)
					local count = CountSpecs(specs)

					if count > max then
						max = count
					end
				end
			-- Find class with the most specializations out of the selected classes
			else
				for i = 1, #classNames do
					local class = classNames[i]
					local specs = LibTalentInfo:GetClassSpecIDs(class)

					local count = CountSpecs(specs)

					if count > max then
						max = count
					end
				end
			end

			for i = 1, max do
				local key = i

				items[key] = string.format("<text=%s>", Addon.L["Specialization %s"]:format(i))
				table.insert(order, key)
			end
		end

		return items, order
	end

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

	--- Get a localized list of all available shapeshift forms for the given specialization IDs.
	--- If the `specializations` parameter is `nil` it will return results for the player's current specialization.
	---
	--- @param specializations? integer[]
	--- @return table<integer,string> items
	--- @return integer[] order
	function Addon:GetLocalizedForms(specializations)
		--- @type table<integer,string>
		local items = {}

		--- @type integer[]
		local order = {}

		if specializations == nil then
			specializations = {}
			specializations[1] = GetSpecializationInfo(GetSpecialization())
		end

		if #specializations == 1 then
			local specId = specializations[1]
			local defaultForm = Addon.L["None"]

			-- Balance Druid, Feral Druid, Guardian Druid, Restoration Druid, Initial Druid
			if specId == 102 or specId == 103 or specId == 104 or specId == 105 or specId == 1447 then
				defaultForm = Addon.L["Humanoid Form"]
			end

			do
				local key = #order + 1

				items[key] = string.format("<text=%s>", defaultForm)
				table.insert(order, key)
			end

			for _, spellId in Addon:IterateShapeshiftForms(specId) do
				local name, _, icon = Addon:GetSpellInfo(spellId, true)
				local key = #order + 1

				items[key] = string.format("<icon=%d><text=%s>", icon, name)
				table.insert(order, key)
			end
		else
			local max = 0

			-- Find specialization with the highest number of forms
			if #specializations == 0 then
				for _, forms in Addon:IterateShapeshiftSpecs() do
					if #forms > max then
						max = #forms
					end
				end
			-- Find specialization with the highest number of forms out of the selected specializations
			else
				for _, spec in ipairs(specializations) do
					local forms = Addon:GetShapeshiftForms(spec)

					if #forms > max then
						max = #forms
					end
				end
			end

			-- start at 0 because [form:0] is no form
			for i = 0, max do
				local key = #order + 1

				items[key] = string.format("<text=%s>", Addon.L["Stance %s"]:format(i))
				table.insert(order, key)
			end
		end

		return items, order
	end
elseif Addon:IsGameVersionAtleast("CATA") then
	--- Get a localized list of all available specializations for the given class names. If the `classNames` parameter is `nil` it will return results for the
	--- player's current class.
	---
	--- @param classNames? string[]
	--- @return table<integer,string> items
	--- @return integer[] order
	function Addon:Cata_GetLocalizedSpecializations(classNames)
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
			local specs = LibTalentInfoClassic:GetClassSpecializations(class)

			for specIndex, spec in pairs(specs) do
				local _, name, _, icon = GetSpecializationInfoForSpecID(spec.id)
				local key = specIndex

				if not Addon:IsStringNilOrEmpty(name) then
					items[key] = string.format("<icon=%d><text=%s>", icon, name)
					table.insert(order, key)
				end
			end
		else
			local max = 0

			-- Find class with the most specializations out of all available classes
			if #classNames == 0 then
				for _, class in ipairs(allClasses) do
					local count = LibTalentInfoClassic:GetNumSpecializationsForClass(class)

					if count > max then
						max = count
					end
				end
			-- Find class with the most specializations out of the selected classes
			else
				for i = 1, #classNames do
					local count = LibTalentInfoClassic:GetNumSpecializationsForClass(classNames[i])

					if count > max then
						max = count
					end
				end
			end

			for i = 1, max do
				local key = i

				items[key] = string.format("<text=%s>", Addon.L["Specialization %s"]:format(i))
				table.insert(order, key)
			end
		end

		return items, order
	end

	--- Get a localized list of all available talents for the
	--- given specialization IDs. If the `specializations` parameter
	--- is `nil` it will return results for the player's current specialization.
	---
	--- @param specializations? integer[]
	--- @return TalentInfo[]
	function Addon:Cata_GetTalents(specializations)
		--- @type TalentInfo[]
		local result = {}

		if specializations == nil then
			local class = select(2, UnitClass("player"))
			specializations = {}
			specializations[1] = LibTalentInfoClassic:GetClassSpecialization(class, GetPrimaryTalentTree()).id
		end

		--- @type table<string,boolean>
		local found = {}

		for _, specialization in ipairs(specializations) do
			local count = LibTalentInfoClassic:GetNumTalentsForSpec(specialization)

			for i = 1, count do
				local id, name, texture = LibTalentInfoClassic:GetTalentInfoBySpecID(specialization, i)

				if name ~= nil and not found[name] then
					found[name] = true
					table.insert(result, {
						entryId = id,
						text = name,
						icon = texture,
					})
				end
			end
		end

		return result
	end

	--- Get a localized list of all available classic shapeshift forms for the  given class names.
	--- If the `classNames` parameter is `nil` it will return results for the player's current class.
	---
	--- @param classes? string[]
	--- @return table<integer,string> items
	--- @return integer[] order
	function Addon:Classic_GetLocalizedForms(classes)
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

				items[key] = string.format("<text=%s>", defaultForm)
				table.insert(order, key)
			end

			for _, spellIds in Addon:Classic_IterateShapeshiftForms(className) do
				local key = #order + 1
				local targetSpellId = spellIds[#spellIds]

				-- Find first available form to set name
				for _, spellId in ipairs(spellIds) do
					if IsSpellKnown(spellId) then
						targetSpellId = spellId
						break
					end
				end

				local name, _, icon = Addon:GetSpellInfo(targetSpellId, false)
				items[key] = string.format("<icon=%d><text=%s>", icon, name)

				table.insert(order, key)
			end
		else
			local max = 0

			-- Find specialization with the highest number of forms
			if #classes == 0 then
				for _, forms in Addon:Classic_IterateShapeshiftClasses() do
					if #forms > max then
						max = #forms
					end
				end
			-- Find specialization with the highest number of forms out of the selected specializations
			else
				for _, className in ipairs(classes) do
					local forms = Addon:Classic_GetShapeshiftForms(className)

					if #forms > max then
						max = #forms
					end
				end
			end

			-- start at 0 because [form:0] is no form
			for i = 0, max do
				local key = #order + 1

				items[key] = string.format("<text=%s>", Addon.L["Stance %s"]:format(i))
				table.insert(order, key)
			end
		end

		return items, order
	end
else
	--- Get a localized list of all available talents for the given classes.
	--- If the `classes` parameter is `nil` it will return results for the player's current class.
	---
	--- @param classes? string[]
	--- @return table<string,string> items
	--- @return integer[] order
	function Addon:Classic_GetLocalizedTalents(classes)
		--- @type table<string,string>
		local items = {}

		--- @type integer[]
		local order = {}

		if classes == nil then
			classes = {}
			classes[1] = select(2, UnitClass("player"))
		end

		if #classes == 1 and classes[1] == select(2, UnitClass("player")) then
			local class = classes[1]

			for tab = 1, GetNumTalentTabs() do
				for index = 1, GetNumTalents(tab) do
					local _, name, texture = LibTalentInfoClassic:GetTalentInfo(class, tab, index)
					local key = #order + 1

					if not Addon:IsStringNilOrEmpty(name) then
						items[key] = string.format("<icon=%d><text=%s>", texture, name)
						table.insert(order, key)
					end
				end
			end
		else
			for tab = 1, MAX_TALENT_TABS do
				local max = 0

				-- Find the class with the highest number of talents for the given tab
				for _, class in ipairs(classes) do
					local count = LibTalentInfoClassic:GetNumTalentsForTab(class, tab)

					if count > max then
						max = count
					end
				end

				for index = 1, max do
					local key = #order + 1

					items[key] = string.format("<text=%s>", Addon.L["Talent %s/%s"]:format(tab, index))
					table.insert(order, key)
				end
			end
		end

		return items, order
	end

	--- Get a localized list of all available classic shapeshift forms for the  given class names.
	--- If the `classNames` parameter is `nil` it will return results for the player's current class.
	---
	--- @param classes? string[]
	--- @return table<integer,string> items
	--- @return integer[] order
	function Addon:Classic_GetLocalizedForms(classes)
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

				items[key] = string.format("<text=%s>", defaultForm)
				table.insert(order, key)
			end

			for _, spellIds in Addon:Classic_IterateShapeshiftForms(className) do
				local key = #order + 1
				local targetSpellId = spellIds[#spellIds]

				-- Find first available form to set name
				for _, spellId in ipairs(spellIds) do
					if IsSpellKnown(spellId) then
						targetSpellId = spellId
						break
					end
				end

				local name, _, icon = Addon:GetSpellInfo(targetSpellId, false)
				items[key] = string.format("<icon=%d><text=%s>", icon, name)

				table.insert(order, key)
			end
		else
			local max = 0

			-- Find specialization with the highest number of forms
			if #classes == 0 then
				for _, forms in Addon:Classic_IterateShapeshiftClasses() do
					if #forms > max then
						max = #forms
					end
				end
			-- Find specialization with the highest number of forms out of the selected specializations
			else
				for _, className in ipairs(classes) do
					local forms = Addon:Classic_GetShapeshiftForms(className)

					if #forms > max then
						max = #forms
					end
				end
			end

			-- start at 0 because [form:0] is no form
			for i = 0, max do
				local key = #order + 1

				items[key] = string.format("<text=%s>", Addon.L["Stance %s"]:format(i))
				table.insert(order, key)
			end
		end

		return items, order
	end
end

--- @param scope BindingScope
function Addon:GetLocalizedScope(scope)
	if scope == Addon.BindingScope.GLOBAL then
		return Addon.L["Global bindings"]
	end

	if scope == Addon.BindingScope.PROFILE then
		return Addon.L["Profile specific bindings"]
	end

	error("Unknown binding scope: " .. scope)
end
