local AceConsole = LibStub("AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0")

local keybindOrderMapping = {
    "`", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "-", "=",
    "NUMPAD0", "NUMPAD1", "NUMPAD2", "NUMPAD3", "NUMPAD4", "NUMPAD5", "NUMPAD6", "NUMPAD7", "NUMPAD8", "NUMPAD9", "NUMPADDIVIDE", "NUMPADMULTIPLY", "NUMPADMINUS", "NUMPADPLUS", "NUMPADDECIMAL",
    "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12", "F13",
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
    "TAB", "CAPSLOCK", "INSERT", "DELETE", "HOME", "END", "PAGEUP", "PAGEDOWN", "[", "]", "\\", ";", "'", ",", ".", "/"
}

local root, tree, items, selected
local spellbookHandlers = {}

local function CanUpdateBinding()
    if InCombatLockdown() then
		return false
    end
    
    return true
end

local function IsRestrictedKeybind(keybind)
    return keybind == "BUTTON1" or keybind == "BUTTON2"
end

local function TreeSortFunc(left, right)
    if left.binding.keybind == "" and right.binding.keybind ~= "" then
        return false
    end

    if left.binding.keybind ~= "" and right.binding.keybind == "" then
        return true
    end

    if left.binding.keybind == "" and right.binding.keybind == "" then
        return left.index < right.index
    end

    if left.binding.keybind == right.binding.keybind then
        return left.index < right.index
    end

    local function GetKeybindKey(bind)
        local mods = {}
        local result = ""

        for match in string.gmatch(bind, "[^-]+") do
            table.insert(mods, match)
            result = match
        end

        table.remove(mods, #mods)

        local index = #keybindOrderMapping + 1
        local found = false

        for i = 1, #keybindOrderMapping do
            if keybindOrderMapping[i] == result then
                index = i
                found = true
                break
            end
        end

        -- register this unknown keybind for this session
        if not found then
            table.insert(keybindOrderMapping, result)
        end

        for i = 1, #mods do
            if mods[i] == "CTRL" then
                index = index + 1000
            end

            if mods[i] == "ALT" then
                index = index + 10000
            end

            if mods[i] == "SHIFT" then
                index = index + 100000
            end
        end

        return index
    end
    
    return GetKeybindKey(left.binding.keybind) < GetKeybindKey(right.binding.keybind)
end

local function GetTreeViewItems()
    local items = {}
    
    for i, binding in ipairs(Clicked.bindings) do
        local item = {}
        item.value = "binding_" .. i
        item.index = i
        item.binding = binding
        item.icon = "Interface\\ICONS\\INV_Misc_QuestionMark"

        if binding.type == Clicked.TYPE_SPELL then
            item.text1 = "Cast " .. binding.action_spell
            item.icon = select(3, GetSpellInfo(binding.action_spell)) or item.icon
        elseif binding.type == Clicked.TYPE_ITEM then
            item.text1 = "Use " .. binding.action_item
            item.icon = select(10, GetItemInfo(binding.action_item)) or item.icon
        elseif binding.type == Clicked.TYPE_MACRO then
            item.text1 = "Run Custom Macro"
        end

        item.text2 = binding.keybind

        if Clicked:IsBindingValid(binding) and Clicked:ShouldBindingLoad(binding) then
            item.text3 = "L"
        else
            item.text3 = "U"
        end

        table.insert(items, item)
    end
    
    table.sort(items, TreeSortFunc)
    return items
end

local function UpdateStatusText(text)
    root:SetStatusText(text)
end

local function EnableSpellbookHandlers(handler)
    if not SpellBookFrame:IsVisible() then
        return
    end

    if #spellbookHandlers == 0 then
        for i = 1, 12 do
            local parent = _G["SpellButton" .. i]
            local button = CreateFrame("Button", "ClickedSpellbookButton" .. i, parent, "ClickedSpellbookButtonTemplate")
            button.parent = parent
            button:RegisterForClicks("LeftButtonDown")
            button:SetID(parent:GetID())
            button:SetScript("OnClick", function(self)
                local slot = SpellBook_GetSpellBookSlot(self:GetParent())
                local name = GetSpellBookItemName(slot, SpellBookFrame.bookType)

                if name ~= nil and name ~= "" then
                    handler(name)
                end
            end)
            button:SetScript("OnEnter", function(self)
                if self.parent:IsEnabled() then
                    SpellButton_OnEnter(self.parent)
                else
                    self:GetHighlightTexture():Hide()
                end
            end)
            button:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)

            spellbookHandlers[i] = button
        end
    end

    for _, handler in ipairs(spellbookHandlers) do
        if handler.parent:IsEnabled() then
            handler:Show()
        end
    end
