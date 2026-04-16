--// DIAMOND HUB — Script Hub
--// Version: 2.0 | Hub Edition

local success, err = pcall(function()

    --// SERVICES
    local Players         = game:GetService("Players")
    local RunService      = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local TweenService    = game:GetService("TweenService")
    local LocalPlayer     = Players.LocalPlayer
    local Camera          = workspace.CurrentCamera
    local Mouse           = LocalPlayer:GetMouse()

    --// ACCENT
    local ACCENT = Color3.fromRGB(0, 170, 255)
    local ACCENT_DARK = Color3.fromRGB(0, 120, 200)
    local BG_MAIN   = Color3.fromRGB(10, 10, 12)
    local BG_PANEL  = Color3.fromRGB(16, 16, 20)
    local BG_CARD   = Color3.fromRGB(22, 22, 28)
    local BG_ITEM   = Color3.fromRGB(28, 28, 36)
    local TEXT_DIM  = Color3.fromRGB(140, 140, 160)

    --// GUI ROOT
    local function GetGui()
        if gethui then return gethui() end
        local cg = game:GetService("CoreGui")
        if cg:FindFirstChild("RobloxGui") then return cg.RobloxGui end
        return LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Full cleanup on re-execution
    if getgenv().DiamondHub_Loaded then
        local old = GetGui():FindFirstChild("DiamondHub_V2")
        if old then old:Destroy() end
        -- Disconnect all stored connections from previous run
        if getgenv().DiamondHub_Connections then
            for _, conn in pairs(getgenv().DiamondHub_Connections) do
                pcall(function() conn:Disconnect() end)
            end
        end
        -- Signal any running coroutines to stop
        getgenv().DiamondHub_Active = false
        task.wait(0.05)
    end
    getgenv().DiamondHub_Loaded = true
    getgenv().DiamondHub_Active = true
    getgenv().DiamondHub_Connections = {}

    local ScreenGui = Instance.new("ScreenGui", GetGui())
    ScreenGui.Name = "DiamondHub_V2"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    --// ============================================================
    --//  HELPERS
    --// ============================================================

    local function MakeCorner(parent, radius)
        local c = Instance.new("UICorner", parent)
        c.CornerRadius = UDim.new(0, radius or 10)
        return c
    end

    local function MakeStroke(parent, color, thickness, transparency)
        local s = Instance.new("UIStroke", parent)
        s.Color = color or ACCENT
        s.Thickness = thickness or 1
        s.Transparency = transparency or 0.6
        return s
    end

    local function MakeLabel(parent, props)
        local l = Instance.new("TextLabel", parent)
        l.BackgroundTransparency = 1
        l.Font = props.Font or Enum.Font.GothamBold
        l.TextColor3 = props.TextColor3 or Color3.new(1,1,1)
        l.TextSize = props.TextSize or 16
        l.Text = props.Text or ""
        l.Size = props.Size or UDim2.new(1,0,0,30)
        l.Position = props.Position or UDim2.new(0,0,0,0)
        l.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Center
        l.TextWrapped = props.TextWrapped or false
        l.RichText = props.RichText or false
        return l
    end

    local function MakeButton(parent, props)
        local b = Instance.new("TextButton", parent)
        b.BackgroundColor3 = props.BackgroundColor3 or ACCENT
        b.TextColor3 = props.TextColor3 or Color3.new(1,1,1)
        b.Font = props.Font or Enum.Font.GothamBold
        b.TextSize = props.TextSize or 16
        b.Text = props.Text or ""
        b.Size = props.Size or UDim2.new(1,0,0,40)
        b.Position = props.Position or UDim2.new(0,0,0,0)
        b.AutoButtonColor = false
        b.BorderSizePixel = 0
        if props.Radius ~= false then MakeCorner(b, props.Radius or 10) end
        return b
    end

    local function MakeFrame(parent, props)
        local f = Instance.new("Frame", parent)
        f.BackgroundColor3 = props.BackgroundColor3 or BG_MAIN
        f.BorderSizePixel = 0
        f.Size = props.Size or UDim2.new(1,0,1,0)
        f.Position = props.Position or UDim2.new(0,0,0,0)
        if props.Radius then MakeCorner(f, props.Radius) end
        if props.Transparency then f.BackgroundTransparency = props.Transparency end
        return f
    end

    local function Tween(obj, t, props, style, dir)
        local info = TweenInfo.new(t, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
        local tw = TweenService:Create(obj, info, props)
        tw:Play()
        return tw
    end

    --// ============================================================
    --//  SCREEN 1 — LOADING SPLASH
    --// ============================================================

    local LoadingFrame = MakeFrame(ScreenGui, {BackgroundColor3 = BG_MAIN})
    LoadingFrame.Size = UDim2.new(1,0,1,0)
    LoadingFrame.ZIndex = 100

    -- Centered content container
    local LoadCenter = MakeFrame(LoadingFrame, {BackgroundColor3 = Color3.new(0,0,0), Transparency = 1})
    LoadCenter.Size = UDim2.new(0, 420, 0, 220)
    LoadCenter.Position = UDim2.new(0.5, -210, 0.5, -110)

    -- Diamond logo
    local DiamondIcon = MakeLabel(LoadCenter, {
        Text = "💎",
        TextSize = 64,
        Size = UDim2.new(1,0,0,80),
        Position = UDim2.new(0,0,0,0),
    })

    -- Title
    local LoadTitle = MakeLabel(LoadCenter, {
        Text = "DIAMOND HUB",
        TextSize = 30,
        Font = Enum.Font.GothamBlack,
        TextColor3 = Color3.new(1,1,1),
        Size = UDim2.new(1,0,0,40),
        Position = UDim2.new(0,0,0,82),
        RichText = true,
    })

    -- Subtitle animated dots
    local LoadSub = MakeLabel(LoadCenter, {
        Text = "Loading",
        TextSize = 15,
        Font = Enum.Font.GothamMedium,
        TextColor3 = TEXT_DIM,
        Size = UDim2.new(1,0,0,24),
        Position = UDim2.new(0,0,0,122),
    })

    -- Progress bar background
    local ProgressBG = MakeFrame(LoadCenter, {
        BackgroundColor3 = Color3.fromRGB(30,30,40),
        Size = UDim2.new(1,0,0,4),
        Position = UDim2.new(0,0,0,162),
        Radius = 4,
    })

    local ProgressFill = MakeFrame(ProgressBG, {
        BackgroundColor3 = ACCENT,
        Size = UDim2.new(0,0,1,0),
        Radius = 4,
    })

    -- Signature
    MakeLabel(LoadCenter, {
        Text = "v2.0 Hub Edition",
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextColor3 = Color3.fromRGB(60,60,80),
        Size = UDim2.new(1,0,0,20),
        Position = UDim2.new(0,0,0,190),
    })

    -- Animate icon: fade in + gentle pulse, size stays fixed so text is never clipped
    DiamondIcon.TextTransparency = 1
    Tween(DiamondIcon, 0.6, {TextTransparency = 0}, Enum.EasingStyle.Quad)
    task.spawn(function()
        task.wait(0.1)
        Tween(DiamondIcon, 0.45, {TextSize = 72}, Enum.EasingStyle.Sine)
        task.wait(0.45)
        Tween(DiamondIcon, 0.4, {TextSize = 64}, Enum.EasingStyle.Sine)
    end)

    LoadTitle.TextTransparency = 1
    task.delay(0.3, function() Tween(LoadTitle, 0.5, {TextTransparency = 0}) end)

    LoadSub.TextTransparency = 1
    task.delay(0.5, function() Tween(LoadSub, 0.4, {TextTransparency = 0}) end)

    -- Animate dots (stops when hub is no longer active)
    local dotCount = 0
    task.spawn(function()
        while getgenv().DiamondHub_Active and LoadingFrame.Parent do
            dotCount = (dotCount % 3) + 1
            LoadSub.Text = "Loading" .. string.rep(".", dotCount)
            task.wait(0.4)
        end
    end)

    -- Progress bar tween over 2 seconds
    ProgressBG.BackgroundTransparency = 1
    task.delay(0.5, function()
        Tween(ProgressBG, 0.2, {BackgroundTransparency = 0})
        Tween(ProgressFill, 2.0, {Size = UDim2.new(1,0,1,0)}, Enum.EasingStyle.Quart)
    end)

    --// ============================================================
    --//  SCREEN 2 — GAME SELECTOR HUB
    --// ============================================================

    local HubFrame = MakeFrame(ScreenGui, {BackgroundColor3 = BG_MAIN})
    HubFrame.Size = UDim2.new(0, 540, 0, 380)
    HubFrame.Position = UDim2.new(0.5, -270, 0.5, -190)
    HubFrame.Visible = false
    HubFrame.ZIndex = 10
    MakeCorner(HubFrame, 14)
    MakeStroke(HubFrame, ACCENT, 1.5, 0.3)

    -- Hub header
    local HubHeader = MakeFrame(HubFrame, {BackgroundColor3 = BG_PANEL})
    HubHeader.Size = UDim2.new(1,0,0,56)
    MakeCorner(HubHeader, 14)
    -- Fix header bottom corners
    local HubHeaderFix = MakeFrame(HubHeader, {BackgroundColor3 = BG_PANEL})
    HubHeaderFix.Size = UDim2.new(1,0,0,14)
    HubHeaderFix.Position = UDim2.new(0,0,1,-14)

    -- Accent line under header
    local HubAccentLine = MakeFrame(HubFrame, {BackgroundColor3 = ACCENT})
    HubAccentLine.Size = UDim2.new(1,0,0,2)
    HubAccentLine.Position = UDim2.new(0,0,0,56)

    -- Hub title
    local HubTitleLbl = MakeLabel(HubHeader, {
        Text = "💎  DIAMOND HUB",
        TextSize = 20,
        Font = Enum.Font.GothamBlack,
        TextColor3 = Color3.new(1,1,1),
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-110,1,0),
        Position = UDim2.new(0,18,0,0),
    })

    local HubSubLbl = MakeLabel(HubHeader, {
        Text = "Script Hub",
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextColor3 = TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,0,0,14),
        Position = UDim2.new(0,45,0,34),
    })

    -- Hub close button
    local HubCloseBtn = MakeButton(HubFrame, {
        Text = "✕",
        BackgroundColor3 = Color3.fromRGB(200,50,60),
        Size = UDim2.new(0,32,0,32),
        Position = UDim2.new(1,-46,0,12),
        Radius = 8,
        TextSize = 15,
    })

    -- Hub body
    local HubBody = MakeFrame(HubFrame, {Transparency = 1})
    HubBody.Size = UDim2.new(1,-24,1,-80)
    HubBody.Position = UDim2.new(0,12,0,68)

    -- Section label
    local GamesLabel = MakeLabel(HubBody, {
        Text = "SELECT A GAME",
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextColor3 = TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,0,0,18),
        Position = UDim2.new(0,4,0,0),
    })

    -- Scrolling list for games
    local GamesScroll = Instance.new("ScrollingFrame", HubBody)
    GamesScroll.Size = UDim2.new(1,0,1,-26)
    GamesScroll.Position = UDim2.new(0,0,0,26)
    GamesScroll.BackgroundTransparency = 1
    GamesScroll.ScrollBarThickness = 3
    GamesScroll.ScrollBarImageColor3 = ACCENT
    GamesScroll.CanvasSize = UDim2.new(0,0,0,0)
    GamesScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local GamesLayout = Instance.new("UIListLayout", GamesScroll)
    GamesLayout.Padding = UDim.new(0,10)
    GamesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    GamesLayout.SortOrder = Enum.SortOrder.LayoutOrder

    Instance.new("UIPadding", GamesScroll).PaddingTop = UDim.new(0,4)

    --// Game Card Builder
    local GameCards = {}
    local function AddGameCard(name, subtitle, emoji, onLaunch)
        local Card = MakeFrame(GamesScroll, {BackgroundColor3 = BG_CARD, Radius = 12})
        Card.Size = UDim2.new(1,-4,0,78)
        MakeStroke(Card, Color3.fromRGB(50,50,70), 1, 0.4)

        local EmojiLbl = MakeLabel(Card, {
            Text = emoji,
            TextSize = 32,
            Size = UDim2.new(0,60,1,0),
            Position = UDim2.new(0,14,0,0),
        })

        local NameLbl = MakeLabel(Card, {
            Text = name,
            TextSize = 18,
            Font = Enum.Font.GothamBold,
            TextColor3 = Color3.new(1,1,1),
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1,-170,0,26),
            Position = UDim2.new(0,76,0,14),
        })

        local SubLbl = MakeLabel(Card, {
            Text = subtitle,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextColor3 = TEXT_DIM,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1,-170,0,18),
            Position = UDim2.new(0,76,0,40),
        })

        local LaunchBtn = MakeButton(Card, {
            Text = "LAUNCH",
            BackgroundColor3 = ACCENT,
            Size = UDim2.new(0,96,0,36),
            Position = UDim2.new(1,-110,0.5,-18),
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            Radius = 8,
        })
        MakeStroke(LaunchBtn, Color3.fromRGB(100,210,255), 1, 0.5)

        -- Hover effect
        LaunchBtn.MouseEnter:Connect(function()
            Tween(LaunchBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(30,190,255)})
        end)
        LaunchBtn.MouseLeave:Connect(function()
            Tween(LaunchBtn, 0.15, {BackgroundColor3 = ACCENT})
        end)
        LaunchBtn.MouseButton1Click:Connect(function()
            onLaunch()
        end)

        -- Card hover glow
        Card.MouseEnter:Connect(function()
            Tween(Card, 0.15, {BackgroundColor3 = Color3.fromRGB(28,28,40)})
        end)
        Card.MouseLeave:Connect(function()
            Tween(Card, 0.15, {BackgroundColor3 = BG_CARD})
        end)

        table.insert(GameCards, Card)
        return Card
    end

    --// Hub drag
    local dhDragging, dhDragStart, dhStartPos
    HubHeader.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dhDragging = true; dhDragStart = i.Position; dhStartPos = HubFrame.Position
        end
    end)
    table.insert(getgenv().DiamondHub_Connections, UserInputService.InputChanged:Connect(function(i)
        if dhDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dhDragStart
            HubFrame.Position = UDim2.new(dhStartPos.X.Scale, dhStartPos.X.Offset+d.X, dhStartPos.Y.Scale, dhStartPos.Y.Offset+d.Y)
        end
    end))
    table.insert(getgenv().DiamondHub_Connections, UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dhDragging = false end
    end))

    HubCloseBtn.MouseButton1Click:Connect(function()
        Tween(HubFrame, 0.25, {BackgroundTransparency = 1})
        task.wait(0.25)
        HubFrame.Visible = false
        getgenv().DiamondHub_Active = false
        getgenv().DiamondHub_Loaded = false
        ScreenGui:Destroy()
    end)

    --// ============================================================
    --//  SCREEN 3 — GAME LOADING TRANSITION OVERLAY
    --// ============================================================

    local GameLoadFrame = MakeFrame(ScreenGui, {BackgroundColor3 = BG_MAIN})
    GameLoadFrame.Size = UDim2.new(0,360,0,180)
    GameLoadFrame.Position = UDim2.new(0.5,-180,0.5,-90)
    GameLoadFrame.Visible = false
    GameLoadFrame.ZIndex = 50
    MakeCorner(GameLoadFrame, 16)
    MakeStroke(GameLoadFrame, ACCENT, 1.5, 0.3)

    -- Spinner (rotating line)
    local SpinnerRing = MakeFrame(GameLoadFrame, {Transparency = 1})
    SpinnerRing.Size = UDim2.new(0,56,0,56)
    SpinnerRing.Position = UDim2.new(0.5,-28,0,28)

    -- Spinner visual: arc using UIStroke on a frame
    local SpinArc = Instance.new("Frame", SpinnerRing)
    SpinArc.Size = UDim2.new(1,0,1,0)
    SpinArc.BackgroundTransparency = 1
    local spinStroke = Instance.new("UIStroke", SpinArc)
    spinStroke.Color = ACCENT
    spinStroke.Thickness = 4
    spinStroke.Transparency = 0
    MakeCorner(SpinArc, 28)

    -- Inner fill to make arc look like a ring
    local SpinInner = MakeFrame(SpinnerRing, {BackgroundColor3 = BG_MAIN})
    SpinInner.Size = UDim2.new(1,-12,1,-12)
    SpinInner.Position = UDim2.new(0,6,0,6)
    MakeCorner(SpinInner, 22)

    local SpinDot = MakeFrame(SpinnerRing, {BackgroundColor3 = ACCENT, Radius = 5})
    SpinDot.Size = UDim2.new(0,10,0,10)
    SpinDot.Position = UDim2.new(0.5,-5,0,-5)

    local GameLoadTitle = MakeLabel(GameLoadFrame, {
        Text = "Loading...",
        TextSize = 22,
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.new(1,1,1),
        Size = UDim2.new(1,-20,0,30),
        Position = UDim2.new(0,10,0,96),
    })

    local GameLoadSub = MakeLabel(GameLoadFrame, {
        Text = "Please wait",
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextColor3 = TEXT_DIM,
        Size = UDim2.new(1,-20,0,20),
        Position = UDim2.new(0,10,0,128),
    })

    local GameLoadBar_BG = MakeFrame(GameLoadFrame, {BackgroundColor3 = Color3.fromRGB(30,30,40), Radius = 4})
    GameLoadBar_BG.Size = UDim2.new(1,-40,0,4)
    GameLoadBar_BG.Position = UDim2.new(0,20,0,154)

    local GameLoadBar_Fill = MakeFrame(GameLoadBar_BG, {BackgroundColor3 = ACCENT, Radius = 4})
    GameLoadBar_Fill.Size = UDim2.new(0,0,1,0)

    -- Spinner rotation (stops when hub is no longer active)
    task.spawn(function()
        local angle = 0
        while getgenv().DiamondHub_Active do
            if GameLoadFrame.Visible then
                angle = angle + 6
                SpinDot.Position = UDim2.new(
                    0.5 + math.sin(math.rad(angle))*0.5 - 0.08,
                    0,
                    0.5 - math.cos(math.rad(angle))*0.5 - 0.08,
                    0
                )
            end
            task.wait(1/60)
        end
    end)

    --// ============================================================
    --//  SCREEN 4 — RIVALS CHEAT UI (Redesigned)
    --// ============================================================

    _G.DH_Config = {
        Aimbot        = false,
        RageHitbox    = false,
        HitboxSize    = 15,
        FOV           = 250,
        ESP           = false,
        Speed         = false,
        WalkSpeedValue= 60,
        Fly           = false,
        FlySpeed      = 50,
        Noclip        = false,
    }

    local RivalsFrame = MakeFrame(ScreenGui, {BackgroundColor3 = BG_MAIN})
    RivalsFrame.Size = UDim2.new(0, 660, 0, 440)
    RivalsFrame.Position = UDim2.new(0.5,-330,0.5,-220)
    RivalsFrame.Visible = false
    RivalsFrame.ZIndex = 10
    RivalsFrame.ClipsDescendants = true
    MakeCorner(RivalsFrame, 14)
    MakeStroke(RivalsFrame, ACCENT, 1.5, 0.25)

    --// Rivals Header
    local RivalsHeader = MakeFrame(RivalsFrame, {BackgroundColor3 = BG_PANEL})
    RivalsHeader.Size = UDim2.new(1,0,0,56)
    MakeCorner(RivalsHeader, 14)
    local RivalsHeaderFix = MakeFrame(RivalsHeader, {BackgroundColor3 = BG_PANEL})
    RivalsHeaderFix.Size = UDim2.new(1,0,0,14)
    RivalsHeaderFix.Position = UDim2.new(0,0,1,-14)

    local RivalsAccentLine = MakeFrame(RivalsFrame, {BackgroundColor3 = ACCENT})
    RivalsAccentLine.Size = UDim2.new(1,0,0,2)
    RivalsAccentLine.Position = UDim2.new(0,0,0,56)

    -- Title
    MakeLabel(RivalsHeader, {
        Text = "💎  DIAMOND HUB  ›  Rivals",
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-160,1,0),
        Position = UDim2.new(0,18,0,0),
    })

    -- Back button
    local BackBtn = MakeButton(RivalsHeader, {
        Text = "← Hub",
        BackgroundColor3 = BG_ITEM,
        TextColor3 = Color3.fromRGB(180,180,200),
        Size = UDim2.new(0,70,0,32),
        Position = UDim2.new(1,-168,0,12),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        Radius = 8,
    })
    MakeStroke(BackBtn, Color3.fromRGB(60,60,90), 1, 0.3)
    BackBtn.MouseEnter:Connect(function() Tween(BackBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(38,38,50)}) end)
    BackBtn.MouseLeave:Connect(function() Tween(BackBtn, 0.15, {BackgroundColor3 = BG_ITEM}) end)

    -- Minimize
    local MinBtn = MakeButton(RivalsHeader, {
        Text = "—",
        BackgroundColor3 = BG_ITEM,
        Size = UDim2.new(0,32,0,32),
        Position = UDim2.new(1,-124,0,12),
        TextSize = 16,
        Radius = 8,
    })
    MakeStroke(MinBtn, Color3.fromRGB(60,60,90), 1, 0.4)

    -- Close
    local CloseBtn = MakeButton(RivalsHeader, {
        Text = "✕",
        BackgroundColor3 = Color3.fromRGB(200,50,60),
        Size = UDim2.new(0,32,0,32),
        Position = UDim2.new(1,-80,0,12),
        TextSize = 15,
        Radius = 8,
    })

    -- Rivals dragging
    local rDragging, rDragStart, rStartPos
    RivalsHeader.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            rDragging = true; rDragStart = i.Position; rStartPos = RivalsFrame.Position
        end
    end)
    table.insert(getgenv().DiamondHub_Connections, UserInputService.InputChanged:Connect(function(i)
        if rDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - rDragStart
            RivalsFrame.Position = UDim2.new(rStartPos.X.Scale, rStartPos.X.Offset+d.X, rStartPos.Y.Scale, rStartPos.Y.Offset+d.Y)
        end
    end))
    table.insert(getgenv().DiamondHub_Connections, UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then rDragging = false end
    end))

    --// Rivals Content
    local RivalsContent = MakeFrame(RivalsFrame, {Transparency = 1})
    RivalsContent.Size = UDim2.new(1,0,1,-60)
    RivalsContent.Position = UDim2.new(0,0,0,60)

    --// Sidebar
    local Sidebar = MakeFrame(RivalsContent, {BackgroundColor3 = BG_PANEL})
    Sidebar.Size = UDim2.new(0,168,1,0)

    local SidebarLayout = Instance.new("UIListLayout", Sidebar)
    SidebarLayout.Padding = UDim.new(0,2)
    SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    SidebarLayout.FillDirection = Enum.FillDirection.Vertical
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local SidebarPad = Instance.new("UIPadding", Sidebar)
    SidebarPad.PaddingTop = UDim.new(0,12)
    SidebarPad.PaddingBottom = UDim.new(0,8)

    -- Sidebar divider
    local SideDiv = MakeFrame(RivalsContent, {BackgroundColor3 = Color3.fromRGB(35,35,50)})
    SideDiv.Size = UDim2.new(0,1,1,0)
    SideDiv.Position = UDim2.new(0,168,0,0)

    --// Pages
    local Pages = MakeFrame(RivalsContent, {Transparency = 1})
    Pages.Size = UDim2.new(1,-180,1,0)
    Pages.Position = UDim2.new(0,176,0,0)

    local RivalsTabs = {}
    local function CreateTab(name, icon, layoutOrder, active)
        -- Page (scrolling content area)
        local Frame = Instance.new("ScrollingFrame", Pages)
        Frame.Size = UDim2.new(1,0,1,-10)
        Frame.Position = UDim2.new(0,0,0,5)
        Frame.BackgroundTransparency = 1
        Frame.Visible = active
        Frame.ScrollBarThickness = 2
        Frame.ScrollBarImageColor3 = Color3.fromRGB(60,60,90)
        Frame.CanvasSize = UDim2.new(0,0,0,0)
        Frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Frame.BorderSizePixel = 0
        local Layout = Instance.new("UIListLayout", Frame)
        Layout.Padding = UDim.new(0,8)
        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        local FPad = Instance.new("UIPadding", Frame)
        FPad.PaddingTop = UDim.new(0,10)
        FPad.PaddingLeft = UDim.new(0,12)
        FPad.PaddingRight = UDim.new(0,12)

        -- Sidebar button wrapper (for the accent bar + button together)
        local BtnWrap = Instance.new("Frame", Sidebar)
        BtnWrap.LayoutOrder = layoutOrder
        BtnWrap.Size = UDim2.new(1,0,0,38)
        BtnWrap.BackgroundTransparency = 1
        BtnWrap.BorderSizePixel = 0

        -- Thin left accent bar (only visible when active)
        local Bar = Instance.new("Frame", BtnWrap)
        Bar.Size = UDim2.new(0,3,0.6,0)
        Bar.Position = UDim2.new(0,0,0.2,0)
        Bar.BackgroundColor3 = ACCENT
        Bar.BorderSizePixel = 0
        Bar.BackgroundTransparency = active and 0 or 1
        MakeCorner(Bar, 2)

        -- Actual button
        local Btn = Instance.new("TextButton", BtnWrap)
        Btn.Size = UDim2.new(1,-12,1,0)
        Btn.Position = UDim2.new(0,8,0,0)
        Btn.BackgroundColor3 = active and Color3.fromRGB(30,32,46) or Color3.new(0,0,0)
        Btn.BackgroundTransparency = active and 0 or 1
        Btn.TextColor3 = active and Color3.new(1,1,1) or TEXT_DIM
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 13
        Btn.Text = icon .. "  " .. name
        Btn.TextXAlignment = Enum.TextXAlignment.Left
        Btn.AutoButtonColor = false
        Btn.BorderSizePixel = 0
        MakeCorner(Btn, 7)
        local BPad = Instance.new("UIPadding", Btn)
        BPad.PaddingLeft = UDim.new(0,10)

        Btn.MouseEnter:Connect(function()
            if not (RivalsTabs[name] and RivalsTabs[name].F.Visible) then
                Tween(Btn, 0.12, {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(26,26,38)})
            end
        end)
        Btn.MouseLeave:Connect(function()
            if not (RivalsTabs[name] and RivalsTabs[name].F.Visible) then
                Tween(Btn, 0.12, {BackgroundTransparency = 1})
            end
        end)

        Btn.MouseButton1Click:Connect(function()
            for n, v in pairs(RivalsTabs) do
                v.F.Visible = false
                Tween(v.B, 0.15, {BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 1, TextColor3 = TEXT_DIM})
                Tween(v.Bar, 0.15, {BackgroundTransparency = 1})
            end
            Frame.Visible = true
            Tween(Btn, 0.15, {BackgroundColor3 = Color3.fromRGB(30,32,46), BackgroundTransparency = 0, TextColor3 = Color3.new(1,1,1)})
            Tween(Bar, 0.15, {BackgroundTransparency = 0})
        end)

        RivalsTabs[name] = {F = Frame, B = Btn, Bar = Bar}
        return Frame
    end

    local HomeTab    = CreateTab("Home",      "🏠", 1, true)
    local CombatTab  = CreateTab("Combat",    "⚔️", 2, false)
    local VisualsTab = CreateTab("Visuals",   "👁", 3, false)
    local MoveTab    = CreateTab("Movement",  "⚡", 4, false)
    local ProfileTab = CreateTab("Profile",   "👤", 5, false)
    local DiscordTab = CreateTab("Discord",   "💬", 6, false)

    --// SECTION HEADER — subtle divider + label
    local function SectionHeader(parent, text)
        local wrap = MakeFrame(parent, {Transparency = 1})
        wrap.Size = UDim2.new(1,0,0,22)

        local line = MakeFrame(wrap, {BackgroundColor3 = Color3.fromRGB(38,38,54)})
        line.Size = UDim2.new(1,0,0,1)
        line.Position = UDim2.new(0,0,0.5,0)

        local lbl = MakeLabel(wrap, {
            Text = text,
            TextSize = 10,
            Font = Enum.Font.GothamBold,
            TextColor3 = Color3.fromRGB(80,80,105),
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(0,0,1,0),
        })
        lbl.AutomaticSize = Enum.AutomaticSize.X
        lbl.BackgroundColor3 = BG_MAIN
        lbl.BackgroundTransparency = 0
        local lp = Instance.new("UIPadding", lbl)
        lp.PaddingRight = UDim.new(0,6)
        lp.PaddingLeft = UDim.new(0,0)

        return wrap
    end

    --// TOGGLE
    local function AddToggle(parent, label, key)
        local Row = MakeFrame(parent, {BackgroundColor3 = BG_CARD, Radius = 10})
        Row.Size = UDim2.new(1,0,0,52)

        local Lbl = MakeLabel(Row, {
            Text = label,
            TextSize = 14,
            Font = Enum.Font.GothamMedium,
            TextColor3 = Color3.fromRGB(210,210,225),
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1,-70,1,0),
            Position = UDim2.new(0,16,0,0),
        })

        local PillBG = MakeFrame(Row, {
            BackgroundColor3 = _G.DH_Config[key] and ACCENT or Color3.fromRGB(40,40,58),
            Radius = 100,
        })
        PillBG.Size = UDim2.new(0,44,0,24)
        PillBG.Position = UDim2.new(1,-56,0.5,-12)

        local Dot = MakeFrame(PillBG, {BackgroundColor3 = Color3.new(1,1,1), Radius = 100})
        Dot.Size = UDim2.new(0,18,0,18)
        Dot.Position = _G.DH_Config[key] and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)

        local function Refresh()
            local on = _G.DH_Config[key]
            Tween(PillBG, 0.22, {BackgroundColor3 = on and ACCENT or Color3.fromRGB(40,40,58)}, Enum.EasingStyle.Quad)
            Tween(Dot, 0.22, {Position = on and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)}, Enum.EasingStyle.Back)
        end

        Row.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                _G.DH_Config[key] = not _G.DH_Config[key]
                Refresh()
            end
        end)
        Row.MouseEnter:Connect(function() Tween(Row, 0.1, {BackgroundColor3 = Color3.fromRGB(28,30,44)}) end)
        Row.MouseLeave:Connect(function() Tween(Row, 0.1, {BackgroundColor3 = BG_CARD}) end)

        return Row
    end

    --// HOME TAB — Welcome screen only, no duplicate toggles
    -- Player card
    local HomeCard = MakeFrame(HomeTab, {BackgroundColor3 = BG_CARD, Radius = 12})
    HomeCard.Size = UDim2.new(1,0,0,96)

    local HAvatarBG = MakeFrame(HomeCard, {BackgroundColor3 = BG_ITEM, Radius = 36})
    HAvatarBG.Size = UDim2.new(0,64,0,64)
    HAvatarBG.Position = UDim2.new(0,16,0.5,-32)
    MakeStroke(HAvatarBG, ACCENT, 2, 0.5)

    local HAvatar = Instance.new("ImageLabel", HomeCard)
    HAvatar.Size = UDim2.new(0,64,0,64)
    HAvatar.Position = UDim2.new(0,16,0.5,-32)
    HAvatar.BackgroundTransparency = 1
    HAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    MakeCorner(HAvatar, 32)

    MakeLabel(HomeCard, {
        Text = LocalPlayer.DisplayName,
        TextSize = 17,
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.new(1,1,1),
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-100,0,22),
        Position = UDim2.new(0,92,0,22),
    })
    MakeLabel(HomeCard, {
        Text = "@" .. LocalPlayer.Name,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextColor3 = TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-100,0,18),
        Position = UDim2.new(0,92,0,46),
    })
    MakeLabel(HomeCard, {
        Text = "Account age: " .. LocalPlayer.AccountAge .. " days",
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextColor3 = Color3.fromRGB(100,100,120),
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-100,0,16),
        Position = UDim2.new(0,92,0,68),
    })

    -- Hub info card
    local HInfoCard = MakeFrame(HomeTab, {BackgroundColor3 = BG_CARD, Radius = 12})
    HInfoCard.Size = UDim2.new(1,0,0,72)

    -- Left blue accent stripe
    local HStripe = MakeFrame(HInfoCard, {BackgroundColor3 = ACCENT, Radius = 4})
    HStripe.Size = UDim2.new(0,3,0.7,0)
    HStripe.Position = UDim2.new(0,12,0.15,0)

    MakeLabel(HInfoCard, {
        Text = "Diamond Hub",
        TextSize = 16,
        Font = Enum.Font.GothamBlack,
        TextColor3 = Color3.new(1,1,1),
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-80,0,22),
        Position = UDim2.new(0,26,0,14),
    })
    MakeLabel(HInfoCard, {
        Text = "Rivals Edition  •  v2.0",
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextColor3 = TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-80,0,18),
        Position = UDim2.new(0,26,0,38),
    })

    -- Status pill (top right)
    local HStatusPill = MakeFrame(HInfoCard, {BackgroundColor3 = Color3.fromRGB(20,48,28), Radius = 100})
    HStatusPill.Size = UDim2.new(0,90,0,24)
    HStatusPill.Position = UDim2.new(1,-102,0.5,-12)

    local HSDot = MakeFrame(HStatusPill, {BackgroundColor3 = Color3.fromRGB(60,230,110), Radius = 100})
    HSDot.Size = UDim2.new(0,8,0,8)
    HSDot.Position = UDim2.new(0,10,0.5,-4)

    MakeLabel(HStatusPill, {
        Text = "Active",
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.fromRGB(60,230,110),
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-24,1,0),
        Position = UDim2.new(0,24,0,0),
    })

    -- Hint
    local HHint = MakeLabel(HomeTab, {
        Text = "Use the sidebar to navigate to Combat, Visuals, and more.",
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextColor3 = Color3.fromRGB(80,80,100),
        TextXAlignment = Enum.TextXAlignment.Center,
        Size = UDim2.new(1,0,0,18),
        TextWrapped = true,
    })

    --// COMBAT TAB
    SectionHeader(CombatTab, "COMBAT")
    AddToggle(CombatTab, "Aimbot (Hard Lock)", "Aimbot")
    AddToggle(CombatTab, "Hitbox Expander", "RageHitbox")

    --// VISUALS TAB
    SectionHeader(VisualsTab, "VISUALS")
    AddToggle(VisualsTab, "ESP Highlights", "ESP")

    --// MOVEMENT TAB
    SectionHeader(MoveTab, "MOVEMENT")
    AddToggle(MoveTab, "Speed Bypass", "Speed")
    AddToggle(MoveTab, "Fly Hack (WASD)", "Fly")
    AddToggle(MoveTab, "Noclip", "Noclip")

    --// PROFILE TAB
    local PCard = MakeFrame(ProfileTab, {BackgroundColor3 = BG_CARD, Radius = 12})
    PCard.Size = UDim2.new(1,0,0,110)

    local PImg = Instance.new("ImageLabel", PCard)
    PImg.Size = UDim2.new(0,72,0,72)
    PImg.Position = UDim2.new(0,16,0.5,-36)
    PImg.BackgroundColor3 = BG_ITEM
    PImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    MakeCorner(PImg, 36)
    MakeStroke(PImg, ACCENT, 2, 0.4)

    MakeLabel(PCard, {
        Text = LocalPlayer.DisplayName,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.new(1,1,1),
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-110,0,24),
        Position = UDim2.new(0,102,0,22),
    })
    MakeLabel(PCard, {
        Text = "@" .. LocalPlayer.Name,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextColor3 = TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-110,0,18),
        Position = UDim2.new(0,102,0,48),
    })
    MakeLabel(PCard, {
        Text = "ID: " .. LocalPlayer.UserId .. "  •  Age: " .. LocalPlayer.AccountAge .. " days",
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextColor3 = TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-110,0,16),
        Position = UDim2.new(0,102,0,72),
    })

    --// DISCORD TAB
    local DiscCard = MakeFrame(DiscordTab, {BackgroundColor3 = BG_CARD, Radius = 12})
    DiscCard.Size = UDim2.new(1,0,0,116)
    MakeStroke(DiscCard, Color3.fromRGB(88,101,242), 1.5, 0.3)

    MakeLabel(DiscCard, {
        Text = "💬  Official Support Server",
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.new(1,1,1),
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-20,0,24),
        Position = UDim2.new(0,14,0,12),
    })
    MakeLabel(DiscCard, {
        Text = "Join for updates, support, and more scripts.",
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextColor3 = TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-20,0,20),
        Position = UDim2.new(0,14,0,36),
    })

    local DiscLinkBox = Instance.new("TextBox", DiscCard)
    DiscLinkBox.Size = UDim2.new(1,-20,0,36)
    DiscLinkBox.Position = UDim2.new(0,10,0,62)
    DiscLinkBox.BackgroundColor3 = BG_ITEM
    DiscLinkBox.Text = "https://discord.gg/placeholder"
    DiscLinkBox.TextColor3 = ACCENT
    DiscLinkBox.Font = Enum.Font.GothamMedium
    DiscLinkBox.TextSize = 14
    DiscLinkBox.ClearTextOnFocus = false
    DiscLinkBox.TextEditable = false
    DiscLinkBox.TextXAlignment = Enum.TextXAlignment.Left
    MakeCorner(DiscLinkBox, 8)
    local lPad = Instance.new("UIPadding", DiscLinkBox)
    lPad.PaddingLeft = UDim.new(0,10)

    local CopyBtn = MakeButton(DiscordTab, {
        Text = "Copy Invite Link",
        BackgroundColor3 = Color3.fromRGB(88,101,242),
        Size = UDim2.new(1,0,0,40),
        TextSize = 14,
        Radius = 10,
    })
    CopyBtn.MouseButton1Click:Connect(function()
        if setclipboard then setclipboard(DiscLinkBox.Text) end
        CopyBtn.Text = "✓ Copied!"
        task.wait(2)
        CopyBtn.Text = "Copy Invite Link"
    end)

    --// CLOSE & MINIMIZE HANDLERS
    local RivalsMinimized = false
    MinBtn.MouseButton1Click:Connect(function()
        RivalsMinimized = not RivalsMinimized
        if RivalsMinimized then
            RivalsContent.Visible = false
            Tween(RivalsFrame, 0.3, {Size = UDim2.new(0,660,0,60)}, Enum.EasingStyle.Quart)
        else
            Tween(RivalsFrame, 0.3, {Size = UDim2.new(0,660,0,440)}, Enum.EasingStyle.Quart)
            task.wait(0.25)
            RivalsContent.Visible = true
        end
    end)

    -- Confirm Exit popup
    local ExitOverlay = MakeFrame(RivalsFrame, {BackgroundColor3 = Color3.new(0,0,0), Transparency = 1})
    ExitOverlay.Size = UDim2.new(1,0,1,0)
    ExitOverlay.ZIndex = 200
    ExitOverlay.Visible = false

    local ExitBox = MakeFrame(ExitOverlay, {BackgroundColor3 = BG_PANEL, Radius = 12})
    ExitBox.Size = UDim2.new(0,300,0,150)
    ExitBox.Position = UDim2.new(0.5,-150,0.5,-75)
    ExitBox.ZIndex = 201
    MakeStroke(ExitBox, Color3.fromRGB(60,60,80), 1, 0.3)

    MakeLabel(ExitBox, {
        Text = "Close Diamond Hub?",
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(1,0,0,60),
        Position = UDim2.new(0,0,0,10),
    }).ZIndex = 202

    local ExitYes = MakeButton(ExitBox, {
        Text = "Close",
        BackgroundColor3 = Color3.fromRGB(200,50,60),
        Size = UDim2.new(0,110,0,38),
        Position = UDim2.new(0,16,0,80),
        TextSize = 15,
    })
    ExitYes.ZIndex = 202

    local ExitNo = MakeButton(ExitBox, {
        Text = "Cancel",
        BackgroundColor3 = BG_ITEM,
        Size = UDim2.new(0,110,0,38),
        Position = UDim2.new(1,-126,0,80),
        TextSize = 15,
    })
    ExitNo.ZIndex = 202

    CloseBtn.MouseButton1Click:Connect(function()
        ExitOverlay.Visible = true
        Tween(ExitOverlay, 0.2, {BackgroundTransparency = 0.5})
    end)
    ExitNo.MouseButton1Click:Connect(function()
        Tween(ExitOverlay, 0.15, {BackgroundTransparency = 1})
        task.wait(0.15)
        ExitOverlay.Visible = false
    end)
    ExitYes.MouseButton1Click:Connect(function()
        getgenv().DiamondHub_Active = false
        getgenv().DiamondHub_Loaded = false
        ScreenGui:Destroy()
    end)

    --// ============================================================
    --//  GAME ENGINE (Aimbot, Movement, ESP, Noclip)
    --// ============================================================

    local function GetNearest()
        local nearest, dist = nil, _G.DH_Config.FOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local head = p.Character:FindFirstChild("Head")
                if head and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                        if mag < dist then dist = mag; nearest = head end
                    end
                end
            end
        end
        return nearest
    end

    table.insert(getgenv().DiamondHub_Connections, RunService.RenderStepped:Connect(function()
        if not getgenv().DiamondHub_Active then return end
        if not RivalsFrame.Visible then return end

        if _G.DH_Config.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local t = GetNearest()
            if t then Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position) end
        end

        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            if hum then
                hum.WalkSpeed = _G.DH_Config.Speed and _G.DH_Config.WalkSpeedValue or 16
            end
            if root and _G.DH_Config.Fly then
                root.Velocity = Vector3.new(0, 2, 0)
                local move = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
                root.CFrame = root.CFrame + (move * (_G.DH_Config.FlySpeed / 15))
            end
        end

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local head = p.Character:FindFirstChild("Head")
                if head then
                    head.Size = _G.DH_Config.RageHitbox and Vector3.new(_G.DH_Config.HitboxSize,_G.DH_Config.HitboxSize,_G.DH_Config.HitboxSize) or Vector3.new(1.2,1.2,1.2)
                    head.Transparency = _G.DH_Config.RageHitbox and 0.8 or 0
                    head.CanCollide = not _G.DH_Config.RageHitbox

                    local h = p.Character:FindFirstChild("DH_High") or Instance.new("Highlight", p.Character)
                    h.Name = "DH_High"
                    h.Enabled = _G.DH_Config.ESP
                    h.FillColor = ACCENT
                end
            end
        end
    end))

    table.insert(getgenv().DiamondHub_Connections, RunService.Stepped:Connect(function()
        if not getgenv().DiamondHub_Active then return end
        if _G.DH_Config.Noclip and LocalPlayer.Character then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end))

    --// ============================================================
    --//  NAV FUNCTIONS
    --// ============================================================

    local function ShowRivals()
        HubFrame.Visible = false
        GameLoadFrame.Visible = true

        GameLoadTitle.Text = "Loading Rivals"
        GameLoadSub.Text = "Initializing scripts..."
        GameLoadBar_Fill.Size = UDim2.new(0,0,1,0)
        Tween(GameLoadBar_Fill, 1.4, {Size = UDim2.new(1,0,1,0)}, Enum.EasingStyle.Quart)

        task.wait(1.6)
        if not getgenv().DiamondHub_Active then return end

        GameLoadFrame.Visible = false

        -- Reset minimize state so Rivals always opens fully expanded
        RivalsMinimized = false
        RivalsFrame.Size = UDim2.new(0,660,0,440)
        RivalsContent.Visible = true

        RivalsFrame.Visible = true
        RivalsFrame.BackgroundTransparency = 1
        Tween(RivalsFrame, 0.35, {BackgroundTransparency = 0}, Enum.EasingStyle.Quad)
    end

    local function ShowHub()
        RivalsFrame.Visible = false
        HubFrame.Visible = true
        HubFrame.BackgroundTransparency = 1
        Tween(HubFrame, 0.3, {BackgroundTransparency = 0}, Enum.EasingStyle.Quad)
    end

    BackBtn.MouseButton1Click:Connect(ShowHub)

    --// Register games
    AddGameCard("Rivals", "Combat sports — PvP scripts", "⚔️", function()
        ShowRivals()
    end)

    --// More games placeholder card (visual only)
    local MoreCard = MakeFrame(GamesScroll, {BackgroundColor3 = Color3.fromRGB(18,18,24), Radius = 12})
    MoreCard.Size = UDim2.new(1,-4,0,56)
    MakeStroke(MoreCard, Color3.fromRGB(40,40,60), 1, 0.3)

    MakeLabel(MoreCard, {
        Text = "More games coming soon...",
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        TextColor3 = Color3.fromRGB(80,80,100),
        Size = UDim2.new(1,0,1,0),
    })

    --// ============================================================
    --//  STARTUP SEQUENCE: Loading → Hub
    --// ============================================================

    task.spawn(function()
        task.wait(2.4)
        if not getgenv().DiamondHub_Active then return end

        -- Fade out loading
        Tween(LoadingFrame, 0.4, {BackgroundTransparency = 1})
        for _, child in pairs(LoadingFrame:GetDescendants()) do
            if child:IsA("TextLabel") then
                Tween(child, 0.3, {TextTransparency = 1})
            elseif child:IsA("Frame") then
                Tween(child, 0.3, {BackgroundTransparency = 1})
            end
        end
        task.wait(0.45)
        if not getgenv().DiamondHub_Active then return end
        LoadingFrame.Visible = false

        -- Show hub with fade-in
        HubFrame.Visible = true
        HubFrame.BackgroundTransparency = 1
        Tween(HubFrame, 0.4, {BackgroundTransparency = 0}, Enum.EasingStyle.Quad)
    end)

end)

if not success then
    warn("DiamondHub Error: " .. tostring(err))
end
