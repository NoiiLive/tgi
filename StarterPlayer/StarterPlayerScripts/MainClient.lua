-- @ScriptType: LocalScript
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local GameConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GameConfig"))
local UIMod = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ClientUI")
local UIManager = require(UIMod:WaitForChild("UIManager"))
local FactionTab = require(UIMod:WaitForChild("FactionTab"))
local CombatTab = require(UIMod:WaitForChild("CombatTab"))
local CharacterTab = require(UIMod:WaitForChild("CharacterTab"))
local InventoryTab = require(UIMod:WaitForChild("InventoryTab"))
local ShopTab = require(UIMod:WaitForChild("ShopTab"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local FactionEvent = Remotes:WaitForChild("FactionSelect")
local TrainingEvent = Remotes:WaitForChild("TrainingAction")
local CombatEvent = Remotes:WaitForChild("CombatAction")
local InventoryEvent = Remotes:WaitForChild("InventoryAction")
local ShopEvent = Remotes:WaitForChild("ShopAction")
local NotificationEvent = Remotes:WaitForChild("NotificationEvent")

local playerData = player:WaitForChild("PlayerData")
local factionData = playerData:WaitForChild("Faction")

local tabMenu = UIManager.Init(playerGui)
local charFrame = UIManager.CreateTab(tabMenu, "Character", 1)
local combFrame = UIManager.CreateTab(tabMenu, "Combat", 2)
local invFrame = UIManager.CreateTab(tabMenu, "Inventory", 3)
local shopFrame = UIManager.CreateTab(tabMenu, "Shop", 4)
local facFrame = UIManager.CreateTab(tabMenu, "Faction", 5)

FactionTab.Build(facFrame, FactionEvent)
CombatTab.Build(combFrame, CombatEvent, playerData, factionData, GameConfig)
ShopTab.Build(shopFrame, GameConfig, ShopEvent)

NotificationEvent.OnClientEvent:Connect(UIManager.ShowNotification)

local function refreshDynamicMenus()
	if factionData.Value == "Unchosen" then return end
	CharacterTab.Refresh(charFrame, GameConfig, TrainingEvent, playerData, factionData, HttpService)
	InventoryTab.Refresh(invFrame, GameConfig, InventoryEvent, playerData, factionData, HttpService)
end

local function handleLoginState()
	if factionData.Value == "Unchosen" then
		for name, btn in pairs(UIManager.Tabs) do btn.Visible = (name == "Faction") end
		UIManager.SwitchTab("Faction")
	else
		for name, btn in pairs(UIManager.Tabs) do btn.Visible = (name ~= "Faction") end
		UIManager.Tabs["Shop"].Visible = (factionData.Value == "CCG")
		refreshDynamicMenus()
		UIManager.SwitchTab("Character")
	end
end

factionData.Changed:Connect(handleLoginState)
handleLoginState()