local AceConsole = LibStub("AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0")

local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo
local InCombatLockdown = InCombatLockdown

local keybindOrderMapping = {
	"BUTTON1", "BUTTON2", "BUTTON3", "BUTTON4", "BUTTON5", "MOUSEWHEELUP", "MOUSEWHEELDOWN",
	"`", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "-", "=",
	"NUMPAD0", "NUMPAD1", "NUMPAD2", "NUMPAD3", "NUMPAD4", "NUMPAD5", "NUMPAD6", "NUMPAD7", "NUMPAD8", "NUMPAD9", "NUMPADDIVIDE", "NUMPADMULTIPLY", "NUMPADMINUS", "NUMPADPLUS", "NUMPADDECIMAL",
	"F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12", "F13",
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
	"TAB", "CAPSLOCK", "INSERT", "DELETE", "HOME", "END", "PAGEUP", "PAGEDOWN", "[", "]", "\\", ";", "'", ",", ".", "/"
}

local root, tree, items, selected
local spellbookButtons = {}

local function CanUpdateBinding()
	if InCombatLockdown() then
		return false
	end

	return true
end

local function TreeSortFunc(left, right)
	if left.binding.keybind == "" and right.binding.keybind ~= "" then
		return false
	end

	if left.binding.keybind ~= "" and right.binding.keybind == "" then
		return true
	end

	if left.binding.keybind == "" and right.binding.keybind == "" then
		return left.index < right.index
	end

	if left.binding.keybind == right.binding.keybind then
		return left.index < right.index
	end

	if Clicked:IsBindingActive(left.binding) and not Clicked:IsBindingActive(right.binding) then
		return true
	end

	if not Clicked:IsBindingActive(left.binding) and Clicked:IsBindingActive(right.binding) then
		return false
	end

	local function GetKeybindKey(bind)
		local mods = {}
		local result = ""

		for match in string.gmatch(bind, "[^-]+") do
			table.insert(mods, match)
			result = match
		end

		table.remove(mods, #mods)

		local index = #keybindOrderMapping + 1
		local found = false

		for i = 1, #keybindOrderMapping do
			if keybindOrderMapping[i] == result then
				index = i
				found = true
				break
			end
		end

		-- register this unknown keybind for this session
		if not found then
			table.insert(keybindOrderMapping, result)
		end

		for i = 1, #mods do
			if mods[i] == "CTRL" then
				index = index + 1000
			end

			if mods[i] == "ALT" then
				index = index + 10000
			end

			if mods[i] == "SHIFT" then
				index = index + 100000
			end
		end

		return index
	end

	return GetKeybindKey(left.binding.keybind) < GetKeybindKey(right.binding.keybind)
end

local function GetTreeViewItems()
	local items = {}

	for i, binding in ipairs(Clicked.bindings) do
		local item = {}
		item.value = "binding_" .. i
		item.index = i
		item.binding = binding
		item.icon = "Interface\\ICONS\\INV_Misc_QuestionMark"

		if binding.type == Clicked.TYPE_SPELL then
			item.text1 = "Cast " .. (binding.action.spell or "")
			item.icon = select(3, GetSpellInfo(binding.action.spell)) or item.icon
		elseif binding.type == Clicked.TYPE_ITEM then
			item.text1 = "Use " .. (binding.action.item or "")
			item.icon = select(10, GetItemInfo(binding.action.item)) or item.icon
		elseif binding.type == Clicked.TYPE_MACRO then
			item.text1 = "Run Custom Macro"
		elseif binding.type == Clicked.TYPE_UNIT_SELECT then
			item.text1 = "Target the selected unit"
		elseif binding.type == Clicked.TYPE_UNIT_MENU then
			item.text1 = "Open a context menu"
		end

		item.text2 = binding.keybind

		if Clicked:IsBindingActive(binding) then
			item.text3 = "L"
		else
			item.text3 = "U"
		end

		table.insert(items, item)
	end

	table.sort(items, TreeSortFunc)
	return items
end

local function GetToggleValueFromIndex(state)
	if state == 1 then
		return true
	elseif state == 2 then
		return nil
	end

	return false
end

local function GetIndexFromToggleValue(value)
	if value == false then
		return 0
	elseif value == true then
		return 1
	elseif value == nil then
		return 2
	end
end

local function EnableSpellbookHandlers(handler)
	if not SpellBookFrame:IsVisible() then
		return
	end

	if #spellbookButtons == 0 then
		for i = 1, 12 do
			local parent = _G["SpellButton" .. i]
			local button = CreateFrame("Button", "ClickedSpellbookButton" .. i, parent, "ClickedSpellbookButtonTemplate")
			button.parent = parent
			button:RegisterForClicks("LeftButtonUp")
			button:SetID(parent:GetID())

			spellbookButtons[i] = button
		end
	end

	for _, button in ipairs(spellbookButtons) do
		if button.parent:IsEnabled() then
			button:SetScript("OnClick", function(self)
				local slot = SpellBook_GetSpellBookSlot(self:GetParent())
				local name = GetSpellBookItemName(slot, SpellBookFrame.bookType)

				if name ~= nil and name ~= "" then
					handler(name)
				end
			end)
			button:SetScript("OnEnter", function(self)
				if self.parent:IsEnabled() then
					SpellButton_OnEnter(self.parent)
				else
					self:GetHighlightTexture():Hide()
				end
			end)
			button:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)

			button:Show()
		end
	end
