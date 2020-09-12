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

	-- WoW API globals
	"BOOKTYPE_SPELL",
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
	"SpellBookFrame_Update",
	"SpellBook_GetSpellBookSlot",
	"SpellButton_OnEnter",
	"SpellButton_OnLeave",
	"StaticPopup_Show",
	"UIParent",
	"UnitName",
	"WOW_PROJECT_ID",
	"WOW_PROJECT_MAINLINE",
	"hooksecurefunc",

	-- Lua globals
	"floor",
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
