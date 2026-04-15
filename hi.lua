local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui")
local ok = pcall(function() gui.Parent = gethui() end)
if not ok then gui.Parent = game:GetService("CoreGui") end
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 140)
frame.Position = UDim2.new(0.5, -110, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 120)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "💎 DiamondHub"
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.BorderSizePixel = 0
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(0, 180, 0, 40)
toggleBtn.Position = UDim2.new(0.5, -90, 0, 45)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "Focus Nearest: OFF"
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, 0, 0, 25)
statusLabel.Position = UDim2.new(0, 0, 0, 100)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.Text = "No target"
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham

-- Logic
local focusEnabled = false
local connection

local function isVisible(player)
    local char = player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local localChar = LocalPlayer.Character
    if not localChar then return false end
    local localHrp = localChar:FindFirstChild("HumanoidRootPart")
    if not localHrp then return false end

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {localChar, char}
    params.FilterType = Enum.RaycastFilterType.Exclude

    local origin = localHrp.Position
    local direction = hrp.Position - origin
    local result = workspace:Raycast(origin, direction, params)

    -- no wall hit = visible
    return result == nil
end

local function getNearestVisible()
    local localChar = LocalPlayer.Character
    if not localChar then return nil end
    local localHrp = localChar:FindFirstChild("HumanoidRootPart")
    if not localHrp then return nil end

    local nearest, nearestDist = nil, math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        local dist = (hrp.Position - localHrp.Position).Magnitude
        if dist < nearestDist and isVisible(player) then
            nearest = player
            nearestDist = dist
        end
    end
    return nearest
end

toggleBtn.MouseButton1Click:Connect(function()
    focusEnabled = not focusEnabled

    if focusEnabled then
        toggleBtn.Text = "Focus Nearest: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)

        connection = RunService.RenderStepped:Connect(function()
            local target = getNearestVisible()
            if target and target.Character then
                local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    statusLabel.Text = "Target: " .. target.Name
                    Camera.CameraType = Enum.CameraType.Scriptable
Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, hrp.Position)
                end
            else
                statusLabel.Text = "No visible target"
            end
        end)
    else
        toggleBtn.Text = "Focus Nearest: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        statusLabel.Text = "No target"
        if connection then connection:Disconnect() end
        Camera.CameraType = Enum.CameraType.Custom
    end
end)
