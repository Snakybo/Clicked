local VERSION_MAJOR = "LibTalentInfo-1.0"
local VERSION_MINOR = 9

if LibStub == nil then
	error(VERSION_MAJOR .. " requires LibStub")
end

--- @class LibTalentInfo
local LibTalentInfo = LibStub:NewLibrary(VERSION_MAJOR, VERSION_MINOR)

--- @class TalentProvider
--- @field public version integer
--- @field public specializations table<string,integer>
--- @field public talents table<integer,integer[]>
--- @field public pvpTalentSlotCount integer
--- @field public pvpTalents table<integer,integer[][]>

if LibTalentInfo == nil then
	return
end

--- @type TalentProvider
local talentProvider

--- @param provider TalentProvider
function LibTalentInfo:RegisterTalentProvider(provider)
	assert(type(provider) == "table", "bad argument #1: expected table, got " .. type(provider))

	if talentProvider ~= nil and provider.version <= talentProvider.version then
		return
	end

	talentProvider = provider
end

--- @return integer
function LibTalentInfo:GetTalentProviderVersion()
	if talentProvider == nil then
		return -1
	end

	return talentProvider.version
end

--- Get all specialization IDs for the specified class.
---
--- @param classFilename string The non-localized class name as returned by `UnitClass`.
--- @return table<integer,integer>
function LibTalentInfo:GetClassSpecIDs(classFilename)
	if talentProvider == nil then
		error("No talent provider registered, register one first using 'RegisterTalentProvider'.")
	end

	if classFilename == nil or talentProvider.specializations[classFilename] == nil then
		return {}
	end

	local specializationIds = talentProvider.specializations[classFilename]
	local result = {}

	for specIndex, specId in pairs(specializationIds) do
		result[specIndex] = specId
	end

	return result
end

--- Get the number of available PvP talents that the specified specialization has in the specified talent slot.
---
--- @param specID integer The specialization ID obtained by `GetSpecializationInfo`.
--- @param slotIndex integer
--- @return integer
function LibTalentInfo:GetNumPvPTalentsForSpec(specID, slotIndex)
	assert(type(slotIndex) == "number", "bad argument #2: expected number, got " .. type(slotIndex))

	if talentProvider == nil then
		error("No talent provider registered, register one first using 'RegisterTalentProvider'.")
	end

	if specID == nil or talentProvider.pvpTalents[specID] == nil then
		return 0
	end

	if slotIndex <= 0 or slotIndex > talentProvider.pvpTalentSlotCount then
		error("Slot index is out of range: " .. slotIndex .. ". Must be an integer between 1 and " .. talentProvider.pvpTalentSlotCount)
	end

	local slots = talentProvider.pvpTalents[specID]
	local slotTalents = slots[slotIndex] or {}

	return #slotTalents
end

--- Get the info for a talent of the specified specialization.
---
--- @param specID integer The specialization ID obtained by `GetSpecializationInfo`.
--- @param tier integer An integer value between 1 and `MAX_TALENT_TIERS`.
--- @param column integer An integer value between 1 and `NUM_TALENT_COLUMNS`.
--- @return integer talentID
--- @return string name
--- @return integer texture
--- @return boolean selected
--- @return boolean available
--- @return integer spellID
--- @return nil
--- @return integer row
--- @return integer column
--- @return boolean known
--- @return boolean grantedByAura
function LibTalentInfo:GetTalentInfo(specID, tier, column)
	assert(type(tier) == "number", "bad argument #2: expected number, got " .. type(tier))
	assert(type(column) == "number", "bad argument #3: expected number, got " .. type(column))

	if talentProvider == nil then
		error("No talent provider registered, register one first using 'RegisterTalentProvider'.")
	end

	if specID == nil or talentProvider.talents[specID] == nil then
		return nil
	end

	if tier <= 0 or tier > MAX_TALENT_TIERS then
		error("Talent tier is out of range: " .. tier .. ". Must be an integer between 1 and " .. MAX_TALENT_TIERS)
	end

	if column <= 0 or column > NUM_TALENT_COLUMNS then
		error("Talent column is out of range: " .. column .. ". Must be an integer between 1 and " .. NUM_TALENT_COLUMNS)
	end

	local talentIndex = (tier - 1) * NUM_TALENT_COLUMNS + (column - 1)
	local specTalents = talentProvider.talents[specID] or {}

	if talentIndex + 1 > #specTalents then
		return nil
	end

	local talentID = specTalents[talentIndex + 1]

	return GetTalentInfoByID(talentID, 1)
end

--- Get info for a PvP talent of the specified specialization.
---
--- @param specID integer The specialization ID obtained by `GetSpecializationInfo`.
--- @param slotIndex integer The slot index of the PvP talent row, an integer between `1` and `LibTalentInfo.MAX_PVP_TALENT_SLOTS`.
--- @param talentIndex integer An integer between `1` and the number of PvP talents available for the specified specialization.
--- @return integer talentID
--- @return string name
--- @return integer texture
--- @return boolean selected
--- @return boolean available
--- @return integer spellID
--- @return nil
--- @return integer row
--- @return integer column
--- @return boolean known
--- @return boolean grantedByAura
--- @see LibTalentInfo#GetNumPvPTalentsForSpec
function LibTalentInfo:GetPvPTalentInfo(specID, slotIndex, talentIndex)
	assert(type(slotIndex) == "number", "bad argument #2: expected number, got " .. type(slotIndex))
	assert(type(talentIndex) == "number", "bad argument #3: expected number, got " .. type(talentIndex))

	if talentProvider == nil then
		error("No talent provider registered, register one first using 'RegisterTalentProvider'.")
	end

	if specID == nil or talentProvider.pvpTalents[specID] == nil then
		return nil
	end

	if slotIndex <= 0 or slotIndex > talentProvider.pvpTalentSlotCount then
		error("Slot index is out of range: " .. slotIndex ". Must be an integer between 1 and " .. talentProvider.pvpTalentSlotCount)
	end

	local slots = talentProvider.pvpTalents[specID]
	local slotTalents = slots[slotIndex] or {}

	if talentIndex <= 0 or talentIndex > #slotTalents then
		error("Talent index is out of range: " .. talentIndex .. ". Must be an integer between 1 and " .. #slotTalents)
	end

	local talentID = slotTalents[talentIndex]

	return GetPvpTalentInfoByID(talentID)
end
