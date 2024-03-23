-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2022  Kevin Krol
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

local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata -- Deprecated in 10.1.0

--- @class ClickedInternal
local Addon = select(2, ...)
Addon.L = LibStub("AceLocale-3.0"):GetLocale("Clicked") --[[@as table<string,string>]]

--- @class Clicked
Clicked = LibStub("AceAddon-3.0"):NewAddon("Clicked", "AceEvent-3.0")
Clicked.VERSION = GetAddOnMetadata("Clicked", "Version")

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
			Addon:BindingConfig_Open()
		end,
		OnTooltipShow = function(tooltip)
			--- @diagnostic disable-next-line: undefined-field
			tooltip:AddLine(Addon.L["Clicked"])
		end
	}) --[[@as LibDBIcon.dataObject]]

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
			Addon:BindingConfig_Open()
		end
	elseif #args == 1 then
		if args[1] == "opt" or args[1] == "options" then
			Addon:OpenSettingsMenu("Clicked")
		elseif args[1] == "dump" then
			Addon:StatusOutput_Open()
		elseif (args[1] == "viz" or args[1] == "visualizer") and not Addon:IsWotLK() then -- TODO: Remove when WOTLK supports texture slicing
			Addon.KeyVisualizer:Open()
		end
	end
end

-- Event handlers

local function PLAYER_REGEN_DISABLED()
	isPlayerInCombat = true
	openConfigOnCombatExit = Addon:BindingConfig_Close()

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
		Addon:BindingConfig_Open()
		openConfigOnCombatExit = false
	end
end

local function PLAYER_ENTERING_WORLD()
	isInitialized = true

	Addon:ProcessFrameQueue()
	Addon:UpdateClickCastHeaderBlacklist()
	Addon:UpdateTalentCacheAndReloadBindings(true, true)
end

local function ADDON_LOADED()
	Addon:ProcessFrameQueue()
end

local function GET_ITEM_INFO_RECEIVED(_, itemId, success)
	Addon:BindingConfig_ItemInfoReceived(itemId, success)
end

local function ZONE_CHANGED()
	-- TODO: Currently, only ZONE_CHANGED_NEW_AREA is supported by the check for this, enable this once support for sub-zones is enabled
	-- Clicked:ReloadBindings(false, true, "ZONE_CHANGED")
end

local function ZONE_CHANGED_INDOORS()
	-- TODO: Currently, only ZONE_CHANGED_NEW_AREA is supported by the check for this, enable this once support for sub-zones is enabled
	-- Clicked:ReloadBindings(false, true, "ZONE_CHANGED_INDOORS")
end

local function ZONE_CHANGED_NEW_AREA()
	Clicked:ReloadBindings(false, true, "ZONE_CHANGED_NEW_AREA")
end

local function CHARACTER_POINTS_CHANGED()
	Addon:UpdateTalentCacheAndReloadBindings(true, "CHARACTER_POINTS_CHANGED")
end

local function PLAYER_FLAGS_CHANGED(_, unit)
	if unit == "player" then
		Clicked:ReloadBindings(false, true, "PLAYER_FLAGS_CHANGED")
	end
end

local function PLAYER_TALENT_UPDATE()
	Addon:UpdateTalentCacheAndReloadBindings(true, "PLAYER_TALENT_UPDATE")
end

local function PLAYER_PVP_TALENT_UPDATE()
	Clicked:ReloadBindings(false, true, "PLAYER_PVP_TALENT_UPDATE")
end

local function TRAIT_CONFIG_CREATED()
	Addon:UpdateTalentCacheAndReloadBindings(true, "TRAIT_CONFIG_CREATED")
end

local function TRAIT_CONFIG_UPDATED()
	Addon:UpdateTalentCacheAndReloadBindings(true, "TRAIT_CONFIG_UPDATED")
end

local function PLAYER_FOCUS_CHANGED()
	Addon:AbilityTooltips_Refresh()
end

local function PLAYER_LEVEL_CHANGED()
	Clicked:ReloadBindings("PLAYER_LEVEL_CHANGED")
end

local function LEARNED_SPELL_IN_TAB()
	Clicked:ReloadBindings(false, true, "LEARNED_SPELL_IN_TAB")
end

local function PLAYER_EQUIPMENT_CHANGED()
	Clicked:ReloadBindings(false, true, "PLAYER_EQUIPMENT_CHANGED")
end

local function GROUP_ROSTER_UPDATE()
	Clicked:ReloadBindings(false, true, "GROUP_ROSTER_UPDATE")
end

local function MODIFIER_STATE_CHANGED()
	Addon:AbilityTooltips_Refresh()
end

local function UNIT_TARGET()
	Addon:AbilityTooltips_Refresh()
end

