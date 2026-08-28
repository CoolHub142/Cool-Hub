local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer

-- Remotes Reference with Fallback
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes", 10)
local towerRemote = remotesFolder and (remotesFolder:FindFirstChild("TowerStart") or ReplicatedStorage:FindFirstChild("TowerStart"))
local towerDeclineRemote = remotesFolder and (remotesFolder:FindFirstChild("TowerContinueDecline") or ReplicatedStorage:FindFirstChild("TowerContinueDecline"))
local incubatorRemote = remotesFolder and (remotesFolder:FindFirstChild("IncubatorClaim") or ReplicatedStorage:FindFirstChild("IncubatorClaim"))
local upgradeGenRemote = remotesFolder and (remotesFolder:FindFirstChild("UpgradeGenerator") or ReplicatedStorage:FindFirstChild("UpgradeGenerator"))
local buyGenRemote = remotesFolder and (remotesFolder:FindFirstChild("BuyGenerator") or ReplicatedStorage:FindFirstChild("BuyGenerator"))
local expandCoopRemote = remotesFolder and (remotesFolder:FindFirstChild("ExpandCoop") or ReplicatedStorage:FindFirstChild("ExpandCoop"))
local rebirthRemote = remotesFolder and (remotesFolder:FindFirstChild("Rebirth") or ReplicatedStorage:FindFirstChild("Rebirth"))
local upgradeRecyclerRemote = remotesFolder and (remotesFolder:FindFirstChild("UpgradeRecycler") or ReplicatedStorage:FindFirstChild("UpgradeRecycler"))

-- Trigger Function
local function triggerRemote(remote, ...)
	if not remote then return end
	if remote:IsA("RemoteFunction") then
		pcall(function(...) remote:InvokeServer(...) end, ...)
	elseif remote:IsA("RemoteEvent") then
		pcall(function(...) remote:FireServer(...) end, ...)
	end
end

-- Check Feeder Level (Generator 1 Level)
local function getFeederLevel()
	local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
	local feederObj = leaderstats and (leaderstats:FindFirstChild("FeederLevel") or leaderstats:FindFirstChild("GeneratorLevel") or leaderstats:FindFirstChild("Level"))
	if not feederObj then
		feederObj = LocalPlayer:FindFirstChild("FeederLevel") or LocalPlayer:FindFirstChild("Level")
	end
	return feederObj and feederObj.Value or 0
end

-- ScreenGui Setup
local sg = Instance.new("ScreenGui")
sg.Name = "WizardHub_RainbowUI"
sg.ResetOnSpawn = false
sg.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Standalone Open Button
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 75, 0, 32)
openBtn.Position = UDim2.new(0.02, 0, 0.15, 0)
openBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
openBtn.Text = "Open"
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.Font = Enum.Font.SourceSansBold
openBtn.TextSize = 14
openBtn.Active = true
openBtn.Draggable = true
openBtn.Visible = false
openBtn.Parent = sg

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 8)
openCorner.Parent = openBtn

local openStroke = Instance.new("UIStroke")
openStroke.Thickness = 2
openStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
openStroke.Parent = openBtn

-- Main Frame (Adjusted size for 6 options)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 320)
frame.Position = UDim2.new(0.5, -160, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
frame.ClipsDescendants = true
frame.Visible = true
frame.Parent = sg

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Thickness = 3
frameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
frameStroke.Parent = frame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundTransparency = 1
titleBar.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.Text = "Wizard Hub"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(0, 26, 0, 26)
hideBtn.Position = UDim2.new(1, -62, 0, 7)
hideBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
hideBtn.Text = "-"
hideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
hideBtn.Font = Enum.Font.SourceSansBold
hideBtn.TextSize = 16
hideBtn.Parent = titleBar

local hideCorner = Instance.new("UICorner")
hideCorner.CornerRadius = UDim.new(0, 4)
hideCorner.Parent = hideBtn

local destroyBtn = Instance.new("TextButton")
destroyBtn.Size = UDim2.new(0, 26, 0, 26)
destroyBtn.Position = UDim2.new(1, -32, 0, 7)
destroyBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
destroyBtn.Text = "X"
destroyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
destroyBtn.Font = Enum.Font.SourceSansBold
destroyBtn.TextSize = 14
destroyBtn.Parent = titleBar

local destroyCorner = Instance.new("UICorner")
destroyCorner.CornerRadius = UDim.new(0, 4)
destroyCorner.Parent = destroyBtn

hideBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
	openBtn.Visible = true
end)

openBtn.MouseButton1Click:Connect(function()
	frame.Visible = true
	openBtn.Visible = false
end)

destroyBtn.MouseButton1Click:Connect(function()
	sg:Destroy()
end)

-- Content Frame
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -40)
contentFrame.Position = UDim2.new(0, 0, 0, 40)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = frame

local autoTower = false
local autoIncubator = false
local autoGen = false
local autoRebirth = false
local autoRecycler = false
local autoReconExecute = false

local rainbowStrokes = {frameStroke, openStroke}

