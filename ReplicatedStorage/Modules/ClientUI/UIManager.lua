-- @ScriptType: ModuleScript
local UIManager = { Tabs = {}, Frames = {}, ActiveTab = nil, Content = nil }
local TweenService = game:GetService("TweenService")

function UIManager.Init(playerGui)
	if playerGui:FindFirstChild("MainGameUI") then playerGui.MainGameUI:Destroy() end
	local screen = Instance.new("ScreenGui"); screen.Name = "MainGameUI"; screen.ResetOnSpawn = false; screen.IgnoreGuiInset = true; screen.Parent = playerGui
	local main = Instance.new("Frame"); main.Size = UDim2.new(1, 0, 1, 0); main.BackgroundColor3 = Color3.fromRGB(25, 25, 25); main.Parent = screen
	local tabMenu = Instance.new("Frame"); tabMenu.Size = UDim2.new(0.2, 0, 1, 0); tabMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 15); tabMenu.Parent = main

	local listLayout = Instance.new("UIListLayout", tabMenu); listLayout.Padding = UDim.new(0, 2); listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	local title = Instance.new("TextLabel"); title.Name = "GameTitleFiller"; title.Size = UDim2.new(1, 0, 0, 80); title.BackgroundTransparency = 1; title.Text = "TOKYO GHOUL"; title.Font = Enum.Font.GothamBlack; title.TextSize = 24; title.TextColor3 = Color3.fromRGB(200, 50, 50); title.LayoutOrder = -1; title.Parent = tabMenu

	UIManager.Content = Instance.new("Frame"); UIManager.Content.Size = UDim2.new(0.8, 0, 1, 0); UIManager.Content.Position = UDim2.new(0.2, 0, 0, 0); UIManager.Content.BackgroundColor3 = Color3.fromRGB(35, 35, 35); UIManager.Content.Parent = main
	return tabMenu
end

function UIManager.CreateTab(tabMenu, name, order)
	local btn = Instance.new("TextButton"); btn.Name = name .. "Tab"; btn.Size = UDim2.new(1, 0, 0, 60); btn.Text = name; btn.Font = Enum.Font.GothamBold; btn.TextSize = 20; btn.TextColor3 = Color3.fromRGB(200, 200, 200); btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); btn.LayoutOrder = order; btn.Parent = tabMenu
	local frame = Instance.new("Frame"); frame.Size = UDim2.new(1, 0, 1, 0); frame.BackgroundTransparency = 1; frame.Visible = false; frame.Parent = UIManager.Content
	local fTitle = Instance.new("TextLabel"); fTitle.Size = UDim2.new(1, 0, 0, 80); fTitle.Text = name .. " Menu"; fTitle.Font = Enum.Font.GothamBlack; fTitle.TextSize = 36; fTitle.TextColor3 = Color3.fromRGB(255, 255, 255); fTitle.BackgroundTransparency = 1; fTitle.Parent = frame
	UIManager.Tabs[name] = btn; UIManager.Frames[name] = frame
	btn.MouseButton1Click:Connect(function() UIManager.SwitchTab(name) end)
	return frame
end

function UIManager.SwitchTab(targetName, ShopEvent)
	for name, frame in pairs(UIManager.Frames) do
		local isActive = (name == targetName)
		frame.Visible = isActive
		UIManager.Tabs[name].BackgroundColor3 = isActive and Color3.fromRGB(70, 70, 70) or Color3.fromRGB(40, 40, 40)
		UIManager.Tabs[name].TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
	end
	if targetName == "Shop" and ShopEvent then ShopEvent:FireServer("GetShop") end
end

function UIManager.ShowNotification(message, color)
	local notif = Instance.new("TextLabel"); notif.Text = message; notif.Font = Enum.Font.GothamBlack; notif.TextSize = 26; notif.TextColor3 = color or Color3.fromRGB(255, 255, 255); notif.TextStrokeTransparency = 0; notif.Size = UDim2.new(0, 400, 0, 50); notif.Position = UDim2.new(0.5, -200, 0.1, 0); notif.BackgroundTransparency = 1; notif.ZIndex = 100; notif.Parent = UIManager.Content
	local tween = TweenService:Create(notif, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -200, 0.05, 0), TextTransparency = 1, TextStrokeTransparency = 1})
	tween:Play(); tween.Completed:Connect(function() notif:Destroy() end)
end

return UIManager