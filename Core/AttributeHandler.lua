local frameCache = {}

local function EnsureCache(frame)
	if frameCache[frame] ~= nil then
		return
	end

	frameCache[frame] = {
		pending = {},
		applied = {}
	}
end

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

function Clicked:SetPendingFrameAttributes(frame, attributes)
	if frame == nil then
		return
	end

	EnsureCache(frame)

	for key, value in pairs(attributes) do
		-- Some unit frames use "togglemenu" instead of "menu",
		-- so to ensure both work convert the value to whatever is
		-- bound to *type2
		if value == "menu" then
			value = frame:GetAttribute("*type2")
		end

		frameCache[frame].pending[key] = value
	end
end

function Clicked:ApplyAttributesToFrame(frame)
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

	if not Clicked:IsFrameBlacklisted(frame) then
		for key, value in pairs(pending) do
			frame:SetAttribute(key, value)
		end
	end
end

function Clicked:CreateCommandAttributes(register, command, prefix, suffix)
	if command.keybind == "" then
		return
	end

	if command.action == Clicked.CommandType.TARGET then
		CreateAttribute(register, prefix, "type", suffix, "target")
	elseif command.action == Clicked.CommandType.MENU then
		CreateAttribute(register, prefix, "type", suffix, "menu")
	elseif command.action == Clicked.CommandType.MACRO then
		CreateAttribute(register, prefix, "type", suffix, "macro")
		CreateAttribute(register, prefix, "macrotext", suffix, command.data)
	else
		error("Unhandled action type: " .. command.action)
	end
end
