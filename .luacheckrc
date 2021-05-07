-- Disable unused self warnings.
self = false

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
	"WeakAuras",
	"WeakAurasSaved",

	-- WoW API globals
	"BackdropTemplateMixin",
	"BOOKTYPE_PROFESSION",
	"BOOKTYPE_SPELL",
	"CreateFrame",
	"DisableAddOn",
	"C_ChatInfo",
	"C_Covenants",
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
	"GameMenuFrame",
	"GameTooltip",
	"GetAddOnEnableState",
	"GetAddOnMetadata",
	"GetClassColor",
	"GetCVar",
	"GetInventoryItemID",
	"GetItemInfo",
	"GetMouseFocus",
	"GetNumGroupMembers",
	"GetNumShapeshiftForms",
	"GetNumSpecializations",
	"GetNumSpellTabs",
	"GetNumSubgroupMembers",
	"GetPvpTalentInfoByID",
	"GetRealmName",
	"GetRealZoneText",
	"GetShapeshiftForm",
	"GetShapeshiftFormInfo",
	"GetSpecialization",
	"GetSpecializationInfo",
	"GetSpecializationInfoByID",
	"GetSpellBookItemInfo",
	"GetSpellBookItemName",
	"GetSpellInfo",
	"GetSpellSubtext",
	"GetSpellTabInfo",
	"GetTalentInfo",
	"GetTalentInfoByID",
	"GetTime",
	"HideUIPanel",
	"hooksecurefunc",
	"InCombatLockdown",
	"InterfaceOptionsFrame",
	"InterfaceOptionsFrame_OpenToCategory",
	"IsAddOnLoaded",
	"IsAltKeyDown",
	"IsControlKeyDown",
	"IsEquippedItem",
	"IsInInstance",
	"IsInRaid",
	"IsMetaKeyDown",
	"IsModifierKeyDown",
	"IsPassiveSpell",
	"IsShiftKeyDown",
	"IsSpellKnown",
	"LoadAddOn",
	"MAX_SPELLS",
	"MAX_TALENT_TIERS",
	"NUM_TALENT_COLUMNS",
	"PanelTemplates_TabResize",
	"PlaySound",
	"RegisterAttributeDriver",
	"RegisterStateDriver",
	"ReloadUI",
	"SecureCmdOptionParse",
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
	"UnitGUID",
	"UnitIsDeadOrGhost",
	"UnitIsFriend",
	"UnitIsVisible",
	"UnitLevel",
	"UnitName",
	"UnitRace",
	"WorldFrame",
	"wipe",
	"WOW_PROJECT_BURNING_CRUSADE_CLASSIC",
	"WOW_PROJECT_CLASSIC",
	"WOW_PROJECT_ID",
	"WOW_PROJECT_MAINLINE",

	-- Global localization
	"ABILITIES",
	"ARENA",
	"BATTLEGROUND",
	"CANCEL",
	"CLASS",
	"COMBAT",
	"CONTINUE",
	"DEAD",
	"DEFAULT",
	"DELETE",
	"FOCUS",
	"FRIENDLY",
	"HOSTILE",
	"MACRO",
	"NEW",
	"NO",
	"NONE",
	"OFF",
	"OTHER",
	"TARGET",
	"PET",
	"RACE",
	"YES",

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
