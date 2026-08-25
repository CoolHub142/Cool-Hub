local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local pgui = LocalPlayer:WaitForChild("PlayerGui")

-- ----------------------------------------------------
-- 1. PERSISTENT DATA & AUTO EXECUTE QUEUE
-- ----------------------------------------------------
local fileName = "WizardHubSettings.json"
local defaultSettings = {
	AutoRecon = true,
	TropicalSeed = false,
	CosmicSpray = false,
	RainbowSpray = false,
	TimeSkip = false
}
local settings = defaultSettings

if readfile and isfile and isfile(fileName) then
	pcall(function()
		settings = HttpService:JSONDecode(readfile(fileName))
	end)
end

local function saveSettings()
	if writefile then
		pcall(function()
			writefile(fileName, HttpService:JSONEncode(settings))
		end)
	end
end

-- Teleport Queue for Auto-Executors
local queue_on_teleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
if queue_on_teleport then
	queue_on_teleport([[
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Adrianne571/Wizard-Hub/main/main.lua"))()
    ]])
end

-- Auto Reconnect Logic
GuiService.ErrorMessageChanged:Connect(function()
	if settings.AutoRecon then
		task.wait(1.5)
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	end
end)

-- ----------------------------------------------------
-- 2. REMOTES REFERENCE
-- ----------------------------------------------------
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes", 10)
local plantRush = remotesFolder and remotesFolder:WaitForChild("PlantRush", 10)
local buyShopRemote = plantRush and plantRush:WaitForChild("BuyShopItem", 10)

local towerRemote = remotesFolder and (remotesFolder:FindFirstChild("TowerStart") or ReplicatedStorage:FindFirstChild("TowerStart"))
local towerDeclineRemote = remotesFolder and (remotesFolder:FindFirstChild("TowerContinueDecline") or ReplicatedStorage:FindFirstChild("TowerContinueDecline"))
local incubatorRemote = remotesFolder and (remotesFolder:FindFirstChild("IncubatorClaim") or ReplicatedStorage:FindFirstChild("IncubatorClaim"))
local upgradeGenRemote = remotesFolder and (remotesFolder:FindFirstChild("UpgradeGenerator") or ReplicatedStorage:FindFirstChild("UpgradeGenerator"))
local buyGenRemote = remotesFolder and (remotesFolder:FindFirstChild("BuyGenerator") or ReplicatedStorage:FindFirstChild("BuyGenerator"))
local expandCoopRemote = remotesFolder and (remotesFolder:FindFirstChild("ExpandCoop") or ReplicatedStorage:FindFirstChild("ExpandCoop"))
local rebirthRemote = remotesFolder and (remotesFolder:FindFirstChild("Rebirth") or ReplicatedStorage:FindFirstChild("Rebirth"))
local upgradeRecyclerRemote = remotesFolder and (remotesFolder:FindFirstChild("UpgradeRecycler") or ReplicatedStorage:FindFirstChild("UpgradeRecycler"))

local function triggerRemote(remote, ...)
	if not remote then return end
	if remote:IsA("RemoteFunction") then
		pcall(function(...) remote:InvokeServer(...) end, ...)
	elseif remote:IsA("RemoteEvent") then
		pcall(function(...) remote:FireServer(...) end, ...)
	end
end

local function getPlayerLevel()
	local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
	local levelObj = leaderstats and (leaderstats:FindFirstChild("Level") or leaderstats:FindFirstChild("Lvl"))
	if not levelObj then
		levelObj = LocalPlayer:FindFirstChild("Level") or LocalPlayer:FindFirstChild("Lvl")
	end
	return levelObj and levelObj.Value or 0
end

-- ----------------------------------------------------
-- 3. MAIN GUI SETUP (WITH SCROLLING FRAME)
-- ----------------------------------------------------
local sg = Instance.new("ScreenGui")
sg.Name = "WizardHub_MasterUI"
sg.ResetOnSpawn = false
sg.Parent = pgui

local rainbowStrokes = {}

