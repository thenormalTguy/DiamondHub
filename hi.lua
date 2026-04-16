local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// SETTINGS & CONFIGURATION
_G.DH_Config = {
    -- Combat
    SmoothEnabled = false,
    RageEnabled = false,
    SilentAimEnabled = false,
    Smoothness = 0.15,
    AimbotFOV = 100,
    AimPart = "Head", -- "Head" or "Torso"
    TeamCheck = true,
    VisibleCheck = true,
    
    -- Visuals
    ESPEnabled = false,
    ESPBoxes = true,
    ESPNames = true,
    ESPDistance = true,
    ESPTeammates = false,
    ESPTeamColors = true,
    ESPColor_Enemy = Color3.fromRGB(255, 50, 50),
    ESPColor_Team = Color3.fromRGB(50, 255, 100),
    
    -- UI
    Draggable = true,
    OpenCloseKey = Enum.KeyCode.Insert
}

--// UTILS
local function Create(cls, props, parent)
    local obj = Instance.new(cls)
    for i, v in pairs(props) do obj[i] = v end
    if parent then obj.Parent = parent end
    return obj
end

local function ApplyCorner(obj, rad)
    Create("UICorner", {CornerRadius = UDim.new(0, rad or 6)}, obj)
end

--// UI INITIALIZATION
local ScreenGui = Create("ScreenGui", {Name = "DiamondHub", ResetOnSpawn = false})
pcall(function() ScreenGui.Parent = gethui() or LocalPlayer.PlayerGui end)

local MainFrame = Create("Frame", {
    Size = UDim2.new(0, 0, 0, 0), -- Start at 0 for animation
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundColor3 = Color3.fromRGB(28, 28, 28),
    BorderSizePixel = 0,
    ClipsDescendants = true,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Active = true
}, ScreenGui)
ApplyCorner(MainFrame, 8)

local SideBar = Create("Frame", {
    Size = UDim2.new(0, 130, 1, 0),
    BackgroundColor3 = Color3.fromRGB(23, 23, 23),
    BorderSizePixel = 0
}, MainFrame)
ApplyCorner(SideBar, 8)

local Container = Create("Frame", {
    Size = UDim2.new(1, -140, 1, -10),
    Position = UDim2.new(0, 135, 0, 5),
    BackgroundTransparency = 1
}, MainFrame)

local StatusLabel = Create("TextLabel", {
    Text = "Idle", Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 1, -25),
    TextColor3 = Color3.fromRGB(150, 150, 150), Font = Enum.Font.Gotham,
    TextSize = 11, BackgroundTransparency = 1, TextXAlignment = "Left"
}, Container)

--// UI STATE & TABS
local UILib = {Tabs = {}, TabButtons = {}}

local function CreateTab(name, iconId)
    local tab = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -30), BackgroundTransparency = 1,
        Visible = false, CanvasSize = UDim2.new(0,0,0,0), Name = name .. "Tab"
    }, Container)
    Create("UIListLayout", {Padding = UDim.new(0, 6)}, tab)
    UILib.Tabs[name] = tab
    
    local btn = Create("TextButton", {
        Text = "  " .. name, Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1, TextColor3 = Color3.new(0.6,0.6,0.6),
        Font = Enum.Font.GothamSemibold, TextSize = 12, TextXAlignment = "Left",
        Name = name .. "Btn"
    }, SideBar)
    if iconId then
        Create("ImageLabel", {
            Image = iconId, Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 10, 0.5, -8), BackgroundTransparency = 1
        }, btn)
    end
    
    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(UILib.Tabs) do v.Visible = false end
        for _, v in pairs(UILib.TabButtons) do v.TextColor3 = Color3.new(0.6,0.6,0.6) end
        tab.Visible = true
        btn.TextColor3 = Color3.new(1,1,1)
    end)
    UILib.TabButtons[name] = btn
    return tab
end

