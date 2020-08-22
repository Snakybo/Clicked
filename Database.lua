function Clicked:GetDatabaseDefaults()
    local unitSelect = self:GetNewBindingTemplate()
    unitSelect.type = Clicked.TYPE_UNIT_SELECT
    unitSelect.keybind = "BUTTON1"

    local unitMenu = self:GetNewBindingTemplate()
    unitMenu.type = Clicked.TYPE_UNIT_MENU
    unitMenu.keybind = "BUTTON2"
    
    return {
        profile = {
            bindings = {
                ["*"] = self:GetNewBindingTemplate(),
                -- unitSelect,
                -- unitMenu
            },
            minimap = {
                hide = false
            }
        }
    }
end

function Clicked:GetNewBindingTemplate()
    return {
        type = Clicked.TYPE_SPELL,
        keybind = "",
        action = {
            stopCasting = false,
            spell = "",
            item = "",
            macro = ""
        },
        targets = {
            self:GetNewBindingTargetTemplate()
        },
        load = {
            never = false,
            specialization = {
                selected = 0,
                single = GetSpecialization(),
                multiple = {
                    GetSpecialization()
                }
            },
            combat = {
                selected = 0,
                state = Clicked.COMBAT_STATE_TRUE
            },
            spellKnown = {
                selected = 0,
                spell = ""
            }
        }
    }
end

function Clicked:GetNewBindingTargetTemplate()
    return {
        unit = Clicked.TARGET_UNIT_TARGET,
        type = Clicked.TARGET_TYPE_ANY
    }
end
