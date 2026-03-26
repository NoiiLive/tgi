-- @ScriptType: ModuleScript
-- @ScriptType: ModuleScript
local CombatTab = { UI = {} }
local task = task
local TweenService = game:GetService("TweenService")
local SFXManager = require(game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("SFXManager"))

function CombatTab.Build(frame, CombatEvent, playerData, factionData, GameConfig)
	CombatTab.UI.WardBtn = Instance.new("TextButton"); CombatTab.UI.WardBtn.Size = UDim2.new(0.6, 0, 0, 50); CombatTab.UI.WardBtn.Position = UDim2.new(0.2, 0, 0.28, 0); CombatTab.UI.WardBtn.Font = Enum.Font.GothamBold; CombatTab.UI.WardBtn.TextSize = 16; CombatTab.UI.WardBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); CombatTab.UI.WardBtn.TextColor3 = Color3.fromRGB(200, 200, 255); CombatTab.UI.WardBtn.Text = "Current Patrol: 20th Ward"; CombatTab.UI.WardBtn.Parent = frame
	CombatTab.UI.SearchBtn = Instance.new("TextButton"); CombatTab.UI.SearchBtn.Size = UDim2.new(0.5, 0, 0, 80); CombatTab.UI.SearchBtn.Position = UDim2.new(0.25, 0, 0.45, 0); CombatTab.UI.SearchBtn.Text = "Search for Enemies"; CombatTab.UI.SearchBtn.Font = Enum.Font.GothamBold; CombatTab.UI.SearchBtn.TextSize = 28; CombatTab.UI.SearchBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50); CombatTab.UI.SearchBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CombatTab.UI.SearchBtn.Parent = frame

	CombatTab.UI.MapPanel = Instance.new("ScrollingFrame"); CombatTab.UI.MapPanel.Size = UDim2.new(0.8, 0, 0.6, 0); CombatTab.UI.MapPanel.Position = UDim2.new(0.1, 0, 0.2, 0); CombatTab.UI.MapPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 25); CombatTab.UI.MapPanel.AutomaticCanvasSize = Enum.AutomaticSize.Y; CombatTab.UI.MapPanel.CanvasSize = UDim2.new(0, 0, 0, 0); CombatTab.UI.MapPanel.ScrollBarThickness = 8; CombatTab.UI.MapPanel.Visible = false; CombatTab.UI.MapPanel.ZIndex = 50; CombatTab.UI.MapPanel.Parent = frame

	local listLayout = Instance.new("UIListLayout", CombatTab.UI.MapPanel); listLayout.Padding = UDim.new(0, 10); listLayout.SortOrder = Enum.SortOrder.LayoutOrder; listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local topPadding = Instance.new("UIPadding", CombatTab.UI.MapPanel); topPadding.PaddingTop = UDim.new(0, 10); topPadding.PaddingBottom = UDim.new(0, 10)

	local closeMapBtn = Instance.new("TextButton"); closeMapBtn.Size = UDim2.new(0.95, 0, 0, 50); closeMapBtn.Text = "Close Map"; closeMapBtn.Font = Enum.Font.GothamBold; closeMapBtn.TextSize = 20; closeMapBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50); closeMapBtn.TextColor3 = Color3.fromRGB(255, 255, 255); closeMapBtn.LayoutOrder = -1; closeMapBtn.ZIndex = 51; closeMapBtn.Parent = CombatTab.UI.MapPanel
	closeMapBtn.MouseButton1Click:Connect(function() 
		SFXManager.Play("Click")
		CombatTab.UI.MapPanel.Visible = false; CombatTab.UI.WardBtn.Visible = true; CombatTab.UI.SearchBtn.Visible = true 
	end)

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
			local reqKills = math.max(1, math.floor(risk * 2))

			local ccgKills = wardVal and wardVal:FindFirstChild("CCGKills")
			local ghoulKills = wardVal and wardVal:FindFirstChild("GhoulKills")
			local cKills = ccgKills and ccgKills.Value or 0
			local gKills = ghoulKills and ghoulKills.Value or 0

			local fac = factionData.Value
			local progStr = ""
			if fac == "CCG" then
				progStr = " | Securing: " .. cKills .. "/" .. reqKills
			elseif fac == "GHOUL" then
				progStr = " | Terror: " .. gKills .. "/" .. reqKills
			end

			btn.Text = w.Data.Name .. " (Risk: " .. string.format("%.1fx", risk) .. ")" .. progStr

			local alpha = math.clamp((risk - 1) / 4, 0, 1)
			local r = math.floor(50 + (150 * alpha))
			local g = math.floor(200 - (150 * alpha))
			local b = 50
			btn.BackgroundColor3 = Color3.fromRGB(r, g, b)
		end

		if wardVal then 
			wardVal.Changed:Connect(updateBtnText) 
			local cKills = wardVal:FindFirstChild("CCGKills")
			if cKills then cKills.Changed:Connect(updateBtnText) end
			local gKills = wardVal:FindFirstChild("GhoulKills")
			if gKills then gKills.Changed:Connect(updateBtnText) end
		end
		updateBtnText()

		btn.MouseButton1Click:Connect(function()
			SFXManager.Play("Click")
			CombatEvent:FireServer("ChangeWard", w.Key)
			CombatTab.UI.MapPanel.Visible = false; CombatTab.UI.WardBtn.Visible = true; CombatTab.UI.SearchBtn.Visible = true
		end)
	end

	CombatTab.UI.BattleArena = Instance.new("Frame"); CombatTab.UI.BattleArena.Size = UDim2.new(0.9, 0, 0.8, 0); CombatTab.UI.BattleArena.Position = UDim2.new(0.05, 0, 0.15, 0); CombatTab.UI.BattleArena.BackgroundTransparency = 1; CombatTab.UI.BattleArena.Visible = false; CombatTab.UI.BattleArena.Parent = frame

	CombatTab.UI.PlayerSide = Instance.new("Frame"); CombatTab.UI.PlayerSide.Size = UDim2.new(0.4, 0, 0.35, 0); CombatTab.UI.PlayerSide.Position = UDim2.new(0.05, 0, 0, 0); CombatTab.UI.PlayerSide.BackgroundTransparency = 1; CombatTab.UI.PlayerSide.Parent = CombatTab.UI.BattleArena
	CombatTab.UI.PlayerIcon = Instance.new("ImageLabel"); CombatTab.UI.PlayerIcon.Size = UDim2.new(0, 80, 0, 80); CombatTab.UI.PlayerIcon.Position = UDim2.new(0.5, -40, 0, 0); CombatTab.UI.PlayerIcon.BackgroundColor3 = Color3.fromRGB(40, 40, 40); CombatTab.UI.PlayerIcon.Image = "rbxthumb://type=AvatarHeadShot&id=" .. game:GetService("Players").LocalPlayer.UserId .. "&w=150&h=150"; CombatTab.UI.PlayerIcon.Parent = CombatTab.UI.PlayerSide
	CombatTab.UI.PlayerHPBG = Instance.new("Frame"); CombatTab.UI.PlayerHPBG.Size = UDim2.new(1, 0, 0, 20); CombatTab.UI.PlayerHPBG.Position = UDim2.new(0, 0, 0, 90); CombatTab.UI.PlayerHPBG.BackgroundColor3 = Color3.fromRGB(60, 20, 20); CombatTab.UI.PlayerHPBG.Parent = CombatTab.UI.PlayerSide
	CombatTab.UI.PlayerHPFill = Instance.new("Frame"); CombatTab.UI.PlayerHPFill.Size = UDim2.new(1, 0, 1, 0); CombatTab.UI.PlayerHPFill.BackgroundColor3 = Color3.fromRGB(50, 200, 50); CombatTab.UI.PlayerHPFill.BorderSizePixel = 0; CombatTab.UI.PlayerHPFill.Parent = CombatTab.UI.PlayerHPBG
	CombatTab.UI.PlayerStatLabel = Instance.new("TextLabel"); CombatTab.UI.PlayerStatLabel.Size = UDim2.new(1, 0, 0, 30); CombatTab.UI.PlayerStatLabel.Position = UDim2.new(0, 0, 0, 115); CombatTab.UI.PlayerStatLabel.Font = Enum.Font.GothamBold; CombatTab.UI.PlayerStatLabel.TextSize = 14; CombatTab.UI.PlayerStatLabel.TextColor3 = Color3.fromRGB(200, 255, 200); CombatTab.UI.PlayerStatLabel.BackgroundTransparency = 1; CombatTab.UI.PlayerStatLabel.Parent = CombatTab.UI.PlayerSide

	CombatTab.UI.EnemySide = Instance.new("Frame"); CombatTab.UI.EnemySide.Size = UDim2.new(0.4, 0, 0.35, 0); CombatTab.UI.EnemySide.Position = UDim2.new(0.55, 0, 0, 0); CombatTab.UI.EnemySide.BackgroundTransparency = 1; CombatTab.UI.EnemySide.Parent = CombatTab.UI.BattleArena
	CombatTab.UI.EnemyIconBG = Instance.new("Frame"); CombatTab.UI.EnemyIconBG.Size = UDim2.new(0, 80, 0, 80); CombatTab.UI.EnemyIconBG.Position = UDim2.new(0.5, -40, 0, 0); CombatTab.UI.EnemyIconBG.BackgroundColor3 = Color3.fromRGB(40, 40, 40); CombatTab.UI.EnemyIconBG.Parent = CombatTab.UI.EnemySide
	CombatTab.UI.EnemyIconTxt = Instance.new("TextLabel"); CombatTab.UI.EnemyIconTxt.Size = UDim2.new(1, 0, 1, 0); CombatTab.UI.EnemyIconTxt.Text = "?"; CombatTab.UI.EnemyIconTxt.Font = Enum.Font.GothamBlack; CombatTab.UI.EnemyIconTxt.TextSize = 50; CombatTab.UI.EnemyIconTxt.TextColor3 = Color3.fromRGB(200, 50, 50); CombatTab.UI.EnemyIconTxt.BackgroundTransparency = 1; CombatTab.UI.EnemyIconTxt.Parent = CombatTab.UI.EnemyIconBG
	CombatTab.UI.EnemyHPBG = Instance.new("Frame"); CombatTab.UI.EnemyHPBG.Size = UDim2.new(1, 0, 0, 20); CombatTab.UI.EnemyHPBG.Position = UDim2.new(0, 0, 0, 90); CombatTab.UI.EnemyHPBG.BackgroundColor3 = Color3.fromRGB(60, 20, 20); CombatTab.UI.EnemyHPBG.Parent = CombatTab.UI.EnemySide
	CombatTab.UI.EnemyHPFill = Instance.new("Frame"); CombatTab.UI.EnemyHPFill.Size = UDim2.new(1, 0, 1, 0); CombatTab.UI.EnemyHPFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50); CombatTab.UI.EnemyHPFill.BorderSizePixel = 0; CombatTab.UI.EnemyHPFill.Parent = CombatTab.UI.EnemyHPBG
	CombatTab.UI.EnemyLabel = Instance.new("TextLabel"); CombatTab.UI.EnemyLabel.Size = UDim2.new(1, 0, 0, 30); CombatTab.UI.EnemyLabel.Position = UDim2.new(0, 0, 0, 115); CombatTab.UI.EnemyLabel.Font = Enum.Font.GothamBold; CombatTab.UI.EnemyLabel.TextSize = 14; CombatTab.UI.EnemyLabel.TextColor3 = Color3.fromRGB(255, 150, 150); CombatTab.UI.EnemyLabel.BackgroundTransparency = 1; CombatTab.UI.EnemyLabel.Parent = CombatTab.UI.EnemySide

	CombatTab.UI.CombatLog = Instance.new("ScrollingFrame"); CombatTab.UI.CombatLog.Size = UDim2.new(1, 0, 0.35, 0); CombatTab.UI.CombatLog.Position = UDim2.new(0, 0, 0.4, 0); CombatTab.UI.CombatLog.BackgroundColor3 = Color3.fromRGB(20, 20, 20); CombatTab.UI.CombatLog.AutomaticCanvasSize = Enum.AutomaticSize.Y; CombatTab.UI.CombatLog.CanvasSize = UDim2.new(0, 0, 0, 0); CombatTab.UI.CombatLog.ScrollBarThickness = 8; Instance.new("UIListLayout", CombatTab.UI.CombatLog).Parent = CombatTab.UI.CombatLog; CombatTab.UI.CombatLog.Parent = CombatTab.UI.BattleArena

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
		local reqKills = math.max(1, math.floor(risk * 2))

		local ccgKills = val and val:FindFirstChild("CCGKills")
		local ghoulKills = val and val:FindFirstChild("GhoulKills")
		local cKills = ccgKills and ccgKills.Value or 0
		local gKills = ghoulKills and ghoulKills.Value or 0

		local fac = factionData.Value
		local progStr = ""
		if fac == "CCG" then
			progStr = " | Securing: " .. cKills .. "/" .. reqKills
		elseif fac == "GHOUL" then
			progStr = " | Terror: " .. gKills .. "/" .. reqKills
		end

		local timerStr = ""
		local tickVal = dynWards and dynWards:FindFirstChild("NextRiskIncrease")
		if tickVal then
			local timeLeft = math.max(0, tickVal.Value - os.time())
			local m = math.floor(timeLeft / 60)
			local s = timeLeft % 60
			timerStr = string.format(" | +0.1x in %02d:%02d", m, s)
		end

		CombatTab.UI.WardBtn.Text = "Current Patrol: " .. (baseData and baseData.Name or wName) .. " (Risk: " .. string.format("%.1fx", risk) .. ")" .. progStr .. timerStr
	end

	task.spawn(function()
		while true do
			task.wait(1)
			if CombatTab.UI.WardBtn.Visible then
				updateWardBtnTxt()
			end
		end
	end)

	task.spawn(function()
		local arataStat = playerData:WaitForChild("ArataActive")
		arataStat.Changed:Connect(function() CombatTab.UpdateStats(playerData, factionData) end)
	end)

	CombatTab.UI.WardBtn.MouseButton1Click:Connect(function()
		SFXManager.Play("Click")
		CombatTab.UI.WardBtn.Visible = false
		CombatTab.UI.SearchBtn.Visible = false
		CombatTab.UI.MapPanel.Visible = true
	end)

	CombatTab.UI.SearchBtn.MouseButton1Click:Connect(function() SFXManager.Play("Click"); CombatTab.UI.SearchBtn.Visible = false; CombatTab.UI.WardBtn.Visible = false; CombatEvent:FireServer("Search") end)
	CombatTab.UI.AttackBtn.MouseButton1Click:Connect(function() SFXManager.Play("Click"); CombatEvent:FireServer("Attack") end)
	CombatTab.UI.EatFleshBtn.MouseButton1Click:Connect(function() SFXManager.Play("Click"); CombatEvent:FireServer("ConsumeFlesh") end)
	CombatTab.UI.RestBtn.MouseButton1Click:Connect(function() SFXManager.Play("Click"); CombatEvent:FireServer("Rest") end)
	CombatTab.UI.ArataBtn.MouseButton1Click:Connect(function() SFXManager.Play("Click"); CombatEvent:FireServer("ToggleArata") end)
	CombatTab.UI.FleeBtn.MouseButton1Click:Connect(function() SFXManager.Play("Click"); CombatEvent:FireServer("Flee") end)

	local function PlayLogSequence(logTable, onComplete)
		CombatTab.UI.AttackBtn.Visible = false
		CombatTab.UI.EatFleshBtn.Visible = false
		CombatTab.UI.RestBtn.Visible = false
		CombatTab.UI.ArataBtn.Visible = false
		CombatTab.UI.FleeBtn.Visible = false

		task.spawn(function()
			local enemyMaxHP = CombatTab.CurrentEnemyMaxHP or 100
			local playerMaxHP = playerData:FindFirstChild("MaxHealth") and playerData.MaxHealth.Value or 100

			for _, str in ipairs(logTable) do
				CombatTab.AddLog(str)

				local lowerStr = string.lower(str)
				local changedEnemy = false
				local changedPlayer = false

				if string.find(lowerStr, "you struck") then
					CombatTab.VisualEnemyHP = math.max(0, CombatTab.VisualEnemyHP - (tonumber(string.match(str, "%d+")) or 0))
					changedEnemy = true
				elseif string.find(lowerStr, "retaliated") or string.find(lowerStr, "enemy struck you") or string.find(lowerStr, "took %d+ damage") then
					local dmg = tonumber(string.match(lowerStr, "took (%d+) damage")) or tonumber(string.match(lowerStr, "for (%d+) damage")) or tonumber(string.match(str, "%d+")) or 0
					CombatTab.VisualPlayerHP = math.max(0, CombatTab.VisualPlayerHP - dmg)
					changedPlayer = true
				elseif string.find(lowerStr, "drained") then
					CombatTab.VisualPlayerHP = math.min(playerMaxHP, CombatTab.VisualPlayerHP + (tonumber(string.match(str, "%d+")) or 0))
					changedPlayer = true
				elseif string.find(lowerStr, "arata armor consumes") then
					CombatTab.VisualPlayerHP = math.max(0, CombatTab.VisualPlayerHP - 10)
					changedPlayer = true
				elseif string.find(lowerStr, "recoil") then
					CombatTab.VisualPlayerHP = math.max(0, CombatTab.VisualPlayerHP - 3)
					changedPlayer = true
				elseif string.find(lowerStr, "sacrificed hp") then
					CombatTab.VisualPlayerHP = math.max(0, CombatTab.VisualPlayerHP - 5)
					changedPlayer = true
				end

				if changedEnemy then
					CombatTab.UI.EnemyLabel.Text = (CombatTab.CurrentEnemyName or "Enemy") .. " (" .. CombatTab.VisualEnemyHP .. "/" .. enemyMaxHP .. ")"
					TweenService:Create(CombatTab.UI.EnemyHPFill, TweenInfo.new(0.3), {Size = UDim2.new(math.clamp(CombatTab.VisualEnemyHP / enemyMaxHP, 0, 1), 0, 1, 0)}):Play()
					SFXManager.Play("CombatHit")
					CombatTab.ShakeScreen()
				end

				if changedPlayer then
					CombatTab.UpdateStats(playerData, factionData, CombatTab.VisualPlayerHP, playerMaxHP)
					TweenService:Create(CombatTab.UI.PlayerHPFill, TweenInfo.new(0.3), {Size = UDim2.new(math.clamp(CombatTab.VisualPlayerHP / playerMaxHP, 0, 1), 0, 1, 0)}):Play()
					SFXManager.Play("CombatHit")
					CombatTab.ShakeScreen()
				end

				task.wait(1)
			end

			if onComplete then onComplete() end
		end)
	end

	CombatEvent.OnClientEvent:Connect(function(action, data1, data2)
		if action == "BattleStarted" then
			CombatTab.CurrentEnemyName = data1.Name
			CombatTab.CurrentEnemyMaxHP = data1.MaxHealth
			CombatTab.VisualEnemyHP = data1.CurrentHealth
			CombatTab.VisualPlayerHP = playerData:FindFirstChild("CurrentHealth") and playerData.CurrentHealth.Value or 100

			CombatTab.UI.BattleArena.Visible = true; CombatTab.UI.WardBtn.Visible = false; CombatTab.UI.SearchBtn.Visible = false; CombatTab.UI.MapPanel.Visible = false; CombatTab.UI.FleeBtn.Visible = true
			for _, child in pairs(CombatTab.UI.CombatLog:GetChildren()) do if child:IsA("TextLabel") then child:Destroy() end end

			CombatTab.UI.EnemyLabel.Text = data1.Name .. " (" .. data1.CurrentHealth .. "/" .. data1.MaxHealth .. ")"
			CombatTab.UI.EnemyHPFill.Size = UDim2.new(math.clamp(data1.CurrentHealth / data1.MaxHealth, 0, 1), 0, 1, 0)

			CombatTab.UpdateStats(playerData, factionData)
			CombatTab.AddLog("Encountered " .. data1.Name .. "!")
		elseif action == "TurnUpdate" then
			PlayLogSequence(data2, function()
				CombatTab.VisualEnemyHP = data1.CurrentHealth
				CombatTab.UI.EnemyLabel.Text = (CombatTab.CurrentEnemyName or "Enemy") .. " (" .. CombatTab.VisualEnemyHP .. "/" .. CombatTab.CurrentEnemyMaxHP .. ")"
				TweenService:Create(CombatTab.UI.EnemyHPFill, TweenInfo.new(0.3), {Size = UDim2.new(math.clamp(CombatTab.VisualEnemyHP / CombatTab.CurrentEnemyMaxHP, 0, 1), 0, 1, 0)}):Play()

				CombatTab.VisualPlayerHP = playerData:FindFirstChild("CurrentHealth") and playerData.CurrentHealth.Value or 100
				CombatTab.UpdateStats(playerData, factionData)

				CombatTab.UI.AttackBtn.Visible = true
				CombatTab.UI.FleeBtn.Visible = true
			end)
		elseif action == "BattleEnded" then
			PlayLogSequence(data1, function()
				local isVictory = false
				local isDefeat = false

				for _, str in ipairs(data1) do 
					local lowerStr = string.lower(str)
					if string.find(lowerStr, "enemy defeated") then isVictory = true end
					if string.find(lowerStr, "you were defeated") then isDefeat = true end
				end

				CombatTab.VisualPlayerHP = playerData:FindFirstChild("CurrentHealth") and playerData.CurrentHealth.Value or 100
				CombatTab.UpdateStats(playerData, factionData)

				if isVictory then 
					SFXManager.Play("CombatVictory")
				elseif isDefeat then 
					SFXManager.Play("CombatDefeat")
				else 
					SFXManager.Play("CombatUtility") 
				end

				task.wait(3) 
				CombatTab.UI.BattleArena.Visible = false; CombatTab.UI.AttackBtn.Visible = true; CombatTab.UI.SearchBtn.Visible = true; CombatTab.UI.WardBtn.Visible = true; CombatTab.UpdateStats(playerData, factionData)
			end)
		end
	end)