--// UI COMPONENTS
function UILib:addSection(name, parent)
    local frame = Create("Frame", {
        Size = UDim2.new(0.98, 0, 0, 0), BackgroundTransparency = 1, Name = name
    }, parent)
    Create("UIListLayout", {Padding = UDim.new(0, 4)}, frame)
    
    Create("TextLabel", {
        Text = string.upper(name), Size = UDim2.new(1, 0, 0, 16),
        TextColor3 = Color3.fromRGB(100, 100, 100), Font = Enum.Font.GothamBold,
        TextSize = 10, BackgroundTransparency = 1, TextXAlignment = "Left"
    }, frame)
    
    frame.ChildAdded:Connect(function()
        local height = 20
        for _, v in ipairs(frame:GetChildren()) do if v:IsA("GuiObject") then height = height + v.Size.Y.Offset + 4 end end
        frame.Size = UDim2.new(0.98, 0, 0, height)
    end)
    return frame
end

function UILib:addToggle(name, parent, configKey, callback)
    local btn = Create("TextButton", {
        Text = "  " .. name, Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35), TextColor3 = Color3.new(0.6, 0.6, 0.6),
        Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = "Left"
    }, parent)
    ApplyCorner(btn, 5)
    
    local status = Create("Frame", {
        Size = UDim2.new(0, 5, 0.6, 0), Position = UDim2.new(1, -10, 0.2, 0),
        BackgroundColor3 = Color3.fromRGB(200, 50, 50), BorderSizePixel = 0
    }, btn)
    ApplyCorner(status, 2)

    local function updateStatus()
        local enabled = _G.DH_Config[configKey]
        status.BackgroundColor3 = enabled and Color3.fromRGB(50, 200, 80) or Color3.fromRGB(200, 50, 50)
        btn.TextColor3 = enabled and Color3.new(1,1,1) or Color3.new(0.6, 0.6, 0.6)
        if callback then callback(enabled) end
    end
    btn.MouseButton1Click:Connect(function() _G.DH_Config[configKey] = not _G.DH_Config[configKey]; updateStatus() end)
    updateStatus()
end

function UILib:addSlider(name, parent, configKey, min, max, precise, callback)
    local frame = Create("Frame", {Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Color3.fromRGB(35, 35, 35)}, parent)
    ApplyCorner(frame, 5)
    local label = Create("TextLabel", {Text = "  " .. name, Size = UDim2.new(0.6, 0, 1, 0), BackgroundTransparency = 1, TextColor3 = Color3.new(0.6,0.6,0.6), Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = "Left"}, frame)
    local valLabel = Create("TextLabel", {Size = UDim2.new(0.3, 0, 1, 0), Position = UDim2.new(0.7, -10, 0, 0), BackgroundTransparency = 1, TextColor3 = Color3.new(0.6,0.6,0.6), Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = "Right"}, frame)
    local val = _G.DH_Config[configKey]
    valLabel.Text = (precise and string.format("%.2f", val) or math.round(val))
end

