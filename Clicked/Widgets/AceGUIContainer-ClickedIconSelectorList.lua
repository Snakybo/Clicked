-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2026 Kevin Krol
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

--[[-----------------------------------------------------------------------------
A scrollframe container that displays a large list of icons, loading them over
time to improve performance.
-------------------------------------------------------------------------------]]

--- @class Addon
local Addon = select(2, ...)

local TYPE, VERSION = "ClickedIconSelectorList", 3
local AceGUI = LibStub("AceGUI-3.0")

if (AceGUI:GetWidgetVersion(TYPE) or 0) >= VERSION then
	return
end

local ICON_SIZE = 32

--- @alias AceGUIWidgetType
--- | "ClickedIconSelectorList"

--- @class ClickedIconSelectorList.LoadQueue
--- @field public button AceGUIIcon
--- @field public id integer
--- @field public icon string

--- @class ClickedIconSelectorList.Status
--- @field public scrollframe number?
--- @field public contentHeight number
--- @field public scrollvalue number
--- @field public numRows number
--- @field public numColumns number

--- @class ClickedIconSelectorList : AceGUIContainer
--- @field public content Frame&{obj: self}
--- @field public frame Frame&{obj: self}
--- @field public type string
--- @field protected status ClickedIconSelectorList.Status?
--- @field protected localstatus ClickedIconSelectorList.Status
--- @field protected scrollframe ScrollFrame&{obj: self}
--- @field protected buttons AceGUIIcon[]
--- @field protected icons string[]
--- @field protected order integer[]
--- @field protected loadQueue ClickedIconSelectorList.LoadQueue[]
--- @field protected scrollbar Slider&{obj: self}
--- @field protected searchHandler ClickedSearchBox?
--- @field protected originalWidth number
--- @field protected updateLock boolean?
--- @field protected scrollBarShown boolean?
local ClickedIconSelectorList = {}

--- @protected
function ClickedIconSelectorList:OnAcquire()
	self.localstatus = { scrollvalue = 0, contentHeight = 0, numRows = 0, numColumns = 0 }
	self.updateLock = false
	self.originalWidth = 0
	self.scrollframe:SetPoint("BOTTOMRIGHT")
	self.scrollframe:SetScript("OnUpdate", ClickedIconSelectorList.ScrollFrame_OnUpdate)
	self:SetScroll(0)
end

--- @protected
function ClickedIconSelectorList:OnRelease()
	self.status = nil

	if self.searchHandler ~= nil then
		self.searchHandler:SetCallback("SearchTermChanged", function() end)
	end

	self.icons = {}
	self.order = {}

	wipe(self.buttons)
	wipe(self.loadQueue)

	self.scrollBarShown = nil
	self.searchHandler = nil
end

--- @param value number
function ClickedIconSelectorList:SetScroll(value)
	local status = self.status or self.localstatus
	value = math.floor(value)

	if value ~= status.scrollvalue then
		status.scrollvalue = value
		self:RefreshIcons()
	end
end

--- @param value number
function ClickedIconSelectorList:MoveScroll(value)
	local status = self.status or self.localstatus
	local height, viewheight = self.scrollframe:GetHeight(), status.contentHeight

	if self.scrollBarShown then
		local diff = height - viewheight
		local delta = 1
		if value < 0 then
			delta = -1
		end

		self.scrollbar:SetValue(math.min(math.max(status.scrollvalue + delta * (1000 / (diff / 45)), 0), math.ceil(status.numRows / 2)))
	end
end

--- @param handler ClickedSearchBox
function ClickedIconSelectorList:SetSearchHandler(handler)
	if handler == self.searchHandler then
		return
	end

	if self.searchHandler ~= nil then
		self.searchHandler:SetCallback("SearchTermChanged", function() end)
	end

	self.searchHandler = handler
	self.searchHandler:SetCallback("SearchTermChanged", function()
		self:RefreshIcons()
	end)

	self:RefreshIcons()
end

--- @param icons string[]
--- @param order integer[]
function ClickedIconSelectorList:SetIcons(icons, order)
	self.icons =  icons
	self.order = order

	self:FixScroll()
	self.scrollframe:SetScript("OnUpdate", ClickedIconSelectorList.ScrollFrame_OnUpdate)
end

