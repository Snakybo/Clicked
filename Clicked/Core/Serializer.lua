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
		binding.parent = data.group.uid
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

--- @param data ExportProfile
local function RegisterProfile(data)
	if not data.lightweight then
		Addon.db.profile = wipe(Addon.db.profile)
	end

	data.lightweight = nil
	data.type = nil

	for key in pairs(data) do
		Addon.db.profile[key] = data[key]
	end

	Clicked:ReloadDatabase()
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

	data.group.bindings = Addon:DeepCopyTable(Clicked:GetBindingsInGroup(group.uid))

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

--- Serialize the specified profile and generate a string that can be shared via addon communication channels, or in plaintext format. By default this function
--- will only serialize the `bindings` and `groups` of a profile, however the `full` parameter can be specified to serialize the entire profile, including all
--- user settings.
---
--- @param profile Profile The profile to serialize.
--- @param printable boolean Whether the profile should be serialized in a printable format, `false` if the profile is shared via addon communication channels.
--- @param full boolean Whether the full profile should be serialized, or only a lightweight variant containing no user settings.
--- @return string
--- @see Clicked#Deserialize
function Clicked:SerializeProfile(profile, printable, full)
	assert(type(profile) == "table", "bad argument #1, expected table but got " .. type(profile))
	assert(type(printable == "boolean"), "bad argument #2, expected boolean but got " .. type(printable))
	assert(type(full == "boolean"), "bad argument #3, expected boolean but got " .. type(full))

	local data

	if full then
		--- @type Profile
		data = Addon:DeepCopyTable(profile)
		data.type = "profile"
		data.lightweight = false
	else
		-- Construct a lightweight version of the database, only including the version, bindings, and groups.
		-- So any user settings are not serialized (minimap, blacklist, options, etc)
		--- @type ExportProfile
		data = {
			version = profile.version,
			bindings = Addon:DeepCopyTable(profile.bindings),
			groups = Addon:DeepCopyTable(profile.groups),
			nextGroupId = profile.nextGroupId,
			nextBindingId = profile.nextBindingId,
			type = "profile",
			lightweight = true
		}

		-- Clear user-specific data
		for _, binding in ipairs(data.bindings) do
			wipe(binding.integrations)
		end
	end

	return SerializeTable(data, printable)
end

--- Deserialize the specifid string into readable data, this is the ingest counterpart of `SerializeGroup` and `SerializeBinding`.
---
--- The deserialization process itself does not actually import the data, it simply makes it readable for a consumer. Use the `Clicked:Import` function to
--- import the deserialized data.
---
--- @param encoded string
--- @param printable boolean
--- @return boolean status The resulting decode and deserialize status, `false` if anything went wrong during the deserialization process.
--- @return ShareData|ExportProfile|string result A table containing the resulting data, or a `string` with an error message if `status` is `false`.
--- @see Clicked#Import
--- @see Clicked#SerializeBinding
--- @see Clicked#SerializeGroup
function Clicked:Deserialize(encoded, printable)
	local compressed

	if printable then
		--- @diagnostic disable-next-line: undefined-field
		compressed = LibDeflate:DecodeForPrint(encoded)
	else
		--- @diagnostic disable-next-line: undefined-field
		compressed = LibDeflate:DecodeForWoWAddonChannel(encoded)
	end

	if compressed == nil then
		return false, Addon.L["Failed to decode"]
	end

	--- @diagnostic disable-next-line: undefined-field
	local serialized = LibDeflate:DecompressDeflate(compressed)

	if serialized == nil then
		return false, Addon.L["Failed to decompress"]
	end

	local success, data = AceSerializer:Deserialize(serialized)

	if not success then
		return false, Addon.L["Failed to deserialize"]
	end

	if data.version ~= Addon.DATA_VERSION and not Addon:IsDevelopmentBuild() then
		return false, "Incompatible version: " .. data.version .. " vs. " .. Addon.DATA_VERSION
	end

	return true, data
end

--- Import deserialized data into the addon, this is step two of `Deserialize`.
---
--- @param data ShareData|ExportProfile
--- @return boolean
function Clicked:Import(data)
	if data.type == "group" then
		--- @cast data ShareData
		RegisterGroup(data)
		return true
	elseif data.type == "binding" then
		--- @cast data ShareData
		RegisterBinding(data)
		return true
	elseif data.type == "profile" then
		--- @cast data ExportProfile
		RegisterProfile(data)
		return true
	end

	print("Unknown data type: " .. data.type)
	return false
end
