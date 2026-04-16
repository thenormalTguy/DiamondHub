local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

--// SETTINGS
_G.DH_Config = {
    Aimbot = false,
    Rage = false,
    Smoothness = 0.12,
    FOV = 150,
    TeamCheck = true,
    VisibleCheck = true,
    TargetPart = "Head",
    ESP = false,
    ESP_Boxes = true,
    ESP_Names = true,
    AccentColor = Color3.fromRGB(0, 170, 255),
}

--// UTILS
local function Create(cls, props, parent)
    local obj = Instance.new(cls)
    for i, v in pairs(props) do obj[i] = v end
    if parent then obj.Parent = parent end
    return obj
end

local function Round(obj, px)
    Create("UICorner", {CornerRadius = UDim.new(0, px or 8)}, obj)
end

--// MAIN UI
local ScreenGui = Create("ScreenGui", {Name = "DiamondHub_V6", ResetOnSpawn = false})
pcall(function() ScreenGui.Parent = gethui() or LocalPlayer.PlayerGui end)

local MainFrame = Create("Frame", {
    Size = UDim2.new(0, 550, 0, 350),
    Position = UDim2.new(0.5, -275, 0.5, -175),
    BackgroundColor3 = Color3.fromRGB(15, 15, 15),
    BorderSizePixel = 0,
}, ScreenGui)
Round(MainFrame, 10)

--// TOP HEADER
local Header = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 50),
    BackgroundColor3 = Color3.fromRGB(22, 22, 22),
    BorderSizePixel = 0,
    ZIndex = 5
}, MainFrame)
Round(Header, 10)

local Logo = Create("TextLabel", {
    Text = "DIAMOND<font color='#00AAFF'>HUB</font>",
    Size = UDim2.new(0, 200, 1, 0),
    Position = UDim2.new(0, 20, 0, 0),
    BackgroundTransparency = 1,
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 22,
    RichText = true,
    TextXAlignment = "Left",
    ZIndex = 6
}, Header)

--// SIDEBAR
local Sidebar = Create("Frame", {
    Size = UDim2.new(0, 130, 1, -60),
    Position = UDim2.new(0, 10, 0, 55),
    BackgroundColor3 = Color3.fromRGB(18, 18, 18),
    BorderSizePixel = 0,
    ZIndex = 2
}, MainFrame)
Round(Sidebar, 8)
local SideList = Create("UIListLayout", {Padding = UDim.new(0, 5), HorizontalAlignment = "Center", SortOrder = Enum.SortOrder.LayoutOrder}, Sidebar)
Create("UIPadding", {PaddingTop = UDim.new(0, 10)}, Sidebar)

--// CONTENT AREA
local PageContainer = Create("Frame", {
    Size = UDim2.new(1, -165, 1, -60),
    Position = UDim2.new(0, 150, 0, 55),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    ZIndex = 2
}, MainFrame)

local Pages = {}
local Buttons = {}

local function NewPage(name, order)
    local Scroll = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 2, 0), -- Forced Canvas size
        ZIndex = 3
    }, PageContainer)
    Create("UIListLayout", {Padding = UDim.new(0, 15), HorizontalAlignment = "Center", SortOrder = Enum.SortOrder.LayoutOrder}, Scroll)
    
    local Btn = Create("TextButton", {
        Text = name,
        Size = UDim2.new(0.9, 0, 0, 38),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        TextColor3 = Color3.fromRGB(150, 150, 150),
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        LayoutOrder = order,
        ZIndex = 4
    }, Sidebar)
    Round(Btn, 6)

    Btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, b in pairs(Buttons) do 
            b.TextColor3 = Color3.fromRGB(150, 150, 150)
            b.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        end
        Scroll.Visible = true
        Btn.TextColor3 = Color3.new(1, 1, 1)
        Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    end)
    
    Pages[name] = Scroll
    Buttons[name] = Btn
    return Scroll
end

local function AddCard(title, parent, order)
    local Card = Create("Frame", {
        Size = UDim2.new(0.95, 0, 0, 100), -- Base size
        BackgroundColor3 = Color3.fromRGB(22, 22, 22),
        LayoutOrder = order or 1,
        ZIndex = 3
    }, parent)
    Round(Card, 8)
    
    local TitleLabel = Create("TextLabel", {
        Text = title:upper(),
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        TextColor3 = _G.DH_Config.AccentColor,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = "Left",
        ZIndex = 4
    }, Card)

    local Content = Create("Frame", {
        Size = UDim2.new(1, 0, 1, -35),
        Position = UDim2.new(0, 0, 0, 35),
        BackgroundTransparency = 1,
        ZIndex = 3
    }, Card)
    Create("UIListLayout", {Padding = UDim.new(0, 8), HorizontalAlignment = "Center"}, Content)
    
    -- Auto-resize Logic
    Content.ChildAdded:Connect(function()
        local h = 45
        for _, v in pairs(Content:GetChildren()) do
            if v:IsA("GuiObject") then h = h + v.Size.Y.Offset + 8 end
        end
        Card.Size = UDim2.new(0.95, 0, 0, h)
    end)

    return Content
