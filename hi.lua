local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")
local gui = Instance.new("ScreenGui", pg)
gui.ResetOnSpawn = false
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 80)
frame.Position = UDim2.new(0.5, -150, 0.5, -40)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 12)
local label = Instance.new("TextLabel", frame)
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Text = "hi"
label.TextScaled = true
label.Font = Enum.Font.GothamBold
wait(3)
gui:Destroy()