-- Open Button
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

Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 8)
local openStroke = Instance.new("UIStroke")
openStroke.Thickness = 2
openStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
openStroke.Parent = openBtn
table.insert(rainbowStrokes, openStroke)

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 360)
frame.Position = UDim2.new(0.5, -160, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
frame.ClipsDescendants = true
frame.Active = true
frame.Draggable = true
frame.Parent = sg

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
local frameStroke = Instance.new("UIStroke")
frameStroke.Thickness = 3
frameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
frameStroke.Parent = frame
table.insert(rainbowStrokes, frameStroke)

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundTransparency = 1
titleBar.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.Text = "Wizard Hub (Master Edition)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Window Buttons (- / X)
local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(0, 26, 0, 26)
hideBtn.Position = UDim2.new(1, -62, 0, 7)
hideBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
hideBtn.Text = "-"
hideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
hideBtn.Font = Enum.Font.SourceSansBold
hideBtn.TextSize = 16
hideBtn.Parent = titleBar
Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0, 4)

local destroyBtn = Instance.new("TextButton")
destroyBtn.Size = UDim2.new(0, 26, 0, 26)
destroyBtn.Position = UDim2.new(1, -32, 0, 7)
destroyBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
destroyBtn.Text = "X"
destroyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
destroyBtn.Font = Enum.Font.SourceSansBold
destroyBtn.TextSize = 14
destroyBtn.Parent = titleBar
Instance.new("UICorner", destroyBtn).CornerRadius = UDim.new(0, 4)

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

-- Scrollable Container
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -45)
scrollFrame.Position = UDim2.new(0, 5, 0, 40)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 5
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = scrollFrame
listLayout.Padding = UDim.new(0, 6)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 15)
end)

