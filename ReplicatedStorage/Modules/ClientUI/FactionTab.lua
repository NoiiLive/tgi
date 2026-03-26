-- @ScriptType: ModuleScript
-- @ScriptType: ModuleScript
local FactionTab = {}
local SFXManager = require(game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("SFXManager"))

function FactionTab.Build(frame, FactionEvent)
	local cont = Instance.new("Frame"); cont.Size = UDim2.new(0.8, 0, 0.5, 0); cont.Position = UDim2.new(0.1, 0, 0.25, 0); cont.BackgroundTransparency = 1; cont.Parent = frame
	local ghoulBtn = Instance.new("TextButton"); ghoulBtn.Size = UDim2.new(0.45, 0, 1, 0); ghoulBtn.Text = "GHOUL"; ghoulBtn.Font = Enum.Font.GothamBlack; ghoulBtn.TextSize = 50; ghoulBtn.TextColor3 = Color3.fromRGB(255, 50, 50); ghoulBtn.BackgroundColor3 = Color3.fromRGB(20, 0, 0); ghoulBtn.Parent = cont
	local ccgBtn = Instance.new("TextButton"); ccgBtn.Size = UDim2.new(0.45, 0, 1, 0); ccgBtn.Position = UDim2.new(0.55, 0, 0, 0); ccgBtn.Text = "CCG"; ccgBtn.Font = Enum.Font.GothamBlack; ccgBtn.TextSize = 50; ccgBtn.TextColor3 = Color3.fromRGB(50, 150, 255); ccgBtn.BackgroundColor3 = Color3.fromRGB(0, 10, 30); ccgBtn.Parent = cont
	ghoulBtn.MouseButton1Click:Connect(function() SFXManager.Play("Click"); FactionEvent:FireServer("GHOUL") end)
	ccgBtn.MouseButton1Click:Connect(function() SFXManager.Play("Click"); FactionEvent:FireServer("CCG") end)
end
return FactionTab