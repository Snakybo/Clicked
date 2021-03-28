local VERSION_MAJOR = "LibTalentInfo-1.0"
local VERSION_MINOR = 7

if LibStub == nil then
	error(VERSION_MAJOR .. " requires LibStub")
end

if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
	return
end

--- @class LibTalentInfo
local LibTalentInfo = LibStub:NewLibrary(VERSION_MAJOR, VERSION_MINOR)

if LibTalentInfo == nil then
	return
end

--- The maximum number of PvP talents slots available.
--- @type integer
LibTalentInfo.MAX_PVP_TALENT_SLOTS = 3

--- @type table<string,table<integer,integer>>
local specializations = {
	WARRIOR = {
		[1] = 71, -- Arms
		[2] = 72, -- Fury
		[3] = 73, -- Protection
		[5] = 1446 -- Initial
	},
	PALADIN = {
		[1] = 65, -- Holy
		[2] = 66, -- Protection
		[3] = 70, -- Retribution
		[5] = 1451 -- Initial
	},
	HUNTER = {
		[1] = 253, -- Beast Mastery
		[2] = 254, -- Marksmanship
		[3] = 255, -- Survival
		[5] = 1448 -- Initial
	},
	ROGUE = {
		[1] = 259, -- Assassination
		[2] = 260, -- Outlaw
		[3] = 261, -- Subtlety
		[5] = 1453 -- Initial
	},
	PRIEST = {
		[1] = 256, -- Discipline
		[2] = 257, -- Holy
		[3] = 258, -- Shadow
		[5] = 1452 -- Initial
	},
	DEATHKNIGHT = {
		[1] = 250, -- Blood
		[2] = 251, -- Frost
		[3] = 252, -- Unholy
		[5] = 1455 -- Initial
	},
	SHAMAN = {
		[1] = 262, -- Elemental
		[2] = 263, -- Enhancement
		[3] = 264, -- Restoration
		[5] = 1444 -- Initial
	},
	MAGE = {
		[1] = 62, -- Arcane
		[2] = 63, -- Fire
		[3] = 64, -- Frost
		[5] = 1449 -- Initial
	},
	WARLOCK = {
		[1] = 265, -- Afflication
		[2] = 266, -- Demonology
		[3] = 267, -- Destruction
		[5] = 1454 -- Initial
	},
	MONK = {
		[1] = 268, -- Brewmaster
		[2] = 270, -- Mistweaver
		[3] = 269, -- Windwalker
		[5] = 1450 -- Initial
	},
	DRUID = {
		[1] = 102, -- Balance
		[2] = 103, -- Feral
		[3] = 104, -- Guardian
		[4] = 105, -- Restoration
		[5] = 1447 -- Initial
	},
	DEMONHUNTER = {
		[1] = 577, -- Havoc
		[2] = 581, -- Vengeance
		[5] = 1456 -- Initial
	}
}

