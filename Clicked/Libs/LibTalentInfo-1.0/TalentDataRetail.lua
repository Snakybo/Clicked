local LibTalentInfo = LibStub and LibStub("LibTalentInfo-1.0", true)
local version = 45632

if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE or LibTalentInfo == nil or version <= LibTalentInfo:GetTalentProviderVersion() then
	return
end

--- @type table<string,table<integer,integer>>
local specializations = {
	MAGE = {
		[1] = 62, -- Arcane
		[2] = 63, -- Fire
		[3] = 64, -- Frost
		[5] = 1449, -- Initial
	},
	PALADIN = {
		[1] = 65, -- Holy
		[2] = 66, -- Protection
		[3] = 70, -- Retribution
		[5] = 1451, -- Initial
	},
	WARRIOR = {
		[1] = 71, -- Arms
		[2] = 72, -- Fury
		[3] = 73, -- Protection
		[5] = 1446, -- Initial
	},
	DRUID = {
		[1] = 102, -- Balance
		[2] = 103, -- Feral
		[3] = 104, -- Guardian
		[4] = 105, -- Restoration
		[5] = 1447, -- Initial
	},
	DEATHKNIGHT = {
		[1] = 250, -- Blood
		[2] = 251, -- Frost
		[3] = 252, -- Unholy
		[5] = 1455, -- Initial
	},
	HUNTER = {
		[1] = 253, -- Beast Mastery
		[2] = 254, -- Marksmanship
		[3] = 255, -- Survival
		[5] = 1448, -- Initial
	},
	PRIEST = {
		[1] = 256, -- Discipline
		[2] = 257, -- Holy
		[3] = 258, -- Shadow
		[5] = 1452, -- Initial
	},
	ROGUE = {
		[1] = 259, -- Assassination
		[2] = 260, -- Outlaw
		[3] = 261, -- Subtlety
		[5] = 1453, -- Initial
	},
	SHAMAN = {
		[1] = 262, -- Elemental
		[2] = 263, -- Enhancement
		[3] = 264, -- Restoration
		[5] = 1444, -- Initial
	},
	WARLOCK = {
		[1] = 265, -- Affliction
		[2] = 266, -- Demonology
		[3] = 267, -- Destruction
		[5] = 1454, -- Initial
	},
	MONK = {
		[1] = 268, -- Brewmaster
		[2] = 270, -- Mistweaver
		[3] = 269, -- Windwalker
		[5] = 1450, -- Initial
	},
	DEMONHUNTER = {
		[1] = 577, -- Havoc
		[2] = 581, -- Vengeance
		[5] = 1456, -- Initial
	},
	EVOKER = {
		[1] = 1467, -- Devastation
		[2] = 1468, -- Preservation
		[5] = 1465, -- Initial
	},
}