end

local function DisableSpellbookHandlers()
	GameTooltip:Hide()

	for _, button in ipairs(spellbookButtons) do
		button:SetScript("OnClick", nil)
		button:SetScript("OnEnter", nil)
		button:SetScript("OnLeave", nil)
		button:Hide()
	end
end

local function DrawBindingActions(container, tab, binding)
	-- action help label
	do
		local widget = AceGUI:Create("Label")
		widget:SetText("Here you can configure the action that will be performed when the key has been pressed.")
		widget:SetFullWidth(true)

		container:AddChild(widget)
	end

	-- restricted keybind help label
	if Clicked:IsRestrictedKeybind(binding.keybind) then
		do
			local widget = AceGUI:Create("Label")
			widget:SetText("Note: Bindings using the left or right mouse button are considered 'restricted' and will always be cast on the targeted unit frame")
			widget:SetFullWidth(true)

			container:AddChild(widget)
		end
	end

	-- action dropdown
	do
		local widget = AceGUI:Create("Dropdown")
		widget:SetList({
			SPELL = "Cast a spell",
			ITEM = "Use an item",
			MACRO = "Run a macro",
			UNIT_SELECT = "Target the selected unit",
			UNIT_MENU = "Open the unit's context menu"
		},
		{
			"SPELL",
			"ITEM",
			"MACRO",
			"UNIT_SELECT",
			"UNIT_MENU"
		})
		widget:SetValue(binding.type)
		widget:SetLabel("When the keybind has been pressed")
		widget:SetFullWidth(true)
		widget:SetCallback("OnValueChanged", function(...)
			if CanUpdateBinding() then
				binding.type = select(3, ...)
				Clicked:ReloadActiveBindingsAndConfig()
				tab:SelectTab("actions")
			else
				widget:SetValue(binding.type)
			end
		end)

		container:AddChild(widget)
	end

	if binding.type == Clicked.TYPE_SPELL or binding.type == Clicked.TYPE_ITEM then
		if binding.type == Clicked.TYPE_SPELL then
			-- target spell text
			do
				local widget = AceGUI:Create("EditBox")
				widget:SetRelativeWidth(0.75)
				widget:SetText(binding.action.spell)
				widget:SetLabel("Target Spell")
				widget:SetCallback("OnEnterPressed", function(...)
					if CanUpdateBinding() then
						local value = select(3, ...)

						if value ~= "" then
							if GetSpellInfo(value) == nil then
								root:SetStatusText("Unknown spell: " .. value)
							else
								root:SetStatusText("")
							end

							binding.action.spell = value

							Clicked:ReloadActiveBindingsAndConfig()
						end
					else
						widget:SetText(binding.action.spell)
					end
				end)

				container:AddChild(widget)
			end

			-- pick from spellbook button
			do
				local widget = AceGUI:Create("Button")
				widget:SetText("Select")
				widget:SetRelativeWidth(0.25)
				widget:SetCallback("OnClick", function()
					SpellBookFrame:HookScript("OnHide", function()
						DisableSpellbookHandlers()
					end)

					ShowUIPanel(SpellBookFrame)

					EnableSpellbookHandlers(function(name)
						binding.action.spell = name
						root:SetStatusText("")
						Clicked:ReloadActiveBindingsAndConfig()

						HideUIPanel(SpellBookFrame)
					end)
				end)
				widget:SetCallback("OnEnter", function()
					local tooltip = AceGUI.tooltip

					tooltip:SetOwner(widget.frame, "ANCHOR_NONE")
					tooltip:ClearAllPoints()
					tooltip:SetPoint("LEFT", widget.frame, "RIGHT")
					tooltip:SetText(text or "Click on a spell book entry to select it", 1, 0.82, 0, true)
					tooltip:Show()
				end)
				widget:SetCallback("OnLeave", function()
					local tooltip = AceGUI.tooltip
					tooltip:Hide()
				end)

				container:AddChild(widget)
			end
		elseif binding.type == Clicked.TYPE_ITEM then
			-- target item text
			do
				local widget = AceGUI:Create("EditBox")
				widget:SetRelativeWidth(0.75)
				widget:SetText(binding.action.item)
				widget:SetLabel("Target Item")
				widget:SetCallback("OnEnterPressed", function(...)
					if CanUpdateBinding() then
						binding.action.item = select(3, ...)
						Clicked:ReloadActiveBindingsAndConfig()
						root:SetStatusText("")
					else
						widget:SetText(binding.action.item)
					end
				end)

				container:AddChild(widget)
			end

			-- pick from inventory button
			do
				local widget = AceGUI:Create("Button")
				widget:SetText("Select")
				widget:SetRelativeWidth(0.25)
				widget:SetDisabled(true)
				widget:SetCallback("OnClick", function()

				end)

				container:AddChild(widget)
			end
		end

		-- interrupt cast toggle
		do
			local widget = AceGUI:Create("CheckBox")
			widget:SetFullWidth(true)
			widget:SetType("checkbox")
			widget:SetValue(binding.action.stopCasting)
			widget:SetLabel("Interrupt current cast?")
			widget:SetCallback("OnValueChanged", function(...)
				if CanUpdateBinding() then
					binding.action.stopCasting = select(3, ...)
					Clicked:ReloadActiveBindings()
				else
					widget:SetValue(binding.action.stopCasting)
				end
			end)

			container:AddChild(widget)
		end

		-- target type dropdowns
		do
			if not Clicked:IsRestrictedKeybind(binding.keybind) then
				local function DrawTargetUnitDropdown(target, index)
					local list = {
						PLAYER = "Player (you)",
						TARGET = "Target",
						--MOUSEOVER_FRAME = "Mouseover (unit frame)",
						MOUSEOVER = "Mouseover (unit frame and 3D world)",
						FOCUS = "Focus",
						PARTY_1 = "Party 1",
						PARTY_2 = "Party 2",
						PARTY_3 = "Party 3",
						PARTY_4 = "Party 4",
						PARTY_5 = "Party 5"
					}

					local order = {
						"PLAYER",
						"TARGET",
						--"MOUSEOVER_FRAME",
						"MOUSEOVER",
						"FOCUS",
						"PARTY_1",
						"PARTY_2",
						"PARTY_3",
						"PARTY_4",
						"PARTY_5"
					}

					if index == 1 then
						list["GLOBAL"] = "None (global)"
						table.insert(order, 1, "GLOBAL")
					elseif index == 0 then
						list["_NONE"] = ""
						table.insert(order, 1, "_NONE")
					else
						list["_DELETE"] = "<Remove this option>"
						table.insert(order, "_DELETE")
					end

					local widget = AceGUI:Create("Dropdown")
					widget:SetList(list, order)
					widget:SetValue(target.unit)

					if index == 1 then
						widget:SetLabel("On this target")
					else
						widget:SetLabel("Or")
					end

					if Clicked:CanTargetUnitBeHostile(target.unit) then
						widget:SetRelativeWidth(0.5)
					else
						widget:SetRelativeWidth(1)
					end

					widget:SetCallback("OnValueChanged", function(...)
						if CanUpdateBinding() then
							local value = select(3, ...)

							if index == 0 then
								local new = Clicked:GetNewBindingTargetTemplate()
								new.unit = value
								table.insert(binding.targets, new)
							elseif value == "_DELETE" then
								table.remove(binding.targets, index)
							else
								if value == Clicked.TARGET_UNIT_GLOBAL then
									local new = Clicked:GetNewBindingTargetTemplate()
									new.unit = value
									binding.targets = { new }
								else
									target.unit = value
								end
							end

							tab:SelectTab("actions")
							Clicked:ReloadActiveBindings()
						else
							if index ~= 0 then
								widget:SetValue(unit)
							else
								widget:SetValue("_NONE")
							end
						end
					end)

					container:AddChild(widget)
				end

				local function DrawTargetTypeDropdown(target)
					local widget = AceGUI:Create("Dropdown")
					widget:SetList({
						ANY = "Either friendly or hostile",
						HELP = "Friendly",
						HARM = "Hostile"
					},
					{
						"ANY",
						"HELP",
						"HARM"
					})
					widget:SetValue(target.type)
					widget:SetLabel("If it is")
					widget:SetRelativeWidth(0.5)
					widget:SetCallback("OnValueChanged", function(...)
						if CanUpdateBinding() then
							target.type = select(3, ...)
							Clicked:ReloadActiveBindings()
						else
							widget:SetValue(target.type)
						end
					end)

					container:AddChild(widget)
				end

				for i, target in ipairs(binding.targets) do
					DrawTargetUnitDropdown(target, i)

					if Clicked:CanTargetUnitBeHostile(target.unit) then
						DrawTargetTypeDropdown(target)
					end
				end

				if #binding.targets == 0 or (binding.targets[1].unit ~= Clicked.TARGET_UNIT_GLOBAL and binding.targets[#binding.targets].unit ~= Clicked.TARGET_UNIT_PLAYER) then
					DrawTargetUnitDropdown({ unit = "_NONE" }, 0)
				end
			end
		end
	elseif binding.type == Clicked.TYPE_MACRO then
		-- macro text field
		do
			local widget = AceGUI:Create("MultiLineEditBox")
			widget:SetLabel("Macro Text")
			widget:SetText(binding.action.macro)
			widget:SetFullWidth(true)
			widget:SetFullHeight(true)
			widget:SetCallback("OnEnterPressed", function(...)
				if CanUpdateBinding() then
					binding.action.macro = select(3, ...)
					Clicked:ReloadActiveBindings()
				else
					widget:SetText(binding.action.macro)
				end
			end)

			container:AddChild(widget)
		end
	end
