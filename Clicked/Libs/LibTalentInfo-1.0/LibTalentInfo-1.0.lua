if LibStub == nil then
	error("LibTalentInfo-1.0 requires LibStub")
end

--- @class LibTalentInfo-1.0
local LibTalentInfo = LibStub:NewLibrary("LibTalentInfo-1.0", 11)

--- @class TalentProvider
--- @field public version integer
--- @field public specializations table<string,table<integer,integer>>
--- @field public pvpTalents table<integer,integer[]>

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
--- @return integer
function LibTalentInfo:GetNumPvPTalentsForSpec(specID)
	if talentProvider == nil then
		error("No talent provider registered, register one first using 'RegisterTalentProvider'.")
	end

	if specID == nil or talentProvider.pvpTalents[specID] == nil then
		return 0
	end

	return #talentProvider.pvpTalents[specID]
end

--- Get info for a PvP talent of the specified specialization.
---
--- @param specID integer The specialization ID obtained by `GetSpecializationInfo`.
--- @param index integer An integer between `1` and the number of PvP talents available for the specified specialization.
--- @return integer? talentID
--- @see LibTalentInfo#GetNumPvPTalentsForSpec
function LibTalentInfo:GetPvpTalentAt(specID, index)
	assert(type(index) == "number", "bad argument #2: expected number, got " .. type(index))

	if talentProvider == nil then
		error("No talent provider registered, register one first using 'RegisterTalentProvider'.")
	end

	if specID == nil or talentProvider.pvpTalents[specID] == nil then
		return nil
	end

	return talentProvider.pvpTalents[specID][index]
end