--- @type table<integer,integer[]>
local talents = {
	-- Arcane Mage
	[62] = {
		383860, -- [0] Fire Frenzy
		383810, -- [1] Fevered Incantation
		205023, -- [2] Conflagration
		383665, -- [3] Incendiary Eruptions
		205029, -- [4] Flame On
		343230, -- [5] Improved Flamestrike
		387044, -- [6] Fervent Flickering
		205037, -- [7] Flame Patch
		44457, -- [8] Living Bomb
		383391, -- [9] Blaster Master
		384174, -- [10] Master of Flame
		205020, -- [11] Pyromaniac
		384033, -- [12] Molten Skyfall
		155148, -- [13] Kindling
		269650, -- [14] Pyroclasm
		203275, -- [15] Tinder
		383659, -- [16] Tempered Flames
		321710, -- [17] Combustion
		383489, -- [18] Wildfire
		383634, -- [19] Fiery Rush
		383669, -- [20] Controlled Destruction
		383886, -- [21] Sun King's Blessing
		86949, -- [22] Cauterize
		190319, -- [23] Combustion
		383499, -- [24] Firemind
		383476, -- [25] Phoenix Reborn
		343222, -- [26] Phoenix Flames
		383604, -- [27] Improved Scorch
		269644, -- [28] Searing Touch
		2948, -- [29] Scorch
		108853, -- [30] Fire Blast
		11366, -- [31] Pyroblast
		2120, -- [32] Flamestrike
		257541, -- [33] Phoenix Flames
		157642, -- [34] Enhanced Pyrotechnics
		117216, -- [35] Critical Mass
		342344, -- [36] From the Ashes
		235870, -- [37] Alexstrasza's Fury
		205026, -- [38] Firestarter
		387807, -- [39] Time Manipulation
		235224, -- [40] Frigid Winds
		382493, -- [41] Tome of Rhonin
		157997, -- [42] Ice Nova
		382569, -- [43] Reduplication
		382820, -- [44] Reabsorption
		55342, -- [45] Mirror Image
		382424, -- [46] Winter's Protection
		45438, -- [47] Ice Block
		390218, -- [48] Overflowing Energy [NYI]
		235313, -- [49] Blazing Barrier
		66, -- [50] Invisibility
		475, -- [51] Remove Curse
		342245, -- [52] Alter Time
		383092, -- [53] Arcane Warding
		1463, -- [54] Incanter's Flow
		116011, -- [55] Rune of Power
		382293, -- [56] Incantation of Swiftness
		382289, -- [57] Tempest Barrier
		382481, -- [58] Rigid Ice
		391102, -- [59] Sloooow Down
		343183, -- [60] Improved Frost Nova
		382292, -- [61] Cryo-Freeze
		383121, -- [62] Mass Polymorph
		212653, -- [63] Shimmer
		108839, -- [64] Ice Floes
		382297, -- [65] Grounding Surge
		157981, -- [66] Blast Wave
		342249, -- [67] Master of Time
		382270, -- [68] Diverted Energy
		386828, -- [69] Energized Barriers
		382826, -- [70] Temporal Velocity
		382490, -- [71] Tome of Antonidas
		31589, -- [72] Slow
		382268, -- [73] Flow of Time
		110959, -- [74] Greater Invisibility
		383243, -- [75] Time Anomaly
		386539, -- [76] Temporal Warp
		382800, -- [77] Accumulative Shielding
		389713, -- [78] Reflection
		31661, -- [79] Dragon's Breath
		153561, -- [80] Meteor
		389627, -- [81] Volatile Detonation
		113724, -- [82] Ring of Frost
		386763, -- [83] Freezing Cold
		205036, -- [84] Ice Ward
		382440, -- [85] Shifting Power
		30449, -- [86] Spellsteal
	},
	-- Fire Mage
	[63] = {
		205021, -- [0] Ray of Frost
		378919, -- [1] Arctic Piercing
		205027, -- [2] Bone Chilling
		379993, -- [3] Flash Freeze
		236662, -- [4] Improved Blizzard
		385167, -- [5] Everlasting Frost
		381706, -- [6] Snowstorm
		12472, -- [7] Icy Veins
		378406, -- [8] Wintertide
		205024, -- [9] Lonely Winter
		31687, -- [10] Summon Water Elemental
		235219, -- [11] Cold Snap
		190356, -- [12] Blizzard
		30455, -- [13] Ice Lance
		84714, -- [14] Frozen Orb
		44614, -- [15] Flurry
		190447, -- [16] Brain Freeze
		257537, -- [17] Ebonbolt
		205030, -- [18] Frozen Touch
		378198, -- [19] Perpetual Winter
		378947, -- [20] Glacial Assault
		153595, -- [21] Comet Storm
		378448, -- [22] Fractured Frost
		382110, -- [23] Cold Front
		12982, -- [24] Shatter
		112965, -- [25] Fingers of Frost
		379049, -- [26] Ice Nine
		380154, -- [27] Frigid Shattering
		378749, -- [28] Deep Shatter
		381244, -- [29] Hailstones
		199786, -- [30] Glacial Spike
		155149, -- [31] Thermal Void
		278309, -- [32] Chain Reaction
		378433, -- [33] Icy Propulsion
		321702, -- [34] Improved Icy Veins
		378901, -- [35] Snap Freeze
		382103, -- [36] Freezing Winds
		382144, -- [37] Slick Ice
		270233, -- [38] Freezing Rain
		378756, -- [39] Frostbite
		387807, -- [40] Time Manipulation
		235224, -- [41] Frigid Winds
		382493, -- [42] Tome of Rhonin
		157997, -- [43] Ice Nova
		382569, -- [44] Reduplication
		382820, -- [45] Reabsorption
		55342, -- [46] Mirror Image
		382424, -- [47] Winter's Protection
		45438, -- [48] Ice Block
		390218, -- [49] Overflowing Energy [NYI]
		66, -- [50] Invisibility
		11426, -- [51] Ice Barrier
		475, -- [52] Remove Curse
		342245, -- [53] Alter Time
		383092, -- [54] Arcane Warding
		1463, -- [55] Incanter's Flow
		116011, -- [56] Rune of Power
		382293, -- [57] Incantation of Swiftness
		382289, -- [58] Tempest Barrier
		382481, -- [59] Rigid Ice
		391102, -- [60] Sloooow Down
		343183, -- [61] Improved Frost Nova
		382292, -- [62] Cryo-Freeze
		383121, -- [63] Mass Polymorph
		212653, -- [64] Shimmer
		108839, -- [65] Ice Floes
		382297, -- [66] Grounding Surge
		157981, -- [67] Blast Wave
		342249, -- [68] Master of Time
		382270, -- [69] Diverted Energy
		386828, -- [70] Energized Barriers
		382826, -- [71] Temporal Velocity
		382490, -- [72] Tome of Antonidas
		31589, -- [73] Slow
		382268, -- [74] Flow of Time
		110959, -- [75] Greater Invisibility
		383243, -- [76] Time Anomaly
		386539, -- [77] Temporal Warp
		382800, -- [78] Accumulative Shielding
		389713, -- [79] Reflection
		31661, -- [80] Dragon's Breath
		153561, -- [81] Meteor
		389627, -- [82] Volatile Detonation
		113724, -- [83] Ring of Frost
		386763, -- [84] Freezing Cold
		205036, -- [85] Ice Ward
		382440, -- [86] Shifting Power
		30449, -- [87] Spellsteal
		56377, -- [88] Splitting Ice
	},
	-- Frost Mage
	[64] = {
		205021, -- [0] Ray of Frost
		378919, -- [1] Arctic Piercing
		205027, -- [2] Bone Chilling
		379993, -- [3] Flash Freeze
		236662, -- [4] Improved Blizzard
		385167, -- [5] Everlasting Frost
		381706, -- [6] Snowstorm
		12472, -- [7] Icy Veins
		378406, -- [8] Wintertide
		205024, -- [9] Lonely Winter
		31687, -- [10] Summon Water Elemental
		235219, -- [11] Cold Snap
		190356, -- [12] Blizzard
		30455, -- [13] Ice Lance
		84714, -- [14] Frozen Orb
		44614, -- [15] Flurry
		190447, -- [16] Brain Freeze
		257537, -- [17] Ebonbolt
		205030, -- [18] Frozen Touch
		378198, -- [19] Perpetual Winter
		378947, -- [20] Glacial Assault
		153595, -- [21] Comet Storm
		378448, -- [22] Fractured Frost
		382110, -- [23] Cold Front
		12982, -- [24] Shatter
		112965, -- [25] Fingers of Frost
		379049, -- [26] Ice Nine
		380154, -- [27] Frigid Shattering
		378749, -- [28] Deep Shatter
		381244, -- [29] Hailstones
		199786, -- [30] Glacial Spike
		155149, -- [31] Thermal Void
		278309, -- [32] Chain Reaction
		378433, -- [33] Icy Propulsion
		321702, -- [34] Improved Icy Veins
		378901, -- [35] Snap Freeze
		382103, -- [36] Freezing Winds
		382144, -- [37] Slick Ice
		270233, -- [38] Freezing Rain
		378756, -- [39] Frostbite
		387807, -- [40] Time Manipulation
		235224, -- [41] Frigid Winds
		382493, -- [42] Tome of Rhonin
		157997, -- [43] Ice Nova
		382569, -- [44] Reduplication
		382820, -- [45] Reabsorption
		55342, -- [46] Mirror Image
		382424, -- [47] Winter's Protection
		45438, -- [48] Ice Block
		390218, -- [49] Overflowing Energy [NYI]
		66, -- [50] Invisibility
		11426, -- [51] Ice Barrier
		475, -- [52] Remove Curse
		342245, -- [53] Alter Time
		383092, -- [54] Arcane Warding
		1463, -- [55] Incanter's Flow
		116011, -- [56] Rune of Power
		382293, -- [57] Incantation of Swiftness
		382289, -- [58] Tempest Barrier
		382481, -- [59] Rigid Ice
		391102, -- [60] Sloooow Down
		343183, -- [61] Improved Frost Nova
		382292, -- [62] Cryo-Freeze
		383121, -- [63] Mass Polymorph
		212653, -- [64] Shimmer
		108839, -- [65] Ice Floes
		382297, -- [66] Grounding Surge
		157981, -- [67] Blast Wave
		342249, -- [68] Master of Time
		382270, -- [69] Diverted Energy
		386828, -- [70] Energized Barriers
		382826, -- [71] Temporal Velocity
		382490, -- [72] Tome of Antonidas
		31589, -- [73] Slow
		382268, -- [74] Flow of Time
		110959, -- [75] Greater Invisibility
		383243, -- [76] Time Anomaly
		386539, -- [77] Temporal Warp
		382800, -- [78] Accumulative Shielding
		389713, -- [79] Reflection
		31661, -- [80] Dragon's Breath
		153561, -- [81] Meteor
		389627, -- [82] Volatile Detonation
		113724, -- [83] Ring of Frost
		386763, -- [84] Freezing Cold
		205036, -- [85] Ice Ward
		382440, -- [86] Shifting Power
		30449, -- [87] Spellsteal
		56377, -- [88] Splitting Ice
	},
	-- Holy Paladin
	[65] = {
		6940, -- [0] Blessing of Sacrifice
		385414, -- [1] Afterimage
		385416, -- [2] Aspirations of Divinity
		385125, -- [3] Of Dusk and Dawn
		385129, -- [4] Seal of Order
		385450, -- [5] Seal of Might [NYI]
		152262, -- [6] Seraphim
		171648, -- [7] Sanctified Wrath
		385425, -- [8] Seal of Alacrity
		223817, -- [9] Divine Purpose
		105809, -- [10] Holy Avenger
		384909, -- [11] Improved Blessing of Protection
		204018, -- [12] Blessing of Spellwarding
		385427, -- [13] Obduracy
		385728, -- [14] Seal of the Crusader
		391142, -- [15] The Mad Paragon
		190784, -- [16] Divine Steed
		376996, -- [17] Seasoned Warhorse
		377016, -- [18] Seal of the Templar
		384376, -- [19] Avenging Wrath
		1022, -- [20] Blessing of Protection
		385464, -- [21] Incandescence
		385349, -- [22] Touch of Light
		377043, -- [23] Hallowed Ground
		377053, -- [24] Seal of Reprisal
		10326, -- [25] Turn Evil
		231663, -- [26] Judgment
		96231, -- [27] Rebuke
		384897, -- [28] Seal of Mercy
		384815, -- [29] Seal of Clarity
		377128, -- [30] Golden Path
		213644, -- [31] Cleanse Toxins
		183778, -- [32] Judgment of Light
		114154, -- [33] Unbreakable Spirit
		384820, -- [34] Sacrifice of the Just
		384914, -- [35] Recompense
		392911, -- [36] Unwavering Spirit
		200430, -- [37] Protection of Tyr
		387805, -- [38] Scintillation
		325966, -- [39] Glimmer of Light
		375576, -- [40] Divine Toll
		387893, -- [41] Divine Resonance
		200652, -- [42] Tyr's Deliverance
		196926, -- [43] Crusader's Might
		231667, -- [44] Radiant Onslaught
		387791, -- [45] Empyreal Ward
		388007, -- [46] Blessing of Summer
		388018, -- [47] Maraad's Dying Breath
		387814, -- [48] Untempered Dedication
		183998, -- [49] Light of the Martyr
		387801, -- [50] Echoing Blessings
		156910, -- [51] Beacon of Faith
		200025, -- [52] Beacon of Virtue
		388005, -- [53] Shining Savior
		214202, -- [54] Rule of Law
		200482, -- [55] Second Sunrise
		200474, -- [56] Power of the Silver Hand
		387879, -- [57] Breaking Dawn
		384442, -- [58] Avenging Wrath: Might
		216331, -- [59] Avenging Crusader
		248033, -- [60] Awakening
		387808, -- [61] Divine Revelations
		31821, -- [62] Aura Mastery
		498, -- [63] Divine Protection
		231642, -- [64] Beacon of Light
		157047, -- [65] Saved by the Light
		387998, -- [66] Unending Light (NYI)
		223306, -- [67] Bestow Faith
		85222, -- [68] Light of Dawn
		82326, -- [69] Holy Light
		387993, -- [70] Illumination
		392914, -- [71] Divine Insight
		387781, -- [72] Focal Light
		114158, -- [73] Light's Hammer
		114165, -- [74] Holy Prism
		387786, -- [75] Moment of Compassion
		392902, -- [76] Resplendent Light
		20473, -- [77] Holy Shock
		148039, -- [78] Barrier of Faith
		385515, -- [79] Holy Aegis
		20066, -- [80] Repentance
		115750, -- [81] Blinding Light
		633, -- [82] Lay on Hands
		385633, -- [83] Auras of the Resolute
		1044, -- [84] Blessing of Freedom
		385639, -- [85] Auras of Swift Vengeance
		234299, -- [86] Fist of Justice
		24275, -- [87] Hammer of Wrath
		230332, -- [88] Cavalier
		392961, -- [89] Imbued Infusions
		392907, -- [90] Inflorescence of the Sunwell
		387170, -- [91] Empyrean Endowment
		392951, -- [92] Boundless Salvation
		392938, -- [93] Veneration
		210294, -- [94] Divine Favor
		383388, -- [95] Relentless Inquisitor
		392928, -- [96] Tirion's Devotion
	},
	-- Protection Paladin
	[66] = {
		6940, -- [0] Blessing of Sacrifice
		385414, -- [1] Afterimage
		385416, -- [2] Aspirations of Divinity
		385125, -- [3] Of Dusk and Dawn
		385129, -- [4] Seal of Order
		385450, -- [5] Seal of Might [NYI]
		152262, -- [6] Seraphim
		171648, -- [7] Sanctified Wrath
		385425, -- [8] Seal of Alacrity
		223817, -- [9] Divine Purpose
		105809, -- [10] Holy Avenger
		384909, -- [11] Improved Blessing of Protection
		204018, -- [12] Blessing of Spellwarding
		385427, -- [13] Obduracy
		385728, -- [14] Seal of the Crusader
		391142, -- [15] The Mad Paragon
		190784, -- [16] Divine Steed
		376996, -- [17] Seasoned Warhorse
		377016, -- [18] Seal of the Templar
		384376, -- [19] Avenging Wrath
		1022, -- [20] Blessing of Protection
		385464, -- [21] Incandescence
		385349, -- [22] Touch of Light
		377043, -- [23] Hallowed Ground
		377053, -- [24] Seal of Reprisal
		10326, -- [25] Turn Evil
		231663, -- [26] Judgment
		96231, -- [27] Rebuke
		384897, -- [28] Seal of Mercy
		384815, -- [29] Seal of Clarity
		377128, -- [30] Golden Path
		213644, -- [31] Cleanse Toxins
		183778, -- [32] Judgment of Light
		114154, -- [33] Unbreakable Spirit
		384820, -- [34] Sacrifice of the Just
		384914, -- [35] Recompense
		392911, -- [36] Unwavering Spirit
		200430, -- [37] Protection of Tyr
		387805, -- [38] Scintillation
		325966, -- [39] Glimmer of Light
		375576, -- [40] Divine Toll
		387893, -- [41] Divine Resonance
		200652, -- [42] Tyr's Deliverance
		196926, -- [43] Crusader's Might
		231667, -- [44] Radiant Onslaught
		387791, -- [45] Empyreal Ward
		388007, -- [46] Blessing of Summer
		388018, -- [47] Maraad's Dying Breath
		387814, -- [48] Untempered Dedication
		183998, -- [49] Light of the Martyr
		387801, -- [50] Echoing Blessings
		156910, -- [51] Beacon of Faith
		200025, -- [52] Beacon of Virtue
		388005, -- [53] Shining Savior
		214202, -- [54] Rule of Law
		200482, -- [55] Second Sunrise
		200474, -- [56] Power of the Silver Hand
		387879, -- [57] Breaking Dawn
		384442, -- [58] Avenging Wrath: Might
		216331, -- [59] Avenging Crusader
		248033, -- [60] Awakening
		387808, -- [61] Divine Revelations
		31821, -- [62] Aura Mastery
		498, -- [63] Divine Protection
		231642, -- [64] Beacon of Light
		157047, -- [65] Saved by the Light
		387998, -- [66] Unending Light (NYI)
		223306, -- [67] Bestow Faith
		85222, -- [68] Light of Dawn
		82326, -- [69] Holy Light
		387993, -- [70] Illumination
		392914, -- [71] Divine Insight
		387781, -- [72] Focal Light
		114158, -- [73] Light's Hammer
		114165, -- [74] Holy Prism
		387786, -- [75] Moment of Compassion
		392902, -- [76] Resplendent Light
		20473, -- [77] Holy Shock
		148039, -- [78] Barrier of Faith
		385515, -- [79] Holy Aegis
		20066, -- [80] Repentance
		115750, -- [81] Blinding Light
		633, -- [82] Lay on Hands
		385633, -- [83] Auras of the Resolute
		1044, -- [84] Blessing of Freedom
		385639, -- [85] Auras of Swift Vengeance
		234299, -- [86] Fist of Justice
		24275, -- [87] Hammer of Wrath
		230332, -- [88] Cavalier
		392961, -- [89] Imbued Infusions
		392907, -- [90] Inflorescence of the Sunwell
		387170, -- [91] Empyrean Endowment
		392951, -- [92] Boundless Salvation
		392938, -- [93] Veneration
		210294, -- [94] Divine Favor
		383388, -- [95] Relentless Inquisitor
		392928, -- [96] Tirion's Devotion
	},
	-- Retribution Paladin
	[70] = {
		383304, -- [0] Virtuous Command
		6940, -- [1] Blessing of Sacrifice
		385414, -- [2] Afterimage
		385416, -- [3] Aspirations of Divinity
		385125, -- [4] Of Dusk and Dawn
		385129, -- [5] Seal of Order
		385450, -- [6] Seal of Might [NYI]
		152262, -- [7] Seraphim
		171648, -- [8] Sanctified Wrath
		385425, -- [9] Seal of Alacrity
		223817, -- [10] Divine Purpose
		105809, -- [11] Holy Avenger
		384909, -- [12] Improved Blessing of Protection
		204018, -- [13] Blessing of Spellwarding
		385427, -- [14] Obduracy
		385728, -- [15] Seal of the Crusader
		391142, -- [16] The Mad Paragon
		190784, -- [17] Divine Steed
		376996, -- [18] Seasoned Warhorse
		377016, -- [19] Seal of the Templar
		384376, -- [20] Avenging Wrath
		1022, -- [21] Blessing of Protection
		385464, -- [22] Incandescence
		385349, -- [23] Touch of Light
		377043, -- [24] Hallowed Ground
		377053, -- [25] Seal of Reprisal
		10326, -- [26] Turn Evil
		231663, -- [27] Judgment
		96231, -- [28] Rebuke
		384897, -- [29] Seal of Mercy
		384815, -- [30] Seal of Clarity
		377128, -- [31] Golden Path
		213644, -- [32] Cleanse Toxins
		183778, -- [33] Judgment of Light
		114154, -- [34] Unbreakable Spirit
		384820, -- [35] Sacrifice of the Just
		384914, -- [36] Recompense
		383388, -- [37] Relentless Inquisitor
		343527, -- [38] Execution Sentence
		384162, -- [39] Executioner's Will
		387196, -- [40] Executioner's Wrath
		267344, -- [41] Art of War
		383342, -- [42] Holy Blade
		184662, -- [43] Shield of Vengeance
		498, -- [44] Divine Protection
		255937, -- [45] Wake of Ashes
		384442, -- [46] Avenging Wrath: Might
		384392, -- [47] Crusade
		85804, -- [48] Selfless Healer
		326734, -- [49] Healing Hands
		383276, -- [50] Ashes to Ashes
		385515, -- [51] Holy Aegis
		20066, -- [52] Repentance
		115750, -- [53] Blinding Light
		633, -- [54] Lay on Hands
		385633, -- [55] Auras of the Resolute
		343721, -- [56] Final Reckoning
		383274, -- [57] Templar's Vindication
		383327, -- [58] Final Verdict
		383314, -- [59] Vanguard's Momentum
		215661, -- [60] Justicar's Vengeance
		205191, -- [61] Eye for an Eye
		387640, -- [62] Sealed Verdict
		383344, -- [63] Expurgation
		326732, -- [64] Empyrean Power
		203316, -- [65] Fires of Justice
		383396, -- [66] Tempest of the Lightbringer
		386901, -- [67] Seal of Wrath
		231832, -- [68] Blade of Wrath
		382275, -- [69] Consecrated Blade
		383263, -- [70] Condemning Blade
		375576, -- [71] Divine Toll
		384027, -- [72] Divine Resonance
		387170, -- [73] Empyrean Endowment
		183218, -- [74] Hand of Hindrance
		382430, -- [75] Sanctification
		383334, -- [76] Inner Power
		204054, -- [77] Consecrated Ground
		387479, -- [78] Sanctified Ground
		383876, -- [79] Boundless Judgment
		383271, -- [80] Highlord's Judgment
		269569, -- [81] Zeal
		382536, -- [82] Calm Before the Storm
		267610, -- [83] Righteous Verdict
		383254, -- [84] Improved Crusader Strike
		53385, -- [85] Divine Storm
		386967, -- [86] Holy Crusader
		383228, -- [87] Timely Judgment
		184575, -- [88] Blade of Justice
		383185, -- [89] Exorcism
		383300, -- [90] Ashes to Dust
		384052, -- [91] Path of Ruin
		383350, -- [92] Truth's Wake
		1044, -- [93] Blessing of Freedom
		385639, -- [94] Auras of Swift Vengeance
		234299, -- [95] Fist of Justice
		24275, -- [96] Hammer of Wrath
		230332, -- [97] Cavalier
	},
	-- Arms Warrior
	[71] = {
		85288, -- [0] Raging Blow
		184364, -- [1] Enraged Regeneration
		208154, -- [2] Warpaint
		184367, -- [3] Rampage
		388004, -- [4] Slaughtering Strikes
		346002, -- [5] War Machine
		386196, -- [6] Berserker Stance
		382258, -- [7] Siphoning Strikes
		390354, -- [8] Furious Blows
		382767, -- [9] Overwhelming Rage
		391270, -- [10] Honed Reflexes
		384110, -- [11] Wrecking Throw
		64382, -- [12] Shattering Throw
		382764, -- [13] Crushing Force
		215571, -- [14] Frothing Berserker
		382310, -- [15] Inspiring Presence
		29838, -- [16] Second Wind
		202168, -- [17] Impending Victory
		382260, -- [18] Fast Footwork
		97462, -- [19] Rallying Cry
		386208, -- [20] Defensive Stance
		18499, -- [21] Berserker Rage
		23881, -- [22] Bloodthirst
		392931, -- [23] Cruelty
		392777, -- [24] Cruel Strikes
		392936, -- [25] Wrath and Fury
		392536, -- [26] Ashen Juggernaut
		206315, -- [27] Massacre
		383115, -- [28] Concussive Blows
		384404, -- [29] Sidearm
		275339, -- [30] Rumbling Earth
		390725, -- [31] Sonic Boom
		46968, -- [32] Shockwave
		382900, -- [33] Dual Wield Specialization
		390123, -- [34] Memory of a Tormented Berserker
		390135, -- [35] Memory of a Tormented Titan
		382939, -- [36] Reinforced Plates
		107574, -- [37] Avatar
		386285, -- [38] Elysian Might
		382948, -- [39] Piercing Verdict
		391572, -- [40] Uproar
		384969, -- [41] Thunderous Words
		384318, -- [42] Thunderous Roar
		382946, -- [43] Quick Thinking
		382549, -- [44] Pain and Gain
		390674, -- [45] Barbaric Training
		384090, -- [46] Titanic Throw
		382956, -- [47] Seismic Reverberation
		107570, -- [48] Storm Bolt
		376079, -- [49] Spear of Bastion
		383762, -- [50] Bitter Immunity
		382940, -- [51] Endurance Training
		384124, -- [52] Armored to the Teeth
		6544, -- [53] Heroic Leap
		202163, -- [54] Bounding Stride
		392383, -- [55] Wrenching Impact
		103827, -- [56] Double Time
		382954, -- [57] Cacophonous Roar
		275338, -- [58] Menace
		5246, -- [59] Intimidating Shout
		3411, -- [60] Intervene
		23920, -- [61] Spell Reflection
		384100, -- [62] Berserker Shout
		12323, -- [63] Piercing Howl
		6343, -- [64] Thunder Clap
		384277, -- [65] Blood and Thunder
		203201, -- [66] Crackling Thunder
		383468, -- [67] Invigorating Fury
		383922, -- [68] Depths of Insanity
		389603, -- [69] Unbridled Ferocity
		152278, -- [70] Anger Management
		202751, -- [71] Reckless Abandon
		383877, -- [72] Hack And Slash
		383916, -- [73] Annihilator
		388903, -- [74] Storm of Swords
		391683, -- [75] Dancing Blades
		390376, -- [76] Placeholder Talent
		385059, -- [77] Odyn's Fury
		383959, -- [78] Cold Steel, Hot Blood
		385703, -- [79] Bloodborne
		383295, -- [80] Deft Experience
		383605, -- [81] Frenzied Flurry
		81099, -- [82] Single-Minded Fury
		215568, -- [83] Fresh Meat
		383848, -- [84] Improved Enrage
		383852, -- [85] Improved Bloodthirst
		383486, -- [86] Focus In Chaos
		383885, -- [87] Vicious Contempt
		385735, -- [88] Bloodcraze
		335077, -- [89] Frenzy
		1719, -- [90] Recklessness
		383459, -- [91] Swift Strikes
		382953, -- [92] Storm of Steel
		390563, -- [93] Hurricane
		228920, -- [94] Ravager
		280392, -- [95] Meat Cleaver
		388049, -- [96] Raging Armaments
		383297, -- [97] Critical Thinking
		388933, -- [98] Pulverize
		315720, -- [99] Onslaught
		280721, -- [100] Sudden Death
		12950, -- [101] Improved Whirlwind
		316402, -- [102] Improved Execute
		383854, -- [103] Improved Raging Blow
	},
	-- Fury Warrior
	[72] = {
		382258, -- [0] Siphoning Strikes
		390354, -- [1] Furious Blows
		382767, -- [2] Overwhelming Rage
		390642, -- [3] Crushing Force
		384110, -- [4] Wrecking Throw
		64382, -- [5] Shattering Throw
		392790, -- [6] Frothing Berserker
		382310, -- [7] Inspiring Presence
		29838, -- [8] Second Wind
		202168, -- [9] Impending Victory
		382260, -- [10] Fast Footwork
		97462, -- [11] Rallying Cry
		386208, -- [12] Defensive Stance
		18499, -- [13] Berserker Rage
		316733, -- [14] War Machine
		236279, -- [15] Devastator
		202095, -- [16] Indomitable
		772, -- [17] Rend
		152278, -- [18] Anger Management
		386328, -- [19] Champion's Bulwark
		385952, -- [20] Shield Charge
		386477, -- [21] Outburst
		384063, -- [22] Enduring Alacrity
		385843, -- [23] Show of Force
		386034, -- [24] Improved Heroic Throw
		386071, -- [25] Disrupting Shout
		203177, -- [26] Heavy Repercussions
		202603, -- [27] Into the Fray
		385840, -- [28] Thunderlord
		1161, -- [29] Challenging Shout
		202743, -- [30] Booming Voice
		1160, -- [31] Demoralizing Shout
		202560, -- [32] Best Served Cold
		382953, -- [33] Storm of Steel
		228920, -- [34] Ravager
		384074, -- [35] Unbreakable Will
		384072, -- [36] The Wall
		384067, -- [37] Focused Vigor
		280001, -- [38] Bolster
		385704, -- [39] Bloodborne
		275334, -- [40] Punish
		383292, -- [41] Juggernaut
		385888, -- [42] Spiked Shield
		383103, -- [43] Fueled by Violence
		384036, -- [44] Brutal Vitality
		386030, -- [45] Brace For Impact
		12975, -- [46] Last Stand
		384042, -- [47] Unnerving Focus
		190456, -- [48] Ignore Pain
		6572, -- [49] Revenge
		384041, -- [50] Strategist
		384361, -- [51] Bloodsurge
		871, -- [52] Shield Wall
		386027, -- [53] Enduring Defenses
		281001, -- [54] Massacre
		386011, -- [55] Shield Specialization
		392966, -- [56] Spell Block
		386394, -- [57] Battle-Scarred Veteran
		391271, -- [58] Honed Reflexes
		392777, -- [59] Cruel Strikes
		29725, -- [60] Sudden Death
		383115, -- [61] Concussive Blows
		384404, -- [62] Sidearm
		386164, -- [63] Battle Stance
		275339, -- [64] Rumbling Earth
		390725, -- [65] Sonic Boom
		46968, -- [66] Shockwave
		382949, -- [67] Signet of Tormented Kings
		275336, -- [68] Unstoppable Force
		382939, -- [69] Reinforced Plates
		107574, -- [70] Avatar
		386285, -- [71] Elysian Might
		382948, -- [72] Piercing Verdict
		391572, -- [73] Uproar
		384969, -- [74] Thunderous Words
		384318, -- [75] Thunderous Roar
		382946, -- [76] Quick Thinking
		390675, -- [77] Barbaric Training
		384090, -- [78] Titanic Throw
		382549, -- [79] Pain and Gain
		382956, -- [80] Seismic Reverberation
		107570, -- [81] Storm Bolt
		376079, -- [82] Spear of Bastion
		382895, -- [83] One-Handed Weapon Specialization
		383762, -- [84] Bitter Immunity
		382940, -- [85] Endurance Training
		384124, -- [86] Armored to the Teeth
		6544, -- [87] Heroic Leap
		202163, -- [88] Bounding Stride
		392383, -- [89] Wrenching Impact
		103827, -- [90] Double Time
		382954, -- [91] Cacophonous Roar
		275338, -- [92] Menace
		5246, -- [93] Intimidating Shout
		3411, -- [94] Intervene
		23920, -- [95] Spell Reflection
		384100, -- [96] Berserker Shout
		12323, -- [97] Piercing Howl
		6343, -- [98] Thunder Clap
		384277, -- [99] Blood and Thunder
		203201, -- [100] Crackling Thunder
	},
	-- Protection Warrior
	[73] = {
		382258, -- [0] Siphoning Strikes
		390354, -- [1] Furious Blows
		382767, -- [2] Overwhelming Rage
		390642, -- [3] Crushing Force
		384110, -- [4] Wrecking Throw
		64382, -- [5] Shattering Throw
		392790, -- [6] Frothing Berserker
		382310, -- [7] Inspiring Presence
		29838, -- [8] Second Wind
		202168, -- [9] Impending Victory
		382260, -- [10] Fast Footwork
		97462, -- [11] Rallying Cry
		386208, -- [12] Defensive Stance
		18499, -- [13] Berserker Rage
		316733, -- [14] War Machine
		236279, -- [15] Devastator
		202095, -- [16] Indomitable
		772, -- [17] Rend
		152278, -- [18] Anger Management
		386328, -- [19] Champion's Bulwark
		385952, -- [20] Shield Charge
		386477, -- [21] Outburst
		384063, -- [22] Enduring Alacrity
		385843, -- [23] Show of Force
		386034, -- [24] Improved Heroic Throw
		386071, -- [25] Disrupting Shout
		203177, -- [26] Heavy Repercussions
		202603, -- [27] Into the Fray
		385840, -- [28] Thunderlord
		1161, -- [29] Challenging Shout
		202743, -- [30] Booming Voice
		1160, -- [31] Demoralizing Shout
		202560, -- [32] Best Served Cold
		382953, -- [33] Storm of Steel
		228920, -- [34] Ravager
		384074, -- [35] Unbreakable Will
		384072, -- [36] The Wall
		384067, -- [37] Focused Vigor
		280001, -- [38] Bolster
		385704, -- [39] Bloodborne
		275334, -- [40] Punish
		383292, -- [41] Juggernaut
		385888, -- [42] Spiked Shield
		383103, -- [43] Fueled by Violence
		384036, -- [44] Brutal Vitality
		386030, -- [45] Brace For Impact
		12975, -- [46] Last Stand
		384042, -- [47] Unnerving Focus
		190456, -- [48] Ignore Pain
		6572, -- [49] Revenge
		384041, -- [50] Strategist
		384361, -- [51] Bloodsurge
		871, -- [52] Shield Wall
		386027, -- [53] Enduring Defenses
		281001, -- [54] Massacre
		386011, -- [55] Shield Specialization
		392966, -- [56] Spell Block
		386394, -- [57] Battle-Scarred Veteran
		391271, -- [58] Honed Reflexes
		392777, -- [59] Cruel Strikes
		29725, -- [60] Sudden Death
		383115, -- [61] Concussive Blows
		384404, -- [62] Sidearm
		386164, -- [63] Battle Stance
		275339, -- [64] Rumbling Earth
		390725, -- [65] Sonic Boom
		46968, -- [66] Shockwave
		382949, -- [67] Signet of Tormented Kings
		275336, -- [68] Unstoppable Force
		382939, -- [69] Reinforced Plates
		107574, -- [70] Avatar
		386285, -- [71] Elysian Might
		382948, -- [72] Piercing Verdict
		391572, -- [73] Uproar
		384969, -- [74] Thunderous Words
		384318, -- [75] Thunderous Roar
		382946, -- [76] Quick Thinking
		390675, -- [77] Barbaric Training
		384090, -- [78] Titanic Throw
		382549, -- [79] Pain and Gain
		382956, -- [80] Seismic Reverberation
		107570, -- [81] Storm Bolt
		376079, -- [82] Spear of Bastion
		382895, -- [83] One-Handed Weapon Specialization
		383762, -- [84] Bitter Immunity
		382940, -- [85] Endurance Training
		384124, -- [86] Armored to the Teeth
		6544, -- [87] Heroic Leap
		202163, -- [88] Bounding Stride
		392383, -- [89] Wrenching Impact
		103827, -- [90] Double Time
		382954, -- [91] Cacophonous Roar
		275338, -- [92] Menace
		5246, -- [93] Intimidating Shout
		3411, -- [94] Intervene
		23920, -- [95] Spell Reflection
		384100, -- [96] Berserker Shout
		12323, -- [97] Piercing Howl
		6343, -- [98] Thunder Clap
		384277, -- [99] Blood and Thunder
		203201, -- [100] Crackling Thunder
	},
	-- Balance Druid
	[102] = {
		274281, -- [0] New Moon
		202770, -- [1] Fury of Elune
		383196, -- [2] Umbral Infusion [NNF]
		114107, -- [3] Soul of the Forest
		102560, -- [4] Incarnation: Chosen of Elune
		323764, -- [5] Convoke the Spirits
		384656, -- [6] Fury of the Skies
		383194, -- [7] Stellar Inspiration
		328022, -- [8] Improved Starsurge
		327541, -- [9] Starfall
		202354, -- [10] Stellar Drift
		202737, -- [11] Blessing of Elune
		202739, -- [12] Blessing of An'she
		338661, -- [13] Oneth's Clear Vision
		339949, -- [14] Timeworn Dreambinder
		325727, -- [15] Adaptive Swarm
		339942, -- [16] Balance of All Things
		383197, -- [17] Orbit Breaker
		390378, -- [18] Syzygy
		338668, -- [19] Primordial Arcanic Pulsar
		202342, -- [20] Shooting Stars
		202345, -- [21] Starlord
		340706, -- [22] Precise Alignment
		343647, -- [23] Solstice
		338657, -- [24] Circle of Life and Death
		231042, -- [25] Owlkin Frenzy
		202430, -- [26] Nature's Balance
		191034, -- [27] Starfall
		205636, -- [28] Force of Nature
		328021, -- [29] Improved Eclipse
		79577, -- [30] Eclipse
		202425, -- [31] Warrior of Elune
		194223, -- [32] Celestial Alignment
		78675, -- [33] Solar Beam
		202996, -- [34] Power of Goldrinn
		383195, -- [35] Umbral Intensity
		279620, -- [36] Twin Moons
		202347, -- [37] Stellar Flare
		328023, -- [38] Improved Moonfire
		2782, -- [39] Remove Corruption
		202918, -- [40] Light of the Sun
		301768, -- [41] Improved Frenzied Regeneration (NNF)
		2637, -- [42] Hibernate
		33786, -- [43] Cyclone
		377801, -- [44] Tireless Pursuit
		22570, -- [45] Maim
		1822, -- [46] Rake
		231050, -- [47] Improved Sunfire
		378986, -- [48] Furor
		377842, -- [49] Ursine Vigor
		108238, -- [50] Renewal
		319454, -- [51] Heart of the Wild
		288826, -- [52] Improved Stampeding Roar
		378988, -- [53] Lycara's Teachings
		106898, -- [54] Stampeding Roar
		102401, -- [55] Wild Charge
		252216, -- [56] Tiger Dash
		2908, -- [57] Soothe
		106839, -- [58] Skull Bash
		108299, -- [59] Killer Instinct
		213764, -- [60] Swipe
		192081, -- [61] Ironfur
		16931, -- [62] Thick Hide
		385786, -- [63] Ursoc's Endurance
		159286, -- [64] Primal Fury
		99, -- [65] Incapacitating Roar
		5211, -- [66] Mighty Bash
		377847, -- [67] Well-Honed Instincts
		231040, -- [68] Improved Rejuvenation
		48438, -- [69] Wild Growth
		377796, -- [70] New Resto Passive (NNF)
		132469, -- [71] Typhoon
		197524, -- [72] Astral Influence
		93402, -- [73] Sunfire
		102359, -- [74] Mass Entanglement
		102793, -- [75] Ursol's Vortex
		29166, -- [76] Innervate
		124974, -- [77] Nature's Vigil
		194153, -- [78] Starfire
		78674, -- [79] Starsurge
		24858, -- [80] Moonkin Form
		33873, -- [81] Nurturing Instinct
		18562, -- [82] Swiftmend
		774, -- [83] Rejuvenation
		327993, -- [84] Improved Barkskin
		22842, -- [85] Frenzied Regeneration
		106832, -- [86] Thrash
		1079, -- [87] Rip
		131768, -- [88] Feline Swiftness
	},
	-- Feral Druid
	[103] = {
		274281, -- [0] New Moon
		202770, -- [1] Fury of Elune
		383196, -- [2] Umbral Infusion [NNF]
		114107, -- [3] Soul of the Forest
		102560, -- [4] Incarnation: Chosen of Elune
		323764, -- [5] Convoke the Spirits
		384656, -- [6] Fury of the Skies
		383194, -- [7] Stellar Inspiration
		328022, -- [8] Improved Starsurge
		327541, -- [9] Starfall
		202354, -- [10] Stellar Drift
		202737, -- [11] Blessing of Elune
		202739, -- [12] Blessing of An'she
		338661, -- [13] Oneth's Clear Vision
		339949, -- [14] Timeworn Dreambinder
		325727, -- [15] Adaptive Swarm
		339942, -- [16] Balance of All Things
		383197, -- [17] Orbit Breaker
		390378, -- [18] Syzygy
		338668, -- [19] Primordial Arcanic Pulsar
		202342, -- [20] Shooting Stars
		202345, -- [21] Starlord
		340706, -- [22] Precise Alignment
		343647, -- [23] Solstice
		338657, -- [24] Circle of Life and Death
		231042, -- [25] Owlkin Frenzy
		202430, -- [26] Nature's Balance
		191034, -- [27] Starfall
		205636, -- [28] Force of Nature
		328021, -- [29] Improved Eclipse
		79577, -- [30] Eclipse
		202425, -- [31] Warrior of Elune
		194223, -- [32] Celestial Alignment
		78675, -- [33] Solar Beam
		202996, -- [34] Power of Goldrinn
		383195, -- [35] Umbral Intensity
		279620, -- [36] Twin Moons
		202347, -- [37] Stellar Flare
		328023, -- [38] Improved Moonfire
		2782, -- [39] Remove Corruption
		202918, -- [40] Light of the Sun
		301768, -- [41] Improved Frenzied Regeneration (NNF)
		2637, -- [42] Hibernate
		33786, -- [43] Cyclone
		377801, -- [44] Tireless Pursuit
		22570, -- [45] Maim
		1822, -- [46] Rake
		231050, -- [47] Improved Sunfire
		378986, -- [48] Furor
		377842, -- [49] Ursine Vigor
		108238, -- [50] Renewal
		319454, -- [51] Heart of the Wild
		288826, -- [52] Improved Stampeding Roar
		378988, -- [53] Lycara's Teachings
		106898, -- [54] Stampeding Roar
		102401, -- [55] Wild Charge
		252216, -- [56] Tiger Dash
		2908, -- [57] Soothe
		106839, -- [58] Skull Bash
		108299, -- [59] Killer Instinct
		213764, -- [60] Swipe
		192081, -- [61] Ironfur
		16931, -- [62] Thick Hide
		385786, -- [63] Ursoc's Endurance
		159286, -- [64] Primal Fury
		99, -- [65] Incapacitating Roar
		5211, -- [66] Mighty Bash
		377847, -- [67] Well-Honed Instincts
		231040, -- [68] Improved Rejuvenation
		48438, -- [69] Wild Growth
		377796, -- [70] New Resto Passive (NNF)
		132469, -- [71] Typhoon
		197524, -- [72] Astral Influence
		93402, -- [73] Sunfire
		102359, -- [74] Mass Entanglement
		102793, -- [75] Ursol's Vortex
		29166, -- [76] Innervate
		124974, -- [77] Nature's Vigil
		194153, -- [78] Starfire
		78674, -- [79] Starsurge
		24858, -- [80] Moonkin Form
		33873, -- [81] Nurturing Instinct
		18562, -- [82] Swiftmend
		774, -- [83] Rejuvenation
		327993, -- [84] Improved Barkskin
		22842, -- [85] Frenzied Regeneration
		106832, -- [86] Thrash
		1079, -- [87] Rip
		131768, -- [88] Feline Swiftness
	},
	-- Guardian Druid
	[104] = {
		391548, -- [0] Ashamane's Guidance
		102543, -- [1] Incarnation: Avatar of Ashamane
		391528, -- [2] Convoke the Spirits
		391969, -- [3] Circle of Life and Death
		158476, -- [4] Soul of the Forest
		61336, -- [5] Survival Instincts
		391872, -- [6] Eye of Fearful Symmetry
		391888, -- [7] Adaptive Swarm
		391951, -- [8] Unbridled Swarm
		391972, -- [9] Bite Force
		319439, -- [10] Bloodtalons
		285564, -- [11] Scent of Blood
		391700, -- [12] Double-Clawed Rake
		384665, -- [13] Taste for Blood
		48484, -- [14] Infected Wounds
		391174, -- [15] Berserk: Heart of the Lion
		390902, -- [16] Carnivorous Instinct
		391078, -- [17] Raging Fury
		391875, -- [18] Frantic Momentum
		16974, -- [19] Predatory Swiftness
		391045, -- [20] Dreadful Bleeding
		202031, -- [21] Sabertooth
		384667, -- [22] Sudden Ambush
		383352, -- [23] Tireless Energy
		231063, -- [24] Improved Bleeds
		16864, -- [25] Omen of Clarity
		5217, -- [26] Tiger's Fury
		285381, -- [27] Primal Wrath
		202021, -- [28] Predator
		391785, -- [29] Tear Open Wounds
		391709, -- [30] Ferocious Frenzy
		202028, -- [31] Brutal Slash
		390864, -- [32] Wild Slashes
		386318, -- [33] Cat's Curiosity
		391978, -- [34] Veinripper
		391347, -- [35] Rip and Tear
		2782, -- [36] Remove Corruption
		301768, -- [37] Improved Frenzied Regeneration (NNF)
		2637, -- [38] Hibernate
		33786, -- [39] Cyclone
		377801, -- [40] Tireless Pursuit
		22570, -- [41] Maim
		1822, -- [42] Rake
		231050, -- [43] Improved Sunfire
		378986, -- [44] Furor
		377842, -- [45] Ursine Vigor
		108238, -- [46] Renewal
		319454, -- [47] Heart of the Wild
		288826, -- [48] Improved Stampeding Roar
		378988, -- [49] Lycara's Teachings
		106898, -- [50] Stampeding Roar
		102401, -- [51] Wild Charge
		252216, -- [52] Tiger Dash
		2908, -- [53] Soothe
		106839, -- [54] Skull Bash
		108299, -- [55] Killer Instinct
		213764, -- [56] Swipe
		192081, -- [57] Ironfur
		16931, -- [58] Thick Hide
		385786, -- [59] Ursoc's Endurance
		159286, -- [60] Primal Fury
		99, -- [61] Incapacitating Roar
		5211, -- [62] Mighty Bash
		377847, -- [63] Well-Honed Instincts
		231040, -- [64] Improved Rejuvenation
		48438, -- [65] Wild Growth
		377796, -- [66] New Resto Passive (NNF)
		132469, -- [67] Typhoon
		197524, -- [68] Astral Influence
		93402, -- [69] Sunfire
		102359, -- [70] Mass Entanglement
		102793, -- [71] Ursol's Vortex
		29166, -- [72] Innervate
		124974, -- [73] Nature's Vigil
		197626, -- [74] Starsurge
		194153, -- [75] Starfire
		24858, -- [76] Moonkin Form
		33873, -- [77] Nurturing Instinct
		18562, -- [78] Swiftmend
		774, -- [79] Rejuvenation
		327993, -- [80] Improved Barkskin
		22842, -- [81] Frenzied Regeneration
		106832, -- [82] Thrash
		1079, -- [83] Rip
		131768, -- [84] Feline Swiftness
		391881, -- [85] Apex Predator's Craving
		391947, -- [86] Protective Growth
		384668, -- [87] Berserk: Frenzy
		391037, -- [88] Piercing Claws
		390772, -- [89] Pouncing Strikes
		274837, -- [90] Feral Frenzy
		155580, -- [91] Lunar Inspiration
		343223, -- [92] Berserk
		236068, -- [93] Moment of Clarity
	},
	-- Restoration Druid
	[105] = {
		392378, -- [0] Improved Nature's Cure
		158478, -- [1] Soul of the Forest
		391969, -- [2] Circle of Life and Death
		392116, -- [3] Regenerative Heartwood
		740, -- [4] Tranquility
		33891, -- [5] Incarnation: Tree of Life
		391528, -- [6] Convoke the Spirits
		392325, -- [7] Verdancy
		197061, -- [8] Stonebark
		382552, -- [9] Improved Ironbark
		391888, -- [10] Adaptive Swarm
		102342, -- [11] Ironbark
		328025, -- [12] Improved Wild Growth
		326228, -- [13] Improved Innervate
		33763, -- [14] Lifebloom
		50464, -- [15] Nourish
		383191, -- [16] Deep Roots
		382559, -- [17] Unstoppable Growth
		132158, -- [18] Nature's Swiftness
		392356, -- [19] Reforestation
		155675, -- [20] Germination
		200390, -- [21] Cultivation
		207385, -- [22] Spring Blossoms
		203651, -- [23] Overgrowth
		392256, -- [24] Improved Lifebloom
		392221, -- [25] Waking Dream
		231032, -- [26] Improved Regrowth
		145205, -- [27] Efflorescence
		392124, -- [28] Embrace of the Dream
		207383, -- [29] Abundance
		102351, -- [30] Cenarion Ward
		278515, -- [31] Rampant Growth
		197073, -- [32] Inner Peace
		392162, -- [33] Dreamstate
		392410, -- [34] Verdant Infusion
		197721, -- [35] Flourish
		392315, -- [36] Unending Growth
		391951, -- [37] Unbridled Swarm
		392302, -- [38] Power of the Archdruid
		392160, -- [39] Invigorate
		392167, -- [40] Budding Leaves
		279778, -- [41] Grove Tending
		145108, -- [42] Ysera's Gift
		392099, -- [43] Nurturing Dormancy
		113043, -- [44] Omen of Clarity
		392301, -- [45] Undergrowth
		392220, -- [46] Flash of Clarity
		274902, -- [47] Photosynthesis
		392288, -- [48] Nature's Splendor
		382550, -- [49] Ready For Anything
		301768, -- [50] Improved Frenzied Regeneration (NNF)
		2637, -- [51] Hibernate
		33786, -- [52] Cyclone
		377801, -- [53] Tireless Pursuit
		22570, -- [54] Maim
		1822, -- [55] Rake
		231050, -- [56] Improved Sunfire
		378986, -- [57] Furor
		377842, -- [58] Ursine Vigor
		108238, -- [59] Renewal
		319454, -- [60] Heart of the Wild
		288826, -- [61] Improved Stampeding Roar
		378988, -- [62] Lycara's Teachings
		106898, -- [63] Stampeding Roar
		102401, -- [64] Wild Charge
		252216, -- [65] Tiger Dash
		2908, -- [66] Soothe
		106839, -- [67] Skull Bash
		108299, -- [68] Killer Instinct
		213764, -- [69] Swipe
		192081, -- [70] Ironfur
		16931, -- [71] Thick Hide
		385786, -- [72] Ursoc's Endurance
		159286, -- [73] Primal Fury
		99, -- [74] Incapacitating Roar
		5211, -- [75] Mighty Bash
		377847, -- [76] Well-Honed Instincts
		231040, -- [77] Improved Rejuvenation
		48438, -- [78] Wild Growth
		377796, -- [79] New Resto Passive (NNF)
		132469, -- [80] Typhoon
		197524, -- [81] Astral Influence
		93402, -- [82] Sunfire
		102359, -- [83] Mass Entanglement
		102793, -- [84] Ursol's Vortex
		29166, -- [85] Innervate
		124974, -- [86] Nature's Vigil
		197626, -- [87] Starsurge
		194153, -- [88] Starfire
		24858, -- [89] Moonkin Form
		33873, -- [90] Nurturing Instinct
		18562, -- [91] Swiftmend
		774, -- [92] Rejuvenation
		327993, -- [93] Improved Barkskin
		22842, -- [94] Frenzied Regeneration
		106832, -- [95] Thrash
		1079, -- [96] Rip
		131768, -- [97] Feline Swiftness
	},
	-- Blood Death Knight
	[250] = {
		195679, -- [0] Bloodworms
		55233, -- [1] Vampiric Blood
		391395, -- [2] Iron Heart
		81136, -- [3] Crimson Scourge
		50842, -- [4] Blood Boil
		206930, -- [5] Heart Strike
		195182, -- [6] Marrowrend
		206974, -- [7] Foul Bulwark
		377629, -- [8] Leeching Strike
		374737, -- [9] Reinforced Bones
		317610, -- [10] Relish in Blood
		195292, -- [11] Death's Caress
		194679, -- [12] Rune Tap
		219786, -- [13] Ossuary
		206931, -- [14] Blooddrinker
		274156, -- [15] Consumption
		221699, -- [16] Blood Tap
		194662, -- [17] Rapid Decomposition
		317133, -- [18] Improved Vampiric Blood
		206940, -- [19] Mark of Blood
		219809, -- [20] Tombstone
		49028, -- [21] Dancing Rune Weapon
		273946, -- [22] Hemostasis
		108199, -- [23] Gorefiend's Grasp
		221536, -- [24] Heartbreaker
		206970, -- [25] Tightening Grasp
		114556, -- [26] Purgatory
		205723, -- [27] Red Thirst
		377655, -- [28] Heartrend
		377668, -- [29] Everlasting Bond
		377637, -- [30] Insatiable Blade
		377640, -- [31] Shattering Bone
		194844, -- [32] Bonestorm
		374717, -- [33] Improved Heart Strike
		391398, -- [34] Bloodshot
		374747, -- [35] Perseverance of the Ebon Blade
		391477, -- [36] Coagulopathy
		391386, -- [37] Blood Feast
		391517, -- [38] Umbilicus Eternus
		391458, -- [39] Sanguine Ground
		374715, -- [40] Improved Boneshield
		273953, -- [41] Voracious
		207167, -- [42] Blinding Sleet
		378848, -- [43] Anticipation
		205727, -- [44] Anti-Magic Barrier
		373926, -- [45] Acclimation
		374383, -- [46] Assimilation
		383269, -- [47] Abomination Limb
		47568, -- [48] Empower Rune Weapon
		194878, -- [49] Icy Talons
		391571, -- [50] Gloom Ward
		343294, -- [51] Soul Reaper
		206967, -- [52] Will of the Necropolis
		374261, -- [53] Unholy Bond
		356367, -- [54] Death's Echo
		276079, -- [55] Death's Reach
		273952, -- [56] Grip of the Dead
		374265, -- [57] Unholy Ground
		111673, -- [58] Control Undead
		392566, -- [59] Enfeeble
		374504, -- [60] Brittle
		389679, -- [61] Clenching Grasp
		389682, -- [62] Unholy Endurance
		221562, -- [63] Asphyxiate
		51052, -- [64] Anti-Magic Zone
		374030, -- [65] Blood Scent
		374277, -- [66] Improved Death Strike
		48263, -- [67] Veteran of the Third War
		391546, -- [68] March of Darkness
		48707, -- [69] Anti-Magic Shell
		49998, -- [70] Death Strike
		46585, -- [71] Raise Dead
		316916, -- [72] Cleaving Strikes
		327574, -- [73] Sacrificial Pact
		374049, -- [74] Suppression
		374111, -- [75] Might of Thassarian
		48743, -- [76] Death Pact
		212552, -- [77] Wraith Walk
		374598, -- [78] Blood Draw
		374574, -- [79] Rune Mastery
		45524, -- [80] Chains of Ice
		47528, -- [81] Mind Freeze
		207200, -- [82] Permafrost
		48792, -- [83] Icebound Fortitude
		373923, -- [84] Merciless Strikes
		373930, -- [85] Proliferating Chill
		207104, -- [86] Runic Attenuation
		391566, -- [87] Insidious Chill
	},
	-- Frost Death Knight
	[251] = {
		195679, -- [0] Bloodworms
		55233, -- [1] Vampiric Blood
		391395, -- [2] Iron Heart
		81136, -- [3] Crimson Scourge
		50842, -- [4] Blood Boil
		206930, -- [5] Heart Strike
		195182, -- [6] Marrowrend
		206974, -- [7] Foul Bulwark
		377629, -- [8] Leeching Strike
		374737, -- [9] Reinforced Bones
		317610, -- [10] Relish in Blood
		195292, -- [11] Death's Caress
		194679, -- [12] Rune Tap
		219786, -- [13] Ossuary
		206931, -- [14] Blooddrinker
		274156, -- [15] Consumption
		221699, -- [16] Blood Tap
		194662, -- [17] Rapid Decomposition
		317133, -- [18] Improved Vampiric Blood
		206940, -- [19] Mark of Blood
		219809, -- [20] Tombstone
		49028, -- [21] Dancing Rune Weapon
		273946, -- [22] Hemostasis
		108199, -- [23] Gorefiend's Grasp
		221536, -- [24] Heartbreaker
		206970, -- [25] Tightening Grasp
		114556, -- [26] Purgatory
		205723, -- [27] Red Thirst
		377655, -- [28] Heartrend
		377668, -- [29] Everlasting Bond
		377637, -- [30] Insatiable Blade
		377640, -- [31] Shattering Bone
		194844, -- [32] Bonestorm
		374717, -- [33] Improved Heart Strike
		391398, -- [34] Bloodshot
		374747, -- [35] Perseverance of the Ebon Blade
		391477, -- [36] Coagulopathy
		391386, -- [37] Blood Feast
		391517, -- [38] Umbilicus Eternus
		391458, -- [39] Sanguine Ground
		374715, -- [40] Improved Boneshield
		273953, -- [41] Voracious
		207167, -- [42] Blinding Sleet
		378848, -- [43] Anticipation
		205727, -- [44] Anti-Magic Barrier
		373926, -- [45] Acclimation
		374383, -- [46] Assimilation
		383269, -- [47] Abomination Limb
		47568, -- [48] Empower Rune Weapon
		194878, -- [49] Icy Talons
		391571, -- [50] Gloom Ward
		343294, -- [51] Soul Reaper
		206967, -- [52] Will of the Necropolis
		374261, -- [53] Unholy Bond
		356367, -- [54] Death's Echo
		276079, -- [55] Death's Reach
		273952, -- [56] Grip of the Dead
		374265, -- [57] Unholy Ground
		111673, -- [58] Control Undead
		392566, -- [59] Enfeeble
		374504, -- [60] Brittle
		389679, -- [61] Clenching Grasp
		389682, -- [62] Unholy Endurance
		221562, -- [63] Asphyxiate
		51052, -- [64] Anti-Magic Zone
		374030, -- [65] Blood Scent
		374277, -- [66] Improved Death Strike
		48263, -- [67] Veteran of the Third War
		391546, -- [68] March of Darkness
		48707, -- [69] Anti-Magic Shell
		49998, -- [70] Death Strike
		46585, -- [71] Raise Dead
		316916, -- [72] Cleaving Strikes
		327574, -- [73] Sacrificial Pact
		374049, -- [74] Suppression
		374111, -- [75] Might of Thassarian
		48743, -- [76] Death Pact
		212552, -- [77] Wraith Walk
		374598, -- [78] Blood Draw
		374574, -- [79] Rune Mastery
		45524, -- [80] Chains of Ice
		47528, -- [81] Mind Freeze
		207200, -- [82] Permafrost
		48792, -- [83] Icebound Fortitude
		373923, -- [84] Merciless Strikes
		373930, -- [85] Proliferating Chill
		207104, -- [86] Runic Attenuation
		391566, -- [87] Insidious Chill
	},
	-- Unholy Death Knight
	[252] = {
		207126, -- [0] Icecap
		377083, -- [1] Cold-Blooded Rage
		377098, -- [2] Bonegrinder
		207061, -- [3] Murderous Efficiency
		377073, -- [4] Frigid Executioner
		377076, -- [5] Rage of the Frozen Champion
		317198, -- [6] Improved Obliterate
		376905, -- [7] Unleashed Frenzy
		392950, -- [8] Icebreaker
		51128, -- [9] Killing Machine
		49020, -- [10] Obliterate
		49143, -- [11] Frost Strike
		253593, -- [12] Inexorable Assault
		207167, -- [13] Blinding Sleet
		378848, -- [14] Anticipation
		205727, -- [15] Anti-Magic Barrier
		373926, -- [16] Acclimation
		374383, -- [17] Assimilation
		383269, -- [18] Abomination Limb
		47568, -- [19] Empower Rune Weapon
		194878, -- [20] Icy Talons
		391571, -- [21] Gloom Ward
		343294, -- [22] Soul Reaper
		206967, -- [23] Will of the Necropolis
		374261, -- [24] Unholy Bond
		356367, -- [25] Death's Echo
		276079, -- [26] Death's Reach
		273952, -- [27] Grip of the Dead
		374265, -- [28] Unholy Ground
		111673, -- [29] Control Undead
		392566, -- [30] Enfeeble
		374504, -- [31] Brittle
		389679, -- [32] Clenching Grasp
		389682, -- [33] Unholy Endurance
		221562, -- [34] Asphyxiate
		51052, -- [35] Anti-Magic Zone
		374030, -- [36] Blood Scent
		374277, -- [37] Improved Death Strike
		48263, -- [38] Veteran of the Third War
		391546, -- [39] March of Darkness
		48707, -- [40] Anti-Magic Shell
		49998, -- [41] Death Strike
		46585, -- [42] Raise Dead
		316916, -- [43] Cleaving Strikes
		327574, -- [44] Sacrificial Pact
		374049, -- [45] Suppression
		374111, -- [46] Might of Thassarian
		48743, -- [47] Death Pact
		212552, -- [48] Wraith Walk
		374598, -- [49] Blood Draw
		374574, -- [50] Rune Mastery
		45524, -- [51] Chains of Ice
		47528, -- [52] Mind Freeze
		207200, -- [53] Permafrost
		48792, -- [54] Icebound Fortitude
		373923, -- [55] Merciless Strikes
		373930, -- [56] Proliferating Chill
		207104, -- [57] Runic Attenuation
		391566, -- [58] Insidious Chill
		317214, -- [59] Frostreaper
		81333, -- [60] Might of the Frozen Wastes
		281238, -- [61] Obliteration
		194913, -- [62] Glacial Advance
		152279, -- [63] Breath of Sindragosa
		377047, -- [64] Absolute Zero
		279302, -- [65] Frostwyrm's Fury
		207230, -- [66] Frostscythe
		377351, -- [67] Piercing Chill
		377376, -- [68] Enduring Chill
		305392, -- [69] Chill Streak
		47568, -- [70] Empower Rune Weapon
		377190, -- [71] Enduring Strength
		207057, -- [72] Shattering Strike
		376251, -- [73] Runic Command
		316803, -- [74] Improved Frost Strike
		51271, -- [75] Pillar of Frost
		207142, -- [76] Avalanche
		377226, -- [77] Frostwhelp's Aid
		376938, -- [78] Everfrost
		377092, -- [79] Invigorating Freeze
		194912, -- [80] Gathering Storm
		281208, -- [81] Cold Heart
		316838, -- [82] Improved Rime
		196770, -- [83] Remorseless Winter
		59057, -- [84] Rime
		49184, -- [85] Howling Blast
		377056, -- [86] Biting Cold
		57330, -- [87] Horn of Winter
	},
	-- Beast Mastery Hunter
	[253] = {
		378766, -- [0] Hunter's Knowledge
		288613, -- [1] Trueshot
		213691, -- [2] Scatter Shot
		109248, -- [3] Binding Shot
		343242, -- [4] Improved Mend Pet
		199483, -- [5] Camouflage
		266921, -- [6] Born To Be Wild
		378010, -- [7] Improved Kill Command
		199921, -- [8] Trailblazer
		343248, -- [9] Improved Kill Shot
		378759, -- [10] Nesingwary's Trapping Apparatus
		187698, -- [11] Tar Trap
		1513, -- [12] Scare Beast
		378007, -- [13] Beast Master
		270581, -- [14] Natural Mending
		34477, -- [15] Misdirection
		343247, -- [16] Improved Traps
		378004, -- [17] Keen Eyesight
		109215, -- [18] Posthaste
		321468, -- [19] Binding Shackles
		343244, -- [20] Improved Tranquilizing Shot
		378002, -- [21] Agile Movement
		201430, -- [22] Stampede
		375891, -- [23] Death Chakram
		342049, -- [24] Chimaera Shot
		212431, -- [25] Explosive Shot
		120360, -- [26] Barrage
		260309, -- [27] Master Marksman
		378014, -- [28] Latent Poison Injectors
		260241, -- [29] Hydra's Bite
		19577, -- [30] Intimidation
		236776, -- [31] Hi-Explosive Trap
		385539, -- [32] Rejuvenating Wind
		162488, -- [33] Steel Trap
		19801, -- [34] Tranquilizing Shot
		5116, -- [35] Concussive Shot
		271788, -- [36] Serpent Sting
		273887, -- [37] Killer Instinct
		269737, -- [38] Alpha Predator
		378910, -- [39] Heavy Ammo
		378913, -- [40] Light Ammo
		260404, -- [41] Calling the Shots
		386878, -- [42] Unerring Vision
		389449, -- [43] Eagletalon's True Focus
		378765, -- [44] Killing Blow
		190852, -- [45] Legacy of the Windrunners
		321018, -- [46] Improved Steady Shot
		260393, -- [47] Lethal Shots
		391559, -- [48] Surging Shots
		378767, -- [49] Focused Aim
		321293, -- [50] Crack Shot
		378905, -- [51] Windrunner's Guidance
		260367, -- [52] Streamline
		321460, -- [53] Dead Eye
		193533, -- [54] Steady Focus
		260243, -- [55] Volley
		378880, -- [56] Bombardment
		378907, -- [57] Sharpshooter
		392060, -- [58] Wailing Arrow
		194595, -- [59] Lock and Load
		378769, -- [60] Deathblow
		378888, -- [61] Serpentstalker's Trickery
		257044, -- [62] Rapid Fire
		260228, -- [63] Careful Aim
		378771, -- [64] Quick Load
		260240, -- [65] Precise Shots
		204089, -- [66] Bullseye
		257621, -- [67] Trick Shots
		260402, -- [68] Double Tap
		19434, -- [69] Aimed Shot
		186387, -- [70] Bursting Shot
		155228, -- [71] Lone Wolf
		257620, -- [72] Multi-Shot
		34026, -- [73] Kill Command
		147362, -- [74] Counter Shot
		53351, -- [75] Kill Shot
		384799, -- [76] Hunter's Agility
		384790, -- [77] Razor Fragments
		384791, -- [78] Salvo
		264735, -- [79] Survival of the Fittest
		388039, -- [80] Lone Survivor
		388042, -- [81] Nature's Endurance
		388045, -- [82] Sentinel (NYI)
		388056, -- [83] Sentinel's Perception (NYI)
		388057, -- [84] Sentinel's Wisdom (NYI)
		389019, -- [85] Bulletstorm
		390231, -- [86] Arctic Bola
		389882, -- [87] Serrated Shots
		389866, -- [88] Windrunner's Barrage
		389865, -- [89] Readiness
		321287, -- [90] True Aim
	},
	-- Marksmanship Hunter
	[254] = {
		213691, -- [0] Scatter Shot
		109248, -- [1] Binding Shot
		343242, -- [2] Improved Mend Pet
		199483, -- [3] Camouflage
		266921, -- [4] Born To Be Wild
		378010, -- [5] Improved Kill Command
		199921, -- [6] Trailblazer
		343248, -- [7] Improved Kill Shot
		378759, -- [8] Nesingwary's Trapping Apparatus
		187698, -- [9] Tar Trap
		1513, -- [10] Scare Beast
		378007, -- [11] Beast Master
		270581, -- [12] Natural Mending
		34477, -- [13] Misdirection
		343247, -- [14] Improved Traps
		378004, -- [15] Keen Eyesight
		109215, -- [16] Posthaste
		321468, -- [17] Binding Shackles
		343244, -- [18] Improved Tranquilizing Shot
		378002, -- [19] Agile Movement
		201430, -- [20] Stampede
		375891, -- [21] Death Chakram
		212431, -- [22] Explosive Shot
		120360, -- [23] Barrage
		260309, -- [24] Master Marksman
		378014, -- [25] Latent Poison Injectors
		260241, -- [26] Hydra's Bite
		19577, -- [27] Intimidation
		236776, -- [28] Hi-Explosive Trap
		385539, -- [29] Rejuvenating Wind
		162488, -- [30] Steel Trap
		19801, -- [31] Tranquilizing Shot
		5116, -- [32] Concussive Shot
		271788, -- [33] Serpent Sting
		273887, -- [34] Killer Instinct
		269737, -- [35] Alpha Predator
		271014, -- [36] Wildfire Infusion
		378962, -- [37] Deadly Duo
		378940, -- [38] Quick Shot
		264332, -- [39] Guerrilla Tactics
		360966, -- [40] Spearhead
		360952, -- [41] Coordinated Assault
		260331, -- [42] Birds of Prey
		389880, -- [43] Bombardier
		259495, -- [44] Wildfire Bomb
		265895, -- [45] Terms of Engagement
		259387, -- [46] Mongoose Bite
		263186, -- [47] Predator
		260248, -- [48] Bloodseeker
		378937, -- [49] Explosives Expert
		186289, -- [50] Aspect of the Eagle
		378950, -- [51] Sweeping Spear
		378961, -- [52] Energetic Ally
		378955, -- [53] Killer Companion
		378953, -- [54] Spear Focus
		203415, -- [55] Fury of the Eagle
		378951, -- [56] Tactical Advantage
		321290, -- [57] Improved Wildfire Bomb
		260285, -- [58] Tip of the Spear
		187708, -- [59] Carve
		212436, -- [60] Butchery
		186270, -- [61] Raptor Strike
		378934, -- [62] Lunge
		378916, -- [63] Ferocity
		294029, -- [64] Frenzy Strikes
		378948, -- [65] Sharp Edges
		190925, -- [66] Harpoon
		269751, -- [67] Flanking Strike
		259489, -- [68] Kill Command
		187707, -- [69] Muzzle
		320976, -- [70] Kill Shot
		384799, -- [71] Hunter's Agility
		385718, -- [72] Ruthless Marauder
		385737, -- [73] Bloody Claws
		385709, -- [74] Intense Focus
		268501, -- [75] Viper's Venom
		385695, -- [76] Ranger
		385739, -- [77] Coordinated Kill
		264735, -- [78] Survival of the Fittest
		388039, -- [79] Lone Survivor
		388042, -- [80] Nature's Endurance
		388045, -- [81] Sentinel (NYI)
		388056, -- [82] Sentinel's Perception (NYI)
		388057, -- [83] Sentinel's Wisdom (NYI)
		390231, -- [84] Arctic Bola
		389882, -- [85] Serrated Shots
	},
	-- Survival Hunter
	[255] = {
		213691, -- [0] Scatter Shot
		109248, -- [1] Binding Shot
		343242, -- [2] Improved Mend Pet
		199483, -- [3] Camouflage
		266921, -- [4] Born To Be Wild
		378010, -- [5] Improved Kill Command
		199921, -- [6] Trailblazer
		343248, -- [7] Improved Kill Shot
		378759, -- [8] Nesingwary's Trapping Apparatus
		187698, -- [9] Tar Trap
		1513, -- [10] Scare Beast
		378007, -- [11] Beast Master
		270581, -- [12] Natural Mending
		34477, -- [13] Misdirection
		343247, -- [14] Improved Traps
		378004, -- [15] Keen Eyesight
		109215, -- [16] Posthaste
		321468, -- [17] Binding Shackles
		343244, -- [18] Improved Tranquilizing Shot
		378002, -- [19] Agile Movement
		201430, -- [20] Stampede
		375891, -- [21] Death Chakram
		212431, -- [22] Explosive Shot
		120360, -- [23] Barrage
		260309, -- [24] Master Marksman
		378014, -- [25] Latent Poison Injectors
		260241, -- [26] Hydra's Bite
		19577, -- [27] Intimidation
		236776, -- [28] Hi-Explosive Trap
		385539, -- [29] Rejuvenating Wind
		162488, -- [30] Steel Trap
		19801, -- [31] Tranquilizing Shot
		5116, -- [32] Concussive Shot
		271788, -- [33] Serpent Sting
		273887, -- [34] Killer Instinct
		269737, -- [35] Alpha Predator
		271014, -- [36] Wildfire Infusion
		378962, -- [37] Deadly Duo
		378940, -- [38] Quick Shot
		264332, -- [39] Guerrilla Tactics
		360966, -- [40] Spearhead
		360952, -- [41] Coordinated Assault
		260331, -- [42] Birds of Prey
		389880, -- [43] Bombardier
		259495, -- [44] Wildfire Bomb
		265895, -- [45] Terms of Engagement
		259387, -- [46] Mongoose Bite
		263186, -- [47] Predator
		260248, -- [48] Bloodseeker
		378937, -- [49] Explosives Expert
		186289, -- [50] Aspect of the Eagle
		378950, -- [51] Sweeping Spear
		378961, -- [52] Energetic Ally
		378955, -- [53] Killer Companion
		378953, -- [54] Spear Focus
		203415, -- [55] Fury of the Eagle
		378951, -- [56] Tactical Advantage
		321290, -- [57] Improved Wildfire Bomb
		260285, -- [58] Tip of the Spear
		187708, -- [59] Carve
		212436, -- [60] Butchery
		186270, -- [61] Raptor Strike
		378934, -- [62] Lunge
		378916, -- [63] Ferocity
		294029, -- [64] Frenzy Strikes
		378948, -- [65] Sharp Edges
		190925, -- [66] Harpoon
		269751, -- [67] Flanking Strike
		259489, -- [68] Kill Command
		187707, -- [69] Muzzle
		320976, -- [70] Kill Shot
		384799, -- [71] Hunter's Agility
		385718, -- [72] Ruthless Marauder
		385737, -- [73] Bloody Claws
		385709, -- [74] Intense Focus
		268501, -- [75] Viper's Venom
		385695, -- [76] Ranger
		385739, -- [77] Coordinated Kill
		264735, -- [78] Survival of the Fittest
		388039, -- [79] Lone Survivor
		388042, -- [80] Nature's Endurance
		388045, -- [81] Sentinel (NYI)
		388056, -- [82] Sentinel's Perception (NYI)
		388057, -- [83] Sentinel's Wisdom (NYI)
		390231, -- [84] Arctic Bola
		389882, -- [85] Serrated Shots
	},
	-- Discipline Priest
	[256] = {
		34433, -- [0] Shadowfiend
		390996, -- [1] Manipulation
		391112, -- [2] Shattered Perceptions
		108968, -- [3] Void Shift
		108945, -- [4] Angelic Bulwark
		373481, -- [5] Power Word: Life
		109186, -- [6] Surge of Light
		238100, -- [7] Angel's Mercy
		368275, -- [8] Binding Heals
		373450, -- [9] Light's Inspiration
		373457, -- [10] Crystalline Reflection
		110744, -- [11] Divine Star
		120517, -- [12] Halo
		373466, -- [13] Twins of the Sun Priestess
		390972, -- [14] Twist of Fate
		373446, -- [15] Translucent Image
		390670, -- [16] Improved Fade
		375901, -- [17] Mindgames
		373223, -- [18] Tithe Evasion
		390668, -- [19] Apathy
		199855, -- [20] San'layn
		15286, -- [21] Vampiric Embrace
		280749, -- [22] Void Shield
		9484, -- [23] Shackle Undead
		10060, -- [24] Power Infusion
		196704, -- [25] Psychic Voice
		390676, -- [26] Inspiration
		373456, -- [27] Unwavering Will
		341167, -- [28] Improved Mass Dispel
		32375, -- [29] Mass Dispel
		390622, -- [30] Rhapsody
		132157, -- [31] Holy Nova
		390620, -- [32] Move with Grace
		121536, -- [33] Angelic Feather
		390632, -- [34] Improved Purify
		64129, -- [35] Body and Soul
		193063, -- [36] Masochism
		390615, -- [37] Depth of the Shadows
		390919, -- [38] Sheer Terror
		108920, -- [39] Void Tendrils
		377422, -- [40] Throes of Pain
		605, -- [41] Mind Control
		205364, -- [42] Dominate Mind
		321291, -- [43] Death and Madness
		32379, -- [44] Shadow Word: Death
		186263, -- [45] Shadow Mend
		377438, -- [46] Tools of the Cloth
		73325, -- [47] Leap of Faith
		139, -- [48] Renew
		33076, -- [49] Prayer of Mending
		372354, -- [50] Focused Mending
		390667, -- [51] Spell Warding
		390767, -- [52] Blessed Recovery
		47515, -- [53] Divine Aegis
		390693, -- [54] Train of Thought
		391079, -- [55] Make Amends
		390691, -- [56] Borrowed Time
		197419, -- [57] Contrition
		47536, -- [58] Rapture
		390686, -- [59] Painful Punishment
		372972, -- [60] Dark Indulgence
		198068, -- [61] Power of the Dark Side
		81749, -- [62] Atonement
		194509, -- [63] Power Word: Radiance
		322115, -- [64] Light's Promise
		390684, -- [65] Bright Pupil
		390685, -- [66] Enduring Luminescence
		204197, -- [67] Purge the Wicked
		197045, -- [68] Shield Discipline
		129250, -- [69] Power Word: Solace
		372991, -- [70] Pain Transformation
		373035, -- [71] Protector of the Frail
		33206, -- [72] Pain Suppression
		373427, -- [73] Shadowflame Prism
		390832, -- [74] Expiation
		123040, -- [75] Mindbender
		373054, -- [76] Stolen Psyche
		372985, -- [77] Embrace Shadow
		373065, -- [78] Twilight Corruption
		314867, -- [79] Shadow Covenant
		372969, -- [80] Malicious Scission
		214621, -- [81] Schism
		390689, -- [82] Improved Shadow Word: Pain
		193134, -- [83] Castigation
		373042, -- [84] Exaltation
		373178, -- [85] Light's Wrath
		390765, -- [86] Resplendent Light
		390781, -- [87] Wrath, Unleashed
		373180, -- [88] Harsh Discipline
		390705, -- [89] Twilight Equilibrium
		390770, -- [90] Fiending Dark
		390786, -- [91] Weal and Woe
		280391, -- [92] Sins of the Many
		238063, -- [93] Lenience
		246287, -- [94] Evangelism
		373003, -- [95] Revel in Purity
		373049, -- [96] Indemnity
		238135, -- [97] Aegis of Wrath
		62618, -- [98] Power Word: Barrier
		108942, -- [99] Phantasm
		528, -- [100] Dispel Magic
	},
	-- Holy Priest
	[257] = {
		34433, -- [0] Shadowfiend
		390996, -- [1] Manipulation
		391112, -- [2] Shattered Perceptions
		108968, -- [3] Void Shift
		108945, -- [4] Angelic Bulwark
		373481, -- [5] Power Word: Life
		109186, -- [6] Surge of Light
		238100, -- [7] Angel's Mercy
		368275, -- [8] Binding Heals
		373450, -- [9] Light's Inspiration
		373457, -- [10] Crystalline Reflection
		110744, -- [11] Divine Star
		120517, -- [12] Halo
		373466, -- [13] Twins of the Sun Priestess
		390972, -- [14] Twist of Fate
		373446, -- [15] Translucent Image
		390670, -- [16] Improved Fade
		375901, -- [17] Mindgames
		373223, -- [18] Tithe Evasion
		390668, -- [19] Apathy
		199855, -- [20] San'layn
		15286, -- [21] Vampiric Embrace
		280749, -- [22] Void Shield
		9484, -- [23] Shackle Undead
		10060, -- [24] Power Infusion
		196704, -- [25] Psychic Voice
		390676, -- [26] Inspiration
		373456, -- [27] Unwavering Will
		341167, -- [28] Improved Mass Dispel
		32375, -- [29] Mass Dispel
		390622, -- [30] Rhapsody
		132157, -- [31] Holy Nova
		390620, -- [32] Move with Grace
		121536, -- [33] Angelic Feather
		390632, -- [34] Improved Purify
		64129, -- [35] Body and Soul
		193063, -- [36] Masochism
		390615, -- [37] Depth of the Shadows
		390919, -- [38] Sheer Terror
		108920, -- [39] Void Tendrils
		377422, -- [40] Throes of Pain
		605, -- [41] Mind Control
		205364, -- [42] Dominate Mind
		321291, -- [43] Death and Madness
		32379, -- [44] Shadow Word: Death
		186263, -- [45] Shadow Mend
		377438, -- [46] Tools of the Cloth
		73325, -- [47] Leap of Faith
		139, -- [48] Renew
		33076, -- [49] Prayer of Mending
		372354, -- [50] Focused Mending
		390667, -- [51] Spell Warding
		390767, -- [52] Blessed Recovery
		47515, -- [53] Divine Aegis
		390693, -- [54] Train of Thought
		391079, -- [55] Make Amends
		390691, -- [56] Borrowed Time
		197419, -- [57] Contrition
		47536, -- [58] Rapture
		390686, -- [59] Painful Punishment
		372972, -- [60] Dark Indulgence
		198068, -- [61] Power of the Dark Side
		81749, -- [62] Atonement
		194509, -- [63] Power Word: Radiance
		322115, -- [64] Light's Promise
		390684, -- [65] Bright Pupil
		390685, -- [66] Enduring Luminescence
		204197, -- [67] Purge the Wicked
		197045, -- [68] Shield Discipline
		129250, -- [69] Power Word: Solace
		372991, -- [70] Pain Transformation
		373035, -- [71] Protector of the Frail
		33206, -- [72] Pain Suppression
		373427, -- [73] Shadowflame Prism
		390832, -- [74] Expiation
		123040, -- [75] Mindbender
		373054, -- [76] Stolen Psyche
		372985, -- [77] Embrace Shadow
		373065, -- [78] Twilight Corruption
		314867, -- [79] Shadow Covenant
		372969, -- [80] Malicious Scission
		214621, -- [81] Schism
		390689, -- [82] Improved Shadow Word: Pain
		193134, -- [83] Castigation
		373042, -- [84] Exaltation
		373178, -- [85] Light's Wrath
		390765, -- [86] Resplendent Light
		390781, -- [87] Wrath, Unleashed
		373180, -- [88] Harsh Discipline
		390705, -- [89] Twilight Equilibrium
		390770, -- [90] Fiending Dark
		390786, -- [91] Weal and Woe
		280391, -- [92] Sins of the Many
		238063, -- [93] Lenience
		246287, -- [94] Evangelism
		373003, -- [95] Revel in Purity
		373049, -- [96] Indemnity
		238135, -- [97] Aegis of Wrath
		62618, -- [98] Power Word: Barrier
		108942, -- [99] Phantasm
		528, -- [100] Dispel Magic
	},
	-- Shadow Priest
	[258] = {
		34433, -- [0] Shadowfiend
		200128, -- [1] Trail of Light
		196707, -- [2] Afterlife
		200209, -- [3] Guardian Angel
		196437, -- [4] Guardians of the Light
		47788, -- [5] Guardian Spirit
		2050, -- [6] Holy Word: Serenity
		88625, -- [7] Holy Word: Chastise
		372307, -- [8] Burning Vehemence
		193157, -- [9] Benediction
		391154, -- [10] Holy Mending
		391233, -- [11] Divine Service
		390996, -- [12] Manipulation
		391112, -- [13] Shattered Perceptions
		108968, -- [14] Void Shift
		108945, -- [15] Angelic Bulwark
		373481, -- [16] Power Word: Life
		109186, -- [17] Surge of Light
		238100, -- [18] Angel's Mercy
		368275, -- [19] Binding Heals
		373450, -- [20] Light's Inspiration
		373457, -- [21] Crystalline Reflection
		110744, -- [22] Divine Star
		120517, -- [23] Halo
		373466, -- [24] Twins of the Sun Priestess
		390972, -- [25] Twist of Fate
		373446, -- [26] Translucent Image
		390670, -- [27] Improved Fade
		375901, -- [28] Mindgames
		373223, -- [29] Tithe Evasion
		390668, -- [30] Apathy
		199855, -- [31] San'layn
		15286, -- [32] Vampiric Embrace
		280749, -- [33] Void Shield
		9484, -- [34] Shackle Undead
		10060, -- [35] Power Infusion
		196704, -- [36] Psychic Voice
		390676, -- [37] Inspiration
		373456, -- [38] Unwavering Will
		341167, -- [39] Improved Mass Dispel
		32375, -- [40] Mass Dispel
		390622, -- [41] Rhapsody
		132157, -- [42] Holy Nova
		390620, -- [43] Move with Grace
		121536, -- [44] Angelic Feather
		390632, -- [45] Improved Purify
		64129, -- [46] Body and Soul
		193063, -- [47] Masochism
		390615, -- [48] Depth of the Shadows
		390919, -- [49] Sheer Terror
		108920, -- [50] Void Tendrils
		377422, -- [51] Throes of Pain
		605, -- [52] Mind Control
		205364, -- [53] Dominate Mind
		321291, -- [54] Death and Madness
		32379, -- [55] Shadow Word: Death
		391208, -- [56] Revitalizing Prayers
		196489, -- [57] Sanctified Prayers
		34861, -- [58] Holy Word: Sanctify
		596, -- [59] Prayer of Healing
		186263, -- [60] Shadow Mend
		377438, -- [61] Tools of the Cloth
		73325, -- [62] Leap of Faith
		139, -- [63] Renew
		33076, -- [64] Prayer of Mending
		372354, -- [65] Focused Mending
		390667, -- [66] Spell Warding
		390767, -- [67] Blessed Recovery
		238136, -- [68] Cosmic Ripple
		196985, -- [69] Light of the Naaru
		390980, -- [70] Pontifex
		390954, -- [71] Crisis Management
		390947, -- [72] Orison
		321377, -- [73] Prayer Circle
		390881, -- [74] Healing Chorus
		204883, -- [75] Circle of Healing
		391209, -- [76] Prayerful Litany
		391161, -- [77] Everlasting Light
		64843, -- [78] Divine Hymn
		341997, -- [79] Renewed Faith
		200199, -- [80] Censure
		193155, -- [81] Enlightenment
		64901, -- [82] Symbol of Hope
		390977, -- [83] Prayers of the Virtuous
		391186, -- [84] Say Your Prayers
		390967, -- [85] Prismatic Echoes
		372370, -- [86] Gales of Song
		391339, -- [87] Empowered Renew
		391368, -- [88] Rapid Recovery
		390994, -- [89] Harmonious Apparatus
		200183, -- [90] Apotheosis
		265202, -- [91] Holy Word: Salvation
		391381, -- [92] Desperate Times
		391387, -- [93] Answered Prayers
		372616, -- [94] Empyreal Blaze
		372611, -- [95] Searing Light
		235587, -- [96] Miracle Worker
		391124, -- [97] Restitution
		372309, -- [98] Resonant Words
		390992, -- [99] Lightweaver
		372835, -- [100] Lightwell
		108942, -- [101] Phantasm
		392988, -- [102] Divine Image
		372760, -- [103] Divine Word
		528, -- [104] Dispel Magic
	},
	-- Assassination Rogue
	[259] = {
		193531, -- [0] Deeper Stratagem
		79008, -- [1] Elusiveness
		385616, -- [2] Echoing Reprimand
		381622, -- [3] Resounding Clarity
		14983, -- [4] Vigor
		381623, -- [5] Thistle Tea
		280716, -- [6] Leeching Poison
		14190, -- [7] Seal Fate
		185313, -- [8] Shadow Dance
		91023, -- [9] Find Weakness
		31230, -- [10] Cheat Death
		57934, -- [11] Tricks of the Trade
		36554, -- [12] Shadowstep
		379005, -- [13] Improved Sap
		137619, -- [14] Marked for Death
		193539, -- [15] Alacrity
		381619, -- [16] So Versatile
		1776, -- [17] Gouge
		231691, -- [18] Improved Sprint
		378996, -- [19] Recuperator
		381620, -- [20] Improved Ambush
		14062, -- [21] Nightstalker
		196924, -- [22] Acrobatic Strikes
		382238, -- [23] Lethality
		381542, -- [24] Deadly Precision
		382245, -- [25] Cold Blood
		381543, -- [26] Virulent Poisons
		319066, -- [27] Improved Wound Poison
		378436, -- [28] Master Poisoner
		193546, -- [29] Iron Stomach
		378427, -- [30] Nimble Fingers
		5938, -- [31] Shiv
		5277, -- [32] Evasion
		5761, -- [33] Numbing Poison
		381637, -- [34] Atrophic Poison
		378813, -- [35] Fleet Footed
		231719, -- [36] Deadened Nerves
		108208, -- [37] Subterfuge
		378807, -- [38] Shadowrunner
		6770, -- [39] Sap
		31224, -- [40] Cloak of Shadows
		378803, -- [41] Rushed Setup
		2094, -- [42] Blind
		1966, -- [43] Feint
		381621, -- [44] Tight Spender
		131511, -- [45] Prey on the Weak
		383281, -- [46] Hidden Opportunity
		382742, -- [47] Take 'em by Surprise
		385408, -- [48] Sepsis
		196937, -- [49] Ghostly Strike
		381885, -- [50] Heavy Hitter [NYI]
		381845, -- [51] Audacity
		381894, -- [52] Triple Threat
		271877, -- [53] Blade Rush
		256165, -- [54] Blinding Powder
		256188, -- [55] Retractable Hook
		108216, -- [56] Dirty Tricks
		196922, -- [57] Hit and Run
		381839, -- [58] Sleight of Hand
		381989, -- [59] Keep It Rolling
		381990, -- [60] Dispatcher
		382794, -- [61] Restless Crew [NYI]
		381982, -- [62] Count the Odds
		61329, -- [63] Combat Potency
		193531, -- [64] Deeper Stratagem
		386823, -- [65] Greenskin's Wickers
		381846, -- [66] Fan the Hammer
		381985, -- [67] Precise Cuts [NYI]
		51690, -- [68] Killing Spree
		343142, -- [69] Dreadblades
		382746, -- [70] Improved Main Gauche
		272026, -- [71] Dancing Steel
		381878, -- [72] Long Arm of the Outlaw
		381828, -- [73] Ace Up Your Sleeve
		196938, -- [74] Quick Draw
		381877, -- [75] Combat Stamina
		35551, -- [76] Fatal Flourish
		354897, -- [77] Float Like a Butterfly
		79096, -- [78] Restless Blades
		256170, -- [79] Loaded Dice
		315508, -- [80] Roll the Bones
		13750, -- [81] Adrenaline Rush
		381822, -- [82] Ambidexterity
		13877, -- [83] Blade Flurry
		315341, -- [84] Between the Eyes
		200733, -- [85] Weaponmaster
		279876, -- [86] Opportunity
		195457, -- [87] Grappling Hook
		344363, -- [88] Riposte
		14161, -- [89] Ruthlessness
		381988, -- [90] Slicerdicer
	},
	-- Outlaw Rogue
	[260] = {
		382515, -- [0] Cloaked in Shadows
		382513, -- [1] Without a Trace
		382528, -- [2] Shadow Mist [NYI]
		382524, -- [3] Lingering Shadow
		245687, -- [4] Dark Shadow
		382514, -- [5] Fade to Nothing
		382509, -- [6] Stiletto Staccato
		185314, -- [7] Deepening Shadows
		121471, -- [8] Shadow Blades
		185313, -- [9] Shadow Dance
		58423, -- [10] Relentless Strikes
		385722, -- [11] Silent Storm
		382017, -- [12] Veiltouched
		36554, -- [13] Shadowstep
		108209, -- [14] Shadow Focus
		319949, -- [15] Improved Backstab
		193537, -- [16] Weaponmaster
		343160, -- [17] Premeditation
		196912, -- [18] Shadow Techniques
		212283, -- [19] Symbols of Death
		382508, -- [20] Planned Execution
		278683, -- [21] Inevitability
		193531, -- [22] Deeper Stratagem
		79008, -- [23] Elusiveness
		385616, -- [24] Echoing Reprimand
		381622, -- [25] Resounding Clarity
		14983, -- [26] Vigor
		381623, -- [27] Thistle Tea
		280716, -- [28] Leeching Poison
		14190, -- [29] Seal Fate
		185313, -- [30] Shadow Dance
		91023, -- [31] Find Weakness
		31230, -- [32] Cheat Death
		57934, -- [33] Tricks of the Trade
		36554, -- [34] Shadowstep
		379005, -- [35] Improved Sap
		137619, -- [36] Marked for Death
		193539, -- [37] Alacrity
		381619, -- [38] So Versatile
		1776, -- [39] Gouge
		231691, -- [40] Improved Sprint
		378996, -- [41] Recuperator
		381620, -- [42] Improved Ambush
		14062, -- [43] Nightstalker
		196924, -- [44] Acrobatic Strikes
		382238, -- [45] Lethality
		381542, -- [46] Deadly Precision
		382245, -- [47] Cold Blood
		381543, -- [48] Virulent Poisons
		319066, -- [49] Improved Wound Poison
		378436, -- [50] Master Poisoner
		193546, -- [51] Iron Stomach
		378427, -- [52] Nimble Fingers
		5938, -- [53] Shiv
		5277, -- [54] Evasion
		5761, -- [55] Numbing Poison
		381637, -- [56] Atrophic Poison
		378813, -- [57] Fleet Footed
		231719, -- [58] Deadened Nerves
		108208, -- [59] Subterfuge
		378807, -- [60] Shadowrunner
		6770, -- [61] Sap
		31224, -- [62] Cloak of Shadows
		378803, -- [63] Rushed Setup
		2094, -- [64] Blind
		1966, -- [65] Feint
		277953, -- [66] Night Terrors
		381621, -- [67] Tight Spender
		131511, -- [68] Prey on the Weak
		385408, -- [69] Sepsis
		382503, -- [70] Quick Decisions
		200758, -- [71] Gloomblade
		382507, -- [72] Shrouded in Darkness
		257505, -- [73] Shot in the Dark
		382518, -- [74] Perforated Veins
		382523, -- [75] Invigorating Shadowdust
		382015, -- [76] The Rotten
		382505, -- [77] The First Dance
		196976, -- [78] Master of Shadows
		277925, -- [79] Shuriken Tornado
		384631, -- [80] Flagellation
		382525, -- [81] Finality
		193531, -- [82] Deeper Stratagem
		382517, -- [83] Deeper Daggers
		382504, -- [84] Dark Brew
		280719, -- [85] Secret Technique
		319175, -- [86] Black Powder
		319951, -- [87] Improved Shuriken Storm
		382506, -- [88] Replicating Shadows [NYI]
		382511, -- [89] Shadowed Finishers
	},
	-- Subtlety Rogue
	[261] = {
		382515, -- [0] Cloaked in Shadows
		382513, -- [1] Without a Trace
		382528, -- [2] Shadow Mist [NYI]
		382524, -- [3] Lingering Shadow
		245687, -- [4] Dark Shadow
		382514, -- [5] Fade to Nothing
		382509, -- [6] Stiletto Staccato
		185314, -- [7] Deepening Shadows
		121471, -- [8] Shadow Blades
		185313, -- [9] Shadow Dance
		58423, -- [10] Relentless Strikes
		385722, -- [11] Silent Storm
		382017, -- [12] Veiltouched
		36554, -- [13] Shadowstep
		108209, -- [14] Shadow Focus
		319949, -- [15] Improved Backstab
		193537, -- [16] Weaponmaster
		343160, -- [17] Premeditation
		196912, -- [18] Shadow Techniques
		212283, -- [19] Symbols of Death
		382508, -- [20] Planned Execution
		278683, -- [21] Inevitability
		193531, -- [22] Deeper Stratagem
		79008, -- [23] Elusiveness
		385616, -- [24] Echoing Reprimand
		381622, -- [25] Resounding Clarity
		14983, -- [26] Vigor
		381623, -- [27] Thistle Tea
		280716, -- [28] Leeching Poison
		14190, -- [29] Seal Fate
		185313, -- [30] Shadow Dance
		91023, -- [31] Find Weakness
		31230, -- [32] Cheat Death
		57934, -- [33] Tricks of the Trade
		36554, -- [34] Shadowstep
		379005, -- [35] Improved Sap
		137619, -- [36] Marked for Death
		193539, -- [37] Alacrity
		381619, -- [38] So Versatile
		1776, -- [39] Gouge
		231691, -- [40] Improved Sprint
		378996, -- [41] Recuperator
		381620, -- [42] Improved Ambush
		14062, -- [43] Nightstalker
		196924, -- [44] Acrobatic Strikes
		382238, -- [45] Lethality
		381542, -- [46] Deadly Precision
		382245, -- [47] Cold Blood
		381543, -- [48] Virulent Poisons
		319066, -- [49] Improved Wound Poison
		378436, -- [50] Master Poisoner
		193546, -- [51] Iron Stomach
		378427, -- [52] Nimble Fingers
		5938, -- [53] Shiv
		5277, -- [54] Evasion
		5761, -- [55] Numbing Poison
		381637, -- [56] Atrophic Poison
		378813, -- [57] Fleet Footed
		231719, -- [58] Deadened Nerves
		108208, -- [59] Subterfuge
		378807, -- [60] Shadowrunner
		6770, -- [61] Sap
		31224, -- [62] Cloak of Shadows
		378803, -- [63] Rushed Setup
		2094, -- [64] Blind
		1966, -- [65] Feint
		277953, -- [66] Night Terrors
		381621, -- [67] Tight Spender
		131511, -- [68] Prey on the Weak
		385408, -- [69] Sepsis
		382503, -- [70] Quick Decisions
		200758, -- [71] Gloomblade
		382507, -- [72] Shrouded in Darkness
		257505, -- [73] Shot in the Dark
		382518, -- [74] Perforated Veins
		382523, -- [75] Invigorating Shadowdust
		382015, -- [76] The Rotten
		382505, -- [77] The First Dance
		196976, -- [78] Master of Shadows
		277925, -- [79] Shuriken Tornado
		384631, -- [80] Flagellation
		382525, -- [81] Finality
		193531, -- [82] Deeper Stratagem
		382517, -- [83] Deeper Daggers
		382504, -- [84] Dark Brew
		280719, -- [85] Secret Technique
		319175, -- [86] Black Powder
		319951, -- [87] Improved Shuriken Storm
		382506, -- [88] Replicating Shadows [NYI]
		382511, -- [89] Shadowed Finishers
	},
	-- Elemental Shaman
	[262] = {
		381867, -- [0] Totemic Surge
		381930, -- [1] Mana Spring Totem
		108281, -- [2] Ancestral Guidance
		378094, -- [3] Swirling Currents
		5394, -- [4] Healing Stream Totem
		378081, -- [5] Nature's Swiftness
		381674, -- [6] Improved Lightning Bolt
		51490, -- [7] Thunderstorm
		378779, -- [8] Thundershock
		305483, -- [9] Lightning Lasso
		383017, -- [10] Stoneskin Totem
		383019, -- [11] Tranquil Air Totem
		382201, -- [12] Totemic Focus
		383013, -- [13] Poison Cleansing Totem
		382033, -- [14] Surging Shields
		108285, -- [15] Call of the Elements
		383011, -- [16] Improved Call of the Elements
		383012, -- [17] Creation Core
		381678, -- [18] Go With The Flow
		58875, -- [19] Spirit Walk
		192063, -- [20] Gust of Wind
		382215, -- [21] Winds of Al'Akir
		381655, -- [22] Nature's Fury
		381689, -- [23] Brimming with Life
		381650, -- [24] Elemental Warding
		382947, -- [25] Ancestral Defense
		192077, -- [26] Wind Rush Totem
		51485, -- [27] Earthgrab Totem
		30884, -- [28] Nature's Guardian
		108287, -- [29] Totemic Projection
		51514, -- [30] Hex
		204268, -- [31] Voodoo Mastery
		378079, -- [32] Enfeeblement
		51886, -- [33] Cleanse Spirit
		370, -- [34] Purge
		378773, -- [35] Greater Purge
		196840, -- [36] Frost Shock
		260878, -- [37] Spirit Wolf
		378075, -- [38] Thunderous Paws
		192058, -- [39] Capacitor Totem
		265046, -- [40] Static Charge
		381819, -- [41] Guardian's Cudgel
		8143, -- [42] Tremor Totem
		57994, -- [43] Wind Shear
		382886, -- [44] Fire and Ice
		79206, -- [45] Spiritwalker's Grace
		192088, -- [46] Graceful Spirit
		378077, -- [47] Spiritwalker's Aegis
		198103, -- [48] Earth Elemental
		1064, -- [49] Chain Heal
		51505, -- [50] Lava Burst
		188443, -- [51] Chain Lightning
		187880, -- [52] Maelstrom Weapon
		382888, -- [53] Flurry
		381666, -- [54] Focused Insight
		108271, -- [55] Astral Shift
		381647, -- [56] Planes Traveler
		377933, -- [57] Astral Bulwark
		383010, -- [58] Elemental Orbit
		974, -- [59] Earth Shield
		197214, -- [60] Sundering
		187874, -- [61] Crash Lightning
		384363, -- [62] Gathering Storms
		51533, -- [63] Feral Spirit
		384447, -- [64] Witch Doctor's Wolf Bones
		262624, -- [65] Elemental Spirits
		198434, -- [66] Alpha Wolf
		262647, -- [67] Forceful Winds
		390288, -- [68] Unruly Winds
		392352, -- [69] Storm's Wrath
		117014, -- [70] Elemental Blast
		375982, -- [71] Primordial Wave
		384405, -- [72] Primal Maelstrom
		382042, -- [73] Splintered Elements
		210853, -- [74] Elemental Assault
		384355, -- [75] Elemental Weapons
		319930, -- [76] Stormblast
		384352, -- [77] Doom Winds
		33757, -- [78] Windfury Weapon
		383303, -- [79] Improved Maelstrom Weapon
		342240, -- [80] Ice Strike
		384359, -- [81] Swirling Maelstrom
		344357, -- [82] Stormflurry
		334308, -- [83] Crashing Storms
		114051, -- [84] Ascendance
		378270, -- [85] Deeply Rooted Elements
		384450, -- [86] Legacy of the Frost Witch
		384411, -- [87] Static Accumulation
		384444, -- [88] Thorim's Invocation
		334046, -- [89] Lashing Flames
		390370, -- [90] Primal Lava Actuators
		196884, -- [91] Feral Lunge
		201900, -- [92] Hot Hand
		334195, -- [93] Hailstorm
		333974, -- [94] Fire Nova
		334033, -- [95] Molten Assault
		60103, -- [96] Lava Lash
		17364, -- [97] Stormstrike
		8512, -- [98] Windfury Totem
		384143, -- [99] Raging Maelstrom
		384149, -- [100] Overflowing Maelstrom
		337974, -- [101] Refreshing Waters
		382197, -- [102] Ancestral Wolf Affinity
	},
	-- Enhancement Shaman
	[263] = {
		381867, -- [0] Totemic Surge
		381930, -- [1] Mana Spring Totem
		108281, -- [2] Ancestral Guidance
		378094, -- [3] Swirling Currents
		5394, -- [4] Healing Stream Totem
		378081, -- [5] Nature's Swiftness
		381674, -- [6] Improved Lightning Bolt
		51490, -- [7] Thunderstorm
		378779, -- [8] Thundershock
		305483, -- [9] Lightning Lasso
		383017, -- [10] Stoneskin Totem
		383019, -- [11] Tranquil Air Totem
		382201, -- [12] Totemic Focus
		383013, -- [13] Poison Cleansing Totem
		382033, -- [14] Surging Shields
		108285, -- [15] Call of the Elements
		383011, -- [16] Improved Call of the Elements
		383012, -- [17] Creation Core
		381678, -- [18] Go With The Flow
		58875, -- [19] Spirit Walk
		192063, -- [20] Gust of Wind
		382215, -- [21] Winds of Al'Akir
		381655, -- [22] Nature's Fury
		381689, -- [23] Brimming with Life
		381650, -- [24] Elemental Warding
		382947, -- [25] Ancestral Defense
		192077, -- [26] Wind Rush Totem
		51485, -- [27] Earthgrab Totem
		30884, -- [28] Nature's Guardian
		108287, -- [29] Totemic Projection
		51514, -- [30] Hex
		204268, -- [31] Voodoo Mastery
		378079, -- [32] Enfeeblement
		370, -- [33] Purge
		378773, -- [34] Greater Purge
		196840, -- [35] Frost Shock
		383016, -- [36] Improved Purify Spirit
		260878, -- [37] Spirit Wolf
		378075, -- [38] Thunderous Paws
		192058, -- [39] Capacitor Totem
		265046, -- [40] Static Charge
		381819, -- [41] Guardian's Cudgel
		8143, -- [42] Tremor Totem
		57994, -- [43] Wind Shear
		382886, -- [44] Fire and Ice
		79206, -- [45] Spiritwalker's Grace
		192088, -- [46] Graceful Spirit
		378077, -- [47] Spiritwalker's Aegis
		198103, -- [48] Earth Elemental
		1064, -- [49] Chain Heal
		51505, -- [50] Lava Burst
		188443, -- [51] Chain Lightning
		187880, -- [52] Maelstrom Weapon
		382888, -- [53] Flurry
		381666, -- [54] Focused Insight
		108271, -- [55] Astral Shift
		381647, -- [56] Planes Traveler
		377933, -- [57] Astral Bulwark
		114052, -- [58] Ascendance
		382020, -- [59] Earthen Harmony
		382029, -- [60] Ever-Rising Tide
		382194, -- [61] Undercurrent
		378270, -- [62] Deeply Rooted Elements
		197995, -- [63] Wellspring
		382315, -- [64] Earthwarden
		382021, -- [65] Earthliving Weapon
		382482, -- [66] Living Stream
		157153, -- [67] Cloudburst Totem
		200072, -- [68] Torrent
		198838, -- [69] Earthen Wall Totem
		207399, -- [70] Ancestral Protection Totem
		16191, -- [71] Mana Tide Totem
		333919, -- [72] Echo of the Elements
		382309, -- [73] Ancestral Awakening
		382045, -- [74] Primal Tide Core
		157154, -- [75] High Tide
		382019, -- [76] Nature's Focus
		73920, -- [77] Healing Rain
		383222, -- [78] Overflowing Shores
		378443, -- [79] Acid Rain
		381946, -- [80] Wavespeaker's Blessing
		200071, -- [81] Undulation
		73685, -- [82] Unleash Life
		375982, -- [83] Primordial Wave
		382191, -- [84] Improved Primordial Wave
		382046, -- [85] Continuous Waves
		382040, -- [86] Tumbling Waves
		98008, -- [87] Spirit Link Totem
		108280, -- [88] Healing Tide Totem
		382732, -- [89] Ancestral Reach
		382039, -- [90] Flow of the Tides
		207401, -- [91] Ancestral Vigor
		382197, -- [92] Ancestral Wolf Affinity
		383009, -- [93] Stormkeeper
		383010, -- [94] Elemental Orbit
		974, -- [95] Earth Shield
		200076, -- [96] Deluge
		61295, -- [97] Riptide
		207778, -- [98] Downpour
		77756, -- [99] Lava Surge
		382030, -- [100] Water Totem Mastery
		378211, -- [101] Refreshing Waters
		16166, -- [102] Master of the Elements
		280614, -- [103] Flash Flood
		51564, -- [104] Tidal Waves
		5394, -- [105] Healing Stream Totem
		378241, -- [106] Call of Thunder
		16196, -- [107] Resurgence
		52127, -- [108] Water Shield
		77472, -- [109] Healing Wave
	},
	-- Restoration Shaman
	[264] = {
		381867, -- [0] Totemic Surge
		381930, -- [1] Mana Spring Totem
		108281, -- [2] Ancestral Guidance
		378094, -- [3] Swirling Currents
		5394, -- [4] Healing Stream Totem
		378081, -- [5] Nature's Swiftness
		381674, -- [6] Improved Lightning Bolt
		51490, -- [7] Thunderstorm
		378779, -- [8] Thundershock
		305483, -- [9] Lightning Lasso
		383017, -- [10] Stoneskin Totem
		383019, -- [11] Tranquil Air Totem
		382201, -- [12] Totemic Focus
		383013, -- [13] Poison Cleansing Totem
		382033, -- [14] Surging Shields
		108285, -- [15] Call of the Elements
		383011, -- [16] Improved Call of the Elements
		383012, -- [17] Creation Core
		381678, -- [18] Go With The Flow
		58875, -- [19] Spirit Walk
		192063, -- [20] Gust of Wind
		382215, -- [21] Winds of Al'Akir
		381655, -- [22] Nature's Fury
		381689, -- [23] Brimming with Life
		381650, -- [24] Elemental Warding
		382947, -- [25] Ancestral Defense
		192077, -- [26] Wind Rush Totem
		51485, -- [27] Earthgrab Totem
		30884, -- [28] Nature's Guardian
		108287, -- [29] Totemic Projection
		51514, -- [30] Hex
		204268, -- [31] Voodoo Mastery
		378079, -- [32] Enfeeblement
		370, -- [33] Purge
		378773, -- [34] Greater Purge
		196840, -- [35] Frost Shock
		383016, -- [36] Improved Purify Spirit
		260878, -- [37] Spirit Wolf
		378075, -- [38] Thunderous Paws
		192058, -- [39] Capacitor Totem
		265046, -- [40] Static Charge
		381819, -- [41] Guardian's Cudgel
		8143, -- [42] Tremor Totem
		57994, -- [43] Wind Shear
		382886, -- [44] Fire and Ice
		79206, -- [45] Spiritwalker's Grace
		192088, -- [46] Graceful Spirit
		378077, -- [47] Spiritwalker's Aegis
		198103, -- [48] Earth Elemental
		1064, -- [49] Chain Heal
		51505, -- [50] Lava Burst
		188443, -- [51] Chain Lightning
		187880, -- [52] Maelstrom Weapon
		382888, -- [53] Flurry
		381666, -- [54] Focused Insight
		108271, -- [55] Astral Shift
		381647, -- [56] Planes Traveler
		377933, -- [57] Astral Bulwark
		114052, -- [58] Ascendance
		382020, -- [59] Earthen Harmony
		382029, -- [60] Ever-Rising Tide
		382194, -- [61] Undercurrent
		378270, -- [62] Deeply Rooted Elements
		197995, -- [63] Wellspring
		382315, -- [64] Earthwarden
		382021, -- [65] Earthliving Weapon
		382482, -- [66] Living Stream
		157153, -- [67] Cloudburst Totem
		200072, -- [68] Torrent
		198838, -- [69] Earthen Wall Totem
		207399, -- [70] Ancestral Protection Totem
		16191, -- [71] Mana Tide Totem
		333919, -- [72] Echo of the Elements
		382309, -- [73] Ancestral Awakening
		382045, -- [74] Primal Tide Core
		157154, -- [75] High Tide
		382019, -- [76] Nature's Focus
		73920, -- [77] Healing Rain
		383222, -- [78] Overflowing Shores
		378443, -- [79] Acid Rain
		381946, -- [80] Wavespeaker's Blessing
		200071, -- [81] Undulation
		73685, -- [82] Unleash Life
		375982, -- [83] Primordial Wave
		382191, -- [84] Improved Primordial Wave
		382046, -- [85] Continuous Waves
		382040, -- [86] Tumbling Waves
		98008, -- [87] Spirit Link Totem
		108280, -- [88] Healing Tide Totem
		382732, -- [89] Ancestral Reach
		382039, -- [90] Flow of the Tides
		207401, -- [91] Ancestral Vigor
		382197, -- [92] Ancestral Wolf Affinity
		383009, -- [93] Stormkeeper
		383010, -- [94] Elemental Orbit
		974, -- [95] Earth Shield
		200076, -- [96] Deluge
		61295, -- [97] Riptide
		207778, -- [98] Downpour
		77756, -- [99] Lava Surge
		382030, -- [100] Water Totem Mastery
		378211, -- [101] Refreshing Waters
		16166, -- [102] Master of the Elements
		280614, -- [103] Flash Flood
		51564, -- [104] Tidal Waves
		5394, -- [105] Healing Stream Totem
		378241, -- [106] Call of Thunder
		16196, -- [107] Resurgence
		52127, -- [108] Water Shield
		77472, -- [109] Healing Wave
	},
	-- Affliction Warlock
	[265] = {
		267170, -- [0] From the Shadows
		265187, -- [1] Summon Demonic Tyrant
		387483, -- [2] Kazaak's Final Curse
		603, -- [3] Doom
		267216, -- [4] Inner Demons
		386185, -- [5] Borne of Blood
		387322, -- [6] Shadow's Bite
		264178, -- [7] Demonbolt
		104316, -- [8] Call Dreadstalkers
		386174, -- [9] Fel Commando
		267211, -- [10] Bilescourge Bombers
		267171, -- [11] Demonic Strength
		264078, -- [12] Dreadlash
		264119, -- [13] Summon Vilefiend
		264057, -- [14] Soul Strike
		386194, -- [15] Carnivorous Stalkers
		205145, -- [16] Demonic Calling
		386200, -- [17] Fel and Steel
		387338, -- [18] Fel Might
		390173, -- [19] Reign of Tyranny
		337020, -- [20] Wilfred's Sigil of Superior Summoning
		387396, -- [21] Demonic Meteor
		387488, -- [22] Houndmaster's Gambit
		387399, -- [23] Fel Sunder
		387485, -- [24] Ripped through the Portal
		387494, -- [25] Antoran Armaments
		387602, -- [26] Stolen Power
		387549, -- [27] Command Aura
		386833, -- [28] Guillotine
		387541, -- [29] Forces of the Horned Nightmare
		264130, -- [30] Power Siphon
		196277, -- [31] Implosion
		387349, -- [32] Bloodbound Imps
		387432, -- [33] Balespider's Burning Core
		387391, -- [34] Grim Inquisitor's Dread Calling
		387445, -- [35] Imp Gang Boss
		267217, -- [36] Nether Portal
		387526, -- [37] Ner'zhul's Volition
		387578, -- [38] Gul'dan's Ambition
		387600, -- [39] The Expendables
		267214, -- [40] Sacrificed Souls
		334585, -- [41] Soulbound Tyrant
		385899, -- [42] Soulburn
		317138, -- [43] Strength of Will
		386659, -- [44] Demonic Durability
		111771, -- [45] Demonic Gateway
		389609, -- [46] Abyss Walker
		386613, -- [47] Accrued Vitality
		219272, -- [48] Demon Skin
		386105, -- [49] Curses of Enfeeblement
		386124, -- [50] Fel Armor
		111400, -- [51] Burning Rush
		386110, -- [52] Imp Step
		5484, -- [53] Howl of Terror
		6789, -- [54] Mortal Coil
		386864, -- [55] Wrathful Minion
		386648, -- [56] Nightmare
		710, -- [57] Banish
		386651, -- [58] Greater Banish
		30283, -- [59] Shadowfury
		264874, -- [60] Darkfury
		384069, -- [61] Shadowflame
		386646, -- [62] Lifeblood
		386244, -- [63] Summon Soulkeeper
		386344, -- [64] Inquisitor's Gaze
		385881, -- [65] Teachings of the Black Harvest
		386664, -- [66] Ichor of Devils
		386686, -- [67] Frequent Donor
		108416, -- [68] Dark Pact
		387972, -- [69] Foul Mouth
		328774, -- [70] Amplify Curse
		268358, -- [71] Demonic Circle
		386113, -- [72] Quick Fiends
		333889, -- [73] Fel Domination
		288843, -- [74] Demonic Embrace
		386619, -- [75] Desperate Power
		386858, -- [76] Demonic Inspiration
		386620, -- [77] Sweet Souls
		386689, -- [78] Claw of Endereth
		108415, -- [79] Soul Link
		171975, -- [80] Grimoire of Synergy
		215941, -- [81] Soul Conduit
		386617, -- [82] Demonic Fortitude
		389576, -- [83] Soul Armor
		389367, -- [84] Fel Synergy
		389590, -- [85] Demonic Resilience
		389623, -- [86] Gorefiend's Resolve
		389359, -- [87] Resolute Barrier
		111898, -- [88] Grimoire: Felguard
	},
	-- Demonology Warlock
	[266] = {
		387259, -- [0] Flashpoint
		388832, -- [1] Scalding Flames
		270545, -- [2] Inferno
		152108, -- [3] Cataclysm
		387095, -- [4] Pyrogenics
		387093, -- [5] Improved Immolate
		387176, -- [6] Decimation
		6353, -- [7] Soul Fire
		387506, -- [8] Mayhem [NYI]
		80240, -- [9] Havoc
		205148, -- [10] Reverse Entropy
		266134, -- [11] Internal Combustion
		387509, -- [12] Pandemonium
		387522, -- [13] Cry Havoc
		196408, -- [14] Fire and Brimstone
		387384, -- [15] Backlash
		196412, -- [16] Eradication
		1122, -- [17] Summon Infernal
		388827, -- [18] Explosive Potential
		17877, -- [19] Shadowburn
		387108, -- [20] Conflagration of Chaos
		387103, -- [21] Ruin
		387166, -- [22] Raging Demonfire
		196447, -- [23] Channel Demonfire
		205184, -- [24] Roaring Blaze
		231793, -- [25] Improved Conflagrate
		196406, -- [26] Backdraft
		17962, -- [27] Conflagrate
		116858, -- [28] Chaos Bolt
		5740, -- [29] Rain of Fire
		108503, -- [30] Grimoire of Sacrifice
		387156, -- [31] Ritual of Ruin
		387252, -- [32] Ashen Remains
		387173, -- [33] Embers of the Diabolic
		387400, -- [34] Madness of the Azj'Aqir
		387275, -- [35] Chaos Incarnate
		387976, -- [36] Dimensional Rift
		387279, -- [37] Power Overwhelming
		387153, -- [38] Burn to Ashes
		387159, -- [39] Avatar of Destruction
		387165, -- [40] Master Ritualist
		387569, -- [41] Rolling Havoc
		387355, -- [42] Crashing Chaos
		266086, -- [43] Rain of Chaos
		387084, -- [44] Wilfred's Sigil of Superior Summoning
		387475, -- [45] Infernal Brand
		385899, -- [46] Soulburn
		317138, -- [47] Strength of Will
		386659, -- [48] Demonic Durability
		111771, -- [49] Demonic Gateway
		389609, -- [50] Abyss Walker
		386613, -- [51] Accrued Vitality
		219272, -- [52] Demon Skin
		386105, -- [53] Curses of Enfeeblement
		386124, -- [54] Fel Armor
		111400, -- [55] Burning Rush
		386110, -- [56] Imp Step
		5484, -- [57] Howl of Terror
		6789, -- [58] Mortal Coil
		386864, -- [59] Wrathful Minion
		386648, -- [60] Nightmare
		710, -- [61] Banish
		386651, -- [62] Greater Banish
		30283, -- [63] Shadowfury
		264874, -- [64] Darkfury
		384069, -- [65] Shadowflame
		386646, -- [66] Lifeblood
		386244, -- [67] Summon Soulkeeper
		386344, -- [68] Inquisitor's Gaze
		385881, -- [69] Teachings of the Black Harvest
		386664, -- [70] Ichor of Devils
		386686, -- [71] Frequent Donor
		108416, -- [72] Dark Pact
		387972, -- [73] Foul Mouth
		328774, -- [74] Amplify Curse
		268358, -- [75] Demonic Circle
		386113, -- [76] Quick Fiends
		333889, -- [77] Fel Domination
		288843, -- [78] Demonic Embrace
		386619, -- [79] Desperate Power
		386858, -- [80] Demonic Inspiration
		386620, -- [81] Sweet Souls
		386689, -- [82] Claw of Endereth
		108415, -- [83] Soul Link
		171975, -- [84] Grimoire of Synergy
		215941, -- [85] Soul Conduit
		386617, -- [86] Demonic Fortitude
		389576, -- [87] Soul Armor
		389367, -- [88] Fel Synergy
		389590, -- [89] Demonic Resilience
		389623, -- [90] Gorefiend's Resolve
		389359, -- [91] Resolute Barrier
	},
	-- Destruction Warlock
	[267] = {
		387259, -- [0] Flashpoint
		388832, -- [1] Scalding Flames
		270545, -- [2] Inferno
		152108, -- [3] Cataclysm
		387095, -- [4] Pyrogenics
		387093, -- [5] Improved Immolate
		387176, -- [6] Decimation
		6353, -- [7] Soul Fire
		387506, -- [8] Mayhem [NYI]
		80240, -- [9] Havoc
		205148, -- [10] Reverse Entropy
		266134, -- [11] Internal Combustion
		387509, -- [12] Pandemonium
		387522, -- [13] Cry Havoc
		196408, -- [14] Fire and Brimstone
		387384, -- [15] Backlash
		196412, -- [16] Eradication
		1122, -- [17] Summon Infernal
		388827, -- [18] Explosive Potential
		17877, -- [19] Shadowburn
		387108, -- [20] Conflagration of Chaos
		387103, -- [21] Ruin
		387166, -- [22] Raging Demonfire
		196447, -- [23] Channel Demonfire
		205184, -- [24] Roaring Blaze
		231793, -- [25] Improved Conflagrate
		196406, -- [26] Backdraft
		17962, -- [27] Conflagrate
		116858, -- [28] Chaos Bolt
		5740, -- [29] Rain of Fire
		108503, -- [30] Grimoire of Sacrifice
		387156, -- [31] Ritual of Ruin
		387252, -- [32] Ashen Remains
		387173, -- [33] Embers of the Diabolic
		387400, -- [34] Madness of the Azj'Aqir
		387275, -- [35] Chaos Incarnate
		387976, -- [36] Dimensional Rift
		387279, -- [37] Power Overwhelming
		387153, -- [38] Burn to Ashes
		387159, -- [39] Avatar of Destruction
		387165, -- [40] Master Ritualist
		387569, -- [41] Rolling Havoc
		387355, -- [42] Crashing Chaos
		266086, -- [43] Rain of Chaos
		387084, -- [44] Wilfred's Sigil of Superior Summoning
		387475, -- [45] Infernal Brand
		385899, -- [46] Soulburn
		317138, -- [47] Strength of Will
		386659, -- [48] Demonic Durability
		111771, -- [49] Demonic Gateway
		389609, -- [50] Abyss Walker
		386613, -- [51] Accrued Vitality
		219272, -- [52] Demon Skin
		386105, -- [53] Curses of Enfeeblement
		386124, -- [54] Fel Armor
		111400, -- [55] Burning Rush
		386110, -- [56] Imp Step
		5484, -- [57] Howl of Terror
		6789, -- [58] Mortal Coil
		386864, -- [59] Wrathful Minion
		386648, -- [60] Nightmare
		710, -- [61] Banish
		386651, -- [62] Greater Banish
		30283, -- [63] Shadowfury
		264874, -- [64] Darkfury
		384069, -- [65] Shadowflame
		386646, -- [66] Lifeblood
		386244, -- [67] Summon Soulkeeper
		386344, -- [68] Inquisitor's Gaze
		385881, -- [69] Teachings of the Black Harvest
		386664, -- [70] Ichor of Devils
		386686, -- [71] Frequent Donor
		108416, -- [72] Dark Pact
		387972, -- [73] Foul Mouth
		328774, -- [74] Amplify Curse
		268358, -- [75] Demonic Circle
		386113, -- [76] Quick Fiends
		333889, -- [77] Fel Domination
		288843, -- [78] Demonic Embrace
		386619, -- [79] Desperate Power
		386858, -- [80] Demonic Inspiration
		386620, -- [81] Sweet Souls
		386689, -- [82] Claw of Endereth
		108415, -- [83] Soul Link
		171975, -- [84] Grimoire of Synergy
		215941, -- [85] Soul Conduit
		386617, -- [86] Demonic Fortitude
		389576, -- [87] Soul Armor
		389367, -- [88] Fel Synergy
		389590, -- [89] Demonic Resilience
		389623, -- [90] Gorefiend's Resolve
		389359, -- [91] Resolute Barrier
	},
	-- Brewmaster Monk
	[268] = {
		387035, -- [0] Fundamental Observation
		322510, -- [1] Celestial Brew
		322507, -- [2] Celestial Brew
		196736, -- [3] Blackout Combo
		387046, -- [4] Elusive Footwork
		324312, -- [5] Clash
		389982, -- [6] Shocking Blow [NYI]
		387638, -- [7] Shadowboxing Treads
		387230, -- [8] Fluidity of Motion
		389942, -- [9] Face Palm
		383785, -- [10] Counterstrike
		356684, -- [11] Call to Arms
		352188, -- [12] Effusive Anima Accelerator
		387184, -- [13] Weapons of Order
		386937, -- [14] Anvil & Stave
		325093, -- [15] Light Brewing
		383714, -- [16] Training of Niuzao
		121253, -- [17] Keg Smash
		115069, -- [18] Stagger
		124502, -- [19] Gift of the Ox
		119582, -- [20] Purifying Brew
		122281, -- [21] Healing Elixir
		322120, -- [22] Shuffle
		388505, -- [23] Quick Sip
		387256, -- [24] Graceful Exit
		115399, -- [25] Black Ox Brew
		280515, -- [26] Bob and Weave
		343743, -- [27] Purifying Brew
		387625, -- [28] Staggering Strikes
		383695, -- [29] Hit Scheme
		325177, -- [30] Celestial Flames
		115181, -- [31] Breath of Fire
		383994, -- [32] Dragonfire Brew
		386965, -- [33] Charred Passions
		383698, -- [34] Scalding Brew
		383697, -- [35] Sal'salabim's Strength
		196737, -- [36] High Tolerance
		322960, -- [37] Fortifying Brew
		386949, -- [38] Bountiful Brew
		386941, -- [39] Attenuation
		386276, -- [40] Bonedust Brew
		322740, -- [41] Invoke Niuzao, the Black Ox
		383707, -- [42] Stormstout's Last Keg
		325153, -- [43] Exploding Keg
		387219, -- [44] Walk with the Ox
		132578, -- [45] Invoke Niuzao, the Black Ox
		387276, -- [46] Strength of Spirit
		383700, -- [47] Gai Plin's Imperial Brew
		115176, -- [48] Zen Meditation
		116847, -- [49] Rushing Jade Wind
		196730, -- [50] Special Delivery
		231602, -- [51] Vivify
		107428, -- [52] Rising Sun Kick
		116841, -- [53] Tiger's Lust
		115078, -- [54] Paralysis
		116095, -- [55] Disable
		344359, -- [56] Paralysis
		115203, -- [57] Fortifying Brew
		115315, -- [58] Summon Black Ox Statue
		389577, -- [59] Bounce Back
		389575, -- [60] Generous Pour
		387276, -- [61] Strength of Spirit
		322960, -- [62] Fortifying Brew
		388813, -- [63] Fortifying Brew
		264348, -- [64] Tiger Tail Sweep
		388681, -- [65] Elusive Mists
		328670, -- [66] Provoke
		122783, -- [67] Diffuse Magic
		115098, -- [68] Chi Wave
		123986, -- [69] Chi Burst
		392910, -- [70] Profound Rebuttal
		389574, -- [71] Close to Heart
		115313, -- [72] Summon Jade Serpent Statue
		389579, -- [73] Save Them All
		343250, -- [74] Escape from Reality
		157411, -- [75] Windwalking
		196607, -- [76] Eye of the Tiger
		116844, -- [77] Ring of Peace
		122278, -- [78] Dampen Harm
		388809, -- [79] Fast Feet
		101643, -- [80] Transcendence
		388812, -- [81] Vivacious Vivification
		388811, -- [82] Grace of the Crane
		392900, -- [83] Vigorous Expulsion
		109132, -- [84] Roll
		388686, -- [85] Summon White Tiger Statue
		389578, -- [86] Resonant Fists
		337296, -- [87] Fatal Touch
		322113, -- [88] Touch of Death
		115173, -- [89] Celerity
		115008, -- [90] Chi Torpedo
		116705, -- [91] Spear Hand Strike
		388674, -- [92] Ferocity of Xuen
		218164, -- [93] Detox
		388664, -- [94] Calming Presence
		115175, -- [95] Soothing Mist
	},
	-- Windwalker Monk
	[269] = {
		388779, -- [0] Awakened Faeline
		388740, -- [1] Ancient Concordance
		388509, -- [2] Restorative Proliferation
		388517, -- [3] Tea of Plenty
		388511, -- [4] Overflowing Mists
		388023, -- [5] Ancient Teachings of the Monastery
		388047, -- [6] Clouded Focus
		197900, -- [7] Mist Wrap
		196725, -- [8] Refreshing Jade Wind
		388593, -- [9] Peaceful Mending
		231602, -- [10] Vivify
		107428, -- [11] Rising Sun Kick
		116841, -- [12] Tiger's Lust
		115078, -- [13] Paralysis
		116095, -- [14] Disable
		344359, -- [15] Paralysis
		115203, -- [16] Fortifying Brew
		115315, -- [17] Summon Black Ox Statue
		389577, -- [18] Bounce Back
		389575, -- [19] Generous Pour
		387276, -- [20] Strength of Spirit
		322960, -- [21] Fortifying Brew
		388813, -- [22] Fortifying Brew
		264348, -- [23] Tiger Tail Sweep
		388681, -- [24] Elusive Mists
		328670, -- [25] Provoke
		122783, -- [26] Diffuse Magic
		115098, -- [27] Chi Wave
		123986, -- [28] Chi Burst
		392910, -- [29] Profound Rebuttal
		389574, -- [30] Close to Heart
		115313, -- [31] Summon Jade Serpent Statue
		389579, -- [32] Save Them All
		343250, -- [33] Escape from Reality
		157411, -- [34] Windwalking
		196607, -- [35] Eye of the Tiger
		116844, -- [36] Ring of Peace
		122278, -- [37] Dampen Harm
		388809, -- [38] Fast Feet
		101643, -- [39] Transcendence
		388812, -- [40] Vivacious Vivification
		388811, -- [41] Grace of the Crane
		392900, -- [42] Vigorous Expulsion
		109132, -- [43] Roll
		388686, -- [44] Summon White Tiger Statue
		389578, -- [45] Resonant Fists
		337296, -- [46] Fatal Touch
		322113, -- [47] Touch of Death
		115173, -- [48] Celerity
		115008, -- [49] Chi Torpedo
		116705, -- [50] Spear Hand Strike
		388674, -- [51] Ferocity of Xuen
		218164, -- [52] Detox
		388664, -- [53] Calming Presence
		115175, -- [54] Soothing Mist
		343655, -- [55] Enveloping Breath
		388661, -- [56] Invoker's Delight
		388477, -- [57] Unison
		388491, -- [58] Secret Infusion
		388031, -- [59] Jade Bond
		388212, -- [60] Gift of the Celestials
		116645, -- [61] Teachings of the Monastery
		210802, -- [62] Spirit of the Crane
		388038, -- [63] Yu'lon's Whisper
		388193, -- [64] Faeline Stomp
		388218, -- [65] Calming Coalescence
		387765, -- [66] Nourishing Chi
		388548, -- [67] Mists of Life
		116849, -- [68] Life Cocoon
		191837, -- [69] Essence Font
		124682, -- [70] Enveloping Mist
		281231, -- [71] Mastery of Mist
		274586, -- [72] Invigorating Mists
		115151, -- [73] Renewing Mist
		116680, -- [74] Thunder Focus Tea
		337209, -- [75] Font of Life
		388551, -- [76] Uplifted Spirits
		115310, -- [77] Revival
		388615, -- [78] Restoral
		388604, -- [79] Zen Reverberation
		388564, -- [80] Accumulating Mist
		124081, -- [81] Zen Pulse
		198898, -- [82] Song of Chi-Ji
		122281, -- [83] Healing Elixir
		388847, -- [84] Rapid Diffusion
		197915, -- [85] Lifecycles
		197908, -- [86] Mana Tea
		386276, -- [87] Bonedust Brew
		386949, -- [88] Bountiful Brew
		386941, -- [89] Attenuation
		388020, -- [90] Resplendent Mist
		387991, -- [91] Tear of Morning
		274909, -- [92] Rising Mist
		388682, -- [93] Misty Peaks
		197895, -- [94] Focused Thunder
		274963, -- [95] Upwelling
		388701, -- [96] Dancing Mists
		322118, -- [97] Invoke Yu'lon, the Jade Serpent
		325197, -- [98] Invoke Chi-Ji, the Red Crane
	},
	-- Mistweaver Monk
	[270] = {
		387035, -- [0] Fundamental Observation
		322510, -- [1] Celestial Brew
		322507, -- [2] Celestial Brew
		196736, -- [3] Blackout Combo
		387046, -- [4] Elusive Footwork
		324312, -- [5] Clash
		389982, -- [6] Shocking Blow [NYI]
		387638, -- [7] Shadowboxing Treads
		387230, -- [8] Fluidity of Motion
		389942, -- [9] Face Palm
		383785, -- [10] Counterstrike
		356684, -- [11] Call to Arms
		352188, -- [12] Effusive Anima Accelerator
		387184, -- [13] Weapons of Order
		386937, -- [14] Anvil & Stave
		325093, -- [15] Light Brewing
		383714, -- [16] Training of Niuzao
		121253, -- [17] Keg Smash
		115069, -- [18] Stagger
		124502, -- [19] Gift of the Ox
		119582, -- [20] Purifying Brew
		122281, -- [21] Healing Elixir
		322120, -- [22] Shuffle
		388505, -- [23] Quick Sip
		387256, -- [24] Graceful Exit
		115399, -- [25] Black Ox Brew
		280515, -- [26] Bob and Weave
		343743, -- [27] Purifying Brew
		387625, -- [28] Staggering Strikes
		383695, -- [29] Hit Scheme
		325177, -- [30] Celestial Flames
		115181, -- [31] Breath of Fire
		383994, -- [32] Dragonfire Brew
		386965, -- [33] Charred Passions
		383698, -- [34] Scalding Brew
		383697, -- [35] Sal'salabim's Strength
		196737, -- [36] High Tolerance
		322960, -- [37] Fortifying Brew
		386949, -- [38] Bountiful Brew
		386941, -- [39] Attenuation
		386276, -- [40] Bonedust Brew
		322740, -- [41] Invoke Niuzao, the Black Ox
		383707, -- [42] Stormstout's Last Keg
		325153, -- [43] Exploding Keg
		387219, -- [44] Walk with the Ox
		132578, -- [45] Invoke Niuzao, the Black Ox
		387276, -- [46] Strength of Spirit
		383700, -- [47] Gai Plin's Imperial Brew
		115176, -- [48] Zen Meditation
		116847, -- [49] Rushing Jade Wind
		196730, -- [50] Special Delivery
		231602, -- [51] Vivify
		107428, -- [52] Rising Sun Kick
		116841, -- [53] Tiger's Lust
		115078, -- [54] Paralysis
		116095, -- [55] Disable
		344359, -- [56] Paralysis
		115203, -- [57] Fortifying Brew
		115315, -- [58] Summon Black Ox Statue
		389577, -- [59] Bounce Back
		389575, -- [60] Generous Pour
		387276, -- [61] Strength of Spirit
		322960, -- [62] Fortifying Brew
		388813, -- [63] Fortifying Brew
		264348, -- [64] Tiger Tail Sweep
		388681, -- [65] Elusive Mists
		328670, -- [66] Provoke
		122783, -- [67] Diffuse Magic
		115098, -- [68] Chi Wave
		123986, -- [69] Chi Burst
		392910, -- [70] Profound Rebuttal
		389574, -- [71] Close to Heart
		115313, -- [72] Summon Jade Serpent Statue
		389579, -- [73] Save Them All
		343250, -- [74] Escape from Reality
		157411, -- [75] Windwalking
		196607, -- [76] Eye of the Tiger
		116844, -- [77] Ring of Peace
		122278, -- [78] Dampen Harm
		388809, -- [79] Fast Feet
		101643, -- [80] Transcendence
		388812, -- [81] Vivacious Vivification
		388811, -- [82] Grace of the Crane
		392900, -- [83] Vigorous Expulsion
		109132, -- [84] Roll
		388686, -- [85] Summon White Tiger Statue
		389578, -- [86] Resonant Fists
		337296, -- [87] Fatal Touch
		322113, -- [88] Touch of Death
		115173, -- [89] Celerity
		115008, -- [90] Chi Torpedo
		116705, -- [91] Spear Hand Strike
		388674, -- [92] Ferocity of Xuen
		218164, -- [93] Detox
		388664, -- [94] Calming Presence
		115175, -- [95] Soothing Mist
	},
	-- Havoc Demon Hunter
	[577] = {
		207666, -- [0] Concentrated Sigils
		389799, -- [1] Precise Sigils
		389978, -- [2] Dancing with Fate
		206416, -- [3] First Blood
		388109, -- [4] Felfire Heart
		320374, -- [5] Burning Hatred
		343017, -- [6] Improved Fel Rush
		393029, -- [7] Furious Throws
		198013, -- [8] Eye Beam
		258881, -- [9] Trail of Ruin
		389688, -- [10] Tactical Retreat
		320413, -- [11] Critical Chaos
		388108, -- [12] Initiative
		388113, -- [13] Isolated Prey
		205411, -- [14] Desperate Instincts
		391397, -- [15] Erratic Felheart
		320412, -- [16] Chaos Fragments
		206477, -- [17] Unleashed Power
		389846, -- [18] Felfire Haste
		320418, -- [19] Improved Sigil of Misery
		388110, -- [20] Misery in Defeat
		389781, -- [21] Long Night
		389783, -- [22] Pitch Black
		389811, -- [23] Unnatural Malice
		389819, -- [24] Fae Empowered Elixir
		370965, -- [25] The Hunt
		196718, -- [26] Darkness
		217832, -- [27] Imprison
		207347, -- [28] Aura of Pain
		232893, -- [29] Felblade
		320361, -- [30] Improved Disrupt
		183782, -- [31] Disrupting Fury
		204909, -- [32] Soul Rending
		213410, -- [33] Demonic
		235893, -- [34] Demonic Origins
		207684, -- [35] Sigil of Misery
		209281, -- [36] Quickened Sigils
		391409, -- [37] Aldrachi Design
		389697, -- [38] Extended Sigils
		388111, -- [39] Demon Muzzle [NYI]
		202137, -- [40] Sigil of Silence
		389695, -- [41] Will of the Illidari
		179057, -- [42] Chaos Nova
		198589, -- [43] Blur
		389694, -- [44] Flames of Fury
		389824, -- [45] Shattered Restoration
		204596, -- [46] Sigil of Flame
		320416, -- [47] Hot Feet
		320386, -- [48] Bouncing Glaives
		278326, -- [49] Consume Magic
		320313, -- [50] Consume Magic
		320331, -- [51] Infernal Armor
		320421, -- [52] Rush of Chaos
		198793, -- [53] Vengeful Retreat
		320770, -- [54] Unrestrained Fury
		320654, -- [55] Pursuit
		389763, -- [56] Master of the Glaive
		389696, -- [57] Illidari Knowledge
		390142, -- [58] Restless Hunter
		343311, -- [59] Furious Gaze
		203550, -- [60] Blind Fury
		258876, -- [61] Insatiable Hunger
		203555, -- [62] Demon Blades
		347461, -- [63] Unbound Chaos
		389977, -- [64] Relentless Onslaught
		391275, -- [65] Mo'arg Bionics
		342817, -- [66] Glaive Tempest
		258925, -- [67] Fel Barrage
		388107, -- [68] Ragefire
		388106, -- [69] Soulrend
		388114, -- [70] Any Means Necessary
		391429, -- [71] Fodder to the Flame
		390163, -- [72] Elysian Decree
		389693, -- [73] Inner Demon
		388112, -- [74] Chaotic Transformation
		390154, -- [75] Serrated Glaive
		390158, -- [76] Growing Inferno
		388118, -- [77] Know Your Enemy
		389687, -- [78] Chaos Theory
		258860, -- [79] Essence Break
		258887, -- [80] Cycle of Hatred
		206476, -- [81] Momentum
		391189, -- [82] Burning Wound
		320415, -- [83] Looks Can Kill
		388116, -- [84] Shattered Destiny
		196555, -- [85] Netherwalk
		343206, -- [86] Improved Chaos Strike
		328725, -- [87] Mortal Dance
		211881, -- [88] Fel Eruption
		320635, -- [89] Vengeful Restraint
		206478, -- [90] Demonic Appetite
		213010, -- [91] Charred Warblades
		389849, -- [92] Lost in Darkness
	},
	-- Vengeance Demon Hunter
	[581] = {
		207666, -- [0] Concentrated Sigils
		389799, -- [1] Precise Sigils
		389978, -- [2] Dancing with Fate
		206416, -- [3] First Blood
		388109, -- [4] Felfire Heart
		320374, -- [5] Burning Hatred
		343017, -- [6] Improved Fel Rush
		393029, -- [7] Furious Throws
		198013, -- [8] Eye Beam
		258881, -- [9] Trail of Ruin
		389688, -- [10] Tactical Retreat
		320413, -- [11] Critical Chaos
		388108, -- [12] Initiative
		388113, -- [13] Isolated Prey
		205411, -- [14] Desperate Instincts
		391397, -- [15] Erratic Felheart
		320412, -- [16] Chaos Fragments
		206477, -- [17] Unleashed Power
		389846, -- [18] Felfire Haste
		320418, -- [19] Improved Sigil of Misery
		388110, -- [20] Misery in Defeat
		389781, -- [21] Long Night
		389783, -- [22] Pitch Black
		389811, -- [23] Unnatural Malice
		389819, -- [24] Fae Empowered Elixir
		370965, -- [25] The Hunt
		196718, -- [26] Darkness
		217832, -- [27] Imprison
		207347, -- [28] Aura of Pain
		232893, -- [29] Felblade
		320361, -- [30] Improved Disrupt
		183782, -- [31] Disrupting Fury
		204909, -- [32] Soul Rending
		213410, -- [33] Demonic
		235893, -- [34] Demonic Origins
		207684, -- [35] Sigil of Misery
		209281, -- [36] Quickened Sigils
		391409, -- [37] Aldrachi Design
		389697, -- [38] Extended Sigils
		388111, -- [39] Demon Muzzle [NYI]
		202137, -- [40] Sigil of Silence
		389695, -- [41] Will of the Illidari
		179057, -- [42] Chaos Nova
		198589, -- [43] Blur
		389694, -- [44] Flames of Fury
		389824, -- [45] Shattered Restoration
		204596, -- [46] Sigil of Flame
		320416, -- [47] Hot Feet
		320386, -- [48] Bouncing Glaives
		278326, -- [49] Consume Magic
		320313, -- [50] Consume Magic
		320331, -- [51] Infernal Armor
		320421, -- [52] Rush of Chaos
		198793, -- [53] Vengeful Retreat
		320770, -- [54] Unrestrained Fury
		320654, -- [55] Pursuit
		389763, -- [56] Master of the Glaive
		389696, -- [57] Illidari Knowledge
		390142, -- [58] Restless Hunter
		343311, -- [59] Furious Gaze
		203550, -- [60] Blind Fury
		258876, -- [61] Insatiable Hunger
		203555, -- [62] Demon Blades
		347461, -- [63] Unbound Chaos
		389977, -- [64] Relentless Onslaught
		391275, -- [65] Mo'arg Bionics
		342817, -- [66] Glaive Tempest
		258925, -- [67] Fel Barrage
		388107, -- [68] Ragefire
		388106, -- [69] Soulrend
		388114, -- [70] Any Means Necessary
		391429, -- [71] Fodder to the Flame
		390163, -- [72] Elysian Decree
		389693, -- [73] Inner Demon
		388112, -- [74] Chaotic Transformation
		390154, -- [75] Serrated Glaive
		390158, -- [76] Growing Inferno
		388118, -- [77] Know Your Enemy
		389687, -- [78] Chaos Theory
		258860, -- [79] Essence Break
		258887, -- [80] Cycle of Hatred
		206476, -- [81] Momentum
		391189, -- [82] Burning Wound
		320415, -- [83] Looks Can Kill
		388116, -- [84] Shattered Destiny
		196555, -- [85] Netherwalk
		343206, -- [86] Improved Chaos Strike
		328725, -- [87] Mortal Dance
		211881, -- [88] Fel Eruption
		320635, -- [89] Vengeful Restraint
		206478, -- [90] Demonic Appetite
		213010, -- [91] Charred Warblades
		389849, -- [92] Lost in Darkness
	},
	-- Initial Shaman
	[1444] = {
	},
	-- Initial Warrior
	[1446] = {
	},
	-- Initial Druid
	[1447] = {
	},
	-- Initial Hunter
	[1448] = {
	},
	-- Initial Mage
	[1449] = {
	},
	-- Initial Monk
	[1450] = {
	},
	-- Initial Paladin
	[1451] = {
	},
	-- Initial Priest
	[1452] = {
	},
	-- Initial Rogue
	[1453] = {
	},
	-- Initial Warlock
	[1454] = {
	},
	-- Initial Death Knight
	[1455] = {
	},
	-- Initial Demon Hunter
	[1456] = {
	},
	-- Initial Evoker
	[1465] = {
	},
	-- Devastation Evoker
	[1467] = {
		370821, -- [0] Scintillation
		374251, -- [1] Cauterizing Flame
		375406, -- [2] Obsidian Bulwark
		363916, -- [3] Obsidian Scales
		370897, -- [4] Permeating Chill
		375554, -- [5] Enkindled
		375556, -- [6] Tailwind
		375517, -- [7] Extended Flight
		387761, -- [8] Grovetender's Gift
		358385, -- [9] Landslide
		369913, -- [10] Natural Convergence
		375520, -- [11] Innate Magic
		371806, -- [12] Recall
		376166, -- [13] Draconic Legacy
		370553, -- [14] Tip the Scales
		372469, -- [15] Scarlet Adaptation
		360995, -- [16] Rescue
		369459, -- [17] Source of Magic
		372048, -- [18] Oppressing Roar
		375510, -- [19] Blast Furnace
		376164, -- [20] Suffused With Power
		351338, -- [21] Quell
		375507, -- [22] Roar of Exhilaration
		368432, -- [23] Unravel
		369939, -- [24] Leaping Flames
		369909, -- [25] Protracted Talons
		374346, -- [26] Overawe
		365933, -- [27] Aerial Mastery
		370665, -- [28] Fly With Me
		387341, -- [29] Walloping Blow
		370888, -- [30] Twin Guardian
		374227, -- [31] Zephyr
		375574, -- [32] Pyrexia
		375577, -- [33] Fire Within
		374348, -- [34] Renewing Blaze
		375561, -- [35] Lush Growth
		387787, -- [36] Regenerative Magic
		374968, -- [37] Time Spiral
		371032, -- [38] Terror of the Skies
		365937, -- [39] Ruby Embers
		370837, -- [40] Engulfing Blaze
		369089, -- [41] Volatility
		370962, -- [42] Dense Energy
		376872, -- [43] Ruby Essence Burst
		357211, -- [44] Pyre
		375721, -- [45] Azure Essence Burst
		371016, -- [46] Imposing Presence
		386405, -- [47] Inner Radiance
		375087, -- [48] Dragonrage
		375797, -- [49] Animosity
		386272, -- [50] Might of the Aspects
		376888, -- [51] Ruin
		375725, -- [52] Heat Wave
		386283, -- [53] Catalyze
		368847, -- [54] Firestorm
		370783, -- [55] Snapfire
		375801, -- [56] Burnout
		375783, -- [57] Font of Magic
		370781, -- [58] Imminent Destruction
		386348, -- [59] Onyx Legacy
		376930, -- [60] Attuned to the Dream
		369990, -- [61] Ancient Flame
		375544, -- [62] Tempered Scales
		370845, -- [63] Tyranny
		365585, -- [64] Expunge
		371038, -- [65] Honed Aggression
		375722, -- [66] Essence Attunement
		371034, -- [67] Lay Waste
		359073, -- [68] Eternity Surge
		375618, -- [69] Arcane Intensity
		375757, -- [70] Eternity's Span
		370839, -- [71] Power Swell
		386336, -- [72] Focusing Iris
		386342, -- [73] Arcane Vigor
		370452, -- [74] Shattering Star
		369375, -- [75] Continuum
		375777, -- [76] Causality
		370867, -- [77] Iridescence
		369846, -- [78] Feed the Flames
		370819, -- [79] Everburning Flame
		375796, -- [80] Cascading Power
		369908, -- [81] Power Nexus
		375542, -- [82] Exuberance
		370886, -- [83] Bountiful Bloom
		360806, -- [84] Sleep Walk
		368838, -- [85] Heavy Wingbeats
		375443, -- [86] Clobbering Sweep
		375528, -- [87] Forger of Mountains
		370455, -- [88] Charged Blast
	},
	-- Preservation Evoker
	[1468] = {
		374251, -- [0] Cauterizing Flame
		375406, -- [1] Obsidian Bulwark
		363916, -- [2] Obsidian Scales
		370897, -- [3] Permeating Chill
		375554, -- [4] Enkindled
		375556, -- [5] Tailwind
		375517, -- [6] Extended Flight
		387761, -- [7] Grovetender's Gift
		358385, -- [8] Landslide
		369913, -- [9] Natural Convergence
		375520, -- [10] Innate Magic
		371806, -- [11] Recall
		376166, -- [12] Draconic Legacy
		370553, -- [13] Tip the Scales
		372469, -- [14] Scarlet Adaptation
		360995, -- [15] Rescue
		369459, -- [16] Source of Magic
		372048, -- [17] Oppressing Roar
		375510, -- [18] Blast Furnace
		376164, -- [19] Suffused With Power
		351338, -- [20] Quell
		375507, -- [21] Roar of Exhilaration
		368432, -- [22] Unravel
		369939, -- [23] Leaping Flames
		369909, -- [24] Protracted Talons
		374346, -- [25] Overawe
		365933, -- [26] Aerial Mastery
		370665, -- [27] Fly With Me
		387341, -- [28] Walloping Blow
		370888, -- [29] Twin Guardian
		374227, -- [30] Zephyr
		375574, -- [31] Pyrexia
		375577, -- [32] Fire Within
		374348, -- [33] Renewing Blaze
		375561, -- [34] Lush Growth
		387787, -- [35] Regenerative Magic
		374968, -- [36] Time Spiral
		371032, -- [37] Terror of the Skies
		376930, -- [38] Attuned to the Dream
		369990, -- [39] Ancient Flame
		375544, -- [40] Tempered Scales
		365585, -- [41] Expunge
		377099, -- [42] Sacral Empowerment
		373270, -- [43] Lifebind
		370062, -- [44] Field of Dreams
		359793, -- [45] Fluttering Seedlings
		375722, -- [46] Essence Attunement
		369297, -- [47] Essence Burst
		366155, -- [48] Reversion
		364343, -- [49] Echo
		355936, -- [50] Dream Breath
		362874, -- [51] Temporal Compression
		367226, -- [52] Spiritbloom
		376138, -- [53] Empath
		376150, -- [54] Spiritual Clarity
		371832, -- [55] Cycle of Life
		376239, -- [56] Grace Period
		376210, -- [57] Borrowed Time
		381922, -- [58] Temporal Artificer
		373834, -- [59] Call of Ysera
		376179, -- [60] Lifeforce Mender
		371426, -- [61] Life Giver's Flame
		372527, -- [62] Time Lord
		378196, -- [63] Golden Hour
		357170, -- [64] Time Dilation
		363534, -- [65] Rewind
		373861, -- [66] Temporal Anomaly
		385696, -- [67] Flow State
		376236, -- [68] Resonating Sphere
		376237, -- [69] Nozdormu's Teachings
		371270, -- [70] Time Keeper
		372233, -- [71] Energy Loop
		376240, -- [72] Timeless Magic
		368412, -- [73] Time of Need
		370537, -- [74] Stasis
		376207, -- [75] Delay Harm
		376204, -- [76] Just in Time
		381921, -- [77] Ouroboros
		371257, -- [78] Renewing Breath
		369908, -- [79] Power Nexus
		359816, -- [80] Dream Flight
		375783, -- [81] Font of Magic
		377100, -- [82] Exhilarating Burst
		370960, -- [83] Emerald Communion
		377082, -- [84] Dreamwalker
		377086, -- [85] Rush of Vitality
		375542, -- [86] Exuberance
		370886, -- [87] Bountiful Bloom
		360806, -- [88] Sleep Walk
		368838, -- [89] Heavy Wingbeats
		375443, -- [90] Clobbering Sweep
		375528, -- [91] Forger of Mountains
	},
}

