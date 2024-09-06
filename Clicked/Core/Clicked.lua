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

local AceConsole = LibStub("AceConsole-3.0")
local LibDataBroker = LibStub("LibDataBroker-1.1")
local LibDBIcon = LibStub("LibDBIcon-1.0")

--- @class ClickedInternal
local Addon = select(2, ...)
Addon.L = LibStub("AceLocale-3.0"):GetLocale("Clicked") --[[@as table<string,string>]]

--- @class Clicked
Clicked = LibStub("AceAddon-3.0"):NewAddon("Clicked", "AceEvent-3.0")
Clicked.VERSION = C_AddOns.GetAddOnMetadata("Clicked", "Version")

--@debug@
if Clicked.VERSION == "@project-version@" then
	Clicked.VERSION = "development"
end
--@end-debug@

local isPlayerInCombat = false
local isInitialized = false
local openConfigOnCombatExit = false

-- Local support functions

local function RegisterIcons()
	local iconData = LibDataBroker:NewDataObject("Clicked", {
		type = "launcher",
		label = Addon.L["Clicked"],
		icon = "Interface\\Icons\\inv_misc_punchcards_yellow",
		OnClick = function()
			Addon.BindingConfig.Window:Open()
		end,
		OnTooltipShow = function(tooltip)
			tooltip:AddLine(Addon.L["Clicked"])
		end
	})

	LibDBIcon:Register(Addon.L["Clicked"], iconData, Addon.db.profile.options.minimap)
	LibDBIcon:AddButtonToCompartment(Addon.L["Clicked"])
end

--- Parse a chat command input and handle it appropriately.
---
--- @param input string The data of the chat command, excluding the first word
local function HandleChatCommand(input)
	--- @type string[]
	local args = {}
	local start = 1

	while true do
		local arg, next = AceConsole:GetArgs(input, 1, start)
		table.insert(args, arg)

		if next == 1e9 then
			break
		end

		start = next
	end

	if #args == 0 then
		if InCombatLockdown() then
			openConfigOnCombatExit = true
			print(Addon:AppendClickedMessagePrefix("Binding configuration will open once you leave combat."))
		else
			Addon.BindingConfig.Window:Open()
		end
	elseif #args == 1 then
		if args[1] == "opt" or args[1] == "options" then
			Addon:OpenSettingsMenu("Clicked")
		elseif args[1] == "dump" then
			Addon:StatusOutput_Open()
		elseif (args[1] == "viz" or args[1] == "visualizer") then
			Addon.KeyVisualizer:Open()
		elseif args[1] == "ignore-self-cast-warning" then
			Addon.db.profile.options.ignoreSelfCastWarning = not Addon.db.profile.options.ignoreSelfCastWarning

			if Addon.db.profile.options.ignoreSelfCastWarning then
				print(Addon:GetPrefixedAndFormattedString(Addon.L["Disabled self-cast warning, type this command again to re-enable it."]))
			else
				print(Addon:GetPrefixedAndFormattedString(Addon.L["Enabled self-cast warning, type this command again to disable it."]))
			end
		end
	end
end

-- Event handlers

local function PLAYER_REGEN_DISABLED()
	isPlayerInCombat = true
	openConfigOnCombatExit = Addon.BindingConfig.Window:IsOpen()

	Addon.BindingConfig.Window:Close()
	Addon:AbilityTooltips_Refresh()

	if Addon:IsCombatProcessRequired() then
		Clicked:ProcessActiveBindings()
	end
end

local function PLAYER_REGEN_ENABLED()
	isPlayerInCombat = false

	Addon:ProcessFrameQueue()
	Addon:AbilityTooltips_Refresh()

	if Addon:IsCombatProcessRequired() then
		Clicked:ProcessActiveBindings()
	end

	if openConfigOnCombatExit then
		Addon.BindingConfig.Window:Open()
		openConfigOnCombatExit = false
	end
end

local function PLAYER_ENTERING_WORLD()
	isInitialized = true

	local isInitialLoadPending = false

	Addon:RequestItemLoadForBindings()
	Addon:ProcessFrameQueue()
	Addon:UpdateClickCastHeaderBlacklist()
	Addon:UpdateTalentCache(function()
		isInitialLoadPending = true
		Addon:ReloadBindingsImmediate()
	end, true)

	-- Reload immediately in case we are about to be in combat
	if not isInitialLoadPending then
		Addon:ReloadBindingsImmediate()
	end
