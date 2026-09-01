-- ==========================================
-- 1. SERVICES & IMPORTS
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ==========================================
-- 2. CONSTANTS & CONFIGURATION
-- ==========================================
local FLUENT_URL = "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
local INFINITE_YIELD_URL = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"

local THEMES = {
    "Dark", "Light", "Night", "Abyss", "Aero", "Amethyst", 
    "Rose", "Femboy", "Vaporwave", "Forest", "Quartz", "Joker", "Twist", "Crown"
}

local Config = {
    GodMode = false,
    KillAura = false,
    InfiniteAmmo = false,
    SpamRPG = false,
    RapidFire = false,
    RapidFireSpeed = 0
}

-- ==========================================
-- 3. UTILITY FUNCTIONS
-- ==========================================
local function getRandomTheme()
    return THEMES[math.random(1, #THEMES)]
end

local function notify(title, content)
    if Fluent then
        Fluent:Notify({
            Title = title,
            Content = content,
            Duration = 5
        })
    end
end

local function findPlayerByName(name)
    if not name or name == "" then return nil end
    local lowerName = string.lower(name:match("^%s*(.-)%s*$"))
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local playerName = string.lower(player.Name:match("^%s*(.-)%s*$"))
            local displayName = string.lower(player.DisplayName:match("^%s*(.-)%s*$"))
            
            if string.sub(playerName, 1, #lowerName) == lowerName or 
               string.sub(displayName, 1, #lowerName) == lowerName then
                return player
            end
        end
    end
    return nil
end

local function findIslandByCode(code)
    for _, child in ipairs(Workspace:GetChildren()) do
        if child.Name == "Island" and child:IsA("Model") then
            local islandCode = child:FindFirstChild("IslandCode")
            if islandCode and islandCode.Value == tostring(code) then
                return child
            end
        end
    end
    return nil
end

local function findClosureByName(name)
    if not getgc then return nil end
    for _, v in ipairs(getgc()) do
        if type(v) == "function" then
            local info = debug.getinfo(v)
            if info and info.name == name then
                return v
            end
        end
    end
    return nil
end

-- ==========================================
-- 4. COREGUI MANAGEMENT (Hider, Renamer, Cleanup)
-- ==========================================
local function cleanupOldGuis()
    for _, child in ipairs(CoreGui:GetChildren()) do
        if #child.Name == 32 and child:FindFirstChildWhichIsA("UIListLayout", true) then
            child:Destroy()
        end
    end
end

local function setupHiderButton()
    local hiderGui = Instance.new("ScreenGui")
    hiderGui.Name = "HiderGui"
    hiderGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local hiderButton = Instance.new("TextButton")
    hiderButton.Name = "Hider"
    hiderButton.Parent = hiderGui
    hiderButton.Size = UDim2.new(0, 100, 0, 50)
    hiderButton.Position = UDim2.new(0, 10, 0.5, -25)
    hiderButton.BackgroundTransparency = 0.5
    hiderButton.Font = Enum.Font.GothamBold
    hiderButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    hiderButton.Text = "Hide"
    hiderButton.TextScaled = true
    hiderButton.Draggable = true
    hiderButton.AutoButtonColor = false
    hiderButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = hiderButton

    local isHidden = false
    hiderButton.MouseButton1Click:Connect(function()
        isHidden = not isHidden
        hiderButton.Text = isHidden and "View" or "Hide"
        for _, child in ipairs(CoreGui:GetChildren()) do
            if child.Name ~= "HiderGui" and child:IsA("ScreenGui") then
                child.Visible = not isHidden
            end
        end
    end)
end

local function setupCoreGuiRenamer()
    CoreGui.ChildAdded:Connect(function(child)
        if child:IsA("ScreenGui") then
            task.wait(1)
            for _, subChild in ipairs(child:GetChildren()) do
                if subChild:IsA("Frame") then
                    subChild.Name = string.gsub(HttpService:GenerateGUID(false), "[^%w]", "")
                end
            end
            child.Name = string.gsub(HttpService:GenerateGUID(false), "[^%w]", "")
        end
    end)
end

-- ==========================================
-- 5. FEATURE LOOPS & HOOKS
-- ==========================================
local function startGodModeLoop()
    task.spawn(function()
        while Config.GodMode do
            task.wait(0.1)
            local char = LocalPlayer.Character
            if not char then break end
            
            local humanoid = char:FindFirstChild("Humanoid")
            if not humanoid or humanoid.Sit then break end
            
            if not char:FindFirstChild("ForceField") then
                pcall(function()
                    ReplicatedStorage:WaitForChild("Event"):FireServer("Teleport", { "Harbour", "" })
                end)
            end
        end
    end)
end

local function startKillAuraLoop()
    task.spawn(function()
        while Config.KillAura do
            task.wait(0.1)
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("Humanoid") then return end
                
                for _, descendant in ipairs(Workspace:GetDescendants()) do
                    if descendant:IsA("Humanoid") and descendant.Parent and descendant.Parent:FindFirstChild("HumanoidRootPart") then
                        local targetTeam = descendant.Parent:FindFirstChild("Team")
                        if not targetTeam or targetTeam.Value ~= LocalPlayer.Team then
                            local dist = (char.HumanoidRootPart.Position - descendant.Parent.HumanoidRootPart.Position).Magnitude
                            if dist <= 200 then
                                local event = ReplicatedStorage:FindFirstChild("Event")
                                if event then
                                    event:FireServer("shootRifle", "", { descendant.Parent.HumanoidRootPart })
                                    event:FireServer("shootRifle", "hit", { descendant })
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end

local function startSpamRpgLoop()
    task.spawn(function()
        while Config.SpamRPG do
            task.wait(0.1)
            pcall(function()
                local event = ReplicatedStorage:WaitForChild("Event")
                event:FireServer("fireRPG", { Mouse.Hit.p })
            end)
        end
    end)
end

local function startRapidFireLoop()
    task.spawn(function()
        while Config.RapidFire do
            task.wait(Config.RapidFireSpeed)
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("M1 Garand") then
                    char["M1 Garand"]:Activate()
                end
            end)
        end
    end)
end

local function hookInfiniteAmmo()
    local reloadClosure = findClosureByName("reload")
    if reloadClosure and debug.setupvalue then
        for i = 1, 10 do
            local success = pcall(debug.setupvalue, reloadClosure, i, math.huge)
            if not success then break end
        end
        return true
    end
    return false
end

local function disableDockTouch(folderName)
    local folder = Workspace:WaitForChild(folderName, 5)
    if folder then
        for _, descendant in ipairs(folder:GetDescendants()) do
            if descendant:IsA("BasePart") then
                descendant.CanTouch = false
            end
        end
    end
end

-- ==========================================
-- 6. UI CONSTRUCTION (Fluent)
-- ==========================================
local Fluent = nil
local Window = nil

local function buildMenu()
    Fluent = loadstring(game:HttpGet(FLUENT_URL))()
    local ProductInfo = MarketplaceService:GetProductInfo(game.PlaceId)

    Window = Fluent:CreateWindow({
        Title = ProductInfo.Name,
        SubTitle = "By 7sone",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = false,
        Theme = getRandomTheme(),
        MinimizeKey = Enum.KeyCode.LeftControl
    })

    local MainTab = Window:AddTab({ Title = "Main", Icon = "rbxassetid://10723407389" })
    local TeleportsTab = Window:AddTab({ Title = "Teleports", Icon = "rbxassetid://10734898355" })
    Window:SelectTab(1)

    -- Main Tab Toggles
    MainTab:AddToggle("GodMode", { Title = "God Mode", Default = false }):OnChanged(function(value)
        Config.GodMode = value
        if value then startGodModeLoop() end
    end)

    MainTab:AddToggle("KillAura", { Title = "Kill Aura", Default = false }):OnChanged(function(value)
        Config.KillAura = value
        if not value then
            notify("Warning", "-This Option Only Kills Enemies\n-You Need To Hold M1 Garand")
        else
            startKillAuraLoop()
        end
    end)

    MainTab:AddToggle("InfiniteA", { Title = "Infinite Ammo", Default = false }):OnChanged(function(value)
        Config.InfiniteAmmo = value
        if value and not hookInfiniteAmmo() then
            notify("Error", "Your exploit does not support this option")
        end
    end)

    MainTab:AddToggle("SpamRPG", { Title = "Spam RPG", Default = false }):OnChanged(function(value)
        Config.SpamRPG = value
        if value then startSpamRpgLoop() end
    end)

    MainTab:AddToggle("RapidA", { Title = "Rapid Fire", Default = false }):OnChanged(function(value)
        Config.RapidFire = value
        if not value then
            notify("Hint", "For Better GamePlay Turn On Infinite Ammo(:")
        else
            startRapidFireLoop()
        end
    end)

    MainTab:AddSlider("RapidFireSpeed", {
        Title = "Rapid-Fire Speed",
        Default = 0,
        Min = 0,
        Max = 5,
        Rounding = 1,
        Callback = function(value)
            Config.RapidFireSpeed = value
        end
    })

    -- Main Tab Buttons
    MainTab:AddSection("Spoofer, Etc...")

    MainTab:AddButton({
        Title = "Anti Harbour Kill",
        Callback = function()
            disableDockTouch("USDock")
            disableDockTouch("JapanDock")
        end
    })

    MainTab:AddButton({
        Title = "Infinite Yield",
        Callback = function()
            loadstring(game:HttpGet(INFINITE_YIELD_URL))()
        end
    })

    -- Teleports Tab Inputs & Buttons
    TeleportsTab:AddSection("Players")
    TeleportsTab:AddInput("GotoPlayer", {
        Title = "Goto Player",
        Placeholder = "Player Name",
        Finished = true,
        Callback = function(name)
            local player = findPlayerByName(name)
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
            else
                notify("Error", "Unknown Player")
            end
        end
    })

    TeleportsTab:AddSection("Harbours")
    TeleportsTab:AddButton({
        Title = "Japan Dock",
        Callback = function()
            local mainBody = Workspace:FindFirstChild("JapanDock") and Workspace.JapanDock:FindFirstChild("MainBody")
            if mainBody then
                mainBody.CanTouch = false
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(mainBody.Position + Vector3.new(0, 10, 0))
            end
        end
    })

    TeleportsTab:AddButton({
        Title = "USA Dock",
        Callback = function()
            local mainBody = Workspace:FindFirstChild("USDock") and Workspace.USDock:FindFirstChild("MainBody")
            if mainBody then
                mainBody.CanTouch = false
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(mainBody.Position + Vector3.new(0, 10, 0))
            end
        end
    })

    TeleportsTab:AddSection("Islands")
    for _, islandCode in ipairs({"A", "B", "C"}) do
        TeleportsTab:AddButton({
            Title = "Island " .. islandCode,
            Callback = function()
                local island = findIslandByCode(islandCode)
                if island then
                    local flagPad = island:FindFirstChild("FlagPad", true)
                    if flagPad then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(flagPad.Position + Vector3.new(0, 5, 0))
                    end
                end
            end
        })
    end
end

-- ==========================================
-- 7. ENTRY POINT / STARTUP LOGIC
-- ==========================================
local function initialize()
    cleanupOldGuis()
    setupHiderButton()
    setupCoreGuiRenamer()
    buildMenu()
end

initialize()