-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2022  Kevin Krol
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

--- @class ClickedInternal
local _, Addon = ...

--- @type Localization
local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

local frames = {}
local registerQueue = {}
local unregisterQueue = {}
local registerClicksQueue = {}
local cachedAttributes = {}
local sidecars = {}

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
			Clicked:RegisterClickCastFrame(frame.frame, frame.addon)
		end
	end

	do
		local queue = registerClicksQueue
		registerClicksQueue = {}

		for _, frame in ipairs(queue) do
			Clicked:RegisterFrameClicks(frame, true)
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

--- @param frame Frame
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
--- @param frame Button|string Either the frame to register, or the name of the frame that can be found in the global table.
--- @param addon string? The name of the addon that has requested the frame, unless the frames are part of a load-on-demand addon, this can be nil.
--- @see Clicked:UnregisterClickCastFrame
function Clicked:RegisterClickCastFrame(frame, addon)
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
		if addon ~= nil and not IsAddOnLoaded(addon) then
			TryEnqueue()
			return
		else
			--- @type string
			local name = frame
			frame = _G[name]

			if frame == nil then
				print(Addon:GetPrefixedAndFormattedString(L["Unable to register unit frame: %s"], name))
				return
			end
		end
	end

	-- Skip anything that is not clickable
	if frame.RegisterForClicks == nil then
		return
	end

	if frame:GetName() == nil then
		Clicked:CreateSidecar(frame, nil)
	end

	Clicked:RegisterFrameClicks(frame, true)
	UpdateClickCastFrame(frame, cachedAttributes)

	table.insert(frames, frame)

	Addon:BlacklistOptions_RegisterFrame(frame)
end

--- Unregister a registered click-cast enabled frame. See the documentation of `RegisterClickCastFrame` for more information.
---
--- @param frame Button The frame to unregister
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

	-- TODO: Unregister sidecar?

	table.remove(frames, index)

	Addon:BlacklistOptions_UnregisterFrame(frame)
end

--- Ensure that a frame is registered for mouse clicks and scrollwheel events. This will override the `RegisterForClicks` and `EnableMouseWheel` properties on
--- the frame. Because Clicked supports both on-down and on-up casting, if your addon provides built-in click behaviour, you may have to add in support for
--- this too.
---
--- @param frame Button The frame to register for clicks and scrollwheel events
--- @param isUnitFrame boolean Whether the frame is an unit frame
function Clicked:RegisterFrameClicks(frame, isUnitFrame)
	if frame == nil or frame.RegisterForClicks == nil then
		return
	end

	if InCombatLockdown() or not Addon:IsInitialized() then
		table.insert(registerClicksQueue, frame)
		return
	end

	if Addon:IsGameVersionAtleast("RETAIL") then
		if isUnitFrame then
			frame:RegisterForClicks(Addon.db.profile.options.onKeyDown and "AnyDown" or "AnyUp")
		else
			frame:RegisterForClicks("AnyDown", "AnyUp")
		end
	else
		frame:RegisterForClicks(Addon.db.profile.options.onKeyDown and "AnyDown" or "AnyUp")
	end

	frame:EnableMouseWheel(true)
end

--- Create a clickable sidecar, primarily for unamed frames such as the party frames.
---
--- @param frame Button The frame to create a sidecar for
--- @param name string? The human-readable name of the frame, since these frames are generally unamed, a custom name needs to be supploed
--- @return Button sidecar
function Clicked:CreateSidecar(frame, name)
	local sidecar = frame:GetAttribute("clicked-sidecar")

	if sidecar == nil then
		local frameName = "ClickedSidecar" .. tostring(#sidecars + 1)

		sidecar = CreateFrame("Button", frameName, frame, "SecureActionButtonTemplate")
		sidecar:SetAttribute("useparent*", true)

		frame:SetAttribute("clicked-sidecar", frameName)
		frame:SetAttribute("clicked-name", name)

		table.insert(sidecars, sidecar)
	else
		sidecar = _G[sidecar]
	end

	if name ~= nil then
		sidecar:SetAttribute("clicked-name", name)
	end

	return sidecar
end

--- Iterate through all registered click-cast enabled frames. This function can be used in a `for in` loop.
---
--- @return function iterator
--- @return Button t
--- @return number i
function Clicked:IterateClickCastFrames()
	return ipairs(frames)
end

--- Iterate through all registered click-cast sidecars. This function can be used in a `for in` loop.
---
--- A sidecar is a custom overlay frame used when a registered frame does not have a name. A name is required for
--- unit frame casting.
---
--- @return function iterator
--- @return Button t
--- @return number i
function Clicked:IterateSidecars()
	return ipairs(sidecars)
end
