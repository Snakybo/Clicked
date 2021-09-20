--- @type ClickedInternal
local _, Addon = ...

--- @type Localization
local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

local spellActionButtonTemplate = {
	["iconSource"] = -1,
	["color"] = {
		[1] = 1,
		[2] = 1,
		[3] = 1,
		[4] = 1,
	},
	["yOffset"] = 0,
	["anchorPoint"] = "CENTER",
	["cooldownSwipe"] = true,
	["cooldownEdge"] = false,
	["icon"] = true,
	["triggers"] = {
		[1] = {
			["trigger"] = {
				["duration"] = "1",
				["genericShowOn"] = "showAlways",
				["names"] = {
				},
				["debuffType"] = "HELPFUL",
				["type"] = "status",
				["unevent"] = "auto",
				["use_unit"] = true,
				["unit"] = "player",
				["event"] = "Cooldown Progress (Spell)",
				["subeventPrefix"] = "SPELL",
				["realSpellName"] = "", -- dynamic
				["use_spellName"] = true,
				["spellIds"] = {
				},
				["spellName"] = 0, -- dynamic
				["subeventSuffix"] = "_CAST_START",
				["use_absorbMode"] = true,
				["use_track"] = true,
				["use_genericShowOn"] = true,
			},
			["untrigger"] = {
				["genericShowOn"] = "showAlways",
			},
		},
		["activeTriggerMode"] = -10,
	},
	["internalVersion"] = 40,
	["keepAspectRatio"] = false,
	["selfPoint"] = "CENTER",
	["desaturate"] = false,
	["subRegions"] = {
		[1] = {
			["text_shadowXOffset"] = 0,
			["text_text_format_s_format"] = "none",
			["text_text"] = "%s",
			["text_shadowColor"] = {
				[1] = 0,
				[2] = 0,
				[3] = 0,
				[4] = 1,
			},
			["text_selfPoint"] = "AUTO",
			["text_automaticWidth"] = "Auto",
			["text_fixedWidth"] = 64,
			["anchorYOffset"] = 0,
			["text_justify"] = "CENTER",
			["rotateText"] = "NONE",
			["type"] = "subtext",
			["text_color"] = {
				[1] = 1,
				[2] = 1,
				[3] = 1,
				[4] = 1,
			},
			["text_font"] = "Friz Quadrata TT",
			["text_shadowYOffset"] = 0,
			["text_wordWrap"] = "WordWrap",
			["text_visible"] = true,
			["text_anchorPoint"] = "INNER_BOTTOMRIGHT",
			["text_fontSize"] = 14,
			["anchorXOffset"] = 0,
			["text_fontType"] = "OUTLINE",
		},
	},
	["height"] = 64,
	["load"] = {
		["use_spellknown"] = true,
		["talent"] = {
			["multi"] = {
			},
		},
		["spec"] = {
			["multi"] = {
			},
		},
		["class"] = {
			["multi"] = {
			},
		},
		["spellknown"] = "",
		["size"] = {
			["multi"] = {
			},
		},
	},
	["regionType"] = "icon",
	["alpha"] = 1,
	["animation"] = {
		["start"] = {
			["easeStrength"] = 3,
			["type"] = "none",
			["duration_type"] = "seconds",
			["easeType"] = "none",
		},
		["main"] = {
			["easeStrength"] = 3,
			["type"] = "none",
			["duration_type"] = "seconds",
			["easeType"] = "none",
		},
		["finish"] = {
			["easeStrength"] = 3,
			["type"] = "none",
			["duration_type"] = "seconds",
			["easeType"] = "none",
		},
	},
	["information"] = {
	},
	["zoom"] = 0,
	["authorOptions"] = {
	},
	["actions"] = {
		["start"] = {
		},
		["finish"] = {
		},
		["init"] = {
		},
	},
	["id"] = "", -- dynamic
	["cooldownTextDisabled"] = false,
	["frameStrata"] = 1,
	["width"] = 64,
	["config"] = {
	},
	["inverse"] = false,
	["anchorFrameType"] = "SCREEN",
	["conditions"] = {
		[1] = {
			["check"] = {
				["trigger"] = 1,
				["variable"] = "insufficientResources",
				["value"] = 1,
			},
			["linked"] = false,
			["changes"] = {
				[1] = {
					["value"] = {
						[1] = 0.50196078431373,
						[2] = 0.50196078431373,
						[3] = 1,
						[4] = 1,
					},
					["property"] = "color",
				},
			},
		},
		[2] = {
			["check"] = {
				["trigger"] = 1,
				["variable"] = "spellInRange",
				["value"] = 0,
			},
			["linked"] = true,
			["changes"] = {
				[1] = {
					["value"] = {
						[1] = 0.8,
						[2] = 0.10196078431373,
						[3] = 0.10196078431373,
						[4] = 1,
					},
					["property"] = "color",
				},
			},
		},
		[3] = {
			["check"] = {
				["trigger"] = 1,
				["variable"] = "maxCharges",
				["op"] = ">",
				["value"] = "1",
			},
			["changes"] = {
				[1] = {
					["value"] = true,
					["property"] = "cooldownEdge",
				},
			},
		},
		[4] = {
			["check"] = {
				["trigger"] = -2,
				["variable"] = "AND",
				["op"] = ">",
				["checks"] = {
					[1] = {
						["trigger"] = 1,
						["op"] = ">",
						["value"] = "0",
						["variable"] = "charges",
					},
					[2] = {
						["trigger"] = 1,
						["variable"] = "onCooldown",
						["value"] = 1,
					},
				},
			},
			["changes"] = {
				[1] = {
					["property"] = "cooldownSwipe",
				},
			},
		},
	},
	["cooldown"] = true,
	["xOffset"] = 0,
}

