--[[
    FINAL MONSTER v3.1 — Ring + Fling (Planes Edition)
    FIXED: moving target tracking + plane prediction lag
    - 3x stronger lead calculation
    - acceleration-aware prediction
    - dense orbital sweep instead of fixed points
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local Player = Players.LocalPlayer

getgenv().OldPos = getgenv().OldPos or nil
getgenv().FPDH = getgenv().FPDH or Workspace.FallenPartsDestroyHeight

local function Message(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 5
        })
    end)
end

local function getLocalRoot()
    local chr = Player.Character
    return chr and chr:FindFirstChild("HumanoidRootPart")
end

-- ============================================================
-- OWNERSHIP + REPLICATION
-- ============================================================
Player.ReplicationFocus = Workspace
RunService.Heartbeat:Connect(function()
    pcall(function()
        sethiddenproperty(Player, "SimulationRadius", math.huge)
    end)
end)

-- ============================================================
-- SHARED STATE
-- ============================================================
local ringEnabled = false
local FlingActive = false
local ringLockDuringFling = true
local ringLockCenter = nil
local SelectedTargets = {}
local PlayerCheckboxes = {}

-- ============================================================
-- IMPROVED NETWORK PREDICTION (FIXED for moving targets)
-- ============================================================
local pingCache = 0.08
local lastPing = 0
local trackers = {}

RunService.Heartbeat:Connect(function()
    if tick() - lastPing > 0.5 then
        lastPing = tick()
        pcall(function()
            local ping = Player:GetNetworkPing()
            if ping and ping > 0 then
                pingCache = ping
            end
        end)
    end
end)

local function GetNetworkLead()
    -- FIXED: stronger lead multiplier for fast-moving planes
    return math.clamp(pingCache * 2.6 + 0.04, 0.08, 0.9)
end

local function GetPredictedCFrame(BasePart)
    if not BasePart or not BasePart.Parent then
        if BasePart then trackers[BasePart] = nil end
        return nil
    end
    local now = tick()
    local data = trackers[BasePart]
    local vel = BasePart.AssemblyLinearVelocity or Vector3.new()
    local accel = Vector3.new()

    if data then
        local dt = now - data.t
        if dt > 0.0001 and dt < 0.4 then
            local delta = BasePart.Position - data.pos
            local measured = delta / dt
            if measured.Magnitude > 2000 then
                measured = measured.Unit * 2000
            end
            -- FIXED: trust measured velocity more (engine velocity is often delayed)
            vel = vel:Lerp(measured, 0.6)
            if data.vel then
                local ddt = now - (data.vt or data.t)
                if ddt > 0.0001 then
                    local measuredAccel = (measured - data.vel) / ddt
                    if measuredAccel.Magnitude > 800 then
                        measuredAccel = measuredAccel.Unit * 800
                    end
                    accel = measuredAccel
                end
            end
        end
    end

    trackers[BasePart] = {
        pos = BasePart.Position,
        t = now,
        vel = vel,
        vt = now
    }

    if vel.Magnitude < 2 then
        return BasePart.CFrame
    end

    -- FIXED: much stronger lead calculation
    local speed = vel.Magnitude
    local leadTime = GetNetworkLead() + math.clamp(speed / 350, 0, 0.55)
    leadTime = math.clamp(leadTime, 0.08, 0.95)

    local offset = vel * leadTime + accel * (leadTime * leadTime * 0.5)

    -- FIXED: raised cap from 70 to 220 studs
    if offset.Magnitude > 220 then
        offset = offset.Unit * 220
    end

    return BasePart.CFrame + offset
end

-- ============================================================
-- RING SYSTEM (original values — proven stable)
-- ============================================================
local radius = math.huge
local height = 300
local rotationSpeed = 1000000
local attractionStrength = 2500000
local SAFE_BUBBLE = 0
local ringParts = {}

local function RetainPart(part)
    if part:IsA("BasePart") and not part:IsA("Terrain") and not part.Anchored and part:IsDescendantOf(Workspace) then
        local chr = Player.Character
        if chr and part:IsDescendantOf(chr) then return false end
        pcall(function()
            part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
        end)
        part.CanCollide = false
        return true
    end
    return false
end

local function addRingPart(part)
    if RetainPart(part) then ringParts[part] = true end
