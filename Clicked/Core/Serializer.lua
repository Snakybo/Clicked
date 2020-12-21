local AceSerializer = LibStub("AceSerializer-3.0")
local LibDeflate = LibStub("LibDeflate")

local function ValidateData(data)
	if data.version ~= Clicked.VERSION then
		return false, "Incompatible version: " .. data.version
	end

	return true, nil
end

--- Serialize a profile into a serialized string.
--- @see DeserializeProfile
---
--- @param profile table
--- @param printable boolean
--- @return string
function Clicked:SerializeProfile(profile, printable)
	local serialized = AceSerializer:Serialize(profile)
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
	return self:SerializeProfile(Clicked.db.profile, printable)
end

--- Deserialize a string into a profile
--- @see SerializeProfile
---
--- @param string string
--- @return string
--- @return any
function Clicked:DeserializeProfile(encoded, printable)
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
