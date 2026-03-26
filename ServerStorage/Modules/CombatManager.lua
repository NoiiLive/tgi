-- @ScriptType: ModuleScript
local CombatManager = { ActiveBattles = {} }
local HttpService = game:GetService("HttpService")

local GameConfig, EnemyConfig, CombatEvent, Network, DataManager

function CombatManager.Init(params)
	GameConfig = params.GameConfig; EnemyConfig = params.EnemyConfig; CombatEvent = params.CombatEvent; Network = params.Network; DataManager = params.DataManager

	local RS = game:GetService("ReplicatedStorage")
	local dynamicWards = RS:FindFirstChild("DynamicWards")
	if not dynamicWards then
		dynamicWards = Instance.new("Folder")
		dynamicWards.Name = "DynamicWards"
		dynamicWards.Parent = RS

		local nextTick = Instance.new("IntValue")
		nextTick.Name = "NextRiskIncrease"
		nextTick.Value = os.time() + GameConfig.WardPassiveTickRate
		nextTick.Parent = dynamicWards

		for wardName, _ in pairs(GameConfig.Wards) do
			local val = Instance.new("NumberValue")
			val.Name = wardName

			if wardName == "1st Ward" then
				val.Value = 1.0
			elseif wardName == "24th Ward" then
				val.Value = 5.0
			else
				val.Value = math.random(10, 50) / 10
			end

			local ccgKills = Instance.new("IntValue")
			ccgKills.Name = "CCGKills"
			ccgKills.Value = 0
			ccgKills.Parent = val

			local ghoulKills = Instance.new("IntValue")
			ghoulKills.Name = "GhoulKills"
			ghoulKills.Value = 0
			ghoulKills.Parent = val

			val.Parent = dynamicWards
		end
	end

	task.spawn(function()
		while true do
			task.wait(1)
			local dynWards = game:GetService("ReplicatedStorage"):FindFirstChild("DynamicWards")
			if dynWards then
				local tickVal = dynWards:FindFirstChild("NextRiskIncrease")
				if tickVal and os.time() >= tickVal.Value then
					tickVal.Value = os.time() + GameConfig.WardPassiveTickRate
					for _, wVal in ipairs(dynWards:GetChildren()) do
						if wVal:IsA("NumberValue") and wVal.Name ~= "1st Ward" then
							wVal.Value = math.min(5.0, wVal.Value + 0.1)
						end
					end
				end
			end
		end
	end)

	task.spawn(function()
		local Players = game:GetService("Players")
		while true do
			task.wait(2)
			for _, player in ipairs(Players:GetPlayers()) do
				if not CombatManager.ActiveBattles[player] then
					local folder = player:FindFirstChild("PlayerData")
					if folder and folder:FindFirstChild("CurrentHealth") and folder:FindFirstChild("MaxHealth") then
						if folder.CurrentHealth.Value > 0 and folder.CurrentHealth.Value < folder.MaxHealth.Value then
							local healAmount = 5
							if folder:FindFirstChild("Regeneration") then
								healAmount = folder.Regeneration.Value
							end
							folder.CurrentHealth.Value = math.min(folder.MaxHealth.Value, folder.CurrentHealth.Value + healAmount)
						end
					end
				end
			end
		end
	end)

	CombatEvent.OnServerEvent:Connect(function(player, action, value)
		local folder = player:FindFirstChild("PlayerData")
		if not folder then return end

		if action == "Search" then 
			CombatManager.GenerateEnemy(player)
			CombatEvent:FireClient(player, "BattleStarted", CombatManager.ActiveBattles[player])
		elseif action == "Attack" then CombatManager.ProcessTurn(player, "Attack")
		elseif action == "ConsumeFlesh" then CombatManager.ProcessTurn(player, "ConsumeFlesh")
		elseif action == "Rest" then CombatManager.ProcessTurn(player, "Rest")
		elseif action == "Flee" then
			if CombatManager.ActiveBattles[player] then
				CombatManager.ActiveBattles[player] = nil
				folder.CurrentStamina.Value = folder.Stamina.Value
				if folder:FindFirstChild("ArataActive") then
					folder.ArataActive.Value = false
					folder.ArataHasEaten.Value = false
				end
				CombatEvent:FireClient(player, "BattleEnded", {"You fled from the encounter!"})
			end
		elseif action == "ChangeWard" and value then
			if folder and GameConfig.Wards[value] then 
				folder.PatrolWard.Value = value
				Network.notify(player, "Deployed to " .. value, Color3.fromRGB(150, 150, 255)) 
			end
		elseif action == "ToggleArata" then
			if folder and folder:FindFirstChild("EquippedArata") and folder.EquippedArata.Value ~= "None" then
				folder.ArataActive.Value = not folder.ArataActive.Value
				Network.notify(player, folder.ArataActive.Value and "Arata Armor ACTIVATED!" or "Arata Armor DEACTIVATED", folder.ArataActive.Value and Color3.fromRGB(255,50,50) or Color3.fromRGB(200,200,200))
			end
		end
	end)
