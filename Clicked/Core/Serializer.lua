-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2022  Kevin Krol
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

local AceSerializer = LibStub("AceSerializer-3.0")
local LibDeflate = LibStub("LibDeflate")

--- @class ClickedInternal
local Addon = select(2, ...)

-- Local support functions

--- @param data Profile
--- @return boolean status
--- @return string? message
local function ValidateData(data)
	if data.version ~= Addon.DATA_VERSION and not Addon:IsDevelopmentBuild() then
		return false, "Incompatible version: " .. data.version .. " vs. " .. Addon.DATA_VERSION
	end

	if data.bindings == nil or data.groups == nil then
		return false, "Invalid data"
	end

	return true, nil
end

--- @param data table
--- @param printable boolean
--- @return string
local function SerializeTable(data, printable)
	local serialized = AceSerializer:Serialize(data)
	--- @diagnostic disable-next-line: undefined-field
	local compressed = LibDeflate:CompressDeflate(serialized)

	if printable then
		--- @diagnostic disable-next-line: undefined-field
		return LibDeflate:EncodeForPrint(compressed)
	end

	--- @diagnostic disable-next-line: undefined-field
	return LibDeflate:EncodeForWoWAddonChannel(compressed)
end

--- @param data ShareData
local function RegisterGroup(data)
	if data.type ~= "group" then
		error("bad argument #1, expected group but got " .. data.type)
	end

	local bindings = data.group.bindings
	data.group.bindings = nil

	Addon:RegisterGroup(data.group, Addon.BindingScope.PROFILE)

	for _, binding in ipairs(bindings) do
		binding.parent = data.group.identifier
		Addon:RegisterBinding(binding, Addon.BindingScope.PROFILE)
	end
end

--- @param data ShareData
local function RegisterBinding(data)
	if data.type ~= "binding" then
		error("bad argument #1, expected binding but got " .. data.type)
	end

	Addon:RegisterBinding(data.binding, Addon.BindingScope.PROFILE)
end

-- Public addon API

--- Serialize the specified group, including all bindings that are part of the group, and generate a string that can be shared.
---
--- @param group Group
--- @return string
--- @see Clicked#SerializeBinding
--- @see Clicked#Deserialize
function Clicked:SerializeGroup(group)
	assert(type(group) == "table", "bad argument #1, expected table but got " .. type(group))

	--- @type ShareData
	local data = {
		version = Addon.DATA_VERSION,
		type = "group",
		group = Addon:DeepCopyTable(group) --[[@as ShareData.Group]]
	}

	data.group.bindings = Addon:DeepCopyTable(Clicked:GetBindingsInGroup(group.identifier))

	-- Clear user-specific data
	for _, binding in ipairs(data.group.bindings) do
		wipe(binding.integrations)
	end

	return SerializeTable(data, true)
end

--- Serialize the specified binding and generate a string that can be shared.
---
--- @param binding Binding
--- @return string
--- @see Clicked#SerializeGroup
--- @see Clicked#Deserialize
function Clicked:SerializeBinding(binding)
	assert(type(binding) == "table", "bad argument #1, expected table but got " .. type(binding))

	--- @type ShareData
	local data = {
		version = Addon.DATA_VERSION,
		type = "binding",
		binding = Addon:DeepCopyTable(binding)
	}

	-- Clear user-specific data
	wipe(data.binding.integrations)
	data.binding.parent = nil

	return SerializeTable(data, true)
end

--- Deserialize the specifid string into readable data, this is the ingest counterpart of `SerializeGroup` and `SerializeBinding`.
---
--- The deserialization process itself does not actually import the data, it simply makes it readable for a consumer. Use the `Clicked:Import` function to
--- import the deserialized data.
---
--- @param encoded string
--- @return boolean status The resulting decode and deserialize status, `false` if anything went wrong during the deserialization process.
--- @return ShareData|string result A table containing the resulting data, or a `string` with an error message if `status` is `false`.
--- @see Clicked#Import
--- @see Clicked#SerializeBinding
--- @see Clicked#SerializeGroup
function Clicked:Deserialize(encoded)
	--- @diagnostic disable-next-line: undefined-field
	local compressed = LibDeflate:DecodeForPrint(encoded)

	if compressed == nil then
		return false, "Failed to decode"
	end

	--- @diagnostic disable-next-line: undefined-field
	local serialized = LibDeflate:DecompressDeflate(compressed)

	if serialized == nil then
		return false, "Failed to decompress"
	end

	local success, data = AceSerializer:Deserialize(serialized)

	if not success then
		return false, "Failed to deserialize"
	end

	if data.version ~= Addon.DATA_VERSION and not Addon:IsDevelopmentBuild() then
		return false, "Incompatible version: " .. data.version .. " vs. " .. Addon.DATA_VERSION
	end

	return true, data