end

--// INIT PAGES
local ProfilePage = NewPage("Profile", 1)
local CombatPage = NewPage("Combat", 2)
local VisualPage = NewPage("Visuals", 3)

--// 1. PROFILE SECTION
local ProfContent = AddCard("Account Details", ProfilePage, 1)
local PFP = Create("ImageLabel", {
    Size = UDim2.new(0, 64, 0, 64),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150",
    ZIndex = 4
}, ProfContent)
Round(PFP, 32)

Create("TextLabel", {
    Text = "Welcome, " .. LocalPlayer.DisplayName .. "\n<font color='#AAAAAA'>@" .. LocalPlayer.Name .. "</font>",
    Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, TextColor3 = Color3.new(1,1,1),
    Font = Enum.Font.GothamMedium, TextSize = 14, RichText = true, ZIndex = 4
}, ProfContent)

--// 2. COMBAT SECTION
local AimContent = AddCard("Aimbot Tools", CombatPage, 1)

local function NewToggle(name, parent, configKey)
    local Tgl = Create("TextButton", {
        Text = "  " .. name, Size = UDim2.new(0.9, 0, 0, 32),
        BackgroundColor3 = Color3.fromRGB(28, 28, 28), TextColor3 = Color3.fromRGB(200, 200, 200),
        Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = "Left", ZIndex = 4
    }, parent)
    Round(Tgl, 5)
    
    local Dot = Create("Frame", {
        Size = UDim2.new(0, 24, 0, 12), Position = UDim2.new(1, -35, 0.5, -6),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50), ZIndex = 5
    }, Tgl)
    Round(Dot, 10)

    local function Update()
        local enabled = _G.DH_Config[configKey]
        TweenService:Create(Dot, TweenInfo.new(0.2), {BackgroundColor3 = enabled and _G.DH_Config.AccentColor or Color3.fromRGB(50, 50, 50)}):Play()
    end
    Tgl.MouseButton1Click:Connect(function() _G.DH_Config[configKey] = not _G.DH_Config[configKey] Update() end)
    Update()
end

NewToggle("Smooth Lock", AimContent, "Aimbot")
NewToggle("Rage Snap", AimContent, "Rage")
NewToggle("Team Check", AimContent, "TeamCheck")

--// 3. VISUALS SECTION
local VisualContent = AddCard("Visual Enhancements", VisualPage, 1)
NewToggle("Enable ESP", VisualContent, "ESP")
NewToggle("Boxes", VisualContent, "ESP_Boxes")
NewToggle("Names", VisualContent, "ESP_Names")

--// TARGETING & ESP (Same Logic, Optimized)
local function GetClosest()
    local target, dist = nil, _G.DH_Config.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
            if _G.DH_Config.TeamCheck and p.Team == LocalPlayer.Team then continue end
            local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if vis then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if mag < dist then dist = mag target = p end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    if _G.DH_Config.Aimbot or _G.DH_Config.Rage then
        local t = GetClosest()
        if t then
            local goal = CFrame.lookAt(Camera.CFrame.Position, t.Character.Head.Position)
            Camera.CFrame = _G.DH_Config.Rage and goal or Camera.CFrame:Lerp(goal, _G.DH_Config.Smoothness)
        end
    end
    -- ESP
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            local box = char:FindFirstChild("DH_B") or Create("Highlight", {Name = "DH_B", OutlineColor = _G.DH_Config.AccentColor, FillTransparency = 0.7}, char)
            box.Enabled = _G.DH_Config.ESP and _G.DH_Config.ESP_Boxes
            local tag = char:FindFirstChild("DH_T") or Create("BillboardGui", {Name = "DH_T", Size = UDim2.new(0,100,0,40), StudsOffset = Vector3.new(0,3,0), AlwaysOnTop = true}, char)
            local l = tag:FindFirstChild("L") or Create("TextLabel", {Name="L", Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, TextColor3=Color3.new(1,1,1), Font=Enum.Font.GothamBold, TextSize=11}, tag)
            l.Text = p.DisplayName tag.Enabled = _G.DH_Config.ESP and _G.DH_Config.ESP_Names
        end
    end
end)

--// DRAG
local d, ds, sp
MainFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true ds = i.Position sp = MainFrame.Position end end)
UserInputService.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then
    local delta = i.Position - ds MainFrame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)

--// FINAL SHOW
Pages["Profile"].Visible = true
Buttons["Profile"].BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Buttons["Profile"].TextColor3 = Color3.new(1, 1, 1)
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame:TweenSize(UDim2.new(0, 550, 0, 350), "Out", "Back", 0.5)
