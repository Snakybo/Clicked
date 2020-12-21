local AceSerializer = LibStub("AceSerializer-3.0")
local LibCompress = LibStub("LibCompress")

local base64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

-- From http://lua-users.org/wiki/BaseSixtyFour
local function Encode(data)
	return ((data:gsub(".", function(x)
        local r, b = "", x:byte()

		for i = 8, 1, -1 do
			r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and "1" or "0")
		end

        return r
    end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
		if #x < 6 then
			return ""
		end

		local c=0

		for i = 1, 6 do
			c = c + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0)
		end

        return base64:sub(c+1,c+1)
    end) .. ({ "", "==", "=" })[#data % 3 + 1])
end

local function Decode(data)
	data = string.gsub(data, "[^" .. base64 .. "=]", "")

    return (data:gsub(".", function(x)
		if x == "=" then
			return ""
		end

		local r, f = "", base64:find(x) - 1

		for i = 6, 1, -1 do
			r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and "1" or "0")
		end

        return r
    end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
		if #x ~= 8 then
			return ""
		end

		local c = 0

		for i = 1, 8 do
			c = c + (x:sub(i, i) == "1" and 2 ^ (8 - i) or 0)
		end

        return string.char(c)
    end))
end

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
--- @return string
function Clicked:SerializeProfile(profile)
	local serialized = AceSerializer:Serialize(profile)
	local compressed = LibCompress:Compress(serialized)
	local encoded = Encode(compressed)

	if encoded == nil then
		return "Failed to serialize profile"
	end

	return encoded
end

--- Serialize the current profile into a serialized string.
--- @see SerializeProfile
--- @see DeserializeProfile
---
--- @return string
function Clicked:SerializeCurrentProfile()
	return self:SerializeProfile(Clicked.db.profile)
end

--- Deserialize a string into a profile
--- @see SerializeProfile
---
--- @param string string
--- @return string
--- @return any
function Clicked:DeserializeProfile(string)
	local compressed = Decode(string)

	if compressed == nil then
		return false, "Failed to decode"
	end

	local serialized, error = LibCompress:Decompress(compressed)

	if serialized == nil then
		return false, "Failed to decompress: " .. error
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
