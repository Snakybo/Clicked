local AceGUI = LibStub("AceGUI-3.0")

local frame
local editbox

local data

local function GetBasicinfoString()
	local lines = {}

	table.insert(lines, "Version: " .. Clicked.VERSION)
	table.insert(lines, "Race: " .. UnitRace("player"))
	table.insert(lines, "Level: " .. UnitLevel("player"))
	table.insert(lines, "Class: " .. UnitClass("player"))

	if not Clicked:IsClassic() then
		do
			local _, name = GetSpecializationInfo(GetSpecialization())
			table.insert(lines, "Specialization: " .. name)
		end

		do
			local talents = {}

			for tier = 1, MAX_TALENT_TIERS do
				for column = 1, NUM_TALENT_COLUMNS do
					local _, _, _, selected, _, _, _, _, _, _, known = GetTalentInfo(tier, column, 1)

					if selected or known then
						table.insert(talents, tier .. "/" .. column)
					end
				end
			end

			table.insert(lines, "Talents: " .. table.concat(talents, " "))
		end
	end

	return table.concat(lines, "\n")
end

local function GetParsedDataString()
	local lines = {}

	for i, command in ipairs(data) do
		if i > 1 then
			table.insert(lines, "")
		end

		table.insert(lines, "----- Loaded binding " .. i .. " -----")
		table.insert(lines, "Keybind: " .. command.keybind)
		table.insert(lines, "Hovercast: " .. tostring(command.hovercast))
		table.insert(lines, "Action: " .. command.action)

		if command.data ~= nil then
			local split = { strsplit("\n", command.data) }

			for _, line in ipairs(split) do
				table.insert(lines, "Data: " .. line)
			end
		end

		if data[command] ~= nil then
			for attribute, value in pairs(data[command]) do
				local split = { strsplit("\n", value) }

				for _, line in ipairs(split) do
					table.insert(lines, "Attribute-" .. attribute .. ": " .. line)
				end
			end
		end
	end

	if data["hovercast"] ~= nil then
		local first = true

		for attribute, value in pairs(data["hovercast"].attributes) do
			if first then
				table.insert(lines, "")
				table.insert(lines, "----- Hovercast attributes -----")
				first = false
			end

			local split = { strsplit("\n", value) }

			for _, line in ipairs(split) do
				table.insert(lines, "Attribute-" .. attribute .. ": " .. line)
			end
		end
	end

	return table.concat(lines, "\n")
end

local function GetRegisteredClickCastFrames()
	local lines = {}

	for _, clickCastFrame in ipairs(Clicked:GetClickCastFrames()) do
		if clickCastFrame ~= nil and clickCastFrame.GetName ~= nil then
			local name = clickCastFrame:GetName()
			local blacklisted = Clicked:IsFrameBlacklisted(clickCastFrame)

			table.insert(lines, name .. (blacklisted and " (blacklisted)" or ""))
		end
	end

	if #lines > 0 then
		table.insert(lines, 1, "----- Registered unit frames -----")
	end

	return table.concat(lines, "\n")
end

local function UpdateStatusOutputText()
	local text = {}
	table.insert(text, GetBasicinfoString())
	table.insert(text, GetParsedDataString())
	table.insert(text, GetRegisteredClickCastFrames())

	editbox:SetText(table.concat(text, "\n\n"))
end

local function OpenStatusOutput()
	if frame ~= nil and frame:IsVisible() then
		return
	end

	frame = AceGUI:Create("Frame")
	frame:SetTitle("Clicked Data Dump")
	frame:SetLayout("Fill")

	editbox = AceGUI:Create("MultiLineEditBox")
	editbox:SetLabel("")
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
