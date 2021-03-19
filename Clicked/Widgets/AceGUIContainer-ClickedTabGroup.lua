--[[-----------------------------------------------------------------------------
TabGroup Container
Container that uses tabs on top to switch between groups.
-------------------------------------------------------------------------------]]
local Type, Version = "ClickedTabGroup", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- local upvalue storage used by BuildTabs
local widths = {}
local rowwidths = {}
local rowends = {}

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["BuildTabs"] = function(self)
		local hastitle = (self.titletext:GetText() and self.titletext:GetText() ~= "")
		local tablist = self.tablist
		local tabs = self.tabs

		if not tablist then return end

		local width = self.frame.width or self.frame:GetWidth() or 0

		wipe(widths)
		wipe(rowwidths)
		wipe(rowends)

		--Place Text into tabs and get thier initial width
		for i, v in ipairs(tablist) do
			local tab = tabs[i]
			if not tab then
				tab = self:CreateTab(i)
				tabs[i] = tab
			end

			tab:Show()
			tab:SetText(v.text)
			tab:SetDisabled(v.disabled)
			tab.value = v.value

			widths[i] = tab:GetWidth() - 6 --tabs are anchored 10 pixels from the right side of the previous one to reduce spacing, but add a fixed 4px padding for the text
		end

		for i = (#tablist)+1, #tabs, 1 do
			tabs[i]:Hide()
		end

		--First pass, find the minimum number of rows needed to hold all tabs and the initial tab layout
		local numtabs = #tablist
		local numrows = 1
		local usedwidth = 0

		for i = 1, #tablist do
			--If this is not the first tab of a row and there isn't room for it
			if usedwidth ~= 0 and (width - usedwidth - widths[i]) < 0 then
				rowwidths[numrows] = usedwidth + 10 --first tab in each row takes up an extra 10px
				rowends[numrows] = i - 1
				numrows = numrows + 1
				usedwidth = 0
			end
			usedwidth = usedwidth + widths[i]
		end
		rowwidths[numrows] = usedwidth + 10 --first tab in each row takes up an extra 10px
		rowends[numrows] = #tablist

		--Fix for single tabs being left on the last row, move a tab from the row above if applicable
		if numrows > 1 then
			--if the last row has only one tab
			if rowends[numrows-1] == numtabs-1 then
				--if there are more than 2 tabs in the 2nd last row
				if (numrows == 2 and rowends[numrows-1] > 2) or (rowends[numrows] - rowends[numrows-1] > 2) then
					--move 1 tab from the second last row to the last, if there is enough space
					if (rowwidths[numrows] + widths[numtabs-1]) <= width then
						rowends[numrows-1] = rowends[numrows-1] - 1
						rowwidths[numrows] = rowwidths[numrows] + widths[numtabs-1]
						rowwidths[numrows-1] = rowwidths[numrows-1] - widths[numtabs-1]
					end
				end
			end
		end

		--anchor the rows as defined and resize tabs to fill thier row
		local starttab = 1
		for row, endtab in ipairs(rowends) do
			local first = true
			for tabno = starttab, endtab do
				local tab = tabs[tabno]
				tab:ClearAllPoints()
				if first then
					tab:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, -(hastitle and 14 or 7)-(row-1)*20 )
					first = false
				else
					tab:SetPoint("LEFT", tabs[tabno-1], "RIGHT", -10, 0)
				end
			end

			for i = starttab, endtab do
				PanelTemplates_TabResize(tabs[i], 4, nil, nil, width, tabs[i]:GetFontString():GetStringWidth())
			end
			starttab = endtab + 1
		end

		self.borderoffset = (hastitle and 17 or 10)+((numrows)*20)
		self.border:SetPoint("TOPLEFT", 1, -self.borderoffset)
	end,
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	local widget = AceGUI:Create("TabGroup")
	widget.type = type

	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
