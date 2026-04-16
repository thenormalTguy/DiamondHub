local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--// GUI PARENTING
local function GetGui()
    local success, core = pcall(function() return game:GetService("CoreGui") end)
    if gethui then return gethui() end
    if success and core:FindFirstChild("RobloxGui") then return core.RobloxGui end
    return LocalPlayer:WaitForChild("PlayerGui")
end

if getgenv().DiamondHub_Loaded then
    local old = GetGui():FindFirstChild("DiamondHub_Master")
    if old then old:Destroy() end
end
getgenv().DiamondHub_Loaded = true

--// CREATE MASTER GUI
local ScreenGui = Instance.new("ScreenGui", GetGui())
ScreenGui.Name = "DiamondHub_Master"
ScreenGui.ResetOnSpawn = false

--=========================================--
--      PHASE 3: THE RIVALS SCRIPT         --
--=========================================--
local function LoadRivalsScript()
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Camera = workspace.CurrentCamera
    local Mouse = LocalPlayer:GetMouse()

    -- We wrap the entire V10 Rivals script here
    _G.DH_Config = { Aimbot=false, RageHitbox=false, HitboxSize=15, FOV=250, ESP=false, Speed=false, WalkSpeedValue=60, Fly=false, FlySpeed=50, Noclip=false, Accent=Color3.fromRGB(0, 170, 255) }

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 620, 0, 420)
    Main.Position = UDim2.new(0.5, -310, 0.5, -210)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Main.ClipsDescendants = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = _G.DH_Config.Accent
    MainStroke.Thickness = 1.5
    MainStroke.Transparency = 0.2

    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    Header.BorderSizePixel = 0
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)
    local HeaderFix = Instance.new("Frame", Header)
    HeaderFix.Size = UDim2.new(1, 0, 0, 10)
    HeaderFix.Position = UDim2.new(0, 0, 1, -10)
    HeaderFix.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    HeaderFix.BorderSizePixel = 0

    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(0, 350, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Text = "💎 DIAMOND<font color='#00AAFF'>HUB</font> <font color='#666'>| RIVALS</font>"
    Title.RichText = true
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 22
    Title.TextXAlignment = "Left"
    Title.BackgroundTransparency = 1

    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Size = UDim2.new(0, 36, 0, 36)
    CloseBtn.Position = UDim2.new(1, -45, 0, 7)
    CloseBtn.Text = "✖"
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseBtn.TextColor3 = Color3.new(1,1,1)
    CloseBtn.TextSize = 18
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy(); getgenv().DiamondHub_Loaded = false end)

    local ContentFrame = Instance.new("Frame", Main)
    ContentFrame.Size = UDim2.new(1, 0, 1, -50)
    ContentFrame.Position = UDim2.new(0, 0, 0, 50)
    ContentFrame.BackgroundTransparency = 1

    local Sidebar = Instance.new("Frame", ContentFrame)
    Sidebar.Size = UDim2.new(0, 160, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Sidebar.BorderSizePixel = 0
    local TabList = Instance.new("UIListLayout", Sidebar)
    TabList.Padding = UDim.new(0, 10)
    TabList.HorizontalAlignment = "Center"
    Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 15)

    local Pages = Instance.new("Frame", ContentFrame)
    Pages.Size = UDim2.new(1, -170, 1, 0)
    Pages.Position = UDim2.new(0, 160, 0, 0)
    Pages.BackgroundTransparency = 1

    local Tabs = {}
    local function CreateTab(name, active)
        local Frame = Instance.new("ScrollingFrame", Pages)
        Frame.Size = UDim2.new(1, -10, 1, -20)
        Frame.Position = UDim2.new(0, 5, 0, 10)
        Frame.BackgroundTransparency = 1
        Frame.Visible = active
        Frame.ScrollBarThickness = 2
        local Layout = Instance.new("UIListLayout", Frame)
        Layout.Padding = UDim.new(0, 12)
        Layout.HorizontalAlignment = "Center"

        local Btn = Instance.new("TextButton", Sidebar)
        Btn.Size = UDim2.new(0.85, 0, 0, 42)
        Btn.BackgroundColor3 = active and _G.DH_Config.Accent or Color3.fromRGB(25, 25, 25)
        Btn.Text = name
        Btn.TextColor3 = active and Color3.new(1,1,1) or Color3.fromRGB(170, 170, 170)
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 16
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

        Btn.MouseButton1Click:Connect(function()
            for _, v in pairs(Tabs) do v.F.Visible = false; v.B.BackgroundColor3 = Color3.fromRGB(25, 25, 25); v.B.TextColor3 = Color3.fromRGB(170, 170, 170) end
            Frame.Visible = true; Btn.BackgroundColor3 = _G.DH_Config.Accent; Btn.TextColor3 = Color3.new(1,1,1)
        end)
        Tabs[name] = {F = Frame, B = Btn}
        return Frame
    end

    local DiscordTab = CreateTab("💬 Discord", true)
    local CombatTab = CreateTab("⚔️ Combat", false)
    local VisualsTab = CreateTab("👁️ Visuals", false)

    -- Discord elements
    local DiscLabel = Instance.new("TextLabel", DiscordTab)
    DiscLabel.Size = UDim2.new(1, -20, 0, 40)
    DiscLabel.BackgroundTransparency = 1
    DiscLabel.Text = "Join the Official Support Server"
    DiscLabel.TextColor3 = Color3.new(1,1,1)
    DiscLabel.Font = Enum.Font.GothamBold
    DiscLabel.TextSize = 18

    local DiscBox = Instance.new("TextBox", DiscordTab)
    DiscBox.Size = UDim2.new(1, -40, 0, 45)
    DiscBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    DiscBox.Text = "https://discord.gg/diamondhub"
    DiscBox.TextColor3 = _G.DH_Config.Accent
    DiscBox.Font = Enum.Font.GothamMedium
    DiscBox.TextSize = 16
    DiscBox.ClearTextOnFocus = false
    DiscBox.TextEditable = false
    Instance.new("UICorner", DiscBox).CornerRadius = UDim.new(0, 8)

    -- Toggle System
    local function AddToggle(name, parent, key)
        local T = Instance.new("TextButton", parent)
        T.Size = UDim2.new(1, -20, 0, 50)
        T.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        T.Text = "      " .. name
        T.TextColor3 = Color3.fromRGB(220, 220, 220)
        T.Font = Enum.Font.GothamMedium
        T.TextSize = 16
        T.TextXAlignment = "Left"
        Instance.new("UICorner", T).CornerRadius = UDim.new(0, 8)

        local Pill = Instance.new("Frame", T)
        Pill.Size = UDim2.new(0, 46, 0, 24)
        Pill.Position = UDim2.new(1, -60, 0.5, -12)
        Pill.BackgroundColor3 = _G.DH_Config[key] and _G.DH_Config.Accent or Color3.fromRGB(50, 50, 50)
        Instance.new("UICorner", Pill).CornerRadius = UDim.new(1, 0)

        local Dot = Instance.new("Frame", Pill)
        Dot.Size = UDim2.new(0, 18, 0, 18)
        Dot.Position = _G.DH_Config[key] and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        Dot.BackgroundColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

        T.MouseButton1Click:Connect(function()
            _G.DH_Config[key] = not _G.DH_Config[key]
            TweenService:Create(Pill, TweenInfo.new(0.3), {BackgroundColor3 = _G.DH_Config[key] and _G.DH_Config.Accent or Color3.fromRGB(50, 50, 50)}):Play()
            TweenService:Create(Dot, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Position = _G.DH_Config[key] and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)}):Play()
        end)
    end

    AddToggle("Aimbot (Hard Lock)", CombatTab, "Aimbot")
    AddToggle("Hitbox Expander", CombatTab, "RageHitbox")
    AddToggle("ESP Highlights", VisualsTab, "ESP")

    -- Engine Logic
    RunService.RenderStepped:Connect(function()
        if not getgenv().DiamondHub_Loaded then return end
        if _G.DH_Config.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local nearest, dist = nil, _G.DH_Config.FOV
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
                    local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                    if onScreen then
                        local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                        if mag < dist then dist = mag; nearest = p.Character.Head end
                    end
                end
            end
            if nearest then Camera.CFrame = CFrame.new(Camera.CFrame.Position, nearest.Position) end
        end
    end)
    
    -- Pop up animation
    Main.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(0, 620, 0, 420)}):Play()
