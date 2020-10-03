local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

local function GetLoadOptionTemplate(default)
	return {
		selected = false,
		value = default
	}
end

local function GetTriStateLoadOptionTemplate(default)
	return {
		selected = 0,
		single = default,
		multiple = {
			default
		}
	}
end

function Clicked:GetDatabaseDefaults()
	return {
		profile = {
			version = nil,
			options = {
				onKeyDown = false
			},
			bindings = {},
			blacklist = {},
			minimap = {
				hide = false
			}
		}
	}
end

function Clicked:GetNewBindingTemplate()
	local template = {
		type = Clicked.BindingTypes.SPELL,
		keybind = "",
		action = {
			stopCasting = false,
			spell = "",
			item = "",
			macroName = "",
			macroIcon = "",
			macroText = "",
			macroMode = "FIRST",
			icon = nil
		},
		primaryTarget = self:GetNewBindingTargetTemplate(),
		secondaryTargets = {},
		load = {
			never = false,
			combat = GetLoadOptionTemplate(Clicked.CombatState.IN_COMBAT),
			spellKnown = GetLoadOptionTemplate(""),
			inGroup = GetLoadOptionTemplate(Clicked.GroupState.PARTY_OR_RAID),
			playerInGroup = GetLoadOptionTemplate(""),
			stance = GetTriStateLoadOptionTemplate(1)
		}
	}

	if not self:IsClassic() then
		template.load.specialization = GetTriStateLoadOptionTemplate(GetSpecialization())
		template.load.talent = GetTriStateLoadOptionTemplate(1)
		template.load.pvpTalent = GetTriStateLoadOptionTemplate(1)
		template.load.warMode = GetLoadOptionTemplate(false)
	end

	return template
end

function Clicked:GetNewBindingTargetTemplate()
	return {
		unit = Clicked.TargetUnits.TARGET,
		hostility = Clicked.TargetHostility.ANY,
		status = Clicked.TargetStatus.ANY
	}
end

-- Don't use any constants in this function to prevent breaking the updater
-- when the value of a constant changes. Always use direct values that are
-- read from the database.

function Clicked:UpgradeDatabaseProfile(profile)
	if profile.version == self.VERSION then
		return
	end

	-- If there are no bindings configured for the profile
	-- it's likely new. In any case there's nothing to upgrade
	-- so don't bother trying.
	if #profile.bindings == 0 then
		profile.version = self.VERSION
		return
	end

	-- version 0.4.x to 0.5.0
	-- Versions prior to 0.5.0 didn't have a version number serialized,
	-- so all (and only) old profiles won't have a version field, and
	-- we can safely assume the profile is from 0.4.0 or older
	if profile.version == nil or string.sub(profile.version, 1, 3) == "0.4" then
		for _, binding in ipairs(profile.bindings) do
			if #binding.targets > 0 and binding.targets[1].unit == "GLOBAL" then
				binding.targetingMode = "GLOBAL"
				binding.targets = {
					{
						unit = "TARGET",
						type = "ANY"
					}
				}
			else
				binding.targetingMode = "DYNAMIC_PRIORITY"
			end

			binding.load.inGroup = {
				selected = false,
				state = "IN_GROUP_PARTY_OR_RAID"
			}

			binding.load.playerInGroup = {
				selected = false,
				player = ""
			}
		end

		print(L["MSG_PROFILE_UPDATED"]:format(profile.version or "UNKNOWN", "0.5.0"))
		profile.version = "0.5.0"
	end

	-- version 0.5.x to 0.6.0
	if string.sub(profile.version, 1, 3) == "0.5" then
		for _, binding in ipairs(profile.bindings) do
			binding.load.stance = {
				selected = 0,
				single = 1,
				multiple = {
					1
				}
			}

			binding.load.talent = {
				selected = 0,
				single = 1,
				multiple = {
					1
				}
			}
		end

		print(L["MSG_PROFILE_UPDATED"]:format(profile.version, "0.6.0"))
		profile.version = "0.6.0"
	end

	-- version 0.6.x to 0.7.0
	if string.sub(profile.version, 1, 3) == "0.6" then
		profile.blacklist = {}

		for _, binding in ipairs(profile.bindings) do
			binding.primaryTarget = {
				unit = binding.targets[1].unit,
				hostility = binding.targets[1].type
			}

			binding.secondaryTargets = binding.targets
			table.remove(binding.secondaryTargets, 1)

			for _, target in ipairs(binding.secondaryTargets) do
				target.hostility = target.type
				target.type = nil
			end

			if binding.type == "MACRO" then
				binding.primaryTarget = {
					unit = "GLOBAL",
					hostility = "ANY"
				}
			elseif binding.type == "UNIT_SELECT" or binding.type == "UNIT_MENU" then
				binding.primaryTarget = {
					unit = "HOVERCAST",
					hostility = "ANY"
				}
			else
				if binding.targetingMode == "HOVERCAST" then
					binding.primaryTarget = {
						unit = "HOVERCAST",
						hostility = "ANY"
					}
				elseif binding.targetingMode == "GLOBAL" then
					binding.primaryTarget = {
						unit = "GLOBAL",
						hostility = "ANY"
					}
				end
			end

			-- Run this sanity check last, to force any bindings using the left
			-- or right mouse buttons to be HOVERCAST.
			if binding.keybind == "BUTTON1" or binding.keybind == "BUTTON2" then
				binding.primaryTarget = {
					unit = "HOVERCAST",
					hostility = binding.primaryTarget.hostility
				}
			end

			binding.action.stopcasting = binding.action.stopCasting
			binding.action.stopCasting = nil

			binding.action.macrotext = binding.action.macro
			binding.action.macro = nil

			binding.action.macroMode = "FIRST"

			binding.targets = nil
			binding.targetingMode = nil
		end

		print(L["MSG_PROFILE_UPDATED"]:format(profile.version, "0.7.0"))
		profile.version = "0.7.0"
	end

	-- version 0.7.x to 0.8.0
	if string.sub(profile.version, 1, 3) == "0.7" then
		for _, binding in ipairs(profile.bindings) do
			binding.primaryTarget.status = "ANY"

			for _, target in ipairs(binding.secondaryTargets) do
				target.status = "ANY"
			end

			binding.action.macroName = ""
			binding.action.macroIcon = ""
			binding.action.macroText = binding.action.macrotext
			binding.action.macrotext = nil
			binding.action.stopCasting = binding.action.stopcasting
			binding.action.stopcasting = nil

			binding.load.combat.value = binding.load.combat.state
			binding.load.combat.state = nil

			binding.load.spellKnown.value = binding.load.spellKnown.spell
			binding.load.spellKnown.spell = nil

			binding.load.inGroup.value = binding.load.inGroup.state
			binding.load.inGroup.state = nil

			binding.load.playerInGroup.value = binding.load.playerInGroup.player
			binding.load.playerInGroup.player = nil

			if not self:IsClassic() then
				binding.load.pvpTalent = {
					selected = 0,
					single = 1,
					multiple = {
						1
					}
				}

				binding.load.warMode = {
					selected = false,
					value = "IN_WAR_MODE"
				}
			end
		end

		profile.options = {
			onKeyDown = false
		}

		print(L["MSG_PROFILE_UPDATED"]:format(profile.version, "0.8.0"))
		profile.version = "0.8.0"
	end

	profile.version = self.VERSION
end
