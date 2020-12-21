local AceGUI = LibStub("AceGUI-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")
local AceComm = LibStub("AceComm-3.0")
local LibDBIcon = LibStub("LibDBIcon-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

local Module

local importExportFrame = nil

-- Share to target player
local shareTarget = ""
local shareEnabled = false
local shareBusy = false
local shareAckReceived = false
local shareBytesSent = 0
local shareBytesTotal = 0
local shareMessage = ""

local function OverwriteCurrentProfile(data)
	local profile = table.wipe(Clicked.db.profile)

	for key in pairs(data) do
		profile[key] = data[key]
	end

	Clicked:ReloadDatabase()
end

local function OpenImportExportFrame(mode)
	if importExportFrame ~= nil and importExportFrame:IsVisible() then
		return
	end

	importExportFrame = AceGUI:Create("ClickedFrame")

	if mode == "export" then
		importExportFrame:SetTitle(L["Export Profile"])
		importExportFrame:SetStatusText(string.format(L["Exporting profile: %s"], Clicked.db:GetCurrentProfile()))
	elseif mode == "import" then
		importExportFrame:SetTitle(L["Import Profile"])
		importExportFrame:SetStatusText(string.format(L["Importing into profile: %s"], Clicked.db:GetCurrentProfile()))
	end

	importExportFrame:EnableResize(false)
	importExportFrame:SetWidth(600)
	importExportFrame:SetHeight(400)
	importExportFrame:SetLayout("flow")
	importExportFrame.frame:SetFrameStrata("FULLSCREEN_DIALOG")

	local textField = AceGUI:Create(mode == "export" and "ClickedReadOnlyMultilineEditBox" or "MultiLineEditBox")
	textField:SetNumLines(22)
	textField:SetFullWidth(true)
	textField:SetLabel("")

	importExportFrame:AddChild(textField)

	if mode == "export" then
		local text = Clicked:SerializeCurrentProfile(true)

		textField:SetText(text)
		textField:SetFocus()
		textField:HighlightText()
	elseif mode == "import" then
		textField:DisableButton(true)
		textField:SetFocus()
		textField:SetCallback("OnTextChanged", function(widget, event, text)
			local success, data = Clicked:DeserializeProfile(text, true)

			if success then
				local function OnConfirm()
					OverwriteCurrentProfile(data)
				end

				Clicked:ShowConfirmationPopup(L["Profile import successful, do you want to apply this profile? This will overwrite the current profile?"], OnConfirm)
				importExportFrame:Hide()
			else
				textField:SetText("")
				importExportFrame:SetStatusText(data)
			end
		end)
	end

	importExportFrame:SetCallback("OnClose", function(widget)
		AceGUI:Release(widget)
		InterfaceOptionsFrame_OpenToCategory(Module.profile)
	end)

	HideUIPanel(InterfaceOptionsFrame)
	HideUIPanel(GameMenuFrame)
end

Module = {
	["Initialize"] = function(self)
		local config = {
			type = "group",
			name = L["Clicked"],
			args = {
				minimapIcon = {
					name = L["Enable minimap icon"],
					desc = L["Enable or disable the minimap icon."],
					type = "toggle",
					order = 1,
					width = "full",
					set = function(info, val)
						Clicked.db.profile.minimap.hide = not val

						if val then
							LibDBIcon:Show("Clicked")
						else
							LibDBIcon:Hide("Clicked")
						end
					end,
					get = function(info)
						return not Clicked.db.profile.minimap.hide
					end
				},
				onKeyDown = {
					name = L["Cast on key down rather than key up"],
					desc = L["This option will make bindings trigger on the 'down' portion of a button press rather than the 'up' portion."],
					type = "toggle",
					order = 2,
					width = "full",
					set = function(info, val)
						Clicked.db.profile.options.onKeyDown = val

						for _, frame in Clicked:IterateClickCastFrames() do
							Clicked:RegisterFrameClicks(frame)
						end

						Clicked:RegisterFrameClicks(_G[Clicked.MACRO_FRAME_HANDLER_NAME])
						Clicked:ShowInformationPopup(L["If you are using custom unit frames you may have to adjust a setting within the unit frame configuration panel to enable support for this, and potentially even a UI reload."])
					end,
					get = function(info)
						return Clicked.db.profile.options.onKeyDown
					end
				}
			}
		}

		AceConfig:RegisterOptionsTable("Clicked", config)
		self.options = AceConfigDialog:AddToBlizOptions("Clicked", L["Clicked"])

		local profileOptions = AceDBOptions:GetOptionsTable(Clicked.db)

		-- Enhance profile options page with import/export buttons
		profileOptions.plugins = profileOptions.plugins or {}
		profileOptions.plugins["AceDBShare"] = {}

		local plugin = profileOptions.plugins["AceDBShare"]

		plugin.importExportDesc = {
			name = "\n" .. L["Import external profile data into your current profile, or export the current profile into a sharable format."],
			type = "description",
			order = 61,
		}

		plugin.import = {
			name = L["Import"],
			type = "execute",
			order = 62,
			func = function()
				OpenImportExportFrame("import")
			end
		}

		plugin.export = {
			name = L["Export"],
			type = "execute",
			order = 63,
			func = function()
				OpenImportExportFrame("export")
			end
		}

		plugin.sendToDesc = {
			name = "\n" .. L["Immediately share the current profile with another player. The target player must allow profile sharing first."],
			type = "description",
			order = 65
		}

		plugin.sendToName = {
			name = L["Target player"],
			type = "input",
			order = 66,
			disabled = function(info)
				return shareBusy
			end,
			get = function(info)
				return shareTarget
			end,
			set = function(info, value)
				shareTarget = value
			end
		}

		plugin.sendToButton = {
			name = L["Share"],
			type = "execute",
			order = 67,
			disabled = function(info)
				if Clicked:IsStringNilOrEmpty(shareTarget) then
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
						Clicked:ShowInformationPopup(string.format(L["Unable to send a message to %s. Make sure that they are online and have allowed profile sharing."], shareTarget))
					end
				end

				shareBusy = true

				-- Just wait for the ACK timeout if we're currently in combat, to prevent stuttering
				if not InCombatLockdown() then
					shareMessage = Clicked:SerializeCurrentProfile(false)
					shareAckReceived = false

					Module:RegisterComm("Clicked", "OnCommReceived")
					Module:SendCommMessage("Clicked", "ShareRequest", "WHISPER", shareTarget, "NORMAL")
				end

				C_Timer.After(5, OnTimeout)
			end
		}

		plugin.allowReceiveSendTo = {
			name = L["Allow profile sharing"],
			type = "toggle",
			order = 68,
			get = function(info)
				return shareEnabled
			end,
			set = function(info, value)
				shareEnabled = value

				if value then
					Module:RegisterComm("Clicked", "OnCommReceived")
				else
					Module:UnregisterAllComm()
				end
			end
		}

		plugin.sendProgressDesc = {
			name = function(info)
				if not shareAckReceived then
					local label = L["Waiting for acknowledgement from %s"]
					return string.format(label, shareTarget)
				else
					local label = L["Sending profile to %s, progress %d/%d (%d%%)"]

					if shareBytesTotal > 0 then
						local percent = math.floor((shareBytesSent / shareBytesTotal) * 100)
						return string.format(label, shareTarget, shareBytesSent, shareBytesTotal, percent)
					end
				end

				return ""
			end,
			type = "description",
			order = 69,
			hidden = function(info)
				return not shareBusy
			end
		}

		AceConfig:RegisterOptionsTable("Clicked/Profile", profileOptions)
		self.profile = AceConfigDialog:AddToBlizOptions("Clicked/Profile", L["Profiles"], "Clicked")

		AceComm:Embed(self)

		if not C_ChatInfo.IsAddonMessagePrefixRegistered("Clicked") then
			C_ChatInfo.RegisterAddonMessagePrefix("Clicked")
		end
	end,

	["OnCommReceived"] = function(self, prefix, message, distribution, sender)
		if InCombatLockdown() then
			return
		end

		if message == "ShareRequest" then
			if shareEnabled then
				Module:SendCommMessage("Clicked", "ShareRequestAck", "WHISPER", sender, "NORMAL")
			end
		elseif message == "ShareRequestAck" then
			shareAckReceived = true

			if not shareEnabled then
				Module:UnregisterAllComm()
			end

			Module:SendCommMessage("Clicked", shareMessage, "WHISPER", shareTarget, "NORMAL", Module.OnCommProgress, self)
		else
			local success, data = Clicked:DeserializeProfile(message, false)

			if success then
				local function OnConfirm()
					OverwriteCurrentProfile(data)
				end

				Clicked:ShowConfirmationPopup(string.format(L["%s has sent you a Clicked profile, do you want to apply it? This will overwrite the current profile."], sender), OnConfirm)

				shareEnabled = false
			end
		end

		AceConfigRegistry:NotifyChange("Clicked/Profile")
	end,

	["OnCommProgress"] = function(self, sent, total)
		shareBytesSent = sent
		shareBytesTotal = total

		if sent == total then
			shareBusy = false
		end

		AceConfigRegistry:NotifyChange("Clicked/Profile")
	end,

	["OnChatCommandReceived"] = function(self, args)
		for _, arg in ipairs(args) do
			if arg == "profile" then
				InterfaceOptionsFrame_OpenToCategory(self.profile)
				InterfaceOptionsFrame_OpenToCategory(self.profile)
				break
			end
		end
	end,
}

Clicked:RegisterModule("AddonConfig", Module)