end

local function DrawBindingLoadOptions(container, tab, binding)
	-- never load toggle
	do
		local widget = AceGUI:Create("CheckBox")
		widget:SetFullWidth(true)
		widget:SetType("checkbox")
		widget:SetValue(binding.load.never)
		widget:SetLabel("Never load")
		widget:SetCallback("OnValueChanged", function(...)
			if CanUpdateBinding() then
				binding.load.never = select(3, ...)
				Clicked:ReloadActiveBindingsAndConfig()
				tab:SelectTab("load_options")
			else
				widget:SetValue(binding.load.never)
			end
		end)

		container:AddChild(widget)
	end

	-- spec selection
	do
		local function GetSpecializations()
			local result = {}

			local numSpecs = GetNumSpecializations()

			for i = 1, numSpecs do
				local _, name = GetSpecializationInfo(i)
				result["spec" .. i] = name
			end

			return result
		end

		-- spec toggle
		do
			local widget = AceGUI:Create("CheckBox")
			widget:SetRelativeWidth(0.5)
			widget:SetType("checkbox")
			widget:SetValue(GetToggleValueFromIndex(binding.load.specialization.selected))
			widget:SetLabel("Specialization")
			widget:SetTriState(true)
			widget:SetCallback("OnValueChanged", function(...)
				if CanUpdateBinding() then
					local value = select(3, ...)
					binding.load.specialization.selected = GetIndexFromToggleValue(value)
					Clicked:ReloadActiveBindingsAndConfig()
					tab:SelectTab("load_options")
				else
					widget:SetValue(GetToggleValueFromIndex(binding.load.specialization.selected))
				end
			end)

			container:AddChild(widget)
		end

		-- spec (single)
		if binding.load.specialization.selected == 1 then
			do
				local widget = AceGUI:Create("Dropdown")
				widget:SetRelativeWidth(0.5)
				widget:SetList(GetSpecializations())
				widget:SetValue("spec" .. (binding.load.specialization.single or 1))
				widget:SetCallback("OnValueChanged", function(...)
					if CanUpdateBinding() then
						local value = select(3, ...)
						binding.load.specialization.single = tonumber(string.sub(value, -1))
						Clicked:ReloadActiveBindingsAndConfig()
						tab:SelectTab("load_options")
					else
						widget:SetValue("spec" .. (binding.load.specialization.single or 1))
					end
				end)

				container:AddChild(widget)
			end
		-- spec (multiple)
		elseif binding.load.specialization.selected == 2 then
			local specs = GetSpecializations()
			local widget = AceGUI:Create("Dropdown")

			local function SetInitialState()
				for key, _ in pairs(specs) do
					local index = tonumber(string.sub(key, -1))
					local found = false

					for i = 1, #binding.load.specialization.multiple do
						if binding.load.specialization.multiple[i] == index then
							found = true
							break
						end
					end

					widget:SetItemValue(key, found)
				end
			end

			widget:SetRelativeWidth(0.5)
			widget:SetList(specs)
			widget:SetMultiselect(true)
			widget:SetCallback("OnValueChanged", function(...)
				if CanUpdateBinding() then
					local key, checked = select(3, ...)
					local index = tonumber(string.sub(key, -1))

					if checked then
						table.insert(binding.load.specialization.multiple, index)
					else
						for i = 1, #binding.load.specialization.multiple do
							if binding.load.specialization.multiple[i] == index then
								table.remove(binding.load.specialization.multiple, i)
							end
						end
					end

					Clicked:ReloadActiveBindingsAndConfig()
					tab:SelectTab("load_options")
				else
					SetInitialState()
				end
			end)

			SetInitialState()

			container:AddChild(widget)
		end

		-- separator
		do
			local widget = AceGUI:Create("SimpleGroup")
			widget:SetFullWidth(true)

			container:AddChild(widget)
		end
	end

	-- combat selection
	do
		-- combat toggle
		do
			local widget = AceGUI:Create("CheckBox")
			widget:SetRelativeWidth(0.5)
			widget:SetType("checkbox")
			widget:SetValue(GetToggleValueFromIndex(binding.load.combat.selected))
			widget:SetLabel("Combat")
			widget:SetCallback("OnValueChanged", function(...)
				if CanUpdateBinding() then
					local value = select(3, ...)
					binding.load.combat.selected = GetIndexFromToggleValue(value)
					Clicked:ReloadActiveBindingsAndConfig()
					tab:SelectTab("load_options")
				else
					widget:SetValue(binding.load.combat.selected)
				end
			end)

			container:AddChild(widget)
		end

		-- combat
		if binding.load.combat.selected == 1 then
			do
				local widget = AceGUI:Create("Dropdown")
				widget:SetRelativeWidth(0.5)
				widget:SetList({
					IN_COMBAT = "In combat",
					NOT_IN_COMBAT = "Not in combat"
				})
				widget:SetValue(binding.load.combat.state)
				widget:SetCallback("OnValueChanged", function(...)
					if CanUpdateBinding() then
						local value = select(3, ...)
						binding.load.combat.state = value
						Clicked:ReloadActiveBindingsAndConfig()
						tab:SelectTab("load_options")
					else
						widget:SetValue(binding.load.combat.state)
					end
				end)

				container:AddChild(widget)
			end
		end

		-- separator
		do
			local widget = AceGUI:Create("SimpleGroup")
			widget:SetFullWidth(true)

			container:AddChild(widget)
		end
	end

	-- spell known
	do
		-- spell known toggle
		do
			local widget = AceGUI:Create("CheckBox")
			widget:SetRelativeWidth(0.5)
			widget:SetType("checkbox")
			widget:SetValue(GetToggleValueFromIndex(binding.load.spellKnown.selected))
			widget:SetLabel("Spell Known")
			widget:SetCallback("OnValueChanged", function(...)
				if CanUpdateBinding() then
					local value = select(3, ...)
					binding.load.spellKnown.selected = GetIndexFromToggleValue(value)
					Clicked:ReloadActiveBindingsAndConfig()
					tab:SelectTab("load_options")
				else
					widget:SetValue(GetToggleValueFromIndex(binding.load.spellKnown.selected))
				end
			end)

			container:AddChild(widget)
		end

		if binding.load.spellKnown.selected == 1 then
			do
				local widget = AceGUI:Create("EditBox")
				widget:SetRelativeWidth(0.5)
				widget:SetText(binding.load.spellKnown.spell)
				widget:SetCallback("OnEnterPressed", function(...)
					if CanUpdateBinding() then
						binding.load.spellKnown.spell = select(3, ...)
						Clicked:ReloadActiveBindingsAndConfig()
						tab:SelectTab("load_options")
					else
						widget:SetValue(binding.load.spellKnown.spell)
					end
				end)

				container:AddChild(widget)
			end
		end

		-- separator
		do
			local widget = AceGUI:Create("SimpleGroup")
			widget:SetFullWidth(true)

			container:AddChild(widget)
		end
	end
