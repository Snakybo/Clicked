-- Disable unused self warnings.
self = false

-- Allow unused arguments.
unused_args = false

-- Disable line length limits.
max_line_length = false
max_code_line_length = false
max_string_line_length = false
max_comment_line_length = false

-- Add exceptions for external libraries.
std = "lua51"

globals = {
	-- Clicked
	"Clicked",
	"Clique",
	"ClickCastHeader",
	"ClickCastFrames",

	-- WoW API globals
	"SpellBookFrame",
	"StaticPopupDialogs"
}

exclude_files = {
	"**/Libs",
	".luacheckrc",
}

ignore = {
	"542", -- empty if branch
}

read_globals = {
	-- Libraries
	"LibStub",
	"ElvUI",

	-- WoW API globals
	"CreateFrame",
	"DisableAddOn",
	"FONT_COLOR_CODE_CLOSE",
	"GameFontHighlight",
	"GameFontHighlightLarge",
	"GameFontHighlightSmall",
	"GameTooltip",
	"GetAddOnEnableState",
	"GetAddOnMetadata",
	"GetItemInfo",
	"GetNumGroupMembers",
	"GetNumShapeshiftForms",
	"GetNumSpecializations",
	"GetNumSubgroupMembers",
	"GetRealmName",
	"GetShapeshiftFormInfo",
	"GetSpecialization",
	"GetSpecializationInfo",
	"GetSpellBookItemName",
	"GetSpellInfo",
	"GetTalentInfo",
	"GetTime",
	"HideUIPanel",
	"InCombatLockdown",
	"InterfaceOptionsFrame_OpenToCategory",
	"IsAddOnLoaded",
	"IsAltKeyDown",
	"IsControlKeyDown",
	"IsInRaid",
	"IsShiftKeyDown",
	"MAX_TALENT_TIERS",
	"NUM_TALENT_COLUMNS",
	"PlaySound",
	"RegisterStateDriver",
	"ReloadUI",
	"ShowUIPanel",
	"SpellBook_GetSpellBookSlot",
	"SpellButton_OnEnter",
	"SpellButton_OnLeave",
	"SpellButton_UpdateButton",
	"StaticPopup_Show",
	"strsplit",
	"SPELLS_PER_PAGE",
	"UIParent",
	"UnitClass",
	"UnitLevel",
	"UnitName",
	"UnitRace",
	"WOW_PROJECT_ID",
	"WOW_PROJECT_MAINLINE",
	"hooksecurefunc",

	-- Lua globals
	"floor",
	"geterrorhandler",
	"error",
	"ipairs",
	"pairs",
	"print",
	"select",
	"setmetatable",
	"string",
	"table",
	"tonumber",
	"tostring",
	"type",

	-- Global table
	"_G"
}
