local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

--// SETTINGS
local _G = {
    FocusEnabled = false,
    RageEnabled = false,
    Smoothness = 0.1,
    ESPEnabled = false,
    CurrentTab = "Home"
}

--// UTILS
local function Create(cls, props, parent)
    local obj = Instance.new(cls)
    for i, v in pairs(props) do obj[i] = v end
    if parent then obj.Parent = parent end
    return obj
end

--// UI INITIALIZATION
local ScreenGui = Create("ScreenGui", {Name = "DiamondHub", ResetOnSpawn = false})
pcall(function() ScreenGui.Parent = gethui() or LocalPlayer.PlayerGui end)

local MainFrame = Create("Frame", {
    Size = UDim2.new(0, 0, 0, 0), -- Start at 0 for animation
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundColor3 = Color3.fromRGB(25, 25, 25),
    BorderSizePixel = 0,
    ClipsDescendants = true,
    AnchorPoint = Vector2.new(0.5, 0.5)
}, ScreenGui)
Create("UICorner", {CornerRadius = UDim.new(0, 8)}, MainFrame)

local SideBar = Create("Frame", {
    Size = UDim2.new(0, 120, 1, 0),
    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
    BorderSizePixel = 0
}, MainFrame)
Create("UICorner", {CornerRadius = UDim.new(0, 8)}, SideBar)

local Container = Create("Frame", {
    Size = UDim2.new(1, -130, 1, -10),
    Position = UDim2.new(0, 125, 0, 5),
    BackgroundTransparency = 1
}, MainFrame)

--// TABS SETUP
local Tabs = {
    Home = Create("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = true, CanvasSize = UDim2.new(0,0,0,0)}, Container),
    Combat = Create("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, CanvasSize = UDim2.new(0,0,0,0)}, Container),
    Visuals = Create("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, CanvasSize = UDim2.new(0,0,0,0)}, Container)
}

--// PROFILE CONTENT
Create("TextLabel", {
    Text = "YOUR PROFILE", Size = UDim2.new(1, 0, 0, 20),
    TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold,
    TextSize = 14, BackgroundTransparency = 1, TextXAlignment = "Left"
}, Tabs.Home)

local pImg = Create("ImageLabel", {
    Size = UDim2.new(0, 60, 0, 60), Position = UDim2.new(0, 0, 0, 30),
    Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150",
    BackgroundColor3 = Color3.fromRGB(40,40,40)
}, Tabs.Home)
Create("UICorner", {CornerRadius = UDim.new(1,0)}, pImg)

Create("TextLabel", {
    Text = "User: "..LocalPlayer.DisplayName.."\nID: "..LocalPlayer.UserId.."\nAge: "..LocalPlayer.AccountAge.." days",
    Size = UDim2.new(1, -70, 0, 60), Position = UDim2.new(0, 70, 0, 30),
    TextColor3 = Color3.new(0.8, 0.8, 0.8), Font = Enum.Font.Gotham,
    TextSize = 12, BackgroundTransparency = 1, TextXAlignment = "Left"
}, Tabs.Home)

--// UI TOGGLE COMPONENT
local function AddToggle(name, parent, callback)
    local btn = Create("TextButton", {
        Text = "  " .. name, Size = UDim2.new(0.95, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35), TextColor3 = Color3.new(0.6, 0.6, 0.6),
        Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = "Left"
    }, parent)
    Create("UICorner", {CornerRadius = UDim.new(0, 4)}, btn)
    local status = Create("Frame", {
        Size = UDim2.new(0, 4, 0.6, 0), Position = UDim2.new(1, -8, 0.2, 0),
        BackgroundColor3 = Color3.fromRGB(255, 50, 50), BorderSizePixel = 0
    }, btn)

    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        status.BackgroundColor3 = enabled and Color3.fromRGB(50, 255, 100) or Color3.fromRGB(255, 50, 50)
        btn.TextColor3 = enabled and Color3.new(1,1,1) or Color3.new(0.6, 0.6, 0.6)
        callback(enabled)
    end)
    Create("UIListLayout", {Padding = UDim.new(0, 5)}, parent)
end

--// COMBAT & VISUALS TOGGLES
AddToggle("Smooth Focus (Legit)", Tabs.Combat, function(v) _G.FocusEnabled = v end)
AddToggle("Ragebot (Instant Snap)", Tabs.Combat, function(v) _G.RageEnabled = v end)
AddToggle("Player ESP (Boxes/Names)", Tabs.Visuals, function(v) _G.ESPEnabled = v end)

--// SIDEBAR BUTTONS
local function AddTabBtn(name, icon)
    local b = Create("TextButton", {
        Text = " " .. name, Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1, TextColor3 = Color3.new(0.7,0.7,0.7),
        Font = Enum.Font.GothamSemibold, TextSize = 12
    }, SideBar)
    b.MouseButton1Click:Connect(function()
        for i, v in pairs(Tabs) do v.Visible = (i == name) end
    end)
end
AddTabBtn("Home")
AddTabBtn("Combat")
AddTabBtn("Visuals")
Create("UIListLayout", {Padding = UDim.new(0, 2)}, SideBar)

--// LOGIC: TARGETING
local function getTarget()
    local nearest, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") then
            if p.Character.Humanoid.Health > 0 then
                local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if vis then
                    local mDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if mDist < dist then
                        nearest = p
                        dist = mDist
                    end
                end
            end
        end
    end
    return nearest
end

--// LOGIC: ESP
local function updateESP()
    for _, p in pairs(Players:GetPlayers()) do
        local char = p.Character
        if p ~= LocalPlayer and char and char:FindFirstChild("HumanoidRootPart") then
            local highlight = char:FindFirstChild("DH_ESP") or Create("Highlight", {Name = "DH_ESP", FillTransparency = 0.5, OutlineColor = Color3.new(1,1,1)}, char)
            highlight.Enabled = _G.ESPEnabled
        end
    end
end

--// MAIN LOOP
RunService.RenderStepped:Connect(function()
    if _G.FocusEnabled or _G.RageEnabled then
        local t = getTarget()
        if t and t.Character and t.Character:FindFirstChild("Head") then
            local goal = CFrame.lookAt(Camera.CFrame.Position, t.Character.Head.Position)
            if _G.RageEnabled then
                Camera.CFrame = goal
            else
                Camera.CFrame = Camera.CFrame:Lerp(goal, _G.Smoothness)
            end
        end
    end
    updateESP()
end)

--// INTRO ANIMATION
MainFrame:TweenSize(UDim2.new(0, 400, 0, 250), "Out", "Back", 0.6, true)