end

local function DrawBinding(container, binding)
	-- keybinding button
	do
		local widget = AceGUI:Create("ClickedKeybinding")
		widget:SetKey(binding.keybind)
		widget:SetRelativeWidth(0.75)
		widget:SetCallback("OnKeyChanged", function(...)
			if CanUpdateBinding() then
				binding.keybind = select(3, ...)

				Clicked:ReloadActiveBindingsAndConfig()
			else
				widget:SetKey(binding.keybind)
			end
		end)

		container:AddChild(widget)
	end

	-- delete button
	do
		local widget = AceGUI:Create("Button")
		widget:SetText("Delete")
		widget:SetRelativeWidth(0.25)
		widget:SetCallback("OnClick", function()
			if CanUpdateBinding() then
				local index = 1

				for i, other in ipairs(Clicked.bindings) do
					if other == binding then
						table.remove(Clicked.bindings, i)
						index = i
						break
					end
				end

				Clicked:ReloadActiveBindingsAndConfig()

				if index <= #items then
					tree:SelectByPath(items[index].value)
				elseif index - 1 >= 1 then
					tree:SelectByPath(items[index - 1].value)
				end
			end
		end)

		container:AddChild(widget)
	end

	-- tabs
	do
		local widget = AceGUI:Create("TabGroup")
		widget:SetFullWidth(true)
		widget:SetFullHeight(true)
		widget:SetLayout("Fill")
		widget:SetTabs(
			{
				{
					text = "Actions",
					value = "actions"
				},
				{
					text = "Load Options",
					value = "load_options"
				}
			}
		)
		widget:SetCallback("OnGroupSelected", function(container, _, group)
			container:ReleaseChildren()

			local scrollFrame = AceGUI:Create("ScrollFrame")
			scrollFrame:SetLayout("Flow")

			container:AddChild(scrollFrame)

			if group == "actions" then
				DrawBindingActions(scrollFrame, container, binding)
			elseif group == "load_options" then
				DrawBindingLoadOptions(scrollFrame, container, binding)
			end
		end)
		widget:SelectTab("actions")

		container:AddChild(widget)
	end
