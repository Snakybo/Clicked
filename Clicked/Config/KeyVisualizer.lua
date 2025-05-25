-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2024  Kevin Krol
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

local AceGUI = LibStub("AceGUI-3.0")

--- @class ClickedInternal
local Addon = select(2, ...)

local DEFAULT_KEYBOARD_LAYOUT = Addon.KeyboardLayouts.QWERTY
local DEFAULT_KEYBOARD_SIZE = Addon.KeyboardSizes.SIZE_80

local MIN_FRAME_WIDTH = 900

local GROUP_ALL = "all"
local GROUP_EXT = "ext"

--- @class KeyVisualizer
local KeyVisualizer = {}

--- @type ClickedFrame
local frame

--- @type ClickedKeyVisualizerTreeGroup
local tree

--- @type table<string,ClickedKeyVisualizerButton>?
local buttonCache = nil

local showCtrl = false
local showCtrlWidget
local showAlt = false
local showAltWidget
local showMeta = false
local showMetaWidget
local showShift = false
local showShiftWidget
local showGroup = GROUP_ALL

local function GetTreeLayout()
	local result = {}

	for _, layout in ipairs(Addon.KeyLayouts:GetKeyboardLayouts()) do
		local item = {
			value = layout,
			text = layout,
			children = {}
		}

		for _, size in ipairs(Addon.KeyLayouts:GetKeyboardSizes(layout)) do
			table.insert(item.children, {
				value = size,
				text = size .. "%"
			})
		end

		table.insert(result, item)
	end

	return result
end

--- @class KeyVisualizerDb
--- @field public lastKeyboardLayout? KeyboardLayout
--- @field public lastKeyboardSize? KeyboardSize
--- @field public showOnlyLoadedBindings boolean
--- @field public highlightEmptyKeys boolean

--- @return KeyVisualizerDb
local function GetDb()
	return Addon.db.global.keyVisualizer
end

--- @param layout? KeyboardLayout
--- @param size? KeyboardSize
local function SelectLayout(layout, size)
	local db = GetDb()
	layout = layout or db.lastKeyboardLayout or DEFAULT_KEYBOARD_LAYOUT
	size = size or db.lastKeyboardSize or DEFAULT_KEYBOARD_SIZE

	tree:SelectByPath(layout, size)
end

--- @param key string
--- @return string
local function GetModifiedKey(key)
	if showMeta then
		key = "META-" .. key
	end

	if showShift then
		key = "SHIFT-" .. key
	end

	if showCtrl then
		key = "CTRL-" .. key
	end

	if showAlt then
		key = "ALT-" .. key
	end

	return key
end

--- @param layout KeyboardLayout
--- @param size KeyboardSize
local function BuildLayout(layout, size)
	local keys, visible = Addon.KeyLayouts:GetKeyboardLayout(layout, size)

	--- @param key KeyButton
	local function GetOveride(key)
		if key.overrides == nil then
			return key
		end

		local bestOverride = nil
		local bestOverrideDiff = math.huge

		for overrideSize, override in pairs(key.overrides) do
			if overrideSize >= size then
				local diff = math.abs(size - overrideSize)

				if diff < bestOverrideDiff then
					bestOverride = override
					bestOverrideDiff = diff
				end
			end
		end

		if bestOverride ~= nil then
			return Mixin({}, key, bestOverride)
		end

		return key
	end

	buttonCache = {}

	for _, key in ipairs(keys) do
		local widget = AceGUI:Create("ClickedKeyVisualizerButton") --[[@as ClickedKeyVisualizerButton]]
		widget:SetKey(GetOveride(key))
		widget:SetVisible(Addon:TableContains(visible, key:GetId()))

		tree:AddChild(widget)
		buttonCache[key:GetId()] = widget
	end

	--- @diagnostic disable-next-line: invisible
	local oldWidth = frame.frame:GetWidth()
	local width = math.max(tree:GetTreeWidth() + tree:GetContentWidth() + 54, MIN_FRAME_WIDTH)
	frame:SetWidth(width)

	local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint(1)

	if point == "CENTER" or point == "TOP" or point == "BOTTOM" then
		--- @diagnostic disable-next-line: invisible
		local xOffset = (frame.frame:GetWidth() - oldWidth) / 2
		frame:SetPoint(point, relativeTo, relativePoint, xOfs + xOffset, yOfs)
	elseif point == "RIGHT" or point == "TOPRIGHT" or point == "BOTTOMRIGHT" then
		--- @diagnostic disable-next-line: invisible
		local xOffset = (frame.frame:GetWidth() - oldWidth)
		frame:SetPoint(point, relativeTo, relativePoint, xOfs + xOffset, yOfs)
	end
