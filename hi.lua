w(0,7,0,54)
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
    AddGameCard("Rivals", "Combat sports — PvP scripts", "PVP", function()
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
