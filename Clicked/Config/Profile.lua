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

local AceGUI = LibStub("AceGUI-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")
local AceComm = LibStub("AceComm-3.0")

--- @class ClickedInternal : AceComm-3.0
local Addon = select(2, ...)

--- @type AceGUIFrame
local importExportFrame
local panelId

-- Share to target player
local shareTarget = ""
local shareEnabled = false
local shareBusy = false
local shareAckReceived = false
local shareBytesSent = 0
local shareBytesTotal = 0
local shareMessage = ""

-- Local support functions

-- Private addon API

function Addon:ProfileOptions_Initialize()
	local profileOptions = AceDBOptions:GetOptionsTable(Addon.db)

	-- Enhance profile options page with import/export buttons
	profileOptions.plugins = profileOptions.plugins or {}
	profileOptions.plugins["AceDBShare"] = {}

	local plugin = profileOptions.plugins["AceDBShare"]

	plugin.importExportDesc = {
		name = "\n" .. Addon.L["Import external profile data into your current profile, or export the current profile into a sharable format."],
		type = "description",
		order = 61,
	}

	plugin.import = {
		name = Addon.L["Import"],
		type = "execute",
		order = 62,
		func = function()
			Addon.ImportFrame:ImportProfile()
		end
	}

	plugin.export = {
		name = Addon.L["Export"],
		type = "execute",
		order = 63,
		func = function()
			Addon.ExportFrame:ExportProfile(Addon.db.profile)
		end
	}

	plugin.sendToDesc = {
		name = "\n" .. Addon.L["Immediately share the current profile with another player. The target player must be on the same realm as you (or a connected realm), and allow for profile sharing."],
		type = "description",
		order = 65
	}

	plugin.sendToName = {
		name = Addon.L["Target player"],
		type = "input",
		order = 66,
		disabled = function()
			return shareBusy
		end,
		get = function()
			return shareTarget
		end,
		set = function(_, value)
			shareTarget = value
		end
	}

	plugin.sendToButton = {
		name = Addon.L["Share"],
		type = "execute",
		order = 67,
		disabled = function()
			if Addon:IsStringNilOrEmpty(shareTarget) then
				return true
			end

			if shareBusy then
				return true
			end

			return false
		end,
		func = function()
			local function OnTimeout()
				if not shareAckReceived then
					shareBusy = false

					AceConfigRegistry:NotifyChange("Clicked/Profile")
					Addon:ShowInformationPopup(string.format(Addon.L["Unable to send a message to %s. Make sure that they are online, have allowed profile sharing, and are on the same realm or a connected realm."], shareTarget))
				end
			end

			shareBusy = true

			-- Just wait for the ACK timeout if we're currently in combat, to prevent stuttering
			if not InCombatLockdown() then
				shareMessage = Clicked:SerializeProfile(Addon.db.profile, false, false)
				shareAckReceived = false

				Addon:RegisterComm("Clicked", "OnCommReceived")
				Addon:SendCommMessage("Clicked", "ShareRequest", "WHISPER", shareTarget, "NORMAL")
			end

			C_Timer.After(5, OnTimeout)
		end
	}

	plugin.allowReceiveSendTo = {
		name = Addon.L["Allow profile sharing"],
		type = "toggle",
		order = 68,
		get = function()
			return shareEnabled
		end,
		set = function(_, value)
			shareEnabled = value

			if value then
				Addon:RegisterComm("Clicked", "OnCommReceived")
			else
				Addon:UnregisterAllComm()
			end
		end
	}

	plugin.sendProgressDesc = {
		name = function()
			if not shareAckReceived then
				local label = Addon.L["Waiting for acknowledgement from %s"]
				return string.format(label, shareTarget)
			else
				local label = Addon.L["Sending profile to %s, progress %d/%d (%d%%)"]

				if shareBytesTotal > 0 then
					local percent = math.floor((shareBytesSent / shareBytesTotal) * 100)
					return string.format(label, shareTarget, shareBytesSent, shareBytesTotal, percent)
				end
			end

			return ""
		end,
		type = "description",
		order = 69,
		hidden = function()
			return not shareBusy
		end
	}

	AceConfig:RegisterOptionsTable("Clicked/Profile", profileOptions)
	panelId = select(2, AceConfigDialog:AddToBlizOptions("Clicked/Profile", Addon.L["Profiles"], "Clicked"))

	AceComm:Embed(self)

	if not C_ChatInfo.IsAddonMessagePrefixRegistered("Clicked") then
		C_ChatInfo.RegisterAddonMessagePrefix("Clicked")
	end
end

function Addon:ProfileOptions_Open()
	if Addon:IsGameVersionAtleast("RETAIL") then
		Settings.OpenToCategory(panelId)
		Settings.OpenToCategory(panelId)
	else
		InterfaceOptionsFrame_OpenToCategory(panelId)
		InterfaceOptionsFrame_OpenToCategory(panelId)
	end
end

--- @param message string
--- @param sender string
function Addon:OnCommReceived(_, message, _, sender)
	if InCombatLockdown() then
		return
	end

	if message == "ShareRequest" then
		if shareEnabled then
			Addon:SendCommMessage("Clicked", "ShareRequestAck", "WHISPER", sender, "NORMAL")
		end
	elseif message == "ShareRequestAck" then
		shareAckReceived = true

		if not shareEnabled then
			Addon:UnregisterAllComm()
		end

		Addon:SendCommMessage("Clicked", shareMessage, "WHISPER", shareTarget, "NORMAL", Addon.OnCommProgress, self)
	else
		local success, data = Clicked:Deserialize(message, false)

		Addon.ImportFrame:ImportProfileFromComm(success, data, sender)
		shareEnabled = not success
	end

	AceConfigRegistry:NotifyChange("Clicked/Profile")
end

--- @param sent number
--- @param total number
function Addon:OnCommProgress(sent, total)
	shareBytesSent = sent
	shareBytesTotal = total

	if sent == total then
		shareBusy = false
	end

	AceConfigRegistry:NotifyChange("Clicked/Profile")
end
