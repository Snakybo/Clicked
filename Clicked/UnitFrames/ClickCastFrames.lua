--- @type ClickedInternal
local _, Addon = ...

--- @type Localization
local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

local frames = {}
local registerQueue = {}
local unregisterQueue = {}
local registerClicksQueue = {}
local cachedAttributes = {}

-- Local support functions

--- @param frame table
--- @param attributes table<string,string>
local function UpdateClickCastFrame(frame, attributes)
	Addon:SetPendingFrameAttributes(frame, attributes)
	Addon:ApplyAttributesToFrame(frame)

	if Addon.ClickCastHeader ~= nil then
		Addon.ClickCastHeader:UnwrapScript(frame, "OnEnter")
		Addon.ClickCastHeader:UnwrapScript(frame, "OnLeave")
		Addon.ClickCastHeader:WrapScript(frame, "OnEnter", Addon.ClickCastHeader:GetAttribute("setup-keybinds"))
		Addon.ClickCastHeader:WrapScript(frame, "OnLeave", Addon.ClickCastHeader:GetAttribute("clear-keybinds"))
	end
end

-- Private addon API

function Addon:ProcessFrameQueue()
	if InCombatLockdown() then
		return
	end

	do
		local queue = unregisterQueue
		unregisterQueue = {}

		for _, frame in ipairs(queue) do
			Clicked:UnregisterClickCastFrame(frame)
		end
	end

	do
		local queue = registerQueue
		registerQueue = {}

		for _, frame in ipairs(queue) do
			Clicked:RegisterClickCastFrame(frame.addon, frame.frame)
		end
	end

	do
		local queue = registerClicksQueue
		registerClicksQueue = {}

		for _, frame in ipairs(queue) do
			Clicked:RegisterFrameClicks(frame)
		end
	end
end

--- @param newAtributes table<string,string>
function Addon:UpdateClickCastFrames(newAtributes)
	for _, frame in ipairs(frames) do
		UpdateClickCastFrame(frame, newAtributes)
	end

	cachedAttributes = newAtributes
end

--- @param frame table
--- @return boolean
function Addon:IsFrameBlacklisted(frame)
	if frame == nil then
		return false
	end

	local blacklist = Addon.db.profile.blacklist
	local name = frame:GetName()

	return blacklist[name]
end

-- Public addon API

--- Manually register a click-cast enabled frame. This is not the preferred method of registering frames as it offers no cross-addon compatibility. Instead use
--- the global `ClickCastFrames` table to register and unregister your frames.
---
--- Registration:
--- `ClickCastFrames[myFrame] = true`
---
--- Unregistration:
--- `ClickCastFrames[myFrame] = false`
---
--- Additionally, it is possible to register and unregister frames using the global `ClickCastHeader` frame. This header has two attributes that can be
--- executed: `clickcast_register` to register a frame, and `clickcast_unregister` to unregister a frame. Both of these attributes require a
--- `clickcast_button` attribute to be set prior to execution:
--- ```
--- local header = self:GetFrameRef("clickcast_header")
--- header:SetAttribute("clickcast_button", self)
--- header:RunAttribute("clickcast_register")
--- ```
---
--- The `ClickCastHeader` also has attributes that can be used for `OnEnter` and `OnLeave` events, which can be used if your frame does not support the
--- frame `OnEnter` and `OnLeave` scripts, these can be invoked using the `clickcast_onenter` and `clickcast_onleave` attributes. These will also be used if
--- your frame inherits from the `ClickCastUnitTemplate`.
---
--- @param addon string The name of the addon that has requested the frame, unless the frames are part of a load-on-demand addon, this can be an empty string.
--- @param frame table The frame to register.
--- @see Clicked:UnregisterClickCastFrame
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

	if InCombatLockdown() or not Addon:IsInitialized() then
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
				print(Addon:GetPrefixedAndFormattedString(L["Unable to register unit frame: %s"], tostring(name)))
				return
			end
		end
	end

	-- Skip anything that is not clickable

	if frame.RegisterForClicks == nil then
		return
	end

	Clicked:RegisterFrameClicks(frame)
	UpdateClickCastFrame(frame, cachedAttributes)

	table.insert(frames, frame)

	Addon:BlacklistOptions_RegisterFrame(frame)
end

--- Unregister a registered click-cast enabled frame. See the documentation of `RegisterClickCastFrame` for more information.
---
--- @param frame table The frame to unregister
--- @see Clicked#RegisterClickCastFrame
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

	if InCombatLockdown() or not Addon:IsInitialized() then
		TryEnqueue()
		return
	end

	Addon:SetPendingFrameAttributes(frame, {})
	Addon:ApplyAttributesToFrame(frame)

	Addon.ClickCastHeader:UnwrapScript(frame, "OnEnter")
	Addon.ClickCastHeader:UnwrapScript(frame, "OnLeave")

	table.remove(frames, index)

	Addon:BlacklistOptions_UnregisterFrame(frame)
end

--- Ensure that a frame is registered for mouse clicks and scrollwheel events. This will override the `RegisterForClicks` and `EnableMouseWheel` properties on
--- the frame. Because Clicked supports both on-down and on-up casting, if your addon provides built-in click behaviour, you may have to add in support for
--- this too.
---
--- @param frame table The frame to register for clicks and scrollwheel events
function Clicked:RegisterFrameClicks(frame)
	if frame == nil or frame.RegisterForClicks == nil then
		return
	end

	if InCombatLockdown() or not Addon:IsInitialized() then
		table.insert(registerClicksQueue, frame)
		return
	end

	frame:RegisterForClicks(Addon.db.profile.options.onKeyDown and "AnyDown" or "AnyUp")
	frame:EnableMouseWheel(true)
end

--- Iterate through all registered click-cast enabled frames. This function can be used in a `for in` loop.
---
--- @return function iterator
--- @return table t
--- @return number i
function Clicked:IterateClickCastFrames()
	return ipairs(frames)
end
