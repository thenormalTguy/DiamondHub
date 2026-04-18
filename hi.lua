
--// Version: 2.0 | Hub Edition

-- Compatibility shim: fall back to _G on executors without getgenv
local getgenv = (typeof(getgenv) == "function") and getgenv or function() return _G end

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
    LoadCenter.Size = UDim2.new(0, 400, 0, 156)
    LoadCenter.Position = UDim2.new(0.5,-200,0.5,-78)

    -- Accent logo mark: small colored bar above the title
    local LogoMark = MakeFrame(LoadCenter, {BackgroundColor3 = ACCENT, Radius = 4})
    LogoMark.Size     = UDim2.new(0,40,0,5)
    LogoMark.Position = UDim2.new(0.5,-20,0,0)
    LogoMark.BackgroundTransparency = 1

    local LoadTitle = MakeLabel(LoadCenter, {
        Text = "DIAMOND HUB",
        TextSize = 32,
        Font = Enum.Font.GothamBold,
        TextColor3 = TEXT_BRIGHT,
        Size = UDim2.new(1,0,0,42),
        Position = UDim2.new(0,0,0,18),
    })
    local LoadSub = MakeLabel(LoadCenter, {
        Text = "Loading",
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        TextColor3 = TEXT_DIM,
        Size = UDim2.new(1,0,0,22),
        Position = UDim2.new(0,0,0,68),
    })
    local ProgressBG = MakeFrame(LoadCenter, {
        BackgroundColor3 = BG_ITEM,
        Size = UDim2.new(1,0,0,3),
        Position = UDim2.new(0,0,0,106),
        Radius = 3,
    })
    local ProgressFill = MakeFrame(ProgressBG, {
        BackgroundColor3 = ACCENT,
        Size = UDim2.new(0,0,1,0),
        Radius = 3,
    })
    MakeLabel(LoadCenter, {
        Text = "v2.0  —  Hub Edition",
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextColor3 = TEXT_MUTED,
        Size = UDim2.new(1,0,0,18),
        Position = UDim2.new(0,0,0,128),
    })

    task.delay(0.1, function()
        Tween(LogoMark, 0.5, {BackgroundTransparency = 0}, Enum.EasingStyle.Quad)
        Tween(LogoMark, 0.5, {Size = UDim2.new(0,56,0,5)}, Enum.EasingStyle.Quart)
    end)
    LoadTitle.TextTransparency = 1
    task.delay(0.2, function() Tween(LoadTitle, 0.5, {TextTransparency = 0}) end)
    LoadSub.TextTransparency = 1
    task.delay(0.4, function() Tween(LoadSub, 0.4, {TextTransparency = 0}) end)

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
        Text = "Diamond Hub",
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextColor3 = TEXT_BRIGHT,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0,140,0,22),
        Position = UDim2.new(0,16,0,7),
    })
    MakeLabel(HubHeader, {
        Text = "select a game",
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextColor3 = TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0,140,0,16),
        Position = UDim2.new(0,16,0,27),
    })

    local HubCloseBtn = MakeButton(HubHeader, {
        Text = "X",
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
    pcall(function() GamesScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y end)
    GamesScroll.BorderSizePixel = 0
    local GamesLayout = Instance.new("UIListLayout", GamesScroll)
    GamesLayout.Padding = UDim.new(0,7)
    GamesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local GamesPad = Instance.new("UIPadding", GamesScroll)
    GamesPad.PaddingTop = UDim.new(0,4)
    GamesPad.PaddingBottom = UDim.new(0,4)

    local function AddGameCard(name, subtitle, tag, onLaunch)
        local Card = MakeFrame(GamesScroll, {BackgroundColor3 = BG_CARD, Radius = 10})
        Card.Size = UDim2.new(1,0,0,72)
        MakeStroke(Card, BORDER_CLR, 1, 0.15)

        -- Small colored tag pill on the left
        local TagPill = MakeFrame(Card, {BackgroundColor3 = Color3.fromRGB(0,90,160), Radius = 5})
        TagPill.Size     = UDim2.new(0,42,0,22)
        TagPill.Position = UDim2.new(0,14,0.5,-11)
        MakeLabel(TagPill, {
            Text = tag,
            TextSize = 10,
            Font = Enum.Font.GothamBold,
            TextColor3 = Color3.fromRGB(160,210,255),
            Size = UDim2.new(1,0,1,0),
        })

        MakeLabel(Card, {
            Text = name,
            TextSize = 16,
            Font = Enum.Font.GothamBold,
            TextColor3 = TEXT_BRIGHT,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1,-160,0,22),
            Position = UDim2.new(0,68,0,12),
        })
        MakeLabel(Card, {
            Text = subtitle,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextColor3 = TEXT_DIM,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1,-160,0,18),
            Position = UDim2.new(0,68,0,36),
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

    -- "Diamond Hub" bold
    MakeLabel(RivalsHeader, {
        Text = "Diamond Hub",
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextColor3 = TEXT_BRIGHT,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0,112,0,20),
        Position = UDim2.new(0,16,0,8),
    })

    -- separator dot
    MakeLabel(RivalsHeader, {
        Text = "·",
        TextSize = 15,
        Font = Enum.Font.Gotham,
        TextColor3 = TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0,10,1,0),
        Position = UDim2.new(0,126,0,0),
    })

    -- "Rivals" subtitle
    MakeLabel(RivalsHeader, {
        Text = "Rivals",
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextColor3 = TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0,60,0,18),
        Position = UDim2.new(0,139,0,17),
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

    local BackBtn  = HeaderBtn(-112, "Hub", BG_ITEM)
    local MinBtn   = HeaderBtn(-74,  "—",  BG_ITEM)
    local CloseBtn = HeaderBtn(-36,  "X",  Color3.fromRGB(190,45,55))

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
        pcall(function() Frame.AutomaticCanvasSize = Enum.AutomaticSize.Y end)
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

        -- Tab label (short text, centered)
        local Ico = MakeLabel(Slot, {
            Text = icon,
            TextSize = 10,
            Font = Enum.Font.GothamBold,
            TextColor3 = active and TEXT_BRIGHT or TEXT_MUTED,
            Size = UDim2.new(1,0,1,0),
            TextWrapped = false,
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

    local HomeTab    = CreateTab("Home",     "Home",    1, true)
    local CombatTab  = CreateTab("Combat",   "Combat",  2, false)
    local VisualsTab = CreateTab("Visuals",  "Visuals", 3, false)
    local MoveTab    = CreateTab("Movement", "Move",    4, false)
    local ProfileTab = CreateTab("Profile",  "Profile", 5, false)
    local DiscordTab = CreateTab("Discord",  "Discord", 6, false)

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
        Text = "Discord",
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
        Text = "Official Support Server",
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
        CopyBtn.Text = "Copied!"
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
                local move = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
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
                    pcall(function()
                        local h = p.Character:FindFirstChild("DH_High") or Instance.new("Highlight", p.Character)
                        h.Name      = "DH_High"
                        h.Enabled   = _G.DH_Config.ESP
                        h.FillColor = ACCENT
                    end)
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
    --//  SCREEN 5 — BLOX FRUITS CHEAT UI
    --// ============================================================

    _G.BF_Config = {
        AutoFarm          = false,
        AutoFarmWeapon    = "Melee",
        AutoBones         = false,
        AutoMaterial      = false,
        SelectedMaterial  = "Dragon Scales (Hydra Island — 3rd Sea)",
        AutoBoss          = false,
        SelectedBoss      = "Gorilla King (Lv. 25)",
        AutoMastery       = false,
        MasteryType       = "Melee",
        AutoStats_Melee   = false,
        AutoStats_Defense = false,
        AutoStats_Sword   = false,
        AutoStats_Gun     = false,
        AutoStats_Fruit   = false,
        ESP               = false,
        FruitNotifier     = false,
        -- Auto Buy toggles (each fires its corresponding CommF_ remote ~3s)
        AutoBuy_TrueTripleKatana = false,
        AutoBuy_CursedDualKatana = false,
        AutoBuy_Tushita          = false,
        AutoBuy_Yama             = false,
        AutoBuy_Saber            = false,
        AutoBuy_SoulCane         = false,
        AutoBuy_BuddySword       = false,
        AutoBuy_BlackLeg         = false,
        AutoBuy_Electric         = false,
        AutoBuy_DragonClaw       = false,
        AutoBuy_DarkStep         = false,
        AutoBuy_DeathStep        = false,
        AutoBuy_Superhuman       = false,
        AutoBuy_SharkmanKarate   = false,
        AutoBuy_ElectricClaw     = false,
        AutoBuy_DragonTalon      = false,
        AutoBuy_Godhuman         = false,
    }

    -- Sea detection via PlaceId
    local function BF_GetSea()
        local id = game.PlaceId
        if id == 4442272183 then return "Second" end
        if id == 7449423635 then return "Third" end
        return "First"
    end

    -- BF window (624x374, same as Rivals)
    local BFFrame = MakeFrame(ScreenGui, {BackgroundColor3 = BG_MAIN})
    BFFrame.Size     = UDim2.new(0,624,0,374)
    BFFrame.Position = UDim2.new(0.5,-312,0.5,-187)
    BFFrame.Visible  = false
    BFFrame.ZIndex   = 10
    BFFrame.ClipsDescendants = true
    MakeCorner(BFFrame, 12)
    MakeStroke(BFFrame, BORDER_CLR, 1, 0.1)

    local BFHeader = MakeFrame(BFFrame, {BackgroundColor3 = BG_PANEL})
    BFHeader.Size = UDim2.new(1,0,0,50)
    MakeCorner(BFHeader, 12)
    MakeFrame(BFHeader, {BackgroundColor3 = BG_PANEL, Size = UDim2.new(1,0,0,12), Position = UDim2.new(0,0,1,-12)})
    MakeFrame(BFFrame,  {BackgroundColor3 = BORDER_CLR, Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,0,50)})

    MakeLabel(BFHeader, {
        Text = "Diamond Hub",
        TextSize = 14, Font = Enum.Font.GothamBold, TextColor3 = TEXT_BRIGHT,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0,112,0,20), Position = UDim2.new(0,16,0,8),
    })
    MakeLabel(BFHeader, {
        Text = "·", TextSize = 15, Font = Enum.Font.Gotham, TextColor3 = TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0,10,1,0), Position = UDim2.new(0,126,0,0),
    })
    MakeLabel(BFHeader, {
        Text = "Blox Fruits", TextSize = 12, Font = Enum.Font.Gotham, TextColor3 = TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0,80,0,18), Position = UDim2.new(0,139,0,17),
    })

    local function BFHeaderBtn(xOff, icon, hoverColor)
        local b = MakeButton(BFHeader, {
            Text = icon, BackgroundColor3 = BG_MAIN, TextColor3 = TEXT_DIM,
            Size = UDim2.new(0,26,0,26), Position = UDim2.new(1,xOff,0.5,-13),
            TextSize = 13, Radius = 5,
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

    local BFBackBtn  = BFHeaderBtn(-112, "Hub", BG_ITEM)
    local BFMinBtn   = BFHeaderBtn(-74,  "—",  BG_ITEM)
    local BFCloseBtn = BFHeaderBtn(-36,  "X",  Color3.fromRGB(190,45,55))

    local bfDragging, bfDragStart, bfStartPos
    BFHeader.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            bfDragging = true; bfDragStart = i.Position; bfStartPos = BFFrame.Position
        end
    end)
    table.insert(getgenv().DiamondHub_Connections, UserInputService.InputChanged:Connect(function(i)
        if bfDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - bfDragStart
            BFFrame.Position = UDim2.new(bfStartPos.X.Scale, bfStartPos.X.Offset+d.X, bfStartPos.Y.Scale, bfStartPos.Y.Offset+d.Y)
        end
    end))
    table.insert(getgenv().DiamondHub_Connections, UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then bfDragging = false end
    end))

    local BFBody = MakeFrame(BFFrame, {Transparency = 1})
    BFBody.Size     = UDim2.new(1,0,1,-51)
    BFBody.Position = UDim2.new(0,0,0,51)

    local BFSidebar = MakeFrame(BFBody, {BackgroundColor3 = BG_PANEL})
    BFSidebar.Size = UDim2.new(0,50,1,0)
    local BFSideLayout = Instance.new("UIListLayout", BFSidebar)
    BFSideLayout.Padding             = UDim.new(0,0)
    BFSideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    BFSideLayout.FillDirection       = Enum.FillDirection.Vertical
    BFSideLayout.SortOrder           = Enum.SortOrder.LayoutOrder
    MakeFrame(BFBody, {BackgroundColor3 = BORDER_CLR, Size = UDim2.new(0,1,1,0), Position = UDim2.new(0,50,0,0)})

    local BFPages = MakeFrame(BFBody, {Transparency = 1})
    BFPages.Size     = UDim2.new(1,-52,1,0)
    BFPages.Position = UDim2.new(0,52,0,0)

    local BFTabs = {}
    local function CreateBFTab(tabName, icon, layoutOrder, active)
        local Frame = Instance.new("ScrollingFrame", BFPages)
        Frame.Size = UDim2.new(1,0,1,0)
        Frame.BackgroundTransparency = 1
        Frame.Visible = active
        Frame.ScrollBarThickness = 2
        Frame.ScrollBarImageColor3 = Color3.fromRGB(50,50,65)
        Frame.CanvasSize = UDim2.new(0,0,0,0)
        pcall(function() Frame.AutomaticCanvasSize = Enum.AutomaticSize.Y end)
        Frame.BorderSizePixel = 0
        local Layout = Instance.new("UIListLayout", Frame)
        Layout.Padding = UDim.new(0,8)
        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        local FPad = Instance.new("UIPadding", Frame)
        FPad.PaddingTop = UDim.new(0,10); FPad.PaddingBottom = UDim.new(0,10)
        FPad.PaddingLeft = UDim.new(0,10); FPad.PaddingRight = UDim.new(0,10)

        local Slot = Instance.new("Frame", BFSidebar)
        Slot.Size = UDim2.new(1,0,0,46)
        Slot.BackgroundTransparency = 1
        Slot.BorderSizePixel = 0
        Slot.LayoutOrder = layoutOrder

        local Bar = MakeFrame(Slot, {BackgroundColor3 = ACCENT})
        Bar.Size = UDim2.new(0,3,0,26)
        Bar.Position = UDim2.new(0,0,0.5,-13)
        Bar.BackgroundTransparency = active and 0 or 1
        MakeCorner(Bar, 2)

        local Pill = MakeFrame(Slot, {BackgroundColor3 = BG_ITEM, Radius = 8})
        Pill.Size = UDim2.new(0,36,0,36)
        Pill.Position = UDim2.new(0.5,-18,0.5,-18)
        Pill.BackgroundTransparency = active and 0 or 1

        local Ico = MakeLabel(Slot, {
            Text = icon, TextSize = 10, Font = Enum.Font.GothamBold,
            TextColor3 = active and TEXT_BRIGHT or TEXT_MUTED,
            Size = UDim2.new(1,0,1,0), TextWrapped = false,
        })

        local Btn = Instance.new("TextButton", Slot)
        Btn.Size = UDim2.new(1,0,1,0)
        Btn.BackgroundTransparency = 1
        Btn.Text = ""
        Btn.ZIndex = 5
        Btn.MouseEnter:Connect(function()
            if not (BFTabs[tabName] and BFTabs[tabName].F.Visible) then
                Tween(Pill, 0.12, {BackgroundTransparency = 0.55, BackgroundColor3 = BG_ITEM})
                Tween(Ico,  0.12, {TextColor3 = TEXT_DIM})
            end
        end)
        Btn.MouseLeave:Connect(function()
            if not (BFTabs[tabName] and BFTabs[tabName].F.Visible) then
                Tween(Pill, 0.12, {BackgroundTransparency = 1})
                Tween(Ico,  0.12, {TextColor3 = TEXT_MUTED})
            end
        end)
        Btn.MouseButton1Click:Connect(function()
            for _, v in pairs(BFTabs) do
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
        BFTabs[tabName] = {F = Frame, Pill = Pill, Bar = Bar, Ico = Ico}
        return Frame
    end

    local BF_HomeTab    = CreateBFTab("BF_Home",    "Home",    1, true)
    local BF_MainTab    = CreateBFTab("BF_Main",    "Main",    2, false)
    local BF_MasteryTab = CreateBFTab("BF_Mastery", "Mastery", 3, false)
    local BF_BuyTab     = CreateBFTab("BF_Buy",     "Buy",     4, false)
    local BF_VisualsTab = CreateBFTab("BF_Visuals", "Visuals", 5, false)

    local BFAvatarHolder = MakeFrame(BFBody, {Transparency = 1})
    BFAvatarHolder.Size     = UDim2.new(0,50,0,48)
    BFAvatarHolder.Position = UDim2.new(0,0,1,-48)
    local BFAvatarImg = Instance.new("ImageLabel", BFAvatarHolder)
    BFAvatarImg.Size     = UDim2.new(0,30,0,30)
    BFAvatarImg.Position = UDim2.new(0.5,-15,0.5,-15)
    BFAvatarImg.BackgroundColor3 = BG_ITEM
    BFAvatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    MakeCorner(BFAvatarImg, 15)
    MakeStroke(BFAvatarImg, BORDER_CLR, 1, 0.15)

    -- BF toggle (uses _G.BF_Config)
    local function BFToggle(parent, label, sublabel, key)
        local Row = MakeFrame(parent, {BackgroundColor3 = BG_CARD, Radius = 9})
        Row.Size = UDim2.new(1,0,0,56)
        MakeStroke(Row, BORDER_CLR, 1, 0.15)
        MakeLabel(Row, {
            Text = label, TextSize = 13, Font = Enum.Font.GothamBold, TextColor3 = TEXT_BRIGHT,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1,-68,0,19), Position = UDim2.new(0,14,0,9),
        })
        if sublabel and sublabel ~= "" then
            MakeLabel(Row, {
                Text = sublabel, TextSize = 11, Font = Enum.Font.Gotham, TextColor3 = TEXT_DIM,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(1,-68,0,16), Position = UDim2.new(0,14,0,29),
            })
        end
        local PillBG = MakeFrame(Row, {BackgroundColor3 = _G.BF_Config[key] and ACCENT or BG_ITEM, Radius = 100})
        PillBG.Size = UDim2.new(0,40,0,22); PillBG.Position = UDim2.new(1,-52,0.5,-11)
        MakeStroke(PillBG, BORDER_CLR, 1, 0.3)
        local Dot = MakeFrame(PillBG, {BackgroundColor3 = Color3.new(1,1,1), Radius = 100})
        Dot.Size = UDim2.new(0,16,0,16)
        Dot.Position = _G.BF_Config[key] and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
        local Toggling = false
        Row.InputBegan:Connect(function(i)
            if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            if Toggling then return end
            Toggling = true
            _G.BF_Config[key] = not _G.BF_Config[key]
            local on = _G.BF_Config[key]
            Tween(PillBG, 0.2, {BackgroundColor3 = on and ACCENT or BG_ITEM})
            Tween(Dot,    0.2, {Position = on and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)})
            task.wait(0.25); Toggling = false
        end)
        return Row
    end

    -- Inline expandable dropdown
    local function BFDropdown(parent, label, options, configKey, defaultIdx)
        if defaultIdx and (not _G.BF_Config[configKey] or _G.BF_Config[configKey] == "") then
            _G.BF_Config[configKey] = options[defaultIdx]
        end
        local closedH = 52
        local openH   = closedH + (#options * 30) + 6
        local Wrap = MakeFrame(parent, {BackgroundColor3 = BG_CARD, Radius = 9})
        Wrap.Size = UDim2.new(1,0,0,closedH)
        Wrap.ClipsDescendants = true
        MakeStroke(Wrap, BORDER_CLR, 1, 0.15)

        MakeLabel(Wrap, {
            Text = label, TextSize = 12, Font = Enum.Font.GothamBold, TextColor3 = TEXT_BRIGHT,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1,-48,0,18), Position = UDim2.new(0,12,0,8),
        })
        local SelLabel = MakeLabel(Wrap, {
            Text = _G.BF_Config[configKey] or options[1] or "", TextSize = 11, Font = Enum.Font.Gotham, TextColor3 = ACCENT,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1,-48,0,16), Position = UDim2.new(0,12,0,28),
        })
        local ArrowBtn = MakeButton(Wrap, {
            Text = "v", BackgroundColor3 = BG_ITEM, TextColor3 = TEXT_DIM, TextSize = 10,
            Size = UDim2.new(0,28,0,24), Position = UDim2.new(1,-36,0,14), Radius = 5,
        })

        local OptionList = MakeFrame(Wrap, {Transparency = 1})
        OptionList.Size     = UDim2.new(1,-16,0,#options * 30)
        OptionList.Position = UDim2.new(0,8,0,closedH + 2)
        local OLL = Instance.new("UIListLayout", OptionList)
        OLL.Padding = UDim.new(0,2)
        OLL.HorizontalAlignment = Enum.HorizontalAlignment.Left

        local isOpen = false
        local function CloseDropdown()
            if isOpen then
                isOpen = false
                Tween(Wrap, 0.18, {Size = UDim2.new(1,0,0,closedH)}, Enum.EasingStyle.Quart)
                ArrowBtn.Text = "v"
            end
        end

        for _, opt in ipairs(options) do
            local isSelected = (_G.BF_Config[configKey] == opt)
            local OptBtn = MakeButton(OptionList, {
                Text = opt,
                BackgroundColor3 = isSelected and BG_ITEM or Color3.fromRGB(22,22,27),
                TextColor3 = isSelected and ACCENT or TEXT_DIM,
                TextSize = 11,
                Size = UDim2.new(1,0,0,28),
                Radius = 6,
            })
            OptBtn.TextXAlignment = Enum.TextXAlignment.Left
            local op = Instance.new("UIPadding", OptBtn)
            op.PaddingLeft = UDim.new(0,10)
            OptBtn.MouseButton1Click:Connect(function()
                _G.BF_Config[configKey] = opt
                SelLabel.Text = opt
                CloseDropdown()
            end)
        end

        local function ToggleDrop()
            isOpen = not isOpen
            Tween(Wrap, 0.18, {Size = UDim2.new(1,0,0, isOpen and openH or closedH)}, Enum.EasingStyle.Quart)
            ArrowBtn.Text = isOpen and "^" or "v"
        end
        ArrowBtn.MouseButton1Click:Connect(ToggleDrop)
        local HdrClick = Instance.new("TextButton", Wrap)
        HdrClick.Size = UDim2.new(1,-44,0,52)
        HdrClick.BackgroundTransparency = 1
        HdrClick.Text = ""
        HdrClick.ZIndex = 5
        HdrClick.MouseButton1Click:Connect(ToggleDrop)
        return Wrap
    end

    -- Section divider label
    local function BF_SecLabel(parent, text)
        MakeLabel(parent, {
            Text = text, TextSize = 10, Font = Enum.Font.GothamBold, TextColor3 = TEXT_DIM,
            TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1,0,0,18),
        })
    end

    --// ─── HOME TAB ─────────────────────────────────────────────────

    local BF_GreetCard = MakeCard(BF_HomeTab, 68)
    local BF_AvatarImg = Instance.new("ImageLabel", BF_GreetCard)
    BF_AvatarImg.Size = UDim2.new(0,44,0,44); BF_AvatarImg.Position = UDim2.new(0,12,0.5,-22)
    BF_AvatarImg.BackgroundColor3 = BG_ITEM
    BF_AvatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    MakeCorner(BF_AvatarImg, 22); MakeStroke(BF_AvatarImg, BORDER_CLR, 1.5, 0.1)
    MakeLabel(BF_GreetCard, {
        Text = "Hello, " .. LocalPlayer.DisplayName, TextSize = 15, Font = Enum.Font.GothamBold,
        TextColor3 = TEXT_BRIGHT, TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-72,0,20), Position = UDim2.new(0,66,0,12),
    })
    MakeLabel(BF_GreetCard, {
        Text = LocalPlayer.Name .. "  ·  Diamond Hub  ·  Blox Fruits",
        TextSize = 11, Font = Enum.Font.Gotham, TextColor3 = TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-72,0,16), Position = UDim2.new(0,66,0,36),
    })

    local BF_ColWrap = MakeFrame(BF_HomeTab, {Transparency = 1})
    BF_ColWrap.Size = UDim2.new(1,0,0,168)
    local BF_CL = Instance.new("UIListLayout", BF_ColWrap)
    BF_CL.FillDirection = Enum.FillDirection.Horizontal
    BF_CL.Padding = UDim.new(0,8)
    BF_CL.HorizontalAlignment = Enum.HorizontalAlignment.Left

    -- Session card
    local BF_SessCard = MakeFrame(BF_ColWrap, {BackgroundColor3 = BG_CARD, Radius = 9})
    BF_SessCard.Size = UDim2.new(0.5,-4,1,0)
    MakeStroke(BF_SessCard, BORDER_CLR, 1, 0.15)
    MakeLabel(BF_SessCard, {
        Text = "Session", TextSize = 12, Font = Enum.Font.GothamBold, TextColor3 = TEXT_BRIGHT,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-12,0,18), Position = UDim2.new(0,11,0,9),
    })
    MakeLabel(BF_SessCard, {
        Text = "Current session info", TextSize = 10, Font = Enum.Font.Gotham, TextColor3 = TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-12,0,14), Position = UDim2.new(0,11,0,25),
    })
    local function BF_SessPill(par, xs, xo, y, val, lbl)
        local p = MakeFrame(par, {BackgroundColor3 = BG_ITEM, Radius = 6})
        p.Size = UDim2.new(0.5,-10,0,44); p.Position = UDim2.new(xs,xo,0,y)
        MakeLabel(p, {Text=tostring(val), TextSize=14, Font=Enum.Font.GothamBold, TextColor3=TEXT_BRIGHT,
            TextXAlignment=Enum.TextXAlignment.Left, Size=UDim2.new(1,-8,0,19), Position=UDim2.new(0,8,0,6)})
        MakeLabel(p, {Text=lbl, TextSize=10, Font=Enum.Font.Gotham, TextColor3=TEXT_DIM,
            TextXAlignment=Enum.TextXAlignment.Left, Size=UDim2.new(1,-8,0,13), Position=UDim2.new(0,8,0,26)})
    end
    BF_SessPill(BF_SessCard,  0,  8, 44, #Players:GetPlayers(), "Players")
    BF_SessPill(BF_SessCard, 0.5, 2, 44, BF_GetSea().." Sea",  "Current Sea")
    BF_SessPill(BF_SessCard,  0,  8, 96, LocalPlayer.AccountAge.."d", "Account Age")
    BF_SessPill(BF_SessCard, 0.5, 2, 96, "#"..tostring(LocalPlayer.UserId):sub(1,7), "User ID")

    -- Hub status card
    local BF_HubCard = MakeFrame(BF_ColWrap, {BackgroundColor3 = Color3.fromRGB(13,34,54), Radius = 9})
    BF_HubCard.Size = UDim2.new(0.5,-4,1,0)
    MakeStroke(BF_HubCard, Color3.fromRGB(0,90,160), 1, 0.35)
    MakeLabel(BF_HubCard, {
        Text = "Hub", TextSize = 12, Font = Enum.Font.GothamBold, TextColor3 = TEXT_BRIGHT,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-12,0,18), Position = UDim2.new(0,11,0,9),
    })
    MakeLabel(BF_HubCard, {
        Text = "Diamond Hub is active and running", TextSize = 10, Font = Enum.Font.Gotham,
        TextColor3 = Color3.fromRGB(120,165,210), TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-12,0,28), Position = UDim2.new(0,11,0,24), TextWrapped = true,
    })
    local BF_ActPill = MakeFrame(BF_HubCard, {BackgroundColor3 = Color3.fromRGB(9,46,78), Radius = 6})
    BF_ActPill.Size = UDim2.new(1,-18,0,36); BF_ActPill.Position = UDim2.new(0,9,0,58)
    local BF_GDot = MakeFrame(BF_ActPill, {BackgroundColor3 = Color3.fromRGB(55,215,95), Radius = 100})
    BF_GDot.Size = UDim2.new(0,7,0,7); BF_GDot.Position = UDim2.new(0,10,0.5,-3)
    MakeLabel(BF_ActPill, {
        Text = "Hub Active", TextSize = 13, Font = Enum.Font.GothamBold,
        TextColor3 = Color3.fromRGB(195,230,255), TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-28,1,0), Position = UDim2.new(0,24,0,0),
    })
    local BF_VerPill2 = MakeFrame(BF_HubCard, {BackgroundColor3 = Color3.fromRGB(9,46,78), Radius = 6})
    BF_VerPill2.Size = UDim2.new(1,-18,0,36); BF_VerPill2.Position = UDim2.new(0,9,0,100)
    MakeLabel(BF_VerPill2, {
        Text = "v2.0  ·  Hub Edition", TextSize = 12, Font = Enum.Font.Gotham,
        TextColor3 = Color3.fromRGB(145,195,240), TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-14,1,0), Position = UDim2.new(0,10,0,0),
    })

    local BF_DiscRow = MakeFrame(BF_HomeTab, {BackgroundColor3 = Color3.fromRGB(29,32,78), Radius = 9})
    BF_DiscRow.Size = UDim2.new(1,0,0,52)
    MakeStroke(BF_DiscRow, Color3.fromRGB(78,86,210), 1, 0.3)
    MakeLabel(BF_DiscRow, {
        Text = "Discord", TextSize = 14, Font = Enum.Font.GothamBold,
        TextColor3 = Color3.fromRGB(195,205,255), TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-100,0,22), Position = UDim2.new(0,13,0,7),
    })
    MakeLabel(BF_DiscRow, {
        Text = "Tap to join the Support Server", TextSize = 11, Font = Enum.Font.Gotham,
        TextColor3 = Color3.fromRGB(130,140,210), TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-100,0,16), Position = UDim2.new(0,13,0,30),
    })
    local BF_DiscBtn = MakeButton(BF_DiscRow, {
        Text = "Join", BackgroundColor3 = Color3.fromRGB(78,86,210), TextColor3 = Color3.new(1,1,1),
        Size = UDim2.new(0,52,0,28), Position = UDim2.new(1,-64,0.5,-14), TextSize = 12, Radius = 6,
    })
    BF_DiscBtn.MouseEnter:Connect(function() Tween(BF_DiscBtn, 0.13, {BackgroundColor3 = Color3.fromRGB(100,110,240)}) end)
    BF_DiscBtn.MouseLeave:Connect(function() Tween(BF_DiscBtn, 0.13, {BackgroundColor3 = Color3.fromRGB(78,86,210)}) end)

    --// ─── MAIN TAB ─────────────────────────────────────────────────

    BF_SecLabel(BF_MainTab, "AUTO FARM LEVEL")
    BFToggle(BF_MainTab, "Auto Farm Level", "Teleports to nearest NPC and attacks", "AutoFarm")
    BFDropdown(BF_MainTab, "Attack Weapon", {"Melee", "Blox Fruit", "Sword"}, "AutoFarmWeapon")

    BF_SecLabel(BF_MainTab, "AUTO FARM BONES")
    local BonesRow = MakeFrame(BF_MainTab, {BackgroundColor3 = BG_CARD, Radius = 9})
    BonesRow.Size = UDim2.new(1,0,0,56)
    MakeStroke(BonesRow, BORDER_CLR, 1, 0.15)
    MakeLabel(BonesRow, {
        Text = "Auto Farm Bones", TextSize = 13, Font = Enum.Font.GothamBold, TextColor3 = TEXT_BRIGHT,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-68,0,19), Position = UDim2.new(0,14,0,9),
    })
    local BonesSubLbl = MakeLabel(BonesRow, {
        Text = "Haunted Castle: Zombies, Souls, Mummies, Vampires",
        TextSize = 11, Font = Enum.Font.Gotham, TextColor3 = TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-68,0,16), Position = UDim2.new(0,14,0,29),
    })
    local BonesPill = MakeFrame(BonesRow, {BackgroundColor3 = BG_ITEM, Radius = 100})
    BonesPill.Size = UDim2.new(0,40,0,22); BonesPill.Position = UDim2.new(1,-52,0.5,-11)
    MakeStroke(BonesPill, BORDER_CLR, 1, 0.3)
    local BonesDot = MakeFrame(BonesPill, {BackgroundColor3 = Color3.new(1,1,1), Radius = 100})
    BonesDot.Size = UDim2.new(0,16,0,16); BonesDot.Position = UDim2.new(0,3,0.5,-8)
    local BonesToggling = false
    BonesRow.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if BonesToggling then return end
        BonesToggling = true
        if BF_GetSea() ~= "Third" then
            BonesSubLbl.Text = "Requires Third Sea! You are in " .. BF_GetSea() .. " Sea."
            BonesSubLbl.TextColor3 = Color3.fromRGB(220,80,80)
            task.wait(2.5)
            BonesSubLbl.Text = "Haunted Castle: Zombies, Souls, Mummies, Vampires"
            BonesSubLbl.TextColor3 = TEXT_DIM
            BonesToggling = false
            return
        end
        _G.BF_Config.AutoBones = not _G.BF_Config.AutoBones
        local on = _G.BF_Config.AutoBones
        Tween(BonesPill, 0.2, {BackgroundColor3 = on and ACCENT or BG_ITEM})
        Tween(BonesDot,  0.2, {Position = on and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)})
        task.wait(0.25); BonesToggling = false
    end)

    BF_SecLabel(BF_MainTab, "AUTO FARM MATERIAL")
    BFToggle(BF_MainTab, "Auto Farm Material", "Kills NPCs dropping the selected material", "AutoMaterial")
    BFDropdown(BF_MainTab, "Select Material", {
        "Dragon Scales (Hydra Island — 3rd Sea)",
        "Scrap Metal (Junk Island — All Seas)",
        "Magma Ore (Magma Village — 1st/2nd Sea)",
        "Vampire Fangs (Graveyard — 2nd Sea)",
        "Leather (Port Town / Jungle — 1st Sea)",
        "Angel Wings (Upper Skylands — 1st Sea)",
        "Dark Fragment (Dark Arena — 2nd Sea)",
        "Leviathan Heart (Sea Zone — 3rd Sea)",
    }, "SelectedMaterial", 1)

    BF_SecLabel(BF_MainTab, "AUTO FARM BOSS")
    BFToggle(BF_MainTab, "Auto Farm Boss", "Attacks the selected boss continuously", "AutoBoss")
    BF_SecLabel(BF_MainTab, "First Sea Bosses")
    BFDropdown(BF_MainTab, "First Sea Boss", {
        "Gorilla King (Lv. 25)",
        "Bobby / The Clown (Lv. 55)",
        "The Saw (Lv. 100)",
        "Yeti (Lv. 105)",
        "Mob Leader (Lv. 120)",
        "Vice Admiral (Lv. 130)",
        "Saber Expert (Lv. 200)",
        "Warden (Lv. 220)",
        "Chief Warden (Lv. 230)",
        "Swan (Lv. 240)",
        "Magma Admiral (Lv. 350)",
        "Fishman Lord (Lv. 425)",
        "Wysper (Lv. 500)",
        "Thunder God / Enel (Lv. 575)",
        "Cyborg (Lv. 675)",
        "Ice Admiral (Lv. 700)",
        "Greybeard (Lv. 750)",
    }, "SelectedBoss", 1)
    BF_SecLabel(BF_MainTab, "Second Sea Bosses")
    BFDropdown(BF_MainTab, "Second Sea Boss", {
        "Diamond (Lv. 750)",
        "Jeremy (Lv. 850)",
        "Fajita (Lv. 925)",
        "Don Swan (Lv. 1000)",
        "Darkbeard (Lv. 1000)",
        "Order (Lv. 1250)",
        "Cursed Captain (Lv. 1325)",
        "Smoke Admiral (Lv. 1150)",
        "Awakened Ice Admiral (Lv. 1400)",
        "Tide Keeper (Lv. 1475)",
    }, "SelectedBoss")
    BF_SecLabel(BF_MainTab, "Third Sea Bosses")
    BFDropdown(BF_MainTab, "Third Sea Boss", {
        "Stone (Lv. 1550)",
        "Island Empress (Lv. 1675)",
        "Kilo Admiral (Lv. 1750)",
        "Captain Elephant (Lv. 1875)",
        "Beautiful Pirate (Lv. 1950)",
        "Soul Reaper (Lv. 2100)",
        "Cake Queen (Lv. 2175)",
        "Dough King (Lv. 2300)",
        "Rip_indra (Lv. 5000)",
        "Leviathan (Sea Boss)",
    }, "SelectedBoss")

    --// ─── BUY TAB ──────────────────────────────────────────────────

    BF_SecLabel(BF_BuyTab, "AUTO BUY — SWORDS")
    BFToggle(BF_BuyTab, "True Triple Katana", "Combines Saddi, Wando, Shisui (need all 3)", "AutoBuy_TrueTripleKatana")
    BFToggle(BF_BuyTab, "Cursed Dual Katana", "Buys CDK from Cursed Ship NPC",              "AutoBuy_CursedDualKatana")
    BFToggle(BF_BuyTab, "Tushita",            "Claims Tushita using God's Chalice",          "AutoBuy_Tushita")
    BFToggle(BF_BuyTab, "Yama",               "Combines CDK + Tushita into Yama",            "AutoBuy_Yama")
    BFToggle(BF_BuyTab, "Saber",              "Buys Saber from Saber Expert (850K Beli)",    "AutoBuy_Saber")
    BFToggle(BF_BuyTab, "Soul Cane",          "Buys Soul Cane (1.85M Beli)",                 "AutoBuy_SoulCane")
    BFToggle(BF_BuyTab, "Buddy Sword",        "Buys Buddy Sword (5M Beli)",                  "AutoBuy_BuddySword")

    BF_SecLabel(BF_BuyTab, "AUTO BUY — FIGHTING STYLES")
    BFToggle(BF_BuyTab, "Black Leg",          "Buys Black Leg (1.5K Beli)",                  "AutoBuy_BlackLeg")
    BFToggle(BF_BuyTab, "Electric",           "Buys Electric (500K Beli)",                   "AutoBuy_Electric")
    BFToggle(BF_BuyTab, "Dragon Claw",        "Claims Dragon Claw via NPC quest",            "AutoBuy_DragonClaw")
    BFToggle(BF_BuyTab, "Dark Step",          "Buys Dark Step (250K Beli)",                  "AutoBuy_DarkStep")
    BFToggle(BF_BuyTab, "Death Step",         "Upgrades Black Leg → Death Step (Bones)",     "AutoBuy_DeathStep")
    BFToggle(BF_BuyTab, "Superhuman",         "Combines BL + Electric + DC + Sharkman (3M)", "AutoBuy_Superhuman")
    BFToggle(BF_BuyTab, "Sharkman Karate",    "Buys Sharkman Karate (5M Beli, all stages)",  "AutoBuy_SharkmanKarate")
    BFToggle(BF_BuyTab, "Electric Claw",      "Combines Electric + Sharkman + Dragon Claw",  "AutoBuy_ElectricClaw")
    BFToggle(BF_BuyTab, "Dragon Talon",       "Claims Dragon Talon (Hidden NPC quest)",      "AutoBuy_DragonTalon")
    BFToggle(BF_BuyTab, "Godhuman",           "Combines Superhuman + Death Step + Talon + EC", "AutoBuy_Godhuman")

    --// ─── MASTERY TAB ──────────────────────────────────────────────

    BF_SecLabel(BF_MasteryTab, "AUTO FARM MASTERY")
    BFToggle(BF_MasteryTab, "Auto Farm Mastery", "Farms mastery using selected weapon", "AutoMastery")
    BFDropdown(BF_MasteryTab, "Mastery Weapon", {"Melee", "Blox Fruit", "Sword"}, "MasteryType")

    BF_SecLabel(BF_MasteryTab, "AUTO ADD STATS")
    BFToggle(BF_MasteryTab, "Auto Add Melee Stats",   "Spends stat points into Melee",      "AutoStats_Melee")
    BFToggle(BF_MasteryTab, "Auto Add Defense Stats", "Spends stat points into Defense",    "AutoStats_Defense")
    BFToggle(BF_MasteryTab, "Auto Add Sword Stats",   "Spends stat points into Sword",      "AutoStats_Sword")
    BFToggle(BF_MasteryTab, "Auto Add Gun Stats",     "Spends stat points into Gun",        "AutoStats_Gun")
    BFToggle(BF_MasteryTab, "Auto Add Fruit Stats",   "Spends stat points into Blox Fruit", "AutoStats_Fruit")

    --// ─── VISUALS TAB ──────────────────────────────────────────────

    BFToggle(BF_VisualsTab, "ESP Players",    "Highlights all players through walls",  "ESP")
    BFToggle(BF_VisualsTab, "Fruit Notifier", "Teleports to nearby dropped fruits",    "FruitNotifier")

    --// ─── BF MINIMIZE & CLOSE ─────────────────────────────────────

    local BFMinimized = false
    BFMinBtn.MouseButton1Click:Connect(function()
        BFMinimized = not BFMinimized
        if BFMinimized then
            BFBody.Visible = false
            Tween(BFFrame, 0.28, {Size = UDim2.new(0,624,0,51)}, Enum.EasingStyle.Quart)
        else
            Tween(BFFrame, 0.28, {Size = UDim2.new(0,624,0,374)}, Enum.EasingStyle.Quart)
            task.wait(0.22)
            BFBody.Visible = true
        end
    end)

    local BFExitOverlay = MakeFrame(BFFrame, {BackgroundColor3 = Color3.new(0,0,0), Transparency = 1})
    BFExitOverlay.Size = UDim2.new(1,0,1,0); BFExitOverlay.ZIndex = 200; BFExitOverlay.Visible = false
    local BFExitBox = MakeFrame(BFExitOverlay, {BackgroundColor3 = BG_PANEL, Radius = 10})
    BFExitBox.Size = UDim2.new(0,270,0,132); BFExitBox.Position = UDim2.new(0.5,-135,0.5,-66); BFExitBox.ZIndex = 201
    MakeStroke(BFExitBox, BORDER_CLR, 1, 0.1)
    MakeLabel(BFExitBox, {
        Text = "Close Diamond Hub?", TextSize = 15, Font = Enum.Font.GothamBold,
        Size = UDim2.new(1,0,0,52), Position = UDim2.new(0,0,0,8),
    }).ZIndex = 202
    local BFExitYes = MakeButton(BFExitBox, {
        Text = "Close", BackgroundColor3 = Color3.fromRGB(190,45,55),
        Size = UDim2.new(0,96,0,34), Position = UDim2.new(0,14,0,74), TextSize = 13,
    }); BFExitYes.ZIndex = 202
    local BFExitNo = MakeButton(BFExitBox, {
        Text = "Cancel", BackgroundColor3 = BG_ITEM,
        Size = UDim2.new(0,96,0,34), Position = UDim2.new(1,-110,0,74), TextSize = 13,
    }); BFExitNo.ZIndex = 202
    BFCloseBtn.MouseButton1Click:Connect(function()
        BFExitOverlay.Visible = true
        Tween(BFExitOverlay, 0.18, {BackgroundTransparency = 0.5})
    end)
    BFExitNo.MouseButton1Click:Connect(function()
        Tween(BFExitOverlay, 0.15, {BackgroundTransparency = 1})
        task.wait(0.15); BFExitOverlay.Visible = false
    end)
    BFExitYes.MouseButton1Click:Connect(function()
        getgenv().DiamondHub_Active = false
        getgenv().DiamondHub_Loaded = false
        ScreenGui:Destroy()
    end)

    --// ─── BF ENGINE LOOPS ─────────────────────────────────────────

    -- Real Blox Fruits remotes (CommF_ is the main game RemoteFunction)
    local BF_RS      = game:GetService("ReplicatedStorage")
    local BF_Remotes = BF_RS:FindFirstChild("Remotes")
    local BF_CommF   = BF_Remotes and BF_Remotes:FindFirstChild("CommF_")

    -- Quest table: {questName, tier, minLv, maxLv, mobName, sea}
    -- Standard public Blox Fruits quest progression (1st → 2nd → 3rd Sea)
    local BF_Quests = {
        {"BanditQuest1",        1,    1,    9, "Bandit",                1},
        {"JungleQuest",         1,   10,   14, "Monkey",                1},
        {"JungleQuest",         2,   15,   29, "Gorilla",               1},
        {"BuggyQuest1",         1,   30,   39, "Pirate",                1},
        {"BuggyQuest1",         2,   40,   59, "Brute",                 1},
        {"DesertQuest",         1,   60,   74, "Desert Bandit",         1},
        {"DesertQuest",         2,   75,   89, "Desert Officer",        1},
        {"SnowQuest",           1,   90,   99, "Snow Bandit",           1},
        {"SnowQuest",           2,  100,  119, "Snowman",               1},
        {"MarineQuest2",        1,  120,  149, "Chief Petty Officer",   1},
        {"SkyQuest",            1,  150,  174, "Sky Bandit",            1},
        {"SkyQuest",            2,  175,  189, "Dark Master",           1},
        {"PrisonerQuest",       1,  190,  209, "Prisoner",              1},
        {"PrisonerQuest",       2,  210,  249, "Dangerous Prisoner",    1},
        {"ColosseumQuest",      1,  250,  274, "Toga Warrior",          1},
        {"ColosseumQuest",      2,  275,  299, "Gladiator",             1},
        {"MagmaQuest",          1,  300,  324, "Military Soldier",      1},
        {"MagmaQuest",          2,  325,  374, "Military Spy",          1},
        {"FishmanQuest",        1,  375,  399, "Fishman Warrior",       1},
        {"FishmanQuest",        2,  400,  449, "Fishman Commando",      1},
        {"SkyExp1Quest",        1,  450,  474, "God's Guard",           1},
        {"SkyExp1Quest",        2,  475,  524, "Shanda",                1},
        {"SkyExp2Quest",        1,  525,  549, "Royal Squad",           1},
        {"SkyExp2Quest",        2,  550,  624, "Royal Soldier",         1},
        {"FountainQuest",       1,  625,  649, "Galley Pirate",         1},
        {"FountainQuest",       2,  650,  699, "Galley Captain",        1},
        -- Second Sea
        {"Area1Quest",          1,  700,  724, "Raider",                2},
        {"Area1Quest",          2,  725,  774, "Mercenary",             2},
        {"Area2Quest",          1,  775,  824, "Swan Pirate",           2},
        {"Area2Quest",          2,  825,  874, "Factory Staff",         2},
        {"MarineQuest3",        1,  875,  899, "Marine Lieutenant",     2},
        {"MarineQuest3",        2,  900,  949, "Marine Captain",        2},
        {"ZombieQuest",         1,  950,  974, "Zombie",                2},
        {"ZombieQuest",         2,  975,  999, "Vampire",               2},
        {"SnowMountainQuest",   1, 1000, 1049, "Snow Trooper",          2},
        {"SnowMountainQuest",   2, 1050, 1099, "Winter Warrior",        2},
        {"IceSideQuest",        1, 1100, 1124, "Lab Subordinate",       2},
        {"IceSideQuest",        2, 1125, 1174, "Horned Warrior",        2},
        {"FireSideQuest",       1, 1175, 1199, "Magma Ninja",           2},
        {"FireSideQuest",       2, 1200, 1249, "Lava Pirate",           2},
        {"ZQuest",              1, 1250, 1274, "Ship Deckhand",         2},
        {"ZQuest",              2, 1275, 1299, "Ship Engineer",         2},
        {"GraveyardQuest",      1, 1300, 1324, "Zombie",                2},
        {"GraveyardQuest",      2, 1325, 1349, "Vampire",               2},
        {"PiratePortQuest",     1, 1350, 1424, "Pirate Millionaire",    2},
        {"PiratePortQuest",     2, 1425, 1499, "Toxic Pirate",          2},
        -- Third Sea
        {"AmazonQuest",         1, 1500, 1574, "Dragon Crew Warrior",   3},
        {"AmazonQuest",         2, 1575, 1624, "Dragon Crew Archer",    3},
        {"MarineTreeIsland",    1, 1625, 1699, "Marine Commodore",      3},
        {"MarineTreeIsland",    2, 1700, 1724, "Marine Rear Admiral",   3},
        {"DeepForestIsland",    1, 1725, 1774, "Fishman Raider",        3},
        {"DeepForestIsland",    2, 1775, 1824, "Fishman Captain",       3},
        {"DeepForestIsland3",   1, 1825, 1899, "Forest Pirate",         3},
        {"DeepForestIsland3",   2, 1900, 1999, "Mythological Pirate",   3},
        {"HauntedQuest1",       1, 2000, 2049, "Jungle Pirate",         3},
        {"HauntedQuest1",       2, 2050, 2074, "Musketeer Pirate",      3},
        {"HauntedQuest2",       1, 2075, 2124, "Reborn Skeleton",       3},
        {"HauntedQuest2",       2, 2125, 2199, "Living Zombie",         3},
        {"IceCreamIslandQuest", 1, 2200, 2249, "Head Cake Soldier",     3},
        {"IceCreamIslandQuest", 2, 2250, 2274, "Cookie Crafter",        3},
        {"CakeQuest1",          1, 2275, 2299, "Cake Soldier",          3},
        {"CakeQuest1",          2, 2300, 2324, "Cake Guard",            3},
        {"CakeQuest2",          1, 2325, 2349, "Baking Staff",          3},
        {"CakeQuest2",          2, 2350, 2399, "Head Baker",            3},
        {"ChocQuest",           1, 2400, 2424, "Cocoa Warrior",         3},
        {"ChocQuest",           2, 2425, 2449, "Chocolate Bar Battler", 3},
        {"ChocQuest",           3, 2450, 9999, "Sweet Thief",           3},
    }

    -- Player level resolver. Tries Data.Level first (BF's primary store), then
    -- falls back to leaderstats.Level. Returns 0 only if both are missing /
    -- not yet replicated — in which case the scan loop must NOT pick a quest
    -- (otherwise the fallback below would send a fresh test account flying
    -- to ChocQuest at Y=422 in the 3rd Sea: the "random sky location" bug).
    local function BF_PlayerLevel()
        local data = LocalPlayer:FindFirstChild("Data")
        local lvl  = data and data:FindFirstChild("Level")
        if lvl and typeof(lvl.Value) == "number" and lvl.Value > 0 then
            return lvl.Value
        end
        local ls    = LocalPlayer:FindFirstChild("leaderstats")
        local lvl2  = ls and ls:FindFirstChild("Level")
        if lvl2 and typeof(lvl2.Value) == "number" and lvl2.Value > 0 then
            return lvl2.Value
        end
        return 0
    end

    local function BF_QuestForLevel(lv)
        -- Safety: never fall through to the highest-level quest when level
        -- isn't known. That would teleport a low-level player to a 3rd-Sea
        -- island they can't survive on. Default to the first quest instead.
        if not lv or lv <= 0 then return BF_Quests[1] end
        for _, q in ipairs(BF_Quests) do
            if lv >= q[3] and lv <= q[4] then return q end
        end
        return BF_Quests[#BF_Quests]
    end

    local BF_LastQuest = nil
    local function BF_StartQuest(questName, tier)
        local key = questName .. "_" .. tostring(tier)
        if BF_LastQuest == key then return end
        if BF_CommF then
            local ok = pcall(function() BF_CommF:InvokeServer("StartQuest", questName, tier) end)
            if ok then BF_LastQuest = key end
        end
    end

    -- Find nearest enemy in workspace.Enemies within ~600 studs — EXACT name match
    -- (BF mob model names are exactly the friendly name, e.g. "Bandit", "Vampire").
    -- The distance gate is critical: workspace.Enemies streams mobs from many islands,
    -- so without it, the scan loop can pick a far-away mob, clear the destination, and
    -- never trigger the teleport branch — the player just stands there.
    local BF_FIND_RADIUS = 600
    -- Substring + case-insensitive match: BF mob model names sometimes have
    -- numeric suffixes ("Bandit_1", "Vampire2") or capitalization variants.
    -- Exact-match misses these, leaving the farm idle.
    local function BF_FindEnemy(mobName)
        local enemies = workspace:FindFirstChild("Enemies")
        if not enemies then return nil end
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
        local myPos = char.HumanoidRootPart.Position
        local needle = mobName and mobName:lower() or nil
        local nearest, bestDist = nil, BF_FIND_RADIUS
        for _, mob in ipairs(enemies:GetChildren()) do
            local nameMatch = (not needle) or (mob.Name and mob.Name:lower():find(needle, 1, true) ~= nil)
            if mob:IsA("Model") and nameMatch then
                local hum  = mob:FindFirstChildOfClass("Humanoid")
                local root = mob:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    local d = (myPos - root.Position).Magnitude
                    if d < bestDist then bestDist = d; nearest = root end
                end
            end
        end
        return nearest
    end

    -- Find ANY mob with the given name anywhere in workspace.Enemies — no
    -- distance limit. Used to dynamically discover the actual quest island
    -- coordinates when the hardcoded BF_QuestCFrame entry is wrong/stale
    -- (BF moves/renames quest islands across updates). As long as ANY player
    -- on the server is keeping the mob alive, this finds the real location.
    -- Returns the mob's HRP, or nil if no live instance exists in the world.
    local function BF_FindMobAnywhere(mobName)
        local enemies = workspace:FindFirstChild("Enemies")
        if not enemies then return nil end
        local needle = mobName and mobName:lower() or nil
        if not needle then return nil end
        for _, mob in ipairs(enemies:GetChildren()) do
            if mob:IsA("Model") and mob.Name and mob.Name:lower():find(needle, 1, true) then
                local hum  = mob:FindFirstChildOfClass("Humanoid")
                local root = mob:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then return root end
            end
        end
        return nil
    end

    -- Quest island spawn locations (teleport here if no quest mob is loaded near us)
    local BF_QuestCFrame = {
        ["BanditQuest1"]        = CFrame.new(1056,   16, 1547),
        ["JungleQuest"]         = CFrame.new(-1612,  37,  154),
        ["BuggyQuest1"]         = CFrame.new(-1140,   5, 3825),
        ["DesertQuest"]         = CFrame.new( 944,    7, 4373),
        ["SnowQuest"]           = CFrame.new(1356,  105,-1297),
        ["MarineQuest2"]        = CFrame.new(-5035,  29, 4324),
        ["SkyQuest"]            = CFrame.new(-4869, 717,-2667),
        ["PrisonerQuest"]       = CFrame.new(5308,    1,  474),
        ["ColosseumQuest"]      = CFrame.new(-1577,   8,-2984),
        ["MagmaQuest"]          = CFrame.new(-5318,  13, 8517),
        ["FishmanQuest"]        = CFrame.new(61135,  19, 1819),
        ["SkyExp1Quest"]        = CFrame.new(-7913,5544, -380),
        ["SkyExp2Quest"]        = CFrame.new(-7842,5616,-1325),
        ["FountainQuest"]       = CFrame.new(5258,   39, 4050),
        -- 2nd Sea
        ["Area1Quest"]          = CFrame.new(-1450,  30,   -3),
        ["Area2Quest"]          = CFrame.new(-1817,  50, 3613),
        ["MarineQuest3"]        = CFrame.new(-2451,  73,-3219),
        ["ZombieQuest"]         = CFrame.new(-5648,   3, -793),
        ["SnowMountainQuest"]   = CFrame.new(606,   402,-5372),
        ["IceSideQuest"]        = CFrame.new(-6061,  16,-5165),
        ["FireSideQuest"]       = CFrame.new(-5417,  16,-5299),
        ["ZQuest"]              = CFrame.new(-7095, 213,-8167),
        ["GraveyardQuest"]      = CFrame.new(-5972,  22,-1411),
        ["PiratePortQuest"]     = CFrame.new(-290,   43, 5577),
        -- 3rd Sea
        ["AmazonQuest"]         = CFrame.new(5814,   52,-1118),
        ["MarineTreeIsland"]    = CFrame.new(2333,   26,-6738),
        ["DeepForestIsland"]    = CFrame.new(-9510, 143, 5557),
        ["DeepForestIsland3"]   = CFrame.new(-13234,332,-7625),
        ["HauntedQuest1"]       = CFrame.new(-9518, 143, 5567),
        ["HauntedQuest2"]       = CFrame.new(-9518, 143, 5567),
        ["IceCreamIslandQuest"] = CFrame.new(-902,  445,-10963),
        ["CakeQuest1"]          = CFrame.new(-1812,  19,-11862),
        ["CakeQuest2"]          = CFrame.new(-1812,  19,-11862),
        ["ChocQuest"]           = CFrame.new(-12702,332,-7570),
    }

    -- Resolve the travel CFrame for a quest. Prefer the live mob's actual
    -- position (always correct, self-healing against stale/wrong coords).
    -- Fall back to the hardcoded BF_QuestCFrame entry only if no live
    -- instance of the mob exists anywhere on the server.
    local function BF_QuestDestination(questKey, mobName)
        local live = mobName and BF_FindMobAnywhere(mobName)
        if live then
            -- Aim 6 studs in front of and 4 above the mob so we land
            -- on the island floor next to it, not inside it.
            return live.CFrame * CFrame.new(0, 4, -6)
        end
        return BF_QuestCFrame[questKey]
    end

    -- Boss spawn locations
    local BF_BossCFrame = {
        ["Gorilla King"]            = CFrame.new(-1085,  39, -487),
        ["Bobby"]                   = CFrame.new(-1141,   5, 3831),
        ["The Saw"]                 = CFrame.new(-768,   23, 1612),
        ["Yeti"]                    = CFrame.new(1209,  126,-1488),
        ["Mob Leader"]              = CFrame.new(-1149,  43, -570),
        ["Vice Admiral"]            = CFrame.new(-5039,  29, 4324),
        ["Saber Expert"]            = CFrame.new(-1438,  29, -100),
        ["Warden"]                  = CFrame.new(5310,    1,  502),
        ["Chief Warden"]            = CFrame.new(5301,    1,  733),
        ["Swan"]                    = CFrame.new(2287,   16,  864),
        ["Magma Admiral"]           = CFrame.new(-5747,  16,-3477),
        ["Fishman Lord"]            = CFrame.new(61135,  19, 1819),
        ["Wysper"]                  = CFrame.new(-7858,5544,-377),
        ["Thunder God"]             = CFrame.new(-7912,5546,-1789),
        ["Cyborg"]                  = CFrame.new(6265,  295,-6968),
        ["Ice Admiral"]             = CFrame.new(1037,  126,-1340),
        ["Greybeard"]               = CFrame.new(-5078,  88,-3145),
        ["Diamond"]                 = CFrame.new(-2096,  17, -106),
        ["Jeremy"]                  = CFrame.new(2298,   29,  886),
        ["Fajita"]                  = CFrame.new(-1424,   8,-3074),
        ["Don Swan"]                = CFrame.new(2330,  144, 875),
        ["Darkbeard"]               = CFrame.new(3676,  121,-3110),
        ["Order"]                   = CFrame.new(-6217,  29,-5045),
        ["Cursed Captain"]          = CFrame.new(916,   122, 33291),
        ["Smoke Admiral"]           = CFrame.new(-5072, 25,-2913),
        ["Awakened Ice Admiral"]    = CFrame.new(1074, 127, -1185),
        ["Tide Keeper"]             = CFrame.new(-3792, 137, -11369),
        ["Stone"]                   = CFrame.new(-1632, 76, -110),
        ["Island Empress"]          = CFrame.new(5685, 49, -918),
        ["Kilo Admiral"]            = CFrame.new(2547, 26, -6744),
        ["Captain Elephant"]        = CFrame.new(-12127, 332, -7625),
        ["Beautiful Pirate"]        = CFrame.new(-12009, 332, -7393),
        ["Soul Reaper"]             = CFrame.new(-9519, 142, 5567),
        ["Cake Queen"]              = CFrame.new(-2104, 39, -12089),
        ["Dough King"]              = CFrame.new(-2173, 38, -12018),
        ["Rip_indra"]               = CFrame.new(-13059, 332, -7758),
        ["Leviathan"]               = CFrame.new(-13234, 332, -7625),
    }

    -- Smooth-fly state. CRITICAL: BF_Destination MUST be declared as a local here,
    -- BEFORE BF_GoTo is defined. If BF_GoTo is parsed first, Lua resolves the
    -- assignment "BF_Destination = cf" to a global (because no local of that
    -- name is in scope yet), and the movement loop's later local-of-the-same-name
    -- reads nil forever — flight silently never triggers.
    local BF_CurTarget    = nil
    local BF_Destination  = nil   -- island CFrame to PIN the player at every frame
    local function BF_GoTo(cf)
        -- Always overwrite. The movement loop pins the player to BF_Destination
        -- every frame, so leaving it set keeps the player on the island while
        -- mobs stream in. Once a mob loads within range, the scan loop sets
        -- BF_CurTarget and clears BF_Destination, and combat lock takes over.
        BF_Destination = cf
    end

    -- Find a boss anywhere in workspace (bosses spawn outside Enemies sometimes)
    local function BF_FindBoss(bossName)
        local nearest, bestDist = nil, math.huge
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
        local myPos = char.HumanoidRootPart.Position
        local function scan(parent)
            for _, m in pairs(parent:GetChildren()) do
                if m:IsA("Model") and m.Name == bossName then
                    local hum  = m:FindFirstChildOfClass("Humanoid")
                    local root = m:FindFirstChild("HumanoidRootPart")
                    if hum and root and hum.Health > 0 then
                        local d = (myPos - root.Position).Magnitude
                        if d < bestDist then bestDist = d; nearest = root end
                    end
                end
            end
        end
        scan(workspace)
        local enemies = workspace:FindFirstChild("Enemies")
        if enemies then scan(enemies) end
        return nearest
    end

    -- Movement uses a hybrid pattern that's been proven in working BF scripts:
    --   • TRAVEL  : TweenService linear @ 350 studs/s. Long-distance flight.
    --                Server tolerates this as long as no Anchored/PlatformStand.
    --   • COMBAT  : direct CFrame write onto the mob each tick. Close-range
    --                CFrame nudges (< 200 studs) are accepted by BF.
    -- Earlier attempts failed because of PlatformStand (ragdoll, instant flag)
    -- or because BodyVelocity hovered us at the destination → stuck in water.
    local BF_CurTween     = nil   -- the currently-playing TRAVEL Tween
    local BF_TweenTarget  = nil   -- Vector3 the travel tween is heading to
    local BF_NoclipConn   = nil   -- Stepped conn that sets parts CanCollide=false

    -- Debug flag (set _G.BF_Debug = true in console to enable). Throttled to
    -- only fire warnings on CHANGES (target/destination), not every scan tick.
    -- Default ON during current iteration so users can paste F9 output
    -- if the farm misbehaves. Set _G.BF_Debug = false in console to silence.
    if _G.BF_Debug == nil then _G.BF_Debug = true end
    local BF_LastScanLine = ""
    -- Single throttled scan-loop diagnostic. Fires only when the line CHANGES.
    --   mode  : "Farm" / "Mastery" / "Bones" / "Material" / "Boss" / "Idle"
    --   quest : quest key (e.g. "BanditQuest1") or "-"
    --   dest  : "(x, y, z)" of teleport pad or "-"
    --   mob   : mob name being searched ("Bandit") or "-"
    --   found : "yes" / "no"
    local function BF_DbgScan(mode, quest, destPos, mob, found)
        if not _G.BF_Debug then return end
        local destStr = destPos and string.format("(%d,%d,%d)", destPos.X, destPos.Y, destPos.Z) or "-"
        local line = string.format("[Diamond Hub BF] mode=%s quest=%s dest=%s mob=%s found=%s",
            mode or "-", quest or "-", destStr, mob or "-", found and "yes" or "no")
        if line ~= BF_LastScanLine then warn(line); BF_LastScanLine = line end
    end

    -- Anti-cheat workaround: PlatformStand prevents Humanoid from fighting the
    -- tween, and noclip lets us pass through walls/terrain en route to the mob.
    -- Both are toggled OFF when we stop moving.
    local function BF_SetNoclip(on)
        if on and not BF_NoclipConn then
            BF_NoclipConn = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if not char then return end
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
                end
            end)
        elseif (not on) and BF_NoclipConn then
            BF_NoclipConn:Disconnect()
            BF_NoclipConn = nil
            -- Restore collisions on the character so physics behaves normally
            -- when idle. (HumanoidRootPart is naturally CanCollide=false; the
            -- Humanoid manages it, so re-enabling here is harmless.)
            local char = LocalPlayer.Character
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                        pcall(function() p.CanCollide = true end)
                    end
                end
            end
        end
    end
    local function BF_SetPlatformStand(on)
        -- Kept as a no-op for safety — calling Humanoid.PlatformStand=true
        -- ragdolls the avatar and is flagged by BF anti-cheat / automod.
        -- Movement now relies on tween + noclip only.
        local char = LocalPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.PlatformStand = false end) end
    end

    -- Travel speed for cross-island flight. 350 studs/s is the sweet spot
    -- — fast enough to actually move you between islands in a few seconds,
    -- slow enough that BF's server doesn't roll you back.
    local BF_TRAVEL_SPEED = 350

    local function BF_StopTween()
        if BF_CurTween then
            pcall(function() BF_CurTween:Cancel() end)
            BF_CurTween = nil
        end
        BF_TweenTarget = nil
        BF_SetPlatformStand(false)
        BF_SetNoclip(false)
    end

    -- TRAVEL mover. Tween HRP CFrame in a straight line at BF_TRAVEL_SPEED.
    -- Idempotent: re-calling with the same target leaves the running tween alone.
    local function BF_TweenTo(targetPos, speed)
        local char = LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp or not targetPos then return end
        -- Already on the destination island? Skip. Check HORIZONTAL
        -- distance only (X/Z) — once we land, gravity pulls us off
        -- the +15 landing pad onto the real island floor, which can
        -- be 15-100+ studs lower on sky islands (ChocQuest,
        -- IceCreamIslandQuest, SnowMountainQuest, SkyExp*, ZQuest).
        -- A full 3D check would still see us "far" from the pad
        -- after gravity settled and re-fire the tween upward, which
        -- is the "jumps up and down" bug.
        local horiz = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z)
                     - Vector3.new(targetPos.X,    0, targetPos.Z)).Magnitude
        if horiz < 12 then
            if not BF_CurTween or BF_CurTween.PlaybackState ~= Enum.PlaybackState.Playing then
                BF_SetNoclip(false)
            end
            return
        end
        if BF_TweenTarget and (BF_TweenTarget - targetPos).Magnitude < 4
           and BF_CurTween and BF_CurTween.PlaybackState == Enum.PlaybackState.Playing then
            return
        end
        if BF_CurTween then pcall(function() BF_CurTween:Cancel() end); BF_CurTween = nil end
        BF_SetNoclip(true)

        local dist = (hrp.Position - targetPos).Magnitude
        local sp   = speed or BF_TRAVEL_SPEED
        -- Only enforce a MINIMUM time so we never instant-snap. No upper bound.
        local time = math.max(dist / sp, 0.15)
        BF_CurTween    = TweenService:Create(
            hrp,
            TweenInfo.new(time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
            {CFrame = CFrame.new(targetPos)}
        )
        BF_TweenTarget = targetPos
        -- When the travel tween finishes naturally, drop noclip so the
        -- player sits on the ground normally for stationary combat.
        local thisTween = BF_CurTween
        thisTween.Completed:Connect(function(state)
            if state == Enum.PlaybackState.Completed and BF_CurTween == thisTween then
                BF_SetNoclip(false)
            end
        end)
        BF_CurTween:Play()
    end

    -- BRING-MOB pattern. The PROVEN-WORKING auto-farm technique used by
    -- every public BF script in 2025-2026. Instead of moving the player
    -- to the mob (which BF's anti-cheat watches and kicks), we keep the
    -- player stationary on the quest island and write the MOB's CFrame
    -- to a spot 3 studs in front of the player. NPC CFrame writes from
    -- the client are tolerated by BF's server because anti-cheat
    -- watches PLAYER position, not NPC position.
    --
    -- Some bosses have network ownership locks that silently reject the
    -- write — the pcall absorbs that. Worst case the boss isn't pulled,
    -- but the attack loop still fires when the boss walks into range.
    local function BF_BringMob(mobRoot)
        if not mobRoot or not mobRoot.Parent then return end
        local char = LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        pcall(function()
            mobRoot.CFrame = hrp.CFrame * CFrame.new(0, 0, -3)
        end)
    end

    -- Equip weapon by ToolTip (BF tools set ToolTip = "Melee", "Sword", or "Blox Fruit")
    local function BF_EquipWeapon(wType)
        pcall(function()
            local char = LocalPlayer.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            -- Already equipped?
            local equipped = char:FindFirstChildOfClass("Tool")
            if equipped and equipped.ToolTip == wType then return end
            -- Search backpack for matching ToolTip
            for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                if tool:IsA("Tool") and tool.ToolTip == wType then
                    hum:EquipTool(tool)
                    return
                end
            end
            -- Fallback: name pattern (older/legacy weapons may lack ToolTip)
            for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    local n = tool.Name:lower()
                    local match = (wType == "Sword" and (n:find("sword",1,true) or n:find("blade",1,true) or n:find("katana",1,true) or n:find("saber",1,true)))
                               or (wType == "Blox Fruit" and (n:find("fruit",1,true) or n:find("devil",1,true)))
                               or  wType == "Melee"
                    if match then hum:EquipTool(tool); return end
                end
            end
        end)
    end

    -- Attack: fire touch interest from held tool's Handle into the target HRP, then activate
    -- (BF_CurTarget and BF_Destination are declared earlier — see "Smooth-fly state")
    local function BF_Attack(root)
        pcall(function()
            local char = LocalPlayer.Character
            if not char or not root or not root.Parent then return end
            local tool = char:FindFirstChildOfClass("Tool")
            if not tool then return end
            local handle = tool:FindFirstChild("Handle")
            if handle and firetouchinterest then
                firetouchinterest(handle, root, 0)
                firetouchinterest(handle, root, 1)
            end
            tool:Activate()
        end)
    end

    -- Material → mob lookup (mobs that drop the material when killed)
    local BF_MatMap = {
        ["Dragon Scales"]   = "Dragon Crew Warrior",
        ["Scrap Metal"]     = "Factory Staff",
        ["Magma Ore"]       = "Military Soldier",
        ["Vampire Fangs"]   = "Vampire",
        ["Leather"]         = "Brute",
        ["Angel Wings"]     = "Royal Squad",
        ["Dark Fragment"]   = "Dark Master",
        ["Leviathan Heart"] = "Water Fighter",
    }

    -- Bones drop from undead enemies (Third Sea Haunted Castle)
    local BF_BoneMobs = {"Reborn Skeleton","Living Zombie","Demonic Soul","Possessed Mummy"}

    -- Tracks the currently-active farm mode so sticky targeting clears
    -- when the user switches modes (see scan loop below).
    local BF_LastMode = nil

    -- Sticky-target helper. Returns true if BF_CurTarget is still a valid,
    -- alive mob. Sticky targeting prevents the scan loop from flipping
    -- between mobs every 0.5s — each flip used to cancel + restart the
    -- combat tween with a new destination, which looked like teleport
    -- spam to BF's anti-cheat and got the player kicked.
    local function BF_TargetAlive()
        local root = BF_CurTarget
        if not root or not root.Parent then return false end
        local mob = root.Parent
        local hum = mob:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return false end
        return true
    end

    -- Throttled target scan (every 0.5s)
    local BF_ScanTimer = 0
    table.insert(getgenv().DiamondHub_Connections, RunService.Heartbeat:Connect(function(dt)
        if not getgenv().DiamondHub_Active then return end
        if not BFFrame.Visible then return end
        local farmOn = _G.BF_Config.AutoFarm or _G.BF_Config.AutoBones or
                       _G.BF_Config.AutoMaterial or _G.BF_Config.AutoBoss or _G.BF_Config.AutoMastery
        if not farmOn then
            BF_CurTarget = nil; BF_Destination = nil; BF_LastQuest = nil
            BF_StopTween()
            BF_DbgScan("Idle", nil, nil, nil, false)
            return
        end
        BF_ScanTimer = BF_ScanTimer + dt
        if BF_ScanTimer < 0.5 then return end
        BF_ScanTimer = 0

        -- Detect mode switch (e.g. user toggled off AutoFarm and turned on
        -- AutoBoss). Sticky targeting must NOT carry an old mob across
        -- modes — otherwise the new mode keeps chasing the old target
        -- until it dies, which feels broken to the user.
        local mode = (_G.BF_Config.AutoFarm and "Farm")
                  or (_G.BF_Config.AutoMastery and "Mastery")
                  or (_G.BF_Config.AutoBones   and "Bones")
                  or (_G.BF_Config.AutoMaterial and "Material")
                  or (_G.BF_Config.AutoBoss    and "Boss")
        if mode ~= BF_LastMode then
            BF_CurTarget = nil
            BF_LastMode  = mode
        end

        -- Sticky targeting: keep the current target until it's dead.
        -- Only when the existing target is gone do we acquire a new one.
        local sticky = BF_TargetAlive()

        -- Auto Farm Level: pick quest by player level, start quest, hunt that mob
        -- (teleports to quest island if mob not loaded near us)
        if _G.BF_Config.AutoFarm then
            BF_EquipWeapon(_G.BF_Config.AutoFarmWeapon)
            local q = BF_QuestForLevel(BF_PlayerLevel())
            if q then
                BF_StartQuest(q[1], q[2])
                local t = sticky and BF_CurTarget or BF_FindEnemy(q[5])
                if t then BF_Destination = nil else BF_GoTo(BF_QuestDestination(q[1], q[5])) end
                BF_CurTarget = t
                BF_DbgScan("Level", q[1], BF_Destination and BF_Destination.Position or nil, q[5], t ~= nil)
            else
                BF_DbgScan("Level", nil, nil, nil, false)
            end
            return
        end

        -- Auto Farm Mastery: hunt any nearby enemy with selected mastery weapon
        if _G.BF_Config.AutoMastery then
            BF_EquipWeapon(_G.BF_Config.MasteryType)
            BF_CurTarget = sticky and BF_CurTarget or BF_FindEnemy(nil)
            BF_DbgScan("Mastery", nil, nil, "<any>", BF_CurTarget ~= nil)
            return
        end

        -- Auto Farm Bones (undead at Haunted Castle, 3rd Sea)
        if _G.BF_Config.AutoBones then
            BF_EquipWeapon(_G.BF_Config.AutoFarmWeapon)
            local t, mobFound = nil, nil
            if sticky then
                t = BF_CurTarget
            else
                for _, name in ipairs(BF_BoneMobs) do
                    t = BF_FindEnemy(name); if t then mobFound = name; break end
                end
            end
            if t then BF_Destination = nil else BF_GoTo(BF_QuestDestination("HauntedQuest2", mobFound or BF_BoneMobs[1])) end
            BF_CurTarget = t
            BF_DbgScan("Bones", "HauntedQuest2", BF_Destination and BF_Destination.Position or nil, mobFound or BF_BoneMobs[1], t ~= nil)
            return
        end

        -- Auto Farm Material: hunt the mob mapped to selected material
        if _G.BF_Config.AutoMaterial then
            BF_EquipWeapon(_G.BF_Config.AutoFarmWeapon)
            local key = _G.BF_Config.SelectedMaterial:match("^([^%(]+)")
            if key then key = key:gsub("%s+$","") end
            local mob = key and BF_MatMap[key]
            local t   = sticky and BF_CurTarget or (mob and BF_FindEnemy(mob)) or nil
            local questKey = nil
            if t then
                BF_Destination = nil
            elseif mob then
                for _, q in ipairs(BF_Quests) do
                    if q[5] == mob and BF_QuestCFrame[q[1]] then
                        BF_GoTo(BF_QuestDestination(q[1], mob)); questKey = q[1]; break
                    end
                end
            end
            BF_CurTarget = t
            BF_DbgScan("Material", questKey, BF_Destination and BF_Destination.Position or nil, mob, t ~= nil)
            return
        end

        -- Auto Farm Boss: teleport to boss spawn if boss not loaded
        if _G.BF_Config.AutoBoss then
            BF_EquipWeapon(_G.BF_Config.AutoFarmWeapon)
            local raw  = _G.BF_Config.SelectedBoss
            local name = raw:match("^([^%(/]+)"); if name then name = name:gsub("%s+$","") end
            local t = sticky and BF_CurTarget or (name and BF_FindBoss(name)) or nil
            if t then
                BF_Destination = nil
            elseif name and BF_BossCFrame[name] then
                BF_GoTo(BF_BossCFrame[name])
            end
            BF_CurTarget = t
            BF_DbgScan("Boss", name, BF_Destination and BF_Destination.Position or nil, name, t ~= nil)
            return
        end
    end))

    -- Movement controller. The player ONLY moves to travel between
    -- islands. Combat NEVER moves the player — that's the bring-mob
    -- helper's job. Throttled to 0.25s.
    --   1. Have a combat target → DO NOT move and do NOT cancel any
    --      in-flight travel tween — let it finish naturally so its
    --      Completed handler drops noclip. The 0.1s attack loop pulls
    --      the mob in once we're standing still.
    --   2. No target but a travel destination → tween to landing pad.
    --   3. Idle → stop any tween.
    local BF_MoveTimer = 0
    table.insert(getgenv().DiamondHub_Connections, RunService.Heartbeat:Connect(function(dt)
        if not getgenv().DiamondHub_Active then return end
        if not BFFrame.Visible then return end
        BF_MoveTimer = BF_MoveTimer + dt
        if BF_MoveTimer < 0.25 then return end
        BF_MoveTimer = 0

        local char = LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- Priority 1: combat target locked → do nothing. Let the
        -- in-flight travel tween (if any) complete naturally; once it
        -- ends the player sits stationary and the 0.1s attack loop
        -- pulls the mob in. We must NOT cancel the tween here — the
        -- travel tween's Completed handler is what disables noclip.
        if BF_CurTarget and BF_CurTarget.Parent then
            return
        end

        -- Priority 2: island destination → tween to landing pad at full
        -- travel speed (350 stud/s). Land 15 studs above the pad so we
        -- don't end up underwater when the pad is at sea level.
        if BF_Destination then
            local landPos = BF_Destination.Position + Vector3.new(0, 15, 0)
            BF_TweenTo(landPos, BF_TRAVEL_SPEED)
            return
        end

        -- Idle → kill any leftover tween (also resets PlatformStand + noclip)
        BF_StopTween()
    end))

    --// ─── AUTO BUY ENGINE ─────────────────────────────────────────
    -- Each entry maps a config key → list of {remoteName, args...} call tuples.
    -- The buy loop fires every ~3s; each call is wrapped in pcall so a failure
    -- on one item (e.g. unmet prerequisites) doesn't break the loop. The server
    -- silently no-ops when reqs aren't met, so the toggle effectively waits
    -- until the player has the requirements then auto-completes the purchase.
    -- One canonical remote call per item. Server no-ops on unmet prereqs,
    -- so toggles auto-complete the moment requirements are met.
    local BF_BuyMap = {
        -- ── Swords ──────────────────────────────────────────────
        AutoBuy_TrueTripleKatana = { {"BuyTrueTripleKatana"} },
        AutoBuy_CursedDualKatana = { {"BuyCursedDualKatana"} },
        AutoBuy_Tushita          = { {"Tushita"} },
        AutoBuy_Yama             = { {"Yama"} },
        AutoBuy_Saber            = { {"Buy Sword", "Saber",      850000} },
        AutoBuy_SoulCane         = { {"Buy Sword", "Soul Cane",  1850000} },
        AutoBuy_BuddySword       = { {"Buy Sword", "Buddy Sword", 5000000} },

        -- ── Fighting Styles ────────────────────────────────────
        AutoBuy_BlackLeg       = { {"BlackLeg"} },
        AutoBuy_Electric       = { {"Electro"} },
        AutoBuy_DragonClaw     = { {"DragonClaw"} },
        AutoBuy_DarkStep       = { {"DarkStep"} },
        AutoBuy_DeathStep      = { {"DeathStep"} },
        AutoBuy_Superhuman     = { {"Superhuman"} },
        AutoBuy_SharkmanKarate = { {"SharkmanKarate"} },
        AutoBuy_ElectricClaw   = { {"ElectricClaw"} },
        AutoBuy_DragonTalon    = { {"DragonTalon"} },
        AutoBuy_Godhuman       = { {"Godhuman"} },
    }

    local BF_BuyTimer = 0
    table.insert(getgenv().DiamondHub_Connections, RunService.Heartbeat:Connect(function(dt)
        if not getgenv().DiamondHub_Active then return end
        if not BFFrame.Visible then return end
        BF_BuyTimer = BF_BuyTimer + dt
        if BF_BuyTimer < 3 then return end
        BF_BuyTimer = 0
        if not BF_CommF then return end
        for cfgKey, calls in pairs(BF_BuyMap) do
            if _G.BF_Config[cfgKey] then
                for _, args in ipairs(calls) do
                    pcall(function() BF_CommF:InvokeServer(unpack(args)) end)
                end
            end
        end
    end))

    -- Attack loop (throttled to 0.1s). Each tick: pull the mob to a spot
    -- 3 studs in front of us (NPC CFrame writes are accepted by BF's
    -- server), then fire the touch interest + activate the held tool.
    -- The player never moves — combat ping-pong / kicks are gone.
    local attackTimer = 0
    table.insert(getgenv().DiamondHub_Connections, RunService.Heartbeat:Connect(function(dt)
        if not getgenv().DiamondHub_Active then return end
        if not BFFrame.Visible then return end
        attackTimer = attackTimer + dt
        if attackTimer < 0.1 then return end
        attackTimer = 0
        if BF_CurTarget and BF_CurTarget.Parent then
            BF_BringMob(BF_CurTarget)
            BF_Attack(BF_CurTarget)
        end
    end))

    -- Auto stats (throttled 0.5s)
    local statsTimer = 0
    table.insert(getgenv().DiamondHub_Connections, RunService.Heartbeat:Connect(function(dt)
        if not getgenv().DiamondHub_Active then return end
        if not BFFrame.Visible then return end
        statsTimer = statsTimer + dt
        if statsTimer < 0.5 then return end
        statsTimer = 0
        local statMap = {
            AutoStats_Melee="Melee", AutoStats_Defense="Defense",
            AutoStats_Sword="Sword", AutoStats_Gun="Gun", AutoStats_Fruit="Blox Fruit",
        }
        for k, v in pairs(statMap) do
            if _G.BF_Config[k] then
                pcall(function()
                    local RS  = game:GetService("ReplicatedStorage")
                    local rem = RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("CommF_")
                    if rem then rem:InvokeServer("addStat", v) end
                end)
            end
        end
    end))

    -- ESP
    table.insert(getgenv().DiamondHub_Connections, RunService.Heartbeat:Connect(function()
        if not getgenv().DiamondHub_Active then return end
        if not BFFrame.Visible then return end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                pcall(function()
                    local h = p.Character:FindFirstChild("BF_ESP")
                            or Instance.new("Highlight", p.Character)
                    h.Name = "BF_ESP"; h.Enabled = _G.BF_Config.ESP
                    h.FillColor = Color3.fromRGB(255,200,0)
                    h.OutlineColor = Color3.fromRGB(255,255,0)
                end)
            end
        end
    end))

    -- Fruit notifier (throttled 2s)
    local fruitTimer = 0
    table.insert(getgenv().DiamondHub_Connections, RunService.Heartbeat:Connect(function(dt)
        if not getgenv().DiamondHub_Active then return end
        if not BFFrame.Visible or not _G.BF_Config.FruitNotifier then return end
        fruitTimer = fruitTimer + dt
        if fruitTimer < 2 then return end
        fruitTimer = 0
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                local n = obj.Name:lower()
                if (n:find("fruit",1,true) or n:find("devil fruit",1,true))
                and obj:FindFirstChildOfClass("ClickDetector") then
                    local part = obj:IsA("BasePart") and obj
                             or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")))
                    if part then
                        warn("[Diamond Hub] Fruit spotted: " .. obj.Name)
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            char.HumanoidRootPart.CFrame = CFrame.new(part.Position + Vector3.new(0,4,0))
                        end
                        break
                    end
                end
            end
        end)
    end))

    --// ============================================================
    --//  NAVIGATION
    --// ============================================================

    local function ShowBloxFruits()
        HubFrame.Visible = false
        GameLoadFrame.Visible = true
        GameLoadTitle.Text = "Loading Blox Fruits"
        GameLoadSub.Text   = "Initializing scripts..."
        GameLoadBar_Fill.Size = UDim2.new(0,0,1,0)
        Tween(GameLoadBar_Fill, 1.4, {Size = UDim2.new(1,0,1,0)}, Enum.EasingStyle.Quart)
        task.wait(1.6)
        if not getgenv().DiamondHub_Active then return end
        GameLoadFrame.Visible = false
        BFMinimized = false
        BFFrame.Size  = UDim2.new(0,624,0,374)
        BFBody.Visible = true
        BFFrame.Visible = true
        BFFrame.BackgroundTransparency = 1
        Tween(BFFrame, 0.32, {BackgroundTransparency = 0}, Enum.EasingStyle.Quad)
    end

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
        BFFrame.Visible     = false
        HubFrame.Visible    = true
        HubFrame.BackgroundTransparency = 1
        Tween(HubFrame, 0.28, {BackgroundTransparency = 0}, Enum.EasingStyle.Quad)
    end

    BackBtn.MouseButton1Click:Connect(ShowHub)
    BFBackBtn.MouseButton1Click:Connect(ShowHub)

    AddGameCard("Rivals",      "Combat sports — PvP scripts",       "PVP", ShowRivals)
    AddGameCard("Blox Fruits", "Open-world adventure — Autofarm",   "RPG", ShowBloxFruits)

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
