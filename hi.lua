local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

--// CONFIG
_G.DH_Config = {
    Aimbot = false,
    RageHitbox = false,
    HitboxSize = 15,
    FOV = 250,
    ESP = false,
    -- Movement
    Speed = false,
    WalkSpeedValue = 60,
    Fly = false,
    FlySpeed = 50,
    Noclip = false,
    Accent = Color3.fromRGB(0, 170, 255)
}

--// GUI PARENTING
local function GetGui()
    if gethui then return gethui() end
    if game:GetService("CoreGui"):FindFirstChild("RobloxGui") then return game:GetService("CoreGui").RobloxGui end
    return LocalPlayer:WaitForChild("PlayerGui")
end

if getgenv().DiamondHub_Loaded then
    local old = GetGui():FindFirstChild("DiamondHub_V10")
    if old then old:Destroy() end
end
getgenv().DiamondHub_Loaded = true

--// MAIN UI DESIGN
local ScreenGui = Instance.new("ScreenGui", GetGui())
ScreenGui.Name = "DiamondHub_V10"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 580, 0, 400)
Main.Position = UDim2.new(0.5, -290, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = _G.DH_Config.Accent
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.4

--// SIDEBAR
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 150, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

local TabHolder = Instance.new("Frame", Sidebar)
TabHolder.Size = UDim2.new(1, 0, 1, -100)
TabHolder.Position = UDim2.new(0, 0, 0, 60)
TabHolder.BackgroundTransparency = 1
local TabList = Instance.new("UIListLayout", TabHolder)
TabList.Padding = UDim.new(0, 8)
TabList.HorizontalAlignment = "Center"

--// TOP HEADER
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, -150, 0, 50)
Header.Position = UDim2.new(0, 150, 0, 0)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "💎 DIAMOND<font color='#00AAFF'>HUB</font>"
Title.RichText = true
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextXAlignment = "Left"
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 10)
CloseBtn.Text = "✕"
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -75, 0, 10)
MinBtn.Text = "—"
MinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MinBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

--// CONTAINERS
local Pages = Instance.new("Frame", Main)
Pages.Size = UDim2.new(1, -170, 1, -70)
Pages.Position = UDim2.new(0, 160, 0, 60)
Pages.BackgroundTransparency = 1

local Tabs = {}
local function CreateTab(name, active)
    local Frame = Instance.new("ScrollingFrame", Pages)
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundTransparency = 1
    Frame.Visible = active
    Frame.ScrollBarThickness = 0
    Instance.new("UIListLayout", Frame).Padding = UDim.new(0, 10)

    local Btn = Instance.new("TextButton", TabHolder)
    Btn.Size = UDim2.new(0.85, 0, 0, 40)
    Btn.BackgroundColor3 = active and _G.DH_Config.Accent or Color3.fromRGB(25, 25, 25)
    Btn.Text = name
    Btn.TextColor3 = active and Color3.new(1,1,1) or Color3.fromRGB(150,150,150)
    Btn.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

    Btn.MouseButton1Click:Connect(function()
        for _, v in pairs(Tabs) do 
            v.F.Visible = false 
            v.B.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            v.B.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
        Frame.Visible = true
        Btn.BackgroundColor3 = _G.DH_Config.Accent
        Btn.TextColor3 = Color3.new(1,1,1)
    end)
    Tabs[name] = {F = Frame, B = Btn}
    return Frame
end

local CombatTab = CreateTab("Combat", true)
local VisualsTab = CreateTab("Visuals", false)
local MoveTab = CreateTab("Movement", false)
local ProfileTab = CreateTab("Profile", false)

--// TOGGLE SYSTEM
local function AddToggle(name, parent, key)
    local T = Instance.new("TextButton", parent)
    T.Size = UDim2.new(1, 0, 0, 45)
    T.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    T.Text = "     " .. name
    T.TextColor3 = Color3.fromRGB(200, 200, 200)
    T.Font = Enum.Font.GothamMedium
    T.TextXAlignment = "Left"
    Instance.new("UICorner", T).CornerRadius = UDim.new(0, 8)

    local Box = Instance.new("Frame", T)
    Box.Size = UDim2.new(0, 36, 0, 18)
    Box.Position = UDim2.new(1, -45, 0.5, -9)
    Box.BackgroundColor3 = _G.DH_Config[key] and _G.DH_Config.Accent or Color3.fromRGB(40, 40, 40)
    Instance.new("UICorner", Box).CornerRadius = UDim.new(1, 0)

    T.MouseButton1Click:Connect(function()
        _G.DH_Config[key] = not _G.DH_Config[key]
        TweenService:Create(Box, TweenInfo.new(0.2), {BackgroundColor3 = _G.DH_Config[key] and _G.DH_Config.Accent or Color3.fromRGB(40, 40, 40)}):Play()
    end)
end

AddToggle("Aimbot (Hard Lock)", CombatTab, "Aimbot")
AddToggle("Hitbox Expander", CombatTab, "RageHitbox")
AddToggle("ESP Highlights", VisualsTab, "ESP")
AddToggle("Speed Bypass", MoveTab, "Speed")
AddToggle("Fly Hack (WASD)", MoveTab, "Fly")
AddToggle("Noclip", MoveTab, "Noclip")

