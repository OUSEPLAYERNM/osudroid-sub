
--!nonstrict

--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled


--// STATE
local scriptActive = true
local masterEnabled = false
local groupBombingEnabled = true
local arcModeEnabled = false
local freezeEnabled = false
local debugEnabled = false
local speed = 4600
local bombInterval = 0.60
local homingDisableDistance = 0.01
local arc_max_height = 250
local LARGE_BOMBER_NAME = "Large Bomber"
local WATER_FOLDER_NAME = "BombrainWaterGrid"
local LARGE_ANCHORS = {
    Japan = Vector3.new(250, 100.6, -10246.3),
    USA = Vector3.new(250, 100.6, 10246.3),
}
local selectedTarget = { type = "All" }
local selectedIslands = {}
local spectatingVehicle = nil
local frozenPlane = nil
local lbCurrentBomber = nil
local lbCurrentSeat = nil
local ActiveProjectiles = {}
local bombTargetAssignment = {}
local projectileId = 0
local lastFireTime = 0
local lastFailure = ""
local waterFolder = nil
local lastVehicleSignature = ""
local lastIslandSignature = ""
local customStatus = nil
local customStatusUntil = 0
local performanceMetrics = { HeartbeatTime = 0 }
local targetCache = { Parts = {}, Signature = "", LastRefresh = 0 }
local statusLabel

--// THEME
local THEME = {
    BG = Color3.fromRGB(8, 8, 10),
    PANEL = Color3.fromRGB(13, 13, 16),
    CONTROL = Color3.fromRGB(20, 20, 24),
    BORDER = Color3.fromRGB(222, 222, 227),
    BORDER_SOFT = Color3.fromRGB(150, 150, 156),
    TEXT = Color3.fromRGB(236, 236, 240),
    DIM = Color3.fromRGB(126, 126, 134),
    ON = Color3.fromRGB(240, 240, 244),
    DARK = Color3.fromRGB(8, 8, 10),
}

--// VEHICLE NAMES
local PLANE_NAMES = {
    ["Bomber"] = true,
    ["Torpedo Bomber"] = true,
    ["Large Bomber"] = true,
}
local DESTROYER_CRUISER_NAMES = {
    ["Destroyer"] = true,
    ["Cruiser"] = true,
    ["Heavy Cruiser"] = true,
    ["Submarine"] = true,
}
local BATTLESHIP_CARRIER_NAMES = {
    ["Battleship"] = true,
    ["Carrier"] = true,
}

--// MOBILE SCALING
local WIN_W, WIN_H, BTN_H, PAD
if IS_MOBILE then
    WIN_W = UDim2.new(0.85, 0, 0.7, 0)
    WIN_H = WIN_W
    BTN_H = 38
    PAD = 10
else
    WIN_W = UDim2.new(0, 340, 0, 600)
    BTN_H = 30
    PAD = 16
end

--// AIM PART
local aimPart = Instance.new("Part")
aimPart.Name = "BombrainAimTarget"
aimPart.Size = Vector3.new(1, 1, 1)
aimPart.Anchored = true
aimPart.CanCollide = false
aimPart.CanTouch = false
aimPart.CanQuery = false
aimPart.Transparency = 1

local highlightTargets
local buildVehicleList
local buildIslandList
local updateAutoFreezeButton
local unloadScript