end

local function DisableSpellbookHandlers()
    for _, handler in ipairs(spellbookHandlers) do
        handler:Hide()
    end
end

local function DrawBindingActions(container, binding)
    -- action help label
    do
        local widget = AceGUI:Create("Label")
        widget:SetText("Here you can configure the action that will be performed when the key has been pressed.")
        widget:SetFullWidth(true)

        container:AddChild(widget)
    end
    
    -- action dropdown
    do
        local widget = AceGUI:Create("Dropdown")
        widget:SetList({
            SPELL = "Cast a spell",
            ITEM = "Use an item",
            MACRO = "Run a macro"
        }, { "SPELL", "ITEM", "MACRO" })
        widget:SetValue(binding.type)
        widget:SetLabel("When the keybind has been pressed")
        widget:SetFullWidth(true)
        widget:SetCallback("OnValueChanged", function(...)
            if CanUpdateBinding() then
                binding.type = select(3, ...)
                Clicked:ReloadBindingConfig()
                container:SelectTab("actions")
                Clicked:ReloadActiveBindings()
            else
                widget:SetValue(binding.type)
            end
        end)

        container:AddChild(widget)
    end

    if binding.type == Clicked.TYPE_SPELL or binding.type == Clicked.TYPE_ITEM then
        if binding.type == Clicked.TYPE_SPELL then
            -- target spell text
            do
                local widget = AceGUI:Create("EditBox")
                widget:SetRelativeWidth(0.75)
                widget:SetText(binding.action_spell)
                widget:SetLabel("Target Spell")
                widget:SetCallback("OnEnterPressed", function(...)
                    if CanUpdateBinding() then
                        local value = select(3, ...)
                        local name = GetSpellInfo(value)

                        if value ~= "" then
                            if name ~= nil then
                                binding.action_spell = name
                                root:SetStatusText("")
                                Clicked:ReloadBindingConfig()
                                Clicked:ReloadActiveBindings()
                            else
                                widget:SetText(binding.action_spell)
                                root:SetStatusText("Invalid spell: " .. value)
                                AceGUI:ClearFocus()
                            end
                        end
                    else
                        widget:SetText(binding.action_spell)
                    end
                end)

                container:AddChild(widget)
            end

            -- pick from spellbook button
            do
                local widget = AceGUI:Create("Button")
                widget:SetText("Select")
                widget:SetRelativeWidth(0.25)
                widget:SetCallback("OnClick", function()
                    SpellBookFrame:HookScript("OnHide", function()
                        DisableSpellbookHandlers()
                    end)

                    ShowUIPanel(SpellBookFrame)
                    
                    SpellBookFrame:ClearAllPoints()
                    SpellBookFrame:SetParent(root.frame)
                    SpellBookFrame:SetPoint("RIGHT", root.frame, "LEFT", -55, 0)

                    EnableSpellbookHandlers(function(name)
                        binding.action_spell = name
                        root:SetStatusText("")
                        Clicked:ReloadBindingConfig()
                        Clicked:ReloadActiveBindings()

                        HideUIPanel(SpellBookFrame)
                    end)
                end)
                widget:SetCallback("OnEnter", function()
                    local tooltip = AceGUI.tooltip
        
                    tooltip:SetOwner(widget.frame, "ANCHOR_NONE")
                    tooltip:ClearAllPoints()
                    tooltip:SetPoint("LEFT", widget.frame, "RIGHT")
                    tooltip:SetText(text or "Click on a spell book entry to select it", 1, 0.82, 0, true)
                    tooltip:Show()
                end)
                widget:SetCallback("OnLeave", function()
                    local tooltip = AceGUI.tooltip
                    tooltip:Hide()
                end)

                container:AddChild(widget)
            end
        elseif binding.type == Clicked.TYPE_ITEM then
            -- target item text
            do
                local widget = AceGUI:Create("EditBox")
                widget:SetRelativeWidth(0.75)
                widget:SetText(binding.action_item)
                widget:SetLabel("Target Item")
                widget:SetCallback("OnEnterPressed", function(...)
                    if CanUpdateBinding() then
                        binding.action_item = select(3, ...)
                        Clicked:ReloadBindingConfig()
                        root:SetStatusText("")
                        Clicked:ReloadActiveBindings()
                    else
                        widget:SetText(binding.action_item)
                    end
                end)

                container:AddChild(widget)
            end

            -- pick from inventory button
            do
                local widget = AceGUI:Create("Button")
                widget:SetText("Select")
                widget:SetRelativeWidth(0.25)
                widget:SetDisabled(true)
                widget:SetCallback("OnClick", function()
                    
                end)

                container:AddChild(widget)
            end
        end

        -- interrupt cast toggle
        do
            local widget = AceGUI:Create("CheckBox")
            widget:SetFullWidth(true)
            widget:SetType("checkbox")
            widget:SetValue(binding.action_stop_casting)
            widget:SetLabel("Interrupt current cast?")
            widget:SetCallback("OnValueChanged", function(...)
                if CanUpdateBinding() then
                    binding.action_stop_casting = select(3, ...)
                    Clicked:ReloadActiveBindings()
                else
                    widget:SetValue(binding.action_stop_casting)
                end
            end)

            container:AddChild(widget)
        end

        -- target type dropdown
        do
            if not IsRestrictedKeybind(binding.keybind) then
                local widget = AceGUI:Create("Dropdown")
                widget:SetList({
                    GLOBAL = "None (global)",
                    PLAYER = "Player (you)",
                    TARGET = "Target",
                    --MOUSEOVER_FRAME = "Mouseover (unit frame)",
                    MOUSEOVER = "Mouseover (unit frame and 3D world)",
                    PARTY_1 = "Party 1",
                    PARTY_2 = "Party 2",
                    PARTY_3 = "Party 3",
                    PARTY_4 = "Party 4",
                    PARTY_5 = "Party 5"
                }, { "GLOBAL", "PLAYER", "TARGET", --[["MOUSEOVER_FRAME",]] "MOUSEOVER", "PARTY_1", "PARTY_2", "PARTY_3", "PARTY_4", "PARTY_5" })
                widget:SetValue(binding.target_unit)
                widget:SetLabel("On this target")
                widget:SetFullWidth(true)
                widget:SetCallback("OnValueChanged", function(...)
                    if CanUpdateBinding() then
                        binding.target_unit = select(3, ...)
                        container:SelectTab("actions")
                        Clicked:ReloadActiveBindings()
                    else
                        widget:SetValue(binding.target_unit)
                    end
                end)

                container:AddChild(widget)
            end
        end

        -- target unit dropdown
        do
            if not IsRestrictedKeybind(binding.keybind) then
                if binding.target_unit == Clicked.TARGET_UNIT_TARGET or
                   binding.target_unit == Clicked.TARGET_UNIT_MOUSEOVER_FRAME or
                   binding.target_unit == Clicked.TARGET_UNIT_MOUSEOVER then
                    local widget = AceGUI:Create("Dropdown")
                    widget:SetList({
                        ANY = "Either friendly or hostile",
                        HELP = "Friendly",
                        HARM = "Hostile"
                    }, { "ANY", "HELP", "HARM" })
                    widget:SetValue(binding.target_type)
                    widget:SetLabel("If the target is")
                    widget:SetFullWidth(true)
                    widget:SetCallback("OnValueChanged", function(...)
                        if CanUpdateBinding() then
                            binding.target_type = select(3, ...)
                            Clicked:ReloadActiveBindings()
                        else
                            widget:SetValue(binding.target_type)
                        end
                    end)

                    container:AddChild(widget)
                end
            end
        end
    elseif binding.type == Clicked.TYPE_MACRO then
        -- macro text field
        do
            local widget = AceGUI:Create("MultiLineEditBox")
            widget:SetLabel("Macro Text")
            widget:SetText(binding.action_macro_text)
            widget:SetFullWidth(true)
            widget:SetFullHeight(true)
            widget:SetCallback("OnEnterPressed", function(...)
                if CanUpdateBinding() then
                    binding.action_macro_text = select(3, ...)
                    Clicked:ReloadActiveBindings()
                else
                    widget:SetText(binding.action_macro_text)
                end
            end)

            container:AddChild(widget)
        end
    end
