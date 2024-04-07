local VERSION_MAJOR = "LibTalentInfoClassic-1.0"
local VERSION_MINOR = 1

if LibStub == nil then
	error(VERSION_MAJOR .. " requires LibStub")
end

--- @class LibTalentInfoClassic-1.0
local LibTalentInfoClassic = LibStub:NewLibrary(VERSION_MAJOR, VERSION_MINOR)

--- @alias SpecializationInfo { id: integer, name: string, icon: integer}

--- @class TalentProvider
--- @field public version integer
--- @field public specializations table<string, {[integer]: SpecializationInfo}>?
--- @field public talents table<integer,{ id: integer, name: string, icon: integer }[]>


if LibTalentInfoClassic == nil then
	return
end

--- @type TalentProvider
local talentProvider

--- @param provider TalentProvider
function LibTalentInfoClassic:RegisterTalentProvider(provider)
	assert(type(provider) == "table", "bad argument #1: expected table, got " .. type(provider))

	if talentProvider ~= nil and provider.version <= talentProvider.version then
		return
	end

	talentProvider = provider
end

--- @return integer
function LibTalentInfoClassic:GetTalentProviderVersion()
	if talentProvider == nil then
		return -1
	end

	return talentProvider.version
end

--- Get all specialization IDs for the given class.
---
--- @param classFileName string
--- @return {[integer]: SpecializationInfo}
function LibTalentInfoClassic:GetClassSpecializations(classFileName)
	if talentProvider == nil then
		error("No talent provider registered, register one first using 'RegisterTalentProvider'.")
	end

	if classFileName == nil or talentProvider.specializations[classFileName] == nil then
		return {}
	end

	local specializationIDs = talentProvider.specializations[classFileName]
	local result = {}

	for index, spec in pairs(specializationIDs) do
		result[index] = { id = spec.id, name = spec.name, icon = spec.icon }
	end

	return result
end

--- Get a specialization for the given class.
---
--- @param classFileName string
--- @param tabIndexOrSpecID integer
--- @return SpecializationInfo
function LibTalentInfoClassic:GetClassSpecialization(classFileName, tabIndexOrSpecID)
	if talentProvider == nil then
		error("No talent provider registered, register one first using 'RegisterTalentProvider'.")
	end

	if classFileName == nil or talentProvider.specializations[classFileName] == nil then
		return {}
	end

	local specializationIDs = talentProvider.specializations[classFileName]

	if tabIndexOrSpecID > 0 and tabIndexOrSpecID <= MAX_TALENT_TABS then
		local spec = specializationIDs[tabIndexOrSpecID]
		return { id = spec.id, name = spec.name, icon = spec.icon, }
	end

	for _, spec in pairs(specializationIDs) do
		if spec.id == tabIndexOrSpecID then
			return { id = spec.id, name = spec.name, icon = spec.icon }
		end
	end

	error("No specialization found for class " .. classFileName .. " with index or ID " .. tabIndexOrSpecID)
end

--- Get the number of specializations for a class.
---
--- @param classFileName string
--- @return integer
function LibTalentInfoClassic:GetNumSpecializationsForClass(classFileName)
	if talentProvider == nil then
		error("No talent provider registered, register one first using 'RegisterTalentProvider'.")
	end

	if classFileName == nil or talentProvider.specializations[classFileName] == nil then
		return 0
	end

	local specializationIDs = talentProvider.specializations[classFileName] or {}
	return #specializationIDs
end

--- Get the amount of talents available in the talent tree for a specific specialization.
---
--- @param classFileName string
--- @param tabIndex integer
--- @return integer
function LibTalentInfoClassic:GetNumTalentsForTab(classFileName, tabIndex)
	assert(type(classFileName) == "string", "bad argument #1: expected string, got " .. type(classFileName))
	assert(type(tabIndex) == "number", "bad argument #2: expected number, got " .. type(tabIndex))

	if talentProvider == nil then
		error("No talent provider registered, register one first using 'RegisterTalentProvider'.")
	end

	local specs = talentProvider.specializations[classFileName]
	if specs == nil then
		error("No talents found for class: " .. classFileName)
	end

	local spec = specs[tabIndex]

	if tabIndex <= 0 or tabIndex > MAX_TALENT_TABS or spec == nil then
		error("Talent tab is out of range: " .. tabIndex .. ". Must be an integer between 1 and " .. MAX_TALENT_TABS)
	end

	local talents = talentProvider.talents[spec.id] or {}
	return #talents
end

--- Get the amount of talents available in the talent tree for a specific specialization.
---
--- @param specID integer
--- @return integer
function LibTalentInfoClassic:GetNumTalentsForSpec(specID)
	assert(type(specID) == "number", "bad argument #2: expected number, got " .. type(specID))

	if talentProvider == nil then
		error("No talent provider registered, register one first using 'RegisterTalentProvider'.")
	end

	local talents = talentProvider.talents[specID] or {}
	if talents == nil then
		error("No talents found for spec ID: " .. specID)
	end

	return #talents
end

--- Get the info for a talent of the specified class.
---
--- @param specID integer An integer value between 1 and `MAX_TALENT_TABS`, or the specialization ID.
--- @param talentIndex integer An integer value between 1 and `MAX_NUM_TALENTS`.
--- @return integer? talentID
--- @return string? name
--- @return integer? texture
function LibTalentInfoClassic:GetTalentInfoBySpecID(specID, talentIndex)
	assert(type(specID) == "number", "bad argument #2: expected number, got " .. type(specID))
	assert(type(talentIndex) == "number", "bad argument #3: expected number, got " .. type(talentIndex))

	if talentProvider == nil then
		error("No talent provider registered, register one first using 'RegisterTalentProvider'.")
	end

	if talentIndex <= 0 or talentIndex > MAX_NUM_TALENTS then
		error("Talent index is out of range: " .. talentIndex .. ". Must be an integer between 1 and " .. MAX_NUM_TALENTS)
	end

	local talents = talentProvider.talents[specID]

	if talentIndex > #talents then
		return
	end

	local talent = talents[talentIndex]
	return talent.id, talent.name, talent.icon
end

--- Get the info for a talent of the specified class.
---
--- @param classFileName string The class file name obtained by `UnitClass`.
--- @param tabIndex integer An integer value between 1 and `MAX_TALENT_TABS`.
--- @param talentIndex integer An integer value between 1 and `MAX_NUM_TALENTS`.
--- @return integer? talentID
--- @return string? name
--- @return integer? texture
function LibTalentInfoClassic:GetTalentInfoByTab(classFileName, tabIndex, talentIndex)
	assert(type(classFileName) == "string", "bad argument #1: expected string, got " .. type(classFileName))
	assert(type(tabIndex) == "number", "bad argument #2: expected number, got " .. type(tabIndex))
	assert(type(talentIndex) == "number", "bad argument #3: expected number, got " .. type(talentIndex))

	if talentProvider == nil then
		error("No talent provider registered, register one first using 'RegisterTalentProvider'.")
	end

	if tabIndex <= 0 or tabIndex > MAX_TALENT_TABS then
		error("Talent tab is out of range: " .. tabIndex .. ". Must be an integer between 1 and " .. MAX_TALENT_TABS)
	end

	local specializations = talentProvider.specializations[classFileName]  or {}
	local spec = specializations[tabIndex].id

	return self:GetTalentInfoBySpecID(spec, talentIndex)
end
