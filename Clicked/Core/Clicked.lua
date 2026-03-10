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

local AceConsole = LibStub("AceConsole-3.0")

--- @class Addon
local Addon = select(2, ...)

local isPlayerInCombat = false
local isInitialized = false
local wasHouseEditorActive = false

--- @type table<string, boolean>
local playerFlagsCache = {}

--- Parse a chat command input and handle it appropriately.
---
--- @param input string The data of the chat command, excluding the first word
local function HandleChatCommand(input)
	--- @type string[]
	local args = {}
	local start = 1

	while true do
		local arg, next = AceConsole:GetArgs(input, 1, start)

		if next == 1e9 then
			break
		end

		table.insert(args, arg)
		start = next
	end

	for _, module in Clicked2:IterateModules() do
		--- @cast module SlashCommandHandler
		local handler = module.HandleSlashCommand

		if type(handler) == "function" and handler(module, args) then
			return
		end
	end

	if #args == 1 then
		if args[1] == "opt" or args[1] == "options" then
			Addon:OpenSettingsMenu("Clicked2")
		elseif args[1] == "dump" then
			Addon:StatusOutput_Open()
		elseif (args[1] == "viz" or args[1] == "visualizer") then
			Addon.KeyVisualizer:Open()
		elseif args[1] == "ignore-self-cast-warning" then
			Addon.db.profile.options.ignoreSelfCastWarning = not Addon.db.profile.options.ignoreSelfCastWarning

			if Addon.db.profile.options.ignoreSelfCastWarning then
				Clicked2:LogInfo(Addon.L["Disabled self-cast warning, type this command again to re-enable it."])
			else
				Clicked2:LogInfo(Addon.L["Enabled self-cast warning, type this command again to disable it."])
			end
		end
	end
end

-- Event handlers

local function PLAYER_REGEN_DISABLED()
	Clicked2:LogVerbose("Received event {eventName}", "PLAYER_REGEN_DISABLED")

	isPlayerInCombat = true

	if Addon:IsCombatProcessRequired() then
		Clicked2:ProcessActiveBindings()
	end
end

local function PLAYER_REGEN_ENABLED()
	Clicked2:LogVerbose("Received event {eventName}", "PLAYER_REGEN_ENABLED")

	isPlayerInCombat = false

	Addon:ProcessFrameQueue()

	if Addon:IsCombatProcessRequired() then
		Clicked2:ProcessActiveBindings()
	end
end

local function PLAYER_ENTERING_WORLD()
	Clicked2:LogVerbose("Received event {eventName}", "PLAYER_ENTERING_WORLD")

	isInitialized = true
	playerFlagsCache = {
		warMode = Addon.EXPANSION >= Addon.Expansion.BFA and C_PvP.IsWarModeDesired() or false
	}

	local isInitialLoadPending = false

	Addon:ProcessFrameQueue()
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

local function ADDON_LOADED()
	Clicked2:LogVerbose("Received event {eventName}", "ADDON_LOADED")

	Addon:ProcessFrameQueue()
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

