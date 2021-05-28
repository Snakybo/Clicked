--- @type ClickedInternal
local _, Addon = ...

-- Local support functions

local function errorhandler(err)
	return geterrorhandler()(err)
end

local function safecall(func, ...)
	if func then
		return xpcall(func, errorhandler, ...)
	end
end

-- Private addon API

function Addon:RegisterClickCastHeader()
	if GetAddOnEnableState(UnitName("player"), "Clique") == 2 then
		Addon:ShowAddonIncompatibilityPopup("Clique")
		return
	end

	-- This is mostly based on Clique, mainly to ensure it will continue
	-- working with any addons that integrate with Clique directly, such as oUF.

	--- @type table
	ClickCastHeader = CreateFrame("Frame", "ClickCastHeader", UIParent, "SecureHandlerBaseTemplate,SecureHandlerAttributeTemplate")
	Addon.ClickCastHeader = ClickCastHeader

	ClickCastHeader:SetAttribute("clicked-keybinds", "")
	ClickCastHeader:SetAttribute("clicked-identifiers", "")
	ClickCastHeader:Execute([[
		blacklist = table.new()
	]])

	ClickCastHeader:SetAttribute("setup-keybinds", [[
		if blacklist[self:GetName()] then
			return
		end

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

	ClickCastHeader:SetAttribute("clear-keybinds", [[
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

	ClickCastHeader:SetAttribute("clickcast_register", [[
		local frame = self:GetAttribute("clickcast_button")
		self:SetAttribute("export_register", frame)
	]])

	ClickCastHeader:SetAttribute("clickcast_unregister", [[
		local frame = self:GetAttribute("clickcast_button")
		self:SetAttribute("export_unregister", frame)
	]])

	ClickCastHeader:SetAttribute("clickcast_onenter", [[
		local frame = self:GetParent():GetFrameRef("clickcast_header")
		frame:RunFor(self, frame:GetAttribute("setup-keybinds"))
	]])

	ClickCastHeader:SetAttribute("clickcast_onleave", [[
		local frame = self:GetParent():GetFrameRef("clickcast_header")
		frame:RunFor(self, frame:GetAttribute("clear-keybinds"))
	]])

	ClickCastHeader:SetAttribute("_onattributechanged", [[
		local button = currentClickcastButton

		if name == "unit-exists" and value == "false" and button ~= nil then
			if not button:IsUnderMouse() or not button:IsVisible() then
				self:RunFor(button, self:GetAttribute("clear-keybinds"))
				currentClickcastButton = nil
			end
		end
	]])

	ClickCastHeader:HookScript("OnAttributeChanged", function(_, name, value)
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

	RegisterAttributeDriver(ClickCastHeader, "unit-exists", "[@mouseover,exists] true; false")

	-- Hook into the global ClickCastFrames table
	local originalClickCastFrames = ClickCastFrames or {}

	ClickCastFrames = setmetatable({}, {
		__newindex = function(_, frame, options)
			if options ~= nil and options ~= false then
				Clicked:RegisterClickCastFrame("", frame)
			else
				Clicked:UnregisterClickCastFrame(frame)
			end
		end
	})

	for frame in pairs(originalClickCastFrames) do
		Clicked:RegisterClickCastFrame("", frame)
	end

	-- Hook into Clique because a lot of (older) addons are hardcoded to add Clique-support
	Clique = {}
	Clique.header = ClickCastHeader
	Clique.UpdateRegisteredClicks = function(_, frame)
		safecall(Clicked.RegisterFrameClicks, Clicked, frame)
	end
end

function Addon:UpdateClickCastHeaderBlacklist()
	local blacklist = Addon.db.profile.blacklist
	local data = {
		"blacklist = table.wipe(blacklist)"
	}

	for frame, blacklisted in pairs(blacklist) do
		if blacklisted then
			local line = [[
				blacklist["%s"] = true
			]]

			table.insert(data, string.format(line, frame))
		end
	end

	Addon.ClickCastHeader:Execute(table.concat(data, "\n"))
end

--- @param keybinds Keybind[]
function Addon:UpdateClickCastHeader(keybinds)
	if Addon.ClickCastHeader == nil then
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

	Addon.ClickCastHeader:SetAttribute("clicked-keybinds", table.concat(split.keybinds, "\001"))
	Addon.ClickCastHeader:SetAttribute("clicked-identifiers", table.concat(split.identifiers, "\001"))
end