--// UTILITY
local function isFiniteNumber(n)
    return typeof(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
end

local function isFiniteVector3(v)
    return typeof(v) == "Vector3" and isFiniteNumber(v.X) and isFiniteNumber(v.Y) and isFiniteNumber(v.Z)
end

local function clampNumber(v, a, b)
    if v < a then return a end
    if v > b then return b end
    return v
end

local function getPlayerTeam()
    if player and player.Team and player.Team.Name then
        return tostring(player.Team.Name)
    end
    return "USA"
end

local function getEnemyTeam()
    if getPlayerTeam():lower() == "usa" then
        return "Japan"
    end
    return "USA"
end

local function setStatus(text)
    customStatus = text
    customStatusUntil = tick() + 5
    if statusLabel then
        statusLabel.Text = text
    end
end

local function getOwnDock()
    local t = getPlayerTeam()
    if t == "Japan" then return Workspace:FindFirstChild("JapanDock") end
    if t == "USA" then return Workspace:FindFirstChild("USDock") end
    return nil
end

local function getHarbourAnchorPosition()
    local exact = LARGE_ANCHORS[getPlayerTeam()]
    if exact then return exact end
    local dock = getOwnDock()
    if dock then return dock:GetPivot().Position + Vector3.new(-70, 50, 0) end
    return nil
end

local islandCache = nil
local islandCacheTime = 0

local function getIslands()
    local now = tick()
    if islandCache and (now - islandCacheTime) < 0.5 then
        return islandCache
    end
    local islands = {}
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name == "Island" then
            local codeObj = obj:FindFirstChild("IslandCode")
            if codeObj and codeObj:IsA("StringValue") then
                local mainPart = obj.PrimaryPart or obj:FindFirstChild("Main") or obj:FindFirstChildWhichIsA("BasePart")
                if not mainPart then
                    for _, part in ipairs(obj:GetDescendants()) do
                        if part:IsA("BasePart") then
                            mainPart = part
                            break
                        end
                    end
                end
                if mainPart then
                    table.insert(islands, { model = obj, mainPart = mainPart, code = codeObj.Value })
                end
            end
        end
    end
    islandCache = islands
    islandCacheTime = now
    return islands
end

local function getNearestIslandCode(position)
    if not position then return nil end
    local bestCode = nil
    local bestDistance = math.huge
    for _, island in ipairs(getIslands()) do
        local d = (island.mainPart.Position - position).Magnitude
        if d < bestDistance then
            bestDistance = d
            bestCode = island.code
        end
    end
    return bestCode
end

local function isCodeSelected(code)
    for _, c in ipairs(selectedIslands) do
        if c == code then return true end
    end
    return false
end

local function isIslandAllowed(code)
    if #selectedIslands == 0 then return true end
    if not code then return false end
    return isCodeSelected(code)
end

local function resolveMainPart(model)
    if not model or not model.Parent then return nil end
    local main = model.PrimaryPart or model:FindFirstChild("MainBody", true) or model:FindFirstChild("Main", true) or model:FindFirstChildWhichIsA("BasePart")
    if main and main:IsA("BasePart") and main.Parent then return main end
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then return d end
    end
    return nil
end

local function enemyModels(nameSet)
    local my = getPlayerTeam():lower()
    local out = {}
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and nameSet[obj.Name] then
            local tv = obj:FindFirstChild("Team")
            if tv and tostring(tv.Value):lower() ~= my then
                local mp = resolveMainPart(obj)
                if mp then
                    table.insert(out, {
                        model = obj,
                        mainPart = mp,
                        name = obj.Name,
                        team = tostring(tv.Value),
                        island = getNearestIslandCode(mp.Position)
                    })
                end
            end
        end
    end
    return out
end

local function enemyHealParts()
    local my = getPlayerTeam():lower()
    local out = {}
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj.Name == "Healpart" and obj:IsA("Model") then
            local tv = obj:FindFirstChild("Team")
            if tv and tostring(tv.Value):lower() ~= my then
                local mb = obj:FindFirstChild("MainBody", true) or resolveMainPart(obj)
                if mb and mb:IsA("BasePart") then
                    table.insert(out, {
                        model = obj,
                        mainPart = mb,
                        team = tostring(tv.Value),
                        island = getNearestIslandCode(mb.Position)
                    })
                end
            end
        end
    end
    return out
end

local function getEnemyDockMainBody()
    local dockName = getEnemyTeam() == "USA" and "USDock" or "JapanDock"
    local dockModel = Workspace:FindFirstChild(dockName)
    if dockModel and dockModel:IsA("Model") then
        local mb = dockModel:FindFirstChild("MainBody", true)
        if mb and mb:IsA("BasePart") then return mb end
    end
    return nil
end

local function filterIslands(list)
    if #selectedIslands == 0 then return list end
    local out = {}
    for _, info in ipairs(list) do
        local code = info.island or (info.mainPart and getNearestIslandCode(info.mainPart.Position))
        if isIslandAllowed(code) then
            info.island = code
            table.insert(out, info)
        end
    end
    return out
end

local function getAllEnemyPool()
    local pool = {}
    for _, v in ipairs(filterIslands(enemyModels(PLANE_NAMES))) do table.insert(pool, v) end
    for _, v in ipairs(filterIslands(enemyModels(DESTROYER_CRUISER_NAMES))) do table.insert(pool, v) end
    for _, v in ipairs(filterIslands(enemyModels(BATTLESHIP_CARRIER_NAMES))) do table.insert(pool, v) end
    for _, h in ipairs(filterIslands(enemyHealParts())) do table.insert(pool, h) end
    return pool
end

local function getAllTargetMainBodies()
    local t = selectedTarget.type
    if t == "Vehicle" then
        local mp = selectedTarget.mainPart
        if selectedTarget.model and selectedTarget.model.Parent and mp and mp.Parent and isIslandAllowed(selectedTarget.island) then
            return { mp }
        end
        return {}
    elseif t == "Aim" then
        if aimPart.Parent then return { aimPart } end
        return {}
    elseif t == "Dock" then
        local dp = getEnemyDockMainBody()
        if dp and isIslandAllowed(getNearestIslandCode(dp.Position)) then return { dp } end
        return {}
    elseif t == "AllEnemyHealParts" then
        local out = {}
        for _, h in ipairs(filterIslands(enemyHealParts())) do table.insert(out, h.mainPart) end
        return out
    elseif t == "Planes" then
        local out = {}
        for _, v in ipairs(filterIslands(enemyModels(PLANE_NAMES))) do table.insert(out, v.mainPart) end
        return out
    elseif t == "DCS" then
        local out = {}
        for _, v in ipairs(filterIslands(enemyModels(DESTROYER_CRUISER_NAMES))) do table.insert(out, v.mainPart) end
        return out
    elseif t == "BattleshipsCarriers" then
        local out = {}
        for _, v in ipairs(filterIslands(enemyModels(BATTLESHIP_CARRIER_NAMES))) do table.insert(out, v.mainPart) end
        return out
    elseif t == "Islands" then
        local out = {}
        for _, island in ipairs(getIslands()) do
            if #selectedIslands == 0 or isCodeSelected(island.code) then
                table.insert(out, island.mainPart)
            end
        end
        return out
    elseif t == "All" then
        local out = {}
        for _, v in ipairs(getAllEnemyPool()) do table.insert(out, v.mainPart) end
        return out
    end
    return {}
end

local function getTargetCacheSignature()
    local sig = { selectedTarget.type }
    if selectedTarget.type == "Vehicle" then
        table.insert(sig, tostring(selectedTarget.model))
        table.insert(sig, tostring(selectedTarget.mainPart))
    end
    if selectedTarget.type == "Aim" then
        table.insert(sig, tostring(aimPart.Parent))
    end
    table.insert(sig, "isl:" .. tostring(#selectedIslands))
    for _, c in ipairs(selectedIslands) do
        table.insert(sig, tostring(c))
    end
    return table.concat(sig, "|")
end

local function refreshTargetCache(force)
    local sig = getTargetCacheSignature()
    local now = tick()
    if not force and sig == targetCache.Signature and (now - targetCache.LastRefresh) < 0.5 then return end
    targetCache.Parts = getAllTargetMainBodies()
    targetCache.Signature = sig
    targetCache.LastRefresh = now
end

local function getCachedTargetParts()
    refreshTargetCache(false)
    return targetCache.Parts
end

local function countValidCachedTargets()
    refreshTargetCache(false)
    local c = 0
    for _, p in ipairs(targetCache.Parts) do
        if p and p.Parent then c = c + 1 end
    end
    return c
end

local function toggleIsland(code)
    local removed = false
    for i, c in ipairs(selectedIslands) do
        if c == code then
            table.remove(selectedIslands, i)
            removed = true
            break
        end
    end
    if not removed then table.insert(selectedIslands, code) end
    refreshTargetCache(true)
    if buildIslandList then buildIslandList() end
    if buildVehicleList then buildVehicleList() end
end

--// BALLISTICS
local function arcParabola(startPos, finishPos, arc_height, t)
    local mid = (startPos + finishPos) / 2
    local apex = Vector3.new(mid.X, math.max(startPos.Y, finishPos.Y) + arc_height, mid.Z)
    local function lerp(a, b, x) return a + (b - a) * x end
    return lerp(lerp(startPos, apex, t), lerp(apex, finishPos, t), t)
end

local function predictIntercept(bombPos, bombSpeed, targetPos, targetVel)
    local rel = targetPos - bombPos
    local a = targetVel:Dot(targetVel) - bombSpeed * bombSpeed
    local b = 2 * rel:Dot(targetVel)
    local c = rel:Dot(rel)
    local t = 0
    if math.abs(a) < 1e-6 then
        if math.abs(b) > 1e-6 then
            local tl = -c / b
            if tl > 0 then t = tl end
        end
    else
        local disc = b * b - 4 * a * c
        if disc > 0 then
            local sq = math.sqrt(disc)
            local t1 = (-b + sq) / (2 * a)
            local t2 = (-b - sq) / (2 * a)
            t = (t1 > 0 and t1) or (t2 > 0 and t2) or 0
        end
    end
    if t <= 0 then
        local d = rel.Magnitude
        if bombSpeed > 0 then t = d / bombSpeed end
    end
    for _ = 1, 2 do
        local predicted = targetPos + targetVel * t
        local d = (predicted - bombPos).Magnitude
        if d > 0 and bombSpeed > 0 then t = d / bombSpeed end
    end
    local final = targetPos + targetVel * t
    if not isFiniteVector3(final) then return targetPos, 0 end
    return final, t
end

local IGNORED_CLASSES = { ["Terrain"] = true, ["Water"] = true }

local function isObstacle(obj)
    if not obj or not obj.Parent then return false end
    if IGNORED_CLASSES[obj.ClassName] then return false end
    if waterFolder and obj:IsDescendantOf(waterFolder) then return false end
    if obj.Name == "Bomb" then return false end
    if obj:IsA("BasePart") then
        local lower = obj.Name:lower()
        if lower:find("antiair") or lower:find("aa") or lower:find("obstacle") then return true end
        if player.Character and obj:IsDescendantOf(player.Character) then return false end
    end
    return obj:IsA("BasePart")
end

local sharedRaycastParams = RaycastParams.new()
sharedRaycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function resolveMovementDirection(projectile, bomb, finalTarget)
    local offset = finalTarget - bomb.Position
    local dist = offset.Magnitude
    if dist < 0.001 then return Vector3.zero end
    local direct = offset.Unit
    local now = tick()
    if (now - projectile.LastPathTime) >= 0.15 or (projectile.PathIsObstacle and not projectile.PathDirection) then
        projectile.FilterTable[1] = bomb
        sharedRaycastParams.FilterDescendantsInstances = projectile.FilterTable
        local result = Workspace:Raycast(bomb.Position, direct * dist, sharedRaycastParams)
        local blocked = false
        if result then
            local inst = result.Instance
            local isTarget = (projectile.TargetPart and inst == projectile.TargetPart)
                or (projectile.TargetModel and inst:IsDescendantOf(projectile.TargetModel))
            if not isTarget and isObstacle(inst) then
                blocked = true
                local above = result.Position + Vector3.new(0, 30, 0)
                local adjusted = above - bomb.Position
                if adjusted.Magnitude > 0.001 then
                    projectile.PathDirection = adjusted.Unit
                else
                    projectile.PathDirection = direct
                end
            end
        end
        if not blocked then
            projectile.PathDirection = direct
            projectile.PathIsObstacle = false
        else
            projectile.PathIsObstacle = true
        end
        projectile.LastPathTime = now
    end
    if projectile.PathIsObstacle and projectile.PathDirection then return projectile.PathDirection end
    return direct
end

--// NOCLIP / FREEZE
local function setCharacterNoclip(enabled)
    local character = player.Character
    if not character then return end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            if enabled then
                if part:GetAttribute("BombrainOrigCollide") == nil then
                    part:SetAttribute("BombrainOrigCollide", part.CanCollide)
                end
                part.CanCollide = false
                part.CanQuery = false
                part.CanTouch = false
            else
                part.CanCollide = part:GetAttribute("BombrainOrigCollide") == true
                part.CanQuery = true
                part.CanTouch = true
                part:SetAttribute("BombrainOrigCollide", nil)
            end
        end
    end
end

local function freezePlaneModel(model)
    if not model or not model.Parent then return false end
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true
            part.CanCollide = false
            part.CanQuery = false
            part.CanTouch = false
            part.Velocity = Vector3.zero
            part.RotVelocity = Vector3.zero
            part.AssemblyLinearVelocity = Vector3.zero
            part.AssemblyAngularVelocity = Vector3.zero
            for _, child in ipairs(part:GetChildren()) do
                if child:IsA("BodyMover") or child:IsA("BodyVelocity") or child:IsA("BodyGyro")
                    or child:IsA("BodyPosition") or child:IsA("BodyForce") or child:IsA("VectorForce")
                    or child:IsA("LinearVelocity") or child:IsA("AngularVelocity") or child:IsA("Torque")
                    or child:IsA("Constraint") then
                    child:Destroy()
                end
            end
        end
    end
    frozenPlane = model
    setCharacterNoclip(true)
    return true
end

local function unfreezePlane()
    if frozenPlane and frozenPlane.Parent then
        for _, part in ipairs(frozenPlane:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = false
                part.CanCollide = true
                part.CanQuery = true
                part.CanTouch = true
            end
        end
    end
    setCharacterNoclip(false)
    frozenPlane = nil
end

local function getSeatedPlane()
    local character = player.Character
    if not character then return nil end
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then return nil end
    local seat = humanoid.SeatPart
    if not seat or (not seat:IsA("Seat") and not seat:IsA("VehicleSeat")) then return nil end
    local plane = seat:FindFirstAncestorOfClass("Model")
    if plane and PLANE_NAMES[plane.Name] then return plane end
    return nil
end

--// LARGE BOMBER SPAWN
local Event = nil
do
    local attempts = 0
    while not Event and attempts < 50 do
        Event = ReplicatedStorage:FindFirstChild("Event")
        if not Event then
            task.wait(0.1)
            attempts = attempts + 1
        end
    end
end

local function lbGetEvent()
    if Event and Event.Parent then return Event end
    Event = ReplicatedStorage:FindFirstChild("Event")
    if not Event then
        local ok, result = pcall(function() return ReplicatedStorage:WaitForChild("Event", 2) end)
        if ok and result then Event = result end
    end
    return Event
end

local function lbGetBombers()
    local list = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == LARGE_BOMBER_NAME then
            table.insert(list, obj)
        end
    end
    return list
end

local function lbOwns(bomber)
    local owner = bomber:FindFirstChild("Owner", true)
    if not owner then return false end
    local v = owner.Value
    return v == player.Name or v == player
end

local function lbGetOwned()
    for _, b in ipairs(lbGetBombers()) do
        if lbOwns(b) then return b end
    end
    return nil
end

local function lbWaitForOwned(timeout)
    local deadline = tick() + timeout
    while tick() < deadline do
        local owned = lbGetOwned()
        if owned then return owned end
        task.wait(0.1)
    end
    return lbGetOwned()
end

local function lbGetSeat(model)
    if not model then return nil end
    local direct = model:FindFirstChild("Seat")
    if direct and direct:IsA("BasePart") then return direct end
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("VehicleSeat") or d:IsA("Seat") then return d end
    end
    return nil
end

local function lbWaitForSeat(bomber, timeout)
    local deadline = tick() + timeout
    while tick() < deadline do
        if not bomber or not bomber.Parent then return nil end
        local seat = lbGetSeat(bomber)
        if seat and seat.Parent then return seat end
        task.wait(0.1)
    end
    return nil
end

local function lbGetAirports(dock)
    local vehicleSP = dock and dock:FindFirstChild("VehicleSP")
    if not vehicleSP then return {} end
    local airports = {}
    for _, child in ipairs(vehicleSP:GetChildren()) do
        if child.Name == "Airport" then table.insert(airports, child) end
    end
    return airports
end

local function lbFireVSpawn(airport)
    local event = lbGetEvent()
    if not event then return false end
    local payloads = {
        { airport, LARGE_BOMBER_NAME, 5 },
        { airport, LARGE_BOMBER_NAME },
        { airport.Name, LARGE_BOMBER_NAME, 5 },
        { airport, LARGE_BOMBER_NAME, player.Team and player.Team.Name or "USA" },
    }
    for _, payload in ipairs(payloads) do
        local ok = pcall(function() event:FireServer("VSpawn", payload) end)
        if ok then
            if lbWaitForOwned(1.2) then return true end
        end
    end
    return false
end

local function lbSpawn()
    if lbGetOwned() then return true end
    if not lbGetEvent() then return false end
    local dock = getOwnDock()
    local airports = lbGetAirports(dock)
    if #airports == 0 then return false end
    setStatus("waiting for large bomber")
    for _ = 1, 8 do
        for _, airport in ipairs(airports) do
            if lbFireVSpawn(airport) then
                setStatus("large bomber found")
                return true
            end
        end
        task.wait(0.35)
    end
    if lbWaitForOwned(2) then
        setStatus("large bomber found")
        return true
    end
    return false
end

local function lbSit()
    for _ = 1, 12 do
        local bomber = lbGetOwned()
        if not bomber then return false end
        local seat = lbGetSeat(bomber)
        if not seat or not seat.Parent then
            setStatus("waiting for seat")
            seat = lbWaitForSeat(bomber, 1.5)
        end
        if seat and seat.Parent then
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if humanoid and root then
                setStatus("seating player")
                root.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
                task.wait(0.06)
                pcall(function() seat:Sit(humanoid) end)
                task.wait(0.22)
                if humanoid.SeatPart == seat or seat.Occupant == humanoid then
                    lbCurrentBomber = bomber
                    lbCurrentSeat = seat
                    setStatus("large bomber seated")
                    return true
                end
            end
        end
        task.wait(0.18)
    end
    return false
end

local function lbSpawnAndSit()
    setStatus("spawning large bomber")
    if not lbSpawn() then return false end
    task.wait(0.35)
    if not lbSit() then return false end
    task.wait(0.25)
    return lbCurrentBomber ~= nil and lbCurrentSeat ~= nil
end

local function getSeatedLargeBomber()
    local character = player.Character
    if not character then return nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end
    local seat = humanoid.SeatPart
    if not seat then return nil end
    local model = seat:FindFirstAncestorOfClass("Model")
    if model and model.Name == LARGE_BOMBER_NAME and lbOwns(model) then
        lbCurrentBomber = model
        lbCurrentSeat = seat
        return model
    end
    return nil
end

--// HARBOUR FLOAT
local harbourFloatBP = nil
local harbourFloatConn = nil

local function stopHarbourFloat()
    if harbourFloatConn then
        harbourFloatConn:Disconnect()
        harbourFloatConn = nil
    end
    if harbourFloatBP then
        harbourFloatBP:Destroy()
        harbourFloatBP = nil
    end
end

local function startHarbourFloat()
    stopHarbourFloat()
    local character = player.Character
    if not character then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local target = getHarbourAnchorPosition()
    if not target then return false end
    harbourFloatBP = Instance.new("BodyPosition")
    harbourFloatBP.MaxForce = Vector3.new(1e8, 1e8, 1e8)
    harbourFloatBP.P = 10000
    harbourFloatBP.D = 750
    harbourFloatBP.Position = target
    harbourFloatBP.Parent = hrp
    harbourFloatConn = RunService.Heartbeat:Connect(function()
        if not hrp or not hrp.Parent then
            stopHarbourFloat()
            return
        end
        local current = getHarbourAnchorPosition()
        if current and harbourFloatBP then
            harbourFloatBP.Position = current
        end
    end)
    return true
end

local function isNearHarbour()
    local character = player.Character
    if not character then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local target = getHarbourAnchorPosition()
    if not target then return false end
    return (hrp.Position - target).Magnitude < 25
end

local function runAutoSequence()
    stopHarbourFloat()
    setStatus("spawning large bomber")
    local plane = getSeatedLargeBomber()
    if not plane then
        if not lbSpawnAndSit() then return false end
        plane = lbCurrentBomber
    end
    if not plane or not plane.Parent then return false end
    setStatus("auto: seated, moving to anchor")
    if not startHarbourFloat() then
        setStatus("auto: harbour float failed")
        return false
    end
    local arrived = false
    for _ = 1, 100 do
        if isNearHarbour() then
            arrived = true
            break
        end
        task.wait(0.05)
    end
    if freezePlaneModel(plane) then
        freezeEnabled = true
        if updateAutoFreezeButton then updateAutoFreezeButton() end
        task.wait(0.15)
        stopHarbourFloat()
        setStatus(arrived and "auto: anchor freeze complete" or "auto: freeze complete")
        return true
    end
    stopHarbourFloat()
    setStatus("auto: freeze failed")
    return false
end

local function autoSpawnAndFreeze()
    if freezeEnabled then
        stopHarbourFloat()
        unfreezePlane()
        freezeEnabled = false
        if updateAutoFreezeButton then updateAutoFreezeButton() end
        setStatus("freeze released")
        return
    end
    task.spawn(function()
        for _ = 1, 5 do
            if runAutoSequence() then return end
            task.wait(1.5)
        end
        setStatus("auto: large bomber failed")
    end)
end

--// SESSION
local function rejoinSameServer()
    setStatus("rejoining server")
    pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
end

local function serverHop()
    setStatus("searching for server")
    task.spawn(function()
        local ok, response = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"))
        end)
        if ok and response and response.data then
            for _, server in pairs(response.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, player) end)
                    return
                end
            end
        end
        setStatus("server hop failed")
    end)
end

--// SPECTATE
local function isRecordValid(rec)
    return rec and rec.model and rec.model.Parent and rec.mainPart and rec.mainPart.Parent
end

local function isRecordEnemy(rec)
    if not isRecordValid(rec) then return false end
    local tv = rec.model:FindFirstChild("Team")
    return tv and tostring(tv.Value):lower() ~= getPlayerTeam():lower()
end

local function startSpectate(rec)
    if not isRecordValid(rec) or not isRecordEnemy(rec) then return end
    local camera = Workspace.CurrentCamera
    if not camera then return end
    camera.CameraSubject = rec.mainPart
    camera.CameraType = Enum.CameraType.Track
    spectatingVehicle = rec
end

local function stopSpectate()
    local camera = Workspace.CurrentCamera
    if camera then
        camera.CameraType = Enum.CameraType.Custom
        local character = player and player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then camera.CameraSubject = humanoid end
        end
    end
    spectatingVehicle = nil
end

local function setAimTarget()
    local pos = nil
    if mouse and mouse.Hit then
        pos = mouse.Hit.Position
    else
        local camera = Workspace.CurrentCamera
        if camera then
            local ray = camera:ScreenPointToRay(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
            pos = ray.Origin + ray.Direction * 2000
        end
    end
    if not pos then return end
    aimPart.CFrame = CFrame.new(pos)
    if not aimPart.Parent then aimPart.Parent = Workspace end
    selectedTarget = { type = "Aim" }
    refreshTargetCache(true)
    if highlightTargets then highlightTargets() end
end

--// PROJECTILE SYSTEM
local function shouldControlBomb()
    return masterEnabled or (tick() - lastFireTime) <= 2
end

local function cleanupBombAssignments()
    local now = tick()
    for bomb, a in pairs(bombTargetAssignment) do
        if not bomb or not bomb.Parent or (now - a.time) > 0.5 then
            bombTargetAssignment[bomb] = nil
        end
    end
end

local function ensureMovementController(bomb)
    if not bomb or not bomb.Parent then return nil end
    local controller = bomb:FindFirstChildOfClass("BodyVelocity")
    if not controller then
        controller = Instance.new("BodyVelocity")
        controller.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        controller.Velocity = Vector3.zero
        controller.Parent = bomb
    end
    controller.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    return controller
end

local function assignTargetForBomb(bomb)
    local parts = getCachedTargetParts()
    if #parts == 0 then return nil end
    if selectedTarget.type == "Vehicle" or selectedTarget.type == "Aim" then
        for _, p in ipairs(parts) do
            if p and p.Parent then return p end
        end
        return nil
    end
    if groupBombingEnabled then
        cleanupBombAssignments()
        local used = {}
        for _, a in pairs(bombTargetAssignment) do used[a.target] = true end
        local best = nil
        local bestDist = math.huge
        for _, p in ipairs(parts) do
            if p and p.Parent and not used[p] then
                local d = (p.Position - bomb.Position).Magnitude
                if d < bestDist then
                    bestDist = d
                    best = p
                end
            end
        end
        if not best then
            for _, p in ipairs(parts) do
                if p and p.Parent then
                    local d = (p.Position - bomb.Position).Magnitude
                    if d < bestDist then
                        bestDist = d
                        best = p
                    end
                end
            end
        end
        if best then
            bombTargetAssignment[bomb] = { target = best, time = tick() }
        end
        return best
    end
    local best = nil
    local bestDist = math.huge
    for _, p in ipairs(parts) do
        if p and p.Parent then
            local d = (p.Position - bomb.Position).Magnitude
            if d < bestDist then
                bestDist = d
                best = p
            end
        end
    end
    return best
end

local function removeProjectile(projectile, reason, completed)
    if not projectile then return end
    if projectile.Bomb and ActiveProjectiles[projectile.Bomb] then
        ActiveProjectiles[projectile.Bomb] = nil
    end
    if projectile.Controller and projectile.Controller.Parent then
        projectile.Controller.Velocity = Vector3.zero
        projectile.Controller:Destroy()
    end
    if projectile.Bomb and projectile.Bomb.Parent then
        projectile.Bomb.Anchored = true
    end
    projectile.State = completed and "COMPLETED" or "INVALID"
    projectile.Reason = reason or ""
    if not completed then lastFailure = reason or "UNKNOWN" end
end

local function terminateAllProjectiles(reason)
    local list = {}
    for _, p in pairs(ActiveProjectiles) do table.insert(list, p) end
    for _, p in ipairs(list) do removeProjectile(p, reason, false) end
end

local initializeProjectile
local updateProjectile

initializeProjectile = function(bomb, source)
    if not scriptActive then return end
    if not bomb or not bomb.Parent or not bomb:IsA("BasePart") or bomb.Name ~= "Bomb" then return end
    if ActiveProjectiles[bomb] then return end
    if not shouldControlBomb() then return end
    bomb.Anchored = false
    bomb.CanCollide = true
    local controller = ensureMovementController(bomb)
    if not controller then return end
    local targetPart = assignTargetForBomb(bomb)
    projectileId = projectileId + 1
    local projectile = {
        Id = projectileId,
        Bomb = bomb,
        Controller = controller,
        TargetPart = targetPart,
        TargetModel = nil,
        TargetName = "None",
        LastValidPosition = targetPart and targetPart.Position or nil,
        State = targetPart and "TRACKING" or "WAITING",
        Reason = source or "",
        Created = tick(),
        InitialDistance = nil,
        PathDirection = nil,
        PathIsObstacle = false,
        LastPathTime = 0,
        FilterTable = { bomb },
        NextAcquireTime = 0,
        PredictionTime = 0,
        FailureReported = false,
    }
    if targetPart then
        if targetPart.Parent and targetPart.Parent:IsA("Model") then
            projectile.TargetModel = targetPart.Parent
        end
        projectile.TargetName = targetPart.Parent and targetPart.Parent.Name or targetPart.Name
    end
    ActiveProjectiles[bomb] = projectile
end

updateProjectile = function(projectile)
    local bomb = projectile.Bomb
    if not bomb or not bomb.Parent then
        removeProjectile(projectile, "BOMB_REMOVED", true)
        return
    end
    local controller = projectile.Controller
    if not controller or not controller.Parent then
        controller = ensureMovementController(bomb)
        projectile.Controller = controller
        if not controller then
            removeProjectile(projectile, "NO_MOVEMENT_CONTROLLER", false)
            return
        end
    end
    bomb.Anchored = false
    bomb.CanCollide = true
    local targetPart = projectile.TargetPart
    if targetPart and not targetPart.Parent then
        projectile.TargetPart = nil
        targetPart = nil
    end
    if not targetPart and projectile.TargetModel and projectile.TargetModel.Parent then
        local resolved = resolveMainPart(projectile.TargetModel)
        if resolved and resolved.Parent then
            targetPart = resolved
            projectile.TargetPart = resolved
            projectile.LastValidPosition = resolved.Position
        end
    end
    if not targetPart and not projectile.LastValidPosition then
        local age = tick() - projectile.Created
        if age < 0.75 then
            if not projectile.NextAcquireTime or tick() >= projectile.NextAcquireTime then
                projectile.NextAcquireTime = tick() + 0.1
                local acquired = assignTargetForBomb(bomb)
                if acquired and acquired.Parent then
                    targetPart = acquired
                    projectile.TargetPart = acquired
                    if acquired.Parent and acquired.Parent:IsA("Model") then
                        projectile.TargetModel = acquired.Parent
                    end
                    projectile.TargetName = acquired.Parent and acquired.Parent.Name or acquired.Name
                    projectile.LastValidPosition = acquired.Position
                    projectile.State = "TRACKING"
                end
            end
        end
        if not targetPart then
            controller.Velocity = Vector3.zero
            projectile.State = "WAITING"
            if age >= 0.75 then
                removeProjectile(projectile, "NO_TARGET", false)
            end
            return
        end
    end
    local destination
    if targetPart and targetPart.Parent then
        projectile.LastValidPosition = targetPart.Position
        local targetVelocity = targetPart.AssemblyLinearVelocity or Vector3.zero
        local predicted, predictTime = predictIntercept(bomb.Position, speed, targetPart.Position, targetVelocity)
        destination = predicted
        projectile.PredictionTime = predictTime
        projectile.State = "TRACKING"
    else
        destination = projectile.LastValidPosition
        projectile.State = "TRACKING_LAST"
    end
    if not isFiniteVector3(destination) then
        controller.Velocity = Vector3.zero
        return
    end
    local finalTarget = destination
    if arcModeEnabled then
        local currentDistance = (destination - bomb.Position).Magnitude
        if not projectile.InitialDistance then
            projectile.InitialDistance = math.max(currentDistance, 1)
        end
        local progress = 1 - clampNumber(currentDistance / projectile.InitialDistance, 0, 1)
        local arced = arcParabola(bomb.Position, destination, arc_max_height, progress)
        if isFiniteVector3(arced) then finalTarget = arced end
    end
    local direction = resolveMovementDirection(projectile, bomb, finalTarget)
    if direction.Magnitude == 0 then
        controller.Velocity = Vector3.zero
        return
    end
    local distance = (finalTarget - bomb.Position).Magnitude
    if distance <= homingDisableDistance then
        bomb.Position = finalTarget + Vector3.new(0, 0.1, 0)
        controller.Velocity = Vector3.zero
        removeProjectile(projectile, "TARGET_REACHED", true)
        return
    end
    local finalSpeed = speed
    if distance <= 5 then finalSpeed = speed * (distance / 5) end
    controller.Velocity = direction * finalSpeed
end

--// GUI HELPERS
local function corner(inst, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 9)
    c.Parent = inst
    return c
end

local function stroke(inst, color, th, trans)
    local s = Instance.new("UIStroke")
    s.Color = color or THEME.BORDER_SOFT
    s.Thickness = th or 1
    s.Transparency = trans or 0.45
    s.Parent = inst
    return s
end

local function makeDraggable(frame)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

local function makeButton(parent, text, size)
    local btn = Instance.new("TextButton")
    btn.Size = size or UDim2.new(1, 0, 0, BTN_H)
    btn.BackgroundColor3 = THEME.CONTROL
    btn.TextColor3 = THEME.TEXT
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = IS_MOBILE and 14 or 13
    btn.Text = text
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.Parent = parent
    corner(btn, 9)
    stroke(btn, THEME.BORDER_SOFT, 1, 0.5)
    return btn
end

local function makeSectionHeader(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = string.upper(text)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = IS_MOBILE and 12 or 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = THEME.DIM
    lbl.Parent = parent
    return lbl
end

--// GUI STATE
local guiRef
local targetButtons = {}
local countLabels = {}
local masterBtn, autoFreezeBtn, groupBtn, arcBtn, debugBtn, debugLabel
local islandScroll, vehicleScroll

highlightTargets = function()
    for t, b in pairs(targetButtons) do
        local selected = selectedTarget.type == t
        b.BackgroundColor3 = selected and THEME.ON or THEME.CONTROL
        b.TextColor3 = selected and THEME.DARK or THEME.TEXT
    end
end

local function getIslandSignature()
    local sig = {}
    for _, island in ipairs(getIslands()) do table.insert(sig, tostring(island.code)) end
    return table.concat(sig, "|")
end

buildIslandList = function()
    if not islandScroll then return end
    for _, child in ipairs(islandScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local islands = getIslands()
    for index, island in ipairs(islands) do
        local selected = isCodeSelected(island.code)
        local btn = makeButton(islandScroll, (selected and "[x]  " or "[ ]  ") .. "Island " .. tostring(island.code), UDim2.new(1, -6, 0, IS_MOBILE and 34 or 24))
        btn.LayoutOrder = index
        btn.TextSize = IS_MOBILE and 13 or 12
        btn.BackgroundColor3 = selected and THEME.ON or THEME.CONTROL
        btn.TextColor3 = selected and THEME.DARK or THEME.TEXT
        btn.MouseButton1Click:Connect(function() toggleIsland(island.code) end)
    end
    lastIslandSignature = getIslandSignature()
end

local function getVehicleSignature(records)
    local sig = {}
    for _, rec in ipairs(records) do
        table.insert(sig, tostring(rec.model) .. ":" .. tostring(rec.team) .. ":" .. tostring(rec.island))
    end
    return table.concat(sig, "|")
end

local function getEnemyVehicleRecords()
    local records = {}
    local function append(list)
        for _, info in ipairs(list) do table.insert(records, info) end
    end
    append(filterIslands(enemyModels(PLANE_NAMES)))
    append(filterIslands(enemyModels(DESTROYER_CRUISER_NAMES)))
    append(filterIslands(enemyModels(BATTLESHIP_CARRIER_NAMES)))
    table.sort(records, function(a, b)
        if a.name == b.name then return tostring(a.island or "?") < tostring(b.island or "?") end
        return a.name < b.name
    end)
    return records
end

buildVehicleList = function()
    if not vehicleScroll then return end
    for _, child in ipairs(vehicleScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    local records = getEnemyVehicleRecords()
    local rowH = IS_MOBILE and 40 or 30
    for index, rec in ipairs(records) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -6, 0, rowH)
        row.BackgroundColor3 = THEME.PANEL
        row.BorderSizePixel = 0
        row.LayoutOrder = index
        row.Parent = vehicleScroll
        corner(row, 8)
        stroke(row, THEME.BORDER_SOFT, 1, 0.6)
        local isSelected = selectedTarget.type == "Vehicle" and selectedTarget.model == rec.model
        local isSpectated = spectatingVehicle and spectatingVehicle.model == rec.model
        local btnW = IS_MOBILE and 36 or 30
        local selectBtn = makeButton(row, isSelected and "[x]" or "[ ]", UDim2.new(0, btnW, 0, IS_MOBILE and 32 or 22))
        selectBtn.Position = UDim2.new(0, 4, 0, 4)
        selectBtn.TextSize = IS_MOBILE and 13 or 12
        selectBtn.BackgroundColor3 = isSelected and THEME.ON or THEME.CONTROL
        selectBtn.TextColor3 = isSelected and THEME.DARK or THEME.TEXT
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, IS_MOBILE and -130 or -106, 0, IS_MOBILE and 32 or 22)
        nameLabel.Position = UDim2.new(0, IS_MOBILE and 46 or 40, 0, 4)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = string.format("%s  |  %s", rec.name, tostring(rec.island or "?"))
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextSize = IS_MOBILE and 12 or 12
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.TextColor3 = THEME.TEXT
        nameLabel.BorderSizePixel = 0
        nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
        nameLabel.Parent = row
        local specW = IS_MOBILE and 64 or 58
        local specBtn = makeButton(row, isSpectated and "LIVE" or "VIEW", UDim2.new(0, specW, 0, IS_MOBILE and 32 or 22))
        specBtn.Position = UDim2.new(1, -(specW + 4), 0, 4)
        specBtn.TextSize = IS_MOBILE and 12 or 11
        specBtn.BackgroundColor3 = isSpectated and THEME.ON or THEME.CONTROL
        specBtn.TextColor3 = isSpectated and THEME.DARK or THEME.TEXT
        selectBtn.MouseButton1Click:Connect(function()
            selectedTarget = { type = "Vehicle", model = rec.model, mainPart = rec.mainPart, name = rec.name, island = rec.island }
            refreshTargetCache(true)
            if highlightTargets then highlightTargets() end
            buildVehicleList()
        end)
        specBtn.MouseButton1Click:Connect(function()
            if spectatingVehicle and spectatingVehicle.model == rec.model then
                stopSpectate()
            else
                startSpectate(rec)
            end
            buildVehicleList()
        end)
    end
    lastVehicleSignature = getVehicleSignature(records)
end

local function updateMasterButton()
    if not masterBtn then return end
    masterBtn.Text = masterEnabled and "ENABLED" or "DISABLED"
    masterBtn.BackgroundColor3 = masterEnabled and THEME.ON or THEME.CONTROL
    masterBtn.TextColor3 = masterEnabled and THEME.DARK or THEME.TEXT
end

updateAutoFreezeButton = function()
    if not autoFreezeBtn then return end
    autoFreezeBtn.Text = freezeEnabled and "RELEASE FREEZE" or "AUTO SPAWN + FREEZE"
    autoFreezeBtn.BackgroundColor3 = freezeEnabled and THEME.ON or THEME.CONTROL
    autoFreezeBtn.TextColor3 = freezeEnabled and THEME.DARK or THEME.TEXT
end

local function updateModeButtons()
    if groupBtn then
        groupBtn.Text = "Distribution   " .. (groupBombingEnabled and "ON" or "OFF")
        groupBtn.BackgroundColor3 = groupBombingEnabled and THEME.ON or THEME.CONTROL
        groupBtn.TextColor3 = groupBombingEnabled and THEME.DARK or THEME.TEXT
    end
    if arcBtn then
        arcBtn.Text = "Arc Trajectory   " .. (arcModeEnabled and "ON" or "OFF")
        arcBtn.BackgroundColor3 = arcModeEnabled and THEME.ON or THEME.CONTROL
        arcBtn.TextColor3 = arcModeEnabled and THEME.DARK or THEME.TEXT
    end
    if debugBtn then
        debugBtn.Text = "Diagnostics   " .. (debugEnabled and "ON" or "OFF")
        debugBtn.BackgroundColor3 = debugEnabled and THEME.ON or THEME.CONTROL
        debugBtn.TextColor3 = debugEnabled and THEME.DARK or THEME.TEXT
    end
end

local function addTargetButton(parent, label, ttype)
    local btn = makeButton(parent, label, UDim2.new(1, 0, 0, IS_MOBILE and 38 or 28))
    btn.MouseButton1Click:Connect(function()
        selectedTarget = { type = ttype }
        refreshTargetCache(true)
        if highlightTargets then highlightTargets() end
    end)
    targetButtons[ttype] = btn
    return btn
end

--// CREATE GUI
local function createGUI()
    if guiRef then
        guiRef:Destroy()
        guiRef = nil
    end
    guiRef = Instance.new("ScreenGui")
    guiRef.Name = "Bombrain"
    guiRef.ResetOnSpawn = false
    guiRef.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    guiRef.IgnoreGuiInset = true

    local Main = Instance.new("Frame", guiRef)
    if IS_MOBILE then
        Main.Size = UDim2.new(0.88, 0, 0.65, 0)
        Main.Position = UDim2.new(0.06, 0, 0.18, 0)
    else
        Main.Size = UDim2.new(0, 340, 0, 600)
        Main.Position = UDim2.new(0, 30, 0, 80)
    end
    Main.BackgroundColor3 = THEME.BG
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    corner(Main, 12)
    stroke(Main, THEME.BORDER, 1, 0.3)
    makeDraggable(Main)

    local titleBarH = IS_MOBILE and 42 or 46
    local TitleBar = Instance.new("Frame", Main)
    TitleBar.Size = UDim2.new(1, 0, 0, titleBarH)
    TitleBar.BackgroundColor3 = THEME.PANEL
    TitleBar.BorderSizePixel = 0
    corner(TitleBar, 12)

    local TitleBlocker = Instance.new("Frame", TitleBar)
    TitleBlocker.Size = UDim2.new(1, 0, 0, 12)
    TitleBlocker.Position = UDim2.new(0, 0, 1, -12)
    TitleBlocker.BackgroundColor3 = THEME.PANEL
    TitleBlocker.BorderSizePixel = 0

    local Title = Instance.new("TextLabel", TitleBar)
    Title.Size = UDim2.new(1, -140, 0, 20)
    Title.Position = UDim2.new(0, PAD, 0, IS_MOBILE and 6 or 7)
    Title.BackgroundTransparency = 1
    Title.Text = "Bombrain"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = IS_MOBILE and 15 or 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextColor3 = THEME.TEXT

    local Subtitle = Instance.new("TextLabel", TitleBar)
    Subtitle.Size = UDim2.new(1, -140, 0, 13)
    Subtitle.Position = UDim2.new(0, PAD + 1, 0, IS_MOBILE and 24 or 26)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "by clev."
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = IS_MOBILE and 10 or 11
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.TextColor3 = THEME.DIM

    local masterBtnW = IS_MOBILE and 68 or 74
    local masterBtnH = IS_MOBILE and 30 or 26
    masterBtn = makeButton(TitleBar, "DISABLED", UDim2.new(0, masterBtnW, 0, masterBtnH))
    masterBtn.Position = UDim2.new(1, -(masterBtnW + 8), 0, 8)
    masterBtn.Font = Enum.Font.GothamBold
    masterBtn.TextSize = IS_MOBILE and 11 or 12
    masterBtn.MouseButton1Click:Connect(function()
        masterEnabled = not masterEnabled
        if masterEnabled then
            refreshTargetCache(true)
        else
            lastFireTime = 0
            terminateAllProjectiles("Operation stopped")
        end
        updateMasterButton()
    end)

    local Content = Instance.new("ScrollingFrame", Main)
    Content.Size = UDim2.new(1, IS_MOBILE and -12 or -16, 1, -(titleBarH + 8))
    Content.Position = UDim2.new(0, IS_MOBILE and 6 or 8, 0, titleBarH + 6)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.ScrollBarThickness = IS_MOBILE and 2 or 3
    Content.ScrollBarImageColor3 = THEME.DIM
    Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Content.CanvasSize = UDim2.new(0, 0, 0, 0)

    local ContentList = Instance.new("UIListLayout", Content)
    ContentList.Padding = UDim.new(0, IS_MOBILE and 6 or 7)
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder

    local order = 0

    makeSectionHeader(Content, "Operation").LayoutOrder = order
    order = order + 1

    autoFreezeBtn = makeButton(Content, "AUTO SPAWN + FREEZE", UDim2.new(1, 0, 0, IS_MOBILE and 42 or 36))
    autoFreezeBtn.Font = Enum.Font.GothamBold
    autoFreezeBtn.TextSize = IS_MOBILE and 13 or 13
    autoFreezeBtn.LayoutOrder = order
    order = order + 1
    autoFreezeBtn.MouseButton1Click:Connect(function()
        autoSpawnAndFreeze()
    end)

    statusLabel = Instance.new("TextLabel", Content)
    statusLabel.Size = UDim2.new(1, 0, 0, 18)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "state idle"
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = IS_MOBILE and 11 or 12
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.TextColor3 = THEME.DIM
    statusLabel.LayoutOrder = order
    order = order + 1

    makeSectionHeader(Content, "Island Filter").LayoutOrder = order
    order = order + 1

    islandScroll = Instance.new("ScrollingFrame", Content)
    islandScroll.Size = UDim2.new(1, 0, 0, IS_MOBILE and 110 or 92)
    islandScroll.BackgroundTransparency = 1
    islandScroll.BorderSizePixel = 0
    islandScroll.ScrollBarThickness = IS_MOBILE and 2 or 3
    islandScroll.ScrollBarImageColor3 = THEME.DIM
    islandScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    islandScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    islandScroll.LayoutOrder = order
    order = order + 1

    local islandListLayout = Instance.new("UIListLayout", islandScroll)
    islandListLayout.Padding = UDim.new(0, 4)
    islandListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    makeSectionHeader(Content, "Target Select").LayoutOrder = order
    order = order + 1

    countLabels.All = addTargetButton(Content, "All Targets", "All")
    countLabels.All.LayoutOrder = order
    order = order + 1

    countLabels.Planes = addTargetButton(Content, "Enemy Planes", "Planes")
    countLabels.Planes.LayoutOrder = order
    order = order + 1

    countLabels.DCS = addTargetButton(Content, "Destroyers and Cruisers", "DCS")
    countLabels.DCS.LayoutOrder = order
    order = order + 1

    countLabels.BC = addTargetButton(Content, "Battleships and Carriers", "BattleshipsCarriers")
    countLabels.BC.LayoutOrder = order
    order = order + 1

    countLabels.Heal = addTargetButton(Content, "Enemy Heal Parts", "AllEnemyHealParts")
    countLabels.Heal.LayoutOrder = order
    order = order + 1

    countLabels.Dock = addTargetButton(Content, "Enemy Dock", "Dock")
    countLabels.Dock.LayoutOrder = order
    order = order + 1

    countLabels.Islands = addTargetButton(Content, "Islands", "Islands")
    countLabels.Islands.LayoutOrder = order
    order = order + 1

    makeSectionHeader(Content, "Manual Aim").LayoutOrder = order
    order = order + 1

    local aimBtn = makeButton(Content, "Set Aim at Cursor", UDim2.new(1, 0, 0, IS_MOBILE and 38 or 28))
    aimBtn.LayoutOrder = order
    order = order + 1
    aimBtn.MouseButton1Click:Connect(function() setAimTarget() end)

    makeSectionHeader(Content, "Ballistics").LayoutOrder = order
    order = order + 1

    arcBtn = makeButton(Content, "Arc Trajectory   ON", UDim2.new(1, 0, 0, IS_MOBILE and 38 or 28))
    arcBtn.LayoutOrder = order
    order = order + 1
    arcBtn.MouseButton1Click:Connect(function()
        arcModeEnabled = not arcModeEnabled
        updateModeButtons()
    end)

    groupBtn = makeButton(Content, "Distribution   OFF", UDim2.new(1, 0, 0, IS_MOBILE and 38 or 28))
    groupBtn.LayoutOrder = order
    order = order + 1
    groupBtn.MouseButton1Click:Connect(function()
        groupBombingEnabled = not groupBombingEnabled
        updateModeButtons()
    end)

    debugBtn = makeButton(Content, "Diagnostics   OFF", UDim2.new(1, 0, 0, IS_MOBILE and 34 or 26))
    debugBtn.LayoutOrder = order
    order = order + 1
    debugBtn.MouseButton1Click:Connect(function()
        debugEnabled = not debugEnabled
        updateModeButtons()
    end)

    debugLabel = Instance.new("TextLabel", Content)
    debugLabel.Size = UDim2.new(1, 0, 0, IS_MOBILE and 120 or 105)
    debugLabel.BackgroundColor3 = THEME.PANEL
    debugLabel.BorderSizePixel = 0
    debugLabel.Text = ""
    debugLabel.Font = Enum.Font.Gotham
    debugLabel.TextSize = IS_MOBILE and 10 or 11
    debugLabel.TextXAlignment = Enum.TextXAlignment.Left
    debugLabel.TextYAlignment = Enum.TextYAlignment.Top
    debugLabel.TextColor3 = THEME.DIM
    debugLabel.TextWrapped = true
    debugLabel.Visible = false
    debugLabel.LayoutOrder = order
    order = order + 1
    corner(debugLabel, 8)
    stroke(debugLabel, THEME.BORDER_SOFT, 1, 0.6)

    makeSectionHeader(Content, "Enemy Vehicles").LayoutOrder = order
    order = order + 1

    vehicleScroll = Instance.new("ScrollingFrame", Content)
    vehicleScroll.Size = UDim2.new(1, 0, 0, IS_MOBILE and 160 or 150)
    vehicleScroll.BackgroundTransparency = 1
    vehicleScroll.BorderSizePixel = 0
    vehicleScroll.ScrollBarThickness = IS_MOBILE and 2 or 3
    vehicleScroll.ScrollBarImageColor3 = THEME.DIM
    vehicleScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    vehicleScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    vehicleScroll.LayoutOrder = order
    order = order + 1

    local vehicleListLayout = Instance.new("UIListLayout", vehicleScroll)
    vehicleListLayout.Padding = UDim.new(0, 4)
    vehicleListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    makeSectionHeader(Content, "Spectate").LayoutOrder = order
    order = order + 1

    local stopSpecBtn = makeButton(Content, "Stop Spectating", UDim2.new(1, 0, 0, IS_MOBILE and 38 or 28))
    stopSpecBtn.LayoutOrder = order
    order = order + 1
    stopSpecBtn.MouseButton1Click:Connect(function()
        stopSpectate()
        buildVehicleList()
    end)

    makeSectionHeader(Content, "Session").LayoutOrder = order
    order = order + 1

    local rejoinBtn = makeButton(Content, "Rejoin Server", UDim2.new(1, 0, 0, IS_MOBILE and 38 or 28))
    rejoinBtn.LayoutOrder = order
    order = order + 1
    rejoinBtn.MouseButton1Click:Connect(function() rejoinSameServer() end)

    local hopBtn = makeButton(Content, "Server Hop", UDim2.new(1, 0, 0, IS_MOBILE and 38 or 28))
    hopBtn.LayoutOrder = order
    order = order + 1
    hopBtn.MouseButton1Click:Connect(function() serverHop() end)

    local unloadBtn = makeButton(Content, "Unload Script", UDim2.new(1, 0, 0, IS_MOBILE and 38 or 28))
    unloadBtn.LayoutOrder = order
    order = order + 1
    unloadBtn.MouseButton1Click:Connect(function()
        if unloadScript then unloadScript() end
    end)

    local ok = pcall(function() guiRef.Parent = game:GetService("CoreGui") end)
    if not ok then guiRef.Parent = player:WaitForChild("PlayerGui") end

    highlightTargets()
    updateMasterButton()
    updateAutoFreezeButton()
    updateModeButtons()
    buildIslandList()
    buildVehicleList()
end

--// CONNECTIONS
local childAddedConnection = Workspace.ChildAdded:Connect(function(child)
    if child.Name == "Bomb" and child:IsA("BasePart") then
        initializeProjectile(child, "ChildAdded")
    end
end)

local heartbeatConnection = RunService.Heartbeat:Connect(function()
    if not scriptActive then return end
    local startTime = os.clock()
    for bomb, projectile in pairs(ActiveProjectiles) do
        local ok, err = pcall(updateProjectile, projectile)
        if not ok then
            if projectile and not projectile.FailureReported then
                projectile.FailureReported = true
                projectile.Reason = "UPDATE_ERROR"
                lastFailure = "UPDATE_ERROR: " .. tostring(err)
            end
            if projectile and projectile.Controller and projectile.Controller.Parent then
                projectile.Controller.Velocity = Vector3.zero
            end
        end
    end
    performanceMetrics.HeartbeatTime = (os.clock() - startTime) * 1000
end)

--// BOMB LOOP
task.spawn(function()
    while scriptActive do
        if masterEnabled then
            local event = ReplicatedStorage:WaitForChild("Event", 0.5)
            if event then
                local validTargets = countValidCachedTargets()
                if validTargets > 0 then
                    lastFireTime = tick()
                    if groupBombingEnabled then
                        local count = math.min(validTargets, 10)
                        for _ = 1, count do
                            event:FireServer("bomb")
                            task.wait(0.05)
                        end
                    else
                        event:FireServer("bomb")
                    end
                end
            end
        end
        task.wait(bombInterval)
    end
end)

--// GUI UPDATE LOOP
task.spawn(function()
    while scriptActive do
        if guiRef and guiRef.Parent then
            local planes = filterIslands(enemyModels(PLANE_NAMES))
            local dcs = filterIslands(enemyModels(DESTROYER_CRUISER_NAMES))
            local bc = filterIslands(enemyModels(BATTLESHIP_CARRIER_NAMES))
            local heals = filterIslands(enemyHealParts())
            local pool = getAllEnemyPool()
            local islands = getIslands()
            if countLabels.Planes then countLabels.Planes.Text = "Enemy Planes   " .. tostring(#planes) end
            if countLabels.DCS then countLabels.DCS.Text = "Destroyers and Cruisers   " .. tostring(#dcs) end
            if countLabels.BC then countLabels.BC.Text = "Battleships and Carriers   " .. tostring(#bc) end
            if countLabels.Heal then countLabels.Heal.Text = "Enemy Heal Parts   " .. tostring(#heals) end
            if countLabels.Islands then countLabels.Islands.Text = "Islands   " .. tostring(#islands) end
            if countLabels.All then countLabels.All.Text = "All Targets   " .. tostring(#pool) end
            local specName = "none"
            if spectatingVehicle and isRecordValid(spectatingVehicle) then
                specName = tostring(spectatingVehicle.name)
            end
            if tick() < customStatusUntil and customStatus then
                statusLabel.Text = customStatus
            else
                statusLabel.Text = "state  " .. (masterEnabled and "active" or "idle")
                    .. "  target  " .. tostring(selectedTarget.type):lower()
                    .. "  islands  " .. tostring(#selectedIslands)
                    .. "  spectate  " .. specName
            end
            if spectatingVehicle and (not isRecordValid(spectatingVehicle) or not isRecordEnemy(spectatingVehicle)) then
                stopSpectate()
                buildVehicleList()
            end
            if freezeEnabled and (not frozenPlane or not frozenPlane.Parent) then
                freezeEnabled = false
                setCharacterNoclip(false)
                if updateAutoFreezeButton then updateAutoFreezeButton() end
            end
            local islandSig = getIslandSignature()
            if islandSig ~= lastIslandSignature then buildIslandList() end
            local records = getEnemyVehicleRecords()
            if getVehicleSignature(records) ~= lastVehicleSignature then buildVehicleList() end
            refreshTargetCache(false)
            if masterEnabled then
                for _, child in ipairs(Workspace:GetChildren()) do
                    if child.Name == "Bomb" and child:IsA("BasePart") and not ActiveProjectiles[child] then
                        initializeProjectile(child, "Reconcile")
                    end
                end
            end
            if debugEnabled and debugLabel then
                debugLabel.Visible = true
                local activeCount = 0
                for _ in pairs(ActiveProjectiles) do activeCount = activeCount + 1 end
                local _, projectile = next(ActiveProjectiles)
                if projectile then
                    local targetPart = projectile.TargetPart
                    local posText = "nil"
                    local velText = "nil"
                    if targetPart and targetPart.Parent then
                        local pos = targetPart.Position
                        local vel = targetPart.AssemblyLinearVelocity or Vector3.zero
                        posText = string.format("%.0f, %.0f, %.0f", pos.X, pos.Y, pos.Z)
                        velText = string.format("%.0f, %.0f, %.0f", vel.X, vel.Y, vel.Z)
                    end
                    debugLabel.Text = string.format(
                        "Active %d\nCache %d\nFrame %.2f ms\nTarget %s\nPos %s\nVel %s\nSpeed %d\nIntercept %.4f\nState %s\nReason %s",
                        activeCount, #targetCache.Parts, performanceMetrics.HeartbeatTime,
                        tostring(projectile.TargetName), posText, velText, speed,
                        projectile.PredictionTime or 0, tostring(projectile.State), tostring(projectile.Reason or lastFailure)
                    )
                else
                    debugLabel.Text = string.format(
                        "Active %d\nCache %d\nFrame %.2f ms\nLast %s",
                        activeCount, #targetCache.Parts, performanceMetrics.HeartbeatTime,
                        lastFailure == "" and "none" or lastFailure
                    )
                end
            elseif debugLabel then
                debugLabel.Visible = false
            end
        end
        task.wait(1)
    end
end)

--// WATER FLOOR
local WATER_CORNERS = {
    Vector3.new(-5114, 1, -8188),
    Vector3.new(-5118, 0, 8188),
    Vector3.new(5119, 2, 8190),
    Vector3.new(5126, 6, -8199),
}
local WATER_TILE_SIZE = 2048
local waterMinX = math.min(WATER_CORNERS[1].X, WATER_CORNERS[2].X, WATER_CORNERS[3].X, WATER_CORNERS[4].X)
local waterMinZ = math.min(WATER_CORNERS[1].Z, WATER_CORNERS[2].Z, WATER_CORNERS[3].Z, WATER_CORNERS[4].Z)
local waterMaxX = math.max(WATER_CORNERS[1].X, WATER_CORNERS[2].X, WATER_CORNERS[3].X, WATER_CORNERS[4].X)
local waterMaxZ = math.max(WATER_CORNERS[1].Z, WATER_CORNERS[2].Z, WATER_CORNERS[3].Z, WATER_CORNERS[4].Z)
local waterXTiles = math.ceil((waterMaxX - waterMinX) / WATER_TILE_SIZE)
local waterZTiles = math.ceil((waterMaxZ - waterMinZ) / WATER_TILE_SIZE)
local EXPECTED_WATER_TILES = waterXTiles * waterZTiles

local function buildWaterFloor()
    local existing = Workspace:FindFirstChild(WATER_FOLDER_NAME)
    if existing and #existing:GetChildren() >= EXPECTED_WATER_TILES then
        waterFolder = existing
        return existing
    end
    if existing then existing:Destroy() end
    local folder = Instance.new("Folder")
    folder.Name = WATER_FOLDER_NAME
    folder.Parent = Workspace
    for x = 1, waterXTiles do
        for z = 1, waterZTiles do
            local part = Instance.new("Part")
            part.Name = "Baseplate"
            part.Anchored = true
            part.CanCollide = true
            part.CanQuery = false
            part.CanTouch = false
            part.Size = Vector3.new(WATER_TILE_SIZE, 1, WATER_TILE_SIZE)
            part.BrickColor = BrickColor.new(Color3.fromRGB(128, 187, 219))
            part.Material = Enum.Material.Granite
            part.TopSurface = Enum.SurfaceType.Smooth
            part.BottomSurface = Enum.SurfaceType.Smooth
            part.CFrame = CFrame.new(
                waterMinX + (x - 0.5) * WATER_TILE_SIZE,
                0,
                waterMinZ + (z - 0.5) * WATER_TILE_SIZE
            )
            part.Parent = folder
        end
    end
    waterFolder = folder
    return folder
end

task.spawn(function()
    while scriptActive do
        pcall(buildWaterFloor)
        task.wait(1)
    end
end)

task.spawn(function()
    while scriptActive do
        if freezeEnabled and frozenPlane and frozenPlane.Parent then
            for _, part in ipairs(frozenPlane:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    part.CanQuery = false
                    part.CanTouch = false
                end
            end
        end
        if freezeEnabled then setCharacterNoclip(true) end
        task.wait(0.1)
    end
end)

player.CharacterAdded:Connect(function()
    stopHarbourFloat()
    lbCurrentBomber = nil
    lbCurrentSeat = nil
    if freezeEnabled then
        freezeEnabled = false
        unfreezePlane()
        if updateAutoFreezeButton then updateAutoFreezeButton() end
    end
end)

--// UNLOAD
unloadScript = function()
    scriptActive = false
    masterEnabled = false
    terminateAllProjectiles("Unloaded")
    stopHarbourFloat()
    if freezeEnabled then
        unfreezePlane()
        freezeEnabled = false
    end
    setCharacterNoclip(false)
    stopSpectate()
    if waterFolder and waterFolder.Parent then waterFolder:Destroy() end
    waterFolder = nil
    if childAddedConnection then
        childAddedConnection:Disconnect()
        childAddedConnection = nil
    end
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end
    if aimPart then
        aimPart:Destroy()
        aimPart = nil
    end
    if guiRef then
        guiRef:Destroy()
        guiRef = nil
    end
end

--// INIT
createGUI()
refreshTargetCache(true)
pcall(buildWaterFloor)