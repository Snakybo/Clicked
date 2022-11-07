local LibTalentInfo = LibStub and LibStub("LibTalentInfo-1.0", true)
local version = 46658

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
		30449, -- [0] Spellsteal
		382440, -- [1] Shifting Power
		205036, -- [2] Ice Ward
		386763, -- [3] Freezing Cold
		113724, -- [4] Ring of Frost
		389627, -- [5] Volatile Detonation
		153561, -- [6] Meteor
		31661, -- [7] Dragon's Breath
		389713, -- [8] Displacement
		382800, -- [9] Accumulative Shielding
		383243, -- [10] Time Anomaly
		386539, -- [11] Temporal Warp
		110959, -- [12] Greater Invisibility
		382268, -- [13] Flow of Time
		31589, -- [14] Slow
		382490, -- [15] Tome of Antonidas
		382826, -- [16] Temporal Velocity
		386828, -- [17] Energized Barriers
		382270, -- [18] Diverted Energy
		342249, -- [19] Master of Time
		157981, -- [20] Blast Wave
		382297, -- [21] Quick Witted
		212653, -- [22] Shimmer
		108839, -- [23] Ice Floes
		383121, -- [24] Mass Polymorph
		382292, -- [25] Cryo-Freeze
		343183, -- [26] Improved Frost Nova
		391102, -- [27] Mass Slow
		382481, -- [28] Rigid Ice
		382289, -- [29] Tempest Barrier
		382293, -- [30] Incantation of Swiftness
		1463, -- [31] Incanter's Flow
		116011, -- [32] Rune of Power
		383092, -- [33] Arcane Warding
		342245, -- [34] Alter Time
		475, -- [35] Remove Curse
		66, -- [36] Invisibility
		390218, -- [37] Overflowing Energy
		235450, -- [38] Prismatic Barrier
		45438, -- [39] Ice Block
		382424, -- [40] Winter's Protection
		55342, -- [41] Mirror Image
		382569, -- [42] Reduplication
		382820, -- [43] Reabsorption
		157997, -- [44] Ice Nova
		382493, -- [45] Tome of Rhonin
		235224, -- [46] Frigid Winds
		387807, -- [47] Time Manipulation
		321739, -- [48] Arcane Power
		342231, -- [49] Arcane Echo
		759, -- [50] Conjure Mana Gem
		384276, -- [51] Cascading Power
		384374, -- [52] Concentration
		384452, -- [53] Arcane Harmony
		384858, -- [54] Orb Barrage
		384612, -- [55] Prodigious Savant
		281482, -- [56] Reverberate
		114923, -- [57] Nether Tempest
		205028, -- [58] Resonance
		231564, -- [59] Arcing Cleave
		235711, -- [60] Chrono Shift
		384861, -- [61] Foresight
		321387, -- [62] Enlightened
		383980, -- [63] Arcane Tempo
		264354, -- [64] Rule of Threes
		205022, -- [65] Arcane Familiar
		205025, -- [66] Presence of Mind
		12051, -- [67] Evocation
		384187, -- [68] Siphon Storm
		157980, -- [69] Supernova
		383676, -- [70] Impetus
		384060, -- [71] Illuminated Thoughts
		321420, -- [72] Improved Clearcasting
		236628, -- [73] Amplification
		383782, -- [74] Nether Precision
		236457, -- [75] Slipstream
		321752, -- [76] Crackling Energy
		79684, -- [77] Clearcasting
		365350, -- [78] Arcane Surge
		321526, -- [79] Mana Adept
		321745, -- [80] Improved Prismatic Barrier
		321507, -- [81] Touch of the Magi
		384581, -- [82] Arcane Bombardment
		376103, -- [83] Radiant Spark
		384683, -- [84] Harmonic Echo
		44425, -- [85] Arcane Barrage
		5143, -- [86] Arcane Missiles
		153626, -- [87] Arcane Orb
		383661, -- [88] Improved Arcane Missiles
		384651, -- [89] Charged Orb
	},
	-- Fire Mage
	[63] = {
		205026, -- [0] Firestarter
		30449, -- [1] Spellsteal
		382440, -- [2] Shifting Power
		205036, -- [3] Ice Ward
		386763, -- [4] Freezing Cold
		113724, -- [5] Ring of Frost
		389627, -- [6] Volatile Detonation
		153561, -- [7] Meteor
		31661, -- [8] Dragon's Breath
		389713, -- [9] Displacement
		382800, -- [10] Accumulative Shielding
		383243, -- [11] Time Anomaly
		386539, -- [12] Temporal Warp
		110959, -- [13] Greater Invisibility
		382268, -- [14] Flow of Time
		31589, -- [15] Slow
		382490, -- [16] Tome of Antonidas
		382826, -- [17] Temporal Velocity
		386828, -- [18] Energized Barriers
		382270, -- [19] Diverted Energy
		342249, -- [20] Master of Time
		157981, -- [21] Blast Wave
		382297, -- [22] Quick Witted
		212653, -- [23] Shimmer
		108839, -- [24] Ice Floes
		383121, -- [25] Mass Polymorph
		382292, -- [26] Cryo-Freeze
		343183, -- [27] Improved Frost Nova
		391102, -- [28] Mass Slow
		382481, -- [29] Rigid Ice
		382289, -- [30] Tempest Barrier
		382293, -- [31] Incantation of Swiftness
		1463, -- [32] Incanter's Flow
		116011, -- [33] Rune of Power
		383092, -- [34] Arcane Warding
		342245, -- [35] Alter Time
		475, -- [36] Remove Curse
		66, -- [37] Invisibility
		235313, -- [38] Blazing Barrier
		390218, -- [39] Overflowing Energy
		45438, -- [40] Ice Block
		382424, -- [41] Winter's Protection
		55342, -- [42] Mirror Image
		382569, -- [43] Reduplication
		382820, -- [44] Reabsorption
		157997, -- [45] Ice Nova
		382493, -- [46] Tome of Rhonin
		235224, -- [47] Frigid Winds
		387807, -- [48] Time Manipulation
		383860, -- [49] Hyperthermia
		383810, -- [50] Fevered Incantation
		205023, -- [51] Conflagration
		383665, -- [52] Incendiary Eruptions
		205029, -- [53] Flame On
		343230, -- [54] Improved Flamestrike
		2120, -- [55] Flamestrike
		205037, -- [56] Flame Patch
		44457, -- [57] Living Bomb
		383391, -- [58] Feel the Burn
		384174, -- [59] Master of Flame
		205020, -- [60] Pyromaniac
		384033, -- [61] Firefall
		155148, -- [62] Kindling
		383476, -- [63] Phoenix Reborn
		203275, -- [64] Flame Accelerant
		383967, -- [65] Improved Combustion
		383659, -- [66] Tempered Flames
		383489, -- [67] Wildfire
		383634, -- [68] Fiery Rush
		383669, -- [69] Controlled Destruction
		383886, -- [70] Sun King's Blessing
		86949, -- [71] Cauterize
		190319, -- [72] Combustion
		383499, -- [73] Firemind
		269650, -- [74] Pyroclasm
		343222, -- [75] Call of the Sun King
		383604, -- [76] Improved Scorch
		269644, -- [77] Searing Touch
		2948, -- [78] Scorch
		108853, -- [79] Fire Blast
		11366, -- [80] Pyroblast
		387044, -- [81] Fervent Flickering
		257541, -- [82] Phoenix Flames
		157642, -- [83] Pyrotechnics
		117216, -- [84] Critical Mass
		342344, -- [85] From the Ashes
		235870, -- [86] Alexstrasza's Fury
	},
	-- Frost Mage
	[64] = {
		30449, -- [0] Spellsteal
		382440, -- [1] Shifting Power
		205036, -- [2] Ice Ward
		386763, -- [3] Freezing Cold
		113724, -- [4] Ring of Frost
		389627, -- [5] Volatile Detonation
		153561, -- [6] Meteor
		31661, -- [7] Dragon's Breath
		389713, -- [8] Displacement
		382800, -- [9] Accumulative Shielding
		383243, -- [10] Time Anomaly
		386539, -- [11] Temporal Warp
		110959, -- [12] Greater Invisibility
		382268, -- [13] Flow of Time
		31589, -- [14] Slow
		382490, -- [15] Tome of Antonidas
		382826, -- [16] Temporal Velocity
		386828, -- [17] Energized Barriers
		382270, -- [18] Diverted Energy
		342249, -- [19] Master of Time
		157981, -- [20] Blast Wave
		382297, -- [21] Quick Witted
		212653, -- [22] Shimmer
		108839, -- [23] Ice Floes
		383121, -- [24] Mass Polymorph
		382292, -- [25] Cryo-Freeze
		343183, -- [26] Improved Frost Nova
		391102, -- [27] Mass Slow
		382481, -- [28] Rigid Ice
		382289, -- [29] Tempest Barrier
		382293, -- [30] Incantation of Swiftness
		1463, -- [31] Incanter's Flow
		116011, -- [32] Rune of Power
		383092, -- [33] Arcane Warding
		342245, -- [34] Alter Time
		475, -- [35] Remove Curse
		11426, -- [36] Ice Barrier
		66, -- [37] Invisibility
		390218, -- [38] Overflowing Energy
		45438, -- [39] Ice Block
		382424, -- [40] Winter's Protection
		55342, -- [41] Mirror Image
		382569, -- [42] Reduplication
		382820, -- [43] Reabsorption
		157997, -- [44] Ice Nova
		382493, -- [45] Tome of Rhonin
		235224, -- [46] Frigid Winds
		387807, -- [47] Time Manipulation
		270233, -- [48] Freezing Rain
		382103, -- [49] Freezing Winds
		378901, -- [50] Snap Freeze
		382144, -- [51] Slick Ice
		378433, -- [52] Icy Propulsion
		278309, -- [53] Chain Reaction
		155149, -- [54] Thermal Void
		199786, -- [55] Glacial Spike
		381244, -- [56] Hailstones
		378749, -- [57] Deep Shatter
		380154, -- [58] Subzero
		56377, -- [59] Splitting Ice
		379049, -- [60] Splintering Cold
		205021, -- [61] Ray of Frost
		112965, -- [62] Fingers of Frost
		12982, -- [63] Shatter
		378919, -- [64] Piercing Cold
		205027, -- [65] Bone Chilling
		379993, -- [66] Flash Freeze
		236662, -- [67] Ice Caller
		381706, -- [68] Snowstorm
		12472, -- [69] Icy Veins
		378406, -- [70] Wintertide
		205024, -- [71] Lonely Winter
		31687, -- [72] Summon Water Elemental
		235219, -- [73] Cold Snap
		190356, -- [74] Blizzard
		30455, -- [75] Ice Lance
		84714, -- [76] Frozen Orb
		44614, -- [77] Flurry
		190447, -- [78] Brain Freeze
		205030, -- [79] Frozen Touch
		257537, -- [80] Ebonbolt
		378198, -- [81] Perpetual Winter
		378947, -- [82] Glacial Assault
		153595, -- [83] Comet Storm
		378448, -- [84] Fractured Frost
		382110, -- [85] Cold Front
		378756, -- [86] Frostbite
		385167, -- [87] Everlasting Frost
	},
	-- Holy Paladin
	[65] = {
		393024, -- [0] Improved Cleanse
		377043, -- [1] Hallowed Ground
		24275, -- [2] Hammer of Wrath
		156910, -- [3] Beacon of Faith
		200025, -- [4] Beacon of Virtue
		20473, -- [5] Holy Shock
		387801, -- [6] Echoing Blessings
		392961, -- [7] Imbued Infusions
		148039, -- [8] Barrier of Faith
		388018, -- [9] Maraad's Dying Breath
		387814, -- [10] Untempered Dedication
		183998, -- [11] Light of the Martyr
		214202, -- [12] Rule of Law
		157047, -- [13] Saved by the Light
		387998, -- [14] Unending Light
		223306, -- [15] Bestow Faith
		85222, -- [16] Light of Dawn
		392911, -- [17] Unwavering Spirit
		200430, -- [18] Protection of Tyr
		31821, -- [19] Aura Mastery
		498, -- [20] Divine Protection
		82326, -- [21] Holy Light
		210294, -- [22] Divine Favor
		387786, -- [23] Moment of Compassion
		392902, -- [24] Resplendent Light
		387993, -- [25] Illumination
		392914, -- [26] Divine Insight
		392928, -- [27] Tirion's Devotion
		231667, -- [28] Radiant Onslaught
		387791, -- [29] Empyreal Ward
		388005, -- [30] Shining Savior
		114158, -- [31] Light's Hammer
		114165, -- [32] Holy Prism
		387808, -- [33] Divine Revelations
		375576, -- [34] Divine Toll
		387781, -- [35] Commanding Light
		392938, -- [36] Veneration
		387879, -- [37] Breaking Dawn
		200482, -- [38] Second Sunrise
		31884, -- [39] Avenging Wrath
		216331, -- [40] Avenging Crusader
		387805, -- [41] Divine Glimpse
		231642, -- [42] Tower of Radiance
		392951, -- [43] Boundless Salvation
		200652, -- [44] Tyr's Deliverance
		200474, -- [45] Power of the Silver Hand
		383388, -- [46] Relentless Inquisitor
		392907, -- [47] Inflorescence of the Sunwell
		387170, -- [48] Empyrean Legacy
		248033, -- [49] Awakening
		388007, -- [50] Blessing of Summer
		196926, -- [51] Crusader's Might
		325966, -- [52] Glimmer of Light
		387893, -- [53] Divine Resonance
		633, -- [54] Lay on Hands
		20066, -- [55] Repentance
		115750, -- [56] Blinding Light
		385633, -- [57] Auras of the Resolute
		1044, -- [58] Blessing of Freedom
		385639, -- [59] Auras of Swift Vengeance
		234299, -- [60] Fist of Justice
		96231, -- [61] Rebuke
		230332, -- [62] Cavalier
		31884, -- [63] Avenging Wrath
		384820, -- [64] Sacrifice of the Just
		384914, -- [65] Recompense
		183778, -- [66] Judgment of Light
		385515, -- [67] Holy Aegis
		377128, -- [68] Golden Path
		384897, -- [69] Seal of Mercy
		384815, -- [70] Seal of Clarity
		385414, -- [71] Afterimage
		6940, -- [72] Blessing of Sacrifice
		114154, -- [73] Unbreakable Spirit
		1022, -- [74] Blessing of Protection
		384909, -- [75] Improved Blessing of Protection
		223817, -- [76] Divine Purpose
		105809, -- [77] Holy Avenger
		385425, -- [78] Seal of Alacrity
		31884, -- [79] Avenging Wrath
		152262, -- [80] Seraphim
		385450, -- [81] Seal of Might
		385416, -- [82] Aspiration of Divinity
		385129, -- [83] Seal of Order
		385125, -- [84] Of Dusk and Dawn
		391142, -- [85] Zealot's Paragon
		385728, -- [86] Seal of the Crusader
		385427, -- [87] Obduracy
		385464, -- [88] Incandescence
		385349, -- [89] Touch of Light
		377053, -- [90] Seal of Reprisal
		10326, -- [91] Turn Evil
		376996, -- [92] Seasoned Warhorse
		377016, -- [93] Seal of the Templar
		190784, -- [94] Divine Steed
		231644, -- [95] Greater Judgment
	},
	-- Protection Paladin
	[66] = {
		53595, -- [0] Hammer of the Righteous
		204019, -- [1] Blessed Hammer
		379022, -- [2] Consecration in Flame
		385422, -- [3] Resolute Defender
		378845, -- [4] Focused Enmity
		378457, -- [5] Soaring Shield
		204023, -- [6] Crusader's Judgment
		378285, -- [7] Tyr's Enforcer
		315924, -- [8] Hand of the Protector
		393022, -- [9] Inspiring Vanguard
		204074, -- [10] Righteous Protector
		386738, -- [11] Divine Resonance
		379391, -- [12] Quickened Invocations
		379043, -- [13] Faith in the Light
		31850, -- [14] Ardent Defender
		378762, -- [15] Ferren Marcus's Fervor
		31884, -- [16] Avenging Wrath
		389539, -- [17] Sentinel
		378279, -- [18] Gift of the Golden Val'kyr
		379008, -- [19] Strength of Conviction
		393030, -- [20] Improved Holy Shield
		379021, -- [21] Sanctuary
		85043, -- [22] Grand Crusader
		378974, -- [23] Bastion of Light
		152261, -- [24] Holy Shield
		86659, -- [25] Guardian of Ancient Kings
		386653, -- [26] Bulwark of Righteous Fury
		204054, -- [27] Consecrated Ground
		393027, -- [28] Improved Lay on Hands
		393071, -- [29] Strength in Adversity
		380188, -- [30] Crusader's Resolve
		386568, -- [31] Inner Light
		280373, -- [32] Redoubt
		379017, -- [33] Faith's Armor
		375576, -- [34] Divine Toll
		387174, -- [35] Eye of Tyr
		321136, -- [36] Shining Light
		209389, -- [37] Bulwark of Order
		378425, -- [38] Uther's Counsel
		385726, -- [39] Barricade of Faith
		31935, -- [40] Avenger's Shield
		378405, -- [41] Light of the Titans
		204077, -- [42] Final Stand
		327193, -- [43] Moment of Glory
		383388, -- [44] Relentless Inquisitor
		213644, -- [45] Cleanse Toxins
		377043, -- [46] Hallowed Ground
		24275, -- [47] Hammer of Wrath
		633, -- [48] Lay on Hands
		20066, -- [49] Repentance
		115750, -- [50] Blinding Light
		385633, -- [51] Auras of the Resolute
		1044, -- [52] Blessing of Freedom
		385639, -- [53] Auras of Swift Vengeance
		234299, -- [54] Fist of Justice
		231663, -- [55] Greater Judgment
		96231, -- [56] Rebuke
		230332, -- [57] Cavalier
		31884, -- [58] Avenging Wrath
		384820, -- [59] Sacrifice of the Just
		384914, -- [60] Recompense
		183778, -- [61] Judgment of Light
		385515, -- [62] Holy Aegis
		377128, -- [63] Golden Path
		384897, -- [64] Seal of Mercy
		384815, -- [65] Seal of Clarity
		385414, -- [66] Afterimage
		6940, -- [67] Blessing of Sacrifice
		114154, -- [68] Unbreakable Spirit
		1022, -- [69] Blessing of Protection
		384909, -- [70] Improved Blessing of Protection
		223817, -- [71] Divine Purpose
		105809, -- [72] Holy Avenger
		385425, -- [73] Seal of Alacrity
		31884, -- [74] Avenging Wrath
		152262, -- [75] Seraphim
		385450, -- [76] Seal of Might
		385416, -- [77] Aspiration of Divinity
		385129, -- [78] Seal of Order
		385125, -- [79] Of Dusk and Dawn
		391142, -- [80] Zealot's Paragon
		385728, -- [81] Seal of the Crusader
		385427, -- [82] Obduracy
		385464, -- [83] Incandescence
		385349, -- [84] Touch of Light
		377053, -- [85] Seal of Reprisal
		10326, -- [86] Turn Evil
		376996, -- [87] Seasoned Warhorse
		377016, -- [88] Seal of the Templar
		190784, -- [89] Divine Steed
		393114, -- [90] Improved Ardent Defender
		204018, -- [91] Blessing of Spellwarding
	},
	-- Retribution Paladin
	[70] = {
		213644, -- [0] Cleanse Toxins
		377043, -- [1] Hallowed Ground
		24275, -- [2] Hammer of Wrath
		387170, -- [3] Empyrean Legacy
		383396, -- [4] Tempest of the Lightbringer
		383263, -- [5] Blade of Condemnation
		383314, -- [6] Vanguard's Momentum
		383328, -- [7] Final Verdict
		383274, -- [8] Templar's Vindication
		215661, -- [9] Justicar's Vengeance
		205191, -- [10] Eye for an Eye
		387640, -- [11] Sealed Verdict
		383344, -- [12] Expurgation
		386901, -- [13] Seal of Wrath
		231832, -- [14] Blade of Wrath
		383350, -- [15] Truth's Wake
		383300, -- [16] Ashes to Dust
		384052, -- [17] Radiant Decree
		255937, -- [18] Wake of Ashes
		31884, -- [19] Avenging Wrath
		231895, -- [20] Crusade
		184575, -- [21] Blade of Justice
		386967, -- [22] Holy Crusader
		383254, -- [23] Improved Crusader Strike
		53385, -- [24] Divine Storm
		383228, -- [25] Improved Judgment
		267610, -- [26] Righteous Verdict
		326732, -- [27] Empyrean Power
		383271, -- [28] Highlord's Judgment
		383876, -- [29] Boundless Judgment
		204054, -- [30] Consecrated Ground
		387479, -- [31] Sanctified Ground
		384162, -- [32] Executioner's Will
		387196, -- [33] Executioner's Wrath
		343527, -- [34] Execution Sentence
		384027, -- [35] Divine Resonance
		375576, -- [36] Divine Toll
		383388, -- [37] Relentless Inquisitor
		183218, -- [38] Hand of Hindrance
		383185, -- [39] Exorcism
		382430, -- [40] Sanctification
		383334, -- [41] Inner Grace
		382536, -- [42] Sanctify
		184662, -- [43] Shield of Vengeance
		498, -- [44] Divine Protection
		383342, -- [45] Holy Blade
		267344, -- [46] Art of War
		343721, -- [47] Final Reckoning
		383304, -- [48] Virtuous Command
		383276, -- [49] Ashes to Ashes
		85804, -- [50] Selfless Healer
		326734, -- [51] Healing Hands
		269569, -- [52] Zeal
		203316, -- [53] Fires of Justice
		382275, -- [54] Consecrated Blade
		633, -- [55] Lay on Hands
		20066, -- [56] Repentance
		115750, -- [57] Blinding Light
		385633, -- [58] Auras of the Resolute
		1044, -- [59] Blessing of Freedom
		385639, -- [60] Auras of Swift Vengeance
		234299, -- [61] Fist of Justice
		231663, -- [62] Greater Judgment
		96231, -- [63] Rebuke
		230332, -- [64] Cavalier
		31884, -- [65] Avenging Wrath
		384820, -- [66] Sacrifice of the Just
		384914, -- [67] Recompense
		183778, -- [68] Judgment of Light
		385515, -- [69] Holy Aegis
		377128, -- [70] Golden Path
		384897, -- [71] Seal of Mercy
		384815, -- [72] Seal of Clarity
		385414, -- [73] Afterimage
		6940, -- [74] Blessing of Sacrifice
		114154, -- [75] Unbreakable Spirit
		1022, -- [76] Blessing of Protection
		384909, -- [77] Improved Blessing of Protection
		223817, -- [78] Divine Purpose
		105809, -- [79] Holy Avenger
		385425, -- [80] Seal of Alacrity
		31884, -- [81] Avenging Wrath
		152262, -- [82] Seraphim
		385450, -- [83] Seal of Might
		385416, -- [84] Aspiration of Divinity
		385129, -- [85] Seal of Order
		385125, -- [86] Of Dusk and Dawn
		391142, -- [87] Zealot's Paragon
		385728, -- [88] Seal of the Crusader
		385427, -- [89] Obduracy
		385464, -- [90] Incandescence
		385349, -- [91] Touch of Light
		377053, -- [92] Seal of Reprisal
		10326, -- [93] Turn Evil
		376996, -- [94] Seasoned Warhorse
		377016, -- [95] Seal of the Templar
		190784, -- [96] Divine Steed
	},
	-- Arms Warrior
	[71] = {
		390713, -- [0] Dance of Death
		383317, -- [1] Merciless Bonegrinder
		385512, -- [2] Storm of Swords
		334779, -- [3] Collateral Damage
		260708, -- [4] Sweeping Strikes
		388807, -- [5] Storm Wall
		12294, -- [6] Mortal Strike
		7384, -- [7] Overpower
		202316, -- [8] Fervor of Battle
		316405, -- [9] Improved Execute
		29725, -- [10] Sudden Death
		383103, -- [11] Fueled by Violence
		118038, -- [12] Die by the Sword
		384361, -- [13] Bloodsurge
		316440, -- [14] Martial Prowess
		385571, -- [15] Improved Overpower
		386357, -- [16] Tide of Blood
		260643, -- [17] Skullsplitter
		184783, -- [18] Tactician
		383287, -- [19] Bloodborne
		772, -- [20] Rend
		262150, -- [21] Dreadnaught
		383219, -- [22] Exhilarating Blows
		383442, -- [23] Blunt Instruments
		262161, -- [24] Warbreaker
		248621, -- [25] In For The Kill
		385008, -- [26] Test of Might
		152278, -- [27] Anger Management
		167105, -- [28] Colossus Smash
		281001, -- [29] Massacre
		383430, -- [30] Impale
		845, -- [31] Cleave
		383293, -- [32] Reaping Swings
		390725, -- [33] Sonic Boom
		382896, -- [34] Two-Handed Weapon Specialization
		386285, -- [35] Elysian Might
		202168, -- [36] Impending Victory
		386164, -- [37] Battle Stance
		262231, -- [38] War Machine
		3411, -- [39] Intervene
		386208, -- [40] Defensive Stance
		97462, -- [41] Rallying Cry
		382310, -- [42] Inspiring Presence
		29838, -- [43] Second Wind
		384404, -- [44] Sidearm
		383115, -- [45] Concussive Blows
		390354, -- [46] Furious Blows
		107570, -- [47] Storm Bolt
		382940, -- [48] Endurance Training
		382956, -- [49] Seismic Reverberation
		384090, -- [50] Titanic Throw
		384277, -- [51] Blood and Thunder
		203201, -- [52] Crackling Thunder
		382258, -- [53] Leeching Strikes
		6544, -- [54] Heroic Leap
		382764, -- [55] Crushing Force
		384100, -- [56] Berserker Shout
		12323, -- [57] Piercing Howl
		384110, -- [58] Wrecking Throw
		64382, -- [59] Shattering Throw
		392792, -- [60] Frothing Berserker
		382549, -- [61] Pain and Gain
		382461, -- [62] Honed Reflexes
		202163, -- [63] Bounding Stride
		383762, -- [64] Bitter Immunity
		391572, -- [65] Uproar
		384969, -- [66] Thunderous Words
		384318, -- [67] Thunderous Roar
		382946, -- [68] Wild Strikes
		390138, -- [69] Blademaster's Torment
		390140, -- [70] Warlord's Torment
		107574, -- [71] Avatar
		384124, -- [72] Armored to the Teeth
		382939, -- [73] Reinforced Plates
		382260, -- [74] Fast Footwork
		18499, -- [75] Berserker Rage
		275339, -- [76] Rumbling Earth
		46968, -- [77] Shockwave
		382767, -- [78] Overwhelming Rage
		382948, -- [79] Piercing Verdict
		376079, -- [80] Spear of Bastion
		392777, -- [81] Cruel Strikes
		103827, -- [82] Double Time
		382954, -- [83] Cacophonous Roar
		275338, -- [84] Menace
		5246, -- [85] Intimidating Shout
		23920, -- [86] Spell Reflection
		386630, -- [87] Battlelord
		389308, -- [88] Deft Experience
		383154, -- [89] Bloodletting
		383703, -- [90] Fatality
		386628, -- [91] Unhinged
		390563, -- [92] Hurricane
		227847, -- [93] Bladestorm
		383338, -- [94] Valor in Victory
		385573, -- [95] Improved Mortal Strike
		389306, -- [96] Critical Thinking
		386634, -- [97] Executioner's Precision
		383292, -- [98] Juggernaut
		383341, -- [99] Sharpened Blades
		383082, -- [100] Barbaric Training
		396719, -- [101] Thunder Clap
	},
	-- Fury Warrior
	[72] = {
		384124, -- [0] Armored to the Teeth
		390725, -- [1] Sonic Boom
		386285, -- [2] Elysian Might
		386196, -- [3] Berserker Stance
		202168, -- [4] Impending Victory
		3411, -- [5] Intervene
		386208, -- [6] Defensive Stance
		97462, -- [7] Rallying Cry
		382310, -- [8] Inspiring Presence
		29838, -- [9] Second Wind
		384404, -- [10] Sidearm
		383115, -- [11] Concussive Blows
		390354, -- [12] Furious Blows
		107570, -- [13] Storm Bolt
		382956, -- [14] Seismic Reverberation
		384090, -- [15] Titanic Throw
		384277, -- [16] Blood and Thunder
		203201, -- [17] Crackling Thunder
		382258, -- [18] Leeching Strikes
		6544, -- [19] Heroic Leap
		384100, -- [20] Berserker Shout
		12323, -- [21] Piercing Howl
		382764, -- [22] Crushing Force
		215571, -- [23] Frothing Berserker
		384110, -- [24] Wrecking Throw
		64382, -- [25] Shattering Throw
		382549, -- [26] Pain and Gain
		202163, -- [27] Bounding Stride
		383762, -- [28] Bitter Immunity
		391572, -- [29] Uproar
		384969, -- [30] Thunderous Words
		384318, -- [31] Thunderous Roar
		382946, -- [32] Wild Strikes
		390123, -- [33] Berserker's Torment
		390135, -- [34] Titan's Torment
		107574, -- [35] Avatar
		391270, -- [36] Honed Reflexes
		382939, -- [37] Reinforced Plates
		382260, -- [38] Fast Footwork
		18499, -- [39] Berserker Rage
		382900, -- [40] Dual Wield Specialization
		275339, -- [41] Rumbling Earth
		46968, -- [42] Shockwave
		391997, -- [43] Endurance Training
		382767, -- [44] Overwhelming Rage
		382948, -- [45] Piercing Verdict
		376079, -- [46] Spear of Bastion
		392777, -- [47] Cruel Strikes
		103827, -- [48] Double Time
		382954, -- [49] Cacophonous Roar
		275338, -- [50] Menace
		5246, -- [51] Intimidating Shout
		23920, -- [52] Spell Reflection
		346002, -- [53] War Machine
		392936, -- [54] Wrath and Fury
		228920, -- [55] Ravager
		382953, -- [56] Storm of Steel
		390563, -- [57] Hurricane
		383854, -- [58] Improved Raging Blow
		280392, -- [59] Meat Cleaver
		23881, -- [60] Bloodthirst
		383468, -- [61] Invigorating Fury
		208154, -- [62] Warpaint
		184364, -- [63] Enraged Regeneration
		85288, -- [64] Raging Blow
		383852, -- [65] Improved Bloodthirst
		383848, -- [66] Improved Enrage
		215568, -- [67] Fresh Meat
		81099, -- [68] Single-Minded Fury
		385703, -- [69] Bloodborne
		383959, -- [70] Cold Steel, Hot Blood
		383486, -- [71] Focus in Chaos
		383885, -- [72] Vicious Contempt
		393950, -- [73] Bloodcraze
		335077, -- [74] Frenzy
		383877, -- [75] Hack and Slash
		184367, -- [76] Rampage
		392536, -- [77] Ashen Juggernaut
		206315, -- [78] Massacre
		388004, -- [79] Slaughtering Strikes
		1719, -- [80] Recklessness
		383922, -- [81] Depths of Insanity
		389603, -- [82] Unbridled Ferocity
		152278, -- [83] Anger Management
		396749, -- [84] Reckless Abandon
		383459, -- [85] Swift Strikes
		391683, -- [86] Dancing Blades
		394329, -- [87] Titanic Rage
		385059, -- [88] Odyn's Fury
		383916, -- [89] Annihilator
		388903, -- [90] Storm of Swords
		383295, -- [91] Deft Experience
		383605, -- [92] Frenzied Flurry
		388933, -- [93] Tenderize
		315720, -- [94] Onslaught
		383297, -- [95] Critical Thinking
		388049, -- [96] Raging Armaments
		12950, -- [97] Improved Whirlwind
		392931, -- [98] Cruelty
		280721, -- [99] Sudden Death
		316402, -- [100] Improved Execute
		390674, -- [101] Barbaric Training
		396719, -- [102] Thunder Clap
	},
	-- Protection Warrior
	[73] = {
		394855, -- [0] Armored to the Teeth
		393965, -- [1] Dance of Death
		386164, -- [2] Battle Stance
		394312, -- [3] Battering Ram
		280001, -- [4] Bolster
		386477, -- [5] Violent Outburst
		190456, -- [6] Ignore Pain
		386030, -- [7] Brace For Impact
		12975, -- [8] Last Stand
		6572, -- [9] Revenge
		236279, -- [10] Devastator
		384361, -- [11] Bloodsurge
		394311, -- [12] Instigate
		394062, -- [13] Rend
		384041, -- [14] Strategist
		202560, -- [15] Best Served Cold
		1160, -- [16] Demoralizing Shout
		386034, -- [17] Improved Heroic Throw
		386071, -- [18] Disrupting Shout
		385840, -- [19] Thunderlord
		1161, -- [20] Challenging Shout
		397103, -- [21] Defender's Aegis
		384072, -- [22] Impenetrable Wall
		152278, -- [23] Anger Management
		871, -- [24] Shield Wall
		386027, -- [25] Enduring Defenses
		281001, -- [26] Massacre
		202743, -- [27] Booming Voice
		386011, -- [28] Shield Specialization
		386328, -- [29] Champion's Bulwark
		385952, -- [30] Shield Charge
		384067, -- [31] Focused Vigor
		203177, -- [32] Heavy Repercussions
		202603, -- [33] Into the Fray
		385843, -- [34] Show of Force
		29725, -- [35] Sudden Death
		390725, -- [36] Sonic Boom
		386285, -- [37] Elysian Might
		382895, -- [38] One-Handed Weapon Specialization
		202168, -- [39] Impending Victory
		3411, -- [40] Intervene
		386208, -- [41] Defensive Stance
		97462, -- [42] Rallying Cry
		382310, -- [43] Inspiring Presence
		29838, -- [44] Second Wind
		384404, -- [45] Sidearm
		383115, -- [46] Concussive Blows
		390354, -- [47] Furious Blows
		107570, -- [48] Storm Bolt
		382940, -- [49] Endurance Training
		382956, -- [50] Seismic Reverberation
		384090, -- [51] Titanic Throw
		384277, -- [52] Blood and Thunder
		203201, -- [53] Crackling Thunder
		6343, -- [54] Thunder Clap
		382258, -- [55] Leeching Strikes
		316733, -- [56] War Machine
		6544, -- [57] Heroic Leap
		384100, -- [58] Berserker Shout
		12323, -- [59] Piercing Howl
		384110, -- [60] Wrecking Throw
		64382, -- [61] Shattering Throw
		382549, -- [62] Pain and Gain
		202163, -- [63] Bounding Stride
		383762, -- [64] Bitter Immunity
		391572, -- [65] Uproar
		384969, -- [66] Thunderous Words
		384318, -- [67] Thunderous Roar
		382946, -- [68] Wild Strikes
		391271, -- [69] Honed Reflexes
		394307, -- [70] Immovable Object
		275336, -- [71] Unstoppable Force
		107574, -- [72] Avatar
		382939, -- [73] Reinforced Plates
		390642, -- [74] Crushing Force
		392790, -- [75] Frothing Berserker
		382260, -- [76] Fast Footwork
		18499, -- [77] Berserker Rage
		275339, -- [78] Rumbling Earth
		46968, -- [79] Shockwave
		390675, -- [80] Barbaric Training
		382767, -- [81] Overwhelming Rage
		382948, -- [82] Piercing Verdict
		376079, -- [83] Spear of Bastion
		392777, -- [84] Cruel Strikes
		103827, -- [85] Double Time
		382954, -- [86] Cacophonous Roar
		275338, -- [87] Menace
		5246, -- [88] Intimidating Shout
		23920, -- [89] Spell Reflection
		382953, -- [90] Storm of Steel
		228920, -- [91] Ravager
		384063, -- [92] Enduring Alacrity
		202095, -- [93] Indomitable
		386394, -- [94] Battle-Scarred Veteran
		385704, -- [95] Bloodborne
		275334, -- [96] Punish
		393967, -- [97] Juggernaut
		385888, -- [98] Tough as Nails
		392966, -- [99] Spell Block
		383103, -- [100] Fueled by Violence
		384036, -- [101] Brutal Vitality
		384042, -- [102] Unnerving Focus
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
		377847, -- [48] Well-Honed Instincts
		383197, -- [49] Orbit Breaker
		202345, -- [50] Starlord
		191034, -- [51] Starfall
		393956, -- [52] Waning Twilight
		343647, -- [53] Solstice
		394058, -- [54] Astral Smolder
		392999, -- [55] Fungal Growth
		394013, -- [56] Incarnation: Chosen of Elune
		391528, -- [57] Convoke the Spirits
		394046, -- [58] Power of Goldrinn
		279620, -- [59] Twin Moons
		327541, -- [60] Aetherial Kindling
		205636, -- [61] Force of Nature
		202918, -- [62] Light of the Sun
		114107, -- [63] Soul of the Forest
		394121, -- [64] Radiant Moonlight
		394048, -- [65] Balance of All Things
		194223, -- [66] Celestial Alignment
		393760, -- [67] Umbral Embrace
		394094, -- [68] Sundered Firmament
		394065, -- [69] Denizen of the Dream
		383195, -- [70] Umbral Intensity
		88747, -- [71] Wild Mushroom
		390378, -- [72] Orbital Strike
		393960, -- [73] Primordial Arcanic Pulsar
		393958, -- [74] Nature's Grace
		79577, -- [75] Eclipse
		274281, -- [76] New Moon
		202770, -- [77] Fury of Elune
		202342, -- [78] Shooting Stars
		202430, -- [79] Nature's Balance
		391969, -- [80] Circle of Life and Death
		393991, -- [81] Elune's Guidance
		394115, -- [82] Stellar Innervation
		78675, -- [83] Solar Beam
		393868, -- [84] Lunar Shrapnel
		202425, -- [85] Warrior of Elune
		394081, -- [86] Friend of the Fae
		202359, -- [87] Astral Communion
		393940, -- [88] Starweaver
		393954, -- [89] Rattle the Stars
		202347, -- [90] Stellar Flare
	},
	-- Feral Druid
	[103] = {
		391037, -- [0] Primal Claws
		391700, -- [1] Double-Clawed Rake
		155580, -- [2] Lunar Inspiration
		393771, -- [3] Relentless Predator
		391785, -- [4] Tear Open Wounds
		384668, -- [5] Berserk: Frenzy
		202028, -- [6] Brutal Slash
		390864, -- [7] Wild Slashes
		391881, -- [8] Apex Predator's Craving
		391978, -- [9] Veinripper
		391347, -- [10] Rip and Tear
		386318, -- [11] Cat's Curiosity
		391969, -- [12] Circle of Life and Death
		158476, -- [13] Soul of the Forest
		391947, -- [14] Protective Growth
		231063, -- [15] Merciless Claws
		391709, -- [16] Rampant Ferocity
		236068, -- [17] Moment of Clarity
		106951, -- [18] Berserk
		202031, -- [19] Sabertooth
		48484, -- [20] Infected Wounds
		384667, -- [21] Sudden Ambush
		391174, -- [22] Berserk: Heart of the Lion
		16974, -- [23] Predatory Swiftness
		391078, -- [24] Raging Fury
		391872, -- [25] Tiger's Tenacity
		274837, -- [26] Feral Frenzy
		391972, -- [27] Lion's Strength
		319439, -- [28] Bloodtalons
		390902, -- [29] Carnivorous Instinct
		391951, -- [30] Unbridled Swarm
		391888, -- [31] Adaptive Swarm
		391548, -- [32] Ashamane's Guidance
		102543, -- [33] Incarnation: Avatar of Ashamane
		391528, -- [34] Convoke the Spirits
		391875, -- [35] Frantic Momentum
		61336, -- [36] Survival Instincts
		391045, -- [37] Dreadful Bleeding
		384665, -- [38] Taste for Blood
		390772, -- [39] Pouncing Strikes
		285381, -- [40] Primal Wrath
		383352, -- [41] Tireless Energy
		202021, -- [42] Predator
		16864, -- [43] Omen of Clarity
		5217, -- [44] Tiger's Fury
		377801, -- [45] Tireless Pursuit
		102401, -- [46] Wild Charge
		252216, -- [47] Tiger Dash
		1822, -- [48] Rake
		197626, -- [49] Starsurge
		2782, -- [50] Remove Corruption
		377796, -- [51] Natural Recovery
		231050, -- [52] Improved Sunfire
		93402, -- [53] Sunfire
		132469, -- [54] Typhoon
		197524, -- [55] Astral Influence
		2637, -- [56] Hibernate
		33786, -- [57] Cyclone
		33873, -- [58] Nurturing Instinct
		18562, -- [59] Swiftmend
		774, -- [60] Rejuvenation
		301768, -- [61] Verdant Heart
		327993, -- [62] Improved Barkskin
		22842, -- [63] Frenzied Regeneration
		22570, -- [64] Maim
		1079, -- [65] Rip
		106832, -- [66] Thrash
		106839, -- [67] Skull Bash
		108299, -- [68] Killer Instinct
		213764, -- [69] Swipe
		192081, -- [70] Ironfur
		16931, -- [71] Thick Hide
		2908, -- [72] Soothe
		288826, -- [73] Improved Stampeding Roar
		319454, -- [74] Heart of the Wild
		108238, -- [75] Renewal
		378988, -- [76] Lycara's Teachings
		106898, -- [77] Stampeding Roar
		377842, -- [78] Ursine Vigor
		385786, -- [79] Matted Fur
		99, -- [80] Incapacitating Roar
		5211, -- [81] Mighty Bash
		159286, -- [82] Primal Fury
		131768, -- [83] Feline Swiftness
		231040, -- [84] Improved Rejuvenation
		48438, -- [85] Wild Growth
		102359, -- [86] Mass Entanglement
		102793, -- [87] Ursol's Vortex
		29166, -- [88] Innervate
		124974, -- [89] Nature's Vigil
		378986, -- [90] Protector of the Pack
		377847, -- [91] Well-Honed Instincts
		197628, -- [92] Starfire
		197625, -- [93] Moonkin Form
	},
	-- Guardian Druid
	[104] = {
		377835, -- [0] Front of the Pack
		210706, -- [1] Gore
		6807, -- [2] Maul
		328767, -- [3] Improved Survival Instincts
		61336, -- [4] Survival Instincts
		393611, -- [5] Ursoc's Endurance
		231064, -- [6] Mangle
		200854, -- [7] Gory Fur
		135288, -- [8] Tooth and Claw
		370586, -- [9] Elune's Favored
		393414, -- [10] Ursoc's Guidance
		102558, -- [11] Incarnation: Guardian of Ursoc
		391528, -- [12] Convoke the Spirits
		391969, -- [13] Circle of Life and Death
		370695, -- [14] Fury of Nature
		393618, -- [15] Reinforced Fur
		371905, -- [16] After the Wildfire
		155578, -- [17] Guardian of Elune
		200851, -- [18] Rage of the Sleeper
		203962, -- [19] Blood Frenzy
		203965, -- [20] Survival of the Fittest
		50334, -- [21] Berserk
		372567, -- [22] Twin Moonfire
		238049, -- [23] Scintillating Moonlight
		203964, -- [24] Galactic Guardian
		384721, -- [25] Layered Mane
		50334, -- [26] Berserk
		300346, -- [27] Ursine Adept
		377210, -- [28] Ursoc's Fury
		204053, -- [29] Rend and Tear
		372943, -- [30] Untamed Savagery
		80313, -- [31] Pulverize
		372945, -- [32] Reinvigoration
		50334, -- [33] Berserk
		203974, -- [34] Earthwarden
		393427, -- [35] Flashing Claws
		371999, -- [36] Vicious Cycle
		372618, -- [37] Vulnerable Flesh
		377811, -- [38] Innate Resolve
		203953, -- [39] Brambles
		155835, -- [40] Bristling Fur
		345208, -- [41] Infected Wounds
		377801, -- [42] Tireless Pursuit
		102401, -- [43] Wild Charge
		252216, -- [44] Tiger Dash
		1822, -- [45] Rake
		197626, -- [46] Starsurge
		377796, -- [47] Natural Recovery
		231050, -- [48] Improved Sunfire
		93402, -- [49] Sunfire
		132469, -- [50] Typhoon
		197524, -- [51] Astral Influence
		2637, -- [52] Hibernate
		33786, -- [53] Cyclone
		33873, -- [54] Nurturing Instinct
		2782, -- [55] Remove Corruption
		18562, -- [56] Swiftmend
		774, -- [57] Rejuvenation
		301768, -- [58] Verdant Heart
		327993, -- [59] Improved Barkskin
		22842, -- [60] Frenzied Regeneration
		22570, -- [61] Maim
		1079, -- [62] Rip
		106832, -- [63] Thrash
		106839, -- [64] Skull Bash
		108299, -- [65] Killer Instinct
		213764, -- [66] Swipe
		192081, -- [67] Ironfur
		16931, -- [68] Thick Hide
		2908, -- [69] Soothe
		288826, -- [70] Improved Stampeding Roar
		319454, -- [71] Heart of the Wild
		108238, -- [72] Renewal
		378988, -- [73] Lycara's Teachings
		106898, -- [74] Stampeding Roar
		377842, -- [75] Ursine Vigor
		385786, -- [76] Matted Fur
		99, -- [77] Incapacitating Roar
		5211, -- [78] Mighty Bash
		159286, -- [79] Primal Fury
		131768, -- [80] Feline Swiftness
		231040, -- [81] Improved Rejuvenation
		48438, -- [82] Wild Growth
		102359, -- [83] Mass Entanglement
		102793, -- [84] Ursol's Vortex
		29166, -- [85] Innervate
		124974, -- [86] Nature's Vigil
		378986, -- [87] Protector of the Pack
		377847, -- [88] Well-Honed Instincts
		197628, -- [89] Starfire
		197625, -- [90] Moonkin Form
		158477, -- [91] Soul of the Forest
		372119, -- [92] Dream of Cenarius
	},
	-- Restoration Druid
	[105] = {
		50464, -- [0] Nourish
		392301, -- [1] Undergrowth
		328025, -- [2] Improved Wild Growth
		392221, -- [3] Waking Dream
		383192, -- [4] Grove Tending
		145108, -- [5] Ysera's Gift
		33763, -- [6] Lifebloom
		132158, -- [7] Nature's Swiftness
		392288, -- [8] Nature's Splendor
		382550, -- [9] Passing Seasons
		207383, -- [10] Abundance
		102351, -- [11] Cenarion Ward
		197073, -- [12] Inner Peace
		392162, -- [13] Dreamstate
		740, -- [14] Tranquility
		231032, -- [15] Improved Regrowth
		200390, -- [16] Cultivation
		145205, -- [17] Efflorescence
		278515, -- [18] Rampant Growth
		158478, -- [19] Soul of the Forest
		392325, -- [20] Verdancy
		207385, -- [21] Spring Blossoms
		203651, -- [22] Overgrowth
		383191, -- [23] Regenesis
		393371, -- [24] Cenarius' Guidance
		33891, -- [25] Incarnation: Tree of Life
		391528, -- [26] Convoke the Spirits
		392256, -- [27] Harmonious Blooming
		391951, -- [28] Unbridled Swarm
		391888, -- [29] Adaptive Swarm
		392315, -- [30] Luxuriant Soil
		392356, -- [31] Reforestation
		392124, -- [32] Embrace of the Dream
		155675, -- [33] Germination
		392167, -- [34] Budding Leaves
		274902, -- [35] Photosynthesis
		391969, -- [36] Circle of Life and Death
		392116, -- [37] Regenerative Heartwood
		392099, -- [38] Nurturing Dormancy
		392302, -- [39] Power of the Archdruid
		392160, -- [40] Invigorate
		326228, -- [41] Natural Wisdom
		392410, -- [42] Verdant Infusion
		197721, -- [43] Flourish
		382559, -- [44] Unstoppable Growth
		197061, -- [45] Stonebark
		382552, -- [46] Improved Ironbark
		102342, -- [47] Ironbark
		392220, -- [48] Flash of Clarity
		113043, -- [49] Omen of Clarity
		377801, -- [50] Tireless Pursuit
		102401, -- [51] Wild Charge
		252216, -- [52] Tiger Dash
		1822, -- [53] Rake
		197626, -- [54] Starsurge
		392378, -- [55] Improved Nature's Cure
		377796, -- [56] Natural Recovery
		231050, -- [57] Improved Sunfire
		93402, -- [58] Sunfire
		132469, -- [59] Typhoon
		197524, -- [60] Astral Influence
		2637, -- [61] Hibernate
		33786, -- [62] Cyclone
		33873, -- [63] Nurturing Instinct
		18562, -- [64] Swiftmend
		774, -- [65] Rejuvenation
		301768, -- [66] Verdant Heart
		327993, -- [67] Improved Barkskin
		22842, -- [68] Frenzied Regeneration
		22570, -- [69] Maim
		1079, -- [70] Rip
		106832, -- [71] Thrash
		106839, -- [72] Skull Bash
		108299, -- [73] Killer Instinct
		213764, -- [74] Swipe
		192081, -- [75] Ironfur
		16931, -- [76] Thick Hide
		2908, -- [77] Soothe
		288826, -- [78] Improved Stampeding Roar
		319454, -- [79] Heart of the Wild
		108238, -- [80] Renewal
		378988, -- [81] Lycara's Teachings
		106898, -- [82] Stampeding Roar
		377842, -- [83] Ursine Vigor
		385786, -- [84] Matted Fur
		99, -- [85] Incapacitating Roar
		5211, -- [86] Mighty Bash
		159286, -- [87] Primal Fury
		131768, -- [88] Feline Swiftness
		231040, -- [89] Improved Rejuvenation
		48438, -- [90] Wild Growth
		102359, -- [91] Mass Entanglement
		102793, -- [92] Ursol's Vortex
		29166, -- [93] Innervate
		124974, -- [94] Nature's Vigil
		378986, -- [95] Protector of the Pack
		377847, -- [96] Well-Honed Instincts
		197628, -- [97] Starfire
		197625, -- [98] Moonkin Form
	},
	-- Blood Death Knight
	[250] = {
		391477, -- [0] Coagulopathy
		391386, -- [1] Blood Feast
		391517, -- [2] Umbilicus Eternus
		391458, -- [3] Sanguine Ground
		374715, -- [4] Improved Bone Shield
		273953, -- [5] Voracious
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
		48792, -- [47] Icebound Fortitude
		373923, -- [48] Merciless Strikes
		373930, -- [49] Proliferating Chill
		207104, -- [50] Runic Attenuation
		391566, -- [51] Insidious Chill
		374747, -- [52] Perseverance of the Ebon Blade
		391398, -- [53] Bloodshot
		374717, -- [54] Improved Heart Strike
		194844, -- [55] Bonestorm
		377640, -- [56] Shattering Bone
		377637, -- [57] Insatiable Blade
		377668, -- [58] Everlasting Bond
		377655, -- [59] Heartrend
		205723, -- [60] Red Thirst
		114556, -- [61] Purgatory
		206970, -- [62] Tightening Grasp
		221536, -- [63] Heartbreaker
		108199, -- [64] Gorefiend's Grasp
		273946, -- [65] Hemostasis
		49028, -- [66] Dancing Rune Weapon
		206940, -- [67] Mark of Blood
		219809, -- [68] Tombstone
		317133, -- [69] Improved Vampiric Blood
		194662, -- [70] Rapid Decomposition
		221699, -- [71] Blood Tap
		206931, -- [72] Blooddrinker
		274156, -- [73] Consumption
		219786, -- [74] Ossuary
		194679, -- [75] Rune Tap
		195292, -- [76] Death's Caress
		317610, -- [77] Relish in Blood
		374737, -- [78] Reinforced Bones
		377629, -- [79] Leeching Strike
		206974, -- [80] Foul Bulwark
		195182, -- [81] Marrowrend
		206930, -- [82] Heart Strike
		50842, -- [83] Blood Boil
		81136, -- [84] Crimson Scourge
		391395, -- [85] Iron Heart
		55233, -- [86] Vampiric Blood
		195679, -- [87] Bloodworms
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
		207167, -- [0] Blinding Sleet
		378848, -- [1] Coldthirst
		205727, -- [2] Anti-Magic Barrier
		373926, -- [3] Acclimation
		374383, -- [4] Assimilation
		383269, -- [5] Abomination Limb
		47568, -- [6] Empower Rune Weapon
		194878, -- [7] Icy Talons
		391571, -- [8] Gloom Ward
		343294, -- [9] Soul Reaper
		206967, -- [10] Will of the Necropolis
		374261, -- [11] Unholy Bond
		356367, -- [12] Death's Echo
		276079, -- [13] Death's Reach
		273952, -- [14] Grip of the Dead
		374265, -- [15] Unholy Ground
		111673, -- [16] Control Undead
		392566, -- [17] Enfeeble
		374504, -- [18] Brittle
		389679, -- [19] Clenching Grasp
		389682, -- [20] Unholy Endurance
		221562, -- [21] Asphyxiate
		51052, -- [22] Anti-Magic Zone
		374030, -- [23] Blood Scent
		374277, -- [24] Improved Death Strike
		48263, -- [25] Veteran of the Third War
		391546, -- [26] March of Darkness
		48707, -- [27] Anti-Magic Shell
		49998, -- [28] Death Strike
		46585, -- [29] Raise Dead
		316916, -- [30] Cleaving Strikes
		327574, -- [31] Sacrificial Pact
		374049, -- [32] Suppression
		374111, -- [33] Might of Thassarian
		48743, -- [34] Death Pact
		212552, -- [35] Wraith Walk
		374598, -- [36] Blood Draw
		374574, -- [37] Rune Mastery
		45524, -- [38] Chains of Ice
		47528, -- [39] Mind Freeze
		207200, -- [40] Permafrost
		48792, -- [41] Icebound Fortitude
		373923, -- [42] Merciless Strikes
		373930, -- [43] Proliferating Chill
		207104, -- [44] Runic Attenuation
		391566, -- [45] Insidious Chill
		390196, -- [46] Magus of the Dead
		390236, -- [47] Ruptured Viscera
		390259, -- [48] Commander of the Dead
		377440, -- [49] Unholy Aura
		207289, -- [50] Unholy Assault
		377590, -- [51] Festermight
		276837, -- [52] Army of the Damned
		377587, -- [53] Ghoulish Frenzy
		390283, -- [54] Superstrain
		390270, -- [55] Coil of Devastation
		277234, -- [56] Pestilence
		377537, -- [57] Death Rot
		390279, -- [58] Vile Contagion
		194917, -- [59] Pestilent Pustules
		207317, -- [60] Epidemic
		115989, -- [61] Unholy Blight
		377585, -- [62] Replenishing Wounds
		207264, -- [63] Bursting Sores
		207269, -- [64] Ebon Fever
		276023, -- [65] Harbinger of Doom
		49206, -- [66] Summon Gargoyle
		377514, -- [67] Reaping
		390275, -- [68] Rotten Touch
		49530, -- [69] Sudden Doom
		319230, -- [70] Unholy Pact
		152280, -- [71] Defile
		194916, -- [72] All Will Serve
		207272, -- [73] Infected Claws
		390175, -- [74] Plaguebringer
		207311, -- [75] Clawing Shadows
		377580, -- [76] Improved Death Coil
		275699, -- [77] Apocalypse
		390166, -- [78] Runic Mastery
		63560, -- [79] Dark Transformation
		46584, -- [80] Raise Dead
		85948, -- [81] Festering Strike
		55090, -- [82] Scourge Strike
		77575, -- [83] Outbreak
		316867, -- [84] Improved Festering Strike
		390161, -- [85] Feasting Strikes
		316941, -- [86] Unholy Command
		390268, -- [87] Eternal Agony
		42650, -- [88] Army of the Dead
		377592, -- [89] Morbidity
	},
	-- Beast Mastery Hunter
	[253] = {
		389882, -- [0] Serrated Shots
		390231, -- [1] Arctic Bola
		386870, -- [2] Brutal Companion
		388056, -- [3] Sentinel's Perception
		388057, -- [4] Sentinel's Protection
		388045, -- [5] Sentinel Owl
		388039, -- [6] Lone Survivor
		388042, -- [7] Nature's Endurance
		264735, -- [8] Survival of the Fittest
		231548, -- [9] Barbed Wrath
		385810, -- [10] Dire Frenzy
		384799, -- [11] Hunter's Avoidance
		53351, -- [12] Kill Shot
		273887, -- [13] Killer Instinct
		269737, -- [14] Alpha Predator
		271788, -- [15] Serpent Sting
		5116, -- [16] Concussive Shot
		19801, -- [17] Tranquilizing Shot
		162488, -- [18] Steel Trap
		385539, -- [19] Rejuvenating Wind
		19577, -- [20] Intimidation
		236776, -- [21] High Explosive Trap
		378014, -- [22] Poison Injection
		260241, -- [23] Hydra's Bite
		147362, -- [24] Counter Shot
		260309, -- [25] Master Marksman
		212431, -- [26] Explosive Shot
		120360, -- [27] Barrage
		201430, -- [28] Stampede
		375891, -- [29] Death Chakram
		2643, -- [30] Multi-Shot
		378002, -- [31] Pathfinding
		343244, -- [32] Improved Tranquilizing Shot
		321468, -- [33] Binding Shackles
		109215, -- [34] Posthaste
		378004, -- [35] Keen Eyesight
		343247, -- [36] Improved Traps
		34477, -- [37] Misdirection
		270581, -- [38] Natural Mending
		378007, -- [39] Beast Master
		1513, -- [40] Scare Beast
		187698, -- [41] Tar Trap
		343248, -- [42] Improved Kill Shot
		199921, -- [43] Trailblazer
		378010, -- [44] Improved Kill Command
		266921, -- [45] Born To Be Wild
		199483, -- [46] Camouflage
		34026, -- [47] Kill Command
		343242, -- [48] Wilderness Medicine
		213691, -- [49] Scatter Shot
		109248, -- [50] Binding Shot
		392060, -- [51] Wailing Arrow
		378740, -- [52] Killer Command
		378745, -- [53] Dire Pack
		378750, -- [54] Cobra Sting
		199530, -- [55] Stomp
		131894, -- [56] A Murder of Crows
		321530, -- [57] Bloodshed
		191384, -- [58] Aspect of the Beast
		378205, -- [59] Sharp Barbs
		378442, -- [60] Wild Instincts
		378739, -- [61] Bloody Frenzy
		267116, -- [62] Animal Companion
		378209, -- [63] Training Expert
		193455, -- [64] Cobra Shot
		193530, -- [65] Aspect of the Wild
		378210, -- [66] Hunter's Prey
		393933, -- [67] War Orders
		378743, -- [68] Dire Command
		378207, -- [69] Kill Cleave
		19574, -- [70] Bestial Wrath
		115939, -- [71] Beast Cleave
		56315, -- [72] Kindred Spirits
		321014, -- [73] Pack Tactics
		120679, -- [74] Dire Beast
		199528, -- [75] One with the Pack
		199532, -- [76] Killer Cobra
		392053, -- [77] Piercing Fangs
		389654, -- [78] Master Handler
		389660, -- [79] Snake Bite
		378244, -- [80] Cobra Senses
		257944, -- [81] Thrill of the Hunt
		193532, -- [82] Scent of Blood
		185789, -- [83] Wild Call
		359844, -- [84] Call of the Wild
		217200, -- [85] Barbed Shot
		393344, -- [86] Entrapment
	},
	-- Marksmanship Hunter
	[254] = {
		389866, -- [0] Windrunner's Barrage
		389865, -- [1] Readiness
		389882, -- [2] Serrated Shots
		390231, -- [3] Arctic Bola
		389019, -- [4] Bulletstorm
		388056, -- [5] Sentinel's Perception
		388057, -- [6] Sentinel's Protection
		388045, -- [7] Sentinel Owl
		388039, -- [8] Lone Survivor
		388042, -- [9] Nature's Endurance
		264735, -- [10] Survival of the Fittest
		384791, -- [11] Salvo
		384790, -- [12] Razor Fragments
		384799, -- [13] Hunter's Avoidance
		53351, -- [14] Kill Shot
		147362, -- [15] Counter Shot
		34026, -- [16] Kill Command
		257620, -- [17] Multi-Shot
		155228, -- [18] Lone Wolf
		186387, -- [19] Bursting Shot
		19434, -- [20] Aimed Shot
		260402, -- [21] Double Tap
		257621, -- [22] Trick Shots
		204089, -- [23] Bullseye
		260240, -- [24] Precise Shots
		378771, -- [25] Quick Load
		260228, -- [26] Careful Aim
		257044, -- [27] Rapid Fire
		378888, -- [28] Serpentstalker's Trickery
		288613, -- [29] Trueshot
		378769, -- [30] Deathblow
		194595, -- [31] Lock and Load
		392060, -- [32] Wailing Arrow
		321287, -- [33] Target Practice
		378907, -- [34] Sharpshooter
		378766, -- [35] Hunter's Knowledge
		378880, -- [36] Bombardment
		260243, -- [37] Volley
		193533, -- [38] Steady Focus
		321460, -- [39] Deadeye
		260367, -- [40] Streamline
		378905, -- [41] Windrunner's Guidance
		321293, -- [42] Crack Shot
		378767, -- [43] Focused Aim
		260393, -- [44] Lethal Shots
		391559, -- [45] Surging Shots
		321018, -- [46] Improved Steady Shot
		190852, -- [47] Legacy of the Windrunners
		378765, -- [48] Killer Accuracy
		389449, -- [49] Eagletalon's True Focus
		260404, -- [50] Calling the Shots
		386878, -- [51] Unerring Vision
		378910, -- [52] Heavy Ammo
		378913, -- [53] Light Ammo
		273887, -- [54] Killer Instinct
		269737, -- [55] Alpha Predator
		271788, -- [56] Serpent Sting
		5116, -- [57] Concussive Shot
		19801, -- [58] Tranquilizing Shot
		162488, -- [59] Steel Trap
		385539, -- [60] Rejuvenating Wind
		19577, -- [61] Intimidation
		236776, -- [62] High Explosive Trap
		378014, -- [63] Poison Injection
		260241, -- [64] Hydra's Bite
		260309, -- [65] Master Marksman
		212431, -- [66] Explosive Shot
		120360, -- [67] Barrage
		342049, -- [68] Chimaera Shot
		201430, -- [69] Stampede
		375891, -- [70] Death Chakram
		378002, -- [71] Pathfinding
		343244, -- [72] Improved Tranquilizing Shot
		321468, -- [73] Binding Shackles
		109215, -- [74] Posthaste
		378004, -- [75] Keen Eyesight
		343247, -- [76] Improved Traps
		34477, -- [77] Misdirection
		270581, -- [78] Natural Mending
		378007, -- [79] Beast Master
		1513, -- [80] Scare Beast
		187698, -- [81] Tar Trap
		343248, -- [82] Improved Kill Shot
		199921, -- [83] Trailblazer
		378010, -- [84] Improved Kill Command
		266921, -- [85] Born To Be Wild
		199483, -- [86] Camouflage
		343242, -- [87] Wilderness Medicine
		213691, -- [88] Scatter Shot
		109248, -- [89] Binding Shot
		393344, -- [90] Entrapment
	},
	-- Survival Hunter
	[255] = {
		389882, -- [0] Serrated Shots
		390231, -- [1] Arctic Bola
		388056, -- [2] Sentinel's Perception
		388057, -- [3] Sentinel's Protection
		388045, -- [4] Sentinel Owl
		388039, -- [5] Lone Survivor
		388042, -- [6] Nature's Endurance
		264735, -- [7] Survival of the Fittest
		385739, -- [8] Coordinated Kill
		385695, -- [9] Ranger
		268501, -- [10] Viper's Venom
		385709, -- [11] Intense Focus
		385737, -- [12] Bloody Claws
		385718, -- [13] Ruthless Marauder
		384799, -- [14] Hunter's Avoidance
		320976, -- [15] Kill Shot
		187707, -- [16] Muzzle
		259489, -- [17] Kill Command
		269751, -- [18] Flanking Strike
		190925, -- [19] Harpoon
		378948, -- [20] Sharp Edges
		294029, -- [21] Frenzy Strikes
		378916, -- [22] Ferocity
		378934, -- [23] Lunge
		186270, -- [24] Raptor Strike
		187708, -- [25] Carve
		212436, -- [26] Butchery
		260285, -- [27] Tip of the Spear
		321290, -- [28] Improved Wildfire Bomb
		378951, -- [29] Tactical Advantage
		203415, -- [30] Fury of the Eagle
		378953, -- [31] Spear Focus
		378955, -- [32] Killer Companion
		378961, -- [33] Energetic Ally
		378950, -- [34] Sweeping Spear
		186289, -- [35] Aspect of the Eagle
		378937, -- [36] Explosives Expert
		260248, -- [37] Bloodseeker
		263186, -- [38] Flanker's Advantage
		259387, -- [39] Mongoose Bite
		265895, -- [40] Terms of Engagement
		259495, -- [41] Wildfire Bomb
		260331, -- [42] Birds of Prey
		389880, -- [43] Bombardier
		360952, -- [44] Coordinated Assault
		360966, -- [45] Spearhead
		264332, -- [46] Guerrilla Tactics
		378940, -- [47] Quick Shot
		378962, -- [48] Deadly Duo
		271014, -- [49] Wildfire Infusion
		273887, -- [50] Killer Instinct
		269737, -- [51] Alpha Predator
		271788, -- [52] Serpent Sting
		5116, -- [53] Concussive Shot
		19801, -- [54] Tranquilizing Shot
		162488, -- [55] Steel Trap
		385539, -- [56] Rejuvenating Wind
		19577, -- [57] Intimidation
		236776, -- [58] High Explosive Trap
		378014, -- [59] Poison Injection
		260241, -- [60] Hydra's Bite
		260309, -- [61] Master Marksman
		212431, -- [62] Explosive Shot
		120360, -- [63] Barrage
		201430, -- [64] Stampede
		375891, -- [65] Death Chakram
		378002, -- [66] Pathfinding
		343244, -- [67] Improved Tranquilizing Shot
		321468, -- [68] Binding Shackles
		109215, -- [69] Posthaste
		378004, -- [70] Keen Eyesight
		343247, -- [71] Improved Traps
		34477, -- [72] Misdirection
		270581, -- [73] Natural Mending
		378007, -- [74] Beast Master
		1513, -- [75] Scare Beast
		187698, -- [76] Tar Trap
		343248, -- [77] Improved Kill Shot
		199921, -- [78] Trailblazer
		378010, -- [79] Improved Kill Command
		266921, -- [80] Born To Be Wild
		199483, -- [81] Camouflage
		343242, -- [82] Wilderness Medicine
		213691, -- [83] Scatter Shot
		109248, -- [84] Binding Shot
		393344, -- [85] Entrapment
	},
	-- Discipline Priest
	[256] = {
		108942, -- [0] Phantasm
		62618, -- [1] Power Word: Barrier
		373003, -- [2] Revel in Purity
		238063, -- [3] Lenience
		246287, -- [4] Evangelism
		215768, -- [5] Blaze of Light
		390786, -- [6] Weal and Woe
		390770, -- [7] Void Summoner
		390705, -- [8] Twilight Equilibrium
		373180, -- [9] Harsh Discipline
		390781, -- [10] Wrath Unleashed
		390765, -- [11] Resplendent Light
		373178, -- [12] Light's Wrath
		373042, -- [13] Exaltation
		373049, -- [14] Indemnity
		193134, -- [15] Castigation
		390689, -- [16] Pain and Suffering
		214621, -- [17] Schism
		372969, -- [18] Malicious Intent
		314867, -- [19] Shadow Covenant
		372985, -- [20] Embrace Shadow
		373065, -- [21] Twilight Corruption
		373054, -- [22] Stolen Psyche
		123040, -- [23] Mindbender
		390832, -- [24] Expiation
		373427, -- [25] Inescapable Torment
		33206, -- [26] Pain Suppression
		372991, -- [27] Pain Transformation
		373035, -- [28] Protector of the Frail
		197045, -- [29] Shield Discipline
		129250, -- [30] Power Word: Solace
		204197, -- [31] Purge the Wicked
		390684, -- [32] Bright Pupil
		390685, -- [33] Enduring Luminescence
		322115, -- [34] Light's Promise
		194509, -- [35] Power Word: Radiance
		81749, -- [36] Atonement
		198068, -- [37] Power of the Dark Side
		372972, -- [38] Dark Indulgence
		390686, -- [39] Painful Punishment
		47536, -- [40] Rapture
		197419, -- [41] Contrition
		390691, -- [42] Borrowed Time
		390693, -- [43] Train of Thought
		47515, -- [44] Divine Aegis
		390996, -- [45] Manipulation
		391112, -- [46] Shattered Perceptions
		108968, -- [47] Void Shift
		108945, -- [48] Angelic Bulwark
		373481, -- [49] Power Word: Life
		109186, -- [50] Surge of Light
		238100, -- [51] Angel's Mercy
		368275, -- [52] Binding Heals
		373450, -- [53] Light's Inspiration
		373457, -- [54] Crystalline Reflection
		110744, -- [55] Divine Star
		120517, -- [56] Halo
		373466, -- [57] Twins of the Sun Priestess
		390972, -- [58] Twist of Fate
		373446, -- [59] Translucent Image
		390670, -- [60] Improved Fade
		375901, -- [61] Mindgames
		373223, -- [62] Tithe Evasion
		390668, -- [63] Apathy
		199855, -- [64] San'layn
		15286, -- [65] Vampiric Embrace
		280749, -- [66] Void Shield
		9484, -- [67] Shackle Undead
		10060, -- [68] Power Infusion
		196704, -- [69] Psychic Voice
		390676, -- [70] Inspiration
		373456, -- [71] Unwavering Will
		341167, -- [72] Improved Mass Dispel
		32375, -- [73] Mass Dispel
		390622, -- [74] Rhapsody
		132157, -- [75] Holy Nova
		390620, -- [76] Move with Grace
		121536, -- [77] Angelic Feather
		390632, -- [78] Improved Purify
		64129, -- [79] Body and Soul
		193063, -- [80] Protective Light
		390615, -- [81] From Darkness Comes Light
		390919, -- [82] Sheer Terror
		108920, -- [83] Void Tendrils
		377422, -- [84] Throes of Pain
		605, -- [85] Mind Control
		205364, -- [86] Dominate Mind
		321291, -- [87] Death and Madness
		32379, -- [88] Shadow Word: Death
		34433, -- [89] Shadowfiend
		393870, -- [90] Improved Flash Heal
		528, -- [91] Dispel Magic
		73325, -- [92] Leap of Faith
		139, -- [93] Renew
		33076, -- [94] Prayer of Mending
		372354, -- [95] Focused Mending
		390667, -- [96] Spell Warding
		390767, -- [97] Blessed Recovery
		377438, -- [98] Words of the Pious
		238135, -- [99] Aegis of Wrath
		391079, -- [100] Make Amends
	},
	-- Holy Priest
	[257] = {
		392988, -- [0] Divine Image
		372760, -- [1] Divine Word
		108942, -- [2] Phantasm
		390992, -- [3] Lightweaver
		372835, -- [4] Lightwell
		372309, -- [5] Resonant Words
		235587, -- [6] Miracle Worker
		391124, -- [7] Restitution
		372611, -- [8] Searing Light
		372616, -- [9] Empyreal Blaze
		391387, -- [10] Answered Prayers
		391381, -- [11] Desperate Times
		200183, -- [12] Apotheosis
		265202, -- [13] Holy Word: Salvation
		390994, -- [14] Harmonious Apparatus
		391339, -- [15] Empowered Renew
		391368, -- [16] Rapid Recovery
		372370, -- [17] Gales of Song
		390967, -- [18] Prismatic Echoes
		391186, -- [19] Say Your Prayers
		390977, -- [20] Prayers of the Virtuous
		64901, -- [21] Symbol of Hope
		193155, -- [22] Enlightenment
		200199, -- [23] Censure
		341997, -- [24] Renewed Faith
		64843, -- [25] Divine Hymn
		391161, -- [26] Everlasting Light
		391209, -- [27] Prayerful Litany
		204883, -- [28] Circle of Healing
		321377, -- [29] Prayer Circle
		390881, -- [30] Healing Chorus
		390947, -- [31] Orison
		390954, -- [32] Crisis Management
		390980, -- [33] Pontifex
		196985, -- [34] Light of the Naaru
		238136, -- [35] Cosmic Ripple
		596, -- [36] Prayer of Healing
		34861, -- [37] Holy Word: Sanctify
		391208, -- [38] Revitalizing Prayers
		196489, -- [39] Sanctified Prayers
		200128, -- [40] Trail of Light
		196707, -- [41] Afterlife
		200209, -- [42] Guardian Angel
		196437, -- [43] Guardians of the Light
		47788, -- [44] Guardian Spirit
		2050, -- [45] Holy Word: Serenity
		88625, -- [46] Holy Word: Chastise
		372307, -- [47] Burning Vehemence
		193157, -- [48] Benediction
		391154, -- [49] Holy Mending
		391233, -- [50] Divine Service
		390996, -- [51] Manipulation
		391112, -- [52] Shattered Perceptions
		108968, -- [53] Void Shift
		108945, -- [54] Angelic Bulwark
		373481, -- [55] Power Word: Life
		109186, -- [56] Surge of Light
		238100, -- [57] Angel's Mercy
		368275, -- [58] Binding Heals
		373450, -- [59] Light's Inspiration
		373457, -- [60] Crystalline Reflection
		110744, -- [61] Divine Star
		120517, -- [62] Halo
		373466, -- [63] Twins of the Sun Priestess
		390972, -- [64] Twist of Fate
		373446, -- [65] Translucent Image
		390670, -- [66] Improved Fade
		375901, -- [67] Mindgames
		373223, -- [68] Tithe Evasion
		390668, -- [69] Apathy
		199855, -- [70] San'layn
		15286, -- [71] Vampiric Embrace
		280749, -- [72] Void Shield
		9484, -- [73] Shackle Undead
		10060, -- [74] Power Infusion
		196704, -- [75] Psychic Voice
		390676, -- [76] Inspiration
		373456, -- [77] Unwavering Will
		341167, -- [78] Improved Mass Dispel
		32375, -- [79] Mass Dispel
		390622, -- [80] Rhapsody
		132157, -- [81] Holy Nova
		390620, -- [82] Move with Grace
		121536, -- [83] Angelic Feather
		390632, -- [84] Improved Purify
		64129, -- [85] Body and Soul
		193063, -- [86] Protective Light
		390615, -- [87] From Darkness Comes Light
		390919, -- [88] Sheer Terror
		108920, -- [89] Void Tendrils
		377422, -- [90] Throes of Pain
		605, -- [91] Mind Control
		205364, -- [92] Dominate Mind
		321291, -- [93] Death and Madness
		32379, -- [94] Shadow Word: Death
		34433, -- [95] Shadowfiend
		393870, -- [96] Improved Flash Heal
		528, -- [97] Dispel Magic
		73325, -- [98] Leap of Faith
		139, -- [99] Renew
		33076, -- [100] Prayer of Mending
		372354, -- [101] Focused Mending
		390667, -- [102] Spell Warding
		390767, -- [103] Blessed Recovery
		377438, -- [104] Words of the Pious
	},
	-- Shadow Priest
	[258] = {
		373280, -- [0] Idol of N'Zoth
		373310, -- [1] Idol of Y'Shaarj
		373273, -- [2] Idol of Yogg-Saron
		108942, -- [3] Phantasm
		205385, -- [4] Shadow Crash
		392507, -- [5] Deathspeaker
		391399, -- [6] Mind Flay: Insanity
		391090, -- [7] Mind Melt
		373212, -- [8] Insidious Ire
		373202, -- [9] Mind Devourer
		391235, -- [10] Encroaching Shadows
		391137, -- [11] Whispers of the Damned
		377349, -- [12] Idol of C'Thun
		373427, -- [13] Inescapable Torment
		391228, -- [14] Maddening Touch
		377387, -- [15] Puppet Master
		391296, -- [16] Harnessed Shadows
		200174, -- [17] Mindbender
		375767, -- [18] Screams of the Void
		238558, -- [19] Misery
		263346, -- [20] Dark Void
		15487, -- [21] Silence
		263716, -- [22] Last Word
		64044, -- [23] Psychic Horror
		391242, -- [24] Coalescing Shadows
		341374, -- [25] Damnation
		263165, -- [26] Void Torrent
		373221, -- [27] Malediction
		341240, -- [28] Ancient Madness
		391109, -- [29] Dark Ascension
		228260, -- [30] Void Eruption
		341273, -- [31] Unfurling Darkness
		288733, -- [32] Intangibility
		377065, -- [33] Mental Fortitude
		391095, -- [34] Dark Evangelism
		375994, -- [35] Mental Decay
		375888, -- [36] Shadowy Insight
		47585, -- [37] Dispersion
		48045, -- [38] Mind Sear
		335467, -- [39] Devouring Plague
		341491, -- [40] Shadowy Apparitions
		155271, -- [41] Auspicious Spirits
		391284, -- [42] Tormented Spirits
		73510, -- [43] Mind Spike
		162448, -- [44] Surge of Darkness
		199484, -- [45] Psychic Link
		391288, -- [46] Pain of Death
		390996, -- [47] Manipulation
		391112, -- [48] Shattered Perceptions
		108968, -- [49] Void Shift
		108945, -- [50] Angelic Bulwark
		373481, -- [51] Power Word: Life
		109186, -- [52] Surge of Light
		238100, -- [53] Angel's Mercy
		368275, -- [54] Binding Heals
		373450, -- [55] Light's Inspiration
		122121, -- [56] Divine Star
		120644, -- [57] Halo
		373457, -- [58] Crystalline Reflection
		373466, -- [59] Twins of the Sun Priestess
		390972, -- [60] Twist of Fate
		373446, -- [61] Translucent Image
		390670, -- [62] Improved Fade
		375901, -- [63] Mindgames
		373223, -- [64] Tithe Evasion
		390668, -- [65] Apathy
		199855, -- [66] San'layn
		15286, -- [67] Vampiric Embrace
		280749, -- [68] Void Shield
		9484, -- [69] Shackle Undead
		10060, -- [70] Power Infusion
		196704, -- [71] Psychic Voice
		390676, -- [72] Inspiration
		373456, -- [73] Unwavering Will
		341167, -- [74] Improved Mass Dispel
		32375, -- [75] Mass Dispel
		390622, -- [76] Rhapsody
		132157, -- [77] Holy Nova
		390620, -- [78] Move with Grace
		121536, -- [79] Angelic Feather
		213634, -- [80] Purify Disease
		64129, -- [81] Body and Soul
		193063, -- [82] Protective Light
		390615, -- [83] From Darkness Comes Light
		390919, -- [84] Sheer Terror
		108920, -- [85] Void Tendrils
		377422, -- [86] Throes of Pain
		605, -- [87] Mind Control
		205364, -- [88] Dominate Mind
		321291, -- [89] Death and Madness
		32379, -- [90] Shadow Word: Death
		34433, -- [91] Shadowfiend
		393870, -- [92] Improved Flash Heal
		528, -- [93] Dispel Magic
		73325, -- [94] Leap of Faith
		139, -- [95] Renew
		33076, -- [96] Prayer of Mending
		372354, -- [97] Focused Mending
		390667, -- [98] Spell Warding
		390767, -- [99] Blessed Recovery
		377438, -- [100] Words of the Pious
	},
	-- Assassination Rogue
	[259] = {
		381630, -- [0] Intent to Kill
		381664, -- [1] Amplifying Poison
		385408, -- [2] Sepsis
		385424, -- [3] Serrated Bone Spike
		255989, -- [4] Master Assassin
		381640, -- [5] Lethal Dose
		381626, -- [6] Bloody Mess
		392384, -- [7] Fatal Concoction
		193640, -- [8] Elaborate Planning
		319032, -- [9] Improved Shiv
		51667, -- [10] Cut to the Chase
		381629, -- [11] Thrown Precision
		381631, -- [12] Flying Daggers
		121411, -- [13] Crimson Tempest
		394983, -- [14] Lightweight Shiv
		381624, -- [15] Improved Poisons
		79134, -- [16] Venomous Wounds
		378436, -- [17] Master Poisoner
		319066, -- [18] Improved Wound Poison
		381622, -- [19] Resounding Clarity
		394332, -- [20] Reverberation
		385616, -- [21] Echoing Reprimand
		378996, -- [22] Recuperator
		2094, -- [23] Blind
		6770, -- [24] Sap
		57934, -- [25] Tricks of the Trade
		378807, -- [26] Shadowrunner
		108208, -- [27] Subterfuge
		185313, -- [28] Shadow Dance
		91023, -- [29] Find Weakness
		393970, -- [30] Soothing Darkness
		381620, -- [31] Improved Ambush
		14062, -- [32] Nightstalker
		381621, -- [33] Tight Spender
		36554, -- [34] Shadowstep
		379005, -- [35] Blackjack
		31224, -- [36] Cloak of Shadows
		5938, -- [37] Shiv
		1776, -- [38] Gouge
		1966, -- [39] Feint
		231719, -- [40] Deadened Nerves
		193546, -- [41] Iron Stomach
		378427, -- [42] Nimble Fingers
		231691, -- [43] Improved Sprint
		79008, -- [44] Elusiveness
		31230, -- [45] Cheat Death
		382245, -- [46] Cold Blood
		382238, -- [47] Lethality
		193531, -- [48] Deeper Stratagem
		137619, -- [49] Marked for Death
		193539, -- [50] Alacrity
		196924, -- [51] Acrobatic Strikes
		381619, -- [52] Thief's Versatility
		378803, -- [53] Rushed Setup
		131511, -- [54] Prey on the Weak
		381623, -- [55] Thistle Tea
		14190, -- [56] Seal Fate
		280716, -- [57] Leeching Poison
		14983, -- [58] Vigor
		381542, -- [59] Deadly Precision
		381543, -- [60] Virulent Poisons
		378813, -- [61] Fleet Footed
		5761, -- [62] Numbing Poison
		381637, -- [63] Atrophic Poison
		5277, -- [64] Evasion
		381801, -- [65] Dragon-Tempered Blades
		381797, -- [66] Dashing Scoundrel
		255544, -- [67] Poison Bomb
		381669, -- [68] Twist the Knife
		360194, -- [69] Deathmark
		381800, -- [70] Tiny Toxic Blade
		381652, -- [71] Systemic Failure
		381634, -- [72] Vicious Venoms
		152152, -- [73] Venom Rush
		381802, -- [74] Indiscriminate Carnage
		381799, -- [75] Scent of Blood
		385478, -- [76] Shrouded Suffocation
		381673, -- [77] Doomblade
		196861, -- [78] Iron Wire
		200806, -- [79] Exsanguinate
		381632, -- [80] Improved Garrote
		381627, -- [81] Internal Bleeding
		36554, -- [82] Shadowstep
		2823, -- [83] Deadly Poison
		385627, -- [84] Kingsbane
		381798, -- [85] Zoldyck Recipe
		328085, -- [86] Blindside
	},
	-- Outlaw Rogue
	[260] = {
		378436, -- [0] Master Poisoner
		319066, -- [1] Improved Wound Poison
		381622, -- [2] Resounding Clarity
		394332, -- [3] Reverberation
		385616, -- [4] Echoing Reprimand
		378996, -- [5] Recuperator
		381845, -- [6] Audacity
		381885, -- [7] Heavy Hitter
		256165, -- [8] Blinding Powder
		271877, -- [9] Blade Rush
		108216, -- [10] Dirty Tricks
		61329, -- [11] Combat Potency
		200733, -- [12] Weaponmaster
		381877, -- [13] Combat Stamina
		381988, -- [14] Swift Slasher
		354897, -- [15] Float Like a Butterfly
		381839, -- [16] Sleight of Hand
		381989, -- [17] Keep It Rolling
		381990, -- [18] Summarily Dispatched
		395422, -- [19] Improved Adrenaline Rush
		381982, -- [20] Count the Odds
		256170, -- [21] Loaded Dice
		315508, -- [22] Roll the Bones
		79096, -- [23] Restless Blades
		13750, -- [24] Adrenaline Rush
		381822, -- [25] Ambidexterity
		344363, -- [26] Riposte
		35551, -- [27] Fatal Flourish
		196938, -- [28] Quick Draw
		51690, -- [29] Killing Spree
		343142, -- [30] Dreadblades
		386823, -- [31] Greenskin's Wickers
		381846, -- [32] Fan the Hammer
		381985, -- [33] Precise Cuts
		382746, -- [34] Improved Main Gauche
		272026, -- [35] Dancing Steel
		381828, -- [36] Ace Up Your Sleeve
		235484, -- [37] Improved Between the Eyes
		381878, -- [38] Deft Maneuvers
		196922, -- [39] Hit and Run
		13877, -- [40] Blade Flurry
		383281, -- [41] Hidden Opportunity
		382742, -- [42] Take 'em by Surprise
		385408, -- [43] Sepsis
		196937, -- [44] Ghostly Strike
		381894, -- [45] Triple Threat
		394321, -- [46] Devious Stratagem
		14161, -- [47] Ruthlessness
		256188, -- [48] Retractable Hook
		195457, -- [49] Grappling Hook
		279876, -- [50] Opportunity
		2094, -- [51] Blind
		6770, -- [52] Sap
		57934, -- [53] Tricks of the Trade
		378807, -- [54] Shadowrunner
		108208, -- [55] Subterfuge
		185313, -- [56] Shadow Dance
		91023, -- [57] Find Weakness
		393970, -- [58] Soothing Darkness
		381620, -- [59] Improved Ambush
		14062, -- [60] Nightstalker
		381621, -- [61] Tight Spender
		36554, -- [62] Shadowstep
		379005, -- [63] Blackjack
		31224, -- [64] Cloak of Shadows
		5938, -- [65] Shiv
		1776, -- [66] Gouge
		1966, -- [67] Feint
		231719, -- [68] Deadened Nerves
		193546, -- [69] Iron Stomach
		378427, -- [70] Nimble Fingers
		231691, -- [71] Improved Sprint
		79008, -- [72] Elusiveness
		31230, -- [73] Cheat Death
		382245, -- [74] Cold Blood
		382238, -- [75] Lethality
		193531, -- [76] Deeper Stratagem
		137619, -- [77] Marked for Death
		193539, -- [78] Alacrity
		196924, -- [79] Acrobatic Strikes
		381619, -- [80] Thief's Versatility
		378803, -- [81] Rushed Setup
		131511, -- [82] Prey on the Weak
		381623, -- [83] Thistle Tea
		14190, -- [84] Seal Fate
		280716, -- [85] Leeching Poison
		14983, -- [86] Vigor
		381542, -- [87] Deadly Precision
		381543, -- [88] Virulent Poisons
		378813, -- [89] Fleet Footed
		5761, -- [90] Numbing Poison
		381637, -- [91] Atrophic Poison
		5277, -- [92] Evasion
	},
	-- Subtlety Rogue
	[261] = {
		378436, -- [0] Master Poisoner
		319066, -- [1] Improved Wound Poison
		381622, -- [2] Resounding Clarity
		394332, -- [3] Reverberation
		385616, -- [4] Echoing Reprimand
		378996, -- [5] Recuperator
		2094, -- [6] Blind
		6770, -- [7] Sap
		57934, -- [8] Tricks of the Trade
		378807, -- [9] Shadowrunner
		108208, -- [10] Subterfuge
		185313, -- [11] Shadow Dance
		91023, -- [12] Find Weakness
		393970, -- [13] Soothing Darkness
		381620, -- [14] Improved Ambush
		14062, -- [15] Nightstalker
		381621, -- [16] Tight Spender
		36554, -- [17] Shadowstep
		379005, -- [18] Blackjack
		31224, -- [19] Cloak of Shadows
		257505, -- [20] Shot in the Dark
		200758, -- [21] Gloomblade
		382507, -- [22] Shrouded in Darkness
		394309, -- [23] Swift Death
		382513, -- [24] Without a Trace
		382508, -- [25] Planned Execution
		385408, -- [26] Sepsis
		382015, -- [27] The Rotten
		382523, -- [28] Invigorating Shadowdust
		382518, -- [29] Perforated Veins
		382512, -- [30] Inevitability
		58423, -- [31] Relentless Strikes
		319951, -- [32] Improved Shuriken Storm
		277953, -- [33] Night Terrors
		319175, -- [34] Black Powder
		382017, -- [35] Veiltouched
		385722, -- [36] Silent Storm
		280719, -- [37] Secret Technique
		277925, -- [38] Shuriken Tornado
		382506, -- [39] Replicating Shadows
		384631, -- [40] Flagellation
		382504, -- [41] Dark Brew
		382525, -- [42] Finality
		382517, -- [43] Deeper Daggers
		394320, -- [44] Secret Stratagem
		382511, -- [45] Shadowed Finishers
		185314, -- [46] Deepening Shadows
		382509, -- [47] Stiletto Staccato
		121471, -- [48] Shadow Blades
		108209, -- [49] Shadow Focus
		382503, -- [50] Quick Decisions
		36554, -- [51] Shadowstep
		382528, -- [52] Danse Macabre
		382524, -- [53] Lingering Shadow
		245687, -- [54] Dark Shadow
		382515, -- [55] Cloaked in Shadows
		382514, -- [56] Fade to Nothing
		393972, -- [57] Improved Shadow Dance
		382505, -- [58] The First Dance
		196976, -- [59] Master of Shadows
		394023, -- [60] Improved Shadow Techniques
		343160, -- [61] Premeditation
		193537, -- [62] Weaponmaster
		319949, -- [63] Improved Backstab
		5938, -- [64] Shiv
		1776, -- [65] Gouge
		1966, -- [66] Feint
		231719, -- [67] Deadened Nerves
		193546, -- [68] Iron Stomach
		378427, -- [69] Nimble Fingers
		231691, -- [70] Improved Sprint
		79008, -- [71] Elusiveness
		31230, -- [72] Cheat Death
		382245, -- [73] Cold Blood
		382238, -- [74] Lethality
		193531, -- [75] Deeper Stratagem
		137619, -- [76] Marked for Death
		193539, -- [77] Alacrity
		196924, -- [78] Acrobatic Strikes
		381619, -- [79] Thief's Versatility
		378803, -- [80] Rushed Setup
		131511, -- [81] Prey on the Weak
		381623, -- [82] Thistle Tea
		14190, -- [83] Seal Fate
		280716, -- [84] Leeching Poison
		14983, -- [85] Vigor
		381542, -- [86] Deadly Precision
		381543, -- [87] Virulent Poisons
		378813, -- [88] Fleet Footed
		5761, -- [89] Numbing Poison
		381637, -- [90] Atrophic Poison
		5277, -- [91] Evasion
	},
	-- Elemental Shaman
	[262] = {
		386443, -- [0] Rolling Magma
		386474, -- [1] Primordial Surge
		382042, -- [2] Splintered Elements
		77756, -- [3] Lava Surge
		378211, -- [4] Refreshing Waters
		381764, -- [5] Primordial Bond
		198067, -- [6] Fire Elemental
		192249, -- [7] Storm Elemental
		378193, -- [8] Primordial Fury
		382197, -- [9] Ancestral Wolf Affinity
		60188, -- [10] Elemental Fury
		8042, -- [11] Earth Shock
		61882, -- [12] Earthquake
		381743, -- [13] Tumultuous Fissures
		378776, -- [14] Inundate
		378241, -- [15] Call of Thunder
		382685, -- [16] Unrelenting Calamity
		191634, -- [17] Stormkeeper
		381936, -- [18] Flash of Lightning
		384087, -- [19] Echoes of Great Sundering
		210689, -- [20] Lightning Rod
		191634, -- [21] Stormkeeper
		378271, -- [22] Elemental Equilibrium
		117014, -- [23] Elemental Blast
		381708, -- [24] Eye of the Storm
		381776, -- [25] Flux Melting
		382086, -- [26] Electrified Shocks
		210714, -- [27] Icefury
		385923, -- [28] Flow of Power
		333919, -- [29] Echo of the Elements
		273221, -- [30] Aftershock
		262303, -- [31] Surge of Power
		381787, -- [32] Further Beyond
		381785, -- [33] Oath of the Far Seer
		378270, -- [34] Deeply Rooted Elements
		114050, -- [35] Ascendance
		16166, -- [36] Master of the Elements
		381782, -- [37] Searing Flames
		378268, -- [38] Windspeaker's Lava Resurgence
		378310, -- [39] Skybreaker's Fiery Demise
		381932, -- [40] Magma Chamber
		117013, -- [41] Primal Elementalist
		192222, -- [42] Liquid Magma Totem
		382027, -- [43] Improved Flametongue Weapon
		378266, -- [44] Flames of the Cauldron
		378255, -- [45] Call of Fire
		381726, -- [46] Mountains Will Fall
		382032, -- [47] Echo Chamber
		375982, -- [48] Primordial Wave
		191861, -- [49] Power of the Maelstrom
		381707, -- [50] Swelling Maelstrom
		381647, -- [51] Planes Traveler
		377933, -- [52] Astral Bulwark
		108271, -- [53] Astral Shift
		381666, -- [54] Focused Insight
		382888, -- [55] Flurry
		187880, -- [56] Maelstrom Weapon
		188443, -- [57] Chain Lightning
		51505, -- [58] Lava Burst
		1064, -- [59] Chain Heal
		198103, -- [60] Earth Elemental
		192088, -- [61] Graceful Spirit
		378077, -- [62] Spiritwalker's Aegis
		79206, -- [63] Spiritwalker's Grace
		382886, -- [64] Fire and Ice
		57994, -- [65] Wind Shear
		8143, -- [66] Tremor Totem
		265046, -- [67] Static Charge
		381819, -- [68] Guardian's Cudgel
		192058, -- [69] Capacitor Totem
		260878, -- [70] Spirit Wolf
		378075, -- [71] Thunderous Paws
		196840, -- [72] Frost Shock
		51886, -- [73] Cleanse Spirit
		370, -- [74] Purge
		378773, -- [75] Greater Purge
		204268, -- [76] Voodoo Mastery
		378079, -- [77] Enfeeblement
		51514, -- [78] Hex
		108287, -- [79] Totemic Projection
		30884, -- [80] Nature's Guardian
		192077, -- [81] Wind Rush Totem
		51485, -- [82] Earthgrab Totem
		382947, -- [83] Ancestral Defense
		381650, -- [84] Elemental Warding
		381689, -- [85] Brimming with Life
		381655, -- [86] Nature's Fury
		382215, -- [87] Winds of Al'Akir
		58875, -- [88] Spirit Walk
		192063, -- [89] Gust of Wind
		381678, -- [90] Go with the Flow
		383011, -- [91] Call of the Elements
		383012, -- [92] Creation Core
		108285, -- [93] Totemic Recall
		382033, -- [94] Surging Shields
		383013, -- [95] Poison Cleansing Totem
		382201, -- [96] Totemic Focus
		383017, -- [97] Stoneskin Totem
		383019, -- [98] Tranquil Air Totem
		378779, -- [99] Thundershock
		305483, -- [100] Lightning Lasso
		51490, -- [101] Thunderstorm
		381674, -- [102] Improved Lightning Bolt
		378081, -- [103] Nature's Swiftness
		5394, -- [104] Healing Stream Totem
		378094, -- [105] Swirling Currents
		108281, -- [106] Ancestral Guidance
		381930, -- [107] Mana Spring Totem
		381867, -- [108] Totemic Surge
		383010, -- [109] Elemental Orbit
		974, -- [110] Earth Shield
	},
	-- Enhancement Shaman
	[263] = {
		393905, -- [0] Refreshing Waters
		382197, -- [1] Ancestral Wolf Affinity
		384149, -- [2] Overflowing Maelstrom
		384143, -- [3] Raging Maelstrom
		8512, -- [4] Windfury Totem
		17364, -- [5] Stormstrike
		60103, -- [6] Lava Lash
		334033, -- [7] Molten Assault
		334195, -- [8] Hailstorm
		333974, -- [9] Fire Nova
		201900, -- [10] Hot Hand
		196884, -- [11] Feral Lunge
		390370, -- [12] Ashen Catalyst
		334046, -- [13] Lashing Flames
		384444, -- [14] Thorim's Invocation
		384411, -- [15] Static Accumulation
		384450, -- [16] Legacy of the Frost Witch
		334308, -- [17] Crashing Storms
		344357, -- [18] Stormflurry
		384359, -- [19] Swirling Maelstrom
		342240, -- [20] Ice Strike
		383303, -- [21] Improved Maelstrom Weapon
		33757, -- [22] Windfury Weapon
		384352, -- [23] Doom Winds
		319930, -- [24] Stormblast
		384355, -- [25] Elemental Weapons
		210853, -- [26] Elemental Assault
		382042, -- [27] Splintered Elements
		384405, -- [28] Primal Maelstrom
		375982, -- [29] Primordial Wave
		117014, -- [30] Elemental Blast
		392352, -- [31] Storm's Wrath
		390288, -- [32] Unruly Winds
		262647, -- [33] Forceful Winds
		262624, -- [34] Elemental Spirits
		198434, -- [35] Alpha Wolf
		384447, -- [36] Witch Doctor's Ancestry
		51533, -- [37] Feral Spirit
		384363, -- [38] Converging Storms
		187874, -- [39] Crash Lightning
		197214, -- [40] Sundering
		381647, -- [41] Planes Traveler
		377933, -- [42] Astral Bulwark
		108271, -- [43] Astral Shift
		381666, -- [44] Focused Insight
		382888, -- [45] Flurry
		187880, -- [46] Maelstrom Weapon
		188443, -- [47] Chain Lightning
		51505, -- [48] Lava Burst
		1064, -- [49] Chain Heal
		198103, -- [50] Earth Elemental
		192088, -- [51] Graceful Spirit
		378077, -- [52] Spiritwalker's Aegis
		79206, -- [53] Spiritwalker's Grace
		382886, -- [54] Fire and Ice
		57994, -- [55] Wind Shear
		8143, -- [56] Tremor Totem
		265046, -- [57] Static Charge
		381819, -- [58] Guardian's Cudgel
		192058, -- [59] Capacitor Totem
		260878, -- [60] Spirit Wolf
		378075, -- [61] Thunderous Paws
		196840, -- [62] Frost Shock
		370, -- [63] Purge
		378773, -- [64] Greater Purge
		51886, -- [65] Cleanse Spirit
		204268, -- [66] Voodoo Mastery
		378079, -- [67] Enfeeblement
		51514, -- [68] Hex
		108287, -- [69] Totemic Projection
		30884, -- [70] Nature's Guardian
		192077, -- [71] Wind Rush Totem
		51485, -- [72] Earthgrab Totem
		382947, -- [73] Ancestral Defense
		381650, -- [74] Elemental Warding
		381689, -- [75] Brimming with Life
		381655, -- [76] Nature's Fury
		382215, -- [77] Winds of Al'Akir
		58875, -- [78] Spirit Walk
		192063, -- [79] Gust of Wind
		381678, -- [80] Go with the Flow
		383011, -- [81] Call of the Elements
		383012, -- [82] Creation Core
		108285, -- [83] Totemic Recall
		382033, -- [84] Surging Shields
		383013, -- [85] Poison Cleansing Totem
		382201, -- [86] Totemic Focus
		383017, -- [87] Stoneskin Totem
		383019, -- [88] Tranquil Air Totem
		378779, -- [89] Thundershock
		305483, -- [90] Lightning Lasso
		51490, -- [91] Thunderstorm
		381674, -- [92] Improved Lightning Bolt
		378081, -- [93] Nature's Swiftness
		5394, -- [94] Healing Stream Totem
		378094, -- [95] Swirling Currents
		108281, -- [96] Ancestral Guidance
		381930, -- [97] Mana Spring Totem
		381867, -- [98] Totemic Surge
		383010, -- [99] Elemental Orbit
		974, -- [100] Earth Shield
		378270, -- [101] Deeply Rooted Elements
		114051, -- [102] Ascendance
	},
	-- Restoration Shaman
	[264] = {
		207778, -- [0] Downpour
		77756, -- [1] Lava Surge
		382030, -- [2] Water Totem Mastery
		378211, -- [3] Refreshing Waters
		16166, -- [4] Master of the Elements
		280614, -- [5] Flash Flood
		51564, -- [6] Tidal Waves
		5394, -- [7] Healing Stream Totem
		378241, -- [8] Call of Thunder
		16196, -- [9] Resurgence
		52127, -- [10] Water Shield
		77472, -- [11] Healing Wave
		61295, -- [12] Riptide
		200076, -- [13] Deluge
		382197, -- [14] Ancestral Wolf Affinity
		383009, -- [15] Stormkeeper
		207401, -- [16] Ancestral Vigor
		382732, -- [17] Ancestral Reach
		382039, -- [18] Flow of the Tides
		108280, -- [19] Healing Tide Totem
		98008, -- [20] Spirit Link Totem
		382046, -- [21] Continuous Waves
		382040, -- [22] Tumbling Waves
		382191, -- [23] Improved Primordial Wave
		375982, -- [24] Primordial Wave
		200071, -- [25] Undulation
		73685, -- [26] Unleash Life
		381946, -- [27] Wavespeaker's Blessing
		383222, -- [28] Overflowing Shores
		378443, -- [29] Acid Rain
		73920, -- [30] Healing Rain
		382019, -- [31] Nature's Focus
		382045, -- [32] Primal Tide Core
		157154, -- [33] High Tide
		382309, -- [34] Ancestral Awakening
		333919, -- [35] Echo of the Elements
		16191, -- [36] Mana Tide Totem
		198838, -- [37] Earthen Wall Totem
		207399, -- [38] Ancestral Protection Totem
		200072, -- [39] Torrent
		382482, -- [40] Living Stream
		157153, -- [41] Cloudburst Totem
		382021, -- [42] Earthliving Weapon
		382315, -- [43] Improved Earthliving Weapon
		378270, -- [44] Deeply Rooted Elements
		197995, -- [45] Wellspring
		382194, -- [46] Undercurrent
		382029, -- [47] Ever-Rising Tide
		382020, -- [48] Earthen Harmony
		114052, -- [49] Ascendance
		381647, -- [50] Planes Traveler
		377933, -- [51] Astral Bulwark
		108271, -- [52] Astral Shift
		381666, -- [53] Focused Insight
		382888, -- [54] Flurry
		187880, -- [55] Maelstrom Weapon
		188443, -- [56] Chain Lightning
		51505, -- [57] Lava Burst
		1064, -- [58] Chain Heal
		198103, -- [59] Earth Elemental
		192088, -- [60] Graceful Spirit
		378077, -- [61] Spiritwalker's Aegis
		79206, -- [62] Spiritwalker's Grace
		382886, -- [63] Fire and Ice
		57994, -- [64] Wind Shear
		8143, -- [65] Tremor Totem
		265046, -- [66] Static Charge
		381819, -- [67] Guardian's Cudgel
		192058, -- [68] Capacitor Totem
		260878, -- [69] Spirit Wolf
		378075, -- [70] Thunderous Paws
		383016, -- [71] Improved Purify Spirit
		196840, -- [72] Frost Shock
		370, -- [73] Purge
		378773, -- [74] Greater Purge
		204268, -- [75] Voodoo Mastery
		378079, -- [76] Enfeeblement
		51514, -- [77] Hex
		108287, -- [78] Totemic Projection
		30884, -- [79] Nature's Guardian
		192077, -- [80] Wind Rush Totem
		51485, -- [81] Earthgrab Totem
		382947, -- [82] Ancestral Defense
		381650, -- [83] Elemental Warding
		381689, -- [84] Brimming with Life
		381655, -- [85] Nature's Fury
		382215, -- [86] Winds of Al'Akir
		58875, -- [87] Spirit Walk
		192063, -- [88] Gust of Wind
		381678, -- [89] Go with the Flow
		383011, -- [90] Call of the Elements
		383012, -- [91] Creation Core
		108285, -- [92] Totemic Recall
		382033, -- [93] Surging Shields
		383013, -- [94] Poison Cleansing Totem
		382201, -- [95] Totemic Focus
		383017, -- [96] Stoneskin Totem
		383019, -- [97] Tranquil Air Totem
		378779, -- [98] Thundershock
		305483, -- [99] Lightning Lasso
		51490, -- [100] Thunderstorm
		381674, -- [101] Improved Lightning Bolt
		378081, -- [102] Nature's Swiftness
		5394, -- [103] Healing Stream Totem
		378094, -- [104] Swirling Currents
		108281, -- [105] Ancestral Guidance
		381930, -- [106] Mana Spring Totem
		381867, -- [107] Totemic Surge
		383010, -- [108] Elemental Orbit
		974, -- [109] Earth Shield
	},
	-- Affliction Warlock
	[265] = {
		389359, -- [0] Resolute Barrier
		389623, -- [1] Gorefiend's Resolve
		389590, -- [2] Demonic Resilience
		389367, -- [3] Fel Synergy
		389576, -- [4] Profane Bargain
		389630, -- [5] Soul-Eater's Gluttony
		389761, -- [6] Malefic Affliction
		386617, -- [7] Demonic Fortitude
		215941, -- [8] Soul Conduit
		171975, -- [9] Grimoire of Synergy
		108415, -- [10] Soul Link
		386689, -- [11] Grim Feast
		386620, -- [12] Sweet Souls
		386858, -- [13] Demonic Inspiration
		386619, -- [14] Desperate Pact
		288843, -- [15] Demonic Embrace
		333889, -- [16] Fel Domination
		386113, -- [17] Fel Pact
		268358, -- [18] Demonic Circle
		328774, -- [19] Amplify Curse
		387972, -- [20] Teachings of the Satyr
		108416, -- [21] Dark Pact
		386664, -- [22] Ichor of Devils
		386686, -- [23] Frequent Donor
		385881, -- [24] Teachings of the Black Harvest
		386256, -- [25] Summon Soulkeeper
		386344, -- [26] Inquisitor's Gaze
		386646, -- [27] Lifeblood
		264874, -- [28] Darkfury
		384069, -- [29] Shadowflame
		30283, -- [30] Shadowfury
		386651, -- [31] Greater Banish
		710, -- [32] Banish
		386648, -- [33] Nightmare
		386864, -- [34] Wrathful Minion
		5484, -- [35] Howl of Terror
		6789, -- [36] Mortal Coil
		386110, -- [37] Fiendish Stride
		111400, -- [38] Burning Rush
		386124, -- [39] Fel Armor
		386105, -- [40] Curses of Enfeeblement
		219272, -- [41] Demon Skin
		386613, -- [42] Accrued Vitality
		389609, -- [43] Abyss Walker
		111771, -- [44] Demonic Gateway
		317138, -- [45] Strength of Will
		386659, -- [46] Dark Accord
		385899, -- [47] Soulburn
		389764, -- [48] Doom Blossom
		389775, -- [49] Dread Touch
		387273, -- [50] Malevolent Visionary
		387084, -- [51] Grand Warlock's Design
		389992, -- [52] Grim Reach
		387301, -- [53] Haunted Soul
		387250, -- [54] Seized Vitality
		387075, -- [55] Tormented Crescendo
		48181, -- [56] Haunt
		387065, -- [57] Wrath of Consumption
		205180, -- [58] Summon Darkglare
		386986, -- [59] Sacrolash's Dark Strike
		205179, -- [60] Phantom Singularity
		278350, -- [61] Vile Taint
		386951, -- [62] Soul Swap
		386922, -- [63] Agonizing Corruption
		196226, -- [64] Sow the Seeds
		196102, -- [65] Writhe in Agony
		199471, -- [66] Soul Flame
		387073, -- [67] Soul Tap
		201424, -- [68] Harvester of Souls
		32388, -- [69] Shadow Embrace
		198590, -- [70] Drain Soul
		334319, -- [71] Inevitable Demise
		108558, -- [72] Nightfall
		316099, -- [73] Unstable Affliction
		324536, -- [74] Malefic Rapture
		27243, -- [75] Seed of Corruption
		317031, -- [76] Xavian Teachings
		386759, -- [77] Pandemic Invocation
		196103, -- [78] Absolute Corruption
		63106, -- [79] Siphon Life
		108503, -- [80] Grimoire of Sacrifice
		386976, -- [81] Withering Bolt
		386997, -- [82] Soul Rot
		387016, -- [83] Dark Harvest
		264000, -- [84] Creeping Death
	},
	-- Demonology Warlock
	[266] = {
		389359, -- [0] Resolute Barrier
		389623, -- [1] Gorefiend's Resolve
		389590, -- [2] Demonic Resilience
		389367, -- [3] Fel Synergy
		389576, -- [4] Profane Bargain
		386617, -- [5] Demonic Fortitude
		215941, -- [6] Soul Conduit
		171975, -- [7] Grimoire of Synergy
		108415, -- [8] Soul Link
		386689, -- [9] Grim Feast
		386620, -- [10] Sweet Souls
		386858, -- [11] Demonic Inspiration
		386619, -- [12] Desperate Pact
		288843, -- [13] Demonic Embrace
		333889, -- [14] Fel Domination
		386113, -- [15] Fel Pact
		268358, -- [16] Demonic Circle
		328774, -- [17] Amplify Curse
		387972, -- [18] Teachings of the Satyr
		108416, -- [19] Dark Pact
		386664, -- [20] Ichor of Devils
		386686, -- [21] Frequent Donor
		385881, -- [22] Teachings of the Black Harvest
		386256, -- [23] Summon Soulkeeper
		386344, -- [24] Inquisitor's Gaze
		386646, -- [25] Lifeblood
		264874, -- [26] Darkfury
		384069, -- [27] Shadowflame
		30283, -- [28] Shadowfury
		386651, -- [29] Greater Banish
		710, -- [30] Banish
		386648, -- [31] Nightmare
		386864, -- [32] Wrathful Minion
		5484, -- [33] Howl of Terror
		6789, -- [34] Mortal Coil
		386110, -- [35] Fiendish Stride
		111400, -- [36] Burning Rush
		386124, -- [37] Fel Armor
		386105, -- [38] Curses of Enfeeblement
		219272, -- [39] Demon Skin
		386613, -- [40] Accrued Vitality
		389609, -- [41] Abyss Walker
		111771, -- [42] Demonic Gateway
		317138, -- [43] Strength of Will
		386659, -- [44] Dark Accord
		385899, -- [45] Soulburn
		390173, -- [46] Reign of Tyranny
		387084, -- [47] Grand Warlock's Design
		334585, -- [48] Soulbound Tyrant
		267214, -- [49] Sacrificed Souls
		387600, -- [50] The Expendables
		387578, -- [51] Gul'dan's Ambition
		387526, -- [52] Ner'zhul's Volition
		267217, -- [53] Nether Portal
		387445, -- [54] Imp Gang Boss
		387391, -- [55] Dread Calling
		387432, -- [56] Fel Covenant
		387349, -- [57] Bloodbound Imps
		196277, -- [58] Implosion
		264130, -- [59] Power Siphon
		387541, -- [60] Pact of the Imp Mother
		386833, -- [61] Guillotine
		387549, -- [62] Infernal Command
		387602, -- [63] Stolen Power
		387494, -- [64] Antoran Armaments
		387485, -- [65] Ripped through the Portal
		387399, -- [66] Fel Sunder
		387488, -- [67] Hounds of War
		387396, -- [68] Demonic Meteor
		111898, -- [69] Grimoire: Felguard
		387338, -- [70] Fel Might
		267170, -- [71] From the Shadows
		386200, -- [72] Fel and Steel
		205145, -- [73] Demonic Calling
		386194, -- [74] Carnivorous Stalkers
		264119, -- [75] Summon Vilefiend
		264057, -- [76] Soul Strike
		264078, -- [77] Dreadlash
		267211, -- [78] Bilescourge Bombers
		267171, -- [79] Demonic Strength
		386174, -- [80] Annihilan Training
		104316, -- [81] Call Dreadstalkers
		264178, -- [82] Demonbolt
		387322, -- [83] Shadow's Bite
		386185, -- [84] Demonic Knowledge
		267216, -- [85] Inner Demons
		603, -- [86] Doom
		387483, -- [87] Kazaak's Final Curse
		265187, -- [88] Summon Demonic Tyrant
	},
	-- Destruction Warlock
	[267] = {
		389359, -- [0] Resolute Barrier
		389623, -- [1] Gorefiend's Resolve
		389590, -- [2] Demonic Resilience
		389367, -- [3] Fel Synergy
		389576, -- [4] Profane Bargain
		386617, -- [5] Demonic Fortitude
		215941, -- [6] Soul Conduit
		171975, -- [7] Grimoire of Synergy
		108415, -- [8] Soul Link
		386689, -- [9] Grim Feast
		386620, -- [10] Sweet Souls
		386858, -- [11] Demonic Inspiration
		386619, -- [12] Desperate Pact
		288843, -- [13] Demonic Embrace
		333889, -- [14] Fel Domination
		386113, -- [15] Fel Pact
		268358, -- [16] Demonic Circle
		328774, -- [17] Amplify Curse
		387972, -- [18] Teachings of the Satyr
		108416, -- [19] Dark Pact
		386664, -- [20] Ichor of Devils
		386686, -- [21] Frequent Donor
		385881, -- [22] Teachings of the Black Harvest
		386256, -- [23] Summon Soulkeeper
		386344, -- [24] Inquisitor's Gaze
		386646, -- [25] Lifeblood
		264874, -- [26] Darkfury
		384069, -- [27] Shadowflame
		30283, -- [28] Shadowfury
		386651, -- [29] Greater Banish
		710, -- [30] Banish
		386648, -- [31] Nightmare
		386864, -- [32] Wrathful Minion
		5484, -- [33] Howl of Terror
		6789, -- [34] Mortal Coil
		386110, -- [35] Fiendish Stride
		111400, -- [36] Burning Rush
		386124, -- [37] Fel Armor
		386105, -- [38] Curses of Enfeeblement
		219272, -- [39] Demon Skin
		386613, -- [40] Accrued Vitality
		389609, -- [41] Abyss Walker
		111771, -- [42] Demonic Gateway
		317138, -- [43] Strength of Will
		386659, -- [44] Dark Accord
		385899, -- [45] Soulburn
		387475, -- [46] Infernal Brand
		266086, -- [47] Rain of Chaos
		387084, -- [48] Grand Warlock's Design
		387355, -- [49] Crashing Chaos
		387569, -- [50] Rolling Havoc
		387165, -- [51] Master Ritualist
		387159, -- [52] Avatar of Destruction
		387153, -- [53] Burn to Ashes
		387279, -- [54] Power Overwhelming
		387275, -- [55] Chaos Incarnate
		387976, -- [56] Dimensional Rift
		387400, -- [57] Madness of the Azj'Aqir
		387173, -- [58] Diabolic Embers
		387252, -- [59] Ashen Remains
		387156, -- [60] Ritual of Ruin
		108503, -- [61] Grimoire of Sacrifice
		387259, -- [62] Flashpoint
		388832, -- [63] Scalding Flames
		270545, -- [64] Inferno
		152108, -- [65] Cataclysm
		387095, -- [66] Pyrogenics
		387093, -- [67] Improved Immolate
		387176, -- [68] Decimation
		6353, -- [69] Soul Fire
		387506, -- [70] Mayhem
		80240, -- [71] Havoc
		205148, -- [72] Reverse Entropy
		266134, -- [73] Internal Combustion
		387509, -- [74] Pandemonium
		387522, -- [75] Cry Havoc
		196408, -- [76] Fire and Brimstone
		387384, -- [77] Backlash
		196412, -- [78] Eradication
		1122, -- [79] Summon Infernal
		388827, -- [80] Explosive Potential
		17877, -- [81] Shadowburn
		387108, -- [82] Conflagration of Chaos
		387103, -- [83] Ruin
		387166, -- [84] Raging Demonfire
		196447, -- [85] Channel Demonfire
		205184, -- [86] Roaring Blaze
		231793, -- [87] Improved Conflagrate
		196406, -- [88] Backdraft
		17962, -- [89] Conflagrate
		116858, -- [90] Chaos Bolt
		5740, -- [91] Rain of Fire
	},
	-- Brewmaster Monk
	[268] = {
		196736, -- [0] Blackout Combo
		387046, -- [1] Elusive Footwork
		388681, -- [2] Elusive Mists
		264348, -- [3] Tiger Tail Sweep
		387035, -- [4] Fundamental Observation
		324312, -- [5] Clash
		383785, -- [6] Counterstrike
		389942, -- [7] Face Palm
		387638, -- [8] Shadowboxing Treads
		387230, -- [9] Fluidity of Motion
		393516, -- [10] Pretense of Instability
		386937, -- [11] Anvil & Stave
		325093, -- [12] Light Brewing
		383714, -- [13] Training of Niuzao
		115399, -- [14] Black Ox Brew
		280515, -- [15] Bob and Weave
		121253, -- [16] Keg Smash
		124502, -- [17] Gift of the Ox
		119582, -- [18] Purifying Brew
		115069, -- [19] Stagger
		322120, -- [20] Shuffle
		388505, -- [21] Quick Sip
		387256, -- [22] Graceful Exit
		122281, -- [23] Healing Elixir
		387625, -- [24] Staggering Strikes
		325177, -- [25] Celestial Flames
		383695, -- [26] Hit Scheme
		322510, -- [27] Improved Celestial Brew
		322507, -- [28] Celestial Brew
		115181, -- [29] Breath of Fire
		383994, -- [30] Dragonfire Brew
		386965, -- [31] Charred Passions
		383698, -- [32] Scalding Brew
		383697, -- [33] Sal'salabim's Strength
		196737, -- [34] High Tolerance
		322960, -- [35] Fortifying Brew: Determination
		343743, -- [36] Improved Purifying Brew
		116095, -- [37] Disable
		115203, -- [38] Fortifying Brew
		388814, -- [39] Ironshell Brew
		388813, -- [40] Expeditious Fortification
		387276, -- [41] Strength of Spirit
		389575, -- [42] Generous Pour
		322113, -- [43] Improved Touch of Death
		115173, -- [44] Celerity
		115008, -- [45] Chi Torpedo
		116705, -- [46] Spear Hand Strike
		344359, -- [47] Improved Paralysis
		115078, -- [48] Paralysis
		116841, -- [49] Tiger's Lust
		107428, -- [50] Rising Sun Kick
		115175, -- [51] Soothing Mist
		231602, -- [52] Improved Vivify
		388664, -- [53] Calming Presence
		101643, -- [54] Transcendence
		388812, -- [55] Vivacious Vivification
		328670, -- [56] Hasty Provocation
		122783, -- [57] Diffuse Magic
		116844, -- [58] Ring of Peace
		157411, -- [59] Windwalking
		196607, -- [60] Eye of the Tiger
		388686, -- [61] Summon White Tiger Statue
		389578, -- [62] Resonant Fists
		394123, -- [63] Fatal Touch
		122278, -- [64] Dampen Harm
		388809, -- [65] Fast Feet
		388674, -- [66] Ferocity of Xuen
		389574, -- [67] Close to Heart
		392910, -- [68] Profound Rebuttal
		115098, -- [69] Chi Wave
		123986, -- [70] Chi Burst
		388811, -- [71] Grace of the Crane
		392900, -- [72] Vigorous Expulsion
		328669, -- [73] Improved Roll
		115313, -- [74] Summon Jade Serpent Statue
		389579, -- [75] Save Them All
		394110, -- [76] Escape from Reality
		115315, -- [77] Summon Black Ox Statue
		389577, -- [78] Bounce Back
		397251, -- [79] Call to Arms
		393400, -- [80] Chi Surge
		387184, -- [81] Weapons of Order
		322740, -- [82] Improved Invoke Niuzao, the Black Ox
		383707, -- [83] Stormstout's Last Keg
		325153, -- [84] Exploding Keg
		387219, -- [85] Walk with the Ox
		132578, -- [86] Invoke Niuzao, the Black Ox
		393357, -- [87] Tranquil Spirit
		383700, -- [88] Gai Plin's Imperial Brew
		115176, -- [89] Zen Meditation
		116847, -- [90] Rushing Jade Wind
		196730, -- [91] Special Delivery
		386949, -- [92] Bountiful Brew
		386941, -- [93] Attenuation
		386276, -- [94] Bonedust Brew
		218164, -- [95] Detox
	},
	-- Windwalker Monk
	[269] = {
		388681, -- [0] Elusive Mists
		264348, -- [1] Tiger Tail Sweep
		392994, -- [2] Way of the Fae
		218164, -- [3] Detox
		392979, -- [4] Jade Ignition
		393098, -- [5] Forbidden Technique
		388846, -- [6] Widening Whirl
		122470, -- [7] Touch of Karma
		391383, -- [8] Hardened Soles
		115396, -- [9] Ascension
		113656, -- [10] Fists of Fury
		121817, -- [11] Power Strikes
		388854, -- [12] Flashing Fists
		116645, -- [13] Teachings of the Monastery
		280197, -- [14] Spiritual Focus
		137639, -- [15] Storm, Earth, and Fire
		152173, -- [16] Serenity
		391370, -- [17] Drinking Horn Cover
		391330, -- [18] Meridian Strikes
		101545, -- [19] Flying Serpent Kick
		388856, -- [20] Touch of the Tiger
		220357, -- [21] Mark of the Crane
		392982, -- [22] Shadowboxing Treads
		116847, -- [23] Rushing Jade Wind
		325201, -- [24] Dance of Chi-Ji
		195243, -- [25] Inner Peace
		396166, -- [26] Fury of Xuen
		123904, -- [27] Invoke Xuen, the White Tiger
		152175, -- [28] Whirling Dragon Punch
		323999, -- [29] Empowered Tiger Lightning
		195300, -- [30] Transfer the Power
		388661, -- [31] Invoker's Delight
		392993, -- [32] Xuen's Battlegear
		392991, -- [33] Skyreach
		392989, -- [34] Last Emperor's Capacitor
		392986, -- [35] Xuen's Bond
		394923, -- [36] Fatal Flying Guillotine
		388848, -- [37] Crane Vortex
		386941, -- [38] Attenuation
		386276, -- [39] Bonedust Brew
		394093, -- [40] Dust in the Wind
		391412, -- [41] Faeline Harmony
		388193, -- [42] Faeline Stomp
		388849, -- [43] Rising Star
		392985, -- [44] Thunderfist
		392983, -- [45] Strike of the Windlord
		196740, -- [46] Hit Combo
		392958, -- [47] Glory of the Dawn
		392970, -- [48] Open Palm Strikes
		116095, -- [49] Disable
		115203, -- [50] Fortifying Brew
		388814, -- [51] Ironshell Brew
		388813, -- [52] Expeditious Fortification
		387276, -- [53] Strength of Spirit
		389575, -- [54] Generous Pour
		322113, -- [55] Improved Touch of Death
		115173, -- [56] Celerity
		115008, -- [57] Chi Torpedo
		116705, -- [58] Spear Hand Strike
		344359, -- [59] Improved Paralysis
		115078, -- [60] Paralysis
		116841, -- [61] Tiger's Lust
		107428, -- [62] Rising Sun Kick
		115175, -- [63] Soothing Mist
		231602, -- [64] Improved Vivify
		388664, -- [65] Calming Presence
		101643, -- [66] Transcendence
		388812, -- [67] Vivacious Vivification
		328670, -- [68] Hasty Provocation
		122783, -- [69] Diffuse Magic
		116844, -- [70] Ring of Peace
		157411, -- [71] Windwalking
		196607, -- [72] Eye of the Tiger
		388686, -- [73] Summon White Tiger Statue
		389578, -- [74] Resonant Fists
		394123, -- [75] Fatal Touch
		122278, -- [76] Dampen Harm
		388809, -- [77] Fast Feet
		388674, -- [78] Ferocity of Xuen
		389574, -- [79] Close to Heart
		392910, -- [80] Profound Rebuttal
		115098, -- [81] Chi Wave
		123986, -- [82] Chi Burst
		388811, -- [83] Grace of the Crane
		392900, -- [84] Vigorous Expulsion
		328669, -- [85] Improved Roll
		115313, -- [86] Summon Jade Serpent Statue
		389579, -- [87] Save Them All
		394110, -- [88] Escape from Reality
		115315, -- [89] Summon Black Ox Statue
		389577, -- [90] Bounce Back
	},
	-- Mistweaver Monk
	[270] = {
		387991, -- [0] Tear of Morning
		274909, -- [1] Rising Mist
		274586, -- [2] Invigorating Mists
		388193, -- [3] Faeline Stomp
		198898, -- [4] Song of Chi-Ji
		210802, -- [5] Spirit of the Crane
		197900, -- [6] Mist Wrap
		196725, -- [7] Refreshing Jade Wind
		388604, -- [8] Echoing Reverberation
		388564, -- [9] Accumulating Mist
		393460, -- [10] Tea of Serenity
		388517, -- [11] Tea of Plenty
		124081, -- [12] Zen Pulse
		388548, -- [13] Mists of Life
		124682, -- [14] Enveloping Mist
		388740, -- [15] Ancient Concordance
		388491, -- [16] Secret Infusion
		388661, -- [17] Invoker's Delight
		122281, -- [18] Healing Elixir
		388477, -- [19] Unison
		388509, -- [20] Mending Proliferation
		115310, -- [21] Revival
		388615, -- [22] Restoral
		197915, -- [23] Lifecycles
		197908, -- [24] Mana Tea
		388031, -- [25] Jade Bond
		388212, -- [26] Gift of the Celestials
		388779, -- [27] Awakened Faeline
		388038, -- [28] Yu'lon's Whisper
		388847, -- [29] Rapid Diffusion
		337209, -- [30] Font of Life
		388511, -- [31] Overflowing Mists
		343655, -- [32] Enveloping Breath
		388218, -- [33] Calming Coalescence
		116849, -- [34] Life Cocoon
		388020, -- [35] Resplendent Mist
		386276, -- [36] Bonedust Brew
		388701, -- [37] Dancing Mists
		115151, -- [38] Renewing Mist
		281231, -- [39] Mastery of Mist
		322118, -- [40] Invoke Yu'lon, the Jade Serpent
		325197, -- [41] Invoke Chi-Ji, the Red Crane
		388551, -- [42] Uplifted Spirits
		388593, -- [43] Peaceful Mending
		197895, -- [44] Focused Thunder
		274963, -- [45] Upwelling
		388682, -- [46] Misty Peaks
		116645, -- [47] Teachings of the Monastery
		386949, -- [48] Bountiful Brew
		386941, -- [49] Attenuation
		191837, -- [50] Essence Font
		388023, -- [51] Ancient Teachings
		388047, -- [52] Clouded Focus
		387765, -- [53] Nourishing Chi
		116680, -- [54] Thunder Focus Tea
		388681, -- [55] Elusive Mists
		264348, -- [56] Tiger Tail Sweep
		116095, -- [57] Disable
		115203, -- [58] Fortifying Brew
		388814, -- [59] Ironshell Brew
		388813, -- [60] Expeditious Fortification
		387276, -- [61] Strength of Spirit
		389575, -- [62] Generous Pour
		322113, -- [63] Improved Touch of Death
		115173, -- [64] Celerity
		115008, -- [65] Chi Torpedo
		116705, -- [66] Spear Hand Strike
		344359, -- [67] Improved Paralysis
		115078, -- [68] Paralysis
		116841, -- [69] Tiger's Lust
		107428, -- [70] Rising Sun Kick
		115175, -- [71] Soothing Mist
		231602, -- [72] Improved Vivify
		388664, -- [73] Calming Presence
		101643, -- [74] Transcendence
		388812, -- [75] Vivacious Vivification
		328670, -- [76] Hasty Provocation
		122783, -- [77] Diffuse Magic
		116844, -- [78] Ring of Peace
		157411, -- [79] Windwalking
		196607, -- [80] Eye of the Tiger
		388686, -- [81] Summon White Tiger Statue
		389578, -- [82] Resonant Fists
		394123, -- [83] Fatal Touch
		122278, -- [84] Dampen Harm
		388809, -- [85] Fast Feet
		388674, -- [86] Ferocity of Xuen
		389574, -- [87] Close to Heart
		392910, -- [88] Profound Rebuttal
		115098, -- [89] Chi Wave
		123986, -- [90] Chi Burst
		388811, -- [91] Grace of the Crane
		392900, -- [92] Vigorous Expulsion
		328669, -- [93] Improved Roll
		115313, -- [94] Summon Jade Serpent Statue
		389579, -- [95] Save Them All
		394110, -- [96] Escape from Reality
		115315, -- [97] Summon Black Ox Statue
		389577, -- [98] Bounce Back
		388874, -- [99] Improved Detox
	},
	-- Havoc Demon Hunter
	[577] = {
		205411, -- [0] Desperate Instincts
		196555, -- [1] Netherwalk
		206478, -- [2] Demonic Appetite
		258881, -- [3] Trail of Ruin
		390158, -- [4] Growing Inferno
		391189, -- [5] Burning Wound
		388107, -- [6] Ragefire
		388114, -- [7] Any Means Necessary
		388106, -- [8] Soulrend
		320415, -- [9] Looks Can Kill
		388112, -- [10] Chaotic Transformation
		320374, -- [11] Burning Hatred
		328725, -- [12] Mortal Dance
		206416, -- [13] First Blood
		389811, -- [14] Unnatural Malice
		389819, -- [15] Relentless Pursuit
		370965, -- [16] The Hunt
		388111, -- [17] Demon Muzzle
		395446, -- [18] Soul Sigils
		320635, -- [19] Vengeful Bonds
		320386, -- [20] Bouncing Glaives
		207347, -- [21] Aura of Pain
		232893, -- [22] Felblade
		320421, -- [23] Rush of Chaos
		393822, -- [24] Internal Struggle
		389696, -- [25] Illidari Knowledge
		204909, -- [26] Soul Rending
		183782, -- [27] Disrupting Fury
		320361, -- [28] Improved Disrupt
		389846, -- [29] Felfire Haste
		320654, -- [30] Pursuit
		320770, -- [31] Unrestrained Fury
		198793, -- [32] Vengeful Retreat
		204596, -- [33] Sigil of Flame
		207666, -- [34] Concentrated Sigils
		389799, -- [35] Precise Sigils
		320418, -- [36] Improved Sigil of Misery
		388110, -- [37] Misery in Defeat
		207684, -- [38] Sigil of Misery
		389849, -- [39] Lost in Darkness
		213010, -- [40] Charred Warblades
		389694, -- [41] Flames of Fury
		389824, -- [42] Shattered Restoration
		320412, -- [43] Chaos Fragments
		206477, -- [44] Unleashed Power
		179057, -- [45] Chaos Nova
		389763, -- [46] Master of the Glaive
		390152, -- [47] Collective Anguish
		391397, -- [48] Erratic Felheart
		209281, -- [49] Quickened Sigils
		389697, -- [50] Extended Sigils
		391409, -- [51] Aldrachi Design
		389695, -- [52] Will of the Illidari
		389781, -- [53] Long Night
		389783, -- [54] Pitch Black
		196718, -- [55] Darkness
		213410, -- [56] Demonic
		235893, -- [57] First of the Illidari
		320331, -- [58] Infernal Armor
		320313, -- [59] Swallowed Anger
		278326, -- [60] Consume Magic
		217832, -- [61] Imprison
		320416, -- [62] Blazing Path
		389693, -- [63] Inner Demon
		391429, -- [64] Fodder to the Flame
		390163, -- [65] Elysian Decree
		391275, -- [66] Accelerating Blade
		389977, -- [67] Relentless Onslaught
		390154, -- [68] Serrated Glaive
		211881, -- [69] Fel Eruption
		389978, -- [70] Dancing with Fate
		393029, -- [71] Furious Throws
		388109, -- [72] Felfire Heart
		198013, -- [73] Eye Beam
		258876, -- [74] Insatiable Hunger
		203555, -- [75] Demon Blades
		347461, -- [76] Unbound Chaos
		206476, -- [77] Momentum
		389688, -- [78] Tactical Retreat
		342817, -- [79] Glaive Tempest
		258925, -- [80] Fel Barrage
		390142, -- [81] Restless Hunter
		343311, -- [82] Furious Gaze
		203550, -- [83] Blind Fury
		388108, -- [84] Initiative
		320413, -- [85] Critical Chaos
		343017, -- [86] Improved Fel Rush
		343206, -- [87] Improved Chaos Strike
		388116, -- [88] Shattered Destiny
		258887, -- [89] Cycle of Hatred
		258860, -- [90] Essence Break
		388118, -- [91] Know Your Enemy
		389687, -- [92] Chaos Theory
		388113, -- [93] Isolated Prey
	},
	-- Vengeance Demon Hunter
	[581] = {
		389811, -- [0] Unnatural Malice
		389819, -- [1] Relentless Pursuit
		370965, -- [2] The Hunt
		388111, -- [3] Demon Muzzle
		395446, -- [4] Soul Sigils
		320635, -- [5] Vengeful Bonds
		320386, -- [6] Bouncing Glaives
		207347, -- [7] Aura of Pain
		232893, -- [8] Felblade
		320421, -- [9] Rush of Chaos
		393822, -- [10] Internal Struggle
		389696, -- [11] Illidari Knowledge
		204909, -- [12] Soul Rending
		183782, -- [13] Disrupting Fury
		320361, -- [14] Improved Disrupt
		389846, -- [15] Felfire Haste
		320654, -- [16] Pursuit
		320770, -- [17] Unrestrained Fury
		198793, -- [18] Vengeful Retreat
		204596, -- [19] Sigil of Flame
		207666, -- [20] Concentrated Sigils
		389799, -- [21] Precise Sigils
		320418, -- [22] Improved Sigil of Misery
		388110, -- [23] Misery in Defeat
		207684, -- [24] Sigil of Misery
		389849, -- [25] Lost in Darkness
		213010, -- [26] Charred Warblades
		389694, -- [27] Flames of Fury
		389824, -- [28] Shattered Restoration
		204021, -- [29] Fiery Brand
		389729, -- [30] Retaliation
		389724, -- [31] Meteoric Strikes
		202138, -- [32] Sigil of Chains
		389705, -- [33] Fel Flame Fortification
		263648, -- [34] Soul Barrier
		320341, -- [35] Bulk Extraction
		343014, -- [36] Revel in Pain
		389220, -- [37] Fiery Demise
		207739, -- [38] Burning Alive
		391429, -- [39] Fodder to the Flame
		390163, -- [40] Elysian Decree
		389732, -- [41] Down in Flames
		336639, -- [42] Charred Flesh
		389718, -- [43] Cycle of Binding
		389715, -- [44] Chains of Anger
		326853, -- [45] Ruinous Bulwark
		389721, -- [46] Extended Spikes
		389720, -- [47] Calcified Spikes
		320387, -- [48] Perfectly Balanced Glaive
		207697, -- [49] Feast of Souls
		389997, -- [50] Shear Fury
		263642, -- [51] Fracture
		207548, -- [52] Agonizing Flames
		227174, -- [53] Fallout
		389711, -- [54] Soulmonger
		391165, -- [55] Soul Furnace
		343207, -- [56] Focused Cleave
		207387, -- [57] Painbringer
		268175, -- [58] Void Reaver
		247454, -- [59] Spirit Bomb
		209258, -- [60] Last Resort
		389985, -- [61] Soulcrush
		389976, -- [62] Vulnerability
		207407, -- [63] Soul Carver
		218612, -- [64] Feed the Demon
		393827, -- [65] Stoke the Flames
		389708, -- [66] Darkglare Boon
		390808, -- [67] Volatile Flameblood
		390213, -- [68] Burning Blood
		391178, -- [69] Roaring Fire
		202137, -- [70] Sigil of Silence
		321028, -- [71] Deflecting Spikes
		389958, -- [72] Frailty
		212084, -- [73] Fel Devastation
		320412, -- [74] Chaos Fragments
		206477, -- [75] Unleashed Power
		179057, -- [76] Chaos Nova
		389763, -- [77] Master of the Glaive
		390152, -- [78] Collective Anguish
		391397, -- [79] Erratic Felheart
		209281, -- [80] Quickened Sigils
		389697, -- [81] Extended Sigils
		391409, -- [82] Aldrachi Design
		389695, -- [83] Will of the Illidari
		389781, -- [84] Long Night
		389783, -- [85] Pitch Black
		196718, -- [86] Darkness
		213410, -- [87] Demonic
		235893, -- [88] First of the Illidari
		320331, -- [89] Infernal Armor
		320313, -- [90] Swallowed Anger
		278326, -- [91] Consume Magic
		217832, -- [92] Imprison
		320416, -- [93] Blazing Path
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
		[1] = { 61, 5397, 3529, 5492, 3517, 5488, 3442, 5491, 637, 635, 3531, }, -- Arcane Empowerment, Arcanosphere, Kleptomania, Precognition, Temporal Shield, Ice Wall, Netherwind Armor, Ring of Fire, Mass Invisibility, Master of Escape, Prismatic Cloak
		[2] = { 61, 5397, 3529, 5492, 3517, 5488, 3442, 5491, 637, 635, 3531, }, -- Arcane Empowerment, Arcanosphere, Kleptomania, Precognition, Temporal Shield, Ice Wall, Netherwind Armor, Ring of Fire, Mass Invisibility, Master of Escape, Prismatic Cloak
		[3] = { 61, 5397, 3529, 5492, 3517, 5488, 3442, 5491, 637, 635, 3531, }, -- Arcane Empowerment, Arcanosphere, Kleptomania, Precognition, Temporal Shield, Ice Wall, Netherwind Armor, Ring of Fire, Mass Invisibility, Master of Escape, Prismatic Cloak
	},
	-- Fire Mage
	[63] = {
		[1] = { 53, 5389, 5489, 828, 5495, 648, 647, 646, 644, 5493, }, -- Netherwind Armor, Ring of Fire, Ice Wall, Prismatic Cloak, Glass Cannon, Greater Pyroblast, Flamecannon, Pyrokinesis, World in Flames, Precognition
		[2] = { 53, 5389, 5489, 828, 5495, 648, 647, 646, 644, 5493, }, -- Netherwind Armor, Ring of Fire, Ice Wall, Prismatic Cloak, Glass Cannon, Greater Pyroblast, Flamecannon, Pyrokinesis, World in Flames, Precognition
		[3] = { 53, 5389, 5489, 828, 5495, 648, 647, 646, 644, 5493, }, -- Netherwind Armor, Ring of Fire, Ice Wall, Prismatic Cloak, Glass Cannon, Greater Pyroblast, Flamecannon, Pyrokinesis, World in Flames, Precognition
	},
	-- Frost Mage
	[64] = {
		[1] = { 66, 3443, 5490, 3532, 5494, 5390, 5496, 5497, 634, 632, }, -- Chilled to the Bone, Netherwind Armor, Ring of Fire, Prismatic Cloak, Precognition, Ice Wall, Frost Bomb, Snowdrift, Ice Form, Concentrated Coolness
		[2] = { 66, 3443, 5490, 3532, 5494, 5390, 5496, 5497, 634, 632, }, -- Chilled to the Bone, Netherwind Armor, Ring of Fire, Prismatic Cloak, Precognition, Ice Wall, Frost Bomb, Snowdrift, Ice Form, Concentrated Coolness
		[3] = { 66, 3443, 5490, 3532, 5494, 5390, 5496, 5497, 634, 632, }, -- Chilled to the Bone, Netherwind Armor, Ring of Fire, Prismatic Cloak, Precognition, Ice Wall, Frost Bomb, Snowdrift, Ice Form, Concentrated Coolness
	},
	-- Holy Paladin
	[65] = {
		[1] = { 85, 86, 87, 88, 5553, 5421, 642, 5501, 82, 640, 3618, 859, 5537, }, -- Ultimate Sacrifice, Darkest before the Dawn, Spreading the Word, Blessed Hands, Aura of Reckoning, Judgments of the Pure, Cleanse the Weak, Precognition, Avenging Light, Divine Vision, Hallowed Ground, Light's Grace, Vengeance Aura
		[2] = { 85, 86, 87, 88, 5553, 5421, 642, 5501, 82, 640, 3618, 859, 5537, }, -- Ultimate Sacrifice, Darkest before the Dawn, Spreading the Word, Blessed Hands, Aura of Reckoning, Judgments of the Pure, Cleanse the Weak, Precognition, Avenging Light, Divine Vision, Hallowed Ground, Light's Grace, Vengeance Aura
		[3] = { 85, 86, 87, 88, 5553, 5421, 642, 5501, 82, 640, 3618, 859, 5537, }, -- Ultimate Sacrifice, Darkest before the Dawn, Spreading the Word, Blessed Hands, Aura of Reckoning, Judgments of the Pure, Cleanse the Weak, Precognition, Avenging Light, Divine Vision, Hallowed Ground, Light's Grace, Vengeance Aura
	},
	-- Protection Paladin
	[66] = {
		[1] = { 5554, 3475, 3474, 861, 860, 844, 92, 5536, 90, 91, 93, 94, 97, }, -- Aura of Reckoning, Unbound Freedom, Luminescence, Shield of Virtue, Warrior of Light, Inquisition, Sacred Duty, Vengeance Aura, Hallowed Ground, Steed of Glory, Judgments of the Pure, Guardian of the Forgotten Queen, Guarded by the Light
		[2] = { 5554, 3475, 3474, 861, 860, 844, 92, 5536, 90, 91, 93, 94, 97, }, -- Aura of Reckoning, Unbound Freedom, Luminescence, Shield of Virtue, Warrior of Light, Inquisition, Sacred Duty, Vengeance Aura, Hallowed Ground, Steed of Glory, Judgments of the Pure, Guardian of the Forgotten Queen, Guarded by the Light
		[3] = { 5554, 3475, 3474, 861, 860, 844, 92, 5536, 90, 91, 93, 94, 97, }, -- Aura of Reckoning, Unbound Freedom, Luminescence, Shield of Virtue, Warrior of Light, Inquisition, Sacred Duty, Vengeance Aura, Hallowed Ground, Steed of Glory, Judgments of the Pure, Guardian of the Forgotten Queen, Guarded by the Light
	},
	-- Retribution Paladin
	[70] = {
		[1] = { 81, 751, 5535, 752, 753, 5422, 754, 755, 756, 757, 641, 858, }, -- Luminescence, Vengeance Aura, Hallowed Ground, Blessing of Sanctuary, Ultimate Retribution, Judgments of the Pure, Lawbringer, Divine Punisher, Aura of Reckoning, Jurisdiction, Unbound Freedom, Law and Order
		[2] = { 81, 751, 5535, 752, 753, 5422, 754, 755, 756, 757, 641, 858, }, -- Luminescence, Vengeance Aura, Hallowed Ground, Blessing of Sanctuary, Ultimate Retribution, Judgments of the Pure, Lawbringer, Divine Punisher, Aura of Reckoning, Jurisdiction, Unbound Freedom, Law and Order
		[3] = { 81, 751, 5535, 752, 753, 5422, 754, 755, 756, 757, 641, 858, }, -- Luminescence, Vengeance Aura, Hallowed Ground, Blessing of Sanctuary, Ultimate Retribution, Judgments of the Pure, Lawbringer, Divine Punisher, Aura of Reckoning, Jurisdiction, Unbound Freedom, Law and Order
	},
	-- Arms Warrior
	[71] = {
		[1] = { 3534, 5376, 28, 29, 5547, 31, 32, 33, 34, 5372, 3522, }, -- Disarm, Warbringer, Master and Commander, Shadow of the Colossus, Rebound, Storm of Destruction, War Banner, Sharpen Blade, Duel, Demolition, Death Sentence
		[2] = { 3534, 5376, 28, 29, 5547, 31, 32, 33, 34, 5372, 3522, }, -- Disarm, Warbringer, Master and Commander, Shadow of the Colossus, Rebound, Storm of Destruction, War Banner, Sharpen Blade, Duel, Demolition, Death Sentence
		[3] = { 3534, 5376, 28, 29, 5547, 31, 32, 33, 34, 5372, 3522, }, -- Disarm, Warbringer, Master and Commander, Shadow of the Colossus, Rebound, Storm of Destruction, War Banner, Sharpen Blade, Duel, Demolition, Death Sentence
	},
	-- Fury Warrior
	[72] = {
		[1] = { 179, 5373, 5548, 3528, 3735, 3533, 25, 5431, 166, 170, 172, 177, }, -- Death Wish, Demolition, Rebound, Master and Commander, Slaughterhouse, Disarm, Death Sentence, Warbringer, Barbarian, Battle Trance, Bloodrage, Enduring Rage
		[2] = { 179, 5373, 5548, 3528, 3735, 3533, 25, 5431, 166, 170, 172, 177, }, -- Death Wish, Demolition, Rebound, Master and Commander, Slaughterhouse, Disarm, Death Sentence, Warbringer, Barbarian, Battle Trance, Bloodrage, Enduring Rage
		[3] = { 179, 5373, 5548, 3528, 3735, 3533, 25, 5431, 166, 170, 172, 177, }, -- Death Wish, Demolition, Rebound, Master and Commander, Slaughterhouse, Disarm, Death Sentence, Warbringer, Barbarian, Battle Trance, Bloodrage, Enduring Rage
	},
	-- Protection Warrior
	[73] = {
		[1] = { 5374, 833, 178, 167, 168, 171, 845, 831, 24, 5432, 175, 173, }, -- Demolition, Rebound, Warpath, Sword and Board, Bodyguard, Morale Killer, Oppressor, Dragon Charge, Disarm, Warbringer, Thunderstruck, Shield Bash
		[2] = { 5374, 833, 178, 167, 168, 171, 845, 831, 24, 5432, 175, 173, }, -- Demolition, Rebound, Warpath, Sword and Board, Bodyguard, Morale Killer, Oppressor, Dragon Charge, Disarm, Warbringer, Thunderstruck, Shield Bash
		[3] = { 5374, 833, 178, 167, 168, 171, 845, 831, 24, 5432, 175, 173, }, -- Demolition, Rebound, Warpath, Sword and Board, Bodyguard, Morale Killer, Oppressor, Dragon Charge, Disarm, Warbringer, Thunderstruck, Shield Bash
	},
	-- Balance Druid
	[102] = {
		[1] = { 836, 834, 182, 822, 184, 3728, 185, 5503, 3058, 5383, 3731, 180, 5407, 5526, 5515, }, -- Faerie Swarm, Deep Roots, Crescent Burn, Dying Stars, Moon and Stars, Protector of the Grove, Moonkin Aura, Precognition, Star Burst, High Winds, Thorns, Celestial Guardian, Owlkin Adept, Reactive Resin, Malorne's Swiftness
		[2] = { 836, 834, 182, 822, 184, 3728, 185, 5503, 3058, 5383, 3731, 180, 5407, 5526, 5515, }, -- Faerie Swarm, Deep Roots, Crescent Burn, Dying Stars, Moon and Stars, Protector of the Grove, Moonkin Aura, Precognition, Star Burst, High Winds, Thorns, Celestial Guardian, Owlkin Adept, Reactive Resin, Malorne's Swiftness
		[3] = { 836, 834, 182, 822, 184, 3728, 185, 5503, 3058, 5383, 3731, 180, 5407, 5526, 5515, }, -- Faerie Swarm, Deep Roots, Crescent Burn, Dying Stars, Moon and Stars, Protector of the Grove, Moonkin Aura, Precognition, Star Burst, High Winds, Thorns, Celestial Guardian, Owlkin Adept, Reactive Resin, Malorne's Swiftness
	},
	-- Feral Druid
	[103] = {
		[1] = { 5525, 601, 5384, 3053, 602, 820, 611, 612, 620, 203, 3751, 201, }, -- Reactive Resin, Malorne's Swiftness, High Winds, Strength of the Wild, King of the Jungle, Savage Momentum, Ferocious Wound, Fresh Wound, Wicked Claws, Freedom of the Herd, Leader of the Pack, Thorns
		[2] = { 5525, 601, 5384, 3053, 602, 820, 611, 612, 620, 203, 3751, 201, }, -- Reactive Resin, Malorne's Swiftness, High Winds, Strength of the Wild, King of the Jungle, Savage Momentum, Ferocious Wound, Fresh Wound, Wicked Claws, Freedom of the Herd, Leader of the Pack, Thorns
		[3] = { 5525, 601, 5384, 3053, 602, 820, 611, 612, 620, 203, 3751, 201, }, -- Reactive Resin, Malorne's Swiftness, High Winds, Strength of the Wild, King of the Jungle, Savage Momentum, Ferocious Wound, Fresh Wound, Wicked Claws, Freedom of the Herd, Leader of the Pack, Thorns
	},
	-- Guardian Druid
	[104] = {
		[1] = { 197, 5410, 192, 52, 193, 49, 50, 51, 194, 1237, 842, 195, 196, 3750, 5524, }, -- Emerald Slumber, Grove Protection, Raging Frenzy, Demoralizing Roar, Sharpened Claws, Master Shapeshifter, Toughness, Den Mother, Charging Bash, Malorne's Swiftness, Alpha Challenge, Entangling Claws, Overrun, Freedom of the Herd, Reactive Resin
		[2] = { 197, 5410, 192, 52, 193, 49, 50, 51, 194, 1237, 842, 195, 196, 3750, 5524, }, -- Emerald Slumber, Grove Protection, Raging Frenzy, Demoralizing Roar, Sharpened Claws, Master Shapeshifter, Toughness, Den Mother, Charging Bash, Malorne's Swiftness, Alpha Challenge, Entangling Claws, Overrun, Freedom of the Herd, Reactive Resin
		[3] = { 197, 5410, 192, 52, 193, 49, 50, 51, 194, 1237, 842, 195, 196, 3750, 5524, }, -- Emerald Slumber, Grove Protection, Raging Frenzy, Demoralizing Roar, Sharpened Claws, Master Shapeshifter, Toughness, Den Mother, Charging Bash, Malorne's Swiftness, Alpha Challenge, Entangling Claws, Overrun, Freedom of the Herd, Reactive Resin
	},
	-- Restoration Druid
	[105] = {
		[1] = { 835, 838, 1215, 3048, 5387, 692, 59, 5514, 5504, 691, 697, 700, }, -- Focused Growth, High Winds, Early Spring, Master Shapeshifter, Keeper of the Grove, Entangling Bark, Disentanglement, Malorne's Swiftness, Precognition, Reactive Resin, Thorns, Deep Roots
		[2] = { 835, 838, 1215, 3048, 5387, 692, 59, 5514, 5504, 691, 697, 700, }, -- Focused Growth, High Winds, Early Spring, Master Shapeshifter, Keeper of the Grove, Entangling Bark, Disentanglement, Malorne's Swiftness, Precognition, Reactive Resin, Thorns, Deep Roots
		[3] = { 835, 838, 1215, 3048, 5387, 692, 59, 5514, 5504, 691, 697, 700, }, -- Focused Growth, High Winds, Early Spring, Master Shapeshifter, Keeper of the Grove, Entangling Bark, Disentanglement, Malorne's Swiftness, Precognition, Reactive Resin, Thorns, Deep Roots
	},
	-- Blood Death Knight
	[250] = {
		[1] = { 841, 609, 608, 607, 206, 205, 3511, 3441, 5513, 5425, 204, }, -- Murderous Intent, Death Chain, Last Dance, Blood for Blood, Strangulate, Walking Dead, Dark Simulacrum, Decomposing Aura, Necrotic Aura, Spellwarden, Rot and Wither
		[2] = { 841, 609, 608, 607, 206, 205, 3511, 3441, 5513, 5425, 204, }, -- Murderous Intent, Death Chain, Last Dance, Blood for Blood, Strangulate, Walking Dead, Dark Simulacrum, Decomposing Aura, Necrotic Aura, Spellwarden, Rot and Wither
		[3] = { 841, 609, 608, 607, 206, 205, 3511, 3441, 5513, 5425, 204, }, -- Murderous Intent, Death Chain, Last Dance, Blood for Blood, Strangulate, Walking Dead, Dark Simulacrum, Decomposing Aura, Necrotic Aura, Spellwarden, Rot and Wither
	},
	-- Frost Death Knight
	[251] = {
		[1] = { 3439, 5510, 5512, 702, 3743, 701, 5424, 5429, 3512, 5435, }, -- Shroud of Winter, Rot and Wither, Necrotic Aura, Delirium, Dead of Winter, Deathchill, Spellwarden, Strangulate, Dark Simulacrum, Bitter Chill
		[2] = { 3439, 5510, 5512, 702, 3743, 701, 5424, 5429, 3512, 5435, }, -- Shroud of Winter, Rot and Wither, Necrotic Aura, Delirium, Dead of Winter, Deathchill, Spellwarden, Strangulate, Dark Simulacrum, Bitter Chill
		[3] = { 3439, 5510, 5512, 702, 3743, 701, 5424, 5429, 3512, 5435, }, -- Shroud of Winter, Rot and Wither, Necrotic Aura, Delirium, Dead of Winter, Deathchill, Spellwarden, Strangulate, Dark Simulacrum, Bitter Chill
	},
	-- Unholy Death Knight
	[252] = {
		[1] = { 5436, 5430, 152, 149, 3437, 41, 3747, 40, 5423, 3746, 5511, }, -- Doomburst, Strangulate, Reanimation, Necrotic Wounds, Necrotic Aura, Dark Simulacrum, Raise Abomination, Life and Death, Spellwarden, Necromancer's Bargain, Rot and Wither
		[2] = { 5436, 5430, 152, 149, 3437, 41, 3747, 40, 5423, 3746, 5511, }, -- Doomburst, Strangulate, Reanimation, Necrotic Wounds, Necrotic Aura, Dark Simulacrum, Raise Abomination, Life and Death, Spellwarden, Necromancer's Bargain, Rot and Wither
		[3] = { 5436, 5430, 152, 149, 3437, 41, 3747, 40, 5423, 3746, 5511, }, -- Doomburst, Strangulate, Reanimation, Necrotic Wounds, Necrotic Aura, Dark Simulacrum, Raise Abomination, Life and Death, Spellwarden, Necromancer's Bargain, Rot and Wither
	},
	-- Beast Mastery Hunter
	[253] = {
		[1] = { 5444, 3600, 3604, 3730, 3612, 5534, 825, 1214, 693, 5418, 3599, 5441, 824, }, -- Kindred Beasts, Dragonscale Armor, Chimaeral Sting, Hunting Pack, Roar of Sacrifice, Diamond Ice, Dire Beast: Basilisk, Interlope, The Beast Within, Tranquilizing Darts, Survival Tactics, Wild Kingdom, Dire Beast: Hawk
		[2] = { 5444, 3600, 3604, 3730, 3612, 5534, 825, 1214, 693, 5418, 3599, 5441, 824, }, -- Kindred Beasts, Dragonscale Armor, Chimaeral Sting, Hunting Pack, Roar of Sacrifice, Diamond Ice, Dire Beast: Basilisk, Interlope, The Beast Within, Tranquilizing Darts, Survival Tactics, Wild Kingdom, Dire Beast: Hawk
		[3] = { 5444, 3600, 3604, 3730, 3612, 5534, 825, 1214, 693, 5418, 3599, 5441, 824, }, -- Kindred Beasts, Dragonscale Armor, Chimaeral Sting, Hunting Pack, Roar of Sacrifice, Diamond Ice, Dire Beast: Basilisk, Interlope, The Beast Within, Tranquilizing Darts, Survival Tactics, Wild Kingdom, Dire Beast: Hawk
	},
	-- Marksmanship Hunter
	[254] = {
		[1] = { 653, 3614, 3729, 5533, 5531, 651, 5419, 649, 5440, 659, 5442, 658, 660, }, -- Chimaeral Sting, Roar of Sacrifice, Hunting Pack, Diamond Ice, Interlope, Survival Tactics, Tranquilizing Darts, Dragonscale Armor, Consecutive Concussion, Ranger's Finesse, Wild Kingdom, Trueshot Mastery, Sniper Shot
		[2] = { 653, 3614, 3729, 5533, 5531, 651, 5419, 649, 5440, 659, 5442, 658, 660, }, -- Chimaeral Sting, Roar of Sacrifice, Hunting Pack, Diamond Ice, Interlope, Survival Tactics, Tranquilizing Darts, Dragonscale Armor, Consecutive Concussion, Ranger's Finesse, Wild Kingdom, Trueshot Mastery, Sniper Shot
		[3] = { 653, 3614, 3729, 5533, 5531, 651, 5419, 649, 5440, 659, 5442, 658, 660, }, -- Chimaeral Sting, Roar of Sacrifice, Hunting Pack, Diamond Ice, Interlope, Survival Tactics, Tranquilizing Darts, Dragonscale Armor, Consecutive Concussion, Ranger's Finesse, Wild Kingdom, Trueshot Mastery, Sniper Shot
	},
	-- Survival Hunter
	[255] = {
		[1] = { 664, 3609, 3607, 5532, 5420, 686, 3610, 5443, 665, 663, 662, 661, }, -- Sticky Tar, Chimaeral Sting, Survival Tactics, Interlope, Tranquilizing Darts, Diamond Ice, Dragonscale Armor, Wild Kingdom, Tracker's Net, Roar of Sacrifice, Mending Bandage, Hunting Pack
		[2] = { 664, 3609, 3607, 5532, 5420, 686, 3610, 5443, 665, 663, 662, 661, }, -- Sticky Tar, Chimaeral Sting, Survival Tactics, Interlope, Tranquilizing Darts, Diamond Ice, Dragonscale Armor, Wild Kingdom, Tracker's Net, Roar of Sacrifice, Mending Bandage, Hunting Pack
		[3] = { 664, 3609, 3607, 5532, 5420, 686, 3610, 5443, 665, 663, 662, 661, }, -- Sticky Tar, Chimaeral Sting, Survival Tactics, Interlope, Tranquilizing Darts, Diamond Ice, Dragonscale Armor, Wild Kingdom, Tracker's Net, Roar of Sacrifice, Mending Bandage, Hunting Pack
	},
	-- Discipline Priest
	[256] = {
		[1] = { 109, 117, 100, 123, 855, 111, 5416, 5475, 5498, 126, 5487, 114, 5483, 98, 5480, }, -- Trinity, Dome of Light, Purified Resolve, Archangel, Thoughtsteal, Strength of Soul, Inner Light and Shadow, Cardinal Mending, Precognition, Dark Archangel, Catharsis, Ultimate Radiance, Eternal Rest, Purification, Delivered from Evil
		[2] = { 109, 117, 100, 123, 855, 111, 5416, 5475, 5498, 126, 5487, 114, 5483, 98, 5480, }, -- Trinity, Dome of Light, Purified Resolve, Archangel, Thoughtsteal, Strength of Soul, Inner Light and Shadow, Cardinal Mending, Precognition, Dark Archangel, Catharsis, Ultimate Radiance, Eternal Rest, Purification, Delivered from Evil
		[3] = { 109, 117, 100, 123, 855, 111, 5416, 5475, 5498, 126, 5487, 114, 5483, 98, 5480, }, -- Trinity, Dome of Light, Purified Resolve, Archangel, Thoughtsteal, Strength of Soul, Inner Light and Shadow, Cardinal Mending, Precognition, Dark Archangel, Catharsis, Ultimate Radiance, Eternal Rest, Purification, Delivered from Evil
	},
	-- Holy Priest
	[257] = {
		[1] = { 127, 124, 115, 5485, 112, 108, 101, 5366, 5365, 5499, 5478, 5476, 5479, 1927, 5482, }, -- Ray of Hope, Spirit of the Redeemer, Cardinal Mending, Catharsis, Greater Heal, Sanctified Ground, Holy Ward, Divine Ascension, Thoughtsteal, Precognition, Purification, Strength of Soul, Purified Resolve, Delivered from Evil, Eternal Rest
		[2] = { 127, 124, 115, 5485, 112, 108, 101, 5366, 5365, 5499, 5478, 5476, 5479, 1927, 5482, }, -- Ray of Hope, Spirit of the Redeemer, Cardinal Mending, Catharsis, Greater Heal, Sanctified Ground, Holy Ward, Divine Ascension, Thoughtsteal, Precognition, Purification, Strength of Soul, Purified Resolve, Delivered from Evil, Eternal Rest
		[3] = { 127, 124, 115, 5485, 112, 108, 101, 5366, 5365, 5499, 5478, 5476, 5479, 1927, 5482, }, -- Ray of Hope, Spirit of the Redeemer, Cardinal Mending, Catharsis, Greater Heal, Sanctified Ground, Holy Ward, Divine Ascension, Thoughtsteal, Precognition, Purification, Strength of Soul, Purified Resolve, Delivered from Evil, Eternal Rest
	},
	-- Shadow Priest
	[258] = {
		[1] = { 106, 5447, 5486, 5481, 5484, 763, 5477, 5474, 5500, 739, 113, 5381, }, -- Driven to Madness, Void Volley, Catharsis, Delivered from Evil, Eternal Rest, Psyfiend, Strength of Soul, Cardinal Mending, Precognition, Void Origins, Mind Trauma, Thoughtsteal
		[2] = { 106, 5447, 5486, 5481, 5484, 763, 5477, 5474, 5500, 739, 113, 5381, }, -- Driven to Madness, Void Volley, Catharsis, Delivered from Evil, Eternal Rest, Psyfiend, Strength of Soul, Cardinal Mending, Precognition, Void Origins, Mind Trauma, Thoughtsteal
		[3] = { 106, 5447, 5486, 5481, 5484, 763, 5477, 5474, 5500, 739, 113, 5381, }, -- Driven to Madness, Void Volley, Catharsis, Delivered from Evil, Eternal Rest, Psyfiend, Strength of Soul, Cardinal Mending, Precognition, Void Origins, Mind Trauma, Thoughtsteal
	},
	-- Assassination Rogue
	[259] = {
		[1] = { 141, 147, 5408, 3479, 5530, 5517, 3480, 5405, 830, 5550, 3448, }, -- Creeping Venom, System Shock, Thick as Thieves, Death from Above, Control is King, Veil of Midnight, Smoke Bomb, Dismantle, Hemotoxin, Dagger in the Dark, Maneuverability
		[2] = { 141, 147, 5408, 3479, 5530, 5517, 3480, 5405, 830, 5550, 3448, }, -- Creeping Venom, System Shock, Thick as Thieves, Death from Above, Control is King, Veil of Midnight, Smoke Bomb, Dismantle, Hemotoxin, Dagger in the Dark, Maneuverability
		[3] = { 141, 147, 5408, 3479, 5530, 5517, 3480, 5405, 830, 5550, 3448, }, -- Creeping Venom, System Shock, Thick as Thieves, Death from Above, Control is King, Veil of Midnight, Smoke Bomb, Dismantle, Hemotoxin, Dagger in the Dark, Maneuverability
	},
	-- Outlaw Rogue
	[260] = {
		[1] = { 138, 145, 129, 3421, 5549, 853, 3619, 5516, 3483, 1208, 135, 5412, 139, }, -- Control is King, Dismantle, Maneuverability, Turn the Tables, Dagger in the Dark, Boarding Party, Death from Above, Veil of Midnight, Smoke Bomb, Thick as Thieves, Take Your Cut, Enduring Brawler, Drink Up Me Hearties
		[2] = { 138, 145, 129, 3421, 5549, 853, 3619, 5516, 3483, 1208, 135, 5412, 139, }, -- Control is King, Dismantle, Maneuverability, Turn the Tables, Dagger in the Dark, Boarding Party, Death from Above, Veil of Midnight, Smoke Bomb, Thick as Thieves, Take Your Cut, Enduring Brawler, Drink Up Me Hearties
		[3] = { 138, 145, 129, 3421, 5549, 853, 3619, 5516, 3483, 1208, 135, 5412, 139, }, -- Control is King, Dismantle, Maneuverability, Turn the Tables, Dagger in the Dark, Boarding Party, Death from Above, Veil of Midnight, Smoke Bomb, Thick as Thieves, Take Your Cut, Enduring Brawler, Drink Up Me Hearties
	},
	-- Subtlety Rogue
	[261] = {
		[1] = { 5406, 5409, 5411, 5529, 136, 146, 153, 846, 856, 1209, 3447, 3462, }, -- Dismantle, Thick as Thieves, Distracting Mirage, Control is King, Veil of Midnight, Thief's Bargain, Shadowy Duel, Dagger in the Dark, Silhouette, Smoke Bomb, Maneuverability, Death from Above
		[2] = { 5406, 5409, 5411, 5529, 136, 146, 153, 846, 856, 1209, 3447, 3462, }, -- Dismantle, Thick as Thieves, Distracting Mirage, Control is King, Veil of Midnight, Thief's Bargain, Shadowy Duel, Dagger in the Dark, Silhouette, Smoke Bomb, Maneuverability, Death from Above
		[3] = { 5406, 5409, 5411, 5529, 136, 146, 153, 846, 856, 1209, 3447, 3462, }, -- Dismantle, Thick as Thieves, Distracting Mirage, Control is King, Veil of Midnight, Thief's Bargain, Shadowy Duel, Dagger in the Dark, Silhouette, Smoke Bomb, Maneuverability, Death from Above
	},
	-- Elemental Shaman
	[262] = {
		[1] = { 3490, 3491, 3621, 3620, 5457, 3062, 5415, 727, 728, 730, 5519, 3488, }, -- Counterstrike Totem, Unleash Shield, Swelling Waves, Grounding Totem, Precognition, Spectral Recovery, Seasoned Winds, Static Field Totem, Control of Lava, Traveling Storms, Tidebringer, Skyfury Totem
		[2] = { 3490, 3491, 3621, 3620, 5457, 3062, 5415, 727, 728, 730, 5519, 3488, }, -- Counterstrike Totem, Unleash Shield, Swelling Waves, Grounding Totem, Precognition, Spectral Recovery, Seasoned Winds, Static Field Totem, Control of Lava, Traveling Storms, Tidebringer, Skyfury Totem
		[3] = { 3490, 3491, 3621, 3620, 5457, 3062, 5415, 727, 728, 730, 5519, 3488, }, -- Counterstrike Totem, Unleash Shield, Swelling Waves, Grounding Totem, Precognition, Spectral Recovery, Seasoned Winds, Static Field Totem, Control of Lava, Traveling Storms, Tidebringer, Skyfury Totem
	},
	-- Enhancement Shaman
	[263] = {
		[1] = { 3489, 3622, 3519, 5438, 1944, 721, 5527, 722, 725, 3623, 5414, 5518, 3487, 3492, }, -- Counterstrike Totem, Grounding Totem, Spectral Recovery, Static Field Totem, Ethereal Form, Ride the Lightning, Traveling Storms, Shamanism, Thundercharge, Swelling Waves, Seasoned Winds, Tidebringer, Skyfury Totem, Unleash Shield
		[2] = { 3489, 3622, 3519, 5438, 1944, 721, 5527, 722, 725, 3623, 5414, 5518, 3487, 3492, }, -- Counterstrike Totem, Grounding Totem, Spectral Recovery, Static Field Totem, Ethereal Form, Ride the Lightning, Traveling Storms, Shamanism, Thundercharge, Swelling Waves, Seasoned Winds, Tidebringer, Skyfury Totem, Unleash Shield
		[3] = { 3489, 3622, 3519, 5438, 1944, 721, 5527, 722, 725, 3623, 5414, 5518, 3487, 3492, }, -- Counterstrike Totem, Grounding Totem, Spectral Recovery, Static Field Totem, Ethereal Form, Ride the Lightning, Traveling Storms, Shamanism, Thundercharge, Swelling Waves, Seasoned Winds, Tidebringer, Skyfury Totem, Unleash Shield
	},
	-- Restoration Shaman
	[264] = {
		[1] = { 3755, 5528, 712, 5458, 1930, 5437, 3520, 714, 715, 5388, 707, 708, }, -- Cleansing Waters, Traveling Storms, Swelling Waves, Precognition, Tidebringer, Unleash Shield, Spectral Recovery, Electrocute, Grounding Totem, Living Tide, Skyfury Totem, Counterstrike Totem
		[2] = { 3755, 5528, 712, 5458, 1930, 5437, 3520, 714, 715, 5388, 707, 708, }, -- Cleansing Waters, Traveling Storms, Swelling Waves, Precognition, Tidebringer, Unleash Shield, Spectral Recovery, Electrocute, Grounding Totem, Living Tide, Skyfury Totem, Counterstrike Totem
		[3] = { 3755, 5528, 712, 5458, 1930, 5437, 3520, 714, 715, 5388, 707, 708, }, -- Cleansing Waters, Traveling Storms, Swelling Waves, Precognition, Tidebringer, Unleash Shield, Spectral Recovery, Electrocute, Grounding Totem, Living Tide, Skyfury Totem, Counterstrike Totem
	},
	-- Affliction Warlock
	[265] = {
		[1] = { 5386, 12, 5543, 15, 5379, 11, 5546, 20, 16, 5392, 5506, 17, 18, 19, }, -- Rapid Contagion, Deathbolt, Call Observer, Gateway Mastery, Rampant Afflictions, Bane of Fragility, Bonds of Fel, Casting Circle, Rot and Decay, Shadow Rift, Precognition, Bane of Shadows, Nether Ward, Essence Drain
		[2] = { 5386, 12, 5543, 15, 5379, 11, 5546, 20, 16, 5392, 5506, 17, 18, 19, }, -- Rapid Contagion, Deathbolt, Call Observer, Gateway Mastery, Rampant Afflictions, Bane of Fragility, Bonds of Fel, Casting Circle, Rot and Decay, Shadow Rift, Precognition, Bane of Shadows, Nether Ward, Essence Drain
		[3] = { 5386, 12, 5543, 15, 5379, 11, 5546, 20, 16, 5392, 5506, 17, 18, 19, }, -- Rapid Contagion, Deathbolt, Call Observer, Gateway Mastery, Rampant Afflictions, Bane of Fragility, Bonds of Fel, Casting Circle, Rot and Decay, Shadow Rift, Precognition, Bane of Shadows, Nether Ward, Essence Drain
	},
	-- Demonology Warlock
	[266] = {
		[1] = { 3624, 156, 158, 162, 165, 5505, 3506, 5394, 3505, 5400, 3626, 5545, 1213, 3625, }, -- Nether Ward, Call Felhunter, Pleasure through Pain, Call Fel Lord, Call Observer, Precognition, Gateway Mastery, Shadow Rift, Bane of Fragility, Fel Obelisk, Casting Circle, Bonds of Fel, Master Summoner, Essence Drain
		[2] = { 3624, 156, 158, 162, 165, 5505, 3506, 5394, 3505, 5400, 3626, 5545, 1213, 3625, }, -- Nether Ward, Call Felhunter, Pleasure through Pain, Call Fel Lord, Call Observer, Precognition, Gateway Mastery, Shadow Rift, Bane of Fragility, Fel Obelisk, Casting Circle, Bonds of Fel, Master Summoner, Essence Drain
		[3] = { 3624, 156, 158, 162, 165, 5505, 3506, 5394, 3505, 5400, 3626, 5545, 1213, 3625, }, -- Nether Ward, Call Felhunter, Pleasure through Pain, Call Fel Lord, Call Observer, Precognition, Gateway Mastery, Shadow Rift, Bane of Fragility, Fel Obelisk, Casting Circle, Bonds of Fel, Master Summoner, Essence Drain
	},
	-- Destruction Warlock
	[267] = {
		[1] = { 3509, 164, 5382, 5401, 5544, 3508, 5393, 5507, 157, 3510, 3502, 159, }, -- Essence Drain, Bane of Havoc, Gateway Mastery, Bonds of Fel, Call Observer, Nether Ward, Shadow Rift, Precognition, Fel Fissure, Casting Circle, Bane of Fragility, Cremation
		[2] = { 3509, 164, 5382, 5401, 5544, 3508, 5393, 5507, 157, 3510, 3502, 159, }, -- Essence Drain, Bane of Havoc, Gateway Mastery, Bonds of Fel, Call Observer, Nether Ward, Shadow Rift, Precognition, Fel Fissure, Casting Circle, Bane of Fragility, Cremation
		[3] = { 3509, 164, 5382, 5401, 5544, 3508, 5393, 5507, 157, 3510, 3502, 159, }, -- Essence Drain, Bane of Havoc, Gateway Mastery, Bonds of Fel, Call Observer, Nether Ward, Shadow Rift, Precognition, Fel Fissure, Casting Circle, Bane of Fragility, Cremation
	},
	-- Brewmaster Monk
	[268] = {
		[1] = { 668, 669, 670, 671, 765, 5538, 843, 673, 5541, 5542, 1958, 5552, 5417, 672, 666, 667, }, -- Guided Meditation, Avert Harm, Nimble Brew, Incendiary Breath, Eerie Fermentation, Grapple Weapon, Admonishment, Mighty Ox Kick, Dematerialize, Wind Waker, Niuzao's Essence, Alpha Tiger, Rodeo, Double Barrel, Microbrew, Hot Trub
		[2] = { 668, 669, 670, 671, 765, 5538, 843, 673, 5541, 5542, 1958, 5552, 5417, 672, 666, 667, }, -- Guided Meditation, Avert Harm, Nimble Brew, Incendiary Breath, Eerie Fermentation, Grapple Weapon, Admonishment, Mighty Ox Kick, Dematerialize, Wind Waker, Niuzao's Essence, Alpha Tiger, Rodeo, Double Barrel, Microbrew, Hot Trub
		[3] = { 668, 669, 670, 671, 765, 5538, 843, 673, 5541, 5542, 1958, 5552, 5417, 672, 666, 667, }, -- Guided Meditation, Avert Harm, Nimble Brew, Incendiary Breath, Eerie Fermentation, Grapple Weapon, Admonishment, Mighty Ox Kick, Dematerialize, Wind Waker, Niuzao's Essence, Alpha Tiger, Rodeo, Double Barrel, Microbrew, Hot Trub
	},
	-- Windwalker Monk
	[269] = {
		[1] = { 3744, 3052, 5540, 675, 3050, 77, 5448, 3734, 852, 3745, 3737, }, -- Pressure Points, Grapple Weapon, Mighty Ox Kick, Tigereye Brew, Disabling Reach, Ride the Wind, Perpetual Paralysis, Alpha Tiger, Reverse Harm, Turbo Fists, Wind Waker
		[2] = { 3744, 3052, 5540, 675, 3050, 77, 5448, 3734, 852, 3745, 3737, }, -- Pressure Points, Grapple Weapon, Mighty Ox Kick, Tigereye Brew, Disabling Reach, Ride the Wind, Perpetual Paralysis, Alpha Tiger, Reverse Harm, Turbo Fists, Wind Waker
		[3] = { 3744, 3052, 5540, 675, 3050, 77, 5448, 3734, 852, 3745, 3737, }, -- Pressure Points, Grapple Weapon, Mighty Ox Kick, Tigereye Brew, Disabling Reach, Ride the Wind, Perpetual Paralysis, Alpha Tiger, Reverse Harm, Turbo Fists, Wind Waker
	},
	-- Mistweaver Monk
	[270] = {
		[1] = { 5508, 70, 5539, 3732, 5551, 5395, 5398, 5402, 1928, 683, 682, 680, 679, 678, }, -- Precognition, Eminence, Mighty Ox Kick, Grapple Weapon, Alpha Tiger, Peaceweaver, Dematerialize, Thunderous Focus Tea, Zen Focus Tea, Healing Sphere, Refreshing Breeze, Dome of Mist, Counteract Magic, Chrysalis
		[2] = { 5508, 70, 5539, 3732, 5551, 5395, 5398, 5402, 1928, 683, 682, 680, 679, 678, }, -- Precognition, Eminence, Mighty Ox Kick, Grapple Weapon, Alpha Tiger, Peaceweaver, Dematerialize, Thunderous Focus Tea, Zen Focus Tea, Healing Sphere, Refreshing Breeze, Dome of Mist, Counteract Magic, Chrysalis
		[3] = { 5508, 70, 5539, 3732, 5551, 5395, 5398, 5402, 1928, 683, 682, 680, 679, 678, }, -- Precognition, Eminence, Mighty Ox Kick, Grapple Weapon, Alpha Tiger, Peaceweaver, Dematerialize, Thunderous Focus Tea, Zen Focus Tea, Healing Sphere, Refreshing Breeze, Dome of Mist, Counteract Magic, Chrysalis
	},
	-- Havoc Demon Hunter
	[577] = {
		[1] = { 1206, 813, 1218, 812, 5433, 811, 5523, 809, 805, 806, }, -- Cover of Darkness, Glimpse, Unending Hatred, Detainment, Blood Moon, Rain from Above, Sigil Mastery, Chaotic Imprint, Cleansed by Flame, Reverse Magic
		[2] = { 1206, 813, 1218, 812, 5433, 811, 5523, 809, 805, 806, }, -- Cover of Darkness, Glimpse, Unending Hatred, Detainment, Blood Moon, Rain from Above, Sigil Mastery, Chaotic Imprint, Cleansed by Flame, Reverse Magic
		[3] = { 1206, 813, 1218, 812, 5433, 811, 5523, 809, 805, 806, }, -- Cover of Darkness, Glimpse, Unending Hatred, Detainment, Blood Moon, Rain from Above, Sigil Mastery, Chaotic Imprint, Cleansed by Flame, Reverse Magic
	},
	-- Vengeance Demon Hunter
	[581] = {
		[1] = { 5439, 5434, 1220, 3727, 3429, 3423, 1948, 3430, 5521, 814, 815, 816, 819, 5520, 5522, }, -- Chaotic Imprint, Blood Moon, Tormentor, Unending Hatred, Reverse Magic, Demonic Trample, Sigil Mastery, Detainment, Rain from Above, Cleansed by Flame, Everlasting Hunt, Jagged Spikes, Illidan's Grasp, Cover of Darkness, Glimpse
		[2] = { 5439, 5434, 1220, 3727, 3429, 3423, 1948, 3430, 5521, 814, 815, 816, 819, 5520, 5522, }, -- Chaotic Imprint, Blood Moon, Tormentor, Unending Hatred, Reverse Magic, Demonic Trample, Sigil Mastery, Detainment, Rain from Above, Cleansed by Flame, Everlasting Hunt, Jagged Spikes, Illidan's Grasp, Cover of Darkness, Glimpse
		[3] = { 5439, 5434, 1220, 3727, 3429, 3423, 1948, 3430, 5521, 814, 815, 816, 819, 5520, 5522, }, -- Chaotic Imprint, Blood Moon, Tormentor, Unending Hatred, Reverse Magic, Demonic Trample, Sigil Mastery, Detainment, Rain from Above, Cleansed by Flame, Everlasting Hunt, Jagged Spikes, Illidan's Grasp, Cover of Darkness, Glimpse
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
