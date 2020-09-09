local L = LibStub("AceLocale-3.0"):NewLocale("Clicked", "enUS", true)

-- The localized addon name
L["NAME"] = "Clicked"

-- Only errors that could be shown to the user are localized,
-- there are several error strings in the source code that could
-- only happen in a development environment.

-- If an error occurred while registering a frame for click and hovercasting,
-- this error will be shown.
-- Example: "Clicked: Unable to register unit frame: PlayerFrame"
L["ERR_FRAME_REGISTRATION"] = "Clicked: Unable to register unit frame: %s"

-- If another addon is installed and enabled that Clicked is incompatible with,
-- this error message will be shown prompting the user to disable one of the two
-- addons.
-- Example: "Clicked is not compatbile with Clique and requires one of the two to be disabled."
-- Example: "Keep Clicked" "Keep Clique"
L["ERR_ADDON_INCOMPATIBILITY"] = "Clicked is not compatible with %s and requires one of the two to be disabled."
L["ERR_ADDON_INCOMPATIBILITY_KEEP"] = "Keep %s"

-- If Clicked was recently updated and the profile database format has changed,
-- this message is printed in the user's chat window.
-- Example: "Clicked: Upgraded profile from version 0.4.0 to version 0.5.0"
L["MSG_PROFILE_UPDATED"] = "Clicked: Upgraded profile from version %s to version %s"

-- Everything prefixed with CFG_UI is shown in the main binding configuration
-- window.

L["CFG_UI_TITLE"] = "Clicked Binding Configuration"

-- Tree items are used for the main bindings list
L["CFG_UI_TREE_LABEL_CAST"] = "Cast %s"
L["CFG_UI_TREE_LABEL_USE"] = "Use %s"
L["CFG_UI_TREE_LABEL_RUN_MACRO"] = "Run custom macro"
L["CFG_UI_TREE_LABEL_TARGET_UNIT"] = "Target the unit"
L["CFG_UI_TREE_LABEL_UNIT_MENU"] = "Open the unit menu"
L["CFG_UI_TREE_LOAD_STATE_LOADED"] = "L"
L["CFG_UI_TREE_LOAD_STATE_UNLOADED"] = "U"
L["CFG_UI_TREE_TOOLTIP_LOAD_STATE_LOADED"] = "Loaded"
L["CFG_UI_TREE_TOOLTIP_LOAD_STATE_UNLOADED"] = "Not loaded"

L["CFG_UI_BINDING_CREATE"] = "Create binding"
L["CFG_UI_BINDING_COPY"] = "Copy"
L["CFG_UI_BINDING_PASTE"] = "Paste"
L["CFG_UI_BINDING_DELETE"] = "Delete"
L["CFG_UI_BINDING_SET_TOOLTIP"] = "Press a key to bind, or ESC to clear the binding."

-- Action items are used on the main binding action page

-- The tab item name
L["CFG_UI_ACTION"] = "Action"

-- Help and other informative labels
L["CFG_UI_ACTION_HELP"] = "On this page you can configure the action that will be performed when the key has been pressed."
L["CFG_UI_ACTION_RESTRICTED"] = "Note: Bindings using the left or right mouse button are considered restricted and will always be hovercast bindings."

-- The various actions that a binding can perform
L["CFG_UI_ACTION_TYPE"] = "When the keybind has been pressed"
L["CFG_UI_ACTION_TYPE_SPELL"] = "Cast a spell"
L["CFG_UI_ACTION_TYPE_ITEM"] = "Use an item"
L["CFG_UI_ACTION_TYPE_MACRO"] = "Run a macro"
L["CFG_UI_ACTION_TYPE_UNIT_TARGET"] = "Target the unit"
L["CFG_UI_ACTION_TYPE_UNIT_MENU"] = "Open the unit menu"

