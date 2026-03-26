-- @ScriptType: ModuleScript
local GameConfig = {
	DefaultStats = {
		Faction = "Unchosen", Prestige = 0, Flesh = 0, Reputation = 0, Kills = 0,
		Strength = 10, Speed = 10, Defence = 10, MaxHealth = 100,
		RCCells = 0, Hunger = 100, Regeneration = 5,
		Kagune = "None", KaguneLevel = 1, KaguneMutation = "None", IsKakuja = false,
		Stamina = 100, 

		EquippedQuinque = '{"Name":"Unarmed","ItemType":"Quinque","Type":"None","Weapon":"Fists","Str":1,"Spd":1,"Mutation":"None","Durability":999,"MaxDurability":999,"Broken":false,"Id":"Unarmed"}',

		CCGRankIndex = 1, PatrolWard = "20th Ward", EquippedArata = "None"
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
		["20th Ward"] = {Mult = 1, Name = "20th Ward (Low Risk)"},
		["11th Ward"] = {Mult = 2.5, Name = "11th Ward (High Risk)"},
		["24th Ward"] = {Mult = 5, Name = "24th Ward (Extreme Risk)"}
	},

	GhoulStatCost = 25, QuinqueShopCost = 50,
	Kagunes = {"Ukaku", "Koukaku", "Rinkaku", "Bikaku"}, ChimeraChance = 5, 
	KaguneModifiers = { Ukaku = {Spd = 5, HungerMult = 1.5}, Koukaku = {Def = 5, Spd = -3}, Rinkaku = {Str = 5, Def = -3}, Bikaku = {Str = 2, Spd = 2, Def = 2} },
	QuinqueWeapons = {"Sword", "Hammer", "Whip", "Blade", "Scythe", "Axe", "Spear", "Shield"},
	QuinquePrefixes = {"Yuki", "Dou", "Kura", "Naru", "Sha", "Abura", "Fue", "Ama", "Yama", "Ara", "Ii", "Chi", "Taru", "Ka", "Zebi", "Na", "Ro", "Tsu", "Boku", "Sen", "Bu", "Te", "A", "Gin", "Oni", "No", "Kuro", "Shiro", "Aka", "Ao", "Ryu", "Tora", "Kaze", "Mizu", "Hoshi", "Tsuki", "Kiri", "Kage", "Sora", "Ten", "Zan", "Geki", "Shin", "Baku", "Retsu", "Koku", "Byaku", "En", "Kaku", "Zetsu", "Gen", "Mei", "Kyomu", "Heki", "Mura", "Yami", "Rai", "Hyaku", "Man", "Kyuu", "Ren", "Shou", "Gou", "Rin"},
	QuinqueSuffixes = {"", "mura", "jima", "kami", "ku", "gama", "guchi", "tsu", "da", "ta", "tsuu", "she", "hi", "jiri", "zu", "gomi", "nagi", "satsu", "za", "ru", "toro", "jite", "kui", "maru", "yama", "gawa", "sawa", "zaki", "bashi", "ki", "ko", "do", "ro", "jin", "shi", "tou", "ken", "sen", "ryuu", "nochi", "gami", "zawa", "bito", "dachi", "hoshi", "ishi", "numa", "hara", "wara", "mizu", "shiro", "kuro", "dori", "tachi", "yari", "kaze", "bi", "goku"},
	KaguneMutations = {"None", "None", "None", "Electric Generation", "Flame Generation", "Virus Generation", "Exploding Cells", "Life Draining", "Detached Kagune"},
	MutationRollChance = 20
}
return GameConfig