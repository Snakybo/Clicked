Clicked = LibStub("AceAddon-3.0"):NewAddon("Clicked", "AceEvent-3.0")

Clicked.TYPE_SPELL = "SPELL"
Clicked.TYPE_ITEM = "ITEM"
Clicked.TYPE_MACRO = "MACRO"
Clicked.TYPE_UNIT_SELECT = "UNIT_SELECT"	-- nyi
Clicked.TYPE_UNIT_MENU = "UNIT_MENU"		-- nyi

Clicked.TARGET_UNIT_GLOBAL = "GLOBAL"
Clicked.TARGET_UNIT_PLAYER = "PLAYER"
Clicked.TARGET_UNIT_TARGET = "TARGET"
Clicked.TARGET_UNIT_PARTY_1 = "PARTY_1"
Clicked.TARGET_UNIT_PARTY_2 = "PARTY_2"
Clicked.TARGET_UNIT_PARTY_3 = "PARTY_3"
Clicked.TARGET_UNIT_PARTY_4 = "PARTY_4"
Clicked.TARGET_UNIT_PARTY_5 = "PARTY_5"
Clicked.TARGET_UNIT_MOUSEOVER = "MOUSEOVER"
Clicked.TARGET_UNIT_MOUSEOVER_FRAME = "MOUSEOVER_FRAME"		-- nyi

Clicked.TARGET_TYPE_ANY = "ANY"
Clicked.TARGET_TYPE_HELP = "HELP"
Clicked.TARGET_TYPE_HARM = "HARM"

Clicked.COMBAT_STATE_TRUE = "IN_COMBAT"
Clicked.COMBAT_STATE_FALSE = "NOT_IN_COMBAT"

local DataBroker = LibStub("LibDataBroker-1.1")
local Icon = LibStub("LibDBIcon-1.0")

local handlers = {}
local inCombat = false

function Clicked:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("ClickedDB", self:GetDatabaseDefaults(), true)
	self.db.RegisterCallback(self, "OnProfileChanged", "ReloadBindings")
	self.db.RegisterCallback(self, "OnProfileCopied", "ReloadBindings")
	self.db.RegisterCallback(self, "OnProfileReset", "ReloadBindings")

	local iconData = DataBroker:NewDataObject("Clicked", {
        type = "launcher",
        label = "Clicked",
        icon = "Interface\\Icons\\inv_misc_punchcards_yellow",
        OnClick = function()
            self:OpenBindingConfig()
		end,
		OnTooltipShow = function(tooltip)
			tooltip:AddLine("Clicked")
		end
    })
    Icon:Register("Clicked", iconData, self.db.profile.minimap)
	
	self:RegisterAddonConfig()
	self:RegisterBindingConfig()
end

function Clicked:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEnteringCombat")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnLeavingCombat")
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "ReloadActiveBindings")
	self:RegisterEvent("PLAYER_TALENT_UPDATE", "ReloadActiveBindingsAndConfig")

	self:ReloadBindings()
end

function Clicked:OnDisable()
	self:UnregisterEvent("OnEnteringCombat")
	self:UnregisterEvent("OnLeavingCombat")
	self:UnregisterEvent("ReloadActiveBindings")
	self:UnregisterEvent("ReloadActiveBindingsAndConfig")
end

function Clicked:ReloadBindings()
	self.bindings = self.db.profile.bindings
	self.activeBindings = {}
	
	self:ReloadActiveBindingsAndConfig()

	if self.db.profile.minimap.hide then
        Icon:Hide("Clicked")
    else
        Icon:Show("Clicked")
    end
end

function Clicked:OnEnteringCombat()
	inCombat = true
	self:ReloadActiveBindings()
end

function Clicked:OnLeavingCombat()
	inCombat = false
	self:ReloadActiveBindings()
end

function Clicked:ReloadActiveBindingsAndConfig()
	self:ReloadBindingConfig()
	self:ReloadActiveBindings()
end

local function AddFlag(flags, new)
	if #flags > 0 then
		flags = flags .. ","
	end

	return flags .. new
end

