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
    Smoothness = 0.05, -- Lower = Faster/Snappier
    FOV = 250,
    ESP = false,
    TeamCheck = false,
    TargetPart = "Head",
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
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 10)

-- Glow Border
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = _G.DH_Config.Accent
Stroke.Thickness = 1.5
Stroke.Transparency = 0.5

--// HEADER
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Header.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Header)
Title.Text = "💎 DIAMOND<font color='#00AAFF'>HUB</font> <font color='#555'>V10</font>"
Title.RichText = true
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.new(1,1,1)
Title.Size = UDim2.new(0, 250, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.TextXAlignment = "Left"

--// WINDOW BUTTONS
local function CreateWinBtn(text, pos, color)
    local btn = Instance.new("TextButton", Header)
    btn.Size = UDim2.new(0, 30, 0, 30)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local CloseBtn = CreateWinBtn("X", UDim2.new(1, -40, 0, 7), Color3.fromRGB(255, 80, 80))
local MinBtn = CreateWinBtn("-", UDim2.new(1, -75, 0, 7), Color3.fromRGB(40, 40, 40))

--// SIDEBAR
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 130, 1, -60)
Sidebar.Position = UDim2.new(0, 10, 0, 55)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local SidebarList = Instance.new("UIListLayout", Sidebar)
SidebarList.Padding = UDim.new(0, 5)
SidebarList.HorizontalAlignment = "Center"
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 10)

--// PAGES CONTAINER
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
    local Layout = Instance.new("UIListLayout", TabFrame)
    Layout.Padding = UDim.new(0, 8)

    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(0.9, 0, 0, 38)
    TabBtn.BackgroundColor3 = active and Color3.fromRGB(30,30,30) or Color3.fromRGB(22,22,22)
    TabBtn.Text = icon .. " " .. name
    TabBtn.TextColor3 = active and Color3.new(1,1,1) or Color3.fromRGB(150,150,150)
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextSize = 13
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    TabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(Tabs) do 
            v.Frame.Visible = false 
            v.Btn.BackgroundColor3 = Color3.fromRGB(22,22,22) 
            v.Btn.TextColor3 = Color3.fromRGB(150,150,150)
        end
        TabFrame.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
        TabBtn.TextColor3 = _G.DH_Config.Accent
    end)
    Tabs[name] = {Frame = TabFrame, Btn = TabBtn}
    return TabFrame
end

local CombatTab = CreateTab("Combat", "⚔️", true)
local VisualsTab = CreateTab("Visuals", "👁️", false)
local ProfileTab = CreateTab("Profile", "👤", false)

--// TOGGLE CREATOR
local function AddToggle(name, parent, configKey)
    local T = Instance.new("TextButton", parent)
    T.Size = UDim2.new(1, -10, 0, 40)
    T.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    T.Text = "     " .. name
    T.TextColor3 = Color3.fromRGB(220, 220, 220)
    T.Font = Enum.Font.Gotham
    T.TextXAlignment = "Left"
    T.TextSize = 14
    Instance.new("UICorner", T).CornerRadius = UDim.new(0, 6)

    local Box = Instance.new("Frame", T)
    Box.Size = UDim2.new(0, 35, 0, 18)
    Box.Position = UDim2.new(1, -45, 0.5, -9)
    Box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Instance.new("UICorner", Box).CornerRadius = UDim.new(1, 0)

    local Dot = Instance.new("Frame", Box)
    Dot.Size = UDim2.new(0, 14, 0, 14)
    Dot.Position = _G.DH_Config[configKey] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    Dot.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

    T.MouseButton1Click:Connect(function()
        _G.DH_Config[configKey] = not _G.DH_Config[configKey]
        TweenService:Create(Box, TweenInfo.new(0.2), {BackgroundColor3 = _G.DH_Config[configKey] and _G.DH_Config.Accent or Color3.fromRGB(40, 40, 40)}):Play()
        TweenService:Create(Dot, TweenInfo.new(0.2), {Position = _G.DH_Config[configKey] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
    end)
end

AddToggle("Aimbot (Lock)", CombatTab, "Aimbot")
AddToggle("Hitbox Expander", CombatTab, "RageHitbox")
AddToggle("Team Check", CombatTab, "TeamCheck")
AddToggle("ESP Masters", VisualsTab, "ESP")

--// PROFILE TAB CONTENT
local function SetupProfile()
    local PAvatar = Instance.new("ImageLabel", ProfileTab)
    PAvatar.Size = UDim2.new(0, 80, 0, 80)
    PAvatar.BackgroundColor3 = Color3.fromRGB(30,30,30)
    PAvatar.Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150"
    Instance.new("UICorner", PAvatar).CornerRadius = UDim.new(1, 0)

    local function CreateInfo(text, parent)
        local l = Instance.new("TextLabel", parent)
        l.Size = UDim2.new(1, 0, 0, 25)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = Color3.new(0.8, 0.8, 0.8)
        l.Font = Enum.Font.GothamMedium
        l.TextSize = 14
        l.TextXAlignment = "Left"
    end

    CreateInfo("User: " .. LocalPlayer.Name, ProfileTab)
    CreateInfo("ID: " .. LocalPlayer.UserId, ProfileTab)
    CreateInfo("Account Age: " .. LocalPlayer.AccountAge .. " days", ProfileTab)
    CreateInfo("Executor: Supported", ProfileTab)
end
SetupProfile()

--// WINDOW LOGIC
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy(); getgenv().DiamondHub_Loaded = false end)
local Minimized = false
MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = Minimized and UDim2.new(0, 550, 0, 45) or UDim2.new(0, 550, 0, 380)}):Play()
end)

-- Dragging
local d, di, ds, sp
Header.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true; ds = i.Position; sp = Main.Position end end)
UserInputService.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then
    local delta = i.Position - ds; Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)

--// ENGINE: AIMBOT & ESP
local function GetTarget()
    local nearest = nil
    local lastDist = _G.DH_Config.FOV
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            if _G.DH_Config.TeamCheck and p.Team == LocalPlayer.Team then continue end
            
            local part = p.Character:FindFirstChild(_G.DH_Config.TargetPart)
            if part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if dist < lastDist then
                        lastDist = dist
                        nearest = part
                    end
                end
            end
        end
    end
    return nearest
end

RunService.RenderStepped:Connect(function()
    if not getgenv().DiamondHub_Loaded then return end
    
    -- High Performance Aimbot Lock
    if _G.DH_Config.Aimbot then
        local target = GetTarget()
        if target and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local targetPos = Camera:WorldToViewportPoint(target.Position)
            local mousePos = Vector2.new(Mouse.X, Mouse.Y)
            -- More aggressive forced camera movement
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end

    -- Visuals & Hitbox
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head then
                -- Hitbox
                if _G.DH_Config.RageHitbox then
                    head.Size = Vector3.new(_G.DH_Config.HitboxSize, _G.DH_Config.HitboxSize, _G.DH_Config.HitboxSize)
                    head.Transparency = 0.8
                    head.CanCollide = false
                else
                    head.Size = Vector3.new(1.2, 1.2, 1.2)
                    head.Transparency = 0
                end
                
                -- ESP
                local high = p.Character:FindFirstChild("DH_High")
                if _G.DH_Config.ESP then
                    if not high then
                        high = Instance.new("Highlight", p.Character)
                        high.Name = "DH_High"
                    end
                    high.Enabled = true
                    high.FillColor = _G.DH_Config.Accent
                elseif high then
                    high.Enabled = false
                end
            end
        end
    end
end)
