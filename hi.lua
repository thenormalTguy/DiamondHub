local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

--// SETTINGS
_G.DH_Config = {
    Aimbot = false,
    RageHitbox = false,
    HitboxSize = 15,
    Smoothness = 0.05,
    FOV = 250,
    ESP = false,
    TeamCheck = false,
    TargetPart = "Head",
    -- Movement
    Speed = false,
    WalkSpeedValue = 60,
    Fly = false,
    FlySpeed = 50,
    Noclip = false,
    Accent = Color3.fromRGB(0, 170, 255)
}

--// CLEANUP
if getgenv().DiamondHub_Loaded then
    local oldUI = gethui():FindFirstChild("DiamondHub_V10") or LocalPlayer.PlayerGui:FindFirstChild("DiamondHub_V10")
    if oldUI then oldUI:Destroy() end
end
getgenv().DiamondHub_Loaded = true

--// UI SETUP
local ScreenGui = Instance.new("ScreenGui", gethui() or LocalPlayer.PlayerGui)
ScreenGui.Name = "DiamondHub_V10"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 550, 0, 380)
Main.Position = UDim2.new(0.5, -275, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- Glow/Stroke
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = _G.DH_Config.Accent
MainStroke.Thickness = 1.2
MainStroke.Transparency = 0.4

--// CONFIRMATION DIALOG (Hidden by default)
local ConfirmFrame = Instance.new("Frame", Main)
ConfirmFrame.Size = UDim2.new(1, 0, 1, 0)
ConfirmFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ConfirmFrame.BackgroundTransparency = 0.2
ConfirmFrame.ZIndex = 100
ConfirmFrame.Visible = false

local ConfirmPop = Instance.new("Frame", ConfirmFrame)
ConfirmPop.Size = UDim2.new(0, 300, 0, 150)
ConfirmPop.Position = UDim2.new(0.5, -150, 0.5, -75)
ConfirmPop.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ConfirmPop.ZIndex = 101
Instance.new("UICorner", ConfirmPop).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", ConfirmPop).Color = Color3.fromRGB(40, 40, 40)

local ConfirmTitle = Instance.new("TextLabel", ConfirmPop)
ConfirmTitle.Text = "Are you sure?"
ConfirmTitle.Size = UDim2.new(1, 0, 0, 50)
ConfirmTitle.Font = Enum.Font.GothamBold
ConfirmTitle.TextColor3 = Color3.new(1, 1, 1)
ConfirmTitle.BackgroundTransparency = 1
ConfirmTitle.ZIndex = 102

local YesBtn = Instance.new("TextButton", ConfirmPop)
YesBtn.Size = UDim2.new(0, 100, 0, 35)
YesBtn.Position = UDim2.new(0.5, -110, 0.65, 0)
YesBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
YesBtn.Text = "Yes, Close"
YesBtn.Font = Enum.Font.GothamBold
YesBtn.TextColor3 = Color3.new(1, 1, 1)
YesBtn.ZIndex = 102
Instance.new("UICorner", YesBtn).CornerRadius = UDim.new(0, 6)

local NoBtn = Instance.new("TextButton", ConfirmPop)
NoBtn.Size = UDim2.new(0, 100, 0, 35)
NoBtn.Position = UDim2.new(0.5, 10, 0.65, 0)
NoBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
NoBtn.Text = "Cancel"
NoBtn.Font = Enum.Font.GothamBold
NoBtn.TextColor3 = Color3.new(1, 1, 1)
NoBtn.ZIndex = 102
Instance.new("UICorner", NoBtn).CornerRadius = UDim.new(0, 6)

--// HEADER
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(18, 18, 18)

local Title = Instance.new("TextLabel", Header)
Title.Text = "💎 DIAMOND<font color='#00AAFF'>HUB</font> <font color='#444'>V10</font>"
Title.RichText = true
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.new(1,1,1)
Title.Size = UDim2.new(0, 250, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.TextXAlignment = "Left"

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 7)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -75, 0, 7)
MinBtn.Text = "-"
MinBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

--// SIDEBAR
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 130, 1, -60)
Sidebar.Position = UDim2.new(0, 10, 0, 55)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local SidebarList = Instance.new("UIListLayout", Sidebar)
SidebarList.Padding = UDim.new(0, 5)
SidebarList.HorizontalAlignment = "Center"
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 10)

--// PAGES
local Pages = Instance.new("Frame", Main)
Pages.Size = UDim2.new(1, -160, 1, -65)
Pages.Position = UDim2.new(0, 150, 0, 55)
Pages.BackgroundTransparency = 1

local Tabs = {}
local function CreateTab(name, icon, active)
    local TabFrame = Instance.new("ScrollingFrame", Pages)
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = active
    TabFrame.ScrollBarThickness = 0
    Instance.new("UIListLayout", TabFrame).Padding = UDim.new(0, 8)

    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(0.9, 0, 0, 38)
    TabBtn.BackgroundColor3 = active and Color3.fromRGB(30,30,30) or Color3.fromRGB(22,22,22)
    TabBtn.Text = icon .. " " .. name
    TabBtn.TextColor3 = active and Color3.new(1,1,1) or Color3.fromRGB(150,150,150)
    TabBtn.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    TabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(Tabs) do v.Frame.Visible = false v.Btn.BackgroundColor3 = Color3.fromRGB(22,22,22) v.Btn.TextColor3 = Color3.fromRGB(150,150,150) end
        TabFrame.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
        TabBtn.TextColor3 = _G.DH_Config.Accent
    end)
    Tabs[name] = {Frame = TabFrame, Btn = TabBtn}
    return TabFrame
