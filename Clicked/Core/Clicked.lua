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

--- @class ClickedInternal
local _, Addon = ...

--- @type table<string,string>
Addon.L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

--- @type Clicked
Clicked = LibStub("AceAddon-3.0"):NewAddon("Clicked", "AceEvent-3.0")

--- The current version of Clicked.
Clicked.VERSION = GetAddOnMetadata("Clicked", "Version")

--@debug@
if Clicked.VERSION == "@project-version@" then
	Clicked.VERSION = "development"
end
--@end-debug@

local isPlayerInCombat = false
local isInitialized = false

-- Local support functions

local function RegisterMinimapIcon()
	local iconData = LibDataBroker:NewDataObject("Clicked", {
		type = "launcher",
		label = Addon.L["Clicked"],
		icon = "Interface\\Icons\\inv_misc_punchcards_yellow",
		OnClick = function()
			Addon:BindingConfig_Open()
		end,
		OnTooltipShow = function(tooltip)
			tooltip:AddLine(Addon.L["Clicked"])
		end
	})

	LibDBIcon:Register("Clicked", iconData, Addon.db.profile.options.minimap)
end

--- Parse a chat command input and handle it appropriately.
---
--- @param input string The data of the chat command, excluding the first word
local function HandleChatCommand(input)
	local args = {}
	local startpos = 1

	while true do
		local arg, next = AceConsole:GetArgs(input, 1, startpos)
		table.insert(args, arg)

		if next == 1e9 then
			break
		end

		startpos = next
	end

	if #args == 0 then
		Addon:BindingConfig_Open()
	elseif #args == 1 then
		if args[1] == "profile" then
			Addon:ProfileOptions_Open()
		elseif args[1] == "blacklist" then
			Addon:BlacklistOptions_Open()
		elseif args[1] == "dump" then
			Addon:StatusOutput_Open()
		end
	end
end

local function SendSelfcastWarning()
	local modifier = GetModifiedClick("SELFCAST")

	if modifier ~= "NONE" then
		local message = Addon:GetPrefixedAndFormattedString("The behavior of the self-cast modifier has changed in Dragonflight, bindings using the '%s' key modifier may not work correctly. It is recommended to disable it by setting it to 'NONE' in the options menu.", modifier)
		print(message)
	end
end

-- Event handlers

local function PLAYER_REGEN_DISABLED()
	isPlayerInCombat = true

	Clicked:ReloadActiveBindings()
	Addon:AbilityTooltips_Refresh()
end

local function PLAYER_REGEN_ENABLED()
	isPlayerInCombat = false

	Addon:ProcessFrameQueue()
	Clicked:ReloadActiveBindings()
	Addon:AbilityTooltips_Refresh()
end

local function PLAYER_ENTERING_WORLD()
	isInitialized = true

	Addon:ProcessFrameQueue()
	Addon:UpdateClickCastHeaderBlacklist()
	Clicked:ReloadActiveBindings()
end

local function ADDON_LOADED()
	Addon:ProcessFrameQueue()
end

local function GET_ITEM_INFO_RECEIVED(_, itemId, success)
	Addon:BindingConfig_ItemInfoReceived(itemId, success)
end

local function ZONE_CHANGED_NEW_AREA()
	Addon:ReloadActiveBindingsNextFrame()
end

local function CHARACTER_POINTS_CHANGED()
	Addon:ReloadActiveBindingsNextFrame()
end

local function PLAYER_FLAGS_CHANGED(_, unit)
	if unit == "player" then
		Addon:ReloadActiveBindingsNextFrame()
	end
end

local function TRAIT_CONFIG_UPDATED()
	Addon:ReloadActiveBindingsNextFrame()
end

local function PLAYER_FOCUS_CHANGED()
	Addon:AbilityTooltips_Refresh()
end

local function PLAYER_LEVEL_CHANGED()
	Addon:ReloadActiveBindingsNextFrame()
end

local function LEARNED_SPELL_IN_TAB()
	Addon:ReloadActiveBindingsNextFrame()
end

local function PLAYER_EQUIPMENT_CHANGED()
	Addon:ReloadActiveBindingsNextFrame()
end

