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
    TeamCheck = true,
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
Main.Size = UDim2.new(0, 520, 0, 340)
Main.Position = UDim2.new(0.5, -260, 0.5, -170)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true -- Crucial for Minimize
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

--// TOP BAR (HEADER)
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Header.BorderSizePixel = 0
Header.ZIndex = 20

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
Title.ZIndex = 21

--// CONTROLS (X and -)
local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -70, 0, 6)
MinBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.ZIndex = 22
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -35, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.ZIndex = 22
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

--// SIDEBAR & PAGES
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 120, 1, -50)
Sidebar.Position = UDim2.new(0, 10, 0, 45)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local SidebarList = Instance.new("UIListLayout", Sidebar)
SidebarList.Padding = UDim.new(0, 5)
SidebarList.HorizontalAlignment = "Center"
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 10)

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
        for _, v in pairs(Tabs) do 
            v.Frame.Visible = false 
            v.Btn.BackgroundColor3 = Color3.fromRGB(22,22,22) 
            v.Btn.TextColor3 = Color3.fromRGB(150,150,150)
        end
        TabFrame.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
        TabBtn.TextColor3 = Color3.new(1,1,1)
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
    T.Text = "    " .. name
    T.TextColor3 = Color3.fromRGB(200, 200, 200)
    T.Font = Enum.Font.Gotham
    T.TextXAlignment = "Left"
    Instance.new("UICorner", T).CornerRadius = UDim.new(0, 6)

    local Ind = Instance.new("Frame", T)
    Ind.Size = UDim2.new(0, 12, 0, 12)
    Ind.Position = UDim2.new(1, -25, 0.5, -6)
    Ind.BackgroundColor3 = _G.DH_Config[configKey] and _G.DH_Config.Accent or Color3.fromRGB(50, 50, 50)
    Instance.new("UICorner", Ind).CornerRadius = UDim.new(1, 0)

    T.MouseButton1Click:Connect(function()
        _G.DH_Config[configKey] = not _G.DH_Config[configKey]
        TweenService:Create(Ind, TweenInfo.new(0.2), {BackgroundColor3 = _G.DH_Config[configKey] and _G.DH_Config.Accent or Color3.fromRGB(50, 50, 50)}):Play()
    end)
end

AddToggle("Aimbot (Smooth)", CombatTab, "Aimbot")
AddToggle("Rage Hitbox", CombatTab, "RageHitbox")
AddToggle("Team Check", CombatTab, "TeamCheck")
AddToggle("ESP Highlight", VisualsTab, "ESP")

--// UI LOGIC
local Mini = false
MinBtn.MouseButton1Click:Connect(function()
    Mini = not Mini
    TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 520, 0, Mini and 40 or 340)}):Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    getgenv().DiamondHub_Loaded = false
end)

--// DRAGGING
local drag, dragInput, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = true; dragStart = input.Position; startPos = Main.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then drag = false end end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

--// GET TARGET FUNCTION
local function GetClosestPlayer()
    local target = nil
    local shortestDistance = _G.DH_Config.FOV

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            -- Team Check Logic
            if _G.DH_Config.TeamCheck and p.Team == LocalPlayer.Team then continue end
            
            local head = p.Character:FindFirstChild("Head")
            if head then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        target = head
                    end
                end
            end
        end
    end
    return target
end

--// MAIN LOOP
RunService.RenderStepped:Connect(function()
    if not getgenv().DiamondHub_Loaded then return end

    -- Aimbot Logic
    if _G.DH_Config.Aimbot then
        local target = GetClosestPlayer()
        if target then
            local lookAt = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(lookAt, _G.DH_Config.Smoothness)
        end
    end

    -- Hitbox & ESP Logic
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local head = p.Character:FindFirstChild("Head")
            local hum = p.Character:FindFirstChild("Humanoid")
            
            if head and hum then
                -- Hitbox Expander
                if _G.DH_Config.RageHitbox and hum.Health > 0 then
                    head.Size = Vector3.new(_G.DH_Config.HitboxSize, _G.DH_Config.HitboxSize, _G.DH_Config.HitboxSize)
                    head.Transparency = 0.7
                    head.CanCollide = false
                else
                    head.Size = Vector3.new(2, 1, 1) -- Standard Roblox head size
                    head.Transparency = 0
                end

                -- ESP Logic
                local highlight = p.Character:FindFirstChild("DH_Highlight")
                if _G.DH_Config.ESP and hum.Health > 0 then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "DH_Highlight"
                        highlight.Parent = p.Character
                    end
                    highlight.Enabled = true
                    highlight.FillColor = _G.DH_Config.Accent
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                elseif highlight then
                    highlight.Enabled = false
                end
            end
        end
    end
end)
