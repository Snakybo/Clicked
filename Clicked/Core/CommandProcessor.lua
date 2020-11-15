Clicked.STOP_CASTING_BUTTON_NAME = "ClickedStopCastingButton"
Clicked.MACRO_FRAME_HANDLER_NAME = "ClickedMacroFrameHandler"

Clicked.EVENT_MACRO_ATTRIBUTES_CREATED = "CLICKED_MACRO_ATTRIBUTES_CREATED"
Clicked.EVENT_HOVERCAST_ATTRIBUTES_CREATED = "CLICKED_HOVERCAST_ATTRIBUTES_CREATED"

local macroFrameHandler
local stopCastingButton

local function GetCommandAttributeIdentifier(command, hovercast)
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

	if buttonIndex ~= nil and hovercast then
		suffix = buttonIndex
	elseif buttonIndex ~= nil then
		suffix = "clicked-mouse-" .. tostring(prefix) .. tostring(buttonIndex)
		prefix = ""
	else
		suffix = "clicked-button-" .. tostring(prefix) .. tostring(suffix)
		prefix = ""
	end

	return prefix, suffix
end

local function CreateStateDriverAttribute(frame, state, condition)
	frame:SetAttribute("_onstate-" .. state, [[
		if not self:IsShown() then
			return
		end

		if newstate == "enabled" then
			self:RunAttribute("clicked-clear-bindings")
		else
			self:RunAttribute("clicked-register-bindings")
		end
	]])

	RegisterStateDriver(frame, state, condition)
end

local function EnsureStopCastingButton()
	if stopCastingButton ~= nil then
		return
	end

	stopCastingButton = CreateFrame("Button", Clicked.STOP_CASTING_BUTTON_NAME, nil, "SecureActionButtonTemplate")
	stopCastingButton:SetAttribute("type", "stop")
end

local function EnsureMacroFrameHandler()
	if macroFrameHandler ~= nil then
		return
	end

	macroFrameHandler = CreateFrame("Button", Clicked.MACRO_FRAME_HANDLER_NAME, UIParent, "SecureActionButtonTemplate,SecureHandlerStateTemplate,SecureHandlerShowHideTemplate")
	macroFrameHandler:Hide()

	-- set required data first
	macroFrameHandler:SetAttribute("clicked-keybinds", "")
	macroFrameHandler:SetAttribute("clicked-identifiers", "")

	-- register OnShow and OnHide handlers to ensure bindings are registered
	macroFrameHandler:SetAttribute("_onshow", [[
		self:RunAttribute("clicked-register-bindings")
	]])

	macroFrameHandler:SetAttribute("_onhide", [[
		self:RunAttribute("clicked-clear-bindings")
	]])

	-- attempt to register a binding, this will also check if the binding
	-- is currently allowed to be active (e.g. not in a vehicle or pet battle)
	macroFrameHandler:SetAttribute("clicked-register-bindings", [[
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

		local keybinds = self:GetAttribute("clicked-keybinds")
		local identifiers = self:GetAttribute("clicked-identifiers")

		if strlen(keybinds) > 0 then
			keybinds = table.new(strsplit("\001", keybinds))
			identifiers = table.new(strsplit("\001", identifiers))

			for i = 1, table.maxn(keybinds) do
				local keybind = keybinds[i]
				local identifier = identifiers[i]

				self:SetBindingClick(true, keybind, self, identifier)
			end
		end
	]])

	-- unregister a binding
	macroFrameHandler:SetAttribute("clicked-clear-bindings", [[
		local keybinds = self:GetAttribute("clicked-keybinds")

		if strlen(keybinds) > 0 then
			keybinds = table.new(strsplit("\001", keybinds))

			for i = 1, table.maxn(keybinds) do
				local keybind = keybinds[i]
				self:ClearBinding(keybind)
			end
		end
	]])

	if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
		CreateStateDriverAttribute(macroFrameHandler, "vehicle", "[@vehicle,exists] enabled; disabled")
		CreateStateDriverAttribute(macroFrameHandler, "vehicleui", "[vehicleui] enabled; disabled")
		CreateStateDriverAttribute(macroFrameHandler, "petbattle", "[petbattle] enabled; disabled")
	end

	CreateStateDriverAttribute(macroFrameHandler, "possessbar", "[possessbar] enabled; disabled")

	-- Enable unit frame clicks
	Clicked:RegisterFrameClicks(macroFrameHandler)
end

local function GetMacroIdentifier(keybind, keybinds, identifiers)
	for i, key in ipairs(keybinds) do
		if key == keybind then
			return identifiers[i]
		end
	end

	return nil
