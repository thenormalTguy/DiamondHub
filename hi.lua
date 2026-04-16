local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// CONFIG
_G.DH_Config = {
    Aimbot = false,
    Rage = false,
    Smoothness = 0.15,
    FOV = 200,
    TeamCheck = true,
    TargetPart = "Head",
    ESP = false,
    Accent = Color3.fromRGB(0, 170, 255)
}

--// CLEANUP PREVIOUS
if getgenv().DiamondHub_Loaded then
    pcall(function() gethui().DiamondHub_V8:Destroy() end)
    RunService:UnbindFromRenderStep("DiamondHub_Combat")
end
getgenv().DiamondHub_Loaded = true

--// UI CONSTRUCT
local ScreenGui = Instance.new("ScreenGui", gethui() or LocalPlayer.PlayerGui)
ScreenGui.Name = "DiamondHub_V8"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 500, 0, 320)
Main.Position = UDim2.new(0.5, -250, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true -- CRITICAL FOR MINIMIZING
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

--// HEADER
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Header.BorderSizePixel = 0
Header.ZIndex = 5
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", Header)
Title.Text = "DIAMOND<font color='#00AAFF'>HUB</font>"
Title.RichText = true
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.new(1,1,1)
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.TextXAlignment = "Left"
Title.ZIndex = 5

--// WINDOW CONTROLS (X and -)
local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MinBtn.Text = "-"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.TextSize = 16
MinBtn.ZIndex = 6
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.TextSize = 14
CloseBtn.ZIndex = 6
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

--// SIDEBAR & CONTAINER
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 120, 1, -50)
Sidebar.Position = UDim2.new(0, 10, 0, 45)
Sidebar.BackgroundTransparency = 1

local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, -150, 1, -50)
Container.Position = UDim2.new(0, 140, 0, 45)
Container.BackgroundTransparency = 1

local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0, 10)

--// CLOSE DIALOG OVERLAY
local Dialog = Instance.new("Frame", Main)
Dialog.Size = UDim2.new(1, 0, 1, -40)
Dialog.Position = UDim2.new(0, 0, 0, 40)
Dialog.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Dialog.ZIndex = 10
Dialog.Visible = false

local DialogText = Instance.new("TextLabel", Dialog)
DialogText.Size = UDim2.new(1, 0, 0, 50)
DialogText.Position = UDim2.new(0, 0, 0.3, 0)
DialogText.BackgroundTransparency = 1
DialogText.Text = "Are you sure you want to close DiamondHub?"
DialogText.Font = Enum.Font.GothamSemibold
DialogText.TextColor3 = Color3.new(1,1,1)
DialogText.TextSize = 16
DialogText.ZIndex = 11

local YesBtn = Instance.new("TextButton", Dialog)
YesBtn.Size = UDim2.new(0, 100, 0, 35)
YesBtn.Position = UDim2.new(0.5, -110, 0.6, 0)
YesBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
YesBtn.Text = "Yes, Close"
YesBtn.Font = Enum.Font.GothamBold
YesBtn.TextColor3 = Color3.new(1,1,1)
YesBtn.TextSize = 13
YesBtn.ZIndex = 11
Instance.new("UICorner", YesBtn).CornerRadius = UDim.new(0, 6)

local NoBtn = Instance.new("TextButton", Dialog)
NoBtn.Size = UDim2.new(0, 100, 0, 35)
NoBtn.Position = UDim2.new(0.5, 10, 0.6, 0)
NoBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
NoBtn.Text = "Cancel"
NoBtn.Font = Enum.Font.GothamBold
NoBtn.TextColor3 = Color3.new(1,1,1)
NoBtn.TextSize = 13
NoBtn.ZIndex = 11
Instance.new("UICorner", NoBtn).CornerRadius = UDim.new(0, 6)

--// WINDOW LOGIC (MINIMIZE / CLOSE)
local IsMinimized = false

MinBtn.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    if IsMinimized then
        Dialog.Visible = false
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 500, 0, 40)}):Play()
    else
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 500, 0, 320)}):Play()
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    if IsMinimized then
        -- Un-minimize first to show the dialog
        IsMinimized = false
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 500, 0, 320)}):Play()
    end
    Dialog.Visible = true
end)

NoBtn.MouseButton1Click:Connect(function()
    Dialog.Visible = false
end)

