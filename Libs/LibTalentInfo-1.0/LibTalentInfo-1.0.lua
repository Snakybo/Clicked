local VERSION_MAJOR = "LibTalentInfo-1.0"
local VERSION_MINOR = 2

if LibStub == nil then
	error(VERSION_MAJOR .. " requires LibStub")
end

local Library = LibStub:NewLibrary(VERSION_MAJOR, VERSION_MINOR)

if Library == nil then
	return
end

--- The maximum number of PvP talents slots available.
--- @type integer
Library.MAX_PVP_TALENT_SLOTS = 3

-- https://wow.gamepedia.com/API_UnitClass
local classes

if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
	classes = {
		"WARRIOR",
		"PALADIN",
		"HUNTER",
		"ROGUE",
		"PRIEST",
		"DEATHKNIGHT",
		"SHAMAN",
		"MAGE",
		"WARLOCK",
		"MONK",
		"DRUID",
		"DEMONHUNTER"
	}
elseif WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
	classes = {
		"WARRIOR",
		"PALADIN",
		"HUNTER",
		"ROGUE",
		"PRIEST",
		"SHAMAN",
		"MAGE",
		"WARLOCK",
		"DRUID"
	}
end

-- https://wow.gamepedia.com/SpecializationID
local specializations = {
	WARRIOR		= { 71, 72, 73 },			-- Arms, Fury, Protection
	PALADIN		= { 65, 66, 70 },			-- Holy, Protection, Retribution
	HUNTER		= { 253, 254, 255 },		-- Beast Mastery, Marksmanship, Survival
	ROGUE		= { 259, 260, 261 },		-- Assassination, Outlaw, Subtlety
	PRIEST		= { 256, 257, 258 },		-- Discipline, Holy, Shadow
	DEATHKNIGHT	= { 250, 251, 252 },		-- Blood, Frost, Unholy
	SHAMAN		= { 262, 263, 264 }, 		-- Elemental, Enhancement, Restoration
	MAGE		= { 62, 63, 64 },			-- Arcane, Fire, Frost
	WARLOCK		= { 265, 266, 267 },		-- Afflication, Demonology, Destruction
	MONK		= { 268, 270, 269 },		-- Brewmaster, Mistweaver, Windwalker
	DRUID		= { 102, 103, 104, 105 },	-- Balance, Feral, Guardian, Restoration
	DEMONHUNTER = { 577, 581 }				-- Havoc, Vengeance
}

-- Macro to retrieve all talent IDs for the current specialization:
-- /run local a=""local b=table.concat;local c=", "for d=1,MAX_TALENT_TIERS do local e,f={},{}for g=1,NUM_TALENT_COLUMNS do local h,i=GetTalentInfo(d,g,1)e[#e+1]=h;f[#f+1]=i end;a=a..b(e,c)..", -- "..b(f,c).."\n"end;print(a)
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
	}
}

