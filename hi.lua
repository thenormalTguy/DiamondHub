local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

--// CONFIGURATION
_G.DH_Config = {
    Aimbot = false,
    RageHitbox = false,
    HitboxSize = 15,
    Smoothness = 0.2,
    FOV = 250,
    ESP = false,
    Accent = Color3.fromRGB(0, 170, 255)
}

--// CLEANUP PREVIOUS
if getgenv().DiamondHub_Loaded then
    pcall(function() gethui().DiamondHub_V9:Destroy() end)
end
getgenv().DiamondHub_Loaded = true

--// MAIN UI
local ScreenGui = Instance.new("ScreenGui", gethui() or LocalPlayer.PlayerGui)
ScreenGui.Name = "DiamondHub_V9"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 520, 0, 340)
Main.Position = UDim2.new(0.5, -260, 0.5, -170)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

--// HEADER
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
Header.BorderSizePixel = 0
Header.ZIndex = 5
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", Header)
Title.Text = "DIAMOND<font color='#00AAFF'>HUB</font>"
Title.RichText = true
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextColor3 = Color3.new(1,1,1)
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.TextXAlignment = "Left"

--// WINDOW CONTROLS
local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -75, 0, 7)
MinBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MinBtn.Text = "-"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.TextSize = 16
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.TextSize = 14
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

--// SIDEBAR
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 130, 1, -55)
Sidebar.Position = UDim2.new(0, 10, 0, 50)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0, 5)
SideLayout.HorizontalAlignment = "Center"
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 10)

--// CONTENT CONTAINER
local ContentArea = Instance.new("Frame", Main)
ContentArea.Size = UDim2.new(1, -160, 1, -55)
ContentArea.Position = UDim2.new(0, 150, 0, 50)
ContentArea.BackgroundTransparency = 1

--// TABS LOGIC
local Tabs = {}
local TabBtns = {}

local function CreateTab(name, active)
    local Page = Instance.new("Frame", ContentArea)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = active
    
    local Layout = Instance.new("UIListLayout", Page)
    Layout.Padding = UDim.new(0, 10)

    local Btn = Instance.new("TextButton", Sidebar)
    Btn.Size = UDim2.new(0.9, 0, 0, 35)
    Btn.BackgroundColor3 = active and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(25, 25, 25)
    Btn.Text = name
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextColor3 = active and Color3.new(1,1,1) or Color3.fromRGB(150, 150, 150)
    Btn.TextSize = 13
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    Btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Tabs) do p.Visible = false end
        for _, b in pairs(TabBtns) do 
            b.TextColor3 = Color3.fromRGB(150, 150, 150)
            b.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        end
        Page.Visible = true
        Btn.TextColor3 = Color3.new(1,1,1)
        Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    end)

    Tabs[name] = Page
    TabBtns[name] = Btn
    return Page
end

--// CREATE PAGES
local ProfileTab = CreateTab("Profile", true)
local CombatTab = CreateTab("Combat", false)
local VisualTab = CreateTab("Visuals", false)

--// UI ELEMENTS HELPER
local function AddToggle(name, parent, configKey)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1, 0, 0, 38)
    Btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    Btn.Text = "   " .. name
    Btn.Font = Enum.Font.Gotham
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.TextSize = 13
    Btn.TextXAlignment = "Left"
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    local Indicator = Instance.new("Frame", Btn)
    Indicator.Size = UDim2.new(0, 12, 0, 12)
    Indicator.Position = UDim2.new(1, -25, 0.5, -6)
    Indicator.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

    Btn.MouseButton1Click:Connect(function()
        _G.DH_Config[configKey] = not _G.DH_Config[configKey]
        TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = _G.DH_Config[configKey] and _G.DH_Config.Accent or Color3.fromRGB(50, 50, 50)}):Play()
        Btn.TextColor3 = _G.DH_Config[configKey] and Color3.new(1,1,1) or Color3.fromRGB(200, 200, 200)
    end)
end

--// POPULATE TABS
-- Profile
local PFP = Instance.new("ImageLabel", ProfileTab)
PFP.Size = UDim2.new(0, 80, 0, 80)
PFP.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
PFP.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
Instance.new("UICorner", PFP).CornerRadius = UDim.new(1, 0)

