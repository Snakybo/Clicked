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
local LibMacroSyntaxHighlight = LibStub("LibMacroSyntaxHighlight-1.0")

--- @class ClickedInternal
local Addon = select(2, ...)

-- Private addon API

Addon.BindingConfig = Addon.BindingConfig or {}

--- @class BindingConfigStatusTab : BindingConfigTab
--- @field private selected integer
--- @field private references integer[]
Addon.BindingConfig.BindingStatusTab = {
	selected = 1,
	references = {}
}

--- @protected
function Addon.BindingConfig.BindingStatusTab:Hide()
	self.selected = 1
	table.wipe(self.references)
end

--- @protected
function Addon.BindingConfig.BindingStatusTab:Redraw()
	if #self.bindings > 1 then
		--- @param index integer
		--- @return string
		local function IndexToString(index)
			return "item_" .. index
		end

		--- @param str string
		--- @return integer
		local function StringToIndex(str)
			--- @diagnostic disable-next-line: return-type-mismatch
			return tonumber(string.sub(str, 6))
		end

		local function OnValueChanged(_, _, value)
			self.selected = StringToIndex(value)
			self.controller:RedrawTab()
		end

		local items = {}
		local order = {}

		for i, binding in ipairs(self.bindings) do
			local key = IndexToString(i)
			local name, icon = Addon:GetBindingNameAndIcon(binding)
			items[key] = Addon:GetTextureString(name, icon)

			table.insert(order, key)
		end

		local dropdown = AceGUI:Create("Dropdown") --[[@as AceGUIDropdown]]
		dropdown:SetLabel(Addon.L["Select binding from selection"])
		dropdown:SetFullWidth(true)
		dropdown:SetList(items, order)
		dropdown:SetValue(IndexToString(self.selected))
		dropdown:SetCallback("OnValueChanged", OnValueChanged)

		self.container:AddChild(dropdown)
	end

	self:RedrawPage()
end

--- @protected
--- @param relevant boolean
--- @param changed integer[]
function Addon.BindingConfig.BindingStatusTab:OnBindingReload(relevant, changed)
	if relevant then
		self.controller:RedrawTab()
		return
	end

	local binding = self.bindings[self.selected]

	if binding ~= nil then
		for _, uid in ipairs(self.references) do
			if tContains(changed, uid) then
				self.controller:RedrawTab()
				return
			end
		end

		for _, other in Clicked:IterateActiveBindings() do
			if other.keybind == binding.keybind and tContains(changed, other.uid) then
				self.controller:RedrawTab()
				return
			end
		end
	end
end

--- @private
function Addon.BindingConfig.BindingStatusTab:RedrawPage()
	local binding = self.bindings[self.selected]
	if binding == nil then
		return
	end

	local function DrawStatus(bindings, interactionType)
		if #bindings == 0 then
			return
		end

		local MAX_MACRO_LENGTH = 255

		local text = Addon:GetMacroForBindings(bindings, interactionType)
		local label = interactionType == Addon.InteractionType.HOVERCAST and Addon.L["Generated hovercast macro (%d/%d)"] or Addon.L["Generated macro (%d/%d)"]

		label = string.format(label, strlenutf8(text), MAX_MACRO_LENGTH)

		if #text > MAX_MACRO_LENGTH then
			label = RED_FONT_COLOR:WrapTextInColorCode(label)
		end

		text = LibMacroSyntaxHighlight:Colorize(text)

		local widget = AceGUI:Create("MultiLineEditBox") --[[@as AceGUIMultiLineEditBox]]
		widget:SetLabel(label)
		widget:SetText(text)
		widget:SetFullWidth(true)
		widget:SetNumLines(8)
		widget:DisableButton(true)
		widget:SetCallback("OnTextChanged", function()
			widget:SetText(text)
		end)

		Addon.Media:UseMonoFont(widget)

		self.container:AddChild(widget)
	end

	--- @type Binding[]
	local hovercast = {}

	--- @type Binding[]
	local regular = {}

	--- @type Binding[]
	local all = {}

	table.wipe(self.references)

	for _, other in Clicked:IterateActiveBindings() do
		if other.keybind == binding.keybind then
			local valid = false

			if Addon:IsHovercastEnabled(binding) and Addon:IsHovercastEnabled(other) then
				table.insert(hovercast, other)
				valid = true
			end

			if Addon:IsMacroCastEnabled(binding) and Addon:IsMacroCastEnabled(other) then
				table.insert(regular, other)
				valid = true
			end

			if valid then
				table.insert(all, other)
				table.insert(self.references, other.uid)
			end
		end
	end

	DrawStatus(hovercast, Addon.InteractionType.HOVERCAST)
	DrawStatus(regular, Addon.InteractionType.REGULAR)

	if #all > 1 then
		table.sort(all, function (left, right)
			return Addon:GetBindingNameAndIcon(left) < Addon:GetBindingNameAndIcon(right)
		end)

		do
			local widget = AceGUI:Create("Heading") --[[@as AceGUIHeading]]
			widget:SetFullWidth(true)
			widget:SetText(Addon.L["%d related binding(s)"]:format(#all - 1))

			self.container:AddChild(widget)
		end

		for _, other in ipairs(all) do
			if other ~= binding then
				do
					local function OnClick()
						Addon.BindingConfig.Window:Select(other.uid)
					end

					local name, icon = Addon:GetBindingNameAndIcon(other)

					local widget = AceGUI:Create("InteractiveLabel") --[[@as AceGUIInteractiveLabel]]
					widget:SetFontObject(GameFontHighlight)
					widget:SetText(name)
					widget:SetImage(icon)
					widget:SetFullWidth(true)
					widget:SetCallback("OnClick", OnClick)

					self.container:AddChild(widget)
				end
			end
		end
	end
end
