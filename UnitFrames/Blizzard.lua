local BLIZZARD_UNIT_FRAMES_MAINLINE = {
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
		"Boss4TargetFrame"
	},
	["Blizzard_ArenaUI"] = {
		"ArenaEnemyFrame1",
		"ArenaEnemyFrame2",
		"ArenaEnemyFrame3"
	}
}

local BLIZZARD_UNIT_FRAMES_CLASSIC = {
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
		"Boss4TargetFrame"
	}
}

local function HookCompactUnitFramePart(name, part, index)
	local frame = _G[name .. part .. index]

	if frame ~= nil then
		Clicked:RegisterClickCastFrame("", frame)
	end
end

local function HookCompactUnitFrame(frame, ...)
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

function Clicked:RegisterBlizzardUnitFrames()
	local frames = BLIZZARD_UNIT_FRAMES_MAINLINE

	if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
		frames = BLIZZARD_UNIT_FRAMES_CLASSIC
	end

	for addon, names in pairs(frames) do
		for _, name in ipairs(names) do
			self:RegisterClickCastFrame(addon, name)
		end
	end

	hooksecurefunc("CompactUnitFrame_SetUpFrame", HookCompactUnitFrame)
end
