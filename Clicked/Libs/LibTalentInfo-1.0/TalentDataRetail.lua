--- @type LibTalentInfo
local LibTalentInfo = LibStub and LibStub("LibTalentInfo-1.0", true)
local version = 43903

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
		22487, 22095, 22562, -- Binding Heals, Guardian Angel, Afterlife
		21750, 21977, 19761, -- Psychic Voice, Censure, Shining Force
		19764, 22327, 21754, -- Surge of Light, Cosmic Ripple, Prayer Circle
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
		[1] = { 635, 61, 62, 3442, 5397, 3531, 3529, 3517, 637, }, -- Master of Escape, Arcane Empowerment, Torment the Weak, Netherwind Armor, Arcanosphere, Prismatic Cloak, Kleptomania, Temporal Shield, Mass Invisibility
		[2] = { 635, 61, 62, 3442, 5397, 3531, 3529, 3517, 637, }, -- Master of Escape, Arcane Empowerment, Torment the Weak, Netherwind Armor, Arcanosphere, Prismatic Cloak, Kleptomania, Temporal Shield, Mass Invisibility
		[3] = { 635, 61, 62, 3442, 5397, 3531, 3529, 3517, 637, }, -- Master of Escape, Arcane Empowerment, Torment the Weak, Netherwind Armor, Arcanosphere, Prismatic Cloak, Kleptomania, Temporal Shield, Mass Invisibility
	},
	-- Fire Mage
	[63] = {
		[1] = { 53, 5389, 648, 647, 646, 645, 644, 643, 828, }, -- Netherwind Armor, Ring of Fire, Greater Pyroblast, Flamecannon, Pyrokinesis, Controlled Burn, World in Flames, Tinder, Prismatic Cloak
		[2] = { 53, 5389, 648, 647, 646, 645, 644, 643, 828, }, -- Netherwind Armor, Ring of Fire, Greater Pyroblast, Flamecannon, Pyrokinesis, Controlled Burn, World in Flames, Tinder, Prismatic Cloak
		[3] = { 53, 5389, 648, 647, 646, 645, 644, 643, 828, }, -- Netherwind Armor, Ring of Fire, Greater Pyroblast, Flamecannon, Pyrokinesis, Controlled Burn, World in Flames, Tinder, Prismatic Cloak
	},
	-- Frost Mage
	[64] = {
		[1] = { 634, 3532, 3443, 5390, 633, 68, 632, 66, 67, }, -- Ice Form, Prismatic Cloak, Netherwind Armor, Ice Wall, Burst of Cold, Deep Shatter, Concentrated Coolness, Chilled to the Bone, Frostbite
		[2] = { 634, 3532, 3443, 5390, 633, 68, 632, 66, 67, }, -- Ice Form, Prismatic Cloak, Netherwind Armor, Ice Wall, Burst of Cold, Deep Shatter, Concentrated Coolness, Chilled to the Bone, Frostbite
		[3] = { 634, 3532, 3443, 5390, 633, 68, 632, 66, 67, }, -- Ice Form, Prismatic Cloak, Netherwind Armor, Ice Wall, Burst of Cold, Deep Shatter, Concentrated Coolness, Chilled to the Bone, Frostbite
	},
	-- Holy Paladin
	[65] = {
		[1] = { 87, 859, 5421, 689, 3618, 642, 640, 88, 82, 86, 85, }, -- Spreading the Word, Light's Grace, Judgments of the Pure, Divine Favor, Hallowed Ground, Cleanse the Weak, Divine Vision, Blessed Hands, Avenging Light, Darkest before the Dawn, Ultimate Sacrifice
		[2] = { 87, 859, 5421, 689, 3618, 642, 640, 88, 82, 86, 85, }, -- Spreading the Word, Light's Grace, Judgments of the Pure, Divine Favor, Hallowed Ground, Cleanse the Weak, Divine Vision, Blessed Hands, Avenging Light, Darkest before the Dawn, Ultimate Sacrifice
		[3] = { 87, 859, 5421, 689, 3618, 642, 640, 88, 82, 86, 85, }, -- Spreading the Word, Light's Grace, Judgments of the Pure, Divine Favor, Hallowed Ground, Cleanse the Weak, Divine Vision, Blessed Hands, Avenging Light, Darkest before the Dawn, Ultimate Sacrifice
	},
	-- Protection Paladin
	[66] = {
		[1] = { 93, 92, 861, 91, 94, 97, 3474, 3475, 844, 90, 860, }, -- Judgments of the Pure, Sacred Duty, Shield of Virtue, Steed of Glory, Guardian of the Forgotten Queen, Guarded by the Light, Luminescence, Unbound Freedom, Inquisition, Hallowed Ground, Warrior of Light
		[2] = { 93, 92, 861, 91, 94, 97, 3474, 3475, 844, 90, 860, }, -- Judgments of the Pure, Sacred Duty, Shield of Virtue, Steed of Glory, Guardian of the Forgotten Queen, Guarded by the Light, Luminescence, Unbound Freedom, Inquisition, Hallowed Ground, Warrior of Light
		[3] = { 93, 92, 861, 91, 94, 97, 3474, 3475, 844, 90, 860, }, -- Judgments of the Pure, Sacred Duty, Shield of Virtue, Steed of Glory, Guardian of the Forgotten Queen, Guarded by the Light, Luminescence, Unbound Freedom, Inquisition, Hallowed Ground, Warrior of Light
	},
	-- Retribution Paladin
	[70] = {
		[1] = { 641, 754, 755, 756, 757, 753, 752, 751, 858, 5422, 81, }, -- Unbound Freedom, Lawbringer, Divine Punisher, Aura of Reckoning, Jurisdiction, Ultimate Retribution, Blessing of Sanctuary, Vengeance Aura, Law and Order, Judgments of the Pure, Luminescence
		[2] = { 641, 754, 755, 756, 757, 753, 752, 751, 858, 5422, 81, }, -- Unbound Freedom, Lawbringer, Divine Punisher, Aura of Reckoning, Jurisdiction, Ultimate Retribution, Blessing of Sanctuary, Vengeance Aura, Law and Order, Judgments of the Pure, Luminescence
		[3] = { 641, 754, 755, 756, 757, 753, 752, 751, 858, 5422, 81, }, -- Unbound Freedom, Lawbringer, Divine Punisher, Aura of Reckoning, Jurisdiction, Ultimate Retribution, Blessing of Sanctuary, Vengeance Aura, Law and Order, Judgments of the Pure, Luminescence
	},
	-- Arms Warrior
	[71] = {
		[1] = { 3522, 5372, 32, 31, 5376, 34, 3534, 28, 29, 33, }, -- Death Sentence, Demolition, War Banner, Storm of Destruction, Warbringer, Duel, Disarm, Master and Commander, Shadow of the Colossus, Sharpen Blade
		[2] = { 3522, 5372, 32, 31, 5376, 34, 3534, 28, 29, 33, }, -- Death Sentence, Demolition, War Banner, Storm of Destruction, Warbringer, Duel, Disarm, Master and Commander, Shadow of the Colossus, Sharpen Blade
		[3] = { 3522, 5372, 32, 31, 5376, 34, 3534, 28, 29, 33, }, -- Death Sentence, Demolition, War Banner, Storm of Destruction, Warbringer, Duel, Disarm, Master and Commander, Shadow of the Colossus, Sharpen Blade
	},
	-- Fury Warrior
	[72] = {
		[1] = { 177, 179, 166, 170, 5373, 3735, 25, 172, 3533, 5431, 3528, }, -- Enduring Rage, Death Wish, Barbarian, Battle Trance, Demolition, Slaughterhouse, Death Sentence, Bloodrage, Disarm, Warbringer, Master and Commander
		[2] = { 177, 179, 166, 170, 5373, 3735, 25, 172, 3533, 5431, 3528, }, -- Enduring Rage, Death Wish, Barbarian, Battle Trance, Demolition, Slaughterhouse, Death Sentence, Bloodrage, Disarm, Warbringer, Master and Commander
		[3] = { 177, 179, 166, 170, 5373, 3735, 25, 172, 3533, 5431, 3528, }, -- Enduring Rage, Death Wish, Barbarian, Battle Trance, Demolition, Slaughterhouse, Death Sentence, Bloodrage, Disarm, Warbringer, Master and Commander
	},
	-- Protection Warrior
	[73] = {
		[1] = { 833, 845, 831, 173, 167, 168, 5374, 171, 24, 175, 178, 5432, }, -- Rebound, Oppressor, Dragon Charge, Shield Bash, Sword and Board, Bodyguard, Demolition, Morale Killer, Disarm, Thunderstruck, Warpath, Warbringer
		[2] = { 833, 845, 831, 173, 167, 168, 5374, 171, 24, 175, 178, 5432, }, -- Rebound, Oppressor, Dragon Charge, Shield Bash, Sword and Board, Bodyguard, Demolition, Morale Killer, Disarm, Thunderstruck, Warpath, Warbringer
		[3] = { 833, 845, 831, 173, 167, 168, 5374, 171, 24, 175, 178, 5432, }, -- Rebound, Oppressor, Dragon Charge, Shield Bash, Sword and Board, Bodyguard, Demolition, Morale Killer, Disarm, Thunderstruck, Warpath, Warbringer
	},
	-- Balance Druid
	[102] = {
		[1] = { 185, 3058, 822, 834, 3731, 836, 5383, 5407, 3728, 180, 182, 184, }, -- Moonkin Aura, Star Burst, Dying Stars, Deep Roots, Thorns, Faerie Swarm, High Winds, Owlkin Adept, Protector of the Grove, Celestial Guardian, Crescent Burn, Moon and Stars
		[2] = { 185, 3058, 822, 834, 3731, 836, 5383, 5407, 3728, 180, 182, 184, }, -- Moonkin Aura, Star Burst, Dying Stars, Deep Roots, Thorns, Faerie Swarm, High Winds, Owlkin Adept, Protector of the Grove, Celestial Guardian, Crescent Burn, Moon and Stars
		[3] = { 185, 3058, 822, 834, 3731, 836, 5383, 5407, 3728, 180, 182, 184, }, -- Moonkin Aura, Star Burst, Dying Stars, Deep Roots, Thorns, Faerie Swarm, High Winds, Owlkin Adept, Protector of the Grove, Celestial Guardian, Crescent Burn, Moon and Stars
	},
	-- Feral Druid
	[103] = {
		[1] = { 602, 201, 601, 3053, 203, 3751, 820, 5384, 611, 612, 620, }, -- King of the Jungle, Thorns, Malorne's Swiftness, Strength of the Wild, Freedom of the Herd, Leader of the Pack, Savage Momentum, High Winds, Ferocious Wound, Fresh Wound, Wicked Claws
		[2] = { 602, 201, 601, 3053, 203, 3751, 820, 5384, 611, 612, 620, }, -- King of the Jungle, Thorns, Malorne's Swiftness, Strength of the Wild, Freedom of the Herd, Leader of the Pack, Savage Momentum, High Winds, Ferocious Wound, Fresh Wound, Wicked Claws
		[3] = { 602, 201, 601, 3053, 203, 3751, 820, 5384, 611, 612, 620, }, -- King of the Jungle, Thorns, Malorne's Swiftness, Strength of the Wild, Freedom of the Herd, Leader of the Pack, Savage Momentum, High Winds, Ferocious Wound, Fresh Wound, Wicked Claws
	},
	-- Guardian Druid
	[104] = {
		[1] = { 194, 195, 196, 197, 52, 51, 50, 49, 842, 1237, 5410, 192, 3750, 193, }, -- Charging Bash, Entangling Claws, Overrun, Emerald Slumber, Demoralizing Roar, Den Mother, Toughness, Master Shapeshifter, Alpha Challenge, Malorne's Swiftness, Grove Protection, Raging Frenzy, Freedom of the Herd, Sharpened Claws
		[2] = { 194, 195, 196, 197, 52, 51, 50, 49, 842, 1237, 5410, 192, 3750, 193, }, -- Charging Bash, Entangling Claws, Overrun, Emerald Slumber, Demoralizing Roar, Den Mother, Toughness, Master Shapeshifter, Alpha Challenge, Malorne's Swiftness, Grove Protection, Raging Frenzy, Freedom of the Herd, Sharpened Claws
		[3] = { 194, 195, 196, 197, 52, 51, 50, 49, 842, 1237, 5410, 192, 3750, 193, }, -- Charging Bash, Entangling Claws, Overrun, Emerald Slumber, Demoralizing Roar, Den Mother, Toughness, Master Shapeshifter, Alpha Challenge, Malorne's Swiftness, Grove Protection, Raging Frenzy, Freedom of the Herd, Sharpened Claws
	},
	-- Restoration Druid
	[105] = {
		[1] = { 838, 697, 1215, 700, 3752, 59, 835, 3048, 5387, 692, 691, }, -- High Winds, Thorns, Early Spring, Deep Roots, Mark of the Wild, Disentanglement, Focused Growth, Master Shapeshifter, Keeper of the Grove, Entangling Bark, Reactive Resin
		[2] = { 838, 697, 1215, 700, 3752, 59, 835, 3048, 5387, 692, 691, }, -- High Winds, Thorns, Early Spring, Deep Roots, Mark of the Wild, Disentanglement, Focused Growth, Master Shapeshifter, Keeper of the Grove, Entangling Bark, Reactive Resin
		[3] = { 838, 697, 1215, 700, 3752, 59, 835, 3048, 5387, 692, 691, }, -- High Winds, Thorns, Early Spring, Deep Roots, Mark of the Wild, Disentanglement, Focused Growth, Master Shapeshifter, Keeper of the Grove, Entangling Bark, Reactive Resin
	},
	-- Blood Death Knight
	[250] = {
		[1] = { 3441, 841, 608, 204, 205, 206, 607, 609, 3511, 5425, 5426, }, -- Decomposing Aura, Murderous Intent, Last Dance, Rot and Wither, Walking Dead, Strangulate, Blood for Blood, Death Chain, Dark Simulacrum, Spellwarden, Death's Echo
		[2] = { 3441, 841, 608, 204, 205, 206, 607, 609, 3511, 5425, 5426, }, -- Decomposing Aura, Murderous Intent, Last Dance, Rot and Wither, Walking Dead, Strangulate, Blood for Blood, Death Chain, Dark Simulacrum, Spellwarden, Death's Echo
		[3] = { 3441, 841, 608, 204, 205, 206, 607, 609, 3511, 5425, 5426, }, -- Decomposing Aura, Murderous Intent, Last Dance, Rot and Wither, Walking Dead, Strangulate, Blood for Blood, Death Chain, Dark Simulacrum, Spellwarden, Death's Echo
	},
	-- Frost Death Knight
	[251] = {
		[1] = { 5427, 701, 5424, 3512, 702, 3743, 706, 5429, 5435, 3439, }, -- Death's Echo, Deathchill, Spellwarden, Dark Simulacrum, Delirium, Dead of Winter, Chill Streak, Strangulate, Bitter Chill, Shroud of Winter
		[2] = { 5427, 701, 5424, 3512, 702, 3743, 706, 5429, 5435, 3439, }, -- Death's Echo, Deathchill, Spellwarden, Dark Simulacrum, Delirium, Dead of Winter, Chill Streak, Strangulate, Bitter Chill, Shroud of Winter
		[3] = { 5427, 701, 5424, 3512, 702, 3743, 706, 5429, 5435, 3439, }, -- Death's Echo, Deathchill, Spellwarden, Dark Simulacrum, Delirium, Dead of Winter, Chill Streak, Strangulate, Bitter Chill, Shroud of Winter
	},
	-- Unholy Death Knight
	[252] = {
		[1] = { 5428, 5423, 149, 3747, 3746, 152, 5430, 40, 3437, 5436, 41, }, -- Death's Echo, Spellwarden, Necrotic Wounds, Raise Abomination, Necromancer's Bargain, Reanimation, Strangulate, Life and Death, Necrotic Aura, Doomburst, Dark Simulacrum
		[2] = { 5428, 5423, 149, 3747, 3746, 152, 5430, 40, 3437, 5436, 41, }, -- Death's Echo, Spellwarden, Necrotic Wounds, Raise Abomination, Necromancer's Bargain, Reanimation, Strangulate, Life and Death, Necrotic Aura, Doomburst, Dark Simulacrum
		[3] = { 5428, 5423, 149, 3747, 3746, 152, 5430, 40, 3437, 5436, 41, }, -- Death's Echo, Spellwarden, Necrotic Wounds, Raise Abomination, Necromancer's Bargain, Reanimation, Strangulate, Life and Death, Necrotic Aura, Doomburst, Dark Simulacrum
	},
	-- Beast Mastery Hunter
	[253] = {
		[1] = { 3730, 825, 3599, 3600, 3604, 3605, 3612, 5418, 5444, 5441, 693, 824, 1214, }, -- Hunting Pack, Dire Beast: Basilisk, Survival Tactics, Dragonscale Armor, Chimaeral Sting, Hi-Explosive Trap, Roar of Sacrifice, Tranquilizing Darts, Kindred Beasts, Wild Kingdom, The Beast Within, Dire Beast: Hawk, Interlope
		[2] = { 3730, 825, 3599, 3600, 3604, 3605, 3612, 5418, 5444, 5441, 693, 824, 1214, }, -- Hunting Pack, Dire Beast: Basilisk, Survival Tactics, Dragonscale Armor, Chimaeral Sting, Hi-Explosive Trap, Roar of Sacrifice, Tranquilizing Darts, Kindred Beasts, Wild Kingdom, The Beast Within, Dire Beast: Hawk, Interlope
		[3] = { 3730, 825, 3599, 3600, 3604, 3605, 3612, 5418, 5444, 5441, 693, 824, 1214, }, -- Hunting Pack, Dire Beast: Basilisk, Survival Tactics, Dragonscale Armor, Chimaeral Sting, Hi-Explosive Trap, Roar of Sacrifice, Tranquilizing Darts, Kindred Beasts, Wild Kingdom, The Beast Within, Dire Beast: Hawk, Interlope
	},
	-- Marksmanship Hunter
	[254] = {
		[1] = { 3614, 660, 659, 658, 657, 656, 653, 5442, 5440, 5419, 649, 3729, 651, }, -- Roar of Sacrifice, Sniper Shot, Ranger's Finesse, Trueshot Mastery, Hi-Explosive Trap, Scatter Shot, Chimaeral Sting, Wild Kingdom, Consecutive Concussion, Tranquilizing Darts, Dragonscale Armor, Hunting Pack, Survival Tactics
		[2] = { 3614, 660, 659, 658, 657, 656, 653, 5442, 5440, 5419, 649, 3729, 651, }, -- Roar of Sacrifice, Sniper Shot, Ranger's Finesse, Trueshot Mastery, Hi-Explosive Trap, Scatter Shot, Chimaeral Sting, Wild Kingdom, Consecutive Concussion, Tranquilizing Darts, Dragonscale Armor, Hunting Pack, Survival Tactics
		[3] = { 3614, 660, 659, 658, 657, 656, 653, 5442, 5440, 5419, 649, 3729, 651, }, -- Roar of Sacrifice, Sniper Shot, Ranger's Finesse, Trueshot Mastery, Hi-Explosive Trap, Scatter Shot, Chimaeral Sting, Wild Kingdom, Consecutive Concussion, Tranquilizing Darts, Dragonscale Armor, Hunting Pack, Survival Tactics
	},
	-- Survival Hunter
	[255] = {
		[1] = { 5443, 3609, 3607, 3606, 665, 664, 663, 662, 661, 3610, 686, 5420, }, -- Wild Kingdom, Chimaeral Sting, Survival Tactics, Hi-Explosive Trap, Tracker's Net, Sticky Tar, Roar of Sacrifice, Mending Bandage, Hunting Pack, Dragonscale Armor, Diamond Ice, Tranquilizing Darts
		[2] = { 5443, 3609, 3607, 3606, 665, 664, 663, 662, 661, 3610, 686, 5420, }, -- Wild Kingdom, Chimaeral Sting, Survival Tactics, Hi-Explosive Trap, Tracker's Net, Sticky Tar, Roar of Sacrifice, Mending Bandage, Hunting Pack, Dragonscale Armor, Diamond Ice, Tranquilizing Darts
		[3] = { 5443, 3609, 3607, 3606, 665, 664, 663, 662, 661, 3610, 686, 5420, }, -- Wild Kingdom, Chimaeral Sting, Survival Tactics, Hi-Explosive Trap, Tracker's Net, Sticky Tar, Roar of Sacrifice, Mending Bandage, Hunting Pack, Dragonscale Armor, Diamond Ice, Tranquilizing Darts
	},
	-- Discipline Priest
	[256] = {
		[1] = { 855, 1244, 5416, 5403, 98, 100, 109, 111, 114, 117, 123, 126, }, -- Thoughtsteal, Blaze of Light, Inner Light and Shadow, Improved Mass Dispel, Purification, Purified Resolve, Trinity, Strength of Soul, Ultimate Radiance, Dome of Light, Archangel, Dark Archangel
		[2] = { 855, 1244, 5416, 5403, 98, 100, 109, 111, 114, 117, 123, 126, }, -- Thoughtsteal, Blaze of Light, Inner Light and Shadow, Improved Mass Dispel, Purification, Purified Resolve, Trinity, Strength of Soul, Ultimate Radiance, Dome of Light, Archangel, Dark Archangel
		[3] = { 855, 1244, 5416, 5403, 98, 100, 109, 111, 114, 117, 123, 126, }, -- Thoughtsteal, Blaze of Light, Inner Light and Shadow, Improved Mass Dispel, Purification, Purified Resolve, Trinity, Strength of Soul, Ultimate Radiance, Dome of Light, Archangel, Dark Archangel
	},
	-- Holy Priest
	[257] = {
		[1] = { 1242, 5366, 1927, 115, 124, 112, 108, 127, 101, 5404, 118, 5365, }, -- Greater Fade, Divine Ascension, Delivered from Evil, Cardinal Mending, Spirit of the Redeemer, Greater Heal, Sanctified Ground, Ray of Hope, Holy Ward, Improved Mass Dispel, Miracle Worker, Thoughtsteal
		[2] = { 1242, 5366, 1927, 115, 124, 112, 108, 127, 101, 5404, 118, 5365, }, -- Greater Fade, Divine Ascension, Delivered from Evil, Cardinal Mending, Spirit of the Redeemer, Greater Heal, Sanctified Ground, Ray of Hope, Holy Ward, Improved Mass Dispel, Miracle Worker, Thoughtsteal
		[3] = { 1242, 5366, 1927, 115, 124, 112, 108, 127, 101, 5404, 118, 5365, }, -- Greater Fade, Divine Ascension, Delivered from Evil, Cardinal Mending, Spirit of the Redeemer, Greater Heal, Sanctified Ground, Ray of Hope, Holy Ward, Improved Mass Dispel, Miracle Worker, Thoughtsteal
	},
	-- Shadow Priest
	[258] = {
		[1] = { 3753, 106, 113, 128, 102, 763, 739, 5381, 5380, 5447, 5446, }, -- Greater Fade, Driven to Madness, Mind Trauma, Void Shift, Void Shield, Psyfiend, Void Origins, Thoughtsteal, Improved Mass Dispel, Void Volley, Megalomania
		[2] = { 3753, 106, 113, 128, 102, 763, 739, 5381, 5380, 5447, 5446, }, -- Greater Fade, Driven to Madness, Mind Trauma, Void Shift, Void Shield, Psyfiend, Void Origins, Thoughtsteal, Improved Mass Dispel, Void Volley, Megalomania
		[3] = { 3753, 106, 113, 128, 102, 763, 739, 5381, 5380, 5447, 5446, }, -- Greater Fade, Driven to Madness, Mind Trauma, Void Shift, Void Shield, Psyfiend, Void Origins, Thoughtsteal, Improved Mass Dispel, Void Volley, Megalomania
	},
	-- Assassination Rogue
	[259] = {
		[1] = { 3479, 5408, 147, 5405, 130, 3480, 141, 144, 830, 3448, }, -- Death from Above, Thick as Thieves, System Shock, Dismantle, Intent to Kill, Smoke Bomb, Creeping Venom, Flying Daggers, Hemotoxin, Maneuverability
		[2] = { 3479, 5408, 147, 5405, 130, 3480, 141, 144, 830, 3448, }, -- Death from Above, Thick as Thieves, System Shock, Dismantle, Intent to Kill, Smoke Bomb, Creeping Venom, Flying Daggers, Hemotoxin, Maneuverability
		[3] = { 3479, 5408, 147, 5405, 130, 3480, 141, 144, 830, 3448, }, -- Death from Above, Thick as Thieves, System Shock, Dismantle, Intent to Kill, Smoke Bomb, Creeping Venom, Flying Daggers, Hemotoxin, Maneuverability
	},
	-- Outlaw Rogue
	[260] = {
		[1] = { 3483, 1208, 135, 3421, 139, 5413, 129, 5412, 145, 138, 853, 3619, }, -- Smoke Bomb, Thick as Thieves, Take Your Cut, Turn the Tables, Drink Up Me Hearties, Float Like a Butterfly, Maneuverability, Enduring Brawler, Dismantle, Control is King, Boarding Party, Death from Above
		[2] = { 3483, 1208, 135, 3421, 139, 5413, 129, 5412, 145, 138, 853, 3619, }, -- Smoke Bomb, Thick as Thieves, Take Your Cut, Turn the Tables, Drink Up Me Hearties, Float Like a Butterfly, Maneuverability, Enduring Brawler, Dismantle, Control is King, Boarding Party, Death from Above
		[3] = { 3483, 1208, 135, 3421, 139, 5413, 129, 5412, 145, 138, 853, 3619, }, -- Smoke Bomb, Thick as Thieves, Take Your Cut, Turn the Tables, Drink Up Me Hearties, Float Like a Butterfly, Maneuverability, Enduring Brawler, Dismantle, Control is King, Boarding Party, Death from Above
	},
	-- Subtlety Rogue
	[261] = {
		[1] = { 136, 153, 146, 856, 846, 1209, 5409, 5411, 5406, 3447, 3462, }, -- Veil of Midnight, Shadowy Duel, Thief's Bargain, Silhouette, Dagger in the Dark, Smoke Bomb, Thick as Thieves, Distracting Mirage, Dismantle, Maneuverability, Death from Above
		[2] = { 136, 153, 146, 856, 846, 1209, 5409, 5411, 5406, 3447, 3462, }, -- Veil of Midnight, Shadowy Duel, Thief's Bargain, Silhouette, Dagger in the Dark, Smoke Bomb, Thick as Thieves, Distracting Mirage, Dismantle, Maneuverability, Death from Above
		[3] = { 136, 153, 146, 856, 846, 1209, 5409, 5411, 5406, 3447, 3462, }, -- Veil of Midnight, Shadowy Duel, Thief's Bargain, Silhouette, Dagger in the Dark, Smoke Bomb, Thick as Thieves, Distracting Mirage, Dismantle, Maneuverability, Death from Above
	},
	-- Elemental Shaman
	[262] = {
		[1] = { 727, 5415, 3062, 730, 728, 731, 3621, 3491, 3490, 3620, 3488, }, -- Static Field Totem, Seasoned Winds, Spectral Recovery, Traveling Storms, Control of Lava, Lightning Lasso, Swelling Waves, Unleash Shield, Counterstrike Totem, Grounding Totem, Skyfury Totem
		[2] = { 727, 5415, 3062, 730, 728, 731, 3621, 3491, 3490, 3620, 3488, }, -- Static Field Totem, Seasoned Winds, Spectral Recovery, Traveling Storms, Control of Lava, Lightning Lasso, Swelling Waves, Unleash Shield, Counterstrike Totem, Grounding Totem, Skyfury Totem
		[3] = { 727, 5415, 3062, 730, 728, 731, 3621, 3491, 3490, 3620, 3488, }, -- Static Field Totem, Seasoned Winds, Spectral Recovery, Traveling Storms, Control of Lava, Lightning Lasso, Swelling Waves, Unleash Shield, Counterstrike Totem, Grounding Totem, Skyfury Totem
	},
	-- Enhancement Shaman
	[263] = {
		[1] = { 3623, 3622, 725, 722, 721, 5438, 1944, 5414, 3487, 3489, 3492, 3519, }, -- Swelling Waves, Grounding Totem, Thundercharge, Shamanism, Ride the Lightning, Static Field Totem, Ethereal Form, Seasoned Winds, Skyfury Totem, Counterstrike Totem, Unleash Shield, Spectral Recovery
		[2] = { 3623, 3622, 725, 722, 721, 5438, 1944, 5414, 3487, 3489, 3492, 3519, }, -- Swelling Waves, Grounding Totem, Thundercharge, Shamanism, Ride the Lightning, Static Field Totem, Ethereal Form, Seasoned Winds, Skyfury Totem, Counterstrike Totem, Unleash Shield, Spectral Recovery
		[3] = { 3623, 3622, 725, 722, 721, 5438, 1944, 5414, 3487, 3489, 3492, 3519, }, -- Swelling Waves, Grounding Totem, Thundercharge, Shamanism, Ride the Lightning, Static Field Totem, Ethereal Form, Seasoned Winds, Skyfury Totem, Counterstrike Totem, Unleash Shield, Spectral Recovery
	},
	-- Restoration Shaman
	[264] = {
		[1] = { 1930, 3755, 3756, 5437, 707, 708, 712, 714, 713, 3520, 715, 5388, }, -- Tidebringer, Cleansing Waters, Ancestral Gift, Unleash Shield, Skyfury Totem, Counterstrike Totem, Swelling Waves, Electrocute, Voodoo Mastery, Spectral Recovery, Grounding Totem, Living Tide
		[2] = { 1930, 3755, 3756, 5437, 707, 708, 712, 714, 713, 3520, 715, 5388, }, -- Tidebringer, Cleansing Waters, Ancestral Gift, Unleash Shield, Skyfury Totem, Counterstrike Totem, Swelling Waves, Electrocute, Voodoo Mastery, Spectral Recovery, Grounding Totem, Living Tide
		[3] = { 1930, 3755, 3756, 5437, 707, 708, 712, 714, 713, 3520, 715, 5388, }, -- Tidebringer, Cleansing Waters, Ancestral Gift, Unleash Shield, Skyfury Totem, Counterstrike Totem, Swelling Waves, Electrocute, Voodoo Mastery, Spectral Recovery, Grounding Totem, Living Tide
	},
	-- Affliction Warlock
	[265] = {
		[1] = { 5370, 20, 19, 5379, 18, 17, 16, 15, 12, 5386, 5392, 3740, 11, }, -- Amplify Curse, Casting Circle, Essence Drain, Rampant Afflictions, Nether Ward, Bane of Shadows, Rot and Decay, Gateway Mastery, Deathbolt, Rapid Contagion, Shadow Rift, Shadowfall, Bane of Fragility
		[2] = { 5370, 20, 19, 5379, 18, 17, 16, 15, 12, 5386, 5392, 3740, 11, }, -- Amplify Curse, Casting Circle, Essence Drain, Rampant Afflictions, Nether Ward, Bane of Shadows, Rot and Decay, Gateway Mastery, Deathbolt, Rapid Contagion, Shadow Rift, Shadowfall, Bane of Fragility
		[3] = { 5370, 20, 19, 5379, 18, 17, 16, 15, 12, 5386, 5392, 3740, 11, }, -- Amplify Curse, Casting Circle, Essence Drain, Rampant Afflictions, Nether Ward, Bane of Shadows, Rot and Decay, Gateway Mastery, Deathbolt, Rapid Contagion, Shadow Rift, Shadowfall, Bane of Fragility
	},
	-- Demonology Warlock
	[266] = {
		[1] = { 165, 3506, 5394, 3505, 1213, 3624, 3625, 3626, 3507, 158, 5400, 162, 156, }, -- Call Observer, Gateway Mastery, Shadow Rift, Bane of Fragility, Master Summoner, Nether Ward, Essence Drain, Casting Circle, Amplify Curse, Pleasure through Pain, Fel Obelisk, Call Fel Lord, Call Felhunter
		[2] = { 165, 3506, 5394, 3505, 1213, 3624, 3625, 3626, 3507, 158, 5400, 162, 156, }, -- Call Observer, Gateway Mastery, Shadow Rift, Bane of Fragility, Master Summoner, Nether Ward, Essence Drain, Casting Circle, Amplify Curse, Pleasure through Pain, Fel Obelisk, Call Fel Lord, Call Felhunter
		[3] = { 165, 3506, 5394, 3505, 1213, 3624, 3625, 3626, 3507, 158, 5400, 162, 156, }, -- Call Observer, Gateway Mastery, Shadow Rift, Bane of Fragility, Master Summoner, Nether Ward, Essence Drain, Casting Circle, Amplify Curse, Pleasure through Pain, Fel Obelisk, Call Fel Lord, Call Felhunter
	},
	-- Destruction Warlock
	[267] = {
		[1] = { 164, 5382, 159, 3502, 5401, 3504, 5393, 3508, 3509, 3510, 157, }, -- Bane of Havoc, Gateway Mastery, Cremation, Bane of Fragility, Bonds of Fel, Amplify Curse, Shadow Rift, Nether Ward, Essence Drain, Casting Circle, Fel Fissure
		[2] = { 164, 5382, 159, 3502, 5401, 3504, 5393, 3508, 3509, 3510, 157, }, -- Bane of Havoc, Gateway Mastery, Cremation, Bane of Fragility, Bonds of Fel, Amplify Curse, Shadow Rift, Nether Ward, Essence Drain, Casting Circle, Fel Fissure
		[3] = { 164, 5382, 159, 3502, 5401, 3504, 5393, 3508, 3509, 3510, 157, }, -- Bane of Havoc, Gateway Mastery, Cremation, Bane of Fragility, Bonds of Fel, Amplify Curse, Shadow Rift, Nether Ward, Essence Drain, Casting Circle, Fel Fissure
	},
	-- Brewmaster Monk
	[268] = {
		[1] = { 671, 667, 668, 765, 669, 670, 843, 673, 1958, 672, 5417, 666, }, -- Incendiary Breath, Hot Trub, Guided Meditation, Eerie Fermentation, Avert Harm, Nimble Brew, Admonishment, Mighty Ox Kick, Niuzao's Essence, Double Barrel, Rodeo, Microbrew
		[2] = { 671, 667, 668, 765, 669, 670, 843, 673, 1958, 672, 5417, 666, }, -- Incendiary Breath, Hot Trub, Guided Meditation, Eerie Fermentation, Avert Harm, Nimble Brew, Admonishment, Mighty Ox Kick, Niuzao's Essence, Double Barrel, Rodeo, Microbrew
		[3] = { 671, 667, 668, 765, 669, 670, 843, 673, 1958, 672, 5417, 666, }, -- Incendiary Breath, Hot Trub, Guided Meditation, Eerie Fermentation, Avert Harm, Nimble Brew, Admonishment, Mighty Ox Kick, Niuzao's Essence, Double Barrel, Rodeo, Microbrew
	},
	-- Windwalker Monk
	[269] = {
		[1] = { 5448, 77, 675, 852, 3050, 3052, 3734, 3737, 3744, 3745, }, -- Perpetual Paralysis, Ride the Wind, Tigereye Brew, Reverse Harm, Disabling Reach, Grapple Weapon, Alpha Tiger, Wind Waker, Pressure Points, Turbo Fists
		[2] = { 5448, 77, 675, 852, 3050, 3052, 3734, 3737, 3744, 3745, }, -- Perpetual Paralysis, Ride the Wind, Tigereye Brew, Reverse Harm, Disabling Reach, Grapple Weapon, Alpha Tiger, Wind Waker, Pressure Points, Turbo Fists
		[3] = { 5448, 77, 675, 852, 3050, 3052, 3734, 3737, 3744, 3745, }, -- Perpetual Paralysis, Ride the Wind, Tigereye Brew, Reverse Harm, Disabling Reach, Grapple Weapon, Alpha Tiger, Wind Waker, Pressure Points, Turbo Fists
	},
	-- Mistweaver Monk
	[270] = {
		[1] = { 5402, 70, 678, 682, 680, 1928, 679, 3732, 683, 5398, 5395, }, -- Thunderous Focus Tea, Eminence, Chrysalis, Refreshing Breeze, Dome of Mist, Zen Focus Tea, Counteract Magic, Grapple Weapon, Healing Sphere, Dematerialize, Peaceweaver
		[2] = { 5402, 70, 678, 682, 680, 1928, 679, 3732, 683, 5398, 5395, }, -- Thunderous Focus Tea, Eminence, Chrysalis, Refreshing Breeze, Dome of Mist, Zen Focus Tea, Counteract Magic, Grapple Weapon, Healing Sphere, Dematerialize, Peaceweaver
		[3] = { 5402, 70, 678, 682, 680, 1928, 679, 3732, 683, 5398, 5395, }, -- Thunderous Focus Tea, Eminence, Chrysalis, Refreshing Breeze, Dome of Mist, Zen Focus Tea, Counteract Magic, Grapple Weapon, Healing Sphere, Dematerialize, Peaceweaver
	},
	-- Havoc Demon Hunter
	[577] = {
		[1] = { 810, 5433, 809, 806, 805, 811, 1218, 1206, 1204, 5445, 813, 812, }, -- Demonic Origins, Blood Moon, Chaotic Imprint, Reverse Magic, Cleansed by Flame, Rain from Above, Unending Hatred, Cover of Darkness, Mortal Dance, Isolated Prey, Glimpse, Detainment
		[2] = { 810, 5433, 809, 806, 805, 811, 1218, 1206, 1204, 5445, 813, 812, }, -- Demonic Origins, Blood Moon, Chaotic Imprint, Reverse Magic, Cleansed by Flame, Rain from Above, Unending Hatred, Cover of Darkness, Mortal Dance, Isolated Prey, Glimpse, Detainment
		[3] = { 810, 5433, 809, 806, 805, 811, 1218, 1206, 1204, 5445, 813, 812, }, -- Demonic Origins, Blood Moon, Chaotic Imprint, Reverse Magic, Cleansed by Flame, Rain from Above, Unending Hatred, Cover of Darkness, Mortal Dance, Isolated Prey, Glimpse, Detainment
	},
	-- Vengeance Demon Hunter
	[581] = {
		[1] = { 816, 819, 3423, 5439, 3429, 3727, 3430, 1220, 5434, 815, 814, 1948, }, -- Jagged Spikes, Illidan's Grasp, Demonic Trample, Chaotic Imprint, Reverse Magic, Unending Hatred, Detainment, Tormentor, Blood Moon, Everlasting Hunt, Cleansed by Flame, Sigil Mastery
		[2] = { 816, 819, 3423, 5439, 3429, 3727, 3430, 1220, 5434, 815, 814, 1948, }, -- Jagged Spikes, Illidan's Grasp, Demonic Trample, Chaotic Imprint, Reverse Magic, Unending Hatred, Detainment, Tormentor, Blood Moon, Everlasting Hunt, Cleansed by Flame, Sigil Mastery
		[3] = { 816, 819, 3423, 5439, 3429, 3727, 3430, 1220, 5434, 815, 814, 1948, }, -- Jagged Spikes, Illidan's Grasp, Demonic Trample, Chaotic Imprint, Reverse Magic, Unending Hatred, Detainment, Tormentor, Blood Moon, Everlasting Hunt, Cleansed by Flame, Sigil Mastery
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