end

function CombatManager.GenerateEnemy(player)
	local folder = player:FindFirstChild("PlayerData")
	local wardMult = 1

	if folder and folder:FindFirstChild("PatrolWard") then
		local dynWards = game:GetService("ReplicatedStorage"):FindFirstChild("DynamicWards")
		local wVal = dynWards and dynWards:FindFirstChild(folder.PatrolWard.Value)
		if wVal then wardMult = wVal.Value end
	end

	local validEnemies = {}
	for _, template in ipairs(EnemyConfig.Enemies) do
		if template.Name == "Kakuja Boss" then
			if wardMult > 3.0 then table.insert(validEnemies, template) end
		else
			table.insert(validEnemies, template)
		end
	end

	local template = validEnemies[math.random(1, #validEnemies)]

	local hp = math.floor(math.random(template.MinHP, template.MaxHP) * wardMult)
	CombatManager.ActiveBattles[player] = { 
		Name = template.Name, MaxHealth = hp, CurrentHealth = hp, 
		Strength = math.floor(math.random(template.MinStr, template.MaxStr) * wardMult), 
		Speed = math.floor(math.random(template.MinSpd, template.MaxSpd) * wardMult), 
		Defence = math.floor(math.random(template.MinDef, template.MaxDef) * wardMult),
		Kagune = DataManager.GenerateKagune(), 
		Mutation = GameConfig.KaguneMutations[math.random(1, #GameConfig.KaguneMutations)], WardMult = wardMult
	}
	return CombatManager.ActiveBattles[player]
end

function CombatManager.ProcessTurn(player, actionType)
	local enemy = CombatManager.ActiveBattles[player]; local folder = player:FindFirstChild("PlayerData")
	if not enemy or not folder then return end
	local log = {}; local costs = EnemyConfig.CombatCosts

	if folder.Faction.Value == "CCG" and actionType == "Attack" then
		if folder.CurrentStamina.Value >= costs.CCGStaminaCost then folder.CurrentStamina.Value -= costs.CCGStaminaCost
		else table.insert(log, "Exhausted! You automatically rested instead of attacking."); actionType = "Rest" end
	end

	if actionType == "ConsumeFlesh" then
		if folder.Flesh.Value > 0 then folder.Flesh.Value -= 1; folder.Hunger.Value = math.min(100, folder.Hunger.Value + 30); table.insert(log, "Ate Flesh! (+30 Hunger)") else return end
	elseif actionType == "Rest" then
		if folder.Faction.Value == "CCG" then folder.CurrentStamina.Value = math.min(folder.Stamina.Value, folder.CurrentStamina.Value + 20); table.insert(log, "Rested and recovered 20 Stamina.") end
	end

	local playerDamage = folder.Strength.Value; local playerSpeed = folder.Speed.Value; local playerDefence = folder.Defence.Value
	local enemyDamage = enemy.Strength; local hungerCost = costs.GhoulHungerCost

	if folder.Faction.Value == "CCG" and folder.EquippedArata.Value ~= "None" then
		local aData = HttpService:JSONDecode(folder.EquippedArata.Value)
		playerDefence += (aData.Def or 0)
		if folder.ArataActive.Value == true then
			folder.ArataHasEaten.Value = true; playerDamage += (aData.Str or 0); playerSpeed += (aData.Spd or 0)
		end
		if folder.ArataHasEaten.Value == true then
			folder.CurrentHealth.Value -= 10; table.insert(log, "Arata Armor consumes your flesh! (-10 HP)")
			if folder.CurrentHealth.Value <= 0 then
				table.insert(log, "The Arata Armor devoured you..."); CombatManager.ActiveBattles[player] = nil
				folder.CurrentHealth.Value = folder.MaxHealth.Value; folder.CurrentStamina.Value = folder.Stamina.Value; folder.ArataActive.Value = false; folder.ArataHasEaten.Value = false

				local dynWards = game:GetService("ReplicatedStorage"):FindFirstChild("DynamicWards")
				if dynWards and folder:FindFirstChild("PatrolWard") then
					local wVal = dynWards:FindFirstChild(folder.PatrolWard.Value)
					if wVal and wVal:IsA("NumberValue") then
						local reqKills = math.max(1, math.floor(wVal.Value * 2))
						local ghoulKills = wVal:FindFirstChild("GhoulKills")
						if ghoulKills then
							ghoulKills.Value += 1
							if ghoulKills.Value >= reqKills then
								ghoulKills.Value = 0
								if wVal.Name ~= "1st Ward" then
									wVal.Value = math.min(5.0, wVal.Value + 0.1)
								end
							end
						end
					end
				end

				CombatEvent:FireClient(player, "BattleEnded", log)
				return
			end
		end
	end

	if actionType == "Attack" then
		if folder.Faction.Value == "GHOUL" then
			for _, kType in ipairs(string.split(folder.Kagune.Value, "-")) do
				local mods = GameConfig.KaguneModifiers[kType]
				if mods then playerDamage += (mods.Str or 0); playerSpeed += (mods.Spd or 0); playerDefence += (mods.Def or 0); hungerCost = math.floor(hungerCost * (mods.HungerMult or 1)) end
			end
			if folder.IsKakuja.Value then playerDamage += 10; playerSpeed += 10; playerDefence += 5 end
			if folder.Hunger.Value >= hungerCost then folder.Hunger.Value -= hungerCost; table.insert(log, "Expended " .. hungerCost .. " Hunger.")
			else folder.CurrentHealth.Value -= costs.GhoulStarvingHPCost; playerDamage = math.floor(playerDamage * costs.GhoulStarvingDamageMultiplier); table.insert(log, "Starving! Sacrificed HP for a damage boost.") end

			local mutation = folder.KaguneMutation.Value
			if mutation == "Flame Generation" then playerDamage += 5; table.insert(log, "Flames scorch the enemy (+5 DMG)!")
			elseif mutation == "Electric Generation" then enemyDamage = math.max(0, enemyDamage - 5); table.insert(log, "Electricity lowered enemy attack!")
			elseif mutation == "Virus Generation" then playerDamage += 8; table.insert(log, "Virulent cells bypassed defenses!")
			elseif mutation == "Exploding Cells" then playerDamage += 15; folder.CurrentHealth.Value -= 3; table.insert(log, "Detonation! Massive damage but took recoil!")
			elseif mutation == "Detached Kagune" then enemy.Speed = math.max(1, enemy.Speed - 5); table.insert(log, "Traps slowed the enemy down!") end

		elseif folder.Faction.Value == "CCG" then
			local qData = HttpService:JSONDecode(folder.EquippedQuinque.Value)

			if qData.ItemType == "Quinque" and not qData.Broken then
				local durDrain = 1
				if folder.CurrentStamina.Value < 20 then
					durDrain = math.random(2, 5)
					table.insert(log, "Low Stamina! You overexerted your weapon, damaging its durability.")
				end

				qData.Durability = (qData.Durability or 50) - durDrain
				if qData.Durability <= 0 then
					qData.Durability = 0
					qData.Broken = true
					table.insert(log, "CRITICAL: Your Quinque BROKE from overexertion! (Stats Halved)")
				end

				folder.EquippedQuinque.Value = HttpService:JSONEncode(qData)
				if qData.Id then
					local invItem = folder.Inventory:FindFirstChild(qData.Id)
					if invItem then invItem.Value = folder.EquippedQuinque.Value end
				end
			end

			local strMod = qData.Broken and math.floor(qData.Str / 2) or qData.Str
			local spdMod = qData.Broken and math.floor(qData.Spd / 2) or qData.Spd

			playerDamage += strMod; playerSpeed += spdMod
			if qData.Mutation == "Flame Generation" then playerDamage += 5; table.insert(log, "Quinque flames scorch the enemy (+5 DMG)!")
			elseif qData.Mutation == "Electric Generation" then enemyDamage = math.max(0, enemyDamage - 5); table.insert(log, "Quinque electricity lowered enemy attack!")
			elseif qData.Mutation == "Virus Generation" then playerDamage += 8; table.insert(log, "Virulent quinque bypassed defenses!")
			elseif qData.Mutation == "Exploding Cells" then playerDamage += 15; folder.CurrentHealth.Value -= 3; table.insert(log, "Quinque detonation! Massive damage but took recoil!") end
		end
	end

	local actualEnemyDamage = math.floor(math.max(1, enemyDamage - playerDefence))
	if actionType == "Attack" then
		local actualPlayerDamage = math.floor(math.max(1, playerDamage - enemy.Defence))
		if playerSpeed >= enemy.Speed then
			enemy.CurrentHealth -= actualPlayerDamage; table.insert(log, "You struck first for " .. actualPlayerDamage .. " damage!")
			if (folder.Faction.Value == "GHOUL" and folder.KaguneMutation.Value == "Life Draining") or (folder.Faction.Value == "CCG" and HttpService:JSONDecode(folder.EquippedQuinque.Value).Mutation == "Life Draining") then
				local heal = math.floor(actualPlayerDamage * 0.3); folder.CurrentHealth.Value = math.min(folder.MaxHealth.Value, folder.CurrentHealth.Value + heal); table.insert(log, "Drained " .. heal .. " HP!")
			end
			if enemy.CurrentHealth > 0 then folder.CurrentHealth.Value -= actualEnemyDamage; table.insert(log, "Enemy retaliated for " .. actualEnemyDamage .. " damage!") end
		else
			folder.CurrentHealth.Value -= actualEnemyDamage; table.insert(log, "Enemy outsped you! Took " .. actualEnemyDamage .. " damage.")
			if folder.CurrentHealth.Value > 0 then 
				enemy.CurrentHealth -= actualPlayerDamage; table.insert(log, "You struck back for " .. actualPlayerDamage .. " damage!") 
				if (folder.Faction.Value == "GHOUL" and folder.KaguneMutation.Value == "Life Draining") or (folder.Faction.Value == "CCG" and HttpService:JSONDecode(folder.EquippedQuinque.Value).Mutation == "Life Draining") then
					local heal = math.floor(actualPlayerDamage * 0.3); folder.CurrentHealth.Value = math.min(folder.MaxHealth.Value, folder.CurrentHealth.Value + heal); table.insert(log, "Drained " .. heal .. " HP!")
				end
			end
		end
	else folder.CurrentHealth.Value -= actualEnemyDamage; table.insert(log, "Enemy struck you for " .. actualEnemyDamage .. " damage!") end

	if folder.CurrentHealth.Value <= 0 then
		table.insert(log, "You were defeated...")

		local dynWards = game:GetService("ReplicatedStorage"):FindFirstChild("DynamicWards")
		if dynWards and folder:FindFirstChild("PatrolWard") then
			local wVal = dynWards:FindFirstChild(folder.PatrolWard.Value)
			if wVal and wVal:IsA("NumberValue") then
				local reqKills = math.max(1, math.floor(wVal.Value * 2))
				if folder.Faction.Value == "CCG" then
					local ghoulKills = wVal:FindFirstChild("GhoulKills")
					if ghoulKills then
						ghoulKills.Value += 1
						if ghoulKills.Value >= reqKills then
							ghoulKills.Value = 0
							if wVal.Name ~= "1st Ward" then
								wVal.Value = math.min(5.0, wVal.Value + 0.1)
							end
						end
					end
				elseif folder.Faction.Value == "GHOUL" then
					local ccgKills = wVal:FindFirstChild("CCGKills")
					if ccgKills then
						ccgKills.Value += 1
						if ccgKills.Value >= reqKills then
							ccgKills.Value = 0
							if wVal.Name ~= "1st Ward" then
								wVal.Value = math.max(1.0, wVal.Value - 0.1)
							end
						end
					end
				end
			end
		end

		CombatManager.ActiveBattles[player] = nil; folder.CurrentHealth.Value = folder.MaxHealth.Value; folder.CurrentStamina.Value = folder.Stamina.Value; folder.ArataActive.Value = false; folder.ArataHasEaten.Value = false
		CombatEvent:FireClient(player, "BattleEnded", log)
	elseif enemy.CurrentHealth <= 0 then
		local dynWards = game:GetService("ReplicatedStorage"):FindFirstChild("DynamicWards")
		if dynWards and folder:FindFirstChild("PatrolWard") then
			local wVal = dynWards:FindFirstChild(folder.PatrolWard.Value)
			if wVal and wVal:IsA("NumberValue") then
				local reqKills = math.max(1, math.floor(wVal.Value * 2))
				if folder.Faction.Value == "CCG" then
					local ccgKills = wVal:FindFirstChild("CCGKills")
					if ccgKills then
						ccgKills.Value += 1
						if ccgKills.Value >= reqKills then
							ccgKills.Value = 0
							if wVal.Name ~= "1st Ward" then
								wVal.Value = math.max(1.0, wVal.Value - 0.1)
							end
						end
					end
				elseif folder.Faction.Value == "GHOUL" then
					local ghoulKills = wVal:FindFirstChild("GhoulKills")
					if ghoulKills then
						ghoulKills.Value += 1
						if ghoulKills.Value >= reqKills then
							ghoulKills.Value = 0
							if wVal.Name ~= "1st Ward" then
								wVal.Value = math.min(5.0, wVal.Value + 0.1)
							end
						end
					end
				end
			end
		end

		table.insert(log, "Enemy defeated!")
		local wMult = enemy.WardMult or 1; local repGain = math.floor(math.random(EnemyConfig.LootRates.ReputationMin, EnemyConfig.LootRates.ReputationMax) * wMult)
		folder.Reputation.Value += repGain; folder.Kills.Value += 1

		if folder.Faction.Value == "GHOUL" then
			local rcGain = math.floor(math.random(EnemyConfig.LootRates.RCCellsMin, EnemyConfig.LootRates.RCCellsMax) * wMult); folder.RCCells.Value += rcGain; folder.Hunger.Value = 100; table.insert(log, "Devoured the enemy! Hunger restored. Gained " .. rcGain .. " RC Cells.")
			local fleshGain = math.random(1, 3); folder.Flesh.Value += fleshGain; Network.notify(player, "Found " .. fleshGain .. " Flesh!", Color3.fromRGB(255, 100, 100))
			if math.random(1, 100) <= EnemyConfig.LootRates.Ghoul_KakuhouChance then DataManager.GiveItem(player, {ItemType = "Kakuhou", Name = "Generic Kakuhou"}); Network.notify(player, "Looted a Kakuhou!", Color3.fromRGB(200, 50, 255)) end
		elseif folder.Faction.Value == "CCG" then
			if math.random(1, 100) <= EnemyConfig.LootRates.CCG_KakuhouChance then 
				local isArata = (enemy.Name == "Kakuja Boss") and (math.random(1, 100) <= 30) or false
				local kakuName = enemy.Name == "Kakuja Boss" and "Kakuja Kakuhou" or (enemy.Kagune .. " Kakuhou")
				local kakuData = { ItemType = "Kakuhou", Name = kakuName, Type = enemy.Kagune, Str = enemy.Strength, Spd = enemy.Speed, Def = enemy.Defence, Mutation = enemy.Mutation, IsArata = isArata }
				DataManager.GiveItem(player, kakuData)

				if isArata then
					Network.notify(player, "Harvested an Arata-Grade Kakuhou!", Color3.fromRGB(255, 100, 100))
				else
					Network.notify(player, "Harvested a " .. kakuName .. "!", Color3.fromRGB(200, 50, 255))
				end
			end
		end
		CombatManager.ActiveBattles[player] = nil; folder.CurrentStamina.Value = folder.Stamina.Value; folder.ArataActive.Value = false; folder.ArataHasEaten.Value = false
		CombatEvent:FireClient(player, "BattleEnded", log)
	else CombatEvent:FireClient(player, "TurnUpdate", enemy, log) end
end

return CombatManager