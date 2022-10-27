local AceGUI = LibStub("AceGUI-3.0")

--- @class ClickedInternal
local _, Addon = ...

function Addon:Skins_ElvInitialize()
	if not GetAddOnEnableState(UnitName("player"), "ElvUI") == 2 then
		return
	end

	local elv = unpack(ElvUI);
	if elv == nil or not elv.private.skins or not elv.private.skins.ace3Enable then
		return
	end

	local originalRegisterAsWidget = AceGUI.RegisterAsWidget
	local originalRegisterAsContainer = AceGUI.RegisterAsContainer

	local skins = elv:GetModule("Skins")

	AceGUI.RegisterAsWidget = function(self, widget)
		if widget.type == "ClickedToggleHeading" then
			widget.checkbg:CreateBackdrop()
			widget.checkbg.backdrop:SetInside(widget.checkbg, 4, 4)
			widget.checkbg.backdrop:SetFrameLevel(widget.checkbg.backdrop:GetFrameLevel() + 1)

			widget.checkbg:SetTexture()
			widget.highlight:SetTexture()

			hooksecurefunc(widget, "SetDisabled", skins.Ace3_CheckBoxSetDisabled)

			if elv.private.skins.checkBoxSkin then
				skins.Ace3_CheckBoxSetDesaturated(widget.check, widget.check:GetDesaturation())
				hooksecurefunc(widget.check, "SetDesaturated", skins.Ace3_CheckBoxSetDesaturated)

				widget.checkbg.backdrop:SetInside(widget.checkbg, 5, 5)
				widget.check:SetInside(widget.checkbg.backdrop)
				widget.check:SetTexture(elv.Media.Textures.Melli)
				widget.check.SetTexture = elv.noop
			else
				widget.check:SetOutside(widget.checkbg.backdrop, 3, 3)
			end

			widget.checkbg.SetTexture = elv.noop
			widget.highlight.SetTexture = elv.noop
		end

		return originalRegisterAsWidget(self, widget)
	end

	AceGUI.RegisterAsContainer = function(self, widget)
		if widget.type == "ClickedSimpleGroup" then
			-- Undo everything done by ElvUI
			widget.frame:SetTemplate("NoBackdrop")
			widget.frame:SetBackdropColor(0, 0, 0, 0)
			widget.frame.callbackBackdropColor = nil

			widget.content:ClearAllPoints()
			widget.content:SetPoint("TOPLEFT")
			widget.content:SetPoint("BOTTOMRIGHT")
		elseif widget.type == "ClickedTreeGroup" then
			widget.content:GetParent():SetTemplate("Transparent")
			widget.treeframe:SetTemplate("Transparent")
			skins:HandleScrollBar(widget.scrollbar)

			if Addon:IsGameVersionAtleast("BC") then
				skins:HandleButton(widget.sortButton, true)
			else
				skins:HandleButton(widget.sortButton, true, nil, true)
			end
		end

		return originalRegisterAsContainer(self, widget)
	end
end
