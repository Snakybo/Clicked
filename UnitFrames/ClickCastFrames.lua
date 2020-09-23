local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

Clicked.EVENT_CLICK_CAST_FRAME_REGISTERED = "CLICKED_CLICK_CAST_FRAME_REGISTERED"
Clicked.EVENT_CLICK_CAST_FRAME_UNREGISTERED = "CLICKED_CLICK_CAST_FRAME_UNREGISTERED"

local frames = {}
local registerQueue = {}
local unregisterQueue = {}
local registerClicksQueue = {}
local cachedAttributes = {}

local function UpdateClickCastFrame(frame, attributes)
	Clicked:SetPendingFrameAttributes(frame, attributes)
	Clicked:ApplyAttributesToFrame(frame)

	if Clicked.ClickCastHeader ~= nil then
		Clicked.ClickCastHeader:UnwrapScript(frame, "OnEnter")
		Clicked.ClickCastHeader:UnwrapScript(frame, "OnLeave")
		Clicked.ClickCastHeader:WrapScript(frame, "OnEnter", Clicked.ClickCastHeader:GetAttribute("setup-keybinds"))
		Clicked.ClickCastHeader:WrapScript(frame, "OnLeave", Clicked.ClickCastHeader:GetAttribute("clear-keybinds"))
	end
end

function Clicked:ProcessClickCastFrameQueue()
	if InCombatLockdown() then
		return
	end

	do
		local queue = unregisterQueue
		unregisterQueue = {}

		for _, frame in ipairs(queue) do
			self:UnregisterClickCastFrame(frame)
		end
	end

	do
		local queue = registerQueue
		registerQueue = {}

		for _, frame in ipairs(queue) do
			self:RegisterClickCastFrame(frame.addon, frame.frame)
		end
	end

	do
		local queue = registerClicksQueue
		registerClicksQueue = {}

		for _, frame in ipairs(queue) do
			self:RegisterClickCastFrameClicks(frame)
		end
	end
end

function Clicked:RegisterClickCastFrame(addon, frame)
	if frame == nil then
		return
	end

	-- Already registered

	for _, existing in ipairs(frames) do
		if existing == frame then
			return
		end
	end

	-- We can't do anything while in combat, so put the items in a queue that
	-- gets processed when we exit combat.

	local function TryEnqueue()
		for i = 1, #registerQueue do
			local element = registerQueue[i]

			if element.addon == addon and element.frame == frame then
				return
			end
		end

		table.insert(registerQueue, {
			addon = addon,
			frame = frame
		})
	end

	if InCombatLockdown() then
		TryEnqueue()
		return
	end

	-- If the input frame is a string (from for example Blizzard frame integration),
	-- check if the associated addon is currently loaded and try to convert it to a
	-- frame in the global table.
	--
	-- Built-in Blizzard frames such as the Blizzard_ArenaUI are loaded on-demand
	-- and thus will have to be queued until the addon actually loads.

	if type(frame) == "string" then
		if addon ~= "" and not IsAddOnLoaded(addon) then
			TryEnqueue()
			return
		else
			local name = frame
			frame = _G[name]

			if frame == nil then
				print(L["ERR_FRAME_REGISTRATION"]:format(tostring(name)))
				return
			end
		end
	end

	-- Skip anything that is not clickable

	if not frame.RegisterForClicks then
		return
	end

	self:RegisterClickCastFrameClicks(frame)
	UpdateClickCastFrame(frame, cachedAttributes)

	table.insert(frames, frame)

	self:SendMessage(self.EVENT_CLICK_CAST_FRAME_REGISTERED, frame)
end

function Clicked:UnregisterClickCastFrame(frame)
	if frame == nil then
		return
	end

	local index = 0

	for i, existing in ipairs(frames) do
		if existing == frame then
			index = i
			break
		end
	end

	if index == 0 then
		return
	end

	-- If we're in combat we can't modify any frames, so put any
	-- unregister requests in a queue that gets processed when
	-- we leave combat.

	local function TryEnqueue()
		for i = 1, #unregisterQueue do
			local element = unregisterQueue[i]

			if element.frame == frame then
				return
			end
		end

		table.insert(unregisterQueue, frame)
	end

	if InCombatLockdown() then
		TryEnqueue()
		return
	end

	self:SetPendingFrameAttributes(frame, {})
	self:ApplyAttributesToFrame(frame)

	self.ClickCastHeader:UnwrapScript(frame, "OnEnter")
	self.ClickCastHeader:UnwrapScript(frame, "OnLeave")

	table.remove(frames, index)

	self:SendMessage(self.EVENT_CLICK_CAST_FRAME_UNREGISTERED, frame)
end

function Clicked:RegisterClickCastFrameClicks(frame)
	if frame == nil or frame.RegisterForClicks == nil then
		return
	end

	if InCombatLockdown() then
		table.insert(registerClicksQueue, frame)
		return
	end

	frame:RegisterForClicks("AnyUp")
	frame:EnableMouseWheel(true)
end

function Clicked:UpdateClickCastFrames(newAtributes)
	for _, frame in ipairs(frames) do
		UpdateClickCastFrame(frame, newAtributes)
	end

	cachedAttributes = newAtributes
end

function Clicked:IsFrameBlacklisted(frame)
	if frame == nil then
		return false
	end

	local blacklist = Clicked.db.profile.blacklist
	local name = frame:GetName()

	return blacklist[name]
end

function Clicked:GetClickCastFrames()
	return frames
end
