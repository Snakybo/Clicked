if LibStub == nil then
	error("LibTalentInfo-1.0 requires LibStub")
end

--- @class LibTalentInfo-1.0
local LibTalentInfo = LibStub:NewLibrary("LibTalentInfo-1.0", 12)

--- @class LibTalentInfo-1.0.Provider
--- @field public classes string[]
--- @field public specializations { [string]: { [integer]: LibTalentInfo-1.0.Specialization } }
--- @field public talents { [unknown]: LibTalentInfo-1.0.Talent[] }
--- @field public pvpTalents { [unknown]: LibTalentInfo-1.0.Talent[] }

--- @class LibTalentInfo-1.0.Specialization
--- @field public id integer
--- @field public name? string
--- @field public icon? integer

--- @class LibTalentInfo-1.0.Talent
--- @field public id integer
--- @field public name string
--- @field public icon integer

if LibTalentInfo == nil then
	return
end

--- @param provider LibTalentInfo-1.0.Provider
function LibTalentInfo:SetProvider(provider)
	assert(type(provider) == "table", "bad argument #1: expected table, got " .. type(provider))

	if self.provider ~= nil then
		error("Cannot register multiple talent providers registered")
	end

	self.provider = provider
end

--- Get the number of classes available in the game.
---
--- @return integer
function LibTalentInfo:GetNumClasses()
	return #self:GetClassesInternal()
end

--- Get the unique identifier of all available classes.
---
--- @return string[]
function LibTalentInfo:GetClasses()
	return CopyTable(self:GetClassesInternal())
end

--- Get the number of specializations available for the given class.
---
--- @param classFileName string
--- @return integer
function LibTalentInfo:GetNumSpecializations(classFileName)
	local specializations = self:GetSpecializationsInternal(classFileName)
	local result = 0

	for _ in pairs(specializations) do
		result = result + 1
	end

	return result
end

--- Get all available specializations for the given class.
---
--- @param classFileName string
--- @return { [integer]: LibTalentInfo-1.0.Specialization }
function LibTalentInfo:GetSpecializations(classFileName)
	return CopyTable(self:GetSpecializationsInternal(classFileName))
end

--- Get the specialization at the given index, for the given class.
---
--- @param classFileName string
--- @return LibTalentInfo-1.0.Specialization
function LibTalentInfo:GetSpecializationAt(classFileName, index)
	assert(type(index) == "number", "bad argument #2: expected number, got " .. type(index))

	local specializations = self:GetSpecializationsInternal(classFileName)
	local specialization = specializations[index]
	if specialization == nil then
		error("Cannot get unknown specialization at index " .. index)
	end

	return CopyTable(specialization)
end

--- Get the specialization with the given ID, for the given class.
---
--- @param classFileName string
--- @return LibTalentInfo-1.0.Specialization
function LibTalentInfo:GetSpecializataionById(classFileName, id)
	assert(type(id) == "number", "bad argument #2: expected number, got " .. type(id))

	local specializations = self:GetSpecializationsInternal(classFileName)

	for _, specialization in ipairs(specializations) do
		if specialization.id == id then
			return CopyTable(specialization)
		end
	end

	error("Cannot get unknown talent with ID " .. id)
end

--- Get the number of talents available for the given key.
---
--- The key can either be a class ID, or specialization ID, depending on the game version. If specializations exist in the game version, the key should be the
--- specialization ID, otherwise (read: Classic Era), the key should be a class ID.
---
--- @param key integer|string
--- @return integer
function LibTalentInfo:GetNumTalents(key)
	return #self:GetTalentsInternal(key)
end

--- Get all available talents available for the given key.
---
--- The key can either be a class ID, or specialization ID, depending on the game version. If specializations exist in the game version, the key should be the
--- specialization ID, otherwise (read: Classic Era), the key should be a class ID.
---
--- @param key integer|string
--- @return LibTalentInfo-1.0.Talent[]
function LibTalentInfo:GetTalents(key)
	return CopyTable(self:GetTalentsInternal(key))
end

--- Get the talent at the given index for the given key.
---
--- The key can either be a class ID, or specialization ID, depending on the game version. If specializations exist in the game version, the key should be the
--- specialization ID, otherwise (read: Classic Era), the key should be a class ID.
---
--- @param key integer|string
--- @return LibTalentInfo-1.0.Talent
function LibTalentInfo:GetTalentAt(key, index)
	assert(type(index) == "number", "bad argument #2: expected number, got " .. type(index))

	local talents = self:GetTalentsInternal(key)
	local talent = talents[index]
	if talent == nil then
		error("Cannot get unknown talent at index " .. index)
	end

	return CopyTable(talent)
end

