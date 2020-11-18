Clicked.ClickCastHeader = nil

-- safecall implementation

local function errorhandler(err)
	return geterrorhandler()(err)
end

local function safecall(func, ...)
	if func then
		return xpcall(func, errorhandler, ...)
	end
end

function Clicked:RegisterClickCastHeader()
	if GetAddOnEnableState(UnitName("player"), "Clique") == 2 then
		self:ShowAddonIncompatibilityPopup("Clique")
		return
	end

	-- This is mostly based on Clique, mainly to ensure it will continue
	-- working with any addons that integrate with Clique directly, such as oUF.

	self.ClickCastHeader = CreateFrame("Frame", "ClickCastHeader", UIParent, "SecureHandlerBaseTemplate,SecureHandlerAttributeTemplate")
	ClickCastHeader = self.ClickCastHeader

	Clique = {}
	Clique.header = self.ClickCastHeader
	Clique.UpdateRegisteredClicks = function(frame)
		safecall(Clicked.RegisterFrameClicks, Clicked, frame)
	end

	-- set required data first
	self.ClickCastHeader:SetAttribute("clicked-keybinds", "")
	self.ClickCastHeader:SetAttribute("clicked-identifiers", "")

	self.ClickCastHeader:SetAttribute("setup-keybinds", [[
		if currentClickcastButton ~= nil then
			control:RunFor(currentClickcastButton, control:GetAttribute("clear-keybinds"))
		end

		currentClickcastButton = self

		local keybinds = control:GetAttribute("clicked-keybinds")
		local identifiers = control:GetAttribute("clicked-identifiers")

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

	self.ClickCastHeader:SetAttribute("clear-keybinds", [[
		local keybinds = control:GetAttribute("clicked-keybinds")

		if strlen(keybinds) > 0 then
			keybinds = table.new(strsplit("\001", keybinds))

			for i = 1, table.maxn(keybinds) do
				local keybind = keybinds[i]
				self:ClearBinding(keybind)
			end
		end

		currentClickcastButton = nil
	]])

	self.ClickCastHeader:SetAttribute("clickcast_register", [[
		local frame = self:GetAttribute("clickcast_button")
		self:SetAttribute("export_register", frame)
	]])

	self.ClickCastHeader:SetAttribute("clickcast_unregister", [[
		local frame = self:GetAttribute("clickcast_button")
		self:SetAttribute("export_unregister", frame)
	]])

	self.ClickCastHeader:SetAttribute("clickcast_onenter", [[
		local frame = self:GetParent():GetFrameRef("clickcast_header")
		frame:RunFor(self, frame:GetAttribute("setup-keybinds"))
	]])

	self.ClickCastHeader:SetAttribute("clickcast_onleave", [[
		local frame = self:GetParent():GetFrameRef("clickcast_header")
		frame:RunFor(self, frame:GetAttribute("clear-keybinds"))
	]])

	self.ClickCastHeader:SetAttribute("_onattributechanged", [[
		local button = currentClickcastButton

		if name == "unit-exists" and value == "false" and button ~= nil then
			if not button:IsUnderMouse() or not button:IsVisible() then
				self:RunFor(button, self:GetAttribute("clear-keybinds"))
				currentClickcastButton = nil
			end
		end
	]])

	RegisterAttributeDriver(self.ClickCastHeader, "unit-exists", "[@mouseover,exists] true; false")

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

function Clicked:UpdateClickCastHeader(keybinds)
	if self.ClickCastHeader == nil then
		return
	end

	local split = {
		keybinds = {},
		identifiers = {}
	}

	for _, keybind in ipairs(keybinds) do
		table.insert(split.keybinds, keybind.key)
		table.insert(split.identifiers, keybind.identifier)
	end

	self.ClickCastHeader:SetAttribute("clicked-keybinds", table.concat(split.keybinds, "\001"))
	self.ClickCastHeader:SetAttribute("clicked-identifiers", table.concat(split.identifiers, "\001"))
end
