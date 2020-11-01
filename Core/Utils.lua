local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

function Clicked:ShowAddonIncompatibilityPopup(addon)
	StaticPopupDialogs["ClickedAddonIncompatibilityMessage"] = {
		text = L["ERR_ADDON_INCOMPAT_MESSAGE"]:format(addon),
		button1 = L["ERR_ADDON_INCOMPAT_BUTTON_KEEP_X"]:format(L["ADDON_NAME"]),
		button2 = L["ERR_ADDON_INCOMPAT_BUTTON_KEEP_X"]:format(addon),
		OnAccept = function()
			DisableAddOn(addon)
			ReloadUI()
		end,
		OnCancel = function()
			DisableAddOn("Clicked")
			ReloadUI()
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = false,
		preferredIndex = 3
	}

	StaticPopup_Show("ClickedAddonIncompatibilityMessage")
end

function Clicked:ShowInformationPopup(text)
	StaticPopupDialogs["ClickedInformationMessage"] = {
		text = text,
		button1 = L["MSG_POPUP_BUTTON_CONTINUE"],
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3
	}

	StaticPopup_Show("ClickedInformationMessage")
end

function Clicked:ShowConfirmationPopup(message, func, ...)
	StaticPopupDialogs["ClickedConfirmationMessage"] = {
		text = message,
		button1 = L["MSG_POPUP_BUTTON_YES"],
		button2 = L["MSG_POPUP_BUTTON_NO"],
		OnAccept = func,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3
	}

	StaticPopup_Show("ClickedConfirmationMessage")
end

function Clicked:DeepCopyTable(original)
	if original == nil then
		return nil
	end

	local result = {}

	for k, v in pairs(original) do
		if type(v) == "table" then
			v = self:DeepCopyTable(v)
		end

		result[k] = v
	end

	return result
end

function Clicked:IsClassic()
	return WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
end

-- Check if the specified keybind is "restricted", a restricted keybind
-- is not allowed to do various actions as it is required for core game
-- input (such as left and right mouse buttons).
--
-- Restricted keybinds can still be used for bindings, but they will
-- have limited functionality.
function Clicked:IsRestrictedKeybind(keybind)
	return keybind == "BUTTON1" or keybind == "BUTTON2"
end

-- Check if a binding's target unit can have a hostility.
-- This will be false when, for example, PARTY_2 is passed
-- in because party members are by definition always friendly.
-- (at the time of configuration at least, i.e. don't take
-- potential mind controls into account)
function Clicked:CanUnitBeHostile(unit)
	if unit == Clicked.TargetUnits.TARGET then
		return true
	end

	if unit == Clicked.TargetUnits.TARGET_OF_TARGET then
		return true
	end

	if unit == Clicked.TargetUnits.FOCUS then
		return true
	end

	if unit == Clicked.TargetUnits.MOUSEOVER then
		return true
	end

	if unit == Clicked.TargetUnits.HOVERCAST then
		return true
	end

	if unit == Clicked.TargetUnits.PET_TARGET then
		return true
	end

	return false
end

function Clicked:CanUnitBeDead(unit)
	if unit == Clicked.TargetUnits.TARGET then
		return true
	end

	if unit == Clicked.TargetUnits.TARGET_OF_TARGET then
		return true
	end

	if unit == Clicked.TargetUnits.FOCUS then
		return true
	end

	if unit == Clicked.TargetUnits.PARTY_1 then
		return true
	end

	if unit == Clicked.TargetUnits.PARTY_2 then
		return true
	end

	if unit == Clicked.TargetUnits.PARTY_3 then
		return true
	end

	if unit == Clicked.TargetUnits.PARTY_4 then
		return true
	end

	if unit == Clicked.TargetUnits.PARTY_5 then
		return true
	end

	if unit == Clicked.TargetUnits.MOUSEOVER then
		return true
	end

	if unit == Clicked.TargetUnits.HOVERCAST then
		return true
	end

	if unit == Clicked.TargetUnits.PET then
		return true
	end

	if unit == Clicked.TargetUnits.PET_TARGET then
		return true
	end

	return false
end

-- Check if a binding's target unit can have a follow up target.
-- This will be the case for most targets, but some targets act
-- as a stop sign in macro code as they will always be valid.
-- For example [@player] or [@cursor] will always be 'true' and
-- thus it doesn't make sense to allow targets beyond.
function Clicked:CanUnitHaveFollowUp(unit)
	if unit == Clicked.TargetUnits.PLAYER then
		return false
	end

	if unit == Clicked.TargetUnits.CURSOR then
		return false
	end

	if unit == Clicked.TargetUnits.HOVERCAST then
		return false
	end

	if unit == Clicked.TargetUnits.DEFAULT then
		return false
	end

	return true
end

function Clicked:GetActiveBindingAction(binding)
	if binding.type == Clicked.BindingTypes.SPELL then
		return binding.actions.spell
	end

	if binding.type == Clicked.BindingTypes.ITEM then
		return binding.actions.item
	end

	if binding.type == Clicked.BindingTypes.MACRO then
		return binding.actions.macro
	end

	if binding.type == Clicked.BindingTypes.UNIT_SELECT then
		return binding.actions.unitSelect
	end

	if binding.type == Clicked.BindingTypes.UNIT_MENU then
		return binding.actions.unitMenu
	end

	return nil
