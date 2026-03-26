-- @ScriptType: ModuleScript
local TrainingManager = {}
local GameConfig, DataManager, Network

function TrainingManager.Init(params)
	GameConfig = params.GameConfig
	DataManager = params.DataManager
	Network = params.Network

	params.TrainingEvent.OnServerEvent:Connect(function(player, action, value)
		local folder = player:FindFirstChild("PlayerData")
		if not folder then return end

		if folder.Faction.Value == "CCG" then
			if action == "ToggleTraining" then 
				if DataManager.ActiveTraining[player] and DataManager.ActiveTraining[player].Stat == value then
					DataManager.ActiveTraining[player] = nil
				else
					DataManager.ActiveTraining[player] = {Stat = value, Timer = 5}
				end

			elseif action == "PromoteCCG" then
				local nextRank = folder.CCGRankIndex.Value + 1
				local reqs = GameConfig.CCGPromotions[nextRank]
				if reqs then
					if folder.Reputation.Value >= reqs.Rep and folder.Kills.Value >= reqs.Kills then 
						folder.Reputation.Value -= reqs.Rep; folder.CCGRankIndex.Value = nextRank
						Network.notify(player, "PROMOTED TO " .. reqs.Title .. "!", Color3.fromRGB(255, 215, 0))
					else Network.notify(player, "Requirements not met!", Color3.fromRGB(255, 50, 50)) end
				end
			end

		elseif folder.Faction.Value == "GHOUL" then
			if action == "LevelUpKagune" then
				local cost = folder.KaguneLevel.Value * 50
				if folder.RCCells.Value >= cost then
					folder.RCCells.Value -= cost; folder.KaguneLevel.Value += 1; folder.MaxHealth.Value += 5
					Network.notify(player, "Kagune Leveled Up!", Color3.fromRGB(50, 255, 50))
					if math.random(1, 100) <= GameConfig.MutationRollChance then 
						folder.KaguneMutation.Value = GameConfig.KaguneMutations[math.random(1, #GameConfig.KaguneMutations)]
						Network.notify(player, "MUTATION: " .. folder.KaguneMutation.Value, Color3.fromRGB(255, 150, 50)) 
					end
				else Network.notify(player, "Not enough RC Cells!", Color3.fromRGB(255, 50, 50)) end
			elseif action == "EvolveKakuja" then
				if folder.KaguneLevel.Value >= 10 and not folder.IsKakuja.Value then 
					folder.IsKakuja.Value = true; folder.Strength.Value += 10; folder.Speed.Value += 10; folder.MaxHealth.Value += 50
					Network.notify(player, "EVOLVED INTO KAKUJA!", Color3.fromRGB(255, 0, 0)) 
				end
			elseif action == "UpgradeStat" then
				if folder.RCCells.Value >= GameConfig.GhoulStatCost then 
					folder.RCCells.Value -= GameConfig.GhoulStatCost; folder[value].Value += 1
					Network.notify(player, "Upgraded " .. value .. "!", Color3.fromRGB(100, 255, 100))
				else Network.notify(player, "Not enough RC Cells!", Color3.fromRGB(255, 50, 50)) end
			end
		end
	end)
end
return TrainingManager