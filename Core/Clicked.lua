local LibDataBroker = LibStub("LibDataBroker-1.1")
local LibDBIcon = LibStub("LibDBIcon-1.0")

Clicked = LibStub("AceAddon-3.0"):NewAddon("Clicked", "AceEvent-3.0")

Clicked.NAME = "Clicked"
Clicked.VERSION = GetAddOnMetadata(Clicked.NAME, "Version")

local isPlayerInCombat = false

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
	if Clicked.db.profile.minimap.hide then
		LibDBIcon:Hide("Clicked")
	else
		LibDBIcon:Show("Clicked")
	end

	Clicked:ReloadActiveBindings()
end

local function OnEnteringCombat()
	isPlayerInCombat = true

	Clicked:ReloadActiveBindings()
end

local function OnLeavingCombat()
	isPlayerInCombat = false

	Clicked:ProcessClickCastFrameQueue()
	Clicked:ReloadActiveBindings()
end

local function OnAddonLoaded()
	Clicked:ProcessClickCastFrameQueue()
end

function Clicked:OnInitialize()
	local defaultProfile = UnitName("player") .. " - " .. GetRealmName()

	self.db = LibStub("AceDB-3.0"):New("ClickedDB", self:GetDatabaseDefaults(), defaultProfile)
	self.db.RegisterCallback(self, "OnProfileChanged", ReloadDatabase)
	self.db.RegisterCallback(self, "OnProfileCopied", ReloadDatabase)
	self.db.RegisterCallback(self, "OnProfileReset", ReloadDatabase)

	RegisterMinimapIcon()

	self:RegisterClickCastHeader()
	self:RegisterBlizzardUnitFrames()

	self:RegisterAddonConfig()
	self:RegisterBindingConfig()
end

function Clicked:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_DISABLED", OnEnteringCombat)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", OnLeavingCombat)
	self:RegisterEvent("PLAYER_TALENT_UPDATE", "ReloadActiveBindings")
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "ReloadActiveBindings")
	self:RegisterEvent("BAG_UPDATE", "ReloadActiveBindings")
	self:RegisterEvent("ADDON_LOADED", OnAddonLoaded)

	ReloadDatabase()
end

function Clicked:OnDisable()
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_TALENT_UPDATE")
	self:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	self:UnregisterEvent("BAG_UPDATE")
	self:UnregisterEvent("ADDON_LOADED")
end

function Clicked:IsPlayerInCombat()
	return isPlayerInCombat
end
