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
	"BackdropTemplateMixin",
	"BOOKTYPE_PROFESSION",
	"CreateFrame",
	"DisableAddOn",
	"C_PvP",
	"C_SpecializationInfo",
	"EasyMenu",
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
	"GetPvpTalentInfoByID",
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
	"IsMetaKeyDown",
	"IsShiftKeyDown",
	"MAX_SPELLS",
	"MAX_TALENT_TIERS",
	"NUM_TALENT_COLUMNS",
	"PlaySound",
	"RegisterStateDriver",
	"ReloadUI",
	"ShowUIPanel",
	"SpellBookFrame",
	"SpellBook_GetSpellBookSlot",
	"SpellButton_OnEnter",
	"SpellButton_OnLeave",
	"SpellButton_UpdateButton",
	"SpellFlyout",
	"SpellFlyoutButton_SetTooltip",
	"StaticPopup_Show",
	"strsplit",
	"SPELLS_PER_PAGE",
	"UIParent",
	"UnitClass",
	"UnitIsVisible",
	"UnitLevel",
	"UnitName",
	"UnitRace",
	"WOW_PROJECT_CLASSIC",
	"WOW_PROJECT_ID",
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
