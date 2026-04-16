local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

--// GLOBAL CONFIG
_G.DH_Config = {
    Aimbot = false,
    Rage = false,
    Smoothness = 0.1,
    FOV = 150,
    TeamCheck = true,
    VisibleCheck = true,
    TargetPart = "Head",
    
    ESP = false,
    ESP_Boxes = true,
    ESP_Names = true,
    ESP_Dist = true,
    
    UI_Theme = Color3.fromRGB(0, 170, 255),
    IsClosed = false
}

--// UI UTILS
local function Create(cls, props, parent)
    local obj = Instance.new(cls)
    for i, v in pairs(props) do obj[i] = v end
    if parent then obj.Parent = parent end
    return obj
end

--// MAIN UI FRAMEWORK
local ScreenGui = Create("ScreenGui", {Name = "DiamondHub_V4", ResetOnSpawn = false})
pcall(function() ScreenGui.Parent = gethui() or LocalPlayer.PlayerGui end)

local MainFrame = Create("Frame", {
    Size = UDim2.new(0, 520, 0, 340),
    Position = UDim2.new(0.5, -260, 0.5, -170),
    BackgroundColor3 = Color3.fromRGB(15, 15, 15),
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, ScreenGui)
Create("UICorner", {CornerRadius = UDim.new(0, 10)}, MainFrame)

--// TOP BAR (LOGO)
local TopBar = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
    BorderSizePixel = 0
}, MainFrame)
Create("UICorner", {CornerRadius = UDim.new(0, 10)}, TopBar)

local Logo = Create("TextLabel", {
    Text = "DIAMOND<font color='#00AAFF'>HUB</font>",
    Size = UDim2.new(0, 150, 1, 0),
    Position = UDim2.new(0, 15, 0, 0),
    BackgroundTransparency = 1,
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    RichText = true,
    TextXAlignment = "Left"
}, TopBar)

--// SIDEBAR
local Sidebar = Create("Frame", {
    Size = UDim2.new(0, 130, 1, -40),
    Position = UDim2.new(0, 0, 0, 40),
    BackgroundColor3 = Color3.fromRGB(18, 18, 18),
    BorderSizePixel = 0
}, MainFrame)

local TabContainer = Create("Frame", {
    Size = UDim2.new(1, -140, 1, -50),
    Position = UDim2.new(0, 135, 0, 45),
    BackgroundTransparency = 1
}, MainFrame)

--// DYNAMIC TAB SYSTEM
local Tabs = {}
local TabBtns = {}

local function NewTab(name, active)
    local Page = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = active or false,
        ScrollBarThickness = 2,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
    }, TabContainer)
    Create("UIListLayout", {Padding = UDim.new(0, 10), HorizontalAlignment = "Center"}, Page)
    
    local Btn = Create("TextButton", {
        Text = name,
        Size = UDim2.new(1, -10, 0, 35),
        BackgroundTransparency = 1,
        TextColor3 = active and Color3.new(1,1,1) or Color3.fromRGB(150, 150, 150),
        Font = Enum.Font.GothamSemibold,
        TextSize = 13
    }, Sidebar)
    Create("UIListLayout", {Padding = UDim.new(0, 5)}, Sidebar)

    Btn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Visible = false end
        for _, b in pairs(TabBtns) do b.TextColor3 = Color3.fromRGB(150, 150, 150) end
        Page.Visible = true
        Btn.TextColor3 = Color3.new(1, 1, 1)
    end)
    
    Tabs[name] = Page
    TabBtns[name] = Btn
    return Page
end