-- Basic options for all binding types
L["CFG_UI_ACTION_TARGET_SPELL"] = "Target Spell"
L["CFG_UI_ACTION_TARGET_SPELL_BOOK"] = "Pick from spellbook"
L["CFG_UI_ACTION_TARGET_SPELL_BOOK_HELP"] = "Click on a spell book entry to select it"
L["CFG_UI_ACTION_TARGET_ITEM"] = "Target Item"
L["CFG_UI_ACTION_INTERRUPT_CURRENT_CAST"] = "Interrupt current cast?"
L["CFG_UI_ACTION_MACRO_TEXT"] = "Macro Text"

-- The various targeting modes that are available
L["CFG_UI_ACTION_TARGETING_MODE"] = "Targeting Mode"
L["CFG_UI_ACTION_TARGETING_MODE_DYNAMIC"] = "Dynamic priority"
L["CFG_UI_ACTION_TARGETING_MODE_HOVERCAST"] = "Hovercast"
L["CFG_UI_ACTION_TARGETING_MODE_GLOBAL"] = "Global (no target)"

-- Used for target unit filters (dynamic prioritization)
L["CFG_UI_ACTION_TARGET_UNIT"] = "On this target"
L["CFG_UI_ACTION_TARGET_UNIT_EXTRA"] = "Or"
L["CFG_UI_ACTION_TARGET_UNIT_PLAYER"] = "Player (you)"
L["CFG_UI_ACTION_TARGET_UNIT_TARGET"] = "Target"
L["CFG_UI_ACTION_TARGET_UNIT_MOUSEOVER"] = "Mouseover target"
L["CFG_UI_ACTION_TARGET_UNIT_FOCUS"] = "Focus"
L["CFG_UI_ACTION_TARGET_UNIT_CURSOR"] = "Cursor position"
L["CFG_UI_ACTION_TARGET_UNIT_PARTY"] = "Party %s"
L["CFG_UI_ACTION_TARGET_UNIT_NONE"] = "<No one>"
L["CFG_UI_ACTION_TARGET_UNIT_REMOVE"] = "<Remove this option>"

-- Used for target hostility filters (dynamic prioritization)
L["CFG_UI_ACTION_TARGET_TYPE"] = "If it is"
L["CFG_UI_ACTION_TARGET_TYPE_ANY"] = "Either friendly or hostile"
L["CFG_UI_ACTION_TARGET_TYPE_FRIEND"] = "Friendly"
L["CFG_UI_ACTION_TARGET_TYPE_HARM"] = "Hostile"

-- Load items are used on the binding load options page

-- The tab item name
L["CFG_UI_LOAD"] = "Load Options"

-- Never load the binding
L["CFG_UI_LOAD_NEVER"] = "Never load"

-- Only load for specific specialization(s)
L["CFG_UI_LOAD_SPECIALIZATION"] = "Specialization"

-- Only load in or out of combat
L["CFG_UI_LOAD_COMBAT"] = "Combat"
L["CFG_UI_LOAD_COMBAT_TRUE"] = "In combat"
L["CFG_UI_LOAD_COMBAT_FALSE"] = "Not in combat"

-- Only load if the provided spell or ability is known to the player
L["CFG_UI_LOAD_SPELL_KNOWN"] = "Spell known"

-- Only load in a party, raid, either, or no group
L["CFG_UI_LOAD_IN_GROUP"] = "In group"
L["CFG_UI_LOAD_IN_GROUP_SOLO"] = "Not in a group"
L["CFG_UI_LOAD_IN_GROUP_PARTY"] = "In a party"
L["CFG_UI_LOAD_IN_GROUP_RAID"] = "In a raid group"
L["CFG_UI_LOAD_IN_GROUP_PARTY_OR_RAID"] = "In a party or raid group"

-- Only load if the provided player is in the group
L["CFG_UI_LOAD_PLAYER_IN_GROUP"] = "Player in group"

-- Everything prefixed with OPT_UI is shown in the interface options UI

L["OPT_UI_LIST_TITLE"] = "Clicked"
L["OPT_UI_LIST_TITLE_PROFILES"] = "Profiles"
L["OPT_UI_MINIMAP_NAME"] = "Enable minimap icon"
L["OPT_UI_MINIMAP_DESC"] = "Enable or disable the minimap icon"
