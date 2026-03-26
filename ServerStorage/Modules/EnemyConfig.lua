-- @ScriptType: ModuleScript
local EnemyConfig = {
	Enemies = {
		{Name = "Rogue Ghoul", MinHP = 30, MaxHP = 80, MinStr = 5, MaxStr = 15, MinSpd = 5, MaxSpd = 15, MinDef = 0, MaxDef = 5},
		{Name = "Aogiri Grunt", MinHP = 50, MaxHP = 100, MinStr = 10, MaxStr = 20, MinSpd = 10, MaxSpd = 20, MinDef = 2, MaxDef = 8},
		{Name = "Kakuja Boss", MinHP = 200, MaxHP = 400, MinStr = 25, MaxStr = 50, MinSpd = 20, MaxSpd = 40, MinDef = 10, MaxDef = 20}
	},
	CombatCosts = {
		GhoulHungerCost = 10,
		GhoulStarvingHPCost = 5,
		GhoulStarvingDamageMultiplier = 1.5,
		CCGStaminaCost = 5
	},
	LootRates = {
		CCG_KakuhouChance = 40,
		Ghoul_KakuhouChance = 30,
		ReputationMin = 1, ReputationMax = 5,
		RCCellsMin = 10, RCCellsMax = 50
	}
}
return EnemyConfig