local function RUNE_UPDATED()
	Clicked:ReloadBindings(false, true, "RUNE_UPDATED")
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
	Addon:BindingConfig_Initialize()
	Addon:StatusOutput_Initialize()
	Addon:AbilityTooltips_Initialize()

	AceConsole:RegisterChatCommand("clicked", HandleChatCommand)
	AceConsole:RegisterChatCommand("cc", HandleChatCommand)
end

function Clicked:OnEnable()
	--- @debug@
	local projectUrl = "https://www.curseforge.com/wow/addons/clicked"
	print(Addon:AppendClickedMessagePrefix("You are using a development version, download the latest release from " .. projectUrl))
	--- @end-debug@

	self:RegisterEvent("PLAYER_REGEN_DISABLED", PLAYER_REGEN_DISABLED)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", PLAYER_REGEN_ENABLED)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", PLAYER_ENTERING_WORLD)

	if Addon:IsGameVersionAtleast("BC") then
		self:RegisterEvent("PLAYER_FOCUS_CHANGED", PLAYER_FOCUS_CHANGED)

		if Addon:IsBC() or Addon:IsWotLK() then
			self:RegisterEvent("CHARACTER_POINTS_CHANGED", CHARACTER_POINTS_CHANGED)
		end
	end

	if Addon:IsClassic() then
		--- @diagnostic disable-next-line: param-type-mismatch
		self:RegisterEvent("RUNE_UPDATED", RUNE_UPDATED)
	end

	if Addon:IsGameVersionAtleast("WOTLK") then
		self:RegisterEvent("PLAYER_TALENT_UPDATE", PLAYER_TALENT_UPDATE)
	end

	if Addon:IsGameVersionAtleast("RETAIL") then
		self:RegisterEvent("PLAYER_FLAGS_CHANGED", PLAYER_FLAGS_CHANGED)
		self:RegisterEvent("PLAYER_PVP_TALENT_UPDATE", PLAYER_PVP_TALENT_UPDATE)
		self:RegisterEvent("TRAIT_CONFIG_CREATED", TRAIT_CONFIG_CREATED)
		self:RegisterEvent("TRAIT_CONFIG_UPDATED", TRAIT_CONFIG_UPDATED)
	end

	self:RegisterEvent("PLAYER_LEVEL_CHANGED", PLAYER_LEVEL_CHANGED)
	self:RegisterEvent("LEARNED_SPELL_IN_TAB", LEARNED_SPELL_IN_TAB)
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", PLAYER_EQUIPMENT_CHANGED)
	self:RegisterEvent("GROUP_ROSTER_UPDATE", GROUP_ROSTER_UPDATE)
	self:RegisterEvent("ADDON_LOADED", ADDON_LOADED)
	self:RegisterEvent("GET_ITEM_INFO_RECEIVED", GET_ITEM_INFO_RECEIVED)
	self:RegisterEvent("ZONE_CHANGED", ZONE_CHANGED)
	self:RegisterEvent("ZONE_CHANGED_INDOORS", ZONE_CHANGED_INDOORS)
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", ZONE_CHANGED_NEW_AREA)
	self:RegisterEvent("MODIFIER_STATE_CHANGED", MODIFIER_STATE_CHANGED)
	self:RegisterEvent("UNIT_TARGET", UNIT_TARGET)
end

function Clicked:OnDisable()
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")

	if Addon:IsGameVersionAtleast("BC") then
		self:UnregisterEvent("PLAYER_FOCUS_CHANGED")

		if Addon:IsBC() or Addon:IsWotLK() then
			self:UnregisterEvent("CHARACTER_POINTS_CHANGED")
		end
	end

	if Addon:IsGameVersionAtleast("WOTLK") then
		self:UnregisterEvent("PLAYER_TALENT_UPDATE")
	end

	if Addon:IsGameVersionAtleast("RETAIL") then
		self:UnregisterEvent("PLAYER_FLAGS_CHANGED")
		self:UnregisterEvent("PLAYER_PVP_TALENT_UPDATE")
		self:UnregisterEvent("TRAIT_CONFIG_CREATED")
		self:UnregisterEvent("TRAIT_CONFIG_UPDATED")
	end

	self:UnregisterEvent("PLAYER_LEVEL_CHANGED")
	self:UnregisterEvent("LEARNED_SPELL_IN_TAB")
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:UnregisterEvent("GROUP_ROSTER_UPDATE")
	self:UnregisterEvent("ADDON_LOADED")
	self:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
	self:UnregisterEvent("ZONE_CHANGED")
	self:UnregisterEvent("ZONE_CHANGED_INDOORS")
	self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
	self:UnregisterEvent("MODIFIER_STATE_CHANGED")
	self:UnregisterEvent("UNIT_TARGET")
end

-- Private addon API

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
