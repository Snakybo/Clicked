--- @type ClickedInternal
local _, Addon = ...

local unitFrames

if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
	unitFrames = {
		[""] = {
			"PlayerFrame",
			"PetFrame",
			"TargetFrame",
			"TargetFrameToT",
			"FocusFrame",
			"FocusFrameToT",
			"PartyMemberFrame1",
			"PartyMemberFrame1PetFrame",
			"PartyMemberFrame2",
			"PartyMemberFrame2PetFrame",
			"PartyMemberFrame3",
			"PartyMemberFrame3PetFrame",
			"PartyMemberFrame4",
			"PartyMemberFrame4PetFrame",
			"Boss1TargetFrame",
			"Boss2TargetFrame",
			"Boss3TargetFrame",
			"Boss4TargetFrame",
			"Boss5TargetFrame"
		},
		["Blizzard_ArenaUI"] = {
			"ArenaEnemyFrame1",
			"ArenaEnemyFrame2",
			"ArenaEnemyFrame3"
		}
	}
else
	unitFrames = {
		[""] = {
			"PlayerFrame",
			"PetFrame",
			"TargetFrame",
			"TargetFrameToT",
			"PartyMemberFrame1",
			"PartyMemberFrame1PetFrame",
			"PartyMemberFrame2",
			"PartyMemberFrame2PetFrame",
			"PartyMemberFrame3",
			"PartyMemberFrame3PetFrame",
			"PartyMemberFrame4",
			"PartyMemberFrame4PetFrame",
			"Boss1TargetFrame",
			"Boss2TargetFrame",
			"Boss3TargetFrame",
			"Boss4TargetFrame",
			"Boss5TargetFrame"
		}
	}
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