-- Macro to retrieve all PvP talent IDs for the current specialization:
-- /run local a,b,c,d,e=C_SpecializationInfo.GetPvpTalentSlotInfo(1),table.concat,", ",{},{}local f=a.availableTalentIDs;for g=1,#f do local h,i=GetPvpTalentInfoByID(f[g])d[#d+1]=h;e[#e+1]=i end;print("[1] = { "..b(d,c).." }, -- "..b(e,c))
local pvpTalents = {
	-- Arms Warrior
	[71] = {
		[1] = { 34, 33, 3534, 32, 5376, 28, 3522, 31, 29, 5372 }, -- Duel, Sharpen Blade, Disarm, War Banner, Overwatch, Master and Commander, Death Sentence, Storm of Destruction, Shadow of the Colossus, Demolition
		[2] = { 34, 33, 3534, 32, 5376, 28, 3522, 31, 29, 5372 }, -- Duel, Sharpen Blade, Disarm, War Banner, Overwatch, Master and Commander, Death Sentence, Storm of Destruction, Shadow of the Colossus, Demolition
		[3] = { 34, 33, 3534, 32, 5376, 28, 3522, 31, 29, 5372 }, -- Duel, Sharpen Blade, Disarm, War Banner, Overwatch, Master and Commander, Death Sentence, Storm of Destruction, Shadow of the Colossus, Demolition
	},
	-- Fury Warrior
	[72] = {
		[1] = { 170, 25, 172, 179, 177, 3533, 3528, 5375, 166, 5373, 3735 }, -- Battle Trance, Death Sentence, Bloodrage, Death Wish, Enduring Rage, Disarm, Master and Commander, Overwatch, Barbarian, Demolition, Slaughterhouse
		[2] = { 170, 25, 172, 179, 177, 3533, 3528, 5375, 166, 5373, 3735 }, -- Battle Trance, Death Sentence, Bloodrage, Death Wish, Enduring Rage, Disarm, Master and Commander, Overwatch, Barbarian, Demolition, Slaughterhouse
		[3] = { 170, 25, 172, 179, 177, 3533, 3528, 5375, 166, 5373, 3735 }, -- Battle Trance, Death Sentence, Bloodrage, Death Wish, Enduring Rage, Disarm, Master and Commander, Overwatch, Barbarian, Demolition, Slaughterhouse
	},
	-- Protection Warrior
	[73] = {
		[1] = { 167, 168, 173, 175, 178, 171, 831, 833, 5374, 24, 845, 5378 }, -- Sword and Board, Bodyguard, Shield Bash, Thunderstruck, Warpath, Morale Killer, Dragon Charge, Rebound, Demolition, Disarm, Oppressor, Overwatch
		[2] = { 167, 168, 173, 175, 178, 171, 831, 833, 5374, 24, 845, 5378 }, -- Sword and Board, Bodyguard, Shield Bash, Thunderstruck, Warpath, Morale Killer, Dragon Charge, Rebound, Demolition, Disarm, Oppressor, Overwatch
		[3] = { 167, 168, 173, 175, 178, 171, 831, 833, 5374, 24, 845, 5378 }, -- Sword and Board, Bodyguard, Shield Bash, Thunderstruck, Warpath, Morale Killer, Dragon Charge, Rebound, Demolition, Disarm, Oppressor, Overwatch
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
		[1] = { 3055, 751, 752, 753, 858, 641, 81, 757, 756, 755, 754 }, -- Cleansing Light, Vengeance Aura, Blessing of Sanctuary, Ultimate Retribution, Law and Order, Unbound Freedom, Luminescence, Jurisdiction, Aura of Reckoning, Divine Punisher, Lawbringer
		[2] = { 3055, 751, 752, 753, 858, 641, 81, 757, 756, 755, 754 }, -- Cleansing Light, Vengeance Aura, Blessing of Sanctuary, Ultimate Retribution, Law and Order, Unbound Freedom, Luminescence, Jurisdiction, Aura of Reckoning, Divine Punisher, Lawbringer
		[3] = { 3055, 751, 752, 753, 858, 641, 81, 757, 756, 755, 754 }, -- Cleansing Light, Vengeance Aura, Blessing of Sanctuary, Ultimate Retribution, Law and Order, Unbound Freedom, Luminescence, Jurisdiction, Aura of Reckoning, Divine Punisher, Lawbringer
	},
	-- Beast Mastery Hunter
	[253] = {
		[1] = { 1214, 824, 3599, 3600, 3602, 3603, 3604, 3605, 3730, 825, 3612, 821, 693 }, -- Interlope, Dire Beast: Hawk, Survival Tactics, Dragonscale Armor, Viper Sting, Spider Sting, Scorpid Sting, Hi-Explosive Trap, Hunting Pack, Dire Beast: Basilisk, Roar of Sacrifice, Wild Protector, The Beast Within
		[2] = { 1214, 824, 3599, 3600, 3602, 3603, 3604, 3605, 3730, 825, 3612, 821, 693 }, -- Interlope, Dire Beast: Hawk, Survival Tactics, Dragonscale Armor, Viper Sting, Spider Sting, Scorpid Sting, Hi-Explosive Trap, Hunting Pack, Dire Beast: Basilisk, Roar of Sacrifice, Wild Protector, The Beast Within
		[3] = { 1214, 824, 3599, 3600, 3602, 3603, 3604, 3605, 3730, 825, 3612, 821, 693 }, -- Interlope, Dire Beast: Hawk, Survival Tactics, Dragonscale Armor, Viper Sting, Spider Sting, Scorpid Sting, Hi-Explosive Trap, Hunting Pack, Dire Beast: Basilisk, Roar of Sacrifice, Wild Protector, The Beast Within
	},
	-- Marksmanship Hunter
	[254] = {
		[1] = { 651, 652, 653, 654, 656, 657, 658, 659, 660, 3614, 649, 3729 }, -- Survival Tactics, Viper Sting, Scorpid Sting, Spider Sting, Scatter Shot, Hi-Explosive Trap, Trueshot Mastery, Ranger's Finesse, Sniper Shot, Roar of Sacrifice, Dragonscale Armor, Hunting Pack
		[2] = { 651, 652, 653, 654, 656, 657, 658, 659, 660, 3614, 649, 3729 }, -- Survival Tactics, Viper Sting, Scorpid Sting, Spider Sting, Scatter Shot, Hi-Explosive Trap, Trueshot Mastery, Ranger's Finesse, Sniper Shot, Roar of Sacrifice, Dragonscale Armor, Hunting Pack
		[3] = { 651, 652, 653, 654, 656, 657, 658, 659, 660, 3614, 649, 3729 }, -- Survival Tactics, Viper Sting, Scorpid Sting, Spider Sting, Scatter Shot, Hi-Explosive Trap, Trueshot Mastery, Ranger's Finesse, Sniper Shot, Roar of Sacrifice, Dragonscale Armor, Hunting Pack
	},
	-- Survival Hunter
	[255] = {
		[1] = { 662, 663, 665, 664, 661, 686, 3609, 3608, 3607, 3606, 3610, 3615 }, -- Mending Bandage, Roar of Sacrifice, Tracker's Net, Sticky Tar, Hunting Pack, Diamond Ice, Scorpid Sting, Spider Sting, Survival Tactics, Hi-Explosive Trap, Dragonscale Armor, Viper Sting
		[2] = { 662, 663, 665, 664, 661, 686, 3609, 3608, 3607, 3606, 3610, 3615 }, -- Mending Bandage, Roar of Sacrifice, Tracker's Net, Sticky Tar, Hunting Pack, Diamond Ice, Scorpid Sting, Spider Sting, Survival Tactics, Hi-Explosive Trap, Dragonscale Armor, Viper Sting
		[3] = { 662, 663, 665, 664, 661, 686, 3609, 3608, 3607, 3606, 3610, 3615 }, -- Mending Bandage, Roar of Sacrifice, Tracker's Net, Sticky Tar, Hunting Pack, Diamond Ice, Scorpid Sting, Spider Sting, Survival Tactics, Hi-Explosive Trap, Dragonscale Armor, Viper Sting
	},
	-- Assassination Rogue
	[259] = {
		[1] = { 130, 132, 3480, 3448, 3479, 147, 144, 141, 830, 137 }, -- Intent to Kill, Honor Among Thieves, Smoke Bomb, Maneuverability, Death from Above, System Shock, Flying Daggers, Creeping Venom, Neurotoxin, Mind-Numbing Poison
		[2] = { 130, 132, 3480, 3448, 3479, 147, 144, 141, 830, 137 }, -- Intent to Kill, Honor Among Thieves, Smoke Bomb, Maneuverability, Death from Above, System Shock, Flying Daggers, Creeping Venom, Neurotoxin, Mind-Numbing Poison
		[3] = { 130, 132, 3480, 3448, 3479, 147, 144, 141, 830, 137 }, -- Intent to Kill, Honor Among Thieves, Smoke Bomb, Maneuverability, Death from Above, System Shock, Flying Daggers, Creeping Venom, Neurotoxin, Mind-Numbing Poison
	},
	-- Outlaw Rogue
	[260] = {
		[1] = { 129, 135, 138, 139, 3421, 142, 150, 3451, 3483, 145, 853, 1208, 3619 }, -- Maneuverability, Take Your Cut, Control is King, Drink Up Me Hearties, Turn the Tables, Cheap Tricks, Plunder Armor, Honor Among Thieves, Smoke Bomb, Dismantle, Boarding Party, Thick as Thieves, Death from Above
		[2] = { 129, 135, 138, 139, 3421, 142, 150, 3451, 3483, 145, 853, 1208, 3619 }, -- Maneuverability, Take Your Cut, Control is King, Drink Up Me Hearties, Turn the Tables, Cheap Tricks, Plunder Armor, Honor Among Thieves, Smoke Bomb, Dismantle, Boarding Party, Thick as Thieves, Death from Above
		[3] = { 129, 135, 138, 139, 3421, 142, 150, 3451, 3483, 145, 853, 1208, 3619 }, -- Maneuverability, Take Your Cut, Control is King, Drink Up Me Hearties, Turn the Tables, Cheap Tricks, Plunder Armor, Honor Among Thieves, Smoke Bomb, Dismantle, Boarding Party, Thick as Thieves, Death from Above
	},
	-- Subtlety Rogue
	[261] = {
		[1] = { 136, 1209, 856, 140, 846, 146, 153, 3447, 3452, 3462 }, -- Veil of Midnight, Smoke Bomb, Silhouette, Cold Blood, Dagger in the Dark, Thief's Bargain, Shadowy Duel, Maneuverability, Honor Among Thieves, Death from Above
		[2] = { 136, 1209, 856, 140, 846, 146, 153, 3447, 3452, 3462 }, -- Veil of Midnight, Smoke Bomb, Silhouette, Cold Blood, Dagger in the Dark, Thief's Bargain, Shadowy Duel, Maneuverability, Honor Among Thieves, Death from Above
		[3] = { 136, 1209, 856, 140, 846, 146, 153, 3447, 3452, 3462 }, -- Veil of Midnight, Smoke Bomb, Silhouette, Cold Blood, Dagger in the Dark, Thief's Bargain, Shadowy Duel, Maneuverability, Honor Among Thieves, Death from Above
	},
	-- Discipline Priest
	[256] = {
		[1] = { 855, 1244, 100, 98, 109, 111, 114, 117, 123, 126 }, -- Thoughtsteal, Searing Light, Purified Resolve, Purification, Trinity, Strength of Soul, Ultimate Radiance, Dome of Light, Archangel, Dark Archangel
		[2] = { 855, 1244, 100, 98, 109, 111, 114, 117, 123, 126 }, -- Thoughtsteal, Searing Light, Purified Resolve, Purification, Trinity, Strength of Soul, Ultimate Radiance, Dome of Light, Archangel, Dark Archangel
		[3] = { 855, 1244, 100, 98, 109, 111, 114, 117, 123, 126 }, -- Thoughtsteal, Searing Light, Purified Resolve, Purification, Trinity, Strength of Soul, Ultimate Radiance, Dome of Light, Archangel, Dark Archangel
	},
	-- Holy Priest
	[257] = {
		[1] = { 1927, 127, 1242, 124, 5365, 101, 5366, 108, 112, 115, 118 }, -- Delivered from Evil, Ray of Hope, Greater Fade, Spirit of the Redeemer, Thoughtsteal, Holy Ward, Divine Ascension, Holy Word: Concentration, Greater Heal, Cardinal Mending, Miracle Worker
		[2] = { 1927, 127, 1242, 124, 5365, 101, 5366, 108, 112, 115, 118 }, -- Delivered from Evil, Ray of Hope, Greater Fade, Spirit of the Redeemer, Thoughtsteal, Holy Ward, Divine Ascension, Holy Word: Concentration, Greater Heal, Cardinal Mending, Miracle Worker
		[3] = { 1927, 127, 1242, 124, 5365, 101, 5366, 108, 112, 115, 118 }, -- Delivered from Evil, Ray of Hope, Greater Fade, Spirit of the Redeemer, Thoughtsteal, Holy Ward, Divine Ascension, Holy Word: Concentration, Greater Heal, Cardinal Mending, Miracle Worker
	},
	-- Shadow Priest
	[258] = {
		[1] = { 128, 739, 102, 106, 3753, 113, 5381, 5380, 763 }, -- Void Shift, Void Origins, Void Shield, Driven to Madness, Greater Fade, Mind Trauma, Thoughtsteal, Lasting Plague, Psyfiend
		[2] = { 128, 739, 102, 106, 3753, 113, 5381, 5380, 763 }, -- Void Shift, Void Origins, Void Shield, Driven to Madness, Greater Fade, Mind Trauma, Thoughtsteal, Lasting Plague, Psyfiend
		[3] = { 128, 739, 102, 106, 3753, 113, 5381, 5380, 763 }, -- Void Shift, Void Origins, Void Shield, Driven to Madness, Greater Fade, Mind Trauma, Thoughtsteal, Lasting Plague, Psyfiend
	},
	-- Blood Death Knight
	[250] = {
		[1] = { 5368, 204, 205, 3441, 3511, 609, 608, 607, 206, 3436, 841 }, -- Dome of Ancient Shadow, Rot and Wither, Walking Dead, Decomposing Aura, Dark Simulacrum, Death Chain, Last Dance, Blood for Blood, Strangulate, Necrotic Aura, Murderous Intent
		[2] = { 5368, 204, 205, 3441, 3511, 609, 608, 607, 206, 3436, 841 }, -- Dome of Ancient Shadow, Rot and Wither, Walking Dead, Decomposing Aura, Dark Simulacrum, Death Chain, Last Dance, Blood for Blood, Strangulate, Necrotic Aura, Murderous Intent
		[3] = { 5368, 204, 205, 3441, 3511, 609, 608, 607, 206, 3436, 841 }, -- Dome of Ancient Shadow, Rot and Wither, Walking Dead, Decomposing Aura, Dark Simulacrum, Death Chain, Last Dance, Blood for Blood, Strangulate, Necrotic Aura, Murderous Intent
	},
	-- Frost Death Knight
	[251] = {
		[1] = { 3439, 701, 702, 706, 43, 3749, 3743, 3515, 3512, 5369 }, -- Heartstop Aura, Deathchill, Delirium, Chill Streak, Necrotic Aura, Transfusion, Dead of Winter, Cadaverous Pallor, Dark Simulacrum, Dome of Ancient Shadow
		[2] = { 3439, 701, 702, 706, 43, 3749, 3743, 3515, 3512, 5369 }, -- Heartstop Aura, Deathchill, Delirium, Chill Streak, Necrotic Aura, Transfusion, Dead of Winter, Cadaverous Pallor, Dark Simulacrum, Dome of Ancient Shadow
		[3] = { 3439, 701, 702, 706, 43, 3749, 3743, 3515, 3512, 5369 }, -- Heartstop Aura, Deathchill, Delirium, Chill Streak, Necrotic Aura, Transfusion, Dead of Winter, Cadaverous Pallor, Dark Simulacrum, Dome of Ancient Shadow
	},
	-- Unholy Death Knight
	[252] = {
		[1] = { 3747, 3746, 163, 41, 152, 40, 3748, 3437, 3440, 149, 5367 }, -- Raise Abomination, Necromancer's Bargain, Cadaverous Pallor, Dark Simulacrum, Reanimation, Life and Death, Transfusion, Necrotic Aura, Decomposing Aura, Necrotic Strike, Dome of Ancient Shadow
		[2] = { 3747, 3746, 163, 41, 152, 40, 3748, 3437, 3440, 149, 5367 }, -- Raise Abomination, Necromancer's Bargain, Cadaverous Pallor, Dark Simulacrum, Reanimation, Life and Death, Transfusion, Necrotic Aura, Decomposing Aura, Necrotic Strike, Dome of Ancient Shadow
		[3] = { 3747, 3746, 163, 41, 152, 40, 3748, 3437, 3440, 149, 5367 }, -- Raise Abomination, Necromancer's Bargain, Cadaverous Pallor, Dark Simulacrum, Reanimation, Life and Death, Transfusion, Necrotic Aura, Decomposing Aura, Necrotic Strike, Dome of Ancient Shadow
	},
	-- Elemental Shaman
	[262] = {
		[1] = { 3621, 3488, 3062, 727, 728, 730, 731, 3491, 3490, 3620 }, -- Swelling Waves, Skyfury Totem, Spectral Recovery, Elemental Attunement, Control of Lava, Traveling Storms, Lightning Lasso, Purifying Waters, Counterstrike Totem, Grounding Totem
		[2] = { 3621, 3488, 3062, 727, 728, 730, 731, 3491, 3490, 3620 }, -- Swelling Waves, Skyfury Totem, Spectral Recovery, Elemental Attunement, Control of Lava, Traveling Storms, Lightning Lasso, Purifying Waters, Counterstrike Totem, Grounding Totem
		[3] = { 3621, 3488, 3062, 727, 728, 730, 731, 3491, 3490, 3620 }, -- Swelling Waves, Skyfury Totem, Spectral Recovery, Elemental Attunement, Control of Lava, Traveling Storms, Lightning Lasso, Purifying Waters, Counterstrike Totem, Grounding Totem
	},
	-- Enhancement Shaman
	[263] = {
		[1] = { 3622, 3623, 3489, 721, 722, 3487, 725, 3519, 3492, 1944 }, -- Grounding Totem, Swelling Waves, Counterstrike Totem, Ride the Lightning, Shamanism, Skyfury Totem, Thundercharge, Spectral Recovery, Purifying Waters, Ethereal Form
		[2] = { 3622, 3623, 3489, 721, 722, 3487, 725, 3519, 3492, 1944 }, -- Grounding Totem, Swelling Waves, Counterstrike Totem, Ride the Lightning, Shamanism, Skyfury Totem, Thundercharge, Spectral Recovery, Purifying Waters, Ethereal Form
		[3] = { 3622, 3623, 3489, 721, 722, 3487, 725, 3519, 3492, 1944 }, -- Grounding Totem, Swelling Waves, Counterstrike Totem, Ride the Lightning, Shamanism, Skyfury Totem, Thundercharge, Spectral Recovery, Purifying Waters, Ethereal Form
	},
	-- Restoration Shaman
	[264] = {
		[1] = { 3520, 3755, 3756, 715, 718, 714, 713, 712, 708, 707, 1930 }, -- Spectral Recovery, Cleansing Waters, Ancestral Gift, Grounding Totem, Spirit Link, Electrocute, Voodoo Mastery, Swelling Waves, Counterstrike Totem, Skyfury Totem, Tidebringer
		[2] = { 3520, 3755, 3756, 715, 718, 714, 713, 712, 708, 707, 1930 }, -- Spectral Recovery, Cleansing Waters, Ancestral Gift, Grounding Totem, Spirit Link, Electrocute, Voodoo Mastery, Swelling Waves, Counterstrike Totem, Skyfury Totem, Tidebringer
		[3] = { 3520, 3755, 3756, 715, 718, 714, 713, 712, 708, 707, 1930 }, -- Spectral Recovery, Cleansing Waters, Ancestral Gift, Grounding Totem, Spirit Link, Electrocute, Voodoo Mastery, Swelling Waves, Counterstrike Totem, Skyfury Totem, Tidebringer
	},
	-- Arcane Mage
	[62] = {
		[1] = { 3517, 3529, 3442, 62, 61, 637, 635, 3523, 3531 }, -- Temporal Shield, Kleptomania, Netherwind Armor, Torment the Weak, Arcane Empowerment, Mass Invisibility, Master of Escape, Dampened Magic, Prismatic Cloak
		[2] = { 3517, 3529, 3442, 62, 61, 637, 635, 3523, 3531 }, -- Temporal Shield, Kleptomania, Netherwind Armor, Torment the Weak, Arcane Empowerment, Mass Invisibility, Master of Escape, Dampened Magic, Prismatic Cloak
		[3] = { 3517, 3529, 3442, 62, 61, 637, 635, 3523, 3531 }, -- Temporal Shield, Kleptomania, Netherwind Armor, Torment the Weak, Arcane Empowerment, Mass Invisibility, Master of Escape, Dampened Magic, Prismatic Cloak
	},
	-- Fire Mage
	[63] = {
		[1] = { 53, 828, 3530, 3524, 648, 647, 646, 645, 644, 643 }, -- Netherwind Armor, Prismatic Cloak, Kleptomania, Dampened Magic, Greater Pyroblast, Flamecannon, Firestarter, Controlled Burn, World in Flames, Tinder
		[2] = { 53, 828, 3530, 3524, 648, 647, 646, 645, 644, 643 }, -- Netherwind Armor, Prismatic Cloak, Kleptomania, Dampened Magic, Greater Pyroblast, Flamecannon, Firestarter, Controlled Burn, World in Flames, Tinder
		[3] = { 53, 828, 3530, 3524, 648, 647, 646, 645, 644, 643 }, -- Netherwind Armor, Prismatic Cloak, Kleptomania, Dampened Magic, Greater Pyroblast, Flamecannon, Firestarter, Controlled Burn, World in Flames, Tinder
	},
	-- Frost Mage
	[64] = {
		[1] = { 57, 58, 66, 67, 68, 632, 3532, 3443, 634, 633 }, -- Dampened Magic, Kleptomania, Chilled to the Bone, Frostbite, Deep Shatter, Concentrated Coolness, Prismatic Cloak, Netherwind Armor, Ice Form, Burst of Cold
		[2] = { 57, 58, 66, 67, 68, 632, 3532, 3443, 634, 633 }, -- Dampened Magic, Kleptomania, Chilled to the Bone, Frostbite, Deep Shatter, Concentrated Coolness, Prismatic Cloak, Netherwind Armor, Ice Form, Burst of Cold
		[3] = { 57, 58, 66, 67, 68, 632, 3532, 3443, 634, 633 }, -- Dampened Magic, Kleptomania, Chilled to the Bone, Frostbite, Deep Shatter, Concentrated Coolness, Prismatic Cloak, Netherwind Armor, Ice Form, Burst of Cold
	},
	-- Afflication Warlock
	[265] = {
		[1] = { 13, 5379, 15, 16, 17, 18, 19, 5370, 20, 11, 12, 3740 }, -- Soulshatter, Rampant Afflictions, Gateway Mastery, Rot and Decay, Bane of Shadows, Nether Ward, Essence Drain, Amplify Curse, Casting Circle, Bane of Fragility, Deathbolt, Demon Armor
		[2] = { 13, 5379, 15, 16, 17, 18, 19, 5370, 20, 11, 12, 3740 }, -- Soulshatter, Rampant Afflictions, Gateway Mastery, Rot and Decay, Bane of Shadows, Nether Ward, Essence Drain, Amplify Curse, Casting Circle, Bane of Fragility, Deathbolt, Demon Armor
		[3] = { 13, 5379, 15, 16, 17, 18, 19, 5370, 20, 11, 12, 3740 }, -- Soulshatter, Rampant Afflictions, Gateway Mastery, Rot and Decay, Bane of Shadows, Nether Ward, Essence Drain, Amplify Curse, Casting Circle, Bane of Fragility, Deathbolt, Demon Armor
	},
	-- Demonology Warlock
	[266] = {
		[1] = { 1213, 162, 3505, 158, 3506, 156, 154, 3507, 165, 3626, 3625, 3624 }, -- Master Summoner, Call Fel Lord, Bane of Fragility, Pleasure through Pain, Gateway Mastery, Call Felhunter, Singe Magic, Amplify Curse, Call Observer, Casting Circle, Essence Drain, Nether Ward
		[2] = { 1213, 162, 3505, 158, 3506, 156, 154, 3507, 165, 3626, 3625, 3624 }, -- Master Summoner, Call Fel Lord, Bane of Fragility, Pleasure through Pain, Gateway Mastery, Call Felhunter, Singe Magic, Amplify Curse, Call Observer, Casting Circle, Essence Drain, Nether Ward
		[3] = { 1213, 162, 3505, 158, 3506, 156, 154, 3507, 165, 3626, 3625, 3624 }, -- Master Summoner, Call Fel Lord, Bane of Fragility, Pleasure through Pain, Gateway Mastery, Call Felhunter, Singe Magic, Amplify Curse, Call Observer, Casting Circle, Essence Drain, Nether Ward
	},
	-- Destruction Warlock
	[267] = {
		[1] = { 3741, 5382, 3504, 3502, 164, 3508, 3509, 3510, 159, 157, 155 }, -- Demon Armor, Gateway Mastery, Amplify Curse, Bane of Fragility, Bane of Havoc, Nether Ward, Essence Drain, Casting Circle, Cremation, Fel Fissure, Focused Chaos
		[2] = { 3741, 5382, 3504, 3502, 164, 3508, 3509, 3510, 159, 157, 155 }, -- Demon Armor, Gateway Mastery, Amplify Curse, Bane of Fragility, Bane of Havoc, Nether Ward, Essence Drain, Casting Circle, Cremation, Fel Fissure, Focused Chaos
		[3] = { 3741, 5382, 3504, 3502, 164, 3508, 3509, 3510, 159, 157, 155 }, -- Demon Armor, Gateway Mastery, Amplify Curse, Bane of Fragility, Bane of Havoc, Nether Ward, Essence Drain, Casting Circle, Cremation, Fel Fissure, Focused Chaos
	},
	-- Brewmaster Monk
	[268] = {
		[1] = { 1958, 667, 668, 666, 669, 670, 671, 672, 673, 843, 765 }, -- Niuzao's Essence, Hot Trub, Guided Meditation, Microbrew, Avert Harm, Craft: Nimble Brew, Incendiary Breath, Double Barrel, Mighty Ox Kick, Admonishment, Eerie Fermentation
		[2] = { 1958, 667, 668, 666, 669, 670, 671, 672, 673, 843, 765 }, -- Niuzao's Essence, Hot Trub, Guided Meditation, Microbrew, Avert Harm, Craft: Nimble Brew, Incendiary Breath, Double Barrel, Mighty Ox Kick, Admonishment, Eerie Fermentation
		[3] = { 1958, 667, 668, 666, 669, 670, 671, 672, 673, 843, 765 }, -- Niuzao's Essence, Hot Trub, Guided Meditation, Microbrew, Avert Harm, Craft: Nimble Brew, Incendiary Breath, Double Barrel, Mighty Ox Kick, Admonishment, Eerie Fermentation
	},
	-- Mistweaver Monk
	[270] = {
		[1] = { 681, 683, 682, 680, 679, 3732, 678, 70, 1928 }, -- Surging Mist, Healing Sphere, Refreshing Breeze, Dome of Mist, Counteract Magic, Grapple Weapon, Chrysalis, Eminence, Zen Focus Tea
		[2] = { 681, 683, 682, 680, 679, 3732, 678, 70, 1928 }, -- Surging Mist, Healing Sphere, Refreshing Breeze, Dome of Mist, Counteract Magic, Grapple Weapon, Chrysalis, Eminence, Zen Focus Tea
		[3] = { 681, 683, 682, 680, 679, 3732, 678, 70, 1928 }, -- Surging Mist, Healing Sphere, Refreshing Breeze, Dome of Mist, Counteract Magic, Grapple Weapon, Chrysalis, Eminence, Zen Focus Tea
	},
	-- Windwalker Monk
	[269] = {
		[1] = { 3050, 3052, 3734, 3737, 675, 3744, 3745, 852, 77 }, -- Disabling Reach, Grapple Weapon, Alpha Tiger, Wind Waker, Tigereye Brew, Pressure Points, Turbo Fists, Reverse Harm, Ride the Wind
		[2] = { 3050, 3052, 3734, 3737, 675, 3744, 3745, 852, 77 }, -- Disabling Reach, Grapple Weapon, Alpha Tiger, Wind Waker, Tigereye Brew, Pressure Points, Turbo Fists, Reverse Harm, Ride the Wind
		[3] = { 3050, 3052, 3734, 3737, 675, 3744, 3745, 852, 77 }, -- Disabling Reach, Grapple Weapon, Alpha Tiger, Wind Waker, Tigereye Brew, Pressure Points, Turbo Fists, Reverse Harm, Ride the Wind
	},
	-- Balance Druid
	[102] = {
		[1] = { 184, 836, 834, 185, 3728, 180, 3058, 182, 5383, 3731, 822 }, -- Moon and Stars, Faerie Swarm, Deep Roots, Moonkin Aura, Protector of the Grove, Celestial Guardian, Prickling Thorns, Crescent Burn, High Winds, Thorns, Dying Stars
		[2] = { 184, 836, 834, 185, 3728, 180, 3058, 182, 5383, 3731, 822 }, -- Moon and Stars, Faerie Swarm, Deep Roots, Moonkin Aura, Protector of the Grove, Celestial Guardian, Prickling Thorns, Crescent Burn, High Winds, Thorns, Dying Stars
		[3] = { 184, 836, 834, 185, 3728, 180, 3058, 182, 5383, 3731, 822 }, -- Moon and Stars, Faerie Swarm, Deep Roots, Moonkin Aura, Protector of the Grove, Celestial Guardian, Prickling Thorns, Crescent Burn, High Winds, Thorns, Dying Stars
	},
	-- Feral Druid
	[103] = {
		[1] = { 201, 203, 601, 602, 612, 620, 5384, 3053, 611, 3751, 820 }, -- Thorns, Freedom of the Herd, Malorne's Swiftness, King of the Jungle, Fresh Wound, Rip and Tear, High Winds, Strength of the Wild, Ferocious Wound, Leader of the Pack, Savage Momentum
		[2] = { 201, 203, 601, 602, 612, 620, 5384, 3053, 611, 3751, 820 }, -- Thorns, Freedom of the Herd, Malorne's Swiftness, King of the Jungle, Fresh Wound, Rip and Tear, High Winds, Strength of the Wild, Ferocious Wound, Leader of the Pack, Savage Momentum
		[3] = { 201, 203, 601, 602, 612, 620, 5384, 3053, 611, 3751, 820 }, -- Thorns, Freedom of the Herd, Malorne's Swiftness, King of the Jungle, Fresh Wound, Rip and Tear, High Winds, Strength of the Wild, Ferocious Wound, Leader of the Pack, Savage Momentum
	},
	-- Guardian Druid
	[104] = {
		[1] = { 195, 194, 197, 5385, 193, 192, 1237, 50, 51, 49, 3750, 52, 196, 842 }, -- Entangling Claws, Charging Bash, Roar of the Protector, High Winds, Sharpened Claws, Raging Frenzy, Malorne's Swiftness, Toughness, Den Mother, Master Shapeshifter, Freedom of the Herd, Demoralizing Roar, Overrun, Alpha Challenge
		[2] = { 195, 194, 197, 5385, 193, 192, 1237, 50, 51, 49, 3750, 52, 196, 842 }, -- Entangling Claws, Charging Bash, Roar of the Protector, High Winds, Sharpened Claws, Raging Frenzy, Malorne's Swiftness, Toughness, Den Mother, Master Shapeshifter, Freedom of the Herd, Demoralizing Roar, Overrun, Alpha Challenge
		[3] = { 195, 194, 197, 5385, 193, 192, 1237, 50, 51, 49, 3750, 52, 196, 842 }, -- Entangling Claws, Charging Bash, Roar of the Protector, High Winds, Sharpened Claws, Raging Frenzy, Malorne's Swiftness, Toughness, Den Mother, Master Shapeshifter, Freedom of the Herd, Demoralizing Roar, Overrun, Alpha Challenge
	},
	-- Restoration Druid
	[105] = {
		[1] = { 3048, 835, 3752, 700, 697, 692, 1215, 838, 59, 691 }, -- Master Shapeshifter, Focused Growth, Mark of the Wild, Deep Roots, Thorns, Entangling Bark, Early Spring, High Winds, Disentanglement, Reactive Resin
		[2] = { 3048, 835, 3752, 700, 697, 692, 1215, 838, 59, 691 }, -- Master Shapeshifter, Focused Growth, Mark of the Wild, Deep Roots, Thorns, Entangling Bark, Early Spring, High Winds, Disentanglement, Reactive Resin
		[3] = { 3048, 835, 3752, 700, 697, 692, 1215, 838, 59, 691 }, -- Master Shapeshifter, Focused Growth, Mark of the Wild, Deep Roots, Thorns, Entangling Bark, Early Spring, High Winds, Disentanglement, Reactive Resin
	},
	-- Havoc Demon Hunter
	[577] = {
		[1] = { 807, 809, 806, 1218, 1206, 1204, 813, 811, 812, 805, 810 }, -- Eye of Leotheras, Mana Rift, Reverse Magic, Unending Hatred, Cover of Darkness, Mortal Rush, Mana Break, Rain from Above, Detainment, Cleansed by Flame, Demonic Origins
		[2] = { 807, 809, 806, 1218, 1206, 1204, 813, 811, 812, 805, 810 }, -- Eye of Leotheras, Mana Rift, Reverse Magic, Unending Hatred, Cover of Darkness, Mortal Rush, Mana Break, Rain from Above, Detainment, Cleansed by Flame, Demonic Origins
		[3] = { 807, 809, 806, 1218, 1206, 1204, 813, 811, 812, 805, 810 }, -- Eye of Leotheras, Mana Rift, Reverse Magic, Unending Hatred, Cover of Darkness, Mortal Rush, Mana Break, Rain from Above, Detainment, Cleansed by Flame, Demonic Origins
	},
	-- Vengeance Demon Hunter
	[581] = {
		[1] = { 814, 815, 819, 3423, 3429, 3727, 1220, 3430, 1948, 816 }, -- Cleansed by Flame, Everlasting Hunt, Illidan's Grasp, Demonic Trample, Reverse Magic, Unending Hatred, Tormentor, Detainment, Sigil Mastery, Jagged Spikes
		[2] = { 814, 815, 819, 3423, 3429, 3727, 1220, 3430, 1948, 816 }, -- Cleansed by Flame, Everlasting Hunt, Illidan's Grasp, Demonic Trample, Reverse Magic, Unending Hatred, Tormentor, Detainment, Sigil Mastery, Jagged Spikes
		[3] = { 814, 815, 819, 3423, 3429, 3727, 1220, 3430, 1948, 816 }, -- Cleansed by Flame, Everlasting Hunt, Illidan's Grasp, Demonic Trample, Reverse Magic, Unending Hatred, Tormentor, Detainment, Sigil Mastery, Jagged Spikes
	}
}