end

--- Import deserialized data into the addon, this is step two of `Deserialize`.
---
--- @param data ShareData
--- @return boolean
function Clicked:Import(data)
	if data.type == "group" then
		RegisterGroup(data)
		return true
	elseif data.type == "binding" then
		RegisterBinding(data)
		return true
	end

	print("Unknown data type: " .. data.type)
	return false
end

--- Serialize the specified profile and generate a string that can be shared via addon communication channels, or in plaintext format. By default this function
--- will only serialize the `bindings` and `groups` of a profile, however the `full` parameter can be specified to serialize the entire profile, including all
--- user settings.
---
--- @param profile Profile The profile to serialize.
--- @param printable boolean Whether the profile should be serialized in a printable format, `false` if the profile is shared via addon communication channels.
--- @param full boolean Whether the full profile should be serialized, or only a lightweight variant containing no user settings.
--- @return string
--- @see Clicked#DeserializeProfile
function Clicked:SerializeProfile(profile, printable, full)
	assert(type(profile) == "table", "bad argument #1, expected table but got " .. type(profile))
	assert(type(printable == "boolean"), "bad argument #2, expected boolean but got " .. type(printable))
	assert(type(full == "boolean"), "bad argument #3, expected boolean but got " .. type(full))

	local data

	if full then
		--- @type any
		data = Addon:DeepCopyTable(profile)
	else
		-- Construct a lightweight version of the database, only including the version, bindings, and groups.
		-- So any user settings are not serialized (minimap, blacklist, options, etc)
		data = {
			version = profile.version,
			bindings = Addon:DeepCopyTable(profile.bindings),
			groups = Addon:DeepCopyTable(profile.groups),
			nextGroupId = profile.nextGroupId,
			nextBindingId = profile.nextBindingId,
			lightweight = true
		}

		-- Clear user-specific data
		for _, binding in ipairs(data.bindings) do
			wipe(binding.integrations)
		end
	end

	return SerializeTable(data, printable)
end

--- Deserialize a string into a profile, this is the ingest counterpart of `SerializeProfile`.
---
--- @param encoded string The encoded profile string
--- @param printable boolean Whether the input was serialized in a printable format, `false` if the profile was shared via addon communication channels.
--- @return boolean status The resulting decode and deserialize status, `false` if anything went wrong during the deserialization process.
--- @return table|string result A `table` containing the resulting profile data, or a `string` with an error message if `status` is `false`.
--- @return boolean lightweight Whether the imported profile data is lightweight, to prevent lightweight profiles from being imported as a full profile.
--- @see Clicked#SerializeProfile
function Clicked:DeserializeProfile(encoded, printable)
	local compressed

	if printable then
		--- @diagnostic disable-next-line: undefined-field
		compressed = LibDeflate:DecodeForPrint(encoded)
	else
		--- @diagnostic disable-next-line: undefined-field
		compressed = LibDeflate:DecodeForWoWAddonChannel(encoded)
	end

	if compressed == nil then
		return false, "Failed to decode", false
	end

	--- @diagnostic disable-next-line: undefined-field
	local serialized = LibDeflate:DecompressDeflate(compressed)

	if serialized == nil then
		return false, "Failed to decompress", false
	end

	local success, data = AceSerializer:Deserialize(serialized)

	if success then
		local validated, message = ValidateData(data)

		if validated then
			return true, data, false
		end

		return false, "Failed to validate data: " .. message, false
	end

	local lightweight = data.lightweight or false
	data.lightweight = nil

	return success, data, lightweight
end
