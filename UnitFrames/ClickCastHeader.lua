Clicked.ClickCastHeader = nil

local function SetupKeybindCommands(keybindings)
	local register = {}
	local unregister = {}

	local setTemplate = "self:SetBindingClick(true, %q, self, %q)"
	local clearTemplate = "self:ClearBinding(%q)"

	for _, keybind in ipairs(keybindings) do
		local set = setTemplate:format(keybind.key, keybind.identifier)
		local clear = clearTemplate:format(keybind.key)
		
		table.insert(register, set)
		table.insert(unregister, clear)
	end

	return table.concat(register, "\n"), table.concat(unregister, "\n")
end

function Clicked:RegisterClickCastHeader()
	if GetAddOnEnableState(UnitName("player"), "Clique") == 2 then
		self:ShowAddonIncompatibilityPopup("Clique")
		return
	end

	-- Keep most of the same setup structure as Clique to ensure that oUF
	-- and all "oUF-like" addons will work

	self.ClickCastHeader = CreateFrame("Frame", "ClickedClickCastHeaderFrame", UIParent, "SecureHandlerBaseTemplate,SecureHandlerAttributeTemplate")
	ClickCastHeader = self.ClickCastHeader

	Clique = {}
	Clique.header = self.ClickCastHeader
	Clique.UpdateRegisteredClicks = Clicked.RegisterClickCastFrameClicks

	self.ClickCastHeader:SetAttribute("setup-keybinds", "")
	self.ClickCastHeader:SetAttribute("clear-keybinds", "")

	self.ClickCastHeader:SetAttribute("clickcast_register", [===[
		local frame = self:GetAttribute("clickcast_button")
		self:SetAttribute("export_register", frame)
	]===])

	self.ClickCastHeader:SetAttribute("clickcast_unregister", [===[
		local frame = self:GetAttribute("clickcast_button")
		self:SetAttribute("export_unregister", frame)
	]===])

	self.ClickCastHeader:SetAttribute("clickcast_onenter", [===[
		local frame = self:GetParent():GetFrameRef("clickcast_header")
        frame:RunFor(self, frame:GetAttribute("setup-keybinds"))
	]===])

	self.ClickCastHeader:SetAttribute("clickcast_onleave", [===[
		local frame = self:GetParent():GetFrameRef("clickcast_header")
        frame:RunFor(self, frame:GetAttribute("clear-keybinds"))
	]===])

	self.ClickCastHeader:HookScript("OnAttributeChanged", function(_, name, value)
		local frameName = value and value.GetName and value:GetName()

		if frameName == nil then
			return
		end

		if name == "export_register" then
			Clicked:RegisterClickCastFrame("", frameName)
		elseif name == "export_unregister" then
			Clicked:UnregisterClickCastFrame(frameName)
		end
	end)

	local originalClickCastFrames = ClickCastFrames or {}

	ClickCastFrames = setmetatable({}, {
		__newindex = function(_, frame, options)
			if options ~= nil and options ~= false then
				self:RegisterClickCastFrame("", frame)
			else
				self:UnregisterClickCastFrame(frame)
			end
		end
	})

	for frame in pairs(originalClickCastFrames) do
		self:RegisterClickCastFrame("", frame)
	end
end

function Clicked:UpdateClickCastHeader(keybindings)
	local set, clear = SetupKeybindCommands(keybindings)
	
	self.ClickCastHeader:SetAttribute("setup-keybinds", set)
	self.ClickCastHeader:SetAttribute("clear-keybinds", clear)
end
