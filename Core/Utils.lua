function Clicked:Trim(str)
	return str:gsub("^%s*(.-)%s*$", "%1")
end

function Clicked:StartsWith(str, start)
	return str:sub(1, #start) == start
end

function Clicked:ShowAddonIncompatibilityPopup(addon)
	StaticPopupDialogs["ClickedAddonIncompatibilityMessage" .. addon] = {
		text = Clicked.NAME .. " is not compatible with " .. addon .. " and requires one of the two to be disabled.",
		button1 = "Keep " .. Clicked.NAME,
		button2 = "Keep " .. addon,
		OnAccept = function()
			DisableAddOn(addon)
			ReloadUI()
		end,
		OnCancel = function()
			DisableAddOn(Clicked.NAME)
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

function Clicked:GetBindingTargetingMode(binding)
	if binding.type == self.TYPE_MACRO then
		return self.TARGETING_MODE_GLOBAL
	end

	if binding.type == self.TYPE_UNIT_SELECT or binding.type == self.TYPE_UNIT_MENU then
		return self.TARGETING_MODE_HOVERCAST
	end

	if self:IsRestrictedKeybind(binding.keybind) then
		return self.TARGETING_MODE_HOVERCAST
	end

	return binding.targetingMode
end