-- Macro to retrieve all talent IDs for the current specialization:
-- /run local a=""local b=table.concat;local c=", "for d=1,MAX_TALENT_TIERS do local e,f={},{}for g=1,NUM_TALENT_COLUMNS do local h,i=GetTalentInfo(d,g,1)e[#e+1]=h;f[#f+1]=i end;a=a..b(e,c)..", -- "..b(f,c).."\n"end;print(a)

--- @type table<integer,integer[]>
local talents = {
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
	-- Initial Warrior
	[1446] = {
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
	-- Initial Paladin
	[1451] = {
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
	-- Initial Hunter
	[1448] = {
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
	-- Initial Rogue
	[1453] = {
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
	-- Initial Priest
	[1452] = {
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
	-- Initial Death Knight
	[1455] = {
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
	-- Initial Shaman
	[1444] = {
	},
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
	-- Initial Mage
	[1449] = {
	},
	-- Afflication Warlock
	[265] = {
		22039, 23140, 23141, -- Nightfall, Inevitable Demise, Drain Soul
		22044, 21180, 22089, -- Writhe in Agony, Absolute Corruption, Siphon Life
		19280, 19285, 19286, -- Demon Skin, Burning Rush, Dark Pact
		19279, 19292, 22046, -- Sow the Seeds, Phantom Singularity, Vile Taint
		22047, 19291, 23465, -- Darkfury, Mortal Coil, Howl of Terror
		23139, 23159, 19295, -- Dark Caller, Haunt, Grimoire of Sacrifice
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
	-- Initial Warlock
	[1454] = {
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
	-- Initial Monk
	[1450] = {
	},
	-- Balance Druid
	[102] = {
		22385, 22386, 22387, -- Nature's Balance, Warrior of Elune, Force of Nature
		19283, 18570, 18571, -- Tiger Dash, Renewal, Wild Charge
		22155, 22157, 22159, -- Feral Affinity, Guardian Affinity, Restoration Affinity
		21778, 18576, 18577, -- Mighty Bash, Mass Entanglement, Heart of the Wild
		18580, 21706, 21702, -- Soul of the Forest, Starlord, Incarnation: Chosen of Elune
		22389, 21712, 22165, -- Stellar Drift, Twin Moons, Stellar Flare
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
	-- Initial Druid
	[1447] = {
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
	-- Initial Demon Hunter
	[1456] = {
	}
}

-- Macro to retrieve all PvP talent IDs for the current specialization:
-- /run local a,b,c,d,e=C_SpecializationInfo.GetPvpTalentSlotInfo(1),table.concat,", ",{},{}local f=a.availableTalentIDs;for g=1,#f do local h,i=GetPvpTalentInfoByID(f[g])d[#d+1]=h;e[#e+1]=i end;print("[1] = { "..b(d,c).." }, -- "..b(e,c))

--- @type table<integer,table<integer,integer[]>>
local pvpTalents = {
	-- Arms Warrior
	[71] = {
		[1] = { 29, 3534, 34, 33, 5376, 28, 5372, 3522, 32, 31 }, -- Shadow of the Colossus, Disarm, Duel, Sharpen Blade, Overwatch, Master and Commander, Demolition, Death Sentence, War Banner, Storm of Destruction
		[2] = { 29, 3534, 34, 33, 5376, 28, 5372, 3522, 32, 31 }, -- Shadow of the Colossus, Disarm, Duel, Sharpen Blade, Overwatch, Master and Commander, Demolition, Death Sentence, War Banner, Storm of Destruction
		[3] = { 29, 3534, 34, 33, 5376, 28, 5372, 3522, 32, 31 }, -- Shadow of the Colossus, Disarm, Duel, Sharpen Blade, Overwatch, Master and Commander, Demolition, Death Sentence, War Banner, Storm of Destruction
	},
	-- Fury Warrior
	[72] = {
		[1] = { 166, 177, 25, 170, 172, 3735, 3533, 3528, 5373, 5375, 179 }, -- Barbarian, Enduring Rage, Death Sentence, Battle Trance, Bloodrage, Slaughterhouse, Disarm, Master and Commander, Demolition, Overwatch, Death Wish
		[2] = { 166, 177, 25, 170, 172, 3735, 3533, 3528, 5373, 5375, 179 }, -- Barbarian, Enduring Rage, Death Sentence, Battle Trance, Bloodrage, Slaughterhouse, Disarm, Master and Commander, Demolition, Overwatch, Death Wish
		[3] = { 166, 177, 25, 170, 172, 3735, 3533, 3528, 5373, 5375, 179 }, -- Barbarian, Enduring Rage, Death Sentence, Battle Trance, Bloodrage, Slaughterhouse, Disarm, Master and Commander, Demolition, Overwatch, Death Wish
	},
	-- Protection Warrior
	[73] = {
		[1] = { 167, 168, 171, 173, 175, 178, 5374, 831, 833, 24, 845, 5378 }, -- Sword and Board, Bodyguard, Morale Killer, Shield Bash, Thunderstruck, Warpath, Demolition, Dragon Charge, Rebound, Disarm, Oppressor, Overwatch
		[2] = { 167, 168, 171, 173, 175, 178, 5374, 831, 833, 24, 845, 5378 }, -- Sword and Board, Bodyguard, Morale Killer, Shield Bash, Thunderstruck, Warpath, Demolition, Dragon Charge, Rebound, Disarm, Oppressor, Overwatch
		[3] = { 167, 168, 171, 173, 175, 178, 5374, 831, 833, 24, 845, 5378 }, -- Sword and Board, Bodyguard, Morale Killer, Shield Bash, Thunderstruck, Warpath, Demolition, Dragon Charge, Rebound, Disarm, Oppressor, Overwatch
	},
	-- Initial Warrior
	[1446] = {
	},
	-- Holy Paladin
	[65] = {
		[1] = { 640, 642, 85, 88, 86, 3618, 82, 689, 87, 859 }, -- Divine Vision, Cleanse the Weak, Ultimate Sacrifice, Blessed Hands, Darkest before the Dawn, Hallowed Ground, Avenging Light, Divine Favor, Spreading the Word, Light's Grace
		[2] = { 640, 642, 85, 88, 86, 3618, 82, 689, 87, 859 }, -- Divine Vision, Cleanse the Weak, Ultimate Sacrifice, Blessed Hands, Darkest before the Dawn, Hallowed Ground, Avenging Light, Divine Favor, Spreading the Word, Light's Grace
		[3] = { 640, 642, 85, 88, 86, 3618, 82, 689, 87, 859 }, -- Divine Vision, Cleanse the Weak, Ultimate Sacrifice, Blessed Hands, Darkest before the Dawn, Hallowed Ground, Avenging Light, Divine Favor, Spreading the Word, Light's Grace
	},
	-- Protection Paladin
	[66] = {
		[1] = { 97, 3475, 3474, 861, 860, 844, 3472, 90, 91, 92, 93, 94 }, -- Guarded by the Light, Unbound Freedom, Luminescence, Shield of Virtue, Warrior of Light, Inquisition, Cleansing Light, Hallowed Ground, Steed of Glory, Sacred Duty, Judgments of the Pure, Guardian of the Forgotten Queen
		[2] = { 97, 3475, 3474, 861, 860, 844, 3472, 90, 91, 92, 93, 94 }, -- Guarded by the Light, Unbound Freedom, Luminescence, Shield of Virtue, Warrior of Light, Inquisition, Cleansing Light, Hallowed Ground, Steed of Glory, Sacred Duty, Judgments of the Pure, Guardian of the Forgotten Queen
		[3] = { 97, 3475, 3474, 861, 860, 844, 3472, 90, 91, 92, 93, 94 }, -- Guarded by the Light, Unbound Freedom, Luminescence, Shield of Virtue, Warrior of Light, Inquisition, Cleansing Light, Hallowed Ground, Steed of Glory, Sacred Duty, Judgments of the Pure, Guardian of the Forgotten Queen
	},
	-- Retribution Paladin
	[70] = {
		[1] = { 81, 3055, 858, 751, 752, 641, 756, 755, 757, 754, 753 }, -- Luminescence, Cleansing Light, Law and Order, Vengeance Aura, Blessing of Sanctuary, Unbound Freedom, Aura of Reckoning, Divine Punisher, Jurisdiction, Lawbringer, Ultimate Retribution
		[2] = { 81, 3055, 858, 751, 752, 641, 756, 755, 757, 754, 753 }, -- Luminescence, Cleansing Light, Law and Order, Vengeance Aura, Blessing of Sanctuary, Unbound Freedom, Aura of Reckoning, Divine Punisher, Jurisdiction, Lawbringer, Ultimate Retribution
		[3] = { 81, 3055, 858, 751, 752, 641, 756, 755, 757, 754, 753 }, -- Luminescence, Cleansing Light, Law and Order, Vengeance Aura, Blessing of Sanctuary, Unbound Freedom, Aura of Reckoning, Divine Punisher, Jurisdiction, Lawbringer, Ultimate Retribution
	},
	-- Initial Paladin
	[1451] = {
	},
	-- Beast Mastery Hunter
	[253] = {
		[1] = { 824, 3599, 3600, 3602, 3603, 3604, 3612, 825, 3730, 821, 3605, 693, 1214 }, -- Dire Beast: Hawk, Survival Tactics, Dragonscale Armor, Viper Sting, Spider Sting, Scorpid Sting, Roar of Sacrifice, Dire Beast: Basilisk, Hunting Pack, Wild Protector, Hi-Explosive Trap, The Beast Within, Interlope
		[2] = { 824, 3599, 3600, 3602, 3603, 3604, 3612, 825, 3730, 821, 3605, 693, 1214 }, -- Dire Beast: Hawk, Survival Tactics, Dragonscale Armor, Viper Sting, Spider Sting, Scorpid Sting, Roar of Sacrifice, Dire Beast: Basilisk, Hunting Pack, Wild Protector, Hi-Explosive Trap, The Beast Within, Interlope
		[3] = { 824, 3599, 3600, 3602, 3603, 3604, 3612, 825, 3730, 821, 3605, 693, 1214 }, -- Dire Beast: Hawk, Survival Tactics, Dragonscale Armor, Viper Sting, Spider Sting, Scorpid Sting, Roar of Sacrifice, Dire Beast: Basilisk, Hunting Pack, Wild Protector, Hi-Explosive Trap, The Beast Within, Interlope
	},
	-- Marksmanship Hunter
	[254] = {
		[1] = { 649, 651, 652, 653, 654, 656, 3614, 657, 3729, 658, 659, 660 }, -- Dragonscale Armor, Survival Tactics, Viper Sting, Scorpid Sting, Spider Sting, Scatter Shot, Roar of Sacrifice, Hi-Explosive Trap, Hunting Pack, Trueshot Mastery, Ranger's Finesse, Sniper Shot
		[2] = { 649, 651, 652, 653, 654, 656, 3614, 657, 3729, 658, 659, 660 }, -- Dragonscale Armor, Survival Tactics, Viper Sting, Scorpid Sting, Spider Sting, Scatter Shot, Roar of Sacrifice, Hi-Explosive Trap, Hunting Pack, Trueshot Mastery, Ranger's Finesse, Sniper Shot
		[3] = { 649, 651, 652, 653, 654, 656, 3614, 657, 3729, 658, 659, 660 }, -- Dragonscale Armor, Survival Tactics, Viper Sting, Scorpid Sting, Spider Sting, Scatter Shot, Roar of Sacrifice, Hi-Explosive Trap, Hunting Pack, Trueshot Mastery, Ranger's Finesse, Sniper Shot
	},
	-- Survival Hunter
	[255] = {
		[1] = { 665, 686, 664, 3606, 3607, 3608, 3609, 3610, 3615, 662, 663, 661 }, -- Tracker's Net, Diamond Ice, Sticky Tar, Hi-Explosive Trap, Survival Tactics, Spider Sting, Scorpid Sting, Dragonscale Armor, Viper Sting, Mending Bandage, Roar of Sacrifice, Hunting Pack
		[2] = { 665, 686, 664, 3606, 3607, 3608, 3609, 3610, 3615, 662, 663, 661 }, -- Tracker's Net, Diamond Ice, Sticky Tar, Hi-Explosive Trap, Survival Tactics, Spider Sting, Scorpid Sting, Dragonscale Armor, Viper Sting, Mending Bandage, Roar of Sacrifice, Hunting Pack
		[3] = { 665, 686, 664, 3606, 3607, 3608, 3609, 3610, 3615, 662, 663, 661 }, -- Tracker's Net, Diamond Ice, Sticky Tar, Hi-Explosive Trap, Survival Tactics, Spider Sting, Scorpid Sting, Dragonscale Armor, Viper Sting, Mending Bandage, Roar of Sacrifice, Hunting Pack
	},
	-- Initial Hunter
	[1448] = {
	},
	-- Assassination Rogue
	[259] = {
		[1] = { 144, 130, 141, 132, 147, 137, 830, 3479, 3480, 3448 }, -- Flying Daggers, Intent to Kill, Creeping Venom, Honor Among Thieves, System Shock, Mind-Numbing Poison, Neurotoxin, Death from Above, Smoke Bomb, Maneuverability
		[2] = { 144, 130, 141, 132, 147, 137, 830, 3479, 3480, 3448 }, -- Flying Daggers, Intent to Kill, Creeping Venom, Honor Among Thieves, System Shock, Mind-Numbing Poison, Neurotoxin, Death from Above, Smoke Bomb, Maneuverability
		[3] = { 144, 130, 141, 132, 147, 137, 830, 3479, 3480, 3448 }, -- Flying Daggers, Intent to Kill, Creeping Venom, Honor Among Thieves, System Shock, Mind-Numbing Poison, Neurotoxin, Death from Above, Smoke Bomb, Maneuverability
	},
	-- Outlaw Rogue
	[260] = {
		[1] = { 142, 3421, 3619, 3451, 129, 3483, 139, 138, 1208, 145, 135, 853, 150 }, -- Cheap Tricks, Turn the Tables, Death from Above, Honor Among Thieves, Maneuverability, Smoke Bomb, Drink Up Me Hearties, Control is King, Thick as Thieves, Dismantle, Take Your Cut, Boarding Party, Plunder Armor
		[2] = { 142, 3421, 3619, 3451, 129, 3483, 139, 138, 1208, 145, 135, 853, 150 }, -- Cheap Tricks, Turn the Tables, Death from Above, Honor Among Thieves, Maneuverability, Smoke Bomb, Drink Up Me Hearties, Control is King, Thick as Thieves, Dismantle, Take Your Cut, Boarding Party, Plunder Armor
		[3] = { 142, 3421, 3619, 3451, 129, 3483, 139, 138, 1208, 145, 135, 853, 150 }, -- Cheap Tricks, Turn the Tables, Death from Above, Honor Among Thieves, Maneuverability, Smoke Bomb, Drink Up Me Hearties, Control is King, Thick as Thieves, Dismantle, Take Your Cut, Boarding Party, Plunder Armor
	},
	-- Subtlety Rogue
	[261] = {
		[1] = { 140, 153, 3447, 3452, 3462, 146, 846, 856, 1209, 136 }, -- Cold Blood, Shadowy Duel, Maneuverability, Honor Among Thieves, Death from Above, Thief's Bargain, Dagger in the Dark, Silhouette, Smoke Bomb, Veil of Midnight
		[2] = { 140, 153, 3447, 3452, 3462, 146, 846, 856, 1209, 136 }, -- Cold Blood, Shadowy Duel, Maneuverability, Honor Among Thieves, Death from Above, Thief's Bargain, Dagger in the Dark, Silhouette, Smoke Bomb, Veil of Midnight
		[3] = { 140, 153, 3447, 3452, 3462, 146, 846, 856, 1209, 136 }, -- Cold Blood, Shadowy Duel, Maneuverability, Honor Among Thieves, Death from Above, Thief's Bargain, Dagger in the Dark, Silhouette, Smoke Bomb, Veil of Midnight
	},
	-- Initial Rogue
	[1453] = {
	},
	-- Discipline Priest
	[256] = {
		[1] = { 855, 1244, 100, 98, 109, 111, 114, 117, 123, 126 }, -- Thoughtsteal, Searing Light, Purified Resolve, Purification, Trinity, Strength of Soul, Ultimate Radiance, Dome of Light, Archangel, Dark Archangel
		[2] = { 855, 1244, 100, 98, 109, 111, 114, 117, 123, 126 }, -- Thoughtsteal, Searing Light, Purified Resolve, Purification, Trinity, Strength of Soul, Ultimate Radiance, Dome of Light, Archangel, Dark Archangel
		[3] = { 855, 1244, 100, 98, 109, 111, 114, 117, 123, 126 }, -- Thoughtsteal, Searing Light, Purified Resolve, Purification, Trinity, Strength of Soul, Ultimate Radiance, Dome of Light, Archangel, Dark Archangel
	},
	-- Holy Priest
	[257] = {
		[1] = { 115, 1927, 101, 1242, 127, 124, 5365, 5366, 108, 118, 112 }, -- Cardinal Mending, Delivered from Evil, Holy Ward, Greater Fade, Ray of Hope, Spirit of the Redeemer, Thoughtsteal, Divine Ascension, Holy Word: Concentration, Miracle Worker, Greater Heal
		[2] = { 115, 1927, 101, 1242, 127, 124, 5365, 5366, 108, 118, 112 }, -- Cardinal Mending, Delivered from Evil, Holy Ward, Greater Fade, Ray of Hope, Spirit of the Redeemer, Thoughtsteal, Divine Ascension, Holy Word: Concentration, Miracle Worker, Greater Heal
		[3] = { 115, 1927, 101, 1242, 127, 124, 5365, 5366, 108, 118, 112 }, -- Cardinal Mending, Delivered from Evil, Holy Ward, Greater Fade, Ray of Hope, Spirit of the Redeemer, Thoughtsteal, Divine Ascension, Holy Word: Concentration, Miracle Worker, Greater Heal
	},
	-- Shadow Priest
	[258] = {
		[1] = { 113, 5381, 128, 763, 739, 5380, 3753, 102, 106 }, -- Mind Trauma, Thoughtsteal, Void Shift, Psyfiend, Void Origins, Lasting Plague, Greater Fade, Void Shield, Driven to Madness
		[2] = { 113, 5381, 128, 763, 739, 5380, 3753, 102, 106 }, -- Mind Trauma, Thoughtsteal, Void Shift, Psyfiend, Void Origins, Lasting Plague, Greater Fade, Void Shield, Driven to Madness
		[3] = { 113, 5381, 128, 763, 739, 5380, 3753, 102, 106 }, -- Mind Trauma, Thoughtsteal, Void Shift, Psyfiend, Void Origins, Lasting Plague, Greater Fade, Void Shield, Driven to Madness
	},
	-- Initial Priest
	[1452] = {
	},
	-- Blood Death Knight
	[250] = {
		[1] = { 841, 3511, 204, 5368, 3441, 609, 608, 607, 206, 205, 3436 }, -- Murderous Intent, Dark Simulacrum, Rot and Wither, Dome of Ancient Shadow, Decomposing Aura, Death Chain, Last Dance, Blood for Blood, Strangulate, Walking Dead, Necrotic Aura
		[2] = { 841, 3511, 204, 5368, 3441, 609, 608, 607, 206, 205, 3436 }, -- Murderous Intent, Dark Simulacrum, Rot and Wither, Dome of Ancient Shadow, Decomposing Aura, Death Chain, Last Dance, Blood for Blood, Strangulate, Walking Dead, Necrotic Aura
		[3] = { 841, 3511, 204, 5368, 3441, 609, 608, 607, 206, 205, 3436 }, -- Murderous Intent, Dark Simulacrum, Rot and Wither, Dome of Ancient Shadow, Decomposing Aura, Death Chain, Last Dance, Blood for Blood, Strangulate, Walking Dead, Necrotic Aura
	},
	-- Frost Death Knight
	[251] = {
		[1] = { 3439, 701, 702, 706, 43, 3749, 3743, 5369, 3515, 3512 }, -- Heartstop Aura, Deathchill, Delirium, Chill Streak, Necrotic Aura, Transfusion, Dead of Winter, Dome of Ancient Shadow, Cadaverous Pallor, Dark Simulacrum
		[2] = { 3439, 701, 702, 706, 43, 3749, 3743, 5369, 3515, 3512 }, -- Heartstop Aura, Deathchill, Delirium, Chill Streak, Necrotic Aura, Transfusion, Dead of Winter, Dome of Ancient Shadow, Cadaverous Pallor, Dark Simulacrum
		[3] = { 3439, 701, 702, 706, 43, 3749, 3743, 5369, 3515, 3512 }, -- Heartstop Aura, Deathchill, Delirium, Chill Streak, Necrotic Aura, Transfusion, Dead of Winter, Dome of Ancient Shadow, Cadaverous Pallor, Dark Simulacrum
	},
	-- Unholy Death Knight
	[252] = {
		[1] = { 152, 3748, 3747, 3746, 163, 149, 41, 40, 3440, 3437, 5367 }, -- Reanimation, Transfusion, Raise Abomination, Necromancer's Bargain, Cadaverous Pallor, Necrotic Strike, Dark Simulacrum, Life and Death, Decomposing Aura, Necrotic Aura, Dome of Ancient Shadow
		[2] = { 152, 3748, 3747, 3746, 163, 149, 41, 40, 3440, 3437, 5367 }, -- Reanimation, Transfusion, Raise Abomination, Necromancer's Bargain, Cadaverous Pallor, Necrotic Strike, Dark Simulacrum, Life and Death, Decomposing Aura, Necrotic Aura, Dome of Ancient Shadow
		[3] = { 152, 3748, 3747, 3746, 163, 149, 41, 40, 3440, 3437, 5367 }, -- Reanimation, Transfusion, Raise Abomination, Necromancer's Bargain, Cadaverous Pallor, Necrotic Strike, Dark Simulacrum, Life and Death, Decomposing Aura, Necrotic Aura, Dome of Ancient Shadow
	},
	-- Initial Death Knight
	[1455] = {
	},
	-- Elemental Shaman
	[262] = {
		[1] = { 3621, 731, 3488, 727, 728, 730, 3491, 3490, 3620, 3062 }, -- Swelling Waves, Lightning Lasso, Skyfury Totem, Elemental Attunement, Control of Lava, Traveling Storms, Purifying Waters, Counterstrike Totem, Grounding Totem, Spectral Recovery
		[2] = { 3621, 731, 3488, 727, 728, 730, 3491, 3490, 3620, 3062 }, -- Swelling Waves, Lightning Lasso, Skyfury Totem, Elemental Attunement, Control of Lava, Traveling Storms, Purifying Waters, Counterstrike Totem, Grounding Totem, Spectral Recovery
		[3] = { 3621, 731, 3488, 727, 728, 730, 3491, 3490, 3620, 3062 }, -- Swelling Waves, Lightning Lasso, Skyfury Totem, Elemental Attunement, Control of Lava, Traveling Storms, Purifying Waters, Counterstrike Totem, Grounding Totem, Spectral Recovery
	},
	-- Enhancement Shaman
	[263] = {
		[1] = { 3622, 3487, 3623, 721, 3519, 3492, 722, 725, 1944, 3489 }, -- Grounding Totem, Skyfury Totem, Swelling Waves, Ride the Lightning, Spectral Recovery, Purifying Waters, Shamanism, Thundercharge, Ethereal Form, Counterstrike Totem
		[2] = { 3622, 3487, 3623, 721, 3519, 3492, 722, 725, 1944, 3489 }, -- Grounding Totem, Skyfury Totem, Swelling Waves, Ride the Lightning, Spectral Recovery, Purifying Waters, Shamanism, Thundercharge, Ethereal Form, Counterstrike Totem
		[3] = { 3622, 3487, 3623, 721, 3519, 3492, 722, 725, 1944, 3489 }, -- Grounding Totem, Skyfury Totem, Swelling Waves, Ride the Lightning, Spectral Recovery, Purifying Waters, Shamanism, Thundercharge, Ethereal Form, Counterstrike Totem
	},
	-- Restoration Shaman
	[264] = {
		[1] = { 3520, 3756, 3755, 718, 715, 714, 713, 712, 708, 707, 1930 }, -- Spectral Recovery, Ancestral Gift, Cleansing Waters, Spirit Link, Grounding Totem, Electrocute, Voodoo Mastery, Swelling Waves, Counterstrike Totem, Skyfury Totem, Tidebringer
		[2] = { 3520, 3756, 3755, 718, 715, 714, 713, 712, 708, 707, 1930 }, -- Spectral Recovery, Ancestral Gift, Cleansing Waters, Spirit Link, Grounding Totem, Electrocute, Voodoo Mastery, Swelling Waves, Counterstrike Totem, Skyfury Totem, Tidebringer
		[3] = { 3520, 3756, 3755, 718, 715, 714, 713, 712, 708, 707, 1930 }, -- Spectral Recovery, Ancestral Gift, Cleansing Waters, Spirit Link, Grounding Totem, Electrocute, Voodoo Mastery, Swelling Waves, Counterstrike Totem, Skyfury Totem, Tidebringer
	},
	-- Initial Shaman
	[1444] = {
	},
	-- Arcane Mage
	[62] = {
		[1] = { 3517, 3529, 3442, 62, 61, 637, 635, 3523, 3531 }, -- Temporal Shield, Kleptomania, Netherwind Armor, Torment the Weak, Arcane Empowerment, Mass Invisibility, Master of Escape, Dampened Magic, Prismatic Cloak
		[2] = { 3517, 3529, 3442, 62, 61, 637, 635, 3523, 3531 }, -- Temporal Shield, Kleptomania, Netherwind Armor, Torment the Weak, Arcane Empowerment, Mass Invisibility, Master of Escape, Dampened Magic, Prismatic Cloak
		[3] = { 3517, 3529, 3442, 62, 61, 637, 635, 3523, 3531 }, -- Temporal Shield, Kleptomania, Netherwind Armor, Torment the Weak, Arcane Empowerment, Mass Invisibility, Master of Escape, Dampened Magic, Prismatic Cloak
	},
	-- Fire Mage
	[63] = {
		[1] = { 53, 828, 3530, 3524, 648, 647, 646, 645, 644, 643 }, -- Netherwind Armor, Prismatic Cloak, Kleptomania, Dampened Magic, Greater Pyroblast, Flamecannon, Pyrokinesis, Controlled Burn, World in Flames, Tinder
		[2] = { 53, 828, 3530, 3524, 648, 647, 646, 645, 644, 643 }, -- Netherwind Armor, Prismatic Cloak, Kleptomania, Dampened Magic, Greater Pyroblast, Flamecannon, Pyrokinesis, Controlled Burn, World in Flames, Tinder
		[3] = { 53, 828, 3530, 3524, 648, 647, 646, 645, 644, 643 }, -- Netherwind Armor, Prismatic Cloak, Kleptomania, Dampened Magic, Greater Pyroblast, Flamecannon, Pyrokinesis, Controlled Burn, World in Flames, Tinder
	},
	-- Frost Mage
	[64] = {
		[1] = { 57, 58, 66, 67, 68, 632, 3532, 3443, 634, 633 }, -- Dampened Magic, Kleptomania, Chilled to the Bone, Frostbite, Deep Shatter, Concentrated Coolness, Prismatic Cloak, Netherwind Armor, Ice Form, Burst of Cold
		[2] = { 57, 58, 66, 67, 68, 632, 3532, 3443, 634, 633 }, -- Dampened Magic, Kleptomania, Chilled to the Bone, Frostbite, Deep Shatter, Concentrated Coolness, Prismatic Cloak, Netherwind Armor, Ice Form, Burst of Cold
		[3] = { 57, 58, 66, 67, 68, 632, 3532, 3443, 634, 633 }, -- Dampened Magic, Kleptomania, Chilled to the Bone, Frostbite, Deep Shatter, Concentrated Coolness, Prismatic Cloak, Netherwind Armor, Ice Form, Burst of Cold
	},
	-- Initial Mage
	[1449] = {
	},
	-- Afflication Warlock
	[265] = {
		[1] = { 5379, 15, 16, 17, 18, 19, 20, 5370, 11, 5386, 12, 13, 3740 }, -- Rampant Afflictions, Gateway Mastery, Rot and Decay, Bane of Shadows, Nether Ward, Essence Drain, Casting Circle, Amplify Curse, Bane of Fragility, Rapid Contagion, Deathbolt, Soulshatter, Demon Armor
		[2] = { 5379, 15, 16, 17, 18, 19, 20, 5370, 11, 5386, 12, 13, 3740 }, -- Rampant Afflictions, Gateway Mastery, Rot and Decay, Bane of Shadows, Nether Ward, Essence Drain, Casting Circle, Amplify Curse, Bane of Fragility, Rapid Contagion, Deathbolt, Soulshatter, Demon Armor
		[3] = { 5379, 15, 16, 17, 18, 19, 20, 5370, 11, 5386, 12, 13, 3740 }, -- Rampant Afflictions, Gateway Mastery, Rot and Decay, Bane of Shadows, Nether Ward, Essence Drain, Casting Circle, Amplify Curse, Bane of Fragility, Rapid Contagion, Deathbolt, Soulshatter, Demon Armor
	},
	-- Demonology Warlock
	[266] = {
		[1] = { 1213, 162, 3505, 158, 3506, 156, 154, 3507, 165, 3626, 3625, 3624 }, -- Master Summoner, Call Fel Lord, Bane of Fragility, Pleasure through Pain, Gateway Mastery, Call Felhunter, Singe Magic, Amplify Curse, Call Observer, Casting Circle, Essence Drain, Nether Ward
		[2] = { 1213, 162, 3505, 158, 3506, 156, 154, 3507, 165, 3626, 3625, 3624 }, -- Master Summoner, Call Fel Lord, Bane of Fragility, Pleasure through Pain, Gateway Mastery, Call Felhunter, Singe Magic, Amplify Curse, Call Observer, Casting Circle, Essence Drain, Nether Ward
		[3] = { 1213, 162, 3505, 158, 3506, 156, 154, 3507, 165, 3626, 3625, 3624 }, -- Master Summoner, Call Fel Lord, Bane of Fragility, Pleasure through Pain, Gateway Mastery, Call Felhunter, Singe Magic, Amplify Curse, Call Observer, Casting Circle, Essence Drain, Nether Ward
	},
	-- Destruction Warlock
	[267] = {
		[1] = { 5382, 3741, 3504, 3502, 164, 3508, 3509, 3510, 159, 157, 155 }, -- Gateway Mastery, Demon Armor, Amplify Curse, Bane of Fragility, Bane of Havoc, Nether Ward, Essence Drain, Casting Circle, Cremation, Fel Fissure, Focused Chaos
		[2] = { 5382, 3741, 3504, 3502, 164, 3508, 3509, 3510, 159, 157, 155 }, -- Gateway Mastery, Demon Armor, Amplify Curse, Bane of Fragility, Bane of Havoc, Nether Ward, Essence Drain, Casting Circle, Cremation, Fel Fissure, Focused Chaos
		[3] = { 5382, 3741, 3504, 3502, 164, 3508, 3509, 3510, 159, 157, 155 }, -- Gateway Mastery, Demon Armor, Amplify Curse, Bane of Fragility, Bane of Havoc, Nether Ward, Essence Drain, Casting Circle, Cremation, Fel Fissure, Focused Chaos
	},
	-- Initial Warlock
	[1454] = {
	},
	-- Brewmaster Monk
	[268] = {
		[1] = { 669, 668, 667, 1958, 666, 670, 671, 672, 673, 765, 843 }, -- Avert Harm, Guided Meditation, Hot Trub, Niuzao's Essence, Microbrew, Craft: Nimble Brew, Incendiary Breath, Double Barrel, Mighty Ox Kick, Eerie Fermentation, Admonishment
		[2] = { 669, 668, 667, 1958, 666, 670, 671, 672, 673, 765, 843 }, -- Avert Harm, Guided Meditation, Hot Trub, Niuzao's Essence, Microbrew, Craft: Nimble Brew, Incendiary Breath, Double Barrel, Mighty Ox Kick, Eerie Fermentation, Admonishment
		[3] = { 669, 668, 667, 1958, 666, 670, 671, 672, 673, 765, 843 }, -- Avert Harm, Guided Meditation, Hot Trub, Niuzao's Essence, Microbrew, Craft: Nimble Brew, Incendiary Breath, Double Barrel, Mighty Ox Kick, Eerie Fermentation, Admonishment
	},
	-- Mistweaver Monk
	[270] = {
		[1] = { 3732, 1928, 70, 682, 680, 683, 681, 678, 679 }, -- Grapple Weapon, Zen Focus Tea, Eminence, Refreshing Breeze, Dome of Mist, Healing Sphere, Surging Mist, Chrysalis, Counteract Magic
		[2] = { 3732, 1928, 70, 682, 680, 683, 681, 678, 679 }, -- Grapple Weapon, Zen Focus Tea, Eminence, Refreshing Breeze, Dome of Mist, Healing Sphere, Surging Mist, Chrysalis, Counteract Magic
		[3] = { 3732, 1928, 70, 682, 680, 683, 681, 678, 679 }, -- Grapple Weapon, Zen Focus Tea, Eminence, Refreshing Breeze, Dome of Mist, Healing Sphere, Surging Mist, Chrysalis, Counteract Magic
	},
	-- Windwalker Monk
	[269] = {
		[1] = { 3745, 675, 852, 77, 3744, 3050, 3052, 3734, 3737 }, -- Turbo Fists, Tigereye Brew, Reverse Harm, Ride the Wind, Pressure Points, Disabling Reach, Grapple Weapon, Alpha Tiger, Wind Waker
		[2] = { 3745, 675, 852, 77, 3744, 3050, 3052, 3734, 3737 }, -- Turbo Fists, Tigereye Brew, Reverse Harm, Ride the Wind, Pressure Points, Disabling Reach, Grapple Weapon, Alpha Tiger, Wind Waker
		[3] = { 3745, 675, 852, 77, 3744, 3050, 3052, 3734, 3737 }, -- Turbo Fists, Tigereye Brew, Reverse Harm, Ride the Wind, Pressure Points, Disabling Reach, Grapple Weapon, Alpha Tiger, Wind Waker
	},
	-- Initial Monk
	[1450] = {
	},
	-- Balance Druid
	[102] = {
		[1] = { 182, 184, 836, 834, 185, 3728, 3731, 3058, 180, 5383, 822 }, -- Crescent Burn, Moon and Stars, Faerie Swarm, Deep Roots, Moonkin Aura, Protector of the Grove, Thorns, Prickling Thorns, Celestial Guardian, High Winds, Dying Stars
		[2] = { 182, 184, 836, 834, 185, 3728, 3731, 3058, 180, 5383, 822 }, -- Crescent Burn, Moon and Stars, Faerie Swarm, Deep Roots, Moonkin Aura, Protector of the Grove, Thorns, Prickling Thorns, Celestial Guardian, High Winds, Dying Stars
		[3] = { 182, 184, 836, 834, 185, 3728, 3731, 3058, 180, 5383, 822 }, -- Crescent Burn, Moon and Stars, Faerie Swarm, Deep Roots, Moonkin Aura, Protector of the Grove, Thorns, Prickling Thorns, Celestial Guardian, High Winds, Dying Stars
	},
	-- Feral Druid
	[103] = {
		[1] = { 201, 203, 601, 602, 612, 620, 3053, 611, 5384, 3751, 820 }, -- Thorns, Freedom of the Herd, Malorne's Swiftness, King of the Jungle, Fresh Wound, Rip and Tear, Strength of the Wild, Ferocious Wound, High Winds, Leader of the Pack, Savage Momentum
		[2] = { 201, 203, 601, 602, 612, 620, 3053, 611, 5384, 3751, 820 }, -- Thorns, Freedom of the Herd, Malorne's Swiftness, King of the Jungle, Fresh Wound, Rip and Tear, Strength of the Wild, Ferocious Wound, High Winds, Leader of the Pack, Savage Momentum
		[3] = { 201, 203, 601, 602, 612, 620, 3053, 611, 5384, 3751, 820 }, -- Thorns, Freedom of the Herd, Malorne's Swiftness, King of the Jungle, Fresh Wound, Rip and Tear, Strength of the Wild, Ferocious Wound, High Winds, Leader of the Pack, Savage Momentum
	},
	-- Guardian Druid
	[104] = {
		[1] = { 193, 196, 197, 192, 50, 5385, 51, 49, 195, 1237, 52, 3750, 194, 842 }, -- Sharpened Claws, Overrun, Roar of the Protector, Raging Frenzy, Toughness, High Winds, Den Mother, Master Shapeshifter, Entangling Claws, Malorne's Swiftness, Demoralizing Roar, Freedom of the Herd, Charging Bash, Alpha Challenge
		[2] = { 193, 196, 197, 192, 50, 5385, 51, 49, 195, 1237, 52, 3750, 194, 842 }, -- Sharpened Claws, Overrun, Roar of the Protector, Raging Frenzy, Toughness, High Winds, Den Mother, Master Shapeshifter, Entangling Claws, Malorne's Swiftness, Demoralizing Roar, Freedom of the Herd, Charging Bash, Alpha Challenge
		[3] = { 193, 196, 197, 192, 50, 5385, 51, 49, 195, 1237, 52, 3750, 194, 842 }, -- Sharpened Claws, Overrun, Roar of the Protector, Raging Frenzy, Toughness, High Winds, Den Mother, Master Shapeshifter, Entangling Claws, Malorne's Swiftness, Demoralizing Roar, Freedom of the Herd, Charging Bash, Alpha Challenge
	},
	-- Restoration Druid
	[105] = {
		[1] = { 835, 3048, 3752, 697, 692, 691, 700, 59, 1215, 838 }, -- Focused Growth, Master Shapeshifter, Mark of the Wild, Thorns, Entangling Bark, Reactive Resin, Deep Roots, Disentanglement, Early Spring, High Winds
		[2] = { 835, 3048, 3752, 697, 692, 691, 700, 59, 1215, 838 }, -- Focused Growth, Master Shapeshifter, Mark of the Wild, Thorns, Entangling Bark, Reactive Resin, Deep Roots, Disentanglement, Early Spring, High Winds
		[3] = { 835, 3048, 3752, 697, 692, 691, 700, 59, 1215, 838 }, -- Focused Growth, Master Shapeshifter, Mark of the Wild, Thorns, Entangling Bark, Reactive Resin, Deep Roots, Disentanglement, Early Spring, High Winds
	},
	-- Initial Druid
	[1447] = {
	},
	-- Havoc Demon Hunter
	[577] = {
		[1] =  { 1218, 812, 805, 811, 806, 807, 809, 1204, 1206, 810, 813 }, -- Unending Hatred, Detainment, Cleansed by Flame, Rain from Above, Reverse Magic, Eye of Leotheras, Mana Rift, Mortal Rush, Cover of Darkness, Demonic Origins, Mana Break
		[2] =  { 1218, 812, 805, 811, 806, 807, 809, 1204, 1206, 810, 813 }, -- Unending Hatred, Detainment, Cleansed by Flame, Rain from Above, Reverse Magic, Eye of Leotheras, Mana Rift, Mortal Rush, Cover of Darkness, Demonic Origins, Mana Break
		[3] =  { 1218, 812, 805, 811, 806, 807, 809, 1204, 1206, 810, 813 }, -- Unending Hatred, Detainment, Cleansed by Flame, Rain from Above, Reverse Magic, Eye of Leotheras, Mana Rift, Mortal Rush, Cover of Darkness, Demonic Origins, Mana Break
	},
	-- Vengeance Demon Hunter
	[581] = {
		[1] = { 814, 3423, 1220, 3429, 3430, 815, 816, 819, 3727, 1948 }, -- Cleansed by Flame, Demonic Trample, Tormentor, Reverse Magic, Detainment, Everlasting Hunt, Jagged Spikes, Illidan's Grasp, Unending Hatred, Sigil Mastery
		[2] = { 814, 3423, 1220, 3429, 3430, 815, 816, 819, 3727, 1948 }, -- Cleansed by Flame, Demonic Trample, Tormentor, Reverse Magic, Detainment, Everlasting Hunt, Jagged Spikes, Illidan's Grasp, Unending Hatred, Sigil Mastery
		[3] = { 814, 3423, 1220, 3429, 3430, 815, 816, 819, 3727, 1948 }, -- Cleansed by Flame, Demonic Trample, Tormentor, Reverse Magic, Detainment, Everlasting Hunt, Jagged Spikes, Illidan's Grasp, Unending Hatred, Sigil Mastery
	},
	-- Initial Demon Hunter
	[1456] = {
	},
}

--- Get all specialization IDs for the specified class.
---
--- @param classFilename string The non-localized class name as returned by `UnitClass`.
--- @return table<integer,integer>
function LibTalentInfo:GetClassSpecIDs(classFilename)
	if classFilename == nil or specializations[classFilename] == nil then
		return {}
	end

	local specializationIds = specializations[classFilename]
	local result = {}

	for specIndex, specId in pairs(specializationIds) do
		result[specIndex] = specId
	end

	return result
end

--- Get the number of available PvP talents that the specified specialization has in the specified talent slot.
---
--- @param specID integer The specialization ID obtained by `GetSpecializationInfo`.
--- @param slotIndex integer
--- @return integer
function LibTalentInfo:GetNumPvPTalentsForSpec(specID, slotIndex)
	assert(type(slotIndex) == "number", "bad argument #2: expected number, got " .. type(slotIndex))

	if specID == nil or pvpTalents[specID] == nil then
		return 0
	end

	if slotIndex <= 0 or slotIndex > self.MAX_PVP_TALENT_SLOTS then
		error("Slot index is out of range: " .. slotIndex .. ". Must be an integer between 1 and " .. self.MAX_PVP_TALENT_SLOTS)
	end

	local slots = pvpTalents[specID]
	local slotTalents = slots[slotIndex] or {}

	return #slotTalents
end

--- Get the info for a talent of the specified specialization.
---
--- @param specID integer The specialization ID obtained by `GetSpecializationInfo`.
--- @param tier integer An integer value between 1 and `MAX_TALENT_TIERS`.
--- @param column integer An integer value between 1 and `NUM_TALENT_COLUMNS`.
--- @return integer talentID
--- @return string name
--- @return integer texture
--- @return boolean selected
--- @return boolean available
--- @return integer spellID
--- @return nil
--- @return integer row
--- @return integer column
--- @return boolean known
--- @return boolean grantedByAura
function LibTalentInfo:GetTalentInfo(specID, tier, column)
	assert(type(tier) == "number", "bad argument #2: expected number, got " .. type(tier))
	assert(type(column) == "number", "bad argument #3: expected number, got " .. type(column))

	if specID == nil or talents[specID] == nil then
		return nil
	end

	if tier <= 0 or tier > MAX_TALENT_TIERS then
		error("Talent tier is out of range: " .. tier .. ". Must be an integer between 1 and " .. MAX_TALENT_TIERS)
	end

	if column <= 0 or column > NUM_TALENT_COLUMNS then
		error("Talent column is out of range: " .. column .. ". Must be an integer between 1 and " .. NUM_TALENT_COLUMNS)
	end

	local talentIndex = (tier - 1) * NUM_TALENT_COLUMNS + (column - 1)
	local specTalents = talents[specID] or {}

	if talentIndex + 1 > #specTalents then
		return nil
	end

	local talentID = specTalents[talentIndex + 1]

	return GetTalentInfoByID(talentID, 1)
end

--- Get info for a PvP talent of the specified specialization.
---
--- @param specID integer The specialization ID obtained by `GetSpecializationInfo`.
--- @param slotIndex integer The slot index of the PvP talent row, an integer between `1` and `LibTalentInfo.MAX_PVP_TALENT_SLOTS`.
--- @param talentIndex integer An integer between `1` and the number of PvP talents available for the specified specialization.
--- @return integer talentID
--- @return string name
--- @return integer texture
--- @return boolean selected
--- @return boolean available
--- @return integer spellID
--- @return nil
--- @return integer row
--- @return integer column
--- @return boolean known
--- @return boolean grantedByAura
--- @see LibTalentInfo#GetNumPvPTalentsForSpec
function LibTalentInfo:GetPvPTalentInfo(specID, slotIndex, talentIndex)
	assert(type(slotIndex) == "number", "bad argument #2: expected number, got " .. type(slotIndex))
	assert(type(talentIndex) == "number", "bad argument #3: expected number, got " .. type(talentIndex))

	if specID == nil or pvpTalents[specID] == nil then
		return nil
	end

	if slotIndex <= 0 or slotIndex > self.MAX_PVP_TALENT_SLOTS then
		error("Slot index is out of range: " .. slotIndex ". Must be an integer between 1 and " .. self.MAX_PVP_TALENT_SLOTS)
	end

	local slots = pvpTalents[specID]
	local slotTalents = slots[slotIndex] or {}

	if talentIndex <= 0 or talentIndex > #slotTalents then
		error("Talent index is out of range: " .. talentIndex .. ". Must be an integer between 1 and " .. #slotTalents)
	end

	local talentID = slotTalents[talentIndex]

	return GetPvpTalentInfoByID(talentID)
end
