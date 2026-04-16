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
local ScreenGui = Create("ScreenGui", {Name = "DiamondHub_V5", ResetOnSpawn = false})
pcall(function() ScreenGui.Parent = gethui() or LocalPlayer.PlayerGui end)

local MainFrame = Create("Frame", {
    Size = UDim2.new(0, 550, 0, 350),
    Position = UDim2.new(0.5, -275, 0.5, -175),
    BackgroundColor3 = Color3.fromRGB(18, 18, 18),
    BorderSizePixel = 0,
}, ScreenGui)
Round(MainFrame, 10)

--// TOP HEADER
local Header = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 45),
    BackgroundColor3 = Color3.fromRGB(25, 25, 25),
    BorderSizePixel = 0
}, MainFrame)
Round(Header, 10)

local Logo = Create("TextLabel", {
    Text = "DIAMOND<font color='#00AAFF'>HUB</font>",
    Size = UDim2.new(0, 200, 1, 0),
    Position = UDim2.new(0, 15, 0, 0),
    BackgroundTransparency = 1,
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    RichText = true,
    TextXAlignment = "Left"
}, Header)

--// SIDEBAR
local Sidebar = Create("Frame", {
    Size = UDim2.new(0, 140, 1, -55),
    Position = UDim2.new(0, 5, 0, 50),
    BackgroundColor3 = Color3.fromRGB(22, 22, 22),
    BorderSizePixel = 0
}, MainFrame)
Round(Sidebar, 8)
Create("UIListLayout", {Padding = UDim.new(0, 5), HorizontalAlignment = "Center"}, Sidebar)
Create("UIPadding", {PaddingTop = UDim.new(0, 10)}, Sidebar)

--// CONTENT AREA
local PageContainer = Create("Frame", {
    Size = UDim2.new(1, -160, 1, -55),
    Position = UDim2.new(0, 150, 0, 50),
    BackgroundTransparency = 1
}, MainFrame)

local Pages = {}
local Buttons = {}

local function NewPage(name, active)
    local Scroll = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = active or false,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
    }, PageContainer)
    Create("UIListLayout", {Padding = UDim.new(0, 12), HorizontalAlignment = "Center"}, Scroll)
    
    local Btn = Create("TextButton", {
        Text = name,
        Size = UDim2.new(0.9, 0, 0, 35),
        BackgroundColor3 = active and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(22, 22, 22),
        TextColor3 = active and Color3.new(1,1,1) or Color3.fromRGB(150, 150, 150),
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
    }, Sidebar)
    Round(Btn, 6)

    Btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, b in pairs(Buttons) do 
            b.TextColor3 = Color3.fromRGB(150, 150, 150)
            b.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        end
        Scroll.Visible = true
        Btn.TextColor3 = Color3.new(1, 1, 1)
        Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end)
    
    Pages[name] = Scroll
    Buttons[name] = Btn
    return Scroll
end

local function AddCard(title, parent)
    local Card = Create("Frame", {
        Size = UDim2.new(0.95, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0
    }, parent)
    Round(Card, 8)
    local List = Create("UIListLayout", {Padding = UDim.new(0, 8), HorizontalAlignment = "Center"}, Card)
    Create("UIPadding", {PaddingTop = UDim.new(0, 35), PaddingBottom = UDim.new(0, 10)}, Card)
    
    local Label = Create("TextLabel", {
        Text = "  " .. title:upper(),
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, -35),
        BackgroundTransparency = 1,
        TextColor3 = _G.DH_Config.AccentColor,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = "Left"
    }, Card)

    -- Auto-resize card based on content
    local function Resize()
        local h = 45
        for _, v in pairs(Card:GetChildren()) do
            if v:IsA("GuiObject") and v ~= Label then h = h + v.Size.Y.Offset + 8 end
        end
        Card.Size = UDim2.new(0.95, 0, 0, h)
    end
    Card.ChildAdded:Connect(Resize)
    return Card
end

