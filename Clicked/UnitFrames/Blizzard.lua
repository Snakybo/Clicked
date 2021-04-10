--- @type ClickedInternal
local _, Addon = ...

local unitFrames = {}

if Addon:IsGameVersionAtleast("CLASSIC") then
	unitFrames[""] = unitFrames[""] or {}

	table.insert(unitFrames[""], "PlayerFrame")
	table.insert(unitFrames[""], "PetFrame")
	table.insert(unitFrames[""], "TargetFrame")
	table.insert(unitFrames[""], "TargetFrameToT")
	table.insert(unitFrames[""], "PartyMemberFrame1")
	table.insert(unitFrames[""], "PartyMemberFrame1PetFrame")
	table.insert(unitFrames[""], "PartyMemberFrame2")
	table.insert(unitFrames[""], "PartyMemberFrame2PetFrame")
	table.insert(unitFrames[""], "PartyMemberFrame3")
	table.insert(unitFrames[""], "PartyMemberFrame3PetFrame")
	table.insert(unitFrames[""], "PartyMemberFrame4")
	table.insert(unitFrames[""], "PartyMemberFrame4PetFrame")
	table.insert(unitFrames[""], "Boss1TargetFrame")
	table.insert(unitFrames[""], "Boss2TargetFrame")
	table.insert(unitFrames[""], "Boss3TargetFrame")
	table.insert(unitFrames[""], "Boss4TargetFrame")
	table.insert(unitFrames[""], "Boss5TargetFrame")
end

if Addon:IsGameVersionAtleast("BC") then
	unitFrames[""] = unitFrames[""] or {}

	table.insert(unitFrames[""], "FocusFrame")
	table.insert(unitFrames[""], "FocusFrameToT")
end

if Addon:IsGameVersionAtleast("RETAIL") then
	unitFrames["Blizzard_ArenaUI"] = unitFrames["Blizzard_ArenaUI"] or {}

	table.insert(unitFrames["Blizzard_ArenaUI"], "ArenaEnemyFrame1")
	table.insert(unitFrames["Blizzard_ArenaUI"], "ArenaEnemyFrame2")
	table.insert(unitFrames["Blizzard_ArenaUI"], "ArenaEnemyFrame3")
end

-- Local support functions

--- @param name string
--- @param part string
--- @param index string
local function HookCompactUnitFramePart(name, part, index)
	local frame = _G[name .. part .. index]

	if frame ~= nil then
		Clicked:RegisterClickCastFrame("", frame)
	end
end

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
		HookCompactUnitFramePart(name, "Buff", i)
		HookCompactUnitFramePart(name, "Debuff", i)
		HookCompactUnitFramePart(name, "DispelDebuff", i)
		HookCompactUnitFramePart(name, "CenterStatusIcon", i)
	end

	Clicked:RegisterClickCastFrame("", frame)
end

-- Private addon API

function Addon:RegisterBlizzardUnitFrames()
	for addon, names in pairs(unitFrames) do
		for _, name in ipairs(names) do
			Clicked:RegisterClickCastFrame(addon, name)
		end
	end

	hooksecurefunc("CompactUnitFrame_SetUpFrame", HookCompactUnitFrame)
end
