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
		label = L["NAME"],
		icon = "Interface\\Icons\\inv_misc_punchcards_yellow",
		OnClick = function()
			Clicked:OpenBindingConfig()
		end,
		OnTooltipShow = function(tooltip)
			tooltip:AddLine(L["NAME"])
		end
	})

	LibDBIcon:Register("Clicked", iconData, Clicked.db.profile.minimap)
end

local function ReloadDatabase()
	Clicked:UpgradeDatabaseProfile(Clicked.db.profile)

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

	Clicked:ProcessFrameQueue()
	Clicked:ReloadActiveBindings()
end

local function OnAddonLoaded()
	Clicked:ProcessFrameQueue()
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
	local defaultProfile = UnitName("player") .. " - " .. GetRealmName()

	self.db = LibStub("AceDB-3.0"):New("ClickedDB", self:GetDatabaseDefaults(), defaultProfile)
	self.db.RegisterCallback(self, "OnProfileChanged", ReloadDatabase)
	self.db.RegisterCallback(self, "OnProfileCopied", ReloadDatabase)
	self.db.RegisterCallback(self, "OnProfileReset", ReloadDatabase)

	RegisterMinimapIcon()

	self:RegisterClickCastHeader()
	self:RegisterBlizzardUnitFrames()
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

	if not self:IsClassic() then
		self:RegisterEvent("PLAYER_TALENT_UPDATE", "ReloadActiveBindings")
		self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "ReloadActiveBindings")
	end

	self:RegisterEvent("PLAYER_ENTERING_WORLD", "ReloadActiveBindings")
	self:RegisterEvent("GROUP_ROSTER_UPDATE", "ReloadActiveBindings")
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORMS", "ReloadActiveBindings")
	self:RegisterEvent("BAG_UPDATE", "ReloadActiveBindings")
	self:RegisterEvent("ADDON_LOADED", OnAddonLoaded)

	for _, module in pairs(modules) do
		if module.Register ~= nil then
			safecall(module.Register, module)
		end
	end

	isInitialized = true

	ReloadDatabase()
	self:ProcessFrameQueue()
end

function Clicked:OnDisable()
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")

	if not self:IsClassic() then
		self:UnregisterEvent("PLAYER_TALENT_UPDATE")
		self:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	end

	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("GROUP_ROSTER_UPDATE")
	self:UnregisterEvent("UPDATE_SHAPESHIFT_FORMS")
	self:UnregisterEvent("BAG_UPDATE")
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

function Clicked:FindModule(name)
	return modules[name]
end

function Clicked:IsPlayerInCombat()
	return isPlayerInCombat
end

function Clicked:IsInitialized()
	return isInitialized
end
