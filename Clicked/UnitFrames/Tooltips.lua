local lastTooltipUpdateTime

local function IsKeybindValidForCurrentModifiers(keybind)
	local mods = {}
	local current = {
		count = 0
	}

	for match in string.gmatch(keybind, "[^-]+") do
		table.insert(mods, match)
	end

	table.remove(mods, #mods)

	if #mods == 0 and IsModifierKeyDown() then
		return false
	end

	if IsControlKeyDown() then
		current["CTRL"] = true
		current.count = current.count + 1
	end

	if IsAltKeyDown() then
		current["ALT"] = true
		current.count = current.count + 1
	end

	if IsShiftKeyDown() then
		current["SHIFT"] = true
		current.count = current.count + 1
	end

	if IsMetaKeyDown() then
		current["META"] = true
		current.count = current.count + 1
	end

	if #mods ~= current.count then
		return
	end

	for _, mod in ipairs(mods) do
		if not current[mod] then
			return false
		end
	end

	return true
end

local function IsTooltipModuleEnabled()
	return Clicked.db.profile.options.tooltips
end

local function SortBindings(left, right)
	return Clicked:CompareBindings(left, right)
end

local function OnTooltipSetUnit(self)
	if not IsTooltipModuleEnabled() then
		return
	end

	lastTooltipUpdateTime = GetTime()
	local _, unit = self:GetUnit()

	if Clicked:IsStringNilOrEmpty(unit) or GetMouseFocus() == WorldFrame then
		return
	end

	local bindings = Clicked:GetHovercastBindingsForUnit(unit)
	local first = true

	table.sort(bindings, SortBindings)

	for _, binding in ipairs(bindings) do
		if IsKeybindValidForCurrentModifiers(binding.keybind) then
			local left = Clicked:GetActiveBindingValue(binding)
			local right = binding.keybind

			if first then
				self:AddLine(" ")
				self:AddLine(ABILITIES, 1, 0.85, 0)
				first = false
			end

			self:AddDoubleLine(left, right, 1, 1, 1, 0, 1, 0)
		end
	end
end

function Clicked:RegisterUnitFrameTooltips()
	-- Add a delay here to make sure we're the always at the bottom of the tooltip
	C_Timer.After(1, function()
		GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)
	end)
end

function Clicked:UpdateUnitFrameTooltips()
	if not IsTooltipModuleEnabled() then
		return
	end

	if not GameTooltip:IsForbidden() and GameTooltip:IsShown() and GetTime() ~= lastTooltipUpdateTime then
		local _, unit = GameTooltip:GetUnit()

		if not Clicked:IsStringNilOrEmpty(unit) and unit ~= "mouseover" then
			GameTooltip:SetUnit(unit)
		end
	end
end