end

local function DrawBindingLoadOptions(container, binding)
    -- never load toggle
    do
        local widget = AceGUI:Create("CheckBox")
        widget:SetFullWidth(true)
        widget:SetType("checkbox")
        widget:SetValue(binding.load_never)
        widget:SetLabel("Never load")
        widget:SetCallback("OnValueChanged", function(...)
            if CanUpdateBinding() then
                binding.load_never = select(3, ...)
                Clicked:ReloadBindingConfig()
                container:SelectTab("load_options")
                Clicked:ReloadActiveBindings()
            else
                widget:SetValue(binding.load_never)
            end
        end)

        container:AddChild(widget)
    end

    -- spec selection
    do
        local function GetSpecializations()
            local result = {}
        
            local numSpecs = GetNumSpecializations()
            
            for i = 1, numSpecs do
                local _, name = GetSpecializationInfo(i)
                result["spec" .. i] = name
            end
        
            return result
        end

        -- spec toggle
        do
            local function GetToggleValueFromState(state)
                if state == 1 then
                    return true
                elseif state == 2 then
                    return nil
                end

                return false
            end

            local function GetStateFromToggleValue(value)
                if value == false then
                    return 0
                elseif value == true then
                    return 1
                elseif value == nil then
                    return 2
                end
            end

            local widget = AceGUI:Create("CheckBox")
            widget:SetRelativeWidth(0.5)
            widget:SetType("checkbox")
            widget:SetValue(GetToggleValueFromState(binding.load_enable_spec))
            widget:SetLabel("Specialization")
            widget:SetTriState(true)
            widget:SetCallback("OnValueChanged", function(...)
                if CanUpdateBinding() then
                    local value = select(3, ...)
                    binding.load_enable_spec = GetStateFromToggleValue(value)
                    Clicked:ReloadBindingConfig()
                    container:SelectTab("load_options")
                    Clicked:ReloadActiveBindings()
                else
                    widget:SetValue(GetToggleValueFromState(binding.load_enable_spec))
                end
            end)

            container:AddChild(widget)
        end

        -- spec (single)
        if binding.load_enable_spec == 1 then
            do
                local widget = AceGUI:Create("Dropdown")
                widget:SetRelativeWidth(0.5)
                widget:SetList(GetSpecializations())
                widget:SetValue("spec" .. (binding.load_spec or 1))
                widget:SetCallback("OnValueChanged", function(...)
                    if CanUpdateBinding() then
                        local value = select(3, ...)
                        binding.load_spec = tonumber(string.sub(value, -1))
                        Clicked:ReloadBindingConfig()
                        container:SelectTab("load_options")
                        Clicked:ReloadActiveBindings()
                    else
                        widget:SetValue("spec" .. (binding.load_spec or 1))
                    end
                end)

                container:AddChild(widget)
            end
        -- spec (multiple)
        elseif binding.load_enable_spec == 2 then
            local specs = GetSpecializations()
            local widget = AceGUI:Create("Dropdown")

            local function SetInitialState()
                for key, _ in pairs(specs) do
                    local index = tonumber(string.sub(key, -1))
                    local found = false
    
                    for i = 1, #binding.load_specs do
                        if binding.load_specs[i] == index then
                            found = true
                            break
                        end
                    end

                    widget:SetItemValue(key, found)
                end
            end

            widget:SetRelativeWidth(0.5)
            widget:SetList(specs)
            widget:SetMultiselect(true)
            widget:SetCallback("OnValueChanged", function(...)
                if CanUpdateBinding() then
                    local key, checked = select(3, ...)
                    local index = tonumber(string.sub(key, -1))

                    if checked then
                        table.insert(binding.load_specs, index)
                    else
                        for i = 1, #binding.load_specs do
                            if binding.load_specs[i] == index then
                                table.remove(binding.load_specs, i)
                            end
                        end
                    end

                    Clicked:ReloadBindingConfig()
                    container:SelectTab("load_options")
                    Clicked:ReloadActiveBindings()
                else
                    SetInitialState()
                end
            end)

            SetInitialState()

            container:AddChild(widget)
        end

        -- separator
        do
            local widget = AceGUI:Create("SimpleGroup")
            widget:SetFullWidth(true)

            container:AddChild(widget)
        end
    end

    -- combat selection
    do
        -- combat toggle
        do
            local widget = AceGUI:Create("CheckBox")
            widget:SetRelativeWidth(0.5)
            widget:SetType("checkbox")
            widget:SetValue(binding.load_enable_combat)
            widget:SetLabel("Combat")
            widget:SetCallback("OnValueChanged", function(...)
                if CanUpdateBinding() then
                    local value = select(3, ...)
                    binding.load_enable_combat = value
                    Clicked:ReloadBindingConfig()
                    container:SelectTab("load_options")
                    Clicked:ReloadActiveBindings()
                else
                    widget:SetValue(binding.load_enable_combat)
                end
            end)

            container:AddChild(widget)
        end

        -- combat
        if binding.load_enable_combat then
            do
                local widget = AceGUI:Create("Dropdown")
                widget:SetRelativeWidth(0.5)
                widget:SetList({
                    IN_COMBAT = "In combat",
                    NOT_IN_COMBAT = "Not in combat"
                })
                widget:SetValue(binding.load_combat)
                widget:SetCallback("OnValueChanged", function(...)
                    if CanUpdateBinding() then
                        local value = select(3, ...)
                        binding.load_combat = value
                        Clicked:ReloadBindingConfig()
                        container:SelectTab("load_options")
                        Clicked:ReloadActiveBindings()
                    else
                        widget:SetValue(binding.load_combat)
                    end
                end)

                container:AddChild(widget)
            end
        end

        -- separator
        do
            local widget = AceGUI:Create("SimpleGroup")
            widget:SetFullWidth(true)

            container:AddChild(widget)
        end
    end
