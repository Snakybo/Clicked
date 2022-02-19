--- @type ClickedInternal
local _, Addon = ...

--- @type Localization
local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

local lastTooltipUpdateTime

-- Local support functions

--- Check if the specified `keybind` is valid for the modifier keys that are currently pressed.
---
--- @param keybind string
--- @return boolean
local function IsKeybindValidForCurrentModifiers(keybind)
	local mods = {}
	local current = {
		count = 0
	}

	for match in string.gmatch(keybind, "[^-]+") do
		table.insert(mods, match)
	end

	table.remove(mods, #mods)

	if #mods == 0 and IsModifierKeyDown() then
		return false
	end

	if IsControlKeyDown() then
		current["CTRL"] = true
		current.count = current.count + 1
	end

	if IsAltKeyDown() then
		current["ALT"] = true
		current.count = current.count + 1
	end

	if IsShiftKeyDown() then
		current["SHIFT"] = true
		current.count = current.count + 1
	end

	if IsMetaKeyDown ~= nil and IsMetaKeyDown() then
		current["META"] = true
		current.count = current.count + 1
	end

	if #mods ~= current.count then
		return
	end

	for _, mod in ipairs(mods) do
		if not current[mod] then
			return false
		end
	end

	return true
end

--- Check if the tooltips module is enabled in the user settings.
---
--- @return boolean
local function IsTooltipModuleEnabled()
	return Addon.db.profile.options.tooltips
end

--- @param left Binding
--- @param right Binding
--- @return boolean
local function SortBindings(left, right)
	return Addon:CompareBindings(left, right)
end

--- @param self table
local function OnTooltipSetUnit(self)
	if not IsTooltipModuleEnabled() then
		return
	end

	local _, unit = self:GetUnit()

	if Addon:IsStringNilOrEmpty(unit) or lastTooltipUpdateTime == GetTime() then
		return
	end

	lastTooltipUpdateTime = GetTime()

	local bindings = Clicked:GetBindingsForUnit(unit)
	local first = true

	table.sort(bindings, SortBindings)

	for _, binding in ipairs(bindings) do
		if IsKeybindValidForCurrentModifiers(binding.keybind) then
			local left = Addon:GetSimpleSpellOrItemInfo(binding)
			local right = Addon:SanitizeKeybind(binding.keybind)

			if first then
				self:AddLine(" ")
				self:AddLine(L["Abilities"], 1, 0.85, 0)
				first = false
			end

			self:AddDoubleLine(left, right, 1, 1, 1, 0, 1, 0)
		end
	end
end

--- @param self table
local function OnTooltipSetSpell(self)
	if self:IsForbidden() then
		return
	end

	local _, spellId = self:GetSpell()

	if spellId == nil or lastTooltipUpdateTime == GetTime()then
		return
	end

	lastTooltipUpdateTime = GetTime()

	--- @type Binding
	for _, binding in Clicked:IterateActiveBindings() do
		if binding.type == Addon.BindingTypes.SPELL and binding.action.spellValue == spellId then
			local text = string.format(L["Bound to %s"], Addon:SanitizeKeybind(binding.keybind))
			self:AddLine(text, LIGHTBLUE_FONT_COLOR.r, LIGHTBLUE_FONT_COLOR.g, LIGHTBLUE_FONT_COLOR.b)
		end
	end
end

-- Private addon API

function Addon:AbilityTooltips_Initialize()
	-- Add a delay here to make sure we're the always at the bottom of the tooltip
	C_Timer.After(1, function()
		GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)
	end)

	GameTooltip:HookScript("OnTooltipSetSpell", OnTooltipSetSpell)

	if ElvUISpellBookTooltip ~= nil then
		ElvUISpellBookTooltip:HookScript("OnTooltipSetSpell", OnTooltipSetSpell)
	end
end

function Addon:AbilityTooltips_Refresh()
	if not IsTooltipModuleEnabled() then
		return
	end

	if not GameTooltip:IsForbidden() and GameTooltip:IsShown() and GetTime() ~= lastTooltipUpdateTime then
		local _, unit = GameTooltip:GetUnit()

		if not Addon:IsStringNilOrEmpty(unit) then
			GameTooltip:SetUnit(unit)
		end
	end
end