local function GROUP_ROSTER_UPDATE()
	Addon:ReloadActiveBindingsNextFrame()
end

local function MODIFIER_STATE_CHANGED()
	Addon:AbilityTooltips_Refresh()
end

local function UNIT_TARGET()
	Addon:AbilityTooltips_Refresh()
end

-- Public addon API

function Clicked:OnInitialize()
	local defaultProfile = select(2, UnitClass("player"))

	--- @type Database
	Addon.db = LibStub("AceDB-3.0"):New("ClickedDB", self:GetDatabaseDefaults(), defaultProfile)
	Addon.db.RegisterCallback(self, "OnProfileChanged", "ReloadDatabase")
	Addon.db.RegisterCallback(self, "OnProfileCopied", "ReloadDatabase")
	Addon.db.RegisterCallback(self, "OnProfileReset", "ReloadDatabase")

	Addon:UpgradeDatabaseProfile(Addon.db.profile)

	RegisterMinimapIcon()

	Addon:RegisterClickCastHeader()
	Addon:RegisterBlizzardUnitFrames()

	Addon:GeneralOptions_Initialize()
	Addon:ProfileOptions_Initialize()
	Addon:BlacklistOptions_Initialize()
	Addon:BindingConfig_Initialize()
	Addon:StatusOutput_Initialize()
	Addon:AbilityTooltips_Initialize()

	AceConsole:RegisterChatCommand("clicked", HandleChatCommand)
	AceConsole:RegisterChatCommand("cc", HandleChatCommand)
end

function Clicked:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_DISABLED", PLAYER_REGEN_DISABLED)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", PLAYER_REGEN_ENABLED)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", PLAYER_ENTERING_WORLD)

	if Addon:IsGameVersionAtleast("BC") then
		self:RegisterEvent("PLAYER_FOCUS_CHANGED", PLAYER_FOCUS_CHANGED)

		if not Addon:IsGameVersionAtleast("RETAIL") then
			self:RegisterEvent("CHARACTER_POINTS_CHANGED", CHARACTER_POINTS_CHANGED)
		end
	end

	if Addon:IsGameVersionAtleast("RETAIL") then
		self:RegisterEvent("PLAYER_FLAGS_CHANGED", PLAYER_FLAGS_CHANGED)
		self:RegisterEvent("TRAIT_CONFIG_UPDATED", TRAIT_CONFIG_UPDATED)
	end

	self:RegisterEvent("PLAYER_LEVEL_CHANGED", PLAYER_LEVEL_CHANGED)
	self:RegisterEvent("LEARNED_SPELL_IN_TAB", LEARNED_SPELL_IN_TAB)
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", PLAYER_EQUIPMENT_CHANGED)
	self:RegisterEvent("GROUP_ROSTER_UPDATE", GROUP_ROSTER_UPDATE)
	self:RegisterEvent("ADDON_LOADED", ADDON_LOADED)
	self:RegisterEvent("GET_ITEM_INFO_RECEIVED", GET_ITEM_INFO_RECEIVED)
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", ZONE_CHANGED_NEW_AREA)
	self:RegisterEvent("MODIFIER_STATE_CHANGED", MODIFIER_STATE_CHANGED)
	self:RegisterEvent("UNIT_TARGET", UNIT_TARGET)

	if Addon:IsGameVersionAtleast("RETAIL") then
		SendSelfcastWarning()
	end
end

function Clicked:OnDisable()
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")

	if Addon:IsGameVersionAtleast("BC") then
		self:UnregisterEvent("PLAYER_FOCUS_CHANGED")

		if not Addon:IsGameVersionAtleast("RETAIL") then
			self:UnregisterEvent("CHARACTER_POINTS_CHANGED")
		end
	end

	if Addon:IsGameVersionAtleast("RETAIL") then
		self:UnregisterEvent("PLAYER_FLAGS_CHANGED")
		self:UnregisterEvent("TRAIT_CONFIG_UPDATED")
	end

	self:UnregisterEvent("PLAYER_LEVEL_CHANGED")
	self:UnregisterEvent("LEARNED_SPELL_IN_TAB")
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:UnregisterEvent("GROUP_ROSTER_UPDATE")
	self:UnregisterEvent("ADDON_LOADED")
	self:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
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