--- @protected
function ClickedIconSelectorList:RefreshIcons()
	for _, v in ipairs(self.buttons) do
		v.frame:Hide()
	end

	if self.icons == nil or #self.order == 0 then
		return
	end

	if self.content:GetWidth() == nil or self.content:GetWidth() < ICON_SIZE then
		return
	end

	local icons = {}
	local order = {}

	if self.searchHandler ~= nil and #self.searchHandler:GetSearchTerm() > 0 then
		local searchTerm = string.gsub(string.lower(self.searchHandler:GetSearchTerm()), "%s+", "_")

		for k, v in pairs(self.icons) do
			local id = tostring(k)
			local name = string.lower(self.icons[k])

			if string.match(name, searchTerm) or string.match(id, searchTerm) then
				icons[k] = v
				table.insert(order, k)
			end
		end

		table.sort(order)
	else
		icons = self.icons
		order = self.order
	end

	local status = self.status or self.localstatus
	local viewHeight = self.scrollframe:GetHeight()
	local viewRows = math.floor(viewHeight / (ICON_SIZE + 4))

	status.numColumns = math.floor(self.content:GetWidth() / (ICON_SIZE + 4))
	status.numRows = math.max(math.ceil(#order / status.numColumns) - viewRows, 0)
	status.contentHeight = math.floor(status.numRows * (ICON_SIZE + 4))

	local numIcons = viewRows * status.numColumns
	local offset = (status.scrollvalue * 2) * status.numColumns

	self.loadQueue = {}

	for i = 1, numIcons do
		local button = self.buttons[i]

		if button == nil then
			button = AceGUI:Create("Icon")
			button:SetImageSize(ICON_SIZE, ICON_SIZE)
			button:SetWidth(ICON_SIZE + 4)
			button:SetHeight(ICON_SIZE)

			self.buttons[i] = button

			self:AddChild(button)
		end

		if order[offset + i] ~= nil then
			table.insert(self.loadQueue, {
				button = button,
				id = order[offset + i],
				icon = "Interface\\ICONS\\" .. icons[order[offset + i]]
			})
		end
	end

	self.scrollbar:SetMinMaxValues(0, math.ceil(status.numRows / 2))
end

--- @param status ClickedIconSelectorList.Status
function ClickedIconSelectorList:SetStatusTable(status)
	assert(type(status) == "table")

	self.status = status
	if not status.scrollvalue then
		status.scrollvalue = 0
	end
end

--- @protected
function ClickedIconSelectorList:FixScroll()
	if self.updateLock then
		return
	end

	self.updateLock = true

	if not self.scrollBarShown then
		self.scrollBarShown = true
		self.scrollbar:Show()
		self.scrollframe:SetPoint("BOTTOMRIGHT", -20, 0)
		if self.originalWidth ~= 0 then
			self.content.width = self.originalWidth - 20
		end
		self:DoLayout()
	end

	self:RefreshIcons()

	local status = self.status or self.localstatus

	self.scrollbar:SetValue(status.scrollvalue)
	self:SetScroll(status.scrollvalue)

	self.updateLock = nil
end

--- @protected
--- @param width? integer
--- @param height? integer
function ClickedIconSelectorList:LayoutFinished(width, height)
	self.content:SetHeight(height or 20)

	self:FixScroll()
	self.scrollframe:SetScript("OnUpdate", ClickedIconSelectorList.ScrollFrame_OnUpdate)
end

--- @protected
--- @param width integer
function ClickedIconSelectorList:OnWidthSet(width)
	local content = self.content
	content.width = width - (self.scrollBarShown and 20 or 0)
	self.originalWidth = width
end

--- @protected
--- @param height integer
function ClickedIconSelectorList:OnHeightSet(height)
	local content = self.content
	content.height = height
end



--- @protected
--- @param frame Frame&{obj: ClickedIconSelectorList}
function ClickedIconSelectorList.Frame_Update(frame)
	local self = frame.obj
	local status = self.status or self.localstatus

	if #self.loadQueue == 0 then
		return
	end

	for _ = 1, math.min(status.numColumns * 9, #self.loadQueue) do
		local next = self.loadQueue[1]
		table.remove(self.loadQueue, 1)

		local button = next.button

		button:SetCallback("OnEnter", function()
			Addon:ShowTooltip(button.frame, next.icon .. "\n" .. next.id)
		end)

		button:SetCallback("OnLeave", function()
			Addon:HideTooltip()
		end)

		button:SetCallback("OnClick", function()
			self:Fire("OnIconSelected", next.icon)
		end)

		button:SetImage(next.icon)
		button.frame:Show()
	end
end

--- @protected
--- @param frame ScrollFrame&{obj: ClickedIconSelectorList}
--- @param value number
function ClickedIconSelectorList.ScrollFrame_OnMouseWheel(frame, value)
	frame.obj:MoveScroll(value)
end

--- @protected
--- @param frame ScrollFrame&{obj: ClickedIconSelectorList}
function ClickedIconSelectorList.ScrollFrame_OnUpdate(frame)
	frame:SetScript("OnUpdate", nil)
	frame.obj:FixScroll()
end

--- @protected
--- @param frame ScrollFrame&{obj: ClickedIconSelectorList}
function ClickedIconSelectorList.ScrollFrame_OnSizeChanged(frame)
	frame:SetScript("OnUpdate", ClickedIconSelectorList.ScrollFrame_OnUpdate)
end

--- @protected
--- @param frame Slider&UIPanelScrollBarTemplate&{obj: ClickedIconSelectorList}
--- @param value number
function ClickedIconSelectorList.ScrollBar_OnScrollValueChanged(frame, value)
	frame.obj:SetScroll(value)
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
--- @return ClickedIconSelectorList
local function Constructor()
	--- @class ClickedIconSelectorList
	local widget = {}
	widget.type = TYPE

	local num = AceGUI:GetNextWidgetNum(TYPE)

	local frame = CreateFrame("Frame", nil, UIParent)
	frame:Hide()
	frame:SetScript("OnUpdate", ClickedIconSelectorList.Frame_Update)
	frame.obj = widget

	local scrollframe = CreateFrame("ScrollFrame", nil, frame)
	scrollframe:SetPoint("TOPLEFT")
	scrollframe:SetPoint("BOTTOMRIGHT")
	scrollframe:EnableMouseWheel(true)
	scrollframe:SetScript("OnMouseWheel", ClickedIconSelectorList.ScrollFrame_OnMouseWheel)
	scrollframe:SetScript("OnSizeChanged", ClickedIconSelectorList.ScrollFrame_OnSizeChanged)
	scrollframe.obj = widget

	local scrollbar = CreateFrame("Slider", ("AceConfigDialogScrollFrame%dScrollBar"):format(num), scrollframe, "UIPanelScrollBarTemplate")
	scrollbar:SetPoint("TOPLEFT", scrollframe, "TOPRIGHT", 4, -16)
	scrollbar:SetPoint("BOTTOMLEFT", scrollframe, "BOTTOMRIGHT", 4, 16)
	scrollbar:SetMinMaxValues(0, 1000)
	scrollbar:SetValueStep(1)
	scrollbar:SetValue(0)
	scrollbar:SetWidth(16)
	scrollbar:Hide()
	scrollbar:SetScript("OnValueChanged", ClickedIconSelectorList.ScrollBar_OnScrollValueChanged)
	scrollbar.obj = widget

	local scrollbg = scrollbar:CreateTexture(nil, "BACKGROUND")
	scrollbg:SetAllPoints(scrollbar)
	scrollbg:SetColorTexture(0, 0, 0, 0.4)

	--Container Support
	local content = CreateFrame("Frame", nil, scrollframe)
	content:SetPoint("TOPLEFT")
	content:SetPoint("TOPRIGHT")
	content:SetHeight(400)
	content.obj = widget

	-- Respect ElvUI skinning
	if C_AddOns.GetAddOnEnableState("ElvUI", UnitName("player")) > 0 then
		--- @diagnostic disable-next-line: unknown-local-type
		local E = unpack(ElvUI);

		if E and E.private.skins and E.private.skins.ace3Enable then
			--- @diagnostic disable-next-line: unknown-local-type
			local S = E:GetModule("Skins")
			S:HandleScrollBar(scrollbar)
		end
	end

	widget.frame = frame
	widget.content = content
	widget.scrollframe = scrollframe
	widget.scrollbar = scrollbar
	widget.buttons = {}
	widget.icons = {}
	widget.order = {}
	widget.loadQueue = {}

	for method, func in pairs(ClickedIconSelectorList) do
		widget[method] = func
	end

	--- TEMP: This cast can be removed once https://github.com/TradeSkillMaster/wowlua-ls/pull/65 is merged
	return AceGUI:RegisterAsContainer(widget) --[[@as ClickedIconSelectorList]]
end

AceGUI:RegisterWidgetType(TYPE, Constructor, VERSION)