--- Create an iterator which contains all available classes.
function Library:AllClasses()
	local iterator = {}

	for i = 1, #classes do
		iterator[classes[i]] = { unpack(specializations[classes[i]]) }
	end

	return pairs(iterator)
end

--- Get all specialization IDs for the specified class.
---
--- * `classFileName` is the non-localized class as returned by `UnitClass`.
---
--- @param classFilename string
--- @return table
function Library:GetClassSpecIDs(classFilename)
	if classFilename == nil or specializations[classFilename] == nil then
		return nil
	end

	return { unpack(specializations[classFilename]) }
end

--- Get the number of available PvP talents that the specified specialization has in the specified talent slot.
---
--- * `specID` can be obtained from `GetSpecializationInfo` or by iterating through `LibTalentInfo.AllClasses`.
--- * `slotIndex` is an integer between 1 and `LibTalentInfo.MAX_PVP_TALENT_SLOTS`.
---
--- @param specID integer
--- @param slotIndex integer
--- @return integer
function Library:GetNumPvPTalentsForSpec(specID, slotIndex)
	assert(type(slotIndex) == "number", "expected slotIndex to be a number, got " .. (slotIndex or "nil"))

	if specID == nil or pvpTalents[specID] == nil then
		return nil
	end

	if slotIndex <= 0 or slotIndex > self.MAX_PVP_TALENT_SLOTS then
		error("Slot index is out of range: " .. slotIndex ". Must be an integer between 1 and " .. self.MAX_PVP_TALENT_SLOTS)
	end

	return #pvpTalents[specID][slotIndex]