function UILib:addDropdown(name, parent, configKey, options, callback)
    local frame = Create("Frame", {Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Color3.fromRGB(35, 35, 35)}, parent)
    ApplyCorner(frame, 5)
    local label = Create("TextLabel", {Text = "  " .. name, Size = UDim2.new(0.5, 0, 1, 0), BackgroundTransparency = 1, TextColor3 = Color3.new(0.6,0.6,0.6), Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = "Left"}, frame)
    local valBtn = Create("TextButton", {Text = _G.DH_Config[configKey], Size = UDim2.new(0.4, 0, 1, 0), Position = UDim2.new(0.5, 10, 0, 0), BackgroundColor3 = Color3.fromRGB(45,45,45), TextColor3 = Color3.new(1,1,1), Font = Enum.Font.Gotham, TextSize = 11}, frame)
    ApplyCorner(valBtn, 3)
    valBtn.MouseButton1Click:Connect(function()
        local currentIdx = table.find(options, _G.DH_Config[configKey])
        local nextIdx = (currentIdx % #options) + 1
        local nextVal = options[nextIdx]
        _G.DH_Config[configKey] = nextVal
        valBtn.Text = nextVal
        if callback then callback(nextVal) end
    end)
end

function UILib:addColorPicker(name, parent, configKey, callback)
    local frame = Create("Frame", {Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Color3.fromRGB(35, 35, 35)}, parent)
    ApplyCorner(frame, 5)
    local label = Create("TextLabel", {Text = "  " .. name, Size = UDim2.new(0.6, 0, 1, 0), BackgroundTransparency = 1, TextColor3 = Color3.new(0.6,0.6,0.6), Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = "Left"}, frame)
    local valBtn = Create("TextButton", {Text = " ", Size = UDim2.new(0, 30, 0, 20), Position = UDim2.new(1, -40, 0.5, -10), BackgroundColor3 = _G.DH_Config[configKey], TextColor3 = Color3.new(1,1,1), Font = Enum.Font.Gotham, TextSize = 11}, frame)
    ApplyCorner(valBtn, 3)
end

--// TABS SETUP
CreateTab("Main", "rbxassetid://10734950309")
local combatTab = CreateTab("Combat", "rbxassetid://10747372992")
local visualsTab = CreateTab("Visuals", "rbxassetid://10747374131")
local settingsTab = CreateTab("Settings", "rbxassetid://10734950020")

--// DRAGGING
local dragStart, startPos = nil, nil
local function updateDrag(input)
    if not _G.DH_Config.Draggable then return end
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragStart = nil end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragStart then updateDrag(input) end
    end
end)

--// KEYBIND OPEN/CLOSE
local isUIOpen = true
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == _G.DH_Config.OpenCloseKey then
        isUIOpen = not isUIOpen
        ScreenGui.Enabled = isUIOpen
    end
end)

--// MAIN CONTENT
Create("TextLabel", {Text = "💎 YOUR PROFILE", Size = UDim2.new(1, 0, 0, 24), TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 14, BackgroundTransparency = 1, TextXAlignment = "Left"}, UILib.Tabs.Main)
local pFrame = Create("Frame", {Size = UDim2.new(1, 0, 0, 70), BackgroundColor3 = Color3.fromRGB(35, 35, 35)}, UILib.Tabs.Main) ApplyCorner(pFrame, 6)
local pImg = Create("ImageLabel", {Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0, 10, 0.5, -25), Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150", BackgroundTransparency = 1}, pFrame) ApplyCorner(pImg, 25)
Create("TextLabel", {Text = "<b>" .. LocalPlayer.DisplayName .. "</b>\n" .. LocalPlayer.Name .. "\nID: " .. LocalPlayer.UserId .. "\nAge: " .. LocalPlayer.AccountAge .. " days", Size = UDim2.new(1, -70, 1, 0), Position = UDim2.new(0, 70, 0, 0), TextColor3 = Color3.new(0.8, 0.8, 0.8), Font = Enum.Font.Gotham, TextSize = 12, BackgroundTransparency = 1, TextXAlignment = "Left", RichText = true}, pFrame)
local hubInfo = Create("Frame", {Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Color3.fromRGB(35, 35, 35)}, UILib.Tabs.Main) ApplyCorner(hubInfo, 6)
Create("TextLabel", {Text = "<b>💎 DiamondHub V3</b>\nStatus: Premium - Undetected\nPremium Aimbot, ESP & Silent Aim Provider", Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0), TextColor3 = Color3.new(0.8, 0.8, 0.8), Font = Enum.Font.Gotham, TextSize = 12, BackgroundTransparency = 1, TextXAlignment = "Left", RichText = true}, hubInfo)
Create("UIListLayout", {Padding = UDim.new(0, 6)}, UILib.Tabs.Main)

