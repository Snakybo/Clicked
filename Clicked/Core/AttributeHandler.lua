--- @type ClickedInternal
local _, Addon = ...

local frameCache = {}

-- Local support functions

--- @param frame table
local function EnsureCache(frame)
	if frameCache[frame] ~= nil then
		return
	end

	frameCache[frame] = {
		pending = {},
		applied = {}
	}
end

--- @param register table<string,string>
--- @param prefix string
--- @param type string
--- @param suffix string
--- @param value string
local function CreateAttribute(register, prefix, type, suffix, value)
	prefix = prefix or ""
	suffix = suffix or ""

	if #prefix > 0 then
		prefix = prefix .. "-"
	end

	if #suffix > 0 and tonumber(suffix) == nil then
		suffix = "-" .. suffix
	end

	local key = prefix .. type .. suffix
	register[key] = value
end

-- Private addon API

--- @param frame table
--- @param attributes table<string,string>
function Addon:SetPendingFrameAttributes(frame, attributes)
	if frame == nil then
		return
	end

	EnsureCache(frame)

	for key, value in pairs(attributes) do
		-- Some unit frames use "menu" instead of "togglemenu", an easy way to make sure we use the correct variant is to look at *type2 and check whether that
		-- is set to `menu`. If it is, we use "menu" instead.
		if value == "togglemenu" and frame:GetAttribute("*type2") == "menu" then
			value = "menu"
		end

		frameCache[frame].pending[key] = value
	end
end

--- @param frame table
function Addon:ApplyAttributesToFrame(frame)
	if frame == nil or frameCache[frame] == nil then
		return
	end

	local applied = frameCache[frame].applied
	local pending = frameCache[frame].pending

	frameCache[frame].applied = frameCache[frame].pending
	frameCache[frame].pending = {}

	for key in pairs(applied) do
		frame:SetAttribute(key, nil)
	end

	if not Addon:IsFrameBlacklisted(frame) then
		for key, value in pairs(pending) do
			frame:SetAttribute(key, value)
		end
	end
end

--- @param register table<string,string>
--- @param command Command
--- @param prefix string
--- @param suffix string
function Addon:CreateCommandAttributes(register, command, prefix, suffix)
	if command.keybind == "" then
		return
	end

	if command.action == Addon.CommandType.TARGET then
		CreateAttribute(register, prefix, "type", suffix, "target")
	elseif command.action == Addon.CommandType.MENU then
		CreateAttribute(register, prefix, "type", suffix, "togglemenu")
	elseif command.action == Addon.CommandType.MACRO then
		CreateAttribute(register, prefix, "type", suffix, "macro")
		CreateAttribute(register, prefix, "macrotext", suffix, command.data)
	else
		error("Unhandled action type: " .. command.action)
	end
end
