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

--- @class ClickedInternal
local Addon = select(2, ...)

--- @type number?
local lastTooltipUpdateTime

--- @type string?
local lastTooltipUnit

--- @type { left: string, right: string }[]
local lineCache = {}

--- @type boolean
local rebuild

-- Local support functions

--- Check if the specified `keybind` is valid for the modifier keys that are currently pressed.
---
--- @param keybind string
--- @return boolean
local function IsKeybindValidForCurrentModifiers(keybind)
	--- @type string[]
	local mods = {}

	--- @type { [string]: boolean, count: integer }
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
		return false
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

local function OnTooltipHide()
	rebuild = true
end

--- @param self GameTooltip
local function OnTooltipSetUnit(self)
	if self:IsForbidden() or self.GetUnit == nil or not IsTooltipModuleEnabled() then
		return
	end

	local unit = select(2, self:GetUnit())
	if Addon:IsNilOrEmpty(unit) or lastTooltipUpdateTime == GetTime() then
		return
	end

	rebuild = rebuild or unit ~= lastTooltipUnit
	lastTooltipUpdateTime = GetTime()
	lastTooltipUnit = unit --[[@as string?]]

	if rebuild then
		rebuild = false

		local bindings = Clicked:GetBindingsForUnit(unit)
		table.sort(bindings, SortBindings)
		table.wipe(lineCache)

		for _, binding in ipairs(bindings) do
			if IsKeybindValidForCurrentModifiers(binding.keybind) then
				local left = Addon:GetSimpleSpellOrItemInfo(binding)
				local right = Addon:SanitizeKeybind(binding.keybind)

				table.insert(lineCache, { left = left, right = right })
			end
		end
	end

	if #lineCache > 0 then
		self:AddLine(" ")
		self:AddLine(Addon.L["Abilities"], 1, 0.85, 0)

		for _, line in ipairs(lineCache) do
			self:AddDoubleLine(line.left, line.right, 1, 1, 1, 0, 1, 0)
		end
	end
end

--- @param self GameTooltip
local function OnTooltipSetSpell(self)
	if self:IsForbidden() or self.GetSpell == nil then
		return
	end

	local _, spellId = self:GetSpell()

	if spellId == nil then
		return
	end

	local addedEmptyLine = false

	--- @type Binding
	for _, binding in Clicked:IterateActiveBindings() do
		if binding.actionType == Clicked.ActionType.SPELL and binding.action.spellValue == spellId then
			local text = string.format(Addon.L["Bound to %s"], Addon:SanitizeKeybind(binding.keybind))

			if not addedEmptyLine then
				self:AddLine(" ", 1, 1, 1)
				addedEmptyLine = true
			end

			self:AddLine(text, LIGHTBLUE_FONT_COLOR.r, LIGHTBLUE_FONT_COLOR.g, LIGHTBLUE_FONT_COLOR.b)
		end
	end
end

-- Private addon API

function Addon:AbilityTooltips_Initialize()
	-- Add a delay here to make sure we're the always at the bottom of the tooltip
	C_Timer.After(1, function()
		if Addon.EXPANSION_LEVEL >= Addon.Expansion.DF then
			TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, OnTooltipSetUnit)
		else
			GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)
		end

		GameTooltip:HookScript("OnHide", OnTooltipHide)
	end)

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.DF then
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, OnTooltipSetSpell)
	else
		GameTooltip:HookScript("OnTooltipSetSpell", OnTooltipSetSpell)

		if ElvUISpellBookTooltip ~= nil then
			ElvUISpellBookTooltip:HookScript("OnTooltipSetSpell", OnTooltipSetSpell)
		end
	end
end

function Addon:AbilityTooltips_Refresh()
	if not IsTooltipModuleEnabled() then
		return
	end

	if not GameTooltip:IsForbidden() and GameTooltip:IsShown() and GetTime() ~= lastTooltipUpdateTime then
		local _, unit = GameTooltip:GetUnit()

		if not Addon:IsNilOrEmpty(unit) then
			rebuild = true
			GameTooltip:SetUnit(unit)
		end
	end
end
