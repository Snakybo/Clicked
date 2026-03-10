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

--- @class (partial) Addon
local Addon = select(2, ...)

local isInitialized = false
local isPlayerInCombat = false
local wasHouseEditorActive = false

--- @type table<string, boolean>
local playerFlagsCache = {}

local function PLAYER_REGEN_DISABLED()
	Clicked2:LogVerbose("Received event {eventName}", "PLAYER_REGEN_DISABLED")

	isPlayerInCombat = true

	Addon.BindingConfig.Window:Close()

	if Addon:IsCombatProcessRequired() then
		Clicked2:ProcessActiveBindings()
	end
end

local function PLAYER_REGEN_ENABLED()
	Clicked2:LogVerbose("Received event {eventName}", "PLAYER_REGEN_ENABLED")

	isPlayerInCombat = false

	if Addon:IsCombatProcessRequired() then
		Clicked2:ProcessActiveBindings()
	end
end

local function PLAYER_ENTERING_WORLD()
	Clicked2:LogVerbose("Received event {eventName}", "PLAYER_ENTERING_WORLD")

	isInitialized = true
	playerFlagsCache = {
		warMode = Addon.EXPANSION >= Addon.Expansions.BFA and C_PvP.IsWarModeDesired() or false
	}

	local isInitialLoadPending = false

	Addon:UpdateTalentCache(function()
		isInitialLoadPending = true
		Addon:ReloadBindingsImmediate()
	end, true)

	-- Reload immediately in case we are about to be in combat
	if not isInitialLoadPending then
		Addon:ReloadBindingsImmediate()
	end

	Addon:RequestItemLoadForBindings()
end

local function ZONE_CHANGED()
	-- Addon:ReloadBindings("ZONE_CHANGED")
end

local function ZONE_CHANGED_INDOORS()
	-- Addon:ReloadBindings("ZONE_CHANGED_INDOORS")
end

local function ZONE_CHANGED_NEW_AREA()
	Clicked2:LogVerbose("Received event {eventName}", "ZONE_CHANGED_NEW_AREA")

	Addon:ReloadBindings("ZONE_CHANGED_NEW_AREA")
end

local function CHARACTER_POINTS_CHANGED()
	Clicked2:LogVerbose("Received event {eventName}", "CHARACTER_POINTS_CHANGED")

	Addon:UpdateTalentCache(function()
		Addon:ReloadBindings("CHARACTER_POINTS_CHANGED")
	end)
end

local function PLAYER_FLAGS_CHANGED(_, unit)
	if unit ~= "player" then
		return
	end

	local changed = false

	if C_PvP.IsWarModeDesired() ~= playerFlagsCache.warMode then
		playerFlagsCache.warMode = C_PvP.IsWarModeDesired()
		changed = true
	end

	if changed then
		Clicked2:LogVerbose("Received event {eventName}", "PLAYER_FLAGS_CHANGED")

		Addon:ReloadBindings("PLAYER_FLAGS_CHANGED")
	end
end

local function PLAYER_TALENT_UPDATE()
	Clicked2:LogVerbose("Received event {eventName}", "PLAYER_TALENT_UPDATE")

	Addon:UpdateTalentCache(function()
		Addon:ReloadBindings("PLAYER_TALENT_UPDATE")
	end)
end

local function PLAYER_PVP_TALENT_UPDATE()
	Clicked2:LogVerbose("Received event {eventName}", "PLAYER_PVP_TALENT_UPDATE")

	Addon:ReloadBindings("PLAYER_PVP_TALENT_UPDATE")
end

local function TRAIT_CONFIG_CREATED()
	Clicked2:LogVerbose("Received event {eventName}", "TRAIT_CONFIG_CREATED")

	Addon:UpdateTalentCache(function()
		Addon:ReloadBindings("TRAIT_CONFIG_CREATED")
	end)
end

local function TRAIT_CONFIG_UPDATED()
	Clicked2:LogVerbose("Received event {eventName}", "TRAIT_CONFIG_UPDATED")

	Addon:UpdateTalentCache(function()
		Addon:ReloadBindings("TRAIT_CONFIG_UPDATED")
	end)
end

local function PLAYER_LEVEL_CHANGED()
	Clicked2:LogVerbose("Received event {eventName}", "PLAYER_LEVEL_CHANGED")

	Addon:ReloadBindings("PLAYER_LEVEL_CHANGED")
end

local function ACTIONBAR_SLOT_CHANGED()
	Clicked2:LogVerbose("Received event {eventName}", "ACTIONBAR_SLOT_CHANGED")

	if Addon.db.profile.options.autoBindActionBar then
		Addon:ReloadBindings("ACTIONBAR_SLOT_CHANGED")
	end
end

local function LEARNED_SPELL_IN_TAB()
	Clicked2:LogVerbose("Received event {eventName}", "LEARNED_SPELL_IN_TAB")

	Addon:ReloadBindings("LEARNED_SPELL_IN_TAB")
end

local function LEARNED_SPELL_IN_SKILL_LINE()
	Clicked2:LogVerbose("Received event {eventName}", "LEARNED_SPELL_IN_SKILL_LINE")

	Addon:ReloadBindings("LEARNED_SPELL_IN_SKILL_LINE")
end