end

local function PopulateKeys()
	--- @param key string
	--- @return string[]
	--- @return integer|string|nil
	local function GetBinds(key)
		local spellNames = {}
		local icon = nil

		key = GetModifiedKey(key)
		local db = GetDb()

		--- @param spellName string
		--- @param spellIcon string|integer
		--- @param forceIcon? boolean
		local function Register(spellName, spellIcon, forceIcon)
			if not Addon:IsNilOrEmpty(spellName) and not spellNames[spellName] then
				spellNames[spellName] = true
				icon = icon or spellIcon
			end

			if forceIcon then
				icon = spellIcon
			end
		end

		--- @param binding Binding
		--- @param isActive boolean
		local function RegisterBinding(binding, isActive)
			if binding.keybind ~= key then
				return
			end

			local spellName, spellIcon = Addon:GetBindingNameAndIcon(binding)
			Register(spellName, spellIcon, isActive)
		end

		--- @param action string
		--- @param slot integer
		local function RegisterAction(action, slot)
			local keybind = GetBindingKey(action)

			if keybind ~= key then
				return
			end

			local type, id, subType = GetActionInfo(slot)

			local actionIcon = GetActionTexture(slot)
			local name

			if type == "spell" or (type == "macro" and subType == "spell") then
				name = C_Spell.GetSpellName(id)
			elseif type == "item" or (type == "macro" and subType == "item") then
				name = C_Item.GetItemInfo(id)
			elseif type == "flyout" then
				--- @cast id number
				name = GetFlyoutInfo(id)
			elseif type == "summonpet" then
				--- @cast id string
				local speciesId, customName = C_PetJournal.GetPetInfoByPetID(id)
				name = customName or C_PetJournal.GetPetInfoBySpeciesID(speciesId)
			elseif type == "summonmount" then
				--- @cast id number
				name = C_MountJournal.GetMountInfoByID(id)
			end

			if name ~= nil and actionIcon ~= nil then
				Register(name, actionIcon)
			end
		end

		if db.showOnlyLoadedBindings then
			for _, binding in Clicked:IterateActiveBindings() do
				if showGroup == GROUP_ALL or binding.parent == showGroup then
					RegisterBinding(binding, true)
				end
			end
		else
			for _, binding in Clicked:IterateConfiguredBindings() do
				if showGroup == GROUP_ALL or binding.parent == showGroup then
					RegisterBinding(binding, Addon:TableContains(Addon:GetActiveBindings(), binding))
				end
			end
		end

		if showGroup == GROUP_ALL or showGroup == GROUP_EXT then
			-- Primary action bar
			for keyNumber = 1, 12 do
				RegisterAction("ACTIONBUTTON" .. keyNumber, keyNumber)
			end

			-- Shapeshift forms
			for form = 1, GetNumShapeshiftForms() do
				local targetKey = GetBindingKey("SHAPESHIFTBUTTON" .. form)

				if targetKey == key then
					local formIcon, _, _, spellId = GetShapeshiftFormInfo(form)
					local spellName = C_Spell.GetSpellName(spellId)
					Register(spellName, formIcon)
				end
			end

			-- Pet buttons
			for petAction = 1, NUM_PET_ACTION_SLOTS do
				local targetKey = GetBindingKey("BONUSACTIONBUTTON" .. petAction)

				if  targetKey == key then
					local name, actionIcon = GetPetActionInfo(petAction)
					Register(name, actionIcon)
				end
			end

			-- Bartender4 integration
			if _G["Bartender4"] then
				for actionBarNumber = 2, 6 do
					for keyNumber = 1, 12 do
						local actionBarButtonId = (actionBarNumber - 1) * 12 + keyNumber
						local bindingKeyName = "CLICK BT4Button" .. actionBarButtonId .. ":LeftButton"
						RegisterAction(bindingKeyName, keyNumber)
					end
				end
			-- ElvUI integration
			elseif _G["ElvUI"] and _G["ElvUI_Bar1Button1"] then
				for i = 2, 6 do
					for b = 1, 12 do
						local btn = _G["ElvUI_Bar" .. i .. "Button" .. b ]
						local slot = tonumber(btn._state_action)

						if slot ~= nil then
							RegisterAction(btn.keyBoundTarget, slot)
						end
					end
				end
			-- Default
			else
				for i = 25, 36 do
					RegisterAction("MULTIACTIONBAR3BUTTON" .. i - 24, i)
				end

				for i = 37, 48 do
					RegisterAction("MULTIACTIONBAR4BUTTON" .. i - 36, i)
				end

				for i = 49, 60 do
					RegisterAction("MULTIACTIONBAR2BUTTON" .. i - 48, i)
				end

				for i = 61, 72 do
					RegisterAction("MULTIACTIONBAR1BUTTON" .. i - 60, i)
				end
			end
		end

		local result = {}
		for spellName in pairs(spellNames) do
			table.insert(result, spellName)
		end

		return result, icon
	end

	if buttonCache == nil then
		return
	end

	for key, widget in pairs(buttonCache) do
		local data = widget:GetKey()

		if data ~= nil then
			local binds, icon = GetBinds(key)

			widget:SetIcon(icon)
			widget:SetHighlight(GetDb().highlightEmptyKeys and #binds == 0 and not data.disabled)
			widget:SetActionCount(#binds)

			widget:SetCallback("OnEnter", function()
				if not data.disabled then
					Addon:ShowTooltip(widget.frame, Addon:SanitizeKeybind(key), table.concat(binds, "\n"))
				end
			end)

			widget:SetCallback("OnLeave", function()
				Addon:HideTooltip()
			end)
		end
	end
end

--- Set the active key layout.
---
--- @param layout KeyboardLayout
--- @param size KeyboardSize
function KeyVisualizer:SetKeyboardLayout(layout, size)
	BuildLayout(layout, size)
	PopulateKeys()
end

function KeyVisualizer:Open()
	if self:IsOpen() then
		return
	end

	do
		local function OnClose(container)
			AceGUI:Release(container)

			showCtrl = false
			showAlt = false
			showShift = false
			showMeta = false
			showGroup = GROUP_ALL

			buttonCache = nil

			frame = nil --- @diagnostic disable-line: cast-local-type
		end

		frame = AceGUI:Create("ClickedFrame") --[[@as ClickedFrame]]
		frame:SetCallback("OnClose", OnClose)
		frame:SetTitle(Addon.L["Clicked Key Visualizer"])
		frame:SetLayout("Flow")
		frame:SetWidth(MIN_FRAME_WIDTH)
		frame:SetHeight(500)
		frame:EnableResize(false)
	end

	do
		local line = AceGUI:Create("InlineGroup") --[[@as AceGUIInlineGroup]]
		line:SetFullWidth(true)
		line:SetLayout("Table")
		line:SetUserData("table", {
			columns = { 0, 0, 125, 1, 75, 75, 75, 75 },
			spaceH = 1
		})

		do
			local widget = AceGUI:Create("CheckBox") --[[@as AceGUICheckBox]]
			widget:SetLabel(Addon.L["Show only loaded bindings"])
			widget:SetValue(GetDb().showOnlyLoadedBindings)
			widget:SetCallback("OnValueChanged", function(_, _, value)
				GetDb().showOnlyLoadedBindings = value
				SelectLayout()
			end)

			line:AddChild(widget)
		end

		do
			local widget = AceGUI:Create("CheckBox") --[[@as AceGUICheckBox]]
			widget:SetLabel(Addon.L["Highlight empty keys"])
			widget:SetValue(GetDb().highlightEmptyKeys)
			widget:SetCallback("OnValueChanged", function(_, _, value)
				GetDb().highlightEmptyKeys = value
				SelectLayout()
			end)

			line:AddChild(widget)
		end

		do
			--- @type table<string,string>
			local items = {
				[GROUP_ALL] = Addon.L["All"],
				[GROUP_EXT] = Addon.L["External"]
			}
			--- @type { id: string, name: string }[]
			local order = {}

			for _, group in Clicked:IterateGroups() do
				items[group.uid] = Addon:GetTextureString(group.name, group.displayIcon)
				table.insert(order, { id = group.uid, name = group.name })
			end

			table.sort(order, function(a, b) return a.name < b.name end)

			order = Addon:TableSelect(order, function(v) return v.id end)
			table.insert(order, 1, GROUP_ALL)
			table.insert(order, 2, GROUP_EXT)

			local widget = AceGUI:Create("Dropdown") --[[@as AceGUIDropdown]]
			widget:SetLabel(Addon.L["Filter bindings"])
			widget:SetList(items, order)
			widget:SetValue(GROUP_ALL)
			widget:SetCallback("OnValueChanged", function(_, _, value)
				showGroup = value
				SelectLayout()
			end)

			line:AddChild(widget)
		end

		do
			local widget = AceGUI:Create("Label") --[[@as AceGUILabel]]
			widget:SetText("")

			line:AddChild(widget)
		end

		do
			showCtrlWidget = AceGUI:Create("CheckBox") --[[@as AceGUICheckBox]]
			showCtrlWidget:SetLabel(Addon:SanitizeKeybind("CTRL"))
			showCtrlWidget:SetValue(showCtrl)
			showCtrlWidget:SetCallback("OnValueChanged", function(_, _, value)
				showCtrl = value
				SelectLayout()
			end)

			line:AddChild(showCtrlWidget)
		end

		do
			showAltWidget = AceGUI:Create("CheckBox") --[[@as AceGUICheckBox]]
			showAltWidget:SetLabel(Addon:SanitizeKeybind("ALT"))
			showAltWidget:SetValue(showAlt)
			showAltWidget:SetCallback("OnValueChanged", function(_, _, value)
				showAlt = value
				SelectLayout()
			end)

			line:AddChild(showAltWidget)
		end

		do
			showShiftWidget = AceGUI:Create("CheckBox") --[[@as AceGUICheckBox]]
			showShiftWidget:SetLabel(Addon:SanitizeKeybind("SHIFT"))
			showShiftWidget:SetValue(showShift)
			showShiftWidget:SetCallback("OnValueChanged", function(_, _, value)
				showShift = value
				SelectLayout()
			end)

			line:AddChild(showShiftWidget)
		end

		do
			showMetaWidget = AceGUI:Create("CheckBox") --[[@as AceGUICheckBox]]
			showMetaWidget:SetLabel(Addon:SanitizeKeybind("META"))
			showMetaWidget:SetValue(showMeta)
			showMetaWidget:SetCallback("OnValueChanged", function(_, _, value)
				showMeta = value
				SelectLayout()
			end)

			line:AddChild(showMetaWidget)
		end

		frame:AddChild(line)
	end

	do
		local function DrawTreeContainer(container, _, value)
			local group = { strsplit("\001", value) }
			local layout = group[1] or DEFAULT_KEYBOARD_LAYOUT --[[@as KeyboardLayout]]
			local size = tonumber(group[2]) or DEFAULT_KEYBOARD_SIZE --[[@as KeyboardSize]]

			local db = GetDb()

			if layout ~= db.lastKeyboardLayout or size ~= db.lastKeyboardSize or buttonCache == nil then
				db.lastKeyboardLayout = layout
				db.lastKeyboardSize = size

				container:ReleaseChildren()
				self:SetKeyboardLayout(layout, size)
			else
				PopulateKeys()
			end
		end

		tree = AceGUI:Create("ClickedKeyVisualizerTreeGroup") --[[@as ClickedKeyVisualizerTreeGroup]]
		tree:SetLayout("ClickedKeys")
		tree:SetFullWidth(true)
		tree:SetFullHeight(true)
		tree:SetCallback("OnGroupSelected", DrawTreeContainer)
		tree:SetTreeWidth(125, false)
		tree:SetTree(GetTreeLayout())
		SelectLayout()

		frame:AddChild(tree)
	end
end

function KeyVisualizer:Close()
	if not self:IsOpen() then
		return
	end

	frame:Hide()
end

function KeyVisualizer:Redraw()
	if not self:IsOpen() then
		return
	end

	SelectLayout()
end

--- @return boolean
function KeyVisualizer:IsOpen()
	return frame ~= nil and frame:IsVisible()
end

Addon.KeyVisualizer = KeyVisualizer

local modifierFrame = CreateFrame("Frame")
modifierFrame:RegisterEvent("MODIFIER_STATE_CHANGED")
modifierFrame:SetScript("OnEvent", function(_, event, key, state)
    if not Addon.KeyVisualizer:IsOpen() or event ~= "MODIFIER_STATE_CHANGED" then
		return
	end

	local down = state == 1

	if key == "LSHIFT" or key == "RSHIFT" then
		showShift = down
		showShiftWidget:SetValue(down)
	elseif key == "LCTRL" or key == "RCTRL" then
		showCtrl = down
		showCtrlWidget:SetValue(down)
	elseif key == "LALT" or key == "RALT" then
		showAlt = down
		showAltWidget:SetValue(down)
	elseif key == "LMETA" or key == "RMETA" then
		showMeta = down
		showMetaWidget:SetValue(down)
	end

	SelectLayout()
end)
