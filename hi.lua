
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
    local BF_VisualsTab = CreateBFTab("BF_Visuals", "Visuals", 4, false)

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

    --// ─── MASTERY TAB ──────────────────────────────────────────────

    BF_SecLabel(BF_MasteryTab, "AUTO FARM MASTERY")
    BFToggle(BF_MasteryTab, "Auto Farm Mastery", "Farms mastery using selected weapon", "AutoMastery")
    BFDropdown(BF_MasteryTab, "Mastery Weapon", {"Melee", "Fruit", "Sword"}, "MasteryType")

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

    local function BF_FindTarget(nameList)
        local nearest, bestDist = nil, math.huge
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
        local myPos = char.HumanoidRootPart.Position
        -- Build a set of all player character models so they are never targeted
        local playerChars = {}
        for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
            if plr.Character then playerChars[plr.Character] = true end
        end
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= char and not playerChars[obj] then
                local hum  = obj:FindFirstChildOfClass("Humanoid")
                local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                if hum and root and hum.Health > 0 then
                    local pass = (nameList == nil)
                    if not pass then
                        local low = obj.Name:lower()
                        for _, n in ipairs(nameList) do
                            if low:find(n:lower(), 1, true) then pass = true; break end
                        end
                    end
                    if pass then
                        local d = (myPos - root.Position).Magnitude
                        if d < bestDist then bestDist = d; nearest = root end
                    end
                end
            end
        end
        return nearest
    end

    local function BF_TeleportTo(root)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") and root and root.Parent then
            char.HumanoidRootPart.CFrame = root.CFrame * CFrame.new(0,0,-4)
        end
    end

    local function BF_EquipWeapon(wType)
        pcall(function()
            local char = LocalPlayer.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    local n = tool.Name:lower()
                    local match = (wType == "Sword" and (n:find("sword",1,true) or n:find("blade",1,true) or n:find("katana",1,true) or n:find("saber",1,true)))
                               or ((wType == "Fruit" or wType == "Blox Fruit") and (n:find("fruit",1,true) or n:find("devil",1,true)))
                               or  wType == "Melee"
                    if match then hum:EquipTool(tool); return end
                end
            end
        end)
    end

    -- Shared current target + attack helper
    local BF_CurTarget = nil

    local function BF_Attack(root)
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            for _, item in pairs(char:GetChildren()) do
                if item:IsA("Tool") then
                    pcall(function() item:Activate() end)
                    local handle = item:FindFirstChild("Handle")
                    if handle and root and root.Parent then
                        if firetouchinterest then
                            firetouchinterest(handle, root.Parent, 0)
                            firetouchinterest(handle, root.Parent, 1)
                        end
                    end
                    break
                end
            end
            if root and root.Parent then
                local cd = root.Parent:FindFirstChildOfClass("ClickDetector")
                        or root:FindFirstChildOfClass("ClickDetector")
                if cd and fireclickdetector then
                    pcall(function() fireclickdetector(cd) end)
                end
            end
        end)
    end

    -- NPC name → boss/material lookup tables
    local BF_MatMap = {
        ["Dragon Scales"]   = {"Dragon Crew"},
        ["Scrap Metal"]     = {"Pirate","Bandit"},
        ["Magma Ore"]       = {"Military Soldier","Military Spy","Magma Ninja"},
        ["Vampire Fangs"]   = {"Vampire"},
        ["Leather"]         = {"Pirate","Monkey","Bandit"},
        ["Angel Wings"]     = {"Sky Bandit","Sky Pirate","Blimp Pirate"},
        ["Dark Fragment"]   = {"Darkbeard"},
        ["Leviathan Heart"] = {"Leviathan"},
    }

    -- Throttled target scan (every 0.5s) — avoids per-frame workspace:GetDescendants()
    local BF_ScanTimer = 0
    table.insert(getgenv().DiamondHub_Connections, RunService.Heartbeat:Connect(function(dt)
        if not getgenv().DiamondHub_Active then return end
        if not BFFrame.Visible then return end
        local farmOn = _G.BF_Config.AutoFarm or _G.BF_Config.AutoBones or
                       _G.BF_Config.AutoMaterial or _G.BF_Config.AutoBoss or _G.BF_Config.AutoMastery
        if not farmOn then BF_CurTarget = nil; return end
        BF_ScanTimer = BF_ScanTimer + dt
        if BF_ScanTimer < 0.5 then return end
        BF_ScanTimer = 0
        -- Equip weapon for active farm mode
        if _G.BF_Config.AutoFarm then
            BF_EquipWeapon(_G.BF_Config.AutoFarmWeapon)
        elseif _G.BF_Config.AutoMastery then
            BF_EquipWeapon(_G.BF_Config.MasteryType)
        end
        -- Find a target matching the active farm mode
        local t = nil
        if _G.BF_Config.AutoFarm or _G.BF_Config.AutoMastery then
            t = BF_FindTarget(nil)
        elseif _G.BF_Config.AutoBones then
            t = BF_FindTarget({"Living Zombie","Demonic Soul","Possessed Mummy","Vampire"})
        elseif _G.BF_Config.AutoMaterial then
            local matKey = _G.BF_Config.SelectedMaterial:match("^([^%(]+)")
            if matKey then matKey = matKey:gsub("%s+$","") end
            t = BF_FindTarget(matKey and BF_MatMap[matKey])
        elseif _G.BF_Config.AutoBoss then
            local raw  = _G.BF_Config.SelectedBoss
            local name = raw:match("^([^%(/]+)"); if name then name = name:gsub("%s+$","") end
            if name then t = BF_FindTarget({name}) end
        end
        BF_CurTarget = t
    end))

    -- Teleport loop — every frame, no scan, just move character to cached target
    table.insert(getgenv().DiamondHub_Connections, RunService.Heartbeat:Connect(function()
        if not getgenv().DiamondHub_Active then return end
        if not BFFrame.Visible then return end
        if BF_CurTarget and BF_CurTarget.Parent then
            BF_TeleportTo(BF_CurTarget)
        end
    end))

    -- Attack loop — throttled to 0.15s
    local attackTimer = 0
    table.insert(getgenv().DiamondHub_Connections, RunService.Heartbeat:Connect(function(dt)
        if not getgenv().DiamondHub_Active then return end
        if not BFFrame.Visible then return end
        attackTimer = attackTimer + dt
        if attackTimer < 0.15 then return end
        attackTimer = 0
        if BF_CurTarget and BF_CurTarget.Parent then
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
