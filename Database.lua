function Clicked:GetDatabaseDefaults()
    local unitSelect = self:GetNewBinding()
    unitSelect.type = Clicked.TYPE_UNIT_SELECT
    unitSelect.keybind = "BUTTON1"

    local unitMenu = self:GetNewBinding()
    unitMenu.type = Clicked.TYPE_UNIT_MENU
    unitMenu.keybind = "BUTTON2"
    
    return {
        profile = {
            bindings = {
                -- unitSelect,
                -- unitMenu
            },
            minimap = {
                hide = false
            }
        }
    }
end

function Clicked:GetNewBinding()
    return {
        type = Clicked.TYPE_SPELL,
        keybind = "",
        action_spell = "",
        action_item = "",
        action_macro_name = "",
        action_macro_text = "",
        action_stop_casting = false,
        target_unit = Clicked.TARGET_UNIT_TARGET,
        target_type = Clicked.TARGET_TYPE_ANY,
        load_lever = false,
        load_enable_spec = 0,
        load_spec = GetSpecialization(),
        load_specs = { GetSpecialization() },
        load_enable_combat = false,
        load_combat = Clicked.COMBAT_STATE_TRUE
    }
end
