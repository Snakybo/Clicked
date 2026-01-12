-- LibTalentInfo, a World of Warcraft library to provide class, specialization, and talent information.
-- Copyright (C) 2024  Kevin Krol
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

local LibTalentInfo = LibStub and LibStub("LibTalentInfo-1.0", true)

local interfaceVersion = select(4, GetBuildInfo())

if LibTalentInfo == nil or interfaceVersion < 110000 or interfaceVersion >= 130000 then
	return
end

--- @type LibTalentInfo-1.0.Provider
LibTalentInfo:SetProvider({
	--- @type string[]
	classes = {
		"DEATHKNIGHT",
		"DEMONHUNTER",
		"DRUID",
		"EVOKER",
		"HUNTER",
		"MAGE",
		"MONK",
		"PALADIN",
		"PRIEST",
		"ROGUE",
		"SHAMAN",
		"WARLOCK",
		"WARRIOR",
	},

	--- @type { [string]: { [integer]: TalentData.Specialization } }
	specializations = {
		["DEATHKNIGHT"] = {
			[1] = { id = 250, name = "Blood", icon = 135770 },
			[2] = { id = 251, name = "Frost", icon = 135773 },
			[3] = { id = 252, name = "Unholy", icon = 135775 },
			[5] = { id = 1455, name = nil, icon = nil },
		},
		["DEMONHUNTER"] = {
			[1] = { id = 577, name = "Havoc", icon = 1247264 },
			[2] = { id = 581, name = "Vengeance", icon = 1247265 },
			[5] = { id = 1456, name = nil, icon = nil },
			[3] = { id = 1480, name = "Devourer", icon = 7455385 },
		},
		["DRUID"] = {
			[1] = { id = 102, name = "Balance", icon = 136096 },
			[2] = { id = 103, name = "Feral", icon = 132115 },
			[3] = { id = 104, name = "Guardian", icon = 132276 },
			[4] = { id = 105, name = "Restoration", icon = 136041 },
			[5] = { id = 1447, name = nil, icon = nil },
		},
		["EVOKER"] = {
			[5] = { id = 1465, name = nil, icon = nil },
			[1] = { id = 1467, name = "Devastation", icon = 4511811 },
			[2] = { id = 1468, name = "Preservation", icon = 4511812 },
			[3] = { id = 1473, name = "Augmentation", icon = 5198700 },
		},
		["HUNTER"] = {
			[1] = { id = 253, name = "Beast Mastery", icon = 461112 },
			[2] = { id = 254, name = "Marksmanship", icon = 236179 },
			[3] = { id = 255, name = "Survival", icon = 461113 },
			[5] = { id = 1448, name = nil, icon = nil },
		},
		["MAGE"] = {
			[1] = { id = 62, name = "Arcane", icon = 135932 },
			[2] = { id = 63, name = "Fire", icon = 135810 },
			[3] = { id = 64, name = "Frost", icon = 135846 },
			[5] = { id = 1449, name = nil, icon = nil },
		},
		["MONK"] = {
			[1] = { id = 268, name = "Brewmaster", icon = 608951 },
			[3] = { id = 269, name = "Windwalker", icon = 608953 },
			[2] = { id = 270, name = "Mistweaver", icon = 608952 },
			[5] = { id = 1450, name = nil, icon = nil },
		},
		["PALADIN"] = {
			[1] = { id = 65, name = "Holy", icon = 135920 },
			[2] = { id = 66, name = "Protection", icon = 236264 },
			[3] = { id = 70, name = "Retribution", icon = 135873 },
			[5] = { id = 1451, name = nil, icon = nil },
		},
		["PRIEST"] = {
			[1] = { id = 256, name = "Discipline", icon = 135940 },
			[2] = { id = 257, name = "Holy", icon = 237542 },
			[3] = { id = 258, name = "Shadow", icon = 136207 },
			[5] = { id = 1452, name = nil, icon = nil },
		},
		["ROGUE"] = {
			[1] = { id = 259, name = "Assassination", icon = 236270 },
			[2] = { id = 260, name = "Outlaw", icon = 236286 },
			[3] = { id = 261, name = "Subtlety", icon = 132320 },
			[5] = { id = 1453, name = nil, icon = nil },
		},
		["SHAMAN"] = {
			[1] = { id = 262, name = "Elemental", icon = 136048 },
			[2] = { id = 263, name = "Enhancement", icon = 237581 },
			[3] = { id = 264, name = "Restoration", icon = 136052 },
			[5] = { id = 1444, name = nil, icon = nil },
		},
		["WARLOCK"] = {
			[1] = { id = 265, name = "Affliction", icon = 136145 },
			[2] = { id = 266, name = "Demonology", icon = 136172 },
			[3] = { id = 267, name = "Destruction", icon = 136186 },
			[5] = { id = 1454, name = nil, icon = nil },
		},
		["WARRIOR"] = {
			[1] = { id = 71, name = "Arms", icon = 132355 },
			[2] = { id = 72, name = "Fury", icon = 132347 },
			[3] = { id = 73, name = "Protection", icon = 132341 },
			[5] = { id = 1446, name = nil, icon = nil },
		},
	},

	--- @type { [unknown]: TalentData.Talent[] }
	talents = {
		[62] = {
		},
		[63] = {
		},
		[64] = {
		},
		[65] = {
		},
		[66] = {
		},
		[70] = {
		},
		[71] = {
		},
		[72] = {
		},
		[73] = {
		},
		[102] = {
		},
		[103] = {
		},
		[104] = {
		},
		[105] = {
		},
		[250] = {
		},
		[251] = {
		},
		[252] = {
		},
		[253] = {
		},
		[254] = {
		},
		[255] = {
		},
		[256] = {
		},
		[257] = {
		},
		[258] = {
		},
		[259] = {
		},
		[260] = {
		},
		[261] = {
		},
		[262] = {
		},
		[263] = {
		},
		[264] = {
		},
		[265] = {
		},
		[266] = {
		},
		[267] = {
		},
		[268] = {
		},
		[269] = {
		},
		[270] = {
		},
		[577] = {
		},
		[581] = {
		},
		[1444] = {
		},
		[1446] = {
		},
		[1447] = {
		},
		[1448] = {
		},
		[1449] = {
		},
		[1450] = {
		},
		[1451] = {
		},
		[1452] = {
		},
		[1453] = {
		},
		[1454] = {
		},
		[1455] = {
		},
		[1456] = {
		},
		[1465] = {
		},
		[1467] = {
		},
		[1468] = {
		},
		[1473] = {
		},
		[1480] = {
		},
	},

	--- @type { [unknown]: TalentData.Talent[] }
	pvpTalents = {
		[62] = {
			{ id = 637, name = "Improved Mass Invisibility", icon = 1387356 },
			{ id = 3529, name = "Kleptomania", icon = 135729 },
			{ id = 5397, name = "Arcanosphere", icon = 4226155 },
			{ id = 5488, name = "Ice Wall", icon = 4226156 },
			{ id = 5491, name = "Ring of Fire", icon = 4067368 },
			{ id = 5589, name = "Master Shepherd", icon = 575586 },
			{ id = 5601, name = "Ethereal Blink", icon = 136054 },
			{ id = 5661, name = "Chrono Shift", icon = 629533 },
			{ id = 5707, name = "Overpowered Barrier", icon = 1723997 },
			{ id = 5714, name = "Nether Flux", icon = 1717107 },
		},
		[63] = {
			{ id = 644, name = "World in Flames", icon = 236228 },
			{ id = 648, name = "Greater Pyroblast", icon = 1387354 },
			{ id = 5389, name = "Ring of Fire", icon = 4067368 },
			{ id = 5489, name = "Ice Wall", icon = 4226156 },
			{ id = 5495, name = "Glass Cannon", icon = 429384 },
			{ id = 5588, name = "Master Shepherd", icon = 575586 },
			{ id = 5602, name = "Ethereal Blink", icon = 136054 },
			{ id = 5621, name = "Improved Mass Invisibility", icon = 1387356 },
			{ id = 5706, name = "Overpowered Barrier", icon = 1723997 },
		},
		[64] = {
			{ id = 66, name = "Icy Feet", icon = 5152258 },
			{ id = 632, name = "Concentrated Coolness", icon = 629077 },
			{ id = 5390, name = "Ice Wall", icon = 4226156 },
			{ id = 5490, name = "Ring of Fire", icon = 4067368 },
			{ id = 5496, name = "Frost Bomb", icon = 609814 },
			{ id = 5497, name = "Snowdrift", icon = 135783 },
			{ id = 5581, name = "Master Shepherd", icon = 575586 },
			{ id = 5600, name = "Ethereal Blink", icon = 136054 },
			{ id = 5622, name = "Improved Mass Invisibility", icon = 1387356 },
			{ id = 5708, name = "Overpowered Barrier", icon = 1723997 },
		},
		[65] = {
			{ id = 85, name = "Ultimate Sacrifice", icon = 135966 },
			{ id = 86, name = "Darkest before the Dawn", icon = 461859 },
			{ id = 87, name = "Spreading the Word", icon = 354719 },
			{ id = 640, name = "Divine Vision", icon = 135934 },
			{ id = 642, name = "Cleanse the Weak", icon = 135949 },
			{ id = 5583, name = "Searing Glare", icon = 5260436 },
			{ id = 5618, name = "Denounce", icon = 135950 },
			{ id = 5663, name = "Divine Plea", icon = 1316218 },
			{ id = 5665, name = "Spellbreaker", icon = 458412 },
			{ id = 5674, name = "Luminescence", icon = 135905 },
			{ id = 5676, name = "Shining Revelation", icon = 135921 },
			{ id = 5692, name = "Blessing of Spellwarding", icon = 135880 },
		},
		[66] = {
			{ id = 90, name = "Hallowed Ground", icon = 135926 },
			{ id = 91, name = "Steed of Glory", icon = 135890 },
			{ id = 92, name = "Sacred Duty", icon = 135964 },
			{ id = 94, name = "Guardian of the Forgotten Queen", icon = 135919 },
			{ id = 97, name = "Guarded by the Light", icon = 236252 },
			{ id = 844, name = "Inquisition", icon = 135984 },
			{ id = 860, name = "Warrior of Light", icon = 1030099 },
			{ id = 861, name = "Shield of Virtue", icon = 237452 },
			{ id = 3474, name = "Luminescence", icon = 135905 },
			{ id = 5582, name = "Searing Glare", icon = 5260436 },
			{ id = 5664, name = "Bear the Burden", icon = 571557 },
			{ id = 5667, name = "Spellbreaker", icon = 458412 },
			{ id = 5677, name = "Shining Revelation", icon = 135921 },
		},
		[70] = {
			{ id = 81, name = "Luminescence", icon = 135905 },
			{ id = 752, name = "Blessing of Sanctuary", icon = 135911 },
			{ id = 753, name = "Ultimate Retribution", icon = 135889 },
			{ id = 5535, name = "Hallowed Ground", icon = 135926 },
			{ id = 5572, name = "Spreading the Word", icon = 354719 },
			{ id = 5573, name = "Blessing of Spellwarding", icon = 135880 },
			{ id = 5584, name = "Searing Glare", icon = 5260436 },
			{ id = 5666, name = "Spellbreaker", icon = 458412 },
			{ id = 5675, name = "Shining Revelation", icon = 135921 },
		},
		[71] = {
			{ id = 28, name = "Master and Commander", icon = 132351 },
			{ id = 31, name = "Storm of Destruction", icon = 236303 },
			{ id = 33, name = "Sharpen Blade", icon = 1380678 },
			{ id = 34, name = "Duel", icon = 1455893 },
			{ id = 3534, name = "Disarm", icon = 132343 },
			{ id = 5372, name = "Demolition", icon = 311430 },
			{ id = 5547, name = "Rebound", icon = 132358 },
			{ id = 5625, name = "Safeguard", icon = 236311 },
			{ id = 5679, name = "Dragon Charge", icon = 1380676 },
			{ id = 5701, name = "Berserker Roar", icon = 136009 },
		},
		[72] = {
			{ id = 177, name = "Enduring Rage", icon = 132352 },
			{ id = 179, name = "Death Wish", icon = 136146 },
			{ id = 3528, name = "Master and Commander", icon = 132351 },
			{ id = 3533, name = "Disarm", icon = 132343 },
			{ id = 3735, name = "Slaughterhouse", icon = 4067373 },
			{ id = 5373, name = "Demolition", icon = 311430 },
			{ id = 5548, name = "Rebound", icon = 132358 },
			{ id = 5624, name = "Safeguard", icon = 236311 },
			{ id = 5678, name = "Dragon Charge", icon = 1380676 },
			{ id = 5702, name = "Berserker Roar", icon = 136009 },
		},
		[73] = {
			{ id = 24, name = "Disarm", icon = 132343 },
			{ id = 168, name = "Bodyguard", icon = 132359 },
			{ id = 171, name = "Morale Killer", icon = 132366 },
			{ id = 173, name = "Shield Bash", icon = 132357 },
			{ id = 175, name = "Thunderstruck", icon = 460957 },
			{ id = 831, name = "Dragon Charge", icon = 1380676 },
			{ id = 833, name = "Rebound", icon = 132358 },
			{ id = 845, name = "Oppressor", icon = 136080 },
			{ id = 5374, name = "Demolition", icon = 311430 },
			{ id = 5626, name = "Safeguard", icon = 236311 },
			{ id = 5627, name = "Storm of Destruction", icon = 236303 },
			{ id = 5703, name = "Berserker Roar", icon = 136009 },
			{ id = 5715, name = "Power Through Adversity", icon = 132175 },
		},
		[102] = {
			{ id = 180, name = "Celestial Guardian", icon = 1408835 },
			{ id = 182, name = "Crescent Burn", icon = 136096 },
			{ id = 184, name = "Moon and Stars", icon = 1408838 },
			{ id = 185, name = "Moonkin Aura", icon = 236156 },
			{ id = 822, name = "Dying Stars", icon = 1392544 },
			{ id = 834, name = "Deep Roots", icon = 134221 },
			{ id = 836, name = "Faerie Swarm", icon = 538516 },
			{ id = 3058, name = "Star Burst", icon = 1408832 },
			{ id = 3728, name = "Protector of the Grove", icon = 136062 },
			{ id = 3731, name = "Thorns", icon = 136104 },
			{ id = 5383, name = "High Winds", icon = 132119 },
			{ id = 5407, name = "Owlkin Adept", icon = 236163 },
			{ id = 5515, name = "Malorne's Swiftness", icon = 1394966 },
			{ id = 5604, name = "Master Shapeshifter", icon = 236161 },
			{ id = 5646, name = "Tireless Pursuit", icon = 538517 },
		},
		[103] = {
			{ id = 201, name = "Thorns", icon = 136104 },
			{ id = 203, name = "Freedom of the Herd", icon = 464343 },
			{ id = 601, name = "Malorne's Swiftness", icon = 1394966 },
			{ id = 611, name = "Ferocious Wound", icon = 132127 },
			{ id = 612, name = "Fresh Wound", icon = 132122 },
			{ id = 620, name = "Wicked Claws", icon = 1392548 },
			{ id = 820, name = "Savage Momentum", icon = 132242 },
			{ id = 3053, name = "Strength of the Wild", icon = 1408835 },
			{ id = 3751, name = "Leader of the Pack", icon = 135881 },
			{ id = 5384, name = "High Winds", icon = 132119 },
			{ id = 5647, name = "Tireless Pursuit", icon = 538517 },
		},
		[104] = {
			{ id = 49, name = "Master Shapeshifter", icon = 236161 },
			{ id = 51, name = "Den Mother", icon = 1408834 },
			{ id = 52, name = "Demoralizing Roar", icon = 132117 },
			{ id = 194, name = "Charging Bash", icon = 236946 },
			{ id = 195, name = "Entangling Claws", icon = 136100 },
			{ id = 196, name = "Overrun", icon = 1408833 },
			{ id = 197, name = "Emerald Slumber", icon = 1394953 },
			{ id = 842, name = "Alpha Challenge", icon = 132270 },
			{ id = 1237, name = "Malorne's Swiftness", icon = 1394966 },
			{ id = 3750, name = "Freedom of the Herd", icon = 464343 },
			{ id = 5410, name = "Grove Protection", icon = 4067364 },
			{ id = 5648, name = "Tireless Pursuit", icon = 538517 },
		},
		[105] = {
			{ id = 59, name = "Disentanglement", icon = 134222 },
			{ id = 692, name = "Entangling Bark", icon = 572025 },
			{ id = 697, name = "Thorns", icon = 136104 },
			{ id = 700, name = "Deep Roots", icon = 134221 },
			{ id = 838, name = "High Winds", icon = 132119 },
			{ id = 1215, name = "Early Spring", icon = 236153 },
			{ id = 5514, name = "Malorne's Swiftness", icon = 1394966 },
			{ id = 5649, name = "Tireless Pursuit", icon = 538517 },
			{ id = 5668, name = "Call of Ohn'ahra", icon = 136076 },
			{ id = 5687, name = "Forest Guardian", icon = 1408831 },
		},
		[250] = {
			{ id = 204, name = "Rot and Wither", icon = 538561 },
			{ id = 206, name = "Strangulate", icon = 136214 },
			{ id = 608, name = "Last Dance", icon = 135277 },
			{ id = 609, name = "Death Chain", icon = 1390941 },
			{ id = 841, name = "Murderous Intent", icon = 136088 },
			{ id = 3441, name = "Decomposing Aura", icon = 1390945 },
			{ id = 3511, name = "Dark Simulacrum", icon = 135888 },
			{ id = 5587, name = "Bloodforged Armor", icon = 237512 },
			{ id = 5592, name = "Spellwarden", icon = 136120 },
			{ id = 5712, name = "Price of Progress", icon = 538039 },
		},
		[251] = {
			{ id = 701, name = "Deathchill", icon = 135842 },
			{ id = 702, name = "Delirium", icon = 344804 },
			{ id = 3439, name = "Shroud of Winter", icon = 4226149 },
			{ id = 3512, name = "Dark Simulacrum", icon = 135888 },
			{ id = 5429, name = "Strangulate", icon = 136214 },
			{ id = 5435, name = "Bitter Chill", icon = 349760 },
			{ id = 5510, name = "Rot and Wither", icon = 538561 },
			{ id = 5586, name = "Bloodforged Armor", icon = 237512 },
			{ id = 5591, name = "Spellwarden", icon = 136120 },
			{ id = 5693, name = "Death's Cold Embrace", icon = 636332 },
		},
		[252] = {
			{ id = 40, name = "Life and Death", icon = 348565 },
			{ id = 41, name = "Dark Simulacrum", icon = 135888 },
			{ id = 149, name = "Necrotic Wounds", icon = 366936 },
			{ id = 152, name = "Zombify", icon = 1390947 },
			{ id = 3746, name = "Stitchmaster", icon = 136133 },
			{ id = 5430, name = "Strangulate", icon = 136214 },
			{ id = 5436, name = "Doomburst", icon = 136181 },
			{ id = 5511, name = "Rot and Wither", icon = 538561 },
			{ id = 5585, name = "Bloodforged Armor", icon = 237512 },
			{ id = 5590, name = "Spellwarden", icon = 136120 },
		},
		[253] = {
			{ id = 693, name = "The Beast Within", icon = 132166 },
			{ id = 824, name = "Dire Beast: Hawk", icon = 612363 },
			{ id = 1214, name = "Interlope", icon = 132180 },
			{ id = 3599, name = "Survival Tactics", icon = 132293 },
			{ id = 3604, name = "Chimaeral Sting", icon = 132211 },
			{ id = 3730, name = "Hunting Pack", icon = 236181 },
			{ id = 5441, name = "Wild Kingdom", icon = 236159 },
			{ id = 5444, name = "Kindred Beasts", icon = 236184 },
			{ id = 5534, name = "Diamond Ice", icon = 236209 },
		},
		[254] = {
			{ id = 651, name = "Survival Tactics", icon = 132293 },
			{ id = 653, name = "Chimaeral Sting", icon = 132211 },
			{ id = 659, name = "Ranger's Finesse", icon = 132208 },
			{ id = 660, name = "Sniper's Advantage", icon = 1412205 },
			{ id = 3729, name = "Hunting Pack", icon = 236181 },
			{ id = 5440, name = "Consecutive Concussion", icon = 135860 },
			{ id = 5533, name = "Diamond Ice", icon = 236209 },
			{ id = 5700, name = "Aspect of the Fox", icon = 458223 },
		},
		[255] = {
			{ id = 661, name = "Hunting Pack", icon = 236181 },
			{ id = 662, name = "Mending Bandage", icon = 1014022 },
			{ id = 664, name = "Sticky Tar Bomb", icon = 5094557 },
			{ id = 665, name = "Tracker's Net", icon = 1412207 },
			{ id = 686, name = "Diamond Ice", icon = 236209 },
			{ id = 3607, name = "Survival Tactics", icon = 132293 },
			{ id = 3609, name = "Chimaeral Sting", icon = 132211 },
			{ id = 5443, name = "Wild Kingdom", icon = 236159 },
			{ id = 5532, name = "Interlope", icon = 132180 },
		},
		[256] = {
			{ id = 100, name = "Purification", icon = 135894 },
			{ id = 109, name = "Trinity", icon = 537078 },
			{ id = 111, name = "Strength of Soul", icon = 135880 },
			{ id = 114, name = "Ultimate Radiance", icon = 1386546 },
			{ id = 123, name = "Inner Light", icon = 135898 },
			{ id = 126, name = "Dark Archangel", icon = 1445237 },
			{ id = 5480, name = "Absolute Faith", icon = 463836 },
			{ id = 5570, name = "Phase Shift", icon = 775463 },
			{ id = 5635, name = "Improved Mass Dispel", icon = 135739 },
			{ id = 5640, name = "Mindgames", icon = 6035316 },
			{ id = 5721, name = "Psychic Shroud", icon = 633004 },
		},
		[257] = {
			{ id = 101, name = "Psychic Shroud", icon = 633004 },
			{ id = 108, name = "Sanctified Ground", icon = 237544 },
			{ id = 112, name = "Greater Heal", icon = 135915 },
			{ id = 124, name = "Spirit of the Redeemer", icon = 132864 },
			{ id = 1927, name = "Absolute Faith", icon = 463836 },
			{ id = 5479, name = "Purification", icon = 135894 },
			{ id = 5569, name = "Phase Shift", icon = 775463 },
			{ id = 5634, name = "Improved Mass Dispel", icon = 135739 },
		},
		[258] = {
			{ id = 106, name = "Driven to Madness", icon = 236300 },
			{ id = 113, name = "Mind Trauma", icon = 462324 },
			{ id = 763, name = "Psyfiend", icon = 537021 },
			{ id = 5447, name = "Cascading Horrors", icon = 132776 },
			{ id = 5481, name = "Absolute Faith", icon = 463836 },
			{ id = 5568, name = "Phase Shift", icon = 775463 },
			{ id = 5636, name = "Improved Mass Dispel", icon = 135739 },
			{ id = 5638, name = "Mindgames", icon = 6035316 },
			{ id = 5720, name = "Psychic Shroud", icon = 633004 },
		},
		[259] = {
			{ id = 141, name = "Creeping Venom", icon = 1398086 },
			{ id = 147, name = "System Shock", icon = 1398089 },
			{ id = 830, name = "Hemotoxin", icon = 3610996 },
			{ id = 3448, name = "Maneuverability", icon = 965900 },
			{ id = 3479, name = "Death from Above", icon = 1043573 },
			{ id = 3480, name = "Smoke Bomb", icon = 458733 },
			{ id = 5405, name = "Dismantle", icon = 236272 },
			{ id = 5408, name = "Thick as Thieves", icon = 236283 },
			{ id = 5530, name = "Control is King", icon = 132298 },
			{ id = 5550, name = "Dagger in the Dark", icon = 643249 },
			{ id = 5697, name = "Preemptive Maneuver", icon = 132294 },
		},
		[260] = {
			{ id = 129, name = "Maneuverability", icon = 965900 },
			{ id = 138, name = "Control is King", icon = 132298 },
			{ id = 139, name = "Drink Up Me Hearties", icon = 461806 },
			{ id = 145, name = "Dismantle", icon = 236272 },
			{ id = 853, name = "Boarding Party", icon = 1141392 },
			{ id = 1208, name = "Thick as Thieves", icon = 236283 },
			{ id = 3421, name = "Turn the Tables", icon = 236286 },
			{ id = 3483, name = "Smoke Bomb", icon = 458733 },
			{ id = 3619, name = "Death from Above", icon = 1043573 },
			{ id = 5549, name = "Dagger in the Dark", icon = 643249 },
			{ id = 5699, name = "Preemptive Maneuver", icon = 132294 },
		},
		[261] = {
			{ id = 146, name = "Thief's Bargain", icon = 133473 },
			{ id = 846, name = "Dagger in the Dark", icon = 643249 },
			{ id = 856, name = "Silhouette", icon = 132303 },
			{ id = 1209, name = "Smoke Bomb", icon = 458733 },
			{ id = 3447, name = "Maneuverability", icon = 965900 },
			{ id = 3462, name = "Death from Above", icon = 1043573 },
			{ id = 5406, name = "Dismantle", icon = 236272 },
			{ id = 5409, name = "Thick as Thieves", icon = 236283 },
			{ id = 5411, name = "Distracting Mirage", icon = 132289 },
			{ id = 5529, name = "Control is King", icon = 132298 },
			{ id = 5698, name = "Preemptive Maneuver", icon = 132294 },
		},
		[262] = {
			{ id = 727, name = "Static Field Totem", icon = 1020304 },
			{ id = 3488, name = "Totem of Wrath", icon = 1385914 },
			{ id = 3490, name = "Counterstrike Totem", icon = 511726 },
			{ id = 3620, name = "Grounding Totem", icon = 136039 },
			{ id = 5574, name = "Burrow", icon = 5260435 },
			{ id = 5659, name = "Electrocute", icon = 136075 },
			{ id = 5660, name = "Shamanism", icon = 454482 },
			{ id = 5681, name = "Storm Conduit", icon = 135990 },
			{ id = 5724, name = "Lightning Lasso", icon = 1385911 },
		},
		[263] = {
			{ id = 722, name = "Shamanism", icon = 454482 },
			{ id = 3487, name = "Totem of Wrath", icon = 1385914 },
			{ id = 3489, name = "Counterstrike Totem", icon = 511726 },
			{ id = 3622, name = "Grounding Totem", icon = 136039 },
			{ id = 5438, name = "Static Field Totem", icon = 1020304 },
			{ id = 5575, name = "Burrow", icon = 5260435 },
			{ id = 5658, name = "Electrocute", icon = 136075 },
			{ id = 5722, name = "Lightning Lasso", icon = 1385911 },
		},
		[264] = {
			{ id = 708, name = "Counterstrike Totem", icon = 511726 },
			{ id = 714, name = "Electrocute", icon = 136075 },
			{ id = 715, name = "Grounding Totem", icon = 136039 },
			{ id = 3755, name = "Rain Dance", icon = 463570 },
			{ id = 5437, name = "Master of the Elements", icon = 136027 },
			{ id = 5567, name = "Static Field Totem", icon = 1020304 },
			{ id = 5576, name = "Burrow", icon = 5260435 },
			{ id = 5704, name = "Storm Conduit", icon = 135990 },
			{ id = 5705, name = "Totem of Wrath", icon = 1385914 },
			{ id = 5719, name = "Call of Al'Akir", icon = 136076 },
			{ id = 5723, name = "Lightning Lasso", icon = 1385911 },
		},
		[265] = {
			{ id = 15, name = "Gateway Mastery", icon = 607512 },
			{ id = 16, name = "Rot and Decay", icon = 1032479 },
			{ id = 18, name = "Nether Ward", icon = 135796 },
			{ id = 19, name = "Essence Drain", icon = 571321 },
			{ id = 5386, name = "Jinx", icon = 460699 },
			{ id = 5392, name = "Shadow Rift", icon = 4067372 },
			{ id = 5546, name = "Bonds of Fel", icon = 1117883 },
			{ id = 5579, name = "Impish Instincts", icon = 237560 },
			{ id = 5608, name = "Soul Rip", icon = 5260437 },
			{ id = 5662, name = "Soul Swap", icon = 460857 },
			{ id = 5695, name = "Bloodstones", icon = 538744 },
		},
		[266] = {
			{ id = 162, name = "Call Fel Lord", icon = 1113433 },
			{ id = 3506, name = "Gateway Mastery", icon = 607512 },
			{ id = 3624, name = "Nether Ward", icon = 135796 },
			{ id = 5394, name = "Shadow Rift", icon = 4067372 },
			{ id = 5545, name = "Bonds of Fel", icon = 1117883 },
			{ id = 5577, name = "Impish Instincts", icon = 237560 },
			{ id = 5606, name = "Soul Rip", icon = 5260437 },
			{ id = 5694, name = "Bloodstones", icon = 538744 },
		},
		[267] = {
			{ id = 157, name = "Fel Fissure", icon = 135801 },
			{ id = 164, name = "Bane of Havoc", icon = 1380866 },
			{ id = 3508, name = "Nether Ward", icon = 135796 },
			{ id = 5382, name = "Gateway Mastery", icon = 607512 },
			{ id = 5393, name = "Shadow Rift", icon = 4067372 },
			{ id = 5401, name = "Bonds of Fel", icon = 1117883 },
			{ id = 5580, name = "Impish Instincts", icon = 237560 },
			{ id = 5607, name = "Soul Rip", icon = 5260437 },
			{ id = 5696, name = "Bloodstones", icon = 538744 },
		},
		[268] = {
			{ id = 666, name = "Microbrew", icon = 615341 },
			{ id = 667, name = "Hot Trub", icon = 623775 },
			{ id = 669, name = "Avert Harm", icon = 620829 },
			{ id = 670, name = "Nimble Brew", icon = 839394 },
			{ id = 672, name = "Double Barrel", icon = 644378 },
			{ id = 673, name = "Mighty Ox Kick", icon = 1381297 },
			{ id = 765, name = "Eerie Fermentation", icon = 651580 },
			{ id = 843, name = "Admonishment", icon = 620830 },
			{ id = 1958, name = "Niuzao's Essence", icon = 133701 },
			{ id = 5541, name = "Dematerialize", icon = 4067369 },
		},
		[269] = {
			{ id = 77, name = "Ride the Wind", icon = 1381298 },
			{ id = 3052, name = "Grapple Weapon", icon = 132343 },
			{ id = 3737, name = "Wind Waker", icon = 611420 },
			{ id = 3744, name = "Predestination", icon = 606552 },
			{ id = 3745, name = "Turbo Fists", icon = 627606 },
			{ id = 5448, name = "Perpetual Paralysis", icon = 629534 },
			{ id = 5641, name = "Absolute Serenity", icon = 988197 },
			{ id = 5643, name = "Rising Dragon Sweep", icon = 134158 },
		},
		[270] = {
			{ id = 70, name = "Eminence", icon = 627608 },
			{ id = 679, name = "Counteract Magic", icon = 1381294 },
			{ id = 683, name = "Healing Spheres", icon = 606546 },
			{ id = 1928, name = "Zen Focus Tea", icon = 651940 },
			{ id = 5395, name = "Peaceweaver", icon = 1020466 },
			{ id = 5398, name = "Dematerialize", icon = 4067369 },
			{ id = 5539, name = "Mighty Ox Kick", icon = 1381297 },
			{ id = 5603, name = "Zen Spheres", icon = 5094560 },
			{ id = 5642, name = "Absolute Serenity", icon = 988197 },
		},
		[577] = {
			{ id = 805, name = "Cleansed by Flame", icon = 135802 },
			{ id = 806, name = "Reverse Magic", icon = 1380372 },
			{ id = 811, name = "Rain from Above", icon = 1380371 },
			{ id = 812, name = "Detainment", icon = 463560 },
			{ id = 813, name = "Glimpse", icon = 1348401 },
			{ id = 1206, name = "Cover of Darkness", icon = 1305154 },
			{ id = 1218, name = "Unending Hatred", icon = 1450140 },
			{ id = 5433, name = "Blood Moon", icon = 828455 },
			{ id = 5523, name = "Sigil Mastery", icon = 1058938 },
			{ id = 5691, name = "Illidan's Grasp", icon = 1380367 },
		},
		[581] = {
			{ id = 814, name = "Cleansed by Flame", icon = 135802 },
			{ id = 815, name = "Everlasting Hunt", icon = 1247265 },
			{ id = 816, name = "Jagged Spikes", icon = 1344645 },
			{ id = 819, name = "Illidan's Grasp", icon = 1380367 },
			{ id = 1220, name = "Tormentor", icon = 1344654 },
			{ id = 1948, name = "Sigil Mastery", icon = 1058938 },
			{ id = 3423, name = "Demonic Trample", icon = 134294 },
			{ id = 3429, name = "Reverse Magic", icon = 1380372 },
			{ id = 3430, name = "Detainment", icon = 463560 },
			{ id = 3727, name = "Unending Hatred", icon = 1450140 },
			{ id = 5434, name = "Blood Moon", icon = 828455 },
			{ id = 5520, name = "Cover of Darkness", icon = 1305154 },
			{ id = 5521, name = "Rain from Above", icon = 1380371 },
			{ id = 5522, name = "Glimpse", icon = 1348401 },
			{ id = 5716, name = "Lay In Wait", icon = 1380366 },
		},
		[1444] = {
		},
		[1446] = {
		},
		[1447] = {
		},
		[1448] = {
		},
		[1449] = {
		},
		[1450] = {
		},
		[1451] = {
		},
		[1452] = {
		},
		[1453] = {
		},
		[1454] = {
		},
		[1455] = {
		},
		[1456] = {
		},
		[1465] = {
		},
		[1467] = {
			{ id = 5456, name = "Chrono Loop", icon = 4630470 },
			{ id = 5460, name = "Obsidian Mettle", icon = 1526594 },
			{ id = 5462, name = "Scouring Flame", icon = 135826 },
			{ id = 5464, name = "Time Stop", icon = 4631367 },
			{ id = 5466, name = "Swoop Up", icon = 4622446 },
			{ id = 5467, name = "Nullifying Shroud", icon = 135752 },
			{ id = 5469, name = "Unburdened Flight", icon = 1029587 },
			{ id = 5556, name = "Divide and Conquer", icon = 5152257 },
			{ id = 5617, name = "Dreamwalker's Embrace", icon = 4913233 },
		},
		[1468] = {
			{ id = 5455, name = "Chrono Loop", icon = 4630470 },
			{ id = 5459, name = "Obsidian Mettle", icon = 1526594 },
			{ id = 5461, name = "Scouring Flame", icon = 135826 },
			{ id = 5463, name = "Time Stop", icon = 4631367 },
			{ id = 5465, name = "Swoop Up", icon = 4622446 },
			{ id = 5468, name = "Nullifying Shroud", icon = 135752 },
			{ id = 5470, name = "Unburdened Flight", icon = 1029587 },
			{ id = 5595, name = "Divide and Conquer", icon = 5152257 },
			{ id = 5616, name = "Dreamwalker's Embrace", icon = 4913233 },
			{ id = 5711, name = "Dream Projection", icon = 5342920 },
			{ id = 5718, name = "Emerald Communion", icon = 4630447 },
		},
		[1473] = {
			{ id = 5454, name = "Seismic Slam", icon = 5199643 },
			{ id = 5557, name = "Divide and Conquer", icon = 5152257 },
			{ id = 5558, name = "Nullifying Shroud", icon = 135752 },
			{ id = 5560, name = "Unburdened Flight", icon = 1029587 },
			{ id = 5561, name = "Scouring Flame", icon = 135826 },
			{ id = 5562, name = "Swoop Up", icon = 4622446 },
			{ id = 5563, name = "Obsidian Mettle", icon = 1526594 },
			{ id = 5564, name = "Chrono Loop", icon = 4630470 },
			{ id = 5612, name = "Born in Flame", icon = 4622464 },
			{ id = 5615, name = "Dreamwalker's Embrace", icon = 4913233 },
			{ id = 5619, name = "Time Stop", icon = 4631367 },
		},
		[1480] = {
			{ id = 5728, name = "Inevitable End", icon = 7137506 },
			{ id = 5729, name = "Armor of Souls", icon = 1391776 },
			{ id = 5730, name = "Surrender to the Void", icon = 1131285 },
			{ id = 5731, name = "Cleansed by Flame", icon = 135802 },
			{ id = 5732, name = "Cover of Darkness", icon = 1305154 },
			{ id = 5733, name = "Detainment", icon = 463560 },
			{ id = 5734, name = "Glimpse", icon = 1348401 },
			{ id = 5735, name = "Beckon", icon = 132102 },
		},
	}
})
