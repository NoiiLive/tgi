-- @ScriptType: ModuleScript
-- @ScriptType: ModuleScript
local CombatTab = { UI = {} }
local task = task

function CombatTab.Build(frame, CombatEvent, playerData, factionData, GameConfig)
	CombatTab.UI.WardBtn = Instance.new("TextButton"); CombatTab.UI.WardBtn.Size = UDim2.new(0.5, 0, 0, 50); CombatTab.UI.WardBtn.Position = UDim2.new(0.25, 0, 0.28, 0); CombatTab.UI.WardBtn.Font = Enum.Font.GothamBold; CombatTab.UI.WardBtn.TextSize = 22; CombatTab.UI.WardBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); CombatTab.UI.WardBtn.TextColor3 = Color3.fromRGB(200, 200, 255); CombatTab.UI.WardBtn.Text = "Current Patrol: 20th Ward"; CombatTab.UI.WardBtn.Parent = frame
	CombatTab.UI.SearchBtn = Instance.new("TextButton"); CombatTab.UI.SearchBtn.Size = UDim2.new(0.5, 0, 0, 80); CombatTab.UI.SearchBtn.Position = UDim2.new(0.25, 0, 0.45, 0); CombatTab.UI.SearchBtn.Text = "Search for Enemies"; CombatTab.UI.SearchBtn.Font = Enum.Font.GothamBold; CombatTab.UI.SearchBtn.TextSize = 28; CombatTab.UI.SearchBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50); CombatTab.UI.SearchBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CombatTab.UI.SearchBtn.Parent = frame

	CombatTab.UI.MapPanel = Instance.new("ScrollingFrame"); CombatTab.UI.MapPanel.Size = UDim2.new(0.8, 0, 0.6, 0); CombatTab.UI.MapPanel.Position = UDim2.new(0.1, 0, 0.2, 0); CombatTab.UI.MapPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 25); CombatTab.UI.MapPanel.AutomaticCanvasSize = Enum.AutomaticSize.Y; CombatTab.UI.MapPanel.CanvasSize = UDim2.new(0, 0, 0, 0); CombatTab.UI.MapPanel.ScrollBarThickness = 8; CombatTab.UI.MapPanel.Visible = false; CombatTab.UI.MapPanel.ZIndex = 50; CombatTab.UI.MapPanel.Parent = frame

	local listLayout = Instance.new("UIListLayout", CombatTab.UI.MapPanel); listLayout.Padding = UDim.new(0, 10); listLayout.SortOrder = Enum.SortOrder.LayoutOrder; listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local topPadding = Instance.new("UIPadding", CombatTab.UI.MapPanel); topPadding.PaddingTop = UDim.new(0, 10); topPadding.PaddingBottom = UDim.new(0, 10)

	local closeMapBtn = Instance.new("TextButton"); closeMapBtn.Size = UDim2.new(0.95, 0, 0, 50); closeMapBtn.Text = "Close Map"; closeMapBtn.Font = Enum.Font.GothamBold; closeMapBtn.TextSize = 20; closeMapBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50); closeMapBtn.TextColor3 = Color3.fromRGB(255, 255, 255); closeMapBtn.LayoutOrder = -1; closeMapBtn.ZIndex = 51; closeMapBtn.Parent = CombatTab.UI.MapPanel
	closeMapBtn.MouseButton1Click:Connect(function() CombatTab.UI.MapPanel.Visible = false; CombatTab.UI.WardBtn.Visible = true; CombatTab.UI.SearchBtn.Visible = true end)

	local sortedWards = {}
	for key, data in pairs(GameConfig.Wards) do
		local num = tonumber(string.match(key, "%d+")) or 99
		table.insert(sortedWards, {Key = key, Data = data, Num = num})
	end
	table.sort(sortedWards, function(a, b) return a.Num < b.Num end)

	local dynWards = game:GetService("ReplicatedStorage"):WaitForChild("DynamicWards")

	for i, w in ipairs(sortedWards) do
		local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0.95, 0, 0, 50); btn.Font = Enum.Font.GothamBold; btn.TextSize = 18; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.LayoutOrder = i; btn.ZIndex = 51; btn.Parent = CombatTab.UI.MapPanel

		local wardVal = dynWards:FindFirstChild(w.Key)
		local function updateBtnText()
			local risk = wardVal and wardVal.Value or 1
			btn.Text = w.Data.Name .. " (Risk: " .. string.format("%.1fx", risk) .. ")"
			local alpha = math.clamp((risk - 1) / 4, 0, 1)
			local r = math.floor(50 + (150 * alpha))
			local g = math.floor(200 - (150 * alpha))
			local b = 50
			btn.BackgroundColor3 = Color3.fromRGB(r, g, b)
		end
		if wardVal then wardVal.Changed:Connect(updateBtnText) end
		updateBtnText()

		btn.MouseButton1Click:Connect(function()
			CombatEvent:FireServer("ChangeWard", w.Key)
			CombatTab.UI.MapPanel.Visible = false; CombatTab.UI.WardBtn.Visible = true; CombatTab.UI.SearchBtn.Visible = true
		end)
	end

	CombatTab.UI.BattleArena = Instance.new("Frame"); CombatTab.UI.BattleArena.Size = UDim2.new(0.9, 0, 0.8, 0); CombatTab.UI.BattleArena.Position = UDim2.new(0.05, 0, 0.15, 0); CombatTab.UI.BattleArena.BackgroundTransparency = 1; CombatTab.UI.BattleArena.Visible = false; CombatTab.UI.BattleArena.Parent = frame
	CombatTab.UI.EnemyLabel = Instance.new("TextLabel"); CombatTab.UI.EnemyLabel.Size = UDim2.new(1, 0, 0, 50); CombatTab.UI.EnemyLabel.Font = Enum.Font.GothamBlack; CombatTab.UI.EnemyLabel.TextSize = 30; CombatTab.UI.EnemyLabel.TextColor3 = Color3.fromRGB(255, 100, 100); CombatTab.UI.EnemyLabel.BackgroundTransparency = 1; CombatTab.UI.EnemyLabel.Parent = CombatTab.UI.BattleArena
	CombatTab.UI.CombatLog = Instance.new("ScrollingFrame"); CombatTab.UI.CombatLog.Size = UDim2.new(1, 0, 0.55, 0); CombatTab.UI.CombatLog.Position = UDim2.new(0, 0, 0.15, 0); CombatTab.UI.CombatLog.BackgroundColor3 = Color3.fromRGB(20, 20, 20); CombatTab.UI.CombatLog.AutomaticCanvasSize = Enum.AutomaticSize.Y; CombatTab.UI.CombatLog.CanvasSize = UDim2.new(0, 0, 0, 0); CombatTab.UI.CombatLog.ScrollBarThickness = 8; Instance.new("UIListLayout", CombatTab.UI.CombatLog).Parent = CombatTab.UI.CombatLog; CombatTab.UI.CombatLog.Parent = CombatTab.UI.BattleArena
	CombatTab.UI.PlayerStatLabel = Instance.new("TextLabel"); CombatTab.UI.PlayerStatLabel.Size = UDim2.new(1, 0, 0, 30); CombatTab.UI.PlayerStatLabel.Position = UDim2.new(0, 0, 0.72, 0); CombatTab.UI.PlayerStatLabel.Font = Enum.Font.GothamBold; CombatTab.UI.PlayerStatLabel.TextSize = 22; CombatTab.UI.PlayerStatLabel.TextColor3 = Color3.fromRGB(100, 255, 100); CombatTab.UI.PlayerStatLabel.BackgroundTransparency = 1; CombatTab.UI.PlayerStatLabel.Parent = CombatTab.UI.BattleArena

	CombatTab.UI.AttackBtn = Instance.new("TextButton"); CombatTab.UI.AttackBtn.Size = UDim2.new(0.25, 0, 0, 60); CombatTab.UI.AttackBtn.Position = UDim2.new(0.05, 0, 0.8, 0); CombatTab.UI.AttackBtn.Text = "ATTACK"; CombatTab.UI.AttackBtn.Font = Enum.Font.GothamBlack; CombatTab.UI.AttackBtn.TextSize = 24; CombatTab.UI.AttackBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); CombatTab.UI.AttackBtn.TextColor3 = Color3.fromRGB(255,255,255); CombatTab.UI.AttackBtn.Parent = CombatTab.UI.BattleArena
	CombatTab.UI.EatFleshBtn = Instance.new("TextButton"); CombatTab.UI.EatFleshBtn.Size = UDim2.new(0.25, 0, 0, 60); CombatTab.UI.EatFleshBtn.Position = UDim2.new(0.35, 0, 0.8, 0); CombatTab.UI.EatFleshBtn.Text = "EAT FLESH"; CombatTab.UI.EatFleshBtn.Font = Enum.Font.GothamBlack; CombatTab.UI.EatFleshBtn.TextSize = 24; CombatTab.UI.EatFleshBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 30); CombatTab.UI.EatFleshBtn.TextColor3 = Color3.fromRGB(255,255,255); CombatTab.UI.EatFleshBtn.Visible = false; CombatTab.UI.EatFleshBtn.Parent = CombatTab.UI.BattleArena
	CombatTab.UI.RestBtn = Instance.new("TextButton"); CombatTab.UI.RestBtn.Size = UDim2.new(0.25, 0, 0, 60); CombatTab.UI.RestBtn.Position = UDim2.new(0.35, 0, 0.8, 0); CombatTab.UI.RestBtn.Text = "REST (+20 Stamina)"; CombatTab.UI.RestBtn.Font = Enum.Font.GothamBlack; CombatTab.UI.RestBtn.TextSize = 18; CombatTab.UI.RestBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 255); CombatTab.UI.RestBtn.TextColor3 = Color3.fromRGB(255,255,255); CombatTab.UI.RestBtn.Visible = false; CombatTab.UI.RestBtn.Parent = CombatTab.UI.BattleArena
	CombatTab.UI.ArataBtn = Instance.new("TextButton"); CombatTab.UI.ArataBtn.Size = UDim2.new(0.1, 0, 0, 60); CombatTab.UI.ArataBtn.Position = UDim2.new(0.62, 0, 0.8, 0); CombatTab.UI.ArataBtn.Text = "ARATA\n[OFF]"; CombatTab.UI.ArataBtn.Font = Enum.Font.GothamBlack; CombatTab.UI.ArataBtn.TextSize = 16; CombatTab.UI.ArataBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); CombatTab.UI.ArataBtn.TextColor3 = Color3.fromRGB(200, 200, 200); CombatTab.UI.ArataBtn.Visible = false; CombatTab.UI.ArataBtn.Parent = CombatTab.UI.BattleArena
	CombatTab.UI.FleeBtn = Instance.new("TextButton"); CombatTab.UI.FleeBtn.Size = UDim2.new(0.2, 0, 0, 60); CombatTab.UI.FleeBtn.Position = UDim2.new(0.75, 0, 0.8, 0); CombatTab.UI.FleeBtn.Text = "FLEE"; CombatTab.UI.FleeBtn.Font = Enum.Font.GothamBlack; CombatTab.UI.FleeBtn.TextSize = 24; CombatTab.UI.FleeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100); CombatTab.UI.FleeBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CombatTab.UI.FleeBtn.Visible = false; CombatTab.UI.FleeBtn.Parent = CombatTab.UI.BattleArena

	local function updateWardBtnTxt()
		local wName = playerData:FindFirstChild("PatrolWard") and playerData.PatrolWard.Value or "20th Ward"
		local baseData = GameConfig.Wards[wName]
		local val = dynWards and dynWards:FindFirstChild(wName)
		local risk = val and val.Value or 1
		CombatTab.UI.WardBtn.Text = "Current Patrol: " .. (baseData and baseData.Name or wName) .. " (Risk: " .. string.format("%.1fx", risk) .. ")"
	end

	task.spawn(function()
		local wardStat = playerData:WaitForChild("PatrolWard")
		wardStat.Changed:Connect(updateWardBtnTxt)
		for _, child in ipairs(dynWards:GetChildren()) do
			child.Changed:Connect(function()
				if playerData:FindFirstChild("PatrolWard") and playerData.PatrolWard.Value == child.Name then
					updateWardBtnTxt()
				end
			end)
		end
		updateWardBtnTxt()
	end)

	task.spawn(function()
		local arataStat = playerData:WaitForChild("ArataActive")
		arataStat.Changed:Connect(function() CombatTab.UpdateStats(playerData, factionData) end)
	end)

	CombatTab.UI.WardBtn.MouseButton1Click:Connect(function()
		CombatTab.UI.WardBtn.Visible = false
		CombatTab.UI.SearchBtn.Visible = false
		CombatTab.UI.MapPanel.Visible = true
	end)

	CombatTab.UI.SearchBtn.MouseButton1Click:Connect(function() CombatTab.UI.SearchBtn.Visible = false; CombatTab.UI.WardBtn.Visible = false; CombatEvent:FireServer("Search") end)
	CombatTab.UI.AttackBtn.MouseButton1Click:Connect(function() CombatEvent:FireServer("Attack") end)
	CombatTab.UI.EatFleshBtn.MouseButton1Click:Connect(function() CombatEvent:FireServer("ConsumeFlesh") end)
	CombatTab.UI.RestBtn.MouseButton1Click:Connect(function() CombatEvent:FireServer("Rest") end)
	CombatTab.UI.ArataBtn.MouseButton1Click:Connect(function() CombatEvent:FireServer("ToggleArata") end)
	CombatTab.UI.FleeBtn.MouseButton1Click:Connect(function() CombatEvent:FireServer("Flee") end)

	CombatEvent.OnClientEvent:Connect(function(action, data1, data2)
		if action == "BattleStarted" then
			CombatTab.UI.BattleArena.Visible = true; CombatTab.UI.WardBtn.Visible = false; CombatTab.UI.SearchBtn.Visible = false; CombatTab.UI.MapPanel.Visible = false; CombatTab.UI.FleeBtn.Visible = true
			for _, child in pairs(CombatTab.UI.CombatLog:GetChildren()) do if child:IsA("TextLabel") then child:Destroy() end end
			CombatTab.UI.EnemyLabel.Text = data1.Name .. " HP: " .. data1.CurrentHealth .. " / " .. data1.MaxHealth; CombatTab.UpdateStats(playerData, factionData)
			CombatTab.AddLog("Encountered " .. data1.Name .. "!")
		elseif action == "TurnUpdate" then
			CombatTab.UI.EnemyLabel.Text = data1.Name .. " HP: " .. data1.CurrentHealth .. " / " .. data1.MaxHealth; CombatTab.UpdateStats(playerData, factionData)
			for _, str in ipairs(data2) do CombatTab.AddLog(str) end
		elseif action == "BattleEnded" then
			CombatTab.UpdateStats(playerData, factionData); for _, str in ipairs(data1) do CombatTab.AddLog(str) end
			CombatTab.UI.AttackBtn.Visible = false; CombatTab.UI.EatFleshBtn.Visible = false; CombatTab.UI.RestBtn.Visible = false; CombatTab.UI.ArataBtn.Visible = false; CombatTab.UI.FleeBtn.Visible = false
			task.wait(3) 
			CombatTab.UI.BattleArena.Visible = false; CombatTab.UI.AttackBtn.Visible = true; CombatTab.UI.SearchBtn.Visible = true; CombatTab.UI.WardBtn.Visible = true; CombatTab.UpdateStats(playerData, factionData)
		end
	end)