-- Slider Creator Component
local function createSliderRow(text, initialValue, callback)
	local rowFrame = Instance.new("Frame")
	rowFrame.Size = UDim2.new(0.95, 0, 0, 36)
	rowFrame.BackgroundTransparency = 1
	rowFrame.Parent = scrollFrame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.65, 0, 1, 0)
	label.Text = text
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.SourceSansBold
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = rowFrame

	local switchTrack = Instance.new("TextButton")
	switchTrack.Size = UDim2.new(0, 46, 0, 22)
	switchTrack.Position = UDim2.new(1, -46, 0.5, -11)
	switchTrack.BackgroundColor3 = initialValue and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(50, 50, 50)
	switchTrack.Text = ""
	switchTrack.AutoButtonColor = false
	switchTrack.Parent = rowFrame

	Instance.new("UICorner", switchTrack).CornerRadius = UDim.new(1, 0)
	local trackStroke = Instance.new("UIStroke")
	trackStroke.Thickness = 2
	trackStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	trackStroke.Parent = switchTrack
	table.insert(rainbowStrokes, trackStroke)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.Position = initialValue and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
	knob.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
	knob.Parent = switchTrack
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local state = initialValue
	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	switchTrack.MouseButton1Click:Connect(function()
		state = not state
		if state then
			TweenService:Create(switchTrack, tweenInfo, {BackgroundColor3 = Color3.fromRGB(46, 204, 113)}):Play()
			TweenService:Create(knob, tweenInfo, {Position = UDim2.new(1, -19, 0.5, -8)}):Play()
		else
			TweenService:Create(switchTrack, tweenInfo, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
			TweenService:Create(knob, tweenInfo, {Position = UDim2.new(0, 3, 0.5, -8)}):Play()
		end
		callback(state)
	end)

	if initialValue then
		callback(true)
	end
end

-- ----------------------------------------------------
-- 4. BOMB JUMP FLOATING BUTTON & ENGINE
-- ----------------------------------------------------
local BOMB_FORCE = 50
local VERTICAL_OFFSET = -3.2
local PREDICTION_TIME = 0.12

local bombBtn = Instance.new("TextButton")
bombBtn.Name = "BombJumpBtn"
bombBtn.Size = UDim2.new(0, 110, 0, 42)
bombBtn.Position = UDim2.new(0.8, 0, 0.65, 0)
bombBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
bombBtn.Text = "BOMB JUMP"
bombBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
bombBtn.Font = Enum.Font.SourceSansBold
bombBtn.TextSize = 13
bombBtn.Active = true
bombBtn.Draggable = true
bombBtn.Parent = sg

Instance.new("UICorner", bombBtn).CornerRadius = UDim.new(0, 8)
local bombStroke = Instance.new("UIStroke")
bombStroke.Thickness = 2
bombStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
bombStroke.Parent = bombBtn
table.insert(rainbowStrokes, bombStroke)

bombBtn.MouseButton1Click:Connect(function()
	local char = LocalPlayer.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChild("Humanoid")
	local fakeBomb = char:FindFirstChild("FakeBomb") or LocalPlayer.Backpack:FindFirstChild("FakeBomb")
	local remote = fakeBomb and fakeBomb:FindFirstChild("Remote")

	if hrp and remote and hum and hum.Health > 0 then
		local vel = hrp.Velocity
		local predictedPos = hrp.Position + (Vector3.new(vel.X, 0, vel.Z) * PREDICTION_TIME)
		local finalPos = predictedPos + Vector3.new(0, VERTICAL_OFFSET, 0)
		local upwardCFrame = CFrame.lookAt(finalPos, finalPos + Vector3.new(0, 1, 0))
		
		remote:FireServer(upwardCFrame, BOMB_FORCE)
	end
end)

-- ----------------------------------------------------
-- 5. TOGGLES & FEATURES REGISTRATION
-- ----------------------------------------------------

-- System Settings
createSliderRow("Auto Reconnect", settings.AutoRecon, function(isOn)
	settings.AutoRecon = isOn
	saveSettings()
end)

-- Wizard Hub Remotes Loops
local autoTower, autoIncubator, autoGen, autoRebirth, autoRecycler = false, false, false, false, false

createSliderRow("Auto Tower (2 Mins)", false, function(isOn)
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

createSliderRow("Auto Claim Incubator", false, function(isOn)
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

createSliderRow("Auto Generator & Coop", false, function(isOn)
	autoGen = isOn
	if autoGen then
		task.spawn(function()
			while autoGen do
				local currentLevel = getPlayerLevel()
				for id = 1, 6 do
					task.spawn(function() triggerRemote(buyGenRemote, id) end)
					task.spawn(function() triggerRemote(upgradeGenRemote, id) end)
				end
				if currentLevel >= 50 then
					for i = 1, 3 do
						task.spawn(function() triggerRemote(expandCoopRemote) end)
					end
				end
				task.wait(0.2)
			end
		end)
	end
end)

createSliderRow("Auto Rebirth", false, function(isOn)
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

createSliderRow("Auto Upgrade Recycler", false, function(isOn)
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

-- Item Spammer Toggles
local itemSpamMap = {
	{key = "TropicalSeed", name = "Spam Tropical Seed", arg = "TropicalSeedPack"},
	{key = "CosmicSpray", name = "Spam Cosmic Spray", arg = "CosmicSpray"},
	{key = "RainbowSpray", name = "Spam Rainbow Spray", arg = "RainbowSpray"},
	{key = "TimeSkip", name = "Spam Time Skip 5m", arg = "TimeSkip5m"}
}

for _, itemData in ipairs(itemSpamMap) do
	createSliderRow(itemData.name, settings[itemData.key], function(isOn)
		settings[itemData.key] = isOn
		saveSettings()
	end)
end

-- ----------------------------------------------------
-- 6. HEARTBEAT SPAMMER LOOP & RAINBOW ENGINE
-- ----------------------------------------------------
RunService.Heartbeat:Connect(function()
	if not buyShopRemote then return end
	
	for _, itemData in ipairs(itemSpamMap) do
		if settings[itemData.key] then
			task.spawn(function()
				pcall(function()
					buyShopRemote:InvokeServer(itemData.arg, 1)
				end)
			end)
		end
	end
end)

local hue = 0
RunService.RenderStepped:Connect(function()
	hue = (hue + 0.005) % 1
	local rainbowColor = Color3.fromHSV(hue, 1, 1)
	for _, stroke in ipairs(rainbowStrokes) do
		if stroke and stroke.Parent then
			stroke.Color = rainbowColor
		end
	end
end)
