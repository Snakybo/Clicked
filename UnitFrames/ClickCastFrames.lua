local frames = {}
local registerQueue = {}
local unregisterQueue = {}
local registerClicksQueue = {}
local attributes = {}

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

	-- Already registered, so just update the options in case they have
	-- changed for whatever reason.
	
	for _, existing in ipairs(frames) do
		if existing == frame then
			return
		end
	end

	-- We can't do anything while in combat, so put the items in a queue that
	-- gets processed when we exit combat.

	if InCombatLockdown() then
		table.insert(registerQueue, {
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
			table.insert(registerQueue, {
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

	if self.ClickCastHeader ~= nil then
		self.ClickCastHeader:WrapScript(frame, "OnEnter", Clicked.ClickCastHeader:GetAttribute("setup-keybinds"))
		self.ClickCastHeader:WrapScript(frame, "OnLeave", Clicked.ClickCastHeader:GetAttribute("clear-keybinds"))
	end
	
	self:ApplyAttributesToFrame(nil, attributes, frame)
	self:RegisterClickCastFrameClicks(frame)
	
	table.insert(frames, frame)
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

	if InCombatLockdown() then
		table.insert(unregisterQueue, frame)
		return
	end

	self:SetPendingFrameAttributes(frame, attributes)
	self:ApplyAttributesToFrame(frame)

	self.ClickCastHeader:UnwrapScript(frame, "OnEnter")
	self.ClickCastHeader:UnwrapScript(frame, "OnLeave")
	
	table.remove(frames, index)
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
		self:SetPendingFrameAttributes(frame, newAtributes)
		self:ApplyAttributesToFrame(frame)
		
		if self.ClickCastHeader ~= nil then
			self.ClickCastHeader:UnwrapScript(frame, "OnEnter")
			self.ClickCastHeader:UnwrapScript(frame, "OnLeave")
			self.ClickCastHeader:WrapScript(frame, "OnEnter", Clicked.ClickCastHeader:GetAttribute("setup-keybinds"))
			self.ClickCastHeader:WrapScript(frame, "OnLeave", Clicked.ClickCastHeader:GetAttribute("clear-keybinds"))
		end
	end

	attributes = newAtributes
end
