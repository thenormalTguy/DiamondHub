local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// SETTINGS
local SMOOTHNESS = 0.15 -- Lower = Smoother/Slower, Higher = Snappier
local STICKY_TARGET = true -- Stays on one person until they hide/die

--// GUI SETUP
local gui = Instance.new("ScreenGui")
pcall(function() gui.Parent = gethui() or LocalPlayer:WaitForChild("PlayerGui") end)
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 170)
frame.Position = UDim2.new(0.5, -110, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "💎 DiamondHub V2"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 150)
Instance.new("UICorner", title)

local focusBtn = Instance.new("TextButton", frame)
focusBtn.Size = UDim2.new(0.9, 0, 0, 35)
focusBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
focusBtn.Text = "Aimbot: OFF"
focusBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
focusBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", focusBtn)

local espBtn = Instance.new("TextButton", frame)
espBtn.Size = UDim2.new(0.9, 0, 0, 35)
espBtn.Position = UDim2.new(0.05, 0, 0.5, 0)
espBtn.Text = "ESP: OFF"
espBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
espBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", espBtn)

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0.75, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Idle"
statusLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)

--// LOGIC VARIABLES
local focusEnabled = false
local espEnabled = false
local currentTarget = nil

--// ESP FUNCTION
local function createESP(player)
    if player == LocalPlayer then return end
    
    local function setupESP(char)
        if not char then return end
        
        -- Highlight (Box effect)
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.FillColor = Color3.new(1, 0, 0)
        highlight.Parent = char
        highlight.Enabled = espEnabled
        
        -- Billboard (Name tag)
        local bb = Instance.new("BillboardGui")
        bb.Name = "ESP_Name"
        bb.Size = UDim2.new(0, 100, 0, 50)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        bb.Parent = char
        bb.Enabled = espEnabled
        
        local label = Instance.new("TextLabel", bb)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextStrokeTransparency = 0
        label.Text = player.Name
        label.Font = Enum.Font.GothamBold
    end
    
    player.CharacterAdded:Connect(setupESP)
    if player.Character then setupESP(player.Character) end
end

--// VISIBILITY CHECK
local function isVisible(player)
    local char = player.Character
    if not char or not char:FindFirstChild("Head") then return false end
    
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, char}
    params.FilterType = Enum.RaycastFilterType.Exclude
    
    local origin = Camera.CFrame.Position
    local dest = char.Head.Position
    local result = workspace:Raycast(origin, dest - origin, params)
    
    return result == nil
end

--// TARGETING
local function getBestTarget()
    -- Stick to current target if they are still visible and alive
    if STICKY_TARGET and currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Humanoid") then
        if currentTarget.Character.Humanoid.Health > 0 and isVisible(currentTarget) then
            return currentTarget
        end
    end

    local nearest, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if p.Character.Humanoid.Health > 0 and isVisible(p) then
                local d = (p.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then
                    nearest = p
                    dist = d
                end
            end
        end
    end
    return nearest
end

--// CONNECTIONS
focusBtn.MouseButton1Click:Connect(function()
    focusEnabled = not focusEnabled
    focusBtn.Text = focusEnabled and "Aimbot: ON" or "Aimbot: OFF"
    focusBtn.BackgroundColor3 = focusEnabled and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(50, 50, 50)
    if not focusEnabled then currentTarget = nil end
end)

espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(50, 50, 50)
    
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            if p.Character:FindFirstChild("ESP_Highlight") then p.Character.ESP_Highlight.Enabled = espEnabled end
            if p.Character:FindFirstChild("ESP_Name") then p.Character.ESP_Name.Enabled = espEnabled end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if focusEnabled then
        currentTarget = getBestTarget()
        if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Head") then
            statusLabel.Text = "Locking: " .. currentTarget.Name
            
            -- Smooth camera movement using Lerp
            local targetPos = currentTarget.Character.Head.Position
            local lookAtCFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(lookAtCFrame, SMOOTHNESS)
        else
            statusLabel.Text = "Searching..."
        end
    end
end)

-- Initialize ESP for players
for _, p in pairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)