local function AddToggle(name, parent, configKey)
    local TglBtn = Create("TextButton", {
        Text = "  " .. name,
        Size = UDim2.new(0.9, 0, 0, 32),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        TextColor3 = Color3.fromRGB(200, 200, 200),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = "Left"
    }, parent)
    Round(TglBtn, 5)
    
    local Status = Create("Frame", {
        Size = UDim2.new(0, 20, 0, 10),
        Position = UDim2.new(1, -30, 0.5, -5),
        BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    }, TglBtn)
    Round(Status, 10)

    local function Update()
        local enabled = _G.DH_Config[configKey]
        TweenService:Create(Status, TweenInfo.new(0.2), {BackgroundColor3 = enabled and _G.DH_Config.AccentColor or Color3.fromRGB(60, 60, 60)}):Play()
        TglBtn.TextColor3 = enabled and Color3.new(1, 1, 1) or Color3.fromRGB(200, 200, 200)
    end
    
    TglBtn.MouseButton1Click:Connect(function()
        _G.DH_Config[configKey] = not _G.DH_Config[configKey]
        Update()
    end)
    Update()
end

--// CREATE PAGES
local ProfilePage = NewPage("Your Profile", true)
local CombatPage = NewPage("Combat")
local VisualPage = NewPage("Visuals")

--// PROFILE CONTENT (WITH PFP)
local ProfCard = AddCard("Account Overview", ProfilePage)
local PFPFrame = Create("ImageLabel", {
    Size = UDim2.new(0, 60, 0, 60),
    Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150",
    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
}, ProfCard)
Round(PFPFrame, 30)

Create("TextLabel", {
    Text = "Welcome, <b>" .. LocalPlayer.DisplayName .. "</b>\nStatus: <font color='#00FF00'>Active</font>",
    Size = UDim2.new(0.9, 0, 0, 40), BackgroundTransparency = 1,
    TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.Gotham,
    TextSize = 13, RichText = true
}, ProfCard)

--// COMBAT CONTENT
local AimCard = AddCard("Aimbot Logic", CombatPage)
AddToggle("Enable Smooth Aim", AimCard, "Aimbot")
AddToggle("Enable Rage Snap", AimCard, "Rage")
AddToggle("Team Check", AimCard, "TeamCheck")

--// VISUALS CONTENT
local EspCard = AddCard("ESP Visuals", VisualPage)
AddToggle("Master ESP", EspCard, "ESP")
AddToggle("Box ESP", EspCard, "ESP_Boxes")
AddToggle("Name Tags", EspCard, "ESP_Names")

--// TARGETING SYSTEM
local function GetTarget()
    local target, closest = nil, _G.DH_Config.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            if _G.DH_Config.TeamCheck and p.Team == LocalPlayer.Team then continue end
            if p.Character.Humanoid.Health <= 0 then continue end
            local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if vis then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if mag < closest then
                    closest = mag
                    target = p
                end
            end
        end
    end
    return target
end

--// ESP SYSTEM
local function DoESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            local h = char:FindFirstChild("DH_High") or Create("Highlight", {Name = "DH_High", OutlineColor = _G.DH_Config.AccentColor, FillTransparency = 0.6}, char)
            h.Enabled = _G.DH_Config.ESP and _G.DH_Config.ESP_Boxes
            
            local b = char:FindFirstChild("DH_BB") or Create("BillboardGui", {Name = "DH_BB", Size = UDim2.new(0,100,0,50), StudsOffset = Vector3.new(0,3,0), AlwaysOnTop = true}, char)
            local l = b:FindFirstChild("L") or Create("TextLabel", {Name = "L", Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 11}, b)
            l.Text = p.DisplayName
            b.Enabled = _G.DH_Config.ESP and _G.DH_Config.ESP_Names
        end
    end
end

--// LOOPS
RunService.RenderStepped:Connect(function()
    if _G.DH_Config.Aimbot or _G.DH_Config.Rage then
        local t = GetTarget()
        if t and t.Character:FindFirstChild("Head") then
            local cf = CFrame.lookAt(Camera.CFrame.Position, t.Character.Head.Position)
            if _G.DH_Config.Rage then
                Camera.CFrame = cf
            else
                Camera.CFrame = Camera.CFrame:Lerp(cf, _G.DH_Config.Smoothness)
            end
        end
    end
    DoESP()
end)

--// DRAG SYSTEM
local d, di, ds, sp
MainFrame.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true ds = i.Position sp = MainFrame.Position end
end)
UserInputService.InputChanged:Connect(function(i)
    if d and i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - ds
        MainFrame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)

--// OPEN ANIM
MainFrame.ClipsDescendants = true
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame:TweenSize(UDim2.new(0, 550, 0, 350), "Out", "Back", 0.6)