end

local function ADDON_LOADED()
	Addon:ProcessFrameQueue()
end

local function ZONE_CHANGED()
	-- TODO: Currently, only ZONE_CHANGED_NEW_AREA is supported by the check for this, enable this once support for sub-zones is enabled
	-- Addon:ReloadBindings("ZONE_CHANGED")
end

local function ZONE_CHANGED_INDOORS()
	-- TODO: Currently, only ZONE_CHANGED_NEW_AREA is supported by the check for this, enable this once support for sub-zones is enabled
	-- Addon:ReloadBindings("ZONE_CHANGED_INDOORS")
end

local function ZONE_CHANGED_NEW_AREA()
	Addon:ReloadBindings("ZONE_CHANGED_NEW_AREA")
end

local function CHARACTER_POINTS_CHANGED()
	Addon:UpdateTalentCache(function()
		Addon:ReloadBindings("CHARACTER_POINTS_CHANGED")
	end)
end

local function PLAYER_FLAGS_CHANGED(_, unit)
	if unit == "player" then
		Addon:ReloadBindings("PLAYER_FLAGS_CHANGED")
	end
end

local function PLAYER_TALENT_UPDATE()
	Addon:UpdateTalentCache(function()
		Addon:ReloadBindings("PLAYER_TALENT_UPDATE")
	end)
end

local function PLAYER_PVP_TALENT_UPDATE()
	Addon:ReloadBindings("PLAYER_PVP_TALENT_UPDATE")
end

local function TRAIT_CONFIG_CREATED()
	Addon:UpdateTalentCache(function()
		Addon:ReloadBindings("TRAIT_CONFIG_CREATED")
	end)
end

local function TRAIT_CONFIG_UPDATED()
	Addon:UpdateTalentCache(function()
		Addon:ReloadBindings("TRAIT_CONFIG_UPDATED")
	end)
end

local function PLAYER_FOCUS_CHANGED()
	Addon:AbilityTooltips_Refresh()
end

local function PLAYER_LEVEL_CHANGED()
	Addon:ReloadBindings("PLAYER_LEVEL_CHANGED")
end

local function LEARNED_SPELL_IN_TAB()
	Addon:ReloadBindings("LEARNED_SPELL_IN_TAB")
end

local function PLAYER_EQUIPMENT_CHANGED()
	Addon:ReloadBindings("PLAYER_EQUIPMENT_CHANGED")
end

local function GROUP_ROSTER_UPDATE()
	Addon:ReloadBindings("GROUP_ROSTER_UPDATE")
end

local function MODIFIER_STATE_CHANGED()
	Addon:AbilityTooltips_Refresh()
end

local function UNIT_TARGET()
	Addon:AbilityTooltips_Refresh()
end

local function RUNE_UPDATED()
	Addon:ReloadBindings("RUNE_UPDATED")
end

--- @param itemId integer
--- @param success boolean
local function ITEM_DATA_LOAD_RESULT(_, itemId, success)
	if not success then
		return
	end

	for _, binding in Clicked:IterateConfiguredBindings() do
		if binding.actionType == Clicked.ActionType.ITEM and binding.action.itemValue == itemId then
			Addon:ReloadBinding(binding, "value")
		end
	end
end

