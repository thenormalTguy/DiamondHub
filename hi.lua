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
    Smoothness = 0.1,
    FOV = 200,
    ESP = false,
    Accent = Color3.fromRGB(0, 170, 255)
}

--// CLEANUP
if getgenv().DiamondHub_Loaded then
    pcall(function() gethui().DiamondHub_V11:Destroy() end)
end
getgenv().DiamondHub_Loaded = true

--// UI SETUP
local ScreenGui = Instance.new("ScreenGui", gethui() or LocalPlayer.PlayerGui)
ScreenGui.Name = "DiamondHub_V11"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

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
Header.ZIndex = 100

local Title = Instance.new("TextLabel", Header)
Title.Text = "DIAMOND<font color='#00AAFF'>HUB</font> V11"
Title.RichText = true; Title.Font = Enum.Font.GothamBold; Title.TextSize = 18; Title.TextColor3 = Color3.new(1,1,1)
Title.Size = UDim2.new(0, 200, 1, 0); Title.Position = UDim2.new(0, 15, 0, 0); Title.BackgroundTransparency = 1; Title.TextXAlignment = "Left"; Title.ZIndex = 101

--// MINIMIZE & CLOSE (THE FIX)
local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 30, 0, 30); MinBtn.Position = UDim2.new(1, -75, 0, 7); MinBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MinBtn.Text = "-"; MinBtn.TextColor3 = Color3.new(1,1,1); MinBtn.Font = Enum.Font.GothamBold; MinBtn.ZIndex = 102
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -40, 0, 7); CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"; CloseBtn.TextColor3 = Color3.new(1,1,1); CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.ZIndex = 102
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

--// SIDEBAR
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 130, 1, -55); Sidebar.Position = UDim2.new(0, 10, 0, 50); Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 18); Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)
local SideLayout = Instance.new("UIListLayout", Sidebar); SideLayout.Padding = UDim.new(0, 5); SideLayout.HorizontalAlignment = "Center"
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 10)

--// CONTENT
local PageArea = Instance.new("Frame", Main)
PageArea.Size = UDim2.new(1, -160, 1, -55); PageArea.Position = UDim2.new(0, 150, 0, 50); PageArea.BackgroundTransparency = 1

local Tabs = {}
local function CreateTab(name, active)
    local F = Instance.new("Frame", PageArea); F.Size = UDim2.new(1, 0, 1, 0); F.BackgroundTransparency = 1; F.Visible = active
    Instance.new("UIListLayout", F).Padding = UDim.new(0, 10)
    local B = Instance.new("TextButton", Sidebar); B.Size = UDim2.new(0.9, 0, 0, 35); B.BackgroundColor3 = active and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(25, 25, 25)
    B.Text = name; B.TextColor3 = active and Color3.new(1,1,1) or Color3.fromRGB(150,150,150); B.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)
    B.MouseButton1Click:Connect(function()
        for _, v in pairs(Tabs) do v.F.Visible = false; v.B.BackgroundColor3 = Color3.fromRGB(25, 25, 25); v.B.TextColor3 = Color3.fromRGB(150, 150, 150) end
        F.Visible = true; B.BackgroundColor3 = Color3.fromRGB(35, 35, 35); B.TextColor3 = Color3.new(1,1,1)
    end)
    Tabs[name] = {F = F, B = B}; return F
end

--// CATEGORIES
local Profile = CreateTab("Profile", true)
local Combat = CreateTab("Combat", false)
local Visuals = CreateTab("Visuals", false)

-- PROFILE CONTENT
local PFP = Instance.new("ImageLabel", Profile)
PFP.Size = UDim2.new(0, 70, 0, 70); PFP.BackgroundColor3 = Color3.fromRGB(30, 30, 30); PFP.Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150"
Instance.new("UICorner", PFP).CornerRadius = UDim.new(1, 0)
local UserText = Instance.new("TextLabel", Profile)
UserText.Size = UDim2.new(1, 0, 0, 30); UserText.BackgroundTransparency = 1; UserText.Text = "Welcome, "..LocalPlayer.DisplayName; UserText.TextColor3 = Color3.new(1,1,1); UserText.Font = Enum.Font.GothamBold; UserText.TextXAlignment = "Left"

