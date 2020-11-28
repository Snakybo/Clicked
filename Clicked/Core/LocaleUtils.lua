local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")
local LibTalentInfo = LibStub("LibTalentInfo-1.0")

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

--- Construct a localized string with a summary of the target setting.
---
--- For example:
--- - Friendly Mouseover target
--- - Friendly Dead Target
--- - Hostile Alive Target
---
--- @param target table
--- @return string
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

	if target.unit ~= nil then
		local units = self:GetLocalizedTargetUnits()
		table.insert(result, units[target.unit])
	end

	return table.concat(result, " ")
end

--- Get a localized list of all available target units for a binding.
---
--- @return table items
--- @return table order
function Clicked:GetLocalizedTargetUnits()
	local items = {
		[Clicked.TargetUnits.DEFAULT] = DEFAULT,
		[Clicked.TargetUnits.PLAYER] = L["Player (you)"],
		[Clicked.TargetUnits.TARGET] = TARGET,
		[Clicked.TargetUnits.TARGET_OF_TARGET] = L["Target of target"],
		[Clicked.TargetUnits.MOUSEOVER] = L["Mouseover"],
		[Clicked.TargetUnits.FOCUS] = FOCUS,
		[Clicked.TargetUnits.CURSOR] = L["Cursor"],
		[Clicked.TargetUnits.PET] = PET,
		[Clicked.TargetUnits.PET_TARGET] = L["Pet target"],
		[Clicked.TargetUnits.PARTY_1] = L["Party %s"]:format("1"),
		[Clicked.TargetUnits.PARTY_2] = L["Party %s"]:format("2"),
		[Clicked.TargetUnits.PARTY_3] = L["Party %s"]:format("3"),
		[Clicked.TargetUnits.PARTY_4] = L["Party %s"]:format("4"),
		[Clicked.TargetUnits.PARTY_5] = L["Party %s"]:format("5")
	}

	local order = {
		Clicked.TargetUnits.DEFAULT,
		Clicked.TargetUnits.PLAYER,
		Clicked.TargetUnits.TARGET,
		Clicked.TargetUnits.TARGET_OF_TARGET,
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

	return items, order
end

--- Get a localized list of all available target hostility settings.
---
--- @return table items
--- @return table order
function Clicked:GetLocalizedTargetHostility()
	local items = {
		[Clicked.TargetHostility.ANY] = L["Friendly, Hostile"],
		[Clicked.TargetHostility.HELP] = FRIENDLY,
		[Clicked.TargetHostility.HARM] = HOSTILE
	}

	local order = {
		Clicked.TargetHostility.ANY,
		Clicked.TargetHostility.HELP,
		Clicked.TargetHostility.HARM
	}

	return items, order
end

--- Get a localized list of all available target vitals settings.
---
--- @return table items
--- @return table order
function Clicked:GetLocalizedTargetVitals()
	local items = {
		[Clicked.TargetVitals.ANY] = L["Alive, Dead"],
		[Clicked.TargetVitals.ALIVE] = L["Alive"],
		[Clicked.TargetVitals.DEAD] = DEAD
	}

	local order = {
		Clicked.TargetVitals.ANY,
		Clicked.TargetVitals.ALIVE,
		Clicked.TargetVitals.DEAD
	}

	return items, order
end

--- Get a localized list of all available classes, this will
--- return the correct value for both Retail and Classic.
---
--- @return table items
--- @return table order
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

--- Get a localized list of all available races, this will
--- return the correct value for both Retail and Classic.
---
--- @return table items
--- @return table order
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

--- Get a localized list of all available specializations for the
--- given class names. If the `classNames` parameter is `nil` it
--- will return results for the player's current class.
---
--- @return table items
--- @return table order
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

		for specIndex, specId in pairs(specs) do
			local _, name, _, icon = GetSpecializationInfoByID(specId)
			local key = specIndex

			if not self:IsStringNilOrEmpty(name) then
				items[key] = string.format("<icon=%d><text=%s>", icon, name)
				table.insert(order, key)
			end
		end
	else
		local function CountSpecs(specs)
			local count = 0

			for specIndex in pairs(specs) do
				count = count + 1
			end

			return count
		end

		local max = 0

		-- Find class with the most specializations out of all available classes
		if #classNames == 0 then
			for _, specs in LibTalentInfo:AllClasses() do
				local count = CountSpecs(specs)

				if count > max then
					max = count
				end
			end
		-- Find class with the most specializations out of the selected classes
		else
			for i = 1, #classNames do
				local class = classNames[i]
				local specs = LibTalentInfo:GetClassSpecIDs(class) or {}
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
--- @return table items
--- @return table order
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

				if not self:IsStringNilOrEmpty(name) then
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
--- @return table items
--- @return table order
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
--- @return table items
--- @return table order
function Clicked:GetLocalizedForms(specializations)
	local items = {}
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

		for _, spellId in Clicked:IterateShapeshiftForms(specId) do
			local name, _, icon = GetSpellInfo(spellId)
			local key = #order + 1

			items[key] = string.format("<icon=%d><text=%s>", icon, name)
			table.insert(order, key)
		end
	else
		local max = 0

		-- Find specialization with the highest number of forms
		if #specializations == 0 then
			for _, forms in Clicked:IterateShapeshiftForms() do
				if #forms > max then
					max = #forms
				end
			end
		-- Find specialization with the highest number of forms out of the selected specializations
		else
			for _, spec in ipairs(specializations) do
				local forms = Clicked:GetShapeshiftFormsForSpecId(spec)

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