--// PROFILE LOGIC (FIXED)
local function SetupProfile()
    local Layout = Instance.new("UIListLayout", ProfileTab)
    Layout.Padding = UDim.new(0, 15)
    Layout.HorizontalAlignment = "Center"

    local ProfileImage = Instance.new("ImageLabel", ProfileTab)
    ProfileImage.Size = UDim2.new(0, 100, 0, 100)
    ProfileImage.Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150"
    ProfileImage.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", ProfileImage).CornerRadius = UDim.new(1, 0)

    local function Info(txt)
        local l = Instance.new("TextLabel", ProfileTab)
        l.Size = UDim2.new(1, 0, 0, 30)
        l.Text = txt
        l.TextColor3 = Color3.new(1,1,1)
        l.Font = Enum.Font.GothamBold
        l.TextSize = 16
        l.BackgroundTransparency = 1
    end

    Info("User: " .. LocalPlayer.Name)
    Info("ID: " .. LocalPlayer.UserId)
    Info("Account Age: " .. LocalPlayer.AccountAge .. " Days")
end
SetupProfile()

--// CONFIRMATION POPUP
local ConfirmOverlay = Instance.new("Frame", Main)
ConfirmOverlay.Size = UDim2.new(1, 0, 1, 0)
ConfirmOverlay.BackgroundColor3 = Color3.new(0,0,0)
ConfirmOverlay.BackgroundTransparency = 1
ConfirmOverlay.Visible = false
ConfirmOverlay.ZIndex = 500

local ConfirmBox = Instance.new("Frame", ConfirmOverlay)
ConfirmBox.Size = UDim2.new(0, 260, 0, 130)
ConfirmBox.Position = UDim2.new(0.5, -130, 0.5, -65)
ConfirmBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", ConfirmBox).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", ConfirmBox).Color = Color3.fromRGB(60, 60, 60)

local Prompt = Instance.new("TextLabel", ConfirmBox)
Prompt.Size = UDim2.new(1, 0, 0.5, 0)
Prompt.Text = "Confirm Exit?"
Prompt.TextColor3 = Color3.new(1,1,1)
Prompt.Font = Enum.Font.GothamBold
Prompt.BackgroundTransparency = 1

local Yes = Instance.new("TextButton", ConfirmBox)
Yes.Size = UDim2.new(0, 100, 0, 35)
Yes.Position = UDim2.new(0.1, 0, 0.6, 0)
Yes.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
Yes.Text = "Yes"
Yes.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", Yes).CornerRadius = UDim.new(0, 6)

local No = Instance.new("TextButton", ConfirmBox)
No.Size = UDim2.new(0, 100, 0, 35)
No.Position = UDim2.new(0.55, 0, 0.6, 0)
No.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
No.Text = "No"
No.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", No).CornerRadius = UDim.new(0, 6)

--// WINDOW HANDLERS
CloseBtn.MouseButton1Click:Connect(function() ConfirmOverlay.Visible = true end)
No.MouseButton1Click:Connect(function() ConfirmOverlay.Visible = false end)
Yes.MouseButton1Click:Connect(function() ScreenGui:Destroy(); getgenv().DiamondHub_Loaded = false end)

local Mini = false
MinBtn.MouseButton1Click:Connect(function()
    Mini = not Mini
    TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = Mini and UDim2.new(0, 580, 0, 50) or UDim2.new(0, 580, 0, 400)}):Play()
end)

-- Draggable
local d, ds, sp
Header.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true; ds = i.Position; sp = Main.Position end end)
UserInputService.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then
    local delta = i.Position - ds; Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)

--// ENGINES
local function GetNearest()
    local nearest = nil; local dist = _G.DH_Config.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if mag < dist then dist = mag; nearest = p.Character.Head end
            end
        end
    end
    return nearest
end

RunService.RenderStepped:Connect(function()
    if not getgenv().DiamondHub_Loaded then return end

    -- Aimbot (Hard)
    if _G.DH_Config.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = GetNearest()
        if t then Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position) end
    end

    -- Character Engine
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        local hum = LocalPlayer.Character.Humanoid
        hum.WalkSpeed = _G.DH_Config.Speed and _G.DH_Config.WalkSpeedValue or 16

        if _G.DH_Config.Fly then
            root.Velocity = Vector3.new(0, 2, 0)
            local move = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
            root.CFrame = root.CFrame + (move * (_G.DH_Config.FlySpeed/15))
        end
    end

    -- Visuals
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head then
                head.Size = _G.DH_Config.RageHitbox and Vector3.new(_G.DH_Config.HitboxSize, _G.DH_Config.HitboxSize, _G.DH_Config.HitboxSize) or Vector3.new(1.2, 1.2, 1.2)
                head.Transparency = _G.DH_Config.RageHitbox and 0.8 or 0
                head.CanCollide = not _G.DH_Config.RageHitbox
                
                local h = p.Character:FindFirstChild("DH_High") or Instance.new("Highlight", p.Character)
                h.Name = "DH_High"; h.Enabled = _G.DH_Config.ESP; h.FillColor = _G.DH_Config.Accent
            end
        end
    end
end)

RunService.Stepped:Connect(function()
    if _G.DH_Config.Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)
