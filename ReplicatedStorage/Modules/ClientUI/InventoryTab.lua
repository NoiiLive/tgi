-- @ScriptType: ModuleScript
local InventoryTab = {}
local SFXManager = require(game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("SFXManager"))

function InventoryTab.Refresh(frame, GameConfig, InventoryEvent, playerData, factionData, HttpService)
	local fac = factionData.Value; if fac == "Unchosen" then return end
	if frame:FindFirstChild("InvCont") then frame.InvCont:Destroy() end
	local iCont = Instance.new("ScrollingFrame"); iCont.Name = "InvCont"; iCont.Size = UDim2.new(0.9, 0, 0.8, 0); iCont.Position = UDim2.new(0.05, 0, 0.15, 0); iCont.BackgroundTransparency = 1; iCont.AutomaticCanvasSize = Enum.AutomaticSize.Y; iCont.CanvasSize = UDim2.new(0,0,0,0); iCont.ScrollBarThickness = 8; iCont.Parent = frame
	Instance.new("UIListLayout", iCont).Padding = UDim.new(0, 10)

	local fObj = playerData:FindFirstChild("Flesh")
	if fObj and fac == "GHOUL" then
		local row = Instance.new("Frame"); row.Size = UDim2.new(1, 0, 0, 60); row.BackgroundColor3 = Color3.fromRGB(30, 30, 30); row.BorderSizePixel = 0; row.Parent = iCont
		local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0.4, 0, 1, 0); lbl.Position = UDim2.new(0, 15, 0, 0); lbl.Text = "Flesh:"; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 24; lbl.TextColor3 = Color3.fromRGB(200, 200, 200); lbl.BackgroundTransparency = 1; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row
		local val = Instance.new("TextLabel"); val.Size = UDim2.new(0.2, 0, 1, 0); val.Position = UDim2.new(0.4, 0, 0, 0); val.Text = tostring(fObj.Value); val.Font = Enum.Font.Gotham; val.TextSize = 24; val.TextColor3 = Color3.fromRGB(255, 255, 255); val.BackgroundTransparency = 1; val.TextXAlignment = Enum.TextXAlignment.Left; val.Parent = row
		fObj.Changed:Connect(function(newVal) val.Text = tostring(newVal) end)

		local useBtn = Instance.new("TextButton"); useBtn.Size = UDim2.new(0.3, 0, 0.8, 0); useBtn.Position = UDim2.new(0.65, 0, 0.1, 0); useBtn.Text = "Consume (+30 Hunger)"; useBtn.Font = Enum.Font.GothamBold; useBtn.TextSize = 18; useBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50); useBtn.TextColor3 = Color3.fromRGB(255, 255, 255); useBtn.Parent = row
		useBtn.MouseButton1Click:Connect(function() SFXManager.Play("Click"); InventoryEvent:FireServer("ConsumeFlesh") end)
	end

	local invFolder = playerData:WaitForChild("Inventory")
	local function renderItems()
		for _, child in pairs(iCont:GetChildren()) do if child.Name == "DynamicItem" then child:Destroy() end end
		for _, item in ipairs(invFolder:GetChildren()) do
			local data = HttpService:JSONDecode(item.Value)
			local row = Instance.new("Frame"); row.Name = "DynamicItem"; row.Size = UDim2.new(1, 0, 0, 60); row.BackgroundColor3 = Color3.fromRGB(40, 20, 60); row.BorderSizePixel = 0; row.Parent = iCont
			local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0.55, 0, 1, 0); lbl.Position = UDim2.new(0, 15, 0, 0); lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 14; lbl.TextColor3 = Color3.fromRGB(200, 200, 255); lbl.BackgroundTransparency = 1; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row

			if data.ItemType == "Kakuhou" then
				lbl.Text = data.Name .. " (Material)"
				if fac == "CCG" then
					if data.Name == "Kakuja Kakuhou" then
						local arataBtn = Instance.new("TextButton"); arataBtn.Size = UDim2.new(0.3, 0, 0.8, 0); arataBtn.Position = UDim2.new(0.65, 0, 0.1, 0); arataBtn.Text = "Forge Arata Armor"; arataBtn.Font = Enum.Font.GothamBold; arataBtn.TextSize = 16; arataBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); arataBtn.TextColor3 = Color3.fromRGB(255, 255, 255); arataBtn.Parent = row
						arataBtn.MouseButton1Click:Connect(function() SFXManager.Play("Click"); InventoryEvent:FireServer("CraftArata", item.Name) end)
					else
						local craftBtn = Instance.new("TextButton"); craftBtn.Size = UDim2.new(0.18, 0, 0.8, 0); craftBtn.Position = UDim2.new(0.58, 0, 0.1, 0); craftBtn.Text = "Craft Quinque"; craftBtn.Font = Enum.Font.GothamBold; craftBtn.TextSize = 14; craftBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 30); craftBtn.TextColor3 = Color3.fromRGB(255, 255, 255); craftBtn.Parent = row
						craftBtn.MouseButton1Click:Connect(function() SFXManager.Play("Click"); InventoryEvent:FireServer("CraftQuinque", item.Name) end)

						local repairBtn = Instance.new("TextButton"); repairBtn.Size = UDim2.new(0.18, 0, 0.8, 0); repairBtn.Position = UDim2.new(0.78, 0, 0.1, 0); repairBtn.Text = "Repair Eqp."; repairBtn.Font = Enum.Font.GothamBold; repairBtn.TextSize = 14; repairBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50); repairBtn.TextColor3 = Color3.fromRGB(255, 255, 255); repairBtn.Parent = row
						repairBtn.MouseButton1Click:Connect(function() SFXManager.Play("Click"); InventoryEvent:FireServer("RepairQuinque", item.Name) end)
					end
				else
					local rollBtn = Instance.new("TextButton"); rollBtn.Size = UDim2.new(0.3, 0, 0.8, 0); rollBtn.Position = UDim2.new(0.65, 0, 0.1, 0); rollBtn.Text = "Roll Kagune (Resets Lvl)"; rollBtn.Font = Enum.Font.GothamBold; rollBtn.TextSize = 14; rollBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 30); rollBtn.TextColor3 = Color3.fromRGB(255, 255, 255); rollBtn.Parent = row
					rollBtn.MouseButton1Click:Connect(function() SFXManager.Play("Click"); InventoryEvent:FireServer("RollKagune", item.Name) end)
				end
			elseif data.ItemType == "Quinque" or data.ItemType == "Arata" then
				if data.ItemType == "Quinque" then 
					local isBroken = data.Broken
					local str = isBroken and math.floor(data.Str/2) or data.Str
					local spd = isBroken and math.floor(data.Spd/2) or data.Spd
					local bTxt = isBroken and " [BROKEN]" or ""
					local dTxt = data.Durability and (" | Dur: " .. data.Durability .. "/" .. data.MaxDurability) or ""
					lbl.Text = data.Name .. " [" .. data.Type .. " " .. data.Weapon .. "] (+ " .. str .. " Str, + " .. spd .. " Spd" .. dTxt .. ") <" .. data.Mutation .. ">" .. bTxt
					if isBroken then lbl.TextColor3 = Color3.fromRGB(255, 100, 100) end
				else lbl.Text = data.Name .. " (Passive: +" .. data.Def .. " Def | Active: +" .. data.Str .. " Str, +" .. data.Spd .. " Spd)" end

				local eqStat = (data.ItemType == "Quinque") and "EquippedQuinque" or "EquippedArata"
				local isEquipped = (playerData:FindFirstChild(eqStat) and playerData[eqStat].Value == item.Value)

				local equipBtn = Instance.new("TextButton"); equipBtn.Size = UDim2.new(0.18, 0, 0.8, 0); equipBtn.Position = UDim2.new(0.58, 0, 0.1, 0); equipBtn.Font = Enum.Font.GothamBold; equipBtn.TextSize = 16; equipBtn.Parent = row
				if isEquipped then equipBtn.Text = "EQUIPPED"; equipBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50); equipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				else equipBtn.Text = "Equip"; equipBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200); equipBtn.TextColor3 = Color3.fromRGB(255, 255, 255); equipBtn.MouseButton1Click:Connect(function() SFXManager.Play("Click"); InventoryEvent:FireServer("EquipItem", item.Name) end) end

				local retireBtn = Instance.new("TextButton"); retireBtn.Size = UDim2.new(0.18, 0, 0.8, 0); retireBtn.Position = UDim2.new(0.78, 0, 0.1, 0); retireBtn.Text = "Retire"; retireBtn.Font = Enum.Font.GothamBold; retireBtn.TextSize = 16; retireBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); retireBtn.TextColor3 = Color3.fromRGB(255, 255, 255); retireBtn.Parent = row
				retireBtn.MouseButton1Click:Connect(function() SFXManager.Play("Click"); InventoryEvent:FireServer("RetireItem", item.Name) end)
			end
		end
	end
	invFolder.ChildAdded:Connect(renderItems); invFolder.ChildRemoved:Connect(renderItems); renderItems()
	if playerData:FindFirstChild("EquippedQuinque") then playerData.EquippedQuinque.Changed:Connect(renderItems) end
	if playerData:FindFirstChild("EquippedArata") then playerData.EquippedArata.Changed:Connect(renderItems) end
end
return InventoryTab