local unitFrames = {}
local unitFrameRegisterQueue = {}
local unitFrameUnregisterQueue = {}

local clickCastRegisterQueue = {}
local clickCastAttributes = {}

function Clicked:ProcessUnitFrameQueue()
	if InCombatLockdown() then
		return
	end

	local unregisterQueue = unitFrameUnregisterQueue
	unitFrameUnregisterQueue = {}

	for _, frame in ipairs(unregisterQueue) do
		self:UnregisterUnitFrame(frame)
	end

	local registerQueue = unitFrameRegisterQueue
	unitFrameRegisterQueue = {}

	for _, frame in ipairs(registerQueue) do
		self:RegisterUnitFrame(frame.addon, frame.frame)
	end
end

function Clicked:ProcessClickCastQueue()
	local queue = clickCastRegisterQueue
	clickCastRegisterQueue = {}

	for _, frame in ipairs(queue) do
		self:UpdateRegisteredClicks(frame)
	end
end

function Clicked:RegisterUnitFrame(addon, frame)
	if frame == nil then
		return
	end

	-- Already registered, so just update the options in case they have
	-- changed for whatever reason.
	
	for _, existing in ipairs(unitFrames) do
		if existing == frame then
			return
		end
	end

	-- We can't do anything while in combat, so put the items in a queue that
	-- gets processed when we exit combat.

	if InCombatLockdown() then
		table.insert(unitFrameRegisterQueue, {
			addon = addon,
			frame = frame
		})

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
			table.insert(unitFrameRegisterQueue, {
				addon = addon,
				frame = frame
			})

			return
		else
			local name = frame
			frame = _G[name]

			if frame == nil then
				print("[" .. self.NAME .. "] Unablet to register unit frame: " .. tostring(name))
				return
			end
		end
	end

	-- Skip anything that is not clickable

	if not frame.RegisterForClicks then
		return
	end

	-- if not AceHook:IsHooked(frame, "OnEnter") then
	-- 	AceHook:SecureHookScript(frame, "OnEnter", function(frame)
	-- 		hoveredUnitFrame = frame.unit
	-- 	end)
	-- end

	-- if not AceHook:IsHooked(frame, "OnLeave") then
	-- 	AceHook:SecureHookScript(frame, "OnLeave", function(frame)
	-- 		hoveredUnitFrame = nil
	-- 	end)
	-- end
	
	self:ApplyAttributesToFrame(nil, clickCastAttributes, frame)
	self:UpdateRegisteredClicks(frame)
	
	table.insert(unitFrames, frame)
end

function Clicked:UnregisterUnitFrame(frame)
	if frame == nil then
		return
	end

	local index = 0

	for i, existing in ipairs(unitFrames) do
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

	if InCombatLockdown() then
		table.insert(unitFrameUnregisterQueue, frame)
		return
	end

	self:ApplyAttributesToFrame(clickCastAttributes, nil, frame)

	-- AceHook:Unhook(frame, "OnEnter")
	-- AceHook:Unhook(frame, "OnLeave")
	
	table.remove(unitFrames, index)
end

function Clicked:UpdateRegisteredClicks(frame)
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

function Clicked:UpdateClickCastAttributes(attributes)
	self:ApplyAttributesToFrames(clickCastAttributes, attributes, unitFrames)
	clickCastAttributes = attributes
end

function Clicked:RegisterIntegrations()
	self:RegisterBlizzardUnitFrames()
	self:RegisterOUF()
end