YesBtn.MouseButton1Click:Connect(function()
    -- Fully unload script
    RunService:UnbindFromRenderStep("DiamondHub_Combat")
    for _, v in pairs(Players:GetPlayers()) do
        if v.Character then
            if v.Character:FindFirstChild("DH_Box") then v.Character.DH_Box:Destroy() end
            if v.Character:FindFirstChild("DH_Tag") then v.Character.DH_Tag:Destroy() end
        end
    end
    getgenv().DiamondHub_Loaded = false
    ScreenGui:Destroy()
end)

--// UI HELPERS
local function CreateToggle(name, configKey)
    local Btn = Instance.new("TextButton", Container)
    Btn.Size = UDim2.new(0.95, 0, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Btn.Text = "  " .. name
    Btn.Font = Enum.Font.Gotham
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.TextSize = 13
    Btn.TextXAlignment = "Left"
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    local Indicator = Instance.new("Frame", Btn)
    Indicator.Size = UDim2.new(0, 10, 0, 10)
    Indicator.Position = UDim2.new(1, -20, 0.5, -5)
    Indicator.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

    Btn.MouseButton1Click:Connect(function()
        _G.DH_Config[configKey] = not _G.DH_Config[configKey]
        Indicator.BackgroundColor3 = _G.DH_Config[configKey] and _G.DH_Config.Accent or Color3.fromRGB(50, 50, 50)
        Btn.TextColor3 = _G.DH_Config[configKey] and Color3.new(1,1,1) or Color3.fromRGB(200, 200, 200)
    end)
end

--// ADDING CONTROLS
CreateToggle("Legit Aimbot", "Aimbot")
CreateToggle("Ragebot (Auto-Kill)", "Rage")
CreateToggle("Team Check", "TeamCheck")
CreateToggle("Master ESP", "ESP")

--// COMBAT LOGIC
local function GetClosestPlayer()
    local Target, Closest = nil, _G.DH_Config.FOV
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
            if _G.DH_Config.TeamCheck and v.Team == LocalPlayer.Team then continue end
            if v.Character.Humanoid.Health <= 0 then continue end
            
            local Pos, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(v.Character.Head.Position)
            if OnScreen then
                local Dist = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if Dist < Closest then
                    Closest = Dist
                    Target = v
                end
            end
        end
    end
    return Target
end

RunService:BindToRenderStep("DiamondHub_Combat", Enum.RenderPriority.Camera.Value + 1, function()
    if _G.DH_Config.Aimbot or _G.DH_Config.Rage then
        local Target = GetClosestPlayer()
        if Target and Target.Character and Target.Character:FindFirstChild("Head") then
            local Camera = workspace.CurrentCamera
            local Goal = CFrame.lookAt(Camera.CFrame.Position, Target.Character.Head.Position)
            
            if _G.DH_Config.Rage then
                Camera.CFrame = Goal
            else
                Camera.CFrame = Camera.CFrame:Lerp(Goal, _G.DH_Config.Smoothness)
            end
        end
    end
end)

--// ESP LOGIC
RunService.RenderStepped:Connect(function()
    if not getgenv().DiamondHub_Loaded then return end
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            local Char = v.Character
            local Box = Char:FindFirstChild("DH_Box") or Instance.new("Highlight", Char)
            Box.Name = "DH_Box"
            Box.OutlineColor = _G.DH_Config.Accent
            Box.Enabled = _G.DH_Config.ESP
            
            local Tag = Char:FindFirstChild("DH_Tag") or Instance.new("BillboardGui", Char)
            Tag.Name = "DH_Tag"
            Tag.Size = UDim2.new(0, 100, 0, 50)
            Tag.AlwaysOnTop = true
            Tag.StudsOffset = Vector3.new(0, 3, 0)
            
            local Label = Tag:FindFirstChild("L") or Instance.new("TextLabel", Tag)
            Label.Name = "L"
            Label.BackgroundTransparency = 1
            Label.Size = UDim2.new(1, 0, 1, 0)
            Label.Text = v.DisplayName
            Label.Font = Enum.Font.GothamBold
            Label.TextColor3 = Color3.new(1,1,1)
            Label.TextSize = 11
            Tag.Enabled = _G.DH_Config.ESP
        end
    end
end)

--// DRAGGING (Restricted to Header so you can still drag while minimized)
local Dragging, DragInput, DragStart, StartPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true; DragStart = input.Position; StartPos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local Delta = input.Position - DragStart
        Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
end)
