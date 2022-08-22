local VERSION_MAJOR = "LibTalentInfoClassic-1.0"
local VERSION_MINOR = 1

if LibStub == nil then
	error(VERSION_MAJOR .. " requires LibStub")
end

--- @class LibTalentInfoClassic
local LibTalentInfoClassic = LibStub:NewLibrary(VERSION_MAJOR, VERSION_MINOR)

--- @class TalentProvider
--- @field public version integer
--- @field public classes string[]?
--- @field public talents table<string,integer[]>

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

function LibTalentInfoClassic:GetNumTalentsForTab(class, tabIndex)
	assert(type(class) == "string", "bad argument #1: expected string, got " .. type(class))
	assert(type(tabIndex) == "number", "bad argument #2: expected number, got " .. type(tabIndex))

	if talentProvider == nil then
		error("No talent provider registered, register one first using 'RegisterTalentProvider'.")
	end

	if talentProvider.talents[class] == nil then
		return 0
	end

	if tabIndex <= 0 or tabIndex > MAX_TALENT_TABS then
		error("Talent tab is out of range: " .. tabIndex .. ". Must be an integer between 1 and " .. MAX_TALENT_TABS)
	end

	local talents = talentProvider.talents[class][tabIndex] or {}
	return #talents
end

--- Get the info for a talent of the specified class.
---
--- @param class string The class file name obtained by `UnitClass`.
--- @param tabIndex integer An integer value between 1 and `MAX_TALENT_TABS`.
--- @param talentIndex integer An integer value between 1 and `MAX_NUM_TALENTS`.
--- @return integer? talentID
--- @return string? name
--- @return integer? texture
--- @return boolean? selected
--- @return boolean? available
--- @return integer? spellID
--- @return nil
--- @return integer? row
--- @return integer? column
--- @return boolean? known
--- @return boolean? grantedByAura
function LibTalentInfoClassic:GetTalentInfo(class, tabIndex, talentIndex)
	assert(type(class) == "string", "bad argument #1: expected string, got " .. type(class))
	assert(type(tabIndex) == "number", "bad argument #2: expected number, got " .. type(tabIndex))
	assert(type(talentIndex) == "number", "bad argument #3: expected number, got " .. type(talentIndex))

	if talentProvider == nil then
		error("No talent provider registered, register one first using 'RegisterTalentProvider'.")
	end

	if talentProvider.talents[class] == nil then
		return nil
	end

	if tabIndex <= 0 or tabIndex > MAX_TALENT_TABS then
		error("Talent tab is out of range: " .. tabIndex .. ". Must be an integer between 1 and " .. MAX_TALENT_TABS)
	end

	if talentIndex <= 0 or talentIndex > MAX_NUM_TALENTS then
		error("Talent index is out of range: " .. talentIndex .. ". Must be an integer between 1 and " .. MAX_NUM_TALENTS)
	end

	local talents = talentProvider.talents[class][tabIndex] or {}

	if talentIndex > #talents then
		return nil
	end

	local talentID = talents[talentIndex]
	return talentID, GetTalentInfo(tabIndex, talentIndex)
end