end

--=========================================--
--      PHASE 2: GAME SELECTION HUB        --
--=========================================--
local function LoadHubMenu()
    local HubMain = Instance.new("Frame", ScreenGui)
    HubMain.Size = UDim2.new(0, 500, 0, 350)
    HubMain.Position = UDim2.new(0.5, -250, 0.5, -175)
    HubMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    HubMain.ClipsDescendants = true
    Instance.new("UICorner", HubMain).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", HubMain).Color = Color3.fromRGB(0, 170, 255)

    local Title = Instance.new("TextLabel", HubMain)
    Title.Size = UDim2.new(1, 0, 0, 60)
    Title.Text = "💎 DIAMOND<font color='#00AAFF'>HUB</font> | GAME SELECTION"
    Title.RichText = true
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.BackgroundTransparency = 1

    -- Games List
    local GameList = Instance.new("ScrollingFrame", HubMain)
    GameList.Size = UDim2.new(1, -40, 1, -80)
    GameList.Position = UDim2.new(0, 20, 0, 60)
    GameList.BackgroundTransparency = 1
    GameList.ScrollBarThickness = 2
    local GL = Instance.new("UIListLayout", GameList)
    GL.Padding = UDim.new(0, 10)

    local function CreateGameCard(gameName, description, isSupported)
        local Card = Instance.new("TextButton", GameList)
        Card.Size = UDim2.new(1, -10, 0, 70)
        Card.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        Card.Text = ""
        Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

        local Name = Instance.new("TextLabel", Card)
        Name.Size = UDim2.new(1, -20, 0, 35)
        Name.Position = UDim2.new(0, 15, 0, 5)
        Name.Text = gameName
        Name.TextColor3 = Color3.new(1,1,1)
        Name.Font = Enum.Font.GothamBold
        Name.TextSize = 18
        Name.TextXAlignment = "Left"
        Name.BackgroundTransparency = 1

        local Desc = Instance.new("TextLabel", Card)
        Desc.Size = UDim2.new(1, -20, 0, 20)
        Desc.Position = UDim2.new(0, 15, 0, 40)
        Desc.Text = description
        Desc.TextColor3 = Color3.fromRGB(150, 150, 150)
        Desc.Font = Enum.Font.Gotham
        Desc.TextSize = 14
        Desc.TextXAlignment = "Left"
        Desc.BackgroundTransparency = 1

        if not isSupported then
            Card.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            Name.TextColor3 = Color3.fromRGB(100, 100, 100)
            Desc.Text = "Coming Soon..."
        end

        return Card
    end

    local RivalsBtn = CreateGameCard("🔫 Rivals", "Aimbot, Hitbox Expander, ESP", true)
    CreateGameCard("🧱 Arsenal", "Coming Soon...", false)
    CreateGameCard("💸 Da Hood", "Coming Soon...", false)

    -- Loading text when clicking a game
    local LoadingLabel = Instance.new("TextLabel", HubMain)
    LoadingLabel.Size = UDim2.new(1, 0, 1, 0)
    LoadingLabel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    LoadingLabel.Text = "Loading Rivals..."
    LoadingLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
    LoadingLabel.Font = Enum.Font.GothamBold
    LoadingLabel.TextSize = 24
    LoadingLabel.Visible = false
    LoadingLabel.ZIndex = 50

    RivalsBtn.MouseButton1Click:Connect(function()
        LoadingLabel.Visible = true
        LoadingLabel.BackgroundTransparency = 1
        LoadingLabel.TextTransparency = 1
        TweenService:Create(LoadingLabel, TweenInfo.new(0.5), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
        
        task.wait(1.5) -- Fake loading time
        HubMain:Destroy()
        LoadRivalsScript()
    end)
    
    HubMain.Size = UDim2.new(0,0,0,0)
    TweenService:Create(HubMain, TweenInfo.new(0.6, Enum.EasingStyle.Back), {Size = UDim2.new(0, 500, 0, 350)}):Play()
end

--=========================================--
--      PHASE 1: BOOT LOADING SCREEN       --
--=========================================--
local BootFrame = Instance.new("Frame", ScreenGui)
BootFrame.Size = UDim2.new(1, 0, 1, 0)
BootFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
BootFrame.ZIndex = 100

local DiamondText = Instance.new("TextLabel", BootFrame)
DiamondText.Size = UDim2.new(1, 0, 1, 0)
DiamondText.BackgroundTransparency = 1
DiamondText.Text = "Loading Diamond Hub..."
DiamondText.TextColor3 = Color3.new(1,1,1)
DiamondText.Font = Enum.Font.GothamBold
DiamondText.TextSize = 30

-- Simple fade out animation
task.spawn(function()
    task.wait(1.5)
    TweenService:Create(DiamondText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(BootFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    task.wait(0.5)
    BootFrame:Destroy()
    LoadHubMenu()
end)