--// COMPONENTS
local function AddSection(name, parent)
    local Sect = Create("Frame", {
        Size = UDim2.new(0.95, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(22, 22, 22),
    }, parent)
    Create("UICorner", {CornerRadius = UDim.new(0, 6)}, Sect)
    Create("UIListLayout", {Padding = UDim.new(0, 5), HorizontalAlignment = "Center"}, Sect)
    
    local Label = Create("TextLabel", {
        Text = "  " .. name,
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1,
        TextColor3 = _G.DH_Config.UI_Theme,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = "Left"
    }, Sect)
    
    Sect.ChildAdded:Connect(function()
        local h = 30
        for _, v in pairs(Sect:GetChildren()) do
            if v:IsA("GuiObject") then h = h + v.Size.Y.Offset + 5 end
        end
        Sect.Size = UDim2.new(0.95, 0, 0, h)
    end)
    return Sect
end

local function AddToggle(name, parent, configKey)
    local Tgl = Create("TextButton", {
        Text = "  " .. name,
        Size = UDim2.new(0.9, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        TextColor3 = Color3.new(0.8, 0.8, 0.8),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = "Left"
    }, parent)
    Create("UICorner", {CornerRadius = UDim.new(0, 4)}, Tgl)
    
    local Indicator = Create("Frame", {
        Size = UDim2.new(0, 15, 0, 15),
        Position = UDim2.new(1, -25, 0.5, -7),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    }, Tgl)
    Create("UICorner", {CornerRadius = UDim.new(1, 0)}, Indicator)

    local function Update()
        local enabled = _G.DH_Config[configKey]
        TweenService:Create(Indicator, TweenInfo.new(0.3), {BackgroundColor3 = enabled and _G.DH_Config.UI_Theme or Color3.fromRGB(50, 50, 50)}):Play()
        Tgl.TextColor3 = enabled and Color3.new(1, 1, 1) or Color3.new(0.8, 0.8, 0.8)
    end
    
    Tgl.MouseButton1Click:Connect(function()
        _G.DH_Config[configKey] = not _G.DH_Config[configKey]
        Update()
    end)
    Update()
end

--// PAGE INITIALIZATION
local Home = NewTab("Profile", true)
local Combat = NewTab("Combat")
local Visuals = NewTab("Visuals")

--// PROFILE TAB
local ProfSection = AddSection("PLAYER INFO", Home)
Create("TextLabel", {
    Text = "User: " .. LocalPlayer.DisplayName .. "\nAccount Age: " .. LocalPlayer.AccountAge .. " Days",
    Size = UDim2.new(0.9, 0, 0, 40), BackgroundTransparency = 1, TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = "Left"
}, ProfSection)

--// COMBAT TAB
local AimbotSect = AddSection("AIMBOT SETTINGS", Combat)
AddToggle("Smooth Lock", AimbotSect, "Aimbot")
AddToggle("Rage Snap (Instant)", AimbotSect, "Rage")
AddToggle("Team Check", AimbotSect, "TeamCheck")
AddToggle("Visible Check", AimbotSect, "VisibleCheck")

--// VISUALS TAB
local ESPSect = AddSection("ESP SETTINGS", Visuals)
AddToggle("Enable ESP", ESPSect, "ESP")
AddToggle("Box Highlights", ESPSect, "ESP_Boxes")
AddToggle("Show Names", ESPSect, "ESP_Names")

--// AIMBOT LOGIC
local function GetClosest()
    local target, closest = nil, _G.DH_Config.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            if _G.DH_Config.TeamCheck and p.Team == LocalPlayer.Team then continue end
            if p.Character.Humanoid.Health <= 0 then continue end
            
            local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if dist < closest then
                    closest = dist
                    target = p
                end
            end
        end
    end
    return target
end

--// ESP LOGIC
local function UpdateESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            local box = char:FindFirstChild("DH_Box") or Create("Highlight", {Name = "DH_Box", FillTransparency = 0.5, OutlineColor = _G.DH_Config.UI_Theme}, char)
            box.Enabled = _G.DH_Config.ESP and _G.DH_Config.ESP_Boxes
            
            local nameTag = char:FindFirstChild("DH_Name") or Create("BillboardGui", {Name = "DH_Name", Size = UDim2.new(0, 100, 0, 50), StudsOffset = Vector3.new(0, 3, 0), AlwaysOnTop = true}, char)
            local label = nameTag:FindFirstChild("Label") or Create("TextLabel", {Name = "Label", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 12}, nameTag)
            label.Text = p.DisplayName
            nameTag.Enabled = _G.DH_Config.ESP and _G.DH_Config.ESP_Names
        end
    end
end

--// LOOP
RunService.RenderStepped:Connect(function()
    if _G.DH_Config.Aimbot or _G.DH_Config.Rage then
        local t = GetClosest()
        if t and t.Character:FindFirstChild(_G.DH_Config.TargetPart) then
            local goal = CFrame.lookAt(Camera.CFrame.Position, t.Character[_G.DH_Config.TargetPart].Position)
            if _G.DH_Config.Rage then
                Camera.CFrame = goal
            else
                Camera.CFrame = Camera.CFrame:Lerp(goal, _G.DH_Config.Smoothness)
            end
        end
    end
    UpdateESP()
end)

--// DRAGGABLE
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

--// INITIALIZE
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame:TweenSize(UDim2.new(0, 520, 0, 340), "Out", "Back", 0.7)
