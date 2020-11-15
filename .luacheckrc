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
	"ClickedMedia",
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
	"C_CreatureInfo",
	"C_PvP",
	"C_SpecializationInfo",
	"C_Timer",
	"EasyMenu",
	"EnableAddOn",
	"FillLocalizedClassList",
	"FONT_COLOR_CODE_CLOSE",
	"GameFontHighlight",
	"GameFontHighlightLarge",
	"GameFontHighlightSmall",
	"GameTooltip",
	"GetAddOnEnableState",
	"GetAddOnMetadata",
	"GetClassColor",
	"GetItemInfo",
	"GetNumGroupMembers",
	"GetNumShapeshiftForms",
	"GetNumSubgroupMembers",
	"GetPvpTalentInfoByID",
	"GetRealmName",
	"GetShapeshiftFormInfo",
	"GetSpecialization",
	"GetSpecializationInfo",
	"GetSpecializationInfoByID",
	"GetSpellBookItemName",
	"GetSpellInfo",
	"GetTalentInfo",
	"GetTalentInfoByID",
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
	"IsSpellKnown",
	"LoadAddOn",
	"MAX_SPELLS",
	"MAX_TALENT_TIERS",
	"NUM_TALENT_COLUMNS",
	"PlaySound",
	"RegisterStateDriver",
	"ReloadUI",
	"SetDesaturation",
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