local itemActionButtonTemplate = {
    ["iconSource"] = -1,
    ["xOffset"] = 0,
    ["yOffset"] = 0,
    ["anchorPoint"] = "CENTER",
    ["cooldownSwipe"] = true,
    ["cooldownEdge"] = false,
    ["icon"] = true,
    ["triggers"] = {
        [1] = {
            ["trigger"] = {
                ["itemName"] = 0, -- dynamic
                ["duration"] = "1",
                ["genericShowOn"] = "showAlways",
                ["use_unit"] = true,
                ["debuffType"] = "HELPFUL",
                ["type"] = "status",
                ["use_itemName"] = true,
                ["unevent"] = "auto",
                ["use_genericShowOn"] = true,
                ["subeventPrefix"] = "SPELL",
                ["event"] = "Cooldown Progress (Item)",
                ["use_absorbMode"] = true,
                ["realSpellName"] = 0,
                ["use_spellName"] = true,
                ["spellIds"] = {
                },
                ["subeventSuffix"] = "_CAST_START",
                ["spellName"] = 0,
                ["names"] = {
                },
                ["use_track"] = true,
                ["unit"] = "player",
            },
            ["untrigger"] = {
                ["genericShowOn"] = "showAlways",
            },
        },
        ["activeTriggerMode"] = -10,
    },
    ["internalVersion"] = 40,
    ["keepAspectRatio"] = false,
    ["selfPoint"] = "CENTER",
    ["desaturate"] = false,
    ["subRegions"] = {
    },
    ["height"] = 64,
    ["load"] = {
        ["size"] = {
            ["multi"] = {
            },
        },
        ["spec"] = {
            ["multi"] = {
            },
        },
        ["class"] = {
            ["multi"] = {
            },
        },
        ["talent"] = {
            ["multi"] = {
            },
        },
    },
    ["regionType"] = "icon",
    ["anchorFrameType"] = "SCREEN",
    ["actions"] = {
        ["start"] = {
        },
        ["init"] = {
        },
        ["finish"] = {
        },
    },
    ["cooldown"] = true,
    ["zoom"] = 0,
    ["authorOptions"] = {
    },
    ["alpha"] = 1,
    ["id"] = "", -- dynamic
    ["color"] = {
        [1] = 1,
        [2] = 1,
        [3] = 1,
        [4] = 1,
    },
    ["frameStrata"] = 1,
    ["width"] = 64,
    ["animation"] = {
        ["start"] = {
            ["type"] = "none",
            ["easeStrength"] = 3,
            ["duration_type"] = "seconds",
            ["easeType"] = "none",
        },
        ["main"] = {
            ["type"] = "none",
            ["easeStrength"] = 3,
            ["duration_type"] = "seconds",
            ["easeType"] = "none",
        },
        ["finish"] = {
            ["type"] = "none",
            ["easeStrength"] = 3,
            ["duration_type"] = "seconds",
            ["easeType"] = "none",
        },
    },
    ["inverse"] = false,
    ["config"] = {
    },
    ["conditions"] = {
        [1] = {
            ["check"] = {
                ["trigger"] = 1,
                ["variable"] = "itemInRange",
                ["value"] = 0,
            },
            ["linked"] = false,
            ["changes"] = {
                [1] = {
                    ["value"] = {
                        [1] = 0.8,
                        [2] = 0.10196078431373,
                        [3] = 0.10196078431373,
                        [4] = 1,
                    },
                    ["property"] = "color",
                },
            },
        },
    },
    ["information"] = {
    },
    ["cooldownTextDisabled"] = false,
}