end

-- Note: This is a secure function and may not be called during combat
function Clicked:ProcessCommands(commands)
	if InCombatLockdown() then
		return
	end

	local newClickCastFrameKeybinds = {}
	local newClickCastFrameAttributes = {}

	local newMacroFrameHandlerKeybinds = {}
	local newMacroFrameHandlerIdentifiers = {}
	local newMacroFrameHandlerAttributes = {}

	EnsureStopCastingButton()
	EnsureMacroFrameHandler()

	-- Unregister all current keybinds
	macroFrameHandler:Hide()

	-- First, process all non-hovercast commands so we can build a table
	-- which can map frame handlers to keybinds. This is required in order
	-- to not "consume" keybinds if a hovercast binding is set to only activate
	-- on a friendly unit and you press it on an enemy unit. We append a /click <framehandler>
	-- command as a fallback so it continues to work.

	for _, command in ipairs(commands) do
		if not command.hovercast and not command.virtual then
			local prefix, suffix = GetCommandAttributeIdentifier(command, false)

			local attributes = {}

			self:CreateCommandAttributes(attributes, command, prefix, suffix)
			self:SendMessage(self.EVENT_MACRO_ATTRIBUTES_CREATED, command, attributes)

			for attribute, value in pairs(attributes) do
				newMacroFrameHandlerAttributes[attribute] = value
			end

			table.insert(newMacroFrameHandlerKeybinds, command.keybind)
			table.insert(newMacroFrameHandlerIdentifiers, suffix)

			-- dynamically assign the identifier, for debugging
			command.identifier = suffix
		end
	end

	-- Second, process all hovercast commands with the database built above, this
	-- allows us to "remap" hovercast bindings to regular bindings if their macro
	-- conditionals are not met (i.e. a binding that only activates on `[help]` but
	-- you're hovering over a `[harm]` target). In this case we append a `/stopmacro [help]`
	-- followed by a `/click` command to virtually click the macro frame handler.
	--
	-- Additionally in the case of "virtual hovercast" bindings which are generated when a mouse
	-- button is set to the `[@mouseover]` target, we don't have any pre-build data for the command,
	-- so a virtual hovercast binding will only serve the purpose of virtually clicking the
	-- regular macro frame handler.

	for _, command in ipairs(commands) do
		if command.hovercast then
			local prefix, suffix = GetCommandAttributeIdentifier(command, command.hovercast)

			local attributes = {}
			local macroTarget = GetMacroIdentifier(command.keybind, newMacroFrameHandlerKeybinds, newMacroFrameHandlerIdentifiers)
			local keybind = {
				key = command.keybind,
				identifier = suffix
			}

			if macroTarget ~= nil then
				local onKeyDown = tostring(Clicked.db.profile.options.onKeyDown)
				local virtualClickCommand = string.format("/click %s %s %s", Clicked.MACRO_FRAME_HANDLER_NAME, macroTarget, onKeyDown)

				if Clicked:IsStringNilOrEmpty(command.data) then
					command.data = virtualClickCommand
				else
					local data = { command.data }

					table.insert(data, "/stopmacro " .. table.concat(command.macroFlags))
					table.insert(data, virtualClickCommand)

					command.data = table.concat(data, "\n")
				end
			end

			self:CreateCommandAttributes(attributes, command, prefix, suffix)
			self:SendMessage(self.EVENT_MACRO_ATTRIBUTES_CREATED, command, attributes)

			for attribute, value in pairs(attributes) do
				if newClickCastFrameAttributes[attribute] ~= nil then
					if not command.virtual then
						newClickCastFrameAttributes[attribute] = value
					end
				else
					newClickCastFrameAttributes[attribute] = value
				end
			end

			table.insert(newClickCastFrameKeybinds, keybind)
		end
	end

	self:SetPendingFrameAttributes(macroFrameHandler, newMacroFrameHandlerAttributes)
	self:ApplyAttributesToFrame(macroFrameHandler)

	macroFrameHandler:SetAttribute("clicked-keybinds", table.concat(newMacroFrameHandlerKeybinds, "\001"))
	macroFrameHandler:SetAttribute("clicked-identifiers", table.concat(newMacroFrameHandlerIdentifiers, "\001"))
	macroFrameHandler:Show()

	self:SendMessage(self.EVENT_HOVERCAST_ATTRIBUTES_CREATED, newClickCastFrameKeybinds, newClickCastFrameAttributes)

	self:UpdateClickCastHeader(newClickCastFrameKeybinds)
	self:UpdateClickCastFrames(newClickCastFrameAttributes)
end
