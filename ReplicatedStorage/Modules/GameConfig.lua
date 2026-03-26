-- @ScriptType: ModuleScript
local GameConfig = {
	DefaultStats = {
		Faction = "Unchosen", Prestige = 0, Flesh = 0, Reputation = 0, Kills = 0,
		Strength = 10, Speed = 10, Defence = 10, MaxHealth = 100,
		RCCells = 0, Hunger = 100, Regeneration = 5,
		Kagune = "None", KaguneLevel = 1, KaguneMutation = "None", IsKakuja = false,
		Stamina = 100, 

		EquippedQuinque = '{"Name":"Unarmed","ItemType":"Quinque","Type":"None","Weapon":"Fists","Str":1,"Spd":1,"Mutation":"None","Durability":999,"MaxDurability":999,"Broken":false,"Id":"Unarmed"}',

		CCGRankIndex = 1, PatrolWard = "1st Ward", EquippedArata = "None"
	},

	DisplayStats = {
		Universal = {"CurrentHealth", "MaxHealth", "Strength", "Speed", "Defence", "Reputation", "Kills"},
		GHOUL = {"Hunger", "RCCells", "KaguneLevel", "Kagune", "KaguneMutation", "Regeneration"},
		CCG = {"Stamina", "CCGRankIndex"} 
	},

	TrainingStats = {
		CCG = {"Defence", "Strength", "Speed", "Stamina"},
		GHOUL = {"Strength", "Speed", "Defence", "Regeneration"} 
	},

	CCGRanks = {"Rank 3 Investigator", "Rank 2 Investigator", "Rank 1 Investigator", "First Class Investigator", "Associate Special Class", "Special Class Investigator"},
	CCGPromotions = {
		[2] = {Rep = 200, Kills = 10, Title = "Rank 2 Investigator"},
		[3] = {Rep = 500, Kills = 30, Title = "Rank 1 (Single White Wing)"},
		[4] = {Rep = 1500, Kills = 50, Title = "First Class (Double White Wing)"},
		[5] = {Rep = 5000, Kills = 100, Title = "Assoc. Special (White Dragon Wing)"},
		[6] = {Rep = 15000, Kills = 250, Title = "Special Class Investigator"}
	},

	Wards = {
		["1st Ward"] = {Name = "1st Ward (Chiyoda)"},
		["2nd Ward"] = {Name = "2nd Ward (Chuo)"},
		["3rd Ward"] = {Name = "3rd Ward (Minato)"},
		["4th Ward"] = {Name = "4th Ward (Shinjuku)"},
		["5th Ward"] = {Name = "5th Ward (Bunkyo)"},
		["6th Ward"] = {Name = "6th Ward (Taito)"},
		["7th Ward"] = {Name = "7th Ward (Sumida)"},
		["8th Ward"] = {Name = "8th Ward (Koto)"},
		["9th Ward"] = {Name = "9th Ward (Shinagawa)"},
		["10th Ward"] = {Name = "10th Ward (Meguro)"},
		["11th Ward"] = {Name = "11th Ward (Ota)"},
		["12th Ward"] = {Name = "12th Ward (Setagaya)"},
		["13th Ward"] = {Name = "13th Ward (Shibuya)"},
		["14th Ward"] = {Name = "14th Ward (Nakano)"},
		["15th Ward"] = {Name = "15th Ward (Suginami)"},
		["16th Ward"] = {Name = "16th Ward (Toshima)"},
		["17th Ward"] = {Name = "17th Ward (Kita)"},
		["18th Ward"] = {Name = "18th Ward (Arakawa)"},
		["19th Ward"] = {Name = "19th Ward (Itabashi)"},
		["20th Ward"] = {Name = "20th Ward (Nerima)"},
		["21st Ward"] = {Name = "21st Ward (Adachi)"},
		["22nd Ward"] = {Name = "22nd Ward (Katsushika)"},
		["23rd Ward"] = {Name = "23rd Ward (Edogawa)"},
		["24th Ward"] = {Name = "24th Ward (Underground)"}
	},

	GhoulStatCost = 25, QuinqueShopCost = 50,
	Kagunes = {"Ukaku", "Koukaku", "Rinkaku", "Bikaku"}, ChimeraChance = 5, 
	KaguneModifiers = { Ukaku = {Spd = 5, HungerMult = 1.5}, Koukaku = {Def = 5, Spd = -3}, Rinkaku = {Str = 5, Def = -3}, Bikaku = {Str = 2, Spd = 2, Def = 2} },
	QuinqueWeapons = {"Sword", "Hammer", "Whip", "Blade", "Scythe", "Axe", "Spear", "Shield"},
	QuinquePrefixes = {"Yuki", "Dou", "Kura", "Naru", "Sha", "Abura", "Fue", "Ama", "Yama", "Ara", "Ii", "Chi", "Taru", "Ka", "Zebi", "Na", "Ro", "Tsu", "Boku", "Sen", "Bu", "Te", "A", "Gin", "Oni", "No", "Kuro", "Shiro", "Aka", "Ao", "Ryu", "Tora", "Kaze", "Mizu", "Hoshi", "Tsuki", "Kiri", "Kage", "Sora", "Ten", "Zan", "Geki", "Shin", "Baku", "Retsu", "Koku", "Byaku", "En", "Kaku", "Zetsu", "Gen", "Mei", "Kyomu", "Heki", "Mura", "Yami", "Rai", "Hyaku", "Man", "Kyuu", "Ren", "Shou", "Gou", "Rin"},
	QuinqueSuffixes = {"", "mura", "jima", "kami", "ku", "gama", "guchi", "tsu", "da", "ta", "tsuu", "she", "hi", "jiri", "zu", "gomi", "nagi", "satsu", "za", "ru", "toro", "jite", "kui", "maru", "yama", "gawa", "sawa", "zaki", "bashi", "ki", "ko", "do", "ro", "jin", "shi", "tou", "ken", "sen", "ryuu", "nochi", "gami", "zawa", "bito", "dachi", "hoshi", "ishi", "numa", "hara", "wara", "mizu", "shiro", "kuro", "dori", "tachi", "yari", "kaze", "bi", "goku"},
	KaguneMutations = {"None", "None", "None", "Electric Generation", "Flame Generation", "Virus Generation", "Exploding Cells", "Life Draining", "Detached Kagune"},
	MutationRollChance = 20,
	WardKillsToShift = 10,
	WardPassiveTickRate = 300
}
return GameConfig