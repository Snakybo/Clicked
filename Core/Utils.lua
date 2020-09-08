local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

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
function Clicked:CanBindingTargetUnitBeHostile(unit)
	if unit == self.TARGET_UNIT_TARGET then
		return true
	end

	if unit == self.TARGET_UNIT_FOCUS then
		return true
	end

	if unit == self.TARGET_UNIT_MOUSEOVER then
		return true
	end

	return false
end

-- Check if a binding's target unit can have a follow up target.
-- This will be the case for most targets, but some targets act
-- as a stop sign in macro code as they will always be valid.
-- For example [@player] or [@cursor] will always be 'true' and
-- thus it doesn't make sense to allow targets beyond.
function Clicked:CanBindingTargetHaveFollowUp(unit)
	if unit == self.TARGET_UNIT_PLAYER then
		return false
	end

	if unit == self.TARGET_UNIT_CURSOR then
		return false
	end

	return true
end

-- Gets the virtual targeting mode of a binding. This may differ
-- from what can be visualized in the UI. In the majority
-- of these we simply don't show the UI and thus don't allow the user
-- to change it at the moment, and in order to protect user data,
-- we won't alter the actual data but instead determine which targeting
-- mode should be used based on the other data available.
function Clicked:GetBindingTargetingMode(binding)
	-- If the binding type is set to target a unit or open the
	-- unit context menu, force it to be a hovercast to prevent
	-- it from working on 3D world units.

	if binding.type == self.TYPE_UNIT_SELECT or binding.type == self.TYPE_UNIT_MENU then
		return self.TARGETING_MODE_HOVERCAST
	end

	-- If the binding uses a restricted keybind (left mouse or
	-- right mouse), force it to be a hovercast binding as
	-- we would break the game otherwise.

	if self:IsRestrictedKeybind(binding.keybind) then
		return self.TARGETING_MODE_HOVERCAST
	end

	-- Pretend the global targeting mode is identical to the
	-- dynamic priority targeting mode everywhere but in the UI.

	if binding.targetingMode == self.TARGETING_MODE_GLOBAL then
		return self.TARGETING_MODE_DYNAMIC_PRIORITY
	end

	return binding.targetingMode
end