--- Get the talent with the given ID for the given key.
---
--- The key can either be a class ID, or specialization ID, depending on the game version. If specializations exist in the game version, the key should be the
--- specialization ID, otherwise (read: Classic Era), the key should be a class ID.
---
--- @param key integer|string
--- @return LibTalentInfo-1.0.Talent
function LibTalentInfo:GetTalentById(key, id)
	assert(type(id) == "number", "bad argument #2: expected number, got " .. type(id))

	local talents = self:GetTalentsInternal(key)

	for _, talent in ipairs(talents) do
		if talent.id == id then
			return CopyTable(talent)
		end
	end

	error("Cannot get unknown talent with ID " .. id)
end

--- Get the number of PvP talents available for the given key.
---
--- The key can either be a class ID, or specialization ID, depending on the game version. If specializations exist in the game version, the key should be the
--- specialization ID, otherwise (read: Classic Era), the key should be a class ID.
---
--- @param key integer|string
--- @return integer
function LibTalentInfo:GetNumPvpTalents(key)
	return #self:GetPvpTalentsInternal(key)
end

--- Get all available PvP talents available for the given key.
---
--- The key can either be a class ID, or specialization ID, depending on the game version. If specializations exist in the game version, the key should be the
--- specialization ID, otherwise (read: Classic Era), the key should be a class ID.
---
--- @param key integer|string
--- @return LibTalentInfo-1.0.Talent[]
function LibTalentInfo:GetPvpTalents(key)
	return CopyTable(self:GetPvpTalentsInternal(key))
end

--- Get the PvP talent at the given index for the given key.
---
--- The key can either be a class ID, or specialization ID, depending on the game version. If specializations exist in the game version, the key should be the
--- specialization ID, otherwise (read: Classic Era), the key should be a class ID.
---
--- @param key integer|string
--- @return LibTalentInfo-1.0.Talent
function LibTalentInfo:GetPvpTalentAt(key, index)
	assert(type(index) == "number", "bad argument #2: expected number, got " .. type(index))

	local talents = self:GetPvpTalentsInternal(key)
	local talent = talents[index]
	if talent == nil then
		error("Cannot get unknown talent at index " .. index)
	end

	return CopyTable(talent)
end

--- Get the PvP talent with the given ID for the given key.
---
--- The key can either be a class ID, or specialization ID, depending on the game version. If specializations exist in the game version, the key should be the
--- specialization ID, otherwise (read: Classic Era), the key should be a class ID.
---
--- @param key integer|string
--- @return LibTalentInfo-1.0.Talent
function LibTalentInfo:GetPvpTalentById(key, id)
	assert(type(id) == "number", "bad argument #2: expected number, got " .. type(id))

	local talents = self:GetPvpTalentsInternal(key)

	for _, talent in ipairs(talents) do
		if talent.id == id then
			return CopyTable(talent)
		end
	end

	error("Cannot get unknown talent with ID " .. id)
end

--- @private
--- @return string[]
function LibTalentInfo:GetClassesInternal()
	if self.provider == nil then
		error("No talent provider registered, register one first using 'SetProvider'.")
	end

	return self.provider.classes
end

--- @private
--- @param classFileName string
--- @return { [integer]: LibTalentInfo-1.0.Specialization }
function LibTalentInfo:GetSpecializationsInternal(classFileName)
	assert(type(classFileName) == "string", "bad argument #1: expected string, got " .. type(classFileName))

	if self.provider == nil then
		error("No talent provider registered, register one first using 'SetProvider'.")
	end

	local specializations = self.provider.specializations[classFileName]
	if specializations == nil then
		error("Cannot get specializations for unknown class '" .. classFileName .. "'")
	end

	return specializations
end

--- @private
--- @param specIdOrClassFileName integer|string
--- @return LibTalentInfo-1.0.Talent[]
function LibTalentInfo:GetTalentsInternal(specIdOrClassFileName)
	assert(tContains({"number", "string"}, type(specIdOrClassFileName)), "bad argument #1: expected number or string, got " .. type(specIdOrClassFileName))

	if self.provider == nil then
		error("No talent provider registered, register one first using 'SetProvider'.")
	end

	local talents = self.provider.talents[specIdOrClassFileName]
	if talents == nil then
		error("Cannot get talents for unknown specialization or class '" .. specIdOrClassFileName .. "'")
	end

	return talents
end

--- @private
--- @param specIdOrClassFileName integer|string
--- @return LibTalentInfo-1.0.Talent[]
function LibTalentInfo:GetPvpTalentsInternal(specIdOrClassFileName)
	assert(tContains({"number", "string"}, type(specIdOrClassFileName)), "bad argument #1: expected number or string, got " .. type(specIdOrClassFileName))

	if self.provider == nil then
		error("No talent provider registered, register one first using 'SetProvider'.")
	end

	local talents = self.provider.pvpTalents[specIdOrClassFileName]
	if talents == nil then
		error("Cannot get PvP talents for unknown specialization or class '" .. specIdOrClassFileName .. "'")
	end

	return talents
end