end

function Clicked:GetLocalizedTargetUnits(excludeHovercast)
	local items = {
		[Clicked.TargetUnits.DEFAULT] = L["BINDING_UI_PAGE_TARGETS_UNIT_DEFAULT"],
		[Clicked.TargetUnits.PLAYER] = L["BINDING_UI_PAGE_TARGETS_UNIT_PLAYER"],
		[Clicked.TargetUnits.TARGET] = L["BINDING_UI_PAGE_TARGETS_UNIT_TARGET"],
		[Clicked.TargetUnits.TARGET_OF_TARGET] = L["BINDING_UI_PAGE_TARGETS_UNIT_TARGETTARGET"],
		[Clicked.TargetUnits.HOVERCAST] = L["BINDING_UI_PAGE_TARGETS_UNIT_HOVERCAST"],
		[Clicked.TargetUnits.MOUSEOVER] = L["BINDING_UI_PAGE_TARGETS_UNIT_MOUSEOVER"],
		[Clicked.TargetUnits.FOCUS] = L["BINDING_UI_PAGE_TARGETS_UNIT_FOCUS"],
		[Clicked.TargetUnits.CURSOR] = L["BINDING_UI_PAGE_TARGETS_UNIT_CURSOR"],
		[Clicked.TargetUnits.PET] = L["BINDING_UI_PAGE_TARGETS_UNIT_PET"],
		[Clicked.TargetUnits.PET_TARGET] = L["BINDING_UI_PAGE_TARGETS_UNIT_PET_TARGET"],
		[Clicked.TargetUnits.PARTY_1] = L["BINDING_UI_PAGE_TARGETS_UNIT_PARTY"]:format("1"),
		[Clicked.TargetUnits.PARTY_2] = L["BINDING_UI_PAGE_TARGETS_UNIT_PARTY"]:format("2"),
		[Clicked.TargetUnits.PARTY_3] = L["BINDING_UI_PAGE_TARGETS_UNIT_PARTY"]:format("3"),
		[Clicked.TargetUnits.PARTY_4] = L["BINDING_UI_PAGE_TARGETS_UNIT_PARTY"]:format("4"),
		[Clicked.TargetUnits.PARTY_5] = L["BINDING_UI_PAGE_TARGETS_UNIT_PARTY"]:format("5")
	}

	local order = {
		Clicked.TargetUnits.DEFAULT,
		Clicked.TargetUnits.PLAYER,
		Clicked.TargetUnits.TARGET,
		Clicked.TargetUnits.TARGET_OF_TARGET,
		Clicked.TargetUnits.HOVERCAST,
		Clicked.TargetUnits.MOUSEOVER,
		Clicked.TargetUnits.FOCUS,
		Clicked.TargetUnits.CURSOR,
		Clicked.TargetUnits.PET,
		Clicked.TargetUnits.PET_TARGET,
		Clicked.TargetUnits.PARTY_1,
		Clicked.TargetUnits.PARTY_2,
		Clicked.TargetUnits.PARTY_3,
		Clicked.TargetUnits.PARTY_4,
		Clicked.TargetUnits.PARTY_5
	}

	if excludeHovercast then
		table.remove(order, 5)
	end

	return items, order
end

function Clicked:GetLocalizedTargetHostility()
	local items = {
		[Clicked.TargetHostility.ANY] = L["BINDING_UI_PAGE_TARGETS_HOSTILITY_ANY"],
		[Clicked.TargetHostility.HELP] = L["BINDING_UI_PAGE_TARGETS_HOSTILITY_FRIEND"],
		[Clicked.TargetHostility.HARM] = L["BINDING_UI_PAGE_TARGETS_HOSTILITY_HARM"]
	}

	local order = {
		Clicked.TargetHostility.ANY,
		Clicked.TargetHostility.HELP,
		Clicked.TargetHostility.HARM
	}

	return items, order
end

function Clicked:GetLocalizedTargetVitals()
	local items = {
		[Clicked.TargetVitals.ANY] = L["BINDING_UI_PAGE_TARGETS_VITALS_ANY"],
		[Clicked.TargetVitals.ALIVE] = L["BINDING_UI_PAGE_TARGETS_VITALS_ALIVE"],
		[Clicked.TargetVitals.DEAD] = L["BINDING_UI_PAGE_TARGETS_VITALS_DEAD"]
	}

	local order = {
		Clicked.TargetVitals.ANY,
		Clicked.TargetVitals.ALIVE,
		Clicked.TargetVitals.DEAD
	}

	return items, order
end

function Clicked:GetLocalizedTargetString(target)
	local result = {}

	if Clicked:CanUnitBeHostile(target.unit) and target.hostility ~= Clicked.TargetHostility.ANY then
		local hostility = self:GetLocalizedTargetHostility()
		table.insert(result, hostility[target.hostility])
	end

	if Clicked:CanUnitBeDead(target.unit) and target.vitals ~= Clicked.TargetVitals.ANY then
		local vitals = self:GetLocalizedTargetVitals()
		table.insert(result, vitals[target.vitals])
	end

	local units = self:GetLocalizedTargetUnits()
	table.insert(result, units[target.unit])

	return table.concat(result, " ")
end
