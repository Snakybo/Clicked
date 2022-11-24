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
	"ElvUISpellBookTooltip",
	"WeakAuras",
	"WeakAurasSaved",

	-- WoW API globals
	"AUTOCOMPLETE_DEFAULT_Y_OFFSET",
	"BOOKTYPE_PROFESSION",
	"BOOKTYPE_SPELL",
	"CreateFrame",
	"DisableAddOn",
	"C_ChatInfo",
	"C_ClassTalents",
	"C_CreatureInfo",
	"C_PvP",
	"C_SpecializationInfo",
	"C_Traits",
	"C_Timer",
	"ClassTalentFrame",
	"ClearCursor",
	"EasyMenu",
	"EnableAddOn",
	"Enum",
	"FillLocalizedClassList",
	"FONT_COLOR_CODE_CLOSE",
	"GameFontHighlight",
	"GameFontHighlightLarge",
	"GameFontHighlightSmall",
	"GameMenuFrame",
	"GameTooltip",
	"GetActionInfo",
	"GetActiveTalentGroup",
	"GetAddOnEnableState",
	"GetAddOnMetadata",
	"GetBinding",
	"GetBindingKey",
	"GetClassColor",
	"GetCursorInfo",
	"GetCVar",
	"GetInventoryItemID",
	"GetItemInfo",
	"GetMacroBody",
	"GetMacroInfo",
	"GetModifiedClick",
	"GetMouseFocus",
	"GetNumBindings",
	"GetNumGroupMembers",
	"GetNumShapeshiftForms",
	"GetNumSpecializations",
	"GetNumSpellTabs",
	"GetNumSubgroupMembers",
	"GetNumTalents",
	"GetNumTalentTabs",
	"GetPetActionInfo",
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
	"HIGHLIGHT_FONT_COLOR",
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
	"IsMacClient",
	"IsMetaKeyDown",
	"IsModifierKeyDown",
	"IsPassiveSpell",
	"IsShiftKeyDown",
	"IsSpellKnown",
	"IsSpellKnownOrOverridesKnown",
	"LE_EXPANSION_LEVEL_CURRENT",
	"LE_EXPANSION_BURNING_CRUSADE",
	"LE_EXPANSION_WRATH_OF_THE_LICH_KING",
	"LIGHTBLUE_FONT_COLOR",
	"LoadAddOn",
	"MAX_SPELLS",
	"MAX_NUM_TALENTS",
	"MAX_TALENT_TABS",
	"MAX_TALENT_TIERS",
	"NOT_BOUND",
	"NUM_PET_ACTION_SLOTS",
	"NUM_TALENT_COLUMNS",
	"NORMAL_FONT_COLOR",
	"PanelTemplates_TabResize",
	"PartyFrame",
	"PlayerUtil",
	"PlaySound",
	"RegisterAttributeDriver",
	"RegisterStateDriver",
	"ReloadUI",
	"SecureCmdOptionParse",
	"SetDesaturation",
	"Settings",
	"ShowUIPanel",
	"SpellBookFrame",
	"SpellBookFrame_UpdateSpells",
	"SpellBook_GetSpellBookSlot",
	"SpellButton_OnEnter",
	"SpellButton_OnLeave",
	"SpellButton_UpdateButton",
	"SpellFlyout",
	"SpellFlyoutButton_SetTooltip",
	"StaticPopup_Show",
	"strsplit",
	"SPELLS_PER_PAGE",
	"TalentUtil",
	"TooltipDataProcessor",
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
	"WOW_PROJECT_WRATH_CLASSIC",

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
	"strlen",
	"strlenutf8",
	"table",
	"tonumber",
	"tostring",
	"type",

	-- Global table
	"_G"
}
