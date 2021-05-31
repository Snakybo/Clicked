--- @type ClickedInternal
local _, Addon = ...

--- @type Localization
local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

local KEYBIND_ORDER_LIST = {
	"BUTTON1", "BUTTON2", "BUTTON3", "BUTTON4", "BUTTON5", "MOUSEWHEELUP", "MOUSEWHEELDOWN",
	"`", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "-", "=",
	"NUMPAD0", "NUMPAD1", "NUMPAD2", "NUMPAD3", "NUMPAD4", "NUMPAD5", "NUMPAD6", "NUMPAD7", "NUMPAD8", "NUMPAD9", "NUMPADDIVIDE", "NUMPADMULTIPLY", "NUMPADMINUS", "NUMPADPLUS", "NUMPADDECIMAL",
	"F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12", "F13",
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
	"TAB", "CAPSLOCK", "INSERT", "DELETE", "HOME", "END", "PAGEUP", "PAGEDOWN", "[", "]", "\\", ";", "'", ",", ".", "/"
}

-- /run local a,b,c=table.concat,{},{};for d=1,GetNumShapeshiftForms() do local _,_,_,f=GetShapeshiftFormInfo(d);local e=GetSpellInfo(f);b[#b+1]=e;c[#c+1]=f;end print("{ "..a(c, ",").." }, --"..a(b,", "))
local shapeshiftForms = {
	-- Arms Warrior
	-- Fury Warrior
	-- Protection Warrior
	-- Initial Warrior
	[71] = {},
	[72] = {},
	[73] = {},
	[1446] = {},

	-- Holy Paladin
	-- Protection Paladin
	-- Retribution Paladin
	-- Initial Paladin
	[65] = { 32223, 465, 317920, 183435 }, -- Crusader Aura, Devotion Aura, Concentration Aura, Retribution Aura
	[66] = { 32223, 465, 317920, 183435 }, -- Crusader Aura, Devotion Aura, Concentration Aura, Retribution Aura
	[70] = { 32223, 465, 317920, 183435 }, -- Crusader Aura, Devotion Aura, Concentration Aura, Retribution Aura
	[1451] = { 32223, 465, 317920, 183435 }, -- Crusader Aura, Devotion Aura, Concentration Aura, Retribution Aura

	-- Beast Mastery Hunter
	-- Marksmanship Hunter
	-- Survival Hunter
	-- Initial Hunter
	[253] = {},
	[254] = {},
	[255] = {},
	[1448] = {},

	-- Assassination Rogue
	-- Outlaw Rogue
	-- Subtlety Rogue
	-- Initial Rogue
	[259] = { 1784 }, -- Stealth
	[260] = { 1784 }, -- Stealth
	[261] = { 1784 }, -- Stealth
	[1453] = { 1784 },  -- Stealth

	-- Discipline Priest
	-- Holy Priest
	-- Shadow Priest
	-- Initial Priest
	[256] = {},
	[257] = {},
	[258] = { 232698 }, -- Shadowform
	[1452] = {},

	-- Blood Death Knight
	-- Frost Death Knight
	-- Unholy Death Knight
	-- Initial Death Knight
	[250] = {},
	[251] = {},
	[252] = {},
	[1455] = {},

	-- Elemental Shaman
	-- Enhancement Shaman
	-- Restoration Shaman
	-- Initial Shaman
	[262] = {},
	[263] = {},
	[264] = {},
	[1444] = {},

	-- Arcane Mage
	-- Fire Mage
	-- Frost Mage
	-- Initial Mage
	[62] = {},
	[63] = {},
	[64] = {},
	[1449] = {},

	-- Afflication Warlock
	-- Demonology Warlock
	-- Destruction Warlock
	-- Initial Warlock
	[265] = {},
	[266] = {},
	[267] = {},
	[1454] = {},

	-- Brewmaster Monk
	-- Mistweaver Monk
	-- Windwalker Monk
	-- Initial Monk
	[268] = {},
	[270] = {},
	[269] = {},
	[1450] = {},

	-- Balance Druid
	-- Feral Druid
	-- Guardian Druid
	-- Restoration Druid
	-- Initial Druid
	[102] = { 5487, 768, 783, 24858, 114282, 210053 }, -- Bear Form, Cat Form, Travel Form, Moonkin Form, Treant Form, Mount Form
	[103] = { 5487, 768, 783, 197625, 114282, 210053 }, -- Bear Form, Cat Form, Travel Form, Moonkin Form, Treant Form, Mount Form
	[104] = { 5487, 768, 783, 197625, 114282, 210053 }, -- Bear Form, Cat Form, Travel Form, Moonkin Form, Treant Form, Mount Form
	[105] = { 5487, 768, 783, 197625, 114282, 210053 }, -- Bear Form, Cat Form, Travel Form, Moonkin Form, Treant Form, Mount Form
	[1447] = { 5487, 768, 783, 114282, 210053 }, -- Bear Form, Cat Form, Travel Form, Treant Form, Mount Form

	-- Havoc Demon Hunter
	-- Vengeance Demon Hunter
	-- Initial Demon Hunter
	[577] = {},
	[581] = {},
	[1456] = {}
}

local classicShapeshiftForms = {
	WARRIOR = {},

	PALADIN = {},

	HUNTER = {},

	ROGUE = {},

	PRIEST = {},

	SHAMAN = {},

	MAGE = {},

	WARLOCK = {},

	DRUID = {
		{ 9634, 5487 }, -- Dire Bear Form, Bear Form
		{ 1066 }, -- Aquatic Form
		{ 768 }, -- Cat Form
		{ 783 }, -- Travel Form
		{ 24858, 33891 }, -- Moonkin Form, Tree of Life Form
		{ 40120, 33943 } -- Swift Flight Form, Flight Form
	}
}

-- Local support functions

local function errorhandler(err)
	return geterrorhandler()(err)
end

local function safecall(func, ...)
	if func then
		return xpcall(func, errorhandler, ...)
	end
end

---@param keybind string
---@return integer
local function GetKeybindIndex(keybind)
	local mods = {}
	local result = ""

	for match in string.gmatch(keybind, "[^-]+") do
		table.insert(mods, match)
		result = match
	end

	table.remove(mods, #mods)

	local index = #KEYBIND_ORDER_LIST + 1
	local found = false

	for i = 1, #KEYBIND_ORDER_LIST do
		if KEYBIND_ORDER_LIST[i] == result then
			index = i
			found = true
			break
		end
	end

	-- register this unknown keybind for this session
	if not found then
		table.insert(KEYBIND_ORDER_LIST, result)
	end

	for i = 1, #mods do
		if mods[i] == "CTRL" then
			index = index + 1000
		end

		if mods[i] == "ALT" then
			index = index + 10000
		end

		if mods[i] == "SHIFT" then
			index = index + 100000
		end

		if mods[i] == "META" then
			index = index + 1000000
		end
	end

	return index
end

---@param keybind string
---@return string modifiers
---@return string key
local function GetKeybindModifiersAndKey(keybind)
	local modifiers = ""
	local current = ""

	for i = 1, #keybind do
		local char = string.sub(keybind, i, i)

		if char == "-" and #current > 0 then
			if not Addon:IsStringNilOrEmpty(modifiers) then
				modifiers = modifiers .. "-" .. current
			else
				modifiers = current
			end

			current = ""
		else
			current = current .. char
		end
	end

	return modifiers, current
end

StaticPopupDialogs["CLICKED_INCOMPATIBLE_ADDON"] = {
	text = "",
	button1 = string.format(L["Keep %s"], L["Clicked"]),
	button2 = "",
	OnShow = function(self)
		self.text:SetFormattedText(L["Clicked is not compatible with %s and requires one of the two to be disabled."], self.data.addon)
		self.button2:SetFormattedText(L["Keep %s"],self.data.addon)
	end,
	OnAccept = function(self)
		DisableAddOn(self.data.addon)
		ReloadUI()
	end,
	OnCancel = function()
		DisableAddOn("Clicked")
		ReloadUI()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = false
}

StaticPopupDialogs["CLICKED_MESSAGE"] = {
	text = "",
	button1 = CONTINUE,
	OnShow = function(self)
		self.text:SetText(self.data.text)
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true
}

StaticPopupDialogs["CLICKED_CONFIRM"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnShow = function(self)
		self.text:SetText(self.data.text)
	end,
	OnAccept = function(self)
		safecall(self.data.onAccept)
	end,
	OnCancel = function(self)
		safecall(self.data.onCancel)
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true
}

-- Private addon API

--- @param addon string
function Addon:ShowAddonIncompatibilityPopup(addon)
	StaticPopup_Show("CLICKED_INCOMPATIBLE_ADDON", "", "", { addon = addon })
end

--- @param text string
function Addon:ShowInformationPopup(text)
	StaticPopup_Show("CLICKED_MESSAGE", "", "", { text = text })
end

--- @param message string
--- @param onAccept function
--- @param onCancel function
function Addon:ShowConfirmationPopup(message, onAccept, onCancel)
	StaticPopup_Show("CLICKED_CONFIRM", "", "", {
		text = message,
		onAccept = onAccept,
		onCancel = onCancel
	})
end

--- @generic T : table
--- @param original T
--- @return T
function Addon:DeepCopyTable(original)
	if original == nil then
		return nil
	end

	local result = {}

	for k, v in pairs(original) do
		if type(v) == "table" then
			v = Addon:DeepCopyTable(v)
		end

		result[k] = v
	end

	return result
end

--- @param string string
--- @param keyword string
--- @return string
function Addon:GetDataFromString(string, keyword)
	if Addon:IsStringNilOrEmpty(string) or Addon:IsStringNilOrEmpty(keyword) then
		return nil
	end

	local pattern = string.format("<%s=(.-)>", keyword)
	local match = string.match(string, pattern)

	return match
end

--- @param unit string
--- @param addPrefix boolean
--- @return string unit
--- @return boolean needsExistsCheck
function Addon:GetWoWUnitFromUnit(unit, addPrefix)
	local units = {
		[Addon.TargetUnits.PLAYER] = "player",
		[Addon.TargetUnits.TARGET] = "target",
		[Addon.TargetUnits.TARGET_OF_TARGET] = "targettarget",
		[Addon.TargetUnits.MOUSEOVER] = "mouseover",
		[Addon.TargetUnits.MOUSEOVER_TARGET] = "mouseovertarget",
		[Addon.TargetUnits.PET] = "pet",
		[Addon.TargetUnits.PET_TARGET] = "pettarget",
		[Addon.TargetUnits.PARTY_1] = "party1",
		[Addon.TargetUnits.PARTY_2] = "party2",
		[Addon.TargetUnits.PARTY_3] = "party3",
		[Addon.TargetUnits.PARTY_4] = "party4",
		[Addon.TargetUnits.PARTY_5] = "party5",
		[Addon.TargetUnits.ARENA_1] = "arena1",
		[Addon.TargetUnits.ARENA_2] = "arena2",
		[Addon.TargetUnits.ARENA_3] = "arena3",
		[Addon.TargetUnits.FOCUS] = "focus",
		[Addon.TargetUnits.CURSOR] = "cursor"
	}

	local needsExistsCheck = {
		[Addon.TargetUnits.TARGET] = true,
		[Addon.TargetUnits.TARGET_OF_TARGET] = true,
		[Addon.TargetUnits.MOUSEOVER] = true,
		[Addon.TargetUnits.MOUSEOVER_TARGET] = true,
		[Addon.TargetUnits.PET] = true,
		[Addon.TargetUnits.PET_TARGET] = true,
		[Addon.TargetUnits.PARTY_1] = true,
		[Addon.TargetUnits.PARTY_2] = true,
		[Addon.TargetUnits.PARTY_3] = true,
		[Addon.TargetUnits.PARTY_4] = true,
		[Addon.TargetUnits.PARTY_5] = true,
		[Addon.TargetUnits.ARENA_1] = true,
		[Addon.TargetUnits.ARENA_2] = true,
		[Addon.TargetUnits.ARENA_3] = true,
		[Addon.TargetUnits.FOCUS] = true
	}

	local target = units[unit]
	if target ~= nil and addPrefix then
		target = "@" .. target
	end

	return target, needsExistsCheck[unit] or false
end

---@param binding Binding
---@return boolean
function Addon:HasBindingValue(binding)
	assert(Addon:IsBindingType(binding), "bad argument #1, expected Binding but got " .. type(binding))

	local value = Addon:GetBindingValue(binding)
	return not Addon:IsStringNilOrEmpty(tostring(value))
end

--- @param binding Binding
--- @return string|integer
function Addon:GetBindingValue(binding)
	assert(Addon:IsBindingType(binding), "bad argument #1, expected Binding but got " .. type(binding))

	if binding.type == Addon.BindingTypes.SPELL then
		local spell = binding.action.spellValue
		return self:GetSpellInfo(spell) or spell
	end

	if binding.type == Addon.BindingTypes.ITEM then
		local item = binding.action.itemValue

		if type(item) == "number" and item < 20 then
			return item
		end

		return self:GetItemInfo(item) or item
	end

	if binding.type == Addon.BindingTypes.MACRO or binding.type == Addon.BindingTypes.APPEND then
		return binding.action.macroValue
	end

	return nil
end

---@param binding Binding
---@return string name
---@return string icon
---@return number id
function Addon:GetSimpleSpellOrItemInfo(binding)
	assert(Addon:IsBindingType(binding), "bad argument #1, expected Binding but got " .. type(binding))

	if binding.type == Addon.BindingTypes.SPELL then
		local name, _, icon, _, _, _, id = Addon:GetSpellInfo(binding.action.spellValue)
		return name, icon, id
	end

	if binding.type == Addon.BindingTypes.ITEM then
		local name, _, _, _, _, _, _, _, _, icon = Addon:GetItemInfo(binding.action.itemValue)

		if name == nil then
			return nil, nil, nil
		end

		return name, icon, self:GetItemId(name)
	end

	return nil, nil, nil
end

--- @param binding Binding
--- @return string name
--- @return string|number icon
function Addon:GetBindingNameAndIcon(binding)
	local function IsValidIcon(icon)
		if icon == nil then
			return false
		end

		if type(icon) == "string" and #icon == 0 then
			return false
		end

		if type(icon) == "number" and icon <= 0 then
			return false
		end

		return true
	end

	local name = ""
	local icon = "Interface\\ICONS\\INV_Misc_QuestionMark"

	if binding.type == Addon.BindingTypes.SPELL or binding.type == Addon.BindingTypes.ITEM then
		local label = binding.type == Addon.BindingTypes.SPELL and L["Cast %s"] or L["Use %s"]

		local spellName, spellIcon = Addon:GetSimpleSpellOrItemInfo(binding)
		local value = Addon:GetBindingValue(binding)

		if spellName ~= nil or value ~= nil then
			name = string.format(label, spellName or value)
		end

		if IsValidIcon(spellIcon) then
			icon = spellIcon
		end
	elseif binding.type == Addon.BindingTypes.MACRO or binding.type == Addon.BindingTypes.APPEND then
		if Addon:IsStringNilOrEmpty(binding.action.macroName) then
			name = L["Run custom macro"]
		else
			name = binding.action.macroName
		end

		if binding.action.macroIcon ~= nil then
			icon = binding.action.macroIcon
		end
	elseif binding.type == Addon.BindingTypes.UNIT_SELECT then
		name = L["Target the unit"]
	elseif binding.type == Addon.BindingTypes.UNIT_MENU then
		name = L["Open the unit menu"]
	end

	return name, icon
end

--- @param input string|integer
--- @return string itemName
--- @return string itemLink
--- @return number itemQuality
--- @return number itemLevel
--- @return number itemMinLevel
--- @return string itemType
--- @return string itemSubType
--- @return number itemStackCount
--- @return string itemEquipLoc
--- @return number itemTexture
--- @return number sellPrice
--- @return number classID
--- @return number subclassID
--- @return number bindType
--- @return number expacID
--- @return number setID
--- @return boolean isCraftingReagent
function Addon:GetItemInfo(input)
	assert(type(input) == "string" or type(input) == "number", "bad argument #1, expected string or number but got " .. type(input))

	local itemId = tonumber(input)

	if itemId ~= nil then
		input = itemId

		if itemId >= 0 and itemId <= 19 then
			input = GetInventoryItemID("player", itemId)

			if input == nil then
				return nil
			end
		end
	end

	return GetItemInfo(input)
end

--- @param input string|integer
--- @return string name
--- @return nil rank
--- @return integer icon
--- @return number castTime
--- @return number minRange
--- @return number maxRange
--- @return integer spellId
function Addon:GetSpellInfo(input)
	assert(type(input) == "string" or type(input) == "number", "bad argument #1, expected string or number but got " .. type(input))

	local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(input)

	if Addon:IsClassic() or Addon:IsBC() then
		local subtext = GetSpellSubtext(spellId)

		if not self:IsStringNilOrEmpty(subtext) then
			name = string.format("%s(%s)", name, subtext)
		end
	end

	return name, rank, icon, castTime, minRange, maxRange, spellId
end

--- Get the ID for the specified item name.
--- @param name string
--- @return integer
function Addon:GetItemId(name)
	assert(type(name) == "string", "bad argument #1, expected string but got " .. type(name))

	local itemName, link = Addon:GetItemInfo(name)

	if itemName == nil then
		return nil
	end

	local _, _, _, _, id = string.find(link, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
	return tonumber(id)
end

--- Get the spell ID for the specified spell name.
--- @param name string
--- @return integer
function Addon:GetSpellId(name)
	assert(type(name) == "string", "bad argument #1, expected string but got " .. type(name))

	return select(7, self:GetSpellInfo(name))
end

--- Generate an attribute identifier for a key. This will
--- separate the keybind into two parts: a prefix, and a suffix.
---
--- The prefix is always an empty string unless the key is a mouse
--- button _and_ the `hovercast` parameter has been set to `true`.
---
--- That will allow for the generation of proper frame attribute keys:
---
--- * `"BUTTON1"` == `"", "1"` == `"type1"`
--- * `"SHIFT-BUTTON1"` == `"shift", "1"` == `"shift-type1"`
--- * etc.
---
--- For any keys that are _not_ mouse buttons, or the `hovercast`
--- parameter has been set to `false`, a custom identifier will
--- be generated, generally prefixed by `clicked-mouse-` or
--- `clicked-button-` for mouse buttons and all other buttons respectively.
---
--- * `"T"` == `"", "clicked-button-t"` == `"type-clicked-button-t"`
--- * `"SHIFT-T"` == `"", "clicked-button-shiftt"` == `"type-clicked-button-shiftt"`
--- * `"BUTTON3"` == `"", "clicked-mouse-3"` == `"type-clicked-mouse-3"`
--- * `"SHIFT-BUTTON3"` == `"", "clicked-mouse-shift3"` == `"type-clicked-mouse-shift3"`
---
--- @param keybind string
--- @param hovercast boolean
--- @return string prefix
--- @return string suffix
function Addon:CreateAttributeIdentifier(keybind, hovercast)
	local mods, key = GetKeybindModifiersAndKey(keybind)
	local buttonIndex = string.match(key, "^BUTTON(%d+)$")

	-- convert the parts to lowercase so it fits the attribute naming style
	mods = string.lower(mods)
	key = string.lower(key)

	if buttonIndex ~= nil and hovercast then
		key = buttonIndex
	elseif buttonIndex ~= nil then
		key = "clicked-mouse-" .. tostring(mods) .. tostring(buttonIndex)
		mods = ""
	else
		key = "clicked-button-" .. tostring(mods) .. tostring(key)
		mods = ""
	end

	return mods, key
end

--- Check if a string is `nil` or has a length of `0`.
---
--- @param string string
--- @return boolean
function Addon:IsStringNilOrEmpty(string)
	if string == nil then
		return true
	end

	assert(type(string) == "string", "bad argument #1, expected string but got " .. type(string))
	return #string == 0
end

---@param string string
---@return string
function Addon:TrimString(string)
	string = string or ""
	return string.gsub(string, "^%s*(.-)%s*$", "%1")
end

--- Compare two bindings, for use in a comparison function such as `table.sort`
--- This function is stable and will return the opposite result if called with inverted parameters
---
--- @param left Binding
--- @param right Binding
--- @return boolean
function Addon:CompareBindings(left, right)
	assert(Addon:IsBindingType(left), "bad argument #1, expected Binding but got " .. type(left))
	assert(Addon:IsBindingType(right), "bad argument #2, expected Binding but got " .. type(right))

	do
		local leftLoad = Addon:CanBindingLoad(left)
		local rightLoad = Addon:CanBindingLoad(right)

		if leftLoad and not rightLoad then
			return true
		end

		if not leftLoad and rightLoad then
			return false
		end
	end

	if left.keybind == "" and right.keybind ~= "" then
		return false
	end

	if left.keybind ~= "" and right.keybind == "" then
		return true
	end

	if left.keybind == right.keybind then
		local leftValue = Addon:GetBindingValue(left)
		local rightValue = Addon:GetBindingValue(right)

		if leftValue ~= nil and rightValue == nil then
			return true
		end

		if leftValue == nil and rightValue ~= nil then
			return false
		end

		if leftValue == nil and rightValue == nil then
			return left.identifier < right.identifier
		end

		return tostring(leftValue) < tostring(rightValue)
	end

	return GetKeybindIndex(left.keybind) < GetKeybindIndex(right.keybind)
end

--- Get all available shapeshift forms the the specified spec ID.
--- Note that this does not mean _currently available_ shapeshift forms,
--- just all possible shapeshift forms.
---
--- It is important that we use this instead of `GetNumShapeshiftForms` and
--- `GetShapeshiftFormInfo` as those will dynamically change depending on what
--- the player currently knows, which can vary depending on talents or level.
---
--- To ensure that shapeshift form data does not get corrupted when switching
--- talents, we store all available shapeshift forms manually.
---
--- @param specId integer
--- @return integer[]
function Addon:GetShapeshiftFormsForSpecId(specId)
	local forms = shapeshiftForms[specId] or {}
	return { unpack(forms) }
end

--- Get all available classic shapeshift forms the the specified class name.
--- Note that this does not mean _currently available_ shapeshift forms,
--- just all possible shapeshift forms.
---
--- To ensure that shapeshift form data does not get corrupted when switching
--- talents, we store all available shapeshift forms manually.
---
--- @param className string
--- @return integer[]
function Addon:GetClassicShapeshiftFormsForClass(className)
	local forms = classicShapeshiftForms[className] or {}
	return { unpack(forms) }
end

---@param binding Binding
---@return integer[]
function Addon:GetAvailableShapeshiftForms(binding)
	local form = binding.load.form
	local forms = {}

	-- Forms need to be zero-indexed
	if form.selected == 1 then
		forms[1] = form.single - 1
	elseif form.selected == 2 then
		for i = 1, #form.multiple do
			forms[i] = form.multiple[i] - 1
		end
	end

	if Addon:IsGameVersionAtleast("RETAIL") then
		if select(2, UnitClass("player")) == "DRUID" then
			local specId = GetSpecializationInfo(GetSpecialization())
			local all = Addon:GetShapeshiftFormsForSpecId(specId)
			local available = {}
			local result = {}

			for _, spellId in ipairs(all) do
				if IsSpellKnown(spellId) then
					table.insert(available, spellId)
				end
			end

			for i = 1, #forms do
				local formId = forms[i]

				-- 0 is [form:0] aka humanoid
				if formId == 0 then
					table.insert(result, formId)

					-- Incarnation: Tree of Life does not show up as a shapeshift form,
					-- but it will always be NUM_SHAPESHIFT_FORMS + 1 (See: #9)
					if IsSpellKnown(33891) then
						table.insert(result, GetNumShapeshiftForms() + 1)
					end
				else
					for j = 1, #available do
						if available[j] == all[formId] then
							table.insert(result, j)
							break
						end
					end
				end
			end

			forms = result
		end
	end

	return forms
end

--- Iterate through all available shapeshift forms, this function behaves
--- slightly differently depending on the input value.
---
--- If `specId` is not set (or is `nil`), this will return a `pairs` iterator
--- containing all spec IDs and shapeshift forms per spec ID.
---
--- If `specId` is set, it will return an `ipairs` iterator containing all
--- shapeshift forms for the specified spec ID.
---
--- @param specId integer
--- @return function
--- @return table
--- @return number
function Addon:IterateShapeshiftForms(specId)
	if specId == nil then
		return pairs(shapeshiftForms)
	else
		return ipairs(shapeshiftForms[specId])
	end
end

--- Iterate through all available classic shapeshift forms, this function behaves
--- slightly differently depending on the input value.
---
--- If `className` is not set (or is `nil`), this will return a `pairs` iterator
--- containing all class names and shapeshift forms per class name.
---
--- If `className` is set, it will return an `ipairs` iterator containing all
--- shapeshift forms for the specified class name.
---
--- @param className string
--- @return function
--- @return table
--- @return number
function Addon:IterateClassicShapeshiftForms(className)
	if className == nil then
		return pairs(classicShapeshiftForms)
	else
		return ipairs(classicShapeshiftForms[className])
	end
end

--- Check if the specified keybind is "restricted", a restricted keybind
--- is not allowed to do various actions as it is required for core game
--- input (such as left and right mouse buttons).
---
--- Restricted keybinds can still be used for bindings, but they will
--- have limited functionality.
---
--- @param keybind string
--- @return boolean
function Addon:IsRestrictedKeybind(keybind)
	return keybind == "BUTTON1" or keybind == "BUTTON2"
end

--- Check if the specified keybind is a mouse button. This will also
--- return `true` if the mouse button has been modified with alt/shift/ctrl.
---
--- @param keybind string
--- @return boolean
function Addon:IsMouseButton(keybind)
	if Addon:IsStringNilOrEmpty(keybind) then
		return false
	end

	local _, key = GetKeybindModifiersAndKey(keybind)
	local buttonIndex = string.match(key, "^BUTTON(%d+)$")

	return buttonIndex ~= nil
end

--- Ensure that the specified `targets` table is properly updated after switching
--- the type or keybind of a binding. Some bindings only support hovercast, e.g. mouse button 1 and 2.
--- Other binding types, such as `MACRO` do not support specifying multiple targets.
---
--- @param targets Binding.Targets
--- @param keybind string
--- @param type string
function Addon:EnsureSupportedTargetModes(targets, keybind, type)
	if Addon:IsRestrictedKeybind(keybind) or type == Addon.BindingTypes.UNIT_SELECT or type == Addon.BindingTypes.UNIT_MENU then
		targets.hovercastEnabled = true
		targets.regularEnabled = false
	end

	if type == Addon.BindingTypes.MACRO then
		while #targets.regular > 0 do
			table.remove(targets.regular, 1)
		end

		targets.regular[1] = Addon:GetNewBindingTargetTemplate()

		targets.hovercast.hostility = Addon.TargetHostility.ANY
		targets.hovercast.vitals = Addon.TargetVitals.ANY
	end
end

--- Check if a binding's target unit can have a hostility. This will be
--- `false` when, for example, `PARTY_2` is passed in because party members
--- are by definition always friendly during the configuration phase.
---
--- @param unit string
--- @return boolean
function Addon:CanUnitBeHostile(unit)
	local valid = {
		[Addon.TargetUnits.TARGET] = true,
		[Addon.TargetUnits.TARGET_OF_TARGET] = true,
		[Addon.TargetUnits.PET_TARGET] = true,
		[Addon.TargetUnits.ARENA_1] = true,
		[Addon.TargetUnits.ARENA_2] = true,
		[Addon.TargetUnits.ARENA_3] = true,
		[Addon.TargetUnits.FOCUS] = true,
		[Addon.TargetUnits.MOUSEOVER] = true,
		[Addon.TargetUnits.MOUSEOVER_TARGET] = true
	}

	return valid[unit] == true
end

--- Check if a binding's target unit supports `dead` and `nodead` modifiers.
--- This will be `false` when, for example, `CURSOR` is passed in, but also
--- when `PLAYER` is passed in. The player can technically be dead, but we cannot
--- cast anything while dead so it is a condition that can never be reached.
---
--- @param unit string
--- @return boolean
function Addon:CanUnitBeDead(unit)
	local valid = {
		[Addon.TargetUnits.TARGET] = true,
		[Addon.TargetUnits.TARGET_OF_TARGET] = true,
		[Addon.TargetUnits.PET] = true,
		[Addon.TargetUnits.PET_TARGET] = true,
		[Addon.TargetUnits.PARTY_1] = true,
		[Addon.TargetUnits.PARTY_2] = true,
		[Addon.TargetUnits.PARTY_3] = true,
		[Addon.TargetUnits.PARTY_4] = true,
		[Addon.TargetUnits.PARTY_5] = true,
		[Addon.TargetUnits.ARENA_1] = true,
		[Addon.TargetUnits.ARENA_2] = true,
		[Addon.TargetUnits.ARENA_3] = true,
		[Addon.TargetUnits.FOCUS] = true,
		[Addon.TargetUnits.MOUSEOVER] = true,
		[Addon.TargetUnits.MOUSEOVER_TARGET] = true
	}

	return valid[unit] == true
end

--- Notify the user that Clicked is currently in combat lockdown mode,
--- this will print a message to the user's chat frame with a helpful message.
function Addon:NotifyCombatLockdown()
	local message = Addon:GetPrefixedAndFormattedString(L["You are in combat, the binding configuration is in read-only mode."])
	print(message)
end

--- Colorize the specified string. This will enclose the string
--- in WoW color tags (`|c` and `|r`).
---
--- @param string string
--- @param color string
--- @return string
function Addon:GetColorizedString(string, color)
	return "|c" .. color .. string .. "|r"
end

--- Prefix the specified string with `Clicked:`.
---
--- @param message string
--- @return string
function Addon:AppendClickedMessagePrefix(message)
	return Addon:GetColorizedString(L["Clicked"], "ffe31919") .. ": " .. message
end

--- Run `string.format` on the specified string, and prefix the resulting string with `Clicked:`.
---
--- @param format string
--- @vararg string
--- @return string
function Addon:GetPrefixedAndFormattedString(format, ...)
	local message = string.format(format, ...)
	return Addon:AppendClickedMessagePrefix(message)
end

--- Check if a table can be considered a valid representation of a binding type.
---
--- @param binding Binding
--- @return boolean
function Addon:IsBindingType(binding)
	return type(binding) == "table" and binding.identifier ~= nil and binding.type ~= nil
end

--- Check if the game client is running the retail version of the API.
---
--- @return boolean
function Addon:IsRetail()
	return WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
end

--- Check if the game client is running the Classic version of the API.
---
--- @return boolean
function Addon:IsClassic()
	return WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
end

--- Check if the game client is running the Burning Crusade version of the API.
---
--- @return boolean
function Addon:IsBC()
	return WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
end

--- Check if the client version is at least the specified version, for example `IsAtLeast("BC")` will return `true` on both the BC and Retail versions of the
--- game, but `false` on Classic.
---
--- @param version '"RETAIL"'|'"CLASSIC"'|'"BC"'
--- @return boolean
function Addon:IsGameVersionAtleast(version)
	if version == "CLASSIC" then
		return Addon:IsClassic() or Addon:IsBC() or Addon:IsRetail()
	elseif version == "BC" then
		return Addon:IsBC() or Addon:IsRetail()
	elseif version == "RETAIL" then
		return Addon:IsRetail()
	end

	return false
end
