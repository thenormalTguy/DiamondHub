local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GUI Setup
local gui = Instance.new("ScreenGui")
local ok = pcall(function() gui.Parent = gethui() end)
if not ok then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 140)
frame.Position = UDim2.new(0.5, -110, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 150)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "💎 DiamondHub"
title.TextScaled = true
title.Font = Enum.Font.GothamBold
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(0, 180, 0, 40)
toggleBtn.Position = UDim2.new(0.5, -90, 0, 45)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "Focus Nearest: OFF"
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, 0, 0, 25)
statusLabel.Position = UDim2.new(0, 0, 0, 100)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Text = "Idle"
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham

-- Logic Variables
local focusEnabled = false
local connection = nil

-- Improved Visibility Check (checks from Camera to Target Head)
local function isVisible(targetChar)
    if not targetChar then return false end
    local head = targetChar:FindFirstChild("Head")
    if not head then return false end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetChar}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
    -- Raycast from Camera to Target Head
    local direction = head.Position - Camera.CFrame.Position
    local result = workspace:Raycast(Camera.CFrame.Position, direction, raycastParams)

    return result == nil
end

local function getNearestVisible()
    local localChar = LocalPlayer.Character
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return nil end
    
    local nearest = nil
    local nearestDist = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
            if char.Humanoid.Health > 0 then
                local dist = (char.HumanoidRootPart.Position - localChar.HumanoidRootPart.Position).Magnitude
                if dist < nearestDist then
                    if isVisible(char) then
                        nearest = player
                        nearestDist = dist
                    end
                end
            end
        end
    end
    return nearest
end

toggleBtn.MouseButton1Click:Connect(function()
    focusEnabled = not focusEnabled
    
    if focusEnabled then
        toggleBtn.Text = "Focus Nearest: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
        
        connection = RunService.RenderStepped:Connect(function()
            -- Ensure Camera is indexed correctly in case of respawn
            Camera = workspace.CurrentCamera
            
            local target = getNearestVisible()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos = target.Character.HumanoidRootPart.Position
                statusLabel.Text = "Target: " .. target.Name
                
                -- Smoothly rotate camera without locking it to Scriptable
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
            else
                statusLabel.Text = "No visible target"
            end
        end)
    else
        toggleBtn.Text = "Focus Nearest: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        statusLabel.Text = "Idle"
        if connection then
            connection:Disconnect()
            connection = nil
        end
    end
end)