end

function CombatTab.UpdateStats(playerData, factionData)
	if not CombatTab.UI.PlayerStatLabel then return end
	local hp = playerData:FindFirstChild("CurrentHealth") and playerData.CurrentHealth.Value or 0
	local maxHp = playerData:FindFirstChild("MaxHealth") and playerData.MaxHealth.Value or 0
	local fac = factionData.Value; local extraTxt = ""
	if fac == "GHOUL" then 
		extraTxt = "  |  Hunger: " .. (playerData:FindFirstChild("Hunger") and playerData.Hunger.Value or 0)
		CombatTab.UI.EatFleshBtn.Visible = true; CombatTab.UI.RestBtn.Visible = false; CombatTab.UI.ArataBtn.Visible = false
	elseif fac == "CCG" then 
		extraTxt = "  |  Stamina: " .. (playerData:FindFirstChild("CurrentStamina") and playerData.CurrentStamina.Value or 0) .. " / " .. (playerData:FindFirstChild("Stamina") and playerData.Stamina.Value or 0)
		CombatTab.UI.EatFleshBtn.Visible = false; CombatTab.UI.RestBtn.Visible = true
		local arataState = playerData:FindFirstChild("ArataActive") and playerData.ArataActive.Value or false
		if playerData:FindFirstChild("EquippedArata") and playerData.EquippedArata.Value ~= "None" then
			CombatTab.UI.ArataBtn.Visible = true; CombatTab.UI.ArataBtn.Text = arataState and "ARATA\n[ON]" or "ARATA\n[OFF]"
			CombatTab.UI.ArataBtn.BackgroundColor3 = arataState and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(60, 60, 60)
			CombatTab.UI.ArataBtn.TextColor3 = arataState and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
		else CombatTab.UI.ArataBtn.Visible = false end
	end
	CombatTab.UI.PlayerStatLabel.Text = "Your HP: " .. hp .. " / " .. maxHp .. extraTxt
end

function CombatTab.AddLog(msgText)
	local msg = Instance.new("TextLabel"); msg.Size = UDim2.new(1, 0, 0, 30); msg.Text = " " .. msgText; msg.Font = Enum.Font.Gotham; msg.TextSize = 18; msg.TextColor3 = Color3.fromRGB(200, 200, 200); msg.BackgroundTransparency = 1; msg.TextXAlignment = Enum.TextXAlignment.Left; msg.Parent = CombatTab.UI.CombatLog
	task.defer(function() CombatTab.UI.CombatLog.CanvasPosition = Vector2.new(0, CombatTab.UI.CombatLog.AbsoluteCanvasSize.Y) end)
end

return CombatTab