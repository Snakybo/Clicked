Clicked.STOP_CASTING_BUTTON_NAME = "ClickedStopCastingButton"

Clicked.EVENT_MACRO_ATTRIBUTES_CREATED = "CLICKED_MACRO_ATTRIBUTES_CREATED"
Clicked.EVENT_HOVERCAST_ATTRIBUTES_CREATED = "CLICKED_HOVERCAST_ATTRIBUTES_CREATED"

local macroFrameHandlers = {}
local stopCastingButton

local function GetCommandAttributeIdentifier(command, isClickCastCommand)
	-- separate modifiers from the actual binding
	local prefix, suffix = string.match(command.keybind, "^(.-)([^%-]+)$")
	local buttonIndex = string.match(suffix, "^BUTTON(%d+)$")

	-- remove any trailing dashes (shift- becomes shift, ctrl- becomes ctrl, etc.)
	if string.sub(prefix, -1, -1) == "-" then
		prefix = string.sub(prefix, 1, -2)
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

local function CreateStateDriverAttribute(frame, state, condition)
	frame:SetAttribute("_onstate-" .. state, [[
		if newstate == "enabled" then
			self:RunAttribute("clicked-clear-binding")
		else
			self:RunAttribute("clicked-register-binding")
		end
	]])

	RegisterStateDriver(frame, state, condition)
end

local function GetFrameHandler(index)
	if index > #macroFrameHandlers then
		local frame = CreateFrame("Button", "ClickedMacroFrameHandler" .. index, UIParent, "SecureActionButtonTemplate,SecureHandlerStateTemplate,SecureHandlerShowHideTemplate")
		frame:Hide()

		-- set required data first
		frame:SetAttribute("clicked-keybind", "")

		-- register OnShow and OnHide handlers to ensure bindings are registered
		frame:SetAttribute("_onshow", [[ self:RunAttribute("clicked-register-binding") ]])
		frame:SetAttribute("_onhide", [[ self:RunAttribute("clicked-clear-binding") ]])

		-- attempt to register a binding, this will also check if the binding
		-- is currently allowed to be active (e.g. not in a vehicle or pet battle)
		frame:SetAttribute("clicked-register-binding", [[
			if not self:IsShown() then
				return
			end

			if self:GetAttribute("state-petbattle") == "enabled" then
				return
			end

			if self:GetAttribute("state-vehicle") == "enabled" or self:GetAttribute("state-vehicleui") == "enabled" then
				return
			end

			if self:GetAttribute("state-possessbar") == "enabled" then
				return
			end


			local keybind = self:GetAttribute("clicked-keybind")
			local identifier = self:GetAttribute("clicked-identifier")

			self:SetBindingClick(true, keybind, self, identifier)
		]])

		-- unregister a binding
		frame:SetAttribute("clicked-clear-binding", [[
			local keybind = self:GetAttribute("clicked-keybind")
			self:ClearBinding(keybind)
		]])

		if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
			CreateStateDriverAttribute(frame, "vehicle", "[@vehicle,exists] enabled; disabled")
			CreateStateDriverAttribute(frame, "vehicleui", "[vehicleui] enabled; disabled")
			CreateStateDriverAttribute(frame, "petbattle", "[petbattle] enabled; disabled")
		end

		CreateStateDriverAttribute(frame, "possessbar", "[possessbar] enabled; disabled")

		Clicked:RegisterFrameClicks(frame)

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

	if stopCastingButton == nil then
		stopCastingButton = CreateFrame("Button", self.STOP_CASTING_BUTTON_NAME, nil, "SecureActionButtonTemplate")
		stopCastingButton:SetAttribute("type", "stop")
	end

	for _, command in ipairs(commands) do
		local prefix, suffix, isMouseButton = GetCommandAttributeIdentifier(command, command.hovercast)

		if command.hovercast or isMouseButton then
			local keybind = {
				key = command.keybind,
				identifier = suffix
			}

			local attributes = {}

			self:CreateCommandAttributes(attributes, command, prefix, suffix)
			self:SendMessage(self.EVENT_MACRO_ATTRIBUTES_CREATED, command, attributes)

			for attribute, value in pairs(attributes) do
				newClickCastFrameAttributes[attribute] = value
			end

			if not isMouseButton then
				table.insert(newClickCastFrameKeybindings, keybind)
			end
		end

		if not command.hovercast then
			local frame = GetFrameHandler(nextMacroFrameHandler)
			local attributes = {}

			nextMacroFrameHandler = nextMacroFrameHandler + 1

			frame:Hide()

			self:CreateCommandAttributes(attributes, command, prefix, suffix)
			self:SendMessage(self.EVENT_MACRO_ATTRIBUTES_CREATED, command, attributes)
			self:SetPendingFrameAttributes(frame, attributes)
			self:ApplyAttributesToFrame(frame)

			frame:SetAttribute("clicked-keybind", command.keybind)
			frame:SetAttribute("clicked-identifier", suffix)
			frame:Show()
		end
	end

	self:SendMessage(self.EVENT_HOVERCAST_ATTRIBUTES_CREATED, newClickCastFrameKeybindings, newClickCastFrameAttributes)

	self:UpdateClickCastHeader(newClickCastFrameKeybindings)
	self:UpdateClickCastFrames(newClickCastFrameAttributes)

	for i = nextMacroFrameHandler, #macroFrameHandlers do
		local frame = macroFrameHandlers[i]

		frame:Hide()
		frame:SetAttribute("clicked-keybind", "")

		self:ApplyAttributesToFrame(frame)
	end
end

function Clicked:IterateMacroHandlerFrames()
	return ipairs(macroFrameHandlers)
end
