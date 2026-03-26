-- @ScriptType: Script
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)
local EnemyConfig = require(ServerStorage.Modules.EnemyConfig)

local Network = {}
Network.Folder = ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder")
Network.Folder.Name = "Remotes"; Network.Folder.Parent = ReplicatedStorage
function Network.getEvent(name)
	local event = Network.Folder:FindFirstChild(name)
	if not event then event = Instance.new("RemoteEvent"); event.Name = name; event.Parent = Network.Folder end
	return event
end

local FactionEvent = Network.getEvent("FactionSelect")
local TrainingEvent = Network.getEvent("TrainingAction")
local CombatEvent = Network.getEvent("CombatAction")
local InventoryEvent = Network.getEvent("InventoryAction")
local NotificationEvent = Network.getEvent("NotificationEvent")
local ShopEvent = Network.getEvent("ShopAction")
function Network.notify(player, message, color) NotificationEvent:FireClient(player, message, color) end

local DataManager = require(ServerStorage.Modules.DataManager)
local ShopManager = require(ServerStorage.Modules.ShopManager)
local CombatManager = require(ServerStorage.Modules.CombatManager)
local InventoryManager = require(ServerStorage.Modules.InventoryManager)
local TrainingManager = require(ServerStorage.Modules.TrainingManager)

DataManager.Init(GameConfig)
ShopManager.Init({ ShopEvent = ShopEvent, GameConfig = GameConfig, DataManager = DataManager, Network = Network })
CombatManager.Init({ GameConfig = GameConfig, EnemyConfig = EnemyConfig, CombatEvent = CombatEvent, Network = Network, DataManager = DataManager })
InventoryManager.Init({ InventoryEvent = InventoryEvent, GameConfig = GameConfig, DataManager = DataManager, ShopManager = ShopManager, Network = Network })
TrainingManager.Init({ TrainingEvent = TrainingEvent, GameConfig = GameConfig, DataManager = DataManager, Network = Network })

Players.PlayerAdded:Connect(DataManager.SetupPlayer)
Players.PlayerRemoving:Connect(function(p) DataManager.ActiveTraining[p] = nil; CombatManager.ActiveBattles[p] = nil; DataManager.SavePlayer(p) end)
game:BindToClose(function() for _, p in pairs(Players:GetPlayers()) do DataManager.SavePlayer(p) end end)

FactionEvent.OnServerEvent:Connect(function(player, choice)
	local folder = player:FindFirstChild("PlayerData")
	if folder and folder.Faction.Value == "Unchosen" then 
		folder.Faction.Value = choice 
		if choice == "GHOUL" then 
			folder.PatrolWard.Value = "20th Ward"
			folder.Kagune.Value = DataManager.GenerateKagune() 
		elseif choice == "CCG" then
			folder.PatrolWard.Value = "1st Ward"
			local standardIssue = { ItemType = "Quinque", Name = "Standard Issue", Type = "Bikaku", Weapon = "Sword", Str = 5, Spd = 2, Mutation = "None", Creator = "CCG Quartermaster", Durability = 50, MaxDurability = 50, Broken = false, Id = "Item_"..HttpService:GenerateGUID(false) }
			DataManager.GiveItem(player, standardIssue)
			folder.EquippedQuinque.Value = HttpService:JSONEncode(standardIssue)
		end 
	end
end)

task.spawn(function() while true do task.wait(300); for _, p in pairs(Players:GetPlayers()) do DataManager.SavePlayer(p) end end end)

task.spawn(function() 
	while true do 
		task.wait(1) 
		for p, data in pairs(DataManager.ActiveTraining) do 
			if p and p.Parent then 
				data.Timer = data.Timer - 1
				if data.Timer <= 0 then
					data.Timer = 5 
					local folder = p:FindFirstChild("PlayerData")
					if folder then 
						local mult = (folder.Faction.Value == "CCG") and folder.CCGRankIndex.Value or 1
						folder[data.Stat].Value += (1 * mult) 
					end 
				end
			else 
				DataManager.ActiveTraining[p] = nil 
			end 
		end 
	end 
end)