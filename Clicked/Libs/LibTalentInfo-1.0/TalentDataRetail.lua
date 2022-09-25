local LibTalentInfo = LibStub and LibStub("LibTalentInfo-1.0", true)
local version = 45746

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
		321752, -- [7] Improved Arcane Explosion
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
		30449, -- [21] Spellsteal
		382440, -- [22] Shifting Power
		205036, -- [23] Ice Ward
		386763, -- [24] Freezing Cold
		113724, -- [25] Ring of Frost
		389627, -- [26] Volatile Detonation
		153561, -- [27] Meteor
		31661, -- [28] Dragon's Breath
		389713, -- [29] Displacement
		382800, -- [30] Accumulative Shielding
		383243, -- [31] Time Anomaly
		386539, -- [32] Temporal Warp
		110959, -- [33] Greater Invisibility
		382268, -- [34] Flow of Time
		31589, -- [35] Slow
		382490, -- [36] Tome of Antonidas
		382826, -- [37] Temporal Velocity
		386828, -- [38] Energized Barriers
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
		114923, -- [77] Nether Tempest
		281482, -- [78] Reverberate
		231564, -- [79] Arcing Cleave
		205028, -- [80] Resonance
		235711, -- [81] Chrono Shift
		384861, -- [82] Foresight
		321387, -- [83] Enlightened
		383980, -- [84] Arcane Tempo
		205022, -- [85] Arcane Familiar
		264354, -- [86] Rule of Threes
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
		235313, -- [38] Blazing Barrier
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
		386828, -- [57] Energized Barriers
		382270, -- [58] Diverted Energy
		342249, -- [59] Master of Time
		157981, -- [60] Blast Wave
		382297, -- [61] Quick Witted
		212653, -- [62] Shimmer
		108839, -- [63] Ice Floes
		383121, -- [64] Mass Polymorph
		382292, -- [65] Cryo-Freeze
		343183, -- [66] Improved Frost Nova
		391102, -- [67] Mass Slow
		382481, -- [68] Rigid Ice
		382289, -- [69] Tempest Barrier
		382293, -- [70] Incantation of Swiftness
		1463, -- [71] Incanter's Flow
		116011, -- [72] Rune of Power
		383092, -- [73] Arcane Warding
		342245, -- [74] Alter Time
		475, -- [75] Remove Curse
		66, -- [76] Invisibility
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
		30449, -- [15] Spellsteal
		382440, -- [16] Shifting Power
		205036, -- [17] Ice Ward
		386763, -- [18] Freezing Cold
		113724, -- [19] Ring of Frost
		389627, -- [20] Volatile Detonation
		153561, -- [21] Meteor
		31661, -- [22] Dragon's Breath
		389713, -- [23] Displacement
		382800, -- [24] Accumulative Shielding
		383243, -- [25] Time Anomaly
		386539, -- [26] Temporal Warp
		110959, -- [27] Greater Invisibility
		382268, -- [28] Flow of Time
		31589, -- [29] Slow
		382490, -- [30] Tome of Antonidas
		382826, -- [31] Temporal Velocity
		386828, -- [32] Energized Barriers
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
		378406, -- [85] Wintertide
		205024, -- [86] Lonely Winter
		31687, -- [87] Summon Water Elemental
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
		384909, -- [19] Improved Blessing of Protection
		204018, -- [20] Blessing of Spellwarding
		1022, -- [21] Blessing of Protection
		114154, -- [22] Unbreakable Spirit
		6940, -- [23] Blessing of Sacrifice
		385414, -- [24] Afterimage
		384815, -- [25] Seal of Clarity
		384897, -- [26] Seal of Mercy
		377128, -- [27] Golden Path
		385515, -- [28] Holy Aegis
		183778, -- [29] Judgment of Light
		384820, -- [30] Sacrifice of the Just
		384914, -- [31] Recompense
		384376, -- [32] Avenging Wrath
		230332, -- [33] Cavalier
		96231, -- [34] Rebuke
		231663, -- [35] Greater Judgment
		234299, -- [36] Fist of Justice
		385639, -- [37] Auras of Swift Vengeance
		1044, -- [38] Blessing of Freedom
		385633, -- [39] Auras of the Resolute
		20066, -- [40] Repentance
		115750, -- [41] Blinding Light
		633, -- [42] Lay on Hands
		387893, -- [43] Divine Resonance
		325966, -- [44] Glimmer of Light
		196926, -- [45] Crusader's Might
		388007, -- [46] Blessing of Summer
		248033, -- [47] Awakening
		392907, -- [48] Inflorescence of the Sunwell
		387170, -- [49] Empyrean Legacy
		383388, -- [50] Relentless Inquisitor
		200474, -- [51] Power of the Silver Hand
		200652, -- [52] Tyr's Deliverance
		392951, -- [53] Boundless Salvation
		231642, -- [54] Tower of Radiance
		387805, -- [55] Divine Glimpse
		384442, -- [56] Avenging Wrath: Might
		394088, -- [57] Avenging Crusader
		200482, -- [58] Second Sunrise
		387879, -- [59] Breaking Dawn
		392938, -- [60] Veneration
		387781, -- [61] Commanding Light
		375576, -- [62] Divine Toll
		387808, -- [63] Divine Revelations
		114158, -- [64] Light's Hammer
		114165, -- [65] Holy Prism
		388005, -- [66] Shining Savior
		387791, -- [67] Empyreal Ward
		231667, -- [68] Radiant Onslaught
		392928, -- [69] Tirion's Devotion
		387993, -- [70] Illumination
		392914, -- [71] Divine Insight
		387786, -- [72] Moment of Compassion
		392902, -- [73] Resplendent Light
		210294, -- [74] Divine Favor
		393024, -- [75] Improved Cleanse
		377043, -- [76] Hallowed Ground
		24275, -- [77] Hammer of Wrath
		156910, -- [78] Beacon of Faith
		200025, -- [79] Beacon of Virtue
		20473, -- [80] Holy Shock
		387801, -- [81] Echoing Blessings
		392961, -- [82] Imbued Infusions
		148039, -- [83] Barrier of Faith
		388018, -- [84] Maraad's Dying Breath
		387814, -- [85] Untempered Dedication
		183998, -- [86] Light of the Martyr
		214202, -- [87] Rule of Law
		157047, -- [88] Saved by the Light
		387998, -- [89] Unending Light
		223306, -- [90] Bestow Faith
		85222, -- [91] Light of Dawn
		392911, -- [92] Unwavering Spirit
		200430, -- [93] Protection of Tyr
		31821, -- [94] Aura Mastery
		498, -- [95] Divine Protection
		82326, -- [96] Holy Light
	},
	-- Protection Paladin
	[66] = {
		393022, -- [0] Inspiring Vanguard
		204023, -- [1] Crusader's Judgment
		378845, -- [2] Focused Enmity
		378457, -- [3] Soaring Shield
		190784, -- [4] Divine Steed
		376996, -- [5] Seasoned Warhorse
		377016, -- [6] Seal of the Templar
		10326, -- [7] Turn Evil
		377053, -- [8] Seal of Reprisal
		385464, -- [9] Incandescence
		385349, -- [10] Touch of Light
		385427, -- [11] Obduracy
		385728, -- [12] Seal of the Crusader
		391142, -- [13] Zealot's Paragon
		385125, -- [14] Of Dusk and Dawn
		385129, -- [15] Seal of Order
		385416, -- [16] Aspiration of Divinity
		385450, -- [17] Seal of Might
		152262, -- [18] Seraphim
		53376, -- [19] Sanctified Wrath
		385425, -- [20] Seal of Alacrity
		223817, -- [21] Divine Purpose
		105809, -- [22] Holy Avenger
		384909, -- [23] Improved Blessing of Protection
		204018, -- [24] Blessing of Spellwarding
		1022, -- [25] Blessing of Protection
		114154, -- [26] Unbreakable Spirit
		6940, -- [27] Blessing of Sacrifice
		385414, -- [28] Afterimage
		384815, -- [29] Seal of Clarity
		384897, -- [30] Seal of Mercy
		377128, -- [31] Golden Path
		385515, -- [32] Holy Aegis
		183778, -- [33] Judgment of Light
		384820, -- [34] Sacrifice of the Just
		384914, -- [35] Recompense
		384376, -- [36] Avenging Wrath
		230332, -- [37] Cavalier
		96231, -- [38] Rebuke
		231663, -- [39] Greater Judgment
		234299, -- [40] Fist of Justice
		385639, -- [41] Auras of Swift Vengeance
		1044, -- [42] Blessing of Freedom
		385633, -- [43] Auras of the Resolute
		20066, -- [44] Repentance
		115750, -- [45] Blinding Light
		633, -- [46] Lay on Hands
		204074, -- [47] Righteous Protector
		393114, -- [48] Improved Ardent Defender
		386738, -- [49] Divine Resonance
		379391, -- [50] Quickened Invocations
		379043, -- [51] Faith in the Light
		31850, -- [52] Ardent Defender
		378762, -- [53] Ferren Marcus's Fervor
		384442, -- [54] Avenging Wrath: Might
		385438, -- [55] Sentinel
		378279, -- [56] Gift of the Golden Val'kyr
		379008, -- [57] Strength of Conviction
		393030, -- [58] Improved Holy Shield
		379021, -- [59] Sanctuary
		85043, -- [60] Grand Crusader
		378974, -- [61] Bastion of Light
		152261, -- [62] Holy Shield
		86659, -- [63] Guardian of Ancient Kings
		386653, -- [64] Bulwark of Righteous Fury
		378285, -- [65] Tyr's Enforcer
		315924, -- [66] Hand of the Protector
		204054, -- [67] Consecrated Ground
		393027, -- [68] Improved Lay on Hands
		379017, -- [69] Faith's Armor
		375576, -- [70] Divine Toll
		387174, -- [71] Eye of Tyr
		321136, -- [72] Shining Light
		209389, -- [73] Bulwark of Order
		378425, -- [74] Uther's Counsel
		385726, -- [75] Barricade of Faith
		31935, -- [76] Avenger's Shield
		378405, -- [77] Light of the Titans
		204077, -- [78] Final Stand
		327193, -- [79] Moment of Glory
		383388, -- [80] Relentless Inquisitor
		213644, -- [81] Cleanse Toxins
		377043, -- [82] Hallowed Ground
		24275, -- [83] Hammer of Wrath
		53595, -- [84] Hammer of the Righteous
		204019, -- [85] Blessed Hammer
		379022, -- [86] Consecration in Flame
		385422, -- [87] Resolute Defender
		386568, -- [88] Inner Light
		280373, -- [89] Redoubt
		393071, -- [90] Strength in Adversity
		380188, -- [91] Crusader's Resolve
	},
	-- Retribution Paladin
	[70] = {
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
		384909, -- [19] Improved Blessing of Protection
		204018, -- [20] Blessing of Spellwarding
		1022, -- [21] Blessing of Protection
		114154, -- [22] Unbreakable Spirit
		6940, -- [23] Blessing of Sacrifice
		385414, -- [24] Afterimage
		384815, -- [25] Seal of Clarity
		384897, -- [26] Seal of Mercy
		377128, -- [27] Golden Path
		385515, -- [28] Holy Aegis
		183778, -- [29] Judgment of Light
		384820, -- [30] Sacrifice of the Just
		384914, -- [31] Recompense
		384376, -- [32] Avenging Wrath
		230332, -- [33] Cavalier
		96231, -- [34] Rebuke
		231663, -- [35] Greater Judgment
		234299, -- [36] Fist of Justice
		385639, -- [37] Auras of Swift Vengeance
		1044, -- [38] Blessing of Freedom
		385633, -- [39] Auras of the Resolute
		20066, -- [40] Repentance
		115750, -- [41] Blinding Light
		633, -- [42] Lay on Hands
		213644, -- [43] Cleanse Toxins
		377043, -- [44] Hallowed Ground
		24275, -- [45] Hammer of Wrath
		387170, -- [46] Empyrean Legacy
		383396, -- [47] Tempest of the Lightbringer
		383263, -- [48] Blade of Condemnation
		383314, -- [49] Vanguard's Momentum
		383327, -- [50] Final Verdict
		383274, -- [51] Templar's Vindication
		215661, -- [52] Justicar's Vengeance
		205191, -- [53] Eye for an Eye
		387640, -- [54] Sealed Verdict
		383344, -- [55] Expurgation
		386901, -- [56] Seal of Wrath
		231832, -- [57] Blade of Wrath
		383350, -- [58] Truth's Wake
		383300, -- [59] Ashes to Dust
		384052, -- [60] Radiant Decree
		255937, -- [61] Wake of Ashes
		384442, -- [62] Avenging Wrath: Might
		384392, -- [63] Crusade
		184575, -- [64] Blade of Justice
		386967, -- [65] Holy Crusader
		383254, -- [66] Improved Crusader Strike
		53385, -- [67] Divine Storm
		383228, -- [68] Improved Judgment
		267610, -- [69] Righteous Verdict
		269569, -- [70] Zeal
		383271, -- [71] Highlord's Judgment
		383876, -- [72] Boundless Judgment
		204054, -- [73] Consecrated Ground
		387479, -- [74] Sanctified Ground
		384162, -- [75] Executioner's Will
		387196, -- [76] Executioner's Wrath
		343527, -- [77] Execution Sentence
		384027, -- [78] Divine Resonance
		375576, -- [79] Divine Toll
		383388, -- [80] Relentless Inquisitor
		183218, -- [81] Hand of Hindrance
		383185, -- [82] Exorcism
		382430, -- [83] Sanctification
		383334, -- [84] Inner Grace
		382536, -- [85] Sanctify
		184662, -- [86] Shield of Vengeance
		498, -- [87] Divine Protection
		383342, -- [88] Holy Blade
		267344, -- [89] Art of War
		343721, -- [90] Final Reckoning
		383304, -- [91] Virtuous Command
		383276, -- [92] Ashes to Ashes
		85804, -- [93] Selfless Healer
		326734, -- [94] Healing Hands
		326732, -- [95] Empyrean Power
		203316, -- [96] Fires of Justice
		382275, -- [97] Consecrated Blade
	},
	-- Arms Warrior
	[71] = {
		384277, -- [0] Blood and Thunder
		203201, -- [1] Crackling Thunder
		6343, -- [2] Thunder Clap
		382258, -- [3] Siphoning Strikes
		6544, -- [4] Heroic Leap
		382764, -- [5] Crushing Force
		384100, -- [6] Berserker Shout
		12323, -- [7] Piercing Howl
		384110, -- [8] Wrecking Throw
		64382, -- [9] Shattering Throw
		392777, -- [10] Cruel Strikes
		103827, -- [11] Double Time
		382954, -- [12] Cacophonous Roar
		275338, -- [13] Menace
		5246, -- [14] Intimidating Shout
		23920, -- [15] Spell Reflection
		392792, -- [16] Frothing Berserker
		384318, -- [17] Thunderous Roar
		382946, -- [18] Quick Thinking
		390138, -- [19] Memory of a Tormented Blademaster
		390140, -- [20] Memory of a Tormented Warlord
		107574, -- [21] Avatar
		384124, -- [22] Armored to the Teeth
		382939, -- [23] Reinforced Plates
		382260, -- [24] Fast Footwork
		18499, -- [25] Berserker Rage
		275339, -- [26] Rumbling Earth
		46968, -- [27] Shockwave
		384404, -- [28] Sidearm
		382767, -- [29] Overwhelming Rage
		382948, -- [30] Piercing Verdict
		376079, -- [31] Spear of Bastion
		384969, -- [32] Thunderous Words
		391572, -- [33] Uproar
		383762, -- [34] Bitter Immunity
		202163, -- [35] Bounding Stride
		392383, -- [36] Wrenching Impact
		382461, -- [37] Honed Reflexes
		382549, -- [38] Pain and Gain
		389308, -- [39] Deft Experience
		383154, -- [40] Bloodletting
		383703, -- [41] Fatality
		386628, -- [42] Unhinged
		390563, -- [43] Hurricane
		227847, -- [44] Bladestorm
		383338, -- [45] Valor in Victory
		385573, -- [46] Improved Mortal Strike
		389306, -- [47] Critical Thinking
		386634, -- [48] Exploiter
		383292, -- [49] Juggernaut
		383341, -- [50] Sharpened Blades
		382956, -- [51] Seismic Reverberation
		384090, -- [52] Titanic Throw
		382940, -- [53] Endurance Training
		107570, -- [54] Storm Bolt
		390354, -- [55] Furious Blows
		383082, -- [56] Barbaric Training
		383115, -- [57] Concussive Blows
		382310, -- [58] Inspiring Presence
		29838, -- [59] Second Wind
		97462, -- [60] Rallying Cry
		386208, -- [61] Defensive Stance
		3411, -- [62] Intervene
		262231, -- [63] War Machine
		386164, -- [64] Battle Stance
		202168, -- [65] Impending Victory
		386285, -- [66] Elysian Might
		382896, -- [67] Two-Handed Weapon Specialization
		390725, -- [68] Sonic Boom
		383293, -- [69] Reaping Swings
		845, -- [70] Cleave
		383430, -- [71] Impale
		281001, -- [72] Massacre
		167105, -- [73] Colossus Smash
		152278, -- [74] Anger Management
		248621, -- [75] In For The Kill
		385008, -- [76] Test of Might
		383442, -- [77] Blunt Instruments
		262161, -- [78] Warbreaker
		383219, -- [79] Exhilarating Blows
		262150, -- [80] Dreadnaught
		772, -- [81] Rend
		383287, -- [82] Bloodborne
		184783, -- [83] Tactician
		260643, -- [84] Skullsplitter
		386357, -- [85] Fracture
		385571, -- [86] Improved Overpower
		316440, -- [87] Martial Prowess
		384361, -- [88] Bloodsurge
		118038, -- [89] Die by the Sword
		383103, -- [90] Fueled by Violence
		29725, -- [91] Sudden Death
		316405, -- [92] Improved Execute
		202316, -- [93] Fervor of Battle
		7384, -- [94] Overpower
		12294, -- [95] Mortal Strike
		388807, -- [96] Storm Wall
		260708, -- [97] Sweeping Strikes
		385512, -- [98] Storm of Swords
		334779, -- [99] Collateral Damage
		383317, -- [100] Merciless Bonegrinder
		390713, -- [101] Dance of Death
		386630, -- [102] Battlelord
	},
	-- Fury Warrior
	[72] = {
		384277, -- [0] Blood and Thunder
		203201, -- [1] Crackling Thunder
		6343, -- [2] Thunder Clap
		382258, -- [3] Siphoning Strikes
		6544, -- [4] Heroic Leap
		384100, -- [5] Berserker Shout
		12323, -- [6] Piercing Howl
		382764, -- [7] Crushing Force
		215571, -- [8] Frothing Berserker
		384110, -- [9] Wrecking Throw
		64382, -- [10] Shattering Throw
		316402, -- [11] Improved Execute
		280721, -- [12] Sudden Death
		392777, -- [13] Cruel Strikes
		103827, -- [14] Double Time
		382954, -- [15] Cacophonous Roar
		275338, -- [16] Menace
		5246, -- [17] Intimidating Shout
		23920, -- [18] Spell Reflection
		346002, -- [19] War Machine
		392936, -- [20] Wrath and Fury
		228920, -- [21] Ravager
		382953, -- [22] Storm of Steel
		390563, -- [23] Hurricane
		383854, -- [24] Improved Raging Blow
		280392, -- [25] Meat Cleaver
		23881, -- [26] Bloodthirst
		383468, -- [27] Invigorating Fury
		208154, -- [28] Warpaint
		184364, -- [29] Enraged Regeneration
		85288, -- [30] Raging Blow
		383852, -- [31] Improved Bloodthirst
		383848, -- [32] Improved Enrage
		215568, -- [33] Fresh Meat
		81099, -- [34] Single-Minded Fury
		385703, -- [35] Bloodborne
		383959, -- [36] Cold Steel, Hot Blood
		383486, -- [37] Focus in Chaos
		383885, -- [38] Vicious Contempt
		393950, -- [39] Bloodcraze
		335077, -- [40] Frenzy
		383877, -- [41] Hack and Slash
		184367, -- [42] Rampage
		392536, -- [43] Ashen Juggernaut
		206315, -- [44] Massacre
		388004, -- [45] Slaughtering Strikes
		383922, -- [46] Depths of Insanity
		389603, -- [47] Unbridled Ferocity
		152278, -- [48] Anger Management
		202751, -- [49] Reckless Abandon
		383459, -- [50] Swift Strikes
		391683, -- [51] Dancing Blades
		390376, -- [52] Placeholder Talent
		385059, -- [53] Odyn's Fury
		383916, -- [54] Annihilator
		388903, -- [55] Storm of Swords
		383295, -- [56] Deft Experience
		383605, -- [57] Frenzied Flurry
		388933, -- [58] Pulverize
		315720, -- [59] Onslaught
		383297, -- [60] Critical Thinking
		388049, -- [61] Raging Armaments
		12950, -- [62] Improved Whirlwind
		392931, -- [63] Cruelty
		384318, -- [64] Thunderous Roar
		382946, -- [65] Quick Thinking
		390123, -- [66] Memory of a Tormented Berserker
		390135, -- [67] Memory of a Tormented Titan
		107574, -- [68] Avatar
		384124, -- [69] Armored to the Teeth
		391270, -- [70] Honed Reflexes
		382939, -- [71] Reinforced Plates
		382260, -- [72] Fast Footwork
		18499, -- [73] Berserker Rage
		382900, -- [74] Dual Wield Specialization
		275339, -- [75] Rumbling Earth
		46968, -- [76] Shockwave
		391997, -- [77] Endurance Training
		384404, -- [78] Sidearm
		382767, -- [79] Overwhelming Rage
		382948, -- [80] Piercing Verdict
		376079, -- [81] Spear of Bastion
		384969, -- [82] Thunderous Words
		391572, -- [83] Uproar
		383762, -- [84] Bitter Immunity
		202163, -- [85] Bounding Stride
		392383, -- [86] Wrenching Impact
		382549, -- [87] Pain and Gain
		1719, -- [88] Recklessness
		382956, -- [89] Seismic Reverberation
		384090, -- [90] Titanic Throw
		107570, -- [91] Storm Bolt
		390354, -- [92] Furious Blows
		390674, -- [93] Barbaric Training
		383115, -- [94] Concussive Blows
		382310, -- [95] Inspiring Presence
		29838, -- [96] Second Wind
		97462, -- [97] Rallying Cry
		386208, -- [98] Defensive Stance
		3411, -- [99] Intervene
		202168, -- [100] Impending Victory
		386196, -- [101] `
		386285, -- [102] Elysian Might
		390725, -- [103] Sonic Boom
	},
	-- Protection Warrior
	[73] = {
		202095, -- [0] Indomitable
		228920, -- [1] Ravager
		385888, -- [2] Spiked Shield
		392966, -- [3] Spell Block
		384277, -- [4] Blood and Thunder
		203201, -- [5] Crackling Thunder
		6343, -- [6] Thunder Clap
		382258, -- [7] Siphoning Strikes
		316733, -- [8] War Machine
		6544, -- [9] Heroic Leap
		384100, -- [10] Berserker Shout
		12323, -- [11] Piercing Howl
		384110, -- [12] Wrecking Throw
		64382, -- [13] Shattering Throw
		382953, -- [14] Storm of Steel
		392777, -- [15] Cruel Strikes
		103827, -- [16] Double Time
		382954, -- [17] Cacophonous Roar
		275338, -- [18] Menace
		5246, -- [19] Intimidating Shout
		23920, -- [20] Spell Reflection
		384042, -- [21] Unnerving Focus
		384063, -- [22] Enduring Alacrity
		382940, -- [23] Endurance Training
		384318, -- [24] Thunderous Roar
		382946, -- [25] Quick Thinking
		391271, -- [26] Honed Reflexes
		394307, -- [27] Immovable Object
		275336, -- [28] Unstoppable Force
		107574, -- [29] Avatar
		384124, -- [30] Armored to the Teeth
		382939, -- [31] Reinforced Plates
		390642, -- [32] Crushing Force
		392790, -- [33] Frothing Berserker
		382260, -- [34] Fast Footwork
		18499, -- [35] Berserker Rage
		275339, -- [36] Rumbling Earth
		46968, -- [37] Shockwave
		384404, -- [38] Sidearm
		382767, -- [39] Overwhelming Rage
		382948, -- [40] Piercing Verdict
		376079, -- [41] Spear of Bastion
		384969, -- [42] Thunderous Words
		391572, -- [43] Uproar
		383762, -- [44] Bitter Immunity
		202163, -- [45] Bounding Stride
		392383, -- [46] Wrenching Impact
		382549, -- [47] Pain and Gain
		383103, -- [48] Fueled by Violence
		384036, -- [49] Brutal Vitality
		385704, -- [50] Bloodborne
		275334, -- [51] Punish
		393967, -- [52] Juggernaut
		382956, -- [53] Seismic Reverberation
		384090, -- [54] Titanic Throw
		107570, -- [55] Storm Bolt
		390354, -- [56] Furious Blows
		390675, -- [57] Barbaric Training
		383115, -- [58] Concussive Blows
		382310, -- [59] Inspiring Presence
		29838, -- [60] Second Wind
		97462, -- [61] Rallying Cry
		386208, -- [62] Defensive Stance
		3411, -- [63] Intervene
		202168, -- [64] Impending Victory
		382895, -- [65] One-Handed Weapon Specialization
		386285, -- [66] Elysian Might
		390725, -- [67] Sonic Boom
		385843, -- [68] Show of Force
		29725, -- [69] Sudden Death
		203177, -- [70] Heavy Repercussions
		202603, -- [71] Into the Fray
		384067, -- [72] Focused Vigor
		385952, -- [73] Shield Charge
		386328, -- [74] Champion's Bulwark
		386011, -- [75] Shield Specialization
		202743, -- [76] Booming Voice
		386027, -- [77] Enduring Defenses
		281001, -- [78] Massacre
		871, -- [79] Shield Wall
		152278, -- [80] Anger Management
		384074, -- [81] Unbreakable Will
		384072, -- [82] The Wall
		1161, -- [83] Challenging Shout
		385840, -- [84] Thunderlord
		386071, -- [85] Disrupting Shout
		386034, -- [86] Improved Heroic Throw
		1160, -- [87] Demoralizing Shout
		202560, -- [88] Best Served Cold
		384041, -- [89] Strategist
		394062, -- [90] Rend
		394311, -- [91] Instigate
		384361, -- [92] Bloodsurge
		236279, -- [93] Devastator
		6572, -- [94] Revenge
		12975, -- [95] Last Stand
		386030, -- [96] Brace For Impact
		190456, -- [97] Ignore Pain
		386477, -- [98] Outburst
		280001, -- [99] Bolster
		394312, -- [100] Battering Ram
		386164, -- [101] Battle Stance
		393965, -- [102] Dance of Death
		386394, -- [103] Battle-Scarred Veteran
	},
	-- Balance Druid
	[102] = {
		378986, -- [0] Furor
		124974, -- [1] Nature's Vigil
		29166, -- [2] Innervate
		102359, -- [3] Mass Entanglement
		102793, -- [4] Ursol's Vortex
		48438, -- [5] Wild Growth
		231040, -- [6] Improved Rejuvenation
		131768, -- [7] Feline Swiftness
		159286, -- [8] Primal Fury
		99, -- [9] Incapacitating Roar
		5211, -- [10] Mighty Bash
		385786, -- [11] Matted Fur
		377842, -- [12] Ursine Vigor
		106898, -- [13] Stampeding Roar
		378988, -- [14] Lycara's Teachings
		108238, -- [15] Renewal
		319454, -- [16] Heart of the Wild
		288826, -- [17] Improved Stampeding Roar
		2908, -- [18] Soothe
		16931, -- [19] Thick Hide
		192081, -- [20] Ironfur
		213764, -- [21] Swipe
		108299, -- [22] Killer Instinct
		106839, -- [23] Skull Bash
		106832, -- [24] Thrash
		1079, -- [25] Rip
		22570, -- [26] Maim
		22842, -- [27] Frenzied Regeneration
		327993, -- [28] Improved Barkskin
		301768, -- [29] Verdant Heart
		774, -- [30] Rejuvenation
		18562, -- [31] Swiftmend
		33873, -- [32] Nurturing Instinct
		33786, -- [33] Cyclone
		24858, -- [34] Moonkin Form
		2637, -- [35] Hibernate
		197524, -- [36] Astral Influence
		132469, -- [37] Typhoon
		93402, -- [38] Sunfire
		377796, -- [39] Natural Recovery
		2782, -- [40] Remove Corruption
		78674, -- [41] Starsurge
		194153, -- [42] Starfire
		1822, -- [43] Rake
		102401, -- [44] Wild Charge
		252216, -- [45] Tiger Dash
		377801, -- [46] Tireless Pursuit
		279620, -- [47] Twin Moons
		202347, -- [48] Stellar Flare
		338657, -- [49] Circle of Life and Death
		325727, -- [50] Adaptive Swarm
		339942, -- [51] Balance of All Things
		338661, -- [52] Oneth's Clear Vision
		339949, -- [53] Timeworn Dreambinder
		202737, -- [54] Blessing of Elune
		202739, -- [55] Blessing of An'she
		383196, -- [56] Umbral Infusion [NNF]
		202770, -- [57] Fury of Elune
		274281, -- [58] New Moon
		383197, -- [59] Orbit Breaker
		390378, -- [60] Syzygy
		338668, -- [61] Primordial Arcanic Pulsar
		343647, -- [62] Solstice
		340706, -- [63] Precise Alignment
		202345, -- [64] Starlord
		383195, -- [65] Umbral Intensity
		384656, -- [66] Fury of the Skies
		102560, -- [67] Incarnation: Chosen of Elune
		323764, -- [68] Convoke the Spirits
		202918, -- [69] Light of the Sun
		202996, -- [70] Power of Goldrinn
		383194, -- [71] Stellar Inspiration
		114107, -- [72] Soul of the Forest
		327541, -- [73] Aetherial Kindling
		202354, -- [74] Stellar Drift
		328022, -- [75] Improved Starsurge
		191034, -- [76] Starfall
		78675, -- [77] Solar Beam
		194223, -- [78] Celestial Alignment
		202342, -- [79] Shooting Stars
		202430, -- [80] Nature's Balance
		231042, -- [81] Owlkin Frenzy
		328021, -- [82] Improved Eclipse
		205636, -- [83] Force of Nature
		79577, -- [84] Eclipse
		328023, -- [85] Improved Moonfire
		202425, -- [86] Warrior of Elune
		231050, -- [87] Improved Sunfire
		377847, -- [88] Well-Honed Instincts
	},
	-- Feral Druid
	[103] = {
		378986, -- [0] Furor
		124974, -- [1] Nature's Vigil
		29166, -- [2] Innervate
		102359, -- [3] Mass Entanglement
		102793, -- [4] Ursol's Vortex
		48438, -- [5] Wild Growth
		231040, -- [6] Improved Rejuvenation
		131768, -- [7] Feline Swiftness
		159286, -- [8] Primal Fury
		99, -- [9] Incapacitating Roar
		5211, -- [10] Mighty Bash
		385786, -- [11] Matted Fur
		377842, -- [12] Ursine Vigor
		106898, -- [13] Stampeding Roar
		378988, -- [14] Lycara's Teachings
		108238, -- [15] Renewal
		319454, -- [16] Heart of the Wild
		288826, -- [17] Improved Stampeding Roar
		2908, -- [18] Soothe
		16931, -- [19] Thick Hide
		192081, -- [20] Ironfur
		213764, -- [21] Swipe
		108299, -- [22] Killer Instinct
		106839, -- [23] Skull Bash
		106832, -- [24] Thrash
		1079, -- [25] Rip
		22570, -- [26] Maim
		22842, -- [27] Frenzied Regeneration
		327993, -- [28] Improved Barkskin
		301768, -- [29] Verdant Heart
		774, -- [30] Rejuvenation
		18562, -- [31] Swiftmend
		33873, -- [32] Nurturing Instinct
		33786, -- [33] Cyclone
		24858, -- [34] Moonkin Form
		2637, -- [35] Hibernate
		197524, -- [36] Astral Influence
		132469, -- [37] Typhoon
		93402, -- [38] Sunfire
		377796, -- [39] Natural Recovery
		2782, -- [40] Remove Corruption
		194153, -- [41] Starfire
		197626, -- [42] Starsurge
		1822, -- [43] Rake
		102401, -- [44] Wild Charge
		252216, -- [45] Tiger Dash
		377801, -- [46] Tireless Pursuit
		231050, -- [47] Improved Sunfire
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
		372567, -- [0] Twin Moonfire
		238049, -- [1] Scintillating Moonlight
		203964, -- [2] Galactic Guardian
		279552, -- [3] Layered Mane
		343240, -- [4] Berserk: Ravage
		300346, -- [5] Ursine Adept
		377210, -- [6] Ursoc's Fury
		372119, -- [7] Dream of Cenarius
		204053, -- [8] Rend and Tear
		372943, -- [9] Untamed Savagery
		80313, -- [10] Pulverize
		372945, -- [11] Reinvigoration
		377623, -- [12] Berserk: Unchecked Aggression
		203974, -- [13] Earthwarden
		393427, -- [14] Flashing Claws
		371999, -- [15] Vicious Cycle
		135288, -- [16] Tooth and Claw
		377811, -- [17] Innate Resolve
		378986, -- [18] Furor
		124974, -- [19] Nature's Vigil
		29166, -- [20] Innervate
		102359, -- [21] Mass Entanglement
		102793, -- [22] Ursol's Vortex
		48438, -- [23] Wild Growth
		231040, -- [24] Improved Rejuvenation
		131768, -- [25] Feline Swiftness
		159286, -- [26] Primal Fury
		99, -- [27] Incapacitating Roar
		5211, -- [28] Mighty Bash
		385786, -- [29] Matted Fur
		377842, -- [30] Ursine Vigor
		106898, -- [31] Stampeding Roar
		378988, -- [32] Lycara's Teachings
		108238, -- [33] Renewal
		319454, -- [34] Heart of the Wild
		288826, -- [35] Improved Stampeding Roar
		2908, -- [36] Soothe
		16931, -- [37] Thick Hide
		192081, -- [38] Ironfur
		213764, -- [39] Swipe
		108299, -- [40] Killer Instinct
		106839, -- [41] Skull Bash
		106832, -- [42] Thrash
		1079, -- [43] Rip
		22570, -- [44] Maim
		22842, -- [45] Frenzied Regeneration
		327993, -- [46] Improved Barkskin
		301768, -- [47] Verdant Heart
		774, -- [48] Rejuvenation
		18562, -- [49] Swiftmend
		2782, -- [50] Remove Corruption
		33873, -- [51] Nurturing Instinct
		33786, -- [52] Cyclone
		24858, -- [53] Moonkin Form
		2637, -- [54] Hibernate
		197524, -- [55] Astral Influence
		132469, -- [56] Typhoon
		93402, -- [57] Sunfire
		155835, -- [58] Bristling Fur
		203953, -- [59] Brambles
		377796, -- [60] Natural Recovery
		194153, -- [61] Starfire
		197626, -- [62] Starsurge
		1822, -- [63] Rake
		102401, -- [64] Wild Charge
		252216, -- [65] Tiger Dash
		377801, -- [66] Tireless Pursuit
		345208, -- [67] Infected Wounds
		231050, -- [68] Improved Sunfire
		377847, -- [69] Well-Honed Instincts
		203965, -- [70] Survival of the Fittest
		203962, -- [71] Blood Frenzy
		158477, -- [72] Soul of the Forest
		200851, -- [73] Rage of the Sleeper
		371905, -- [74] After the Wildfire
		155578, -- [75] Guardian of Elune
		393618, -- [76] Reinforced Fur
		370695, -- [77] Fury of Nature
		391969, -- [78] Circle of Life and Death
		102558, -- [79] Incarnation: Guardian of Ursoc
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
		377779, -- [92] Berserk: Persistence
	},
	-- Restoration Druid
	[105] = {
		378986, -- [0] Furor
		124974, -- [1] Nature's Vigil
		29166, -- [2] Innervate
		102359, -- [3] Mass Entanglement
		102793, -- [4] Ursol's Vortex
		48438, -- [5] Wild Growth
		231040, -- [6] Improved Rejuvenation
		131768, -- [7] Feline Swiftness
		159286, -- [8] Primal Fury
		99, -- [9] Incapacitating Roar
		5211, -- [10] Mighty Bash
		385786, -- [11] Matted Fur
		377842, -- [12] Ursine Vigor
		106898, -- [13] Stampeding Roar
		378988, -- [14] Lycara's Teachings
		108238, -- [15] Renewal
		319454, -- [16] Heart of the Wild
		288826, -- [17] Improved Stampeding Roar
		2908, -- [18] Soothe
		16931, -- [19] Thick Hide
		192081, -- [20] Ironfur
		213764, -- [21] Swipe
		108299, -- [22] Killer Instinct
		106839, -- [23] Skull Bash
		106832, -- [24] Thrash
		1079, -- [25] Rip
		22570, -- [26] Maim
		22842, -- [27] Frenzied Regeneration
		327993, -- [28] Improved Barkskin
		301768, -- [29] Verdant Heart
		774, -- [30] Rejuvenation
		18562, -- [31] Swiftmend
		33873, -- [32] Nurturing Instinct
		33786, -- [33] Cyclone
		24858, -- [34] Moonkin Form
		2637, -- [35] Hibernate
		197524, -- [36] Astral Influence
		132469, -- [37] Typhoon
		93402, -- [38] Sunfire
		377796, -- [39] Natural Recovery
		392378, -- [40] Improved Nature's Cure
		194153, -- [41] Starfire
		197626, -- [42] Starsurge
		1822, -- [43] Rake
		102401, -- [44] Wild Charge
		252216, -- [45] Tiger Dash
		377801, -- [46] Tireless Pursuit
		231050, -- [47] Improved Sunfire
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
		391477, -- [33] Coagulopathy
		391386, -- [34] Blood Feast
		391517, -- [35] Umbilicus Eternus
		391458, -- [36] Sanguine Ground
		374715, -- [37] Improved Bone Shield
		273953, -- [38] Voracious
		207167, -- [39] Blinding Sleet
		378848, -- [40] Coldthirst
		205727, -- [41] Anti-Magic Barrier
		373926, -- [42] Acclimation
		374383, -- [43] Assimilation
		383269, -- [44] Abomination Limb
		47568, -- [45] Empower Rune Weapon
		194878, -- [46] Icy Talons
		391571, -- [47] Gloom Ward
		343294, -- [48] Soul Reaper
		206967, -- [49] Will of the Necropolis
		374261, -- [50] Unholy Bond
		356367, -- [51] Death's Echo
		276079, -- [52] Death's Reach
		273952, -- [53] Grip of the Dead
		374265, -- [54] Unholy Ground
		111673, -- [55] Control Undead
		392566, -- [56] Enfeeble
		374504, -- [57] Brittle
		389679, -- [58] Clenching Grasp
		389682, -- [59] Unholy Endurance
		221562, -- [60] Asphyxiate
		51052, -- [61] Anti-Magic Zone
		374030, -- [62] Blood Scent
		374277, -- [63] Improved Death Strike
		48263, -- [64] Veteran of the Third War
		391546, -- [65] March of Darkness
		48707, -- [66] Anti-Magic Shell
		49998, -- [67] Death Strike
		46585, -- [68] Raise Dead
		316916, -- [69] Cleaving Strikes
		327574, -- [70] Sacrificial Pact
		374049, -- [71] Suppression
		374111, -- [72] Might of Thassarian
		48743, -- [73] Death Pact
		212552, -- [74] Wraith Walk
		374598, -- [75] Blood Draw
		374574, -- [76] Rune Mastery
		45524, -- [77] Chains of Ice
		47528, -- [78] Mind Freeze
		207200, -- [79] Permafrost
		48792, -- [80] Icebound Fortitude
		373923, -- [81] Merciless Strikes
		373930, -- [82] Proliferating Chill
		207104, -- [83] Runic Attenuation
		391566, -- [84] Insidious Chill
		374747, -- [85] Perseverance of the Ebon Blade
		374717, -- [86] Improved Heart Strike
		391398, -- [87] Bloodshot
	},
	-- Frost Death Knight
	[251] = {
		392950, -- [0] Icebreaker
		207126, -- [1] Icecap
		281208, -- [2] Cold Heart
		377056, -- [3] Biting Cold
		253593, -- [4] Inexorable Assault
		207167, -- [5] Blinding Sleet
		378848, -- [6] Coldthirst
		205727, -- [7] Anti-Magic Barrier
		373926, -- [8] Acclimation
		374383, -- [9] Assimilation
		383269, -- [10] Abomination Limb
		47568, -- [11] Empower Rune Weapon
		194878, -- [12] Icy Talons
		391571, -- [13] Gloom Ward
		343294, -- [14] Soul Reaper
		206967, -- [15] Will of the Necropolis
		374261, -- [16] Unholy Bond
		356367, -- [17] Death's Echo
		276079, -- [18] Death's Reach
		273952, -- [19] Grip of the Dead
		374265, -- [20] Unholy Ground
		111673, -- [21] Control Undead
		392566, -- [22] Enfeeble
		374504, -- [23] Brittle
		389679, -- [24] Clenching Grasp
		389682, -- [25] Unholy Endurance
		221562, -- [26] Asphyxiate
		51052, -- [27] Anti-Magic Zone
		374030, -- [28] Blood Scent
		374277, -- [29] Improved Death Strike
		48263, -- [30] Veteran of the Third War
		391546, -- [31] March of Darkness
		48707, -- [32] Anti-Magic Shell
		49998, -- [33] Death Strike
		46585, -- [34] Raise Dead
		316916, -- [35] Cleaving Strikes
		327574, -- [36] Sacrificial Pact
		374049, -- [37] Suppression
		374111, -- [38] Might of Thassarian
		48743, -- [39] Death Pact
		212552, -- [40] Wraith Walk
		374598, -- [41] Blood Draw
		374574, -- [42] Rune Mastery
		45524, -- [43] Chains of Ice
		47528, -- [44] Mind Freeze
		207200, -- [45] Permafrost
		48792, -- [46] Icebound Fortitude
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
		277234, -- [9] Pestilence
		377537, -- [10] Death Rot
		390279, -- [11] Vile Contagion
		194917, -- [12] Pestilent Pustules
		207317, -- [13] Epidemic
		115989, -- [14] Unholy Blight
		377585, -- [15] Replenishing Wounds
		207264, -- [16] Bursting Sores
		207269, -- [17] Ebon Fever
		276023, -- [18] Harbinger of Doom
		49206, -- [19] Summon Gargoyle
		377514, -- [20] Reaping
		390275, -- [21] Rotten Touch
		49530, -- [22] Sudden Doom
		319230, -- [23] Unholy Pact
		152280, -- [24] Defile
		194916, -- [25] All Will Serve
		207272, -- [26] Infected Claws
		207311, -- [27] Clawing Shadows
		390175, -- [28] Plaguebringer
		377580, -- [29] Improved Death Coil
		275699, -- [30] Apocalypse
		390166, -- [31] Runic Mastery
		63560, -- [32] Dark Transformation
		46584, -- [33] Raise Dead
		85948, -- [34] Festering Strike
		55090, -- [35] Scourge Strike
		77575, -- [36] Outbreak
		316867, -- [37] Improved Festering Strike
		390161, -- [38] Feasting Strikes
		316941, -- [39] Unholy Command
		390268, -- [40] Eternal Agony
		42650, -- [41] Army of the Dead
		377592, -- [42] Morbidity
		390270, -- [43] Coil of Devastation
		207167, -- [44] Blinding Sleet
		378848, -- [45] Coldthirst
		205727, -- [46] Anti-Magic Barrier
		373926, -- [47] Acclimation
		374383, -- [48] Assimilation
		383269, -- [49] Abomination Limb
		47568, -- [50] Empower Rune Weapon
		194878, -- [51] Icy Talons
		391571, -- [52] Gloom Ward
		343294, -- [53] Soul Reaper
		206967, -- [54] Will of the Necropolis
		374261, -- [55] Unholy Bond
		356367, -- [56] Death's Echo
		276079, -- [57] Death's Reach
		273952, -- [58] Grip of the Dead
		374265, -- [59] Unholy Ground
		111673, -- [60] Control Undead
		392566, -- [61] Enfeeble
		374504, -- [62] Brittle
		389679, -- [63] Clenching Grasp
		389682, -- [64] Unholy Endurance
		221562, -- [65] Asphyxiate
		51052, -- [66] Anti-Magic Zone
		374030, -- [67] Blood Scent
		374277, -- [68] Improved Death Strike
		48263, -- [69] Veteran of the Third War
		391546, -- [70] March of Darkness
		48707, -- [71] Anti-Magic Shell
		49998, -- [72] Death Strike
		46585, -- [73] Raise Dead
		316916, -- [74] Cleaving Strikes
		327574, -- [75] Sacrificial Pact
		374049, -- [76] Suppression
		374111, -- [77] Might of Thassarian
		48743, -- [78] Death Pact
		212552, -- [79] Wraith Walk
		374598, -- [80] Blood Draw
		374574, -- [81] Rune Mastery
		45524, -- [82] Chains of Ice
		47528, -- [83] Mind Freeze
		207200, -- [84] Permafrost
		48792, -- [85] Icebound Fortitude
		373923, -- [86] Merciless Strikes
		373930, -- [87] Proliferating Chill
		207104, -- [88] Runic Attenuation
		391566, -- [89] Insidious Chill
	},
	-- Beast Mastery Hunter
	[253] = {
		270581, -- [0] Natural Mending
		34477, -- [1] Misdirection
		343247, -- [2] Improved Traps
		378004, -- [3] Keen Eyesight
		109215, -- [4] Posthaste
		321468, -- [5] Binding Shackles
		343244, -- [6] Improved Tranquilizing Shot
		378002, -- [7] Pathfinding
		2643, -- [8] Multi-Shot
		201430, -- [9] Stampede
		375891, -- [10] Death Chakram
		212431, -- [11] Explosive Shot
		120360, -- [12] Barrage
		321014, -- [13] Pack Tactics
		120679, -- [14] Dire Beast
		199528, -- [15] One with the Pack
		199532, -- [16] Killer Cobra
		392053, -- [17] Piercing Fangs
		389654, -- [18] Master Handler
		389660, -- [19] Snake Bite
		378244, -- [20] Cobra Senses
		257944, -- [21] Thrill of the Hunt
		193532, -- [22] Scent of Blood
		185789, -- [23] Wild Call
		359844, -- [24] Call of the Wild
		217200, -- [25] Barbed Shot
		260309, -- [26] Master Marksman
		393344, -- [27] Entrapment
		273887, -- [28] Killer Instinct
		269737, -- [29] Alpha Predator
		271788, -- [30] Serpent Sting
		5116, -- [31] Concussive Shot
		19801, -- [32] Tranquilizing Shot
		162488, -- [33] Steel Trap
		385539, -- [34] Rejuvenating Wind
		19577, -- [35] Intimidation
		236776, -- [36] High Explosive Trap
		378014, -- [37] Poison Injection
		260241, -- [38] Hydra's Bite
		147362, -- [39] Counter Shot
		343248, -- [40] Improved Kill Shot
		199921, -- [41] Trailblazer
		378010, -- [42] Improved Kill Command
		266921, -- [43] Born To Be Wild
		199483, -- [44] Camouflage
		34026, -- [45] Kill Command
		343242, -- [46] Wilderness Medicine
		213691, -- [47] Scatter Shot
		109248, -- [48] Binding Shot
		392060, -- [49] Wailing Arrow
		378740, -- [50] Killer Command
		378745, -- [51] Dire Pack
		378750, -- [52] Cobra Sting
		199530, -- [53] Stomp
		131894, -- [54] A Murder of Crows
		321530, -- [55] Bloodshed
		191384, -- [56] Aspect of the Beast
		378205, -- [57] Sharp Barbs
		378442, -- [58] Wild Instincts
		378739, -- [59] Bloody Frenzy
		267116, -- [60] Animal Companion
		378209, -- [61] Training Expert
		193455, -- [62] Cobra Shot
		193530, -- [63] Aspect of the Wild
		378210, -- [64] Hunter's Prey
		393933, -- [65] War Orders
		378743, -- [66] Dire Command
		378207, -- [67] Kill Cleave
		19574, -- [68] Bestial Wrath
		115939, -- [69] Beast Cleave
		56315, -- [70] Kindred Spirits
		389882, -- [71] Serrated Shots
		390231, -- [72] Arctic Bola
		386870, -- [73] Brutal Companion
		388056, -- [74] Sentinel's Perception
		388057, -- [75] Sentinel's Protection
		388045, -- [76] Sentinel Owl
		388039, -- [77] Lone Survivor
		388042, -- [78] Nature's Endurance
		264735, -- [79] Survival of the Fittest
		385810, -- [80] Dire Frenzy
		378007, -- [81] Beast Master
		1513, -- [82] Scare Beast
		187698, -- [83] Tar Trap
		231548, -- [84] Barbed Wrath
		384799, -- [85] Hunter's Avoidance
		53351, -- [86] Kill Shot
	},
	-- Marksmanship Hunter
	[254] = {
		270581, -- [0] Natural Mending
		34477, -- [1] Misdirection
		343247, -- [2] Improved Traps
		378004, -- [3] Keen Eyesight
		109215, -- [4] Posthaste
		321468, -- [5] Binding Shackles
		343244, -- [6] Improved Tranquilizing Shot
		378002, -- [7] Pathfinding
		201430, -- [8] Stampede
		375891, -- [9] Death Chakram
		342049, -- [10] Chimaera Shot
		212431, -- [11] Explosive Shot
		120360, -- [12] Barrage
		260309, -- [13] Master Marksman
		393344, -- [14] Entrapment
		378910, -- [15] Heavy Ammo
		378913, -- [16] Light Ammo
		273887, -- [17] Killer Instinct
		269737, -- [18] Alpha Predator
		271788, -- [19] Serpent Sting
		5116, -- [20] Concussive Shot
		19801, -- [21] Tranquilizing Shot
		162488, -- [22] Steel Trap
		385539, -- [23] Rejuvenating Wind
		19577, -- [24] Intimidation
		236776, -- [25] High Explosive Trap
		378014, -- [26] Poison Injection
		260241, -- [27] Hydra's Bite
		343248, -- [28] Improved Kill Shot
		199921, -- [29] Trailblazer
		378010, -- [30] Improved Kill Command
		266921, -- [31] Born To Be Wild
		199483, -- [32] Camouflage
		343242, -- [33] Wilderness Medicine
		213691, -- [34] Scatter Shot
		109248, -- [35] Binding Shot
		389866, -- [36] Windrunner's Barrage
		389865, -- [37] Readiness
		389882, -- [38] Serrated Shots
		390231, -- [39] Arctic Bola
		389019, -- [40] Bulletstorm
		388056, -- [41] Sentinel's Perception
		388057, -- [42] Sentinel's Protection
		388045, -- [43] Sentinel Owl
		388039, -- [44] Lone Survivor
		388042, -- [45] Nature's Endurance
		264735, -- [46] Survival of the Fittest
		378007, -- [47] Beast Master
		1513, -- [48] Scare Beast
		187698, -- [49] Tar Trap
		34026, -- [50] Kill Command
		257620, -- [51] Multi-Shot
		384791, -- [52] Salvo
		384790, -- [53] Razor Fragments
		384799, -- [54] Hunter's Avoidance
		53351, -- [55] Kill Shot
		147362, -- [56] Counter Shot
		260404, -- [57] Calling the Shots
		386878, -- [58] Unerring Vision
		389449, -- [59] Eagletalon's True Focus
		378765, -- [60] Killer Accuracy
		190852, -- [61] Legacy of the Windrunners
		321018, -- [62] Improved Steady Shot
		260393, -- [63] Lethal Shots
		391559, -- [64] Surging Shots
		378767, -- [65] Focused Aim
		321293, -- [66] Crack Shot
		378905, -- [67] Windrunner's Guidance
		260367, -- [68] Streamline
		321460, -- [69] Deadeye
		193533, -- [70] Steady Focus
		260243, -- [71] Volley
		378880, -- [72] Bombardment
		378766, -- [73] Hunter's Knowledge
		378907, -- [74] Sharpshooter
		321287, -- [75] Target Practice
		392060, -- [76] Wailing Arrow
		194595, -- [77] Lock and Load
		378769, -- [78] Deathblow
		288613, -- [79] Trueshot
		378888, -- [80] Serpentstalker's Trickery
		257044, -- [81] Rapid Fire
		260228, -- [82] Careful Aim
		378771, -- [83] Quick Load
		260240, -- [84] Precise Shots
		204089, -- [85] Bullseye
		257621, -- [86] Trick Shots
		260402, -- [87] Double Tap
		19434, -- [88] Aimed Shot
		186387, -- [89] Bursting Shot
		155228, -- [90] Lone Wolf
	},
	-- Survival Hunter
	[255] = {
		385739, -- [0] Coordinated Kill
		270581, -- [1] Natural Mending
		34477, -- [2] Misdirection
		343247, -- [3] Improved Traps
		378004, -- [4] Keen Eyesight
		109215, -- [5] Posthaste
		321468, -- [6] Binding Shackles
		343244, -- [7] Improved Tranquilizing Shot
		378002, -- [8] Pathfinding
		201430, -- [9] Stampede
		375891, -- [10] Death Chakram
		212431, -- [11] Explosive Shot
		120360, -- [12] Barrage
		260309, -- [13] Master Marksman
		393344, -- [14] Entrapment
		273887, -- [15] Killer Instinct
		269737, -- [16] Alpha Predator
		271788, -- [17] Serpent Sting
		5116, -- [18] Concussive Shot
		19801, -- [19] Tranquilizing Shot
		162488, -- [20] Steel Trap
		385539, -- [21] Rejuvenating Wind
		19577, -- [22] Intimidation
		236776, -- [23] High Explosive Trap
		378014, -- [24] Poison Injection
		260241, -- [25] Hydra's Bite
		343248, -- [26] Improved Kill Shot
		199921, -- [27] Trailblazer
		378010, -- [28] Improved Kill Command
		266921, -- [29] Born To Be Wild
		199483, -- [30] Camouflage
		343242, -- [31] Wilderness Medicine
		213691, -- [32] Scatter Shot
		109248, -- [33] Binding Shot
		389882, -- [34] Serrated Shots
		390231, -- [35] Arctic Bola
		388056, -- [36] Sentinel's Perception
		388057, -- [37] Sentinel's Protection
		388045, -- [38] Sentinel Owl
		388039, -- [39] Lone Survivor
		388042, -- [40] Nature's Endurance
		264735, -- [41] Survival of the Fittest
		378007, -- [42] Beast Master
		1513, -- [43] Scare Beast
		187698, -- [44] Tar Trap
		259489, -- [45] Kill Command
		269751, -- [46] Flanking Strike
		190925, -- [47] Harpoon
		268501, -- [48] Viper's Venom
		385709, -- [49] Intense Focus
		385737, -- [50] Bloody Claws
		385718, -- [51] Ruthless Marauder
		384799, -- [52] Hunter's Avoidance
		320976, -- [53] Kill Shot
		187707, -- [54] Muzzle
		271014, -- [55] Wildfire Infusion
		378962, -- [56] Deadly Duo
		378940, -- [57] Quick Shot
		264332, -- [58] Guerrilla Tactics
		360966, -- [59] Spearhead
		360952, -- [60] Coordinated Assault
		260331, -- [61] Birds of Prey
		389880, -- [62] Bombardier
		259495, -- [63] Wildfire Bomb
		265895, -- [64] Terms of Engagement
		259387, -- [65] Mongoose Bite
		263186, -- [66] Flanker's Advantage
		260248, -- [67] Bloodseeker
		378937, -- [68] Explosives Expert
		186289, -- [69] Aspect of the Eagle
		378950, -- [70] Sweeping Spear
		378961, -- [71] Energetic Ally
		378955, -- [72] Killer Companion
		378953, -- [73] Spear Focus
		203415, -- [74] Fury of the Eagle
		378951, -- [75] Tactical Advantage
		321290, -- [76] Improved Wildfire Bomb
		260285, -- [77] Tip of the Spear
		187708, -- [78] Carve
		212436, -- [79] Butchery
		186270, -- [80] Raptor Strike
		378934, -- [81] Lunge
		378916, -- [82] Ferocity
		294029, -- [83] Frenzy Strikes
		378948, -- [84] Sharp Edges
		385695, -- [85] Ranger
	},
	-- Discipline Priest
	[256] = {
		372354, -- [0] Focused Mending
		33076, -- [1] Prayer of Mending
		139, -- [2] Renew
		73325, -- [3] Leap of Faith
		528, -- [4] Dispel Magic
		393870, -- [5] Improved Flash Heal
		34433, -- [6] Shadowfiend
		32379, -- [7] Shadow Word: Death
		321291, -- [8] Death and Madness
		605, -- [9] Mind Control
		205364, -- [10] Dominate Mind
		377422, -- [11] Throes of Pain
		390919, -- [12] Sheer Terror
		108920, -- [13] Void Tendrils
		193063, -- [14] Protective Light
		390615, -- [15] From Darkness Comes Light
		64129, -- [16] Body and Soul
		390632, -- [17] Improved Purify
		121536, -- [18] Angelic Feather
		390620, -- [19] Move with Grace
		132157, -- [20] Holy Nova
		390622, -- [21] Rhapsody
		32375, -- [22] Mass Dispel
		341167, -- [23] Improved Mass Dispel
		373456, -- [24] Unwavering Will
		390676, -- [25] Inspiration
		196704, -- [26] Psychic Voice
		10060, -- [27] Power Infusion
		9484, -- [28] Shackle Undead
		280749, -- [29] Void Shield
		15286, -- [30] Vampiric Embrace
		199855, -- [31] San'layn
		390668, -- [32] Apathy
		373223, -- [33] Tithe Evasion
		375901, -- [34] Mindgames
		390670, -- [35] Improved Fade
		373446, -- [36] Translucent Image
		390972, -- [37] Twist of Fate
		373466, -- [38] Twins of the Sun Priestess
		110744, -- [39] Divine Star
		120517, -- [40] Halo
		373457, -- [41] Crystalline Reflection
		373450, -- [42] Light's Inspiration
		238100, -- [43] Angel's Mercy
		368275, -- [44] Binding Heals
		109186, -- [45] Surge of Light
		373481, -- [46] Power Word: Life
		108945, -- [47] Angelic Bulwark
		108968, -- [48] Void Shift
		391112, -- [49] Shattered Perceptions
		390996, -- [50] Manipulation
		390667, -- [51] Spell Warding
		390767, -- [52] Blessed Recovery
		377438, -- [53] Words of the Pious
		390686, -- [54] Painful Punishment
		47515, -- [55] Divine Aegis
		390693, -- [56] Train of Thought
		391079, -- [57] Make Amends
		390691, -- [58] Borrowed Time
		197419, -- [59] Contrition
		47536, -- [60] Rapture
		372972, -- [61] Dark Indulgence
		198068, -- [62] Power of the Dark Side
		81749, -- [63] Atonement
		194509, -- [64] Power Word: Radiance
		322115, -- [65] Light's Promise
		390684, -- [66] Bright Pupil
		390685, -- [67] Enduring Luminescence
		204197, -- [68] Purge the Wicked
		197045, -- [69] Shield Discipline
		129250, -- [70] Power Word: Solace
		372991, -- [71] Pain Transformation
		373035, -- [72] Protector of the Frail
		33206, -- [73] Pain Suppression
		373427, -- [74] Inescapable Torment
		390832, -- [75] Expiation
		123040, -- [76] Mindbender
		373054, -- [77] Stolen Psyche
		372985, -- [78] Embrace Shadow
		373065, -- [79] Twilight Corruption
		314867, -- [80] Shadow Covenant
		372969, -- [81] Malicious Intent
		214621, -- [82] Schism
		390689, -- [83] Pain and Suffering
		193134, -- [84] Castigation
		373042, -- [85] Exaltation
		373178, -- [86] Light's Wrath
		390765, -- [87] Resplendent Light
		390781, -- [88] Wrath Unleashed
		373180, -- [89] Harsh Discipline
		390705, -- [90] Twilight Equilibrium
		390770, -- [91] Void Summoner
		390786, -- [92] Weal and Woe
		280391, -- [93] Sins of the Many
		238063, -- [94] Lenience
		246287, -- [95] Evangelism
		373003, -- [96] Revel in Purity
		373049, -- [97] Indemnity
		238135, -- [98] Aegis of Wrath
		62618, -- [99] Power Word: Barrier
		108942, -- [100] Phantasm
	},
	-- Holy Priest
	[257] = {
		2050, -- [0] Holy Word: Serenity
		372354, -- [1] Focused Mending
		33076, -- [2] Prayer of Mending
		139, -- [3] Renew
		73325, -- [4] Leap of Faith
		528, -- [5] Dispel Magic
		393870, -- [6] Improved Flash Heal
		34433, -- [7] Shadowfiend
		32379, -- [8] Shadow Word: Death
		321291, -- [9] Death and Madness
		605, -- [10] Mind Control
		205364, -- [11] Dominate Mind
		377422, -- [12] Throes of Pain
		390919, -- [13] Sheer Terror
		108920, -- [14] Void Tendrils
		193063, -- [15] Protective Light
		390615, -- [16] From Darkness Comes Light
		64129, -- [17] Body and Soul
		390632, -- [18] Improved Purify
		121536, -- [19] Angelic Feather
		390620, -- [20] Move with Grace
		132157, -- [21] Holy Nova
		390622, -- [22] Rhapsody
		32375, -- [23] Mass Dispel
		341167, -- [24] Improved Mass Dispel
		373456, -- [25] Unwavering Will
		390676, -- [26] Inspiration
		196704, -- [27] Psychic Voice
		10060, -- [28] Power Infusion
		9484, -- [29] Shackle Undead
		280749, -- [30] Void Shield
		15286, -- [31] Vampiric Embrace
		199855, -- [32] San'layn
		390668, -- [33] Apathy
		373223, -- [34] Tithe Evasion
		375901, -- [35] Mindgames
		390670, -- [36] Improved Fade
		373446, -- [37] Translucent Image
		390972, -- [38] Twist of Fate
		373466, -- [39] Twins of the Sun Priestess
		110744, -- [40] Divine Star
		120517, -- [41] Halo
		373457, -- [42] Crystalline Reflection
		373450, -- [43] Light's Inspiration
		238100, -- [44] Angel's Mercy
		368275, -- [45] Binding Heals
		109186, -- [46] Surge of Light
		373481, -- [47] Power Word: Life
		108945, -- [48] Angelic Bulwark
		108968, -- [49] Void Shift
		391112, -- [50] Shattered Perceptions
		390996, -- [51] Manipulation
		391233, -- [52] Divine Service
		193157, -- [53] Benediction
		391154, -- [54] Holy Mending
		372307, -- [55] Burning Vehemence
		88625, -- [56] Holy Word: Chastise
		390667, -- [57] Spell Warding
		390767, -- [58] Blessed Recovery
		377438, -- [59] Words of the Pious
		200128, -- [60] Trail of Light
		391208, -- [61] Revitalizing Prayers
		196489, -- [62] Sanctified Prayers
		34861, -- [63] Holy Word: Sanctify
		596, -- [64] Prayer of Healing
		238136, -- [65] Cosmic Ripple
		196985, -- [66] Light of the Naaru
		390980, -- [67] Pontifex
		390954, -- [68] Crisis Management
		390947, -- [69] Orison
		321377, -- [70] Prayer Circle
		390881, -- [71] Healing Chorus
		204883, -- [72] Circle of Healing
		391209, -- [73] Prayerful Litany
		391161, -- [74] Everlasting Light
		64843, -- [75] Divine Hymn
		341997, -- [76] Renewed Faith
		200199, -- [77] Censure
		193155, -- [78] Enlightenment
		64901, -- [79] Symbol of Hope
		390977, -- [80] Prayers of the Virtuous
		391186, -- [81] Say Your Prayers
		390967, -- [82] Prismatic Echoes
		372370, -- [83] Gales of Song
		391339, -- [84] Empowered Renew
		391368, -- [85] Rapid Recovery
		390994, -- [86] Harmonious Apparatus
		200183, -- [87] Apotheosis
		265202, -- [88] Holy Word: Salvation
		391381, -- [89] Desperate Times
		391387, -- [90] Answered Prayers
		372616, -- [91] Empyreal Blaze
		372611, -- [92] Searing Light
		235587, -- [93] Miracle Worker
		391124, -- [94] Restitution
		372309, -- [95] Resonant Words
		390992, -- [96] Lightweaver
		372835, -- [97] Lightwell
		108942, -- [98] Phantasm
		392988, -- [99] Divine Image
		372760, -- [100] Divine Word
		196707, -- [101] Afterlife
		47788, -- [102] Guardian Spirit
		200209, -- [103] Guardian Angel
		196437, -- [104] Guardians of the Light
	},
	-- Shadow Priest
	[258] = {
		372354, -- [0] Focused Mending
		33076, -- [1] Prayer of Mending
		139, -- [2] Renew
		73325, -- [3] Leap of Faith
		528, -- [4] Dispel Magic
		393870, -- [5] Improved Flash Heal
		34433, -- [6] Shadowfiend
		32379, -- [7] Shadow Word: Death
		321291, -- [8] Death and Madness
		605, -- [9] Mind Control
		205364, -- [10] Dominate Mind
		377422, -- [11] Throes of Pain
		390919, -- [12] Sheer Terror
		108920, -- [13] Void Tendrils
		193063, -- [14] Protective Light
		390615, -- [15] From Darkness Comes Light
		64129, -- [16] Body and Soul
		213634, -- [17] Purify Disease
		121536, -- [18] Angelic Feather
		390620, -- [19] Move with Grace
		132157, -- [20] Holy Nova
		390622, -- [21] Rhapsody
		32375, -- [22] Mass Dispel
		341167, -- [23] Improved Mass Dispel
		373456, -- [24] Unwavering Will
		390676, -- [25] Inspiration
		196704, -- [26] Psychic Voice
		10060, -- [27] Power Infusion
		9484, -- [28] Shackle Undead
		280749, -- [29] Void Shield
		15286, -- [30] Vampiric Embrace
		199855, -- [31] San'layn
		390668, -- [32] Apathy
		373223, -- [33] Tithe Evasion
		375901, -- [34] Mindgames
		390670, -- [35] Improved Fade
		373446, -- [36] Translucent Image
		390972, -- [37] Twist of Fate
		373466, -- [38] Twins of the Sun Priestess
		373457, -- [39] Crystalline Reflection
		122121, -- [40] Divine Star
		120644, -- [41] Halo
		373450, -- [42] Light's Inspiration
		238100, -- [43] Angel's Mercy
		368275, -- [44] Binding Heals
		109186, -- [45] Surge of Light
		373481, -- [46] Power Word: Life
		108945, -- [47] Angelic Bulwark
		108968, -- [48] Void Shift
		391112, -- [49] Shattered Perceptions
		390996, -- [50] Manipulation
		391288, -- [51] Pain of Death
		199484, -- [52] Psychic Link
		162448, -- [53] Surge of Darkness
		73510, -- [54] Mind Spike
		155271, -- [55] Auspicious Spirits
		391284, -- [56] Tormented Spirits
		341491, -- [57] Shadowy Apparitions
		335467, -- [58] Devouring Plague
		48045, -- [59] Mind Sear
		47585, -- [60] Dispersion
		375888, -- [61] Shadowy Insight
		375994, -- [62] Mental Decay
		391095, -- [63] Dark Evangelism
		288733, -- [64] Intangibility
		377065, -- [65] Mental Fortitude
		341273, -- [66] Unfurling Darkness
		391109, -- [67] Dark Ascension
		228260, -- [68] Void Eruption
		341240, -- [69] Ancient Madness
		373221, -- [70] Malediction
		341374, -- [71] Damnation
		263165, -- [72] Void Torrent
		391242, -- [73] Coalescing Shadows
		64044, -- [74] Psychic Horror
		263716, -- [75] Last Word
		15487, -- [76] Silence
		238558, -- [77] Misery
		263346, -- [78] Dark Void
		375767, -- [79] Screams of the Void
		200174, -- [80] Mindbender
		391296, -- [81] Harnessed Shadows
		377387, -- [82] Puppet Master
		391228, -- [83] Maddening Touch
		373427, -- [84] Inescapable Torment
		377349, -- [85] Idol of C'Thun
		390667, -- [86] Spell Warding
		390767, -- [87] Blessed Recovery
		377438, -- [88] Words of the Pious
		373280, -- [89] Idol of N'Zoth
		391137, -- [90] Whispers of the Damned
		391235, -- [91] Encroaching Shadows
		373202, -- [92] Mind Devourer
		373212, -- [93] Insidious Ire
		391090, -- [94] Mind Melt
		392507, -- [95] Deathspeaker
		391399, -- [96] Mind Flay: Insanity
		205385, -- [97] Shadow Crash
		108942, -- [98] Phantasm
		373273, -- [99] Idol of Yogg-Saron
		373310, -- [100] Idol of Y'Shaarj
	},
	-- Assassination Rogue
	[259] = {
		392384, -- [0] Poison Damage
		382238, -- [1] Lethality
		14983, -- [2] Vigor
		280716, -- [3] Leeching Poison
		14190, -- [4] Seal Fate
		381623, -- [5] Thistle Tea
		36554, -- [6] Shadowstep
		379005, -- [7] Blackjack
		381621, -- [8] Tight Spender
		14062, -- [9] Nightstalker
		79008, -- [10] Elusiveness
		31230, -- [11] Cheat Death
		381619, -- [12] So Versatile
		196924, -- [13] Acrobatic Strikes
		381620, -- [14] Improved Ambush
		193539, -- [15] Alacrity
		193531, -- [16] Deeper Stratagem
		137619, -- [17] Marked for Death
		393970, -- [18] Soothing Darkness
		91023, -- [19] Find Weakness
		185313, -- [20] Shadow Dance
		381620, -- [21] Improved Ambush
		14062, -- [22] Nightstalker
		381622, -- [23] Resounding Clarity
		385616, -- [24] Echoing Reprimand
		378996, -- [25] Recuperator
		381543, -- [26] Virulent Poisons
		231719, -- [27] Deadened Nerves
		381542, -- [28] Deadly Precision
		378813, -- [29] Fleet Footed
		5761, -- [30] Numbing Poison
		381637, -- [31] Atrophic Poison
		5277, -- [32] Evasion
		378427, -- [33] Nimble Fingers
		231691, -- [34] Improved Sprint
		1776, -- [35] Gouge
		1966, -- [36] Feint
		378803, -- [37] Rushed Setup
		131511, -- [38] Prey on the Weak
		31224, -- [39] Cloak of Shadows
		57934, -- [40] Tricks of the Trade
		378807, -- [41] Shadowrunner
		108208, -- [42] Subterfuge
		6770, -- [43] Sap
		2094, -- [44] Blind
		193546, -- [45] Iron Stomach
		378436, -- [46] Master Poisoner
		319066, -- [47] Improved Wound Poison
		5938, -- [48] Shiv
		385408, -- [49] Sepsis
		385424, -- [50] Serrated Bone Spike
		381799, -- [51] Scent of Blood
		381802, -- [52] Indiscriminate Carnage
		381634, -- [53] Vicious Venoms
		381652, -- [54] Maim, Mangle
		328085, -- [55] Blindside
		381798, -- [56] Zoldyck Recipe
		385627, -- [57] Kingsbane
		381624, -- [58] Improved Poisons
		5938, -- [59] Shiv
		360194, -- [60] Deathmark
		381640, -- [61] Lethal Dose
		381673, -- [62] Doomblade
		381800, -- [63] Tiny Toxic Blade
		381664, -- [64] Amplifying Poison
		381669, -- [65] Twist the Knife
		255544, -- [66] Poison Bomb
		381797, -- [67] Dashing Scoundrel
		381801, -- [68] Dragon-Tempered Blades
		79134, -- [69] Venomous Wounds
		381626, -- [70] Bloody Mess
		381630, -- [71] Intent to Kill
		255989, -- [72] Master Assassin
		382245, -- [73] Cold Blood
		385478, -- [74] Shrouded Suffocation
		196861, -- [75] Iron Wire
		381632, -- [76] Improved Garrote
		381627, -- [77] Internal Bleeding
		36554, -- [78] Shadowstep
		2823, -- [79] Deadly Poison
		152152, -- [80] Venom Rush
		381631, -- [81] Flying Daggers
		121411, -- [82] Crimson Tempest
		381629, -- [83] Poisoned Katar
		51667, -- [84] Cut to the Chase
		319032, -- [85] Improved Shiv
		193640, -- [86] Elaborate Planning
		200806, -- [87] Exsanguinate
	},
	-- Outlaw Rogue
	[260] = {
		382238, -- [0] Lethality
		14983, -- [1] Vigor
		280716, -- [2] Leeching Poison
		14190, -- [3] Seal Fate
		381623, -- [4] Thistle Tea
		36554, -- [5] Shadowstep
		379005, -- [6] Blackjack
		381621, -- [7] Tight Spender
		14062, -- [8] Nightstalker
		79008, -- [9] Elusiveness
		31230, -- [10] Cheat Death
		381619, -- [11] So Versatile
		196924, -- [12] Acrobatic Strikes
		381620, -- [13] Improved Ambush
		193539, -- [14] Alacrity
		193531, -- [15] Deeper Stratagem
		137619, -- [16] Marked for Death
		393970, -- [17] Soothing Darkness
		91023, -- [18] Find Weakness
		185313, -- [19] Shadow Dance
		381620, -- [20] Improved Ambush
		14062, -- [21] Nightstalker
		381622, -- [22] Resounding Clarity
		385616, -- [23] Echoing Reprimand
		378996, -- [24] Recuperator
		381543, -- [25] Virulent Poisons
		231719, -- [26] Deadened Nerves
		381542, -- [27] Deadly Precision
		378813, -- [28] Fleet Footed
		5761, -- [29] Numbing Poison
		381637, -- [30] Atrophic Poison
		5277, -- [31] Evasion
		378427, -- [32] Nimble Fingers
		231691, -- [33] Improved Sprint
		1776, -- [34] Gouge
		1966, -- [35] Feint
		378803, -- [36] Rushed Setup
		131511, -- [37] Prey on the Weak
		31224, -- [38] Cloak of Shadows
		57934, -- [39] Tricks of the Trade
		378807, -- [40] Shadowrunner
		108208, -- [41] Subterfuge
		6770, -- [42] Sap
		2094, -- [43] Blind
		193546, -- [44] Iron Stomach
		378436, -- [45] Master Poisoner
		319066, -- [46] Improved Wound Poison
		5938, -- [47] Shiv
		381990, -- [48] Summarily Dispatched
		381989, -- [49] Keep It Rolling
		385408, -- [50] Sepsis
		196937, -- [51] Ghostly Strike
		382742, -- [52] Take 'em by Surprise
		383281, -- [53] Hidden Opportunity
		271877, -- [54] Blade Rush
		381894, -- [55] Triple Threat
		193531, -- [56] Deeper Stratagem
		14161, -- [57] Ruthlessness
		381885, -- [58] Heavy Hitter
		381845, -- [59] Audacity
		381877, -- [60] Combat Stamina
		195457, -- [61] Grappling Hook
		256188, -- [62] Retractable Hook
		382245, -- [63] Cold Blood
		256165, -- [64] Blinding Powder
		381988, -- [65] Swift Slashes
		79096, -- [66] Restless Blades
		354897, -- [67] Float Like a Butterfly
		315508, -- [68] Roll the Bones
		256170, -- [69] Loaded Dice
		382794, -- [70] Restless Crew [NYI]
		381982, -- [71] Count the Odds
		381839, -- [72] Sleight of Hand
		381822, -- [73] Ambidexterity
		13877, -- [74] Blade Flurry
		344363, -- [75] Riposte
		315341, -- [76] Between the Eyes
		108216, -- [77] Dirty Tricks
		196922, -- [78] Hit and Run
		381828, -- [79] Ace Up Your Sleeve
		381878, -- [80] Long Arm of the Outlaw
		272026, -- [81] Dancing Steel
		381985, -- [82] Precise Cuts
		386823, -- [83] Greenskin's Wickers
		381846, -- [84] Fan the Hammer
		51690, -- [85] Killing Spree
		343142, -- [86] Dreadblades
		382746, -- [87] Improved Main Gauche
		196938, -- [88] Quick Draw
		35551, -- [89] Fatal Flourish
		13750, -- [90] Adrenaline Rush
		61329, -- [91] Combat Potency
		200733, -- [92] Weaponmaster
		279876, -- [93] Opportunity
	},
	-- Subtlety Rogue
	[261] = {
		382238, -- [0] Lethality
		14983, -- [1] Vigor
		280716, -- [2] Leeching Poison
		14190, -- [3] Seal Fate
		381623, -- [4] Thistle Tea
		36554, -- [5] Shadowstep
		379005, -- [6] Blackjack
		381621, -- [7] Tight Spender
		14062, -- [8] Nightstalker
		79008, -- [9] Elusiveness
		31230, -- [10] Cheat Death
		381619, -- [11] So Versatile
		196924, -- [12] Acrobatic Strikes
		381620, -- [13] Improved Ambush
		193539, -- [14] Alacrity
		193531, -- [15] Deeper Stratagem
		137619, -- [16] Marked for Death
		393970, -- [17] Soothing Darkness
		91023, -- [18] Find Weakness
		185313, -- [19] Shadow Dance
		381620, -- [20] Improved Ambush
		14062, -- [21] Nightstalker
		381622, -- [22] Resounding Clarity
		385616, -- [23] Echoing Reprimand
		378996, -- [24] Recuperator
		381543, -- [25] Virulent Poisons
		231719, -- [26] Deadened Nerves
		381542, -- [27] Deadly Precision
		378813, -- [28] Fleet Footed
		5761, -- [29] Numbing Poison
		381637, -- [30] Atrophic Poison
		5277, -- [31] Evasion
		378427, -- [32] Nimble Fingers
		231691, -- [33] Improved Sprint
		1776, -- [34] Gouge
		1966, -- [35] Feint
		378803, -- [36] Rushed Setup
		131511, -- [37] Prey on the Weak
		31224, -- [38] Cloak of Shadows
		57934, -- [39] Tricks of the Trade
		378807, -- [40] Shadowrunner
		108208, -- [41] Subterfuge
		6770, -- [42] Sap
		2094, -- [43] Blind
		193546, -- [44] Iron Stomach
		378436, -- [45] Master Poisoner
		319066, -- [46] Improved Wound Poison
		5938, -- [47] Shiv
		382245, -- [48] Cold Blood
		382503, -- [49] Quick Decisions
		319951, -- [50] Improved Shuriken Storm
		319175, -- [51] Black Powder
		277953, -- [52] Night Terrors
		280719, -- [53] Secret Technique
		385722, -- [54] Silent Storm
		58423, -- [55] Relentless Strikes
		36554, -- [56] Shadowstep
		108209, -- [57] Shadow Focus
		121471, -- [58] Shadow Blades
		382509, -- [59] Stiletto Staccato
		185314, -- [60] Deepening Shadows
		382017, -- [61] Veiltouched
		277925, -- [62] Shuriken Tornado
		382506, -- [63] Replicating Shadows
		382511, -- [64] Shadowed Finishers
		193531, -- [65] Deeper Stratagem
		384631, -- [66] Flagellation
		382504, -- [67] Dark Brew
		382525, -- [68] Finality
		382517, -- [69] Deeper Daggers
		257505, -- [70] Shot in the Dark
		200758, -- [71] Gloomblade
		382507, -- [72] Shrouded in Darkness
		212283, -- [73] Symbols of Death
		382508, -- [74] Planned Execution
		382512, -- [75] Inevitability
		385408, -- [76] Sepsis
		382015, -- [77] The Rotten
		382523, -- [78] Invigorating Shadowdust
		382518, -- [79] Perforated Veins
		382513, -- [80] Without a Trace
		245687, -- [81] Dark Shadow
		382515, -- [82] Cloaked in Shadows
		382514, -- [83] Fade to Nothing
		393972, -- [84] Improved Shadow Dance
		382505, -- [85] The First Dance
		196976, -- [86] Master of Shadows
		394023, -- [87] Improved Shadow Techniques
		343160, -- [88] Premeditation
		193537, -- [89] Weaponmaster
		319949, -- [90] Improved Backstab
		382528, -- [91] Danse Macabre
		382524, -- [92] Lingering Shadow
	},
	-- Elemental Shaman
	[262] = {
		381647, -- [0] Planes Traveler
		377933, -- [1] Astral Bulwark
		108271, -- [2] Astral Shift
		381666, -- [3] Focused Insight
		382888, -- [4] Flurry
		187880, -- [5] Maelstrom Weapon
		188443, -- [6] Chain Lightning
		51505, -- [7] Lava Burst
		1064, -- [8] Chain Heal
		198103, -- [9] Earth Elemental
		192088, -- [10] Graceful Spirit
		378077, -- [11] Spiritwalker's Aegis
		79206, -- [12] Spiritwalker's Grace
		382886, -- [13] Fire and Ice
		57994, -- [14] Wind Shear
		8143, -- [15] Tremor Totem
		265046, -- [16] Static Charge
		381819, -- [17] Guardian's Cudgel
		192058, -- [18] Capacitor Totem
		260878, -- [19] Spirit Wolf
		378075, -- [20] Thunderous Paws
		196840, -- [21] Frost Shock
		51886, -- [22] Cleanse Spirit
		370, -- [23] Purge
		378773, -- [24] Greater Purge
		204268, -- [25] Voodoo Mastery
		378079, -- [26] Enfeeblement
		51514, -- [27] Hex
		108287, -- [28] Totemic Projection
		30884, -- [29] Nature's Guardian
		192077, -- [30] Wind Rush Totem
		51485, -- [31] Earthgrab Totem
		382947, -- [32] Ancestral Defense
		381689, -- [33] Brimming with Life
		381655, -- [34] Nature's Fury
		382215, -- [35] Winds of Al'Akir
		58875, -- [36] Spirit Walk
		192063, -- [37] Gust of Wind
		381678, -- [38] Go with the Flow
		383011, -- [39] Call of the Elements
		383012, -- [40] Creation Core
		108285, -- [41] Totemic Recall
		382033, -- [42] Surging Shields
		383013, -- [43] Poison Cleansing Totem
		382201, -- [44] Totemic Focus
		383017, -- [45] Stoneskin Totem
		383019, -- [46] Tranquil Air Totem
		378779, -- [47] Thundershock
		305483, -- [48] Lightning Lasso
		51490, -- [49] Thunderstorm
		381674, -- [50] Improved Lightning Bolt
		378081, -- [51] Nature's Swiftness
		5394, -- [52] Healing Stream Totem
		378094, -- [53] Swirling Currents
		108281, -- [54] Ancestral Guidance
		381930, -- [55] Mana Spring Totem
		381867, -- [56] Totemic Surge
		383010, -- [57] Elemental Orbit
		974, -- [58] Earth Shield
		381650, -- [59] Elemental Warding
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
		381647, -- [0] Planes Traveler
		377933, -- [1] Astral Bulwark
		108271, -- [2] Astral Shift
		381666, -- [3] Focused Insight
		382888, -- [4] Flurry
		187880, -- [5] Maelstrom Weapon
		188443, -- [6] Chain Lightning
		51505, -- [7] Lava Burst
		1064, -- [8] Chain Heal
		198103, -- [9] Earth Elemental
		192088, -- [10] Graceful Spirit
		378077, -- [11] Spiritwalker's Aegis
		79206, -- [12] Spiritwalker's Grace
		382886, -- [13] Fire and Ice
		57994, -- [14] Wind Shear
		8143, -- [15] Tremor Totem
		265046, -- [16] Static Charge
		381819, -- [17] Guardian's Cudgel
		192058, -- [18] Capacitor Totem
		260878, -- [19] Spirit Wolf
		378075, -- [20] Thunderous Paws
		196840, -- [21] Frost Shock
		370, -- [22] Purge
		378773, -- [23] Greater Purge
		51886, -- [24] Cleanse Spirit
		204268, -- [25] Voodoo Mastery
		378079, -- [26] Enfeeblement
		51514, -- [27] Hex
		108287, -- [28] Totemic Projection
		30884, -- [29] Nature's Guardian
		192077, -- [30] Wind Rush Totem
		51485, -- [31] Earthgrab Totem
		382947, -- [32] Ancestral Defense
		381689, -- [33] Brimming with Life
		381655, -- [34] Nature's Fury
		382215, -- [35] Winds of Al'Akir
		58875, -- [36] Spirit Walk
		192063, -- [37] Gust of Wind
		381678, -- [38] Go with the Flow
		383011, -- [39] Call of the Elements
		383012, -- [40] Creation Core
		108285, -- [41] Totemic Recall
		382033, -- [42] Surging Shields
		383013, -- [43] Poison Cleansing Totem
		382201, -- [44] Totemic Focus
		383017, -- [45] Stoneskin Totem
		383019, -- [46] Tranquil Air Totem
		378779, -- [47] Thundershock
		305483, -- [48] Lightning Lasso
		51490, -- [49] Thunderstorm
		381674, -- [50] Improved Lightning Bolt
		378081, -- [51] Nature's Swiftness
		5394, -- [52] Healing Stream Totem
		378094, -- [53] Swirling Currents
		108281, -- [54] Ancestral Guidance
		381930, -- [55] Mana Spring Totem
		381867, -- [56] Totemic Surge
		383010, -- [57] Elemental Orbit
		974, -- [58] Earth Shield
		381650, -- [59] Elemental Warding
		393905, -- [60] Refreshing Waters
		382197, -- [61] Ancestral Wolf Affinity
		384149, -- [62] Overflowing Maelstrom
		197214, -- [63] Sundering
		187874, -- [64] Crash Lightning
		384363, -- [65] Gathering Storms
		51533, -- [66] Feral Spirit
		384447, -- [67] Witch Doctor's Ancestry
		262624, -- [68] Elemental Spirits
		198434, -- [69] Alpha Wolf
		262647, -- [70] Forceful Winds
		390288, -- [71] Unruly Winds
		392352, -- [72] Storm's Wrath
		117014, -- [73] Elemental Blast
		375982, -- [74] Primordial Wave
		384405, -- [75] Primal Maelstrom
		382042, -- [76] Splintered Elements
		210853, -- [77] Elemental Assault
		384355, -- [78] Elemental Weapons
		319930, -- [79] Stormblast
		384352, -- [80] Doom Winds
		33757, -- [81] Windfury Weapon
		383303, -- [82] Improved Maelstrom Weapon
		342240, -- [83] Ice Strike
		384359, -- [84] Swirling Maelstrom
		344357, -- [85] Stormflurry
		334308, -- [86] Crashing Storms
		114051, -- [87] Ascendance
		378270, -- [88] Deeply Rooted Elements
		384450, -- [89] Legacy of the Frost Witch
		384411, -- [90] Static Accumulation
		384444, -- [91] Thorim's Invocation
		334046, -- [92] Lashing Flames
		390370, -- [93] Ashen Catalyst
		196884, -- [94] Feral Lunge
		201900, -- [95] Hot Hand
		334195, -- [96] Hailstorm
		333974, -- [97] Fire Nova
		334033, -- [98] Molten Assault
		60103, -- [99] Lava Lash
		17364, -- [100] Stormstrike
		8512, -- [101] Windfury Totem
		384143, -- [102] Raging Maelstrom
	},
	-- Restoration Shaman
	[264] = {
		108280, -- [0] Healing Tide Totem
		98008, -- [1] Spirit Link Totem
		382046, -- [2] Continuous Waves
		382040, -- [3] Tumbling Waves
		382191, -- [4] Improved Primordial Wave
		375982, -- [5] Primordial Wave
		200071, -- [6] Undulation
		73685, -- [7] Unleash Life
		381946, -- [8] Wavespeaker's Blessing
		383222, -- [9] Overflowing Shores
		378443, -- [10] Acid Rain
		73920, -- [11] Healing Rain
		382019, -- [12] Nature's Focus
		382045, -- [13] Primal Tide Core
		157154, -- [14] High Tide
		382309, -- [15] Ancestral Awakening
		333919, -- [16] Echo of the Elements
		16191, -- [17] Mana Tide Totem
		198838, -- [18] Earthen Wall Totem
		207399, -- [19] Ancestral Protection Totem
		200072, -- [20] Torrent
		382482, -- [21] Living Stream
		157153, -- [22] Cloudburst Totem
		382021, -- [23] Earthliving Weapon
		382315, -- [24] Improved Earthliving Weapon
		378270, -- [25] Deeply Rooted Elements
		197995, -- [26] Wellspring
		382194, -- [27] Undercurrent
		382029, -- [28] Ever-Rising Tide
		382020, -- [29] Earthen Harmony
		114052, -- [30] Ascendance
		381647, -- [31] Planes Traveler
		377933, -- [32] Astral Bulwark
		108271, -- [33] Astral Shift
		381666, -- [34] Focused Insight
		382888, -- [35] Flurry
		187880, -- [36] Maelstrom Weapon
		188443, -- [37] Chain Lightning
		51505, -- [38] Lava Burst
		1064, -- [39] Chain Heal
		198103, -- [40] Earth Elemental
		192088, -- [41] Graceful Spirit
		378077, -- [42] Spiritwalker's Aegis
		79206, -- [43] Spiritwalker's Grace
		382886, -- [44] Fire and Ice
		57994, -- [45] Wind Shear
		8143, -- [46] Tremor Totem
		265046, -- [47] Static Charge
		381819, -- [48] Guardian's Cudgel
		192058, -- [49] Capacitor Totem
		260878, -- [50] Spirit Wolf
		378075, -- [51] Thunderous Paws
		383016, -- [52] Improved Purify Spirit
		196840, -- [53] Frost Shock
		370, -- [54] Purge
		378773, -- [55] Greater Purge
		204268, -- [56] Voodoo Mastery
		378079, -- [57] Enfeeblement
		51514, -- [58] Hex
		108287, -- [59] Totemic Projection
		30884, -- [60] Nature's Guardian
		192077, -- [61] Wind Rush Totem
		51485, -- [62] Earthgrab Totem
		382947, -- [63] Ancestral Defense
		381689, -- [64] Brimming with Life
		381655, -- [65] Nature's Fury
		382215, -- [66] Winds of Al'Akir
		58875, -- [67] Spirit Walk
		192063, -- [68] Gust of Wind
		381678, -- [69] Go with the Flow
		383011, -- [70] Call of the Elements
		383012, -- [71] Creation Core
		108285, -- [72] Totemic Recall
		382033, -- [73] Surging Shields
		383013, -- [74] Poison Cleansing Totem
		382201, -- [75] Totemic Focus
		383017, -- [76] Stoneskin Totem
		383019, -- [77] Tranquil Air Totem
		378779, -- [78] Thundershock
		305483, -- [79] Lightning Lasso
		51490, -- [80] Thunderstorm
		381674, -- [81] Improved Lightning Bolt
		378081, -- [82] Nature's Swiftness
		5394, -- [83] Healing Stream Totem
		378094, -- [84] Swirling Currents
		108281, -- [85] Ancestral Guidance
		381930, -- [86] Mana Spring Totem
		381867, -- [87] Totemic Surge
		383010, -- [88] Elemental Orbit
		974, -- [89] Earth Shield
		381650, -- [90] Elemental Warding
		382197, -- [91] Ancestral Wolf Affinity
		383009, -- [92] Stormkeeper
		200076, -- [93] Deluge
		61295, -- [94] Riptide
		77472, -- [95] Healing Wave
		52127, -- [96] Water Shield
		16196, -- [97] Resurgence
		378241, -- [98] Call of Thunder
		5394, -- [99] Healing Stream Totem
		51564, -- [100] Tidal Waves
		280614, -- [101] Flash Flood
		378211, -- [102] Refreshing Waters
		16166, -- [103] Master of the Elements
		382030, -- [104] Water Totem Mastery
		77756, -- [105] Lava Surge
		207778, -- [106] Downpour
		207401, -- [107] Ancestral Vigor
		382732, -- [108] Ancestral Reach
		382039, -- [109] Flow of the Tides
	},
	-- Affliction Warlock
	[265] = {
		108558, -- [0] Nightfall
		32388, -- [1] Shadow Embrace
		201424, -- [2] Harvester of Souls
		387073, -- [3] Soul Tap
		199471, -- [4] Soul Flame
		196102, -- [5] Writhe in Agony
		196226, -- [6] Sow the Seeds
		386922, -- [7] Agonizing Corruption
		386951, -- [8] Soul Swap
		205179, -- [9] Phantom Singularity
		278350, -- [10] Vile Taint
		386986, -- [11] Sacrolash's Dark Strike
		205180, -- [12] Summon Darkglare
		387065, -- [13] Wrath of Consumption
		48181, -- [14] Haunt
		387075, -- [15] Tormented Crescendo
		264000, -- [16] Creeping Death
		387016, -- [17] Dark Harvest
		386997, -- [18] Soul Rot
		386976, -- [19] Withering Bolt
		108503, -- [20] Grimoire of Sacrifice
		196103, -- [21] Absolute Corruption
		63106, -- [22] Siphon Life
		386759, -- [23] Pandemic Invocation
		317031, -- [24] Xavian Teachings
		27243, -- [25] Seed of Corruption
		324536, -- [26] Malefic Rapture
		316099, -- [27] Unstable Affliction
		334319, -- [28] Inevitable Demise
		108416, -- [29] Dark Pact
		386664, -- [30] Ichor of Devils
		386686, -- [31] Frequent Donor
		389623, -- [32] Gorefiend's Resolve
		389590, -- [33] Demonic Resilience
		389367, -- [34] Fel Synergy
		389576, -- [35] Profane Bargain
		389630, -- [36] Soul-Eater's Gluttony
		389761, -- [37] Malefic Affliction
		386617, -- [38] Demonic Fortitude
		215941, -- [39] Soul Conduit
		171975, -- [40] Grimoire of Synergy
		108415, -- [41] Soul Link
		386689, -- [42] Grim Feast
		386620, -- [43] Sweet Souls
		386858, -- [44] Demonic Inspiration
		386619, -- [45] Desperate Pact
		288843, -- [46] Demonic Embrace
		333889, -- [47] Fel Domination
		386113, -- [48] Fel Pact
		268358, -- [49] Demonic Circle
		328774, -- [50] Amplify Curse
		387972, -- [51] Teachings of the Satyr
		387250, -- [52] Seized Vitality
		387301, -- [53] Haunted Soul
		337020, -- [54] Wilfred's Sigil of Superior Summoning
		389992, -- [55] Grim Reach
		387273, -- [56] Malevolent Visionary
		389764, -- [57] Doom Blossom
		389775, -- [58] Dread Touch
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
		710, -- [74] Banish
		386651, -- [75] Greater Banish
		30283, -- [76] Shadowfury
		264874, -- [77] Darkfury
		384069, -- [78] Shadowflame
		386646, -- [79] Lifeblood
		386244, -- [80] Summon Soulkeeper
		386344, -- [81] Inquisitor's Gaze
		385881, -- [82] Teachings of the Black Harvest
		389359, -- [83] Resolute Barrier
		388667, -- [84] Drain Soul
	},
	-- Demonology Warlock
	[266] = {
		387578, -- [0] Gul'dan's Ambition
		387526, -- [1] Ner'zhul's Volition
		267217, -- [2] Nether Portal
		387445, -- [3] Imp Gang Boss
		387391, -- [4] Dread Calling
		387432, -- [5] Fel Covenant
		387349, -- [6] Bloodbound Imps
		196277, -- [7] Implosion
		264130, -- [8] Power Siphon
		387541, -- [9] Pact of the Imp Mother
		386833, -- [10] Guillotine
		387549, -- [11] Infernal Command
		387602, -- [12] Stolen Power
		387494, -- [13] Antoran Armaments
		387485, -- [14] Ripped through the Portal
		387399, -- [15] Fel Sunder
		387488, -- [16] Hounds of War
		387396, -- [17] Demonic Meteor
		111898, -- [18] Grimoire: Felguard
		387338, -- [19] Fel Might
		267170, -- [20] From the Shadows
		386200, -- [21] Fel and Steel
		205145, -- [22] Demonic Calling
		386194, -- [23] Carnivorous Stalkers
		264119, -- [24] Summon Vilefiend
		264057, -- [25] Soul Strike
		264078, -- [26] Dreadlash
		265187, -- [27] Summon Demonic Tyrant
		387483, -- [28] Kazaak's Final Curse
		603, -- [29] Doom
		267216, -- [30] Inner Demons
		386185, -- [31] Demonic Knowledge
		387322, -- [32] Shadow's Bite
		264178, -- [33] Demonbolt
		104316, -- [34] Call Dreadstalkers
		386174, -- [35] Annihilan Training
		267211, -- [36] Bilescourge Bombers
		267171, -- [37] Demonic Strength
		387600, -- [38] The Expendables
		267214, -- [39] Sacrificed Souls
		334585, -- [40] Soulbound Tyrant
		108416, -- [41] Dark Pact
		386664, -- [42] Ichor of Devils
		386686, -- [43] Frequent Donor
		389623, -- [44] Gorefiend's Resolve
		389590, -- [45] Demonic Resilience
		389367, -- [46] Fel Synergy
		389576, -- [47] Profane Bargain
		386617, -- [48] Demonic Fortitude
		215941, -- [49] Soul Conduit
		171975, -- [50] Grimoire of Synergy
		108415, -- [51] Soul Link
		386689, -- [52] Grim Feast
		386620, -- [53] Sweet Souls
		386858, -- [54] Demonic Inspiration
		386619, -- [55] Desperate Pact
		288843, -- [56] Demonic Embrace
		333889, -- [57] Fel Domination
		386113, -- [58] Fel Pact
		268358, -- [59] Demonic Circle
		328774, -- [60] Amplify Curse
		387972, -- [61] Teachings of the Satyr
		390173, -- [62] Reign of Tyranny
		337020, -- [63] Wilfred's Sigil of Superior Summoning
		385899, -- [64] Soulburn
		317138, -- [65] Strength of Will
		386659, -- [66] Dark Accord
		111771, -- [67] Demonic Gateway
		389609, -- [68] Abyss Walker
		386613, -- [69] Accrued Vitality
		219272, -- [70] Demon Skin
		386105, -- [71] Curses of Enfeeblement
		386124, -- [72] Fel Armor
		111400, -- [73] Burning Rush
		386110, -- [74] Fiendish Stride
		5484, -- [75] Howl of Terror
		6789, -- [76] Mortal Coil
		386864, -- [77] Wrathful Minion
		386648, -- [78] Nightmare
		710, -- [79] Banish
		386651, -- [80] Greater Banish
		30283, -- [81] Shadowfury
		264874, -- [82] Darkfury
		384069, -- [83] Shadowflame
		386646, -- [84] Lifeblood
		386244, -- [85] Summon Soulkeeper
		386344, -- [86] Inquisitor's Gaze
		385881, -- [87] Teachings of the Black Harvest
		389359, -- [88] Resolute Barrier
	},
	-- Destruction Warlock
	[267] = {
		5740, -- [0] Rain of Fire
		116858, -- [1] Chaos Bolt
		17962, -- [2] Conflagrate
		196406, -- [3] Backdraft
		205184, -- [4] Roaring Blaze
		231793, -- [5] Improved Conflagrate
		196447, -- [6] Channel Demonfire
		387166, -- [7] Raging Demonfire
		387103, -- [8] Ruin
		387108, -- [9] Conflagration of Chaos
		17877, -- [10] Shadowburn
		388827, -- [11] Explosive Potential
		108416, -- [12] Dark Pact
		386664, -- [13] Ichor of Devils
		386686, -- [14] Frequent Donor
		389623, -- [15] Gorefiend's Resolve
		389590, -- [16] Demonic Resilience
		389367, -- [17] Fel Synergy
		389576, -- [18] Profane Bargain
		386617, -- [19] Demonic Fortitude
		215941, -- [20] Soul Conduit
		171975, -- [21] Grimoire of Synergy
		108415, -- [22] Soul Link
		386689, -- [23] Grim Feast
		386620, -- [24] Sweet Souls
		386858, -- [25] Demonic Inspiration
		386619, -- [26] Desperate Pact
		288843, -- [27] Demonic Embrace
		333889, -- [28] Fel Domination
		386113, -- [29] Fel Pact
		268358, -- [30] Demonic Circle
		328774, -- [31] Amplify Curse
		387972, -- [32] Teachings of the Satyr
		1122, -- [33] Summon Infernal
		196412, -- [34] Eradication
		387384, -- [35] Backlash
		196408, -- [36] Fire and Brimstone
		387509, -- [37] Pandemonium
		387522, -- [38] Cry Havoc
		205148, -- [39] Reverse Entropy
		266134, -- [40] Internal Combustion
		387506, -- [41] Mayhem
		80240, -- [42] Havoc
		6353, -- [43] Soul Fire
		387176, -- [44] Decimation
		387093, -- [45] Improved Immolate
		387095, -- [46] Pyrogenics
		270545, -- [47] Inferno
		152108, -- [48] Cataclysm
		388832, -- [49] Scalding Flames
		387259, -- [50] Flashpoint
		108503, -- [51] Grimoire of Sacrifice
		387156, -- [52] Ritual of Ruin
		387252, -- [53] Ashen Remains
		387173, -- [54] Diabolic Embers
		387400, -- [55] Madness of the Azj'Aqir
		387275, -- [56] Chaos Incarnate
		387976, -- [57] Dimensional Rift
		387279, -- [58] Power Overwhelming
		387153, -- [59] Burn to Ashes
		387159, -- [60] Avatar of Destruction
		387165, -- [61] Master Ritualist
		387569, -- [62] Rolling Havoc
		387355, -- [63] Crashing Chaos
		266086, -- [64] Rain of Chaos
		387084, -- [65] Grand Warlock's Design
		387475, -- [66] Infernal Brand
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
		386244, -- [88] Summon Soulkeeper
		386344, -- [89] Inquisitor's Gaze
		385881, -- [90] Teachings of the Black Harvest
		389359, -- [91] Resolute Barrier
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
		115203, -- [57] Fortifying Brew
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
		389577, -- [0] Bounce Back
		115315, -- [1] Summon Black Ox Statue
		394110, -- [2] Escape from Reality
		389579, -- [3] Save Them All
		115313, -- [4] Summon Jade Serpent Statue
		328669, -- [5] Improved Roll
		392900, -- [6] Vigorous Expulsion
		388811, -- [7] Grace of the Crane
		115098, -- [8] Chi Wave
		123986, -- [9] Chi Burst
		392910, -- [10] Profound Rebuttal
		389574, -- [11] Close to Heart
		388674, -- [12] Ferocity of Xuen
		388809, -- [13] Fast Feet
		122278, -- [14] Dampen Harm
		394123, -- [15] Fatal Touch
		389578, -- [16] Resonant Fists
		388686, -- [17] Summon White Tiger Statue
		196607, -- [18] Eye of the Tiger
		157411, -- [19] Windwalking
		116844, -- [20] Ring of Peace
		122783, -- [21] Diffuse Magic
		328670, -- [22] Hasty Provocation
		388812, -- [23] Vivacious Vivification
		101643, -- [24] Transcendence
		388664, -- [25] Calming Presence
		231602, -- [26] Improved Vivify
		115175, -- [27] Soothing Mist
		107428, -- [28] Rising Sun Kick
		116841, -- [29] Tiger's Lust
		115078, -- [30] Paralysis
		344359, -- [31] Paralysis
		116705, -- [32] Spear Hand Strike
		115173, -- [33] Celerity
		115008, -- [34] Chi Torpedo
		322113, -- [35] Improved Touch of Death
		389575, -- [36] Generous Pour
		387276, -- [37] Strength of Spirit
		388814, -- [38] Ironshell Brew
		388813, -- [39] Expeditious Fortification
		115203, -- [40] Fortifying Brew
		116095, -- [41] Disable
		392970, -- [42] Open Palm Strikes
		392958, -- [43] Glory of the Dawn
		392979, -- [44] Jade Ignition
		392983, -- [45] Strike of the Windlord
		392985, -- [46] Thunderfist
		392986, -- [47] Xuen's Bond
		392989, -- [48] Last Emperor's Capacitor
		388849, -- [49] Rising Star
		391412, -- [50] Faeline Harmony
		394093, -- [51] Dust in the Wind
		386276, -- [52] Bonedust Brew
		386941, -- [53] Attenuation
		388848, -- [54] Crane Vortex
		331679, -- [55] Fatal Flying Guillotine
		388681, -- [56] Elusive Mists
		264348, -- [57] Tiger Tail Sweep
		392994, -- [58] Way of the Fae
		218164, -- [59] Detox
		196740, -- [60] Hit Combo
		393098, -- [61] Forbidden Technique
		388846, -- [62] Widening Whirl
		122470, -- [63] Touch of Karma
		391383, -- [64] Hardened Soles
		115396, -- [65] Ascension
		113656, -- [66] Fists of Fury
		388193, -- [67] Faeline Stomp
		121817, -- [68] Power Strikes
		388854, -- [69] Flashing Fists
		116645, -- [70] Teachings of the Monastery
		280197, -- [71] Spiritual Focus
		137639, -- [72] Storm, Earth, and Fire
		152173, -- [73] Serenity
		391370, -- [74] Drinking Horn Cover
		391330, -- [75] Meridian Strikes
		101545, -- [76] Flying Serpent Kick
		388856, -- [77] Touch of the Tiger
		228287, -- [78] Mark of the Crane
		392982, -- [79] Shadowboxing Treads
		116847, -- [80] Rushing Jade Wind
		325201, -- [81] Dance of Chi-Ji
		195243, -- [82] Inner Peace
		287055, -- [83] Fury of Xuen
		123904, -- [84] Invoke Xuen, the White Tiger
		152175, -- [85] Whirling Dragon Punch
		335913, -- [86] Empowered Tiger Lightning
		195300, -- [87] Transfer the Power
		388661, -- [88] Invoker's Delight
		392993, -- [89] Xuen's Battlegear
		392991, -- [90] Skyreach
	},
	-- Mistweaver Monk
	[270] = {
		388682, -- [0] Misty Peaks
		388604, -- [1] Echoing Reverberation
		388564, -- [2] Accumulating Mist
		393460, -- [3] Tea of Serenity
		388517, -- [4] Tea of Plenty
		124081, -- [5] Zen Pulse
		388548, -- [6] Mists of Life
		124682, -- [7] Enveloping Mist
		388740, -- [8] Ancient Concordance
		388491, -- [9] Secret Infusion
		388661, -- [10] Invoker's Delight
		122281, -- [11] Healing Elixir
		388477, -- [12] Unison
		388509, -- [13] Mending Proliferation
		115310, -- [14] Revival
		388615, -- [15] Restoral
		197915, -- [16] Lifecycles
		197908, -- [17] Mana Tea
		388847, -- [18] Rapid Diffusion
		388874, -- [19] Improved Detox
		388038, -- [20] Yu'lon's Whisper
		388779, -- [21] Awakened Faeline
		388031, -- [22] Jade Bond
		388212, -- [23] Gift of the Celestials
		210802, -- [24] Spirit of the Crane
		198898, -- [25] Song of Chi-Ji
		388193, -- [26] Faeline Stomp
		274586, -- [27] Invigorating Mists
		387991, -- [28] Tear of Morning
		274909, -- [29] Rising Mist
		389577, -- [30] Bounce Back
		115315, -- [31] Summon Black Ox Statue
		394110, -- [32] Escape from Reality
		389579, -- [33] Save Them All
		115313, -- [34] Summon Jade Serpent Statue
		328669, -- [35] Improved Roll
		392900, -- [36] Vigorous Expulsion
		388811, -- [37] Grace of the Crane
		115098, -- [38] Chi Wave
		123986, -- [39] Chi Burst
		392910, -- [40] Profound Rebuttal
		389574, -- [41] Close to Heart
		388674, -- [42] Ferocity of Xuen
		388809, -- [43] Fast Feet
		122278, -- [44] Dampen Harm
		394123, -- [45] Fatal Touch
		389578, -- [46] Resonant Fists
		388686, -- [47] Summon White Tiger Statue
		196607, -- [48] Eye of the Tiger
		157411, -- [49] Windwalking
		116844, -- [50] Ring of Peace
		122783, -- [51] Diffuse Magic
		328670, -- [52] Hasty Provocation
		388812, -- [53] Vivacious Vivification
		101643, -- [54] Transcendence
		388664, -- [55] Calming Presence
		231602, -- [56] Improved Vivify
		115175, -- [57] Soothing Mist
		107428, -- [58] Rising Sun Kick
		116841, -- [59] Tiger's Lust
		115078, -- [60] Paralysis
		344359, -- [61] Paralysis
		116705, -- [62] Spear Hand Strike
		115173, -- [63] Celerity
		115008, -- [64] Chi Torpedo
		322113, -- [65] Improved Touch of Death
		389575, -- [66] Generous Pour
		387276, -- [67] Strength of Spirit
		388814, -- [68] Ironshell Brew
		388813, -- [69] Expeditious Fortification
		115203, -- [70] Fortifying Brew
		116095, -- [71] Disable
		388511, -- [72] Overflowing Mists
		343655, -- [73] Enveloping Breath
		388218, -- [74] Calming Coalescence
		116849, -- [75] Life Cocoon
		197900, -- [76] Mist Wrap
		196725, -- [77] Refreshing Jade Wind
		197895, -- [78] Focused Thunder
		274963, -- [79] Upwelling
		388020, -- [80] Resplendent Mist
		115151, -- [81] Renewing Mist
		281231, -- [82] Mastery of Mist
		322118, -- [83] Invoke Yu'lon, the Jade Serpent
		325197, -- [84] Invoke Chi-Ji, the Red Crane
		388551, -- [85] Uplifted Spirits
		388593, -- [86] Peaceful Mending
		116645, -- [87] Teachings of the Monastery
		386949, -- [88] Bountiful Brew
		386941, -- [89] Attenuation
		191837, -- [90] Essence Font
		388023, -- [91] Ancient Teachings
		388047, -- [92] Clouded Focus
		387765, -- [93] Nourishing Chi
		116680, -- [94] Thunder Focus Tea
		388681, -- [95] Elusive Mists
		264348, -- [96] Tiger Tail Sweep
		337209, -- [97] Font of Life
		388701, -- [98] Dancing Mists
		386276, -- [99] Bonedust Brew
	},
	-- Havoc Demon Hunter
	[577] = {
		320654, -- [0] Pursuit
		393029, -- [1] Furious Throws
		206478, -- [2] Demonic Appetite
		343017, -- [3] Improved Fel Rush
		343206, -- [4] Improved Chaos Strike
		328725, -- [5] Mortal Dance
		206416, -- [6] First Blood
		388109, -- [7] Felfire Heart
		320374, -- [8] Burning Hatred
		258881, -- [9] Trail of Ruin
		389978, -- [10] Dancing with Fate
		211881, -- [11] Fel Eruption
		389977, -- [12] Relentless Onslaught
		390154, -- [13] Serrated Glaive
		320415, -- [14] Looks Can Kill
		388112, -- [15] Chaotic Transformation
		320413, -- [16] Critical Chaos
		388108, -- [17] Initiative
		206476, -- [18] Momentum
		389688, -- [19] Tactical Retreat
		347461, -- [20] Unbound Chaos
		388113, -- [21] Isolated Prey
		203550, -- [22] Blind Fury
		343311, -- [23] Furious Gaze
		389693, -- [24] Inner Demon
		391429, -- [25] Fodder to the Flame
		390163, -- [26] Elysian Decree
		391275, -- [27] Mo'arg Bionics
		391189, -- [28] Burning Wound
		390158, -- [29] Growing Inferno
		388114, -- [30] Any Means Necessary
		388106, -- [31] Soulrend
		258860, -- [32] Essence Break
		388118, -- [33] Know Your Enemy
		389687, -- [34] Chaos Theory
		342817, -- [35] Glaive Tempest
		258925, -- [36] Fel Barrage
		390142, -- [37] Restless Hunter
		258887, -- [38] Cycle of Hatred
		388116, -- [39] Shattered Destiny
		258876, -- [40] Insatiable Hunger
		203555, -- [41] Demon Blades
		198013, -- [42] Eye Beam
		320386, -- [43] Bouncing Glaives
		217832, -- [44] Imprison
		320416, -- [45] Hot Feet
		198793, -- [46] Vengeful Retreat
		320635, -- [47] Vengeful Restraint
		320770, -- [48] Unrestrained Fury
		389763, -- [49] Master of the Glaive
		389846, -- [50] Felfire Haste
		205411, -- [51] Desperate Instincts
		196555, -- [52] Netherwalk
		388107, -- [53] Ragefire
		320361, -- [54] Improved Disrupt
		320418, -- [55] Improved Sigil of Misery
		388110, -- [56] Misery in Defeat
		320313, -- [57] Consume Magic
		320331, -- [58] Infernal Armor
		320421, -- [59] Rush of Chaos
		204909, -- [60] Soul Rending
		213410, -- [61] Demonic
		235893, -- [62] Demonic Origins
		389781, -- [63] Long Night
		389783, -- [64] Pitch Black
		196718, -- [65] Darkness
		179057, -- [66] Chaos Nova
		389696, -- [67] Illidari Knowledge
		209281, -- [68] Quickened Sigils
		389697, -- [69] Extended Sigils
		391409, -- [70] Aldrachi Design
		202137, -- [71] Sigil of Silence
		389695, -- [72] Will of the Illidari
		207666, -- [73] Concentrated Sigils
		389799, -- [74] Precise Sigils
		389811, -- [75] Unnatural Malice
		389819, -- [76] Fae Empowered Elixir
		370965, -- [77] The Hunt
		207684, -- [78] Sigil of Misery
		204596, -- [79] Sigil of Flame
		389824, -- [80] Shattered Restoration
		389694, -- [81] Flames of Fury
		213010, -- [82] Charred Warblades
		389849, -- [83] Lost in Darkness
		183782, -- [84] Disrupting Fury
		393822, -- [85] Internal Struggle
		391397, -- [86] Erratic Felheart
		390152, -- [87] Collective Anguish
		320412, -- [88] Chaos Fragments
		206477, -- [89] Unleashed Power
		388111, -- [90] Demon Muzzle [NYI]
		278326, -- [91] Consume Magic
		207347, -- [92] Aura of Pain
		232893, -- [93] Felblade
	},
	-- Vengeance Demon Hunter
	[581] = {
		320654, -- [0] Pursuit
		389985, -- [1] The Weak-Willed
		389976, -- [2] Vulnerability
		207407, -- [3] Soul Carver
		218612, -- [4] Feed the Demon
		393827, -- [5] Stoke the Flames
		389708, -- [6] Darkglare Boon
		390808, -- [7] Volatile Flameblood
		390213, -- [8] Burning Blood
		391178, -- [9] Roaring Fire
		321028, -- [10] Deflecting Spikes
		320386, -- [11] Bouncing Glaives
		217832, -- [12] Imprison
		320416, -- [13] Hot Feet
		198793, -- [14] Vengeful Retreat
		320635, -- [15] Vengeful Restraint
		320770, -- [16] Unrestrained Fury
		389763, -- [17] Master of the Glaive
		389846, -- [18] Felfire Haste
		391165, -- [19] Soul Furnace
		320361, -- [20] Improved Disrupt
		320418, -- [21] Improved Sigil of Misery
		388110, -- [22] Misery in Defeat
		320313, -- [23] Consume Magic
		320331, -- [24] Infernal Armor
		320421, -- [25] Rush of Chaos
		204909, -- [26] Soul Rending
		213410, -- [27] Demonic
		235893, -- [28] Demonic Origins
		389781, -- [29] Long Night
		389783, -- [30] Pitch Black
		196718, -- [31] Darkness
		179057, -- [32] Chaos Nova
		389696, -- [33] Illidari Knowledge
		209281, -- [34] Quickened Sigils
		389697, -- [35] Extended Sigils
		391409, -- [36] Aldrachi Design
		202137, -- [37] Sigil of Silence
		389695, -- [38] Will of the Illidari
		207666, -- [39] Concentrated Sigils
		389799, -- [40] Precise Sigils
		389811, -- [41] Unnatural Malice
		389819, -- [42] Fae Empowered Elixir
		370965, -- [43] The Hunt
		207684, -- [44] Sigil of Misery
		343207, -- [45] Focused Cleave
		207387, -- [46] Painbringer
		389711, -- [47] Soulmonger
		389958, -- [48] Frailty
		320387, -- [49] Perfectly Balanced Glaive
		389997, -- [50] Shear Fury
		263642, -- [51] Fracture
		207548, -- [52] Agonizing Flames
		268175, -- [53] Void Reaver
		247454, -- [54] Spirit Bomb
		207697, -- [55] Feast of Souls
		227174, -- [56] Fallout
		389721, -- [57] Extended Spikes
		326853, -- [58] Ruinous Bulwark
		389720, -- [59] Calcified Spikes
		212084, -- [60] Fel Devastation
		204021, -- [61] Fiery Brand
		389724, -- [62] Abyssal Haste
		389729, -- [63] Retaliation
		389705, -- [64] Fel Flame Fortification
		263648, -- [65] Soul Barrier
		320341, -- [66] Bulk Extraction
		343014, -- [67] Revel in Pain
		389715, -- [68] Chains of Anger
		389718, -- [69] Cycle of Binding
		336639, -- [70] Charred Flesh
		389732, -- [71] Down in Flames
		391429, -- [72] Fodder to the Flame
		390163, -- [73] Elysian Decree
		207739, -- [74] Burning Alive
		389220, -- [75] Fiery Demise
		202138, -- [76] Sigil of Chains
		209258, -- [77] Last Resort
		204596, -- [78] Sigil of Flame
		389824, -- [79] Shattered Restoration
		389694, -- [80] Flames of Fury
		213010, -- [81] Charred Warblades
		389849, -- [82] Lost in Darkness
		183782, -- [83] Disrupting Fury
		393822, -- [84] Internal Struggle
		391397, -- [85] Erratic Felheart
		390152, -- [86] Collective Anguish
		320412, -- [87] Chaos Fragments
		206477, -- [88] Unleashed Power
		388111, -- [89] Demon Muzzle [NYI]
		278326, -- [90] Consume Magic
		207347, -- [91] Aura of Pain
		232893, -- [92] Felblade
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
		371032, -- [0] Terror of the Skies
		374968, -- [1] Time Spiral
		387787, -- [2] Regenerative Magic
		375561, -- [3] Lush Growth
		374348, -- [4] Renewing Blaze
		375574, -- [5] Foci of Life
		375577, -- [6] Fire Within
		374227, -- [7] Zephyr
		370888, -- [8] Twin Guardian
		387341, -- [9] Walloping Blow
		370665, -- [10] Rescue
		365933, -- [11] Aerial Mastery
		374346, -- [12] Overawe
		369909, -- [13] Protracted Talons
		369939, -- [14] Leaping Flames
		368432, -- [15] Unravel
		375507, -- [16] Roar of Exhilaration
		351338, -- [17] Quell
		375510, -- [18] Blast Furnace
		372048, -- [19] Oppressing Roar
		369459, -- [20] Source of Magic
		375544, -- [21] Tempered Scales
		369990, -- [22] Ancient Flame
		376930, -- [23] Attuned to the Dream
		374251, -- [24] Cauterizing Flame
		375406, -- [25] Obsidian Bulwark
		363916, -- [26] Obsidian Scales
		370897, -- [27] Permeating Chill
		375554, -- [28] Enkindled
		375556, -- [29] Tailwind
		375517, -- [30] Extended Flight
		387761, -- [31] Panacea
		358385, -- [32] Landslide
		369913, -- [33] Natural Convergence
		375520, -- [34] Innate Magic
		371806, -- [35] Recall
		376166, -- [36] Draconic Legacy
		370553, -- [37] Tip the Scales
		372469, -- [38] Scarlet Adaptation
		360995, -- [39] Verdant Embrace
		365585, -- [40] Expunge
		376164, -- [41] Instinctive Arcana
		375528, -- [42] Forger of Mountains
		368838, -- [43] Heavy Wingbeats
		375443, -- [44] Clobbering Sweep
		360806, -- [45] Sleep Walk
		370886, -- [46] Bountiful Bloom
		375542, -- [47] Exuberance
		377082, -- [48] Dreamwalker
		377086, -- [49] Rush of Vitality
		370960, -- [50] Emerald Communion
		377100, -- [51] Exhilarating Burst
		375783, -- [52] Font of Magic
		359816, -- [53] Dream Flight
		369908, -- [54] Power Nexus
		371257, -- [55] Renewing Breath
		381921, -- [56] Ouroboros
		376207, -- [57] Delay Harm
		376204, -- [58] Just in Time
		370537, -- [59] Stasis
		368412, -- [60] Time of Need
		376240, -- [61] Timeless Magic
		372233, -- [62] Energy Loop
		371270, -- [63] Punctuality
		376236, -- [64] Resonating Sphere
		376237, -- [65] Nozdormu's Teachings
		385696, -- [66] Flow State
		373861, -- [67] Temporal Anomaly
		363534, -- [68] Rewind
		357170, -- [69] Time Dilation
		378196, -- [70] Golden Hour
		372527, -- [71] Time Lord
		371426, -- [72] Life-Giver's Flame
		376179, -- [73] Lifeforce Mender
		373834, -- [74] Call of Ysera
		376210, -- [75] Erasure
		381922, -- [76] Temporal Artificer
		376239, -- [77] Grace Period
		371832, -- [78] Cycle of Life
		376138, -- [79] Empath
		376150, -- [80] Spiritual Clarity
		367226, -- [81] Spiritbloom
		362874, -- [82] Temporal Compression
		355936, -- [83] Dream Breath
		364343, -- [84] Echo
		366155, -- [85] Reversion
		369297, -- [86] Essence Burst
		375722, -- [87] Essence Attunement
		359793, -- [88] Fluttering Seedlings
		370062, -- [89] Field of Dreams
		373270, -- [90] Lifebind
		377099, -- [91] Spark of Insight
	},
	-- Preservation Evoker
	[1468] = {
		371032, -- [0] Terror of the Skies
		374968, -- [1] Time Spiral
		387787, -- [2] Regenerative Magic
		375561, -- [3] Lush Growth
		374348, -- [4] Renewing Blaze
		375574, -- [5] Foci of Life
		375577, -- [6] Fire Within
		374227, -- [7] Zephyr
		370888, -- [8] Twin Guardian
		387341, -- [9] Walloping Blow
		370665, -- [10] Rescue
		365933, -- [11] Aerial Mastery
		374346, -- [12] Overawe
		369909, -- [13] Protracted Talons
		369939, -- [14] Leaping Flames
		368432, -- [15] Unravel
		375507, -- [16] Roar of Exhilaration
		351338, -- [17] Quell
		375510, -- [18] Blast Furnace
		372048, -- [19] Oppressing Roar
		369459, -- [20] Source of Magic
		375544, -- [21] Tempered Scales
		369990, -- [22] Ancient Flame
		376930, -- [23] Attuned to the Dream
		374251, -- [24] Cauterizing Flame
		375406, -- [25] Obsidian Bulwark
		363916, -- [26] Obsidian Scales
		370897, -- [27] Permeating Chill
		375554, -- [28] Enkindled
		375556, -- [29] Tailwind
		375517, -- [30] Extended Flight
		387761, -- [31] Panacea
		358385, -- [32] Landslide
		369913, -- [33] Natural Convergence
		375520, -- [34] Innate Magic
		371806, -- [35] Recall
		376166, -- [36] Draconic Legacy
		370553, -- [37] Tip the Scales
		372469, -- [38] Scarlet Adaptation
		360995, -- [39] Verdant Embrace
		365585, -- [40] Expunge
		376164, -- [41] Instinctive Arcana
		375528, -- [42] Forger of Mountains
		368838, -- [43] Heavy Wingbeats
		375443, -- [44] Clobbering Sweep
		360806, -- [45] Sleep Walk
		370886, -- [46] Bountiful Bloom
		375542, -- [47] Exuberance
		377082, -- [48] Dreamwalker
		377086, -- [49] Rush of Vitality
		370960, -- [50] Emerald Communion
		377100, -- [51] Exhilarating Burst
		375783, -- [52] Font of Magic
		359816, -- [53] Dream Flight
		369908, -- [54] Power Nexus
		371257, -- [55] Renewing Breath
		381921, -- [56] Ouroboros
		376207, -- [57] Delay Harm
		376204, -- [58] Just in Time
		370537, -- [59] Stasis
		368412, -- [60] Time of Need
		376240, -- [61] Timeless Magic
		372233, -- [62] Energy Loop
		371270, -- [63] Punctuality
		376236, -- [64] Resonating Sphere
		376237, -- [65] Nozdormu's Teachings
		385696, -- [66] Flow State
		373861, -- [67] Temporal Anomaly
		363534, -- [68] Rewind
		357170, -- [69] Time Dilation
		378196, -- [70] Golden Hour
		372527, -- [71] Time Lord
		371426, -- [72] Life-Giver's Flame
		376179, -- [73] Lifeforce Mender
		373834, -- [74] Call of Ysera
		376210, -- [75] Erasure
		381922, -- [76] Temporal Artificer
		376239, -- [77] Grace Period
		371832, -- [78] Cycle of Life
		376138, -- [79] Empath
		376150, -- [80] Spiritual Clarity
		367226, -- [81] Spiritbloom
		362874, -- [82] Temporal Compression
		355936, -- [83] Dream Breath
		364343, -- [84] Echo
		366155, -- [85] Reversion
		369297, -- [86] Essence Burst
		375722, -- [87] Essence Attunement
		359793, -- [88] Fluttering Seedlings
		370062, -- [89] Field of Dreams
		373270, -- [90] Lifebind
		377099, -- [91] Spark of Insight
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
		[1] = { 1204, 1206, 811, 5523, 812, 813, 1218, 806, 809, 5433, 810, 805, }, -- Mortal Dance, Cover of Darkness, Rain from Above, Sigil Mastery, Detainment, Glimpse, Unending Hatred, Reverse Magic, Chaotic Imprint, Blood Moon, Demonic Origins, Cleansed by Flame
		[2] = { 1204, 1206, 811, 5523, 812, 813, 1218, 806, 809, 5433, 810, 805, }, -- Mortal Dance, Cover of Darkness, Rain from Above, Sigil Mastery, Detainment, Glimpse, Unending Hatred, Reverse Magic, Chaotic Imprint, Blood Moon, Demonic Origins, Cleansed by Flame
		[3] = { 1204, 1206, 811, 5523, 812, 813, 1218, 806, 809, 5433, 810, 805, }, -- Mortal Dance, Cover of Darkness, Rain from Above, Sigil Mastery, Detainment, Glimpse, Unending Hatred, Reverse Magic, Chaotic Imprint, Blood Moon, Demonic Origins, Cleansed by Flame
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
