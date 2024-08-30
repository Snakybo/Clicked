-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2024  Kevin Krol
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
local Addon = select(2, ...)

-- Local support functions

--- @param count integer
--- @param names string|string[]
--- @param addon string?
local function HookUnitFrame(count, names, addon)
	if type(names) == "string" then
		names = {names}
	end

	for _, name in ipairs(names) do
		for i = 1, count do
			Clicked:RegisterClickCastFrame(string.format(name, i), addon)
		end
	end
end

--- @param parent Button
--- @param name string
local function HookCompactUnitFramePart(parent, name)
	local frame = _G[name]

	Addon.BlacklistOptions:SetBlacklistGroup(frame, parent:GetName())
	Clicked:RegisterClickCastFrame(frame)
end

--- @param frame Button
local function HookCompactUnitFrame(frame)
	if frame == nil or frame:IsForbidden() then
		return
	end

	local name = frame:GetName()

	if name == nil then
		return
	end

	if string.match(name, "^NamePlate") then
		return
	end

	for i = 1, 3 do
		HookCompactUnitFramePart(frame, name .. "Buff" .. i)
		HookCompactUnitFramePart(frame, name .. "Debuff" .. i)
		HookCompactUnitFramePart(frame, name .. "DispelDebuff" .. i)
	end

	HookCompactUnitFramePart(frame, name .. "CenterStatusIcon")
	Clicked:RegisterClickCastFrame(frame)
end

-- Private addon API

function Addon:RegisterBlizzardUnitFrames()
	Clicked:RegisterClickCastFrame("PlayerFrame")
	Clicked:RegisterClickCastFrame("PetFrame")
	Clicked:RegisterClickCastFrame("TargetFrame")
	Clicked:RegisterClickCastFrame("TargetFrameToT")

	HookUnitFrame(5, "Boss%dTargetFrame")

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.BC then
		Clicked:RegisterClickCastFrame("FocusFrame")
		Clicked:RegisterClickCastFrame("FocusFrameToT")
	end

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.CATA then
		HookUnitFrame(3, "ArenaEnemyFrame%d", "Blizzard_ArenaUI")
	end

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.DF then
		local partyFrameIndex = 1

		for frame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
			Clicked:RegisterClickCastFrame(frame)
			Clicked:RegisterClickCastFrame(frame.PetFrame)

			Clicked:CreateSidecar(frame, "PartyMemberFrame" .. partyFrameIndex)
			Clicked:CreateSidecar(frame.PetFrame, "PartyMemberFrame" .. partyFrameIndex .. "PetFrame")

			partyFrameIndex = partyFrameIndex + 1
		end
	else
		HookUnitFrame(4, {"PartyMemberFrame%d", "PartyMemberFrame%dPetFrame"})
	end

	hooksecurefunc("CompactUnitFrame_SetUpFrame", HookCompactUnitFrame)
end