local function createSliderRow(text, posY, callback)
	local rowFrame = Instance.new("Frame")
	rowFrame.Size = UDim2.new(0.9, 0, 0, 36)
	rowFrame.Position = UDim2.new(0.05, 0, posY, 0)
	rowFrame.BackgroundTransparency = 1
	rowFrame.Parent = contentFrame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.65, 0, 1, 0)
	label.Text = text
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.SourceSansBold
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = rowFrame

	local switchTrack = Instance.new("TextButton")
	switchTrack.Size = UDim2.new(0, 50, 0, 24)
	switchTrack.Position = UDim2.new(1, -50, 0.5, -12)
	switchTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	switchTrack.Text = ""
	switchTrack.AutoButtonColor = false
	switchTrack.Parent = rowFrame

	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(1, 0)
	trackCorner.Parent = switchTrack

	local trackStroke = Instance.new("UIStroke")
	trackStroke.Thickness = 2
	trackStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	trackStroke.Parent = switchTrack
	table.insert(rainbowStrokes, trackStroke)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 18, 0, 18)
	knob.Position = UDim2.new(0, 3, 0.5, -9)
	knob.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
	knob.Parent = switchTrack

	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob

	local state = false
	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	switchTrack.MouseButton1Click:Connect(function()
		state = not state
		if state then
			TweenService:Create(switchTrack, tweenInfo, {BackgroundColor3 = Color3.fromRGB(46, 204, 113)}):Play()
			TweenService:Create(knob, tweenInfo, {Position = UDim2.new(1, -21, 0.5, -9)}):Play()
		else
			TweenService:Create(switchTrack, tweenInfo, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
			TweenService:Create(knob, tweenInfo, {Position = UDim2.new(0, 3, 0.5, -9)}):Play()
		end
		callback(state)
	end)
end

-- 1. Auto Tower (2 Mins)
createSliderRow("Auto Tower (2 Mins)", 0.02, function(isOn)
	autoTower = isOn
	if autoTower then
		task.spawn(function()
			while autoTower do
				triggerRemote(towerRemote)
				task.wait(0.2)
				triggerRemote(towerDeclineRemote)
				
				for i = 1, 120 do
					if not autoTower then break end
					task.wait(1)
				end
			end
		end)
	end
end)

-- 2. Auto Claim Incubator
createSliderRow("Auto Claim Incubator", 0.18, function(isOn)
	autoIncubator = isOn
	if autoIncubator then
		task.spawn(function()
			while autoIncubator do
				triggerRemote(incubatorRemote)
				task.wait(0.2)
			end
		end)
	end
end)

-- 3. Auto Feeder & Coop
createSliderRow("Auto Feeder & Coop", 0.34, function(isOn)
	autoGen = isOn
	if autoGen then
		task.spawn(function()
			while autoGen do
				local feederLevel = getFeederLevel()
				
				task.spawn(function() triggerRemote(buyGenRemote, 1) end)
				task.spawn(function() triggerRemote(upgradeGenRemote, 1) end)
				
				if feederLevel >= 50 then
					for i = 1, 3 do
						task.spawn(function() triggerRemote(expandCoopRemote) end)
					end
				end
				
				task.wait(0.2)
			end
		end)
	end
end)

-- 4. Auto Rebirth
createSliderRow("Auto Rebirth", 0.50, function(isOn)
	autoRebirth = isOn
	if autoRebirth then
		task.spawn(function()
			while autoRebirth do
				triggerRemote(rebirthRemote)
				task.wait(0.5)
			end
		end)
	end
end)

-- 5. Auto Upgrade Recycler
createSliderRow("Auto Upgrade Recycler", 0.66, function(isOn)
	autoRecycler = isOn
	if autoRecycler then
		task.spawn(function()
			while autoRecycler do
				triggerRemote(upgradeRecyclerRemote)
				task.wait(0.3)
			end
		end)
	end
end)

-- 6. Auto Recon / Execute (Nasa loob na ng Frame)
createSliderRow("Auto Recon & Execute", 0.82, function(isOn)
	autoReconExecute = isOn
	if autoReconExecute then
		local queue_on_teleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
		if queue_on_teleport then
			queue_on_teleport([[
                loadstring(game:HttpGet("https://raw.githubusercontent.com/Adrianne571/Wizard-Hub/refs/heads/main/main.lua"))()
            ]])
		end
	end
end)

-- Auto Reconnect Connection (Gagana lang kapag NAKA-ON ang Toggle #6)
GuiService.ErrorMessageChanged:Connect(function()
	if autoReconExecute then
		task.wait(2)
		TeleportService:Teleport(game.PlaceId, LocalPlayer)
	end
end)

-- Rainbow Loop
local hue = 0
RunService.RenderStepped:Connect(function()
	hue = (hue + 0.005) % 1
	local rainbowColor = Color3.fromHSV(hue, 1, 1)
	for _, stroke in ipairs(rainbowStrokes) do
		stroke.Color = rainbowColor
	end
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TowerContinueDecline")

while true do
    remote:FireServer()
    task.wait(1) -- Maghihintay ng 1 segundo bago mag-fire ulit (baguhin ang bilang ayon sa kailangan)
end