--// COMBAT TOGGLES
local aimbotSection = UILib:addSection("Aimbot Settings", combatTab)
UILib:addToggle("Smooth Focus (Legit)", aimbotSection, "SmoothEnabled")
UILib:addToggle("Ragebot (Auto-Kill)", aimbotSection, "RageEnabled")
UILib:addToggle("Silent Aim (Target Provider)", aimbotSection, "SilentAimEnabled")
UILib:addToggle("Team Check", aimbotSection, "TeamCheck")
UILib:addToggle("Visibility Check", aimbotSection, "VisibleCheck")
local aimbotConfigSection = UILib:addSection("Configuration", combatTab)
UILib:addSlider("Smoothness", aimbotConfigSection, "Smoothness", 0, 1, true)
UILib:addSlider("Aimbot FOV Radius", aimbotConfigSection, "AimbotFOV", 0, 500)
UILib:addDropdown("Aim Part", aimbotConfigSection, "AimPart", {"Head", "Torso"})

--// VISUALS TOGGLES
local espMainSection = UILib:addSection("Player Visuals", visualsTab)
UILib:addToggle("Enable Player ESP", espMainSection, "ESPEnabled")
UILib:addToggle("Boxes (Highlights)", espMainSection, "ESPBoxes")
UILib:addToggle("Player Names", espMainSection, "ESPNames")
UILib:addToggle("Distance", espMainSection, "ESPDistance")
UILib:addToggle("Teammate ESP", espMainSection, "ESPTeammates")
UILib:addToggle("Team Colors Mode", espMainSection, "ESPTeamColors")
local espColorSection = UILib:addSection("Colors", visualsTab)
UILib:addColorPicker("Enemy Color", espColorSection, "ESPColor_Enemy")
UILib:addColorPicker("Team Color", espColorSection, "ESPColor_Team")