end

local CombatTab = CreateTab("Combat", "⚔️", true)
local VisualsTab = CreateTab("Visuals", "👁️", false)
local MoveTab = CreateTab("Movement", "⚡", false)
local ProfileTab = CreateTab("Profile", "👤", false)

--// TOGGLE HELPER
local function AddToggle(name, parent, configKey)
    local T = Instance.new("TextButton", parent)
    T.Size = UDim2.new(1, -10, 0, 40)
    T.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    T.Text = "     " .. name
    T.TextColor3 = Color3.fromRGB(220, 220, 220)
    T.Font = Enum.Font.Gotham
    T.TextXAlignment = "Left"
    Instance.new("UICorner", T).CornerRadius = UDim.new(0, 6)

    local Box = Instance.new("Frame", T)
    Box.Size = UDim2.new(0, 34, 0, 18)
    Box.Position = UDim2.new(1, -45, 0.5, -9)
    Box.BackgroundColor3 = _G.DH_Config[configKey] and _G.DH_Config.Accent or Color3.fromRGB(45, 45, 45)
    Instance.new("UICorner", Box).CornerRadius = UDim.new(1, 0)

    T.MouseButton1Click:Connect(function()
        _G.DH_Config[configKey] = not _G.DH_Config[configKey]
        TweenService:Create(Box, TweenInfo.new(0.2), {BackgroundColor3 = _G.DH_Config[configKey] and _G.DH_Config.Accent or Color3.fromRGB(45, 45, 45)}):Play()
    end)
end

AddToggle("Aimbot (Hold Right-Click)", CombatTab, "Aimbot")
AddToggle("Hitbox Expander", CombatTab, "RageHitbox")
AddToggle("ESP Highlights", VisualsTab, "ESP")
AddToggle("Speed (60)", MoveTab, "Speed")
AddToggle("Fly (C-Hold)", MoveTab, "Fly")
AddToggle("Noclip", MoveTab, "Noclip")

--// PROFILE CONTENT
local PAvatar = Instance.new("ImageLabel", ProfileTab)
PAvatar.Size = UDim2.new(0, 60, 0, 60)
PAvatar.Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150"
Instance.new("UICorner", PAvatar).CornerRadius = UDim.new(1, 0)
local PName = Instance.new("TextLabel", ProfileTab)
PName.Size = UDim2.new(1, 0, 0, 30)
PName.Text = "Welcome, " .. LocalPlayer.DisplayName
PName.TextColor3 = Color3.new(1,1,1)
PName.Font = Enum.Font.GothamBold
PName.BackgroundTransparency = 1
PName.TextXAlignment = "Left"

--// WINDOW LOGIC
CloseBtn.MouseButton1Click:Connect(function() ConfirmFrame.Visible = true end)
NoBtn.MouseButton1Click:Connect(function() ConfirmFrame.Visible = false end)
YesBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy(); getgenv().DiamondHub_Loaded = false end)

local Minimized = false
MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = Minimized and UDim2.new(0, 550, 0, 45) or UDim2.new(0, 550, 0, 380)}):Play()
end)

-- Dragging
local d, ds, sp
Header.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true; ds = i.Position; sp = Main.Position end end)
UserInputService.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then
    local delta = i.Position - ds; Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)

--// ENGINE
local function GetTarget()
    local nearest = nil; local lastDist = _G.DH_Config.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local part = p.Character:FindFirstChild(_G.DH_Config.TargetPart)
            if part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if dist < lastDist then lastDist = dist; nearest = part end
                end
            end
        end
    end
    return nearest
end

RunService.RenderStepped:Connect(function()
    if not getgenv().DiamondHub_Loaded then return end

    -- AIMBOT (Hard Lock)
    if _G.DH_Config.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetTarget()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end

    -- SPEED & FLY & NOCLIP
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        hum.WalkSpeed = _G.DH_Config.Speed and _G.DH_Config.WalkSpeedValue or 16
        
        if _G.DH_Config.Fly and root then
            root.Velocity = Vector3.new(0, 0.1, 0) -- Neutralize gravity
            if UserInputService:IsKeyDown(Enum.Font.W) then root.CFrame = root.CFrame * CFrame.new(0,0,-_G.DH_Config.FlySpeed/10) end
            if UserInputService:IsKeyDown(Enum.Font.S) then root.CFrame = root.CFrame * CFrame.new(0,0,_G.DH_Config.FlySpeed/10) end
        end
    end

    -- VISUALS & HITBOX LOOP
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head then
                head.Size = _G.DH_Config.RageHitbox and Vector3.new(_G.DH_Config.HitboxSize, _G.DH_Config.HitboxSize, _G.DH_Config.HitboxSize) or Vector3.new(1.2, 1.2, 1.2)
                head.Transparency = _G.DH_Config.RageHitbox and 0.8 or 0
                head.CanCollide = not _G.DH_Config.RageHitbox
                
                local high = p.Character:FindFirstChild("DH_High") or Instance.new("Highlight", p.Character)
                high.Name = "DH_High"; high.Enabled = _G.DH_Config.ESP; high.FillColor = _G.DH_Config.Accent
            end
        end
    end
end)

-- Separate loop for Noclip (Physics)
RunService.Stepped:Connect(function()
    if _G.DH_Config.Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)