local function PLAYER_EQUIPMENT_CHANGED()
	Clicked2:LogVerbose("Received event {eventName}", "PLAYER_EQUIPMENT_CHANGED")

	Addon:ReloadBindings("PLAYER_EQUIPMENT_CHANGED")
end

local function GROUP_ROSTER_UPDATE()
	Clicked2:LogVerbose("Received event {eventName}", "GROUP_ROSTER_UPDATE")

	Addon:ReloadBindings("GROUP_ROSTER_UPDATE")
end

local function RUNE_UPDATED()
	Clicked2:LogVerbose("Received event {eventName}", "RUNE_UPDATED")

	Addon:ReloadBindings("RUNE_UPDATED")
end

local function HOUSE_EDITOR_MODE_CHANGED()
	Clicked2:LogVerbose("Received event {eventName}", "HOUSE_EDITOR_MODE_CHANGED")

	if Addon.db.profile.options.disableInHouse and C_HouseEditor.IsHouseEditorActive() ~= wasHouseEditorActive then
		wasHouseEditorActive = C_HouseEditor.IsHouseEditorActive()
		Addon:ReloadBindings("HOUSE_EDITOR_MODE_CHANGED")
	end
end

--- @param itemId integer
--- @param success boolean
local function ITEM_DATA_LOAD_RESULT(_, itemId, success)
	if not success then
		return
	end

	Clicked2:LogVerbose("Received event {eventName}", "ITEM_DATA_LOAD_RESULT", itemId)

	for _, binding in Clicked2:IterateConfiguredBindings() do
		if binding.actionType == Clicked2.ActionType.ITEM and binding.action.itemValue == itemId then
			Addon:ReloadBinding(binding, "value")
		end
	end
end

function Addon:RegisterEventHandlers()
	Clicked2:RegisterEvent("PLAYER_REGEN_DISABLED", PLAYER_REGEN_DISABLED)
	Clicked2:RegisterEvent("PLAYER_REGEN_ENABLED", PLAYER_REGEN_ENABLED)
	Clicked2:RegisterEvent("PLAYER_ENTERING_WORLD", PLAYER_ENTERING_WORLD)

	if Addon.EXPANSION == Addon.Expansions.CLASSIC then
		Clicked2:RegisterEvent("RUNE_UPDATED", RUNE_UPDATED)
	end

	if Addon.EXPANSION <= Addon.Expansions.CATA then
		Clicked2:RegisterEvent("CHARACTER_POINTS_CHANGED", CHARACTER_POINTS_CHANGED)
	end

	if Addon.EXPANSION >= Addon.Expansions.WOTLK then
		Clicked2:RegisterEvent("PLAYER_TALENT_UPDATE", PLAYER_TALENT_UPDATE)
	end

	if Addon.EXPANSION >= Addon.Expansions.BFA then
		Clicked2:RegisterEvent("PLAYER_FLAGS_CHANGED", PLAYER_FLAGS_CHANGED)
		Clicked2:RegisterEvent("PLAYER_PVP_TALENT_UPDATE", PLAYER_PVP_TALENT_UPDATE)
	end

	if Addon.EXPANSION >= Addon.Expansions.DF then
		Clicked2:RegisterEvent("TRAIT_CONFIG_CREATED", TRAIT_CONFIG_CREATED)
		Clicked2:RegisterEvent("TRAIT_CONFIG_UPDATED", TRAIT_CONFIG_UPDATED)
	end

	Clicked2:RegisterEvent("PLAYER_LEVEL_CHANGED", PLAYER_LEVEL_CHANGED)

	if Addon.EXPANSION >= Addon.Expansions.TWW or Addon.EXPANSION == Addon.Expansions.TBC then -- HACK: Anniversary follows the modern API
		Clicked2:RegisterEvent("LEARNED_SPELL_IN_SKILL_LINE", LEARNED_SPELL_IN_SKILL_LINE)
	else
		Clicked2:RegisterEvent("LEARNED_SPELL_IN_TAB", LEARNED_SPELL_IN_TAB)
	end

	if Addon.EXPANSION >= Addon.Expansions.TWW then
		Clicked2:RegisterEvent("HOUSE_EDITOR_MODE_CHANGED", HOUSE_EDITOR_MODE_CHANGED)
	end

	Clicked2:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", PLAYER_EQUIPMENT_CHANGED)
	Clicked2:RegisterEvent("GROUP_ROSTER_UPDATE", GROUP_ROSTER_UPDATE)
	Clicked2:RegisterEvent("ZONE_CHANGED", ZONE_CHANGED)
	Clicked2:RegisterEvent("ZONE_CHANGED_INDOORS", ZONE_CHANGED_INDOORS)
	Clicked2:RegisterEvent("ZONE_CHANGED_NEW_AREA", ZONE_CHANGED_NEW_AREA)
	Clicked2:RegisterEvent("ITEM_DATA_LOAD_RESULT", ITEM_DATA_LOAD_RESULT)
	Clicked2:RegisterEvent("ACTIONBAR_SLOT_CHANGED", ACTIONBAR_SLOT_CHANGED)
end

--- Check if the addon is fully initialized.
---
--- @return boolean @`true` if the addon is done initializing, `false` otherwise
function Addon:IsInitialized()
	return isInitialized
end

--- Check if the player is currently in combat.

--- @return boolean @`true` if the player is currently considered to be in combat, `false` otherwise.
function Addon:IsPlayerInCombat()
	return isPlayerInCombat
end
