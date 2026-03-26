-- @ScriptType: ModuleScript
local DataManager = { ActiveTraining = {} } 
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Store = DataStoreService:GetDataStore("GameData_V8")
local GameConfig

function DataManager.Init(config) GameConfig = config end

function DataManager.GenerateKagune()
	local types = GameConfig.Kagunes
	if math.random(1, 100) <= GameConfig.ChimeraChance then
		local t1 = types[math.random(1, #types)]; local t2
		repeat t2 = types[math.random(1, #types)] until t1 ~= t2
		return t1 .. "-" .. t2
	else return types[math.random(1, #types)] end
end

function DataManager.SetupPlayer(player)
	local folder = Instance.new("Folder"); folder.Name = "PlayerData"; folder.Parent = player
	for statName, defaultVal in pairs(GameConfig.DefaultStats) do
		local statType = type(defaultVal) == "number" and "IntValue" or (type(defaultVal) == "boolean" and "BoolValue" or "StringValue")
		local stat = Instance.new(statType, folder); stat.Name = statName; stat.Value = defaultVal
	end
	local curHP = Instance.new("IntValue", folder); curHP.Name = "CurrentHealth"; curHP.Value = 100
	local curStamina = Instance.new("IntValue", folder); curStamina.Name = "CurrentStamina"; curStamina.Value = folder.Stamina.Value
	local arataActive = Instance.new("BoolValue", folder); arataActive.Name = "ArataActive"; arataActive.Value = false
	local arataEaten = Instance.new("BoolValue", folder); arataEaten.Name = "ArataHasEaten"; arataEaten.Value = false
	local invFolder = Instance.new("Folder"); invFolder.Name = "Inventory"; invFolder.Parent = folder

	if not RunService:IsStudio() then
		local success, saved = pcall(function() return Store:GetAsync(tostring(player.UserId)) end)
		if success and saved then
			for statName, value in pairs(saved.Stats or {}) do local stat = folder:FindFirstChild(statName); if stat then stat.Value = value end end
			for itemID, itemJSON in pairs(saved.Inventory or {}) do local item = Instance.new("StringValue", invFolder); item.Name = itemID; item.Value = itemJSON end
			folder.CurrentHealth.Value = folder.MaxHealth.Value; folder.CurrentStamina.Value = folder.Stamina.Value
		end
	end
	if folder:FindFirstChild("ArataActive") then folder.ArataActive.Value = false end
end

function DataManager.SavePlayer(player)
	if RunService:IsStudio() then return end
	local folder = player:FindFirstChild("PlayerData"); if not folder then return end
	local dataToSave = { Stats = {}, Inventory = {} }
	for _, stat in ipairs(folder:GetChildren()) do
		if stat:IsA("ValueBase") and stat.Name ~= "CurrentHealth" and stat.Name ~= "CurrentStamina" and stat.Name ~= "ArataActive" and stat.Name ~= "ArataHasEaten" then 
			dataToSave.Stats[stat.Name] = stat.Value 
		elseif stat.Name == "Inventory" then
			for _, item in ipairs(stat:GetChildren()) do dataToSave.Inventory[item.Name] = item.Value end
		end
	end
	pcall(function() Store:SetAsync(tostring(player.UserId), dataToSave) end)
end

function DataManager.GiveItem(player, itemTable)
	local invFolder = player.PlayerData.Inventory
	local itemID = itemTable.Id

	if not itemID or itemID == "StandardIssue" then
		itemID = "Item_" .. HttpService:GenerateGUID(false)
		itemTable.Id = itemID 
	end

	local itemNode = Instance.new("StringValue", invFolder)
	itemNode.Name = itemID
	itemNode.Value = HttpService:JSONEncode(itemTable)
end

return DataManager