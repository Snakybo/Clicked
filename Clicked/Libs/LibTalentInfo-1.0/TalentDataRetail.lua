--- @type LibTalentInfo
local LibTalentInfo = LibStub and LibStub("LibTalentInfo-1.0", true)
local version = 39172

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
}

--- @type table<integer,integer[]>
local talents = {
	-- Arcane Mage
	[62] = {
		22458, 22461, 22464, -- Amplification, Rule of Threes, Arcane Familiar
		23072, 22443, 16025, -- Master of Time, Shimmer, Slipstream
		22444, 22445, 22447, -- Incanter's Flow, Focus Magic, Rune of Power
		22453, 22467, 22470, -- Resonance, Arcane Echo, Nether Tempest
		22907, 22448, 22471, -- Chrono Shift, Ice Ward, Ring of Frost
		22455, 22449, 22474, -- Reverberate, Arcane Orb, Supernova
		21630, 21144, 21145, -- Overpowered, Time Anomaly, Enlightened
	},
	-- Fire Mage
	[63] = {
		22456, 22459, 22462, -- Firestarter, Pyromaniac, Searing Touch
		23071, 22443, 23074, -- Blazing Soul, Shimmer, Blast Wave
		22444, 22445, 22447, -- Incanter's Flow, Focus Magic, Rune of Power
		22450, 22465, 22468, -- Flame On, Alexstrasza's Fury, From the Ashes
		22904, 22448, 22471, -- Frenetic Speed, Ice Ward, Ring of Frost
		22451, 23362, 22472, -- Flame Patch, Conflagration, Living Bomb
		21631, 22220, 21633, -- Kindling, Pyroclasm, Meteor
	},
	-- Frost Mage
	[64] = {
		22457, 22460, 22463, -- Bone Chilling, Lonely Winter, Ice Nova
		22442, 22443, 23073, -- Glacial Insulation, Shimmer, Ice Floes
		22444, 22445, 22447, -- Incanter's Flow, Focus Magic, Rune of Power
		22452, 22466, 22469, -- Frozen Touch, Chain Reaction, Ebonbolt
		22446, 22448, 22471, -- Frigid Winds, Ice Ward, Ring of Frost
		22454, 23176, 22473, -- Freezing Rain, Splitting Ice, Comet Storm
		21632, 22309, 21634, -- Thermal Void, Ray of Frost, Glacial Spike
	},
	-- Holy Paladin
	[65] = {
		17565, 17567, 17569, -- Crusader's Might, Bestow Faith, Light's Hammer
		22176, 17575, 17577, -- Saved by the Light, Judgment of Light, Holy Prism
		22179, 22180, 21811, -- Fist of Justice, Repentance, Blinding Light
		22433, 22434, 17593, -- Unbreakable Spirit, Cavalier, Rule of Law
		17597, 17599, 17601, -- Divine Purpose, Holy Avenger, Seraphim
		23191, 22190, 22484, -- Sanctified Wrath, Avenging Crusader, Awakening
		21201, 21671, 21203, -- Glimmer of Light, Beacon of Faith, Beacon of Virtue
	},
	-- Protection Paladin
	[66] = {
		22428, 22558, 23469, -- Holy Shield, Redoubt, Blessed Hammer
		22431, 22604, 23468, -- First Avenger, Crusader's Judgment, Moment of Glory
		22179, 22180, 21811, -- Fist of Justice, Repentance, Blinding Light
		22433, 22434, 22435, -- Unbreakable Spirit, Cavalier, Blessing of Spellwarding
		17597, 17599, 17601, -- Divine Purpose, Holy Avenger, Seraphim
		22189, 22438, 23087, -- Hand of the Protector, Consecrated Ground, Judgment of Light
		23457, 21202, 22645, -- Sanctified Wrath, Righteous Protector, Final Stand
	},
	-- Retribution Paladin
	[70] = {
		22590, 22557, 23467, -- Zeal, Righteous Verdict, Execution Sentence
		22319, 22592, 23466, -- Fires of Justice, Blade of Wrath, Empyrean Power
		22179, 22180, 21811, -- Fist of Justice, Repentance, Blinding Light
		22433, 22434, 22183, -- Unbreakable Spirit, Cavalier, Eye for an Eye
		17597, 17599, 17601, -- Divine Purpose, Holy Avenger, Seraphim
		23167, 22483, 23086, -- Selfless Healer, Justicar's Vengeance, Healing Hands
		23456, 22215, 22634, -- Sanctified Wrath, Crusade, Final Reckoning
	},
	-- Arms Warrior
	[71] = {
		22624, 22360, 22371, -- War Machine, Sudden Death, Skullsplitter
		19676, 22372, 22789, -- Double Time, Impending Victory, Storm Bolt
		22380, 22489, 19138, -- Massacre, Fervor of Battle, Rend
		15757, 22627, 22628, -- Second Wind, Bounding Stride, Defensive Stance
		22392, 22391, 22362, -- Collateral Damage, Warbreaker, Cleave
		22394, 22397, 22399, -- In For The Kill, Avatar, Deadly Calm
		21204, 22407, 21667, -- Anger Management, Dreadnaught, Ravager
	},
	-- Fury Warrior
	[72] = {
		22632, 22633, 22491, -- War Machine, Sudden Death, Fresh Meat
		19676, 22625, 23093, -- Double Time, Impending Victory, Storm Bolt
		22379, 22381, 23372, -- Massacre, Frenzy, Onslaught
		23097, 22627, 22382, -- Furious Charge, Bounding Stride, Warpaint
		22383, 22393, 19140, -- Seethe, Frothing Berserker, Cruelty
		22396, 22398, 22400, -- Meat Cleaver, Dragon Roar, Bladestorm
		22405, 22402, 16037, -- Anger Management, Reckless Abandon, Siegebreaker
	},
	-- Protection Warrior
	[73] = {
		15760, 15759, 15774, -- War Machine, Punish, Devastator
		19676, 22629, 22409, -- Double Time, Rumbling Earth, Storm Bolt
		22378, 22626, 23260, -- Best Served Cold, Booming Voice, Dragon Roar
		23096, 22627, 22488, -- Crackling Thunder, Bounding Stride, Menace
		22384, 22631, 22800, -- Never Surrender, Indomitable, Impending Victory
		22395, 22544, 22401, -- Into the Fray, Unstoppable Force, Ravager
		23455, 22406, 23099, -- Anger Management, Heavy Repercussions, Bolster
	},
	-- Balance Druid
	[102] = {
		22385, 22386, 22387, -- Nature's Balance, Warrior of Elune, Force of Nature
		19283, 18570, 18571, -- Tiger Dash, Renewal, Wild Charge
		22155, 22157, 22159, -- Feral Affinity, Guardian Affinity, Restoration Affinity
		21778, 18576, 18577, -- Mighty Bash, Mass Entanglement, Heart of the Wild
		18580, 21706, 21702, -- Soul of the Forest, Starlord, Incarnation: Chosen of Elune
		22389, 21712, 22165, -- Twin Moons, Stellar Drift, Stellar Flare
		21648, 21193, 21655, -- Solstice, Fury of Elune, New Moon
	},
	-- Feral Druid
	[103] = {
		22363, 22364, 22365, -- Predator, Sabertooth, Lunar Inspiration
		19283, 18570, 18571, -- Tiger Dash, Renewal, Wild Charge
		22163, 22158, 22159, -- Balance Affinity, Guardian Affinity, Restoration Affinity
		21778, 18576, 18577, -- Mighty Bash, Mass Entanglement, Heart of the Wild
		21708, 18579, 21704, -- Soul of the Forest, Savage Roar, Incarnation: King of the Jungle
		21714, 21711, 22370, -- Scent of Blood, Brutal Slash, Primal Wrath
		21646, 21649, 21653, -- Moment of Clarity, Bloodtalons, Feral Frenzy
	},
	-- Guardian Druid
	[104] = {
		22419, 22418, 22420, -- Brambles, Blood Frenzy, Bristling Fur
		19283, 18570, 18571, -- Tiger Dash, Renewal, Wild Charge
		22163, 22156, 22159, -- Balance Affinity, Feral Affinity, Restoration Affinity
		21778, 18576, 18577, -- Mighty Bash, Mass Entanglement, Heart of the Wild
		21709, 21707, 22388, -- Soul of the Forest, Galactic Guardian, Incarnation: Guardian of Ursoc
		22423, 21713, 22390, -- Earthwarden, Survival of the Fittest, Guardian of Elune
		22426, 22427, 22425, -- Rend and Tear, Tooth and Claw, Pulverize
	},
	-- Restoration Druid
	[105] = {
		18569, 18574, 18572, -- Abundance, Nourish, Cenarion Ward
		19283, 18570, 18571, -- Tiger Dash, Renewal, Wild Charge
		22366, 22367, 22160, -- Balance Affinity, Feral Affinity, Guardian Affinity
		21778, 18576, 18577, -- Mighty Bash, Mass Entanglement, Heart of the Wild
		21710, 21705, 22421, -- Soul of the Forest, Cultivation, Incarnation: Tree of Life
		21716, 18585, 22422, -- Inner Peace, Spring Blossoms, Overgrowth
		22403, 21651, 22404, -- Photosynthesis, Germination, Flourish
	},
	-- Blood Death Knight
	[250] = {
		19165, 19166, 23454, -- Heartbreaker, Blooddrinker, Tombstone
		19218, 19219, 19220, -- Rapid Decomposition, Hemostasis, Consumption
		19221, 22134, 22135, -- Foul Bulwark, Relish in Blood, Blood Tap
		22013, 22014, 22015, -- Will of the Necropolis, Anti-Magic Barrier, Mark of Blood
		19227, 19226, 19228, -- Grip of the Dead, Tightening Grasp, Wraith Walk
		19230, 19231, 19232, -- Voracious, Death Pact, Bloodworms
		21207, 21208, 21209, -- Purgatory, Red Thirst, Bonestorm
	},
	-- Frost Death Knight
	[251] = {
		22016, 22017, 22018, -- Inexorable Assault, Icy Talons, Cold Heart
		22019, 22020, 22021, -- Runic Attenuation, Murderous Efficiency, Horn of Winter
		22515, 22517, 22519, -- Death's Reach, Asphyxiate, Blinding Sleet
		22521, 22523, 22525, -- Avalanche, Frozen Pulse, Frostscythe
		22527, 22530, 23373, -- Permafrost, Wraith Walk, Death Pact
		22531, 22533, 22535, -- Gathering Storm, Hypothermic Presence, Glacial Advance
		22023, 22109, 22537, -- Icecap, Obliteration, Breath of Sindragosa
	},
	-- Unholy Death Knight
	[252] = {
		22024, 22025, 22026, -- Infected Claws, All Will Serve, Clawing Shadows
		22027, 22028, 22029, -- Bursting Sores, Ebon Fever, Unholy Blight
		22516, 22518, 22520, -- Grip of the Dead, Death's Reach, Asphyxiate
		22522, 22524, 22526, -- Pestilent Pustules, Harbinger of Doom, Soul Reaper
		22528, 22529, 23373, -- Spell Eater, Wraith Walk, Death Pact
		22532, 22534, 22536, -- Pestilence, Unholy Pact, Defile
		22030, 22110, 22538, -- Army of the Damned, Summon Gargoyle, Unholy Assault
	},
	-- Beast Mastery Hunter
	[253] = {
		22291, 22280, 22282, -- Killer Instinct, Animal Companion, Dire Beast
		22500, 22266, 22290, -- Scent of Blood, One with the Pack, Chimaera Shot
		19347, 19348, 23100, -- Trailblazer, Natural Mending, Camouflage
		22441, 22347, 22269, -- Spitting Cobra, Thrill of the Hunt, A Murder of Crows
		22268, 22276, 22499, -- Born To Be Wild, Posthaste, Binding Shot
		19357, 22002, 23044, -- Stomp, Barrage, Stampede
		22273, 21986, 22295, -- Aspect of the Beast, Killer Cobra, Bloodshed
	},
	-- Marksmanship Hunter
	[254] = {
		22279, 22501, 22289, -- Master Marksman, Serpent Sting, A Murder of Crows
		22495, 22497, 22498, -- Careful Aim, Barrage, Explosive Shot
		19347, 19348, 23100, -- Trailblazer, Natural Mending, Camouflage
		22267, 22286, 21998, -- Steady Focus, Streamline, Chimaera Shot
		22268, 22276, 23463, -- Born To Be Wild, Posthaste, Binding Shackles
		23063, 23104, 22287, -- Lethal Shots, Dead Eye, Double Tap
		22274, 22308, 22288, -- Calling the Shots, Lock and Load, Volley
	},
	-- Survival Hunter
	[255] = {
		22275, 22283, 22296, -- Viper's Venom, Terms of Engagement, Alpha Predator
		21997, 22769, 22297, -- Guerrilla Tactics, Hydra's Bite, Butchery
		19347, 19348, 23100, -- Trailblazer, Natural Mending, Camouflage
		22277, 19361, 22299, -- Bloodseeker, Steel Trap, A Murder of Crows
		22268, 22276, 22499, -- Born To Be Wild, Posthaste, Binding Shot
		22300, 22278, 22271, -- Tip of the Spear, Mongoose Bite, Flanking Strike
		22272, 22301, 23105, -- Birds of Prey, Wildfire Infusion, Chakrams
	},
	-- Discipline Priest
	[256] = {
		19752, 22313, 22329, -- Castigation, Twist of Fate, Schism
		22315, 22316, 19758, -- Body and Soul, Masochism, Angelic Feather
		22440, 22094, 19755, -- Shield Discipline, Mindbender, Power Word: Solace
		19759, 19769, 19761, -- Psychic Voice, Dominant Mind, Shining Force
		22330, 19765, 19766, -- Sins of the Many, Contrition, Shadow Covenant
		22161, 19760, 19763, -- Purge the Wicked, Divine Star, Halo
		21183, 21184, 22976, -- Lenience, Spirit Shell, Evangelism
	},
	-- Holy Priest
	[257] = {
		22312, 19753, 19754, -- Enlightenment, Trail of Light, Renewed Faith
		22325, 22326, 19758, -- Angel's Mercy, Body and Soul, Angelic Feather
		22487, 22095, 22562, -- Cosmic Ripple, Guardian Angel, Afterlife
		21750, 21977, 19761, -- Psychic Voice, Censure, Shining Force
		19764, 22327, 21754, -- Surge of Light, Binding Heal, Prayer Circle
		19767, 19760, 19763, -- Benediction, Divine Star, Halo
		21636, 21644, 23145, -- Light of the Naaru, Apotheosis, Holy Word: Salvation
	},
	-- Shadow Priest
	[258] = {
		22328, 22136, 22314, -- Fortress of the Mind, Death and Madness, Unfurling Darkness
		22315, 23374, 21976, -- Body and Soul, San'layn, Intangibility
		23125, 23126, 23127, -- Twist of Fate, Misery, Searing Nightmare
		23137, 23375, 21752, -- Last Word, Mind Bomb, Psychic Horror
		22310, 22311, 21755, -- Auspicious Spirits, Psychic Link, Shadow Crash
		21718, 21719, 21720, -- Damnation, Mindbender, Void Torrent
		21637, 21978, 21979, -- Ancient Madness, Hungering Void, Surrender to Madness
	},
	-- Assassination Rogue
	[259] = {
		22337, 22338, 22339, -- Master Poisoner, Elaborate Planning, Blindside
		22331, 22332, 23022, -- Nightstalker, Subterfuge, Master Assassin
		19239, 19240, 19241, -- Vigor, Deeper Stratagem, Marked for Death
		22340, 22122, 22123, -- Leeching Poison, Cheat Death, Elusiveness
		19245, 23037, 22115, -- Internal Bleeding, Iron Wire, Prey on the Weak
		22343, 23015, 22344, -- Venom Rush, Alacrity, Exsanguinate
		21186, 22133, 23174, -- Poison Bomb, Hidden Blades, Crimson Tempest
	},
	-- Outlaw Rogue
	[260] = {
		22118, 22119, 22120, -- Weaponmaster, Quick Draw, Ghostly Strike
		23470, 19237, 19238, -- Acrobatic Strikes, Retractable Hook, Hit and Run
		19239, 19240, 19241, -- Vigor, Deeper Stratagem, Marked for Death
		22121, 22122, 22123, -- Iron Stomach, Cheat Death, Elusiveness
		23077, 22114, 22115, -- Dirty Tricks, Blinding Powder, Prey on the Weak
		21990, 23128, 19250, -- Loaded Dice, Alacrity, Dreadblades
		22125, 23075, 23175, -- Dancing Steel, Blade Rush, Killing Spree
	},
	-- Subtlety Rogue
	[261] = {
		19233, 19234, 19235, -- Weaponmaster, Premeditation, Gloomblade
		22331, 22332, 22333, -- Nightstalker, Subterfuge, Shadow Focus
		19239, 19240, 19241, -- Vigor, Deeper Stratagem, Marked for Death
		22128, 22122, 22123, -- Soothing Darkness, Cheat Death, Elusiveness
		23078, 23036, 22115, -- Shot in the Dark, Night Terrors, Prey on the Weak
		22335, 19249, 22336, -- Dark Shadow, Alacrity, Enveloping Shadows
		22132, 23183, 21188, -- Master of Shadows, Secret Technique, Shuriken Tornado
	},
	-- Elemental Shaman
	[262] = {
		22356, 22357, 22358, -- Earthen Rage, Echo of the Elements, Static Discharge
		23108, 23460, 23190, -- Aftershock, Echoing Shock, Elemental Blast
		23162, 23163, 23164, -- Spirit Wolf, Earth Shield, Static Charge
		19271, 19272, 19273, -- Master of the Elements, Storm Elemental, Liquid Magma Totem
		22144, 22172, 21966, -- Nature's Guardian, Ancestral Guidance, Wind Rush Totem
		22145, 19266, 23111, -- Surge of Power, Primal Elementalist, Icefury
		21198, 22153, 21675, -- Unlimited Power, Stormkeeper, Ascendance
	},
	-- Enhancement Shaman
	[263] = {
		22354, 22355, 22353, -- Lashing Flames, Forceful Winds, Elemental Blast
		22636, 23462, 23109, -- Stormflurry, Hot Hand, Ice Strike
		23165, 19260, 23166, -- Spirit Wolf, Earth Shield, Static Charge
		23089, 23090, 22171, -- Elemental Assault, Hailstorm, Fire Nova
		22144, 22149, 21966, -- Nature's Guardian, Feral Lunge, Wind Rush Totem
		21973, 22352, 22351, -- Crashing Storm, Stormkeeper, Sundering
		21970, 22977, 21972, -- Elemental Spirits, Earthen Spike, Ascendance
	},
	-- Restoration Shaman
	[264] = {
		19262, 19263, 19264, -- Torrent, Undulation, Unleash Life
		19259, 23461, 21963, -- Echo of the Elements, Deluge, Surge of Earth
		19275, 23110, 22127, -- Spirit Wolf, Earthgrab Totem, Static Charge
		22152, 22322, 22323, -- Ancestral Vigor, Earthen Wall Totem, Ancestral Protection Totem
		22144, 19269, 21966, -- Nature's Guardian, Graceful Spirit, Wind Rush Totem
		19265, 21971, 21968, -- Flash Flood, Downpour, Cloudburst Totem
		21969, 21199, 22359, -- High Tide, Wellspring, Ascendance
	},
	-- Affliction Warlock
	[265] = {
		22039, 23140, 23141, -- Nightfall, Inevitable Demise, Drain Soul
		22044, 21180, 22089, -- Writhe in Agony, Absolute Corruption, Siphon Life
		19280, 19285, 19286, -- Demon Skin, Burning Rush, Dark Pact
		19279, 19292, 22046, -- Sow the Seeds, Phantom Singularity, Vile Taint
		22047, 19291, 23465, -- Darkfury, Mortal Coil, Howl of Terror
		23139, 23159, 19295, -- Shadow Embrace, Haunt, Grimoire of Sacrifice
		19284, 19281, 19293, -- Soul Conduit, Creeping Death, Dark Soul: Misery
	},
	-- Demonology Warlock
	[266] = {
		19290, 22048, 23138, -- Dreadlash, Bilescourge Bombers, Demonic Strength
		22045, 21694, 23158, -- Demonic Calling, Power Siphon, Doom
		19280, 19285, 19286, -- Demon Skin, Burning Rush, Dark Pact
		22477, 22042, 23160, -- From the Shadows, Soul Strike, Summon Vilefiend
		22047, 19291, 23465, -- Darkfury, Mortal Coil, Howl of Terror
		23147, 23146, 21717, -- Soul Conduit, Inner Demons, Grimoire: Felguard
		23161, 22479, 23091, -- Sacrificed Souls, Demonic Consumption, Nether Portal
	},
	-- Destruction Warlock
	[267] = {
		22038, 22090, 22040, -- Flashover, Eradication, Soul Fire
		23148, 21695, 23157, -- Reverse Entropy, Internal Combustion, Shadowburn
		19280, 19285, 19286, -- Demon Skin, Burning Rush, Dark Pact
		22480, 22043, 23143, -- Inferno, Fire and Brimstone, Cataclysm
		22047, 19291, 23465, -- Darkfury, Mortal Coil, Howl of Terror
		23155, 23156, 19295, -- Roaring Blaze, Rain of Chaos, Grimoire of Sacrifice
		19284, 23144, 23092, -- Soul Conduit, Channel Demonfire, Dark Soul: Instability
	},
	-- Brewmaster Monk
	[268] = {
		23106, 19820, 20185, -- Eye of the Tiger, Chi Wave, Chi Burst
		19304, 19818, 19302, -- Celerity, Chi Torpedo, Tiger's Lust
		22099, 22097, 19992, -- Light Brewing, Spitfire, Black Ox Brew
		19993, 19994, 19995, -- Tiger Tail Sweep, Summon Black Ox Statue, Ring of Peace
		20174, 23363, 20175, -- Bob and Weave, Healing Elixir, Dampen Harm
		19819, 20184, 22103, -- Special Delivery, Rushing Jade Wind, Exploding Keg
		22106, 22104, 22108, -- High Tolerance, Celestial Flames, Blackout Combo
	},
	-- Windwalker Monk
	[269] = {
		23106, 19820, 20185, -- Eye of the Tiger, Chi Wave, Chi Burst
		19304, 19818, 19302, -- Celerity, Chi Torpedo, Tiger's Lust
		22098, 19771, 22096, -- Ascension, Fist of the White Tiger, Energizing Elixir
		19993, 23364, 19995, -- Tiger Tail Sweep, Good Karma, Ring of Peace
		23258, 20173, 20175, -- Inner Strength, Diffuse Magic, Dampen Harm
		22093, 23122, 22102, -- Hit Combo, Rushing Jade Wind, Dance of Chi-Ji
		22107, 22105, 21191, -- Spiritual Focus, Whirling Dragon Punch, Serenity
	},
	-- Mistweaver Monk
	[270] = {
		19823, 19820, 20185, -- Mist Wrap, Chi Wave, Chi Burst
		19304, 19818, 19302, -- Celerity, Chi Torpedo, Tiger's Lust
		22168, 22167, 22166, -- Lifecycles, Spirit of the Crane, Mana Tea
		19993, 22219, 19995, -- Tiger Tail Sweep, Song of Chi-Ji, Ring of Peace
		23371, 20173, 20175, -- Healing Elixir, Diffuse Magic, Dampen Harm
		23107, 22101, 22214, -- Summon Jade Serpent Statue, Refreshing Jade Wind, Invoke Chi-Ji, the Red Crane
		22218, 22169, 22170, -- Focused Thunder, Upwelling, Rising Mist
	},
	-- Havoc Demon Hunter
	[577] = {
		21854, 22493, 22416, -- Blind Fury, Demonic Appetite, Felblade
		21857, 22765, 22799, -- Insatiable Hunger, Burning Hatred, Demon Blades
		22909, 22494, 21862, -- Trail of Ruin, Unbound Chaos, Glaive Tempest
		21863, 21864, 21865, -- Soul Rending, Desperate Instincts, Netherwalk
		21866, 21867, 21868, -- Cycle of Hatred, First Blood, Essence Break
		21869, 21870, 22767, -- Unleashed Power, Master of the Glaive, Fel Eruption
		21900, 21901, 22547, -- Demonic, Momentum, Fel Barrage
	},
	-- Vengeance Demon Hunter
	[581] = {
		22502, 22503, 22504, -- Abyssal Strike, Agonizing Flames, Felblade
		22505, 22766, 22507, -- Feast of Souls, Fallout, Burning Alive
		22324, 22541, 22540, -- Infernal Armor, Charred Flesh, Spirit Bomb
		22508, 22509, 22770, -- Soul Rending, Feed the Demon, Fracture
		22546, 22510, 22511, -- Concentrated Sigils, Quickened Sigils, Sigil of Chains
		22512, 22513, 22768, -- Void Reaver, Demonic, Soul Barrier
		22543, 23464, 21902, -- Last Resort, Ruinous Bulwark, Bulk Extraction
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
}

--- @type table<integer,table<integer,integer[]>>
local pvpTalents = {
	-- Arcane Mage
	[62] = {
		[1] = { 3442, 3531, 5397, 635, 3529, 637, 62, 61, 3517, }, -- Netherwind Armor, Prismatic Cloak, Arcanosphere, Master of Escape, Kleptomania, Mass Invisibility, Torment the Weak, Arcane Empowerment, Temporal Shield
		[2] = { 3442, 3531, 5397, 635, 3529, 637, 62, 61, 3517, }, -- Netherwind Armor, Prismatic Cloak, Arcanosphere, Master of Escape, Kleptomania, Mass Invisibility, Torment the Weak, Arcane Empowerment, Temporal Shield
		[3] = { 3442, 3531, 5397, 635, 3529, 637, 62, 61, 3517, }, -- Netherwind Armor, Prismatic Cloak, Arcanosphere, Master of Escape, Kleptomania, Mass Invisibility, Torment the Weak, Arcane Empowerment, Temporal Shield
	},
	-- Fire Mage
	[63] = {
		[1] = { 53, 648, 647, 646, 644, 643, 645, 5389, 828, }, -- Netherwind Armor, Greater Pyroblast, Flamecannon, Pyrokinesis, World in Flames, Tinder, Controlled Burn, Ring of Fire, Prismatic Cloak
		[2] = { 53, 648, 647, 646, 644, 643, 645, 5389, 828, }, -- Netherwind Armor, Greater Pyroblast, Flamecannon, Pyrokinesis, World in Flames, Tinder, Controlled Burn, Ring of Fire, Prismatic Cloak
		[3] = { 53, 648, 647, 646, 644, 643, 645, 5389, 828, }, -- Netherwind Armor, Greater Pyroblast, Flamecannon, Pyrokinesis, World in Flames, Tinder, Controlled Burn, Ring of Fire, Prismatic Cloak
	},
	-- Frost Mage
	[64] = {
		[1] = { 5390, 632, 633, 68, 3532, 3443, 634, 66, 67, }, -- Ice Wall, Concentrated Coolness, Burst of Cold, Deep Shatter, Prismatic Cloak, Netherwind Armor, Ice Form, Chilled to the Bone, Frostbite
		[2] = { 5390, 632, 633, 68, 3532, 3443, 634, 66, 67, }, -- Ice Wall, Concentrated Coolness, Burst of Cold, Deep Shatter, Prismatic Cloak, Netherwind Armor, Ice Form, Chilled to the Bone, Frostbite
		[3] = { 5390, 632, 633, 68, 3532, 3443, 634, 66, 67, }, -- Ice Wall, Concentrated Coolness, Burst of Cold, Deep Shatter, Prismatic Cloak, Netherwind Armor, Ice Form, Chilled to the Bone, Frostbite
	},
	-- Holy Paladin
	[65] = {
		[1] = { 640, 86, 87, 88, 642, 85, 689, 3618, 859, 5421, 82, }, -- Divine Vision, Darkest before the Dawn, Spreading the Word, Blessed Hands, Cleanse the Weak, Ultimate Sacrifice, Divine Favor, Hallowed Ground, Light's Grace, Judgments of the Pure, Avenging Light
		[2] = { 640, 86, 87, 88, 642, 85, 689, 3618, 859, 5421, 82, }, -- Divine Vision, Darkest before the Dawn, Spreading the Word, Blessed Hands, Cleanse the Weak, Ultimate Sacrifice, Divine Favor, Hallowed Ground, Light's Grace, Judgments of the Pure, Avenging Light
		[3] = { 640, 86, 87, 88, 642, 85, 689, 3618, 859, 5421, 82, }, -- Divine Vision, Darkest before the Dawn, Spreading the Word, Blessed Hands, Cleanse the Weak, Ultimate Sacrifice, Divine Favor, Hallowed Ground, Light's Grace, Judgments of the Pure, Avenging Light
	},
	-- Protection Paladin
	[66] = {
		[1] = { 844, 90, 91, 92, 93, 94, 97, 861, 860, 3475, 3474, }, -- Inquisition, Hallowed Ground, Steed of Glory, Sacred Duty, Judgments of the Pure, Guardian of the Forgotten Queen, Guarded by the Light, Shield of Virtue, Warrior of Light, Unbound Freedom, Luminescence
		[2] = { 844, 90, 91, 92, 93, 94, 97, 861, 860, 3475, 3474, }, -- Inquisition, Hallowed Ground, Steed of Glory, Sacred Duty, Judgments of the Pure, Guardian of the Forgotten Queen, Guarded by the Light, Shield of Virtue, Warrior of Light, Unbound Freedom, Luminescence
		[3] = { 844, 90, 91, 92, 93, 94, 97, 861, 860, 3475, 3474, }, -- Inquisition, Hallowed Ground, Steed of Glory, Sacred Duty, Judgments of the Pure, Guardian of the Forgotten Queen, Guarded by the Light, Shield of Virtue, Warrior of Light, Unbound Freedom, Luminescence
	},
	-- Retribution Paladin
	[70] = {
		[1] = { 641, 751, 752, 753, 754, 755, 756, 757, 858, 5422, 81, }, -- Unbound Freedom, Vengeance Aura, Blessing of Sanctuary, Ultimate Retribution, Lawbringer, Divine Punisher, Aura of Reckoning, Jurisdiction, Law and Order, Judgments of the Pure, Luminescence
		[2] = { 641, 751, 752, 753, 754, 755, 756, 757, 858, 5422, 81, }, -- Unbound Freedom, Vengeance Aura, Blessing of Sanctuary, Ultimate Retribution, Lawbringer, Divine Punisher, Aura of Reckoning, Jurisdiction, Law and Order, Judgments of the Pure, Luminescence
		[3] = { 641, 751, 752, 753, 754, 755, 756, 757, 858, 5422, 81, }, -- Unbound Freedom, Vengeance Aura, Blessing of Sanctuary, Ultimate Retribution, Lawbringer, Divine Punisher, Aura of Reckoning, Jurisdiction, Law and Order, Judgments of the Pure, Luminescence
	},
	-- Arms Warrior
	[71] = {
		[1] = { 5376, 33, 5372, 34, 32, 31, 29, 28, 3534, 3522, }, -- Warbringer, Sharpen Blade, Demolition, Duel, War Banner, Storm of Destruction, Shadow of the Colossus, Master and Commander, Disarm, Death Sentence
		[2] = { 5376, 33, 5372, 34, 32, 31, 29, 28, 3534, 3522, }, -- Warbringer, Sharpen Blade, Demolition, Duel, War Banner, Storm of Destruction, Shadow of the Colossus, Master and Commander, Disarm, Death Sentence
		[3] = { 5376, 33, 5372, 34, 32, 31, 29, 28, 3534, 3522, }, -- Warbringer, Sharpen Blade, Demolition, Duel, War Banner, Storm of Destruction, Shadow of the Colossus, Master and Commander, Disarm, Death Sentence
	},
	-- Fury Warrior
	[72] = {
		[1] = { 5373, 3735, 166, 170, 172, 177, 5431, 3533, 3528, 25, 179, }, -- Demolition, Slaughterhouse, Barbarian, Battle Trance, Bloodrage, Enduring Rage, Warbringer, Disarm, Master and Commander, Death Sentence, Death Wish
		[2] = { 5373, 3735, 166, 170, 172, 177, 5431, 3533, 3528, 25, 179, }, -- Demolition, Slaughterhouse, Barbarian, Battle Trance, Bloodrage, Enduring Rage, Warbringer, Disarm, Master and Commander, Death Sentence, Death Wish
		[3] = { 5373, 3735, 166, 170, 172, 177, 5431, 3533, 3528, 25, 179, }, -- Demolition, Slaughterhouse, Barbarian, Battle Trance, Bloodrage, Enduring Rage, Warbringer, Disarm, Master and Commander, Death Sentence, Death Wish
	},
	-- Protection Warrior
	[73] = {
		[1] = { 833, 175, 831, 845, 167, 168, 178, 171, 173, 24, 5374, 5432, }, -- Rebound, Thunderstruck, Dragon Charge, Oppressor, Sword and Board, Bodyguard, Warpath, Morale Killer, Shield Bash, Disarm, Demolition, Warbringer
		[2] = { 833, 175, 831, 845, 167, 168, 178, 171, 173, 24, 5374, 5432, }, -- Rebound, Thunderstruck, Dragon Charge, Oppressor, Sword and Board, Bodyguard, Warpath, Morale Killer, Shield Bash, Disarm, Demolition, Warbringer
		[3] = { 833, 175, 831, 845, 167, 168, 178, 171, 173, 24, 5374, 5432, }, -- Rebound, Thunderstruck, Dragon Charge, Oppressor, Sword and Board, Bodyguard, Warpath, Morale Killer, Shield Bash, Disarm, Demolition, Warbringer
	},
	-- Balance Druid
	[102] = {
		[1] = { 185, 3058, 822, 182, 3728, 5407, 836, 834, 5383, 180, 3731, 184, }, -- Moonkin Aura, Star Burst, Dying Stars, Crescent Burn, Protector of the Grove, Owlkin Adept, Faerie Swarm, Deep Roots, High Winds, Celestial Guardian, Thorns, Moon and Stars
		[2] = { 185, 3058, 822, 182, 3728, 5407, 836, 834, 5383, 180, 3731, 184, }, -- Moonkin Aura, Star Burst, Dying Stars, Crescent Burn, Protector of the Grove, Owlkin Adept, Faerie Swarm, Deep Roots, High Winds, Celestial Guardian, Thorns, Moon and Stars
		[3] = { 185, 3058, 822, 182, 3728, 5407, 836, 834, 5383, 180, 3731, 184, }, -- Moonkin Aura, Star Burst, Dying Stars, Crescent Burn, Protector of the Grove, Owlkin Adept, Faerie Swarm, Deep Roots, High Winds, Celestial Guardian, Thorns, Moon and Stars
	},
	-- Feral Druid
	[103] = {
		[1] = { 5384, 3053, 602, 820, 601, 201, 3751, 203, 611, 612, 620, }, -- High Winds, Strength of the Wild, King of the Jungle, Savage Momentum, Malorne's Swiftness, Thorns, Leader of the Pack, Freedom of the Herd, Ferocious Wound, Fresh Wound, Wicked Claws
		[2] = { 5384, 3053, 602, 820, 601, 201, 3751, 203, 611, 612, 620, }, -- High Winds, Strength of the Wild, King of the Jungle, Savage Momentum, Malorne's Swiftness, Thorns, Leader of the Pack, Freedom of the Herd, Ferocious Wound, Fresh Wound, Wicked Claws
		[3] = { 5384, 3053, 602, 820, 601, 201, 3751, 203, 611, 612, 620, }, -- High Winds, Strength of the Wild, King of the Jungle, Savage Momentum, Malorne's Swiftness, Thorns, Leader of the Pack, Freedom of the Herd, Ferocious Wound, Fresh Wound, Wicked Claws
	},
	-- Guardian Druid
	[104] = {
		[1] = { 842, 49, 50, 51, 52, 1237, 195, 194, 193, 192, 196, 197, 5410, 3750, }, -- Alpha Challenge, Master Shapeshifter, Toughness, Den Mother, Demoralizing Roar, Malorne's Swiftness, Entangling Claws, Charging Bash, Sharpened Claws, Raging Frenzy, Overrun, Emerald Slumber, Grove Protection, Freedom of the Herd
		[2] = { 842, 49, 50, 51, 52, 1237, 195, 194, 193, 192, 196, 197, 5410, 3750, }, -- Alpha Challenge, Master Shapeshifter, Toughness, Den Mother, Demoralizing Roar, Malorne's Swiftness, Entangling Claws, Charging Bash, Sharpened Claws, Raging Frenzy, Overrun, Emerald Slumber, Grove Protection, Freedom of the Herd
		[3] = { 842, 49, 50, 51, 52, 1237, 195, 194, 193, 192, 196, 197, 5410, 3750, }, -- Alpha Challenge, Master Shapeshifter, Toughness, Den Mother, Demoralizing Roar, Malorne's Swiftness, Entangling Claws, Charging Bash, Sharpened Claws, Raging Frenzy, Overrun, Emerald Slumber, Grove Protection, Freedom of the Herd
	},
	-- Restoration Druid
	[105] = {
		[1] = { 59, 5387, 700, 838, 1215, 697, 692, 3752, 691, 3048, 835, }, -- Disentanglement, Keeper of the Grove, Deep Roots, High Winds, Early Spring, Thorns, Entangling Bark, Mark of the Wild, Reactive Resin, Master Shapeshifter, Focused Growth
		[2] = { 59, 5387, 700, 838, 1215, 697, 692, 3752, 691, 3048, 835, }, -- Disentanglement, Keeper of the Grove, Deep Roots, High Winds, Early Spring, Thorns, Entangling Bark, Mark of the Wild, Reactive Resin, Master Shapeshifter, Focused Growth
		[3] = { 59, 5387, 700, 838, 1215, 697, 692, 3752, 691, 3048, 835, }, -- Disentanglement, Keeper of the Grove, Deep Roots, High Winds, Early Spring, Thorns, Entangling Bark, Mark of the Wild, Reactive Resin, Master Shapeshifter, Focused Growth
	},
	-- Blood Death Knight
	[250] = {
		[1] = { 204, 841, 3441, 5426, 5368, 5425, 609, 608, 607, 206, 205, 3511, }, -- Rot and Wither, Murderous Intent, Decomposing Aura, Death's Echo, Dome of Ancient Shadow, Spellwarden, Death Chain, Last Dance, Blood for Blood, Strangulate, Walking Dead, Dark Simulacrum
		[2] = { 204, 841, 3441, 5426, 5368, 5425, 609, 608, 607, 206, 205, 3511, }, -- Rot and Wither, Murderous Intent, Decomposing Aura, Death's Echo, Dome of Ancient Shadow, Spellwarden, Death Chain, Last Dance, Blood for Blood, Strangulate, Walking Dead, Dark Simulacrum
		[3] = { 204, 841, 3441, 5426, 5368, 5425, 609, 608, 607, 206, 205, 3511, }, -- Rot and Wither, Murderous Intent, Decomposing Aura, Death's Echo, Dome of Ancient Shadow, Spellwarden, Death Chain, Last Dance, Blood for Blood, Strangulate, Walking Dead, Dark Simulacrum
	},
	-- Frost Death Knight
	[251] = {
		[1] = { 701, 702, 706, 3512, 5435, 3439, 5369, 5424, 5427, 5429, 3743, }, -- Deathchill, Delirium, Chill Streak, Dark Simulacrum, Bitter Chill, Shroud of Winter, Dome of Ancient Shadow, Spellwarden, Death's Echo, Strangulate, Dead of Winter
		[2] = { 701, 702, 706, 3512, 5435, 3439, 5369, 5424, 5427, 5429, 3743, }, -- Deathchill, Delirium, Chill Streak, Dark Simulacrum, Bitter Chill, Shroud of Winter, Dome of Ancient Shadow, Spellwarden, Death's Echo, Strangulate, Dead of Winter
		[3] = { 701, 702, 706, 3512, 5435, 3439, 5369, 5424, 5427, 5429, 3743, }, -- Deathchill, Delirium, Chill Streak, Dark Simulacrum, Bitter Chill, Shroud of Winter, Dome of Ancient Shadow, Spellwarden, Death's Echo, Strangulate, Dead of Winter
	},
	-- Unholy Death Knight
	[252] = {
		[1] = { 3437, 5423, 5428, 5436, 3746, 5367, 3747, 5430, 152, 40, 41, 149, }, -- Necrotic Aura, Spellwarden, Death's Echo, Doomburst, Necromancer's Bargain, Dome of Ancient Shadow, Raise Abomination, Strangulate, Reanimation, Life and Death, Dark Simulacrum, Necrotic Wounds
		[2] = { 3437, 5423, 5428, 5436, 3746, 5367, 3747, 5430, 152, 40, 41, 149, }, -- Necrotic Aura, Spellwarden, Death's Echo, Doomburst, Necromancer's Bargain, Dome of Ancient Shadow, Raise Abomination, Strangulate, Reanimation, Life and Death, Dark Simulacrum, Necrotic Wounds
		[3] = { 3437, 5423, 5428, 5436, 3746, 5367, 3747, 5430, 152, 40, 41, 149, }, -- Necrotic Aura, Spellwarden, Death's Echo, Doomburst, Necromancer's Bargain, Dome of Ancient Shadow, Raise Abomination, Strangulate, Reanimation, Life and Death, Dark Simulacrum, Necrotic Wounds
	},
	-- Beast Mastery Hunter
	[253] = {
		[1] = { 1214, 825, 824, 5418, 3730, 3612, 693, 5441, 3605, 3604, 3600, 3599, 5444, }, -- Interlope, Dire Beast: Basilisk, Dire Beast: Hawk, Tranquilizing Darts, Hunting Pack, Roar of Sacrifice, The Beast Within, Wild Kingdom, Hi-Explosive Trap, Chimaeral Sting, Dragonscale Armor, Survival Tactics, Kindred Beasts
		[2] = { 1214, 825, 824, 5418, 3730, 3612, 693, 5441, 3605, 3604, 3600, 3599, 5444, }, -- Interlope, Dire Beast: Basilisk, Dire Beast: Hawk, Tranquilizing Darts, Hunting Pack, Roar of Sacrifice, The Beast Within, Wild Kingdom, Hi-Explosive Trap, Chimaeral Sting, Dragonscale Armor, Survival Tactics, Kindred Beasts
		[3] = { 1214, 825, 824, 5418, 3730, 3612, 693, 5441, 3605, 3604, 3600, 3599, 5444, }, -- Interlope, Dire Beast: Basilisk, Dire Beast: Hawk, Tranquilizing Darts, Hunting Pack, Roar of Sacrifice, The Beast Within, Wild Kingdom, Hi-Explosive Trap, Chimaeral Sting, Dragonscale Armor, Survival Tactics, Kindred Beasts
	},
	-- Marksmanship Hunter
	[254] = {
		[1] = { 658, 657, 656, 653, 651, 649, 659, 660, 5419, 3614, 5442, 3729, 5440, }, -- Trueshot Mastery, Hi-Explosive Trap, Scatter Shot, Chimaeral Sting, Survival Tactics, Dragonscale Armor, Ranger's Finesse, Sniper Shot, Tranquilizing Darts, Roar of Sacrifice, Wild Kingdom, Hunting Pack, Consecutive Concussion
		[2] = { 658, 657, 656, 653, 651, 649, 659, 660, 5419, 3614, 5442, 3729, 5440, }, -- Trueshot Mastery, Hi-Explosive Trap, Scatter Shot, Chimaeral Sting, Survival Tactics, Dragonscale Armor, Ranger's Finesse, Sniper Shot, Tranquilizing Darts, Roar of Sacrifice, Wild Kingdom, Hunting Pack, Consecutive Concussion
		[3] = { 658, 657, 656, 653, 651, 649, 659, 660, 5419, 3614, 5442, 3729, 5440, }, -- Trueshot Mastery, Hi-Explosive Trap, Scatter Shot, Chimaeral Sting, Survival Tactics, Dragonscale Armor, Ranger's Finesse, Sniper Shot, Tranquilizing Darts, Roar of Sacrifice, Wild Kingdom, Hunting Pack, Consecutive Concussion
	},
	-- Survival Hunter
	[255] = {
		[1] = { 3609, 5443, 3610, 686, 3607, 3606, 665, 664, 663, 662, 661, 5420, }, -- Chimaeral Sting, Wild Kingdom, Dragonscale Armor, Diamond Ice, Survival Tactics, Hi-Explosive Trap, Tracker's Net, Sticky Tar, Roar of Sacrifice, Mending Bandage, Hunting Pack, Tranquilizing Darts
		[2] = { 3609, 5443, 3610, 686, 3607, 3606, 665, 664, 663, 662, 661, 5420, }, -- Chimaeral Sting, Wild Kingdom, Dragonscale Armor, Diamond Ice, Survival Tactics, Hi-Explosive Trap, Tracker's Net, Sticky Tar, Roar of Sacrifice, Mending Bandage, Hunting Pack, Tranquilizing Darts
		[3] = { 3609, 5443, 3610, 686, 3607, 3606, 665, 664, 663, 662, 661, 5420, }, -- Chimaeral Sting, Wild Kingdom, Dragonscale Armor, Diamond Ice, Survival Tactics, Hi-Explosive Trap, Tracker's Net, Sticky Tar, Roar of Sacrifice, Mending Bandage, Hunting Pack, Tranquilizing Darts
	},
	-- Discipline Priest
	[256] = {
		[1] = { 855, 117, 114, 5416, 1244, 123, 98, 126, 100, 5403, 111, 109, }, -- Thoughtsteal, Dome of Light, Ultimate Radiance, Inner Light and Shadow, Blaze of Light, Archangel, Purification, Dark Archangel, Purified Resolve, Improved Mass Dispel, Strength of Soul, Trinity
		[2] = { 855, 117, 114, 5416, 1244, 123, 98, 126, 100, 5403, 111, 109, }, -- Thoughtsteal, Dome of Light, Ultimate Radiance, Inner Light and Shadow, Blaze of Light, Archangel, Purification, Dark Archangel, Purified Resolve, Improved Mass Dispel, Strength of Soul, Trinity
		[3] = { 855, 117, 114, 5416, 1244, 123, 98, 126, 100, 5403, 111, 109, }, -- Thoughtsteal, Dome of Light, Ultimate Radiance, Inner Light and Shadow, Blaze of Light, Archangel, Purification, Dark Archangel, Purified Resolve, Improved Mass Dispel, Strength of Soul, Trinity
	},
	-- Holy Priest
	[257] = {
		[1] = { 1242, 1927, 5365, 5366, 5404, 112, 101, 108, 115, 118, 124, 127, }, -- Greater Fade, Delivered from Evil, Thoughtsteal, Divine Ascension, Improved Mass Dispel, Greater Heal, Holy Ward, Sanctified Ground, Cardinal Mending, Miracle Worker, Spirit of the Redeemer, Ray of Hope
		[2] = { 1242, 1927, 5365, 5366, 5404, 112, 101, 108, 115, 118, 124, 127, }, -- Greater Fade, Delivered from Evil, Thoughtsteal, Divine Ascension, Improved Mass Dispel, Greater Heal, Holy Ward, Sanctified Ground, Cardinal Mending, Miracle Worker, Spirit of the Redeemer, Ray of Hope
		[3] = { 1242, 1927, 5365, 5366, 5404, 112, 101, 108, 115, 118, 124, 127, }, -- Greater Fade, Delivered from Evil, Thoughtsteal, Divine Ascension, Improved Mass Dispel, Greater Heal, Holy Ward, Sanctified Ground, Cardinal Mending, Miracle Worker, Spirit of the Redeemer, Ray of Hope
	},
	-- Shadow Priest
	[258] = {
		[1] = { 5447, 102, 106, 5381, 739, 763, 3753, 128, 5380, 113, 5446, }, -- Void Volley, Void Shield, Driven to Madness, Thoughtsteal, Void Origins, Psyfiend, Greater Fade, Void Shift, Improved Mass Dispel, Mind Trauma, Megalomania
		[2] = { 5447, 102, 106, 5381, 739, 763, 3753, 128, 5380, 113, 5446, }, -- Void Volley, Void Shield, Driven to Madness, Thoughtsteal, Void Origins, Psyfiend, Greater Fade, Void Shift, Improved Mass Dispel, Mind Trauma, Megalomania
		[3] = { 5447, 102, 106, 5381, 739, 763, 3753, 128, 5380, 113, 5446, }, -- Void Volley, Void Shield, Driven to Madness, Thoughtsteal, Void Origins, Psyfiend, Greater Fade, Void Shift, Improved Mass Dispel, Mind Trauma, Megalomania
	},
	-- Assassination Rogue
	[259] = {
		[1] = { 141, 3448, 3479, 130, 3480, 147, 5405, 830, 5408, 144, }, -- Creeping Venom, Maneuverability, Death from Above, Intent to Kill, Smoke Bomb, System Shock, Dismantle, Hemotoxin, Thick as Thieves, Flying Daggers
		[2] = { 141, 3448, 3479, 130, 3480, 147, 5405, 830, 5408, 144, }, -- Creeping Venom, Maneuverability, Death from Above, Intent to Kill, Smoke Bomb, System Shock, Dismantle, Hemotoxin, Thick as Thieves, Flying Daggers
		[3] = { 141, 3448, 3479, 130, 3480, 147, 5405, 830, 5408, 144, }, -- Creeping Venom, Maneuverability, Death from Above, Intent to Kill, Smoke Bomb, System Shock, Dismantle, Hemotoxin, Thick as Thieves, Flying Daggers
	},
	-- Outlaw Rogue
	[260] = {
		[1] = { 3483, 145, 138, 5412, 3619, 1208, 135, 5413, 139, 129, 3421, 853, }, -- Smoke Bomb, Dismantle, Control is King, Enduring Brawler, Death from Above, Thick as Thieves, Take Your Cut, Float Like a Butterfly, Drink Up Me Hearties, Maneuverability, Turn the Tables, Boarding Party
		[2] = { 3483, 145, 138, 5412, 3619, 1208, 135, 5413, 139, 129, 3421, 853, }, -- Smoke Bomb, Dismantle, Control is King, Enduring Brawler, Death from Above, Thick as Thieves, Take Your Cut, Float Like a Butterfly, Drink Up Me Hearties, Maneuverability, Turn the Tables, Boarding Party
		[3] = { 3483, 145, 138, 5412, 3619, 1208, 135, 5413, 139, 129, 3421, 853, }, -- Smoke Bomb, Dismantle, Control is King, Enduring Brawler, Death from Above, Thick as Thieves, Take Your Cut, Float Like a Butterfly, Drink Up Me Hearties, Maneuverability, Turn the Tables, Boarding Party
	},
	-- Subtlety Rogue
	[261] = {
		[1] = { 5411, 5409, 5406, 136, 1209, 153, 846, 146, 3447, 3462, 856, }, -- Distracting Mirage, Thick as Thieves, Dismantle, Veil of Midnight, Smoke Bomb, Shadowy Duel, Dagger in the Dark, Thief's Bargain, Maneuverability, Death from Above, Silhouette
		[2] = { 5411, 5409, 5406, 136, 1209, 153, 846, 146, 3447, 3462, 856, }, -- Distracting Mirage, Thick as Thieves, Dismantle, Veil of Midnight, Smoke Bomb, Shadowy Duel, Dagger in the Dark, Thief's Bargain, Maneuverability, Death from Above, Silhouette
		[3] = { 5411, 5409, 5406, 136, 1209, 153, 846, 146, 3447, 3462, 856, }, -- Distracting Mirage, Thick as Thieves, Dismantle, Veil of Midnight, Smoke Bomb, Shadowy Duel, Dagger in the Dark, Thief's Bargain, Maneuverability, Death from Above, Silhouette
	},
	-- Elemental Shaman
	[262] = {
		[1] = { 3062, 3621, 3620, 731, 730, 728, 727, 3488, 5415, 3490, 3491, }, -- Spectral Recovery, Swelling Waves, Grounding Totem, Lightning Lasso, Traveling Storms, Control of Lava, Static Field Totem, Skyfury Totem, Seasoned Winds, Counterstrike Totem, Unleash Shield
		[2] = { 3062, 3621, 3620, 731, 730, 728, 727, 3488, 5415, 3490, 3491, }, -- Spectral Recovery, Swelling Waves, Grounding Totem, Lightning Lasso, Traveling Storms, Control of Lava, Static Field Totem, Skyfury Totem, Seasoned Winds, Counterstrike Totem, Unleash Shield
		[3] = { 3062, 3621, 3620, 731, 730, 728, 727, 3488, 5415, 3490, 3491, }, -- Spectral Recovery, Swelling Waves, Grounding Totem, Lightning Lasso, Traveling Storms, Control of Lava, Static Field Totem, Skyfury Totem, Seasoned Winds, Counterstrike Totem, Unleash Shield
	},
	-- Enhancement Shaman
	[263] = {
		[1] = { 3487, 722, 721, 3623, 3519, 3622, 5438, 1944, 725, 5414, 3489, 3492, }, -- Skyfury Totem, Shamanism, Ride the Lightning, Swelling Waves, Spectral Recovery, Grounding Totem, Static Field Totem, Ethereal Form, Thundercharge, Seasoned Winds, Counterstrike Totem, Unleash Shield
		[2] = { 3487, 722, 721, 3623, 3519, 3622, 5438, 1944, 725, 5414, 3489, 3492, }, -- Skyfury Totem, Shamanism, Ride the Lightning, Swelling Waves, Spectral Recovery, Grounding Totem, Static Field Totem, Ethereal Form, Thundercharge, Seasoned Winds, Counterstrike Totem, Unleash Shield
		[3] = { 3487, 722, 721, 3623, 3519, 3622, 5438, 1944, 725, 5414, 3489, 3492, }, -- Skyfury Totem, Shamanism, Ride the Lightning, Swelling Waves, Spectral Recovery, Grounding Totem, Static Field Totem, Ethereal Form, Thundercharge, Seasoned Winds, Counterstrike Totem, Unleash Shield
	},
	-- Restoration Shaman
	[264] = {
		[1] = { 5388, 3756, 3755, 1930, 5437, 3520, 715, 714, 713, 712, 708, 707, }, -- Living Tide, Ancestral Gift, Cleansing Waters, Tidebringer, Unleash Shield, Spectral Recovery, Grounding Totem, Electrocute, Voodoo Mastery, Swelling Waves, Counterstrike Totem, Skyfury Totem
		[2] = { 5388, 3756, 3755, 1930, 5437, 3520, 715, 714, 713, 712, 708, 707, }, -- Living Tide, Ancestral Gift, Cleansing Waters, Tidebringer, Unleash Shield, Spectral Recovery, Grounding Totem, Electrocute, Voodoo Mastery, Swelling Waves, Counterstrike Totem, Skyfury Totem
		[3] = { 5388, 3756, 3755, 1930, 5437, 3520, 715, 714, 713, 712, 708, 707, }, -- Living Tide, Ancestral Gift, Cleansing Waters, Tidebringer, Unleash Shield, Spectral Recovery, Grounding Totem, Electrocute, Voodoo Mastery, Swelling Waves, Counterstrike Totem, Skyfury Totem
	},
	-- Affliction Warlock
	[265] = {
		[1] = { 5392, 19, 18, 20, 11, 12, 15, 16, 3740, 17, 5386, 5379, 5370, }, -- Shadow Rift, Essence Drain, Nether Ward, Casting Circle, Bane of Fragility, Deathbolt, Gateway Mastery, Rot and Decay, Demon Armor, Bane of Shadows, Rapid Contagion, Rampant Afflictions, Amplify Curse
		[2] = { 5392, 19, 18, 20, 11, 12, 15, 16, 3740, 17, 5386, 5379, 5370, }, -- Shadow Rift, Essence Drain, Nether Ward, Casting Circle, Bane of Fragility, Deathbolt, Gateway Mastery, Rot and Decay, Demon Armor, Bane of Shadows, Rapid Contagion, Rampant Afflictions, Amplify Curse
		[3] = { 5392, 19, 18, 20, 11, 12, 15, 16, 3740, 17, 5386, 5379, 5370, }, -- Shadow Rift, Essence Drain, Nether Ward, Casting Circle, Bane of Fragility, Deathbolt, Gateway Mastery, Rot and Decay, Demon Armor, Bane of Shadows, Rapid Contagion, Rampant Afflictions, Amplify Curse
	},
	-- Demonology Warlock
	[266] = {
		[1] = { 165, 162, 158, 5394, 5400, 1213, 156, 3505, 3506, 3507, 3624, 3625, 3626, }, -- Call Observer, Call Fel Lord, Pleasure through Pain, Shadow Rift, Fel Obelisk, Master Summoner, Call Felhunter, Bane of Fragility, Gateway Mastery, Amplify Curse, Nether Ward, Essence Drain, Casting Circle
		[2] = { 165, 162, 158, 5394, 5400, 1213, 156, 3505, 3506, 3507, 3624, 3625, 3626, }, -- Call Observer, Call Fel Lord, Pleasure through Pain, Shadow Rift, Fel Obelisk, Master Summoner, Call Felhunter, Bane of Fragility, Gateway Mastery, Amplify Curse, Nether Ward, Essence Drain, Casting Circle
		[3] = { 165, 162, 158, 5394, 5400, 1213, 156, 3505, 3506, 3507, 3624, 3625, 3626, }, -- Call Observer, Call Fel Lord, Pleasure through Pain, Shadow Rift, Fel Obelisk, Master Summoner, Call Felhunter, Bane of Fragility, Gateway Mastery, Amplify Curse, Nether Ward, Essence Drain, Casting Circle
	},
	-- Destruction Warlock
	[267] = {
		[1] = { 5401, 5382, 3510, 3509, 5393, 3508, 159, 3741, 164, 157, 3502, 3504, }, -- Bonds of Fel, Gateway Mastery, Casting Circle, Essence Drain, Shadow Rift, Nether Ward, Cremation, Demon Armor, Bane of Havoc, Fel Fissure, Bane of Fragility, Amplify Curse
		[2] = { 5401, 5382, 3510, 3509, 5393, 3508, 159, 3741, 164, 157, 3502, 3504, }, -- Bonds of Fel, Gateway Mastery, Casting Circle, Essence Drain, Shadow Rift, Nether Ward, Cremation, Demon Armor, Bane of Havoc, Fel Fissure, Bane of Fragility, Amplify Curse
		[3] = { 5401, 5382, 3510, 3509, 5393, 3508, 159, 3741, 164, 157, 3502, 3504, }, -- Bonds of Fel, Gateway Mastery, Casting Circle, Essence Drain, Shadow Rift, Nether Ward, Cremation, Demon Armor, Bane of Havoc, Fel Fissure, Bane of Fragility, Amplify Curse
	},
	-- Brewmaster Monk
	[268] = {
		[1] = { 765, 5417, 843, 667, 670, 669, 668, 666, 1958, 671, 672, 673, }, -- Eerie Fermentation, Rodeo, Admonishment, Hot Trub, Nimble Brew, Avert Harm, Guided Meditation, Microbrew, Niuzao's Essence, Incendiary Breath, Double Barrel, Mighty Ox Kick
		[2] = { 765, 5417, 843, 667, 670, 669, 668, 666, 1958, 671, 672, 673, }, -- Eerie Fermentation, Rodeo, Admonishment, Hot Trub, Nimble Brew, Avert Harm, Guided Meditation, Microbrew, Niuzao's Essence, Incendiary Breath, Double Barrel, Mighty Ox Kick
		[3] = { 765, 5417, 843, 667, 670, 669, 668, 666, 1958, 671, 672, 673, }, -- Eerie Fermentation, Rodeo, Admonishment, Hot Trub, Nimble Brew, Avert Harm, Guided Meditation, Microbrew, Niuzao's Essence, Incendiary Breath, Double Barrel, Mighty Ox Kick
	},
	-- Windwalker Monk
	[269] = {
		[1] = { 3744, 3745, 3737, 675, 3050, 852, 3052, 3734, 77, 5448, }, -- Pressure Points, Turbo Fists, Wind Waker, Tigereye Brew, Disabling Reach, Reverse Harm, Grapple Weapon, Alpha Tiger, Ride the Wind, Perpetual Paralysis
		[2] = { 3744, 3745, 3737, 675, 3050, 852, 3052, 3734, 77, 5448, }, -- Pressure Points, Turbo Fists, Wind Waker, Tigereye Brew, Disabling Reach, Reverse Harm, Grapple Weapon, Alpha Tiger, Ride the Wind, Perpetual Paralysis
		[3] = { 3744, 3745, 3737, 675, 3050, 852, 3052, 3734, 77, 5448, }, -- Pressure Points, Turbo Fists, Wind Waker, Tigereye Brew, Disabling Reach, Reverse Harm, Grapple Weapon, Alpha Tiger, Ride the Wind, Perpetual Paralysis
	},
	-- Mistweaver Monk
	[270] = {
		[1] = { 5402, 683, 5395, 682, 680, 679, 678, 3732, 1928, 5398, 70, }, -- Thunderous Focus Tea, Healing Sphere, Peaceweaver, Refreshing Breeze, Dome of Mist, Counteract Magic, Chrysalis, Grapple Weapon, Zen Focus Tea, Dematerialize, Eminence
		[2] = { 5402, 683, 5395, 682, 680, 679, 678, 3732, 1928, 5398, 70, }, -- Thunderous Focus Tea, Healing Sphere, Peaceweaver, Refreshing Breeze, Dome of Mist, Counteract Magic, Chrysalis, Grapple Weapon, Zen Focus Tea, Dematerialize, Eminence
		[3] = { 5402, 683, 5395, 682, 680, 679, 678, 3732, 1928, 5398, 70, }, -- Thunderous Focus Tea, Healing Sphere, Peaceweaver, Refreshing Breeze, Dome of Mist, Counteract Magic, Chrysalis, Grapple Weapon, Zen Focus Tea, Dematerialize, Eminence
	},
	-- Havoc Demon Hunter
	[577] = {
		[1] = { 5433, 812, 1218, 805, 806, 809, 810, 1206, 1204, 811, 813, 5445, }, -- Blood Moon, Detainment, Unending Hatred, Cleansed by Flame, Reverse Magic, Chaotic Imprint, Demonic Origins, Cover of Darkness, Mortal Dance, Rain from Above, Glimpse, Isolated Prey
		[2] = { 5433, 812, 1218, 805, 806, 809, 810, 1206, 1204, 811, 813, 5445, }, -- Blood Moon, Detainment, Unending Hatred, Cleansed by Flame, Reverse Magic, Chaotic Imprint, Demonic Origins, Cover of Darkness, Mortal Dance, Rain from Above, Glimpse, Isolated Prey
		[3] = { 5433, 812, 1218, 805, 806, 809, 810, 1206, 1204, 811, 813, 5445, }, -- Blood Moon, Detainment, Unending Hatred, Cleansed by Flame, Reverse Magic, Chaotic Imprint, Demonic Origins, Cover of Darkness, Mortal Dance, Rain from Above, Glimpse, Isolated Prey
	},
	-- Vengeance Demon Hunter
	[581] = {
		[1] = { 3727, 1948, 3423, 5434, 5439, 3429, 1220, 814, 3430, 819, 816, 815, }, -- Unending Hatred, Sigil Mastery, Demonic Trample, Blood Moon, Chaotic Imprint, Reverse Magic, Tormentor, Cleansed by Flame, Detainment, Illidan's Grasp, Jagged Spikes, Everlasting Hunt
		[2] = { 3727, 1948, 3423, 5434, 5439, 3429, 1220, 814, 3430, 819, 816, 815, }, -- Unending Hatred, Sigil Mastery, Demonic Trample, Blood Moon, Chaotic Imprint, Reverse Magic, Tormentor, Cleansed by Flame, Detainment, Illidan's Grasp, Jagged Spikes, Everlasting Hunt
		[3] = { 3727, 1948, 3423, 5434, 5439, 3429, 1220, 814, 3430, 819, 816, 815, }, -- Unending Hatred, Sigil Mastery, Demonic Trample, Blood Moon, Chaotic Imprint, Reverse Magic, Tormentor, Cleansed by Flame, Detainment, Illidan's Grasp, Jagged Spikes, Everlasting Hunt
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
}

LibTalentInfo:RegisterTalentProvider({
	version = version,
	specializations = specializations,
	talents = talents,
	pvpTalentSlotCount = 3,
	pvpTalents = pvpTalents
})
