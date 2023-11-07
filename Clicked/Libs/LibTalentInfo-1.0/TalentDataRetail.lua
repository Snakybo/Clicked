local LibTalentInfo = LibStub and LibStub("LibTalentInfo-1.0", true)
local version = 52068

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
		[3] = 1473, -- Augmentation
		[5] = 1465, -- Initial
	},
}

--- @type table<integer,integer[]>
local pvpTalents = {
	-- Arcane Mage
	[62] = { 635, 637, 3517, 3529, 5397, 5488, 5491, 5589, 5601, }, -- Master of Escape, Improved Mass Invisibility, Temporal Shield, Kleptomania, Arcanosphere, Ice Wall, Ring of Fire, Master Shepherd, Ethereal Blink
	-- Fire Mage
	[63] = { 644, 647, 648, 5389, 5489, 5495, 5588, 5602, 5621, }, -- World in Flames, Flamecannon, Greater Pyroblast, Ring of Fire, Ice Wall, Glass Cannon, Master Shepherd, Ethereal Blink, Improved Mass Invisibility
	-- Frost Mage
	[64] = { 66, 632, 634, 5390, 5490, 5496, 5497, 5581, 5600, 5622, }, -- Icy Feet, Concentrated Coolness, Ice Form, Ice Wall, Ring of Fire, Frost Bomb, Snowdrift, Master Shepherd, Ethereal Blink, Improved Mass Invisibility
	-- Holy Paladin
	[65] = { 82, 85, 86, 87, 88, 640, 642, 3618, 5421, 5583, 5614, 5618, }, -- Avenging Light, Ultimate Sacrifice, Darkest before the Dawn, Spreading the Word, Blessed Hands, Divine Vision, Cleanse the Weak, Hallowed Ground, Judgments of the Pure, Searing Glare, Divine Plea, Denounce
	-- Protection Paladin
	[66] = { 90, 91, 92, 93, 94, 97, 844, 860, 861, 3474, 5554, 5582, }, -- Hallowed Ground, Steed of Glory, Sacred Duty, Judgments of the Pure, Guardian of the Forgotten Queen, Guarded by the Light, Inquisition, Warrior of Light, Shield of Virtue, Luminescence, Aura of Reckoning, Searing Glare
	-- Retribution Paladin
	[70] = { 81, 752, 753, 754, 756, 5422, 5535, 5572, 5573, 5584, }, -- Luminescence, Blessing of Sanctuary, Ultimate Retribution, Lawbringer, Aura of Reckoning, Judgments of the Pure, Hallowed Ground, Spreading the Word, Blessing of Spellwarding, Searing Glare
	-- Arms Warrior
	[71] = { 28, 29, 31, 32, 33, 34, 3522, 3534, 5372, 5376, 5547, 5625, 5630, }, -- Master and Commander, Shadow of the Colossus, Storm of Destruction, War Banner, Sharpen Blade, Duel, Death Sentence, Disarm, Demolition, Warbringer, Rebound, Safeguard, Battlefield Commander
	-- Fury Warrior
	[72] = { 25, 166, 170, 172, 177, 179, 3528, 3533, 3735, 5373, 5431, 5548, 5623, 5624, 5628, }, -- Death Sentence, Barbarian, Battle Trance, Bloodrage, Enduring Rage, Death Wish, Master and Commander, Disarm, Slaughterhouse, Demolition, Warbringer, Rebound, Storm of Destruction, Safeguard, Battlefield Commander
	-- Protection Warrior
	[73] = { 24, 168, 171, 173, 175, 178, 831, 833, 845, 5374, 5432, 5626, 5627, 5629, }, -- Disarm, Bodyguard, Morale Killer, Shield Bash, Thunderstruck, Warpath, Dragon Charge, Rebound, Oppressor, Demolition, Warbringer, Safeguard, Storm of Destruction, Battlefield Commander
	-- Balance Druid
	[102] = { 180, 182, 184, 185, 822, 834, 836, 3058, 3728, 3731, 5383, 5407, 5515, 5604, }, -- Celestial Guardian, Crescent Burn, Moon and Stars, Moonkin Aura, Dying Stars, Deep Roots, Faerie Swarm, Star Burst, Protector of the Grove, Thorns, High Winds, Owlkin Adept, Malorne's Swiftness, Master Shapeshifter
	-- Feral Druid
	[103] = { 201, 203, 601, 602, 611, 612, 620, 820, 3053, 3751, 5384, 5593, }, -- Thorns, Freedom of the Herd, Malorne's Swiftness, King of the Jungle, Ferocious Wound, Fresh Wound, Wicked Claws, Savage Momentum, Strength of the Wild, Leader of the Pack, High Winds, Wild Attunement
	-- Guardian Druid
	[104] = { 49, 51, 52, 194, 195, 196, 197, 842, 1237, 3750, 5410, }, -- Master Shapeshifter, Den Mother, Demoralizing Roar, Charging Bash, Entangling Claws, Overrun, Emerald Slumber, Alpha Challenge, Malorne's Swiftness, Freedom of the Herd, Grove Protection
	-- Restoration Druid
	[105] = { 59, 691, 692, 697, 700, 835, 838, 1215, 5387, 5514, 5637, }, -- Disentanglement, Reactive Resin, Entangling Bark, Thorns, Deep Roots, Focused Growth, High Winds, Early Spring, Keeper of the Grove, Malorne's Swiftness, Call of the Elder Druid
	-- Blood Death Knight
	[250] = { 204, 205, 206, 608, 609, 841, 3441, 3511, 5513, 5587, 5592, }, -- Rot and Wither, Walking Dead, Strangulate, Last Dance, Death Chain, Murderous Intent, Decomposing Aura, Dark Simulacrum, Necrotic Aura, Bloodforged Armor, Spellwarden
	-- Frost Death Knight
	[251] = { 701, 702, 3439, 3512, 3743, 5429, 5435, 5510, 5512, 5586, 5591, }, -- Deathchill, Delirium, Shroud of Winter, Dark Simulacrum, Dead of Winter, Strangulate, Bitter Chill, Rot and Wither, Necrotic Aura, Bloodforged Armor, Spellwarden
	-- Unholy Death Knight
	[252] = { 40, 41, 149, 152, 3437, 3746, 5430, 5436, 5511, 5585, 5590, }, -- Life and Death, Dark Simulacrum, Necrotic Wounds, Reanimation, Necrotic Aura, Necromancer's Bargain, Strangulate, Doomburst, Rot and Wither, Bloodforged Armor, Spellwarden
	-- Beast Mastery Hunter
	[253] = { 693, 824, 825, 1214, 3599, 3604, 3730, 5418, 5441, 5444, 5534, }, -- The Beast Within, Dire Beast: Hawk, Dire Beast: Basilisk, Interlope, Survival Tactics, Chimaeral Sting, Hunting Pack, Tranquilizing Darts, Wild Kingdom, Kindred Beasts, Diamond Ice
	-- Marksmanship Hunter
	[254] = { 651, 653, 658, 659, 660, 3729, 5419, 5440, 5442, 5531, 5533, }, -- Survival Tactics, Chimaeral Sting, Trueshot Mastery, Ranger's Finesse, Sniper Shot, Hunting Pack, Tranquilizing Darts, Consecutive Concussion, Wild Kingdom, Interlope, Diamond Ice
	-- Survival Hunter
	[255] = { 661, 662, 664, 665, 686, 3607, 3609, 5420, 5443, 5532, }, -- Hunting Pack, Mending Bandage, Sticky Tar Bomb, Tracker's Net, Diamond Ice, Survival Tactics, Chimaeral Sting, Tranquilizing Darts, Wild Kingdom, Interlope
	-- Discipline Priest
	[256] = { 100, 109, 111, 114, 123, 126, 855, 5416, 5480, 5487, 5570, 5635, }, -- Purification, Trinity, Strength of Soul, Ultimate Radiance, Archangel, Dark Archangel, Thoughtsteal, Inner Light and Shadow, Absolute Faith, Catharsis, Phase Shift, Improved Mass Dispel
	-- Holy Priest
	[257] = { 101, 108, 112, 124, 127, 1927, 5365, 5366, 5479, 5485, 5569, 5620, 5634, }, -- Holy Ward, Sanctified Ground, Greater Heal, Spirit of the Redeemer, Ray of Hope, Absolute Faith, Thoughtsteal, Divine Ascension, Purification, Catharsis, Phase Shift, Seraphic Crescendo, Improved Mass Dispel
	-- Shadow Priest
	[258] = { 106, 113, 763, 5381, 5447, 5481, 5486, 5568, 5636, }, -- Driven to Madness, Mind Trauma, Psyfiend, Thoughtsteal, Void Volley, Absolute Faith, Catharsis, Phase Shift, Improved Mass Dispel
	-- Assassination Rogue
	[259] = { 141, 147, 830, 3448, 3479, 3480, 5405, 5408, 5517, 5530, 5550, }, -- Creeping Venom, System Shock, Hemotoxin, Maneuverability, Death from Above, Smoke Bomb, Dismantle, Thick as Thieves, Veil of Midnight, Control is King, Dagger in the Dark
	-- Outlaw Rogue
	[260] = { 129, 135, 138, 139, 145, 853, 1208, 3421, 3483, 3619, 5412, 5516, 5549, }, -- Maneuverability, Take Your Cut, Control is King, Drink Up Me Hearties, Dismantle, Boarding Party, Thick as Thieves, Turn the Tables, Smoke Bomb, Death from Above, Enduring Brawler, Veil of Midnight, Dagger in the Dark
	-- Subtlety Rogue
	[261] = { 136, 146, 153, 846, 856, 1209, 3447, 3462, 5406, 5409, 5411, 5529, }, -- Veil of Midnight, Thief's Bargain, Shadowy Duel, Dagger in the Dark, Silhouette, Smoke Bomb, Maneuverability, Death from Above, Dismantle, Thick as Thieves, Distracting Mirage, Control is King
	-- Elemental Shaman
	[262] = { 727, 730, 3488, 3490, 3491, 3620, 5415, 5571, 5574, }, -- Static Field Totem, Traveling Storms, Skyfury Totem, Counterstrike Totem, Unleash Shield, Grounding Totem, Seasoned Winds, Volcanic Surge, Burrow
	-- Enhancement Shaman
	[263] = { 721, 722, 3487, 3489, 3492, 3622, 5414, 5438, 5527, 5575, 5596, }, -- Ride the Lightning, Shamanism, Skyfury Totem, Counterstrike Totem, Unleash Shield, Grounding Totem, Seasoned Winds, Static Field Totem, Traveling Storms, Burrow, Stormweaver
	-- Restoration Shaman
	[264] = { 707, 708, 714, 715, 3755, 5388, 5437, 5528, 5566, 5567, 5576, }, -- Skyfury Totem, Counterstrike Totem, Electrocute, Grounding Totem, Rain Dance, Living Tide, Unleash Shield, Traveling Storms, Seasoned Winds, Static Field Totem, Burrow
	-- Affliction Warlock
	[265] = { 12, 15, 16, 18, 19, 5379, 5386, 5392, 5543, 5546, 5579, 5608, }, -- Oblivion, Gateway Mastery, Rot and Decay, Nether Ward, Essence Drain, Rampant Afflictions, Jinx, Shadow Rift, Call Observer, Bonds of Fel, Impish Instincts, Soul Rip
	-- Demonology Warlock
	[266] = { 162, 165, 1213, 3506, 3624, 5394, 5400, 5545, 5577, 5606, }, -- Call Fel Lord, Call Observer, Master Summoner, Gateway Mastery, Nether Ward, Shadow Rift, Fel Obelisk, Bonds of Fel, Impish Instincts, Soul Rip
	-- Destruction Warlock
	[267] = { 157, 164, 3508, 5382, 5393, 5401, 5544, 5580, 5607, }, -- Fel Fissure, Bane of Havoc, Nether Ward, Gateway Mastery, Shadow Rift, Bonds of Fel, Call Observer, Impish Instincts, Soul Rip
	-- Brewmaster Monk
	[268] = { 666, 667, 668, 669, 670, 672, 673, 765, 843, 1958, 5417, 5538, 5541, 5552, }, -- Microbrew, Hot Trub, Guided Meditation, Avert Harm, Nimble Brew, Double Barrel, Mighty Ox Kick, Eerie Fermentation, Admonishment, Niuzao's Essence, Rodeo, Grapple Weapon, Dematerialize, Alpha Tiger
	-- Windwalker Monk
	[269] = { 77, 675, 852, 3050, 3052, 3734, 3737, 3744, 3745, 5448, 5540, 5610, }, -- Ride the Wind, Tigereye Brew, Reverse Harm, Disabling Reach, Grapple Weapon, Alpha Tiger, Wind Waker, Pressure Points, Turbo Fists, Perpetual Paralysis, Mighty Ox Kick, Stormspirit Strikes
	-- Mistweaver Monk
	[270] = { 70, 679, 680, 683, 1928, 3732, 5395, 5398, 5402, 5539, 5551, 5565, 5603, }, -- Eminence, Counteract Magic, Dome of Mist, Healing Sphere, Zen Focus Tea, Grapple Weapon, Peaceweaver, Dematerialize, Thunderous Focus Tea, Mighty Ox Kick, Alpha Tiger, Fae Accord, Zen Spheres
	-- Havoc Demon Hunter
	[577] = { 805, 806, 809, 811, 812, 813, 1206, 1218, 5433, 5523, }, -- Cleansed by Flame, Reverse Magic, Chaotic Imprint, Rain from Above, Detainment, Glimpse, Cover of Darkness, Unending Hatred, Blood Moon, Sigil Mastery
	-- Vengeance Demon Hunter
	[581] = { 814, 815, 816, 819, 1220, 1948, 3423, 3429, 3430, 3727, 5434, 5439, 5520, 5521, 5522, }, -- Cleansed by Flame, Everlasting Hunt, Jagged Spikes, Illidan's Grasp, Tormentor, Sigil Mastery, Demonic Trample, Reverse Magic, Detainment, Unending Hatred, Blood Moon, Chaotic Imprint, Cover of Darkness, Rain from Above, Glimpse
	-- Initial Shaman
	[1444] = { },
	-- Initial Warrior
	[1446] = { },
	-- Initial Druid
	[1447] = { },
	-- Initial Hunter
	[1448] = { },
	-- Initial Mage
	[1449] = { },
	-- Initial Monk
	[1450] = { },
	-- Initial Paladin
	[1451] = { },
	-- Initial Priest
	[1452] = { },
	-- Initial Rogue
	[1453] = { },
	-- Initial Warlock
	[1454] = { },
	-- Initial Death Knight
	[1455] = { },
	-- Initial Demon Hunter
	[1456] = { },
	-- Initial Evoker
	[1465] = { },
	-- Devastation Evoker
	[1467] = { 5456, 5460, 5462, 5464, 5466, 5467, 5469, 5471, 5556, 5599, 5617, }, -- Chrono Loop, Obsidian Mettle, Scouring Flame, Time Stop, Swoop Up, Nullifying Shroud, Unburdened Flight, Crippling Force, Divide and Conquer, Dream Catcher, Dreamwalker's Embrace
	-- Preservation Evoker
	[1468] = { 5454, 5455, 5459, 5461, 5463, 5465, 5468, 5470, 5595, 5598, 5616, }, -- Dream Projection, Chrono Loop, Obsidian Mettle, Scouring Flame, Time Stop, Swoop Up, Nullifying Shroud, Unburdened Flight, Divide and Conquer, Dream Catcher, Dreamwalker's Embrace
	-- Augmentation Evoker
	[1473] = { 5557, 5558, 5559, 5560, 5561, 5562, 5563, 5564, 5612, 5613, 5615, 5619, }, -- Divide and Conquer, Nullifying Shroud, Dream Projection, Unburdened Flight, Scouring Flame, Swoop Up, Obsidian Mettle, Chrono Loop, Born in Flame, Dream Catcher, Dreamwalker's Embrace, Time Stop
}

LibTalentInfo:RegisterTalentProvider({
	version = version,
	specializations = specializations,
	pvpTalents = pvpTalents
})