-- Local support functions

--- @param binding Binding
--- @return table
local function PopulateTemplate(binding)
	local template
	local name, icon, id = Addon:GetSimpleSpellOrItemInfo(binding)

	if name == nil then
		return nil
	end

	if binding.type == Addon.BindingTypes.SPELL then
		template = Addon:DeepCopyTable(spellActionButtonTemplate)
		template.triggers[1].trigger.realSpellName = name
		template.triggers[1].trigger.spellName = id
		template.load.spellknown = id
	elseif binding.type == Addon.BindingTypes.ITEM then
		template = Addon:DeepCopyTable(itemActionButtonTemplate)
		template.triggers[1].trigger.itemName = id
	end

	template.id = string.format("[%s] %s", L["Clicked"], name)

	return {
		d = template,
		i = icon
	}
end

--- @param binding Binding
--- @return string
local function UpdateWeakAuraUniqueID(binding)
	local integrations = binding.integrations
	local target = nil

	if integrations.weakauras ~= nil then
		local installed = false

		for _, installedData in pairs(WeakAurasSaved.displays) do
			if installedData.uid == integrations.weakauras then
				target = installedData.uid
				installed = true
				break
			end
		end

		if not installed then
			integrations.weakauras = nil
		end
	end

	if integrations.weakauras == nil then
		integrations.weakauras = WeakAuras.GenerateUniqueID()
	end

	return target
end

-- Private addon API

--- @param binding Binding
--- @return boolean
function Addon:CreateWeakAurasIcon(binding)
	assert(type(binding) == "table", "bad argument #1, expected table but got " .. type(binding))

	if not Addon:IsWeakAurasIntegrationEnabled() then
		error("WeakAuras is not installed or enabled, unable to create an aura")
		return false
	end

	if binding.type ~= Addon.BindingTypes.SPELL and binding.type ~= Addon.BindingTypes.ITEM then
		return false
	end

	local inData = PopulateTemplate(binding)

	if inData == nil then
		return false
	end

	local target = UpdateWeakAuraUniqueID(binding)
	inData.uid = binding.integrations.weakauras

	local success, message = WeakAuras.Import(inData, target)

	if not success then
		binding.integrations.weakauras = nil
		print(Addon:GetPrefixedAndFormattedString("%s: %s", "Unable to create aura", message))
	end

	return success
end

--- @return boolean
function Addon:IsWeakAurasIntegrationEnabled()
	return GetAddOnEnableState(UnitName("player"), "WeakAuras") == 2 and WeakAuras ~= nil and WeakAurasSaved ~= nil
end