end

local function DrawBinding(container, index, binding)
    -- keybinding button
    do
        local widget = AceGUI:Create("Keybinding")
        widget:SetKey(binding.keybind)
        widget:SetRelativeWidth(0.75)
        widget:SetCallback("OnKeyChanged", function(...)
            if CanUpdateBinding() then
                binding.keybind = select(3, ...)
                
                Clicked:ReloadBindingConfig()
                Clicked:ReloadActiveBindings()
            else
                widget:SetKey(binding.keybind)
            end
        end)

        container:AddChild(widget)
    end

    -- delete button
    do
        local widget = AceGUI:Create("Button")
        widget:SetText("Delete")
        widget:SetRelativeWidth(0.25)
        widget:SetCallback("OnClick", function()
            if CanUpdateBinding() then
                table.remove(Clicked.bindings, index)
                Clicked:ReloadBindingConfig()
                Clicked:ReloadActiveBindings()

                if index <= #items then
                    tree:SelectByPath(items[index].value)
                elseif index - 1 >= 1 then
                    tree:SelectByPath(items[index - 1].value)
                end
            end
        end)

        container:AddChild(widget)
    end

    -- tabs
    do
        local widget = AceGUI:Create("TabGroup")
        widget:SetFullWidth(true)
        widget:SetFullHeight(true)
        widget:SetLayout("Flow")
        widget:SetTabs(
            {
                {
                    text = "Actions",
                    value = "actions"
                },
                {
                    text = "Load Options",
                    value = "load_options"
                }
            }
        )
        widget:SetCallback("OnGroupSelected", function(container, evt, group)
            container:ReleaseChildren()

            if group == "actions" then
                DrawBindingActions(container, binding)
            elseif group == "load_options" then
                DrawBindingLoadOptions(container, binding)
            end
        end)
        widget:SelectTab("actions")

        container:AddChild(widget)
    end
