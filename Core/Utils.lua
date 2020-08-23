function Clicked:Trim(str)
	return str:gsub("^%s*(.-)%s*$", "%1")
end

function Clicked:StartsWith(str, start)
	return str:sub(1, #start) == start
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

	if unit == self.TARGET_UNIT_MOUSEOVER_FRAME then
		return true
	end

	return false
end