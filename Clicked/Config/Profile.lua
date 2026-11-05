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

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")
local AceComm = LibStub("AceComm-3.0")

--- @class Addon : AceComm-3.0
local Addon = select(2, ...)

-- Share to target player
local shareTarget = ""
local shareEnabled = false
local shareBusy = false
local shareAckReceived = false
local shareBytesSent = 0
local shareBytesTotal = 0
local shareMessage = ""

--- @class ProfileOptions : AceComm-3.0
local ProfileOptions = {}

function ProfileOptions:Initialize()
	AceConfig:RegisterOptionsTable("Clicked/Profile", self:CreateOptionsTable())
	AceConfigDialog:AddToBlizOptions("Clicked/Profile", Addon.L["Profiles"], "Clicked")

	AceComm:Embed(self)

	if not C_ChatInfo.IsAddonMessagePrefixRegistered("Clicked") then
		C_ChatInfo.RegisterAddonMessagePrefix("Clicked")
	end
end

--- @private
--- @return AceConfig.OptionsTable
function ProfileOptions:CreateOptionsTable()
	local options = AceDBOptions:GetOptionsTable(Addon.db)

	-- Enhance profile options page with import/export buttons
	options.plugins = options.plugins or {}
	options.plugins["AceDBShare"] = {}

	local plugin = options.plugins["AceDBShare"]

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
			Addon.BindingConfig.Window:SetPage(Addon.BindingConfig.Window.PAGE_IMPORT_STRING)
		end
	}

	plugin.export = {
		name = Addon.L["Export Profile"],
		desc = Addon.L["Export the current profile into a sharable format, this will only include the profile-specific group and bindings."],
		type = "execute",
		order = 63,
		func = function()
			Addon.BindingConfig.Window:SetPage(Addon.BindingConfig.Window.PAGE_EXPORT_STRING, Addon.BindingConfig.ExportStringModes.PROFILE, Addon.db.profile)
		end
	}

	plugin.exportGlobal = {
		name = Addon.L["Export Global"],
		desc = Addon.L["Export the global profile into a sharable format, this will include global groups and bindings, as well as addon options."],
		type = "execute",
		order = 64,
		func = function()
			Addon.BindingConfig.Window:SetPage(Addon.BindingConfig.Window.PAGE_EXPORT_STRING, Addon.BindingConfig.ExportStringModes.PROFILE, Addon.db.global)
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
			if Addon:IsNilOrEmpty(shareTarget) then
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
				local result, data = Clicked:SerializeProfile(Addon.db.profile, true)

				if result then
					shareMessage = data
					shareAckReceived = false

					self:RegisterComm("Clicked", "OnCommReceived")
					self:SendCommMessage("Clicked", "ShareRequest", "WHISPER", shareTarget, "NORMAL")
				else
					Clicked:LogWarning(data)
				end
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
				self:RegisterComm("Clicked", "OnCommReceived")
			else
				self:UnregisterAllComm()
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

	return options
end

--- @private
--- @param message string
--- @param sender string
function ProfileOptions:OnCommReceived(_, message, _, sender)
	if InCombatLockdown() then
		return
	end

	if message == "ShareRequest" then
		if shareEnabled then
			self:SendCommMessage("Clicked", "ShareRequestAck", "WHISPER", sender, "NORMAL")
		end
	elseif message == "ShareRequestAck" then
		shareAckReceived = true

		if not shareEnabled then
			self:UnregisterAllComm()
		end

		self:SendCommMessage("Clicked", shareMessage, "WHISPER", shareTarget, "NORMAL", self.OnCommProgress, self)
	else
		local success, data = Clicked:Deserialize(message, true)

		if success then
			Addon.BindingConfig.Window:SetPage(Addon.BindingConfig.Window.PAGE_IMPORT_STRING, data, sender)
		else
			Clicked:LogWarning(data)
		end

		shareEnabled = not success
	end

	AceConfigRegistry:NotifyChange("Clicked/Profile")
end

--- @private
--- @param sent number
--- @param total number
function ProfileOptions:OnCommProgress(sent, total)
	shareBytesSent = sent
	shareBytesTotal = total

	if sent == total then
		shareBusy = false
	end

	AceConfigRegistry:NotifyChange("Clicked/Profile")
end

Addon.ProfileOptions = ProfileOptions
