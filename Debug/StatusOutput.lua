local AceConsole = LibStub("AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0")

local frame
local editbox

local data

local function GetParsedDataString()
	local lines = {}

	for i, command in ipairs(data) do
		table.insert(lines, "----- " .. i .. " -----")
		table.insert(lines, "keybind: " .. command.keybind)
		table.insert(lines, "hovercast: " .. tostring(command.hovercast))
		table.insert(lines, "action: " .. command.action)

		if command.data ~= nil then
			local split = { strsplit("\n", command.data) }

			for _, line in ipairs(split) do
				table.insert(lines, "data: " .. line)
			end
		end

		if data[command] ~= nil then
			for attribute, value in pairs(data[command]) do
				local split = { strsplit("\n", value) }

				for _, line in ipairs(split) do
					table.insert(lines, "attribute-" .. attribute .. ": " .. line)
				end
			end
		end

		table.insert(lines, "")
	end

	if data["hovercast"] ~= nil then
		local first = true

		for attribute, value in pairs(data["hovercast"].attributes) do
			if first then
				table.insert(lines, "----- hovercast -----")
				first = false
			end

			local split = { strsplit("\n", value) }

			for _, line in ipairs(split) do
				table.insert(lines, "attribute-" .. attribute .. ": " .. line)
			end
		end

		if not first then
			table.insert(lines, "")
		end
	end

	return table.concat(lines, "\n")
end

local function UpdateStatusOutputText()
	local versionString = "Clicked version " .. Clicked.VERSION .. "\n\n"
	local dataString = GetParsedDataString()

	editbox:SetText(versionString .. dataString)
end

local function OpenStatusOutput()
	if frame ~= nil and frame:IsVisible() then
		return
	end

	frame = AceGUI:Create("Frame")
	frame:SetTitle("Clicked Binding Processor Output")
	frame:SetLayout("Fill")

	editbox = AceGUI:Create("MultiLineEditBox")
	editbox:DisableButton(true)
	frame:AddChild(editbox)

	local originalOnTextChanged = editbox.editBox:GetScript("OnTextChanged")

	editbox.editBox:SetScript("OnChar", function()
		UpdateStatusOutputText()
	end)

	editbox.editBox:SetScript("OnTextChanged", function()
		UpdateStatusOutputText()
	end)

	frame:SetCallback("OnClose", function(widget)
		editbox.editBox:SetScript("OnTextChanged", originalOnTextChanged)
		editbox.editBox:SetScript("OnChar", nil)

		AceGUI:Release(widget)
	end)

	UpdateStatusOutputText()
end

local function OnBindingProcessorComplete(event, commands)
	data = {}

	for i, command in ipairs(commands) do
		data[i] = command
	end

	if frame ~= nil and frame:IsVisible() then
		UpdateStatusOutputText()
	end
end

local function OnMacroAttributesCreated(event, command, attributes)
	data[command] = attributes

	if frame ~= nil and frame:IsVisible() then
		UpdateStatusOutputText()
	end
end

local function OnHovercastAttributesCreated(event, keybindings, attributes)
	data["hovercast"] = {
		keybindings = keybindings,
		attributes = attributes
	}

	if frame ~= nil and frame:IsVisible() then
		UpdateStatusOutputText()
	end
end

local module = {
	--["Initialize"] = nil,

	["Register"] = function(self)
		Clicked:RegisterMessage(Clicked.EVENT_BINDING_PROCESSOR_COMPLETE, OnBindingProcessorComplete)
		Clicked:RegisterMessage(Clicked.EVENT_MACRO_ATTRIBUTES_CREATED, OnMacroAttributesCreated)
		Clicked:RegisterMessage(Clicked.EVENT_HOVERCAST_ATTRIBUTES_CREATED, OnHovercastAttributesCreated)
	end,

	["Unregister"] = function(self)
		Clicked:UnregisterMessage(Clicked.EVENT_BINDING_PROCESSOR_COMPLETE)
		Clicked:UnregisterMessage(Clicked.EVENT_MACRO_ATTRIBUTES_CREATED)
		Clicked:UnregisterMessage(Clicked.EVENT_HOVERCAST_ATTRIBUTES_CREATED)
	end,

	["OnChatCommandReceived"] = function(self, args)
		for _, arg in ipairs(args) do
			if arg == "dump" then
				OpenStatusOutput()
				break
			end
		end
	end
}

Clicked:RegisterModule("StatusOutput", module)