-- TOGGLE HELPER
local function NewToggle(name, parent, config)
    local T = Instance.new("TextButton", parent); T.Size = UDim2.new(1, 0, 0, 38); T.BackgroundColor3 = Color3.fromRGB(25, 25, 25); T.Text = "   "..name
    T.TextColor3 = Color3.fromRGB(200, 200, 200); T.Font = Enum.Font.Gotham; T.TextXAlignment = "Left"; Instance.new("UICorner", T).CornerRadius = UDim.new(0, 6)
    local Dot = Instance.new("Frame", T); Dot.Size = UDim2.new(0, 10, 0, 10); Dot.Position = UDim2.new(1, -25, 0.5, -5); Dot.BackgroundColor3 = Color3.fromRGB(50, 50, 50); Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
    T.MouseButton1Click:Connect(function() _G.DH_Config[config] = not _G.DH_Config[config]; Dot.BackgroundColor3 = _G.DH_Config[config] and _G.DH_Config.Accent or Color3.fromRGB(50, 50, 50) end)
end

NewToggle("Legit Aimbot", Combat, "Aimbot")
NewToggle("Rage Hitbox", Combat, "RageHitbox")
NewToggle("Master ESP", Visuals, "ESP")

--// WINDOW LOGIC
local Mini = false
MinBtn.MouseButton1Click:Connect(function()
    Mini = not Mini
    TweenService:Create(Main, TweenInfo.new(0.3), {Size = UDim2.new(0, 520, 0, Mini and 45 or 340)}):Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
    local Conf = Instance.new("Frame", Main); Conf.Size = UDim2.new(1, 0, 1, 0); Conf.BackgroundColor3 = Color3.new(0,0,0); Conf.BackgroundTransparency = 0.4; Conf.ZIndex = 200
    local Msg = Instance.new("TextLabel", Conf); Msg.Size = UDim2.new(1, 0, 0, 100); Msg.Position = UDim2.new(0,0,0.3,0); Msg.Text = "Are you sure?"; Msg.TextColor3 = Color3.new(1,1,1); Msg.Font = Enum.Font.GothamBold; Msg.ZIndex = 201
    local Y = Instance.new("TextButton", Conf); Y.Size = UDim2.new(0,100,0,30); Y.Position = UDim2.new(0.5, -110, 0.6, 0); Y.Text = "Close"; Y.ZIndex = 201
    Y.MouseButton1Click:Connect(function() ScreenGui:Destroy(); getgenv().DiamondHub_Loaded = false end)
    local N = Instance.new("TextButton", Conf); N.Size = UDim2.new(0,100,0,30); N.Position = UDim2.new(0.5, 10, 0.6, 0); N.Text = "Cancel"; N.ZIndex = 201
    N.MouseButton1Click:Connect(function() Conf:Destroy() end)
end)

--// DRAG
local drag = false; local start; local pos
Header.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true; start = i.Position; pos = Main.Position end end)
UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
    local d = i.Position - start; Main.Position = UDim2.new(pos.X.Scale, pos.X.Offset + d.X, pos.Y.Scale, pos.Y.Offset + d.Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)

--// COMBAT
RunService:BindToRenderStep("DH_V11", Enum.RenderPriority.Camera.Value + 1, function()
    if _G.DH_Config.Aimbot then
        local t = nil; local d = _G.DH_Config.FOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
                local s, onscreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if onscreen then
                    local mag = (Vector2.new(s.X, s.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if mag < d then d = mag; t = p end
                end
            end
        end
        if t then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t.Character.Head.Position), _G.DH_Config.Smoothness) end
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            p.Character.Head.Size = _G.DH_Config.RageHitbox and Vector3.new(_G.DH_Config.HitboxSize, _G.DH_Config.HitboxSize, _G.DH_Config.HitboxSize) or Vector3.new(2,1,1)
            p.Character.Head.Transparency = _G.DH_Config.RageHitbox and 0.6 or 0
            local h = p.Character:FindFirstChild("Highlight") or Instance.new("Highlight", p.Character)
            h.Enabled = _G.DH_Config.ESP; h.FillTransparency = 0.5
        end
    end
end)
