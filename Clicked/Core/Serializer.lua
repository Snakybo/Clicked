local AceSerializer = LibStub("AceSerializer-3.0")
local LibDeflate = LibStub("LibDeflate")

local function ValidateData(data)
	if data.version ~= Clicked.VERSION then
		return false, "Incompatible version: " .. data.version
	end

	if data.bindings == nil or data.groups == nil then
		return false, "Invalid data"
	end

	return true, nil
end

--- Serialize a profile into a serialized string.
--- @see DeserializeProfile
---
--- @param data table
--- @param printable boolean
--- @return string
function Clicked:SerializeTable(data, printable)
	local serialized = AceSerializer:Serialize(data)
	local compressed = LibDeflate:CompressDeflate(serialized)

	if printable then
		return LibDeflate:EncodeForPrint(compressed)
	end

	return LibDeflate:EncodeForWoWAddonChannel(compressed)
end

--- Serialize the current profile into a serialized string.
--- @see SerializeProfile
--- @see DeserializeProfile
---
--- @param printable boolean
--- @return string
function Clicked:SerializeCurrentProfile(printable)
	return self:SerializeTable(Clicked.db.profile, printable)
end

function Clicked:SerializeCurrentProfileBindings(printable)
	-- Construct a lightweight version of the database, only including the version, bindings, and groups.
	-- So any user settings are not serialized (minimap, blacklist, options, etc)
	local data = {
		version = Clicked.db.profile.version,
		bindings = Clicked.db.profile.bindings,
		groups = Clicked.db.profile.groups
	}

	return self:SerializeTable(data, printable)
end

--- Deserialize a string into a profile
--- @see SerializeProfile
---
--- @param string string
--- @return string
--- @return any
function Clicked:DeserializeString(encoded, printable)
	local compressed

	if printable then
		compressed = LibDeflate:DecodeForPrint(encoded)
	else
		compressed = LibDeflate:DecodeForWoWAddonChannel(encoded)
	end

	if compressed == nil then
		return false, "Failed to decode"
	end

	local serialized = LibDeflate:DecompressDeflate(compressed)

	if serialized == nil then
		return false, "Failed to decompress"
	end

	local success, data = AceSerializer:Deserialize(serialized)

	if success then
		local validated, message = ValidateData(data)

		if validated then
			return true, data
		end

		return false, "Failed to validate data: " .. message
	end

	return success, data
end
