Clicked.ClickCastHeader = nil

local clickCastRegisterQueue = {}

local function ShowIncompatibilityPopup(addon)
    StaticPopupDialogs["ClickedIncompatibilityMessage" .. addon] = {
        text = Clicked.NAME .. " is not compatible with " .. addon .. " and requires one of the two to be disabled.",
        button1 = "Keep " .. Clicked.NAME,
        button2 = "Keep " .. addon,
        OnAccept = function()
            DisableAddOn(addon)
            ReloadUI()
        end,
        OnCancel = function()
            DisableAddOn(Clicked.NAME)
            ReloadUI()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = false,
        preferredIndex = 3
    }

    StaticPopup_Show("ClickedIncompatibilityMessage" .. addon)
end

local function UpdateRegisteredClicks(frame)
    if frame == nil or frame.RegisterForClicks == nil then
        return
    end

    if InCombatLockdown() then
        table.insert(clickCastRegisterQueue, frame)
        return
    end

    frame:RegisterForClicks("AnyUp")
    frame:EnableMouseWheel(true)
end

function Clicked:ProcessClickCastQueue()
    local queue = clickCastRegisterQueue
    clickCastRegisterQueue = {}

    for _, frame in ipairs(queue) do
        UpdateRegisteredClicks(frame)
    end
end

function Clicked:RegisterOUF()
    if GetAddOnEnableState(UnitName("player"), "Clique") == 2 then
        ShowIncompatibilityPopup("Clique")

        -- Cancel oUF integration to prevent corrupting the current session
        return
    end

    -- Keep most of the same setup structure as Clique to ensure that oUF
    -- and all "oUF-like" addons will work

    self.ClickCastHeader = CreateFrame("Frame", "ClickedClickCastHeaderFrame", UIParent, "SecureHandlerBaseTemplate,SecureHandlerAttributeTemplate")
    ClickCastHeader = self.ClickCastHeader
    
    Clique = {}
    Clique.header = self.ClickCastHeader
    Clique.UpdateRegisteredClicks = UpdateRegisteredClicks

	self.ClickCastHeader:SetAttribute("clickcast_register", [===[
        local frame = self:GetAttribute("clickcast_button")
        self:SetAttribute("export_register", frame)
    ]===])
    
    self.ClickCastHeader:SetAttribute("clickcast_unregister", [===[
        local frame = self:GetAttribute("clickcast_button")
        self:SetAttribute("export_unregister", frame)
    ]===])
    
    -- self.ClickCastHeader:SetAttribute("clickcast_onenter", function(...)
	-- 	print("onenter: " .. (...))
    -- end)

    -- self.ClickCastHeader:SetAttribute("clickcast_onleave", function(...)
	-- 	print("onleave: " .. (...))
    -- end)

    self.ClickCastHeader:HookScript("OnAttributeChanged", function(frame, name, value)
        local frameName = value and value.GetName and value:GetName()

        if frameName == nil then
            return
        end

        if name == "export_register" then
            Clicked:RegisterUnitFrame("", frameName, true)
            UpdateRegisteredClicks(_G[frameName])
        elseif name == "export_unregister" then
            Clicked:UnregisterUnitFrame(frameName)
        end
    end)

    local originalClickCastFrames = ClickCastFrames or {}

    ClickCastFrames = setmetatable({}, {
        __newindex = function(t, frame, options)
            if options ~= nil and options ~= false then
                self:RegisterUnitFrame("", frame, options)
            else
                self:UnregisterUnitFrame(frame)
            end
        end
    })

    for frame, options in pairs(originalClickCastFrames) do
        self:RegisterUnitFrame("", frame, options)
    end
end