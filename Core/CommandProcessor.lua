Clicked.COMMAND_ACTION_TARGET = "target"
Clicked.COMMAND_ACTION_MENU = "menu"
Clicked.COMMAND_ACTION_MACRO = "macro"

local macroFrameHandlers = {}

-- Note: This is a secure function and may not be called during combat
function Clicked:ProcessCommands(commands)
	if InCombatLockdown() then
		return
	end
	
	local newClickCastAttributes = {}
	local nextMacroFrameHandler = 1
	
	for _, command in ipairs(commands) do
		if self:StartsWith(command.keybind, "BUTTON") then
			local buttonIndex = command.keybind:match("^BUTTON(%d+)$")
			self:CreateCommandAttributes(newClickCastAttributes, command, buttonIndex)
		end

		if not self:IsRestrictedKeybind(command.keybind) then
			local frame

			if nextMacroFrameHandler > #macroFrameHandlers then
				frame = CreateFrame("Button", "ClickedMacroFrameHandler" .. nextMacroFrameHandler, UIParent, "SecureActionButtonTemplate")
				table.insert(macroFrameHandlers, frame)
			else
				frame = macroFrameHandlers[nextMacroFrameHandler]
			end
			
			nextMacroFrameHandler = nextMacroFrameHandler + 1

			local target = frame:GetName()
			local attributes = {}
			
			self:CreateCommandAttributes(attributes, command, "")
			self:ApplyAttributesToFrame(frame.clickedRegisteredAttributes, attributes, frame)

			frame.clickedRegisteredAttributes = attributes

			ClearOverrideBindings(frame)
			SetOverrideBindingClick(frame, false, command.keybind, target)
		end
	end
	
	self:UpdateClickCastAttributes(newClickCastAttributes)

	for i = nextMacroFrameHandler, #macroFrameHandlers do
		local frame = macroFrameHandlers[i]

		self:ApplyAttributesToFrame(frame.clickedRegisteredAttributes, nil, frame)
		frame.clickedRegisteredAttributes = nil
		
		ClearOverrideBindings(frame)
	end
end