--- @param self AceEvent-3.0
--- @param method fun(self: AceEvent-3.0, event: WowEvent, callback: function|string)
local function UpdateEventHooks(self, method)
	method(self, "PLAYER_REGEN_DISABLED", PLAYER_REGEN_DISABLED)
	method(self, "PLAYER_REGEN_ENABLED", PLAYER_REGEN_ENABLED)
	method(self, "PLAYER_ENTERING_WORLD", PLAYER_ENTERING_WORLD)

	if Addon.EXPANSION == Addon.Expansion.CLASSIC then
		method(self, "RUNE_UPDATED", RUNE_UPDATED)
	end

	if Addon.EXPANSION <= Addon.Expansion.CATA then
		method(self, "CHARACTER_POINTS_CHANGED", CHARACTER_POINTS_CHANGED)
	end

	if Addon.EXPANSION >= Addon.Expansion.WOTLK then
		method(self, "PLAYER_TALENT_UPDATE", PLAYER_TALENT_UPDATE)
	end

	if Addon.EXPANSION >= Addon.Expansion.BFA then
		method(self, "PLAYER_FLAGS_CHANGED", PLAYER_FLAGS_CHANGED)
		method(self, "PLAYER_PVP_TALENT_UPDATE", PLAYER_PVP_TALENT_UPDATE)
	end

	if Addon.EXPANSION >= Addon.Expansion.DF then
		method(self, "TRAIT_CONFIG_CREATED", TRAIT_CONFIG_CREATED)
		method(self, "TRAIT_CONFIG_UPDATED", TRAIT_CONFIG_UPDATED)
	end

	method(self, "PLAYER_LEVEL_CHANGED", PLAYER_LEVEL_CHANGED)

	if Addon.EXPANSION >= Addon.Expansion.TWW or Addon.EXPANSION == Addon.Expansion.TBC then -- HACK: Anniversary follows the modern API
		method(self, "LEARNED_SPELL_IN_SKILL_LINE", LEARNED_SPELL_IN_SKILL_LINE)
	else
		method(self, "LEARNED_SPELL_IN_TAB", LEARNED_SPELL_IN_TAB)
	end

	if Addon.EXPANSION >= Addon.Expansion.TWW then
		method(self, "HOUSE_EDITOR_MODE_CHANGED", HOUSE_EDITOR_MODE_CHANGED)
	end

	method(self, "PLAYER_EQUIPMENT_CHANGED", PLAYER_EQUIPMENT_CHANGED)
	method(self, "GROUP_ROSTER_UPDATE", GROUP_ROSTER_UPDATE)
	method(self, "ADDON_LOADED", ADDON_LOADED)
	method(self, "ZONE_CHANGED", ZONE_CHANGED)
	method(self, "ZONE_CHANGED_INDOORS", ZONE_CHANGED_INDOORS)
	method(self, "ZONE_CHANGED_NEW_AREA", ZONE_CHANGED_NEW_AREA)
	method(self, "ITEM_DATA_LOAD_RESULT", ITEM_DATA_LOAD_RESULT)
	method(self, "ACTIONBAR_SLOT_CHANGED", ACTIONBAR_SLOT_CHANGED)
end

-- Public addon API

function Clicked2:OnInitialize()
	local defaultProfile = select(2, UnitClass("player"))

	Addon.db = LibStub("AceDB-3.0"):New("Clicked2DB", self:GetDatabaseDefaults(), defaultProfile)
	Addon.db.RegisterCallback(self, "OnProfileChanged", "ReloadDatabase")
	Addon.db.RegisterCallback(self, "OnProfileCopied", "ReloadDatabase")
	Addon.db.RegisterCallback(self, "OnProfileReset", "ReloadDatabase")

	self:SetLogLevelFromConfigTable(Addon.db.global)

	Addon:UpgradeDatabase()

	Addon:RegisterClickCastHeader()
	Addon:RegisterBlizzardUnitFrames()

	Addon.AddonOptions:Initialize()
	Addon.ProfileOptions:Initialize()
	Addon.BlacklistOptions:Initialize()
	Addon:StatusOutput_Initialize()

	AceConsole:RegisterChatCommand("clicked2", HandleChatCommand)
	AceConsole:RegisterChatCommand("cc2", HandleChatCommand)
end

function Clicked2:OnEnable()
--@debug@
	local projectUrl = "https://www.curseforge.com/wow/addons/clicked"
	Clicked2:LogWarning("You are using a development version, download the latest release from {url}", projectUrl)
--@end-debug@

	UpdateEventHooks(self, self.RegisterEvent)

	-- self-cast warning
	if not Addon.db.profile.options.ignoreSelfCastWarning and Addon.EXPANSION >= Addon.Expansion.DF then
		local selfCastModifier = GetModifiedClick("SELFCAST")

		if selfCastModifier ~= "NONE" then
			local message = Addon.L["The behavior of the self-cast modifier has changed in Dragonflight, bindings using the '{key}' key modifier may not work correctly. It is recommended to disable it by setting it to 'NONE' in the options menu. You can disable this warning by typing: {command}"]
			Clicked2:LogWarning(message, selfCastModifier, "/clicked ignore-self-cast-warning")
		end
	end
end

function Clicked2:OnDisable()
	UpdateEventHooks(self, self.UnregisterEvent)
end

--- @param system string
--- @return LibLog-1.0.Logger
function Clicked2:CreateSystemLogger(system)
	return Clicked2:ForLogContext({
		system = system
	})
end

-- Private addon API

function Addon:RequestItemLoadForBindings()
	for _, binding in Clicked2:IterateConfiguredBindings() do
		if binding.actionType == Clicked2.ActionType.ITEM then
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