end
local function removeRingPart(part)
    ringParts[part] = nil
end

for _, part in pairs(Workspace:GetDescendants()) do
    addRingPart(part)
end
Workspace.DescendantAdded:Connect(addRingPart)
Workspace.DescendantRemoving:Connect(removeRingPart)

RunService.Heartbeat:Connect(function()
    if not ringEnabled then return end
    local chr = Player.Character
    local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local center
    if FlingActive and ringLockDuringFling and ringLockCenter then
        center = ringLockCenter.Position
    else
        center = hrp.Position
    end
    for part in pairs(ringParts) do
        if not part or not part.Parent then
            ringParts[part] = nil
        else
            local localChr = Player.Character
            if not localChr or not part:IsDescendantOf(localChr) then
                if not part.Anchored then
                    part.CanCollide = false
                    local pos = part.Position
                    local dist = Vector3.new(pos.X - center.X, 0, pos.Z - center.Z).Magnitude
                    if dist > SAFE_BUBBLE then
                        local ang = math.atan2(pos.Z - center.Z, pos.X - center.X) + math.rad(rotationSpeed)
                        local r = math.min(radius, dist)
                        local target = Vector3.new(
                            center.X + math.cos(ang) * r,
                            center.Y + height * math.abs(math.sin((pos.Y - center.Y) / height)),
                            center.Z + math.sin(ang) * r
                        )
                        local dir = target - pos
                        if dir.Magnitude > 0.01 then
                            part.AssemblyLinearVelocity = dir.Unit * attractionStrength
                            part.AssemblyAngularVelocity = Vector3.new(rotationSpeed, rotationSpeed, rotationSpeed)
                        end
                    else
                        part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- GUI
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FinalMonsterV31"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = Player:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 410)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -205)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -32, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "FINAL MONSTER v3.1 [FIXED]"
Title.TextColor3 = Color3.fromRGB(255, 70, 70)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 15
Title.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Position = UDim2.new(1, -32, 0, 0)
CloseButton.Size = UDim2.new(0, 32, 0, 32)
CloseButton.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 16
CloseButton.Parent = TitleBar

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Position = UDim2.new(0, 10, 0, 40)
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "0 selected | Ring: Off"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 13
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

local RingToggle = Instance.new("TextButton")
RingToggle.Position = UDim2.new(0, 10, 0, 65)
RingToggle.Size = UDim2.new(1, -20, 0, 30)
RingToggle.BackgroundColor3 = Color3.fromRGB(120, 25, 25)
RingToggle.BorderSizePixel = 0
RingToggle.Text = "Ring: Off"
RingToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
RingToggle.Font = Enum.Font.SourceSansBold
RingToggle.TextSize = 14
RingToggle.Parent = MainFrame

local SelectionFrame = Instance.new("Frame")
SelectionFrame.Position = UDim2.new(0, 10, 0, 100)
SelectionFrame.Size = UDim2.new(1, -20, 0, 210)
SelectionFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
SelectionFrame.BorderSizePixel = 0
SelectionFrame.Parent = MainFrame

local PlayerScrollFrame = Instance.new("ScrollingFrame")
PlayerScrollFrame.Position = UDim2.new(0, 4, 0, 4)
PlayerScrollFrame.Size = UDim2.new(1, -8, 1, -8)
PlayerScrollFrame.BackgroundTransparency = 1
PlayerScrollFrame.BorderSizePixel = 0
PlayerScrollFrame.ScrollBarThickness = 5
PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerScrollFrame.Parent = SelectionFrame

local StartButton = Instance.new("TextButton")
StartButton.Position = UDim2.new(0, 10, 0, 318)
StartButton.Size = UDim2.new(0.5, -15, 0, 38)
StartButton.BackgroundColor3 = Color3.fromRGB(20, 160, 60)
StartButton.BorderSizePixel = 0
StartButton.Text = "START FLING"
StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StartButton.Font = Enum.Font.SourceSansBold
StartButton.TextSize = 14
StartButton.Parent = MainFrame

local StopButton = Instance.new("TextButton")
StopButton.Position = UDim2.new(0.5, 5, 0, 318)
StopButton.Size = UDim2.new(0.5, -15, 0, 38)
StopButton.BackgroundColor3 = Color3.fromRGB(160, 20, 20)
StopButton.BorderSizePixel = 0
StopButton.Text = "STOP FLING"
StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StopButton.Font = Enum.Font.SourceSansBold
StopButton.TextSize = 14
StopButton.Parent = MainFrame

local SelectAllButton = Instance.new("TextButton")
SelectAllButton.Position = UDim2.new(0, 10, 0, 362)
SelectAllButton.Size = UDim2.new(0.5, -15, 0, 30)
SelectAllButton.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
SelectAllButton.BorderSizePixel = 0
SelectAllButton.Text = "SELECT ALL"
SelectAllButton.TextColor3 = Color3.fromRGB(220, 220, 220)
SelectAllButton.Font = Enum.Font.SourceSans
SelectAllButton.TextSize = 12
SelectAllButton.Parent = MainFrame

local DeselectAllButton = Instance.new("TextButton")
DeselectAllButton.Position = UDim2.new(0.5, 5, 0, 362)
DeselectAllButton.Size = UDim2.new(0.5, -15, 0, 30)
DeselectAllButton.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
DeselectAllButton.BorderSizePixel = 0
DeselectAllButton.Text = "DESELECT ALL"
DeselectAllButton.TextColor3 = Color3.fromRGB(220, 220, 220)
DeselectAllButton.Font = Enum.Font.SourceSans
DeselectAllButton.TextSize = 12
DeselectAllButton.Parent = MainFrame

-- ============================================================
-- GUI FUNCTIONS
-- ============================================================
local function CountSelectedTargets()
    local count = 0
    for _ in pairs(SelectedTargets) do count = count + 1 end
    return count
end

local function UpdateStatus()
    local count = CountSelectedTargets()
    if FlingActive then
        StatusLabel.Text = "⟳ Flinging " .. count .. " target(s)"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    else
        StatusLabel.Text = count .. " selected | Ring: " .. (ringEnabled and "On" or "Off")
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end

local function RefreshPlayerList()
    for _, child in pairs(PlayerScrollFrame:GetChildren()) do child:Destroy() end
    PlayerCheckboxes = {}
    local PlayerList = Players:GetPlayers()
    table.sort(PlayerList, function(a, b) return a.Name:lower() < b.Name:lower() end)
    local yPosition = 4
    for _, player in ipairs(PlayerList) do
        if player ~= Player then
            local PlayerEntry = Instance.new("Frame")
            PlayerEntry.Size = UDim2.new(1, -8, 0, 30)
            PlayerEntry.Position = UDim2.new(0, 4, 0, yPosition)
            PlayerEntry.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            PlayerEntry.BorderSizePixel = 0
            PlayerEntry.Parent = PlayerScrollFrame

            local Checkbox = Instance.new("TextButton")
            Checkbox.Size = UDim2.new(0, 22, 0, 22)
            Checkbox.Position = UDim2.new(0, 4, 0.5, -11)
            Checkbox.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
            Checkbox.BorderSizePixel = 0
            Checkbox.Text = ""
            Checkbox.Parent = PlayerEntry

            local Checkmark = Instance.new("TextLabel")
            Checkmark.Size = UDim2.new(1, 0, 1, 0)
            Checkmark.BackgroundTransparency = 1
            Checkmark.Text = "✓"
            Checkmark.TextColor3 = Color3.fromRGB(50, 255, 100)
            Checkmark.TextSize = 16
            Checkmark.Font = Enum.Font.SourceSansBold
            Checkmark.Visible = SelectedTargets[player.Name] ~= nil
            Checkmark.Parent = Checkbox

            local NameLabel = Instance.new("TextLabel")
            NameLabel.Size = UDim2.new(1, -34, 1, 0)
            NameLabel.Position = UDim2.new(0, 30, 0, 0)
            NameLabel.BackgroundTransparency = 1
            NameLabel.Text = player.Name
            NameLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
            NameLabel.TextSize = 14
            NameLabel.Font = Enum.Font.SourceSans
            NameLabel.TextXAlignment = Enum.TextXAlignment.Left
            NameLabel.Parent = PlayerEntry

            local ClickArea = Instance.new("TextButton")
            ClickArea.Size = UDim2.new(1, 0, 1, 0)
            ClickArea.BackgroundTransparency = 1
            ClickArea.Text = ""
            ClickArea.ZIndex = 2
            ClickArea.Parent = PlayerEntry

            ClickArea.MouseButton1Click:Connect(function()
                if SelectedTargets[player.Name] then
                    SelectedTargets[player.Name] = nil
                    Checkmark.Visible = false
                else
                    SelectedTargets[player.Name] = player
                    Checkmark.Visible = true
                end
                UpdateStatus()
            end)

            PlayerCheckboxes[player.Name] = { Entry = PlayerEntry, Checkmark = Checkmark }
            yPosition = yPosition + 34
        end
    end
    PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPosition + 4)