--- @param self AceEvent-3.0
--- @param method fun(self: AceEvent-3.0, event: WowEvent, callback: function|string)
local function UpdateEventHooks(self, method)
	method(self, "PLAYER_REGEN_DISABLED", PLAYER_REGEN_DISABLED)
	method(self, "PLAYER_REGEN_ENABLED", PLAYER_REGEN_ENABLED)
	method(self, "PLAYER_ENTERING_WORLD", PLAYER_ENTERING_WORLD)

	if Addon.EXPANSION_LEVEL == Addon.Expansion.CLASSIC then
		method(self, "RUNE_UPDATED", RUNE_UPDATED)
	end

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.BC then
		method(self, "PLAYER_FOCUS_CHANGED", PLAYER_FOCUS_CHANGED)
	end

	if Addon.EXPANSION_LEVEL <= Addon.Expansion.CATA then
		method(self, "CHARACTER_POINTS_CHANGED", CHARACTER_POINTS_CHANGED)
	end

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.WOTLK then
		method(self, "PLAYER_TALENT_UPDATE", PLAYER_TALENT_UPDATE)
	end

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.BFA then
		method(self, "PLAYER_FLAGS_CHANGED", PLAYER_FLAGS_CHANGED)
		method(self, "PLAYER_PVP_TALENT_UPDATE", PLAYER_PVP_TALENT_UPDATE)
	end

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.DF then
		method(self, "TRAIT_CONFIG_CREATED", TRAIT_CONFIG_CREATED)
		method(self, "TRAIT_CONFIG_UPDATED", TRAIT_CONFIG_UPDATED)
	end

	method(self, "PLAYER_LEVEL_CHANGED", PLAYER_LEVEL_CHANGED)
	method(self, "LEARNED_SPELL_IN_TAB", LEARNED_SPELL_IN_TAB)
	method(self, "PLAYER_EQUIPMENT_CHANGED", PLAYER_EQUIPMENT_CHANGED)
	method(self, "GROUP_ROSTER_UPDATE", GROUP_ROSTER_UPDATE)
	method(self, "ADDON_LOADED", ADDON_LOADED)
	method(self, "ZONE_CHANGED", ZONE_CHANGED)
	method(self, "ZONE_CHANGED_INDOORS", ZONE_CHANGED_INDOORS)
	method(self, "ZONE_CHANGED_NEW_AREA", ZONE_CHANGED_NEW_AREA)
	method(self, "MODIFIER_STATE_CHANGED", MODIFIER_STATE_CHANGED)
	method(self, "UNIT_TARGET", UNIT_TARGET)
	method(self, "ITEM_DATA_LOAD_RESULT", ITEM_DATA_LOAD_RESULT)
end

-- Public addon API

function Clicked:OnInitialize()
	local defaultProfile = select(2, UnitClass("player"))

	Addon.db = LibStub("AceDB-3.0"):New("ClickedDB", self:GetDatabaseDefaults(), defaultProfile)
	Addon.db.RegisterCallback(self, "OnProfileChanged", "ReloadDatabase")
	Addon.db.RegisterCallback(self, "OnProfileCopied", "ReloadDatabase")
	Addon.db.RegisterCallback(self, "OnProfileReset", "ReloadDatabase")

	Addon:UpgradeDatabase()

	RegisterIcons()

	Addon:RegisterClickCastHeader()
	Addon:RegisterBlizzardUnitFrames()

	Addon.AddonOptions:Initialize()
	Addon.ProfileOptions:Initialize()
	Addon.BlacklistOptions:Initialize()
	Addon:StatusOutput_Initialize()
	Addon:AbilityTooltips_Initialize()

	AceConsole:RegisterChatCommand("clicked", HandleChatCommand)
	AceConsole:RegisterChatCommand("cc", HandleChatCommand)
end

function Clicked:OnEnable()
--@debug@
	local projectUrl = "https://www.curseforge.com/wow/addons/clicked"
	print(Addon:AppendClickedMessagePrefix("You are using a development version, download the latest release from " .. projectUrl))
--@end-debug@

	UpdateEventHooks(self, self.RegisterEvent)

	-- self-cast warning
	if not Addon.db.profile.options.ignoreSelfCastWarning and Addon.EXPANSION_LEVEL >= Addon.Expansion.DF then
		local selfCastModifier = GetModifiedClick("SELFCAST")

		if selfCastModifier ~= "NONE" then
			local message = string.format(Addon.L["The behavior of the self-cast modifier has changed in Dragonflight, bindings using the '%s' key modifier may not work correctly. It is recommended to disable it by setting it to 'NONE' in the options menu. You can disable this warning by typing: %s"], selfCastModifier, YELLOW_FONT_COLOR:WrapTextInColorCode("/clicked ignore-self-cast-warning"))
			print(Addon:GetPrefixedAndFormattedString(message))
		end
	end
end

function Clicked:OnDisable()
	UpdateEventHooks(self, self.UnregisterEvent)
end

-- Private addon API

function Addon:RequestItemLoadForBindings()
	for _, binding in Clicked:IterateConfiguredBindings() do
		if binding.actionType == Clicked.ActionType.ITEM then
			local itemId = tonumber(binding.action.itemValue)

			if itemId ~= nil then
				C_Item.RequestLoadItemDataByID(itemId)
			end
		end
	end
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
