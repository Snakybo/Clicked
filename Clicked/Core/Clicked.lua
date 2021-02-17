local AceConsole = LibStub("AceConsole-3.0")
local LibDataBroker = LibStub("LibDataBroker-1.1")
local LibDBIcon = LibStub("LibDBIcon-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

Clicked = LibStub("AceAddon-3.0"):NewAddon("Clicked", "AceEvent-3.0")
Clicked.VERSION = GetAddOnMetadata("Clicked", "Version")

local modules = {}

local isPlayerInCombat = false
local isInitialized = false

-- safecall implementation

local function errorhandler(err)
	return geterrorhandler()(err)
end

local function safecall(func, ...)
	if func then
		return xpcall(func, errorhandler, ...)
	end
end

local function RegisterMinimapIcon()
	local iconData = LibDataBroker:NewDataObject("Clicked", {
		type = "launcher",
		label = L["Clicked"],
		icon = "Interface\\Icons\\inv_misc_punchcards_yellow",
		OnClick = function()
			Clicked:OpenBindingConfig()
		end,
		OnTooltipShow = function(tooltip)
			tooltip:AddLine(L["Clicked"])
		end
	})

	LibDBIcon:Register("Clicked", iconData, Clicked.db.profile.minimap)
end

local function ReloadDatabase()
	Clicked:ReloadDatabase()
end

local function OnEnteringCombat()
	isPlayerInCombat = true
end

local function OnLeavingCombat()
	isPlayerInCombat = false

	Clicked:ProcessFrameQueue()
	Clicked:ReloadActiveBindingsIfPending()
end

local function OnPlayerEnteringWorld()
	isInitialized = true

	Clicked:ProcessFrameQueue()
	Clicked:UpdateClickCastHeaderBlacklist()
	Clicked:ReloadActiveBindings()
end

local function OnAddonLoaded()
	Clicked:ProcessFrameQueue()
end

local function OnModifierStateChanged()
	Clicked:UpdateUnitFrameTooltips()
end

local function OnPlayerFlagsChanged(event, unit)
	if unit == "player" then
		Clicked:ReloadActiveBindings()
	end
end

local function OnChatCommandReceived(input)
	local args = {}
	local startpos = 1

	while true do
		local arg, next = AceConsole:GetArgs(input, 1, startpos)
		table.insert(args, arg)

		if next == 1e9 then
			break
		end

		startpos = next
	end

	for _, module in pairs(modules) do
		if module.OnChatCommandReceived ~= nil then
			safecall(module.OnChatCommandReceived, module, args)
		end
	end
end

function Clicked:OnInitialize()
	local defaultProfile = select(2, UnitClass("player"))

	self.db = LibStub("AceDB-3.0"):New("ClickedDB", self:GetDatabaseDefaults(), defaultProfile)
	self.db.RegisterCallback(self, "OnProfileChanged", ReloadDatabase)
	self.db.RegisterCallback(self, "OnProfileCopied", ReloadDatabase)
	self.db.RegisterCallback(self, "OnProfileReset", ReloadDatabase)

	Clicked:UpgradeDatabaseProfile(Clicked.db.profile)

	RegisterMinimapIcon()

	self:RegisterClickCastHeader()
	self:RegisterBlizzardUnitFrames()
	self:RegisterUnitFrameTooltips()

	AceConsole:RegisterChatCommand("clicked", OnChatCommandReceived)
	AceConsole:RegisterChatCommand("cc", OnChatCommandReceived)

	for _, module in pairs(modules) do
		if module.Initialize ~= nil then
			safecall(module.Initialize, module)
		end
	end
end

function Clicked:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_DISABLED", OnEnteringCombat)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", OnLeavingCombat)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", OnPlayerEnteringWorld)

	if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
		self:RegisterEvent("PLAYER_TALENT_UPDATE", "ReloadActiveBindings")
		self:RegisterEvent("PLAYER_FLAGS_CHANGED", OnPlayerFlagsChanged)
	end

	self:RegisterEvent("PLAYER_LEVEL_CHANGED", "ReloadActiveBindings");
	self:RegisterEvent("GROUP_ROSTER_UPDATE", "ReloadActiveBindings")
	self:RegisterEvent("MODIFIER_STATE_CHANGED", OnModifierStateChanged)
	self:RegisterEvent("ADDON_LOADED", OnAddonLoaded)

	for _, module in pairs(modules) do
		if module.Register ~= nil then
			safecall(module.Register, module)
		end
	end
end

function Clicked:OnDisable()
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")

	if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
		self:UnregisterEvent("PLAYER_TALENT_UPDATE")
		self:UnregisterEvent("PLAYER_FLAGS_CHANGED")
	end

	self:UnregisterEvent("PLAYER_LEVEL_CHANGED")
	self:UnregisterEvent("GROUP_ROSTER_UPDATE")
	self:UnregisterEvent("MODIFIER_STATE_CHANGED")
	self:UnregisterEvent("ADDON_LOADED")

	for _, module in pairs(modules) do
		if module.Unregister ~= nil then
			safecall(module.Unregister, module)
		end
	end
end

function Clicked:RegisterModule(name, module)
	modules[name] = module
end

function Clicked:IsPlayerInCombat()
	return isPlayerInCombat
end

function Clicked:IsInitialized()
	return isInitialized
end