end

local function ToggleAllPlayers(select)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player then
            local checkboxData = PlayerCheckboxes[player.Name]
            if checkboxData then
                if select then
                    SelectedTargets[player.Name] = player
                    checkboxData.Checkmark.Visible = true
                else
                    SelectedTargets[player.Name] = nil
                    checkboxData.Checkmark.Visible = false
                end
            end
        end
    end
    UpdateStatus()
end

-- ============================================================
-- PLANES-SPECIFIC SEATED VEHICLE TARGETING (from v2)
-- ============================================================
local function GetSeatedVehiclePart(THumanoid, TCharacter)
    if not THumanoid then return nil end
    local seat = nil
    pcall(function() seat = THumanoid.SeatPart end)
    if not seat then
        local root = THumanoid.RootPart or TCharacter:FindFirstChild("HumanoidRootPart")
        if root then
            for _, joint in ipairs(root:GetJoints()) do
                pcall(function()
                    local other
                    if joint:IsA("JointInstance") then
                        other = (joint.Part0 == root and joint.Part1) or joint.Part0
                    else
                        local a0 = joint.Attachment0
                        local a1 = joint.Attachment1
                        if a0 and a0.Parent ~= root then
                            other = a0.Parent
                        elseif a1 and a1.Parent ~= root then
                            other = a1.Parent
                        end
                    end
                    if other and other:IsA("BasePart") then
                        if other:IsA("Seat") or other:IsA("VehicleSeat") then
                            seat = other
                        end
                    end
                end)
            end
        end
    end
    if not (seat and seat.Parent) then return nil end

    local model = seat:FindFirstAncestorWhichIsA("Model")
    if model then
        local mainBody = model:FindFirstChild("MainBody")
        if mainBody and mainBody:IsA("BasePart") and not mainBody.Anchored then
            return mainBody
        end
        if model.PrimaryPart and model.PrimaryPart:IsA("BasePart") and not model.PrimaryPart.Anchored then
            return model.PrimaryPart
        end
    end

    local vehicleRoot = seat.AssemblyRootPart
    if vehicleRoot and vehicleRoot.Parent and not vehicleRoot.Anchored then
        return vehicleRoot
    end
    return seat
