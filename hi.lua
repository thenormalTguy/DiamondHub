--// PROTECTIVE WRAPPER
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
        Speed = false,
        WalkSpeedValue = 60,
        Fly = false,
        FlySpeed = 50,
        Noclip = false,
        Accent = Color3.fromRGB(0, 170, 255)
    }

    --// GUI PARENTING
    local function GetGui()
        if gethui then return gethui() end
        if game:GetService("CoreGui"):FindFirstChild("RobloxGui") then return game:GetService("CoreGui").RobloxGui end
        return LocalPlayer:WaitForChild("PlayerGui")
    end

    if getgenv().DiamondHub_Loaded then
        local old = GetGui():FindFirstChild("DiamondHub_V10")
        if old then old:Destroy() end
    end
    getgenv().DiamondHub_Loaded = true

    --// MAIN UI DESIGN
    local ScreenGui = Instance.new("ScreenGui", GetGui())
    ScreenGui.Name = "DiamondHub_V10"
    ScreenGui.ResetOnSpawn = false

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 620, 0, 420)
    Main.Position = UDim2.new(0.5, -310, 0.5, -210)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true -- Fixes the clipping bug
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = _G.DH_Config.Accent
    MainStroke.Thickness = 1.5
    MainStroke.Transparency = 0.2

    --// HEADER (Fixed Size)
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    Header.BorderSizePixel = 0
    
    local HeaderCorner = Instance.new("UICorner", Header)
    HeaderCorner.CornerRadius = UDim.new(0, 12)
    
    -- Fix bottom corners of header so it sits flat
    local HeaderFix = Instance.new("Frame", Header)
    HeaderFix.Size = UDim2.new(1, 0, 0, 10)
    HeaderFix.Position = UDim2.new(0, 0, 1, -10)
    HeaderFix.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    HeaderFix.BorderSizePixel = 0

    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(0, 300, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Text = "💎 DIAMOND<font color='#00AAFF'>HUB</font>"
    Title.RichText = true
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 22 -- Bigger Text
    Title.TextXAlignment = "Left"
    Title.BackgroundTransparency = 1
    Title.TextWrapped = false

    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Size = UDim2.new(0, 36, 0, 36)
    CloseBtn.Position = UDim2.new(1, -45, 0, 7)
    CloseBtn.Text = "✖"
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseBtn.TextColor3 = Color3.new(1,1,1)
    CloseBtn.TextSize = 18
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

    local MinBtn = Instance.new("TextButton", Header)
    MinBtn.Size = UDim2.new(0, 36, 0, 36)
    MinBtn.Position = UDim2.new(1, -88, 0, 7)
    MinBtn.Text = "—"
    MinBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    MinBtn.TextColor3 = Color3.new(1,1,1)
    MinBtn.TextSize = 18
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)

    --// CONTENT CONTAINER (Hides when minimized)
    local ContentFrame = Instance.new("Frame", Main)
    ContentFrame.Size = UDim2.new(1, 0, 1, -50)
    ContentFrame.Position = UDim2.new(0, 0, 0, 50)
    ContentFrame.BackgroundTransparency = 1

    --// SIDEBAR
    local Sidebar = Instance.new("Frame", ContentFrame)
    Sidebar.Size = UDim2.new(0, 160, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Sidebar.BorderSizePixel = 0

    local TabList = Instance.new("UIListLayout", Sidebar)
    TabList.Padding = UDim.new(0, 10)
    TabList.HorizontalAlignment = "Center"
    Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 15)

    --// PAGES CONTAINER
    local Pages = Instance.new("Frame", ContentFrame)
    Pages.Size = UDim2.new(1, -170, 1, 0)
    Pages.Position = UDim2.new(0, 160, 0, 0)
    Pages.BackgroundTransparency = 1

    local Tabs = {}
    local function CreateTab(name, active)
        local Frame = Instance.new("ScrollingFrame", Pages)
        Frame.Size = UDim2.new(1, -10, 1, -20)
        Frame.Position = UDim2.new(0, 5, 0, 10)
        Frame.BackgroundTransparency = 1
        Frame.Visible = active
        Frame.ScrollBarThickness = 2
        Frame.CanvasSize = UDim2.new(0, 0, 1.5, 0)
        local Layout = Instance.new("UIListLayout", Frame)
        Layout.Padding = UDim.new(0, 12)
        Layout.HorizontalAlignment = "Center"

        local Btn = Instance.new("TextButton", Sidebar)
        Btn.Size = UDim2.new(0.85, 0, 0, 42)
        Btn.BackgroundColor3 = active and _G.DH_Config.Accent or Color3.fromRGB(25, 25, 25)
        Btn.Text = name
        Btn.TextColor3 = active and Color3.new(1,1,1) or Color3.fromRGB(170, 170, 170)
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 16 -- Bigger Sidebar Text
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

        Btn.MouseButton1Click:Connect(function()
            for _, v in pairs(Tabs) do 
                v.F.Visible = false 
                v.B.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                v.B.TextColor3 = Color3.fromRGB(170, 170, 170)
            end
            Frame.Visible = true
            Btn.BackgroundColor3 = _G.DH_Config.Accent
            Btn.TextColor3 = Color3.new(1,1,1)
        end)
        Tabs[name] = {F = Frame, B = Btn}
        return Frame
    end

    -- Tabs Creation (Discord is First!)
    local DiscordTab = CreateTab("💬 Discord", true)
    local CombatTab = CreateTab("⚔️ Combat", false)
    local VisualsTab = CreateTab("👁️ Visuals", false)
    local MoveTab = CreateTab("⚡ Movement", false)
    local ProfileTab = CreateTab("👤 Profile", false)

    --// DISCORD TAB SETUP
    local DiscLabel = Instance.new("TextLabel", DiscordTab)
    DiscLabel.Size = UDim2.new(1, -20, 0, 40)
    DiscLabel.BackgroundTransparency = 1
    DiscLabel.Text = "Join the Official Support Server"
    DiscLabel.TextColor3 = Color3.new(1,1,1)
    DiscLabel.Font = Enum.Font.GothamBold
    DiscLabel.TextSize = 18

    local DiscBox = Instance.new("TextBox", DiscordTab)
    DiscBox.Size = UDim2.new(1, -40, 0, 45)
    DiscBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    DiscBox.Text = "https://discord.gg/placeholder"
    DiscBox.TextColor3 = _G.DH_Config.Accent
    DiscBox.Font = Enum.Font.GothamMedium
    DiscBox.TextSize = 16
    DiscBox.ClearTextOnFocus = false
    DiscBox.TextEditable = false -- So they can easily copy it
    Instance.new("UICorner", DiscBox).CornerRadius = UDim.new(0, 8)

    local CopyBtn = Instance.new("TextButton", DiscordTab)
    CopyBtn.Size = UDim2.new(1, -40, 0, 40)
    CopyBtn.BackgroundColor3 = _G.DH_Config.Accent
    CopyBtn.Text = "Copy Link"
    CopyBtn.TextColor3 = Color3.new(1,1,1)
    CopyBtn.Font = Enum.Font.GothamBold
    CopyBtn.TextSize = 16
    Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 8)
    CopyBtn.MouseButton1Click:Connect(function()
        if setclipboard then setclipboard(DiscBox.Text) end
        CopyBtn.Text = "Copied!"
        task.wait(2)
        CopyBtn.Text = "Copy Link"
    end)

    --// TOGGLE SYSTEM (Redesigned sliding pill)
    local function AddToggle(name, parent, key)
        local T = Instance.new("TextButton", parent)
        T.Size = UDim2.new(1, -20, 0, 50)
        T.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        T.Text = "      " .. name
        T.TextColor3 = Color3.fromRGB(220, 220, 220)
        T.Font = Enum.Font.GothamMedium
        T.TextSize = 16 -- Bigger toggle text
        T.TextXAlignment = "Left"
        Instance.new("UICorner", T).CornerRadius = UDim.new(0, 8)

        -- Pill Background
        local Pill = Instance.new("Frame", T)
        Pill.Size = UDim2.new(0, 46, 0, 24)
        Pill.Position = UDim2.new(1, -60, 0.5, -12)
        Pill.BackgroundColor3 = _G.DH_Config[key] and _G.DH_Config.Accent or Color3.fromRGB(50, 50, 50)
        Instance.new("UICorner", Pill).CornerRadius = UDim.new(1, 0)

        -- Sliding Dot
        local Dot = Instance.new("Frame", Pill)
        Dot.Size = UDim2.new(0, 18, 0, 18)
        Dot.Position = _G.DH_Config[key] and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        Dot.BackgroundColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

        T.MouseButton1Click:Connect(function()
            _G.DH_Config[key] = not _G.DH_Config[key]
            local state = _G.DH_Config[key]
            
            TweenService:Create(Pill, TweenInfo.new(0.3), {BackgroundColor3 = state and _G.DH_Config.Accent or Color3.fromRGB(50, 50, 50)}):Play()
            TweenService:Create(Dot, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)}):Play()
        end)
    end

    AddToggle("Aimbot (Hard Lock)", CombatTab, "Aimbot")
    AddToggle("Hitbox Expander", CombatTab, "RageHitbox")
    AddToggle("ESP Highlights", VisualsTab, "ESP")
    AddToggle("Speed Bypass", MoveTab, "Speed")
    AddToggle("Fly Hack (WASD)", MoveTab, "Fly")
    AddToggle("Noclip", MoveTab, "Noclip")

    --// PROFILE TAB
    local PImage = Instance.new("ImageLabel", ProfileTab)
    PImage.Size = UDim2.new(0, 100, 0, 100)
    PImage.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    PImage.Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150"
    Instance.new("UICorner", PImage).CornerRadius = UDim.new(1, 0)

    local function MakeProfText(txt)
        local l = Instance.new("TextLabel", ProfileTab)
        l.Size = UDim2.new(1, 0, 0, 30)
        l.BackgroundTransparency = 1
        l.Text = txt
        l.TextColor3 = Color3.new(1,1,1)
        l.Font = Enum.Font.GothamBold
        l.TextSize = 16
    end
    MakeProfText("Username: " .. LocalPlayer.Name)
    MakeProfText("User ID: " .. LocalPlayer.UserId)
    MakeProfText("Account Age: " .. LocalPlayer.AccountAge .. " days")

    --// CONFIRMATION POPUP
    local ConfirmOverlay = Instance.new("Frame", Main)
    ConfirmOverlay.Size = UDim2.new(1, 0, 1, 0)
    ConfirmOverlay.BackgroundColor3 = Color3.new(0,0,0)
    ConfirmOverlay.BackgroundTransparency = 1
    ConfirmOverlay.Visible = false
    ConfirmOverlay.ZIndex = 500

    local ConfirmBox = Instance.new("Frame", ConfirmOverlay)
    ConfirmBox.Size = UDim2.new(0, 280, 0, 140)
    ConfirmBox.Position = UDim2.new(0.5, -140, 0.5, -70)
    ConfirmBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UICorner", ConfirmBox).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", ConfirmBox).Color = Color3.fromRGB(60, 60, 60)

    local Prompt = Instance.new("TextLabel", ConfirmBox)
    Prompt.Size = UDim2.new(1, 0, 0.5, 0)
    Prompt.Text = "Confirm Exit?"
    Prompt.TextColor3 = Color3.new(1,1,1)
    Prompt.Font = Enum.Font.GothamBold
    Prompt.TextSize = 20
    Prompt.BackgroundTransparency = 1

    local Yes = Instance.new("TextButton", ConfirmBox)
    Yes.Size = UDim2.new(0, 100, 0, 35)
    Yes.Position = UDim2.new(0.1, 0, 0.6, 0)
    Yes.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    Yes.Text = "Yes"
    Yes.TextColor3 = Color3.new(1,1,1)
    Yes.Font = Enum.Font.GothamBold
    Instance.new("UICorner", Yes).CornerRadius = UDim.new(0, 6)

    local No = Instance.new("TextButton", ConfirmBox)
    No.Size = UDim2.new(0, 100, 0, 35)
    No.Position = UDim2.new(0.55, 0, 0.6, 0)
    No.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    No.Text = "No"
    No.TextColor3 = Color3.new(1,1,1)
    No.Font = Enum.Font.GothamBold
    Instance.new("UICorner", No).CornerRadius = UDim.new(0, 6)

    --// WINDOW HANDLERS
    CloseBtn.MouseButton1Click:Connect(function() 
        ConfirmOverlay.Visible = true 
        TweenService:Create(ConfirmOverlay, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
    end)
    No.MouseButton1Click:Connect(function() 
        ConfirmOverlay.Visible = false 
        ConfirmOverlay.BackgroundTransparency = 1
    end)
    Yes.MouseButton1Click:Connect(function() ScreenGui:Destroy(); getgenv().DiamondHub_Loaded = false end)

    local Mini = false
    MinBtn.MouseButton1Click:Connect(function()
        Mini = not Mini
        if Mini then
            ContentFrame.Visible = false -- Hides everything so text doesn't bunch up
            TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 620, 0, 50)}):Play()
        else
            TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 620, 0, 420)}):Play()
            task.wait(0.2)
            ContentFrame.Visible = true
        end
    end)

    -- Dragging
    local d, ds, sp
    Header.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true; ds = i.Position; sp = Main.Position end end)
    UserInputService.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - ds; Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
    end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)

    --// ENGINE (Aimbot, Movement, ESP)
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

        if _G.DH_Config.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local t = GetNearest()
            if t then Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position) end
        end

        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character.HumanoidRootPart
            local hum = LocalPlayer.Character.Humanoid
            hum.WalkSpeed = _G.DH_Config.Speed and _G.DH_Config.WalkSpeedValue or 16

            if _G.DH_Config.Fly then
                root.Velocity = Vector3.new(0, 2, 0)
                local move = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
                root.CFrame = root.CFrame + (move * (_G.DH_Config.FlySpeed/15))
            end
        end

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local head = p.Character:FindFirstChild("Head")
                if head then
                    head.Size = _G.DH_Config.RageHitbox and Vector3.new(_G.DH_Config.HitboxSize, _G.DH_Config.HitboxSize, _G.DH_Config.HitboxSize) or Vector3.new(1.2, 1.2, 1.2)
                    head.Transparency = _G.DH_Config.RageHitbox and 0.8 or 0
                    head.CanCollide = not _G.DH_Config.RageHitbox
                    
                    local h = p.Character:FindFirstChild("DH_High") or Instance.new("Highlight", p.Character)
                    h.Name = "DH_High"; h.Enabled = _G.DH_Config.ESP; h.FillColor = _G.DH_Config.Accent
                end
            end
        end
    end)

    RunService.Stepped:Connect(function()
        if _G.DH_Config.Noclip and LocalPlayer.Character then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)

end)

if not success then warn("DiamondHub Error: " .. err) end
