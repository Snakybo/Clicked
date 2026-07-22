-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2026 Kevin Krol
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

--- @class Sidecar
--- @field public btnFrame Button
--- @field public keyFrame Button
--- @field public originalValues table<string, any>
--- @field public name? string
--- @field public isApplyPending? boolean

--- @class ClickedInternal
local Addon = select(2, ...)

local NOOP = "__noop"
local CLICK = "click"
local ROUTED = "routed"

--- @type table<Button, Sidecar>
local sidecars = {}

--- @type Sidecar[]
local pool = {}

local nextId = 1

--- @type table<string, string>
local aliases = {}

--- @type table<string, any>
local baseAttributes = {
	["*type1"] = CLICK,
	["*type2"] = CLICK,
	["type"] = CLICK,
	["*type*"] = CLICK,
	["type1"] = CLICK,
	["type2"] = CLICK,
	["clickbutton"] = ROUTED,
	["*clickbutton*"] = ROUTED,
	["clickbutton1"] = ROUTED,
	["clickbutton2"] = ROUTED,
	["*clickbutton1"] = ROUTED,
	["*clickbutton2"] = ROUTED,
}

-- Local support functions

--- @param frame Button
--- @param attribute string
--- @param value any
local function SetAttribute(frame, attribute, value)
	local sidecar = sidecars[frame]
	if sidecar == nil then
		return
	end

	if sidecar.originalValues[attribute] == nil then
		local original = frame:GetAttribute(attribute)
		sidecar.originalValues[attribute] = original == nil and NOOP or original
	end

	frame:SetAttribute(attribute, value)
end

--- @param frame Button
--- @param attribute string
local function ClearAttribute(frame, attribute)
	local sidecar = sidecars[frame]
	if sidecar == nil then
		return
	end

	local original = sidecar.originalValues[attribute]
	if original == nil then
		return
	end

	frame:SetAttribute(attribute, original ~= NOOP and original or nil)
	sidecar.originalValues[attribute] = nil
end

--- @param frame Button
--- @param sidecar Sidecar
local function UpdateAttributes(frame, sidecar)
	for attr, value in pairs(baseAttributes) do
		SetAttribute(frame, attr, value == ROUTED and sidecar.btnFrame or value)
	end

	frame:SetAttribute("clicked-btn-sidecar", sidecar.btnFrame:GetName())
	frame:SetAttribute("clicked-key-sidecar", sidecar.keyFrame:GetName())

	--- @type table<string, boolean>
	local seen = {}

	for type, alias in pairs(aliases) do
		SetAttribute(frame, type, "click")
		seen[type] = true

		SetAttribute(frame, alias, sidecar.btnFrame)
		seen[alias] = true
	end

	for attribute in pairs(sidecar.originalValues) do
		if baseAttributes[attribute] == nil and not seen[attribute] then
			ClearAttribute(frame, attribute)
		end
	end
end

-- Private addon API

--- @param frame Button
--- @return Sidecar
function Addon:GetOrCreateSidecar(frame)
	local sidecar = sidecars[frame]
	if sidecar ~= nil then
		UpdateAttributes(frame, sidecar)
		return sidecar
	end

	local pooled = table.remove(pool)
	if pooled ~= nil then
		sidecars[frame] = pooled
		UpdateAttributes(frame, pooled)
		return pooled
	end

	local btnName = "ClickedBtnSidecar" .. nextId
	local btn = CreateFrame("Button", btnName, frame, "SecureActionButtonTemplate") --[[@as Button]]
	btn:SetAttribute("useparent-unit", true)
	btn:SetAttribute("useparent-unitsuffix", true)
	btn:SetAttribute("useOnKeyDown", false)
	btn:RegisterForClicks("AnyUp")

	local keyName = "ClickedKeySidecar" .. nextId
	local key = CreateFrame("Button", keyName, frame, "SecureActionButtonTemplate") --[[@as Button]]
	key:SetAttribute("useparent-unit", true)
	key:SetAttribute("useparent-unitsuffix", true)
	key:SetAttribute("useOnKeyDown", Addon.db.profile.options.onKeyDown and true or false)
	key:RegisterForClicks(Addon.db.profile.options.onKeyDown and "AnyDown" or "AnyUp")

	Clicked:LogVerbose("Created sidecar {sidecarId} for frame {frameName}", nextId, frame:GetName() or "<unnamed>")

	--- @type Sidecar
	sidecar = {
		btnFrame = btn,
		keyFrame = key,
		originalValues = {}
	}

	sidecars[frame] = sidecar
	nextId = nextId + 1

	UpdateAttributes(frame, sidecar)
	return sidecar
end

--- @param frame Button
--- @return Sidecar?
function Addon:GetSidecar(frame)
	return sidecars[frame]
end

--- @param attributes table<string, string>
function Addon:CreateSidecarAttributeAliases(attributes)
	wipe(aliases)

	for key in pairs(attributes) do
		local prefix, buttonIndex = string.match(key, "^(.-)type(%d+)$")

		if buttonIndex ~= nil then
			local typeAttr = prefix .. "type" .. buttonIndex

			if aliases[typeAttr] == nil then
				aliases[typeAttr] = prefix .. "clickbutton" .. buttonIndex
			end
		end
	end
end

--- @param frame Button
function Addon:ReapplySidecar(frame)
	local sidecar = sidecars[frame]
	if sidecar == nil then
		return
	end

	if Addon:IsFrameBlacklisted(frame) then
		return
	end

	if InCombatLockdown() then
		sidecar.isApplyPending = true
		return
	end

	UpdateAttributes(frame, sidecar)
end
function Addon:ReapplySidecars()
	if InCombatLockdown() then
		for frame, sidecar in pairs(sidecars) do
			if not Addon:IsFrameBlacklisted(frame) then
				sidecar.isApplyPending = true
			end
		end

		return
	end

	for frame, sidecar in pairs(sidecars) do
		if not Addon:IsFrameBlacklisted(frame) then
			UpdateAttributes(frame, sidecar)
		end
	end
end

function Addon:ProcessSidecarQueue()
	if InCombatLockdown() then
		return
	end

	for frame, sidecar in pairs(sidecars) do
		if sidecar.isApplyPending and not Addon:IsFrameBlacklisted(frame) then
			UpdateAttributes(frame, sidecar)
			sidecar.isApplyPending = nil
		end
	end
end

function Addon:UpdateSidecarClickDirection()
	if InCombatLockdown() then
		return
	end

	local onKeyDown = Addon.db.profile.options.onKeyDown and true or false

	for _, sidecar in pairs(sidecars) do
		sidecar.keyFrame:SetAttribute("useOnKeyDown", onKeyDown)
		sidecar.keyFrame:RegisterForClicks(onKeyDown and "AnyDown" or "AnyUp")
	end

	for _, sidecar in ipairs(pool) do
		sidecar.keyFrame:SetAttribute("useOnKeyDown", onKeyDown)
		sidecar.keyFrame:RegisterForClicks(onKeyDown and "AnyDown" or "AnyUp")
	end
end

--- @param frame Button
function Addon:RemoveSidecar(frame)
	local sidecar = sidecars[frame]
	if sidecar == nil then
		return
	end

	for attr in pairs(sidecar.originalValues) do
		ClearAttribute(frame, attr)
	end

	frame:SetAttribute("clicked-btn-sidecar", nil)
	frame:SetAttribute("clicked-key-sidecar", nil)

	wipe(sidecar.originalValues)
	sidecar.name = nil

	sidecars[frame] = nil
	table.insert(pool, sidecar)
end

function Clicked:IterateSidecars()
	return pairs(sidecars)
end
