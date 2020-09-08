Clicked.COMMAND_ACTION_TARGET = "target"
Clicked.COMMAND_ACTION_MENU = "menu"
Clicked.COMMAND_ACTION_MACRO = "macro"

local macroFrameHandlers = {}

local function GetCommandAttributeIdentifier(command, isClickCastCommand)
	-- separate modifiers from the actual binding
	local prefix, suffix = command.keybind:match("^(.-)([^%-]+)$")
	local buttonIndex = suffix:match("^BUTTON(%d+)$")

	-- remove any trailing dashes (shift- becomes shift, ctrl- becomes ctrl, etc.)
	if prefix:sub(-1, -1) == "-" then
        prefix = prefix:sub(1, -2)
    end
	
	-- convert the parts to lowercase so it fits the attribute naming style
	prefix = prefix:lower()
	suffix = suffix:lower()

	if buttonIndex ~= nil and (isClickCastCommand or buttonIndex ~= nil) then
		suffix = buttonIndex
	elseif buttonIndex ~= nil then
		suffix = "clicked-mouse-" .. tostring(prefix) .. tostring(buttonIndex)
		prefix = ""
	else
		suffix = "clicked-button-" .. tostring(prefix) .. tostring(suffix)
		prefix = ""
	end

	return prefix, suffix, buttonIndex ~= nil
end

local function GetFrame(index)
	if index > #macroFrameHandlers then
		frame = CreateFrame("Button", "ClickedMacroFrameHandler" .. index, UIParent, "SecureActionButtonTemplate")
		table.insert(macroFrameHandlers, frame)
	end

	return macroFrameHandlers[index]
end

-- Note: This is a secure function and may not be called during combat
function Clicked:ProcessCommands(commands)
	if InCombatLockdown() then
		return
	end

	local newClickCastFrameKeybindings = {}
	local newClickCastFrameAttributes = {}
	local nextMacroFrameHandler = 1

	for _, command in ipairs(commands) do
		local isHoverCastBinding = command.mode == self.TARGETING_MODE_HOVERCAST
		local prefix, suffix, isMouseButton = GetCommandAttributeIdentifier(command, isHoverCastBinding)

		if isHoverCastBinding or isMouseButton then
			local keybind = {
				key = command.keybind,
				identifier = suffix
			}

			self:CreateCommandAttributes(newClickCastFrameAttributes, command, prefix, suffix)

			if not isMouseButton then
				table.insert(newClickCastFrameKeybindings, keybind)
			end
		end

		if not isHoverCastBinding then
			local frame = GetFrame(nextMacroFrameHandler)
			local attributes = {}

			nextMacroFrameHandler = nextMacroFrameHandler + 1

			self:CreateCommandAttributes(attributes, command, "", "")
			self:SetPendingFrameAttributes(frame, attributes)
			self:ApplyAttributesToFrame(frame)

			ClearOverrideBindings(frame)
			SetOverrideBindingClick(frame, true, command.keybind, frame:GetName())
		end
	end

	self:UpdateClickCastHeader(newClickCastFrameKeybindings)
	self:UpdateClickCastFrames(newClickCastFrameAttributes)

	for i = nextMacroFrameHandler, #macroFrameHandlers do
		local frame = macroFrameHandlers[i]

		self:ApplyAttributesToFrame(frame)

		ClearOverrideBindings(frame)
	end
end