end

function Clicked:ReloadBindingConfig()
	if tree ~= nil then
		items = GetTreeViewItems()
		selected = selected or "binding_1"

		tree:SetTree(items)
		tree:SelectByPath(selected)
	end
end

function Clicked:OpenBindingConfig()
	if root ~= nil and root:IsVisible() then
		return
	end

	-- root frame
	do
		root = AceGUI:Create("Frame")
		root:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
		root:SetTitle("Clicked Binding Config")
		root:SetLayout("Flow")

		root.frame:SetScript("OnKeyDown", function(self, key)
			if key == "ESCAPE" then
				self:SetPropagateKeyboardInput(false)
				self:Hide()
			else
				self:SetPropagateKeyboardInput(true)
			end
		end)
	end

	-- create binding button
	do
		local add = AceGUI:Create("Button")
		add:SetText("Create Binding")
		add:SetWidth(210)
		add:SetCallback("OnClick", function()
			if CanUpdateBinding() then
				table.insert(Clicked.bindings, Clicked:GetNewBindingTemplate())

				Clicked:ReloadActiveBindingsAndConfig()
				tree:SelectByPath("binding_" .. #Clicked.bindings)
			end
		end)

		root:AddChild(add)
	end

	-- binding help label
	do
		local description = AceGUI:Create("Label")
		description:SetText("You can configure key and click bindings from this window.")
		description:SetFontObject(GameFontHighlight)
		description:SetWidth(400)

		root:AddChild(description)
	end

	-- tree view
	do
		items = GetTreeViewItems()
		tree = AceGUI:Create("ClickedTreeGroup")
		tree:SetLayout("Flow")
		tree:SetFullWidth(true)
		tree:SetFullHeight(true)
		tree:SetTree(items)
		tree:EnableButtonTooltips(false)
		tree:SetCallback("OnGroupSelected", function(container, _, group)
			container:ReleaseChildren()
			DisableSpellbookHandlers()

			for _, item in ipairs(items) do
				if item.value == group then
					DrawBinding(container, item.binding)
					break
				end
			end

			selected = group
		end)
		tree:SetCallback("OnButtonEnter", function(_, _, group, frame)
			local tooltip = AceGUI.tooltip
			local text = frame.text:GetText()
			local binding

			for i = 1, #items do
				if items[i].value == group then
					binding = items[i].binding
					break
				end
			end

			if binding ~= nil then
				if binding.type == Clicked.TYPE_MACRO then
					text = binding.action.macro
				end

				text = text .. "\n\n"

				if Clicked:IsBindingActive(binding) then
					text = text .. "Loaded"
				else
					text = text .. "Not Loaded"
				end
			end

			tooltip:SetOwner(frame, "ANCHOR_NONE")
			tooltip:ClearAllPoints()
			tooltip:SetPoint("RIGHT", frame, "LEFT")
			tooltip:SetText(text or "", 1, 0.82, 0, true)
			tooltip:Show()
		end)
		tree:SetCallback("OnButtonLeave", function()
			local tooltip = AceGUI.tooltip
			tooltip:Hide()
		end)

		if #items > 0 then
			tree:SelectByPath(items[1].value)
		end

		root:AddChild(tree)
	end
end

function Clicked:RegisterBindingConfig()
	AceConsole:RegisterChatCommand("clicked", function()
		self:OpenBindingConfig()
	end)
end
