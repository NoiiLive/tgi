-- @ScriptType: ModuleScript
local CharacterTab = { CurrentTraining = nil, ActiveTween = nil }
local TweenService = game:GetService("TweenService")

function CharacterTab.Refresh(frame, GameConfig, TrainingEvent, playerData, factionData, HttpService)
	local fac = factionData.Value; if fac == "Unchosen" then return end
	if frame:FindFirstChild("StatCont") then frame.StatCont:Destroy() end
	if frame:FindFirstChild("TrainCont") then frame.TrainCont:Destroy() end

	local sCont = Instance.new("ScrollingFrame"); sCont.Name = "StatCont"; sCont.Size = UDim2.new(0.45, 0, 0.8, 0); sCont.Position = UDim2.new(0.025, 0, 0.15, 0); sCont.BackgroundTransparency = 1; sCont.AutomaticCanvasSize = Enum.AutomaticSize.Y; sCont.CanvasSize = UDim2.new(0,0,0,0); sCont.ScrollBarThickness = 6; sCont.Parent = frame
	Instance.new("UIListLayout", sCont).Padding = UDim.new(0, 10)

	local tCont = Instance.new("Frame"); tCont.Name = "TrainCont"; tCont.Size = UDim2.new(0.48, 0, 0.8, 0); tCont.Position = UDim2.new(0.5, 0, 0.15, 0); tCont.BackgroundTransparency = 1; tCont.Parent = frame
	local layout = Instance.new("UIGridLayout", tCont); layout.CellSize = UDim2.new(0.9, 0, 0, 80); layout.CellPadding = UDim2.new(0, 0, 0, 10)

	local statsToBuild = {}
	for _, stat in ipairs(GameConfig.DisplayStats.Universal) do table.insert(statsToBuild, stat) end
	for _, stat in ipairs(GameConfig.DisplayStats[fac]) do table.insert(statsToBuild, stat) end

	for _, sName in ipairs(statsToBuild) do
		local row = Instance.new("Frame"); row.Size = UDim2.new(1, 0, 0, 40); row.BackgroundColor3 = Color3.fromRGB(45, 45, 45); row.BorderSizePixel = 0; row.Parent = sCont
		local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0.5, -15, 1, 0); lbl.Position = UDim2.new(0, 15, 0, 0); lbl.Text = sName .. ":"; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 20; lbl.TextColor3 = Color3.fromRGB(200, 200, 200); lbl.BackgroundTransparency = 1; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row
		local val = Instance.new("TextLabel"); val.Size = UDim2.new(0.5, -15, 1, 0); val.Position = UDim2.new(0.5, 0, 0, 0); val.Font = Enum.Font.Gotham; val.TextSize = 18; val.TextColor3 = Color3.fromRGB(255, 255, 255); val.BackgroundTransparency = 1; val.TextXAlignment = Enum.TextXAlignment.Right; val.Parent = row

		local statObj = playerData:FindFirstChild(sName)
		if statObj then 
			if sName == "EquippedQuinque" then
				lbl.Text = "Equipped Quinque:"
				local function decodeQuinque()
					local data = HttpService:JSONDecode(statObj.Value)
					if data.Name == "Unarmed" then
						val.Text = "Unarmed (Fists)"
						val.TextColor3 = Color3.fromRGB(150, 150, 150)
					else
						local isBroken = data.Broken
						local str = isBroken and math.floor(data.Str/2) or data.Str
						local spd = isBroken and math.floor(data.Spd/2) or data.Spd
						local bTxt = isBroken and " [BROKEN]" or ""
						local dTxt = data.Durability and (" | Dur: " .. data.Durability .. "/" .. data.MaxDurability) or ""

						val.Text = data.Name .. " [" .. data.Type .. " " .. data.Weapon .. "] (+ " .. str .. " Str, + " .. spd .. " Spd" .. dTxt .. ") <" .. data.Mutation .. ">" .. bTxt
						if isBroken then val.TextColor3 = Color3.fromRGB(255, 100, 100) else val.TextColor3 = Color3.fromRGB(255, 255, 255) end
					end
				end
				statObj.Changed:Connect(decodeQuinque); decodeQuinque()
			elseif sName == "CCGRankIndex" then
				lbl.Text = "CCG Rank:"
				local function updateRank() val.Text = GameConfig.CCGRanks[statObj.Value] or "Unknown" end
				statObj.Changed:Connect(updateRank); updateRank()
			elseif sName == "KaguneLevel" then
				local function updateLevel()
					local isKakuja = playerData:FindFirstChild("IsKakuja") and playerData.IsKakuja.Value or false
					val.Text = isKakuja and tostring(statObj.Value) .. " (KAKUJA)" or tostring(statObj.Value)
					if isKakuja then val.TextColor3 = Color3.fromRGB(255, 50, 50) else val.TextColor3 = Color3.fromRGB(255, 255, 255) end
				end
				statObj.Changed:Connect(updateLevel)
				if playerData:FindFirstChild("IsKakuja") then playerData.IsKakuja.Changed:Connect(updateLevel) end
				updateLevel()
			else val.Text = tostring(statObj.Value); statObj.Changed:Connect(function(newVal) val.Text = tostring(newVal) end) end
		end
	end

	if fac == "CCG" then
		for _, stat in ipairs(GameConfig.TrainingStats.CCG) do
			local btn = Instance.new("TextButton"); btn.Text = ""; btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60); btn.ClipsDescendants = true; btn.Parent = tCont

			local fill = Instance.new("Frame"); fill.Name = "Fill"; fill.Size = UDim2.new(0, 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(50, 200, 50); fill.BackgroundTransparency = 0.5; fill.BorderSizePixel = 0; fill.Parent = btn
			local txt = Instance.new("TextLabel"); txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 1; txt.Text = "Train " .. stat; txt.Font = Enum.Font.GothamBold; txt.TextSize = 22; txt.TextColor3 = Color3.fromRGB(255, 255, 255); txt.ZIndex = 2; txt.Parent = btn

			if CharacterTab.CurrentTraining == stat then
				btn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
				fill.Size = UDim2.new(0, 0, 1, 0)
				CharacterTab.ActiveTween = TweenService:Create(fill, TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false), {Size = UDim2.new(1, 0, 1, 0)})
				CharacterTab.ActiveTween:Play()
			end

			btn.MouseButton1Click:Connect(function()
				TrainingEvent:FireServer("ToggleTraining", stat)

				if CharacterTab.ActiveTween then 
					CharacterTab.ActiveTween:Cancel()
					CharacterTab.ActiveTween = nil 
				end

				for _, b in pairs(tCont:GetChildren()) do
					if b:IsA("TextButton") and b:FindFirstChild("Fill") then
						b.Fill.Size = UDim2.new(0,0,1,0)
						b.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
					end
				end

				if CharacterTab.CurrentTraining == stat then
					CharacterTab.CurrentTraining = nil
				else
					CharacterTab.CurrentTraining = stat
					btn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)

					fill.Size = UDim2.new(0, 0, 1, 0)
					CharacterTab.ActiveTween = TweenService:Create(fill, TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false), {Size = UDim2.new(1, 0, 1, 0)})
					CharacterTab.ActiveTween:Play()
				end
			end)
		end
		local promBtn = Instance.new("TextButton"); promBtn.Font = Enum.Font.GothamBlack; promBtn.TextSize = 18; promBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 20); promBtn.TextColor3 = Color3.fromRGB(255,255,255); promBtn.Parent = tCont
		local function updatePromBtn()
			local rank = playerData:FindFirstChild("CCGRankIndex") and playerData.CCGRankIndex.Value or 1
			local nextReqs = GameConfig.CCGPromotions[rank + 1]
			if nextReqs then promBtn.Text = "Request Promotion\n(" .. nextReqs.Rep .. " Rep | " .. nextReqs.Kills .. " Kills)"
			else promBtn.Text = "Special Class\n(Max Rank Achieved)"; promBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100) end
		end
		if playerData:FindFirstChild("CCGRankIndex") then playerData.CCGRankIndex.Changed:Connect(updatePromBtn); updatePromBtn() end
		promBtn.MouseButton1Click:Connect(function() TrainingEvent:FireServer("PromoteCCG") end)
	else
		for _, stat in ipairs(GameConfig.TrainingStats.GHOUL) do
			local btn = Instance.new("TextButton"); btn.Text = "Upgrade " .. stat .. "\n(" .. GameConfig.GhoulStatCost .. " RC)"; btn.Font = Enum.Font.GothamBold; btn.TextSize = 20; btn.BackgroundColor3 = Color3.fromRGB(80, 20, 20); btn.TextColor3 = Color3.fromRGB(255,255,255); btn.Parent = tCont
			btn.MouseButton1Click:Connect(function() TrainingEvent:FireServer("UpgradeStat", stat) end)
		end
		local lvlUpBtn = Instance.new("TextButton"); lvlUpBtn.Font = Enum.Font.GothamBlack; lvlUpBtn.TextSize = 20; lvlUpBtn.BackgroundColor3 = Color3.fromRGB(30, 150, 30); lvlUpBtn.TextColor3 = Color3.fromRGB(255,255,255); lvlUpBtn.Parent = tCont
		local function updateLvlBtn()
			local currentLvl = playerData:FindFirstChild("KaguneLevel") and playerData.KaguneLevel.Value or 1
			lvlUpBtn.Text = "Level Up Kagune\n(" .. (currentLvl * 50) .. " RC)"
		end
		playerData:WaitForChild("KaguneLevel").Changed:Connect(updateLvlBtn); updateLvlBtn()
		lvlUpBtn.MouseButton1Click:Connect(function() TrainingEvent:FireServer("LevelUpKagune") end)
		local kakujaBtn = Instance.new("TextButton"); kakujaBtn.Text = "Evolve Kakuja\n(Req: Kagune Lv.10)"; kakujaBtn.Font = Enum.Font.GothamBlack; kakujaBtn.TextSize = 18; kakujaBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0); kakujaBtn.TextColor3 = Color3.fromRGB(255,255,255); kakujaBtn.Parent = tCont
		kakujaBtn.MouseButton1Click:Connect(function() TrainingEvent:FireServer("EvolveKakuja") end)
	end
end
return CharacterTab