end

--- Get the info for a talent of the specified specialization.
---
--- * `specID` can be obtained from `GetSpecializationInfo` or by iterating through `LibTalentInfo.AllClasses`.
--- * `tier` is an integer value between 1 and `MAX_TALENT_TIERS`.
--- * `column` is an integer value between 1 and `NUM_TALENT_COLUMNS`.
---
--- @param specID integer
--- @param tier integer
--- @param column integer
--- @return integer talentID
--- @return string name
--- @return integer texture
--- @return boolean selected
--- @return boolean available
--- @return integer spellID
--- @return nil unknown,
--- @return integer row
--- @return integer column
--- @return boolean known
--- @return boolean grantedByAura
function Library:GetTalentInfo(specID, tier, column)
	assert(type(tier) == "number", "expected tier to be a number, got " .. (tier or "nil"))
	assert(type(column) == "number", "expected column to be a number, got " .. (column or "nil"))

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
	local talentID = talents[specID][talentIndex + 1]

	return GetTalentInfoByID(talentID, 1)
end

--- Get info for a PvP talent of the specified specialization.
---
--- * `specID` can be obtained from `GetSpecializationInfo` or by iterating through `LibTalentInfo.AllClasses`.
--- * `slotIndex` is an integer between 1 and `LibTalentInfo.MAX_PVP_TALENT_SLOTS`.
--- * `talentIndex` is an integer between 1 and the number of PvP talents available for the specified specialization.
---                 can be obtained using `LibTalentInfo.GetNumPvPTalentsForSpec`.
---
--- @param specID integer
--- @param slotIndex integer
--- @param talentIndex integer
--- @return integer talentID
--- @return string name
--- @return integer texture
--- @return boolean selected
--- @return boolean available
--- @return integer spellID
--- @return nil unknown,
--- @return integer row
--- @return integer column
--- @return boolean known
--- @return boolean grantedByAura
function Library:GetPvPTalentInfo(specID, slotIndex, talentIndex)
	assert(type(slotIndex) == "number", "expected slotIndex to be a number, got " .. (slotIndex or "nil"))
	assert(type(talentIndex) == "number", "expected talentIndex to be a number, got " .. (talentIndex or "nil"))

	if specID == nil or pvpTalents[specID] == nil then
		return nil
	end

	if slotIndex <= 0 or slotIndex > self.MAX_PVP_TALENT_SLOTS then
		error("Slot index is out of range: " .. slotIndex ". Must be an integer between 1 and " .. self.MAX_PVP_TALENT_SLOTS)
	end

	local slots = pvpTalents[specID]
	local slotTalents = slots[slotIndex]

	if talentIndex <= 0 or talentIndex > #slotTalents then
		error("Talent index is out of range: " .. talentIndex .. ". Must be an integer between 1 and " .. #slotTalents)
	end

	local talentID = slotTalents[talentIndex]

	return GetPvpTalentInfoByID(talentID)
end