end

function CombatTab.UpdateStats(playerData, factionData, hpOverride, maxHpOverride)
	if not CombatTab.UI.PlayerStatLabel then return end
	local maxHp = maxHpOverride or (playerData:FindFirstChild("MaxHealth") and playerData.MaxHealth.Value or 100)
	local hp = hpOverride or (playerData:FindFirstChild("CurrentHealth") and playerData.CurrentHealth.Value or 0)

	if CombatTab.UI.PlayerHPFill and not hpOverride then 
		local targetSize = UDim2.new(maxHp > 0 and math.clamp(hp / maxHp, 0, 1) or 0, 0, 1, 0)
		TweenService:Create(CombatTab.UI.PlayerHPFill, TweenInfo.new(0.3), {Size = targetSize}):Play()
	end

	local fac = factionData.Value; local extraTxt = ""
	if fac == "GHOUL" then 
		extraTxt = "  |  Hunger: " .. (playerData:FindFirstChild("Hunger") and playerData.Hunger.Value or 0)
		if CombatTab.UI.AttackBtn.Visible then CombatTab.UI.EatFleshBtn.Visible = true end
		CombatTab.UI.RestBtn.Visible = false; CombatTab.UI.ArataBtn.Visible = false
	elseif fac == "CCG" then 
		extraTxt = "  |  Stamina: " .. (playerData:FindFirstChild("CurrentStamina") and playerData.CurrentStamina.Value or 0) .. " / " .. (playerData:FindFirstChild("Stamina") and playerData.Stamina.Value or 0)
		CombatTab.UI.EatFleshBtn.Visible = false
		if CombatTab.UI.AttackBtn.Visible then CombatTab.UI.RestBtn.Visible = true end

		local arataState = playerData:FindFirstChild("ArataActive") and playerData.ArataActive.Value or false
		if playerData:FindFirstChild("EquippedArata") and playerData.EquippedArata.Value ~= "None" then
			if CombatTab.UI.AttackBtn.Visible then CombatTab.UI.ArataBtn.Visible = true end
			CombatTab.UI.ArataBtn.Text = arataState and "ARATA\n[ON]" or "ARATA\n[OFF]"
			CombatTab.UI.ArataBtn.BackgroundColor3 = arataState and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(60, 60, 60)
			CombatTab.UI.ArataBtn.TextColor3 = arataState and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
		else CombatTab.UI.ArataBtn.Visible = false end
	end
	CombatTab.UI.PlayerStatLabel.Text = "HP: " .. hp .. " / " .. maxHp .. extraTxt
end

function CombatTab.AddLog(msgText)
	local msg = Instance.new("TextLabel"); msg.Size = UDim2.new(1, 0, 0, 30); msg.Text = " " .. msgText; msg.Font = Enum.Font.Gotham; msg.TextSize = 18; msg.TextColor3 = Color3.fromRGB(200, 200, 200); msg.BackgroundTransparency = 1; msg.TextXAlignment = Enum.TextXAlignment.Left; msg.Parent = CombatTab.UI.CombatLog
	task.defer(function() CombatTab.UI.CombatLog.CanvasPosition = Vector2.new(0, CombatTab.UI.CombatLog.AbsoluteCanvasSize.Y) end)
end

function CombatTab.ShakeScreen()
	local arena = CombatTab.UI.BattleArena
	if not arena then return end
	local basePos = UDim2.new(0.05, 0, 0.15, 0)
	task.spawn(function()
		for i = 1, 5 do
			arena.Position = basePos + UDim2.new(0, math.random(-8, 8) / 1000, 0, math.random(-8, 8) / 1000)
			task.wait(0.04)
		end
		arena.Position = basePos
	end)
end

return CombatTab