--- @type table<integer,table<integer,integer[]>>
local pvpTalents = {
	-- Arcane Mage
	[62] = {
		[1] = { 61, 3517, 3442, 5488, 637, 635, 5397, 5491, 5492, 3531, 3529, }, -- Arcane Empowerment, Temporal Shield, Netherwind Armor, Ice Wall, Mass Invisibility, Master of Escape, Arcanosphere, Ring of Fire, Precognition, Prismatic Cloak, Kleptomania
		[2] = { 61, 3517, 3442, 5488, 637, 635, 5397, 5491, 5492, 3531, 3529, }, -- Arcane Empowerment, Temporal Shield, Netherwind Armor, Ice Wall, Mass Invisibility, Master of Escape, Arcanosphere, Ring of Fire, Precognition, Prismatic Cloak, Kleptomania
		[3] = { 61, 3517, 3442, 5488, 637, 635, 5397, 5491, 5492, 3531, 3529, }, -- Arcane Empowerment, Temporal Shield, Netherwind Armor, Ice Wall, Mass Invisibility, Master of Escape, Arcanosphere, Ring of Fire, Precognition, Prismatic Cloak, Kleptomania
	},
	-- Fire Mage
	[63] = {
		[1] = { 53, 644, 647, 5389, 828, 5489, 648, 5493, 646, 5495, }, -- Netherwind Armor, World in Flames, Flamecannon, Ring of Fire, Prismatic Cloak, Ice Wall, Greater Pyroblast, Precognition, Pyrokinesis, Glass Cannon
		[2] = { 53, 644, 647, 5389, 828, 5489, 648, 5493, 646, 5495, }, -- Netherwind Armor, World in Flames, Flamecannon, Ring of Fire, Prismatic Cloak, Ice Wall, Greater Pyroblast, Precognition, Pyrokinesis, Glass Cannon
		[3] = { 53, 644, 647, 5389, 828, 5489, 648, 5493, 646, 5495, }, -- Netherwind Armor, World in Flames, Flamecannon, Ring of Fire, Prismatic Cloak, Ice Wall, Greater Pyroblast, Precognition, Pyrokinesis, Glass Cannon
	},
	-- Frost Mage
	[64] = {
		[1] = { 5494, 5490, 3443, 5390, 3532, 5497, 634, 632, 5496, 66, }, -- Precognition, Ring of Fire, Netherwind Armor, Ice Wall, Prismatic Cloak, Snowdrift, Ice Form, Concentrated Coolness, Frost Bomb, Chilled to the Bone
		[2] = { 5494, 5490, 3443, 5390, 3532, 5497, 634, 632, 5496, 66, }, -- Precognition, Ring of Fire, Netherwind Armor, Ice Wall, Prismatic Cloak, Snowdrift, Ice Form, Concentrated Coolness, Frost Bomb, Chilled to the Bone
		[3] = { 5494, 5490, 3443, 5390, 3532, 5497, 634, 632, 5496, 66, }, -- Precognition, Ring of Fire, Netherwind Armor, Ice Wall, Prismatic Cloak, Snowdrift, Ice Form, Concentrated Coolness, Frost Bomb, Chilled to the Bone
	},
	-- Holy Paladin
	[65] = {
		[1] = { 642, 87, 5537, 88, 3618, 859, 82, 85, 86, 5421, 5553, 640, 5501, }, -- Cleanse the Weak, Spreading the Word, Vengeance Aura, Blessed Hands, Hallowed Ground, Light's Grace, Avenging Light, Ultimate Sacrifice, Darkest before the Dawn, Judgments of the Pure, Aura of Reckoning, Divine Vision, Precognition
		[2] = { 642, 87, 5537, 88, 3618, 859, 82, 85, 86, 5421, 5553, 640, 5501, }, -- Cleanse the Weak, Spreading the Word, Vengeance Aura, Blessed Hands, Hallowed Ground, Light's Grace, Avenging Light, Ultimate Sacrifice, Darkest before the Dawn, Judgments of the Pure, Aura of Reckoning, Divine Vision, Precognition
		[3] = { 642, 87, 5537, 88, 3618, 859, 82, 85, 86, 5421, 5553, 640, 5501, }, -- Cleanse the Weak, Spreading the Word, Vengeance Aura, Blessed Hands, Hallowed Ground, Light's Grace, Avenging Light, Ultimate Sacrifice, Darkest before the Dawn, Judgments of the Pure, Aura of Reckoning, Divine Vision, Precognition
	},
	-- Protection Paladin
	[66] = {
		[1] = { 5536, 5554, 861, 860, 97, 90, 91, 92, 93, 94, 844, 3475, 3474, }, -- Vengeance Aura, Aura of Reckoning, Shield of Virtue, Warrior of Light, Guarded by the Light, Hallowed Ground, Steed of Glory, Sacred Duty, Judgments of the Pure, Guardian of the Forgotten Queen, Inquisition, Unbound Freedom, Luminescence
		[2] = { 5536, 5554, 861, 860, 97, 90, 91, 92, 93, 94, 844, 3475, 3474, }, -- Vengeance Aura, Aura of Reckoning, Shield of Virtue, Warrior of Light, Guarded by the Light, Hallowed Ground, Steed of Glory, Sacred Duty, Judgments of the Pure, Guardian of the Forgotten Queen, Inquisition, Unbound Freedom, Luminescence
		[3] = { 5536, 5554, 861, 860, 97, 90, 91, 92, 93, 94, 844, 3475, 3474, }, -- Vengeance Aura, Aura of Reckoning, Shield of Virtue, Warrior of Light, Guarded by the Light, Hallowed Ground, Steed of Glory, Sacred Duty, Judgments of the Pure, Guardian of the Forgotten Queen, Inquisition, Unbound Freedom, Luminescence
	},
	-- Retribution Paladin
	[70] = {
		[1] = { 757, 756, 5422, 858, 754, 753, 752, 81, 755, 641, 751, 5535, }, -- Jurisdiction, Aura of Reckoning, Judgments of the Pure, Law and Order, Lawbringer, Ultimate Retribution, Blessing of Sanctuary, Luminescence, Divine Punisher, Unbound Freedom, Vengeance Aura, Hallowed Ground
		[2] = { 757, 756, 5422, 858, 754, 753, 752, 81, 755, 641, 751, 5535, }, -- Jurisdiction, Aura of Reckoning, Judgments of the Pure, Law and Order, Lawbringer, Ultimate Retribution, Blessing of Sanctuary, Luminescence, Divine Punisher, Unbound Freedom, Vengeance Aura, Hallowed Ground
		[3] = { 757, 756, 5422, 858, 754, 753, 752, 81, 755, 641, 751, 5535, }, -- Jurisdiction, Aura of Reckoning, Judgments of the Pure, Law and Order, Lawbringer, Ultimate Retribution, Blessing of Sanctuary, Luminescence, Divine Punisher, Unbound Freedom, Vengeance Aura, Hallowed Ground
	},
	-- Arms Warrior
	[71] = {
		[1] = { 34, 5547, 28, 29, 31, 32, 33, 3522, 5372, 5376, 3534, }, -- Duel, Rebound, Master and Commander, Shadow of the Colossus, Storm of Destruction, War Banner, Sharpen Blade, Death Sentence, Demolition, Warbringer, Disarm
		[2] = { 34, 5547, 28, 29, 31, 32, 33, 3522, 5372, 5376, 3534, }, -- Duel, Rebound, Master and Commander, Shadow of the Colossus, Storm of Destruction, War Banner, Sharpen Blade, Death Sentence, Demolition, Warbringer, Disarm
		[3] = { 34, 5547, 28, 29, 31, 32, 33, 3522, 5372, 5376, 3534, }, -- Duel, Rebound, Master and Commander, Shadow of the Colossus, Storm of Destruction, War Banner, Sharpen Blade, Death Sentence, Demolition, Warbringer, Disarm
	},
	-- Fury Warrior
	[72] = {
		[1] = { 25, 179, 3533, 5373, 166, 5431, 172, 177, 170, 3528, 5548, 3735, }, -- Death Sentence, Death Wish, Disarm, Demolition, Barbarian, Warbringer, Bloodrage, Enduring Rage, Battle Trance, Master and Commander, Rebound, Slaughterhouse
		[2] = { 25, 179, 3533, 5373, 166, 5431, 172, 177, 170, 3528, 5548, 3735, }, -- Death Sentence, Death Wish, Disarm, Demolition, Barbarian, Warbringer, Bloodrage, Enduring Rage, Battle Trance, Master and Commander, Rebound, Slaughterhouse
		[3] = { 25, 179, 3533, 5373, 166, 5431, 172, 177, 170, 3528, 5548, 3735, }, -- Death Sentence, Death Wish, Disarm, Demolition, Barbarian, Warbringer, Bloodrage, Enduring Rage, Battle Trance, Master and Commander, Rebound, Slaughterhouse
	},
	-- Protection Warrior
	[73] = {
		[1] = { 5374, 24, 168, 167, 845, 831, 833, 171, 173, 175, 178, 5432, }, -- Demolition, Disarm, Bodyguard, Sword and Board, Oppressor, Dragon Charge, Rebound, Morale Killer, Shield Bash, Thunderstruck, Warpath, Warbringer
		[2] = { 5374, 24, 168, 167, 845, 831, 833, 171, 173, 175, 178, 5432, }, -- Demolition, Disarm, Bodyguard, Sword and Board, Oppressor, Dragon Charge, Rebound, Morale Killer, Shield Bash, Thunderstruck, Warpath, Warbringer
		[3] = { 5374, 24, 168, 167, 845, 831, 833, 171, 173, 175, 178, 5432, }, -- Demolition, Disarm, Bodyguard, Sword and Board, Oppressor, Dragon Charge, Rebound, Morale Killer, Shield Bash, Thunderstruck, Warpath, Warbringer
	},
	-- Balance Druid
	[102] = {
		[1] = { 5526, 3728, 836, 3731, 5503, 822, 185, 184, 182, 180, 5515, 834, 5407, 3058, 5383, }, -- Reactive Resin, Protector of the Grove, Faerie Swarm, Thorns, Precognition, Dying Stars, Moonkin Aura, Moon and Stars, Crescent Burn, Celestial Guardian, Malorne's Swiftness, Deep Roots, Owlkin Adept, Star Burst, High Winds
		[2] = { 5526, 3728, 836, 3731, 5503, 822, 185, 184, 182, 180, 5515, 834, 5407, 3058, 5383, }, -- Reactive Resin, Protector of the Grove, Faerie Swarm, Thorns, Precognition, Dying Stars, Moonkin Aura, Moon and Stars, Crescent Burn, Celestial Guardian, Malorne's Swiftness, Deep Roots, Owlkin Adept, Star Burst, High Winds
		[3] = { 5526, 3728, 836, 3731, 5503, 822, 185, 184, 182, 180, 5515, 834, 5407, 3058, 5383, }, -- Reactive Resin, Protector of the Grove, Faerie Swarm, Thorns, Precognition, Dying Stars, Moonkin Aura, Moon and Stars, Crescent Burn, Celestial Guardian, Malorne's Swiftness, Deep Roots, Owlkin Adept, Star Burst, High Winds
	},
	-- Feral Druid
	[103] = {
		[1] = { 820, 3053, 5384, 3751, 612, 5525, 201, 203, 601, 602, 611, 620, }, -- Savage Momentum, Strength of the Wild, High Winds, Leader of the Pack, Fresh Wound, Reactive Resin, Thorns, Freedom of the Herd, Malorne's Swiftness, King of the Jungle, Ferocious Wound, Wicked Claws
		[2] = { 820, 3053, 5384, 3751, 612, 5525, 201, 203, 601, 602, 611, 620, }, -- Savage Momentum, Strength of the Wild, High Winds, Leader of the Pack, Fresh Wound, Reactive Resin, Thorns, Freedom of the Herd, Malorne's Swiftness, King of the Jungle, Ferocious Wound, Wicked Claws
		[3] = { 820, 3053, 5384, 3751, 612, 5525, 201, 203, 601, 602, 611, 620, }, -- Savage Momentum, Strength of the Wild, High Winds, Leader of the Pack, Fresh Wound, Reactive Resin, Thorns, Freedom of the Herd, Malorne's Swiftness, King of the Jungle, Ferocious Wound, Wicked Claws
	},
	-- Guardian Druid
	[104] = {
		[1] = { 842, 49, 50, 51, 52, 192, 193, 5524, 1237, 194, 195, 196, 197, 5410, 3750, }, -- Alpha Challenge, Master Shapeshifter, Toughness, Den Mother, Demoralizing Roar, Raging Frenzy, Sharpened Claws, Reactive Resin, Malorne's Swiftness, Charging Bash, Entangling Claws, Overrun, Emerald Slumber, Grove Protection, Freedom of the Herd
		[2] = { 842, 49, 50, 51, 52, 192, 193, 5524, 1237, 194, 195, 196, 197, 5410, 3750, }, -- Alpha Challenge, Master Shapeshifter, Toughness, Den Mother, Demoralizing Roar, Raging Frenzy, Sharpened Claws, Reactive Resin, Malorne's Swiftness, Charging Bash, Entangling Claws, Overrun, Emerald Slumber, Grove Protection, Freedom of the Herd
		[3] = { 842, 49, 50, 51, 52, 192, 193, 5524, 1237, 194, 195, 196, 197, 5410, 3750, }, -- Alpha Challenge, Master Shapeshifter, Toughness, Den Mother, Demoralizing Roar, Raging Frenzy, Sharpened Claws, Reactive Resin, Malorne's Swiftness, Charging Bash, Entangling Claws, Overrun, Emerald Slumber, Grove Protection, Freedom of the Herd
	},
	-- Restoration Druid
	[105] = {
		[1] = { 5387, 3048, 5514, 5504, 59, 835, 1215, 691, 692, 697, 700, 838, 3752, }, -- Keeper of the Grove, Master Shapeshifter, Malorne's Swiftness, Precognition, Disentanglement, Focused Growth, Early Spring, Reactive Resin, Entangling Bark, Thorns, Deep Roots, High Winds, Mark of the Wild
		[2] = { 5387, 3048, 5514, 5504, 59, 835, 1215, 691, 692, 697, 700, 838, 3752, }, -- Keeper of the Grove, Master Shapeshifter, Malorne's Swiftness, Precognition, Disentanglement, Focused Growth, Early Spring, Reactive Resin, Entangling Bark, Thorns, Deep Roots, High Winds, Mark of the Wild
		[3] = { 5387, 3048, 5514, 5504, 59, 835, 1215, 691, 692, 697, 700, 838, 3752, }, -- Keeper of the Grove, Master Shapeshifter, Malorne's Swiftness, Precognition, Disentanglement, Focused Growth, Early Spring, Reactive Resin, Entangling Bark, Thorns, Deep Roots, High Winds, Mark of the Wild
	},
	-- Blood Death Knight
	[250] = {
		[1] = { 204, 5425, 841, 205, 5513, 609, 608, 607, 3511, 206, 3441, }, -- Rot and Wither, Spellwarden, Murderous Intent, Walking Dead, Necrotic Aura, Death Chain, Last Dance, Blood for Blood, Dark Simulacrum, Strangulate, Decomposing Aura
		[2] = { 204, 5425, 841, 205, 5513, 609, 608, 607, 3511, 206, 3441, }, -- Rot and Wither, Spellwarden, Murderous Intent, Walking Dead, Necrotic Aura, Death Chain, Last Dance, Blood for Blood, Dark Simulacrum, Strangulate, Decomposing Aura
		[3] = { 204, 5425, 841, 205, 5513, 609, 608, 607, 3511, 206, 3441, }, -- Rot and Wither, Spellwarden, Murderous Intent, Walking Dead, Necrotic Aura, Death Chain, Last Dance, Blood for Blood, Dark Simulacrum, Strangulate, Decomposing Aura
	},
	-- Frost Death Knight
	[251] = {
		[1] = { 5512, 702, 701, 5510, 5424, 3512, 5429, 5435, 3743, 3439, }, -- Necrotic Aura, Delirium, Deathchill, Rot and Wither, Spellwarden, Dark Simulacrum, Strangulate, Bitter Chill, Dead of Winter, Shroud of Winter
		[2] = { 5512, 702, 701, 5510, 5424, 3512, 5429, 5435, 3743, 3439, }, -- Necrotic Aura, Delirium, Deathchill, Rot and Wither, Spellwarden, Dark Simulacrum, Strangulate, Bitter Chill, Dead of Winter, Shroud of Winter
		[3] = { 5512, 702, 701, 5510, 5424, 3512, 5429, 5435, 3743, 3439, }, -- Necrotic Aura, Delirium, Deathchill, Rot and Wither, Spellwarden, Dark Simulacrum, Strangulate, Bitter Chill, Dead of Winter, Shroud of Winter
	},
	-- Unholy Death Knight
	[252] = {
		[1] = { 5511, 41, 5423, 5430, 149, 152, 40, 3746, 3747, 5436, 3437, }, -- Rot and Wither, Dark Simulacrum, Spellwarden, Strangulate, Necrotic Wounds, Reanimation, Life and Death, Necromancer's Bargain, Raise Abomination, Doomburst, Necrotic Aura
		[2] = { 5511, 41, 5423, 5430, 149, 152, 40, 3746, 3747, 5436, 3437, }, -- Rot and Wither, Dark Simulacrum, Spellwarden, Strangulate, Necrotic Wounds, Reanimation, Life and Death, Necromancer's Bargain, Raise Abomination, Doomburst, Necrotic Aura
		[3] = { 5511, 41, 5423, 5430, 149, 152, 40, 3746, 3747, 5436, 3437, }, -- Rot and Wither, Dark Simulacrum, Spellwarden, Strangulate, Necrotic Wounds, Reanimation, Life and Death, Necromancer's Bargain, Raise Abomination, Doomburst, Necrotic Aura
	},
	-- Beast Mastery Hunter
	[253] = {
		[1] = { 1214, 5418, 5534, 3730, 3599, 825, 3600, 3604, 693, 3612, 5444, 5441, 824, }, -- Interlope, Tranquilizing Darts, Diamond Ice, Hunting Pack, Survival Tactics, Dire Beast: Basilisk, Dragonscale Armor, Chimaeral Sting, The Beast Within, Roar of Sacrifice, Kindred Beasts, Wild Kingdom, Dire Beast: Hawk
		[2] = { 1214, 5418, 5534, 3730, 3599, 825, 3600, 3604, 693, 3612, 5444, 5441, 824, }, -- Interlope, Tranquilizing Darts, Diamond Ice, Hunting Pack, Survival Tactics, Dire Beast: Basilisk, Dragonscale Armor, Chimaeral Sting, The Beast Within, Roar of Sacrifice, Kindred Beasts, Wild Kingdom, Dire Beast: Hawk
		[3] = { 1214, 5418, 5534, 3730, 3599, 825, 3600, 3604, 693, 3612, 5444, 5441, 824, }, -- Interlope, Tranquilizing Darts, Diamond Ice, Hunting Pack, Survival Tactics, Dire Beast: Basilisk, Dragonscale Armor, Chimaeral Sting, The Beast Within, Roar of Sacrifice, Kindred Beasts, Wild Kingdom, Dire Beast: Hawk
	},
	-- Marksmanship Hunter
	[254] = {
		[1] = { 3614, 5440, 658, 5533, 653, 3729, 651, 5531, 5442, 649, 5419, 659, 660, }, -- Roar of Sacrifice, Consecutive Concussion, Trueshot Mastery, Diamond Ice, Chimaeral Sting, Hunting Pack, Survival Tactics, Interlope, Wild Kingdom, Dragonscale Armor, Tranquilizing Darts, Ranger's Finesse, Sniper Shot
		[2] = { 3614, 5440, 658, 5533, 653, 3729, 651, 5531, 5442, 649, 5419, 659, 660, }, -- Roar of Sacrifice, Consecutive Concussion, Trueshot Mastery, Diamond Ice, Chimaeral Sting, Hunting Pack, Survival Tactics, Interlope, Wild Kingdom, Dragonscale Armor, Tranquilizing Darts, Ranger's Finesse, Sniper Shot
		[3] = { 3614, 5440, 658, 5533, 653, 3729, 651, 5531, 5442, 649, 5419, 659, 660, }, -- Roar of Sacrifice, Consecutive Concussion, Trueshot Mastery, Diamond Ice, Chimaeral Sting, Hunting Pack, Survival Tactics, Interlope, Wild Kingdom, Dragonscale Armor, Tranquilizing Darts, Ranger's Finesse, Sniper Shot
	},
	-- Survival Hunter
	[255] = {
		[1] = { 664, 665, 663, 5420, 3607, 662, 3609, 5532, 3610, 686, 661, 5443, }, -- Sticky Tar, Tracker's Net, Roar of Sacrifice, Tranquilizing Darts, Survival Tactics, Mending Bandage, Chimaeral Sting, Interlope, Dragonscale Armor, Diamond Ice, Hunting Pack, Wild Kingdom
		[2] = { 664, 665, 663, 5420, 3607, 662, 3609, 5532, 3610, 686, 661, 5443, }, -- Sticky Tar, Tracker's Net, Roar of Sacrifice, Tranquilizing Darts, Survival Tactics, Mending Bandage, Chimaeral Sting, Interlope, Dragonscale Armor, Diamond Ice, Hunting Pack, Wild Kingdom
		[3] = { 664, 665, 663, 5420, 3607, 662, 3609, 5532, 3610, 686, 661, 5443, }, -- Sticky Tar, Tracker's Net, Roar of Sacrifice, Tranquilizing Darts, Survival Tactics, Mending Bandage, Chimaeral Sting, Interlope, Dragonscale Armor, Diamond Ice, Hunting Pack, Wild Kingdom
	},
	-- Discipline Priest
	[256] = {
		[1] = { 114, 5480, 109, 100, 98, 5483, 5487, 5498, 111, 855, 5475, 1244, 5416, 126, 123, 117, }, -- Ultimate Radiance, Delivered from Evil, Trinity, Purified Resolve, Purification, Eternal Rest, Catharsis, Precognition, Strength of Soul, Thoughtsteal, Cardinal Mending, Blaze of Light, Inner Light and Shadow, Dark Archangel, Archangel, Dome of Light
		[2] = { 114, 5480, 109, 100, 98, 5483, 5487, 5498, 111, 855, 5475, 1244, 5416, 126, 123, 117, }, -- Ultimate Radiance, Delivered from Evil, Trinity, Purified Resolve, Purification, Eternal Rest, Catharsis, Precognition, Strength of Soul, Thoughtsteal, Cardinal Mending, Blaze of Light, Inner Light and Shadow, Dark Archangel, Archangel, Dome of Light
		[3] = { 114, 5480, 109, 100, 98, 5483, 5487, 5498, 111, 855, 5475, 1244, 5416, 126, 123, 117, }, -- Ultimate Radiance, Delivered from Evil, Trinity, Purified Resolve, Purification, Eternal Rest, Catharsis, Precognition, Strength of Soul, Thoughtsteal, Cardinal Mending, Blaze of Light, Inner Light and Shadow, Dark Archangel, Archangel, Dome of Light
	},
	-- Holy Priest
	[257] = {
		[1] = { 1927, 115, 108, 127, 112, 101, 5476, 124, 5366, 5365, 5482, 5499, 5479, 5485, 5478, }, -- Delivered from Evil, Cardinal Mending, Sanctified Ground, Ray of Hope, Greater Heal, Holy Ward, Strength of Soul, Spirit of the Redeemer, Divine Ascension, Thoughtsteal, Eternal Rest, Precognition, Purified Resolve, Catharsis, Purification
		[2] = { 1927, 115, 108, 127, 112, 101, 5476, 124, 5366, 5365, 5482, 5499, 5479, 5485, 5478, }, -- Delivered from Evil, Cardinal Mending, Sanctified Ground, Ray of Hope, Greater Heal, Holy Ward, Strength of Soul, Spirit of the Redeemer, Divine Ascension, Thoughtsteal, Eternal Rest, Precognition, Purified Resolve, Catharsis, Purification
		[3] = { 1927, 115, 108, 127, 112, 101, 5476, 124, 5366, 5365, 5482, 5499, 5479, 5485, 5478, }, -- Delivered from Evil, Cardinal Mending, Sanctified Ground, Ray of Hope, Greater Heal, Holy Ward, Strength of Soul, Spirit of the Redeemer, Divine Ascension, Thoughtsteal, Eternal Rest, Precognition, Purified Resolve, Catharsis, Purification
	},
	-- Shadow Priest
	[258] = {
		[1] = { 5447, 763, 5500, 113, 5481, 5477, 5381, 5474, 106, 5484, 5486, 739, }, -- Void Volley, Psyfiend, Precognition, Mind Trauma, Delivered from Evil, Strength of Soul, Thoughtsteal, Cardinal Mending, Driven to Madness, Eternal Rest, Catharsis, Void Origins
		[2] = { 5447, 763, 5500, 113, 5481, 5477, 5381, 5474, 106, 5484, 5486, 739, }, -- Void Volley, Psyfiend, Precognition, Mind Trauma, Delivered from Evil, Strength of Soul, Thoughtsteal, Cardinal Mending, Driven to Madness, Eternal Rest, Catharsis, Void Origins
		[3] = { 5447, 763, 5500, 113, 5481, 5477, 5381, 5474, 106, 5484, 5486, 739, }, -- Void Volley, Psyfiend, Precognition, Mind Trauma, Delivered from Evil, Strength of Soul, Thoughtsteal, Cardinal Mending, Driven to Madness, Eternal Rest, Catharsis, Void Origins
	},
	-- Assassination Rogue
	[259] = {
		[1] = { 5517, 5530, 141, 147, 3448, 5405, 3479, 3480, 830, 5408, 5550, }, -- Veil of Midnight, Control is King, Creeping Venom, System Shock, Maneuverability, Dismantle, Death from Above, Smoke Bomb, Hemotoxin, Thick as Thieves, Dagger in the Dark
		[2] = { 5517, 5530, 141, 147, 3448, 5405, 3479, 3480, 830, 5408, 5550, }, -- Veil of Midnight, Control is King, Creeping Venom, System Shock, Maneuverability, Dismantle, Death from Above, Smoke Bomb, Hemotoxin, Thick as Thieves, Dagger in the Dark
		[3] = { 5517, 5530, 141, 147, 3448, 5405, 3479, 3480, 830, 5408, 5550, }, -- Veil of Midnight, Control is King, Creeping Venom, System Shock, Maneuverability, Dismantle, Death from Above, Smoke Bomb, Hemotoxin, Thick as Thieves, Dagger in the Dark
	},
	-- Outlaw Rogue
	[260] = {
		[1] = { 5412, 5516, 5549, 138, 129, 135, 139, 145, 853, 1208, 3421, 3483, 3619, }, -- Enduring Brawler, Veil of Midnight, Dagger in the Dark, Control is King, Maneuverability, Take Your Cut, Drink Up Me Hearties, Dismantle, Boarding Party, Thick as Thieves, Turn the Tables, Smoke Bomb, Death from Above
		[2] = { 5412, 5516, 5549, 138, 129, 135, 139, 145, 853, 1208, 3421, 3483, 3619, }, -- Enduring Brawler, Veil of Midnight, Dagger in the Dark, Control is King, Maneuverability, Take Your Cut, Drink Up Me Hearties, Dismantle, Boarding Party, Thick as Thieves, Turn the Tables, Smoke Bomb, Death from Above
		[3] = { 5412, 5516, 5549, 138, 129, 135, 139, 145, 853, 1208, 3421, 3483, 3619, }, -- Enduring Brawler, Veil of Midnight, Dagger in the Dark, Control is King, Maneuverability, Take Your Cut, Drink Up Me Hearties, Dismantle, Boarding Party, Thick as Thieves, Turn the Tables, Smoke Bomb, Death from Above
	},
	-- Subtlety Rogue
	[261] = {
		[1] = { 856, 146, 5411, 5409, 136, 5529, 5406, 1209, 846, 3462, 153, 3447, }, -- Silhouette, Thief's Bargain, Distracting Mirage, Thick as Thieves, Veil of Midnight, Control is King, Dismantle, Smoke Bomb, Dagger in the Dark, Death from Above, Shadowy Duel, Maneuverability
		[2] = { 856, 146, 5411, 5409, 136, 5529, 5406, 1209, 846, 3462, 153, 3447, }, -- Silhouette, Thief's Bargain, Distracting Mirage, Thick as Thieves, Veil of Midnight, Control is King, Dismantle, Smoke Bomb, Dagger in the Dark, Death from Above, Shadowy Duel, Maneuverability
		[3] = { 856, 146, 5411, 5409, 136, 5529, 5406, 1209, 846, 3462, 153, 3447, }, -- Silhouette, Thief's Bargain, Distracting Mirage, Thick as Thieves, Veil of Midnight, Control is King, Dismantle, Smoke Bomb, Dagger in the Dark, Death from Above, Shadowy Duel, Maneuverability
	},
	-- Elemental Shaman
	[262] = {
		[1] = { 5519, 5415, 5457, 730, 3620, 728, 727, 3491, 3490, 3488, 3062, 3621, }, -- Tidebringer, Seasoned Winds, Precognition, Traveling Storms, Grounding Totem, Control of Lava, Static Field Totem, Unleash Shield, Counterstrike Totem, Skyfury Totem, Spectral Recovery, Swelling Waves
		[2] = { 5519, 5415, 5457, 730, 3620, 728, 727, 3491, 3490, 3488, 3062, 3621, }, -- Tidebringer, Seasoned Winds, Precognition, Traveling Storms, Grounding Totem, Control of Lava, Static Field Totem, Unleash Shield, Counterstrike Totem, Skyfury Totem, Spectral Recovery, Swelling Waves
		[3] = { 5519, 5415, 5457, 730, 3620, 728, 727, 3491, 3490, 3488, 3062, 3621, }, -- Tidebringer, Seasoned Winds, Precognition, Traveling Storms, Grounding Totem, Control of Lava, Static Field Totem, Unleash Shield, Counterstrike Totem, Skyfury Totem, Spectral Recovery, Swelling Waves
	},
	-- Enhancement Shaman
	[263] = {
		[1] = { 5518, 721, 725, 1944, 5414, 722, 3519, 5438, 3622, 3623, 3492, 3489, 3487, 5527, }, -- Tidebringer, Ride the Lightning, Thundercharge, Ethereal Form, Seasoned Winds, Shamanism, Spectral Recovery, Static Field Totem, Grounding Totem, Swelling Waves, Unleash Shield, Counterstrike Totem, Skyfury Totem, Traveling Storms
		[2] = { 5518, 721, 725, 1944, 5414, 722, 3519, 5438, 3622, 3623, 3492, 3489, 3487, 5527, }, -- Tidebringer, Ride the Lightning, Thundercharge, Ethereal Form, Seasoned Winds, Shamanism, Spectral Recovery, Static Field Totem, Grounding Totem, Swelling Waves, Unleash Shield, Counterstrike Totem, Skyfury Totem, Traveling Storms
		[3] = { 5518, 721, 725, 1944, 5414, 722, 3519, 5438, 3622, 3623, 3492, 3489, 3487, 5527, }, -- Tidebringer, Ride the Lightning, Thundercharge, Ethereal Form, Seasoned Winds, Shamanism, Spectral Recovery, Static Field Totem, Grounding Totem, Swelling Waves, Unleash Shield, Counterstrike Totem, Skyfury Totem, Traveling Storms
	},
	-- Restoration Shaman
	[264] = {
		[1] = { 715, 1930, 5458, 5437, 3756, 3755, 714, 5528, 712, 708, 707, 3520, 5388, }, -- Grounding Totem, Tidebringer, Precognition, Unleash Shield, Ancestral Gift, Cleansing Waters, Electrocute, Traveling Storms, Swelling Waves, Counterstrike Totem, Skyfury Totem, Spectral Recovery, Living Tide
		[2] = { 715, 1930, 5458, 5437, 3756, 3755, 714, 5528, 712, 708, 707, 3520, 5388, }, -- Grounding Totem, Tidebringer, Precognition, Unleash Shield, Ancestral Gift, Cleansing Waters, Electrocute, Traveling Storms, Swelling Waves, Counterstrike Totem, Skyfury Totem, Spectral Recovery, Living Tide
		[3] = { 715, 1930, 5458, 5437, 3756, 3755, 714, 5528, 712, 708, 707, 3520, 5388, }, -- Grounding Totem, Tidebringer, Precognition, Unleash Shield, Ancestral Gift, Cleansing Waters, Electrocute, Traveling Storms, Swelling Waves, Counterstrike Totem, Skyfury Totem, Spectral Recovery, Living Tide
	},
	-- Affliction Warlock
	[265] = {
		[1] = { 15, 5506, 12, 11, 20, 19, 18, 5543, 5379, 5546, 5386, 17, 5392, 16, }, -- Gateway Mastery, Precognition, Deathbolt, Bane of Fragility, Casting Circle, Essence Drain, Nether Ward, Call Observer, Rampant Afflictions, Bonds of Fel, Rapid Contagion, Bane of Shadows, Shadow Rift, Rot and Decay
		[2] = { 15, 5506, 12, 11, 20, 19, 18, 5543, 5379, 5546, 5386, 17, 5392, 16, }, -- Gateway Mastery, Precognition, Deathbolt, Bane of Fragility, Casting Circle, Essence Drain, Nether Ward, Call Observer, Rampant Afflictions, Bonds of Fel, Rapid Contagion, Bane of Shadows, Shadow Rift, Rot and Decay
		[3] = { 15, 5506, 12, 11, 20, 19, 18, 5543, 5379, 5546, 5386, 17, 5392, 16, }, -- Gateway Mastery, Precognition, Deathbolt, Bane of Fragility, Casting Circle, Essence Drain, Nether Ward, Call Observer, Rampant Afflictions, Bonds of Fel, Rapid Contagion, Bane of Shadows, Shadow Rift, Rot and Decay
	},
	-- Demonology Warlock
	[266] = {
		[1] = { 158, 156, 3624, 162, 5394, 5505, 5400, 3626, 3625, 5545, 1213, 3506, 165, 3505, }, -- Pleasure through Pain, Call Felhunter, Nether Ward, Call Fel Lord, Shadow Rift, Precognition, Fel Obelisk, Casting Circle, Essence Drain, Bonds of Fel, Master Summoner, Gateway Mastery, Call Observer, Bane of Fragility
		[2] = { 158, 156, 3624, 162, 5394, 5505, 5400, 3626, 3625, 5545, 1213, 3506, 165, 3505, }, -- Pleasure through Pain, Call Felhunter, Nether Ward, Call Fel Lord, Shadow Rift, Precognition, Fel Obelisk, Casting Circle, Essence Drain, Bonds of Fel, Master Summoner, Gateway Mastery, Call Observer, Bane of Fragility
		[3] = { 158, 156, 3624, 162, 5394, 5505, 5400, 3626, 3625, 5545, 1213, 3506, 165, 3505, }, -- Pleasure through Pain, Call Felhunter, Nether Ward, Call Fel Lord, Shadow Rift, Precognition, Fel Obelisk, Casting Circle, Essence Drain, Bonds of Fel, Master Summoner, Gateway Mastery, Call Observer, Bane of Fragility
	},
	-- Destruction Warlock
	[267] = {
		[1] = { 159, 157, 5393, 5544, 3509, 5401, 3510, 5507, 3508, 3502, 164, 5382, }, -- Cremation, Fel Fissure, Shadow Rift, Call Observer, Essence Drain, Bonds of Fel, Casting Circle, Precognition, Nether Ward, Bane of Fragility, Bane of Havoc, Gateway Mastery
		[2] = { 159, 157, 5393, 5544, 3509, 5401, 3510, 5507, 3508, 3502, 164, 5382, }, -- Cremation, Fel Fissure, Shadow Rift, Call Observer, Essence Drain, Bonds of Fel, Casting Circle, Precognition, Nether Ward, Bane of Fragility, Bane of Havoc, Gateway Mastery
		[3] = { 159, 157, 5393, 5544, 3509, 5401, 3510, 5507, 3508, 3502, 164, 5382, }, -- Cremation, Fel Fissure, Shadow Rift, Call Observer, Essence Drain, Bonds of Fel, Casting Circle, Precognition, Nether Ward, Bane of Fragility, Bane of Havoc, Gateway Mastery
	},
	-- Brewmaster Monk
	[268] = {
		[1] = { 765, 1958, 666, 667, 668, 669, 670, 671, 672, 673, 5542, 5541, 5538, 5417, 5552, 843, }, -- Eerie Fermentation, Niuzao's Essence, Microbrew, Hot Trub, Guided Meditation, Avert Harm, Nimble Brew, Incendiary Breath, Double Barrel, Mighty Ox Kick, Wind Waker, Dematerialize, Grapple Weapon, Rodeo, Alpha Tiger, Admonishment
		[2] = { 765, 1958, 666, 667, 668, 669, 670, 671, 672, 673, 5542, 5541, 5538, 5417, 5552, 843, }, -- Eerie Fermentation, Niuzao's Essence, Microbrew, Hot Trub, Guided Meditation, Avert Harm, Nimble Brew, Incendiary Breath, Double Barrel, Mighty Ox Kick, Wind Waker, Dematerialize, Grapple Weapon, Rodeo, Alpha Tiger, Admonishment
		[3] = { 765, 1958, 666, 667, 668, 669, 670, 671, 672, 673, 5542, 5541, 5538, 5417, 5552, 843, }, -- Eerie Fermentation, Niuzao's Essence, Microbrew, Hot Trub, Guided Meditation, Avert Harm, Nimble Brew, Incendiary Breath, Double Barrel, Mighty Ox Kick, Wind Waker, Dematerialize, Grapple Weapon, Rodeo, Alpha Tiger, Admonishment
	},
	-- Windwalker Monk
	[269] = {
		[1] = { 3052, 3744, 3737, 5448, 3050, 3745, 675, 852, 77, 5540, 3734, }, -- Grapple Weapon, Pressure Points, Wind Waker, Perpetual Paralysis, Disabling Reach, Turbo Fists, Tigereye Brew, Reverse Harm, Ride the Wind, Mighty Ox Kick, Alpha Tiger
		[2] = { 3052, 3744, 3737, 5448, 3050, 3745, 675, 852, 77, 5540, 3734, }, -- Grapple Weapon, Pressure Points, Wind Waker, Perpetual Paralysis, Disabling Reach, Turbo Fists, Tigereye Brew, Reverse Harm, Ride the Wind, Mighty Ox Kick, Alpha Tiger
		[3] = { 3052, 3744, 3737, 5448, 3050, 3745, 675, 852, 77, 5540, 3734, }, -- Grapple Weapon, Pressure Points, Wind Waker, Perpetual Paralysis, Disabling Reach, Turbo Fists, Tigereye Brew, Reverse Harm, Ride the Wind, Mighty Ox Kick, Alpha Tiger
	},
	-- Mistweaver Monk
	[270] = {
		[1] = { 5508, 3732, 70, 5539, 5551, 1928, 5402, 5398, 5395, 683, 682, 680, 679, 678, }, -- Precognition, Grapple Weapon, Eminence, Mighty Ox Kick, Alpha Tiger, Zen Focus Tea, Thunderous Focus Tea, Dematerialize, Peaceweaver, Healing Sphere, Refreshing Breeze, Dome of Mist, Counteract Magic, Chrysalis
		[2] = { 5508, 3732, 70, 5539, 5551, 1928, 5402, 5398, 5395, 683, 682, 680, 679, 678, }, -- Precognition, Grapple Weapon, Eminence, Mighty Ox Kick, Alpha Tiger, Zen Focus Tea, Thunderous Focus Tea, Dematerialize, Peaceweaver, Healing Sphere, Refreshing Breeze, Dome of Mist, Counteract Magic, Chrysalis
		[3] = { 5508, 3732, 70, 5539, 5551, 1928, 5402, 5398, 5395, 683, 682, 680, 679, 678, }, -- Precognition, Grapple Weapon, Eminence, Mighty Ox Kick, Alpha Tiger, Zen Focus Tea, Thunderous Focus Tea, Dematerialize, Peaceweaver, Healing Sphere, Refreshing Breeze, Dome of Mist, Counteract Magic, Chrysalis
	},
	-- Havoc Demon Hunter
	[577] = {
		[1] = { 1204, 1206, 811, 5523, 812, 813, 1218, 806, 809, 5433, 810, 805, }, -- Mortal Dance, Cover of Darkness, Rain from Above, Sigil Mastery, Detainment, Glimpse, Unending Hatred, Reverse Magic, Chaotic Imprint, Blood Moon, Demonic Origins, Cleansed by Flame
		[2] = { 1204, 1206, 811, 5523, 812, 813, 1218, 806, 809, 5433, 810, 805, }, -- Mortal Dance, Cover of Darkness, Rain from Above, Sigil Mastery, Detainment, Glimpse, Unending Hatred, Reverse Magic, Chaotic Imprint, Blood Moon, Demonic Origins, Cleansed by Flame
		[3] = { 1204, 1206, 811, 5523, 812, 813, 1218, 806, 809, 5433, 810, 805, }, -- Mortal Dance, Cover of Darkness, Rain from Above, Sigil Mastery, Detainment, Glimpse, Unending Hatred, Reverse Magic, Chaotic Imprint, Blood Moon, Demonic Origins, Cleansed by Flame
	},
	-- Vengeance Demon Hunter
	[581] = {
		[1] = { 814, 815, 5434, 819, 3727, 1220, 5439, 1948, 816, 3423, 3429, 5520, 5521, 5522, 3430, }, -- Cleansed by Flame, Everlasting Hunt, Blood Moon, Illidan's Grasp, Unending Hatred, Tormentor, Chaotic Imprint, Sigil Mastery, Jagged Spikes, Demonic Trample, Reverse Magic, Cover of Darkness, Rain from Above, Glimpse, Detainment
		[2] = { 814, 815, 5434, 819, 3727, 1220, 5439, 1948, 816, 3423, 3429, 5520, 5521, 5522, 3430, }, -- Cleansed by Flame, Everlasting Hunt, Blood Moon, Illidan's Grasp, Unending Hatred, Tormentor, Chaotic Imprint, Sigil Mastery, Jagged Spikes, Demonic Trample, Reverse Magic, Cover of Darkness, Rain from Above, Glimpse, Detainment
		[3] = { 814, 815, 5434, 819, 3727, 1220, 5439, 1948, 816, 3423, 3429, 5520, 5521, 5522, 3430, }, -- Cleansed by Flame, Everlasting Hunt, Blood Moon, Illidan's Grasp, Unending Hatred, Tormentor, Chaotic Imprint, Sigil Mastery, Jagged Spikes, Demonic Trample, Reverse Magic, Cover of Darkness, Rain from Above, Glimpse, Detainment
	},
	-- Initial Shaman
	[1444] = {
		[1] = { },
		[2] = { },
		[3] = { },
	},
	-- Initial Warrior
	[1446] = {
		[1] = { },
		[2] = { },
		[3] = { },
	},
	-- Initial Druid
	[1447] = {
		[1] = { },
		[2] = { },
		[3] = { },
	},
	-- Initial Hunter
	[1448] = {
		[1] = { },
		[2] = { },
		[3] = { },
	},
	-- Initial Mage
	[1449] = {
		[1] = { },
		[2] = { },
		[3] = { },
	},
	-- Initial Monk
	[1450] = {
		[1] = { },
		[2] = { },
		[3] = { },
	},
	-- Initial Paladin
	[1451] = {
		[1] = { },
		[2] = { },
		[3] = { },
	},
	-- Initial Priest
	[1452] = {
		[1] = { },
		[2] = { },
		[3] = { },
	},
	-- Initial Rogue
	[1453] = {
		[1] = { },
		[2] = { },
		[3] = { },
	},
	-- Initial Warlock
	[1454] = {
		[1] = { },
		[2] = { },
		[3] = { },
	},
	-- Initial Death Knight
	[1455] = {
		[1] = { },
		[2] = { },
		[3] = { },
	},
	-- Initial Demon Hunter
	[1456] = {
		[1] = { },
		[2] = { },
		[3] = { },
	},
	-- Initial Evoker
	[1465] = {
		[1] = { },
		[2] = { },
		[3] = { },
	},
	-- Devastation Evoker
	[1467] = {
		[1] = { 5460, 5456, 5471, 5473, 5509, 5469, 5462, 5464, 5466, 5467, }, -- Obsidian Mettle, Chrono Loop, Crippling Force, Divide and Conquer, Precognition, Unburdened Flight, Scouring Flame, Time Stop, You're Coming With Me, Nullifying Shroud
		[2] = { 5460, 5456, 5471, 5473, 5509, 5469, 5462, 5464, 5466, 5467, }, -- Obsidian Mettle, Chrono Loop, Crippling Force, Divide and Conquer, Precognition, Unburdened Flight, Scouring Flame, Time Stop, You're Coming With Me, Nullifying Shroud
		[3] = { 5460, 5456, 5471, 5473, 5509, 5469, 5462, 5464, 5466, 5467, }, -- Obsidian Mettle, Chrono Loop, Crippling Force, Divide and Conquer, Precognition, Unburdened Flight, Scouring Flame, Time Stop, You're Coming With Me, Nullifying Shroud
	},
	-- Preservation Evoker
	[1468] = {
		[1] = { 5459, 5470, 5455, 5454, 5468, 5472, 5502, 5461, 5463, 5465, }, -- Obsidian Mettle, Unburdened Flight, Chrono Loop, Dream Projection, Nullifying Shroud, Divide and Conquer, Precognition, Scouring Flame, Time Stop, You're Coming With Me
		[2] = { 5459, 5470, 5455, 5454, 5468, 5472, 5502, 5461, 5463, 5465, }, -- Obsidian Mettle, Unburdened Flight, Chrono Loop, Dream Projection, Nullifying Shroud, Divide and Conquer, Precognition, Scouring Flame, Time Stop, You're Coming With Me
		[3] = { 5459, 5470, 5455, 5454, 5468, 5472, 5502, 5461, 5463, 5465, }, -- Obsidian Mettle, Unburdened Flight, Chrono Loop, Dream Projection, Nullifying Shroud, Divide and Conquer, Precognition, Scouring Flame, Time Stop, You're Coming With Me
	},
}

LibTalentInfo:RegisterTalentProvider({
	version = version,
	specializations = specializations,
	talents = talents,
	pvpTalentSlotCount = 3,
	pvpTalents = pvpTalents
})
