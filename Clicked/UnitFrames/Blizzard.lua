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

-- Local support functions

--- @param frame table
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
		Clicked:RegisterClickCastFrame(name .. "Buff" .. i)
		Clicked:RegisterClickCastFrame(name .. "Debuff" .. i)
		Clicked:RegisterClickCastFrame(name .. "DispelDebuff" .. i)
	end

	Clicked:RegisterClickCastFrame(name .. "CenterStatusIcon")
	Clicked:RegisterClickCastFrame(frame)
end

-- Private addon API

function Addon:RegisterBlizzardUnitFrames()
	if Addon:IsGameVersionAtleast("CLASSIC") then
		Clicked:RegisterClickCastFrame("PlayerFrame")
		Clicked:RegisterClickCastFrame("PetFrame")
		Clicked:RegisterClickCastFrame("TargetFrame")
		Clicked:RegisterClickCastFrame("TargetFrameToT")

		Clicked:RegisterClickCastFrame("Boss1TargetFrame")
		Clicked:RegisterClickCastFrame("Boss2TargetFrame")
		Clicked:RegisterClickCastFrame("Boss3TargetFrame")
		Clicked:RegisterClickCastFrame("Boss4TargetFrame")
		Clicked:RegisterClickCastFrame("Boss5TargetFrame")

		if not Addon:IsGameVersionAtleast("RETAIL") then
			Clicked:RegisterClickCastFrame("PartyMemberFrame1")
			Clicked:RegisterClickCastFrame("PartyMemberFrame1PetFrame")
			Clicked:RegisterClickCastFrame("PartyMemberFrame2")
			Clicked:RegisterClickCastFrame("PartyMemberFrame2PetFrame")
			Clicked:RegisterClickCastFrame("PartyMemberFrame3")
			Clicked:RegisterClickCastFrame("PartyMemberFrame3PetFrame")
			Clicked:RegisterClickCastFrame("PartyMemberFrame4")
			Clicked:RegisterClickCastFrame("PartyMemberFrame4PetFrame")
		end

		HookCompactUnitFrame(_G["CompactPartyFrameMember1"])
	end

	if Addon:IsGameVersionAtleast("BC") then
		Clicked:RegisterClickCastFrame("FocusFrame")
		Clicked:RegisterClickCastFrame("FocusFrameToT")
	end

	if Addon:IsGameVersionAtleast("RETAIL") then
		Clicked:RegisterClickCastFrame("ArenaEnemyFrame1", "Blizzard_ArenaUI")
		Clicked:RegisterClickCastFrame("ArenaEnemyFrame2", "Blizzard_ArenaUI")
		Clicked:RegisterClickCastFrame("ArenaEnemyFrame3", "Blizzard_ArenaUI")

		-- This fixes click-casting for these frames but there are still errors popping up due to them not having a name.
		-- for memberFrame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
		-- 	Clicked:RegisterClickCastFrame(nil, memberFrame)
		-- 	Clicked:RegisterClickCastFrame(nil, memberFrame.PetFrame)
		-- end
	end

	hooksecurefunc("CompactUnitFrame_SetUpFrame", HookCompactUnitFrame)
end
