-- @ScriptType: ModuleScript
local InventoryManager = {}
local HttpService = game:GetService("HttpService")
local GameConfig, DataManager, ShopManager, Network

function InventoryManager.Init(params)
	GameConfig = params.GameConfig
	DataManager = params.DataManager
	ShopManager = params.ShopManager
	Network = params.Network

	params.InventoryEvent.OnServerEvent:Connect(function(player, action, itemID)
		local folder = player:FindFirstChild("PlayerData")
		if not folder then return end

		if action == "ConsumeFlesh" and folder.Flesh.Value > 0 then
			folder.Flesh.Value -= 1; folder.Hunger.Value = math.min(100, folder.Hunger.Value + 30); Network.notify(player, "Ate Flesh! (+30 Hunger)", Color3.fromRGB(50, 255, 50))

		elseif action == "CraftQuinque" and itemID then
			local targetItem = folder.Inventory:FindFirstChild(itemID)
			if targetItem then
				local kData = HttpService:JSONDecode(targetItem.Value)
				if kData.ItemType ~= "Kakuhou" then return end

				local wType = GameConfig.QuinqueWeapons[math.random(1, #GameConfig.QuinqueWeapons)]
				local randName = GameConfig.QuinquePrefixes[math.random(1, #GameConfig.QuinquePrefixes)] .. GameConfig.QuinqueSuffixes[math.random(1, #GameConfig.QuinqueSuffixes)]
				local wDef = kData.Def or 5
				local dur = math.max(10, wDef * 5)
				if string.find(kData.Type, "-") then dur = dur * 2 end

				local qData = { ItemType = "Quinque", Name = randName, Type = kData.Type, Weapon = wType, Str = math.floor(kData.Str * 0.5), Spd = math.floor(kData.Spd * 0.5), Mutation = kData.Mutation, Durability = dur, MaxDurability = dur, Broken = false }
				DataManager.GiveItem(player, qData); targetItem:Destroy(); Network.notify(player, "Crafted " .. qData.Name .. "!", Color3.fromRGB(50, 150, 255))
			end

		elseif action == "RepairQuinque" and itemID then
			local targetItem = folder.Inventory:FindFirstChild(itemID)
			if targetItem then
				local kData = HttpService:JSONDecode(targetItem.Value)
				if kData.ItemType ~= "Kakuhou" then return end
				local qData = HttpService:JSONDecode(folder.EquippedQuinque.Value)
				if qData.Name == "Unarmed" or qData.Name == "Standard Issue" then
					Network.notify(player, "Cannot repair this item!", Color3.fromRGB(255, 50, 50)); return
				end
				if qData.Durability >= qData.MaxDurability and not qData.Broken then
					Network.notify(player, "Weapon is already at Max Durability!", Color3.fromRGB(255, 255, 50)); return
				end

				if kData.Type == qData.Type then
					qData.Durability = qData.MaxDurability; qData.Broken = false
					folder.EquippedQuinque.Value = HttpService:JSONEncode(qData)
					if qData.Id then local invWep = folder.Inventory:FindFirstChild(qData.Id); if invWep then invWep.Value = folder.EquippedQuinque.Value end end
					targetItem:Destroy(); Network.notify(player, "Repaired " .. qData.Name .. "!", Color3.fromRGB(50, 255, 50))
				else Network.notify(player, "Type mismatch! Need a " .. qData.Type .. " Kakuhou.", Color3.fromRGB(255, 50, 50)) end
			end

		elseif action == "CraftArata" and itemID then
			local targetItem = folder.Inventory:FindFirstChild(itemID)
			if targetItem then
				local kData = HttpService:JSONDecode(targetItem.Value)
				if kData.ItemType == "Kakuhou" and kData.Name == "Kakuja Kakuhou" then
					local randName = GameConfig.QuinquePrefixes[math.random(1, #GameConfig.QuinquePrefixes)] .. GameConfig.QuinqueSuffixes[math.random(1, #GameConfig.QuinqueSuffixes)]
					local aData = { ItemType = "Arata", Name = "Proto-" .. randName .. " Armor", Str = math.floor(kData.Str * 2), Spd = math.floor(kData.Spd * 2), Def = math.floor(kData.Def * 2) }
					DataManager.GiveItem(player, aData); targetItem:Destroy(); Network.notify(player, "Forged " .. aData.Name .. "!", Color3.fromRGB(255, 50, 50))
				end
			end

		elseif action == "EquipItem" and itemID then
			local targetItem = folder.Inventory:FindFirstChild(itemID)
			if targetItem then
				local data = HttpService:JSONDecode(targetItem.Value)
				if data.ItemType == "Quinque" then folder.EquippedQuinque.Value = targetItem.Value; Network.notify(player, "Equipped Quinque!", Color3.fromRGB(100, 200, 255))
				elseif data.ItemType == "Arata" then folder.EquippedArata.Value = targetItem.Value; Network.notify(player, "Equipped Arata!", Color3.fromRGB(255, 100, 100)) end
			end

		elseif action == "RetireItem" and itemID then
			local targetItem = folder.Inventory:FindFirstChild(itemID)
			if targetItem then
				local data = HttpService:JSONDecode(targetItem.Value)
				data.Creator = "Investigator " .. player.Name
				if data.Name ~= "Standard Issue" then ShopManager.AddRetiredItem(data) end

				if data.ItemType == "Quinque" and folder.EquippedQuinque.Value == targetItem.Value then folder.EquippedQuinque.Value = GameConfig.DefaultStats.EquippedQuinque; Network.notify(player, "Retired active weapon. Defaulting to Unarmed.", Color3.fromRGB(255, 150, 100))
				elseif data.ItemType == "Arata" and folder.EquippedArata.Value == targetItem.Value then folder.EquippedArata.Value = "None"; Network.notify(player, "Retired active armor.", Color3.fromRGB(255, 150, 100))
				else Network.notify(player, data.ItemType .. " Retired.", Color3.fromRGB(200, 200, 200)) end
				targetItem:Destroy(); ShopManager.RefreshShop()
			end

		elseif action == "RollKagune" and itemID then
			local targetItem = folder.Inventory:FindFirstChild(itemID)
			if targetItem then
				folder.Kagune.Value = DataManager.GenerateKagune(); folder.KaguneLevel.Value = 1; folder.KaguneMutation.Value = "None"; folder.IsKakuja.Value = false
				targetItem:Destroy(); Network.notify(player, "Rolled Kagune: " .. folder.Kagune.Value, Color3.fromRGB(255, 50, 50))
			end
		end
	end)
end
return InventoryManager