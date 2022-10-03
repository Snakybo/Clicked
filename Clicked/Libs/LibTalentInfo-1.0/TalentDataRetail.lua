local LibTalentInfo = LibStub and LibStub("LibTalentInfo-1.0", true)
local version = 45779

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
		157980, -- [0] Supernova
		236457, -- [1] Slipstream
		384060, -- [2] Illuminated Thoughts
		321420, -- [3] Improved Clearcasting
		236628, -- [4] Amplification
		383676, -- [5] Impetus
		383782, -- [6] Nether Precision
		321752, -- [7] Crackling Energy
		79684, -- [8] Clearcasting
		365350, -- [9] Arcane Surge
		321526, -- [10] Mana Adept
		321745, -- [11] Improved Prismatic Barrier
		321507, -- [12] Touch of the Magi
		384581, -- [13] Arcane Bombardment
		376103, -- [14] Radiant Spark
		384683, -- [15] Harmonic Echo
		44425, -- [16] Arcane Barrage
		5143, -- [17] Arcane Missiles
		153626, -- [18] Arcane Orb
		383661, -- [19] Improved Arcane Missiles
		384651, -- [20] Charged Orb
		386828, -- [21] Energized Barriers
		30449, -- [22] Spellsteal
		382440, -- [23] Shifting Power
		205036, -- [24] Ice Ward
		386763, -- [25] Freezing Cold
		113724, -- [26] Ring of Frost
		389627, -- [27] Volatile Detonation
		153561, -- [28] Meteor
		31661, -- [29] Dragon's Breath
		389713, -- [30] Displacement
		382800, -- [31] Accumulative Shielding
		383243, -- [32] Time Anomaly
		386539, -- [33] Temporal Warp
		110959, -- [34] Greater Invisibility
		382268, -- [35] Flow of Time
		31589, -- [36] Slow
		382490, -- [37] Tome of Antonidas
		382826, -- [38] Temporal Velocity
		382270, -- [39] Diverted Energy
		342249, -- [40] Master of Time
		157981, -- [41] Blast Wave
		382297, -- [42] Quick Witted
		212653, -- [43] Shimmer
		108839, -- [44] Ice Floes
		383121, -- [45] Mass Polymorph
		382292, -- [46] Cryo-Freeze
		343183, -- [47] Improved Frost Nova
		391102, -- [48] Mass Slow
		382481, -- [49] Rigid Ice
		382289, -- [50] Tempest Barrier
		382293, -- [51] Incantation of Swiftness
		1463, -- [52] Incanter's Flow
		116011, -- [53] Rune of Power
		383092, -- [54] Arcane Warding
		342245, -- [55] Alter Time
		475, -- [56] Remove Curse
		66, -- [57] Invisibility
		390218, -- [58] Overflowing Energy
		235450, -- [59] Prismatic Barrier
		45438, -- [60] Ice Block
		382424, -- [61] Winter's Protection
		55342, -- [62] Mirror Image
		382569, -- [63] Reduplication
		382820, -- [64] Reabsorption
		157997, -- [65] Ice Nova
		382493, -- [66] Tome of Rhonin
		235224, -- [67] Frigid Winds
		387807, -- [68] Time Manipulation
		321739, -- [69] Arcane Power
		342231, -- [70] Arcane Echo
		759, -- [71] Conjure Mana Gem
		384276, -- [72] Cascading Power
		384374, -- [73] Concentration
		384452, -- [74] Arcane Harmony
		384858, -- [75] Orb Barrage
		384612, -- [76] Prodigious Savant
		281482, -- [77] Reverberate
		114923, -- [78] Nether Tempest
		231564, -- [79] Arcing Cleave
		205028, -- [80] Resonance
		235711, -- [81] Chrono Shift
		384861, -- [82] Foresight
		321387, -- [83] Enlightened
		383980, -- [84] Arcane Tempo
		264354, -- [85] Rule of Threes
		205022, -- [86] Arcane Familiar
		205025, -- [87] Presence of Mind
		12051, -- [88] Evocation
		384187, -- [89] Siphon Storm
	},
	-- Fire Mage
	[63] = {
		383860, -- [0] Hyperthermia
		383810, -- [1] Fevered Incantation
		205023, -- [2] Conflagration
		383665, -- [3] Incendiary Eruptions
		205029, -- [4] Flame On
		343230, -- [5] Improved Flamestrike
		2120, -- [6] Flamestrike
		205037, -- [7] Flame Patch
		44457, -- [8] Living Bomb
		383391, -- [9] Feel the Burn
		384174, -- [10] Master of Flame
		205020, -- [11] Pyromaniac
		384033, -- [12] Firefall
		155148, -- [13] Kindling
		383476, -- [14] Phoenix Reborn
		203275, -- [15] Flame Accelerant
		383967, -- [16] Improved Combustion
		383659, -- [17] Tempered Flames
		383489, -- [18] Wildfire
		383634, -- [19] Fiery Rush
		383669, -- [20] Controlled Destruction
		383886, -- [21] Sun King's Blessing
		86949, -- [22] Cauterize
		190319, -- [23] Combustion
		383499, -- [24] Firemind
		269650, -- [25] Pyroclasm
		343222, -- [26] Call of the Sun King
		383604, -- [27] Improved Scorch
		269644, -- [28] Searing Touch
		2948, -- [29] Scorch
		108853, -- [30] Fire Blast
		11366, -- [31] Pyroblast
		387044, -- [32] Fervent Flickering
		257541, -- [33] Phoenix Flames
		157642, -- [34] Pyrotechnics
		117216, -- [35] Critical Mass
		342344, -- [36] From the Ashes
		235870, -- [37] Alexstrasza's Fury
		386828, -- [38] Energized Barriers
		205026, -- [39] Firestarter
		30449, -- [40] Spellsteal
		382440, -- [41] Shifting Power
		205036, -- [42] Ice Ward
		386763, -- [43] Freezing Cold
		113724, -- [44] Ring of Frost
		389627, -- [45] Volatile Detonation
		153561, -- [46] Meteor
		31661, -- [47] Dragon's Breath
		389713, -- [48] Displacement
		382800, -- [49] Accumulative Shielding
		383243, -- [50] Time Anomaly
		386539, -- [51] Temporal Warp
		110959, -- [52] Greater Invisibility
		382268, -- [53] Flow of Time
		31589, -- [54] Slow
		382490, -- [55] Tome of Antonidas
		382826, -- [56] Temporal Velocity
		382270, -- [57] Diverted Energy
		342249, -- [58] Master of Time
		157981, -- [59] Blast Wave
		382297, -- [60] Quick Witted
		212653, -- [61] Shimmer
		108839, -- [62] Ice Floes
		383121, -- [63] Mass Polymorph
		382292, -- [64] Cryo-Freeze
		343183, -- [65] Improved Frost Nova
		391102, -- [66] Mass Slow
		382481, -- [67] Rigid Ice
		382289, -- [68] Tempest Barrier
		382293, -- [69] Incantation of Swiftness
		1463, -- [70] Incanter's Flow
		116011, -- [71] Rune of Power
		383092, -- [72] Arcane Warding
		342245, -- [73] Alter Time
		475, -- [74] Remove Curse
		66, -- [75] Invisibility
		235313, -- [76] Blazing Barrier
		390218, -- [77] Overflowing Energy
		45438, -- [78] Ice Block
		382424, -- [79] Winter's Protection
		55342, -- [80] Mirror Image
		382569, -- [81] Reduplication
		382820, -- [82] Reabsorption
		157997, -- [83] Ice Nova
		382493, -- [84] Tome of Rhonin
		235224, -- [85] Frigid Winds
		387807, -- [86] Time Manipulation
	},
	-- Frost Mage
	[64] = {
		235219, -- [0] Cold Snap
		190356, -- [1] Blizzard
		30455, -- [2] Ice Lance
		84714, -- [3] Frozen Orb
		44614, -- [4] Flurry
		190447, -- [5] Brain Freeze
		205030, -- [6] Frozen Touch
		257537, -- [7] Ebonbolt
		378198, -- [8] Perpetual Winter
		378947, -- [9] Glacial Assault
		153595, -- [10] Comet Storm
		378448, -- [11] Fractured Frost
		382110, -- [12] Cold Front
		385167, -- [13] Everlasting Frost
		378756, -- [14] Frostbite
		386828, -- [15] Energized Barriers
		30449, -- [16] Spellsteal
		382440, -- [17] Shifting Power
		205036, -- [18] Ice Ward
		386763, -- [19] Freezing Cold
		113724, -- [20] Ring of Frost
		389627, -- [21] Volatile Detonation
		153561, -- [22] Meteor
		31661, -- [23] Dragon's Breath
		389713, -- [24] Displacement
		382800, -- [25] Accumulative Shielding
		383243, -- [26] Time Anomaly
		386539, -- [27] Temporal Warp
		110959, -- [28] Greater Invisibility
		382268, -- [29] Flow of Time
		31589, -- [30] Slow
		382490, -- [31] Tome of Antonidas
		382826, -- [32] Temporal Velocity
		382270, -- [33] Diverted Energy
		342249, -- [34] Master of Time
		157981, -- [35] Blast Wave
		382297, -- [36] Quick Witted
		212653, -- [37] Shimmer
		108839, -- [38] Ice Floes
		383121, -- [39] Mass Polymorph
		382292, -- [40] Cryo-Freeze
		343183, -- [41] Improved Frost Nova
		391102, -- [42] Mass Slow
		382481, -- [43] Rigid Ice
		382289, -- [44] Tempest Barrier
		382293, -- [45] Incantation of Swiftness
		1463, -- [46] Incanter's Flow
		116011, -- [47] Rune of Power
		383092, -- [48] Arcane Warding
		342245, -- [49] Alter Time
		475, -- [50] Remove Curse
		11426, -- [51] Ice Barrier
		66, -- [52] Invisibility
		390218, -- [53] Overflowing Energy
		45438, -- [54] Ice Block
		382424, -- [55] Winter's Protection
		55342, -- [56] Mirror Image
		382569, -- [57] Reduplication
		382820, -- [58] Reabsorption
		157997, -- [59] Ice Nova
		382493, -- [60] Tome of Rhonin
		235224, -- [61] Frigid Winds
		387807, -- [62] Time Manipulation
		270233, -- [63] Freezing Rain
		382103, -- [64] Freezing Winds
		378901, -- [65] Snap Freeze
		382144, -- [66] Slick Ice
		378433, -- [67] Icy Propulsion
		278309, -- [68] Chain Reaction
		155149, -- [69] Thermal Void
		199786, -- [70] Glacial Spike
		381244, -- [71] Hailstones
		378749, -- [72] Deep Shatter
		380154, -- [73] Subzero
		56377, -- [74] Splitting Ice
		379049, -- [75] Splintering Cold
		205021, -- [76] Ray of Frost
		112965, -- [77] Fingers of Frost
		12982, -- [78] Shatter
		378919, -- [79] Piercing Cold
		205027, -- [80] Bone Chilling
		379993, -- [81] Flash Freeze
		236662, -- [82] Ice Caller
		381706, -- [83] Snowstorm
		12472, -- [84] Icy Veins
		205024, -- [85] Lonely Winter
		31687, -- [86] Summon Water Elemental
		378406, -- [87] Wintertide
	},
	-- Holy Paladin
	[65] = {
		190784, -- [0] Divine Steed
		376996, -- [1] Seasoned Warhorse
		377016, -- [2] Seal of the Templar
		10326, -- [3] Turn Evil
		377053, -- [4] Seal of Reprisal
		385464, -- [5] Incandescence
		385349, -- [6] Touch of Light
		385427, -- [7] Obduracy
		385728, -- [8] Seal of the Crusader
		391142, -- [9] Zealot's Paragon
		385125, -- [10] Of Dusk and Dawn
		385129, -- [11] Seal of Order
		385416, -- [12] Aspiration of Divinity
		385450, -- [13] Seal of Might
		152262, -- [14] Seraphim
		53376, -- [15] Sanctified Wrath
		385425, -- [16] Seal of Alacrity
		223817, -- [17] Divine Purpose
		105809, -- [18] Holy Avenger
		1022, -- [19] Blessing of Protection
		114154, -- [20] Unbreakable Spirit
		6940, -- [21] Blessing of Sacrifice
		385414, -- [22] Afterimage
		384815, -- [23] Seal of Clarity
		384897, -- [24] Seal of Mercy
		377128, -- [25] Golden Path
		385515, -- [26] Holy Aegis
		183778, -- [27] Judgment of Light
		384820, -- [28] Sacrifice of the Just
		384914, -- [29] Recompense
		384376, -- [30] Avenging Wrath
		230332, -- [31] Cavalier
		96231, -- [32] Rebuke
		231663, -- [33] Greater Judgment
		234299, -- [34] Fist of Justice
		385639, -- [35] Auras of Swift Vengeance
		1044, -- [36] Blessing of Freedom
		385633, -- [37] Auras of the Resolute
		20066, -- [38] Repentance
		115750, -- [39] Blinding Light
		633, -- [40] Lay on Hands
		387893, -- [41] Divine Resonance
		325966, -- [42] Glimmer of Light
		196926, -- [43] Crusader's Might
		388007, -- [44] Blessing of Summer
		248033, -- [45] Awakening
		392907, -- [46] Inflorescence of the Sunwell
		387170, -- [47] Empyrean Legacy
		383388, -- [48] Relentless Inquisitor
		200474, -- [49] Power of the Silver Hand
		200652, -- [50] Tyr's Deliverance
		392951, -- [51] Boundless Salvation
		231642, -- [52] Tower of Radiance
		387805, -- [53] Divine Glimpse
		384442, -- [54] Avenging Wrath: Might
		394088, -- [55] Avenging Crusader
		200482, -- [56] Second Sunrise
		387879, -- [57] Breaking Dawn
		392938, -- [58] Veneration
		387781, -- [59] Commanding Light
		375576, -- [60] Divine Toll
		387808, -- [61] Divine Revelations
		114158, -- [62] Light's Hammer
		114165, -- [63] Holy Prism
		388005, -- [64] Shining Savior
		387791, -- [65] Empyreal Ward
		231667, -- [66] Radiant Onslaught
		24275, -- [67] Hammer of Wrath
		377043, -- [68] Hallowed Ground
		393024, -- [69] Improved Cleanse
		156910, -- [70] Beacon of Faith
		200025, -- [71] Beacon of Virtue
		20473, -- [72] Holy Shock
		387801, -- [73] Echoing Blessings
		392961, -- [74] Imbued Infusions
		148039, -- [75] Barrier of Faith
		388018, -- [76] Maraad's Dying Breath
		387814, -- [77] Untempered Dedication
		183998, -- [78] Light of the Martyr
		214202, -- [79] Rule of Law
		157047, -- [80] Saved by the Light
		387998, -- [81] Unending Light
		223306, -- [82] Bestow Faith
		85222, -- [83] Light of Dawn
		392911, -- [84] Unwavering Spirit
		200430, -- [85] Protection of Tyr
		31821, -- [86] Aura Mastery
		498, -- [87] Divine Protection
		82326, -- [88] Holy Light
		210294, -- [89] Divine Favor
		387786, -- [90] Moment of Compassion
		392902, -- [91] Resplendent Light
		387993, -- [92] Illumination
		392914, -- [93] Divine Insight
		392928, -- [94] Tirion's Devotion
		204018, -- [95] Blessing of Spellwarding
		393114, -- [96] Improved Ardent Defender
		384909, -- [97] Improved Blessing of Protection
	},
	-- Protection Paladin
	[66] = {
		379022, -- [0] Consecration in Flame
		385422, -- [1] Resolute Defender
		378845, -- [2] Focused Enmity
		378457, -- [3] Soaring Shield
		204023, -- [4] Crusader's Judgment
		378285, -- [5] Tyr's Enforcer
		315924, -- [6] Hand of the Protector
		393022, -- [7] Inspiring Vanguard
		190784, -- [8] Divine Steed
		376996, -- [9] Seasoned Warhorse
		377016, -- [10] Seal of the Templar
		10326, -- [11] Turn Evil
		377053, -- [12] Seal of Reprisal
		385464, -- [13] Incandescence
		385349, -- [14] Touch of Light
		385427, -- [15] Obduracy
		385728, -- [16] Seal of the Crusader
		391142, -- [17] Zealot's Paragon
		385125, -- [18] Of Dusk and Dawn
		385129, -- [19] Seal of Order
		385416, -- [20] Aspiration of Divinity
		385450, -- [21] Seal of Might
		152262, -- [22] Seraphim
		53376, -- [23] Sanctified Wrath
		385425, -- [24] Seal of Alacrity
		223817, -- [25] Divine Purpose
		105809, -- [26] Holy Avenger
		1022, -- [27] Blessing of Protection
		114154, -- [28] Unbreakable Spirit
		6940, -- [29] Blessing of Sacrifice
		385414, -- [30] Afterimage
		384815, -- [31] Seal of Clarity
		384897, -- [32] Seal of Mercy
		377128, -- [33] Golden Path
		385515, -- [34] Holy Aegis
		183778, -- [35] Judgment of Light
		384820, -- [36] Sacrifice of the Just
		384914, -- [37] Recompense
		384376, -- [38] Avenging Wrath
		230332, -- [39] Cavalier
		96231, -- [40] Rebuke
		231663, -- [41] Greater Judgment
		234299, -- [42] Fist of Justice
		385639, -- [43] Auras of Swift Vengeance
		1044, -- [44] Blessing of Freedom
		385633, -- [45] Auras of the Resolute
		20066, -- [46] Repentance
		115750, -- [47] Blinding Light
		633, -- [48] Lay on Hands
		53595, -- [49] Hammer of the Righteous
		204019, -- [50] Blessed Hammer
		204074, -- [51] Righteous Protector
		24275, -- [52] Hammer of Wrath
		377043, -- [53] Hallowed Ground
		213644, -- [54] Cleanse Toxins
		383388, -- [55] Relentless Inquisitor
		327193, -- [56] Moment of Glory
		204077, -- [57] Final Stand
		378405, -- [58] Light of the Titans
		31935, -- [59] Avenger's Shield
		385726, -- [60] Barricade of Faith
		378425, -- [61] Uther's Counsel
		209389, -- [62] Bulwark of Order
		321136, -- [63] Shining Light
		387174, -- [64] Eye of Tyr
		375576, -- [65] Divine Toll
		379017, -- [66] Faith's Armor
		386568, -- [67] Inner Light
		280373, -- [68] Redoubt
		393071, -- [69] Strength in Adversity
		380188, -- [70] Crusader's Resolve
		204054, -- [71] Consecrated Ground
		393027, -- [72] Improved Lay on Hands
		386653, -- [73] Bulwark of Righteous Fury
		86659, -- [74] Guardian of Ancient Kings
		152261, -- [75] Holy Shield
		378974, -- [76] Bastion of Light
		85043, -- [77] Grand Crusader
		393030, -- [78] Improved Holy Shield
		379021, -- [79] Sanctuary
		379008, -- [80] Strength of Conviction
		378279, -- [81] Gift of the Golden Val'kyr
		384442, -- [82] Avenging Wrath: Might
		385438, -- [83] Sentinel
		378762, -- [84] Ferren Marcus's Fervor
		31850, -- [85] Ardent Defender
		379043, -- [86] Faith in the Light
		386738, -- [87] Divine Resonance
		379391, -- [88] Quickened Invocations
		204018, -- [89] Blessing of Spellwarding
		393114, -- [90] Improved Ardent Defender
		384909, -- [91] Improved Blessing of Protection
	},
	-- Retribution Paladin
	[70] = {
		267344, -- [0] Art of War
		190784, -- [1] Divine Steed
		376996, -- [2] Seasoned Warhorse
		377016, -- [3] Seal of the Templar
		10326, -- [4] Turn Evil
		377053, -- [5] Seal of Reprisal
		385464, -- [6] Incandescence
		385349, -- [7] Touch of Light
		385427, -- [8] Obduracy
		385728, -- [9] Seal of the Crusader
		391142, -- [10] Zealot's Paragon
		385125, -- [11] Of Dusk and Dawn
		385129, -- [12] Seal of Order
		385416, -- [13] Aspiration of Divinity
		385450, -- [14] Seal of Might
		152262, -- [15] Seraphim
		53376, -- [16] Sanctified Wrath
		385425, -- [17] Seal of Alacrity
		223817, -- [18] Divine Purpose
		105809, -- [19] Holy Avenger
		1022, -- [20] Blessing of Protection
		114154, -- [21] Unbreakable Spirit
		6940, -- [22] Blessing of Sacrifice
		385414, -- [23] Afterimage
		384815, -- [24] Seal of Clarity
		384897, -- [25] Seal of Mercy
		377128, -- [26] Golden Path
		385515, -- [27] Holy Aegis
		183778, -- [28] Judgment of Light
		384820, -- [29] Sacrifice of the Just
		384914, -- [30] Recompense
		384376, -- [31] Avenging Wrath
		230332, -- [32] Cavalier
		96231, -- [33] Rebuke
		231663, -- [34] Greater Judgment
		234299, -- [35] Fist of Justice
		385639, -- [36] Auras of Swift Vengeance
		1044, -- [37] Blessing of Freedom
		385633, -- [38] Auras of the Resolute
		20066, -- [39] Repentance
		115750, -- [40] Blinding Light
		633, -- [41] Lay on Hands
		383342, -- [42] Holy Blade
		184662, -- [43] Shield of Vengeance
		498, -- [44] Divine Protection
		382536, -- [45] Sanctify
		382430, -- [46] Sanctification
		383334, -- [47] Inner Grace
		383185, -- [48] Exorcism
		183218, -- [49] Hand of Hindrance
		383388, -- [50] Relentless Inquisitor
		375576, -- [51] Divine Toll
		384027, -- [52] Divine Resonance
		343527, -- [53] Execution Sentence
		384162, -- [54] Executioner's Will
		387196, -- [55] Executioner's Wrath
		204054, -- [56] Consecrated Ground
		387479, -- [57] Sanctified Ground
		383876, -- [58] Boundless Judgment
		383271, -- [59] Highlord's Judgment
		343721, -- [60] Final Reckoning
		326732, -- [61] Empyrean Power
		53385, -- [62] Divine Storm
		383254, -- [63] Improved Crusader Strike
		386967, -- [64] Holy Crusader
		184575, -- [65] Blade of Justice
		384442, -- [66] Avenging Wrath: Might
		384392, -- [67] Crusade
		255937, -- [68] Wake of Ashes
		383300, -- [69] Ashes to Dust
		384052, -- [70] Radiant Decree
		383350, -- [71] Truth's Wake
		231832, -- [72] Blade of Wrath
		386901, -- [73] Seal of Wrath
		383344, -- [74] Expurgation
		387640, -- [75] Sealed Verdict
		215661, -- [76] Justicar's Vengeance
		205191, -- [77] Eye for an Eye
		383274, -- [78] Templar's Vindication
		383327, -- [79] Final Verdict
		383314, -- [80] Vanguard's Momentum
		383263, -- [81] Blade of Condemnation
		383396, -- [82] Tempest of the Lightbringer
		387170, -- [83] Empyrean Legacy
		24275, -- [84] Hammer of Wrath
		377043, -- [85] Hallowed Ground
		213644, -- [86] Cleanse Toxins
		383304, -- [87] Virtuous Command
		383276, -- [88] Ashes to Ashes
		85804, -- [89] Selfless Healer
		326734, -- [90] Healing Hands
		269569, -- [91] Zeal
		203316, -- [92] Fires of Justice
		382275, -- [93] Consecrated Blade
		383228, -- [94] Improved Judgment
		267610, -- [95] Righteous Verdict
		204018, -- [96] Blessing of Spellwarding
		393114, -- [97] Improved Ardent Defender
		384909, -- [98] Improved Blessing of Protection
	},
	-- Arms Warrior
	[71] = {
		383341, -- [0] Sharpened Blades
		383292, -- [1] Juggernaut
		386634, -- [2] Executioner's Precision
		389306, -- [3] Critical Thinking
		385573, -- [4] Improved Mortal Strike
		383338, -- [5] Valor in Victory
		227847, -- [6] Bladestorm
		386628, -- [7] Unhinged
		390563, -- [8] Hurricane
		383703, -- [9] Fatality
		383154, -- [10] Bloodletting
		389308, -- [11] Deft Experience
		386630, -- [12] Battlelord
		23920, -- [13] Spell Reflection
		5246, -- [14] Intimidating Shout
		382954, -- [15] Cacophonous Roar
		275338, -- [16] Menace
		103827, -- [17] Double Time
		392777, -- [18] Cruel Strikes
		376079, -- [19] Spear of Bastion
		382948, -- [20] Piercing Verdict
		382767, -- [21] Overwhelming Rage
		384404, -- [22] Sidearm
		46968, -- [23] Shockwave
		275339, -- [24] Rumbling Earth
		18499, -- [25] Berserker Rage
		382260, -- [26] Fast Footwork
		382939, -- [27] Reinforced Plates
		384124, -- [28] Armored to the Teeth
		107574, -- [29] Avatar
		390138, -- [30] Blademaster's Torment
		390140, -- [31] Warlord's Torment
		382946, -- [32] Wild Strikes
		384318, -- [33] Thunderous Roar
		384969, -- [34] Thunderous Words
		391572, -- [35] Uproar
		383762, -- [36] Bitter Immunity
		382461, -- [37] Honed Reflexes
		382549, -- [38] Pain and Gain
		392792, -- [39] Frothing Berserker
		384110, -- [40] Wrecking Throw
		64382, -- [41] Shattering Throw
		384100, -- [42] Berserker Shout
		12323, -- [43] Piercing Howl
		382764, -- [44] Crushing Force
		6544, -- [45] Heroic Leap
		382258, -- [46] Leeching Strikes
		6343, -- [47] Thunder Clap
		384277, -- [48] Blood and Thunder
		203201, -- [49] Crackling Thunder
		384090, -- [50] Titanic Throw
		382956, -- [51] Seismic Reverberation
		390713, -- [52] Dance of Death
		383317, -- [53] Merciless Bonegrinder
		385512, -- [54] Storm of Swords
		334779, -- [55] Collateral Damage
		260708, -- [56] Sweeping Strikes
		388807, -- [57] Storm Wall
		12294, -- [58] Mortal Strike
		7384, -- [59] Overpower
		202316, -- [60] Fervor of Battle
		316405, -- [61] Improved Execute
		29725, -- [62] Sudden Death
		383103, -- [63] Fueled by Violence
		118038, -- [64] Die by the Sword
		384361, -- [65] Bloodsurge
		316440, -- [66] Martial Prowess
		385571, -- [67] Improved Overpower
		386357, -- [68] Tide of Blood
		260643, -- [69] Skullsplitter
		184783, -- [70] Tactician
		383287, -- [71] Bloodborne
		772, -- [72] Rend
		262150, -- [73] Dreadnaught
		383219, -- [74] Exhilarating Blows
		383442, -- [75] Blunt Instruments
		262161, -- [76] Warbreaker
		248621, -- [77] In For The Kill
		385008, -- [78] Test of Might
		152278, -- [79] Anger Management
		167105, -- [80] Colossus Smash
		281001, -- [81] Massacre
		383430, -- [82] Impale
		845, -- [83] Cleave
		383293, -- [84] Reaping Swings
		390725, -- [85] Sonic Boom
		382896, -- [86] Two-Handed Weapon Specialization
		386285, -- [87] Elysian Might
		202168, -- [88] Impending Victory
		386164, -- [89] Battle Stance
		262231, -- [90] War Machine
		3411, -- [91] Intervene
		386208, -- [92] Defensive Stance
		97462, -- [93] Rallying Cry
		382310, -- [94] Inspiring Presence
		29838, -- [95] Second Wind
		383082, -- [96] Barbaric Training
		383115, -- [97] Concussive Blows
		390354, -- [98] Furious Blows
		107570, -- [99] Storm Bolt
		382940, -- [100] Endurance Training
		202163, -- [101] Bounding Stride
		392383, -- [102] Wrenching Impact
	},
	-- Fury Warrior
	[72] = {
		384124, -- [0] Armored to the Teeth
		316402, -- [1] Improved Execute
		280721, -- [2] Sudden Death
		392931, -- [3] Cruelty
		12950, -- [4] Improved Whirlwind
		388049, -- [5] Raging Armaments
		383297, -- [6] Critical Thinking
		315720, -- [7] Onslaught
		388933, -- [8] Tenderize
		383605, -- [9] Frenzied Flurry
		383295, -- [10] Deft Experience
		388903, -- [11] Storm of Swords
		383916, -- [12] Annihilator
		385059, -- [13] Odyn's Fury
		391683, -- [14] Dancing Blades
		394329, -- [15] Titanic Rage
		383459, -- [16] Swift Strikes
		152278, -- [17] Anger Management
		202751, -- [18] Reckless Abandon
		389603, -- [19] Unbridled Ferocity
		383922, -- [20] Depths of Insanity
		1719, -- [21] Recklessness
		388004, -- [22] Slaughtering Strikes
		206315, -- [23] Massacre
		392536, -- [24] Ashen Juggernaut
		184367, -- [25] Rampage
		383877, -- [26] Hack and Slash
		335077, -- [27] Frenzy
		393950, -- [28] Bloodcraze
		383885, -- [29] Vicious Contempt
		383486, -- [30] Focus in Chaos
		383959, -- [31] Cold Steel, Hot Blood
		385703, -- [32] Bloodborne
		81099, -- [33] Single-Minded Fury
		215568, -- [34] Fresh Meat
		383848, -- [35] Improved Enrage
		383852, -- [36] Improved Bloodthirst
		85288, -- [37] Raging Blow
		184364, -- [38] Enraged Regeneration
		208154, -- [39] Warpaint
		383468, -- [40] Invigorating Fury
		23881, -- [41] Bloodthirst
		280392, -- [42] Meat Cleaver
		383854, -- [43] Improved Raging Blow
		382953, -- [44] Storm of Steel
		390563, -- [45] Hurricane
		228920, -- [46] Ravager
		392936, -- [47] Wrath and Fury
		346002, -- [48] War Machine
		23920, -- [49] Spell Reflection
		5246, -- [50] Intimidating Shout
		382954, -- [51] Cacophonous Roar
		275338, -- [52] Menace
		103827, -- [53] Double Time
		392777, -- [54] Cruel Strikes
		376079, -- [55] Spear of Bastion
		382948, -- [56] Piercing Verdict
		382767, -- [57] Overwhelming Rage
		384404, -- [58] Sidearm
		391997, -- [59] Endurance Training
		46968, -- [60] Shockwave
		275339, -- [61] Rumbling Earth
		382900, -- [62] Dual Wield Specialization
		18499, -- [63] Berserker Rage
		382260, -- [64] Fast Footwork
		382939, -- [65] Reinforced Plates
		391270, -- [66] Honed Reflexes
		107574, -- [67] Avatar
		390123, -- [68] Berserker's Torment
		390135, -- [69] Titan's Torment
		382946, -- [70] Wild Strikes
		384318, -- [71] Thunderous Roar
		384969, -- [72] Thunderous Words
		391572, -- [73] Uproar
		383762, -- [74] Bitter Immunity
		382549, -- [75] Pain and Gain
		384110, -- [76] Wrecking Throw
		64382, -- [77] Shattering Throw
		215571, -- [78] Frothing Berserker
		382764, -- [79] Crushing Force
		384100, -- [80] Berserker Shout
		12323, -- [81] Piercing Howl
		6544, -- [82] Heroic Leap
		382258, -- [83] Leeching Strikes
		6343, -- [84] Thunder Clap
		384277, -- [85] Blood and Thunder
		203201, -- [86] Crackling Thunder
		384090, -- [87] Titanic Throw
		382956, -- [88] Seismic Reverberation
		390725, -- [89] Sonic Boom
		386285, -- [90] Elysian Might
		386196, -- [91] Berserker Stance
		202168, -- [92] Impending Victory
		3411, -- [93] Intervene
		386208, -- [94] Defensive Stance
		97462, -- [95] Rallying Cry
		382310, -- [96] Inspiring Presence
		29838, -- [97] Second Wind
		390674, -- [98] Barbaric Training
		383115, -- [99] Concussive Blows
		390354, -- [100] Furious Blows
		107570, -- [101] Storm Bolt
		202163, -- [102] Bounding Stride
		392383, -- [103] Wrenching Impact
	},
	-- Protection Warrior
	[73] = {
		385888, -- [0] Tough as Nails
		392966, -- [1] Spell Block
		275334, -- [2] Punish
		393967, -- [3] Juggernaut
		385704, -- [4] Bloodborne
		386394, -- [5] Battle-Scarred Veteran
		202095, -- [6] Indomitable
		384063, -- [7] Enduring Alacrity
		228920, -- [8] Ravager
		382953, -- [9] Storm of Steel
		23920, -- [10] Spell Reflection
		5246, -- [11] Intimidating Shout
		382954, -- [12] Cacophonous Roar
		275338, -- [13] Menace
		103827, -- [14] Double Time
		392777, -- [15] Cruel Strikes
		376079, -- [16] Spear of Bastion
		382948, -- [17] Piercing Verdict
		382767, -- [18] Overwhelming Rage
		384404, -- [19] Sidearm
		46968, -- [20] Shockwave
		275339, -- [21] Rumbling Earth
		18499, -- [22] Berserker Rage
		382260, -- [23] Fast Footwork
		392790, -- [24] Frothing Berserker
		390642, -- [25] Crushing Force
		382939, -- [26] Reinforced Plates
		107574, -- [27] Avatar
		394307, -- [28] Immovable Object
		275336, -- [29] Unstoppable Force
		391271, -- [30] Honed Reflexes
		382946, -- [31] Wild Strikes
		384318, -- [32] Thunderous Roar
		384969, -- [33] Thunderous Words
		391572, -- [34] Uproar
		383103, -- [35] Fueled by Violence
		384036, -- [36] Brutal Vitality
		384042, -- [37] Unnerving Focus
		383762, -- [38] Bitter Immunity
		382940, -- [39] Endurance Training
		382549, -- [40] Pain and Gain
		384110, -- [41] Wrecking Throw
		64382, -- [42] Shattering Throw
		384100, -- [43] Berserker Shout
		12323, -- [44] Piercing Howl
		6544, -- [45] Heroic Leap
		316733, -- [46] War Machine
		382258, -- [47] Leeching Strikes
		6343, -- [48] Thunder Clap
		384277, -- [49] Blood and Thunder
		203201, -- [50] Crackling Thunder
		384090, -- [51] Titanic Throw
		382956, -- [52] Seismic Reverberation
		394855, -- [53] Armored to the Teeth
		393965, -- [54] Dance of Death
		386164, -- [55] Battle Stance
		394312, -- [56] Battering Ram
		280001, -- [57] Bolster
		386477, -- [58] Violent Outburst
		190456, -- [59] Ignore Pain
		386030, -- [60] Brace For Impact
		12975, -- [61] Last Stand
		6572, -- [62] Revenge
		236279, -- [63] Devastator
		384361, -- [64] Bloodsurge
		394311, -- [65] Instigate
		394062, -- [66] Rend
		384041, -- [67] Strategist
		202560, -- [68] Best Served Cold
		1160, -- [69] Demoralizing Shout
		386034, -- [70] Improved Heroic Throw
		386071, -- [71] Disrupting Shout
		385840, -- [72] Thunderlord
		1161, -- [73] Challenging Shout
		384074, -- [74] Unbreakable Will
		384072, -- [75] Impenetrable Wall
		152278, -- [76] Anger Management
		871, -- [77] Shield Wall
		386027, -- [78] Enduring Defenses
		281001, -- [79] Massacre
		202743, -- [80] Booming Voice
		386011, -- [81] Shield Specialization
		386328, -- [82] Champion's Bulwark
		385952, -- [83] Shield Charge
		384067, -- [84] Focused Vigor
		203177, -- [85] Heavy Repercussions
		202603, -- [86] Into the Fray
		385843, -- [87] Show of Force
		29725, -- [88] Sudden Death
		390725, -- [89] Sonic Boom
		386285, -- [90] Elysian Might
		382895, -- [91] One-Handed Weapon Specialization
		202168, -- [92] Impending Victory
		3411, -- [93] Intervene
		386208, -- [94] Defensive Stance
		97462, -- [95] Rallying Cry
		382310, -- [96] Inspiring Presence
		29838, -- [97] Second Wind
		390675, -- [98] Barbaric Training
		383115, -- [99] Concussive Blows
		390354, -- [100] Furious Blows
		107570, -- [101] Storm Bolt
		202163, -- [102] Bounding Stride
		392383, -- [103] Wrenching Impact
	},
	-- Balance Druid
	[102] = {
		377801, -- [0] Tireless Pursuit
		102401, -- [1] Wild Charge
		252216, -- [2] Tiger Dash
		1822, -- [3] Rake
		194153, -- [4] Starfire
		78674, -- [5] Starsurge
		2782, -- [6] Remove Corruption
		377796, -- [7] Natural Recovery
		231050, -- [8] Improved Sunfire
		93402, -- [9] Sunfire
		132469, -- [10] Typhoon
		197524, -- [11] Astral Influence
		2637, -- [12] Hibernate
		24858, -- [13] Moonkin Form
		33786, -- [14] Cyclone
		33873, -- [15] Nurturing Instinct
		18562, -- [16] Swiftmend
		774, -- [17] Rejuvenation
		301768, -- [18] Verdant Heart
		327993, -- [19] Improved Barkskin
		22842, -- [20] Frenzied Regeneration
		22570, -- [21] Maim
		1079, -- [22] Rip
		106832, -- [23] Thrash
		106839, -- [24] Skull Bash
		108299, -- [25] Killer Instinct
		213764, -- [26] Swipe
		192081, -- [27] Ironfur
		16931, -- [28] Thick Hide
		2908, -- [29] Soothe
		288826, -- [30] Improved Stampeding Roar
		319454, -- [31] Heart of the Wild
		108238, -- [32] Renewal
		378988, -- [33] Lycara's Teachings
		106898, -- [34] Stampeding Roar
		377842, -- [35] Ursine Vigor
		385786, -- [36] Matted Fur
		99, -- [37] Incapacitating Roar
		5211, -- [38] Mighty Bash
		159286, -- [39] Primal Fury
		131768, -- [40] Feline Swiftness
		231040, -- [41] Improved Rejuvenation
		48438, -- [42] Wild Growth
		102359, -- [43] Mass Entanglement
		102793, -- [44] Ursol's Vortex
		29166, -- [45] Innervate
		124974, -- [46] Nature's Vigil
		378986, -- [47] Protector of the Pack
		393940, -- [48] Starweaver
		393954, -- [49] Rattle the Stars
		202359, -- [50] Astral Communion
		394081, -- [51] Friend of the Fae
		394094, -- [52] Sundered Firmament
		393868, -- [53] Lunar Shrapnel
		78675, -- [54] Solar Beam
		383194, -- [55] Stellar Inspiration
		202430, -- [56] Nature's Balance
		393991, -- [57] Elune's Guidance
		391969, -- [58] Circle of Life and Death
		202425, -- [59] Warrior of Elune
		202342, -- [60] Shooting Stars
		202770, -- [61] Fury of Elune
		274281, -- [62] New Moon
		79577, -- [63] Eclipse
		393958, -- [64] Nature's Grace
		390378, -- [65] Syzygy
		393960, -- [66] Primordial Arcanic Pulsar
		88747, -- [67] Wild Mushroom
		383195, -- [68] Umbral Intensity
		394065, -- [69] Denizen of the Dream
		394115, -- [70] Stellar Innervation
		393760, -- [71] Umbral Embrace
		194223, -- [72] Celestial Alignment
		394048, -- [73] Balance of All Things
		394121, -- [74] Radiant Moonlight
		114107, -- [75] Soul of the Forest
		202918, -- [76] Light of the Sun
		205636, -- [77] Force of Nature
		327541, -- [78] Aetherial Kindling
		279620, -- [79] Twin Moons
		202347, -- [80] Stellar Flare
		394046, -- [81] Power of Goldrinn
		394013, -- [82] Incarnation: Chosen of Elune
		391528, -- [83] Convoke the Spirits
		392999, -- [84] Fungal Growth
		394058, -- [85] Astral Smolder
		343647, -- [86] Solstice
		393956, -- [87] Waning Twilight
		191034, -- [88] Starfall
		377847, -- [89] Well-Honed Instincts
		202345, -- [90] Starlord
		383197, -- [91] Orbit Breaker
	},
	-- Feral Druid
	[103] = {
		377801, -- [0] Tireless Pursuit
		102401, -- [1] Wild Charge
		252216, -- [2] Tiger Dash
		1822, -- [3] Rake
		197626, -- [4] Starsurge
		194153, -- [5] Starfire
		2782, -- [6] Remove Corruption
		377796, -- [7] Natural Recovery
		231050, -- [8] Improved Sunfire
		93402, -- [9] Sunfire
		132469, -- [10] Typhoon
		197524, -- [11] Astral Influence
		2637, -- [12] Hibernate
		24858, -- [13] Moonkin Form
		33786, -- [14] Cyclone
		33873, -- [15] Nurturing Instinct
		18562, -- [16] Swiftmend
		774, -- [17] Rejuvenation
		301768, -- [18] Verdant Heart
		327993, -- [19] Improved Barkskin
		22842, -- [20] Frenzied Regeneration
		22570, -- [21] Maim
		1079, -- [22] Rip
		106832, -- [23] Thrash
		106839, -- [24] Skull Bash
		108299, -- [25] Killer Instinct
		213764, -- [26] Swipe
		192081, -- [27] Ironfur
		16931, -- [28] Thick Hide
		2908, -- [29] Soothe
		288826, -- [30] Improved Stampeding Roar
		319454, -- [31] Heart of the Wild
		108238, -- [32] Renewal
		378988, -- [33] Lycara's Teachings
		106898, -- [34] Stampeding Roar
		377842, -- [35] Ursine Vigor
		385786, -- [36] Matted Fur
		99, -- [37] Incapacitating Roar
		5211, -- [38] Mighty Bash
		159286, -- [39] Primal Fury
		131768, -- [40] Feline Swiftness
		231040, -- [41] Improved Rejuvenation
		48438, -- [42] Wild Growth
		102359, -- [43] Mass Entanglement
		102793, -- [44] Ursol's Vortex
		29166, -- [45] Innervate
		124974, -- [46] Nature's Vigil
		378986, -- [47] Protector of the Pack
		377847, -- [48] Well-Honed Instincts
		5217, -- [49] Tiger's Fury
		16864, -- [50] Omen of Clarity
		202021, -- [51] Predator
		383352, -- [52] Tireless Energy
		285381, -- [53] Primal Wrath
		390772, -- [54] Pouncing Strikes
		384665, -- [55] Taste for Blood
		391045, -- [56] Dreadful Bleeding
		61336, -- [57] Survival Instincts
		391875, -- [58] Frantic Momentum
		102543, -- [59] Incarnation: Avatar of Ashamane
		391528, -- [60] Convoke the Spirits
		391548, -- [61] Ashamane's Guidance
		391888, -- [62] Adaptive Swarm
		391951, -- [63] Unbridled Swarm
		390902, -- [64] Carnivorous Instinct
		391972, -- [65] Lion's Strength
		319439, -- [66] Bloodtalons
		274837, -- [67] Feral Frenzy
		391078, -- [68] Raging Fury
		391872, -- [69] Tiger's Tenacity
		16974, -- [70] Predatory Swiftness
		391174, -- [71] Berserk: Heart of the Lion
		384667, -- [72] Sudden Ambush
		48484, -- [73] Infected Wounds
		202031, -- [74] Sabertooth
		106951, -- [75] Berserk
		236068, -- [76] Moment of Clarity
		391709, -- [77] Rampant Ferocity
		231063, -- [78] Merciless Strikes
		391947, -- [79] Protective Growth
		158476, -- [80] Soul of the Forest
		391969, -- [81] Circle of Life and Death
		386318, -- [82] Cat's Curiosity
		391978, -- [83] Veinripper
		391347, -- [84] Rip and Tear
		391881, -- [85] Apex Predator's Craving
		202028, -- [86] Brutal Slash
		390864, -- [87] Wild Slashes
		384668, -- [88] Berserk: Frenzy
		391785, -- [89] Tear Open Wounds
		393771, -- [90] Relentless Predator
		155580, -- [91] Lunar Inspiration
		391700, -- [92] Double-Clawed Rake
		391037, -- [93] Primal Claws
	},
	-- Guardian Druid
	[104] = {
		343240, -- [0] Berserk: Ravage
		300346, -- [1] Ursine Adept
		377210, -- [2] Ursoc's Fury
		372119, -- [3] Dream of Cenarius
		204053, -- [4] Rend and Tear
		372943, -- [5] Untamed Savagery
		80313, -- [6] Pulverize
		372945, -- [7] Reinvigoration
		377623, -- [8] Berserk: Unchecked Aggression
		203974, -- [9] Earthwarden
		393427, -- [10] Flashing Claws
		371999, -- [11] Vicious Cycle
		135288, -- [12] Tooth and Claw
		377811, -- [13] Innate Resolve
		155835, -- [14] Bristling Fur
		203953, -- [15] Brambles
		345208, -- [16] Infected Wounds
		377801, -- [17] Tireless Pursuit
		102401, -- [18] Wild Charge
		252216, -- [19] Tiger Dash
		1822, -- [20] Rake
		197626, -- [21] Starsurge
		194153, -- [22] Starfire
		377796, -- [23] Natural Recovery
		231050, -- [24] Improved Sunfire
		93402, -- [25] Sunfire
		132469, -- [26] Typhoon
		197524, -- [27] Astral Influence
		2637, -- [28] Hibernate
		24858, -- [29] Moonkin Form
		33786, -- [30] Cyclone
		33873, -- [31] Nurturing Instinct
		2782, -- [32] Remove Corruption
		18562, -- [33] Swiftmend
		774, -- [34] Rejuvenation
		301768, -- [35] Verdant Heart
		327993, -- [36] Improved Barkskin
		22842, -- [37] Frenzied Regeneration
		22570, -- [38] Maim
		1079, -- [39] Rip
		106832, -- [40] Thrash
		106839, -- [41] Skull Bash
		108299, -- [42] Killer Instinct
		213764, -- [43] Swipe
		192081, -- [44] Ironfur
		16931, -- [45] Thick Hide
		2908, -- [46] Soothe
		288826, -- [47] Improved Stampeding Roar
		319454, -- [48] Heart of the Wild
		108238, -- [49] Renewal
		378988, -- [50] Lycara's Teachings
		106898, -- [51] Stampeding Roar
		377842, -- [52] Ursine Vigor
		385786, -- [53] Matted Fur
		99, -- [54] Incapacitating Roar
		5211, -- [55] Mighty Bash
		159286, -- [56] Primal Fury
		131768, -- [57] Feline Swiftness
		231040, -- [58] Improved Rejuvenation
		48438, -- [59] Wild Growth
		102359, -- [60] Mass Entanglement
		102793, -- [61] Ursol's Vortex
		29166, -- [62] Innervate
		124974, -- [63] Nature's Vigil
		378986, -- [64] Protector of the Pack
		377847, -- [65] Well-Honed Instincts
		203964, -- [66] Galactic Guardian
		238049, -- [67] Scintillating Moonlight
		372567, -- [68] Twin Moonfire
		377779, -- [69] Berserk: Persistence
		203965, -- [70] Survival of the Fittest
		203962, -- [71] Blood Frenzy
		158477, -- [72] Soul of the Forest
		200851, -- [73] Rage of the Sleeper
		371905, -- [74] After the Wildfire
		155578, -- [75] Guardian of Elune
		393618, -- [76] Reinforced Fur
		370695, -- [77] Fury of Nature
		391969, -- [78] Circle of Life and Death
		394786, -- [79] Incarnation: Guardian of Ursoc
		391528, -- [80] Convoke the Spirits
		393414, -- [81] Ursoc's Guidance
		370586, -- [82] Elune's Favored
		372618, -- [83] Vulnerable Flesh
		200854, -- [84] Gory Fur
		231064, -- [85] Mangle
		393611, -- [86] Ursoc's Endurance
		61336, -- [87] Survival Instincts
		328767, -- [88] Improved Survival Instincts
		6807, -- [89] Maul
		210706, -- [90] Gore
		377835, -- [91] Front of the Pack
		279552, -- [92] Layered Mane
	},
	-- Restoration Druid
	[105] = {
		377801, -- [0] Tireless Pursuit
		102401, -- [1] Wild Charge
		252216, -- [2] Tiger Dash
		1822, -- [3] Rake
		197626, -- [4] Starsurge
		194153, -- [5] Starfire
		392378, -- [6] Improved Nature's Cure
		377796, -- [7] Natural Recovery
		231050, -- [8] Improved Sunfire
		93402, -- [9] Sunfire
		132469, -- [10] Typhoon
		197524, -- [11] Astral Influence
		2637, -- [12] Hibernate
		24858, -- [13] Moonkin Form
		33786, -- [14] Cyclone
		33873, -- [15] Nurturing Instinct
		18562, -- [16] Swiftmend
		774, -- [17] Rejuvenation
		301768, -- [18] Verdant Heart
		327993, -- [19] Improved Barkskin
		22842, -- [20] Frenzied Regeneration
		22570, -- [21] Maim
		1079, -- [22] Rip
		106832, -- [23] Thrash
		106839, -- [24] Skull Bash
		108299, -- [25] Killer Instinct
		213764, -- [26] Swipe
		192081, -- [27] Ironfur
		16931, -- [28] Thick Hide
		2908, -- [29] Soothe
		288826, -- [30] Improved Stampeding Roar
		319454, -- [31] Heart of the Wild
		108238, -- [32] Renewal
		378988, -- [33] Lycara's Teachings
		106898, -- [34] Stampeding Roar
		377842, -- [35] Ursine Vigor
		385786, -- [36] Matted Fur
		99, -- [37] Incapacitating Roar
		5211, -- [38] Mighty Bash
		159286, -- [39] Primal Fury
		131768, -- [40] Feline Swiftness
		231040, -- [41] Improved Rejuvenation
		48438, -- [42] Wild Growth
		102359, -- [43] Mass Entanglement
		102793, -- [44] Ursol's Vortex
		29166, -- [45] Innervate
		124974, -- [46] Nature's Vigil
		378986, -- [47] Protector of the Pack
		377847, -- [48] Well-Honed Instincts
		113043, -- [49] Omen of Clarity
		392220, -- [50] Flash of Clarity
		102342, -- [51] Ironbark
		197061, -- [52] Stonebark
		382552, -- [53] Improved Ironbark
		382559, -- [54] Unstoppable Growth
		392410, -- [55] Verdant Infusion
		197721, -- [56] Flourish
		326228, -- [57] Natural Wisdom
		392302, -- [58] Power of the Archdruid
		392160, -- [59] Invigorate
		392099, -- [60] Nurturing Dormancy
		392116, -- [61] Regenerative Heartwood
		391969, -- [62] Circle of Life and Death
		274902, -- [63] Photosynthesis
		392167, -- [64] Budding Leaves
		155675, -- [65] Germination
		392124, -- [66] Embrace of the Dream
		392356, -- [67] Reforestation
		392315, -- [68] Luxuriant Soil
		391888, -- [69] Adaptive Swarm
		391951, -- [70] Unbridled Swarm
		392256, -- [71] Harmonious Blooming
		33891, -- [72] Incarnation: Tree of Life
		391528, -- [73] Convoke the Spirits
		393371, -- [74] Cenarius' Guidance
		383191, -- [75] Regenesis
		207385, -- [76] Spring Blossoms
		203651, -- [77] Overgrowth
		392325, -- [78] Verdancy
		158478, -- [79] Soul of the Forest
		278515, -- [80] Rampant Growth
		145205, -- [81] Efflorescence
		200390, -- [82] Cultivation
		231032, -- [83] Improved Regrowth
		740, -- [84] Tranquility
		197073, -- [85] Inner Peace
		392162, -- [86] Dreamstate
		207383, -- [87] Abundance
		102351, -- [88] Cenarion Ward
		392288, -- [89] Nature's Splendor
		382550, -- [90] Passing Seasons
		132158, -- [91] Nature's Swiftness
		33763, -- [92] Lifebloom
		145108, -- [93] Ysera's Gift
		383192, -- [94] Grove Tending
		392221, -- [95] Waking Dream
		328025, -- [96] Improved Wild Growth
		392301, -- [97] Undergrowth
		50464, -- [98] Nourish
	},
	-- Blood Death Knight
	[250] = {
		194844, -- [0] Bonestorm
		377640, -- [1] Shattering Bone
		377637, -- [2] Insatiable Blade
		377668, -- [3] Everlasting Bond
		377655, -- [4] Heartrend
		205723, -- [5] Red Thirst
		114556, -- [6] Purgatory
		206970, -- [7] Tightening Grasp
		221536, -- [8] Heartbreaker
		108199, -- [9] Gorefiend's Grasp
		273946, -- [10] Hemostasis
		49028, -- [11] Dancing Rune Weapon
		206940, -- [12] Mark of Blood
		219809, -- [13] Tombstone
		317133, -- [14] Improved Vampiric Blood
		194662, -- [15] Rapid Decomposition
		221699, -- [16] Blood Tap
		206931, -- [17] Blooddrinker
		274156, -- [18] Consumption
		219786, -- [19] Ossuary
		194679, -- [20] Rune Tap
		195292, -- [21] Death's Caress
		317610, -- [22] Relish in Blood
		374737, -- [23] Reinforced Bones
		377629, -- [24] Leeching Strike
		206974, -- [25] Foul Bulwark
		195182, -- [26] Marrowrend
		206930, -- [27] Heart Strike
		50842, -- [28] Blood Boil
		81136, -- [29] Crimson Scourge
		391395, -- [30] Iron Heart
		55233, -- [31] Vampiric Blood
		195679, -- [32] Bloodworms
		48792, -- [33] Icebound Fortitude
		391477, -- [34] Coagulopathy
		391386, -- [35] Blood Feast
		391517, -- [36] Umbilicus Eternus
		391458, -- [37] Sanguine Ground
		374715, -- [38] Improved Bone Shield
		273953, -- [39] Voracious
		207167, -- [40] Blinding Sleet
		378848, -- [41] Coldthirst
		205727, -- [42] Anti-Magic Barrier
		373926, -- [43] Acclimation
		374383, -- [44] Assimilation
		383269, -- [45] Abomination Limb
		47568, -- [46] Empower Rune Weapon
		194878, -- [47] Icy Talons
		391571, -- [48] Gloom Ward
		343294, -- [49] Soul Reaper
		206967, -- [50] Will of the Necropolis
		374261, -- [51] Unholy Bond
		356367, -- [52] Death's Echo
		276079, -- [53] Death's Reach
		273952, -- [54] Grip of the Dead
		374265, -- [55] Unholy Ground
		111673, -- [56] Control Undead
		392566, -- [57] Enfeeble
		374504, -- [58] Brittle
		389679, -- [59] Clenching Grasp
		389682, -- [60] Unholy Endurance
		221562, -- [61] Asphyxiate
		51052, -- [62] Anti-Magic Zone
		374030, -- [63] Blood Scent
		374277, -- [64] Improved Death Strike
		48263, -- [65] Veteran of the Third War
		391546, -- [66] March of Darkness
		48707, -- [67] Anti-Magic Shell
		49998, -- [68] Death Strike
		46585, -- [69] Raise Dead
		316916, -- [70] Cleaving Strikes
		327574, -- [71] Sacrificial Pact
		374049, -- [72] Suppression
		374111, -- [73] Might of Thassarian
		48743, -- [74] Death Pact
		212552, -- [75] Wraith Walk
		374598, -- [76] Blood Draw
		374574, -- [77] Rune Mastery
		45524, -- [78] Chains of Ice
		47528, -- [79] Mind Freeze
		207200, -- [80] Permafrost
		373923, -- [81] Merciless Strikes
		373930, -- [82] Proliferating Chill
		207104, -- [83] Runic Attenuation
		391566, -- [84] Insidious Chill
		374747, -- [85] Perseverance of the Ebon Blade
		391398, -- [86] Bloodshot
		374717, -- [87] Improved Heart Strike
	},
	-- Frost Death Knight
	[251] = {
		48792, -- [0] Icebound Fortitude
		392950, -- [1] Icebreaker
		207126, -- [2] Icecap
		281208, -- [3] Cold Heart
		377056, -- [4] Biting Cold
		253593, -- [5] Inexorable Assault
		207167, -- [6] Blinding Sleet
		378848, -- [7] Coldthirst
		205727, -- [8] Anti-Magic Barrier
		373926, -- [9] Acclimation
		374383, -- [10] Assimilation
		383269, -- [11] Abomination Limb
		47568, -- [12] Empower Rune Weapon
		194878, -- [13] Icy Talons
		391571, -- [14] Gloom Ward
		343294, -- [15] Soul Reaper
		206967, -- [16] Will of the Necropolis
		374261, -- [17] Unholy Bond
		356367, -- [18] Death's Echo
		276079, -- [19] Death's Reach
		273952, -- [20] Grip of the Dead
		374265, -- [21] Unholy Ground
		111673, -- [22] Control Undead
		392566, -- [23] Enfeeble
		374504, -- [24] Brittle
		389679, -- [25] Clenching Grasp
		389682, -- [26] Unholy Endurance
		221562, -- [27] Asphyxiate
		51052, -- [28] Anti-Magic Zone
		374030, -- [29] Blood Scent
		374277, -- [30] Improved Death Strike
		48263, -- [31] Veteran of the Third War
		391546, -- [32] March of Darkness
		48707, -- [33] Anti-Magic Shell
		49998, -- [34] Death Strike
		46585, -- [35] Raise Dead
		316916, -- [36] Cleaving Strikes
		327574, -- [37] Sacrificial Pact
		374049, -- [38] Suppression
		374111, -- [39] Might of Thassarian
		48743, -- [40] Death Pact
		212552, -- [41] Wraith Walk
		374598, -- [42] Blood Draw
		374574, -- [43] Rune Mastery
		45524, -- [44] Chains of Ice
		47528, -- [45] Mind Freeze
		207200, -- [46] Permafrost
		373923, -- [47] Merciless Strikes
		373930, -- [48] Proliferating Chill
		207104, -- [49] Runic Attenuation
		391566, -- [50] Insidious Chill
		317214, -- [51] Frostreaper
		81333, -- [52] Might of the Frozen Wastes
		281238, -- [53] Obliteration
		194913, -- [54] Glacial Advance
		152279, -- [55] Breath of Sindragosa
		377047, -- [56] Absolute Zero
		279302, -- [57] Frostwyrm's Fury
		207230, -- [58] Frostscythe
		377351, -- [59] Piercing Chill
		377376, -- [60] Enduring Chill
		305392, -- [61] Chill Streak
		47568, -- [62] Empower Rune Weapon
		377190, -- [63] Enduring Strength
		207057, -- [64] Shattering Blade
		376251, -- [65] Runic Command
		316803, -- [66] Improved Frost Strike
		51271, -- [67] Pillar of Frost
		207142, -- [68] Avalanche
		377226, -- [69] Frostwhelp's Aid
		376938, -- [70] Everfrost
		377092, -- [71] Invigorating Freeze
		194912, -- [72] Gathering Storm
		57330, -- [73] Horn of Winter
		316838, -- [74] Improved Rime
		196770, -- [75] Remorseless Winter
		59057, -- [76] Rime
		49184, -- [77] Howling Blast
		49143, -- [78] Frost Strike
		49020, -- [79] Obliterate
		51128, -- [80] Killing Machine
		376905, -- [81] Unleashed Frenzy
		317198, -- [82] Improved Obliterate
		377073, -- [83] Frigid Executioner
		377076, -- [84] Rage of the Frozen Champion
		207061, -- [85] Murderous Efficiency
		377098, -- [86] Bonegrinder
		377083, -- [87] Cold-Blooded Rage
	},
	-- Unholy Death Knight
	[252] = {
		390196, -- [0] Magus of the Dead
		390236, -- [1] Ruptured Viscera
		390259, -- [2] Commander of the Dead
		377440, -- [3] Unholy Aura
		207289, -- [4] Unholy Assault
		377590, -- [5] Festermight
		276837, -- [6] Army of the Damned
		377587, -- [7] Ghoulish Frenzy
		390283, -- [8] Superstrain
		390270, -- [9] Coil of Devastation
		277234, -- [10] Pestilence
		377537, -- [11] Death Rot
		390279, -- [12] Vile Contagion
		194917, -- [13] Pestilent Pustules
		207317, -- [14] Epidemic
		115989, -- [15] Unholy Blight
		377585, -- [16] Replenishing Wounds
		207264, -- [17] Bursting Sores
		207269, -- [18] Ebon Fever
		276023, -- [19] Harbinger of Doom
		49206, -- [20] Summon Gargoyle
		377514, -- [21] Reaping
		390275, -- [22] Rotten Touch
		49530, -- [23] Sudden Doom
		319230, -- [24] Unholy Pact
		152280, -- [25] Defile
		194916, -- [26] All Will Serve
		207272, -- [27] Infected Claws
		390175, -- [28] Plaguebringer
		207311, -- [29] Clawing Shadows
		377580, -- [30] Improved Death Coil
		275699, -- [31] Apocalypse
		390166, -- [32] Runic Mastery
		63560, -- [33] Dark Transformation
		46584, -- [34] Raise Dead
		85948, -- [35] Festering Strike
		55090, -- [36] Scourge Strike
		77575, -- [37] Outbreak
		316867, -- [38] Improved Festering Strike
		390161, -- [39] Feasting Strikes
		316941, -- [40] Unholy Command
		390268, -- [41] Eternal Agony
		42650, -- [42] Army of the Dead
		377592, -- [43] Morbidity
		48792, -- [44] Icebound Fortitude
		207167, -- [45] Blinding Sleet
		378848, -- [46] Coldthirst
		205727, -- [47] Anti-Magic Barrier
		373926, -- [48] Acclimation
		374383, -- [49] Assimilation
		383269, -- [50] Abomination Limb
		47568, -- [51] Empower Rune Weapon
		194878, -- [52] Icy Talons
		391571, -- [53] Gloom Ward
		343294, -- [54] Soul Reaper
		206967, -- [55] Will of the Necropolis
		374261, -- [56] Unholy Bond
		356367, -- [57] Death's Echo
		276079, -- [58] Death's Reach
		273952, -- [59] Grip of the Dead
		374265, -- [60] Unholy Ground
		111673, -- [61] Control Undead
		392566, -- [62] Enfeeble
		374504, -- [63] Brittle
		389679, -- [64] Clenching Grasp
		389682, -- [65] Unholy Endurance
		221562, -- [66] Asphyxiate
		51052, -- [67] Anti-Magic Zone
		374030, -- [68] Blood Scent
		374277, -- [69] Improved Death Strike
		48263, -- [70] Veteran of the Third War
		391546, -- [71] March of Darkness
		48707, -- [72] Anti-Magic Shell
		49998, -- [73] Death Strike
		46585, -- [74] Raise Dead
		316916, -- [75] Cleaving Strikes
		327574, -- [76] Sacrificial Pact
		374049, -- [77] Suppression
		374111, -- [78] Might of Thassarian
		48743, -- [79] Death Pact
		212552, -- [80] Wraith Walk
		374598, -- [81] Blood Draw
		374574, -- [82] Rune Mastery
		45524, -- [83] Chains of Ice
		47528, -- [84] Mind Freeze
		207200, -- [85] Permafrost
		373923, -- [86] Merciless Strikes
		373930, -- [87] Proliferating Chill
		207104, -- [88] Runic Attenuation
		391566, -- [89] Insidious Chill
	},
	-- Beast Mastery Hunter
	[253] = {
		271788, -- [0] Serpent Sting
		5116, -- [1] Concussive Shot
		19801, -- [2] Tranquilizing Shot
		162488, -- [3] Steel Trap
		385539, -- [4] Rejuvenating Wind
		19577, -- [5] Intimidation
		236776, -- [6] High Explosive Trap
		378014, -- [7] Poison Injection
		260241, -- [8] Hydra's Bite
		147362, -- [9] Counter Shot
		260309, -- [10] Master Marksman
		212431, -- [11] Explosive Shot
		120360, -- [12] Barrage
		201430, -- [13] Stampede
		375891, -- [14] Death Chakram
		2643, -- [15] Multi-Shot
		378002, -- [16] Pathfinding
		343244, -- [17] Improved Tranquilizing Shot
		321468, -- [18] Binding Shackles
		109215, -- [19] Posthaste
		378004, -- [20] Keen Eyesight
		343247, -- [21] Improved Traps
		34477, -- [22] Misdirection
		270581, -- [23] Natural Mending
		378007, -- [24] Beast Master
		1513, -- [25] Scare Beast
		187698, -- [26] Tar Trap
		343248, -- [27] Improved Kill Shot
		199921, -- [28] Trailblazer
		378010, -- [29] Improved Kill Command
		266921, -- [30] Born To Be Wild
		199483, -- [31] Camouflage
		34026, -- [32] Kill Command
		343242, -- [33] Wilderness Medicine
		213691, -- [34] Scatter Shot
		109248, -- [35] Binding Shot
		392060, -- [36] Wailing Arrow
		378740, -- [37] Killer Command
		378745, -- [38] Dire Pack
		378750, -- [39] Cobra Sting
		199530, -- [40] Stomp
		131894, -- [41] A Murder of Crows
		321530, -- [42] Bloodshed
		191384, -- [43] Aspect of the Beast
		378205, -- [44] Sharp Barbs
		378442, -- [45] Wild Instincts
		378739, -- [46] Bloody Frenzy
		267116, -- [47] Animal Companion
		378209, -- [48] Training Expert
		193455, -- [49] Cobra Shot
		193530, -- [50] Aspect of the Wild
		378210, -- [51] Hunter's Prey
		393933, -- [52] War Orders
		378743, -- [53] Dire Command
		378207, -- [54] Kill Cleave
		19574, -- [55] Bestial Wrath
		115939, -- [56] Beast Cleave
		56315, -- [57] Kindred Spirits
		321014, -- [58] Pack Tactics
		120679, -- [59] Dire Beast
		199528, -- [60] One with the Pack
		199532, -- [61] Killer Cobra
		392053, -- [62] Piercing Fangs
		389654, -- [63] Master Handler
		389660, -- [64] Snake Bite
		378244, -- [65] Cobra Senses
		257944, -- [66] Thrill of the Hunt
		193532, -- [67] Scent of Blood
		185789, -- [68] Wild Call
		359844, -- [69] Call of the Wild
		217200, -- [70] Barbed Shot
		393344, -- [71] Entrapment
		231548, -- [72] Barbed Wrath
		389882, -- [73] Serrated Shots
		390231, -- [74] Arctic Bola
		386870, -- [75] Brutal Companion
		388056, -- [76] Sentinel's Perception
		388057, -- [77] Sentinel's Protection
		388045, -- [78] Sentinel Owl
		388039, -- [79] Lone Survivor
		388042, -- [80] Nature's Endurance
		264735, -- [81] Survival of the Fittest
		385810, -- [82] Dire Frenzy
		384799, -- [83] Hunter's Avoidance
		53351, -- [84] Kill Shot
		273887, -- [85] Killer Instinct
		269737, -- [86] Alpha Predator
	},
	-- Marksmanship Hunter
	[254] = {
		271788, -- [0] Serpent Sting
		5116, -- [1] Concussive Shot
		19801, -- [2] Tranquilizing Shot
		162488, -- [3] Steel Trap
		385539, -- [4] Rejuvenating Wind
		19577, -- [5] Intimidation
		236776, -- [6] High Explosive Trap
		378014, -- [7] Poison Injection
		260241, -- [8] Hydra's Bite
		260309, -- [9] Master Marksman
		212431, -- [10] Explosive Shot
		120360, -- [11] Barrage
		342049, -- [12] Chimaera Shot
		201430, -- [13] Stampede
		375891, -- [14] Death Chakram
		378002, -- [15] Pathfinding
		343244, -- [16] Improved Tranquilizing Shot
		321468, -- [17] Binding Shackles
		109215, -- [18] Posthaste
		378004, -- [19] Keen Eyesight
		343247, -- [20] Improved Traps
		34477, -- [21] Misdirection
		270581, -- [22] Natural Mending
		378007, -- [23] Beast Master
		1513, -- [24] Scare Beast
		187698, -- [25] Tar Trap
		343248, -- [26] Improved Kill Shot
		199921, -- [27] Trailblazer
		378010, -- [28] Improved Kill Command
		266921, -- [29] Born To Be Wild
		199483, -- [30] Camouflage
		343242, -- [31] Wilderness Medicine
		213691, -- [32] Scatter Shot
		109248, -- [33] Binding Shot
		393344, -- [34] Entrapment
		389866, -- [35] Windrunner's Barrage
		389865, -- [36] Readiness
		389882, -- [37] Serrated Shots
		390231, -- [38] Arctic Bola
		389019, -- [39] Bulletstorm
		388056, -- [40] Sentinel's Perception
		388057, -- [41] Sentinel's Protection
		388045, -- [42] Sentinel Owl
		388039, -- [43] Lone Survivor
		388042, -- [44] Nature's Endurance
		264735, -- [45] Survival of the Fittest
		384791, -- [46] Salvo
		384790, -- [47] Razor Fragments
		384799, -- [48] Hunter's Avoidance
		53351, -- [49] Kill Shot
		147362, -- [50] Counter Shot
		34026, -- [51] Kill Command
		257620, -- [52] Multi-Shot
		155228, -- [53] Lone Wolf
		186387, -- [54] Bursting Shot
		19434, -- [55] Aimed Shot
		260402, -- [56] Double Tap
		257621, -- [57] Trick Shots
		204089, -- [58] Bullseye
		260240, -- [59] Precise Shots
		378771, -- [60] Quick Load
		260228, -- [61] Careful Aim
		257044, -- [62] Rapid Fire
		378888, -- [63] Serpentstalker's Trickery
		288613, -- [64] Trueshot
		378769, -- [65] Deathblow
		194595, -- [66] Lock and Load
		392060, -- [67] Wailing Arrow
		321287, -- [68] Target Practice
		378907, -- [69] Sharpshooter
		378766, -- [70] Hunter's Knowledge
		378880, -- [71] Bombardment
		260243, -- [72] Volley
		193533, -- [73] Steady Focus
		321460, -- [74] Deadeye
		260367, -- [75] Streamline
		378905, -- [76] Windrunner's Guidance
		321293, -- [77] Crack Shot
		378767, -- [78] Focused Aim
		260393, -- [79] Lethal Shots
		391559, -- [80] Surging Shots
		321018, -- [81] Improved Steady Shot
		190852, -- [82] Legacy of the Windrunners
		378765, -- [83] Killer Accuracy
		389449, -- [84] Eagletalon's True Focus
		260404, -- [85] Calling the Shots
		386878, -- [86] Unerring Vision
		273887, -- [87] Killer Instinct
		269737, -- [88] Alpha Predator
		378910, -- [89] Heavy Ammo
		378913, -- [90] Light Ammo
	},
	-- Survival Hunter
	[255] = {
		271788, -- [0] Serpent Sting
		5116, -- [1] Concussive Shot
		19801, -- [2] Tranquilizing Shot
		162488, -- [3] Steel Trap
		385539, -- [4] Rejuvenating Wind
		19577, -- [5] Intimidation
		236776, -- [6] High Explosive Trap
		378014, -- [7] Poison Injection
		260241, -- [8] Hydra's Bite
		260309, -- [9] Master Marksman
		212431, -- [10] Explosive Shot
		120360, -- [11] Barrage
		201430, -- [12] Stampede
		375891, -- [13] Death Chakram
		378002, -- [14] Pathfinding
		343244, -- [15] Improved Tranquilizing Shot
		321468, -- [16] Binding Shackles
		109215, -- [17] Posthaste
		378004, -- [18] Keen Eyesight
		343247, -- [19] Improved Traps
		34477, -- [20] Misdirection
		270581, -- [21] Natural Mending
		378007, -- [22] Beast Master
		1513, -- [23] Scare Beast
		187698, -- [24] Tar Trap
		343248, -- [25] Improved Kill Shot
		199921, -- [26] Trailblazer
		378010, -- [27] Improved Kill Command
		266921, -- [28] Born To Be Wild
		199483, -- [29] Camouflage
		343242, -- [30] Wilderness Medicine
		213691, -- [31] Scatter Shot
		109248, -- [32] Binding Shot
		393344, -- [33] Entrapment
		389882, -- [34] Serrated Shots
		390231, -- [35] Arctic Bola
		388056, -- [36] Sentinel's Perception
		388057, -- [37] Sentinel's Protection
		388045, -- [38] Sentinel Owl
		388039, -- [39] Lone Survivor
		388042, -- [40] Nature's Endurance
		264735, -- [41] Survival of the Fittest
		385739, -- [42] Coordinated Kill
		385695, -- [43] Ranger
		268501, -- [44] Viper's Venom
		385709, -- [45] Intense Focus
		385737, -- [46] Bloody Claws
		385718, -- [47] Ruthless Marauder
		384799, -- [48] Hunter's Avoidance
		320976, -- [49] Kill Shot
		187707, -- [50] Muzzle
		259489, -- [51] Kill Command
		269751, -- [52] Flanking Strike
		190925, -- [53] Harpoon
		378948, -- [54] Sharp Edges
		294029, -- [55] Frenzy Strikes
		378916, -- [56] Ferocity
		378934, -- [57] Lunge
		186270, -- [58] Raptor Strike
		187708, -- [59] Carve
		212436, -- [60] Butchery
		260285, -- [61] Tip of the Spear
		321290, -- [62] Improved Wildfire Bomb
		378951, -- [63] Tactical Advantage
		203415, -- [64] Fury of the Eagle
		378953, -- [65] Spear Focus
		378955, -- [66] Killer Companion
		378961, -- [67] Energetic Ally
		378950, -- [68] Sweeping Spear
		186289, -- [69] Aspect of the Eagle
		378937, -- [70] Explosives Expert
		260248, -- [71] Bloodseeker
		263186, -- [72] Flanker's Advantage
		259387, -- [73] Mongoose Bite
		265895, -- [74] Terms of Engagement
		259495, -- [75] Wildfire Bomb
		260331, -- [76] Birds of Prey
		389880, -- [77] Bombardier
		360952, -- [78] Coordinated Assault
		360966, -- [79] Spearhead
		264332, -- [80] Guerrilla Tactics
		378940, -- [81] Quick Shot
		378962, -- [82] Deadly Duo
		271014, -- [83] Wildfire Infusion
		273887, -- [84] Killer Instinct
		269737, -- [85] Alpha Predator
	},
	-- Discipline Priest
	[256] = {
		373457, -- [0] Crystalline Reflection
		108942, -- [1] Phantasm
		62618, -- [2] Power Word: Barrier
		373003, -- [3] Revel in Purity
		238063, -- [4] Lenience
		246287, -- [5] Evangelism
		280391, -- [6] Sins of the Many
		390786, -- [7] Weal and Woe
		390770, -- [8] Void Summoner
		390705, -- [9] Twilight Equilibrium
		373180, -- [10] Harsh Discipline
		390781, -- [11] Wrath Unleashed
		390765, -- [12] Resplendent Light
		373178, -- [13] Light's Wrath
		373042, -- [14] Exaltation
		373049, -- [15] Indemnity
		193134, -- [16] Castigation
		390689, -- [17] Pain and Suffering
		214621, -- [18] Schism
		372969, -- [19] Malicious Intent
		314867, -- [20] Shadow Covenant
		372985, -- [21] Embrace Shadow
		373065, -- [22] Twilight Corruption
		373054, -- [23] Stolen Psyche
		123040, -- [24] Mindbender
		390832, -- [25] Expiation
		373427, -- [26] Inescapable Torment
		33206, -- [27] Pain Suppression
		372991, -- [28] Pain Transformation
		373035, -- [29] Protector of the Frail
		197045, -- [30] Shield Discipline
		129250, -- [31] Power Word: Solace
		204197, -- [32] Purge the Wicked
		390684, -- [33] Bright Pupil
		390685, -- [34] Enduring Luminescence
		322115, -- [35] Light's Promise
		194509, -- [36] Power Word: Radiance
		81749, -- [37] Atonement
		377438, -- [38] Words of the Pious
		390667, -- [39] Spell Warding
		390767, -- [40] Blessed Recovery
		372354, -- [41] Focused Mending
		33076, -- [42] Prayer of Mending
		139, -- [43] Renew
		73325, -- [44] Leap of Faith
		528, -- [45] Dispel Magic
		393870, -- [46] Improved Flash Heal
		34433, -- [47] Shadowfiend
		32379, -- [48] Shadow Word: Death
		321291, -- [49] Death and Madness
		605, -- [50] Mind Control
		205364, -- [51] Dominate Mind
		377422, -- [52] Throes of Pain
		390919, -- [53] Sheer Terror
		108920, -- [54] Void Tendrils
		193063, -- [55] Protective Light
		390615, -- [56] From Darkness Comes Light
		64129, -- [57] Body and Soul
		390632, -- [58] Improved Purify
		121536, -- [59] Angelic Feather
		390620, -- [60] Move with Grace
		132157, -- [61] Holy Nova
		390622, -- [62] Rhapsody
		32375, -- [63] Mass Dispel
		341167, -- [64] Improved Mass Dispel
		373456, -- [65] Unwavering Will
		390676, -- [66] Inspiration
		196704, -- [67] Psychic Voice
		10060, -- [68] Power Infusion
		9484, -- [69] Shackle Undead
		280749, -- [70] Void Shield
		15286, -- [71] Vampiric Embrace
		199855, -- [72] San'layn
		390668, -- [73] Apathy
		373223, -- [74] Tithe Evasion
		375901, -- [75] Mindgames
		390670, -- [76] Improved Fade
		373446, -- [77] Translucent Image
		390972, -- [78] Twist of Fate
		373466, -- [79] Twins of the Sun Priestess
		110744, -- [80] Divine Star
		120517, -- [81] Halo
		238135, -- [82] Aegis of Wrath
		391079, -- [83] Make Amends
		198068, -- [84] Power of the Dark Side
		372972, -- [85] Dark Indulgence
		390686, -- [86] Painful Punishment
		47536, -- [87] Rapture
		197419, -- [88] Contrition
		390691, -- [89] Borrowed Time
		390693, -- [90] Train of Thought
		47515, -- [91] Divine Aegis
		390996, -- [92] Manipulation
		391112, -- [93] Shattered Perceptions
		108968, -- [94] Void Shift
		108945, -- [95] Angelic Bulwark
		373481, -- [96] Power Word: Life
		109186, -- [97] Surge of Light
		238100, -- [98] Angel's Mercy
		368275, -- [99] Binding Heals
		373450, -- [100] Light's Inspiration
	},
	-- Holy Priest
	[257] = {
		373457, -- [0] Crystalline Reflection
		392988, -- [1] Divine Image
		372760, -- [2] Divine Word
		108942, -- [3] Phantasm
		377438, -- [4] Words of the Pious
		390667, -- [5] Spell Warding
		390767, -- [6] Blessed Recovery
		372354, -- [7] Focused Mending
		33076, -- [8] Prayer of Mending
		139, -- [9] Renew
		73325, -- [10] Leap of Faith
		528, -- [11] Dispel Magic
		393870, -- [12] Improved Flash Heal
		34433, -- [13] Shadowfiend
		32379, -- [14] Shadow Word: Death
		321291, -- [15] Death and Madness
		605, -- [16] Mind Control
		205364, -- [17] Dominate Mind
		377422, -- [18] Throes of Pain
		390919, -- [19] Sheer Terror
		108920, -- [20] Void Tendrils
		193063, -- [21] Protective Light
		390615, -- [22] From Darkness Comes Light
		64129, -- [23] Body and Soul
		390632, -- [24] Improved Purify
		121536, -- [25] Angelic Feather
		390620, -- [26] Move with Grace
		132157, -- [27] Holy Nova
		390622, -- [28] Rhapsody
		32375, -- [29] Mass Dispel
		341167, -- [30] Improved Mass Dispel
		373456, -- [31] Unwavering Will
		390676, -- [32] Inspiration
		196704, -- [33] Psychic Voice
		10060, -- [34] Power Infusion
		9484, -- [35] Shackle Undead
		280749, -- [36] Void Shield
		15286, -- [37] Vampiric Embrace
		199855, -- [38] San'layn
		390668, -- [39] Apathy
		373223, -- [40] Tithe Evasion
		375901, -- [41] Mindgames
		390670, -- [42] Improved Fade
		373446, -- [43] Translucent Image
		390972, -- [44] Twist of Fate
		373466, -- [45] Twins of the Sun Priestess
		110744, -- [46] Divine Star
		120517, -- [47] Halo
		390992, -- [48] Lightweaver
		372835, -- [49] Lightwell
		372309, -- [50] Resonant Words
		235587, -- [51] Miracle Worker
		391124, -- [52] Restitution
		372611, -- [53] Searing Light
		372616, -- [54] Empyreal Blaze
		391387, -- [55] Answered Prayers
		391381, -- [56] Desperate Times
		200183, -- [57] Apotheosis
		265202, -- [58] Holy Word: Salvation
		390994, -- [59] Harmonious Apparatus
		391339, -- [60] Empowered Renew
		391368, -- [61] Rapid Recovery
		372370, -- [62] Gales of Song
		390967, -- [63] Prismatic Echoes
		391186, -- [64] Say Your Prayers
		390977, -- [65] Prayers of the Virtuous
		64901, -- [66] Symbol of Hope
		193155, -- [67] Enlightenment
		200199, -- [68] Censure
		341997, -- [69] Renewed Faith
		64843, -- [70] Divine Hymn
		391161, -- [71] Everlasting Light
		391209, -- [72] Prayerful Litany
		204883, -- [73] Circle of Healing
		321377, -- [74] Prayer Circle
		390881, -- [75] Healing Chorus
		390947, -- [76] Orison
		390954, -- [77] Crisis Management
		390980, -- [78] Pontifex
		196985, -- [79] Light of the Naaru
		238136, -- [80] Cosmic Ripple
		596, -- [81] Prayer of Healing
		34861, -- [82] Holy Word: Sanctify
		391208, -- [83] Revitalizing Prayers
		196489, -- [84] Sanctified Prayers
		200128, -- [85] Trail of Light
		196707, -- [86] Afterlife
		200209, -- [87] Guardian Angel
		196437, -- [88] Guardians of the Light
		47788, -- [89] Guardian Spirit
		2050, -- [90] Holy Word: Serenity
		88625, -- [91] Holy Word: Chastise
		372307, -- [92] Burning Vehemence
		193157, -- [93] Benediction
		391154, -- [94] Holy Mending
		391233, -- [95] Divine Service
		390996, -- [96] Manipulation
		391112, -- [97] Shattered Perceptions
		108968, -- [98] Void Shift
		108945, -- [99] Angelic Bulwark
		373481, -- [100] Power Word: Life
		109186, -- [101] Surge of Light
		238100, -- [102] Angel's Mercy
		368275, -- [103] Binding Heals
		373450, -- [104] Light's Inspiration
	},
	-- Shadow Priest
	[258] = {
		373457, -- [0] Crystalline Reflection
		373273, -- [1] Idol of Yogg-Saron
		108942, -- [2] Phantasm
		205385, -- [3] Shadow Crash
		392507, -- [4] Deathspeaker
		391399, -- [5] Mind Flay: Insanity
		391090, -- [6] Mind Melt
		373212, -- [7] Insidious Ire
		373202, -- [8] Mind Devourer
		391235, -- [9] Encroaching Shadows
		391137, -- [10] Whispers of the Damned
		377438, -- [11] Words of the Pious
		390667, -- [12] Spell Warding
		390767, -- [13] Blessed Recovery
		372354, -- [14] Focused Mending
		33076, -- [15] Prayer of Mending
		139, -- [16] Renew
		73325, -- [17] Leap of Faith
		528, -- [18] Dispel Magic
		393870, -- [19] Improved Flash Heal
		34433, -- [20] Shadowfiend
		32379, -- [21] Shadow Word: Death
		321291, -- [22] Death and Madness
		605, -- [23] Mind Control
		205364, -- [24] Dominate Mind
		377422, -- [25] Throes of Pain
		390919, -- [26] Sheer Terror
		108920, -- [27] Void Tendrils
		193063, -- [28] Protective Light
		390615, -- [29] From Darkness Comes Light
		64129, -- [30] Body and Soul
		213634, -- [31] Purify Disease
		121536, -- [32] Angelic Feather
		390620, -- [33] Move with Grace
		132157, -- [34] Holy Nova
		390622, -- [35] Rhapsody
		32375, -- [36] Mass Dispel
		341167, -- [37] Improved Mass Dispel
		373456, -- [38] Unwavering Will
		390676, -- [39] Inspiration
		196704, -- [40] Psychic Voice
		10060, -- [41] Power Infusion
		9484, -- [42] Shackle Undead
		280749, -- [43] Void Shield
		15286, -- [44] Vampiric Embrace
		199855, -- [45] San'layn
		390668, -- [46] Apathy
		373223, -- [47] Tithe Evasion
		375901, -- [48] Mindgames
		390670, -- [49] Improved Fade
		373446, -- [50] Translucent Image
		390972, -- [51] Twist of Fate
		373466, -- [52] Twins of the Sun Priestess
		373310, -- [53] Idol of Y'Shaarj
		373280, -- [54] Idol of N'Zoth
		391242, -- [55] Coalescing Shadows
		377349, -- [56] Idol of C'Thun
		373427, -- [57] Inescapable Torment
		391228, -- [58] Maddening Touch
		377387, -- [59] Puppet Master
		391296, -- [60] Harnessed Shadows
		200174, -- [61] Mindbender
		375767, -- [62] Screams of the Void
		238558, -- [63] Misery
		263346, -- [64] Dark Void
		15487, -- [65] Silence
		263716, -- [66] Last Word
		64044, -- [67] Psychic Horror
		341374, -- [68] Damnation
		263165, -- [69] Void Torrent
		373221, -- [70] Malediction
		341240, -- [71] Ancient Madness
		391109, -- [72] Dark Ascension
		228260, -- [73] Void Eruption
		341273, -- [74] Unfurling Darkness
		288733, -- [75] Intangibility
		377065, -- [76] Mental Fortitude
		391095, -- [77] Dark Evangelism
		375994, -- [78] Mental Decay
		375888, -- [79] Shadowy Insight
		47585, -- [80] Dispersion
		48045, -- [81] Mind Sear
		335467, -- [82] Devouring Plague
		341491, -- [83] Shadowy Apparitions
		155271, -- [84] Auspicious Spirits
		391284, -- [85] Tormented Spirits
		73510, -- [86] Mind Spike
		162448, -- [87] Surge of Darkness
		199484, -- [88] Psychic Link
		391288, -- [89] Pain of Death
		390996, -- [90] Manipulation
		391112, -- [91] Shattered Perceptions
		108968, -- [92] Void Shift
		108945, -- [93] Angelic Bulwark
		373481, -- [94] Power Word: Life
		109186, -- [95] Surge of Light
		238100, -- [96] Angel's Mercy
		368275, -- [97] Binding Heals
		373450, -- [98] Light's Inspiration
		122121, -- [99] Divine Star
		120644, -- [100] Halo
	},
	-- Assassination Rogue
	[259] = {
		193531, -- [0] Deeper Stratagem
		137619, -- [1] Marked for Death
		193539, -- [2] Alacrity
		196924, -- [3] Acrobatic Strikes
		381619, -- [4] Thief's Versatility
		79008, -- [5] Elusiveness
		31230, -- [6] Cheat Death
		382245, -- [7] Cold Blood
		382238, -- [8] Lethality
		185313, -- [9] Shadow Dance
		91023, -- [10] Find Weakness
		393970, -- [11] Soothing Darkness
		381620, -- [12] Improved Ambush
		14062, -- [13] Nightstalker
		378803, -- [14] Rushed Setup
		131511, -- [15] Prey on the Weak
		381623, -- [16] Thistle Tea
		14190, -- [17] Seal Fate
		280716, -- [18] Leeching Poison
		14983, -- [19] Vigor
		381542, -- [20] Deadly Precision
		381543, -- [21] Virulent Poisons
		319066, -- [22] Improved Wound Poison
		378436, -- [23] Master Poisoner
		385408, -- [24] Sepsis
		385424, -- [25] Serrated Bone Spike
		79134, -- [26] Venomous Wounds
		392384, -- [27] Fatal Concoction
		381624, -- [28] Improved Poisons
		193640, -- [29] Elaborate Planning
		319032, -- [30] Improved Shiv
		51667, -- [31] Cut to the Chase
		394983, -- [32] Lightweight Shiv
		381631, -- [33] Flying Daggers
		121411, -- [34] Crimson Tempest
		381629, -- [35] Thrown Precision
		381626, -- [36] Bloody Mess
		381801, -- [37] Dragon-Tempered Blades
		381797, -- [38] Dashing Scoundrel
		255544, -- [39] Poison Bomb
		381669, -- [40] Twist the Knife
		360194, -- [41] Deathmark
		381800, -- [42] Tiny Toxic Blade
		381652, -- [43] Systemic Failure
		381634, -- [44] Vicious Venoms
		152152, -- [45] Venom Rush
		381802, -- [46] Indiscriminate Carnage
		381799, -- [47] Scent of Blood
		385478, -- [48] Shrouded Suffocation
		381673, -- [49] Doomblade
		196861, -- [50] Iron Wire
		200806, -- [51] Exsanguinate
		381632, -- [52] Improved Garrote
		381627, -- [53] Internal Bleeding
		36554, -- [54] Shadowstep
		2823, -- [55] Deadly Poison
		385627, -- [56] Kingsbane
		381798, -- [57] Zoldyck Recipe
		328085, -- [58] Blindside
		381630, -- [59] Intent to Kill
		381664, -- [60] Amplifying Poison
		255989, -- [61] Master Assassin
		381640, -- [62] Lethal Dose
		381622, -- [63] Resounding Clarity
		394332, -- [64] Reverberation
		385616, -- [65] Echoing Reprimand
		378996, -- [66] Recuperator
		57934, -- [67] Tricks of the Trade
		378807, -- [68] Shadowrunner
		108208, -- [69] Subterfuge
		381621, -- [70] Tight Spender
		36554, -- [71] Shadowstep
		2094, -- [72] Blind
		1966, -- [73] Feint
		1776, -- [74] Gouge
		231691, -- [75] Improved Sprint
		379005, -- [76] Blackjack
		31224, -- [77] Cloak of Shadows
		6770, -- [78] Sap
		5938, -- [79] Shiv
		5277, -- [80] Evasion
		5761, -- [81] Numbing Poison
		381637, -- [82] Atrophic Poison
		378813, -- [83] Fleet Footed
		231719, -- [84] Deadened Nerves
		193546, -- [85] Iron Stomach
		378427, -- [86] Nimble Fingers
	},
	-- Outlaw Rogue
	[260] = {
		193531, -- [0] Deeper Stratagem
		137619, -- [1] Marked for Death
		193539, -- [2] Alacrity
		196924, -- [3] Acrobatic Strikes
		381619, -- [4] Thief's Versatility
		79008, -- [5] Elusiveness
		31230, -- [6] Cheat Death
		382245, -- [7] Cold Blood
		382238, -- [8] Lethality
		185313, -- [9] Shadow Dance
		91023, -- [10] Find Weakness
		393970, -- [11] Soothing Darkness
		381620, -- [12] Improved Ambush
		14062, -- [13] Nightstalker
		378803, -- [14] Rushed Setup
		131511, -- [15] Prey on the Weak
		381623, -- [16] Thistle Tea
		14190, -- [17] Seal Fate
		280716, -- [18] Leeching Poison
		14983, -- [19] Vigor
		381542, -- [20] Deadly Precision
		381543, -- [21] Virulent Poisons
		319066, -- [22] Improved Wound Poison
		378436, -- [23] Master Poisoner
		381622, -- [24] Resounding Clarity
		394332, -- [25] Reverberation
		385616, -- [26] Echoing Reprimand
		378996, -- [27] Recuperator
		57934, -- [28] Tricks of the Trade
		378807, -- [29] Shadowrunner
		108208, -- [30] Subterfuge
		381621, -- [31] Tight Spender
		36554, -- [32] Shadowstep
		2094, -- [33] Blind
		1966, -- [34] Feint
		1776, -- [35] Gouge
		231691, -- [36] Improved Sprint
		379005, -- [37] Blackjack
		31224, -- [38] Cloak of Shadows
		6770, -- [39] Sap
		271877, -- [40] Blade Rush
		108216, -- [41] Dirty Tricks
		200733, -- [42] Weaponmaster
		256165, -- [43] Blinding Powder
		381845, -- [44] Audacity
		381885, -- [45] Heavy Hitter
		14161, -- [46] Ruthlessness
		256188, -- [47] Retractable Hook
		195457, -- [48] Grappling Hook
		279876, -- [49] Opportunity
		61329, -- [50] Combat Potency
		354897, -- [51] Float Like a Butterfly
		256170, -- [52] Loaded Dice
		381989, -- [53] Keep It Rolling
		381990, -- [54] Summarily Dispatched
		382794, -- [55] Restless Crew
		381982, -- [56] Count the Odds
		381839, -- [57] Sleight of Hand
		315508, -- [58] Roll the Bones
		79096, -- [59] Restless Blades
		13750, -- [60] Adrenaline Rush
		381822, -- [61] Ambidexterity
		344363, -- [62] Riposte
		35551, -- [63] Fatal Flourish
		196938, -- [64] Quick Draw
		51690, -- [65] Killing Spree
		343142, -- [66] Dreadblades
		386823, -- [67] Greenskin's Wickers
		381846, -- [68] Fan the Hammer
		381985, -- [69] Precise Cuts
		382746, -- [70] Improved Main Gauche
		272026, -- [71] Dancing Steel
		381878, -- [72] Deft Maneuvers
		196922, -- [73] Hit and Run
		381828, -- [74] Ace Up Your Sleeve
		315341, -- [75] Between the Eyes
		13877, -- [76] Blade Flurry
		383281, -- [77] Hidden Opportunity
		382742, -- [78] Take 'em by Surprise
		385408, -- [79] Sepsis
		196937, -- [80] Ghostly Strike
		381894, -- [81] Triple Threat
		394321, -- [82] Devious Stratagem
		381988, -- [83] Swift Slasher
		381877, -- [84] Combat Stamina
		5938, -- [85] Shiv
		5277, -- [86] Evasion
		5761, -- [87] Numbing Poison
		381637, -- [88] Atrophic Poison
		378813, -- [89] Fleet Footed
		231719, -- [90] Deadened Nerves
		193546, -- [91] Iron Stomach
		378427, -- [92] Nimble Fingers
	},
	-- Subtlety Rogue
	[261] = {
		319951, -- [0] Improved Shuriken Storm
		319175, -- [1] Black Powder
		277953, -- [2] Night Terrors
		382017, -- [3] Veiltouched
		185314, -- [4] Deepening Shadows
		384631, -- [5] Flagellation
		382504, -- [6] Dark Brew
		382525, -- [7] Finality
		382517, -- [8] Deeper Daggers
		394320, -- [9] Secret Stratagem
		382511, -- [10] Shadowed Finishers
		277925, -- [11] Shuriken Tornado
		382506, -- [12] Replicating Shadows
		280719, -- [13] Secret Technique
		385722, -- [14] Silent Storm
		58423, -- [15] Relentless Strikes
		382503, -- [16] Quick Decisions
		36554, -- [17] Shadowstep
		382528, -- [18] Danse Macabre
		382524, -- [19] Lingering Shadow
		245687, -- [20] Dark Shadow
		382515, -- [21] Cloaked in Shadows
		382514, -- [22] Fade to Nothing
		393972, -- [23] Improved Shadow Dance
		382505, -- [24] The First Dance
		196976, -- [25] Master of Shadows
		382509, -- [26] Stiletto Staccato
		121471, -- [27] Shadow Blades
		193531, -- [28] Deeper Stratagem
		137619, -- [29] Marked for Death
		193539, -- [30] Alacrity
		196924, -- [31] Acrobatic Strikes
		381619, -- [32] Thief's Versatility
		79008, -- [33] Elusiveness
		31230, -- [34] Cheat Death
		382245, -- [35] Cold Blood
		382238, -- [36] Lethality
		185313, -- [37] Shadow Dance
		91023, -- [38] Find Weakness
		393970, -- [39] Soothing Darkness
		381620, -- [40] Improved Ambush
		14062, -- [41] Nightstalker
		378803, -- [42] Rushed Setup
		131511, -- [43] Prey on the Weak
		381623, -- [44] Thistle Tea
		14190, -- [45] Seal Fate
		280716, -- [46] Leeching Poison
		14983, -- [47] Vigor
		381542, -- [48] Deadly Precision
		381543, -- [49] Virulent Poisons
		319066, -- [50] Improved Wound Poison
		378436, -- [51] Master Poisoner
		108209, -- [52] Shadow Focus
		381622, -- [53] Resounding Clarity
		394332, -- [54] Reverberation
		385616, -- [55] Echoing Reprimand
		378996, -- [56] Recuperator
		57934, -- [57] Tricks of the Trade
		378807, -- [58] Shadowrunner
		108208, -- [59] Subterfuge
		381621, -- [60] Tight Spender
		36554, -- [61] Shadowstep
		2094, -- [62] Blind
		1966, -- [63] Feint
		1776, -- [64] Gouge
		231691, -- [65] Improved Sprint
		379005, -- [66] Blackjack
		31224, -- [67] Cloak of Shadows
		6770, -- [68] Sap
		5938, -- [69] Shiv
		5277, -- [70] Evasion
		5761, -- [71] Numbing Poison
		381637, -- [72] Atrophic Poison
		378813, -- [73] Fleet Footed
		231719, -- [74] Deadened Nerves
		193546, -- [75] Iron Stomach
		378427, -- [76] Nimble Fingers
		319949, -- [77] Improved Backstab
		257505, -- [78] Shot in the Dark
		193537, -- [79] Weaponmaster
		394023, -- [80] Improved Shadow Techniques
		343160, -- [81] Premeditation
		200758, -- [82] Gloomblade
		382507, -- [83] Shrouded in Darkness
		394309, -- [84] Swift Death
		382513, -- [85] Without a Trace
		382508, -- [86] Planned Execution
		385408, -- [87] Sepsis
		382015, -- [88] The Rotten
		382523, -- [89] Invigorating Shadowdust
		382512, -- [90] Inevitability
		382518, -- [91] Perforated Veins
	},
	-- Elemental Shaman
	[262] = {
		8143, -- [0] Tremor Totem
		265046, -- [1] Static Charge
		381819, -- [2] Guardian's Cudgel
		192058, -- [3] Capacitor Totem
		260878, -- [4] Spirit Wolf
		378075, -- [5] Thunderous Paws
		196840, -- [6] Frost Shock
		51886, -- [7] Cleanse Spirit
		370, -- [8] Purge
		378773, -- [9] Greater Purge
		204268, -- [10] Voodoo Mastery
		378079, -- [11] Enfeeblement
		51514, -- [12] Hex
		108287, -- [13] Totemic Projection
		30884, -- [14] Nature's Guardian
		192077, -- [15] Wind Rush Totem
		51485, -- [16] Earthgrab Totem
		382947, -- [17] Ancestral Defense
		381650, -- [18] Elemental Warding
		381689, -- [19] Brimming with Life
		381655, -- [20] Nature's Fury
		382215, -- [21] Winds of Al'Akir
		58875, -- [22] Spirit Walk
		192063, -- [23] Gust of Wind
		381678, -- [24] Go with the Flow
		383011, -- [25] Call of the Elements
		383012, -- [26] Creation Core
		108285, -- [27] Totemic Recall
		382033, -- [28] Surging Shields
		383013, -- [29] Poison Cleansing Totem
		382201, -- [30] Totemic Focus
		383017, -- [31] Stoneskin Totem
		383019, -- [32] Tranquil Air Totem
		378779, -- [33] Thundershock
		305483, -- [34] Lightning Lasso
		51490, -- [35] Thunderstorm
		381674, -- [36] Improved Lightning Bolt
		378081, -- [37] Nature's Swiftness
		5394, -- [38] Healing Stream Totem
		378094, -- [39] Swirling Currents
		108281, -- [40] Ancestral Guidance
		381930, -- [41] Mana Spring Totem
		381867, -- [42] Totemic Surge
		383010, -- [43] Elemental Orbit
		974, -- [44] Earth Shield
		57994, -- [45] Wind Shear
		382886, -- [46] Fire and Ice
		79206, -- [47] Spiritwalker's Grace
		192088, -- [48] Graceful Spirit
		378077, -- [49] Spiritwalker's Aegis
		198103, -- [50] Earth Elemental
		1064, -- [51] Chain Heal
		51505, -- [52] Lava Burst
		188443, -- [53] Chain Lightning
		187880, -- [54] Maelstrom Weapon
		382888, -- [55] Flurry
		381666, -- [56] Focused Insight
		108271, -- [57] Astral Shift
		381647, -- [58] Planes Traveler
		377933, -- [59] Astral Bulwark
		381707, -- [60] Swelling Maelstrom
		191861, -- [61] Power of the Maelstrom
		375982, -- [62] Primordial Wave
		382032, -- [63] Echo Chamber
		381726, -- [64] Mountains Will Fall
		378255, -- [65] Call of Fire
		378266, -- [66] Flames of the Cauldron
		382027, -- [67] Improved Flametongue Weapon
		117013, -- [68] Primal Elementalist
		192222, -- [69] Liquid Magma Totem
		381932, -- [70] Magma Chamber
		378268, -- [71] Windspeaker's Lava Resurgence
		378310, -- [72] Skybreaker's Fiery Demise
		381782, -- [73] Searing Flames
		16166, -- [74] Master of the Elements
		378270, -- [75] Deeply Rooted Elements
		114050, -- [76] Ascendance
		381785, -- [77] Oath of the Far Seer
		381787, -- [78] Further Beyond
		273221, -- [79] Aftershock
		262303, -- [80] Surge of Power
		333919, -- [81] Echo of the Elements
		385923, -- [82] Flow of Power
		210714, -- [83] Icefury
		381776, -- [84] Flux Melting
		382086, -- [85] Electrified Shocks
		381708, -- [86] Eye of the Storm
		117014, -- [87] Elemental Blast
		378271, -- [88] Elemental Equilibrium
		210689, -- [89] Lightning Rod
		191634, -- [90] Stormkeeper
		384087, -- [91] Echoes of Great Sundering
		381936, -- [92] Flash of Lightning
		191634, -- [93] Stormkeeper
		382685, -- [94] Unrelenting Calamity
		378241, -- [95] Call of Thunder
		381743, -- [96] Tumultuous Fissures
		378776, -- [97] Inundate
		61882, -- [98] Earthquake
		8042, -- [99] Earth Shock
		60188, -- [100] Elemental Fury
		378193, -- [101] Primordial Fury
		382197, -- [102] Ancestral Wolf Affinity
		198067, -- [103] Fire Elemental
		192249, -- [104] Storm Elemental
		378211, -- [105] Refreshing Waters
		381764, -- [106] Primordial Bond
		77756, -- [107] Lava Surge
		386474, -- [108] Heat Wave
		382042, -- [109] Splintered Elements
		386443, -- [110] Rolling Magma
	},
	-- Enhancement Shaman
	[263] = {
		8143, -- [0] Tremor Totem
		265046, -- [1] Static Charge
		381819, -- [2] Guardian's Cudgel
		192058, -- [3] Capacitor Totem
		260878, -- [4] Spirit Wolf
		378075, -- [5] Thunderous Paws
		196840, -- [6] Frost Shock
		370, -- [7] Purge
		378773, -- [8] Greater Purge
		51886, -- [9] Cleanse Spirit
		204268, -- [10] Voodoo Mastery
		378079, -- [11] Enfeeblement
		51514, -- [12] Hex
		108287, -- [13] Totemic Projection
		30884, -- [14] Nature's Guardian
		192077, -- [15] Wind Rush Totem
		51485, -- [16] Earthgrab Totem
		382947, -- [17] Ancestral Defense
		381650, -- [18] Elemental Warding
		381689, -- [19] Brimming with Life
		381655, -- [20] Nature's Fury
		382215, -- [21] Winds of Al'Akir
		58875, -- [22] Spirit Walk
		192063, -- [23] Gust of Wind
		381678, -- [24] Go with the Flow
		383011, -- [25] Call of the Elements
		383012, -- [26] Creation Core
		108285, -- [27] Totemic Recall
		382033, -- [28] Surging Shields
		383013, -- [29] Poison Cleansing Totem
		382201, -- [30] Totemic Focus
		383017, -- [31] Stoneskin Totem
		383019, -- [32] Tranquil Air Totem
		378779, -- [33] Thundershock
		305483, -- [34] Lightning Lasso
		51490, -- [35] Thunderstorm
		381674, -- [36] Improved Lightning Bolt
		378081, -- [37] Nature's Swiftness
		5394, -- [38] Healing Stream Totem
		378094, -- [39] Swirling Currents
		108281, -- [40] Ancestral Guidance
		381930, -- [41] Mana Spring Totem
		381867, -- [42] Totemic Surge
		383010, -- [43] Elemental Orbit
		974, -- [44] Earth Shield
		57994, -- [45] Wind Shear
		382886, -- [46] Fire and Ice
		79206, -- [47] Spiritwalker's Grace
		393905, -- [48] Refreshing Waters
		382197, -- [49] Ancestral Wolf Affinity
		384149, -- [50] Overflowing Maelstrom
		384143, -- [51] Raging Maelstrom
		8512, -- [52] Windfury Totem
		17364, -- [53] Stormstrike
		60103, -- [54] Lava Lash
		334033, -- [55] Molten Assault
		334195, -- [56] Hailstorm
		333974, -- [57] Fire Nova
		201900, -- [58] Hot Hand
		196884, -- [59] Feral Lunge
		390370, -- [60] Ashen Catalyst
		334046, -- [61] Lashing Flames
		384444, -- [62] Thorim's Invocation
		384411, -- [63] Static Accumulation
		384450, -- [64] Legacy of the Frost Witch
		114051, -- [65] Ascendance
		378270, -- [66] Deeply Rooted Elements
		334308, -- [67] Crashing Storms
		344357, -- [68] Stormflurry
		384359, -- [69] Swirling Maelstrom
		342240, -- [70] Ice Strike
		383303, -- [71] Improved Maelstrom Weapon
		33757, -- [72] Windfury Weapon
		384352, -- [73] Doom Winds
		384355, -- [74] Elemental Weapons
		210853, -- [75] Elemental Assault
		192088, -- [76] Graceful Spirit
		378077, -- [77] Spiritwalker's Aegis
		198103, -- [78] Earth Elemental
		1064, -- [79] Chain Heal
		51505, -- [80] Lava Burst
		188443, -- [81] Chain Lightning
		187880, -- [82] Maelstrom Weapon
		382888, -- [83] Flurry
		381666, -- [84] Focused Insight
		108271, -- [85] Astral Shift
		381647, -- [86] Planes Traveler
		377933, -- [87] Astral Bulwark
		197214, -- [88] Sundering
		187874, -- [89] Crash Lightning
		384363, -- [90] Gathering Storms
		51533, -- [91] Feral Spirit
		384447, -- [92] Witch Doctor's Ancestry
		262624, -- [93] Elemental Spirits
		198434, -- [94] Alpha Wolf
		262647, -- [95] Forceful Winds
		390288, -- [96] Unruly Winds
		392352, -- [97] Storm's Wrath
		117014, -- [98] Elemental Blast
		375982, -- [99] Primordial Wave
		384405, -- [100] Primal Maelstrom
		382042, -- [101] Splintered Elements
		319930, -- [102] Stormblast
	},
	-- Restoration Shaman
	[264] = {
		98008, -- [0] Spirit Link Totem
		207401, -- [1] Ancestral Vigor
		382197, -- [2] Ancestral Wolf Affinity
		383009, -- [3] Stormkeeper
		200076, -- [4] Deluge
		61295, -- [5] Riptide
		77472, -- [6] Healing Wave
		8143, -- [7] Tremor Totem
		265046, -- [8] Static Charge
		381819, -- [9] Guardian's Cudgel
		192058, -- [10] Capacitor Totem
		260878, -- [11] Spirit Wolf
		378075, -- [12] Thunderous Paws
		383016, -- [13] Improved Purify Spirit
		196840, -- [14] Frost Shock
		370, -- [15] Purge
		378773, -- [16] Greater Purge
		204268, -- [17] Voodoo Mastery
		378079, -- [18] Enfeeblement
		51514, -- [19] Hex
		108287, -- [20] Totemic Projection
		30884, -- [21] Nature's Guardian
		192077, -- [22] Wind Rush Totem
		51485, -- [23] Earthgrab Totem
		382947, -- [24] Ancestral Defense
		381650, -- [25] Elemental Warding
		381689, -- [26] Brimming with Life
		381655, -- [27] Nature's Fury
		382215, -- [28] Winds of Al'Akir
		58875, -- [29] Spirit Walk
		192063, -- [30] Gust of Wind
		381678, -- [31] Go with the Flow
		383011, -- [32] Call of the Elements
		383012, -- [33] Creation Core
		108285, -- [34] Totemic Recall
		382033, -- [35] Surging Shields
		383013, -- [36] Poison Cleansing Totem
		382201, -- [37] Totemic Focus
		383017, -- [38] Stoneskin Totem
		383019, -- [39] Tranquil Air Totem
		378779, -- [40] Thundershock
		305483, -- [41] Lightning Lasso
		51490, -- [42] Thunderstorm
		381674, -- [43] Improved Lightning Bolt
		378081, -- [44] Nature's Swiftness
		5394, -- [45] Healing Stream Totem
		378094, -- [46] Swirling Currents
		108281, -- [47] Ancestral Guidance
		381930, -- [48] Mana Spring Totem
		381867, -- [49] Totemic Surge
		383010, -- [50] Elemental Orbit
		974, -- [51] Earth Shield
		382045, -- [52] Primal Tide Core
		157154, -- [53] High Tide
		382309, -- [54] Ancestral Awakening
		333919, -- [55] Echo of the Elements
		16191, -- [56] Mana Tide Totem
		198838, -- [57] Earthen Wall Totem
		207399, -- [58] Ancestral Protection Totem
		200072, -- [59] Torrent
		382482, -- [60] Living Stream
		157153, -- [61] Cloudburst Totem
		382021, -- [62] Earthliving Weapon
		382315, -- [63] Improved Earthliving Weapon
		378270, -- [64] Deeply Rooted Elements
		197995, -- [65] Wellspring
		382194, -- [66] Undercurrent
		382029, -- [67] Ever-Rising Tide
		382020, -- [68] Earthen Harmony
		57994, -- [69] Wind Shear
		382886, -- [70] Fire and Ice
		79206, -- [71] Spiritwalker's Grace
		382732, -- [72] Ancestral Reach
		382039, -- [73] Flow of the Tides
		108280, -- [74] Healing Tide Totem
		382191, -- [75] Improved Primordial Wave
		375982, -- [76] Primordial Wave
		200071, -- [77] Undulation
		73685, -- [78] Unleash Life
		381946, -- [79] Wavespeaker's Blessing
		383222, -- [80] Overflowing Shores
		378443, -- [81] Acid Rain
		73920, -- [82] Healing Rain
		382019, -- [83] Nature's Focus
		192088, -- [84] Graceful Spirit
		378077, -- [85] Spiritwalker's Aegis
		198103, -- [86] Earth Elemental
		1064, -- [87] Chain Heal
		51505, -- [88] Lava Burst
		188443, -- [89] Chain Lightning
		187880, -- [90] Maelstrom Weapon
		382888, -- [91] Flurry
		381666, -- [92] Focused Insight
		108271, -- [93] Astral Shift
		381647, -- [94] Planes Traveler
		377933, -- [95] Astral Bulwark
		114052, -- [96] Ascendance
		52127, -- [97] Water Shield
		16196, -- [98] Resurgence
		378241, -- [99] Call of Thunder
		5394, -- [100] Healing Stream Totem
		51564, -- [101] Tidal Waves
		280614, -- [102] Flash Flood
		378211, -- [103] Refreshing Waters
		16166, -- [104] Master of the Elements
		382030, -- [105] Water Totem Mastery
		77756, -- [106] Lava Surge
		207778, -- [107] Downpour
		382046, -- [108] Continuous Waves
		382040, -- [109] Tumbling Waves
	},
	-- Affliction Warlock
	[265] = {
		268358, -- [0] Demonic Circle
		386113, -- [1] Fel Pact
		333889, -- [2] Fel Domination
		288843, -- [3] Demonic Embrace
		386619, -- [4] Desperate Pact
		386858, -- [5] Demonic Inspiration
		386620, -- [6] Sweet Souls
		386689, -- [7] Grim Feast
		108415, -- [8] Soul Link
		171975, -- [9] Grimoire of Synergy
		215941, -- [10] Soul Conduit
		386617, -- [11] Demonic Fortitude
		389761, -- [12] Malefic Affliction
		389630, -- [13] Soul-Eater's Gluttony
		389576, -- [14] Profane Bargain
		389367, -- [15] Fel Synergy
		389590, -- [16] Demonic Resilience
		389623, -- [17] Gorefiend's Resolve
		389359, -- [18] Resolute Barrier
		264000, -- [19] Creeping Death
		387016, -- [20] Dark Harvest
		386997, -- [21] Soul Rot
		386976, -- [22] Withering Bolt
		108503, -- [23] Grimoire of Sacrifice
		196103, -- [24] Absolute Corruption
		63106, -- [25] Siphon Life
		386759, -- [26] Pandemic Invocation
		317031, -- [27] Xavian Teachings
		27243, -- [28] Seed of Corruption
		324536, -- [29] Malefic Rapture
		316099, -- [30] Unstable Affliction
		108558, -- [31] Nightfall
		334319, -- [32] Inevitable Demise
		198590, -- [33] Drain Soul
		32388, -- [34] Shadow Embrace
		201424, -- [35] Harvester of Souls
		387073, -- [36] Soul Tap
		199471, -- [37] Soul Flame
		196102, -- [38] Writhe in Agony
		196226, -- [39] Sow the Seeds
		386922, -- [40] Agonizing Corruption
		386951, -- [41] Soul Swap
		205179, -- [42] Phantom Singularity
		278350, -- [43] Vile Taint
		386986, -- [44] Sacrolash's Dark Strike
		205180, -- [45] Summon Darkglare
		387065, -- [46] Wrath of Consumption
		48181, -- [47] Haunt
		387075, -- [48] Tormented Crescendo
		328774, -- [49] Amplify Curse
		387972, -- [50] Teachings of the Satyr
		389764, -- [51] Doom Blossom
		389775, -- [52] Dread Touch
		387273, -- [53] Malevolent Visionary
		387084, -- [54] Grand Warlock's Design
		389992, -- [55] Grim Reach
		386664, -- [56] Ichor of Devils
		386686, -- [57] Frequent Donor
		387301, -- [58] Haunted Soul
		387250, -- [59] Seized Vitality
		385899, -- [60] Soulburn
		317138, -- [61] Strength of Will
		386659, -- [62] Dark Accord
		111771, -- [63] Demonic Gateway
		389609, -- [64] Abyss Walker
		386613, -- [65] Accrued Vitality
		219272, -- [66] Demon Skin
		386105, -- [67] Curses of Enfeeblement
		386124, -- [68] Fel Armor
		111400, -- [69] Burning Rush
		386110, -- [70] Fiendish Stride
		5484, -- [71] Howl of Terror
		6789, -- [72] Mortal Coil
		386864, -- [73] Wrathful Minion
		386648, -- [74] Nightmare
		710, -- [75] Banish
		386651, -- [76] Greater Banish
		30283, -- [77] Shadowfury
		264874, -- [78] Darkfury
		384069, -- [79] Shadowflame
		386646, -- [80] Lifeblood
		386256, -- [81] Summon Soulkeeper
		386344, -- [82] Inquisitor's Gaze
		385881, -- [83] Teachings of the Black Harvest
		108416, -- [84] Dark Pact
	},
	-- Demonology Warlock
	[266] = {
		268358, -- [0] Demonic Circle
		386113, -- [1] Fel Pact
		333889, -- [2] Fel Domination
		288843, -- [3] Demonic Embrace
		386619, -- [4] Desperate Pact
		386858, -- [5] Demonic Inspiration
		386620, -- [6] Sweet Souls
		386689, -- [7] Grim Feast
		108415, -- [8] Soul Link
		171975, -- [9] Grimoire of Synergy
		215941, -- [10] Soul Conduit
		386617, -- [11] Demonic Fortitude
		389576, -- [12] Profane Bargain
		389367, -- [13] Fel Synergy
		389590, -- [14] Demonic Resilience
		389623, -- [15] Gorefiend's Resolve
		389359, -- [16] Resolute Barrier
		265187, -- [17] Summon Demonic Tyrant
		387483, -- [18] Kazaak's Final Curse
		603, -- [19] Doom
		267216, -- [20] Inner Demons
		386185, -- [21] Demonic Knowledge
		387322, -- [22] Shadow's Bite
		264178, -- [23] Demonbolt
		104316, -- [24] Call Dreadstalkers
		386174, -- [25] Annihilan Training
		267211, -- [26] Bilescourge Bombers
		267171, -- [27] Demonic Strength
		264078, -- [28] Dreadlash
		264119, -- [29] Summon Vilefiend
		264057, -- [30] Soul Strike
		386194, -- [31] Carnivorous Stalkers
		205145, -- [32] Demonic Calling
		386200, -- [33] Fel and Steel
		328774, -- [34] Amplify Curse
		387972, -- [35] Teachings of the Satyr
		267170, -- [36] From the Shadows
		387399, -- [37] Fel Sunder
		111898, -- [38] Grimoire: Felguard
		387396, -- [39] Demonic Meteor
		387488, -- [40] Hounds of War
		386664, -- [41] Ichor of Devils
		386686, -- [42] Frequent Donor
		390173, -- [43] Reign of Tyranny
		387084, -- [44] Grand Warlock's Design
		334585, -- [45] Soulbound Tyrant
		267214, -- [46] Sacrificed Souls
		387600, -- [47] The Expendables
		387578, -- [48] Gul'dan's Ambition
		387526, -- [49] Ner'zhul's Volition
		267217, -- [50] Nether Portal
		387445, -- [51] Imp Gang Boss
		387391, -- [52] Dread Calling
		387432, -- [53] Fel Covenant
		387349, -- [54] Bloodbound Imps
		196277, -- [55] Implosion
		264130, -- [56] Power Siphon
		387541, -- [57] Pact of the Imp Mother
		387549, -- [58] Infernal Command
		385899, -- [59] Soulburn
		317138, -- [60] Strength of Will
		386659, -- [61] Dark Accord
		111771, -- [62] Demonic Gateway
		389609, -- [63] Abyss Walker
		386613, -- [64] Accrued Vitality
		219272, -- [65] Demon Skin
		386105, -- [66] Curses of Enfeeblement
		386124, -- [67] Fel Armor
		111400, -- [68] Burning Rush
		386110, -- [69] Fiendish Stride
		5484, -- [70] Howl of Terror
		6789, -- [71] Mortal Coil
		386864, -- [72] Wrathful Minion
		386648, -- [73] Nightmare
		386833, -- [74] Guillotine
		710, -- [75] Banish
		386651, -- [76] Greater Banish
		30283, -- [77] Shadowfury
		264874, -- [78] Darkfury
		384069, -- [79] Shadowflame
		386646, -- [80] Lifeblood
		386256, -- [81] Summon Soulkeeper
		386344, -- [82] Inquisitor's Gaze
		385881, -- [83] Teachings of the Black Harvest
		108416, -- [84] Dark Pact
		387602, -- [85] Stolen Power
		387494, -- [86] Antoran Armaments
		387485, -- [87] Ripped through the Portal
		387338, -- [88] Fel Might
	},
	-- Destruction Warlock
	[267] = {
		266086, -- [0] Rain of Chaos
		387084, -- [1] Grand Warlock's Design
		268358, -- [2] Demonic Circle
		386113, -- [3] Fel Pact
		333889, -- [4] Fel Domination
		288843, -- [5] Demonic Embrace
		386619, -- [6] Desperate Pact
		386858, -- [7] Demonic Inspiration
		386620, -- [8] Sweet Souls
		386689, -- [9] Grim Feast
		108415, -- [10] Soul Link
		171975, -- [11] Grimoire of Synergy
		215941, -- [12] Soul Conduit
		386617, -- [13] Demonic Fortitude
		389576, -- [14] Profane Bargain
		389367, -- [15] Fel Synergy
		389590, -- [16] Demonic Resilience
		389623, -- [17] Gorefiend's Resolve
		389359, -- [18] Resolute Barrier
		5740, -- [19] Rain of Fire
		116858, -- [20] Chaos Bolt
		17962, -- [21] Conflagrate
		196406, -- [22] Backdraft
		205184, -- [23] Roaring Blaze
		231793, -- [24] Improved Conflagrate
		196447, -- [25] Channel Demonfire
		387166, -- [26] Raging Demonfire
		387103, -- [27] Ruin
		387108, -- [28] Conflagration of Chaos
		17877, -- [29] Shadowburn
		388827, -- [30] Explosive Potential
		328774, -- [31] Amplify Curse
		387972, -- [32] Teachings of the Satyr
		387475, -- [33] Infernal Brand
		387355, -- [34] Crashing Chaos
		387569, -- [35] Rolling Havoc
		387165, -- [36] Master Ritualist
		387159, -- [37] Avatar of Destruction
		387153, -- [38] Burn to Ashes
		387279, -- [39] Power Overwhelming
		387275, -- [40] Chaos Incarnate
		387976, -- [41] Dimensional Rift
		387400, -- [42] Madness of the Azj'Aqir
		387173, -- [43] Diabolic Embers
		387252, -- [44] Ashen Remains
		387156, -- [45] Ritual of Ruin
		108503, -- [46] Grimoire of Sacrifice
		387259, -- [47] Flashpoint
		388832, -- [48] Scalding Flames
		270545, -- [49] Inferno
		152108, -- [50] Cataclysm
		387095, -- [51] Pyrogenics
		387093, -- [52] Improved Immolate
		387176, -- [53] Decimation
		6353, -- [54] Soul Fire
		387506, -- [55] Mayhem
		80240, -- [56] Havoc
		205148, -- [57] Reverse Entropy
		266134, -- [58] Internal Combustion
		387509, -- [59] Pandemonium
		387522, -- [60] Cry Havoc
		196408, -- [61] Fire and Brimstone
		387384, -- [62] Backlash
		196412, -- [63] Eradication
		1122, -- [64] Summon Infernal
		386664, -- [65] Ichor of Devils
		386686, -- [66] Frequent Donor
		385899, -- [67] Soulburn
		317138, -- [68] Strength of Will
		386659, -- [69] Dark Accord
		111771, -- [70] Demonic Gateway
		389609, -- [71] Abyss Walker
		386613, -- [72] Accrued Vitality
		219272, -- [73] Demon Skin
		386105, -- [74] Curses of Enfeeblement
		386124, -- [75] Fel Armor
		111400, -- [76] Burning Rush
		386110, -- [77] Fiendish Stride
		5484, -- [78] Howl of Terror
		6789, -- [79] Mortal Coil
		386864, -- [80] Wrathful Minion
		386648, -- [81] Nightmare
		710, -- [82] Banish
		386651, -- [83] Greater Banish
		30283, -- [84] Shadowfury
		264874, -- [85] Darkfury
		384069, -- [86] Shadowflame
		386646, -- [87] Lifeblood
		386256, -- [88] Summon Soulkeeper
		386344, -- [89] Inquisitor's Gaze
		385881, -- [90] Teachings of the Black Harvest
		108416, -- [91] Dark Pact
	},
	-- Brewmaster Monk
	[268] = {
		218164, -- [0] Detox
		386276, -- [1] Bonedust Brew
		386949, -- [2] Bountiful Brew
		386941, -- [3] Attenuation
		116847, -- [4] Rushing Jade Wind
		196730, -- [5] Special Delivery
		115176, -- [6] Zen Meditation
		393357, -- [7] Tranquil Spirit
		383700, -- [8] Gai Plin's Imperial Brew
		132578, -- [9] Invoke Niuzao, the Black Ox
		387219, -- [10] Walk with the Ox
		325153, -- [11] Exploding Keg
		383707, -- [12] Stormstout's Last Keg
		322740, -- [13] Invoke Niuzao, the Black Ox
		387184, -- [14] Weapons of Order
		356684, -- [15] Call to Arms
		393400, -- [16] Chi Surge
		389577, -- [17] Bounce Back
		115315, -- [18] Summon Black Ox Statue
		394110, -- [19] Escape from Reality
		389579, -- [20] Save Them All
		115313, -- [21] Summon Jade Serpent Statue
		328669, -- [22] Improved Roll
		392900, -- [23] Vigorous Expulsion
		388811, -- [24] Grace of the Crane
		115098, -- [25] Chi Wave
		123986, -- [26] Chi Burst
		392910, -- [27] Profound Rebuttal
		389574, -- [28] Close to Heart
		388674, -- [29] Ferocity of Xuen
		388809, -- [30] Fast Feet
		122278, -- [31] Dampen Harm
		394123, -- [32] Fatal Touch
		389578, -- [33] Resonant Fists
		388686, -- [34] Summon White Tiger Statue
		196607, -- [35] Eye of the Tiger
		157411, -- [36] Windwalking
		116844, -- [37] Ring of Peace
		122783, -- [38] Diffuse Magic
		328670, -- [39] Hasty Provocation
		388812, -- [40] Vivacious Vivification
		101643, -- [41] Transcendence
		388664, -- [42] Calming Presence
		231602, -- [43] Improved Vivify
		115175, -- [44] Soothing Mist
		107428, -- [45] Rising Sun Kick
		116841, -- [46] Tiger's Lust
		115078, -- [47] Paralysis
		344359, -- [48] Paralysis
		116705, -- [49] Spear Hand Strike
		115173, -- [50] Celerity
		115008, -- [51] Chi Torpedo
		322113, -- [52] Improved Touch of Death
		389575, -- [53] Generous Pour
		387276, -- [54] Strength of Spirit
		388814, -- [55] Ironshell Brew
		388813, -- [56] Expeditious Fortification
		388917, -- [57] Fortifying Brew
		116095, -- [58] Disable
		196736, -- [59] Blackout Combo
		387046, -- [60] Elusive Footwork
		388681, -- [61] Elusive Mists
		264348, -- [62] Tiger Tail Sweep
		387035, -- [63] Fundamental Observation
		324312, -- [64] Clash
		383785, -- [65] Counterstrike
		389942, -- [66] Face Palm
		387638, -- [67] Shadowboxing Treads
		387230, -- [68] Fluidity of Motion
		393516, -- [69] Pretense of Instability
		386937, -- [70] Anvil & Stave
		325093, -- [71] Light Brewing
		383714, -- [72] Training of Niuzao
		115399, -- [73] Black Ox Brew
		280515, -- [74] Bob and Weave
		121253, -- [75] Keg Smash
		124502, -- [76] Gift of the Ox
		119582, -- [77] Purifying Brew
		115069, -- [78] Stagger
		322120, -- [79] Shuffle
		388505, -- [80] Quick Sip
		387256, -- [81] Graceful Exit
		122281, -- [82] Healing Elixir
		387625, -- [83] Staggering Strikes
		325177, -- [84] Celestial Flames
		383695, -- [85] Hit Scheme
		322510, -- [86] Improved Celestial Brew
		322507, -- [87] Celestial Brew
		115181, -- [88] Breath of Fire
		383994, -- [89] Dragonfire Brew
		386965, -- [90] Charred Passions
		383698, -- [91] Scalding Brew
		383697, -- [92] Sal'salabim's Strength
		196737, -- [93] High Tolerance
		322960, -- [94] Fortifying Brew
		343743, -- [95] Improved Purifying Brew
	},
	-- Windwalker Monk
	[269] = {
		388193, -- [0] Faeline Stomp
		389577, -- [1] Bounce Back
		115315, -- [2] Summon Black Ox Statue
		394110, -- [3] Escape from Reality
		389579, -- [4] Save Them All
		115313, -- [5] Summon Jade Serpent Statue
		328669, -- [6] Improved Roll
		392900, -- [7] Vigorous Expulsion
		388811, -- [8] Grace of the Crane
		115098, -- [9] Chi Wave
		123986, -- [10] Chi Burst
		392910, -- [11] Profound Rebuttal
		389574, -- [12] Close to Heart
		388674, -- [13] Ferocity of Xuen
		388809, -- [14] Fast Feet
		122278, -- [15] Dampen Harm
		394123, -- [16] Fatal Touch
		389578, -- [17] Resonant Fists
		388686, -- [18] Summon White Tiger Statue
		196607, -- [19] Eye of the Tiger
		157411, -- [20] Windwalking
		116844, -- [21] Ring of Peace
		122783, -- [22] Diffuse Magic
		328670, -- [23] Hasty Provocation
		388812, -- [24] Vivacious Vivification
		101643, -- [25] Transcendence
		388664, -- [26] Calming Presence
		231602, -- [27] Improved Vivify
		115175, -- [28] Soothing Mist
		107428, -- [29] Rising Sun Kick
		116841, -- [30] Tiger's Lust
		115078, -- [31] Paralysis
		344359, -- [32] Paralysis
		116705, -- [33] Spear Hand Strike
		115173, -- [34] Celerity
		115008, -- [35] Chi Torpedo
		322113, -- [36] Improved Touch of Death
		389575, -- [37] Generous Pour
		387276, -- [38] Strength of Spirit
		388814, -- [39] Ironshell Brew
		388813, -- [40] Expeditious Fortification
		388917, -- [41] Fortifying Brew
		116095, -- [42] Disable
		392970, -- [43] Open Palm Strikes
		392958, -- [44] Glory of the Dawn
		196740, -- [45] Hit Combo
		392983, -- [46] Strike of the Windlord
		392985, -- [47] Thunderfist
		388849, -- [48] Rising Star
		195243, -- [49] Inner Peace
		388681, -- [50] Elusive Mists
		264348, -- [51] Tiger Tail Sweep
		392994, -- [52] Way of the Fae
		218164, -- [53] Detox
		392979, -- [54] Jade Ignition
		393098, -- [55] Forbidden Technique
		388846, -- [56] Widening Whirl
		122470, -- [57] Touch of Karma
		391383, -- [58] Hardened Soles
		115396, -- [59] Ascension
		113656, -- [60] Fists of Fury
		121817, -- [61] Power Strikes
		388854, -- [62] Flashing Fists
		116645, -- [63] Teachings of the Monastery
		280197, -- [64] Spiritual Focus
		137639, -- [65] Storm, Earth, and Fire
		152173, -- [66] Serenity
		391370, -- [67] Drinking Horn Cover
		391330, -- [68] Meridian Strikes
		101545, -- [69] Flying Serpent Kick
		388856, -- [70] Touch of the Tiger
		228287, -- [71] Mark of the Crane
		392982, -- [72] Shadowboxing Treads
		116847, -- [73] Rushing Jade Wind
		325201, -- [74] Dance of Chi-Ji
		287055, -- [75] Fury of Xuen
		123904, -- [76] Invoke Xuen, the White Tiger
		152175, -- [77] Whirling Dragon Punch
		335913, -- [78] Empowered Tiger Lightning
		195300, -- [79] Transfer the Power
		388661, -- [80] Invoker's Delight
		392993, -- [81] Xuen's Battlegear
		392991, -- [82] Skyreach
		392989, -- [83] Last Emperor's Capacitor
		392986, -- [84] Xuen's Bond
		394923, -- [85] Fatal Flying Guillotine
		388848, -- [86] Crane Vortex
		386941, -- [87] Attenuation
		386276, -- [88] Bonedust Brew
		394093, -- [89] Dust in the Wind
		391412, -- [90] Faeline Harmony
	},
	-- Mistweaver Monk
	[270] = {
		198898, -- [0] Song of Chi-Ji
		210802, -- [1] Spirit of the Crane
		197900, -- [2] Mist Wrap
		196725, -- [3] Refreshing Jade Wind
		388604, -- [4] Echoing Reverberation
		388564, -- [5] Accumulating Mist
		393460, -- [6] Tea of Serenity
		388517, -- [7] Tea of Plenty
		124081, -- [8] Zen Pulse
		388548, -- [9] Mists of Life
		124682, -- [10] Enveloping Mist
		388740, -- [11] Ancient Concordance
		388491, -- [12] Secret Infusion
		388661, -- [13] Invoker's Delight
		122281, -- [14] Healing Elixir
		388477, -- [15] Unison
		388509, -- [16] Mending Proliferation
		115310, -- [17] Revival
		388615, -- [18] Restoral
		197915, -- [19] Lifecycles
		197908, -- [20] Mana Tea
		388031, -- [21] Jade Bond
		388212, -- [22] Gift of the Celestials
		388779, -- [23] Awakened Faeline
		388038, -- [24] Yu'lon's Whisper
		388847, -- [25] Rapid Diffusion
		337209, -- [26] Font of Life
		388511, -- [27] Overflowing Mists
		343655, -- [28] Enveloping Breath
		388218, -- [29] Calming Coalescence
		388874, -- [30] Improved Detox
		389577, -- [31] Bounce Back
		115315, -- [32] Summon Black Ox Statue
		394110, -- [33] Escape from Reality
		389579, -- [34] Save Them All
		115313, -- [35] Summon Jade Serpent Statue
		328669, -- [36] Improved Roll
		392900, -- [37] Vigorous Expulsion
		388811, -- [38] Grace of the Crane
		115098, -- [39] Chi Wave
		123986, -- [40] Chi Burst
		392910, -- [41] Profound Rebuttal
		389574, -- [42] Close to Heart
		388674, -- [43] Ferocity of Xuen
		388809, -- [44] Fast Feet
		122278, -- [45] Dampen Harm
		394123, -- [46] Fatal Touch
		389578, -- [47] Resonant Fists
		388686, -- [48] Summon White Tiger Statue
		196607, -- [49] Eye of the Tiger
		157411, -- [50] Windwalking
		116844, -- [51] Ring of Peace
		122783, -- [52] Diffuse Magic
		328670, -- [53] Hasty Provocation
		388812, -- [54] Vivacious Vivification
		101643, -- [55] Transcendence
		388664, -- [56] Calming Presence
		231602, -- [57] Improved Vivify
		115175, -- [58] Soothing Mist
		107428, -- [59] Rising Sun Kick
		116841, -- [60] Tiger's Lust
		115078, -- [61] Paralysis
		344359, -- [62] Paralysis
		116705, -- [63] Spear Hand Strike
		115173, -- [64] Celerity
		115008, -- [65] Chi Torpedo
		322113, -- [66] Improved Touch of Death
		389575, -- [67] Generous Pour
		387276, -- [68] Strength of Spirit
		388814, -- [69] Ironshell Brew
		388813, -- [70] Expeditious Fortification
		388917, -- [71] Fortifying Brew
		116095, -- [72] Disable
		388193, -- [73] Faeline Stomp
		274586, -- [74] Invigorating Mists
		387991, -- [75] Tear of Morning
		274909, -- [76] Rising Mist
		116849, -- [77] Life Cocoon
		388020, -- [78] Resplendent Mist
		386276, -- [79] Bonedust Brew
		388701, -- [80] Dancing Mists
		115151, -- [81] Renewing Mist
		281231, -- [82] Mastery of Mist
		322118, -- [83] Invoke Yu'lon, the Jade Serpent
		325197, -- [84] Invoke Chi-Ji, the Red Crane
		388551, -- [85] Uplifted Spirits
		388593, -- [86] Peaceful Mending
		197895, -- [87] Focused Thunder
		274963, -- [88] Upwelling
		388682, -- [89] Misty Peaks
		116645, -- [90] Teachings of the Monastery
		386949, -- [91] Bountiful Brew
		386941, -- [92] Attenuation
		191837, -- [93] Essence Font
		388023, -- [94] Ancient Teachings
		388047, -- [95] Clouded Focus
		387765, -- [96] Nourishing Chi
		116680, -- [97] Thunder Focus Tea
		388681, -- [98] Elusive Mists
		264348, -- [99] Tiger Tail Sweep
	},
	-- Havoc Demon Hunter
	[577] = {
		388107, -- [0] Ragefire
		209281, -- [1] Quickened Sigils
		389697, -- [2] Extended Sigils
		320418, -- [3] Improved Sigil of Misery
		388110, -- [4] Misery in Defeat
		207684, -- [5] Sigil of Misery
		202137, -- [6] Sigil of Silence
		389695, -- [7] Will of the Illidari
		389781, -- [8] Long Night
		389783, -- [9] Pitch Black
		196718, -- [10] Darkness
		179057, -- [11] Chaos Nova
		393822, -- [12] Internal Struggle
		391397, -- [13] Erratic Felheart
		343206, -- [14] Improved Chaos Strike
		390152, -- [15] Collective Anguish
		388114, -- [16] Any Means Necessary
		388106, -- [17] Soulrend
		391275, -- [18] Accelerating Blade
		391429, -- [19] Fodder to the Flame
		390163, -- [20] Elysian Decree
		389693, -- [21] Inner Demon
		343311, -- [22] Furious Gaze
		390142, -- [23] Restless Hunter
		342817, -- [24] Glaive Tempest
		258925, -- [25] Fel Barrage
		389687, -- [26] Chaos Theory
		388113, -- [27] Isolated Prey
		388116, -- [28] Shattered Destiny
		258887, -- [29] Cycle of Hatred
		258860, -- [30] Essence Break
		388118, -- [31] Know Your Enemy
		206476, -- [32] Momentum
		389688, -- [33] Tactical Retreat
		258876, -- [34] Insatiable Hunger
		203555, -- [35] Demon Blades
		198013, -- [36] Eye Beam
		204596, -- [37] Sigil of Flame
		343017, -- [38] Improved Fel Rush
		320413, -- [39] Critical Chaos
		388108, -- [40] Initiative
		347461, -- [41] Unbound Chaos
		203550, -- [42] Blind Fury
		205411, -- [43] Desperate Instincts
		196555, -- [44] Netherwalk
		388112, -- [45] Chaotic Transformation
		320415, -- [46] Looks Can Kill
		390154, -- [47] Serrated Glaive
		389977, -- [48] Relentless Onslaught
		390158, -- [49] Growing Inferno
		389824, -- [50] Shattered Restoration
		391189, -- [51] Burning Wound
		388111, -- [52] Demon Muzzle
		391409, -- [53] Aldrachi Design
		320412, -- [54] Chaos Fragments
		206477, -- [55] Unleashed Power
		258881, -- [56] Trail of Ruin
		211881, -- [57] Fel Eruption
		393029, -- [58] Furious Throws
		388109, -- [59] Felfire Heart
		320374, -- [60] Burning Hatred
		206416, -- [61] First Blood
		328725, -- [62] Mortal Dance
		206478, -- [63] Demonic Appetite
		389811, -- [64] Unnatural Malice
		389819, -- [65] Relentless Pursuit
		370965, -- [66] The Hunt
		213410, -- [67] Demonic
		235893, -- [68] First of the Illidari
		320331, -- [69] Infernal Armor
		320421, -- [70] Rush of Chaos
		204909, -- [71] Soul Rending
		183782, -- [72] Disrupting Fury
		320361, -- [73] Improved Disrupt
		207347, -- [74] Aura of Pain
		232893, -- [75] Felblade
		278326, -- [76] Consume Magic
		320313, -- [77] Swallowed Anger
		213010, -- [78] Charred Warblades
		207666, -- [79] Concentrated Sigils
		389799, -- [80] Precise Sigils
		389849, -- [81] Lost in Darkness
		389694, -- [82] Flames of Fury
		320416, -- [83] Blazing Path
		217832, -- [84] Imprison
		320386, -- [85] Bouncing Glaives
		198793, -- [86] Vengeful Retreat
		320770, -- [87] Unrestrained Fury
		320654, -- [88] Pursuit
		389763, -- [89] Master of the Glaive
		389696, -- [90] Illidari Knowledge
		389846, -- [91] Felfire Haste
		320635, -- [92] Vengeful Bonds
		389978, -- [93] Dancing with Fate
	},
	-- Vengeance Demon Hunter
	[581] = {
		209281, -- [0] Quickened Sigils
		389697, -- [1] Extended Sigils
		320418, -- [2] Improved Sigil of Misery
		388110, -- [3] Misery in Defeat
		207684, -- [4] Sigil of Misery
		202137, -- [5] Sigil of Silence
		389695, -- [6] Will of the Illidari
		389781, -- [7] Long Night
		389783, -- [8] Pitch Black
		196718, -- [9] Darkness
		179057, -- [10] Chaos Nova
		393822, -- [11] Internal Struggle
		391397, -- [12] Erratic Felheart
		207739, -- [13] Burning Alive
		389718, -- [14] Cycle of Binding
		389715, -- [15] Chains of Anger
		343014, -- [16] Revel in Pain
		390213, -- [17] Burning Blood
		391178, -- [18] Roaring Fire
		321028, -- [19] Deflecting Spikes
		389958, -- [20] Frailty
		320387, -- [21] Perfectly Balanced Glaive
		389720, -- [22] Calcified Spikes
		212084, -- [23] Fel Devastation
		204021, -- [24] Fiery Brand
		247454, -- [25] Spirit Bomb
		390152, -- [26] Collective Anguish
		204596, -- [27] Sigil of Flame
		389824, -- [28] Shattered Restoration
		388111, -- [29] Demon Muzzle
		391409, -- [30] Aldrachi Design
		320412, -- [31] Chaos Fragments
		206477, -- [32] Unleashed Power
		389976, -- [33] Vulnerability
		207407, -- [34] Soul Carver
		218612, -- [35] Feed the Demon
		391429, -- [36] Fodder to the Flame
		390163, -- [37] Elysian Decree
		336639, -- [38] Charred Flesh
		389732, -- [39] Down in Flames
		209258, -- [40] Last Resort
		389708, -- [41] Darkglare Boon
		393827, -- [42] Stoke the Flames
		207387, -- [43] Painbringer
		343207, -- [44] Focused Cleave
		389811, -- [45] Unnatural Malice
		389819, -- [46] Relentless Pursuit
		370965, -- [47] The Hunt
		213410, -- [48] Demonic
		235893, -- [49] First of the Illidari
		320331, -- [50] Infernal Armor
		320421, -- [51] Rush of Chaos
		204909, -- [52] Soul Rending
		183782, -- [53] Disrupting Fury
		320361, -- [54] Improved Disrupt
		207347, -- [55] Aura of Pain
		232893, -- [56] Felblade
		278326, -- [57] Consume Magic
		320313, -- [58] Swallowed Anger
		213010, -- [59] Charred Warblades
		207666, -- [60] Concentrated Sigils
		389799, -- [61] Precise Sigils
		268175, -- [62] Void Reaver
		389997, -- [63] Shear Fury
		263642, -- [64] Fracture
		207548, -- [65] Agonizing Flames
		227174, -- [66] Fallout
		389721, -- [67] Extended Spikes
		390808, -- [68] Volatile Flameblood
		389220, -- [69] Fiery Demise
		389849, -- [70] Lost in Darkness
		389694, -- [71] Flames of Fury
		389724, -- [72] Meteoric Strikes
		389729, -- [73] Retaliation
		389705, -- [74] Fel Flame Fortification
		263648, -- [75] Soul Barrier
		320341, -- [76] Bulk Extraction
		202138, -- [77] Sigil of Chains
		326853, -- [78] Ruinous Bulwark
		207697, -- [79] Feast of Souls
		389711, -- [80] Soulmonger
		389985, -- [81] Soulcrush
		320416, -- [82] Blazing Path
		217832, -- [83] Imprison
		320386, -- [84] Bouncing Glaives
		198793, -- [85] Vengeful Retreat
		320770, -- [86] Unrestrained Fury
		320654, -- [87] Pursuit
		389763, -- [88] Master of the Glaive
		389696, -- [89] Illidari Knowledge
		389846, -- [90] Felfire Haste
		320635, -- [91] Vengeful Bonds
		391165, -- [92] Soul Furnace
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
		386348, -- [0] Onyx Legacy
		370821, -- [1] Scintillation
		370845, -- [2] Spellweaver's Dominance
		370455, -- [3] Charged Blast
		371038, -- [4] Honed Aggression
		375722, -- [5] Essence Attunement
		365585, -- [6] Expunge
		360995, -- [7] Verdant Embrace
		372469, -- [8] Scarlet Adaptation
		370553, -- [9] Tip the Scales
		376166, -- [10] Draconic Legacy
		371806, -- [11] Recall
		375520, -- [12] Innate Magic
		369913, -- [13] Natural Convergence
		358385, -- [14] Landslide
		387761, -- [15] Panacea
		375517, -- [16] Extended Flight
		375556, -- [17] Tailwind
		375554, -- [18] Enkindled
		370897, -- [19] Permeating Chill
		363916, -- [20] Obsidian Scales
		375406, -- [21] Obsidian Bulwark
		374251, -- [22] Cauterizing Flame
		376930, -- [23] Attuned to the Dream
		369990, -- [24] Ancient Flame
		369089, -- [25] Volatility
		365937, -- [26] Ruby Embers
		370837, -- [27] Engulfing Blaze
		371032, -- [28] Terror of the Skies
		374968, -- [29] Time Spiral
		387787, -- [30] Regenerative Magic
		375561, -- [31] Lush Growth
		374348, -- [32] Renewing Blaze
		375574, -- [33] Foci of Life
		375577, -- [34] Fire Within
		374227, -- [35] Zephyr
		370888, -- [36] Twin Guardian
		387341, -- [37] Walloping Blow
		370665, -- [38] Rescue
		365933, -- [39] Aerial Mastery
		374346, -- [40] Overawe
		369909, -- [41] Protracted Talons
		369939, -- [42] Leaping Flames
		368432, -- [43] Unravel
		375507, -- [44] Roar of Exhilaration
		351338, -- [45] Quell
		376164, -- [46] Instinctive Arcana
		375510, -- [47] Blast Furnace
		372048, -- [48] Oppressing Roar
		369459, -- [49] Source of Magic
		375544, -- [50] Tempered Scales
		370962, -- [51] Dense Energy
		375783, -- [52] Font of Magic
		375801, -- [53] Burnout
		370783, -- [54] Snapfire
		368847, -- [55] Firestorm
		386283, -- [56] Catalyze
		375725, -- [57] Heat Wave
		376888, -- [58] Tyranny
		386272, -- [59] Titanic Wrath
		375797, -- [60] Animosity
		375087, -- [61] Dragonrage
		371016, -- [62] Imposing Presence
		386405, -- [63] Inner Radiance
		375721, -- [64] Azure Essence Burst
		357211, -- [65] Pyre
		376872, -- [66] Ruby Essence Burst
		371034, -- [67] Lay Waste
		359073, -- [68] Eternity Surge
		375618, -- [69] Arcane Intensity
		375757, -- [70] Eternity's Span
		370839, -- [71] Power Swell
		386336, -- [72] Focusing Iris
		386342, -- [73] Arcane Vigor
		370452, -- [74] Shattering Star
		369375, -- [75] Eye of Infinity
		375777, -- [76] Causality
		370867, -- [77] Iridescence
		369846, -- [78] Feed the Flames
		370819, -- [79] Everburning Flame
		375796, -- [80] Hoarded Power
		369908, -- [81] Power Nexus
		375542, -- [82] Exuberance
		370886, -- [83] Bountiful Bloom
		360806, -- [84] Sleep Walk
		368838, -- [85] Heavy Wingbeats
		375443, -- [86] Clobbering Sweep
		375528, -- [87] Forger of Mountains
		370781, -- [88] Imminent Destruction
	},
	-- Preservation Evoker
	[1468] = {
		365585, -- [0] Expunge
		360995, -- [1] Verdant Embrace
		372469, -- [2] Scarlet Adaptation
		370553, -- [3] Tip the Scales
		376166, -- [4] Draconic Legacy
		371806, -- [5] Recall
		375520, -- [6] Innate Magic
		369913, -- [7] Natural Convergence
		358385, -- [8] Landslide
		387761, -- [9] Panacea
		375517, -- [10] Extended Flight
		375556, -- [11] Tailwind
		375554, -- [12] Enkindled
		370897, -- [13] Permeating Chill
		363916, -- [14] Obsidian Scales
		375406, -- [15] Obsidian Bulwark
		374251, -- [16] Cauterizing Flame
		376930, -- [17] Attuned to the Dream
		369990, -- [18] Ancient Flame
		371032, -- [19] Terror of the Skies
		374968, -- [20] Time Spiral
		387787, -- [21] Regenerative Magic
		375561, -- [22] Lush Growth
		374348, -- [23] Renewing Blaze
		375574, -- [24] Foci of Life
		375577, -- [25] Fire Within
		374227, -- [26] Zephyr
		370888, -- [27] Twin Guardian
		387341, -- [28] Walloping Blow
		370665, -- [29] Rescue
		365933, -- [30] Aerial Mastery
		374346, -- [31] Overawe
		369909, -- [32] Protracted Talons
		369939, -- [33] Leaping Flames
		368432, -- [34] Unravel
		375507, -- [35] Roar of Exhilaration
		351338, -- [36] Quell
		376164, -- [37] Instinctive Arcana
		375510, -- [38] Blast Furnace
		372048, -- [39] Oppressing Roar
		369459, -- [40] Source of Magic
		375544, -- [41] Tempered Scales
		377099, -- [42] Spark of Insight
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
		376210, -- [57] Erasure
		381922, -- [58] Temporal Artificer
		373834, -- [59] Call of Ysera
		376179, -- [60] Lifeforce Mender
		371426, -- [61] Life-Giver's Flame
		372527, -- [62] Time Lord
		378196, -- [63] Golden Hour
		357170, -- [64] Time Dilation
		363534, -- [65] Rewind
		373861, -- [66] Temporal Anomaly
		385696, -- [67] Flow State
		376236, -- [68] Resonating Sphere
		376237, -- [69] Nozdormu's Teachings
		371270, -- [70] Punctuality
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
		[1] = { 53, 644, 647, 5389, 828, 5489, 648, 5493, 5495, 646, }, -- Netherwind Armor, World in Flames, Flamecannon, Ring of Fire, Prismatic Cloak, Ice Wall, Greater Pyroblast, Precognition, Glass Cannon, Pyrokinesis
		[2] = { 53, 644, 647, 5389, 828, 5489, 648, 5493, 5495, 646, }, -- Netherwind Armor, World in Flames, Flamecannon, Ring of Fire, Prismatic Cloak, Ice Wall, Greater Pyroblast, Precognition, Glass Cannon, Pyrokinesis
		[3] = { 53, 644, 647, 5389, 828, 5489, 648, 5493, 5495, 646, }, -- Netherwind Armor, World in Flames, Flamecannon, Ring of Fire, Prismatic Cloak, Ice Wall, Greater Pyroblast, Precognition, Glass Cannon, Pyrokinesis
	},
	-- Frost Mage
	[64] = {
		[1] = { 66, 5490, 3443, 5390, 5496, 5497, 634, 632, 3532, 5494, }, -- Chilled to the Bone, Ring of Fire, Netherwind Armor, Ice Wall, Frost Bomb, Snowdrift, Ice Form, Concentrated Coolness, Prismatic Cloak, Precognition
		[2] = { 66, 5490, 3443, 5390, 5496, 5497, 634, 632, 3532, 5494, }, -- Chilled to the Bone, Ring of Fire, Netherwind Armor, Ice Wall, Frost Bomb, Snowdrift, Ice Form, Concentrated Coolness, Prismatic Cloak, Precognition
		[3] = { 66, 5490, 3443, 5390, 5496, 5497, 634, 632, 3532, 5494, }, -- Chilled to the Bone, Ring of Fire, Netherwind Armor, Ice Wall, Frost Bomb, Snowdrift, Ice Form, Concentrated Coolness, Prismatic Cloak, Precognition
	},
	-- Holy Paladin
	[65] = {
		[1] = { 642, 3618, 88, 859, 85, 82, 86, 87, 5421, 5553, 640, 5501, 5537, }, -- Cleanse the Weak, Hallowed Ground, Blessed Hands, Light's Grace, Ultimate Sacrifice, Avenging Light, Darkest before the Dawn, Spreading the Word, Judgments of the Pure, Aura of Reckoning, Divine Vision, Precognition, Vengeance Aura
		[2] = { 642, 3618, 88, 859, 85, 82, 86, 87, 5421, 5553, 640, 5501, 5537, }, -- Cleanse the Weak, Hallowed Ground, Blessed Hands, Light's Grace, Ultimate Sacrifice, Avenging Light, Darkest before the Dawn, Spreading the Word, Judgments of the Pure, Aura of Reckoning, Divine Vision, Precognition, Vengeance Aura
		[3] = { 642, 3618, 88, 859, 85, 82, 86, 87, 5421, 5553, 640, 5501, 5537, }, -- Cleanse the Weak, Hallowed Ground, Blessed Hands, Light's Grace, Ultimate Sacrifice, Avenging Light, Darkest before the Dawn, Spreading the Word, Judgments of the Pure, Aura of Reckoning, Divine Vision, Precognition, Vengeance Aura
	},
	-- Protection Paladin
	[66] = {
		[1] = { 5536, 5554, 861, 844, 3475, 90, 91, 92, 93, 94, 97, 860, 3474, }, -- Vengeance Aura, Aura of Reckoning, Shield of Virtue, Inquisition, Unbound Freedom, Hallowed Ground, Steed of Glory, Sacred Duty, Judgments of the Pure, Guardian of the Forgotten Queen, Guarded by the Light, Warrior of Light, Luminescence
		[2] = { 5536, 5554, 861, 844, 3475, 90, 91, 92, 93, 94, 97, 860, 3474, }, -- Vengeance Aura, Aura of Reckoning, Shield of Virtue, Inquisition, Unbound Freedom, Hallowed Ground, Steed of Glory, Sacred Duty, Judgments of the Pure, Guardian of the Forgotten Queen, Guarded by the Light, Warrior of Light, Luminescence
		[3] = { 5536, 5554, 861, 844, 3475, 90, 91, 92, 93, 94, 97, 860, 3474, }, -- Vengeance Aura, Aura of Reckoning, Shield of Virtue, Inquisition, Unbound Freedom, Hallowed Ground, Steed of Glory, Sacred Duty, Judgments of the Pure, Guardian of the Forgotten Queen, Guarded by the Light, Warrior of Light, Luminescence
	},
	-- Retribution Paladin
	[70] = {
		[1] = { 755, 757, 858, 81, 754, 753, 641, 751, 5422, 756, 5535, 752, }, -- Divine Punisher, Jurisdiction, Law and Order, Luminescence, Lawbringer, Ultimate Retribution, Unbound Freedom, Vengeance Aura, Judgments of the Pure, Aura of Reckoning, Hallowed Ground, Blessing of Sanctuary
		[2] = { 755, 757, 858, 81, 754, 753, 641, 751, 5422, 756, 5535, 752, }, -- Divine Punisher, Jurisdiction, Law and Order, Luminescence, Lawbringer, Ultimate Retribution, Unbound Freedom, Vengeance Aura, Judgments of the Pure, Aura of Reckoning, Hallowed Ground, Blessing of Sanctuary
		[3] = { 755, 757, 858, 81, 754, 753, 641, 751, 5422, 756, 5535, 752, }, -- Divine Punisher, Jurisdiction, Law and Order, Luminescence, Lawbringer, Ultimate Retribution, Unbound Freedom, Vengeance Aura, Judgments of the Pure, Aura of Reckoning, Hallowed Ground, Blessing of Sanctuary
	},
	-- Arms Warrior
	[71] = {
		[1] = { 34, 5547, 28, 29, 31, 32, 33, 3522, 5372, 5376, 3534, }, -- Duel, Rebound, Master and Commander, Shadow of the Colossus, Storm of Destruction, War Banner, Sharpen Blade, Death Sentence, Demolition, Warbringer, Disarm
		[2] = { 34, 5547, 28, 29, 31, 32, 33, 3522, 5372, 5376, 3534, }, -- Duel, Rebound, Master and Commander, Shadow of the Colossus, Storm of Destruction, War Banner, Sharpen Blade, Death Sentence, Demolition, Warbringer, Disarm
		[3] = { 34, 5547, 28, 29, 31, 32, 33, 3522, 5372, 5376, 3534, }, -- Duel, Rebound, Master and Commander, Shadow of the Colossus, Storm of Destruction, War Banner, Sharpen Blade, Death Sentence, Demolition, Warbringer, Disarm
	},
	-- Fury Warrior
	[72] = {
		[1] = { 25, 172, 5373, 177, 5431, 179, 166, 170, 3533, 3528, 3735, 5548, }, -- Death Sentence, Bloodrage, Demolition, Enduring Rage, Warbringer, Death Wish, Barbarian, Battle Trance, Disarm, Master and Commander, Slaughterhouse, Rebound
		[2] = { 25, 172, 5373, 177, 5431, 179, 166, 170, 3533, 3528, 3735, 5548, }, -- Death Sentence, Bloodrage, Demolition, Enduring Rage, Warbringer, Death Wish, Barbarian, Battle Trance, Disarm, Master and Commander, Slaughterhouse, Rebound
		[3] = { 25, 172, 5373, 177, 5431, 179, 166, 170, 3533, 3528, 3735, 5548, }, -- Death Sentence, Bloodrage, Demolition, Enduring Rage, Warbringer, Death Wish, Barbarian, Battle Trance, Disarm, Master and Commander, Slaughterhouse, Rebound
	},
	-- Protection Warrior
	[73] = {
		[1] = { 5374, 24, 168, 167, 833, 845, 831, 171, 173, 175, 178, 5432, }, -- Demolition, Disarm, Bodyguard, Sword and Board, Rebound, Oppressor, Dragon Charge, Morale Killer, Shield Bash, Thunderstruck, Warpath, Warbringer
		[2] = { 5374, 24, 168, 167, 833, 845, 831, 171, 173, 175, 178, 5432, }, -- Demolition, Disarm, Bodyguard, Sword and Board, Rebound, Oppressor, Dragon Charge, Morale Killer, Shield Bash, Thunderstruck, Warpath, Warbringer
		[3] = { 5374, 24, 168, 167, 833, 845, 831, 171, 173, 175, 178, 5432, }, -- Demolition, Disarm, Bodyguard, Sword and Board, Rebound, Oppressor, Dragon Charge, Morale Killer, Shield Bash, Thunderstruck, Warpath, Warbringer
	},
	-- Balance Druid
	[102] = {
		[1] = { 3728, 822, 3731, 5503, 5515, 185, 184, 182, 180, 836, 834, 5526, 5407, 3058, 5383, }, -- Protector of the Grove, Dying Stars, Thorns, Precognition, Malorne's Swiftness, Moonkin Aura, Moon and Stars, Crescent Burn, Celestial Guardian, Faerie Swarm, Deep Roots, Reactive Resin, Owlkin Adept, Star Burst, High Winds
		[2] = { 3728, 822, 3731, 5503, 5515, 185, 184, 182, 180, 836, 834, 5526, 5407, 3058, 5383, }, -- Protector of the Grove, Dying Stars, Thorns, Precognition, Malorne's Swiftness, Moonkin Aura, Moon and Stars, Crescent Burn, Celestial Guardian, Faerie Swarm, Deep Roots, Reactive Resin, Owlkin Adept, Star Burst, High Winds
		[3] = { 3728, 822, 3731, 5503, 5515, 185, 184, 182, 180, 836, 834, 5526, 5407, 3058, 5383, }, -- Protector of the Grove, Dying Stars, Thorns, Precognition, Malorne's Swiftness, Moonkin Aura, Moon and Stars, Crescent Burn, Celestial Guardian, Faerie Swarm, Deep Roots, Reactive Resin, Owlkin Adept, Star Burst, High Winds
	},
	-- Feral Druid
	[103] = {
		[1] = { 820, 3053, 5384, 3751, 611, 5525, 201, 203, 601, 602, 612, 620, }, -- Savage Momentum, Strength of the Wild, High Winds, Leader of the Pack, Ferocious Wound, Reactive Resin, Thorns, Freedom of the Herd, Malorne's Swiftness, King of the Jungle, Fresh Wound, Wicked Claws
		[2] = { 820, 3053, 5384, 3751, 611, 5525, 201, 203, 601, 602, 612, 620, }, -- Savage Momentum, Strength of the Wild, High Winds, Leader of the Pack, Ferocious Wound, Reactive Resin, Thorns, Freedom of the Herd, Malorne's Swiftness, King of the Jungle, Fresh Wound, Wicked Claws
		[3] = { 820, 3053, 5384, 3751, 611, 5525, 201, 203, 601, 602, 612, 620, }, -- Savage Momentum, Strength of the Wild, High Winds, Leader of the Pack, Ferocious Wound, Reactive Resin, Thorns, Freedom of the Herd, Malorne's Swiftness, King of the Jungle, Fresh Wound, Wicked Claws
	},
	-- Guardian Druid
	[104] = {
		[1] = { 3750, 5524, 842, 49, 50, 51, 192, 193, 194, 52, 1237, 5410, 195, 196, 197, }, -- Freedom of the Herd, Reactive Resin, Alpha Challenge, Master Shapeshifter, Toughness, Den Mother, Raging Frenzy, Sharpened Claws, Charging Bash, Demoralizing Roar, Malorne's Swiftness, Grove Protection, Entangling Claws, Overrun, Emerald Slumber
		[2] = { 3750, 5524, 842, 49, 50, 51, 192, 193, 194, 52, 1237, 5410, 195, 196, 197, }, -- Freedom of the Herd, Reactive Resin, Alpha Challenge, Master Shapeshifter, Toughness, Den Mother, Raging Frenzy, Sharpened Claws, Charging Bash, Demoralizing Roar, Malorne's Swiftness, Grove Protection, Entangling Claws, Overrun, Emerald Slumber
		[3] = { 3750, 5524, 842, 49, 50, 51, 192, 193, 194, 52, 1237, 5410, 195, 196, 197, }, -- Freedom of the Herd, Reactive Resin, Alpha Challenge, Master Shapeshifter, Toughness, Den Mother, Raging Frenzy, Sharpened Claws, Charging Bash, Demoralizing Roar, Malorne's Swiftness, Grove Protection, Entangling Claws, Overrun, Emerald Slumber
	},
	-- Restoration Druid
	[105] = {
		[1] = { 838, 5514, 835, 1215, 691, 692, 697, 700, 3048, 5504, 5387, 59, }, -- High Winds, Malorne's Swiftness, Focused Growth, Early Spring, Reactive Resin, Entangling Bark, Thorns, Deep Roots, Master Shapeshifter, Precognition, Keeper of the Grove, Disentanglement
		[2] = { 838, 5514, 835, 1215, 691, 692, 697, 700, 3048, 5504, 5387, 59, }, -- High Winds, Malorne's Swiftness, Focused Growth, Early Spring, Reactive Resin, Entangling Bark, Thorns, Deep Roots, Master Shapeshifter, Precognition, Keeper of the Grove, Disentanglement
		[3] = { 838, 5514, 835, 1215, 691, 692, 697, 700, 3048, 5504, 5387, 59, }, -- High Winds, Malorne's Swiftness, Focused Growth, Early Spring, Reactive Resin, Entangling Bark, Thorns, Deep Roots, Master Shapeshifter, Precognition, Keeper of the Grove, Disentanglement
	},
	-- Blood Death Knight
	[250] = {
		[1] = { 205, 204, 3441, 5513, 841, 5425, 3511, 609, 608, 607, 206, }, -- Walking Dead, Rot and Wither, Decomposing Aura, Necrotic Aura, Murderous Intent, Spellwarden, Dark Simulacrum, Death Chain, Last Dance, Blood for Blood, Strangulate
		[2] = { 205, 204, 3441, 5513, 841, 5425, 3511, 609, 608, 607, 206, }, -- Walking Dead, Rot and Wither, Decomposing Aura, Necrotic Aura, Murderous Intent, Spellwarden, Dark Simulacrum, Death Chain, Last Dance, Blood for Blood, Strangulate
		[3] = { 205, 204, 3441, 5513, 841, 5425, 3511, 609, 608, 607, 206, }, -- Walking Dead, Rot and Wither, Decomposing Aura, Necrotic Aura, Murderous Intent, Spellwarden, Dark Simulacrum, Death Chain, Last Dance, Blood for Blood, Strangulate
	},
	-- Frost Death Knight
	[251] = {
		[1] = { 5429, 5424, 3743, 5435, 702, 701, 3439, 5512, 3512, 5510, }, -- Strangulate, Spellwarden, Dead of Winter, Bitter Chill, Delirium, Deathchill, Shroud of Winter, Necrotic Aura, Dark Simulacrum, Rot and Wither
		[2] = { 5429, 5424, 3743, 5435, 702, 701, 3439, 5512, 3512, 5510, }, -- Strangulate, Spellwarden, Dead of Winter, Bitter Chill, Delirium, Deathchill, Shroud of Winter, Necrotic Aura, Dark Simulacrum, Rot and Wither
		[3] = { 5429, 5424, 3743, 5435, 702, 701, 3439, 5512, 3512, 5510, }, -- Strangulate, Spellwarden, Dead of Winter, Bitter Chill, Delirium, Deathchill, Shroud of Winter, Necrotic Aura, Dark Simulacrum, Rot and Wither
	},
	-- Unholy Death Knight
	[252] = {
		[1] = { 149, 3747, 5511, 5430, 3746, 5423, 152, 3437, 40, 41, 5436, }, -- Necrotic Wounds, Raise Abomination, Rot and Wither, Strangulate, Necromancer's Bargain, Spellwarden, Reanimation, Necrotic Aura, Life and Death, Dark Simulacrum, Doomburst
		[2] = { 149, 3747, 5511, 5430, 3746, 5423, 152, 3437, 40, 41, 5436, }, -- Necrotic Wounds, Raise Abomination, Rot and Wither, Strangulate, Necromancer's Bargain, Spellwarden, Reanimation, Necrotic Aura, Life and Death, Dark Simulacrum, Doomburst
		[3] = { 149, 3747, 5511, 5430, 3746, 5423, 152, 3437, 40, 41, 5436, }, -- Necrotic Wounds, Raise Abomination, Rot and Wither, Strangulate, Necromancer's Bargain, Spellwarden, Reanimation, Necrotic Aura, Life and Death, Dark Simulacrum, Doomburst
	},
	-- Beast Mastery Hunter
	[253] = {
		[1] = { 825, 3604, 3730, 5444, 693, 5418, 3600, 3599, 5534, 3612, 824, 5441, 1214, }, -- Dire Beast: Basilisk, Chimaeral Sting, Hunting Pack, Kindred Beasts, The Beast Within, Tranquilizing Darts, Dragonscale Armor, Survival Tactics, Diamond Ice, Roar of Sacrifice, Dire Beast: Hawk, Wild Kingdom, Interlope
		[2] = { 825, 3604, 3730, 5444, 693, 5418, 3600, 3599, 5534, 3612, 824, 5441, 1214, }, -- Dire Beast: Basilisk, Chimaeral Sting, Hunting Pack, Kindred Beasts, The Beast Within, Tranquilizing Darts, Dragonscale Armor, Survival Tactics, Diamond Ice, Roar of Sacrifice, Dire Beast: Hawk, Wild Kingdom, Interlope
		[3] = { 825, 3604, 3730, 5444, 693, 5418, 3600, 3599, 5534, 3612, 824, 5441, 1214, }, -- Dire Beast: Basilisk, Chimaeral Sting, Hunting Pack, Kindred Beasts, The Beast Within, Tranquilizing Darts, Dragonscale Armor, Survival Tactics, Diamond Ice, Roar of Sacrifice, Dire Beast: Hawk, Wild Kingdom, Interlope
	},
	-- Marksmanship Hunter
	[254] = {
		[1] = { 5419, 5531, 5533, 3729, 660, 659, 658, 653, 651, 649, 3614, 5442, 5440, }, -- Tranquilizing Darts, Interlope, Diamond Ice, Hunting Pack, Sniper Shot, Ranger's Finesse, Trueshot Mastery, Chimaeral Sting, Survival Tactics, Dragonscale Armor, Roar of Sacrifice, Wild Kingdom, Consecutive Concussion
		[2] = { 5419, 5531, 5533, 3729, 660, 659, 658, 653, 651, 649, 3614, 5442, 5440, }, -- Tranquilizing Darts, Interlope, Diamond Ice, Hunting Pack, Sniper Shot, Ranger's Finesse, Trueshot Mastery, Chimaeral Sting, Survival Tactics, Dragonscale Armor, Roar of Sacrifice, Wild Kingdom, Consecutive Concussion
		[3] = { 5419, 5531, 5533, 3729, 660, 659, 658, 653, 651, 649, 3614, 5442, 5440, }, -- Tranquilizing Darts, Interlope, Diamond Ice, Hunting Pack, Sniper Shot, Ranger's Finesse, Trueshot Mastery, Chimaeral Sting, Survival Tactics, Dragonscale Armor, Roar of Sacrifice, Wild Kingdom, Consecutive Concussion
	},
	-- Survival Hunter
	[255] = {
		[1] = { 664, 661, 3610, 3609, 5532, 663, 665, 5420, 5443, 3607, 686, 662, }, -- Sticky Tar, Hunting Pack, Dragonscale Armor, Chimaeral Sting, Interlope, Roar of Sacrifice, Tracker's Net, Tranquilizing Darts, Wild Kingdom, Survival Tactics, Diamond Ice, Mending Bandage
		[2] = { 664, 661, 3610, 3609, 5532, 663, 665, 5420, 5443, 3607, 686, 662, }, -- Sticky Tar, Hunting Pack, Dragonscale Armor, Chimaeral Sting, Interlope, Roar of Sacrifice, Tracker's Net, Tranquilizing Darts, Wild Kingdom, Survival Tactics, Diamond Ice, Mending Bandage
		[3] = { 664, 661, 3610, 3609, 5532, 663, 665, 5420, 5443, 3607, 686, 662, }, -- Sticky Tar, Hunting Pack, Dragonscale Armor, Chimaeral Sting, Interlope, Roar of Sacrifice, Tracker's Net, Tranquilizing Darts, Wild Kingdom, Survival Tactics, Diamond Ice, Mending Bandage
	},
	-- Discipline Priest
	[256] = {
		[1] = { 117, 114, 111, 109, 5487, 100, 98, 126, 5483, 1244, 5416, 5475, 855, 5498, 5480, 123, }, -- Dome of Light, Ultimate Radiance, Strength of Soul, Trinity, Catharsis, Purified Resolve, Purification, Dark Archangel, Eternal Rest, Blaze of Light, Inner Light and Shadow, Cardinal Mending, Thoughtsteal, Precognition, Delivered from Evil, Archangel
		[2] = { 117, 114, 111, 109, 5487, 100, 98, 126, 5483, 1244, 5416, 5475, 855, 5498, 5480, 123, }, -- Dome of Light, Ultimate Radiance, Strength of Soul, Trinity, Catharsis, Purified Resolve, Purification, Dark Archangel, Eternal Rest, Blaze of Light, Inner Light and Shadow, Cardinal Mending, Thoughtsteal, Precognition, Delivered from Evil, Archangel
		[3] = { 117, 114, 111, 109, 5487, 100, 98, 126, 5483, 1244, 5416, 5475, 855, 5498, 5480, 123, }, -- Dome of Light, Ultimate Radiance, Strength of Soul, Trinity, Catharsis, Purified Resolve, Purification, Dark Archangel, Eternal Rest, Blaze of Light, Inner Light and Shadow, Cardinal Mending, Thoughtsteal, Precognition, Delivered from Evil, Archangel
	},
	-- Holy Priest
	[257] = {
		[1] = { 112, 5366, 5476, 5365, 5479, 1927, 5482, 108, 5499, 127, 101, 124, 115, 5478, 5485, }, -- Greater Heal, Divine Ascension, Strength of Soul, Thoughtsteal, Purified Resolve, Delivered from Evil, Eternal Rest, Sanctified Ground, Precognition, Ray of Hope, Holy Ward, Spirit of the Redeemer, Cardinal Mending, Purification, Catharsis
		[2] = { 112, 5366, 5476, 5365, 5479, 1927, 5482, 108, 5499, 127, 101, 124, 115, 5478, 5485, }, -- Greater Heal, Divine Ascension, Strength of Soul, Thoughtsteal, Purified Resolve, Delivered from Evil, Eternal Rest, Sanctified Ground, Precognition, Ray of Hope, Holy Ward, Spirit of the Redeemer, Cardinal Mending, Purification, Catharsis
		[3] = { 112, 5366, 5476, 5365, 5479, 1927, 5482, 108, 5499, 127, 101, 124, 115, 5478, 5485, }, -- Greater Heal, Divine Ascension, Strength of Soul, Thoughtsteal, Purified Resolve, Delivered from Evil, Eternal Rest, Sanctified Ground, Precognition, Ray of Hope, Holy Ward, Spirit of the Redeemer, Cardinal Mending, Purification, Catharsis
	},
	-- Shadow Priest
	[258] = {
		[1] = { 5484, 5486, 5500, 5474, 5447, 5477, 763, 113, 5381, 106, 739, 5481, }, -- Eternal Rest, Catharsis, Precognition, Cardinal Mending, Void Volley, Strength of Soul, Psyfiend, Mind Trauma, Thoughtsteal, Driven to Madness, Void Origins, Delivered from Evil
		[2] = { 5484, 5486, 5500, 5474, 5447, 5477, 763, 113, 5381, 106, 739, 5481, }, -- Eternal Rest, Catharsis, Precognition, Cardinal Mending, Void Volley, Strength of Soul, Psyfiend, Mind Trauma, Thoughtsteal, Driven to Madness, Void Origins, Delivered from Evil
		[3] = { 5484, 5486, 5500, 5474, 5447, 5477, 763, 113, 5381, 106, 739, 5481, }, -- Eternal Rest, Catharsis, Precognition, Cardinal Mending, Void Volley, Strength of Soul, Psyfiend, Mind Trauma, Thoughtsteal, Driven to Madness, Void Origins, Delivered from Evil
	},
	-- Assassination Rogue
	[259] = {
		[1] = { 5550, 5405, 5517, 5408, 830, 3448, 141, 3479, 3480, 5530, 147, }, -- Dagger in the Dark, Dismantle, Veil of Midnight, Thick as Thieves, Hemotoxin, Maneuverability, Creeping Venom, Death from Above, Smoke Bomb, Control is King, System Shock
		[2] = { 5550, 5405, 5517, 5408, 830, 3448, 141, 3479, 3480, 5530, 147, }, -- Dagger in the Dark, Dismantle, Veil of Midnight, Thick as Thieves, Hemotoxin, Maneuverability, Creeping Venom, Death from Above, Smoke Bomb, Control is King, System Shock
		[3] = { 5550, 5405, 5517, 5408, 830, 3448, 141, 3479, 3480, 5530, 147, }, -- Dagger in the Dark, Dismantle, Veil of Midnight, Thick as Thieves, Hemotoxin, Maneuverability, Creeping Venom, Death from Above, Smoke Bomb, Control is King, System Shock
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
		[1] = { 5519, 5415, 5457, 3621, 730, 728, 727, 3491, 3490, 3488, 3062, 3620, }, -- Tidebringer, Seasoned Winds, Precognition, Swelling Waves, Traveling Storms, Control of Lava, Static Field Totem, Unleash Shield, Counterstrike Totem, Skyfury Totem, Spectral Recovery, Grounding Totem
		[2] = { 5519, 5415, 5457, 3621, 730, 728, 727, 3491, 3490, 3488, 3062, 3620, }, -- Tidebringer, Seasoned Winds, Precognition, Swelling Waves, Traveling Storms, Control of Lava, Static Field Totem, Unleash Shield, Counterstrike Totem, Skyfury Totem, Spectral Recovery, Grounding Totem
		[3] = { 5519, 5415, 5457, 3621, 730, 728, 727, 3491, 3490, 3488, 3062, 3620, }, -- Tidebringer, Seasoned Winds, Precognition, Swelling Waves, Traveling Storms, Control of Lava, Static Field Totem, Unleash Shield, Counterstrike Totem, Skyfury Totem, Spectral Recovery, Grounding Totem
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
		[1] = { 158, 156, 162, 5394, 5505, 5400, 3625, 3624, 3626, 5545, 1213, 3506, 165, 3505, }, -- Pleasure through Pain, Call Felhunter, Call Fel Lord, Shadow Rift, Precognition, Fel Obelisk, Essence Drain, Nether Ward, Casting Circle, Bonds of Fel, Master Summoner, Gateway Mastery, Call Observer, Bane of Fragility
		[2] = { 158, 156, 162, 5394, 5505, 5400, 3625, 3624, 3626, 5545, 1213, 3506, 165, 3505, }, -- Pleasure through Pain, Call Felhunter, Call Fel Lord, Shadow Rift, Precognition, Fel Obelisk, Essence Drain, Nether Ward, Casting Circle, Bonds of Fel, Master Summoner, Gateway Mastery, Call Observer, Bane of Fragility
		[3] = { 158, 156, 162, 5394, 5505, 5400, 3625, 3624, 3626, 5545, 1213, 3506, 165, 3505, }, -- Pleasure through Pain, Call Felhunter, Call Fel Lord, Shadow Rift, Precognition, Fel Obelisk, Essence Drain, Nether Ward, Casting Circle, Bonds of Fel, Master Summoner, Gateway Mastery, Call Observer, Bane of Fragility
	},
	-- Destruction Warlock
	[267] = {
		[1] = { 159, 157, 164, 3509, 5544, 5393, 5401, 3508, 5507, 3502, 3510, 5382, }, -- Cremation, Fel Fissure, Bane of Havoc, Essence Drain, Call Observer, Shadow Rift, Bonds of Fel, Nether Ward, Precognition, Bane of Fragility, Casting Circle, Gateway Mastery
		[2] = { 159, 157, 164, 3509, 5544, 5393, 5401, 3508, 5507, 3502, 3510, 5382, }, -- Cremation, Fel Fissure, Bane of Havoc, Essence Drain, Call Observer, Shadow Rift, Bonds of Fel, Nether Ward, Precognition, Bane of Fragility, Casting Circle, Gateway Mastery
		[3] = { 159, 157, 164, 3509, 5544, 5393, 5401, 3508, 5507, 3502, 3510, 5382, }, -- Cremation, Fel Fissure, Bane of Havoc, Essence Drain, Call Observer, Shadow Rift, Bonds of Fel, Nether Ward, Precognition, Bane of Fragility, Casting Circle, Gateway Mastery
	},
	-- Brewmaster Monk
	[268] = {
		[1] = { 765, 1958, 666, 667, 668, 669, 670, 671, 672, 673, 5542, 5541, 5538, 5417, 5552, 843, }, -- Eerie Fermentation, Niuzao's Essence, Microbrew, Hot Trub, Guided Meditation, Avert Harm, Nimble Brew, Incendiary Breath, Double Barrel, Mighty Ox Kick, Wind Waker, Dematerialize, Grapple Weapon, Rodeo, Alpha Tiger, Admonishment
		[2] = { 765, 1958, 666, 667, 668, 669, 670, 671, 672, 673, 5542, 5541, 5538, 5417, 5552, 843, }, -- Eerie Fermentation, Niuzao's Essence, Microbrew, Hot Trub, Guided Meditation, Avert Harm, Nimble Brew, Incendiary Breath, Double Barrel, Mighty Ox Kick, Wind Waker, Dematerialize, Grapple Weapon, Rodeo, Alpha Tiger, Admonishment
		[3] = { 765, 1958, 666, 667, 668, 669, 670, 671, 672, 673, 5542, 5541, 5538, 5417, 5552, 843, }, -- Eerie Fermentation, Niuzao's Essence, Microbrew, Hot Trub, Guided Meditation, Avert Harm, Nimble Brew, Incendiary Breath, Double Barrel, Mighty Ox Kick, Wind Waker, Dematerialize, Grapple Weapon, Rodeo, Alpha Tiger, Admonishment
	},
	-- Windwalker Monk
	[269] = {
		[1] = { 3052, 3744, 3737, 5448, 3050, 675, 3745, 852, 77, 5540, 3734, }, -- Grapple Weapon, Pressure Points, Wind Waker, Perpetual Paralysis, Disabling Reach, Tigereye Brew, Turbo Fists, Reverse Harm, Ride the Wind, Mighty Ox Kick, Alpha Tiger
		[2] = { 3052, 3744, 3737, 5448, 3050, 675, 3745, 852, 77, 5540, 3734, }, -- Grapple Weapon, Pressure Points, Wind Waker, Perpetual Paralysis, Disabling Reach, Tigereye Brew, Turbo Fists, Reverse Harm, Ride the Wind, Mighty Ox Kick, Alpha Tiger
		[3] = { 3052, 3744, 3737, 5448, 3050, 675, 3745, 852, 77, 5540, 3734, }, -- Grapple Weapon, Pressure Points, Wind Waker, Perpetual Paralysis, Disabling Reach, Tigereye Brew, Turbo Fists, Reverse Harm, Ride the Wind, Mighty Ox Kick, Alpha Tiger
	},
	-- Mistweaver Monk
	[270] = {
		[1] = { 5508, 3732, 70, 5539, 5551, 1928, 5402, 5398, 5395, 683, 682, 680, 679, 678, }, -- Precognition, Grapple Weapon, Eminence, Mighty Ox Kick, Alpha Tiger, Zen Focus Tea, Thunderous Focus Tea, Dematerialize, Peaceweaver, Healing Sphere, Refreshing Breeze, Dome of Mist, Counteract Magic, Chrysalis
		[2] = { 5508, 3732, 70, 5539, 5551, 1928, 5402, 5398, 5395, 683, 682, 680, 679, 678, }, -- Precognition, Grapple Weapon, Eminence, Mighty Ox Kick, Alpha Tiger, Zen Focus Tea, Thunderous Focus Tea, Dematerialize, Peaceweaver, Healing Sphere, Refreshing Breeze, Dome of Mist, Counteract Magic, Chrysalis
		[3] = { 5508, 3732, 70, 5539, 5551, 1928, 5402, 5398, 5395, 683, 682, 680, 679, 678, }, -- Precognition, Grapple Weapon, Eminence, Mighty Ox Kick, Alpha Tiger, Zen Focus Tea, Thunderous Focus Tea, Dematerialize, Peaceweaver, Healing Sphere, Refreshing Breeze, Dome of Mist, Counteract Magic, Chrysalis
	},
	-- Havoc Demon Hunter
	[577] = {
		[1] = { 1204, 1206, 811, 5523, 812, 813, 1218, 806, 809, 5433, 810, 805, }, -- Mortal Dance, Cover of Darkness, Rain from Above, Sigil Mastery, Detainment, Glimpse, Unending Hatred, Reverse Magic, Chaotic Imprint, Blood Moon, First of the Illidari, Cleansed by Flame
		[2] = { 1204, 1206, 811, 5523, 812, 813, 1218, 806, 809, 5433, 810, 805, }, -- Mortal Dance, Cover of Darkness, Rain from Above, Sigil Mastery, Detainment, Glimpse, Unending Hatred, Reverse Magic, Chaotic Imprint, Blood Moon, First of the Illidari, Cleansed by Flame
		[3] = { 1204, 1206, 811, 5523, 812, 813, 1218, 806, 809, 5433, 810, 805, }, -- Mortal Dance, Cover of Darkness, Rain from Above, Sigil Mastery, Detainment, Glimpse, Unending Hatred, Reverse Magic, Chaotic Imprint, Blood Moon, First of the Illidari, Cleansed by Flame
	},
	-- Vengeance Demon Hunter
	[581] = {
		[1] = { 814, 815, 5434, 819, 1220, 3727, 5439, 1948, 816, 3423, 3429, 5520, 5521, 5522, 3430, }, -- Cleansed by Flame, Everlasting Hunt, Blood Moon, Illidan's Grasp, Tormentor, Unending Hatred, Chaotic Imprint, Sigil Mastery, Jagged Spikes, Demonic Trample, Reverse Magic, Cover of Darkness, Rain from Above, Glimpse, Detainment
		[2] = { 814, 815, 5434, 819, 1220, 3727, 5439, 1948, 816, 3423, 3429, 5520, 5521, 5522, 3430, }, -- Cleansed by Flame, Everlasting Hunt, Blood Moon, Illidan's Grasp, Tormentor, Unending Hatred, Chaotic Imprint, Sigil Mastery, Jagged Spikes, Demonic Trample, Reverse Magic, Cover of Darkness, Rain from Above, Glimpse, Detainment
		[3] = { 814, 815, 5434, 819, 1220, 3727, 5439, 1948, 816, 3423, 3429, 5520, 5521, 5522, 3430, }, -- Cleansed by Flame, Everlasting Hunt, Blood Moon, Illidan's Grasp, Tormentor, Unending Hatred, Chaotic Imprint, Sigil Mastery, Jagged Spikes, Demonic Trample, Reverse Magic, Cover of Darkness, Rain from Above, Glimpse, Detainment
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
		[1] = { 5460, 5456, 5471, 5473, 5509, 5469, 5462, 5464, 5466, 5467, }, -- Obsidian Mettle, Chrono Loop, Crippling Force, Divide and Conquer, Precognition, Unburdened Flight, Scouring Flame, Time Stop, Swoop Up, Nullifying Shroud
		[2] = { 5460, 5456, 5471, 5473, 5509, 5469, 5462, 5464, 5466, 5467, }, -- Obsidian Mettle, Chrono Loop, Crippling Force, Divide and Conquer, Precognition, Unburdened Flight, Scouring Flame, Time Stop, Swoop Up, Nullifying Shroud
		[3] = { 5460, 5456, 5471, 5473, 5509, 5469, 5462, 5464, 5466, 5467, }, -- Obsidian Mettle, Chrono Loop, Crippling Force, Divide and Conquer, Precognition, Unburdened Flight, Scouring Flame, Time Stop, Swoop Up, Nullifying Shroud
	},
	-- Preservation Evoker
	[1468] = {
		[1] = { 5459, 5470, 5455, 5454, 5468, 5472, 5502, 5461, 5463, 5465, }, -- Obsidian Mettle, Unburdened Flight, Chrono Loop, Dream Projection, Nullifying Shroud, Divide and Conquer, Precognition, Scouring Flame, Time Stop, Swoop Up
		[2] = { 5459, 5470, 5455, 5454, 5468, 5472, 5502, 5461, 5463, 5465, }, -- Obsidian Mettle, Unburdened Flight, Chrono Loop, Dream Projection, Nullifying Shroud, Divide and Conquer, Precognition, Scouring Flame, Time Stop, Swoop Up
		[3] = { 5459, 5470, 5455, 5454, 5468, 5472, 5502, 5461, 5463, 5465, }, -- Obsidian Mettle, Unburdened Flight, Chrono Loop, Dream Projection, Nullifying Shroud, Divide and Conquer, Precognition, Scouring Flame, Time Stop, Swoop Up
	},
}

LibTalentInfo:RegisterTalentProvider({
	version = version,
	specializations = specializations,
	talents = talents,
	pvpTalentSlotCount = 3,
	pvpTalents = pvpTalents
})
