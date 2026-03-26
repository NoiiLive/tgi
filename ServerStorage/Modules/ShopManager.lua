-- @ScriptType: ModuleScript
local ShopManager = {}
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local GlobalPoolStore = DataStoreService:GetDataStore("GlobalQuinquePool")
local GlobalShopStore = DataStoreService:GetDataStore("GlobalQuinqueShop")

ShopManager.CurrentShopOfferings = {}
ShopManager.StudioFallbackPool = {} 

local ShopEvent, GameConfig, DataManager, Network

function ShopManager.Init(params)
	ShopEvent = params.ShopEvent
	GameConfig = params.GameConfig
	DataManager = params.DataManager
	Network = params.Network

	ShopEvent.OnServerEvent:Connect(function(player, action, index)
		if action == "GetShop" then 
			ShopEvent:FireClient(player, "UpdateShop", ShopManager.CurrentShopOfferings)
		elseif action == "BuyItem" and index then
			local shopItem = ShopManager.CurrentShopOfferings[index]
			if not shopItem then return end

			local folder = player:FindFirstChild("PlayerData")
			if not folder then return end

			local cost = (index == 1) and 0 or GameConfig.QuinqueShopCost 
			if folder.Reputation.Value >= cost then
				folder.Reputation.Value -= cost
				DataManager.GiveItem(player, shopItem) 
				Network.notify(player, "Purchased " .. shopItem.Name .. "!", Color3.fromRGB(50, 255, 50))

				if index > 1 then 
					table.remove(ShopManager.CurrentShopOfferings, index)
					ShopEvent:FireAllClients("UpdateShop", ShopManager.CurrentShopOfferings) 
				end
			else 
				Network.notify(player, "Not enough Reputation!", Color3.fromRGB(255, 50, 50)) 
			end
		end
	end)

	task.spawn(function() while true do task.wait(60); ShopManager.RefreshShop() end end)
	ShopManager.RefreshShop()
end

function ShopManager.RefreshShop()
	local StandardIssue = { ItemType = "Quinque", Name = "Standard Issue", Type = "Bikaku", Weapon = "Sword", Str = 5, Spd = 2, Mutation = "None", Creator = "CCG Quartermaster", Durability = 50, MaxDurability = 50, Broken = false, Id = "StandardIssue" }
	local currentTime = os.time()

	if RunService:IsStudio() then
		if currentTime >= (ShopManager.LocalShopTime or 0) then
			ShopManager.CurrentShopOfferings = { StandardIssue }
			local poolCopy = {unpack(ShopManager.StudioFallbackPool)}
			for i = 1, math.min(5, #poolCopy) do
				local idx = math.random(1, #poolCopy)
				table.insert(ShopManager.CurrentShopOfferings, poolCopy[idx])
				table.remove(poolCopy, idx)
			end
			ShopManager.LocalShopTime = currentTime + 1800
		end
	else
		local success, shopData = pcall(function() return GlobalShopStore:GetAsync("CurrentOfferings") end)
		if not success or not shopData or currentTime >= (shopData.NextRefresh or 0) then
			pcall(function()
				GlobalShopStore:UpdateAsync("CurrentOfferings", function(old)
					if old and currentTime < (old.NextRefresh or 0) then return nil end 
					local pSuccess, pool = pcall(function() return GlobalPoolStore:GetAsync("Weapons") end)
					pool = (pSuccess and type(pool) == "table") and pool or {}
					local newItems = {}
					for i = 1, math.min(5, #pool) do
						local idx = math.random(1, #pool)
						table.insert(newItems, pool[idx])
						table.remove(pool, idx)
					end
					return { Items = newItems, NextRefresh = currentTime + 1800 }
				end)
			end)
			success, shopData = pcall(function() return GlobalShopStore:GetAsync("CurrentOfferings") end)
		end
		ShopManager.CurrentShopOfferings = { StandardIssue }
		if success and shopData and shopData.Items then 
			for _, item in ipairs(shopData.Items) do table.insert(ShopManager.CurrentShopOfferings, item) end 
		end
	end

	if ShopEvent then ShopEvent:FireAllClients("UpdateShop", ShopManager.CurrentShopOfferings) end
end

function ShopManager.AddRetiredItem(data)
	if RunService:IsStudio() then 
		table.insert(ShopManager.StudioFallbackPool, data)
	else
		pcall(function()
			GlobalPoolStore:UpdateAsync("Weapons", function(old)
				old = type(old) == "table" and old or {}
				table.insert(old, data)
				if #old > 200 then table.remove(old, 1) end 
				return old
			end)
		end)
	end
end

return ShopManager