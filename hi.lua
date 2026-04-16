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
    HitboxSize = 12,
    Smoothness = 0.1,
    FOV = 200,
    ESP = false,
    Accent = Color3.fromRGB(0, 170, 255)
}

--// CLEANUP
if getgenv().DiamondHub_Loaded then
    pcall(function() gethui().DiamondHub_V10:Destroy() end)
end
getgenv().DiamondHub_Loaded = true

--// UI SETUP
local ScreenGui = Instance.new("ScreenGui", gethui() or LocalPlayer.PlayerGui)
ScreenGui.Name = "DiamondHub_V10"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 520, 0, 340)
Main.Position = UDim2.new(0.5, -260, 0.5, -170)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

--// TOP BAR (HEADER)
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Header.BorderSizePixel = 0
Header.ZIndex = 10 -- FORCED TO FRONT

local Title = Instance.new("TextLabel", Header)
Title.Text = "DIAMOND<font color='#00AAFF'>HUB</font> V10"
Title.RichText = true
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.new(1,1,1)
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.TextXAlignment = "Left"
Title.ZIndex = 11

--// CONTROLS (X and -)
local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -70, 0, 6)
MinBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.ZIndex = 12
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -35, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.ZIndex = 12
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

--// CATEGORIES SIDEBAR
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 120, 1, -50)
Sidebar.Position = UDim2.new(0, 10, 0, 45)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local SidebarList = Instance.new("UIListLayout", Sidebar)
SidebarList.Padding = UDim.new(0, 5)
SidebarList.HorizontalAlignment = "Center"
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 10)

--// CONTENT CONTAINER
local Pages = Instance.new("Frame", Main)
Pages.Size = UDim2.new(1, -150, 1, -50)
Pages.Position = UDim2.new(0, 140, 0, 45)
Pages.BackgroundTransparency = 1

local Tabs = {}
local function CreateTab(name, active)
    local TabFrame = Instance.new("Frame", Pages)
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = active
    Instance.new("UIListLayout", TabFrame).Padding = UDim.new(0, 10)

    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(0.9, 0, 0, 35)
    TabBtn.BackgroundColor3 = active and Color3.fromRGB(30,30,30) or Color3.fromRGB(22,22,22)
    TabBtn.Text = name
    TabBtn.TextColor3 = active and Color3.new(1,1,1) or Color3.fromRGB(150,150,150)
    TabBtn.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    TabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(Tabs) do v.Frame.Visible = false v.Btn.BackgroundColor3 = Color3.fromRGB(22,22,22) end
        TabFrame.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    end)
    Tabs[name] = {Frame = TabFrame, Btn = TabBtn}
    return TabFrame
end

local CombatTab = CreateTab("Combat", true)
local VisualsTab = CreateTab("Visuals", false)

--// TOGGLE HELPER
local function AddToggle(name, parent, configKey)
    local T = Instance.new("TextButton", parent)
    T.Size = UDim2.new(1, 0, 0, 35)
    T.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    T.Text = "   " .. name
    T.TextColor3 = Color3.fromRGB(200, 200, 200)
    T.Font = Enum.Font.Gotham
    T.TextXAlignment = "Left"
    Instance.new("UICorner", T).CornerRadius = UDim.new(0, 6)

    local Ind = Instance.new("Frame", T)
    Ind.Size = UDim2.new(0, 10, 0, 10)
    Ind.Position = UDim2.new(1, -25, 0.5, -5)
    Ind.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Instance.new("UICorner", Ind).CornerRadius = UDim.new(1, 0)

    T.MouseButton1Click:Connect(function()
        _G.DH_Config[configKey] = not _G.DH_Config[configKey]
        Ind.BackgroundColor3 = _G.DH_Config[configKey] and _G.DH_Config.Accent or Color3.fromRGB(50, 50, 50)
    end)
end

AddToggle("Aimbot (Mouse Lock)", CombatTab, "Aimbot")
AddToggle("Rage (Hitbox Expander)", CombatTab, "RageHitbox")
AddToggle("ESP Highlight", VisualsTab, "ESP")

--// WINDOW CONTROLS LOGIC
local Mini = false
MinBtn.MouseButton1Click:Connect(function()
    Mini = not Mini
    TweenService:Create(Main, TweenInfo.new(0.3), {Size = UDim2.new(0, 520, 0, Mini and 40 or 340)}):Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
    -- Create Confirmation Overlay
    local Conf = Instance.new("Frame", Main)
    Conf.Size = UDim2.new(1, 0, 1, 0)
    Conf.BackgroundColor3 = Color3.new(0,0,0)
    Conf.BackgroundTransparency = 0.5
    Conf.ZIndex = 50
    
    local Msg = Instance.new("TextLabel", Conf)
    Msg.Size = UDim2.new(0, 300, 0, 100)
    Msg.Position = UDim2.new(0.5, -150, 0.4, -50)
    Msg.Text = "Are you sure you want to close?"
    Msg.TextColor3 = Color3.new(1,1,1)
    Msg.Font = Enum.Font.GothamBold

    local Y = Instance.new("TextButton", Conf)
    Y.Size = UDim2.new(0, 100, 0, 30)
    Y.Position = UDim2.new(0.5, -110, 0.6, 0)
    Y.Text = "Yes"
    Y.MouseButton1Click:Connect(function() ScreenGui:Destroy() getgenv().DiamondHub_Loaded = false end)

    local N = Instance.new("TextButton", Conf)
    N.Size = UDim2.new(0, 100, 0, 30)
    N.Position = UDim2.new(0.5, 10, 0.6, 0)
    N.Text = "No"
    N.MouseButton1Click:Connect(function() Conf:Destroy() end)
end)

--// DRAG
local drag = false; local start; local pos
Header.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true; start = i.Position; pos = Main.Position end end)
UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
    local d = i.Position - start; Main.Position = UDim2.new(pos.X.Scale, pos.X.Offset + d.X, pos.Y.Scale, pos.Y.Offset + d.Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)

--// COMBAT ENGINE
RunService.RenderStepped:Connect(function()
    if not getgenv().DiamondHub_Loaded then return end

    if _G.DH_Config.Aimbot then
        local target = nil; local dist = _G.DH_Config.FOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local sPos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local mDist = (Vector2.new(sPos.X, sPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if mDist < dist then dist = mDist; target = p end
                end
            end
        end
        if target then
            -- Use mouse_event or Lerp for smoothness
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Character.Head.Position), _G.DH_Config.Smoothness)
        end
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            p.Character.Head.Size = _G.DH_Config.RageHitbox and Vector3.new(_G.DH_Config.HitboxSize, _G.DH_Config.HitboxSize, _G.DH_Config.HitboxSize) or Vector3.new(2,1,1)
            p.Character.Head.Transparency = _G.DH_Config.RageHitbox and 0.7 or 0
            
            local h = p.Character:FindFirstChild("DH_Highlight") or Instance.new("Highlight", p.Character)
            h.Name = "DH_Highlight"; h.Enabled = _G.DH_Config.ESP; h.FillTransparency = 0.5
        end
    end
end)
