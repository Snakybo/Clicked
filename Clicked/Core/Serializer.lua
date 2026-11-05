-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2026 Kevin Krol
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

--- @class Addon
local Addon = select(2, ...)

local logger = Clicked:CreateSystemLogger("Serializer")

-- Local support functions

--- @param data DataExport
--- @param binary? boolean
--- @return boolean, string
local function SerializeTable(data, binary)
	local result = C_EncodingUtil.SerializeCBOR(data)
	if result == nil then
		return false, Addon.L["Failed to serialize"]
	end

	result = C_EncodingUtil.CompressString(result, Enum.CompressionMethod.Deflate, Enum.CompressionLevel.OptimizeForSize)
	if result == nil then
		return false, Addon.L["Failed to compress"]
	end

	if not binary then
		result = C_EncodingUtil.EncodeBase64(result)
		if result == nil then
			return false, Addon.L["Failed to encode"]
		end
	end

	return true, result
end

--- @param original Group
--- @return Group
local function RegisterGroup(original)
	local copy = CopyTable(original) --[[@as Group]]
	copy.uid = nil

	Addon:RegisterDataObject(copy, Clicked.DataObjectScope.PROFILE)

	return copy
end

--- @param original Binding
--- @return Binding
local function RegisterBinding(original)
	local copy = CopyTable(original) --[[@as Binding]]
	copy.uid = nil

	Addon:RegisterDataObject(copy, Clicked.DataObjectScope.PROFILE)
	Addon:ReloadBinding(copy, true)

	return copy
end

-- Public addon API

--- @enum ImportFlags
Clicked.ImportFlags = {
	OVERWRITE = 1,
	ADDON_OPTIONS = 2,
	KEYBINDS = 4,
	BINDINGS = 8,
}

--- Serialize the specified data object and generate a string that can be shared.
---
--- @param obj DataObject
--- @return boolean, string
function Clicked:SerializeDataObject(obj)
	assert(type(obj) == "table", "bad argument #1, expected table but got " .. type(obj))

	logger:LogDebug("Serializing data object of type {type#DataObjectType}", obj.type)

	--- @type DataExport
	local data = {
		version = Addon.DATA_VERSION,
		bindings = {},
		groups = {}
	}

	if obj.type == Clicked.DataObjectType.BINDING then
		--- @cast obj Binding
		data.bindings[1] = obj
	elseif obj.type == Clicked.DataObjectType.GROUP then
		--- @cast obj Group
		data.groups[1] = obj
		data.bindings = Clicked:GetByParent(obj.uid)

		logger:LogDebug("Serializing {numChildren} children for group", #data.bindings)
	end

	return SerializeTable(data)
end

--- Serialize the specified profile and generate a string that can be shared via addon communication channels, or in plaintext format.
---
--- @param profile DBSchema.Profile|DBSchema.Global
--- @param binary? boolean
--- @return boolean, string
function Clicked:SerializeProfile(profile, binary)
	assert(type(profile) == "table", "bad argument #1, expected table but got " .. type(profile))
	assert(type(binary == "boolean"), "bad argument #2, expected boolean but got " .. type(binary))

	logger:LogDebug("Serializing profile with {numBindings} bindings and {numGroups} groups", #profile.bindings, #profile.groups)

	--- @type DataExport
	local data = {
		version = profile.version,
		bindings = profile.bindings,
		groups = profile.groups,
		isProfile = true
	}

	if profile.options ~= nil then
		logger:LogDebug("Serializing addon options")

		data.options = profile.options
		data.keyVisualizer = profile.keyVisualizer
		data.logLevel = profile.logLevel
		data.blacklist = profile.blacklist
	end

	return SerializeTable(data, binary)
end

--- @param data string
--- @param binary? boolean
--- @return (true, DataExport) | (false, string)
function Clicked:Deserialize(data, binary)
	--- @type boolean
	local success

	--- @type string
	local input = data

	--- @type DataExport?|string
	local result

	if not binary then
		success, input = pcall(C_EncodingUtil.DecodeBase64, input)
		if not success then
			return false, Addon.L["Failed to decode"]
		end
	end

	success, input = pcall(C_EncodingUtil.DecompressString, input)
	if not success then
		return false, Addon.L["Failed to decompress"]
	end

	success, result = pcall(C_EncodingUtil.DeserializeCBOR, input)
	if not success then
		return false, Addon.L["Failed to deserialize"]
	end

	--- @cast result DataExport

	return true, result
end

--- @param data DataExport
--- @param flags? ImportFlags
--- @return (true, table<integer, integer>) | (false, string)
function Clicked:Import(data, flags)
	if data.version ~= Addon.DATA_VERSION and not Addon:IsDevelopmentBuild() then
		return false, "Incompatible version: " .. data.version .. " vs. " .. Addon.DATA_VERSION
	end

	--- @type table<integer, integer>
	local uidRemap = {}

	flags = flags or 0

	if data.options ~= nil and bit.band(flags, Clicked.ImportFlags.ADDON_OPTIONS) ~= 0 then
		logger:LogDebug("Importing addon options")

		Addon.db.global.options = data.options
		Addon.db.global.keyVisualizer = data.keyVisualizer
		Addon.db.global.logLevel = data.logLevel
		Addon.db.global.blacklist = data.blacklist

		self:ReloadDatabase()
	end

	if bit.band(flags, Clicked.ImportFlags.BINDINGS) ~= 0 then
		logger:LogDebug("Importing {numGroups} groups and {numBindings} bindings", #data.groups, #data.bindings)

		if bit.band(flags, Clicked.ImportFlags.OVERWRITE) ~= 0 then
			logger:LogDebug("Overwriting current profile")

			wipe(Addon.db.profile.groups)
			wipe(Addon.db.profile.bindings)
		end

		if bit.band(flags, Clicked.ImportFlags.KEYBINDS) ~= 0 then
			logger:LogDebug("Importing keybinds")
		end

		for _, group in ipairs(data.groups) do
			local imported = RegisterGroup(group)
			uidRemap[group.uid] = imported.uid
		end

		for _, binding in ipairs(data.bindings) do
			if binding.parent ~= nil then
				binding.parent = uidRemap[binding.parent] ~= nil and uidRemap[binding.parent] or nil
			end

			if bit.band(flags, Clicked.ImportFlags.KEYBINDS) == 0 then
				binding.keybind = ""
			end

			local imported = RegisterBinding(binding)
			uidRemap[binding.uid] = imported.uid
		end
	end

	return true, uidRemap
end
