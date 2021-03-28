--- @type LibTalentInfo
local LibTalentInfo = LibStub("LibTalentInfo-1.0")

--- @type ClickedInternal
local _, Addon = ...

--- @type Localization
local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

--- @type integer[]
local allRaces

--- @type string[]
local allClasses

if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
	allRaces = {
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

	allClasses = {
		"WARRIOR",
		"PALADIN",
		"HUNTER",
		"ROGUE",
		"PRIEST",
		"DEATHKNIGHT",
		"SHAMAN",
		"MAGE",
		"WARLOCK",
		"MONK",
		"DRUID",
		"DEMONHUNTER"
	}
elseif WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
	allRaces = {
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

	allClasses = {
		"WARRIOR",
		"PALADIN",
		"HUNTER",
		"ROGUE",
		"PRIEST",
		"SHAMAN",
		"MAGE",
		"WARLOCK",
		"DRUID"
	}
end

-- Private addon API

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
	local items = {
		[Addon.TargetUnits.DEFAULT] = DEFAULT,
		[Addon.TargetUnits.PLAYER] = L["Player (you)"],
		[Addon.TargetUnits.TARGET] = TARGET,
		[Addon.TargetUnits.TARGET_OF_TARGET] = L["Target of target"],
		[Addon.TargetUnits.MOUSEOVER] = L["Mouseover"],
		[Addon.TargetUnits.FOCUS] = FOCUS,
		[Addon.TargetUnits.CURSOR] = L["Cursor"],
		[Addon.TargetUnits.PET] = PET,
		[Addon.TargetUnits.PET_TARGET] = L["Pet target"],
		[Addon.TargetUnits.PARTY_1] = L["Party %s"]:format("1"),
		[Addon.TargetUnits.PARTY_2] = L["Party %s"]:format("2"),
		[Addon.TargetUnits.PARTY_3] = L["Party %s"]:format("3"),
		[Addon.TargetUnits.PARTY_4] = L["Party %s"]:format("4"),
		[Addon.TargetUnits.PARTY_5] = L["Party %s"]:format("5"),
		[Addon.TargetUnits.ARENA_1] = L["Arena %s"]:format("1"),
		[Addon.TargetUnits.ARENA_2] = L["Arena %s"]:format("2"),
		[Addon.TargetUnits.ARENA_3] = L["Arena %s"]:format("3")
	}

	local order = {
		Addon.TargetUnits.DEFAULT,
		Addon.TargetUnits.PLAYER,
		Addon.TargetUnits.TARGET,
		Addon.TargetUnits.TARGET_OF_TARGET,
		Addon.TargetUnits.MOUSEOVER,
		Addon.TargetUnits.FOCUS,
		Addon.TargetUnits.CURSOR,
		Addon.TargetUnits.PET,
		Addon.TargetUnits.PET_TARGET,
		Addon.TargetUnits.PARTY_1,
		Addon.TargetUnits.PARTY_2,
		Addon.TargetUnits.PARTY_3,
		Addon.TargetUnits.PARTY_4,
		Addon.TargetUnits.PARTY_5,
		Addon.TargetUnits.ARENA_1,
		Addon.TargetUnits.ARENA_2,
		Addon.TargetUnits.ARENA_3
	}

	return items, order
end

--- Get a localized list of all available target hostility settings.
---
--- @return table<string,string> items
--- @return string[] order
function Addon:GetLocalizedTargetHostility()
	local items = {
		[Addon.TargetHostility.ANY] = L["Friendly, Hostile"],
		[Addon.TargetHostility.HELP] = FRIENDLY,
		[Addon.TargetHostility.HARM] = HOSTILE
	}

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
	local items = {
		[Addon.TargetVitals.ANY] = L["Alive, Dead"],
		[Addon.TargetVitals.ALIVE] = L["Alive"],
		[Addon.TargetVitals.DEAD] = DEAD
	}

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
--- @return table<integer,string> items
--- @return integer[] order
function Addon:GetLocalizedClasses()
	local items = {}
	local order = {}

	--- @type table<integer,string>
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

		items[raceInfo.clientFileString] = string.format("<text=%s>", raceInfo.raceName)
		table.insert(order, raceInfo.clientFileString)
	end

	table.sort(order)

	return items, order
end

--- Get a localized list of all available specializations for the
--- given class names. If the `classNames` parameter is `nil` it
--- will return results for the player's current class.
---
--- @param classNames string[]
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

			for _ in pairs(specs) do
				count = count + 1
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

			items[key] = string.format("<text=%s>", L["Specialization %s"]:format(i))
			table.insert(order, key)
		end
	end

	return items, order
end

--- Get a localized list of all available talents for the
--- given specialization IDs. If the `specializations` parameter
--- is `nil` it will return results for the player's current specialization.
---
--- @param specializations integer[]
--- @return table<integer,string> items
--- @return integer[] order
function Addon:GetLocalizedTalents(specializations)
	--- @type table<integer,string>
	local items = {}

	--- @type integer[]
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

				if not Addon:IsStringNilOrEmpty(name) then
					items[key] = string.format("<icon=%d><text=%s>", texture, name)
					table.insert(order, key)
				end
			end
		end
	else
		for tier = 1, MAX_TALENT_TIERS do
			for column = 1, NUM_TALENT_COLUMNS do
				local key = #order + 1

				items[key] = string.format("<text=%s>", L["Talent %s/%s"]:format(tier, column))
				table.insert(order, key)
			end
		end
	end

	return items, order
end

--- Get a localized list of all available PvP talents for the
--- given specialization IDs. If the `specializations` parameter
--- is `nil` it will return results for the player's current specialization.
---
--- @param specializations integer[]
--- @return table<integer,string> items
--- @return integer[] order
function Addon:GetLocalizedPvPTalents(specializations)
	--- @type table<integer,string>
	local items = {}

	--- @type integer[]
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
			for _, class in ipairs(allClasses) do
				local specs = LibTalentInfo:GetClassSpecIDs(class)

				for _, spec in pairs(specs) do
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

			items[key] = string.format("<text=%s>", L["PvP Talent %s"]:format(i))
			table.insert(order, key)
		end
	end

	return items, order
end

--- Get a localized list of all available shapeshift forms for the
--- given specialization IDs. If the `specializations` parameter
--- is `nil` it will return results for the player's current specialization.
---
--- @param specializations integer[]
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
		local defaultForm = NONE

		-- Balance Druid, Feral Druid, Guardian Druid, Restoration Druid, Initial Druid
		if specId == 102 or specId == 103 or specId == 104 or specId == 105 or specId == 1447 then
			defaultForm = L["Humanoid Form"]
		end

		do
			local key = #order + 1

			items[key] = string.format("<text=%s>", defaultForm)
			table.insert(order, key)
		end

		for _, spellId in Addon:IterateShapeshiftForms(specId) do
			local name, _, icon = Addon:GetSpellInfo(spellId)
			local key = #order + 1

			items[key] = string.format("<icon=%d><text=%s>", icon, name)
			table.insert(order, key)
		end
	else
		local max = 0

		-- Find specialization with the highest number of forms
		if #specializations == 0 then
			for _, forms in Addon:IterateShapeshiftForms() do
				if #forms > max then
					max = #forms
				end
			end
		-- Find specialization with the highest number of forms out of the selected specializations
		else
			for _, spec in ipairs(specializations) do
				local forms = Addon:GetShapeshiftFormsForSpecId(spec)

				if #forms > max then
					max = #forms
				end
			end
		end

		-- start at 0 because [form:0] is no form
		for i = 0, max do
			local key = #order + 1

			items[key] = string.format("<text=%s>", L["Stance %s"]:format(i))
			table.insert(order, key)
		end
	end

	return items, order
end
