local LibTalentInfo = LibStub and LibStub("LibTalentInfo-1.0", true)
local version = 59679

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
	[62] = { 635, 637, 3529, 5397, 5488, 5491, 5589, 5601, 5661, 5707, }, -- Master of Escape, Improved Mass Invisibility, Kleptomania, Arcanosphere, Ice Wall, Ring of Fire, Master Shepherd, Ethereal Blink, Chrono Shift, Overpowered Barrier
	-- Fire Mage
	[63] = { 644, 648, 5389, 5489, 5495, 5588, 5602, 5621, 5685, 5706, }, -- World in Flames, Greater Pyroblast, Ring of Fire, Ice Wall, Glass Cannon, Master Shepherd, Ethereal Blink, Improved Mass Invisibility, Ignition Burst, Overpowered Barrier
	-- Frost Mage
	[64] = { 66, 632, 634, 5390, 5490, 5496, 5497, 5581, 5600, 5622, 5708, }, -- Icy Feet, Concentrated Coolness, Ice Form, Ice Wall, Ring of Fire, Frost Bomb, Snowdrift, Master Shepherd, Ethereal Blink, Improved Mass Invisibility, Overpowered Barrier
	-- Holy Paladin
	[65] = { 85, 86, 87, 640, 642, 3618, 5583, 5618, 5663, 5665, 5674, 5676, 5692, }, -- Ultimate Sacrifice, Darkest before the Dawn, Spreading the Word, Divine Vision, Cleanse the Weak, Hallowed Ground, Searing Glare, Denounce, Divine Plea, Spellbreaker, Luminescence, Shining Revelation, Blessing of Spellwarding
	-- Protection Paladin
	[66] = { 90, 91, 92, 94, 97, 844, 860, 861, 3474, 5582, 5664, 5667, 5677, }, -- Hallowed Ground, Steed of Glory, Sacred Duty, Guardian of the Forgotten Queen, Guarded by the Light, Inquisition, Warrior of Light, Shield of Virtue, Luminescence, Searing Glare, Bear the Burden, Spellbreaker, Shining Revelation
	-- Retribution Paladin
	[70] = { 81, 752, 753, 5535, 5572, 5573, 5584, 5666, 5675, }, -- Luminescence, Blessing of Sanctuary, Ultimate Retribution, Hallowed Ground, Spreading the Word, Blessing of Spellwarding, Searing Glare, Spellbreaker, Shining Revelation
	-- Arms Warrior
	[71] = { 28, 31, 33, 34, 3534, 5372, 5547, 5625, 5630, 5679, 5701, }, -- Master and Commander, Storm of Destruction, Sharpen Blade, Duel, Disarm, Demolition, Rebound, Safeguard, Battlefield Commander, Dragon Charge, Berserker Roar
	-- Fury Warrior
	[72] = { 177, 179, 3528, 3533, 3735, 5373, 5548, 5624, 5628, 5678, 5702, }, -- Enduring Rage, Death Wish, Master and Commander, Disarm, Slaughterhouse, Demolition, Rebound, Safeguard, Battlefield Commander, Dragon Charge, Berserker Roar
	-- Protection Warrior
	[73] = { 24, 168, 171, 173, 175, 831, 833, 845, 5374, 5626, 5627, 5629, 5703, }, -- Disarm, Bodyguard, Morale Killer, Shield Bash, Thunderstruck, Dragon Charge, Rebound, Oppressor, Demolition, Safeguard, Storm of Destruction, Battlefield Commander, Berserker Roar
	-- Balance Druid
	[102] = { 180, 182, 184, 185, 822, 834, 836, 3058, 3728, 3731, 5383, 5407, 5515, 5604, 5646, }, -- Celestial Guardian, Crescent Burn, Moon and Stars, Moonkin Aura, Dying Stars, Deep Roots, Faerie Swarm, Star Burst, Protector of the Grove, Thorns, High Winds, Owlkin Adept, Malorne's Swiftness, Master Shapeshifter, Tireless Pursuit
	-- Feral Druid
	[103] = { 201, 203, 601, 611, 612, 620, 820, 3053, 3751, 5384, 5647, }, -- Thorns, Freedom of the Herd, Malorne's Swiftness, Ferocious Wound, Fresh Wound, Wicked Claws, Savage Momentum, Strength of the Wild, Leader of the Pack, High Winds, Tireless Pursuit
	-- Guardian Druid
	[104] = { 49, 51, 52, 194, 195, 196, 197, 842, 1237, 3750, 5410, 5648, }, -- Master Shapeshifter, Den Mother, Demoralizing Roar, Charging Bash, Entangling Claws, Overrun, Emerald Slumber, Alpha Challenge, Malorne's Swiftness, Freedom of the Herd, Grove Protection, Tireless Pursuit
	-- Restoration Druid
	[105] = { 59, 692, 697, 700, 838, 1215, 5514, 5649, 5668, 5687, }, -- Disentanglement, Entangling Bark, Thorns, Deep Roots, High Winds, Early Spring, Malorne's Swiftness, Tireless Pursuit, Ancient of Lore, Forest Guardian
	-- Blood Death Knight
	[250] = { 204, 206, 608, 609, 841, 3441, 3511, 5587, 5592, }, -- Rot and Wither, Strangulate, Last Dance, Death Chain, Murderous Intent, Decomposing Aura, Dark Simulacrum, Bloodforged Armor, Spellwarden
	-- Frost Death Knight
	[251] = { 701, 702, 3439, 3512, 5429, 5435, 5510, 5586, 5591, 5693, }, -- Deathchill, Delirium, Shroud of Winter, Dark Simulacrum, Strangulate, Bitter Chill, Rot and Wither, Bloodforged Armor, Spellwarden, Death's Cold Embrace
	-- Unholy Death Knight
	[252] = { 40, 41, 149, 152, 3746, 5430, 5436, 5511, 5585, 5590, }, -- Life and Death, Dark Simulacrum, Necrotic Wounds, Reanimation, Necromancer's Bargain, Strangulate, Doomburst, Rot and Wither, Bloodforged Armor, Spellwarden
	-- Beast Mastery Hunter
	[253] = { 693, 824, 825, 1214, 3599, 3604, 3730, 5441, 5444, 5534, 5689, }, -- The Beast Within, Dire Beast: Hawk, Dire Beast: Basilisk, Interlope, Survival Tactics, Chimaeral Sting, Hunting Pack, Wild Kingdom, Kindred Beasts, Diamond Ice, Explosive Powder
	-- Marksmanship Hunter
	[254] = { 651, 653, 659, 660, 3729, 5440, 5533, 5688, 5700, }, -- Survival Tactics, Chimaeral Sting, Ranger's Finesse, Sniper's Advantage, Hunting Pack, Consecutive Concussion, Diamond Ice, Explosive Powder, Aspect of the Fox
	-- Survival Hunter
	[255] = { 661, 662, 664, 665, 686, 3607, 3609, 5443, 5532, 5690, }, -- Hunting Pack, Mending Bandage, Sticky Tar Bomb, Tracker's Net, Diamond Ice, Survival Tactics, Chimaeral Sting, Wild Kingdom, Interlope, Explosive Powder
	-- Discipline Priest
	[256] = { 100, 109, 111, 114, 123, 126, 855, 5416, 5480, 5487, 5570, 5635, 5640, }, -- Purification, Trinity, Strength of Soul, Ultimate Radiance, Archangel, Dark Archangel, Thoughtsteal, Inner Light and Shadow, Absolute Faith, Catharsis, Phase Shift, Improved Mass Dispel, Mindgames
	-- Holy Priest
	[257] = { 101, 108, 112, 124, 127, 1927, 5365, 5366, 5479, 5485, 5569, 5634, 5639, }, -- Holy Ward, Sanctified Ground, Greater Heal, Spirit of the Redeemer, Ray of Hope, Absolute Faith, Thoughtsteal, Divine Ascension, Purification, Catharsis, Phase Shift, Improved Mass Dispel, Mindgames
	-- Shadow Priest
	[258] = { 106, 113, 763, 5381, 5447, 5481, 5486, 5568, 5636, 5638, }, -- Driven to Madness, Mind Trauma, Psyfiend, Thoughtsteal, Void Volley, Absolute Faith, Catharsis, Phase Shift, Improved Mass Dispel, Mindgames
	-- Assassination Rogue
	[259] = { 141, 147, 830, 3448, 3479, 3480, 5405, 5408, 5530, 5550, 5697, }, -- Creeping Venom, System Shock, Hemotoxin, Maneuverability, Death from Above, Smoke Bomb, Dismantle, Thick as Thieves, Control is King, Dagger in the Dark, Preemptive Maneuver
	-- Outlaw Rogue
	[260] = { 129, 138, 139, 145, 853, 1208, 3421, 3483, 3619, 5549, 5699, }, -- Maneuverability, Control is King, Drink Up Me Hearties, Dismantle, Boarding Party, Thick as Thieves, Turn the Tables, Smoke Bomb, Death from Above, Dagger in the Dark, Preemptive Maneuver
	-- Subtlety Rogue
	[261] = { 146, 846, 856, 1209, 3447, 3462, 5406, 5409, 5411, 5529, 5698, }, -- Thief's Bargain, Dagger in the Dark, Silhouette, Smoke Bomb, Maneuverability, Death from Above, Dismantle, Thick as Thieves, Distracting Mirage, Control is King, Preemptive Maneuver
	-- Elemental Shaman
	[262] = { 727, 3488, 3490, 3491, 3620, 5574, 5659, 5660, 5681, }, -- Static Field Totem, Totem of Wrath, Counterstrike Totem, Unleash Shield, Grounding Totem, Burrow, Electrocute, Shamanism, Storm Conduit
	-- Enhancement Shaman
	[263] = { 722, 3487, 3489, 3492, 3622, 5438, 5575, 5596, 5658, }, -- Shamanism, Totem of Wrath, Counterstrike Totem, Unleash Shield, Grounding Totem, Static Field Totem, Burrow, Stormweaver, Electrocute
	-- Restoration Shaman
	[264] = { 708, 714, 715, 3755, 5388, 5437, 5567, 5576, 5704, 5705, }, -- Counterstrike Totem, Electrocute, Grounding Totem, Rain Dance, Living Tide, Unleash Shield, Static Field Totem, Burrow, Storm Conduit, Totem of Wrath
	-- Affliction Warlock
	[265] = { 15, 16, 18, 19, 5379, 5386, 5392, 5546, 5579, 5608, 5662, 5695, }, -- Gateway Mastery, Rot and Decay, Nether Ward, Essence Drain, Rampant Afflictions, Jinx, Shadow Rift, Bonds of Fel, Impish Instincts, Soul Rip, Soul Swap, Bloodstones
	-- Demonology Warlock
	[266] = { 162, 1213, 3506, 3624, 5394, 5545, 5577, 5606, 5694, }, -- Call Fel Lord, Master Summoner, Gateway Mastery, Nether Ward, Shadow Rift, Bonds of Fel, Impish Instincts, Soul Rip, Bloodstones
	-- Destruction Warlock
	[267] = { 157, 164, 3508, 5382, 5393, 5401, 5580, 5607, 5696, }, -- Fel Fissure, Bane of Havoc, Nether Ward, Gateway Mastery, Shadow Rift, Bonds of Fel, Impish Instincts, Soul Rip, Bloodstones
	-- Brewmaster Monk
	[268] = { 666, 667, 668, 669, 670, 672, 673, 765, 843, 1958, 5417, 5538, 5541, }, -- Microbrew, Hot Trub, Guided Meditation, Avert Harm, Nimble Brew, Double Barrel, Mighty Ox Kick, Eerie Fermentation, Admonishment, Niuzao's Essence, Rodeo, Grapple Weapon, Dematerialize
	-- Windwalker Monk
	[269] = { 77, 675, 3052, 3737, 3744, 3745, 5448, 5610, 5641, 5643, 5644, }, -- Ride the Wind, Tigereye Brew, Grapple Weapon, Wind Waker, Predestination, Turbo Fists, Perpetual Paralysis, Stormspirit Strikes, Absolute Serenity, Rising Dragon Sweep, Rodeo
	-- Mistweaver Monk
	[270] = { 70, 679, 683, 1928, 3732, 5395, 5398, 5539, 5565, 5603, 5642, 5645, 5669, }, -- Eminence, Counteract Magic, Healing Sphere, Zen Focus Tea, Grapple Weapon, Peaceweaver, Dematerialize, Mighty Ox Kick, Jadefire Accord, Zen Spheres, Absolute Serenity, Rodeo, Feather Feet
	-- Havoc Demon Hunter
	[577] = { 805, 806, 811, 812, 813, 1206, 1218, 5433, 5523, 5691, }, -- Cleansed by Flame, Reverse Magic, Rain from Above, Detainment, Glimpse, Cover of Darkness, Unending Hatred, Blood Moon, Sigil Mastery, Illidan's Grasp
	-- Vengeance Demon Hunter
	[581] = { 814, 815, 816, 819, 1220, 1948, 3423, 3429, 3430, 3727, 5434, 5520, 5521, 5522, }, -- Cleansed by Flame, Everlasting Hunt, Jagged Spikes, Illidan's Grasp, Tormentor, Sigil Mastery, Demonic Trample, Reverse Magic, Detainment, Unending Hatred, Blood Moon, Cover of Darkness, Rain from Above, Glimpse
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
	[1467] = { 5456, 5460, 5462, 5464, 5466, 5467, 5469, 5556, 5617, }, -- Chrono Loop, Obsidian Mettle, Scouring Flame, Time Stop, Swoop Up, Nullifying Shroud, Unburdened Flight, Divide and Conquer, Dreamwalker's Embrace
	-- Preservation Evoker
	[1468] = { 5455, 5459, 5461, 5463, 5465, 5468, 5470, 5595, 5616, 5711, }, -- Chrono Loop, Obsidian Mettle, Scouring Flame, Time Stop, Swoop Up, Nullifying Shroud, Unburdened Flight, Divide and Conquer, Dreamwalker's Embrace, Dream Projection
	-- Augmentation Evoker
	[1473] = { 5454, 5557, 5558, 5560, 5561, 5562, 5563, 5564, 5612, 5615, 5619, }, -- Seismic Slam, Divide and Conquer, Nullifying Shroud, Unburdened Flight, Scouring Flame, Swoop Up, Obsidian Mettle, Chrono Loop, Born in Flame, Dreamwalker's Embrace, Time Stop
}

LibTalentInfo:RegisterTalentProvider({
	version = version,
	specializations = specializations,
	pvpTalents = pvpTalents
})
