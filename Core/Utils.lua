local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

function Clicked:StringContains(str, pattern)
	return string.find(str, pattern) ~= nil
end

function Clicked:Trim(str)
	return str:gsub("^%s*(.-)%s*$", "%1")
end

function Clicked:StartsWith(str, start)
	return str:sub(1, #start) == start
end

function Clicked:ShowAddonIncompatibilityPopup(addon)
	StaticPopupDialogs["ClickedAddonIncompatibilityMessage" .. addon] = {
		text = L["ERR_ADDON_INCOMPATIBILITY"]:format(addon),
		button1 = L["ERR_ADDON_INCOMPATIBILITY_KEEP"]:format(L["NAME"]),
		button2 = L["ERR_ADDON_INCOMPATIBILITY_KEEP"]:format(addon),
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

	StaticPopup_Show("ClickedAddonIncompatibilityMessage" .. addon)
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
	if unit == self.TARGET_UNIT_TARGET then
		return true
	end

	if unit == self.TARGET_UNIT_FOCUS then
		return true
	end

	if unit == self.TARGET_UNIT_MOUSEOVER then
		return true
	end

	if unit == self.TARGET_UNIT_HOVERCAST then
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
	if unit == self.TARGET_UNIT_PLAYER then
		return false
	end

	if unit == self.TARGET_UNIT_CURSOR then
		return false
	end

	if unit == self.TARGET_UNIT_HOVERCAST then
		return false
	end

	if unit == self.TARGET_UNIT_GLOBAL then
		return false
	end

	return true
end

