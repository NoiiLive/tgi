-- @ScriptType: ModuleScript
local ShopTab = {}

function ShopTab.Build(frame, GameConfig, ShopEvent)
	local sCont = Instance.new("ScrollingFrame"); sCont.Name = "ShopCont"; sCont.Size = UDim2.new(0.9, 0, 0.8, 0); sCont.Position = UDim2.new(0.05, 0, 0.15, 0); sCont.BackgroundTransparency = 1; sCont.AutomaticCanvasSize = Enum.AutomaticSize.Y; sCont.CanvasSize = UDim2.new(0,0,0,0); sCont.ScrollBarThickness = 8; sCont.Parent = frame
	Instance.new("UIListLayout", sCont).Padding = UDim.new(0, 10)

	local infoLabel = Instance.new("TextLabel"); infoLabel.Size = UDim2.new(1, 0, 0, 40); infoLabel.Text = "Global Retired Equipment (Restocks Every 30 Mins)"; infoLabel.Font = Enum.Font.GothamBold; infoLabel.TextSize = 20; infoLabel.TextColor3 = Color3.fromRGB(200, 200, 255); infoLabel.BackgroundTransparency = 1; infoLabel.LayoutOrder = -1; infoLabel.Parent = sCont

	ShopEvent.OnClientEvent:Connect(function(action, shopData)
		if action == "UpdateShop" then ShopTab.UpdateItems(sCont, shopData, GameConfig, ShopEvent) end
	end)
end

function ShopTab.UpdateItems(sCont, shopData, GameConfig, ShopEvent)
	for _, child in pairs(sCont:GetChildren()) do if child.Name == "ShopItem" then child:Destroy() end end

	for index, data in ipairs(shopData) do
		local row = Instance.new("Frame"); row.Name = "ShopItem"; row.Size = UDim2.new(1, 0, 0, 80); row.BackgroundColor3 = Color3.fromRGB(40, 40, 20); row.BorderSizePixel = 0; row.Parent = sCont
		local creatorTxt = data.Creator and ("\n(Created by " .. data.Creator .. ")") or ""
		local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0.7, 0, 1, 0); lbl.Position = UDim2.new(0.02, 0, 0, 0); lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 16; lbl.TextColor3 = Color3.fromRGB(255, 200, 100); lbl.BackgroundTransparency = 1; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row

		if data.ItemType == "Quinque" then
			local isBroken = data.Broken
			local str = isBroken and math.floor(data.Str/2) or data.Str
			local spd = isBroken and math.floor(data.Spd/2) or data.Spd
			local bTxt = isBroken and " [BROKEN]" or ""
			local dTxt = data.Durability and (" | Dur: " .. data.Durability .. "/" .. data.MaxDurability) or ""
			lbl.Text = data.Name .. " [" .. data.Type .. " " .. data.Weapon .. "] (+ " .. str .. " Str, + " .. spd .. " Spd" .. dTxt .. ") <" .. data.Mutation .. ">" .. bTxt .. creatorTxt
			if isBroken then lbl.TextColor3 = Color3.fromRGB(255, 100, 100) end
		elseif data.ItemType == "Arata" then
			lbl.Text = data.Name .. " (Passive: +" .. data.Def .. " Def | Active: +" .. data.Str .. " Str, +" .. data.Spd .. " Spd)" .. creatorTxt
		end

		local isFree = (index == 1)
		local buyBtn = Instance.new("TextButton"); buyBtn.Size = UDim2.new(0.25, 0, 0.6, 0); buyBtn.Position = UDim2.new(0.72, 0, 0.2, 0); buyBtn.Text = isFree and "Claim (Free)" or "Buy (" .. GameConfig.QuinqueShopCost .. " Rep)"; buyBtn.Font = Enum.Font.GothamBold; buyBtn.TextSize = 16; buyBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50); buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255); buyBtn.Parent = row
		buyBtn.MouseButton1Click:Connect(function() ShopEvent:FireServer("BuyItem", index) end)
	end
end
return ShopTab