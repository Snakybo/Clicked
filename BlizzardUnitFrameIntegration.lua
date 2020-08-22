local BLIZZARD_UNIT_FRAMES = {
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

function Clicked:RegisterBlizzardUnitFrames()
    for addon, names in pairs(BLIZZARD_UNIT_FRAMES) do
        for _, name in ipairs(names) do
            self:RegisterUnitFrame(addon, name, true)
        end
    end
end