local function RegisterBindings()
	if InCombatLockdown() then
		return false
	end
	
	local nextHandlerIndex = 1

	for i, binding in ipairs(Clicked.bindings) do
		if Clicked:IsBindingActive(binding) then
			local macro = {}

			if binding.type == Clicked.TYPE_SPELL or binding.type == Clicked.TYPE_ITEM then
				if binding.action.stopCasting then
					table.insert(macro, "/stopcasting")
				end
				binding.targets = binding.targets or {}

				local text = "/use "

				if not Clicked:IsRestrictedKeybind(binding.keybind) then
					for i, target in ipairs(binding.targets) do
						local flags = ""
						
						if target.unit == Clicked.TARGET_UNIT_PLAYER then
							flags = AddFlag(flags, "@player")
						elseif target.unit == Clicked.TARGET_UNIT_TARGET then
							flags = AddFlag(flags, "@target")
						elseif target.unit == Clicked.TARGET_UNIT_MOUSEOVER then
							flags = AddFlag(flags, "@mouseover")
						elseif target.unit == Clicked.TARGET_UNIT_PARTY_1 then
							flags = AddFlag(flags, "@party1")
						elseif target.unit == Clicked.TARGET_UNIT_PARTY_2 then
							flags = AddFlag(flags, "@party2")
						elseif target.unit == Clicked.TARGET_UNIT_PARTY_3 then
							flags = AddFlag(flags, "@party3")
						elseif target.unit == Clicked.TARGET_UNIT_PARTY_4 then
							flags = AddFlag(flags, "@party4")
						elseif target.unit == Clicked.TARGET_UNIT_PARTY_5 then
							flags = AddFlag(flags, "@party5")
						end

						if target.type == Clicked.TARGET_TYPE_HELP then
							flags = AddFlag(flags, "help")
						elseif target.type == Clicked.TARGET_TYPE_HARM then
							flags = AddFlag(flags, "harm")
						end

						if #flags > 0 then
							flags = AddFlag(flags, "exists")

							text = text .. "[" .. flags .. "] "
						end
					end
				end
				
				if binding.type == Clicked.TYPE_SPELL then
					text = text .. binding.action.spell
				elseif binding.type == Clicked.TYPE_ITEM then
					text = text .. binding.action.item
				end

				table.insert(macro, text)
			elseif binding.type == Clicked.TYPE_MACRO then
				table.insert(macro, binding.action.macro)
			elseif binding.type == Clicked.TYPE_UNIT_SELECT then
				-- TODO: Select unit
			elseif binding.type == Clicked.TYPE_UNIT_MENU then
				-- TODO: Open unit menu
			end
			
			if #macro > 0 then
				--if binding.target_unit == Clicked.TARGET_UNIT_MOUSEOVER_FRAME or binding.keybind == "BUTTON1" or binding.keybind == "BUTTON2" then
					-- TODO: Handle MOUSEOVER_FRAME
					-- TODO: Handle BUTTON1 and BUTTON2 interaction overrides
				--else
					local handler = nil

					if nextHandlerIndex > #handlers then
						handler = CreateFrame("Button", "Clicked Handler (" .. #handlers .. ")", UIParent, "SecureActionButtonTemplate")
						handler:SetAttribute("type", "macro")

						table.insert(handlers, handler)
					else
						handler = handlers[nextHandlerIndex]
					end

					nextHandlerIndex = nextHandlerIndex + 1
					
					local macroText = table.concat(macro, "\n")
					handler:SetAttribute("macrotext", macroText)
					
					ClearOverrideBindings(handler)
					SetOverrideBindingClick(handler, true, binding.keybind, handler:GetName())
				--end
			end
		end
	end

	for i = nextHandlerIndex, #handlers do
		local handler = handlers[i]
		
		handler:SetAttribute("macrotext", "")
		ClearOverrideBindings(handler)
	end

	return true
end

function Clicked:ReloadActiveBindings()
	self.activeBindings = {}

	local activatable = {}

	for i = 1, #self.bindings do
		local binding = self.bindings[i]

		if self:IsBindingValid(binding) and self:ShouldBindingLoad(binding) then
			activatable[binding.keybind] = activatable[binding.keybind] or {}
			table.insert(activatable[binding.keybind], binding)
		end
	end

	for _, bindings in pairs(activatable) do
		local sorted = self:PrioritizeBindings(bindings)
		local binding = sorted[1]

		self.activeBindings[binding.keybind] = binding
	end
	
	RegisterBindings()
end

function Clicked:IsBindingValid(binding)
	if binding.keybind == "" then
		return false
	end
	
	if binding.type == Clicked.TYPE_SPELL and binding.action.spell == "" then
		return false
	end

	if binding.type == Clicked.TYPE_MACRO and binding.action.macro == "" then
		return false
	end

	if binding.type == Clicked.TYPE_ITEM and binding.action.item == "" then
		return false
	end

	return true
end

function Clicked:ShouldBindingLoad(binding)
	if binding.load.never then
		return false
	end

	if binding.load.specialization.selected == 1 then
		if binding.load.specialization.single ~= GetSpecialization() then
			return false
		end
	elseif binding.load.specialization.selected == 2 then
		local spec = GetSpecialization()
		local contains = false

		for i = 1, #binding.load.specialization.multiple do
			if binding.load.specialization.multiple[i] == spec then
				contains = true
			end
		end

		if not contains then
			return false
		end
	end
	
	if binding.load.combat.selected == 1 then
		if binding.load.combat.state == Clicked.COMBAT_STATE_TRUE and not inCombat then
			return false
		elseif binding.load.combat.state == Clicked.COMBAT_STATE_FALSE and inCombat then
			return false
		end
	end

	if binding.load.spellKnown.selected == 1 then
		local name = GetSpellInfo(binding.load.spellKnown.spell)

		if name == nil then
			return false
		end
	end
	
	return true
end

function Clicked:PrioritizeBindings(bindings)
	if #bindings == 1 then
		return bindings
	end

	local ordered = {}

	for _, binding in ipairs(bindings) do
		if binding.load.combat.selected == 1 then
			table.insert(ordered, 1, binding)
		else
			table.insert(ordered, binding)
		end
	end

	return ordered
end

function Clicked:IsBindingActive(binding)
	if binding == nil or binding.keybind == "" then
		return false
	end

	return self.activeBindings[binding.keybind] == binding
end

function Clicked:IsRestrictedKeybind(keybind)
    return keybind == "BUTTON1" or keybind == "BUTTON2"
end

function dump(o)
	if type(o) == 'table' then
	   local s = '{ '
	   for k,v in pairs(o) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. dump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(o)
	end
 end