--// SETTINGS TOGGLES
local uiMainSection = UILib:addSection("UI Settings", settingsTab)
UILib:addToggle("Draggable UI", uiMainSection, "Draggable")
Create("TextLabel", {Text = "  Change Keybind:", Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Color3.fromRGB(35, 35, 35), TextColor3 = Color3.new(0.6,0.6,0.6), Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = "Left"}, uiMainSection)
ApplyCorner(uiMainSection:GetChildren()[#uiMainSection:GetChildren()], 5)
Create("UIListLayout", {Padding = UDim.new(0, 6)}, settingsTab)

--// FOV CIRCLE
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Thickness = 1.5
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.NumSides = 32

--// LOGIC: TARGETING
local function isVisible(player)
    local char = player.Character
    if not char then return false end
    local head = char:FindFirstChild("Head")
    if not head then return false end
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, char}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    local origin = Camera.CFrame.Position
    local dest = head.Position
    local result = workspace:Raycast(origin, dest - origin, raycastParams)
    return result == nil
end

local function isTeam(player)
    return LocalPlayer.Team ~= nil and player.Team ~= nil and player.Team == LocalPlayer.Team
end

_G.DHSilentAimTargetPosition = nil -- Initialized target global

local function getTarget()
    local nearest, dist = nil, math.huge
    local maxDist = _G.DH_Config.AimbotFOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(_G.DH_Config.AimPart) and p.Character:FindFirstChild("Humanoid") then
            if p.Character.Humanoid.Health > 0 then
                if not _G.DH_Config.TeamCheck or not isTeam(p) then
                    if not _G.DH_Config.VisibleCheck or isVisible(p) then
                        local pos, vis = Camera:WorldToViewportPoint(p.Character[_G.DH_Config.AimPart].Position)
                        if vis then
                            local mDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                            if mDist < dist and mDist < maxDist then
                                nearest = p
                                dist = mDist
                            end
                        end
                    end
                end
            end
        end
    end
    return nearest
end

--// LOGIC: ESP
local function getESPColor(player)
    if not _G.DH_Config.ESPTeamColors then return _G.DH_Config.ESPColor_Enemy end
    return isTeam(player) and _G.DH_Config.ESPColor_Team or _G.DH_Config.ESPColor_Enemy
end

local function updateESP()
    for _, p in pairs(Players:GetPlayers()) do
        local char = p.Character
        if p ~= LocalPlayer and char and char:FindFirstChild("HumanoidRootPart") then
            local isTeammate = isTeam(p)
            local shouldESP = _G.DH_Config.ESPEnabled and (not isTeammate or _G.DH_Config.ESPTeammates)
            local color = getESPColor(p)
            local highlight = char:FindFirstChild("DH_ESP") or Create("Highlight", {Name = "DH_ESP", FillTransparency = 0.5}, char)
            highlight.Enabled = shouldESP and _G.DH_Config.ESPBoxes
            highlight.OutlineColor = color
            local bb = char:FindFirstChild("DH_NameESP") or Create("BillboardGui", {Name = "DH_NameESP", Size = UDim2.new(0, 100, 0, 40), StudsOffset = Vector3.new(0, 3.5, 0), AlwaysOnTop = true}, char)
            local valText = ""
            if _G.DH_Config.ESPNames then valText = p.DisplayName .. "\n" end
            if _G.DH_Config.ESPDistance then valText = valText .. math.round((p.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) .. " Studs" end
            local label = bb:FindFirstChild("TextLabel") or Create("TextLabel", {Size = UDim2.new(1, 0, 1, 0), TextStrokeTransparency = 0, BackgroundTransparency = 1, TextColor3 = color, Font = Enum.Font.GothamSemibold, TextSize = 12}, bb)
            label.Text = valText
            bb.Enabled = shouldESP and (_G.DH_Config.ESPNames or _G.DH_Config.ESPDistance)
        end
    end
end

--// MAIN LOOP
RunService.RenderStepped:Connect(function()
    local target = getTarget()
    
    -- Silent Aim Target Provider
    if _G.DH_Config.SilentAimEnabled and target and target.Character and target.Character:FindFirstChild(_G.DH_Config.AimPart) then
        _G.DHSilentAimTargetPosition = target.Character[_G.DH_Config.AimPart].Position
    else
        _G.DHSilentAimTargetPosition = nil
    end
    
    -- Aimbot Logic
    if _G.DH_Config.SmoothEnabled or _G.DH_Config.RageEnabled then
        if target and target.Character and target.Character:FindFirstChild(_G.DH_Config.AimPart) then
            local goal = CFrame.lookAt(Camera.CFrame.Position, target.Character[_G.DH_Config.AimPart].Position)
            if _G.DH_Config.RageEnabled then
                Camera.CFrame = goal
                StatusLabel.Text = "Targeting [R]: " .. target.DisplayName
            else
                Camera.CFrame = Camera.CFrame:Lerp(goal, _G.DH_Config.Smoothness)
                StatusLabel.Text = "Targeting [S]: " .. target.DisplayName
            
            end
        else
            StatusLabel.Text = "No target"
        end
    else
        StatusLabel.Text = "Combat is disabled"
    end
    
    -- FOV Update
    fovCircle.Visible = (_G.DH_Config.SmoothEnabled or _G.DH_Config.RageEnabled)
    fovCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
    fovCircle.Radius = _G.DH_Config.AimbotFOV
    
    -- ESP Update
    updateESP()
end)

--// INTRO ANIMATION & INITIALIZATION
applyIntro = function()
    pFrame.Visible = false
    hubInfo.Visible = false
    for _,v in pairs(combatTab:GetChildren()) do if v:IsA("Frame") then v.Visible = false end end
    MainFrame:TweenSize(UDim2.new(0, 430, 0, 280), "Out", "Back", 0.8, true)
    wait(0.6)
    MainFrame.ClipsDescendants = false
    wait(0.2)
    pFrame.Visible = true
    hubInfo.Visible = true
    for _,v in pairs(combatTab:GetChildren()) do if v:IsA("Frame") then v.Visible = true end end
    wait(0.2)
    UILib.Tabs.Main.Visible = true
    UILib.TabButtons.Main.TextColor3 = Color3.new(1,1,1)
end
task.spawn(applyIntro)