local Welcome = Instance.new("TextLabel", ProfileTab)
Welcome.Size = UDim2.new(1, 0, 0, 40)
Welcome.BackgroundTransparency = 1
Welcome.Text = "Logged in as: <b>" .. LocalPlayer.DisplayName .. "</b>"
Welcome.RichText = true
Welcome.Font = Enum.Font.Gotham
Welcome.TextColor3 = Color3.new(1,1,1)
Welcome.TextSize = 14
Welcome.TextXAlignment = "Left"

-- Combat
AddToggle("Camera Lock (Aimbot)", CombatTab, "Aimbot")
AddToggle("Hitbox Expander (Ragebot)", CombatTab, "RageHitbox")

-- Visuals
AddToggle("Enable Master ESP", VisualTab, "ESP")

--// WINDOW LOGIC
local Dialog = Instance.new("Frame", Main)
Dialog.Size = UDim2.new(1, 0, 1, -45)
Dialog.Position = UDim2.new(0, 0, 0, 45)
Dialog.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Dialog.ZIndex = 10
Dialog.Visible = false

local DText = Instance.new("TextLabel", Dialog)
DText.Size = UDim2.new(1, 0, 0, 50)
DText.Position = UDim2.new(0, 0, 0.3, 0)
DText.BackgroundTransparency = 1
DText.Text = "Are you sure you want to close?"
DText.Font = Enum.Font.GothamBold
DText.TextColor3 = Color3.new(1,1,1)
DText.TextSize = 16
DText.ZIndex = 11

local YesBtn = Instance.new("TextButton", Dialog)
YesBtn.Size = UDim2.new(0, 100, 0, 35)
YesBtn.Position = UDim2.new(0.5, -110, 0.5, 0)
YesBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
YesBtn.Text = "Close Hub"
YesBtn.Font = Enum.Font.GothamBold
YesBtn.TextColor3 = Color3.new(1,1,1)
YesBtn.ZIndex = 11
Instance.new("UICorner", YesBtn).CornerRadius = UDim.new(0, 5)

local NoBtn = Instance.new("TextButton", Dialog)
NoBtn.Size = UDim2.new(0, 100, 0, 35)
NoBtn.Position = UDim2.new(0.5, 10, 0.5, 0)
NoBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
NoBtn.Text = "Cancel"
NoBtn.Font = Enum.Font.GothamBold
NoBtn.TextColor3 = Color3.new(1,1,1)
NoBtn.ZIndex = 11
Instance.new("UICorner", NoBtn).CornerRadius = UDim.new(0, 5)

local IsMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    Dialog.Visible = false
    TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 520, 0, IsMinimized and 45 or 340)}):Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
    if IsMinimized then
        IsMinimized = false
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 520, 0, 340)}):Play()
    end
    Dialog.Visible = true
end)

NoBtn.MouseButton1Click:Connect(function() Dialog.Visible = false end)
YesBtn.MouseButton1Click:Connect(function()
    getgenv().DiamondHub_Loaded = false
    ScreenGui:Destroy()
end)

--// DRAGGING (Restricted to Header)
local Dragging, DragStart, StartPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true; DragStart = input.Position; StartPos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - DragStart
        Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)

--// CORE LOGIC: AIMBOT, HITBOX RAGE, AND ESP
RunService.RenderStepped:Connect(function()
    if not getgenv().DiamondHub_Loaded then return end

    -- 1. Camera Aimbot
    if _G.DH_Config.Aimbot then
        local Target, Closest = nil, _G.DH_Config.FOV
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
                local Pos, OnScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
                if OnScreen then
                    local Dist = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if Dist < Closest then Closest = Dist; Target = v end
                end
            end
        end
        if Target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, Target.Character.Head.Position), _G.DH_Config.Smoothness)
        end
    end

    -- 2. ESP & Hitbox Expander (RAGE)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
            local Char = v.Character
            
            -- Hitbox Logic
            if _G.DH_Config.RageHitbox then
                Char.Head.Size = Vector3.new(_G.DH_Config.HitboxSize, _G.DH_Config.HitboxSize, _G.DH_Config.HitboxSize)
                Char.Head.Transparency = 0.8
                Char.Head.CanCollide = false
            else
                -- Revert back to normal if toggled off
                Char.Head.Size = Vector3.new(2, 1, 1) -- Standard Roblox head size
                Char.Head.Transparency = 0
            end

            -- ESP Logic
            local Box = Char:FindFirstChild("DH_Box") or Instance.new("Highlight", Char)
            Box.Name = "DH_Box"
            Box.OutlineColor = _G.DH_Config.Accent
            Box.Enabled = _G.DH_Config.ESP
        end
    end
end)
