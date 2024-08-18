--[[-----------------------------------------------------------------------------
TabGroup Container
Container that uses tabs on top to switch between groups.
-------------------------------------------------------------------------------]]

--- @diagnostic disable-next-line: duplicate-doc-alias
--- @alias AceGUIWidgetType
--- | "ClickedTabGroup"

local Type, Version = "ClickedTabGroup", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then
	return
end

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]

--- @param tab any
--- @param padding number
--- @param absoluteSize? number
--- @param minWidth? number
--- @param maxWidth? number
--- @param absoluteTextSize? number
local function TabResize(tab, padding, absoluteSize, minWidth, maxWidth, absoluteTextSize)
	local tabName = tab:GetName();

	local buttonMiddle = tab.Middle or tab.middleTexture or _G[tabName.."Middle"];
	local buttonMiddleDisabled = tab.MiddleDisabled or (tabName and _G[tabName.."MiddleDisabled"]);
	local left = tab.Left or tab.leftTexture or _G[tabName.."Left"];
	local sideWidths = 2 * left:GetWidth();
	local tabText = tab.Text or _G[tab:GetName().."Text"];
	local highlightTexture = tab.HighlightTexture or (tabName and _G[tabName.."HighlightTexture"]);

	local width, tabWidth;
	local textWidth;
	if ( absoluteTextSize ) then
		textWidth = absoluteTextSize;
	else
		tabText:SetWidth(0);
		textWidth = tabText:GetWidth();
	end
	-- If there's an absolute size specified then use it
	if ( absoluteSize ) then
		if ( absoluteSize < sideWidths) then
			width = 1;
			tabWidth = sideWidths
		else
			width = absoluteSize - sideWidths;
			tabWidth = absoluteSize
		end
		tabText:SetWidth(width);
	else
		-- Otherwise try to use padding
		if ( padding ) then
			width = textWidth + padding;
		else
			width = textWidth + 24;
		end
		-- If greater than the maxWidth then cap it
		if ( maxWidth and width > maxWidth ) then
			if ( padding ) then
				width = maxWidth + padding;
			else
				width = maxWidth + 24;
			end
			tabText:SetWidth(width);
		else
			tabText:SetWidth(0);
		end
		if (minWidth and width < minWidth) then
			width = minWidth;
		end
		tabWidth = width + sideWidths;
	end

	if ( buttonMiddle ) then
		buttonMiddle:SetWidth(width);
	end
	if ( buttonMiddleDisabled ) then
		buttonMiddleDisabled:SetWidth(width);
	end

	tab:SetWidth(tabWidth);

	if ( highlightTexture ) then
		highlightTexture:SetWidth(tabWidth);
	end
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

--- @class ClickedTabGroup : AceGUITabGroup
local Methods = {}

--- @param tabs AceGUITabGroupTab[]
function Methods:SetTabs(tabs)
	self:BaseSetTabs(tabs)

	local status = self.status or self.localstatus

	for _, v in ipairs(self.tabs) do
		--- @diagnostic disable-next-line: undefined-field
		v:SetSelected(v.value == status.selected)
	end
end

--- @protected
function Methods:BuildTabs()
	self:BaseBuildTabs()

	if self.tablist == nil then
		return
	end

	local width = self.frame:GetWidth() or 0

	for _, tab in ipairs(self.tabs) do
		local textWidth = tab:GetFontString():GetStringWidth()
		TabResize(tab, 4, nil, nil, width, textWidth)
	end
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	--- @class ClickedTabGroup
	local widget = AceGUI:Create("TabGroup") --[[@as AceGUITabGroup]]
	widget.type = Type

	--- @private
	widget.BaseBuildTabs = widget.BuildTabs
	--- @private
	widget.BaseSetTabs = widget.SetTabs

	for method, func in pairs(Methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
