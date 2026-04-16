--// PROTECTIVE WRAPPER (Prevents executor crashes)
local success, err = pcall(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    local Mouse = LocalPlayer:GetMouse()

    --// SETTINGS
    _G.DH_Config = {
        Aimbot = false,
        RageHitbox = false,
        HitboxSize = 15,
        FOV = 250,
        ESP = false,
        -- Movement
        Speed = false,
        WalkSpeedValue = 60,
        Fly = false,
        FlySpeed = 50,
        Noclip = false,
        Accent = Color3.fromRGB(0, 170, 255)
    }

    --// ROBUST GUI PARENTING
    local function GetGuiParent()
        local coreGui = game:GetService("CoreGui")
        if gethui then return gethui() end
        if coreGui:FindFirstChild("RobloxGui") then return coreGui.RobloxGui end
        return LocalPlayer:WaitForChild("PlayerGui")
    end

    --// CLEANUP
    if getgenv().DiamondHub_Loaded then
        local old = GetGuiParent():FindFirstChild("DiamondHub_V10")
        if old then old:Destroy() end
    end
    getgenv().DiamondHub_Loaded = true

    --// MAIN UI
    local ScreenGui = Instance.new("ScreenGui", GetGuiParent())
    ScreenGui.Name = "DiamondHub_V10"
    ScreenGui.ResetOnSpawn = false

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 560, 0, 390)
    Main.Position = UDim2.new(0.5, -280, 0.5, -195)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

    local AccentStroke = Instance.new("UIStroke", Main)
    AccentStroke.Color = _G.DH_Config.Accent
    AccentStroke.Thickness = 1.8
    AccentStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    --// CLOSE CONFIRMATION SYSTEM
    local ConfirmOverlay = Instance.new("Frame", Main)
    ConfirmOverlay.Size = UDim2.new(1, 0, 1, 0)
    ConfirmOverlay.BackgroundColor3 = Color3.new(0,0,0)
    ConfirmOverlay.BackgroundTransparency = 1
    ConfirmOverlay.Visible = false
    ConfirmOverlay.ZIndex = 500

    local ConfirmBox = Instance.new("Frame", ConfirmOverlay)
    ConfirmBox.Size = UDim2.new(0, 260, 0, 120)
    ConfirmBox.Position = UDim2.new(0.5, -130, 0.5, -60)
    ConfirmBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UICorner", ConfirmBox).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", ConfirmBox).Color = Color3.fromRGB(50, 50, 50)

    local ConfirmText = Instance.new("TextLabel", ConfirmBox)
    ConfirmText.Size = UDim2.new(1, 0, 0.5, 0)
    ConfirmText.Text = "Exit DiamondHub?"
    ConfirmText.TextColor3 = Color3.new(1,1,1)
    ConfirmText.Font = Enum.Font.GothamBold
    ConfirmText.BackgroundTransparency = 1

    local YesBtn = Instance.new("TextButton", ConfirmBox)
    YesBtn.Size = UDim2.new(0, 100, 0, 30)
    YesBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
    YesBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    YesBtn.Text = "Yes"
    YesBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", YesBtn).CornerRadius = UDim.new(0, 5)

    local NoBtn = Instance.new("TextButton", ConfirmBox)
    NoBtn.Size = UDim2.new(0, 100, 0, 30)
    NoBtn.Position = UDim2.new(0.55, 0, 0.6, 0)
    NoBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    NoBtn.Text = "No"
    NoBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", NoBtn).CornerRadius = UDim.new(0, 5)

    --// HEADER
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundColor3 = Color3.fromRGB(15, 15, 15)

    local Title = Instance.new("TextLabel", Header)
    Title.Text = "💎 DIAMOND<font color='#00AAFF'>HUB</font> V10"
    Title.RichText = true
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = "Left"

    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Size = UDim2.new(0, 32, 0, 32)
    CloseBtn.Position = UDim2.new(1, -40, 0, 6)
    CloseBtn.Text = "✕"
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

    local MinBtn = Instance.new("TextButton", Header)
    MinBtn.Size = UDim2.new(0, 32, 0, 32)
    MinBtn.Position = UDim2.new(1, -78, 0, 6)
    MinBtn.Text = "—"
    MinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MinBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

    --// SIDEBAR
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 140, 1, -55)
    Sidebar.Position = UDim2.new(0, 10, 0, 50)
    Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

    local SidebarList = Instance.new("UIListLayout", Sidebar)
    SidebarList.Padding = UDim.new(0, 6)
    SidebarList.HorizontalAlignment = "Center"
    Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 10)

    --// PAGES
    local Pages = Instance.new("Frame", Main)
    Pages.Size = UDim2.new(1, -170, 1, -60)
    Pages.Position = UDim2.new(0, 160, 0, 50)
    Pages.BackgroundTransparency = 1

    local Tabs = {}
    local function CreateTab(name, icon, active)
        local TabFrame = Instance.new("ScrollingFrame", Pages)
        TabFrame.Size = UDim2.new(1, 0, 1, 0)
        TabFrame.BackgroundTransparency = 1
        TabFrame.Visible = active
        TabFrame.ScrollBarThickness = 2
        TabFrame.CanvasSize = UDim2.new(0, 0, 1.5, 0)
        Instance.new("UIListLayout", TabFrame).Padding = UDim.new(0, 10)

        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(0.9, 0, 0, 40)
        TabBtn.BackgroundColor3 = active and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(20, 20, 20)
        TabBtn.Text = icon .. "  " .. name
        TabBtn.TextColor3 = active and Color3.new(1,1,1) or Color3.fromRGB(180, 180, 180)
        TabBtn.Font = Enum.Font.GothamSemibold
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Tabs) do 
                v.Frame.Visible = false 
                v.Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20) 
                v.Btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            end
            TabFrame.Visible = true
            TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            TabBtn.TextColor3 = _G.DH_Config.Accent
        end)
        Tabs[name] = {Frame = TabFrame, Btn = TabBtn}
        return TabFrame
    end

    local CombatTab = CreateTab("Combat", "🎯", true)
    local VisualsTab = CreateTab("Visuals", "👁️", false)
    local MovementTab = CreateTab("Movement", "🏃", false)
    local ProfileTab = CreateTab("Profile", "👤", false)

    --// TOGGLE SYSTEM
    local function AddToggle(name, parent, configKey)
        local T = Instance.new("TextButton", parent)
        T.Size = UDim2.new(1, -10, 0, 45)
        T.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        T.Text = "     " .. name
        T.TextColor3 = Color3.fromRGB(230, 230, 230)
        T.Font = Enum.Font.Gotham
        T.TextXAlignment = "Left"
        Instance.new("UICorner", T).CornerRadius = UDim.new(0, 8)

        local Box = Instance.new("Frame", T)
        Box.Size = UDim2.new(0, 40, 0, 20)
        Box.Position = UDim2.new(1, -50, 0.5, -10)
        Box.BackgroundColor3 = _G.DH_Config[configKey] and _G.DH_Config.Accent or Color3.fromRGB(50, 50, 50)
        Instance.new("UICorner", Box).CornerRadius = UDim.new(1, 0)

        T.MouseButton1Click:Connect(function()
            _G.DH_Config[configKey] = not _G.DH_Config[configKey]
            TweenService:Create(Box, TweenInfo.new(0.3), {BackgroundColor3 = _G.DH_Config[configKey] and _G.DH_Config.Accent or Color3.fromRGB(50, 50, 50)}):Play()
        end)
    end

    AddToggle("Aimbot (Hold Right-Click)", CombatTab, "Aimbot")
    AddToggle("Hitbox Expander", CombatTab, "RageHitbox")
    AddToggle("ESP Masters", VisualsTab, "ESP")
    AddToggle("Fly Mode (WASD)", MovementTab, "Fly")
    AddToggle("Speed Hack", MovementTab, "Speed")
    AddToggle("Noclip (Phase)", MovementTab, "Noclip")

    --// PROFILE UI
    local PName = Instance.new("TextLabel", ProfileTab)
    PName.Size = UDim2.new(1, 0, 0, 40)
    PName.Text = "Player: " .. LocalPlayer.DisplayName
    PName.TextColor3 = Color3.new(1,1,1)
    PName.Font = Enum.Font.GothamBold
    PName.BackgroundTransparency = 1

    --// LOGIC HANDLERS
    CloseBtn.MouseButton1Click:Connect(function() 
        ConfirmOverlay.Visible = true 
        TweenService:Create(ConfirmOverlay, TweenInfo.new(0.3), {BackgroundTransparency = 0.4}):Play()
    end)
    NoBtn.MouseButton1Click:Connect(function() ConfirmOverlay.Visible = false end)
    YesBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy(); getgenv().DiamondHub_Loaded = false end)

    local Mini = false
    MinBtn.MouseButton1Click:Connect(function()
        Mini = not Mini
        TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = Mini and UDim2.new(0, 560, 0, 45) or UDim2.new(0, 560, 0, 390)}):Play()
    end)

    -- Draggable
    local d, ds, sp
    Header.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true; ds = i.Position; sp = Main.Position end end)
    UserInputService.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - ds; Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
    end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)

    --// THE ENGINES
    local function GetNearest()
        local nearest = nil; local dist = _G.DH_Config.FOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if mag < dist then dist = mag; nearest = p.Character.Head end
                end
            end
        end
        return nearest
    end

    RunService.RenderStepped:Connect(function()
        if not getgenv().DiamondHub_Loaded then return end

        -- Hard Lock Aimbot
        if _G.DH_Config.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target = GetNearest()
            if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position) end
        end

        -- Movement Engine
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character.HumanoidRootPart
            local hum = LocalPlayer.Character.Humanoid

            hum.WalkSpeed = _G.DH_Config.Speed and _G.DH_Config.WalkSpeedValue or 16

            if _G.DH_Config.Fly then
                root.Velocity = Vector3.new(0, 0.5, 0)
                local moveDir = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + (Camera.CFrame.LookVector) end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - (Camera.CFrame.LookVector) end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - (Camera.CFrame.RightVector) end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + (Camera.CFrame.RightVector) end
                root.CFrame = root.CFrame + (moveDir * (_G.DH_Config.FlySpeed/20))
            end
        end

        -- Visuals/Hitbox
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local head = p.Character:FindFirstChild("Head")
                if head then
                    head.Size = _G.DH_Config.RageHitbox and Vector3.new(_G.DH_Config.HitboxSize, _G.DH_Config.HitboxSize, _G.DH_Config.HitboxSize) or Vector3.new(1.2, 1.2, 1.2)
                    head.Transparency = _G.DH_Config.RageHitbox and 0.8 or 0
                    head.CanCollide = not _G.DH_Config.RageHitbox
                    
                    local h = p.Character:FindFirstChild("DH_Highlight") or Instance.new("Highlight", p.Character)
                    h.Name = "DH_Highlight"; h.Enabled = _G.DH_Config.ESP; h.FillColor = _G.DH_Config.Accent
                end
            end
        end
    end)

    -- Noclip Physics
    RunService.Stepped:Connect(function()
        if _G.DH_Config.Noclip and LocalPlayer.Character then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)

end)

if not success then warn("DiamondHub Execute Error: " .. err) end
