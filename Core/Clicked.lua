local LibDataBroker = LibStub("LibDataBroker-1.1")
local LibDBIcon = LibStub("LibDBIcon-1.0")

Clicked = LibStub("AceAddon-3.0"):NewAddon("Clicked", "AceEvent-3.0")

Clicked.NAME = "Clicked"
Clicked.VERSION = GetAddOnMetadata(Clicked.NAME, "Version")

Clicked.isPlayerInCombat = false

local function RegisterMinimapIcon()
	local iconData = LibDataBroker:NewDataObject("Clicked", {
		type = "launcher",
		label = "Clicked",
		icon = "Interface\\Icons\\inv_misc_punchcards_yellow",
		OnClick = function()
			Clicked:OpenBindingConfig()
		end,
		OnTooltipShow = function(tooltip)
			tooltip:AddLine("Clicked")
		end
	})

	LibDBIcon:Register("Clicked", iconData, Clicked.db.profile.minimap)
end

local function ReloadDatabase()
	Clicked.bindings = Clicked.db.profile.bindings

	if Clicked.db.profile.minimap.hide then
		LibDBIcon:Hide("Clicked")
	else
		LibDBIcon:Show("Clicked")
	end

	Clicked:ReloadActiveBindingsAndConfig()
end

local function OnEnteringCombat()
	Clicked.isPlayerInCombat = true

	Clicked:ReloadActiveBindings()
end

local function OnLeavingCombat()
	Clicked.isPlayerInCombat = false

	Clicked:ProcessUnitFrameQueue()
	Clicked:ProcessClickCastQueue()

	Clicked:ReloadActiveBindings()
end

local function OnAddonLoaded()
	Clicked:ProcessUnitFrameQueue()
end

function Clicked:OnInitialize()
	local defaultProfile = UnitName("player") .. " - " .. GetRealmName()

	self.db = LibStub("AceDB-3.0"):New("ClickedDB", self:GetDatabaseDefaults(), defaultProfile)
	self.db.RegisterCallback(self, "OnProfileChanged", ReloadDatabase)
	self.db.RegisterCallback(self, "OnProfileCopied", ReloadDatabase)
	self.db.RegisterCallback(self, "OnProfileReset", ReloadDatabase)

	self:RegisterIntegrations()
	self:RegisterAddonConfig()
	self:RegisterBindingConfig()

	RegisterMinimapIcon()
end

function Clicked:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_DISABLED", OnEnteringCombat)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", OnLeavingCombat)
	self:RegisterEvent("ADDON_LOADED", OnAddonLoaded)
	
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "ReloadActiveBindingsAndConfig")
	self:RegisterEvent("PLAYER_TALENT_UPDATE", "ReloadActiveBindingsAndConfig")
	self:RegisterEvent("BAG_UPDATE", "ReloadActiveBindingsAndConfig")

	ReloadDatabase()
end

function Clicked:OnDisable()
	self:UnregisterEvent(OnEnteringCombat)
	self:UnregisterEvent(OnLeavingCombat)
	self:UnregisterEvent(OnAddonLoaded)
	
	self:UnregisterEvent("ReloadActiveBindingsAndConfig")
end

function Clicked:ReloadActiveBindingsAndConfig()
	self:ReloadBindingConfig()
	self:ReloadActiveBindings()
end