end

local function GetBestFlingPart(TCharacter, THumanoid)
    local vehicle = GetSeatedVehiclePart(THumanoid, TCharacter)
    if vehicle then return vehicle end
    local TRootPart = THumanoid and THumanoid.RootPart or TCharacter:FindFirstChild("HumanoidRootPart")
    if TRootPart and TRootPart.Parent and not TRootPart.Anchored then return TRootPart end
    local THead = TCharacter:FindFirstChild("Head")
    if THead and THead.Parent and not THead.Anchored then return THead end
    local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    local Handle = Accessory and Accessory:FindFirstChild("Handle")
    if Handle and Handle.Parent and not Handle.Anchored then return Handle end
    if TRootPart and TRootPart.Parent then return TRootPart end
    if THead and THead.Parent then return THead end
    if Handle and Handle.Parent then return Handle end
    return nil
end

-- ============================================================
-- FLING LOGIC (FIXED prediction + dense orbital sweep)
-- ============================================================
local function SkidFling(TargetPlayer)
    local Character = Player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and (Humanoid.RootPart or Character:FindFirstChild("HumanoidRootPart"))
    if not (Character and Humanoid and RootPart) then
        return Message("Error", "Your character is not ready", 2)
    end
    if not Character.PrimaryPart then
        pcall(function() Character.PrimaryPart = RootPart end)
    end

    local TCharacter = TargetPlayer.Character
    if not TCharacter or not TCharacter.Parent then return end
    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local FlingPart = GetBestFlingPart(TCharacter, THumanoid)
    if not FlingPart then
        return Message("Error", TargetPlayer.Name .. " has no valid parts", 2)
    end

    if not getgenv().OldPos or RootPart.AssemblyLinearVelocity.Magnitude < 50 then
        getgenv().OldPos = RootPart.CFrame
    end

    pcall(function() Workspace.CurrentCamera.CameraSubject = FlingPart end)
    if not TCharacter:FindFirstChildWhichIsA("BasePart") and not FlingPart then return end

    pcall(function() FlingPart.CanCollide = true end)
    pcall(function() FlingPart.CustomPhysicalProperties = PhysicalProperties.new(1, 0.3, 0.5) end)
    for _, part in pairs(Character:GetChildren()) do
        if part:IsA("BasePart") then pcall(function() part.CanCollide = true end) end
    end

    -- TUNED VALUES: sweet spot that Roblox accepts without clamping
    local FLING_VELOCITY = 1000000
    local FLING_Y_VELOCITY = 10000000
    local FLING_ROT = 1000000
    local MAX_FORCE = 10000000
    local IMPULSE_MULT = 100000

    local function FPos(BasePart, Pos, Ang, WorldOffset)
        if not RootPart or not RootPart.Parent then return end
        local baseCF = GetPredictedCFrame(BasePart)
        if not baseCF then return end
        local cf = baseCF * Pos * Ang
        if WorldOffset then cf = cf + WorldOffset end
        RootPart.CFrame = cf
        pcall(function() Character:PivotTo(cf) end)
        RootPart.AssemblyLinearVelocity = Vector3.new(FLING_VELOCITY, FLING_Y_VELOCITY, FLING_VELOCITY)
        RootPart.Velocity = Vector3.new(FLING_VELOCITY, FLING_Y_VELOCITY, FLING_VELOCITY)
        RootPart.AssemblyAngularVelocity = Vector3.new(FLING_ROT, FLING_ROT, FLING_ROT)
        RootPart.RotVelocity = Vector3.new(FLING_ROT, FLING_ROT, FLING_ROT)
    end

    local function SFBasePart(BasePart)
        local TimeToWait = 2.35
        local Time = tick()
        local Angle = 0

        -- FIXED: dense orbital sweep instead of sparse fixed points
        -- covers the full hitbox volume so moving targets can't slip through
        local sweepOffsets = {
            CFrame.new(0, 0.8, 0),
            CFrame.new(0, -0.6, 0),
            CFrame.new(1.2, 0.4, 0),
            CFrame.new(-1.2, 0.4, 0),
            CFrame.new(0, 0.4, 1.2),
            CFrame.new(0, 0.4, -1.2),
            CFrame.new(0, 1.8, 0),
            CFrame.new(0, -1.4, 0),
        }

        repeat
            if not FlingActive then break end
            if RootPart and RootPart.Parent and BasePart and BasePart.Parent then
                local moveDir = Vector3.new()
                if THumanoid and THumanoid.Parent then
                    moveDir = THumanoid.MoveDirection
                end

                -- FIXED: use AssemblyLinearVelocity (deprecated .Velocity was giving stale data)
                local vel = BasePart.AssemblyLinearVelocity or Vector3.new()
                local speed = vel.Magnitude

                Angle = Angle + 140

                for i, offset in ipairs(sweepOffsets) do
                    if not FlingActive then break end
                    if not (BasePart and BasePart.Parent) then break end
                    local sweepAng = CFrame.Angles(math.rad(Angle + i * 22), 0, math.rad(Angle * 0.5 + i * 14))
                    local worldOff = moveDir * math.clamp(speed * 0.12, 0, 6)
                    FPos(BasePart, offset, sweepAng, worldOff)
                    RunService.Heartbeat:Wait()
                end
            else
                RunService.Heartbeat:Wait()
            end
        until Time + TimeToWait < tick() or not FlingActive
    end

    pcall(function() Workspace.FallenPartsDestroyHeight = -1e9 end)

    local BV = Instance.new("BodyVelocity")
    BV.Parent = RootPart
    BV.Velocity = Vector3.new(0, 0, 0)
    BV.MaxForce = Vector3.new(MAX_FORCE, MAX_FORCE, MAX_FORCE)

    pcall(function() Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end)

    local mass = FlingPart.AssemblyMass or 1
    if mass <= 0 then mass = 1 end
    mass = math.clamp(mass, 1, 10000)
    pcall(function() FlingPart:ApplyImpulse(Vector3.new(0, IMPULSE_MULT * mass, 0)) end)

    SFBasePart(FlingPart)

    BV:Destroy()
    pcall(function() Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end)
    pcall(function() Workspace.CurrentCamera.CameraSubject = Humanoid end)

    if getgenv().OldPos then
        local returnStart = tick()
        repeat
            if not RootPart or not RootPart.Parent then break end
            RootPart.CFrame = getgenv().OldPos * CFrame.new(0, 0.5, 0)
            pcall(function() Character:PivotTo(getgenv().OldPos * CFrame.new(0, 0.5, 0)) end)
            pcall(function() Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end)
            for _, part in pairs(Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new()
                end
            end
            RunService.Heartbeat:Wait()
        until (RootPart.Position - getgenv().OldPos.Position).Magnitude < 25
            or not RootPart.Parent
            or tick() > returnStart + 5
        pcall(function() Workspace.FallenPartsDestroyHeight = getgenv().FPDH end)
    end
end

-- ============================================================
-- FLING CONTROL (faster cycling for accuracy)
-- ============================================================
local function StartFling()
    if FlingActive then return end
    local count = CountSelectedTargets()
    if count == 0 then
        StatusLabel.Text = "No targets selected!"
        task.wait(1)
        UpdateStatus()
        return
    end
    FlingActive = true
    if ringEnabled and ringLockDuringFling then
        local root = getLocalRoot()
        if root then ringLockCenter = root.CFrame end
    end
    UpdateStatus()
    Message("Started", "Flinging " .. count .. " targets", 2)
    task.spawn(function()
        while FlingActive do
            local validTargets = {}
            for name, player in pairs(SelectedTargets) do
                if player and player.Parent and player.Character then
                    validTargets[name] = player
                else
                    SelectedTargets[name] = nil
                    local checkbox = PlayerCheckboxes[name]
                    if checkbox then checkbox.Checkmark.Visible = false end
                end
            end
            local validCount = 0
            for _ in pairs(validTargets) do validCount = validCount + 1 end
            if validCount == 0 then break end
            for _, player in pairs(validTargets) do
                if FlingActive then
                    SkidFling(player)
                    task.wait(0.03)  -- FIXED: faster between-target cycling
                else
                    break
                end
            end
            UpdateStatus()
            task.wait(0.12)  -- FIXED: tighter loop
        end
        FlingActive = false
        ringLockCenter = nil
        UpdateStatus()
    end)
end

local function StopFling()
    if not FlingActive then return end
    FlingActive = false
    ringLockCenter = nil
    UpdateStatus()
    Message("Stopped", "Fling has been stopped", 2)
end

-- ============================================================
-- BUTTON CONNECTIONS
-- ============================================================
RingToggle.MouseButton1Click:Connect(function()
    ringEnabled = not ringEnabled
    RingToggle.Text = ringEnabled and "Ring: On" or "Ring: Off"
    RingToggle.BackgroundColor3 = ringEnabled and Color3.fromRGB(20, 160, 80) or Color3.fromRGB(120, 25, 25)
    UpdateStatus()
end)
StartButton.MouseButton1Click:Connect(StartFling)
StopButton.MouseButton1Click:Connect(StopFling)
SelectAllButton.MouseButton1Click:Connect(function() ToggleAllPlayers(true) end)
DeselectAllButton.MouseButton1Click:Connect(function() ToggleAllPlayers(false) end)
CloseButton.MouseButton1Click:Connect(function()
    StopFling()
    ScreenGui:Destroy()
end)

Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(function(player)
    if SelectedTargets[player.Name] then SelectedTargets[player.Name] = nil end
    RefreshPlayerList()
    UpdateStatus()
end)

-- ============================================================
-- INIT
-- ============================================================
RefreshPlayerList()
UpdateStatus()
Message("Final Monster v3.1", "FIXED: moving targets + plane lead", 3)