end

function Clicked:ReloadBindingConfig()
    if tree ~= nil then
        items = GetTreeViewItems()
        selected = selected or "binding_1"

        tree:SetTree(items)
        tree:SelectByPath(selected)
    end
end

function Clicked:OpenBindingConfig()
    if root ~= nil and root:IsVisible() then
        return
    end

    -- root frame
    do
        root = AceGUI:Create("Frame")
        root:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
        root:SetTitle("Clicked Binding Config")
        root:SetLayout("Flow")

        root.frame:SetScript("OnKeyDown", function(self, key)
			if key == "ESCAPE" then
				self:SetPropagateKeyboardInput(false)
                self:Hide()
			else
				self:SetPropagateKeyboardInput(true)
			end
		end)
    end
    
    -- create binding button
    do
        local add = AceGUI:Create("Button")
        add:SetText("Create Binding")
        add:SetWidth(210)
        add:SetCallback("OnClick", function()
            if CanUpdateBinding() then
                table.insert(Clicked.bindings, Clicked:GetNewBinding())

                Clicked:ReloadBindingConfig()
                tree:SelectByPath("binding_" .. #Clicked.bindings)
                
                Clicked:ReloadActiveBindings()
            end
        end)

        root:AddChild(add)
    end

    -- binding help label
    do
        local description = AceGUI:Create("Label")
        description:SetText("You can configure key and click bindings from this window.")
        description:SetFontObject(GameFontHighlight)
        description:SetWidth(400)

        root:AddChild(description)
    end
    
    -- tree view
    do
        items = GetTreeViewItems()
        tree = AceGUI:Create("ClickedTreeGroup")
        tree:SetLayout("Flow")
        tree:SetFullWidth(true)
        tree:SetFullHeight(true)
        tree:SetTree(items)
        tree:EnableButtonTooltips(false)
        tree:SetCallback("OnGroupSelected", function(container, evt, group)
            container:ReleaseChildren()

            for i = 1, #items do
                if items[i].value == group then
                    DrawBinding(container, i, items[i].binding)
                    break
                end
            end

            selected = group
        end)
        tree:SetCallback("OnButtonEnter", function(container, evt, group, frame)
            local tooltip = AceGUI.tooltip
            local text = frame.text:GetText()
            local binding
            
            for i = 1, #items do
                if items[i].value == group then
                    binding = items[i].binding
                    break
                end
            end

            if binding ~= nil then
                if binding.type == Clicked.TYPE_MACRO then
                    text = binding.action_macro_text
                end

                text = text .. "\n\n"

                if Clicked:IsBindingValid(binding) and Clicked:ShouldBindingLoad(binding) then
                    text = text .. "Loaded"
                else
                    text = text .. "Not Loaded"
                end
            end

            tooltip:SetOwner(frame, "ANCHOR_NONE")
            tooltip:ClearAllPoints()
            tooltip:SetPoint("RIGHT", frame, "LEFT")
            tooltip:SetText(text or "", 1, 0.82, 0, true)
            tooltip:Show()
        end)
        tree:SetCallback("OnButtonLeave", function(...)
            local tooltip = AceGUI.tooltip
            tooltip:Hide()
        end)
        
        if #items > 0 then
            tree:SelectByPath(items[1].value)
        end

        root:AddChild(tree)
    end
end

function Clicked:RegisterBindingConfig()
    AceConsole:RegisterChatCommand("clicked", function(input)
        self:OpenBindingConfig()
    end)
end
