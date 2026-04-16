--// DIAMOND HUB — Script Hub
--// Version: 2.0 | Hub Edition

local success, err = pcall(function()

    --// SERVICES
    local Players          = game:GetService("Players")
    local RunService       = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local TweenService     = game:GetService("TweenService")
    local LocalPlayer      = Players.LocalPlayer
    local Camera           = workspace.CurrentCamera
    local Mouse            = LocalPlayer:GetMouse()

    --// PALETTE
    local ACCENT      = Color3.fromRGB(0, 168, 255)
    local BG_MAIN     = Color3.fromRGB(14, 14, 17)
    local BG_PANEL    = Color3.fromRGB(20, 20, 24)
    local BG_CARD     = Color3.fromRGB(26, 26, 31)
    local BG_ITEM     = Color3.fromRGB(33, 33, 40)
    local TEXT_BRIGHT = Color3.fromRGB(228, 228, 234)
    local TEXT_DIM    = Color3.fromRGB(108, 108, 128)
    local TEXT_MUTED  = Color3.fromRGB(65, 65, 80)
    local BORDER_CLR  = Color3.fromRGB(38, 38, 50)

    --// GUI ROOT
    local function GetGui()
        if gethui then return gethui() end
        local cg = game:GetService("CoreGui")
        if cg:FindFirstChild("RobloxGui") then return cg.RobloxGui end
        return LocalPlayer:WaitForChild("PlayerGui")
    end

    if getgenv().DiamondHub_Loaded then
        local old = GetGui():FindFirstChild("DiamondHub_V2")
        if old then old:Destroy() end
        if getgenv().DiamondHub_Connections then
            for _, conn in pairs(getgenv().DiamondHub_Connections) do
                pcall(function() conn:Disconnect() end)
            end
        end
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
        l.TextColor3 = props.TextColor3 or TEXT_BRIGHT
        l.TextSize = props.TextSize or 14
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
        b.BackgroundColor3 = props.BackgroundColor3 or BG_CARD
        b.TextColor3 = props.TextColor3 or TEXT_BRIGHT
        b.Font = props.Font or Enum.Font.GothamBold
        b.TextSize = props.TextSize or 14
        b.Text = props.Text or ""
        b.Size = props.Size or UDim2.new(1,0,0,36)
        b.Position = props.Position or UDim2.new(0,0,0,0)
        b.AutoButtonColor = false
        b.BorderSizePixel = 0
        if props.Radius ~= false then MakeCorner(b, props.Radius or 8) end
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

    local LoadCenter = MakeFrame(LoadingFrame, {Transparency = 1})
    LoadCenter.Size = UDim2.new(0, 400, 0, 210)
    LoadCenter.Position = UDim2.new(0.5,-200,0.5,-105)

    local DiamondIcon = MakeLabel(LoadCenter, {
        Text = "💎",
        TextSize = 58,
        Size = UDim2.new(1,0,0,76),
        Position = UDim2.new(0,0,0,0),
    })
    local LoadTitle = MakeLabel(LoadCenter, {
        Text = "DIAMOND HUB",
        TextSize = 28,
        Font = Enum.Font.GothamBlack,
        TextColor3 = TEXT_BRIGHT,
        Size = UDim2.new(1,0,0,38),
        Position = UDim2.new(0,0,0,78),
    })
    local LoadSub = MakeLabel(LoadCenter, {
        Text = "Loading",
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        TextColor3 = TEXT_DIM,
        Size = UDim2.new(1,0,0,22),
        Position = UDim2.new(0,0,0,116),
    })
    local ProgressBG = MakeFrame(LoadCenter, {
        BackgroundColor3 = BG_ITEM,
        Size = UDim2.new(1,0,0,3),
        Position = UDim2.new(0,0,0,154),
        Radius = 3,
    })
    local ProgressFill = MakeFrame(ProgressBG, {
        BackgroundColor3 = ACCENT,
        Size = UDim2.new(0,0,1,0),
        Radius = 3,
    })
    MakeLabel(LoadCenter, {
        Text = "v2.0 Hub Edition",
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextColor3 = TEXT_MUTED,
        Size = UDim2.new(1,0,0,18),
        Position = UDim2.new(0,0,0,180),
    })

    DiamondIcon.TextTransparency = 1
    Tween(DiamondIcon, 0.6, {TextTransparency = 0}, Enum.EasingStyle.Quad)
    task.spawn(function()
        task.wait(0.1)
        Tween(DiamondIcon, 0.4, {TextSize = 66}, Enum.EasingStyle.Sine)
        task.wait(0.4)
        Tween(DiamondIcon, 0.35, {TextSize = 58}, Enum.EasingStyle.Sine)
    end)
    LoadTitle.TextTransparency = 1
    task.delay(0.3, function() Tween(LoadTitle, 0.5, {TextTransparency = 0}) end)
    LoadSub.TextTransparency = 1
    task.delay(0.5, function() Tween(LoadSub, 0.4, {TextTransparency = 0}) end)

    local dotCount = 0
    task.spawn(function()
        while getgenv().DiamondHub_Active and LoadingFrame.Parent do
            dotCount = (dotCount % 3) + 1
            LoadSub.Text = "Loading" .. string.rep(".", dotCount)
            task.wait(0.4)
        end
    end)
    ProgressBG.BackgroundTransparency = 1
    task.delay(0.5, function()
        Tween(ProgressBG, 0.2, {BackgroundTransparency = 0})
        Tween(ProgressFill, 2.0, {Size = UDim2.new(1,0,1,0)}, Enum.EasingStyle.Quart)
    end)

    --// ============================================================
    --//  SCREEN 2 — GAME SELECTOR HUB
    --// ============================================================

    local HubFrame = MakeFrame(ScreenGui, {BackgroundColor3 = BG_MAIN})
    HubFrame.Size = UDim2.new(0, 560, 0, 376)
    HubFrame.Position = UDim2.new(0.5,-280,0.5,-188)
    HubFrame.Visible = false
    HubFrame.ZIndex = 10
    HubFrame.ClipsDescendants = true
    MakeCorner(HubFrame, 12)
    MakeStroke(HubFrame, BORDER_CLR, 1, 0.1)

    -- Header
    local HubHeader = MakeFrame(HubFrame, {BackgroundColor3 = BG_PANEL})
    HubHeader.Size = UDim2.new(1,0,0,50)
    MakeCorner(HubHeader, 12)
    local HubHeaderFix = MakeFrame(HubHeader, {BackgroundColor3 = BG_PANEL})
    HubHeaderFix.Size = UDim2.new(1,0,0,12)
    HubHeaderFix.Position = UDim2.new(0,0,1,-12)

    -- Header bottom border
    MakeFrame(HubFrame, {BackgroundColor3 = BORDER_CLR, Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,0,50)})

    MakeLabel(HubHeader, {
        Text = "💎",
        TextSize = 19,
        Size = UDim2.new(0,34,1,0),
        Position = UDim2.new(0,14,0,0),
    })
    MakeLabel(HubHeader, {
        Text = "Diamond Hub",
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextColor3 = TEXT_BRIGHT,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0,120,0,22),
        Position = UDim2.new(0,44,0,8),
    })
    MakeLabel(HubHeader, {
        Text = "select a game",
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextColor3 = TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0,120,0,16),
        Position = UDim2.new(0,44,0,28),
    })

    local HubCloseBtn = MakeButton(HubHeader, {
        Text = "✕",
        BackgroundColor3 = BG_MAIN,
        TextColor3 = TEXT_DIM,
        Size = UDim2.new(0,28,0,28),
        Position = UDim2.new(1,-40,0.5,-14),
        TextSize = 13,
        Radius = 6,
    })
    HubCloseBtn.BackgroundTransparency = 1
    HubCloseBtn.MouseEnter:Connect(function()
        Tween(HubCloseBtn, 0.12, {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(190,45,55), TextColor3 = Color3.new(1,1,1)})
    end)
    HubCloseBtn.MouseLeave:Connect(function()
        Tween(HubCloseBtn, 0.12, {BackgroundTransparency = 1, TextColor3 = TEXT_DIM})
    end)

    -- Body
    local HubBody = MakeFrame(HubFrame, {Transparency = 1})
    HubBody.Size = UDim2.new(1,0,1,-51)
    HubBody.Position = UDim2.new(0,0,0,51)

    MakeLabel(HubBody, {
        Text = "Available Games",
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextColor3 = TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-28,0,16),
        Position = UDim2.new(0,16,0,12),
    })

    local GamesScroll = Instance.new("ScrollingFrame", HubBody)
    GamesScroll.Size = UDim2.new(1,-16,1,-40)
    GamesScroll.Position = UDim2.new(0,8,0,36)
    GamesScroll.BackgroundTransparency = 1
    GamesScroll.ScrollBarThickness = 2
    GamesScroll.ScrollBarImageColor3 = Color3.fromRGB(50,50,65)
    GamesScroll.CanvasSize = UDim2.new(0,0,0,0)
    GamesScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    GamesScroll.BorderSizePixel = 0
    local GamesLayout = Instance.new("UIListLayout", GamesScroll)
    GamesLayout.Padding = UDim.new(0,7)
    GamesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local GamesPad = Instance.new("UIPadding", GamesScroll)
    GamesPad.PaddingTop = UDim.new(0,4)
    GamesPad.PaddingBottom = UDim.new(0,4)

    local function AddGameCard(name, subtitle, emoji, onLaunch)
        local Card = MakeFrame(GamesScroll, {BackgroundColor3 = BG_CARD, Radius = 10})
        Card.Size = UDim2.new(1,0,0,72)
        MakeStroke(Card, BORDER_CLR, 1, 0.15)

        MakeLabel(Card, {
            Text = emoji,
            TextSize = 26,
            Size = UDim2.new(0,50,1,0),
            Position = UDim2.new(0,12,0,0),
        })
        MakeLabel(Card, {
            Text = name,
            TextSize = 16,
            Font = Enum.Font.GothamBold,
            TextColor3 = TEXT_BRIGHT,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1,-170,0,22),
            Position = UDim2.new(0,64,0,12),
        })
        MakeLabel(Card, {
            Text = subtitle,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextColor3 = TEXT_DIM,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1,-170,0,18),
            Position = UDim2.new(0,64,0,36),
        })

        local LaunchBtn = MakeButton(Card, {
            Text = "Launch",
            BackgroundColor3 = ACCENT,
            Size = UDim2.new(0,86,0,32),
            Position = UDim2.new(1,-100,0.5,-16),
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            Radius = 7,
        })
        LaunchBtn.MouseEnter:Connect(function()
            Tween(LaunchBtn, 0.14, {BackgroundColor3 = Color3.fromRGB(30,196,255)})
        end)
        LaunchBtn.MouseLeave:Connect(function()
            Tween(LaunchBtn, 0.14, {BackgroundColor3 = ACCENT})
        end)
        LaunchBtn.MouseButton1Click:Connect(onLaunch)

        Card.MouseEnter:Connect(function()
            Tween(Card, 0.14, {BackgroundColor3 = Color3.fromRGB(30,30,38)})
        end)
        Card.MouseLeave:Connect(function()
            Tween(Card, 0.14, {BackgroundColor3 = BG_CARD})
        end)
        return Card
    end

    -- Hub drag
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
        getgenv().DiamondHub_Active = false
        getgenv().DiamondHub_Loaded = false
        ScreenGui:Destroy()
    end)

    --// ============================================================
    --//  SCREEN 3 — GAME LOADING OVERLAY
    --// ============================================================

    local GameLoadFrame = MakeFrame(ScreenGui, {BackgroundColor3 = BG_MAIN})
    GameLoadFrame.Size = UDim2.new(0,350,0,172)
    GameLoadFrame.Position = UDim2.new(0.5,-175,0.5,-86)
    GameLoadFrame.Visible = false
    GameLoadFrame.ZIndex = 50
    MakeCorner(GameLoadFrame, 12)
    MakeStroke(GameLoadFrame, BORDER_CLR, 1, 0.15)

    local SpinnerRing = MakeFrame(GameLoadFrame, {Transparency = 1})
    SpinnerRing.Size = UDim2.new(0,48,0,48)
    SpinnerRing.Position = UDim2.new(0.5,-24,0,22)

    local SpinArc = Instance.new("Frame", SpinnerRing)
    SpinArc.Size = UDim2.new(1,0,1,0)
    SpinArc.BackgroundTransparency = 1
    local spinStroke = Instance.new("UIStroke", SpinArc)
    spinStroke.Color = ACCENT
    spinStroke.Thickness = 3
    spinStroke.Transparency = 0
    MakeCorner(SpinArc, 24)

    local SpinInner = MakeFrame(SpinnerRing, {BackgroundColor3 = BG_MAIN})
    SpinInner.Size = UDim2.new(1,-10,1,-10)
    SpinInner.Position = UDim2.new(0,5,0,5)
    MakeCorner(SpinInner, 19)

    local SpinDot = MakeFrame(SpinnerRing, {BackgroundColor3 = ACCENT})
    SpinDot.Size = UDim2.new(0,8,0,8)
    SpinDot.Position = UDim2.new(0.5,-4,0,-4)
    MakeCorner(SpinDot, 4)

    local GameLoadTitle = MakeLabel(GameLoadFrame, {
        Text = "Loading...",
        TextSize = 19,
        Font = Enum.Font.GothamBold,
        TextColor3 = TEXT_BRIGHT,
        Size = UDim2.new(1,-20,0,26),
        Position = UDim2.new(0,10,0,82),
    })
    local GameLoadSub = MakeLabel(GameLoadFrame, {
        Text = "Please wait",
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextColor3 = TEXT_DIM,
        Size = UDim2.new(1,-20,0,18),
        Position = UDim2.new(0,10,0,108),
    })
    local GameLoadBar_BG = MakeFrame(GameLoadFrame, {BackgroundColor3 = BG_ITEM, Radius = 3})
    GameLoadBar_BG.Size = UDim2.new(1,-32,0,3)
    GameLoadBar_BG.Position = UDim2.new(0,16,0,146)
    local GameLoadBar_Fill = MakeFrame(GameLoadBar_BG, {BackgroundColor3 = ACCENT, Radius = 3})
    GameLoadBar_Fill.Size = UDim2.new(0,0,1,0)

    task.spawn(function()
        local angle = 0
        while getgenv().DiamondHub_Active do
            if GameLoadFrame.Visible then
                angle = angle + 6
                SpinDot.Position = UDim2.new(
                    0.5 + math.sin(math.rad(angle)) * 0.5 - 0.083,
                    0,
                    0.5 - math.cos(math.rad(angle)) * 0.5 - 0.083,
                    0
                )
            end
            task.wait(1/60)
        end
    end)

    --// ============================================================
    --//  SCREEN 4 — RIVALS CHEAT UI  (Hidden-style)
    --// ============================================================

    _G.DH_Config = {
        Aimbot         = false,
        RageHitbox     = false,
        HitboxSize     = 15,
        FOV            = 250,
        ESP            = false,
        Speed          = false,
        WalkSpeedValue = 60,
        Fly            = false,
        FlySpeed       = 50,
        Noclip         = false,
    }

    -- Window: 624 × 374  (landscape, matches reference proportions)
    local RivalsFrame = MakeFrame(ScreenGui, {BackgroundColor3 = BG_MAIN})
    RivalsFrame.Size     = UDim2.new(0, 624, 0, 374)
    RivalsFrame.Position = UDim2.new(0.5,-312,0.5,-187)
    RivalsFrame.Visible  = false
    RivalsFrame.ZIndex   = 10
    RivalsFrame.ClipsDescendants = true
    MakeCorner(RivalsFrame, 12)
    MakeStroke(RivalsFrame, BORDER_CLR, 1, 0.1)

    --// ─── HEADER (50px) ───────────────────────────────────────────
    local RivalsHeader = MakeFrame(RivalsFrame, {BackgroundColor3 = BG_PANEL})
    RivalsHeader.Size = UDim2.new(1,0,0,50)
    MakeCorner(RivalsHeader, 12)
    -- fix rounded bottom corners of header
    MakeFrame(RivalsHeader, {BackgroundColor3 = BG_PANEL, Size = UDim2.new(1,0,0,12), Position = UDim2.new(0,0,1,-12)})
    -- header bottom border
    MakeFrame(RivalsFrame, {BackgroundColor3 = BORDER_CLR, Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,0,50)})

    -- Diamond gem icon
    MakeLabel(RivalsHeader, {
        Text = "💎",
        TextSize = 18,
        Size = UDim2.new(0,32,1,0),
        Position = UDim2.new(0,14,0,0),
    })

    -- "Diamond Hub" bold
    MakeLabel(RivalsHeader, {
        Text = "Diamond Hub",
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextColor3 = TEXT_BRIGHT,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0,112,0,20),
        Position = UDim2.new(0,42,0,8),
    })

    -- separator dot
    MakeLabel(RivalsHeader, {
        Text = "·",
        TextSize = 15,
        Font = Enum.Font.Gotham,
        TextColor3 = TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0,10,1,0),
        Position = UDim2.new(0,152,0,0),
    })

    -- "Rivals" subtitle
    MakeLabel(RivalsHeader, {
        Text = "Rivals",
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextColor3 = TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0,60,0,18),
        Position = UDim2.new(0,165,0,17),
    })

    -- Header action buttons (no background, hover-only)
    local function HeaderBtn(xOff, icon, hoverColor)
        local b = MakeButton(RivalsHeader, {
            Text = icon,
            BackgroundColor3 = BG_MAIN,
            TextColor3 = TEXT_DIM,
            Size = UDim2.new(0,26,0,26),
            Position = UDim2.new(1,xOff,0.5,-13),
            TextSize = 13,
            Radius = 5,
        })
        b.BackgroundTransparency = 1
        b.MouseEnter:Connect(function()
            Tween(b, 0.12, {BackgroundTransparency = 0, BackgroundColor3 = hoverColor, TextColor3 = Color3.new(1,1,1)})
        end)
        b.MouseLeave:Connect(function()
            Tween(b, 0.12, {BackgroundTransparency = 1, TextColor3 = TEXT_DIM})
        end)
        return b
    end

    local BackBtn  = HeaderBtn(-104, "⌂",  BG_ITEM)
    local MinBtn   = HeaderBtn(-70,  "—",  BG_ITEM)
    local CloseBtn = HeaderBtn(-36,  "✕",  Color3.fromRGB(190,45,55))

    -- Dragging
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

    --// ─── BODY (below header, 324px tall) ────────────────────────
    -- 374 - 50 = 324px
    local RivalsBody = MakeFrame(RivalsFrame, {Transparency = 1})
    RivalsBody.Size     = UDim2.new(1,0,1,-51)
    RivalsBody.Position = UDim2.new(0,0,0,51)

    --// ─── ICON SIDEBAR (50px wide) ────────────────────────────────
    local Sidebar = MakeFrame(RivalsBody, {BackgroundColor3 = BG_PANEL})
    Sidebar.Size = UDim2.new(0,50,1,0)

    local SideLayout = Instance.new("UIListLayout", Sidebar)
    SideLayout.Padding           = UDim.new(0,0)
    SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SideLayout.FillDirection     = Enum.FillDirection.Vertical
    SideLayout.SortOrder         = Enum.SortOrder.LayoutOrder

    -- Sidebar right border
    MakeFrame(RivalsBody, {BackgroundColor3 = BORDER_CLR, Size = UDim2.new(0,1,1,0), Position = UDim2.new(0,50,0,0)})

    --// ─── CONTENT PAGES ───────────────────────────────────────────
    local Pages = MakeFrame(RivalsBody, {Transparency = 1})
    Pages.Size     = UDim2.new(1,-52,1,0)
    Pages.Position = UDim2.new(0,52,0,0)

    --// ─── TAB SYSTEM ──────────────────────────────────────────────
    local RivalsTabs = {}

    local function CreateTab(tabName, icon, layoutOrder, active)
        -- Scrolling content page
        local Frame = Instance.new("ScrollingFrame", Pages)
        Frame.Size = UDim2.new(1,0,1,0)
        Frame.BackgroundTransparency = 1
        Frame.Visible = active
        Frame.ScrollBarThickness = 2
        Frame.ScrollBarImageColor3 = Color3.fromRGB(50,50,65)
        Frame.CanvasSize = UDim2.new(0,0,0,0)
        Frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Frame.BorderSizePixel = 0
        local Layout = Instance.new("UIListLayout", Frame)
        Layout.Padding = UDim.new(0,8)
        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        local FPad = Instance.new("UIPadding", Frame)
        FPad.PaddingTop    = UDim.new(0,10)
        FPad.PaddingBottom = UDim.new(0,10)
        FPad.PaddingLeft   = UDim.new(0,10)
        FPad.PaddingRight  = UDim.new(0,10)

        -- Sidebar icon slot (50×46px)
        local Slot = Instance.new("Frame", Sidebar)
        Slot.Size = UDim2.new(1,0,0,46)
        Slot.BackgroundTransparency = 1
        Slot.BorderSizePixel = 0
        Slot.LayoutOrder = layoutOrder

        -- Left accent bar (3px)
        local Bar = MakeFrame(Slot, {BackgroundColor3 = ACCENT})
        Bar.Size = UDim2.new(0,3,0,26)
        Bar.Position = UDim2.new(0,0,0.5,-13)
        Bar.BackgroundTransparency = active and 0 or 1
        MakeCorner(Bar, 2)

        -- Icon highlight pill (36×36, centered)
        local Pill = MakeFrame(Slot, {BackgroundColor3 = BG_ITEM, Radius = 8})
        Pill.Size = UDim2.new(0,36,0,36)
        Pill.Position = UDim2.new(0.5,-18,0.5,-18)
        Pill.BackgroundTransparency = active and 0 or 1

        -- Icon label
        local Ico = MakeLabel(Slot, {
            Text = icon,
            TextSize = 17,
            TextColor3 = active and TEXT_BRIGHT or TEXT_MUTED,
            Size = UDim2.new(1,0,1,0),
        })

        -- Invisible clickable overlay
        local Btn = Instance.new("TextButton", Slot)
        Btn.Size = UDim2.new(1,0,1,0)
        Btn.BackgroundTransparency = 1
        Btn.Text = ""
        Btn.ZIndex = 5

        Btn.MouseEnter:Connect(function()
            if not (RivalsTabs[tabName] and RivalsTabs[tabName].F.Visible) then
                Tween(Pill, 0.12, {BackgroundTransparency = 0.55, BackgroundColor3 = BG_ITEM})
                Tween(Ico, 0.12, {TextColor3 = TEXT_DIM})
            end
        end)
        Btn.MouseLeave:Connect(function()
            if not (RivalsTabs[tabName] and RivalsTabs[tabName].F.Visible) then
                Tween(Pill, 0.12, {BackgroundTransparency = 1})
                Tween(Ico, 0.12, {TextColor3 = TEXT_MUTED})
            end
        end)
        Btn.MouseButton1Click:Connect(function()
            for _, v in pairs(RivalsTabs) do
                v.F.Visible = false
                Tween(v.Pill, 0.15, {BackgroundTransparency = 1})
                Tween(v.Bar,  0.15, {BackgroundTransparency = 1})
                Tween(v.Ico,  0.15, {TextColor3 = TEXT_MUTED})
            end
            Frame.Visible = true
            Tween(Pill, 0.15, {BackgroundTransparency = 0, BackgroundColor3 = BG_ITEM})
            Tween(Bar,  0.15, {BackgroundTransparency = 0})
            Tween(Ico,  0.15, {TextColor3 = TEXT_BRIGHT})
        end)

        RivalsTabs[tabName] = {F = Frame, Pill = Pill, Bar = Bar, Ico = Ico}
        return Frame
    end

    local HomeTab    = CreateTab("Home",     "🏠",  1, true)
    local CombatTab  = CreateTab("Combat",   "⚔️",  2, false)
    local VisualsTab = CreateTab("Visuals",  "👁",   3, false)
    local MoveTab    = CreateTab("Movement", "⚡",   4, false)
    local ProfileTab = CreateTab("Profile",  "👤",  5, false)
    local DiscordTab = CreateTab("Discord",  "💬",  6, false)

    -- Small avatar at bottom of sidebar (absolute positioned)
    local SideAvatarHolder = MakeFrame(RivalsBody, {Transparency = 1})
    SideAvatarHolder.Size     = UDim2.new(0,50,0,48)
    SideAvatarHolder.Position = UDim2.new(0,0,1,-48)
    local SideAvatarImg = Instance.new("ImageLabel", SideAvatarHolder)
    SideAvatarImg.Size  = UDim2.new(0,30,0,30)
    SideAvatarImg.Position = UDim2.new(0.5,-15,0.5,-15)
    SideAvatarImg.BackgroundColor3 = BG_ITEM
    SideAvatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    MakeCorner(SideAvatarImg, 15)
    MakeStroke(SideAvatarImg, BORDER_CLR, 1, 0.15)

    --// ============================================================
    --//  CONTENT HELPERS
    --// ============================================================

    -- Card container
    local function MakeCard(parent, height, bgColor, strokeColor)
        local c = MakeFrame(parent, {BackgroundColor3 = bgColor or BG_CARD, Radius = 9})
        c.Size = UDim2.new(1,0,0,height)
        MakeStroke(c, strokeColor or BORDER_CLR, 1, strokeColor and 0.35 or 0.15)
        return c
    end

    -- Toggle row (card with pill toggle)
    local function AddToggle(parent, label, sublabel, key)
        local Row = MakeFrame(parent, {BackgroundColor3 = BG_CARD, Radius = 9})
        Row.Size = UDim2.new(1,0,0,56)
        MakeStroke(Row, BORDER_CLR, 1, 0.15)

        MakeLabel(Row, {
            Text = label,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextColor3 = TEXT_BRIGHT,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1,-68,0,19),
            Position = UDim2.new(0,14,0,9),
        })
        if sublabel and sublabel ~= "" then
            MakeLabel(Row, {
                Text = sublabel,
                TextSize = 11,
                Font = Enum.Font.Gotham,
                TextColor3 = TEXT_DIM,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(1,-68,0,16),
                Position = UDim2.new(0,14,0,29),
            })
        end

        local PillBG = MakeFrame(Row, {
            BackgroundColor3 = _G.DH_Config[key] and ACCENT or BG_ITEM,
            Radius = 100,
        })
        PillBG.Size     = UDim2.new(0,40,0,22)
        PillBG.Position = UDim2.new(1,-52,0.5,-11)
        MakeStroke(PillBG, BORDER_CLR, 1, 0.3)

        local Dot = MakeFrame(PillBG, {BackgroundColor3 = Color3.new(1,1,1), Radius = 100})
        Dot.Size     = UDim2.new(0,16,0,16)
        Dot.Position = _G.DH_Config[key] and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)

        local Toggling = false
        Row.InputBegan:Connect(function(i)
            if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            if Toggling then return end
            Toggling = true
            _G.DH_Config[key] = not _G.DH_Config[key]
            local on = _G.DH_Config[key]
            Tween(PillBG, 0.2, {BackgroundColor3 = on and ACCENT or BG_ITEM})
            Tween(Dot,    0.2, {Position = on and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)})
            task.wait(0.25)
            Toggling = false
        end)
        return Row
    end

    -- Small info pill (value + label stacked)
    local function InfoPill(parent, x, y, w, h, valueText, labelText, bgColor)
        local p = MakeFrame(parent, {BackgroundColor3 = bgColor or BG_ITEM, Radius = 7})
        p.Size     = UDim2.new(0,w,0,h or 46)
        p.Position = UDim2.new(0,x,0,y)
        MakeLabel(p, {
            Text = tostring(valueText),
            TextSize = 15,
            Font = Enum.Font.GothamBold,
            TextColor3 = TEXT_BRIGHT,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1,-10,0,20),
            Position = UDim2.new(0,10,0,7),
        })
        MakeLabel(p, {
            Text = labelText,
            TextSize = 10,
            Font = Enum.Font.Gotham,
            TextColor3 = TEXT_DIM,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1,-10,0,14),
            Position = UDim2.new(0,10,0,26),
        })
        return p
    end

    --// ============================================================
    --//  HOME TAB
    --// ============================================================

    -- ── Greeting card ────────────────────────────────────────────
    local GreetCard = MakeCard(HomeTab, 68)
    local GAvatarImg = Instance.new("ImageLabel", GreetCard)
    GAvatarImg.Size     = UDim2.new(0,44,0,44)
    GAvatarImg.Position = UDim2.new(0,12,0.5,-22)
    GAvatarImg.BackgroundColor3 = BG_ITEM
    GAvatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    MakeCorner(GAvatarImg, 22)
    MakeStroke(GAvatarImg, BORDER_CLR, 1.5, 0.1)
    MakeLabel(GreetCard, {
        Text = "Hello, " .. LocalPlayer.DisplayName,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextColor3 = TEXT_BRIGHT,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-72,0,20),
        Position = UDim2.new(0,66,0,12),
    })
    MakeLabel(GreetCard, {
        Text = LocalPlayer.Name .. "  ·  Diamond Hub  ·  Rivals",
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextColor3 = TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-72,0,16),
        Position = UDim2.new(0,66,0,36),
    })

    -- ── Two-column row ────────────────────────────────────────────
    -- Column wrapper sits in the vertical UIListLayout of HomeTab
    local ColWrap = MakeFrame(HomeTab, {Transparency = 1})
    ColWrap.Size = UDim2.new(1,0,0,168)
    local ColLayout = Instance.new("UIListLayout", ColWrap)
    ColLayout.FillDirection     = Enum.FillDirection.Horizontal
    ColLayout.Padding           = UDim.new(0,8)
    ColLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

    -- Left column: Session info card
    local SessionCard = MakeFrame(ColWrap, {BackgroundColor3 = BG_CARD, Radius = 9})
    SessionCard.Size = UDim2.new(0.5,-4,1,0)
    MakeStroke(SessionCard, BORDER_CLR, 1, 0.15)

    MakeLabel(SessionCard, {
        Text = "Session",
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextColor3 = TEXT_BRIGHT,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-12,0,18),
        Position = UDim2.new(0,11,0,9),
    })
    MakeLabel(SessionCard, {
        Text = "Info about your current session",
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextColor3 = TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-12,0,14),
        Position = UDim2.new(0,11,0,25),
    })

    -- Determine player and server values
    local playerCount = #Players:GetPlayers()
    local gameName = "Rivals"
    pcall(function()
        local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        if info and info.Name then
            gameName = #info.Name > 11 and info.Name:sub(1,11) or info.Name
        end
    end)

    -- 2×2 pill grid inside Session card
    -- Row 1: Players | Game
    local pillW = 0  -- calculated from card width dynamically below
    -- Using relative sizing: two pills side-by-side in the card
    local function SessionPill(parent, xScale, xOff, y, valTxt, lblTxt)
        local p = MakeFrame(parent, {BackgroundColor3 = BG_ITEM, Radius = 6})
        p.Size     = UDim2.new(0.5,-10,0,44)
        p.Position = UDim2.new(xScale,xOff,0,y)
        MakeLabel(p, {
            Text = tostring(valTxt),
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            TextColor3 = TEXT_BRIGHT,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1,-8,0,19),
            Position = UDim2.new(0,8,0,6),
        })
        MakeLabel(p, {
            Text = lblTxt,
            TextSize = 10,
            Font = Enum.Font.Gotham,
            TextColor3 = TEXT_DIM,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1,-8,0,13),
            Position = UDim2.new(0,8,0,26),
        })
        return p
    end

    SessionPill(SessionCard,   0,  8, 44, playerCount,              "Players")
    SessionPill(SessionCard, 0.5,  2, 44, gameName,                 "Game")
    SessionPill(SessionCard,   0,  8, 96, LocalPlayer.AccountAge .. "d", "Account Age")
    SessionPill(SessionCard, 0.5,  2, 96, "#" .. tostring(LocalPlayer.UserId):sub(1,7), "User ID")

    -- Right column: Hub status card (tinted blue accent)
    local HubStatusCard = MakeFrame(ColWrap, {BackgroundColor3 = Color3.fromRGB(13,34,54), Radius = 9})
    HubStatusCard.Size = UDim2.new(0.5,-4,1,0)
    MakeStroke(HubStatusCard, Color3.fromRGB(0,90,160), 1, 0.35)

    MakeLabel(HubStatusCard, {
        Text = "Hub",
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextColor3 = TEXT_BRIGHT,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-12,0,18),
        Position = UDim2.new(0,11,0,9),
    })
    MakeLabel(HubStatusCard, {
        Text = "Diamond Hub is active and running",
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextColor3 = Color3.fromRGB(120,165,210),
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-12,0,28),
        Position = UDim2.new(0,11,0,24),
        TextWrapped = true,
    })

    -- Active pill with green dot
    local HubActivePill = MakeFrame(HubStatusCard, {BackgroundColor3 = Color3.fromRGB(9,46,78), Radius = 6})
    HubActivePill.Size     = UDim2.new(1,-18,0,36)
    HubActivePill.Position = UDim2.new(0,9,0,58)
    local GreenDot = MakeFrame(HubActivePill, {BackgroundColor3 = Color3.fromRGB(55,215,95), Radius = 100})
    GreenDot.Size     = UDim2.new(0,7,0,7)
    GreenDot.Position = UDim2.new(0,10,0.5,-3)
    MakeLabel(HubActivePill, {
        Text = "Hub Active",
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.fromRGB(195,230,255),
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-28,1,0),
        Position = UDim2.new(0,24,0,0),
    })

    -- Version pill
    local VerPill = MakeFrame(HubStatusCard, {BackgroundColor3 = Color3.fromRGB(9,46,78), Radius = 6})
    VerPill.Size     = UDim2.new(1,-18,0,36)
    VerPill.Position = UDim2.new(0,9,0,100)
    MakeLabel(VerPill, {
        Text = "v2.0  ·  Hub Edition",
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextColor3 = Color3.fromRGB(145,195,240),
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-14,1,0),
        Position = UDim2.new(0,10,0,0),
    })

    -- ── Discord card (full-width, indigo) ────────────────────────
    local DiscHomeCard = MakeFrame(HomeTab, {BackgroundColor3 = Color3.fromRGB(29,32,78), Radius = 9})
    DiscHomeCard.Size = UDim2.new(1,0,0,52)
    MakeStroke(DiscHomeCard, Color3.fromRGB(78,86,210), 1, 0.3)

    MakeLabel(DiscHomeCard, {
        Text = "💬  Discord",
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.fromRGB(195,205,255),
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-100,0,22),
        Position = UDim2.new(0,13,0,7),
    })
    MakeLabel(DiscHomeCard, {
        Text = "Tap to join the Support Server",
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextColor3 = Color3.fromRGB(130,140,210),
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-100,0,16),
        Position = UDim2.new(0,13,0,30),
    })
    -- Clickable join button
    local DHDiscBtn = MakeButton(DiscHomeCard, {
        Text = "Join →",
        BackgroundColor3 = Color3.fromRGB(78,86,210),
        TextColor3 = Color3.new(1,1,1),
        Size = UDim2.new(0,64,0,28),
        Position = UDim2.new(1,-76,0.5,-14),
        TextSize = 12,
        Radius = 6,
    })
    DHDiscBtn.MouseEnter:Connect(function() Tween(DHDiscBtn, 0.13, {BackgroundColor3 = Color3.fromRGB(100,110,240)}) end)
    DHDiscBtn.MouseLeave:Connect(function() Tween(DHDiscBtn, 0.13, {BackgroundColor3 = Color3.fromRGB(78,86,210)}) end)

    --// ============================================================
    --//  COMBAT TAB
    --// ============================================================

    AddToggle(CombatTab, "Aimbot", "Hard-lock on the nearest enemy head", "Aimbot")
    AddToggle(CombatTab, "Hitbox Expander", "Expands enemy head collision size", "RageHitbox")

    --// ============================================================
    --//  VISUALS TAB
    --// ============================================================

    AddToggle(VisualsTab, "ESP Highlights", "Highlight all enemies through walls", "ESP")

    --// ============================================================
    --//  MOVEMENT TAB
    --// ============================================================

    AddToggle(MoveTab, "Speed Bypass", "Increase walk speed", "Speed")
    AddToggle(MoveTab, "Fly Hack", "Fly freely with WASD controls", "Fly")
    AddToggle(MoveTab, "Noclip", "Pass through all walls and terrain", "Noclip")

    --// ============================================================
    --//  PROFILE TAB
    --// ============================================================

    local PCard = MakeCard(ProfileTab, 98)
    local PImg = Instance.new("ImageLabel", PCard)
    PImg.Size     = UDim2.new(0,60,0,60)
    PImg.Position = UDim2.new(0,14,0.5,-30)
    PImg.BackgroundColor3 = BG_ITEM
    PImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    MakeCorner(PImg, 30)
    MakeStroke(PImg, BORDER_CLR, 1.5, 0.1)
    MakeLabel(PCard, {
        Text = LocalPlayer.DisplayName,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextColor3 = TEXT_BRIGHT,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-92,0,20),
        Position = UDim2.new(0,86,0,18),
    })
    MakeLabel(PCard, {
        Text = "@" .. LocalPlayer.Name,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextColor3 = TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-92,0,16),
        Position = UDim2.new(0,86,0,40),
    })
    MakeLabel(PCard, {
        Text = "ID: " .. LocalPlayer.UserId .. "  ·  " .. LocalPlayer.AccountAge .. " days old",
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextColor3 = TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-92,0,14),
        Position = UDim2.new(0,86,0,62),
    })

    -- Stats row (3 equal pills)
    local StatsWrap = MakeFrame(ProfileTab, {Transparency = 1})
    StatsWrap.Size = UDim2.new(1,0,0,66)
    local StatsLayout = Instance.new("UIListLayout", StatsWrap)
    StatsLayout.FillDirection     = Enum.FillDirection.Horizontal
    StatsLayout.Padding           = UDim.new(0,8)
    StatsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

    local function StatPill(parent, val, lbl)
        local p = MakeFrame(parent, {BackgroundColor3 = BG_CARD, Radius = 8})
        p.Size = UDim2.new(1/3,-6,1,0)
        MakeStroke(p, BORDER_CLR, 1, 0.15)
        MakeLabel(p, {
            Text = val,
            TextSize = 17,
            Font = Enum.Font.GothamBold,
            TextColor3 = TEXT_BRIGHT,
            Size = UDim2.new(1,0,0,24),
            Position = UDim2.new(0,0,0,10),
        })
        MakeLabel(p, {
            Text = lbl,
            TextSize = 10,
            Font = Enum.Font.Gotham,
            TextColor3 = TEXT_DIM,
            Size = UDim2.new(1,0,0,14),
            Position = UDim2.new(0,0,0,34),
        })
    end

    StatPill(StatsWrap, LocalPlayer.AccountAge .. "d",  "Account Age")
    StatPill(StatsWrap, "#" .. tostring(LocalPlayer.UserId):sub(1,6), "User ID")
    StatPill(StatsWrap, "v2.0", "Hub Version")

    --// ============================================================
    --//  DISCORD TAB
    --// ============================================================

    local DiscCard = MakeFrame(DiscordTab, {BackgroundColor3 = Color3.fromRGB(29,32,78), Radius = 9})
    DiscCard.Size = UDim2.new(1,0,0,100)
    MakeStroke(DiscCard, Color3.fromRGB(78,86,210), 1, 0.25)

    MakeLabel(DiscCard, {
        Text = "💬  Official Support Server",
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.fromRGB(195,205,255),
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-14,0,20),
        Position = UDim2.new(0,13,0,9),
    })
    MakeLabel(DiscCard, {
        Text = "Join for updates, new scripts, and support.",
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextColor3 = Color3.fromRGB(130,140,210),
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-14,0,16),
        Position = UDim2.new(0,13,0,30),
    })

    local DiscLinkBox = Instance.new("TextBox", DiscCard)
    DiscLinkBox.Size     = UDim2.new(1,-14,0,28)
    DiscLinkBox.Position = UDim2.new(0,7,0,54)
    DiscLinkBox.BackgroundColor3 = Color3.fromRGB(19,21,58)
    DiscLinkBox.TextColor3  = Color3.fromRGB(175,185,255)
    DiscLinkBox.Text        = "discord.gg/DiamondHub"
    DiscLinkBox.TextSize    = 12
    DiscLinkBox.Font        = Enum.Font.Gotham
    DiscLinkBox.BorderSizePixel = 0
    DiscLinkBox.TextXAlignment  = Enum.TextXAlignment.Left
    MakeCorner(DiscLinkBox, 6)
    local dlp = Instance.new("UIPadding", DiscLinkBox)
    dlp.PaddingLeft = UDim.new(0,9)

    local CopyBtn = MakeButton(DiscordTab, {
        Text = "Copy Invite Link",
        BackgroundColor3 = Color3.fromRGB(80,90,218),
        Size = UDim2.new(1,0,0,38),
        TextSize = 13,
        Radius = 8,
    })
    CopyBtn.MouseEnter:Connect(function() Tween(CopyBtn, 0.13, {BackgroundColor3 = Color3.fromRGB(100,112,240)}) end)
    CopyBtn.MouseLeave:Connect(function() Tween(CopyBtn, 0.13, {BackgroundColor3 = Color3.fromRGB(80,90,218)}) end)
    CopyBtn.MouseButton1Click:Connect(function()
        if setclipboard then setclipboard(DiscLinkBox.Text) end
        CopyBtn.Text = "✓ Copied!"
        task.wait(2)
        CopyBtn.Text = "Copy Invite Link"
    end)

    --// ============================================================
    --//  CLOSE & MINIMIZE
    --// ============================================================

    local RivalsMinimized = false
    MinBtn.MouseButton1Click:Connect(function()
        RivalsMinimized = not RivalsMinimized
        if RivalsMinimized then
            RivalsBody.Visible = false
            Tween(RivalsFrame, 0.28, {Size = UDim2.new(0,624,0,51)}, Enum.EasingStyle.Quart)
        else
            Tween(RivalsFrame, 0.28, {Size = UDim2.new(0,624,0,374)}, Enum.EasingStyle.Quart)
            task.wait(0.22)
            RivalsBody.Visible = true
        end
    end)

    -- Exit confirm overlay
    local ExitOverlay = MakeFrame(RivalsFrame, {BackgroundColor3 = Color3.new(0,0,0), Transparency = 1})
    ExitOverlay.Size    = UDim2.new(1,0,1,0)
    ExitOverlay.ZIndex  = 200
    ExitOverlay.Visible = false

    local ExitBox = MakeFrame(ExitOverlay, {BackgroundColor3 = BG_PANEL, Radius = 10})
    ExitBox.Size     = UDim2.new(0,270,0,132)
    ExitBox.Position = UDim2.new(0.5,-135,0.5,-66)
    ExitBox.ZIndex   = 201
    MakeStroke(ExitBox, BORDER_CLR, 1, 0.1)

    MakeLabel(ExitBox, {
        Text = "Close Diamond Hub?",
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(1,0,0,52),
        Position = UDim2.new(0,0,0,8),
    }).ZIndex = 202

    local ExitYes = MakeButton(ExitBox, {
        Text = "Close",
        BackgroundColor3 = Color3.fromRGB(190,45,55),
        Size = UDim2.new(0,96,0,34),
        Position = UDim2.new(0,14,0,74),
        TextSize = 13,
    })
    ExitYes.ZIndex = 202

    local ExitNo = MakeButton(ExitBox, {
        Text = "Cancel",
        BackgroundColor3 = BG_ITEM,
        Size = UDim2.new(0,96,0,34),
        Position = UDim2.new(1,-110,0,74),
        TextSize = 13,
    })
    ExitNo.ZIndex = 202

    CloseBtn.MouseButton1Click:Connect(function()
        ExitOverlay.Visible = true
        Tween(ExitOverlay, 0.18, {BackgroundTransparency = 0.5})
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
    --//  GAME ENGINE (Aimbot, Hitbox, ESP, Speed, Fly, Noclip)
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
            local hum  = char:FindFirstChild("Humanoid")
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
                    head.Size = _G.DH_Config.RageHitbox
                        and Vector3.new(_G.DH_Config.HitboxSize,_G.DH_Config.HitboxSize,_G.DH_Config.HitboxSize)
                        or  Vector3.new(1.2,1.2,1.2)
                    head.Transparency = _G.DH_Config.RageHitbox and 0.8 or 0
                    head.CanCollide   = not _G.DH_Config.RageHitbox
                    local h = p.Character:FindFirstChild("DH_High") or Instance.new("Highlight", p.Character)
                    h.Name      = "DH_High"
                    h.Enabled   = _G.DH_Config.ESP
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
    --//  NAVIGATION
    --// ============================================================

    local function ShowRivals()
        HubFrame.Visible = false
        GameLoadFrame.Visible = true
        GameLoadTitle.Text = "Loading Rivals"
        GameLoadSub.Text   = "Initializing scripts..."
        GameLoadBar_Fill.Size = UDim2.new(0,0,1,0)
        Tween(GameLoadBar_Fill, 1.4, {Size = UDim2.new(1,0,1,0)}, Enum.EasingStyle.Quart)
        task.wait(1.6)
        if not getgenv().DiamondHub_Active then return end
        GameLoadFrame.Visible = false
        RivalsMinimized = false
        RivalsFrame.Size  = UDim2.new(0,624,0,374)
        RivalsBody.Visible = true
        RivalsFrame.Visible = true
        RivalsFrame.BackgroundTransparency = 1
        Tween(RivalsFrame, 0.32, {BackgroundTransparency = 0}, Enum.EasingStyle.Quad)
    end

    local function ShowHub()
        RivalsFrame.Visible = false
        HubFrame.Visible    = true
        HubFrame.BackgroundTransparency = 1
        Tween(HubFrame, 0.28, {BackgroundTransparency = 0}, Enum.EasingStyle.Quad)
    end

    BackBtn.MouseButton1Click:Connect(ShowHub)

    -- Register Rivals game card
    AddGameCard("Rivals", "Combat sports — PvP scripts", "⚔️", function()
        ShowRivals()
    end)

    -- "More coming soon" placeholder
    local MoreCard = MakeFrame(GamesScroll, {BackgroundColor3 = Color3.fromRGB(18,18,22), Radius = 9})
    MoreCard.Size = UDim2.new(1,0,0,48)
    MakeStroke(MoreCard, BORDER_CLR, 1, 0.4)
    MakeLabel(MoreCard, {
        Text = "More games coming soon...",
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextColor3 = TEXT_MUTED,
        Size = UDim2.new(1,0,1,0),
    })

    --// ============================================================
    --//  STARTUP SEQUENCE: Loading → Hub
    --// ============================================================

    task.spawn(function()
        task.wait(2.4)
        if not getgenv().DiamondHub_Active then return end
        Tween(LoadingFrame, 0.38, {BackgroundTransparency = 1})
        for _, child in pairs(LoadingFrame:GetDescendants()) do
            if child:IsA("TextLabel") then
                Tween(child, 0.28, {TextTransparency = 1})
            elseif child:IsA("Frame") then
                Tween(child, 0.28, {BackgroundTransparency = 1})
            end
        end
        task.wait(0.42)
        if not getgenv().DiamondHub_Active then return end
        LoadingFrame.Visible = false
        HubFrame.Visible = true
        HubFrame.BackgroundTransparency = 1
        Tween(HubFrame, 0.38, {BackgroundTransparency = 0}, Enum.EasingStyle.Quad)
    end)

end)

if not success then
    warn("DiamondHub Error: " .. tostring(err))
end
