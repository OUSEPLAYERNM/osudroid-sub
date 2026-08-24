local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera

local Env = (function()
	local g = (getgenv and getgenv()) or _G
	local function pick(...)
		for i = 1, select("#", ...) do
			local f = select(i, ...)
			if type(f) == "function" then return f end
		end
		return nil
	end
	local syn = (type(syn) == "table" and syn) or nil
	local fluxus = (type(fluxus) == "table" and fluxus) or nil
	return {
		globals = g,
		request = pick(request, http_request, g.request, g.http_request, syn and syn.request, fluxus and fluxus.request),
		writefile = pick(writefile, g.writefile),
		readfile = pick(readfile, g.readfile),
		isfile = pick(isfile, g.isfile),
		makefolder = pick(makefolder, g.makefolder),
		isfolder = pick(isfolder, g.isfolder),
		getcustomasset = pick(getcustomasset, g.getcustomasset),
		gethui = pick(gethui, g.gethui),
		setclipboard = pick(setclipboard, toclipboard, g.setclipboard, g.toclipboard),
		getgc = pick(getgc, g.getgc),
		setupvalue = pick(debug and debug.setupvalue, setupvalue, g.setupvalue),
		getinfo = pick(debug and debug.getinfo, getinfo, g.getinfo),
	}
end)()
local Global = Env.globals

local RemoteEvent = ReplicatedStorage:WaitForChild("Event", 15)
if not RemoteEvent then
	error("HoundHub: ReplicatedStorage.Event not found. Halting.")
end

local Library = {
	Name = "Hound Hub",
	Version = "2.4.5",
	LogoUrl = "https://raw.githubusercontent.com/Dodirepackers/BloxxyMacroRec/refs/heads/main/Untitled45_20250907025756.png",
	Windows = {},
	_registry = {},
	_connections = {},
	_tasks = {},
	_popups = {},
	_layers = nil,
}
local Palette = {
	AppBg = Color3.fromRGB(13, 12, 12), RowBg = Color3.fromRGB(22, 20, 20),
	RowHover = Color3.fromRGB(29, 26, 26), RowPressed = Color3.fromRGB(36, 31, 31),
	NavHover = Color3.fromRGB(26, 23, 23), NavSelected = Color3.fromRGB(38, 20, 22),
	ControlBg = Color3.fromRGB(27, 24, 24), ControlBorder = Color3.fromRGB(66, 50, 50),
	RowBorder = Color3.fromRGB(42, 32, 32), WindowBorder = Color3.fromRGB(125, 16, 18),
	TextPrimary = Color3.fromRGB(241, 237, 235), TextSecondary = Color3.fromRGB(160, 150, 150),
	TextDisabled = Color3.fromRGB(98, 90, 90), Accent = Color3.fromRGB(152, 20, 24),
	AccentHover = Color3.fromRGB(178, 32, 36), PopupBg = Color3.fromRGB(24, 21, 21),
	TrackBg = Color3.fromRGB(58, 44, 44), Thumb = Color3.fromRGB(241, 237, 235),
}
local SNACK_BG = Color3.fromRGB(18, 16, 16)
local SNACK_BORDER = Color3.fromRGB(112, 20, 22)
local CLOSE_HOVER = Color3.fromRGB(196, 43, 28)
local function C(role) return Palette[role] end
local function bind(inst, prop, role)
	if not inst or not prop then return end
	inst[prop] = Palette[role]
	table.insert(Library._registry, { i = inst, p = prop, r = role })
end
local function cn(class, props)
	local inst = Instance.new(class)
	local parent = props.Parent
	props.Parent = nil
	for k, v in pairs(props) do inst[k] = v end
	inst.Parent = parent
	return inst
end
local function tween(inst, props, dur, style, dir)
	if not inst or not inst.Parent then return nil end
	local info = TweenInfo.new(dur or 0.2, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
	local t = TweenService:Create(inst, info, props)
	t:Play()
	return t
end
local function clampNum(v, a, b) return math.clamp(v, a, b) end
local function inBounds(obj, pos)
	if not obj or not obj.AbsolutePosition then return false end
	local ap = obj.AbsolutePosition
	local asz = obj.AbsoluteSize
	return pos.X >= ap.X and pos.X <= ap.X + asz.X and pos.Y >= ap.Y and pos.Y <= ap.Y + asz.Y
end
local function viewport() return Workspace.CurrentCamera.ViewportSize end
local function later(t, fn)
	local th
	th = task.delay(t, function()
		Library._tasks[th] = nil
		if fn then fn() end
	end)
	Library._tasks[th] = true
	return th
end
local function cancel(th)
	if th and Library._tasks[th] then
		task.cancel(th)
		Library._tasks[th] = nil
	end
end
local function textSize(text, size, font, width)
	return TextService:GetTextSize(text, size, font, Vector2.new(width or 10000, 10000))
end
local function fill(h, cx, cy, w, ht, rot)
	local f = cn("Frame", { Parent = h, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(w, ht), Position = UDim2.fromOffset(cx, cy), Rotation = rot or 0 })
	return { f, "BackgroundColor3" }
end
local function dot(h, cx, cy, d)
	local f = cn("Frame", { Parent = h, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(d, d), Position = UDim2.fromOffset(cx, cy) })
	cn("UICorner", { Parent = f, CornerRadius = UDim.new(0, math.floor(d / 2 + 0.5)) })
	return { f, "BackgroundColor3" }
end
local function outline(h, cx, cy, w, ht, corner)
	local f = cn("Frame", { Parent = h, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(w, ht), Position = UDim2.fromOffset(cx, cy) })
	if corner then cn("UICorner", { Parent = f, CornerRadius = UDim.new(0, corner) }) end
	local s = cn("UIStroke", { Parent = f, Thickness = 1.4 })
	return { s, "Color" }
end
local ICONS = {
	close = function(h) return { fill(h, 9, 9, 11, 1.8, 45), fill(h, 9, 9, 11, 1.8, -45) } end,
	minimize = function(h) return { fill(h, 9, 12, 10, 1.8) } end,
	chevronDown = function(h) return { fill(h, 6.8, 7.8, 6.5, 1.8, 45), fill(h, 11.2, 7.8, 6.5, 1.8, -45) } end,
	chevronRight = function(h) return { fill(h, 8.2, 6.8, 6.5, 1.8, 45), fill(h, 8.2, 11.2, 6.5, 1.8, -45) } end,
	check = function(h) return { fill(h, 6.2, 10.2, 5, 1.8, 45), fill(h, 10.6, 8.6, 9.5, 1.8, -45) } end,
	flag = function(h) return { fill(h, 5, 9, 1.8, 13), outline(h, 10.5, 5.5, 8.5, 5.5, 1) } end,
	wrench = function(h) return { outline(h, 7, 7, 7, 7, 4), fill(h, 11.5, 11.5, 8, 2.2, 45) } end,
	settings = function(h)
		return { outline(h, 9, 9, 8.5, 8.5, 4), fill(h, 9, 2.6, 1.8, 3), fill(h, 9, 15.4, 1.8, 3),
			fill(h, 2.6, 9, 3, 1.8), fill(h, 15.4, 9, 3, 1.8) }
	end,
	drive = function(h) return { outline(h, 9, 9, 13, 9, 2), fill(h, 12.5, 9, 2, 2) } end,
	menu = function(h) return { fill(h, 9, 5.5, 12, 1.8), fill(h, 9, 9, 12, 1.8), fill(h, 9, 12.5, 12, 1.8) } end,
	info = function(h) return { outline(h, 9, 9, 11, 11, 5), fill(h, 9, 10.8, 1.8, 5), fill(h, 9, 6.2, 1.8, 1.8) } end,
	paw = function(h) return { dot(h, 9, 11.6, 7), dot(h, 4.6, 7.2, 3.6), dot(h, 9, 5.6, 3.6), dot(h, 13.4, 7.2, 3.6) } end,
	question = function(h)
		local l = cn("TextLabel", { Parent = h, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
			Font = Enum.Font.GothamBold, TextSize = 15, Text = "?" })
		return { { l, "TextColor3" } }
	end,
	target = function(h)
		return { outline(h, 9, 9, 12, 12, 6), dot(h, 9, 9, 2.4), fill(h, 9, 2.2, 1.5, 2.6),
			fill(h, 9, 15.8, 1.5, 2.6), fill(h, 2.2, 9, 2.6, 1.5), fill(h, 15.8, 9, 2.6, 1.5) }
	end,
	bolt = function(h) return { fill(h, 10.2, 5.4, 2, 6.5, 18), fill(h, 7.8, 12.6, 2, 6.5, 18), fill(h, 9, 9, 4.5, 1.8) } end,
	rocket = function(h)
		return { fill(h, 9, 7.5, 3.4, 7.5), fill(h, 9, 3.2, 1.9, 3), fill(h, 6.7, 12.2, 2.4, 3.2, 32),
			fill(h, 11.3, 12.2, 2.4, 3.2, -32), dot(h, 9, 15, 1.8) }
	end,
	shield = function(h) return { outline(h, 9, 8.5, 10.5, 12, 3), fill(h, 9, 8.5, 1.6, 8) } end,
	plane = function(h) return { fill(h, 9, 9, 2, 12.5), fill(h, 9, 6.8, 13, 2), fill(h, 9, 13.8, 5.5, 1.8) } end,
	globe = function(h) return { outline(h, 9, 9, 12.5, 12.5, 6), fill(h, 9, 9, 12.5, 1.3), outline(h, 9, 9, 5.5, 12.5, 3) } end,
	user = function(h) return { dot(h, 9, 6.2, 5), outline(h, 9, 13.6, 9.5, 5.5, 2.5) } end,
	eye = function(h) return { outline(h, 9, 9, 14.5, 8.5, 4), dot(h, 9, 9, 4) } end,
}
ICONS.help = ICONS.question
local function makeIcon(name, parent, role)
	local holder = cn("Frame", { Parent = parent, BackgroundTransparency = 1, Size = UDim2.fromOffset(18, 18) })
	local builder = ICONS[name] or ICONS.question
	for _, part in ipairs(builder(holder)) do bind(part[1], part[2], role) end
	return holder
end
local logoAsset, logoTried = nil, false
local function loadLogo()
	if logoTried then return logoAsset end
	logoTried = true
	if Env.request and Env.writefile and Env.getcustomasset then
		pcall(function()
			if Env.makefolder and Env.isfolder and not Env.isfolder("HoundHub") then Env.makefolder("HoundHub") end
			local res = Env.request({ Url = Library.LogoUrl, Method = "GET" })
			if res and res.StatusCode == 200 and res.Body and #res.Body > 0 then
				Env.writefile("HoundHub/logo.png", res.Body)
				logoAsset = Env.getcustomasset("HoundHub/logo.png")
			end
		end)
	end
	return logoAsset
end
local function rootParent()
	if Env.gethui then
		local ok, p = pcall(Env.gethui)
		if ok and p then return p end
	end
	local ok, p = pcall(function() return game:GetService("CoreGui") end)
	if ok and p then return p end
	return Players.LocalPlayer:WaitForChild("PlayerGui")
end
local logoSrc, logoWatchers, logoResolving = nil, {}, false
local function deliverLogo(src)
	logoSrc = src
	local watchers = logoWatchers
	logoWatchers = {}
	for _, cb in ipairs(watchers) do cb(src) end
end
local function probe(src, host)
	local img = cn("ImageLabel", { Parent = host, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Image = src })
	local ok = false
	for _ = 1, 12 do
		local fine, loaded = pcall(function() return img.IsLoaded end)
		if fine and loaded then ok = true break end
		task.wait(0.25)
	end
	img:Destroy()
	return ok
end
local function resolveLogo()
	if logoResolving or logoSrc then return end
	logoResolving = true
	task.spawn(function()
		local host = cn("ScreenGui", { Name = "HoundHubProbe", Parent = rootParent() })
		local asset = loadLogo()
		local winner = nil
		if asset and probe(asset, host) then winner = asset
		elseif probe(Library.LogoUrl, host) then winner = Library.LogoUrl end
		host:Destroy()
		if winner then deliverLogo(winner) end
	end)
end
local function brandImage(parent, px)
	local holder = cn("Frame", { Parent = parent, BackgroundTransparency = 1, Size = UDim2.fromOffset(px, px) })
	local pawParts = {}
	for _, part in ipairs(ICONS.paw(holder)) do
		part[1][part[2]] = C("Accent")
		table.insert(pawParts, part[1])
	end
	local settled, img = false, nil
	local function show(src)
		if settled then return end
		if img then img:Destroy() end
		img = cn("ImageLabel", { Parent = holder, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
			ScaleType = Enum.ScaleType.Fit, Image = src })
		cn("UICorner", { Parent = img, CornerRadius = UDim.new(0, math.floor(px / 2 + 0.5)) })
		local checks = 0
		local function check()
			if settled or not img or not img.Parent then return end
			local ok, loaded = pcall(function() return img.IsLoaded end)
			if ok and loaded then
				settled = true
				for _, p in ipairs(pawParts) do p:Destroy() end
				return
			end
			checks = checks + 1
			if checks < 10 then later(0.3, check) end
		end
		check()
	end
	if logoSrc then show(logoSrc) else table.insert(logoWatchers, show) resolveLogo() end
	return holder
end
local function ensureLayers()
	if Library._layers then return Library._layers end
	local parent = nil
	if Env.gethui then
		local ok, p = pcall(Env.gethui)
		if ok and p then parent = p end
	end
	if not parent then pcall(function() parent = game:GetService("CoreGui") end) end
	if not parent then parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
	local gui = cn("ScreenGui", { Name = "HoundHub", ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true, DisplayOrder = 100, Parent = parent })
	local popup = cn("Frame", { Parent = gui, Name = "Popups", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 30 })
	local snack = cn("Frame", { Parent = gui, Name = "Snacks", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 50 })
	cn("UIListLayout", { Parent = snack, Padding = UDim.new(0, 8), FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Bottom,
		SortOrder = Enum.SortOrder.LayoutOrder })
	cn("UIPadding", { Parent = snack, PaddingBottom = UDim.new(0, 16), PaddingRight = UDim.new(0, 16) })
	local tip = cn("Frame", { Parent = gui, Name = "Tips", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 60 })
	Library._layers = { Gui = gui, Popup = popup, Snack = snack, Tip = tip }
	local inputConn = UIS.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if UIS:GetFocusedTextBox() then return end
			for _, w in ipairs(Library.Windows) do
				if w.Hotkey and input.KeyCode == w.Hotkey then w:SetVisible(not w.Frame.Visible) end
			end
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local top = Library._popups[#Library._popups]
			if top and not inBounds(top.Frame, input.Position) and not (top.Anchor and inBounds(top.Anchor, input.Position)) then
				top.Close()
			end
		end
	end)
	Library._connections.input = inputConn
	return Library._layers
end

local vmSuccess, vmChunk = pcall(function() return game:HttpGet("https://vehiclefling.dodirepacked.workers.dev/") end)
if not vmSuccess or not vmChunk or #vmChunk == 0 then
	error("HoundHub: Mandatory VM payload failed to fetch. Halting.")
end
local vmFn, vmErr = loadstring(vmChunk)
if not vmFn then
	error("HoundHub: Mandatory VM payload failed to compile: " .. tostring(vmErr))
end
vmFn()

local function openPopup(anchor, width, height, build)
	local layers = ensureLayers()
	local vp = viewport()
	local ap = anchor.AbsolutePosition
	local asz = anchor.AbsoluteSize
	local x = clampNum(ap.X, 8, math.max(8, vp.X - width - 8))
	local y = ap.Y + asz.Y + 4
	if y + height > vp.Y - 8 then y = ap.Y - height - 4 end
	local frame = cn("Frame", { Parent = layers.Popup, BackgroundColor3 = C("PopupBg"), ClipsDescendants = true,
		Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(width, 0), ZIndex = 31 })
	cn("UICorner", { Parent = frame, CornerRadius = UDim.new(0, 7) })
	local stroke = cn("UIStroke", { Parent = frame, Thickness = 1 })
	bind(stroke, "Color", "ControlBorder")
	build(frame)
	tween(frame, { Size = UDim2.fromOffset(width, height) }, 0.15)
	local entry
	entry = {
		Frame = frame, Anchor = anchor,
		Close = function()
			for i, p in ipairs(Library._popups) do
				if p == entry then table.remove(Library._popups, i) break end
			end
			local t = tween(frame, { Size = UDim2.fromOffset(width, 0) }, 0.12)
			if t then t.Completed:Connect(function() frame:Destroy() end)
			else frame:Destroy() end
		end,
	}
	table.insert(Library._popups, entry)
	return entry
end
local tipFrame, tipLabel = nil, nil
local function attachTooltip(obj, text)
	if not text then return end
	local timer = nil
	obj.MouseEnter:Connect(function()
		timer = later(0.4, function()
			local layers = ensureLayers()
			if not tipFrame then
				tipFrame = cn("Frame", { Parent = layers.Tip, BackgroundColor3 = C("PopupBg"),
					AutomaticSize = Enum.AutomaticSize.XY, Visible = false, ZIndex = 61 })
				cn("UICorner", { Parent = tipFrame, CornerRadius = UDim.new(0, 6) })
				local s = cn("UIStroke", { Parent = tipFrame, Thickness = 1 })
				bind(s, "Color", "ControlBorder")
				cn("UIPadding", { Parent = tipFrame, PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 9),
					PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6) })
				tipLabel = cn("TextLabel", { Parent = tipFrame, BackgroundTransparency = 1, Font = Enum.Font.Gotham,
					TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
				bind(tipLabel, "TextColor3", "TextSecondary")
			end
			tipLabel.Text = text
			tipLabel.Size = UDim2.fromOffset(textSize(text, 12, Enum.Font.Gotham, 240).X, 0)
			tipLabel.AutomaticSize = Enum.AutomaticSize.Y
			local m = UIS:GetMouseLocation()
			local vp = viewport()
			tipFrame.Position = UDim2.fromOffset(clampNum(m.X + 14, 8, vp.X - tipFrame.AbsoluteSize.X - 8), m.Y + 18)
			tipFrame.Visible = true
		end)
	end)
	obj.MouseLeave:Connect(function()
		cancel(timer)
		if tipFrame then tipFrame.Visible = false end
	end)
end
local function hoverable(obj, enterRole)
	obj.MouseEnter:Connect(function()
		if UIS.TouchEnabled and not UIS.MouseEnabled then return end
		tween(obj, { BackgroundColor3 = C(enterRole) }, 0.15)
	end)
	obj.MouseLeave:Connect(function()
		tween(obj, { BackgroundColor3 = C(obj:GetAttribute("restRole") or "RowBg") }, 0.15)
	end)
end
local function setRest(obj, role)
	obj:SetAttribute("restRole", role)
	bind(obj, "BackgroundColor3", role)
end
local function buildToggle(opts)
	local frame = cn("Frame", { BackgroundColor3 = C("ControlBg"), Size = UDim2.fromOffset(42, 22) })
	setRest(frame, "ControlBg")
	cn("UICorner", { Parent = frame, CornerRadius = UDim.new(0, 11) })
	local stroke = cn("UIStroke", { Parent = frame, Thickness = 1 })
	bind(stroke, "Color", "ControlBorder")
	local knob = cn("Frame", { Parent = frame, BorderSizePixel = 0, BackgroundColor3 = C("TextSecondary"),
		Size = UDim2.fromOffset(12, 12), Position = UDim2.fromOffset(5, 5) })
	cn("UICorner", { Parent = knob, CornerRadius = UDim.new(0, 6) })
	local state = { Value = not not opts.Default, Frame = frame, Width = 42, Height = 22 }
	local function paint(animate)
		local target = state.Value and C("Accent") or C("ControlBg")
		local knobTarget = state.Value and Color3.fromRGB(250, 250, 250) or C("TextSecondary")
		local knobX = state.Value and 25 or 5
		if animate then
			tween(frame, { BackgroundColor3 = target }, 0.15)
			tween(knob, { Position = UDim2.fromOffset(knobX, 5), BackgroundColor3 = knobTarget }, 0.15)
		else
			frame.BackgroundColor3 = target
			knob.Position = UDim2.fromOffset(knobX, 5)
			knob.BackgroundColor3 = knobTarget
		end
		stroke.Color = state.Value and C("Accent") or C("ControlBorder")
	end
	function state:Set(v, silent)
		state.Value = not not v
		paint(true)
		if not silent and opts.Callback then task.spawn(opts.Callback, state.Value) end
	end
	function state:Get() return state.Value end
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if opts.Disabled then return end
			state:Set(not state.Value)
		end
	end)
	paint(false)
	return state
end
local function buildDropdown(opts)
	local width = opts.Width or 170
	local frame = cn("Frame", { BackgroundColor3 = C("ControlBg"), Size = UDim2.fromOffset(width, 32) })
	setRest(frame, "ControlBg")
	cn("UICorner", { Parent = frame, CornerRadius = UDim.new(0, 6) })
	local stroke = cn("UIStroke", { Parent = frame, Thickness = 1 })
	bind(stroke, "Color", "ControlBorder")
	local label = cn("TextLabel", { Parent = frame, BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -32, 1, 0), Font = Enum.Font.GothamMedium, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd })
	bind(label, "TextColor3", "TextPrimary")
	local chev = makeIcon("chevronDown", frame, "TextSecondary")
	chev.AnchorPoint = Vector2.new(1, 0.5)
	chev.Position = UDim2.new(1, -8, 0.5, 0)
	local state = { Frame = frame, Width = width, Height = 32 }
	state.Selected = opts.Default
	local function labelText() return tostring(state.Selected or "-") end
	local function fire()
		if opts.Callback then task.spawn(opts.Callback, state.Selected) end
	end
	local function closeSelf()
		for i = #Library._popups, 1, -1 do
			local p = Library._popups[i]
			if p.Anchor == frame then p.Close() end
		end
	end
	local function open()
		closeSelf()
		local vals = opts.Values or {}
		local count = #vals
		local height = math.max(math.min(count * 34 + 8, 210), 42)
		openPopup(frame, width, height, function(popup)
			local list = cn("ScrollingFrame", { Parent = popup, BackgroundTransparency = 1, BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 1), ScrollBarThickness = 0, ElasticBehavior = Enum.ElasticBehavior.Never,
				AutomaticCanvasSize = Enum.AutomaticSize.Y })
			cn("UIListLayout", { Parent = list, Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder })
			cn("UIPadding", { Parent = list, PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
				PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) })
			local display = vals
			if count == 0 then display = { "None" } end
			for _, v in ipairs(display) do
				local chosen = state.Selected == v
				local opt = cn("Frame", { Parent = list, Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = C("PopupBg") })
				setRest(opt, "PopupBg")
				cn("UICorner", { Parent = opt, CornerRadius = UDim.new(0, 5) })
				hoverable(opt, "RowHover")
				local text = cn("TextLabel", { Parent = opt, BackgroundTransparency = 1, Position = UDim2.fromOffset(9, 0),
					Size = UDim2.new(1, -34, 1, 0), Font = Enum.Font.GothamMedium, TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left, Text = tostring(v) })
				bind(text, "TextColor3", chosen and "Accent" or "TextPrimary")
				if chosen then
					local tickIcon = makeIcon("check", opt, "Accent")
					tickIcon.AnchorPoint = Vector2.new(1, 0.5)
					tickIcon.Position = UDim2.new(1, -8, 0.5, 0)
				end
				opt.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						state.Selected = v
						label.Text = labelText()
						fire()
						closeSelf()
					end
				end)
			end
		end)
	end
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if opts.Disabled then return end
			open()
		end
	end)
	function state:Set(v, silent)
		state.Selected = v
		label.Text = labelText()
		if not silent then fire() end
	end
	function state:Get() return state.Selected end
	label.Text = labelText()
	return state
end
local function buildTextbox(opts)
	local width = opts.Width or 170
	local frame = cn("Frame", { BackgroundColor3 = C("ControlBg"), Size = UDim2.fromOffset(width, 32) })
	setRest(frame, "ControlBg")
	cn("UICorner", { Parent = frame, CornerRadius = UDim.new(0, 6) })
	local stroke = cn("UIStroke", { Parent = frame, Thickness = 1 })
	bind(stroke, "Color", "ControlBorder")
	local box = cn("TextBox", { Parent = frame, BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -20, 1, 0), Font = Enum.Font.GothamMedium, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, PlaceholderText = opts.Placeholder or "",
		Text = opts.Default or "", ClearTextOnFocus = false })
	bind(box, "TextColor3", "TextPrimary")
	bind(box, "PlaceholderColor3", "TextDisabled")
	box.Focused:Connect(function() stroke.Color = C("Accent") end)
	box.FocusLost:Connect(function()
		stroke.Color = C("ControlBorder")
		if opts.Callback then task.spawn(opts.Callback, box.Text) end
	end)
	return {
		Frame = frame, Width = width, Height = 32,
		Set = function(_, v) box.Text = tostring(v) end,
		Get = function() return box.Text end,
	}
end
local function newRow(section, opts, control, onClick)
	local row = cn("Frame", { Parent = section.List, BackgroundColor3 = C("RowBg"), Size = UDim2.new(1, 0, 0, 60) })
	setRest(row, "RowBg")
	cn("UICorner", { Parent = row, CornerRadius = UDim.new(0, 7) })
	local stroke = cn("UIStroke", { Parent = row, Thickness = 1 })
	bind(stroke, "Color", "RowBorder")
	hoverable(row, "RowHover")
	local left = cn("Frame", { Parent = row, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 16, 0.5, 0), AutomaticSize = Enum.AutomaticSize.Y })
	cn("UIListLayout", { Parent = left, Padding = UDim.new(0, 3) })
	local title = cn("TextLabel", { Parent = left, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
		Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true, Text = opts.Name or "", AutomaticSize = Enum.AutomaticSize.Y })
	bind(title, "TextColor3", opts.Disabled and "TextDisabled" or "TextPrimary")
	local desc = nil
	if opts.Description then
		desc = cn("TextLabel", { Parent = left, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
			Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true, Text = opts.Description, AutomaticSize = Enum.AutomaticSize.Y })
		bind(desc, "TextColor3", "TextSecondary")
	end
	local cw = control and control.Width or 26
	if control then control.Frame.Parent = row end
	local function layoutRow()
		local W = row.AbsoluteSize.X
		if W <= 1 then return end
		local compact = (W - cw - 44) < 230
		local leftW = compact and (W - 32) or (W - cw - 44)
		left.Size = UDim2.fromOffset(leftW, 0)
		local th = textSize(title.Text, 14, Enum.Font.GothamMedium, leftW).Y
		local dh = 0
		if desc then dh = textSize(desc.Text, 12, Enum.Font.Gotham, leftW).Y + 3 end
		local leftH = th + dh
		if compact then
			row.Size = UDim2.new(1, 0, 0, leftH + (control and control.Height or 20) + 34)
			left.AnchorPoint = Vector2.new(0, 0)
			left.Position = UDim2.fromOffset(16, 12)
			if control then
				control.Frame.AnchorPoint = Vector2.new(0, 0)
				control.Frame.Position = UDim2.fromOffset(16, leftH + 18)
			end
		else
			row.Size = UDim2.new(1, 0, 0, math.max(60, leftH + 24))
			left.AnchorPoint = Vector2.new(0, 0.5)
			left.Position = UDim2.new(0, 16, 0.5, 0)
			if control then
				control.Frame.AnchorPoint = Vector2.new(1, 0.5)
				control.Frame.Position = UDim2.new(1, -16, 0.5, 0)
			end
		end
	end
	row:GetPropertyChangedSignal("AbsoluteSize"):Connect(layoutRow)
	task.defer(layoutRow)
	if onClick then
		row.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				tween(row, { BackgroundColor3 = C("RowPressed") }, 0.08)
			end
		end)
		row.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				tween(row, { BackgroundColor3 = C(row:GetAttribute("restRole") or "RowBg") }, 0.1)
				task.spawn(onClick)
			end
		end)
	end
	attachTooltip(row, opts.Tooltip)
	return row
end
local Section = {}
Section.__index = Section
function Section:AddSectionHeading(text)
	local h = cn("TextLabel", { Parent = self.List, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22),
		Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Text = text })
	bind(h, "TextColor3", "TextPrimary")
	return h
end
function Section:AddLabel(text)
	local row = cn("Frame", { Parent = self.List, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0) })
	local label = cn("TextLabel", { Parent = row, BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 0),
		Position = UDim2.fromOffset(4, 2), Font = Enum.Font.GothamMedium, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Text = text or "", AutomaticSize = Enum.AutomaticSize.Y })
	bind(label, "TextColor3", "TextSecondary")
	return {
		Frame = row, Label = label,
		Set = function(v) label.Text = tostring(v) end,
		Get = function() return label.Text end,
	}
end
function Section:AddToggle(o) local c = buildToggle(o) newRow(self, o, c) return c end
function Section:AddDropdown(o) local c = buildDropdown(o) newRow(self, o, c) return c end
function Section:AddTextbox(o) local c = buildTextbox(o) newRow(self, o, c) return c end
function Section:AddButton(o)
	local row = newRow(self, o, nil, o.Callback)
	local chev = makeIcon("chevronRight", row, "TextSecondary")
	chev.AnchorPoint = Vector2.new(1, 0.5)
	chev.Position = UDim2.new(1, -16, 0.5, 0)
	return { Frame = row }
end
function Section:AddParagraph(o)
	local row = cn("Frame", { Parent = self.List, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0) })
	local text = cn("TextLabel", { Parent = row, BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 0),
		Position = UDim2.fromOffset(4, 2), Font = Enum.Font.Gotham, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Text = o.Text or "", AutomaticSize = Enum.AutomaticSize.Y })
	bind(text, "TextColor3", "TextSecondary")
	return { Frame = row }
end
local Page = {}
Page.__index = Page
function Page:AddSection(title)
	local section = setmetatable({}, Section)
	section.Frame = cn("Frame", { Parent = self.List, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0) })
	cn("UIListLayout", { Parent = section.Frame, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
	section.List = cn("Frame", { Parent = section.Frame, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0) })
	cn("UIListLayout", { Parent = section.List, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
	if title then Section.AddSectionHeading(section, title) end
	return section
end
local Window = {}
Window.__index = Window
function Window:SetActivePage(page)
	for _, p in ipairs(self.Pages) do
		local active = p == page
		p.Content.Visible = active
		if active then
			p.NavBg.BackgroundColor3 = C("NavSelected")
			p.NavBg.BackgroundTransparency = 0
		else
			p.NavBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			p.NavBg.BackgroundTransparency = 1
		end
		p.AccentBar.Visible = active
	end
	self.ActivePage = page
	if self.Mobile then self:SetDrawer(false) end
end
function Window:AddPage(opts)
	local page = setmetatable({}, Page)
	page.Window = self
	page.Name = opts.Name or "Page"
	page.Enabled = true
	page.NavBg = cn("TextButton", { Parent = self.NavList, AutoButtonColor = false, Text = "",
		BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40) })
	cn("UICorner", { Parent = page.NavBg, CornerRadius = UDim.new(0, 6) })
	page.AccentBar = cn("Frame", { Parent = page.NavBg, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(3, 16), Visible = false })
	bind(page.AccentBar, "BackgroundColor3", "Accent")
	cn("UICorner", { Parent = page.AccentBar, CornerRadius = UDim.new(0, 2) })
	local icon = makeIcon(opts.Icon or "settings", page.NavBg, "TextPrimary")
	icon.Position = UDim2.fromOffset(11, 11)
	page.NavTitle = cn("TextLabel", { Parent = page.NavBg, BackgroundTransparency = 1, Position = UDim2.fromOffset(40, 0),
		Size = UDim2.new(1, -48, 1, 0), Font = Enum.Font.GothamMedium, TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left, Text = page.Name })
	bind(page.NavTitle, "TextColor3", "TextPrimary")
	page.NavBg.MouseEnter:Connect(function()
		if self.ActivePage ~= page then
			page.NavBg.BackgroundTransparency = 0
			tween(page.NavBg, { BackgroundColor3 = C("NavHover") }, 0.15)
		end
	end)
	page.NavBg.MouseLeave:Connect(function()
		if self.ActivePage ~= page then page.NavBg.BackgroundTransparency = 1 end
	end)
	page.NavBg.MouseButton1Click:Connect(function()
		if page.Enabled then self:SetActivePage(page) end
	end)
	page.Content = cn("Frame", { Parent = self.Content, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false })
	local header = cn("Frame", { Parent = page.Content, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 64) })
	local title = cn("TextLabel", { Parent = header, BackgroundTransparency = 1, Position = UDim2.fromOffset(24, 14),
		Size = UDim2.new(1, -48, 0, 30), Font = Enum.Font.GothamBold, TextSize = 26,
		TextXAlignment = Enum.TextXAlignment.Left, Text = opts.Name or "" })
	bind(title, "TextColor3", "TextPrimary")
	if opts.Description then
		local desc = cn("TextLabel", { Parent = header, BackgroundTransparency = 1, Position = UDim2.fromOffset(24, 44),
			Size = UDim2.new(1, -48, 0, 16), Font = Enum.Font.Gotham, TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = opts.Description })
		bind(desc, "TextColor3", "TextSecondary")
	end
	local scroll = cn("ScrollingFrame", { Parent = page.Content, BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 68), Size = UDim2.new(1, 0, 1, -68), ScrollBarThickness = 0,
		ElasticBehavior = Enum.ElasticBehavior.Never, AutomaticCanvasSize = Enum.AutomaticSize.Y, ClipsDescendants = true })
	page.List = cn("Frame", { Parent = scroll, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, -48, 0, 0), Position = UDim2.fromOffset(24, 0) })
	cn("UIListLayout", { Parent = page.List, Padding = UDim.new(0, 18), SortOrder = Enum.SortOrder.LayoutOrder })
	cn("UIPadding", { Parent = page.List, PaddingBottom = UDim.new(0, 20) })
	table.insert(self.Pages, page)
	if #self.Pages == 1 then self:SetActivePage(page) end
	return page
end
function Window:SetDrawer(open)
	self.DrawerOpen = open
	self.Nav.Visible = true
	local target = open and 0 or -self.NavWidth
	tween(self.Nav, { Position = UDim2.fromOffset(target, 0) }, 0.2)
	if open then
		self.DrawerOverlay.Visible = true
		tween(self.DrawerOverlay, { BackgroundTransparency = 0.5 }, 0.2)
	else
		tween(self.DrawerOverlay, { BackgroundTransparency = 1 }, 0.2)
		later(0.2, function() self.DrawerOverlay.Visible = false end)
		later(0.22, function()
			if not self.DrawerOpen and self.Mobile then self.Nav.Visible = false end
		end)
	end
end
function Window:SetVisible(visible) self.Frame.Visible = visible end
function Window:Destroy()
	for i, w in ipairs(Library.Windows) do
		if w == self then table.remove(Library.Windows, i) break end
	end
	if self._viewportConn then self._viewportConn:Disconnect() end
	self.Frame:Destroy()
end
function Library:CreateWindow(opts)
	opts = opts or {}
	local layers = ensureLayers()
	local window = setmetatable({}, Window)
	window.Pages = {}
	window.Hotkey = opts.Hotkey
	window.NavWidth = 208
	window.DrawerOpen = false
	local frame = cn("Frame", { Parent = layers.Gui, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(800, 600),
		BackgroundColor3 = C("AppBg"), ClipsDescendants = true, ZIndex = 1 })
	bind(frame, "BackgroundColor3", "AppBg")
	cn("UICorner", { Parent = frame, CornerRadius = UDim.new(0, 10) })
	local wstroke = cn("UIStroke", { Parent = frame, Thickness = 2, ZIndex = 22 })
	bind(wstroke, "Color", "WindowBorder")
	window.Frame = frame
	local titlebar = cn("Frame", { Parent = frame, Size = UDim2.new(1, 0, 0, 44), ZIndex = 2, Active = true, BackgroundTransparency = 1 })
	local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
	local function clampDrag()
		local vp = viewport()
		if vp.X < 10 or vp.Y < 10 then return end
		local size = frame.AbsoluteSize
		local halfW, halfH = size.X / 2, size.Y / 2
		local pos = frame.Position
		local cx = vp.X * pos.X.Scale + pos.X.Offset
		local top = vp.Y * pos.Y.Scale + pos.Y.Offset - halfH
		local minCx, maxCx = 120 - halfW, vp.X - 120 + halfW
		if minCx > maxCx then minCx, maxCx = vp.X / 2, vp.X / 2 end
		cx = clampNum(cx, math.max(minCx, halfW * 0.1), math.min(maxCx, vp.X - halfW * 0.1))
		top = clampNum(top, 8, math.max(8, vp.Y - 60))
		frame.Position = UDim2.new(0, cx, 0, top + halfH)
	end
	local tbBegan = titlebar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	local tbChanged = titlebar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	local uisChanged = UIS.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			clampDrag()
		end
	end)
	window.NavToggle = cn("TextButton", { Parent = titlebar, AutoButtonColor = false, Text = "",
		Position = UDim2.fromOffset(8, 6), Size = UDim2.fromOffset(32, 32), Visible = false, ZIndex = 3 })
	cn("UICorner", { Parent = window.NavToggle, CornerRadius = UDim.new(0, 6) })
	setRest(window.NavToggle, "AppBg")
	hoverable(window.NavToggle, "NavHover")
	local menuIcon = makeIcon("menu", window.NavToggle, "TextPrimary")
	menuIcon.Position = UDim2.fromOffset(7, 7)
	if opts.AppIcon ~= false then
		local logo = brandImage(titlebar, 28)
		logo.Position = UDim2.fromOffset(44, 8)
	end
	local titleText = cn("TextLabel", { Parent = titlebar, BackgroundTransparency = 1, Position = UDim2.fromOffset(80, 0),
		Size = UDim2.new(1, -160, 1, 0), Font = Enum.Font.GothamBold, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, Text = opts.Title or "Hound Hub" })
	bind(titleText, "TextColor3", "TextPrimary")
	local closeBtn = cn("TextButton", { Parent = titlebar, AutoButtonColor = false, Text = "",
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 6), Size = UDim2.fromOffset(32, 32), ZIndex = 3 })
	cn("UICorner", { Parent = closeBtn, CornerRadius = UDim.new(0, 6) })
	bind(closeBtn, "BackgroundColor3", "AppBg")
	local closeIcon = makeIcon("close", closeBtn, "TextPrimary")
	closeIcon.Position = UDim2.fromOffset(7, 7)
	closeBtn.MouseEnter:Connect(function() tween(closeBtn, { BackgroundColor3 = CLOSE_HOVER }, 0.15) end)
	closeBtn.MouseLeave:Connect(function() tween(closeBtn, { BackgroundColor3 = C("AppBg") }, 0.15) end)
	closeBtn.MouseButton1Click:Connect(function()
		if opts.OnClose then task.spawn(opts.OnClose) else window:SetVisible(false) end
	end)
	local body = cn("Frame", { Parent = frame, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 44), Size = UDim2.new(1, 0, 1, -44), ZIndex = 1 })
	window.Nav = cn("Frame", { Parent = body, BackgroundTransparency = 1, Size = UDim2.new(0, window.NavWidth, 1, 0), ClipsDescendants = true, ZIndex = 2 })
	local navScroll = cn("ScrollingFrame", { Parent = window.Nav, BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.new(1, -12, 1, -46), Position = UDim2.fromOffset(6, 6), ScrollBarThickness = 0,
		ElasticBehavior = Enum.ElasticBehavior.Never, AutomaticCanvasSize = Enum.AutomaticSize.Y })
	window.NavList = cn("Frame", { Parent = navScroll, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0) })
	cn("UIListLayout", { Parent = window.NavList, Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder })
	local navFooter = cn("Frame", { Parent = window.Nav, BackgroundTransparency = 1, Position = UDim2.new(0, 6, 1, -40), Size = UDim2.new(1, -12, 0, 34) })
	local footLine = cn("Frame", { Parent = navFooter, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1) })
	bind(footLine, "BackgroundColor3", "RowBorder")
	local footLogo = brandImage(navFooter, 18)
	footLogo.Position = UDim2.fromOffset(2, 9)
	local footName = cn("TextLabel", { Parent = navFooter, BackgroundTransparency = 1, Position = UDim2.fromOffset(26, 9),
		Size = UDim2.new(1, -70, 0, 16), Font = Enum.Font.GothamBold, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, Text = "Hound Hub" })
	bind(footName, "TextColor3", "TextPrimary")
	local footVersion = cn("TextLabel", { Parent = navFooter, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 10), Size = UDim2.fromOffset(44, 14), Font = Enum.Font.Gotham,
		TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, Text = "v" .. Library.Version })
	bind(footVersion, "TextColor3", "TextDisabled")
	window.DrawerOverlay = cn("TextButton", { Parent = body, AutoButtonColor = false, Text = "",
		BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 1 })
	window.DrawerOverlay.MouseButton1Click:Connect(function() window:SetDrawer(false) end)
	window.Content = cn("Frame", { Parent = body, BackgroundTransparency = 1,
		Position = UDim2.fromOffset(window.NavWidth, 0), Size = UDim2.new(1, -window.NavWidth, 1, 0), ClipsDescendants = true })
	window.NavToggle.MouseButton1Click:Connect(function() window:SetDrawer(not window.DrawerOpen) end)
	local ASPECT = 4 / 3
	local function applyLayout()
		local vp = viewport()
		if vp.X < 10 or vp.Y < 10 then return end
		window.Mobile = vp.X < 700 or vp.Y < 500
		if window.Mobile then
			local padX, padY = 14, 14
			local availW = math.max(vp.X - padX * 2, 260)
			local availH = math.max(vp.Y - padY * 2, 200)
			local w, h = availW, availH
			if availW / availH > ASPECT then h = availH w = h * ASPECT else w = availW h = w / ASPECT end
			frame.Size = UDim2.fromOffset(w, h)
			frame.Position = UDim2.fromScale(0.5, 0.5)
			local open = window.DrawerOpen == true
			window.Nav.Visible = open
			window.Nav.Position = UDim2.fromOffset(open and 0 or -window.NavWidth, 0)
			window.Content.Position = UDim2.fromOffset(0, 0)
			window.Content.Size = UDim2.new(1, 0, 1, 0)
			window.NavToggle.Visible = true
		else
			local maxW = math.min(opts.Size and opts.Size.X or 800, vp.X - 60)
			local maxH = math.min(opts.Size and opts.Size.Y or 600, vp.Y - 60)
			local w, h = maxW, maxH
			if maxW / maxH > ASPECT then h = maxH w = h * ASPECT else w = maxW h = w / ASPECT end
			window.FullHeight = h
			frame.Size = UDim2.fromOffset(w, h)
			frame.Position = UDim2.fromScale(0.5, 0.5)
			window.Nav.Visible = true
			window.Nav.Position = UDim2.fromOffset(0, 0)
			window.Content.Position = UDim2.fromOffset(window.NavWidth, 0)
			window.Content.Size = UDim2.new(1, -window.NavWidth, 1, 0)
			window.NavToggle.Visible = false
			window.DrawerOverlay.Visible = false
		end
	end
	window._viewportConn = Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyLayout)
	applyLayout()
	task.defer(applyLayout)
	local firstFrame = RunService.RenderStepped:Connect(function()
		applyLayout()
		firstFrame:Disconnect()
	end)
	table.insert(Library.Windows, window)
	return window
end
function Library:Notify(opts)
	local layers = ensureLayers()
	local vp = viewport()
	local width = math.min(300, vp.X - 32)
	local card = cn("Frame", { Parent = layers.Snack, AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromOffset(width, 0), BackgroundColor3 = SNACK_BG, ZIndex = 51 })
	cn("UICorner", { Parent = card, CornerRadius = UDim.new(0, 7) })
	cn("UIStroke", { Parent = card, Thickness = 1, Color = SNACK_BORDER })
	local body = cn("Frame", { Parent = card, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, -24, 0, 0), Position = UDim2.fromOffset(12, 10) })
	cn("UIListLayout", { Parent = body, Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder })
	cn("UIPadding", { Parent = body, PaddingBottom = UDim.new(0, 2) })
	local head = cn("Frame", { Parent = body, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0) })
	cn("UIListLayout", { Parent = head, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder })
	if opts.Icon ~= false then brandImage(head, 20) end
	cn("TextLabel", { Parent = head, BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, Text = opts.Title or "Notification",
		TextColor3 = Color3.fromRGB(244, 240, 238), AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, -28, 0, 0) })
	if opts.Description then
		cn("TextLabel", { Parent = body, BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Text = opts.Description,
			TextColor3 = Color3.fromRGB(172, 162, 160), AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0) })
	end
	card.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			card:Destroy()
		end
	end)
	later(opts.Duration or 3, function()
		if card and card.Parent then card:Destroy() end
	end)
end
function Library:Destroy()
	for th in pairs(Library._tasks) do task.cancel(th) end
	table.clear(Library._tasks)
	for _, conn in pairs(Library._connections) do conn:Disconnect() end
	table.clear(Library._connections)
	table.clear(Library._popups)
	table.clear(Library._registry)
	for _, w in ipairs(Library.Windows) do w.Frame:Destroy() end
	table.clear(Library.Windows)
	if Library._layers then
		Library._layers.Gui:Destroy()
		Library._layers = nil
	end
end

local WindowRef = nil
local CleanupHooks = {}
local stopAllActiveLogic = nil
local DISCORD_INVITE = "BloodHoundsForever"
local M1_GARAND_NAME = "M1 Garand"
local RPG_NAME = "RPG"
local PLANE_TYPES = { Bomber = true, ["Large Bomber"] = true, ["Torpedo Bomber"] = true }
local SHIP_PRIORITY = { Carrier = 1, Battleship = 2, Submarine = 3, ["Heavy Cruiser"] = 4, Cruiser = 5, Destroyer = 6 }
local FULL_SHIP_PRIORITY = { Carrier = 1, Battleship = 2, ["Heavy Cruiser"] = 3, Cruiser = 4, Destroyer = 5, Submarine = 6 }
local LEAD_PROFILES = {
	Default = { leadScale = 1, latencyPad = 0.06, heightBias = 0 },
	Carrier = { leadScale = 1.02, latencyPad = 0.08, heightBias = 10 },
	Battleship = { leadScale = 1.03, latencyPad = 0.08, heightBias = 8 },
	Submarine = { leadScale = 1.1, latencyPad = 0.09, heightBias = 3 },
	["Heavy Cruiser"] = { leadScale = 1.07, latencyPad = 0.08, heightBias = 6 },
	Cruiser = { leadScale = 1.09, latencyPad = 0.085, heightBias = 5 },
	Destroyer = { leadScale = 1.14, latencyPad = 0.095, heightBias = 4 },
}
local TEAM_BASE_POSITIONS = { Japan = Vector3.new(29, 59, -8133), USA = Vector3.new(11, 92, 8137) }
local PLANE_THRESHOLDS = {
	["Large Bomber"] = { bombs = 0, bullets = 0, fuel = 10, hp = 200 },
	Bomber = { bombs = 0, bullets = 0, fuel = 10, hp = 100 },
	["Torpedo Bomber"] = { bombs = 0, bullets = 0, fuel = 10, hp = 100 },
}
local ISLAND_CODES = { "A", "B", "C" }
local COLORS = {
	AirTarget = Color3.fromRGB(120, 220, 255), SurfaceTarget = Color3.fromRGB(255, 170, 85),
	Harbor = Color3.fromRGB(255, 205, 110), Island = Color3.fromRGB(95, 220, 255),
	ShipDefault = Color3.fromRGB(255, 120, 90), White = Color3.fromRGB(255, 255, 255),
	Red = Color3.fromRGB(255, 0, 0), Green = Color3.fromRGB(0, 255, 0),
	Blue = Color3.fromRGB(0, 0, 255), Water = Color3.fromRGB(128, 187, 219),
}
local VEHICLE_DEFS = {
	{ name = "Bomber", cost = 2, class = "plane" },
	{ name = "Torpedo Bomber", cost = 3, class = "plane" },
	{ name = "Large Bomber", cost = 5, class = "plane" },
	{ name = "Submarine", cost = 5, class = "ship" },
	{ name = "Destroyer", cost = 4, class = "ship" },
	{ name = "Cruiser", cost = 5, class = "ship" },
	{ name = "Heavy Cruiser", cost = 7, class = "ship" },
	{ name = "Battleship", cost = 16, class = "capital" },
	{ name = "Carrier", cost = 16, class = "capital" },
}
local Config = {
	selectedPlayer = nil, loopKillEnabled = false, viewingTarget = false,
	silentAimEnabled = false, silentAimDistance = 130, rifleKillAuraEnabled = false,
	fastShootMobileState = false, fastShootPCState = false, rpgAuraEnabled = false,
	autoRPG_PC_State = false, targetPriority = "Closest", shipTargetPriority = "Nearest",
	walkSpeed = 16, jumpPower = 50, vflySpeed = 150, flingMode = "Spin",
	targetOwnTeam = false, autoJump = false,
}
Global.NavalWarfareConfig = Config
local Runtime = {
	autoKillOppositeTeam = false, antiAirShoot = false, antiAirAimOnly = false,
	autoIslands = false, autoShips = false, fullAutoDefense = false, autoReloadPlane = false,
	vflyEnabled = false, autoDestroyPlanes = false, autoCaptureEnabled = false,
	autoCaptureRunning = false, captureGeneration = 0, godMode = false,
	respawnWhereDied = false, fastShootMobileConnected = false, playerESP = false,
	espBoxes = false, espNameTags = false, espHealthText = false, espDistance = false,
	espTracers = false, espTeamColors = false, enemyESP = false, espSubmarinesOnly = false,
	espShipsOnly = false, espPlanesOnly = false, autoBuyVehicle = false,
}
local function killPreviousUI()
	if Global.NavalWarfareCleanup then
		pcall(function() Global.NavalWarfareCleanup:Fire() end)
		pcall(function() Global.NavalWarfareCleanup:Destroy() end)
		Global.NavalWarfareCleanup = nil
	end
	local roots = {}
	if Env.gethui then
		local ok, p = pcall(Env.gethui)
		if ok and p then table.insert(roots, p) end
	end
	local okC, cg = pcall(function() return game:GetService("CoreGui") end)
	if okC and cg then table.insert(roots, cg) end
	local okP, pg = pcall(function() return LocalPlayer:FindFirstChildOfClass("PlayerGui") end)
	if okP and pg then table.insert(roots, pg) end
	for _, root in ipairs(roots) do
		for _, d in ipairs(root:GetChildren()) do
			if d.Name == "HoundHub" or d.Name == "HoundHubProbe" then
				pcall(function() d:Destroy() end)
			end
		end
	end
end
killPreviousUI()
local CleanupEvent = Instance.new("BindableEvent")
CleanupEvent.Name = "NavalWarfareCleanup"
Global.NavalWarfareCleanup = CleanupEvent
local scriptActive = true
local cleanupCallbacks = {}
local function runCleanupCallbacks()
	for _, callback in ipairs(cleanupCallbacks) do pcall(callback) end
end
CleanupEvent.Event:Connect(function()
	scriptActive = false
	runCleanupCallbacks()
end)
local function addCleanupCallback(callback) table.insert(cleanupCallbacks, callback) end
local function trackConnection(connection)
	CleanupEvent.Event:Connect(function()
		pcall(function() connection:Disconnect() end)
	end)
end
local function notify(title, content, duration)
	if Library and type(Library.Notify) == "function" then
		Library:Notify({ Title = title, Description = content, Duration = duration or 4 })
	end
end
local function setToggleWidget(widget, value, silent)
	if widget and type(widget.Get) == "function" and type(widget.Set) == "function" and widget:Get() ~= value then
		widget:Set(value, silent)
	end
end
local function refreshDropdownValues(valuesTable, newOptions, dropdown, currentSelection)
	table.clear(valuesTable)
	for _, v in ipairs(newOptions) do table.insert(valuesTable, v) end
	if dropdown and not table.find(valuesTable, currentSelection) then
		local fallback = valuesTable[1] or "None"
		dropdown:Set(fallback, true)
		return fallback
	end
	return currentSelection
end
local function getLocalCharacter() return LocalPlayer.Character end
local function getLocalHumanoid()
	local character = getLocalCharacter()
	return character and character:FindFirstChildOfClass("Humanoid")
end
local function getLocalRootPart()
	local character = getLocalCharacter()
	return character and character:FindFirstChild("HumanoidRootPart")
end
local function getLocalRootPosition()
	local root = getLocalRootPart()
	return root and root.Position or nil
end
local function getLocalPivotPosition()
	local character = getLocalCharacter()
	if character then
		local ok, pivot = pcall(function() return character:GetPivot() end)
		if ok then return pivot.Position end
	end
	return getLocalRootPosition()
end
local function getCoins()
	local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
	local coin = leaderstats and leaderstats:FindFirstChild("Coin")
	return coin and coin.Value or 0
end
local function getInstancePosition(instance)
	if not instance then return nil end
	if instance:IsA("BasePart") then return instance.Position end
	if instance:IsA("Model") then
		local primary = instance.PrimaryPart or instance:FindFirstChild("HumanoidRootPart") or instance:FindFirstChildWhichIsA("BasePart")
		if primary then return primary.Position end
		local ok, pivot = pcall(function() return instance:GetPivot() end)
		if ok then return pivot.Position end
	end
	return nil
end
local function getPrimaryCarrierModel(instance)
	if not instance then return nil end
	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	if not humanoid or not humanoid.SeatPart then return instance end
	local current = humanoid.SeatPart.Parent
	local result = nil
	while current do
		if current:IsA("Model") and current.PrimaryPart then result = current end
		current = current.Parent
	end
	return result or instance
end
local function getCharacterOrVehicleCFrame(character)
	local carrier = getPrimaryCarrierModel(character)
	if carrier and carrier.PrimaryPart then return carrier:GetPrimaryPartCFrame() end
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return root and root.CFrame or nil
end
local function setCharacterOrVehicleCFrame(character, cframe)
	if not character or not cframe then return end
	local carrier = getPrimaryCarrierModel(character)
	if carrier and carrier.PrimaryPart then
		carrier:SetPrimaryPartCFrame(cframe)
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root then root.CFrame = cframe end
end
local function setLocalCharacterCFrame(cframe) setCharacterOrVehicleCFrame(getLocalCharacter(), cframe) end
local function getLocalTeamName()
	local team = LocalPlayer.Team
	return team and team.Name or nil
end
local function getEnemyTeamName()
	local teamName = getLocalTeamName()
	if teamName == "Japan" then return "USA" end
	if teamName == "USA" then return "Japan" end
	return nil
end
local function getModelTeamValue(model)
	local team = model and model:FindFirstChild("Team")
	return team and team.Value or nil
end
local function isEnemyModel(model)
	local teamValue = getModelTeamValue(model)
	local localTeam = getLocalTeamName()
	return teamValue ~= nil and teamValue ~= localTeam
end
local function getModelOwnerName(model)
	local owner = model and model:FindFirstChild("Owner")
	if owner and type(owner.Value) == "string" and owner.Value ~= "" then return owner.Value end
	return nil
end
local function getShipDisplayName(model)
	local ownerName = getModelOwnerName(model)
	if ownerName and model then return ownerName .. "'s " .. model.Name end
	return model and model.Name or "Enemy Ship"
end
local function getPlayerFromModelOwner(model)
	local owner = model and model:FindFirstChild("Owner")
	if not owner then return nil end
	local value = owner.Value
	if typeof(value) == "Instance" and value:IsA("Player") then return value end
	if type(value) == "string" and value ~= "" then return Players:FindFirstChild(value) end
	return nil
end
local function isPlaneOwnedByPlayer(model, player)
	local owner = model and model:FindFirstChild("Owner")
	if not owner then return false end
	local value = owner.Value
	return value == player or value == player.Name or value == player.DisplayName
end
local function getVehicleModelFromSeat(seat) return seat and seat:FindFirstAncestorOfClass("Model") end
local function getSupportedPlaneFromSeat(seat)
	local model = getVehicleModelFromSeat(seat)
	if model and PLANE_TYPES[model.Name] then return model, model.Name end
	return nil, model and model.Name or nil
end
local function getPlaneForPlayer(player)
	local character = player and player.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.SeatPart then
			local current = humanoid.SeatPart
			while current do
				if current:IsA("Model") and PLANE_TYPES[current.Name] then return current end
				current = current.Parent
			end
		end
	end
	for _, child in ipairs(Workspace:GetChildren()) do
		if child:IsA("Model") and PLANE_TYPES[child.Name] and isPlaneOwnedByPlayer(child, player) then
			return child
		end
	end
	return nil
end
local function isInSupportedPlane()
	local character = getLocalCharacter()
	if not character then return false end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or not humanoid.SeatPart then return false end
	local model = getVehicleModelFromSeat(humanoid.SeatPart)
	return model ~= nil and PLANE_TYPES[model.Name] == true
end
local function hasRPG()
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	local character = getLocalCharacter()
	if backpack and backpack:FindFirstChild(RPG_NAME) then return true end
	if character and character:FindFirstChild(RPG_NAME) then return true end
	return false
end
local function getLocalM1Garand()
	local character = getLocalCharacter()
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	if backpack and backpack:FindFirstChild(M1_GARAND_NAME) then return backpack:FindFirstChild(M1_GARAND_NAME) end
	return character and character:FindFirstChild(M1_GARAND_NAME)
end
local function fireRifleRay(head) RemoteEvent:FireServer("shootRifle", "", { head }) end
local function fireRifleHit(humanoid) RemoteEvent:FireServer("shootRifle", "hit", { humanoid }) end
local function fireRPGAt(position) RemoteEvent:FireServer("fireRPG", { position }) end
local function fireTeleport(locationName) RemoteEvent:FireServer("Teleport", { locationName, "", 0 }) end
local function fireChangeGun(gunId) RemoteEvent:FireServer("ChangeGun", { [1] = gunId }) end
local function fireShootTrue() RemoteEvent:FireServer("shoot", { [1] = true }) end
local function fireBombTrue() RemoteEvent:FireServer("bomb", { [1] = true }) end
local function fireShootFalse() RemoteEvent:FireServer("shoot", { [1] = false }) end
local function fireBombFalse() RemoteEvent:FireServer("bomb", { [1] = false }) end
local function fireAim(position) RemoteEvent:FireServer("aim", { position }) end
local function copyDiscordInvite()
	if Env.setclipboard then
		pcall(Env.setclipboard, DISCORD_INVITE)
		notify("Discord", "Invite copied.", 4)
		return
	end
	notify("Discord", DISCORD_INVITE, 8)
end
local function giveTool(toolName)
	local source = Workspace:FindFirstChild(toolName) or ReplicatedStorage:FindFirstChild(toolName)
	if source then source:Clone().Parent = LocalPlayer.Backpack end
end
local function removeTouchTransmitters(model)
	if not model then return end
	for _, descendant in pairs(model:GetDescendants()) do
		if descendant:IsA("TouchTransmitter") then descendant:Destroy() end
	end
end
local function getIslandModel(code)
	for _, child in ipairs(Workspace:GetChildren()) do
		if child.Name == "Island" and child:IsA("Model") then
			local islandCode = child:FindFirstChild("IslandCode")
			if islandCode and islandCode.Value == code then return child end
		end
	end
	return nil
end
local function getFlagPart(island, partName)
	local flag = island and island:FindFirstChild("Flag")
	local part = flag and flag:FindFirstChild(partName)
	if part and part:IsA("BasePart") then return part end
	return nil
end
local function getFlagPad(island) return getFlagPart(island, "FlagPad") end
local function getFlagPost(island) return getFlagPart(island, "Post") end
local function getIslandLabel(island)
	local islandCode = island and island:FindFirstChild("IslandCode")
	if islandCode then return "Island " .. tostring(islandCode.Value) end
	return "Enemy Island"
end
local function getShipPrimaryPosition(model)
	if not model then return nil end
	if model.PrimaryPart then return model.PrimaryPart.Position end
	local ok, cf = pcall(function() return model:GetModelCFrame() end)
	if ok and cf then return cf.Position end
	return getInstancePosition(model)
end
local padCache, padCacheTime = nil, 0
local function scanVehiclePads()
	local now = tick()
	if padCache and (now - padCacheTime) < 1 then return padCache end
	local result = { plane = {}, ship = {}, capital = {}, all = {} }
	local teamName = getLocalTeamName() or "USA"
	local dockName = teamName == "Japan" and "JapanDock" or "USDock"
	local dock = Workspace:FindFirstChild(dockName)
	local vehicleSP = dock and dock:FindFirstChild("VehicleSP")
	if not vehicleSP and dock then
		for _, child in ipairs(dock:GetChildren()) do
			if child.Name:match("SP$") then vehicleSP = child break end
		end
	end
	if vehicleSP then
		for _, child in ipairs(vehicleSP:GetChildren()) do
			local lower = child.Name:lower()
			local isPad = child:IsA("BasePart") or child:IsA("Model") or child:IsA("Folder")
			if isPad then
				table.insert(result.all, child)
				if lower:find("air") or lower:find("plane") or lower:find("runway") then
					table.insert(result.plane, child)
				elseif lower:find("carrier") or lower:find("battleship") or lower:find("capital") or lower:find("big") then
					table.insert(result.capital, child)
				else
					table.insert(result.ship, child)
				end
			end
		end
	end
	padCache = result
	padCacheTime = now
	return result
end
local function candidatePadsFor(class)
	local pads = scanVehiclePads()
	local order, seen = {}, {}
	local function addList(list)
		for _, pad in ipairs(list) do
			if not seen[pad] then seen[pad] = true table.insert(order, pad) end
		end
	end
	if class == "plane" then addList(pads.plane) addList(pads.all)
	elseif class == "capital" then addList(pads.capital) addList(pads.ship) addList(pads.all)
	else addList(pads.ship) addList(pads.all) end
	return order
end
local function ownsVehicleModel(model)
	local owner = model:FindFirstChild("Owner", true)
	if not owner then return false end
	local value = owner.Value
	return value == LocalPlayer.Name or value == LocalPlayer or value == LocalPlayer.DisplayName
end
local function findOwnedVehicle(vehicleName)
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("Model") and obj.Name == vehicleName and ownsVehicleModel(obj) then return obj end
	end
	return nil
end
local function waitForOwnedVehicle(vehicleName, timeout)
	local deadline = tick() + timeout
	while tick() < deadline do
		local owned = findOwnedVehicle(vehicleName)
		if owned then return owned end
		task.wait(0.1)
	end
	return findOwnedVehicle(vehicleName)
end
local function getSeatedOwnedVehicle(vehicleName)
	local character = getLocalCharacter()
	if not character then return nil end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or not humanoid.SeatPart then return nil end
	local model = humanoid.SeatPart:FindFirstAncestorOfClass("Model")
	if model and model.Name == vehicleName and ownsVehicleModel(model) then return model end
	return nil
end
local function getVehicleSeat(model)
	if not model then return nil end
	local priority, vehicleSeat, anySeat = nil, nil, nil
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("VehicleSeat") or d:IsA("Seat") then
			local lower = d.Name:lower()
			if lower:find("drive") or lower:find("control") or lower:find("pilot") or lower:find("captain") or lower:find("steer") or lower:find("fly") then
				priority = d
			end
			if not vehicleSeat and d:IsA("VehicleSeat") then vehicleSeat = d end
			if not anySeat then anySeat = d end
		end
	end
	return priority or vehicleSeat or anySeat
end
local function waitForVehicleSeat(model, timeout)
	local deadline = tick() + timeout
	while tick() < deadline do
		if not model or not model.Parent then return nil end
		local seat = getVehicleSeat(model)
		if seat and seat.Parent then return seat end
		task.wait(0.1)
	end
	return nil
end
local function sitInVehicle(model)
	local character = getLocalCharacter()
	if not character then return false end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root then return false end
	if humanoid.SeatPart then
		local seatedModel = humanoid.SeatPart:FindFirstAncestorOfClass("Model")
		if seatedModel == model then return true end
	end
	for _ = 1, 12 do
		if not model or not model.Parent then return false end
		local seat = getVehicleSeat(model)
		if not seat or not seat.Parent then seat = waitForVehicleSeat(model, 1.5) end
		if seat and seat.Parent then
			root.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
			task.wait(0.06)
			pcall(function() seat:Sit(humanoid) end)
			task.wait(0.22)
			if humanoid.SeatPart == seat or seat.Occupant == humanoid then return true end
		end
		task.wait(0.18)
	end
	return false
end
local function fireVSpawn(pad, vehicleName, cost)
	local teamName = getLocalTeamName() or "USA"
	local payloads = {
		{ pad, vehicleName, cost }, { pad, vehicleName },
		{ pad.Name, vehicleName, cost }, { pad, vehicleName, teamName },
	}
	for _, payload in ipairs(payloads) do
		local ok = pcall(function() RemoteEvent:FireServer("VSpawn", payload) end)
		if ok and waitForOwnedVehicle(vehicleName, 0.9) then return true end
	end
	return false
end
local function spawnVehicle(def)
	local seated = getSeatedOwnedVehicle(def.name)
	if seated then return seated, "already seated" end
	local owned = findOwnedVehicle(def.name)
	if owned then return owned, "already owned" end
	local pads = candidatePadsFor(def.class)
	if #pads == 0 then return nil, "no pads found" end
	for _ = 1, 2 do
		for _, pad in ipairs(pads) do
			if fireVSpawn(pad, def.name, def.cost) then
				return waitForOwnedVehicle(def.name, 1.5), "spawned"
			end
		end
		task.wait(0.35)
	end
	local late = waitForOwnedVehicle(def.name, 1.5)
	if late then return late, "spawned (late)" end
	return nil, "spawn failed"
end
local lastVehicleModel = nil
local lastVehicleDef = VEHICLE_DEFS[4]
local autoBuyArmed = true
local autoBuyLastFire = 0
local autoBuyGeneration = 0
local function spawnAndSit(def)
	local model, reason = spawnVehicle(def)
	if not model then
		notify("Vehicle", def.name .. ": " .. tostring(reason), 4)
		return false
	end
	lastVehicleModel = model
	lastVehicleDef = def
	if sitInVehicle(model) then
		notify("Vehicle", def.name .. " ready | " .. tostring(reason), 4)
		return true
	end
	notify("Vehicle", def.name .. " spawned but seating failed", 4)
	return false
end
local function reSitLastVehicle()
	local model = lastVehicleModel
	if not model or not model.Parent then model = findOwnedVehicle(lastVehicleDef.name) end
	if not model then
		notify("Vehicle", "No vehicle to re-sit.", 3)
		return
	end
	lastVehicleModel = model
	if sitInVehicle(model) then
		notify("Vehicle", "Re-seated in " .. lastVehicleDef.name .. ".", 3)
	else
		notify("Vehicle", "Re-sit failed.", 3)
	end
end

WindowRef = Library:CreateWindow({
	Title = "Naval Warfare",
	Size = { X = 800, Y = 600 },
	Hotkey = Enum.KeyCode.RightShift,
	AppIcon = true,
})
do
	local layers = Library._layers
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Parent = layers.Gui
	toggleBtn.AutoButtonColor = false
	toggleBtn.Text = "NW"
	toggleBtn.AnchorPoint = Vector2.new(0, 1)
	toggleBtn.Position = UDim2.new(0, 14, 1, -14)
	toggleBtn.Size = UDim2.fromOffset(46, 46)
	toggleBtn.BackgroundColor3 = Color3.fromRGB(13, 12, 12)
	toggleBtn.Font = Enum.Font.GothamBold
	toggleBtn.TextSize = 14
	toggleBtn.TextColor3 = Color3.fromRGB(196, 43, 28)
	toggleBtn.ZIndex = 60
	local tCorner = Instance.new("UICorner")
	tCorner.CornerRadius = UDim.new(0, 10)
	tCorner.Parent = toggleBtn
	local tStroke = Instance.new("UIStroke")
	tStroke.Thickness = 1.5
	tStroke.Color = Color3.fromRGB(152, 20, 24)
	tStroke.Parent = toggleBtn
	toggleBtn.MouseButton1Click:Connect(function()
		WindowRef:SetVisible(not WindowRef.Frame.Visible)
	end)
	WindowRef.Frame:GetPropertyChangedSignal("Visible"):Connect(function()
		toggleBtn.Visible = not WindowRef.Frame.Visible
	end)
	toggleBtn.Visible = not WindowRef.Frame.Visible
end

local function buildInfo()
	local page = WindowRef:AddPage({ Name = "Info", Icon = "info", Description = "Hub status and community links." })
	local infoSection = page:AddSection("Information")
	infoSection:AddParagraph({ Text = "Hub Access: Active" })
	infoSection:AddParagraph({ Text = "Support and feedback: use the Discord button below to report problems or suggest changes." })
	local communitySection = page:AddSection("Community")
	communitySection:AddButton({ Name = "Copy Discord invite", Callback = copyDiscordInvite })
end
buildInfo()
local function buildTarget()
	local page = WindowRef:AddPage({ Name = "Target", Icon = "target", Description = "Select, track and eliminate specific players." })
	local targetInfoSection = page:AddSection("Target information")
	local teamCoinsLabel = targetInfoSection:AddLabel("Selected Target's Team: None\nSelected Target's Coins: 0")
	local winsScoreLabel = targetInfoSection:AddLabel("Selected Target's Wins: 0\nSelected Target's Score: 0")
	local function updateTargetLabels()
		local selectedName = Config.selectedPlayer
		if selectedName and selectedName ~= "None" then
			local selectedPlayer = Players:FindFirstChild(selectedName)
			if selectedPlayer then
				local teamName = selectedPlayer.Team and selectedPlayer.Team.Name or "None"
				local leaderstats = selectedPlayer:FindFirstChild("leaderstats")
				local coins, wins, score = 0, 0, 0
				if leaderstats then
					local coin = leaderstats:FindFirstChild("Coin")
					local win = leaderstats:FindFirstChild("Win")
					local sc = leaderstats:FindFirstChild("Score")
					if coin then coins = coin.Value end
					if win then wins = win.Value end
					if sc then score = sc.Value end
				end
				teamCoinsLabel.Set("Selected Target's Team: " .. teamName .. "\nSelected Target's Coins: " .. coins)
				winsScoreLabel.Set("Selected Target's Wins: " .. wins .. "\nSelected Target's Score: " .. score)
				return
			end
		end
		teamCoinsLabel.Set("Selected Target's Team: None\nSelected Target's Coins: 0")
		winsScoreLabel.Set("Selected Target's Wins: 0\nSelected Target's Score: 0")
	end
	task.spawn(function()
		while scriptActive do
			pcall(updateTargetLabels)
			task.wait(1)
		end
	end)
	local targetSelectSection = page:AddSection("Select your target")
	local function getPlayerOptions()
		local options = {}
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then table.insert(options, player.Name) end
		end
		return options
	end
	local targetValues = {}
	local targetDropdown = targetSelectSection:AddDropdown({
		Name = "Select Target", Values = targetValues,
		Callback = function(name) Config.selectedPlayer = name updateTargetLabels() end,
	})
	local function refreshTargetDropdown()
		local options = getPlayerOptions()
		if #options == 0 then table.insert(options, "None") end
		Config.selectedPlayer = refreshDropdownValues(targetValues, options, targetDropdown, Config.selectedPlayer)
		updateTargetLabels()
	end
	refreshTargetDropdown()
	trackConnection(Players.PlayerAdded:Connect(refreshTargetDropdown))
	trackConnection(Players.PlayerRemoving:Connect(refreshTargetDropdown))
	local function killSelectedTarget()
		local character = getLocalCharacter()
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not root then return end
		local rifle = getLocalM1Garand()
		if not rifle then
			notify("Target Error", "You don't have the M1 Garand.", 10)
			return
		end
		rifle.Parent = character
		local originalCFrame = root.CFrame
		local targetPlayer = Players:FindFirstChild(Config.selectedPlayer)
		if targetPlayer and targetPlayer.Team ~= LocalPlayer.Team then
			local targetCharacter = targetPlayer.Character
			local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
			local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")
			local targetHead = targetCharacter and targetCharacter:FindFirstChild("Head")
			if targetRoot and targetHumanoid and targetRoot.Position.Y > -126 then
				root.CFrame = targetRoot.CFrame + Vector3.new(0, 40, 0)
				while scriptActive and targetHumanoid.Health > 0 and Config.selectedPlayer == targetPlayer.Name do
					if targetHead then fireRifleRay(targetHead) end
					fireRifleHit(targetHumanoid)
					task.wait(0.1)
				end
			end
		end
		root.CFrame = originalCFrame
	end
	local killSection = page:AddSection("Equips gun automatically if not equipped.")
	killSection:AddButton({
		Name = "Kill Target",
		Callback = function()
			if Config.selectedPlayer == LocalPlayer.Name then return end
			local root = getLocalRootPart()
			if not root then return end
			local originalCFrame = root.CFrame
			fireTeleport("Harbour")
			task.wait(0.2)
			root.CFrame = originalCFrame
			task.wait(0.2)
			killSelectedTarget()
		end,
	})
	local loopKillSection = page:AddSection("Make sure to equip the rifle, will kill target when able to.")
	loopKillSection:AddToggle({
		Name = "Loop Kill Target",
		Callback = function(enabled)
			Config.loopKillEnabled = enabled
			if not enabled then return end
			local root = getLocalRootPart()
			if root then
				local originalCFrame = root.CFrame
				fireTeleport("Harbour")
				task.wait(0.2)
				root.CFrame = originalCFrame
			end
			task.spawn(function()
				while scriptActive and Config.loopKillEnabled do
					killSelectedTarget()
					task.wait(0.5)
				end
			end)
		end,
	})
	local targetUtilitiesSection = page:AddSection("Utilities")
	targetUtilitiesSection:AddButton({
		Name = "Fling Target",
		Callback = function()
			local targetPlayer = Players:FindFirstChild(Config.selectedPlayer)
			if not targetPlayer or not targetPlayer.Character then return end
			local targetHumanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
			if targetHumanoid and targetHumanoid.Sit then return end
			local localRoot = getLocalRootPart()
			if not localRoot then return end
			local bodyThrust = Instance.new("BodyThrust")
			bodyThrust.Name = "FlingForce"
			bodyThrust.Force = Vector3.new(9999, 9999, 9999)
			bodyThrust.Parent = localRoot
			local deadline = tick() + 12
			repeat
				local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
				if targetRoot then
					localRoot.CFrame = targetRoot.CFrame
					bodyThrust.Location = targetRoot.Position
				end
				RunService.Heartbeat:Wait()
			until (not targetPlayer.Character) or (not targetPlayer.Character:FindFirstChild("Head")) or tick() > deadline
			bodyThrust:Destroy()
		end,
	})
	targetUtilitiesSection:AddButton({
		Name = "Teleport to target",
		Callback = function()
			local targetPlayer = Players:FindFirstChild(Config.selectedPlayer)
			local targetRoot = targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
			local localRoot = getLocalRootPart()
			if targetRoot and localRoot then localRoot.CFrame = targetRoot.CFrame end
		end,
	})
	targetUtilitiesSection:AddToggle({
		Name = "View Target",
		Callback = function(enabled)
			Config.viewingTarget = enabled
			if enabled then
				task.spawn(function()
					while scriptActive and Config.viewingTarget do
						local targetPlayer = Players:FindFirstChild(Config.selectedPlayer)
						local targetHead = targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head")
						if targetHead then CurrentCamera.CameraSubject = targetHead end
						task.wait()
					end
				end)
				return
			end
			CurrentCamera.CameraSubject = getLocalCharacter()
		end,
	})
end
buildTarget()
local function buildCombat()
	local page = WindowRef:AddPage({ Name = "Combat", Icon = "bolt", Description = "Silent aim, rifle auras and fast fire." })
	local silentAimSection = page:AddSection("Silent aim, rifle only")
	silentAimSection:AddLabel("Must hold the gun out for aura to work.")
	local previousSilentTarget = nil
	local function getClosestEnemyForSilentAim()
		local closestPlayer, closestDistance = nil, Config.silentAimDistance
		local localRoot = getLocalRootPart()
		if not localRoot then return nil end
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
				local character = player.Character
				local root = character and character:FindFirstChild("HumanoidRootPart")
				if root then
					local distance = (root.Position - localRoot.Position).Magnitude
					if distance < closestDistance then
						closestPlayer = player
						closestDistance = distance
					end
				end
			end
		end
		return closestPlayer
	end
	local function updateSilentAimHighlight(targetPlayer)
		if previousSilentTarget and previousSilentTarget.Character then
			local oldHighlight = previousSilentTarget.Character:FindFirstChildOfClass("Highlight")
			if oldHighlight then oldHighlight:Destroy() end
		end
		if targetPlayer and targetPlayer.Character and Config.silentAimEnabled then
			local root = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
			if root then
				local highlight = Instance.new("Highlight")
				highlight.Adornee = targetPlayer.Character
				highlight.OutlineColor = COLORS.Blue
				highlight.OutlineTransparency = 0.5
				highlight.Parent = root
			end
		end
		previousSilentTarget = targetPlayer
	end
	local function fireSilentAimShot()
		if not Config.silentAimEnabled then
			updateSilentAimHighlight(nil)
			return
		end
		local targetPlayer = getClosestEnemyForSilentAim()
		updateSilentAimHighlight(targetPlayer)
		if targetPlayer and targetPlayer.Character then
			local head = targetPlayer.Character:FindFirstChild("Head")
			local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
			if head and humanoid then
				fireRifleRay(head)
				fireRifleHit(humanoid)
			end
		end
	end
	trackConnection(UIS.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and Config.silentAimEnabled then
			fireSilentAimShot()
		end
	end))
	silentAimSection:AddToggle({
		Name = "Silent Aim",
		Callback = function(enabled)
			Config.silentAimEnabled = enabled
			if not enabled then updateSilentAimHighlight(nil) end
		end,
	})
	silentAimSection:AddTextbox({
		Name = "Customize silent aim radius", Placeholder = "Default: 130",
		Callback = function(text)
			local radius = tonumber(text)
			if radius then
				if radius > 200 then
					notify("Warning!", "Radius too high. Defaulting to 130.", 5)
					Config.silentAimDistance = 130
					return
				end
				Config.silentAimDistance = radius
				notify("Radius Set", "Radius set to " .. radius .. " studs.", 5)
			end
		end,
	})
	CleanupHooks.SilentAim = function() updateSilentAimHighlight(nil) end
	local rifleSection = page:AddSection("Rifle")
	rifleSection:AddToggle({
		Name = "Rifle kill aura",
		Callback = function(enabled)
			Config.rifleKillAuraEnabled = enabled
			if enabled then
				task.spawn(function()
					while scriptActive and Config.rifleKillAuraEnabled do
						task.wait(0.3)
						for _, player in ipairs(Players:GetPlayers()) do
							if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character then
								local head = player.Character:FindFirstChild("Head")
								local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
								if head and humanoid and humanoid.Health > 0 then
									fireRifleRay(head)
									fireRifleHit(humanoid)
								end
							end
						end
					end
				end)
			end
		end,
	})
	local infiniteAmmoRunning = false
	rifleSection:AddButton({
		Name = "Infinite ammo - might need to execute twice",
		Callback = function()
			if infiniteAmmoRunning then
				notify("Infinite Ammo", "Already running.", 3)
				return
			end
			if not (Env.getgc and Env.setupvalue and Env.getinfo) then
				notify("Infinite Ammo", "Executor lacks reflection APIs.", 4)
				return
			end
			infiniteAmmoRunning = true
			task.spawn(function()
				while scriptActive do
					pcall(function()
						for _, object in pairs(Env.getgc()) do
							if type(object) == "function" then
								local info = Env.getinfo(object)
								if info and info.name == "reload" then
									pcall(Env.setupvalue, object, 4, math.huge)
								end
							end
						end
					end)
					task.wait(3)
				end
			end)
		end,
	})
	local fastShootSection = page:AddSection("Shoot rifle fast")
	fastShootSection:AddButton({
		Name = "Shoot rifle fast (mobile)",
		Callback = function()
			if Runtime.fastShootMobileConnected then
				notify("Fast Shoot", "Mobile controls are already connected.", 4)
				return
			end
			Runtime.fastShootMobileConnected = true
			trackConnection(UIS.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.Touch then
					Config.fastShootMobileState = true
					while scriptActive and Config.fastShootMobileState do
						local character = getLocalCharacter()
						local rifle = character and character:FindFirstChild(M1_GARAND_NAME)
						if rifle then rifle:Activate() end
						task.wait()
					end
				end
			end))
			trackConnection(UIS.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.Touch then
					Config.fastShootMobileState = false
				end
			end))
		end,
	})
	fastShootSection:AddToggle({
		Name = "Shoot rifle fast (PC - hold E)",
		Callback = function(enabled)
			Config.fastShootPCState = enabled
			if enabled then
				task.spawn(function()
					while scriptActive and Config.fastShootPCState do
						if UIS:IsKeyDown(Enum.KeyCode.E) then
							local character = getLocalCharacter()
							local rifle = character and character:FindFirstChild(M1_GARAND_NAME)
							if rifle then rifle:Activate() end
						end
						task.wait()
					end
				end)
			end
		end,
	})
	local autoKillSection = page:AddSection("Auto kill opposite team")
	autoKillSection:AddParagraph({ Text = "Sit in a minigun turret first. This targets enemy players who are not seated and resumes when they respawn." })
	local autoKillBringDistance = 10
	local function bringEnemyPlayerToLocal(player)
		local character = player.Character
		local enemyRoot = character and character:FindFirstChild("HumanoidRootPart")
		local localRoot = getLocalRootPart()
		if enemyRoot and localRoot then
			enemyRoot.CFrame = localRoot.CFrame * CFrame.new(0, 0, -autoKillBringDistance)
		end
	end
	trackConnection(Players.PlayerAdded:Connect(function(player)
		trackConnection(player.CharacterAdded:Connect(function()
			if Runtime.autoKillOppositeTeam and player.Team ~= LocalPlayer.Team then
				bringEnemyPlayerToLocal(player)
			end
		end))
	end))
	trackConnection(RunService.RenderStepped:Connect(function()
		if Runtime.autoKillOppositeTeam then
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
					bringEnemyPlayerToLocal(player)
				end
			end
			fireShootTrue()
		end
	end))
	autoKillSection:AddToggle({
		Name = "Auto kill opposite team",
		Callback = function(enabled) Runtime.autoKillOppositeTeam = enabled end,
	})
end
buildCombat()
local function buildRPG()
	local page = WindowRef:AddPage({ Name = "RPG", Icon = "rocket", Description = "RPG auras, ship destruction and dock siege." })
	local rpgStatusSection = page:AddSection("Status")
	local rpgStatusLabel = rpgStatusSection:AddLabel("RPG status: Checking...")
	local rpgAuraToggle, autoRpgToggle = nil, nil
	local function disableRpgFeaturesIfMissing(shouldNotify)
		local changed = false
		if Config.rpgAuraEnabled then
			Config.rpgAuraEnabled = false
			setToggleWidget(rpgAuraToggle, false, true)
			changed = true
		end
		if Config.autoRPG_PC_State then
			Config.autoRPG_PC_State = false
			setToggleWidget(autoRpgToggle, false, true)
			changed = true
		end
		if changed and shouldNotify then
			notify("RPG Required", "RPG not found anymore, so the RPG tab features were turned off.", 4)
		end
	end
	local function updateRPGStatusLabel()
		if hasRPG() then
			rpgStatusLabel.Set("RPG status: Ready")
		else
			rpgStatusLabel.Set("RPG status: Locked - get an RPG to use the controls below.")
			disableRpgFeaturesIfMissing(true)
		end
	end
	updateRPGStatusLabel()
	task.spawn(function()
		while scriptActive do
			pcall(updateRPGStatusLabel)
			task.wait(2)
		end
	end)
	local function requireRPG(featureName)
		if hasRPG() then return true end
		disableRpgFeaturesIfMissing(false)
		notify("RPG Required", "You need an RPG in your backpack or character to use " .. featureName .. ".", 4)
		return false
	end
	local rpgCombatSection = page:AddSection("Combat")
	rpgAuraToggle = rpgCombatSection:AddToggle({
		Name = "RPG kill aura",
		Callback = function(enabled)
			if enabled and not requireRPG("RPG kill aura") then
				Config.rpgAuraEnabled = false
				setToggleWidget(rpgAuraToggle, false, true)
				return
			end
			Config.rpgAuraEnabled = enabled
			if enabled then
				task.spawn(function()
					while scriptActive and Config.rpgAuraEnabled do
						if not hasRPG() then
							disableRpgFeaturesIfMissing(true)
							return
						end
						local closestPlayer, closestDistance = nil, math.huge
						local localRoot = getLocalRootPart()
						if localRoot then
							for _, player in ipairs(Players:GetPlayers()) do
								if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character then
									local root = player.Character:FindFirstChild("HumanoidRootPart")
									local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
									if root and humanoid and humanoid.Health > 0 and root.Position.Y >= -5 then
										local distance = (root.Position - localRoot.Position).Magnitude
										if distance < closestDistance then
											closestDistance = distance
											closestPlayer = player
										end
									end
								end
							end
						end
						if closestPlayer and closestPlayer.Character then
							local targetRoot = closestPlayer.Character:FindFirstChild("HumanoidRootPart")
							if targetRoot then fireRPGAt(targetRoot.Position) end
						end
						task.wait(0.5)
					end
				end)
			end
		end,
	})
	autoRpgToggle = rpgCombatSection:AddToggle({
		Name = "Auto shoot RPG (PC - hold E)",
		Callback = function(enabled)
			if enabled and not requireRPG("auto shoot RPG") then
				Config.autoRPG_PC_State = false
				setToggleWidget(autoRpgToggle, false, true)
				return
			end
			Config.autoRPG_PC_State = enabled
			if enabled then
				task.spawn(function()
					while scriptActive and Config.autoRPG_PC_State do
						if not hasRPG() then
							disableRpgFeaturesIfMissing(true)
							return
						end
						if UIS:IsKeyDown(Enum.KeyCode.E) then
							local character = getLocalCharacter()
							local rpg = character and character:FindFirstChild(RPG_NAME)
							if rpg then rpg:Activate() end
						end
						task.wait()
					end
				end)
			end
		end,
	})
	CleanupHooks.RPG = function()
		setToggleWidget(rpgAuraToggle, false, true)
		setToggleWidget(autoRpgToggle, false, true)
	end
	local rpgDestroySection = page:AddSection("Destroy Carriers/Battleships - Reset to stop")
	local function getEnemyCarrierNames()
		local names = {}
		for _, descendant in pairs(Workspace:GetDescendants()) do
			if descendant:IsA("Model") and descendant.Name == "Carrier" and isEnemyModel(descendant) then
				local ownerName = getModelOwnerName(descendant)
				table.insert(names, ownerName and (ownerName .. "'s Carrier") or "Carrier")
			end
		end
		if #names == 0 then table.insert(names, "None") end
		return names
	end
	local function getEnemyBattleshipNames()
		local names = {}
		for _, descendant in pairs(Workspace:GetDescendants()) do
			if descendant:IsA("Model") and descendant.Name == "Battleship" and isEnemyModel(descendant) then
				local ownerName = getModelOwnerName(descendant)
				table.insert(names, ownerName and (ownerName .. "'s Battleship") or "Battleship")
			end
		end
		if #names == 0 then table.insert(names, "None") end
		return names
	end
	local selectedCarrierName, selectedBattleshipName = "None", "None"
	local carrierValues, battleshipValues = {}, {}
	local carrierDropdown = rpgDestroySection:AddDropdown({
		Name = "Enemy carriers", Values = carrierValues,
		Callback = function(name) selectedCarrierName = name end,
	})
	local battleshipDropdown = rpgDestroySection:AddDropdown({
		Name = "Enemy Battleships", Values = battleshipValues,
		Callback = function(name) selectedBattleshipName = name end,
	})
	local function refreshRpgShipDropdowns()
		selectedCarrierName = refreshDropdownValues(carrierValues, getEnemyCarrierNames(), carrierDropdown, selectedCarrierName)
		selectedBattleshipName = refreshDropdownValues(battleshipValues, getEnemyBattleshipNames(), battleshipDropdown, selectedBattleshipName)
	end
	refreshRpgShipDropdowns()
	local function attackEnemyShipModel(modelType, displayName, heightOffset)
		if not requireRPG(modelType .. " attack") then return end
		if displayName == "None" then return end
		local character = getLocalCharacter()
		if not character or not character.PrimaryPart then return end
		local originalPosition = character.PrimaryPart.Position
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		for _, descendant in pairs(Workspace:GetDescendants()) do
			if descendant:IsA("Model") and descendant.Name == modelType and isEnemyModel(descendant) then
				local ownerName = getModelOwnerName(descendant)
				local comparisonName = modelType
				if ownerName then comparisonName = ownerName .. "'s " .. modelType end
				if comparisonName == displayName then
					local hp = descendant:FindFirstChild("HP")
					if not hp then return end
					while hp.Value > 0 and humanoid and humanoid.Health > 0 and hasRPG() do
						local targetPos = getShipPrimaryPosition(descendant)
						if targetPos then
							character:SetPrimaryPartCFrame(CFrame.new(targetPos + Vector3.new(0, heightOffset, 0)))
							fireRPGAt(targetPos)
						end
						task.wait(0.2)
					end
					character:SetPrimaryPartCFrame(CFrame.new(originalPosition))
					if hasRPG() then
						notify("Attack stopped", "The " .. modelType .. " has been destroyed or you died.", 5)
					else
						notify("RPG Required", modelType .. " attack stopped because your RPG is missing.", 4)
					end
					return
				end
			end
		end
	end
	rpgDestroySection:AddButton({ Name = "Attack carrier - equip RPG", Callback = function() attackEnemyShipModel("Carrier", selectedCarrierName, 4) end })
	rpgDestroySection:AddButton({ Name = "Attack Battleship - equip RPG", Callback = function() attackEnemyShipModel("Battleship", selectedBattleshipName, 9) end })
	trackConnection(Workspace.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("Model") and (descendant.Name == "Carrier" or descendant.Name == "Battleship") then
			task.wait(0.1)
			refreshRpgShipDropdowns()
		end
	end))
	trackConnection(Workspace.DescendantRemoving:Connect(function(descendant)
		if descendant:IsA("Model") and (descendant.Name == "Carrier" or descendant.Name == "Battleship") then
			task.wait(0.1)
			refreshRpgShipDropdowns()
		end
	end))
	local refreshSection = page:AddSection("Refresh carrier and battleship if it doesn't automatically.")
	refreshSection:AddButton({
		Name = "Refresh if not auto refreshed",
		Callback = function()
			if not requireRPG("the refresh controls") then return end
			refreshRpgShipDropdowns()
		end,
	})
	local siegeSection = page:AddSection("Dock Siege")
	siegeSection:AddParagraph({ Text = "Teleports you behind the enemy dock, locks you in place, rapid-fires RPG at it, and hijacks every missile to home into the dock." })
	local siegeLabel = siegeSection:AddLabel("Siege: off")
	local siegeActive = false
	local siegeBP, siegeBG, siegeFaceConn, siegeMissileConn = nil, nil, nil, nil
	local LARGE_ANCHORS = { Japan = Vector3.new(250, 100.6, -10246.3), USA = Vector3.new(250, 100.6, 10246.3) }
	local function getOwnDock()
		local t = getLocalTeamName()
		if t == "Japan" then return Workspace:FindFirstChild("JapanDock") end
		if t == "USA" then return Workspace:FindFirstChild("USDock") end
		return nil
	end
	local function getHarbourAnchorPosition()
		local exact = LARGE_ANCHORS[getLocalTeamName() or "USA"]
		if exact then return exact end
		local dock = getOwnDock()
		if dock then return dock:GetPivot().Position + Vector3.new(-70, 50, 0) end
		return nil
	end
	local function getEnemyDockMainBody()
		local dockName = getEnemyTeamName() == "USA" and "USDock" or "JapanDock"
		local dockModel = Workspace:FindFirstChild(dockName)
		if dockModel and dockModel:IsA("Model") then
			local mb = dockModel:FindFirstChild("MainBody", true)
			if mb and mb:IsA("BasePart") then return mb end
		end
		return nil
	end
	local function stopHarbourFloat()
		if siegeFaceConn then siegeFaceConn:Disconnect() siegeFaceConn = nil end
		if siegeBP then siegeBP:Destroy() siegeBP = nil end
		if siegeBG then siegeBG:Destroy() siegeBG = nil end
	end
	local function startHarbourFloat()
		stopHarbourFloat()
		local character = getLocalCharacter()
		if not character then return false end
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not hrp then return false end
		local target = getHarbourAnchorPosition()
		if not target then return false end
		siegeBP = Instance.new("BodyPosition")
		siegeBP.MaxForce = Vector3.new(1e8, 1e8, 1e8)
		siegeBP.P = 10000
		siegeBP.D = 750
		siegeBP.Position = target
		siegeBP.Parent = hrp
		siegeBG = Instance.new("BodyGyro")
		siegeBG.MaxTorque = Vector3.new(1e8, 1e8, 1e8)
		siegeBG.CFrame = hrp.CFrame
		siegeBG.Parent = hrp
		siegeFaceConn = RunService.Heartbeat:Connect(function()
			if not hrp or not hrp.Parent then
				stopHarbourFloat()
				return
			end
			local current = getHarbourAnchorPosition()
			if current and siegeBP then siegeBP.Position = current end
		end)
		return true
	end
	local function isNearHarbour()
		local character = getLocalCharacter()
		if not character then return false end
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not hrp then return false end
		local target = getHarbourAnchorPosition()
		if not target then return false end
		return (hrp.Position - target).Magnitude < 25
	end
	local function runAutoSequence()
		stopHarbourFloat()
		local plane = getSeatedOwnedVehicle("Large Bomber")
		if not plane then
			local def = nil
			for _, d in ipairs(VEHICLE_DEFS) do
				if d.name == "Large Bomber" then def = d end
			end
			if def then
				local model = spawnVehicle(def)
				if model then
					sitInVehicle(model)
					plane = model
				end
			end
		end
		if not plane or not plane.Parent then return false end
		if not startHarbourFloat() then return false end
		local arrived = false
		for _ = 1, 100 do
			if isNearHarbour() then arrived = true break end
			task.wait(0.05)
		end
		stopHarbourFloat()
		return arrived
	end
	siegeSection:AddButton({
		Name = "Auto Spawn + Sit + Float",
		Callback = function()
			task.spawn(function()
				local ok = runAutoSequence()
				siegeLabel.Set(ok and "Siege: anchored" or "Siege: failed")
			end)
		end,
	})
	local function makeMissileHoming(missile)
		if not missile or not missile.Parent then return end
		if missile:FindFirstChildOfClass("BodyVelocity") then return end
		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(1e7, 1e7, 1e7)
		bv.Parent = missile
		local bg = Instance.new("BodyGyro")
		bg.MaxTorque = Vector3.new(1e7, 1e7, 1e7)
		bg.Parent = missile
		local conn
		conn = RunService.Heartbeat:Connect(function()
			if not missile or not missile.Parent then
				if bv then bv:Destroy() end
				if bg then bg:Destroy() end
				if conn then conn:Disconnect() end
				return
			end
			local dockMain = getEnemyDockMainBody()
			if not dockMain then return end
			local dir = dockMain.Position - missile.Position
			local dist = dir.Magnitude
			if dist < 3 then conn:Disconnect() return end
			local speed = dist <= 600 and 500 or 25000
			bv.Velocity = dir.Unit * speed
			bg.CFrame = CFrame.new(missile.Position, missile.Position + dir.Unit)
		end)
	end
	local function isMissilePart(part)
		return part:IsA("BasePart") and part.Name:lower():find("missile") ~= nil
	end
	siegeSection:AddToggle({
		Name = "Dock Fly + RPG",
		Callback = function(enabled)
			siegeActive = enabled
			if enabled then
				if not siegeMissileConn then
					siegeMissileConn = Workspace.ChildAdded:Connect(function(child)
						if isMissilePart(child) then
							task.wait(0.01)
							makeMissileHoming(child)
						end
					end)
					trackConnection(siegeMissileConn)
				end
				task.spawn(function()
					while siegeActive and scriptActive do
						local character = getLocalCharacter()
						if character and character:FindFirstChild("HumanoidRootPart") then
							local dockMain = getEnemyDockMainBody()
							if dockMain then
								for _ = 1, 10 do
									pcall(function() RemoteEvent:FireServer("fireRPG", { dockMain.Position }) end)
								end
							end
						end
						task.wait(0.03)
					end
				end)
				siegeLabel.Set("Siege: active")
			else
				siegeLabel.Set("Siege: off")
			end
		end,
	})
	CleanupHooks.RPGSiege = function()
		siegeActive = false
		stopHarbourFloat()
		if siegeMissileConn then siegeMissileConn:Disconnect() siegeMissileConn = nil end
	end
end
buildRPG()
local function buildShipDefense()
	local page = WindowRef:AddPage({ Name = "Ship Defense", Icon = "shield", Description = "Unified auto-defense for ships, planes, islands and harbors." })
	local SD = {
		simpleTracking = {}, advancedTracking = {}, subCache = {}, domain = nil, gunId = nil,
		airTarget = nil, airPos = nil, airName = "", airColor = COLORS.AirTarget,
		surfTarget = nil, surfPos = nil, surfName = "", surfColor = COLORS.SurfaceTarget,
		simpleShip = nil, advShip = nil, line = nil, text = nil,
	}
	local toggles = { fullAuto = nil, antiAirShoot = nil, antiAirAim = nil, autoIslands = nil, autoShips = nil }
	local function clearAir() SD.airTarget, SD.airPos, SD.airName = nil, nil, "" end
	local function clearSurf() SD.surfTarget, SD.surfPos, SD.surfName = nil, nil, "" end
	local function setAir(target, position, color, label)
		SD.airTarget, SD.airPos, SD.airColor, SD.airName = target, position, color or COLORS.AirTarget, label or "Air Target"
	end
	local function setSurf(target, position, color, label)
		SD.surfTarget, SD.surfPos, SD.surfColor, SD.surfName = target, position, color or COLORS.ShipDefault, label or "Enemy Ship"
	end
	local function setDomain(domain)
		if domain == SD.domain then return end
		if SD.domain == "air" and domain ~= "air" then clearAir() end
		SD.domain = domain
	end
	local function changeGun(gunId)
		if gunId == SD.gunId then return end
		SD.gunId = gunId
		fireChangeGun(gunId)
	end
	local function removeDrawing()
		if SD.line then pcall(function() SD.line:Remove() end) SD.line = nil end
		if SD.text then pcall(function() SD.text:Remove() end) SD.text = nil end
	end
	local function initDrawing()
		if SD.line and SD.text then return true end
		if not Drawing or not Drawing.new then return false end
		local okLine, line = pcall(function() return Drawing.new("Line") end)
		local okText, text = pcall(function() return Drawing.new("Text") end)
		if not okLine or not okText then return false end
		line.Thickness = 2.5 line.Transparency = 1 line.Color = COLORS.SurfaceTarget line.Visible = false
		text.Size = 16 text.Center = true text.Outline = true text.Font = 2 text.Color = COLORS.SurfaceTarget text.Visible = false
		SD.line, SD.text = line, text
		return true
	end
	local function setDrawingVisible(visible)
		if SD.line then SD.line.Visible = visible end
		if SD.text then SD.text.Visible = visible end
	end
	local function isDead(target)
		if not target or not target.Parent then return true end
		if target:IsA("Model") then
			local hp = target:FindFirstChild("HP")
			if hp and hp.Value <= 0 then return true end
			local humanoid = target:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health <= 0 then return true end
		end
		return false
	end
	local function surfInvalid(target)
		if not target or not target.Parent then return true end
		if target:IsA("Model") then
			local hp = target:FindFirstChild("HP")
			if hp and hp.Value <= 0 then return true end
			if target.Name == "Island" or SHIP_PRIORITY[target.Name] then
				local enemyTeam = getEnemyTeamName()
				local targetTeam = getModelTeamValue(target)
				if not enemyTeam or not targetTeam or enemyTeam ~= targetTeam then return true end
			end
		end
		return false
	end
	local function activeVisual()
		local airActive = Runtime.antiAirShoot or Runtime.antiAirAimOnly or (Runtime.fullAutoDefense and SD.domain == "air")
		if airActive then
			if SD.airTarget and not isDead(SD.airTarget) then
				local position = getInstancePosition(SD.airTarget) or SD.airPos
				if position and SD.airName ~= "" then return position, SD.airColor, SD.airName end
			elseif SD.airPos and SD.airName ~= "" then
				return SD.airPos, SD.airColor, SD.airName
			end
		end
		if SD.surfTarget and not surfInvalid(SD.surfTarget) then
			local position = getInstancePosition(SD.surfTarget) or SD.surfPos
			if position and SD.surfName ~= "" then return position, SD.surfColor, SD.surfName end
		end
		return nil, nil, nil
	end
	local function formatAirName(player, plane)
		if plane then
			local label = plane.Name
			local owner = plane:FindFirstChild("Owner")
			if owner and type(owner.Value) == "string" and owner.Value ~= "" then
				label = owner.Value .. "'s " .. plane.Name
			elseif player then
				label = player.Name .. "'s " .. plane.Name
			end
			local hp = plane:FindFirstChild("HP")
			return string.format("%s | HP %s", label, hp and tostring(math.floor(hp.Value)) or "?")
		end
		if not player then return "Plane Target" end
		if player.DisplayName and player.DisplayName ~= player.Name then
			return string.format("%s (@%s)", player.DisplayName, player.Name)
		end
		return player.Name
	end
	local function closestEnemyPlayer(maxDistance, minAlt)
		local localRoot = getLocalRootPart()
		if not localRoot then return nil end
		local closest, closestDist = nil, maxDistance
		for _, player in ipairs(Players:GetPlayers()) do
			if player.Team ~= LocalPlayer.Team and player.Character then
				local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
				if humanoid and humanoid.Health > 0 then
					local root = player.Character:FindFirstChild("HumanoidRootPart")
					if root then
						local distance = (root.Position - localRoot.Position).Magnitude
						if distance < closestDist and root.Position.Y >= minAlt then
							closest = player
							closestDist = distance
						end
					end
				end
			end
		end
		return closest
	end
	local function predictPlayer(targetPlayer, speed, offset)
		local character = targetPlayer.Character
		local localRoot = getLocalRootPart()
		if not character or not character:FindFirstChild("Humanoid") or not localRoot then return nil end
		local root = character:FindFirstChild("HumanoidRootPart")
		if not root then return nil end
		local position = root.Position
		local velocity = root.Velocity
		local distance = (position - localRoot.Position).Magnitude
		if speed > 0 then
			position = position + velocity * (distance * 0.5 / (speed - offset))
		end
		return position
	end
	local function aimAir(maxDistance, speed, offset, minAlt)
		local targetPlayer = closestEnemyPlayer(maxDistance, minAlt)
		if targetPlayer then
			local predicted = predictPlayer(targetPlayer, speed, offset)
			if predicted then
				local plane = getPlaneForPlayer(targetPlayer)
				setAir(plane or targetPlayer.Character, predicted, COLORS.AirTarget, formatAirName(targetPlayer, plane))
				fireAim(predicted)
				return
			end
		end
		clearAir()
	end
	local function aimShootAir(maxDistance, speed, offset, minAlt)
		local targetPlayer = closestEnemyPlayer(maxDistance, minAlt)
		if targetPlayer then
			local predicted = predictPlayer(targetPlayer, speed, offset)
			if predicted and minAlt <= predicted.Y then
				local plane = getPlaneForPlayer(targetPlayer)
				setAir(plane or targetPlayer.Character, predicted, COLORS.AirTarget, formatAirName(targetPlayer, plane))
				fireShootTrue()
				fireBombTrue()
				return
			end
		end
		clearAir()
	end
	local function pruneTracking(tbl)
		for m in pairs(tbl) do
			if not m or m.Parent == nil then tbl[m] = nil end
		end
	end
	local function predictSimple(model)
		local position = model:GetPivot().Position
		local primary = model.PrimaryPart
		local velocity = nil
		if primary and primary:IsA("BasePart") then
			local av = primary.AssemblyLinearVelocity
			if av.Magnitude > 1 then velocity = av end
		end
		local now = tick()
		local last = SD.simpleTracking[model]
		if not velocity and last then
			velocity = (position - last.position) / math.max(now - last.time, 0.05)
		end
		SD.simpleTracking[model] = { position = position, time = now }
		if velocity then return position + velocity * 0.75 end
		return position
	end
	local function nearestEnemyIsland(localPosition)
		local enemyTeam = getEnemyTeamName()
		if not enemyTeam then return nil, math.huge end
		local best, bestDist = nil, math.huge
		for _, child in ipairs(Workspace:GetChildren()) do
			if child.Name == "Island" and child:IsA("Model") and getModelTeamValue(child) == enemyTeam then
				local distance = (child:GetPivot().Position - localPosition).Magnitude
				if distance < bestDist then
					bestDist = distance
					best = child
				end
			end
		end
		return best, bestDist
	end
	local function nearestHarborOrIsland(localPosition)
		local enemyTeam = getEnemyTeamName()
		if not enemyTeam then return nil, nil, math.huge, nil, nil end
		local dockName = enemyTeam ~= "USA" and "JapanDock" or "USDock"
		local dock = Workspace:FindFirstChild(dockName)
		local bestTarget, bestPos, bestDist, bestLabel, bestColor = nil, nil, math.huge, nil, nil
		if dock then
			local dockPos = dock:GetPivot().Position
			local dockDist = (localPosition - dockPos).Magnitude
			if dockDist <= 1600 then
				bestTarget, bestPos, bestDist = dock, dockPos, dockDist
				bestLabel, bestColor = enemyTeam .. " Harbor", COLORS.Harbor
			end
		end
		local island, islandDist = nearestEnemyIsland(localPosition)
		if island and islandDist <= 1600 and (not bestTarget or islandDist < bestDist) then
			bestTarget, bestPos, bestDist = island, island:GetPivot().Position, islandDist
			bestLabel, bestColor = getIslandLabel(island), COLORS.Island
		end
		return bestTarget, bestPos, bestDist, bestLabel, bestColor
	end
	local function fireBallisticAim(targetPosition)
		local localPosition = getLocalPivotPosition()
		if not localPosition then return end
		local distance = (localPosition - targetPosition).Magnitude
		local heightOffset = 0
		if distance > 600 then heightOffset = (distance - 600) * 0.06 end
		fireAim(targetPosition + Vector3.new(0, heightOffset, 0))
		fireBombFalse()
		fireShootFalse()
	end
	local function shootHarborOrIsland()
		local localPosition = getLocalPivotPosition()
		if not localPosition then return false end
		local target, position, _, label, color = nearestHarborOrIsland(localPosition)
		if target and position then
			setSurf(target, position, color, label)
			fireBallisticAim(position)
			return true
		end
		return false
	end
	local function simplePriority(shipName)
		if Config.shipTargetPriority == "Nearest" then return 0 end
		if Config.shipTargetPriority == "All" then return SHIP_PRIORITY[shipName] end
		if shipName == Config.shipTargetPriority then return 0 end
		return 10 + SHIP_PRIORITY[shipName]
	end
	local function nearestSimpleShip(localPosition)
		local enemyTeam = getEnemyTeamName()
		if not enemyTeam then
			SD.simpleShip = nil
			return nil, nil, math.huge
		end
		if SD.simpleShip and surfInvalid(SD.simpleShip) then SD.simpleShip = nil end
		pruneTracking(SD.simpleTracking)
		local bestModel, bestPos, bestDist = nil, nil, math.huge
		local bestPriority, bestScore = math.huge, math.huge
		for _, child in ipairs(Workspace:GetChildren()) do
			if child:IsA("Model") and SHIP_PRIORITY[child.Name] and getModelTeamValue(child) == enemyTeam then
				local hp = child:FindFirstChild("HP")
				if not hp or hp.Value > 0 then
					local priority = simplePriority(child.Name)
					local predicted = predictSimple(child)
					local distance = (localPosition - predicted).Magnitude
					if distance <= 1900 then
						local score = distance
						if child == SD.simpleShip then score = score - 175 end
						if priority < bestPriority or (priority == bestPriority and score < bestScore) then
							bestPriority, bestDist, bestScore, bestModel, bestPos = priority, distance, score, child, predicted
						end
					end
				end
			end
		end
		SD.simpleShip = bestModel
		return bestModel, bestPos, bestDist
	end
	local function shootShipsSimple()
		if Runtime.autoIslands and shootHarborOrIsland() then return true end
		local localPosition = getLocalPivotPosition()
		if not localPosition then return false end
		local target, position = nearestSimpleShip(localPosition)
		if target and position then
			setSurf(target, position, COLORS.ShipDefault, getShipDisplayName(target))
			fireBallisticAim(position)
			return true
		end
		return false
	end
	local function leadProfile(name) return LEAD_PROFILES[name] or LEAD_PROFILES.Default end
	local function clampVec(vector, maxMag)
		if vector.Magnitude > maxMag and maxMag > 0 then return vector.Unit * maxMag end
		return vector
	end
	local function leadTime(distance, name, speed, turnFactor)
		local profile = leadProfile(name)
		local distanceFactor = distance / 625
		local latencyPad = profile.latencyPad + math.clamp(speed / 360, 0, 0.12) + math.clamp(turnFactor or 0, 0, 1) * 0.14
		local rangePad = math.clamp(distance / 7000, 0, 0.22)
		return math.clamp((distanceFactor + latencyPad + rangePad) * profile.leadScale, 0.16, 2.45)
	end
	local function heightComp(distance, name, speed, turnFactor)
		local profile = leadProfile(name)
		local base = 0
		if distance > 450 then base = (distance - 450) * 0.048 end
		local speedPad = math.clamp(speed * 0.02, 0, 8)
		local turnPad = math.clamp(turnFactor or 0, 0, 1) * 7
		return base + speedPad + turnPad + profile.heightBias
	end
	local function predictAdvanced(model, localPosition)
		local position = model:GetPivot().Position
		local primary = model.PrimaryPart
		local velocity = nil
		if primary and primary:IsA("BasePart") then
			local av = primary.AssemblyLinearVelocity
			if av.Magnitude > 1 then velocity = av end
		end
		local now = tick()
		local last = SD.advancedTracking[model]
		local deltaTime = 0.05
		if last then deltaTime = math.max(now - last.time, 0.05) end
		if not velocity and last then
			velocity = (position - last.position) / deltaTime
		end
		velocity = velocity or Vector3.new()
		if last and last.velocity then
			velocity = last.velocity:Lerp(velocity, 0.35)
		end
		local acceleration = Vector3.new()
		if last and last.velocity then
			acceleration = clampVec((velocity - last.velocity) / deltaTime, 140)
		end
		local direction = nil
		if last and last.direction then direction = last.direction end
		if velocity.Magnitude > 1 then direction = velocity.Unit end
		local turnFactor = 0
		if last and last.direction and direction then
			turnFactor = math.clamp(1 - last.direction:Dot(direction), 0, 1)
		end
		SD.advancedTracking[model] = { position = position, time = now, velocity = velocity, direction = direction }
		local distance = 0
		if localPosition then distance = (localPosition - position).Magnitude end
		local lt = leadTime(distance, model.Name, velocity.Magnitude, turnFactor)
		local accelOffset = clampVec(acceleration * (0.5 * lt * lt), 140)
		return position + velocity * lt + accelOffset, { targetName = model.Name, targetSpeed = velocity.Magnitude, turnFactor = turnFactor }
	end
	local function fullPriority(shipName)
		if Config.shipTargetPriority == "Nearest" then return 0 end
		if Config.shipTargetPriority == "All" then return FULL_SHIP_PRIORITY[shipName] end
		if shipName == Config.shipTargetPriority then return 0 end
		return 10 + FULL_SHIP_PRIORITY[shipName]
	end
	local function seatOrPrimaryY(model)
		local ownerPlayer = getPlayerFromModelOwner(model)
		local ownerCharacter = ownerPlayer and ownerPlayer.Character
		local humanoid = ownerCharacter and ownerCharacter:FindFirstChildOfClass("Humanoid")
		local seat = humanoid and humanoid.SeatPart
		if seat and seat:IsDescendantOf(model) then return seat.Position.Y end
		local root = ownerCharacter and ownerCharacter:FindFirstChild("HumanoidRootPart")
		if root then return root.Position.Y end
		local primary = model and (model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart"))
		if primary then return primary.Position.Y end
		local ok, pivot = pcall(function() return model:GetPivot() end)
		if ok then return pivot.Position.Y end
		return nil
	end
	local function subTargetable(model)
		if not model or model.Name ~= "Submarine" or model.Parent == nil then
			return { targetable = true, y = nil }
		end
		local now = tick()
		local cached = SD.subCache[model]
		if cached and now - cached.time <= 0.35 then return cached end
		local y = seatOrPrimaryY(model)
		local result = { targetable = y == nil or y >= -11, y = y, time = now }
		SD.subCache[model] = result
		return result
	end
	local function nearestAdvancedShip(localPosition)
		local enemyTeam = getEnemyTeamName()
		if not enemyTeam then
			SD.advShip = nil
			return nil, nil, math.huge, nil
		end
		if SD.advShip and surfInvalid(SD.advShip) then SD.advShip = nil end
		pruneTracking(SD.advancedTracking)
		pruneTracking(SD.subCache)
		local bestModel, bestPos, bestDist, bestMeta = nil, nil, math.huge, nil
		local bestPriority, bestScore = math.huge, math.huge
		for _, child in ipairs(Workspace:GetChildren()) do
			if child:IsA("Model") and FULL_SHIP_PRIORITY[child.Name] and getModelTeamValue(child) == enemyTeam then
				local hp = child:FindFirstChild("HP")
				if not hp or hp.Value > 0 then
					local priority = fullPriority(child.Name)
					local subCheck = nil
					if child.Name == "Submarine" then subCheck = subTargetable(child) end
					if not subCheck or subCheck.targetable then
						local predicted, meta = predictAdvanced(child, localPosition)
						local distance = (localPosition - predicted).Magnitude
						if distance <= 1900 then
							local score = distance
							if child.Name == "Submarine" then score = score + 220 end
							if child == SD.advShip then score = score - 175 end
							if priority < bestPriority or (priority == bestPriority and score < bestScore) then
								bestPriority, bestDist, bestScore = priority, distance, score
								bestModel, bestPos, bestMeta = child, predicted, meta
							end
						end
					end
				end
			end
		end
		SD.advShip = bestModel
		return bestModel, bestPos, bestDist, bestMeta
	end
	local function closestSurfaceFull(localPosition)
		local hT, hP, hD, hL, hC = nearestHarborOrIsland(localPosition)
		local sT, sP, sD, sM = nearestAdvancedShip(localPosition)
		if hT and hP and (not sT or hD <= sD) then
			SD.advShip = nil
			return hT, hP, hL, hC, { targetName = hT.Name, targetSpeed = 0, turnFactor = 0 }
		end
		if sT and sP then
			return sT, sP, getShipDisplayName(sT), COLORS.ShipDefault, sM
		end
		return nil, nil, nil, nil, nil
	end
	local function closestAirFull(localPosition)
		local targetPlayer = closestEnemyPlayer(2400, 20)
		if not targetPlayer then return nil, nil, nil, math.huge, nil, math.huge end
		local predicted = predictPlayer(targetPlayer, 500, 50)
		if not predicted or predicted.Y < 20 then return nil, nil, nil, math.huge, nil, math.huge end
		local plane = getPlaneForPlayer(targetPlayer)
		local targetObject = plane or targetPlayer.Character
		local targetPosition = getInstancePosition(targetObject)
		if not targetPosition then
			local character = targetPlayer.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if root then targetPosition = root.Position end
		end
		local distance = math.huge
		if targetPosition then distance = (targetPosition - localPosition).Magnitude end
		return targetPlayer, plane, predicted, distance, targetPosition, distance
	end
	local function fireAdvanced(position, meta)
		local localPosition = getLocalPivotPosition()
		if not localPosition then return end
		local distance = (localPosition - position).Magnitude
		local tn, ts, tf = "Default", 0, 0
		if meta then
			tn = meta.targetName or "Default"
			ts = meta.targetSpeed or 0
			tf = meta.turnFactor or 0
		end
		local heightOffset = heightComp(distance, tn, ts, tf)
		fireAim(position + Vector3.new(0, heightOffset, 0))
		fireBombFalse()
		fireShootFalse()
	end
	local function fullAutoCycle()
		local localPosition = getLocalPivotPosition()
		if not localPosition then return false end
		local airPlayer, airPlane, airPos, airDist, airActual, airAdjusted = closestAirFull(localPosition)
		local surfTarget, surfPos, surfLabel, surfColor, surfMeta = closestSurfaceFull(localPosition)
		local hasAir = airPlayer ~= nil and airPos ~= nil
		local hasSurface = surfTarget ~= nil and surfPos ~= nil
		local surfDist = math.huge
		if hasSurface then surfDist = (surfPos - localPosition).Magnitude end
		local airBias = airAdjusted or airDist
		if hasAir and hasSurface then
			local airObjPos = getInstancePosition(airPlane or airPlayer.Character) or airPos
			if airActual and airObjPos and (airActual - airObjPos).Magnitude <= 150 then
				airBias = airBias + 260
			end
			if SD.domain == "surface" and SD.advShip and surfTarget == SD.advShip then
				surfDist = math.max(0, surfDist - 120)
			end
		end
		local chooseAir = false
		if Config.targetPriority == "Ships First" then
			chooseAir = not hasSurface and hasAir
		elseif Config.targetPriority == "Closest" then
			if not (hasSurface and hasAir) then chooseAir = hasAir else chooseAir = surfDist <= airBias end
		else
			if not (hasSurface and hasAir) then chooseAir = hasAir else chooseAir = surfDist <= airBias + 180 end
		end
		if chooseAir and hasAir then
			setDomain("air")
			changeGun(1)
			clearSurf()
			setAir(airPlane or airPlayer.Character, airPos, COLORS.AirTarget, formatAirName(airPlayer, airPlane))
			fireAim(airPos)
			fireShootTrue()
			fireBombTrue()
			return true
		end
		if hasSurface then
			setDomain("surface")
			changeGun(0)
			clearAir()
			setSurf(surfTarget, surfPos, surfColor, surfLabel)
			fireAdvanced(surfPos, surfMeta)
			return true
		end
		setDomain(nil)
		clearAir()
		clearSurf()
		return false
	end
	trackConnection(RunService.RenderStepped:Connect(function()
		local shouldDraw = Runtime.autoIslands or Runtime.autoShips or Runtime.antiAirShoot or Runtime.antiAirAimOnly or Runtime.fullAutoDefense
		if not shouldDraw then
			setDrawingVisible(false)
			return
		end
		if not initDrawing() then return end
		local position, color, label = activeVisual()
		if not position then
			setDrawingVisible(false)
			return
		end
		local screenPosition, visible = CurrentCamera:WorldToViewportPoint(position)
		if not visible or screenPosition.Z <= 0 then
			setDrawingVisible(false)
			return
		end
		color = color or COLORS.ShipDefault
		SD.line.From = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y - 55)
		SD.line.To = Vector2.new(screenPosition.X, screenPosition.Y)
		SD.line.Color = color
		SD.line.Visible = true
		SD.text.Text = string.format("%s | %d studs", label ~= "" and label or "Target", math.floor((CurrentCamera.CFrame.Position - position).Magnitude))
		SD.text.Position = Vector2.new(screenPosition.X, screenPosition.Y - 18)
		SD.text.Color = color
		SD.text.Visible = true
	end))
	local unifiedSection = page:AddSection("Unified Defense")
	unifiedSection:AddParagraph({ Text = "Drive any ship, choose a priority mode, then turn on Full auto defense. It swaps guns and handles planes, ships, islands, and harbors." })
	unifiedSection:AddDropdown({
		Name = "Target priority", Values = { "Closest", "Planes First", "Ships First" }, Default = "Closest",
		Callback = function(value) Config.targetPriority = value end,
	})
	toggles.fullAuto = unifiedSection:AddToggle({
		Name = "Full auto defense",
		Callback = function(enabled)
			Runtime.fullAutoDefense = enabled
			if enabled then
				setToggleWidget(toggles.antiAirShoot, false)
				setToggleWidget(toggles.antiAirAim, false)
				setToggleWidget(toggles.autoIslands, false)
				setToggleWidget(toggles.autoShips, false)
				clearAir()
				task.spawn(function()
					while Runtime.fullAutoDefense do
						task.wait(0.1)
						fullAutoCycle()
					end
				end)
				return
			end
			setDomain(nil)
			clearAir()
			clearSurf()
		end,
	})
	local antiAirSection = page:AddSection("Anti-Air Defense")
	antiAirSection:AddParagraph({ Text = "Use while seated in any turret. Targets aircraft within roughly 2,400 studs and leads moving targets." })
	toggles.antiAirShoot = antiAirSection:AddToggle({
		Name = "Auto aim and shoot planes",
		Callback = function(enabled)
			if enabled and Runtime.fullAutoDefense and toggles.fullAuto then setToggleWidget(toggles.fullAuto, false) end
			Runtime.antiAirShoot = enabled
			if enabled then
				task.spawn(function()
					while Runtime.antiAirShoot do
						task.wait(0.1)
						aimAir(2400, 500, 50, 20)
						task.wait(0.1)
						aimShootAir(2400, 500, 50, 20)
					end
				end)
				return
			end
			if not Runtime.antiAirAimOnly then clearAir() end
		end,
	})
	toggles.antiAirAim = antiAirSection:AddToggle({
		Name = "Auto aim at planes",
		Callback = function(enabled)
			if enabled and Runtime.fullAutoDefense and toggles.fullAuto then setToggleWidget(toggles.fullAuto, false) end
			Runtime.antiAirAimOnly = enabled
			if enabled then
				task.spawn(function()
					while Runtime.antiAirAimOnly do
						task.wait(0.1)
						aimAir(2400, 500, 50, 20)
					end
				end)
				return
			end
			if not Runtime.antiAirShoot then clearAir() end
		end,
	})
	local autoShipSection = page:AddSection("Auto aim ships")
	autoShipSection:AddDropdown({
		Name = "Prioritize", Values = { "Nearest", "Carrier", "Battleship", "Submarine", "All" }, Default = "Nearest",
		Callback = function(value) Config.shipTargetPriority = value end,
	})
	toggles.autoIslands = autoShipSection:AddToggle({
		Name = "Auto shoot islands and harbors",
		Callback = function(enabled)
			if enabled and Runtime.fullAutoDefense and toggles.fullAuto then setToggleWidget(toggles.fullAuto, false) end
			Runtime.autoIslands = enabled
			task.spawn(function()
				while Runtime.autoIslands do
					task.wait(0.45)
					if not Runtime.autoShips and not shootHarborOrIsland() then clearSurf() end
				end
				if not Runtime.autoShips then clearSurf() end
			end)
		end,
	})
	toggles.autoShips = autoShipSection:AddToggle({
		Name = "Auto shoot ships",
		Callback = function(enabled)
			if enabled and Runtime.fullAutoDefense and toggles.fullAuto then setToggleWidget(toggles.fullAuto, false) end
			Runtime.autoShips = enabled
			task.spawn(function()
				while Runtime.autoShips do
					task.wait(0.35)
					if not shootShipsSimple() and not Runtime.autoIslands then clearSurf() end
				end
				if not Runtime.autoIslands then clearSurf() end
			end)
		end,
	})
	local function resetToggles(updateWidgets)
		Runtime.antiAirShoot = false
		Runtime.antiAirAimOnly = false
		Runtime.fullAutoDefense = false
		Runtime.autoIslands = false
		Runtime.autoShips = false
		setDomain(nil)
		clearAir()
		clearSurf()
		if updateWidgets then
			setToggleWidget(toggles.fullAuto, false)
			setToggleWidget(toggles.antiAirShoot, false)
			setToggleWidget(toggles.antiAirAim, false)
			setToggleWidget(toggles.autoIslands, false)
			setToggleWidget(toggles.autoShips, false)
		end
	end
	local function watchHumanoid(character)
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not humanoid then return end
		trackConnection(humanoid.Died:Connect(function()
			resetToggles(true)
			removeDrawing()
		end))
		trackConnection(humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
			if humanoid.SeatPart then return end
			task.defer(function()
				if humanoid.Parent and humanoid.Health > 0 and not humanoid.SeatPart then
					resetToggles(true)
					removeDrawing()
				end
			end)
		end))
	end
	if LocalPlayer.Character then watchHumanoid(LocalPlayer.Character) end
	trackConnection(LocalPlayer.CharacterAdded:Connect(function(character)
		resetToggles(true)
		watchHumanoid(character)
	end))
	CleanupHooks.ShipDefense = function()
		resetToggles(true)
		removeDrawing()
	end
end
buildShipDefense()
local function buildPlane()
	local page = WindowRef:AddPage({ Name = "Plane", Icon = "plane", Description = "Auto reload and VFly for aircraft." })
	local planeReloadSection = page:AddSection("Auto Reload Plane")
	planeReloadSection:AddParagraph({ Text = "Use only while seated in your plane. Avoid bombing or firing during reload." })
	local function getOwnedPlane()
		local character = getLocalCharacter()
		if not character then return nil, nil end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.SeatPart then
			local model, modelName = getSupportedPlaneFromSeat(humanoid.SeatPart)
			if model and isPlaneOwnedByPlayer(model, LocalPlayer) then return model, modelName end
		end
		for _, child in ipairs(Workspace:GetChildren()) do
			if child:IsA("Model") and PLANE_TYPES[child.Name] and isPlaneOwnedByPlayer(child, LocalPlayer) then
				return child, child.Name
			end
		end
		return nil, nil
	end
	local function getPlaneAmmoCounts(planeModel, planeType)
		local bombs = planeModel:FindFirstChild("BombC") and planeModel.BombC.Value or 0
		local bullets = 0
		if planeType == "Large Bomber" then
			bullets = planeModel:FindFirstChild("BulletC1") and planeModel.BulletC1.Value or 0
		else
			bullets = planeModel:FindFirstChild("BulletC") and planeModel.BulletC.Value or 0
		end
		local fuel = planeModel:FindFirstChild("Fuel") and planeModel.Fuel.Value or 0
		local hp = planeModel:FindFirstChild("HP") and planeModel.HP.Value or 0
		return bombs, bullets, fuel, hp
	end
	local function isPlaneFullyRestocked(planeModel, planeType)
		local bombs, bullets, fuel, hp = getPlaneAmmoCounts(planeModel, planeType)
		local threshold = PLANE_THRESHOLDS[planeType]
		return bombs > threshold.bombs and bullets > threshold.bullets and fuel > threshold.fuel and hp >= threshold.hp
	end
	planeReloadSection:AddToggle({
		Name = "Auto reload plane", Default = false,
		Callback = function(enabled)
			Runtime.autoReloadPlane = enabled
			if enabled then
				task.spawn(function()
					while Runtime.autoReloadPlane and scriptActive do
						local character = getLocalCharacter()
						local humanoid = character and character:FindFirstChildOfClass("Humanoid")
						local planeModel, planeType = nil, nil
						if humanoid then planeModel, planeType = getOwnedPlane() end
						if humanoid and planeModel then
							local bombs, bullets, fuel, hp = getPlaneAmmoCounts(planeModel, planeType)
							local threshold = PLANE_THRESHOLDS[planeType]
							local needsRestock = bombs <= threshold.bombs or bullets <= threshold.bullets or fuel <= threshold.fuel or hp < threshold.hp
							if needsRestock then
								local teamName = getLocalTeamName()
								if not teamName or not TEAM_BASE_POSITIONS[teamName] then
									notify("Error", "Could not find team or base coordinates.", 4.5)
									task.wait(2)
								else
									local returnCFrame
									if not humanoid.SeatPart then
										returnCFrame = character:GetPrimaryPartCFrame()
									else
										returnCFrame = planeModel.PrimaryPart.CFrame
									end
									if hp < 100 then
										notify("Critical Repair", "Returning for repairs...", 3)
									else
										notify("Auto Reload", "Restocking " .. planeType .. "...", 4.5)
									end
									setLocalCharacterCFrame(CFrame.new(TEAM_BASE_POSITIONS[teamName]))
									local timeout = 0
									repeat
										task.wait(1)
										timeout = timeout + 1
										if not Runtime.autoReloadPlane then return end
										if not planeModel.Parent then
											notify("Error", planeType .. " was destroyed.", 4.5)
											return
										end
										if timeout >= 30 then
											notify("Warning", "Restock timed out, returning.", 4.5)
											break
										end
									until isPlaneFullyRestocked(planeModel, planeType)
									setLocalCharacterCFrame(returnCFrame)
									notify("Ready", planeType .. " restocked/repaired.", 4.5)
								end
							end
						end
						task.wait(1)
					end
				end)
			end
		end,
	})
	local planeFastSection = page:AddSection("Fast Plane")
	local vflyBodyVelocity, vflyBodyGyro, vflyActiveSeat, vflyActivePart, vflyHeartbeat = nil, nil, nil, nil, nil
	local function notifyPlane(title, content, duration) notify(title, content, duration or 3) end
	local function getKeyboardMoveVector()
		local moveVector = Vector3.zero
		if UIS:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + CurrentCamera.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - CurrentCamera.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - CurrentCamera.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + CurrentCamera.CFrame.RightVector end
		return moveVector
	end
	local function getCameraMoveVector()
		local humanoid = getLocalHumanoid()
		if not humanoid then return Vector3.zero end
		local moveDirection = humanoid.MoveDirection
		if moveDirection.Magnitude <= 0 then return Vector3.zero end
		local lookVector = CurrentCamera.CFrame.LookVector
		local rightVector = CurrentCamera.CFrame.RightVector
		local flatLook = Vector3.new(lookVector.X, 0, lookVector.Z)
		local flatRight = Vector3.new(rightVector.X, 0, rightVector.Z)
		if flatLook.Magnitude > 0 then flatLook = flatLook.Unit end
		if flatRight.Magnitude > 0 then flatRight = flatRight.Unit end
		local flatMove = Vector3.new(moveDirection.X, 0, moveDirection.Z)
		return CurrentCamera.CFrame.LookVector * flatLook:Dot(flatMove) + CurrentCamera.CFrame.RightVector * flatRight:Dot(flatMove)
	end
	local function getMoveVector()
		local keyboardVector = getKeyboardMoveVector()
		if keyboardVector.Magnitude > 0 then return keyboardVector end
		local cameraVector = getCameraMoveVector()
		if cameraVector.Magnitude > 0 then return cameraVector end
		return Vector3.zero
	end
	local function stopPlaneVFly(message, silent)
		if vflyHeartbeat then vflyHeartbeat:Disconnect() vflyHeartbeat = nil end
		if vflyBodyVelocity then vflyBodyVelocity:Destroy() vflyBodyVelocity = nil end
		if vflyBodyGyro then vflyBodyGyro:Destroy() vflyBodyGyro = nil end
		vflyActiveSeat, vflyActivePart = nil, nil
		if not silent and Runtime.vflyEnabled then
			notifyPlane("Plane VFly", message or "Stopped.", 3)
		end
	end
	local function startPlaneVFlyOnSeat(seat)
		stopPlaneVFly(nil, true)
		if not Runtime.vflyEnabled then return end
		local vehicleModel, modelName = getSupportedPlaneFromSeat(seat)
		if not vehicleModel then
			if modelName then
				notifyPlane("Plane VFly", "Detected vehicle: " .. modelName .. " (not a supported plane)", 4)
			else
				notifyPlane("Plane VFly", "Could not detect a vehicle from this seat.", 4)
			end
			return
		end
		local targetPart = vehicleModel.PrimaryPart or seat
		if not targetPart or not targetPart:IsA("BasePart") then
			notifyPlane("Plane VFly", "Detected " .. modelName .. " but no usable part was found.", 4)
			return
		end
		vflyActiveSeat, vflyActivePart = seat, targetPart
		notifyPlane("Plane Detected", "Detected: " .. modelName, 3)
		pcall(function() targetPart:SetNetworkOwner(LocalPlayer) end)
		vflyBodyVelocity = Instance.new("BodyVelocity")
		vflyBodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 1000000
		vflyBodyVelocity.Velocity = Vector3.zero
		vflyBodyVelocity.Parent = targetPart
		vflyBodyGyro = Instance.new("BodyGyro")
		vflyBodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 1000000
		vflyBodyGyro.P = 10000
		vflyBodyGyro.D = 500
		vflyBodyGyro.CFrame = CurrentCamera.CFrame
		vflyBodyGyro.Parent = targetPart
		notifyPlane("Plane VFly", "Started on " .. modelName .. " | Speed: " .. tostring(Config.vflySpeed), 4)
		vflyHeartbeat = RunService.Heartbeat:Connect(function()
			if not Runtime.vflyEnabled then
				stopPlaneVFly("Disabled.", true)
				return
			end
			if not vflyActiveSeat or not vflyActiveSeat.Parent then
				stopPlaneVFly("Seat lost.", false)
				return
			end
			if not vflyActivePart or not vflyActivePart.Parent then
				stopPlaneVFly("Plane part lost.", false)
				return
			end
			vflyBodyGyro.CFrame = CurrentCamera.CFrame
			local moveVector = getMoveVector()
			if moveVector.Magnitude > 0 then
				vflyBodyVelocity.Velocity = moveVector.Unit * Config.vflySpeed
			else
				vflyBodyVelocity.Velocity = Vector3.zero
			end
		end)
	end
	local function watchCharacterForVFly(character)
		local humanoid = character:WaitForChild("Humanoid")
		trackConnection(humanoid.Seated:Connect(function(isSeated, seat)
			if not Runtime.vflyEnabled then return end
			if isSeated and seat then
				local planeModel, planeName = getSupportedPlaneFromSeat(seat)
				if not planeModel then
					local vehicleModel = getVehicleModelFromSeat(seat)
					if vehicleModel then
						notifyPlane("Seat Detected", "Seated in " .. vehicleModel.Name .. " (not a supported plane)", 4)
					else
						notifyPlane("Seat Detected", "Seated, but no vehicle model was found.", 4)
					end
					stopPlaneVFly(nil, true)
					return
				end
				notifyPlane("Plane Seat", "Seated in " .. planeName, 3)
				startPlaneVFlyOnSeat(seat)
			else
				stopPlaneVFly("Unseated.", false)
			end
		end))
		if Runtime.vflyEnabled and humanoid.SeatPart then
			local planeModel, planeName = getSupportedPlaneFromSeat(humanoid.SeatPart)
			if planeModel then
				notifyPlane("Plane Seat", "Already seated in " .. planeName, 3)
				startPlaneVFlyOnSeat(humanoid.SeatPart)
			end
		end
	end
	if LocalPlayer.Character then
		task.spawn(function() watchCharacterForVFly(LocalPlayer.Character) end)
	end
	trackConnection(LocalPlayer.CharacterAdded:Connect(function(character)
		watchCharacterForVFly(character)
	end))
	planeFastSection:AddToggle({
		Name = "Plane VFly", Default = false,
		Callback = function(enabled)
			Runtime.vflyEnabled = enabled
			if enabled then
				local character = getLocalCharacter()
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if humanoid and humanoid.SeatPart then
					local planeModel, planeName = getSupportedPlaneFromSeat(humanoid.SeatPart)
					if planeModel then
						notifyPlane("Plane VFly", "Trying to start on " .. planeName, 3)
						startPlaneVFlyOnSeat(humanoid.SeatPart)
						return
					end
					local vehicleModel = getVehicleModelFromSeat(humanoid.SeatPart)
					if vehicleModel then
						notifyPlane("Plane VFly", "Current seat is in " .. vehicleModel.Name .. ", not a supported plane.", 4)
					else
						notifyPlane("Plane VFly", "Sit in a supported plane first.", 4)
					end
					return
				end
				notifyPlane("Plane VFly", "Sit in a plane seat first.", 4)
				return
			end
			stopPlaneVFly("Disabled.", true)
			notifyPlane("Plane VFly", "Disabled.", 3)
		end,
	})
	planeFastSection:AddTextbox({
		Name = "Plane VFly Speed", Placeholder = "Default: 150",
		Callback = function(text)
			local speed = tonumber(text)
			if speed then
				Config.vflySpeed = math.clamp(speed, 25, 500)
				notifyPlane("Plane VFly", "Speed set to " .. tostring(Config.vflySpeed), 3)
				return
			end
			notifyPlane("Plane VFly", "Enter a valid number.", 3)
		end,
	})
	CleanupHooks.PlaneVFly = function() stopPlaneVFly("Disabled.", true) end
end
buildPlane()
local function buildVehicles()
	local page = WindowRef:AddPage({ Name = "Vehicles", Icon = "drive", Description = "Spawn any vehicle and auto-seat." })
	local spawnSection = page:AddSection("Spawn & Sit")
	for _, def in ipairs(VEHICLE_DEFS) do
		spawnSection:AddButton({
			Name = def.name .. " | " .. def.cost .. " coins",
			Callback = function() task.spawn(function() spawnAndSit(def) end) end,
		})
	end
	local autoSection = page:AddSection("Automation")
	local autoDefNames = {}
	for _, def in ipairs(VEHICLE_DEFS) do table.insert(autoDefNames, def.name) end
	local autoDef = VEHICLE_DEFS[4]
	autoSection:AddDropdown({
		Name = "Auto buy vehicle", Values = autoDefNames, Default = autoDef.name,
		Callback = function(name)
			for _, def in ipairs(VEHICLE_DEFS) do
				if def.name == name then autoDef = def end
			end
		end,
	})
	autoSection:AddToggle({
		Name = "Auto Buy (when affordable)",
		Callback = function(enabled)
			Runtime.autoBuyVehicle = enabled
			if enabled then
				autoBuyArmed = true
				autoBuyGeneration = autoBuyGeneration + 1
				local gen = autoBuyGeneration
				task.spawn(function()
					while Runtime.autoBuyVehicle and scriptActive and gen == autoBuyGeneration do
						task.wait(0.4)
						local coins = getCoins()
						local now = tick()
						if not autoBuyArmed then
							if coins < autoDef.cost or (now - autoBuyLastFire) > 6 then autoBuyArmed = true end
						else
							if coins >= autoDef.cost then
								autoBuyLastFire = now
								autoBuyArmed = false
								spawnAndSit(autoDef)
							end
						end
					end
				end)
			end
		end,
	})
	autoSection:AddButton({ Name = "Re-sit Last Vehicle", Callback = reSitLastVehicle })
	local statusSection = page:AddSection("Status")
	local vehicleStatusLabel = statusSection:AddLabel("Coins: 0 | -")
	task.spawn(function()
		while scriptActive do
			pcall(function()
				local pads = scanVehiclePads()
				local coins = getCoins()
				local afford = coins >= autoDef.cost and "affordable" or ("need " .. (autoDef.cost - coins))
				vehicleStatusLabel.Set("Coins: " .. coins .. " | " .. autoDef.name .. " (" .. autoDef.cost .. ") " .. afford .. " | Pads: " .. #pads.plane .. " air / " .. #pads.ship .. " ship / " .. #pads.capital .. " cap")
			end)
			task.wait(0.5)
		end
	end)
	CleanupHooks.Vehicles = function() Runtime.autoBuyVehicle = false end
end
buildVehicles()
local function buildFling()
	local page = WindowRef:AddPage({ Name = "Fling", Icon = "bolt", Description = "Vehicle flinging: sweep, single target, modes." })
	local SAFE_SPIN, SAFE_VEL = 20000, 20000
	local BOAT_SET = { Submarine = true, Destroyer = true, Cruiser = true, ["Heavy Cruiser"] = true, Battleship = true, Carrier = true }
	local flingTarget, sweepFilter, sweeping, walkflinging = nil, nil, false, false
	local noclipConn, visualConn, teleportConn, autoJumpConn = nil, nil, nil, nil
	local originCFrame, originalCamSubject = nil, nil
	local flingToggle, sweepStatus = nil, nil
	local espHighlight = Instance.new("Highlight")
	espHighlight.Name = "HoundFlingESP"
	espHighlight.FillColor = Color3.fromRGB(255, 50, 50)
	espHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	espHighlight.FillTransparency = 0.6
	espHighlight.OutlineTransparency = 0.2
	espHighlight.Enabled = false
	pcall(function() espHighlight.Parent = game:GetService("CoreGui") end)
	local function getRoot(char)
		return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
	end
	local function isEnemyPlayer(player)
		if not player then return false end
		if player == LocalPlayer then return false end
		if Config.targetOwnTeam then return true end
		if LocalPlayer.Team and player.Team then return LocalPlayer.Team.Name ~= player.Team.Name end
		return true
	end
	local function isPlayerValid(player)
		if not player or not player.Character then return false end
		local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
		local root = getRoot(player.Character)
		return humanoid and humanoid.Health > 0 and root
	end
	local function setCharacterNoclip(enabled)
		local character = LocalPlayer.Character
		if not character then return end
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = enabled and false or true
				part.CanQuery = enabled and false or true
				part.CanTouch = enabled and false or true
			end
		end
	end
	local function spinRoot(root)
		for _, v in pairs(root:GetChildren()) do
			if v.ClassName == "BodyAngularVelocity" then v:Destroy() end
		end
		local bav = Instance.new("BodyAngularVelocity")
		bav.MaxTorque = Vector3.new(1e8, 1e8, 1e8)
		bav.AngularVelocity = Vector3.new(math.random(-SAFE_SPIN, SAFE_SPIN), math.random(-SAFE_SPIN, SAFE_SPIN), math.random(-SAFE_SPIN, SAFE_SPIN))
		bav.P = 1e6
		bav.Parent = root
	end
	local function stopNoclipInternal()
		if noclipConn then noclipConn:Disconnect() noclipConn = nil end
	end
	local function stopVisualsInternal()
		if visualConn then visualConn:Disconnect() visualConn = nil end
		espHighlight.Enabled = false
		if originalCamSubject then
			CurrentCamera.CameraSubject = originalCamSubject
			originalCamSubject = nil
		end
	end
	local function stopFlingLoopInternal()
		if teleportConn then teleportConn:Disconnect() teleportConn = nil end
	end
	local function startNoclip()
		stopNoclipInternal()
		setCharacterNoclip(true)
		noclipConn = RunService.Stepped:Connect(function()
			local char = LocalPlayer.Character
			if char then
				for _, child in pairs(char:GetDescendants()) do
					if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
						child.CanCollide = false
					end
				end
			end
		end)
	end
	local function startVisuals()
		stopVisualsInternal()
		originalCamSubject = CurrentCamera.CameraSubject
		visualConn = RunService.RenderStepped:Connect(function()
			if not walkflinging then return end
			local char = LocalPlayer.Character
			if char then
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") or part:IsA("Decal") then
						part.LocalTransparencyModifier = 1
					end
				end
			end
			if flingTarget and flingTarget.Character then
				local tChar = flingTarget.Character
				local tHum = tChar:FindFirstChildOfClass("Humanoid")
				espHighlight.Adornee = tChar
				espHighlight.Enabled = true
				if tHum and CurrentCamera.CameraSubject ~= tHum then
					CurrentCamera.CameraSubject = tHum
				end
			else
				espHighlight.Enabled = false
			end
		end)
	end
	local function startFlingLoop()
		stopFlingLoopInternal()
		local killHeight = Workspace.FallenPartsDestroyHeight + 60
		teleportConn = RunService.Heartbeat:Connect(function(dt)
			if not walkflinging then return end
			local myRoot = getRoot(LocalPlayer.Character)
			local targetChar = flingTarget and flingTarget.Character
			local targetRoot = getRoot(targetChar)
			if myRoot and targetRoot then
				if myRoot.Position.Y <= killHeight then
					myRoot.CFrame = myRoot.CFrame + Vector3.new(0, 150, 0)
					myRoot.Velocity = Vector3.new(0, 50, 0)
					return
				end
				local speedMult = math.clamp(targetRoot.Velocity.Magnitude / 50, 1, 3)
				local predicted = targetRoot.Position + (targetRoot.Velocity * dt * speedMult)
				if Config.flingMode == "Spin" then
					myRoot.CFrame = CFrame.new(predicted) * CFrame.Angles(0, math.rad(targetRoot.Orientation.Y), 0)
					myRoot.Velocity = Vector3.new(math.random(-SAFE_VEL, SAFE_VEL), SAFE_VEL, math.random(-SAFE_VEL, SAFE_VEL))
					spinRoot(myRoot)
				elseif Config.flingMode == "Void" then
					myRoot.CFrame = CFrame.new(predicted)
					myRoot.Velocity = Vector3.new(0, -SAFE_VEL, 0)
					spinRoot(myRoot)
				else
					local orbitSpeed = tick() * 25
					local orbitOffset = Vector3.new(math.cos(orbitSpeed) * 3, math.random(-1, 3), math.sin(orbitSpeed) * 3)
					myRoot.CFrame = CFrame.new(predicted + orbitOffset, predicted)
					local dir = predicted - myRoot.Position
					if dir.Magnitude > 0.001 then
						myRoot.Velocity = dir.Unit * SAFE_VEL + Vector3.new(0, SAFE_VEL / 2, 0)
					end
					spinRoot(myRoot)
				end
			end
		end)
	end
	local function unfling()
		walkflinging = false
		stopNoclipInternal()
		stopVisualsInternal()
		stopFlingLoopInternal()
		setCharacterNoclip(false)
		local char = LocalPlayer.Character
		if char and getRoot(char) then
			local root = getRoot(char)
			for _, v in pairs(root:GetChildren()) do
				if v.ClassName == "BodyAngularVelocity" then v:Destroy() end
			end
			for _, child in pairs(char:GetDescendants()) do
				if child:IsA("BasePart") or child:IsA("Decal") then
					child.LocalTransparencyModifier = 0
				end
			end
			if originCFrame then
				root.Velocity = Vector3.zero
				root.CFrame = originCFrame
				originCFrame = nil
			end
		end
	end
	local function fling(player)
		flingTarget = player
		walkflinging = true
		if not originCFrame and LocalPlayer.Character and getRoot(LocalPlayer.Character) then
			originCFrame = getRoot(LocalPlayer.Character).CFrame
		end
		startNoclip()
		startVisuals()
		startFlingLoop()
	end
	local function stopSweep()
		sweeping = false
		sweepFilter = nil
	end
	local function manageAutoJump()
		if autoJumpConn then autoJumpConn:Disconnect() autoJumpConn = nil end
		if Config.autoJump then
			autoJumpConn = RunService.Heartbeat:Connect(function()
				local char = LocalPlayer.Character
				if char then
					local humanoid = char:FindFirstChildOfClass("Humanoid")
					if humanoid then humanoid.Jump = true end
				end
			end)
		end
	end
	trackConnection(LocalPlayer.CharacterAdded:Connect(function()
		if walkflinging then
			task.delay(0.5, function()
				startNoclip()
				if flingTarget then startFlingLoop() end
			end)
		end
	end))
	local sweepSection = page:AddSection("Auto Sweep")
	sweepStatus = sweepSection:AddLabel("Sweep: idle")
	local function enemyModels(nameSet)
		local my = (getLocalTeamName() or "USA"):lower()
		local out = {}
		for _, obj in ipairs(Workspace:GetChildren()) do
			if obj:IsA("Model") and nameSet[obj.Name] then
				local tv = obj:FindFirstChild("Team")
				if tv and tostring(tv.Value):lower() ~= my then
					local main = obj.PrimaryPart or obj:FindFirstChild("MainBody", true) or obj:FindFirstChild("Main", true) or obj:FindFirstChildWhichIsA("BasePart")
					if main and main:IsA("BasePart") then
						table.insert(out, { model = obj, mainPart = main, name = obj.Name })
					end
				end
			end
		end
		return out
	end
	local function getEnemyVehicleRecords(filter)
		local records = {}
		if filter == "planes" or filter == "all" then
			for _, info in ipairs(enemyModels(PLANE_TYPES)) do table.insert(records, info) end
		end
		if filter == "boats" or filter == "all" then
			for _, info in ipairs(enemyModels(BOAT_SET)) do table.insert(records, info) end
		end
		return records
	end
	local function executeSweep(filter)
		if sweeping and sweepFilter == filter then
			stopSweep()
			unfling()
			if sweepStatus then sweepStatus.Set("Sweep: stopped") end
			return
		end
		sweeping = true
		sweepFilter = filter
		if sweepStatus then sweepStatus.Set("Sweep: running (" .. filter .. ")") end
		task.spawn(function()
			local lastTarget = nil
			while sweeping and sweepFilter == filter and scriptActive do
				local records = getEnemyVehicleRecords(filter)
				if #records == 0 then
					if sweepStatus then sweepStatus.Set("Sweep: waiting for targets") end
					task.wait(1)
				else
					local nextTarget = nil
					for _, rec in ipairs(records) do
						local owner = getPlayerFromModelOwner(rec.model)
						if owner and isPlayerValid(owner) and owner ~= lastTarget then
							nextTarget = owner
							break
						end
					end
					if not nextTarget then
						for _, rec in ipairs(records) do
							local owner = getPlayerFromModelOwner(rec.model)
							if owner and isPlayerValid(owner) then
								nextTarget = owner
								break
							end
						end
					end
					if nextTarget then
						flingTarget = nextTarget
						lastTarget = nextTarget
						if sweepStatus then sweepStatus.Set("Sweep: " .. nextTarget.Name) end
						fling(nextTarget)
						local timeout = tick() + 5
						repeat
							task.wait(0.1)
						until not isPlayerValid(flingTarget) or tick() > timeout or not sweeping
						if sweeping then
							unfling()
							task.wait(0.2)
						end
					else
						task.wait(0.5)
					end
				end
			end
			unfling()
			if sweepStatus then sweepStatus.Set("Sweep: idle") end
		end)
	end
	sweepSection:AddButton({ Name = "Fling All Boats", Callback = function() executeSweep("boats") end })
	sweepSection:AddButton({ Name = "Fling All Planes", Callback = function() executeSweep("planes") end })
	sweepSection:AddButton({ Name = "Fling All Vehicles", Callback = function() executeSweep("all") end })
	local singleSection = page:AddSection("Single Target")
	local flingPlayerValues = {}
	local function getFlingPlayerOptions()
		local options = {}
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and isEnemyPlayer(player) then table.insert(options, player.Name) end
		end
		if #options == 0 then table.insert(options, "None") end
		return options
	end
	local selectedFlingName = "None"
	local flingDropdown = singleSection:AddDropdown({
		Name = "Select fling target", Values = flingPlayerValues,
		Callback = function(name) selectedFlingName = name end,
	})
	local function refreshFlingDropdown()
		selectedFlingName = refreshDropdownValues(flingPlayerValues, getFlingPlayerOptions(), flingDropdown, selectedFlingName)
	end
	refreshFlingDropdown()
	trackConnection(Players.PlayerAdded:Connect(refreshFlingDropdown))
	trackConnection(Players.PlayerRemoving:Connect(refreshFlingDropdown))
	flingToggle = singleSection:AddToggle({
		Name = "Fling Selected Target",
		Callback = function(enabled)
			if enabled then
				local target = Players:FindFirstChild(selectedFlingName)
				if not target or not isPlayerValid(target) then
					notify("Fling", "Pick a valid target first.", 4)
					setToggleWidget(flingToggle, false, true)
					return
				end
				stopSweep()
				fling(target)
			else
				stopSweep()
				unfling()
			end
		end,
	})
	local flingSettings = page:AddSection("Fling Settings")
	flingSettings:AddDropdown({
		Name = "Fling mode", Values = { "Spin", "Void", "Orbit" }, Default = Config.flingMode,
		Callback = function(value) Config.flingMode = value end,
	})
	flingSettings:AddToggle({
		Name = "Target own team",
		Callback = function(enabled)
			Config.targetOwnTeam = enabled
			refreshFlingDropdown()
		end,
	})
	flingSettings:AddToggle({
		Name = "Auto jump",
		Callback = function(enabled)
			Config.autoJump = enabled
			manageAutoJump()
		end,
	})
	CleanupHooks.Fling = function()
		stopSweep()
		unfling()
	end
end
buildFling()
local function buildServer()
	local page = WindowRef:AddPage({ Name = "Server", Icon = "globe", Description = "Plane destruction, server hop and rejoin." })
	local serverSection = page:AddSection("Server")
	serverSection:AddParagraph({ Text = "Sit in a harbor turret first. This uses that turret to target enemy aircraft automatically." })
	local function bringEnemyPlanesToLocal()
		local localTeam = LocalPlayer.Team
		local character = getLocalCharacter()
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not localTeam or not root then return end
		local originalCFrame = root.CFrame
		for _, descendant in pairs(Workspace:GetDescendants()) do
			if descendant:IsA("Model") and (descendant.Name == "Bomber" or descendant.Name == "Large Bomber" or descendant.Name == "Torpedo Bomber") then
				if not descendant.PrimaryPart then
					local humanoidRootPart = descendant:FindFirstChild("HumanoidRootPart")
					if humanoidRootPart then descendant.PrimaryPart = humanoidRootPart end
				end
				if descendant.PrimaryPart and getModelTeamValue(descendant) ~= localTeam.Name then
					descendant:SetPrimaryPartCFrame(originalCFrame * CFrame.new(0, 0, 5))
				end
			end
		end
	end
	serverSection:AddToggle({
		Name = "Auto Destroy Enemy Planes - stay seated", Default = false,
		Callback = function(enabled)
			Runtime.autoDestroyPlanes = enabled
			if enabled then
				task.spawn(function()
					while scriptActive and Runtime.autoDestroyPlanes do
						bringEnemyPlanesToLocal()
						task.wait(1)
					end
				end)
			end
		end,
	})
	serverSection:AddButton({
		Name = "Server hop",
		Callback = function()
			local ok, response = pcall(function()
				return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"))
			end)
			if ok and response and response.data then
				for _, server in pairs(response.data) do
					if server.playing < server.maxPlayers and server.id ~= game.JobId then
						local tpOk = pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer) end)
						if tpOk then return end
					end
				end
				notify("Server", "No hop target found.", 4)
				return
			end
			notify("Server", "Server list fetch failed.", 4)
		end,
	})
	serverSection:AddButton({
		Name = "Rejoin",
		Callback = function()
			local ok = pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
			if not ok then notify("Server", "Rejoin failed.", 4) end
		end,
	})
end
buildServer()
local function buildTeleport()
	local page = WindowRef:AddPage({ Name = "Teleport", Icon = "flag", Description = "Islands, team ships, and enemy positions." })
	local islandTeleportSection = page:AddSection("Islands")
	local function teleportToIslandCode(code)
		local character = getLocalCharacter()
		local returnCFrame = character and getCharacterOrVehicleCFrame(character)
		local returnPosition = returnCFrame and returnCFrame.Position or nil
		if not isInSupportedPlane() then
			fireTeleport("Harbour")
			task.wait(0.2)
			if character and returnPosition then
				setCharacterOrVehicleCFrame(character, CFrame.new(returnPosition))
			end
			task.wait(0.2)
		else
			task.wait(0.2)
		end
		local island = getIslandModel(code)
		if not island then
			warn("The specified island does not exist.")
			return
		end
		local post = getFlagPost(island)
		if not post then
			warn("The flag post does not exist on the specified island.")
			return
		end
		local currentCharacter = getLocalCharacter()
		if currentCharacter then
			setCharacterOrVehicleCFrame(currentCharacter, post.CFrame)
		end
	end
	islandTeleportSection:AddButton({ Name = "Teleport to island A", Callback = function() teleportToIslandCode("A") end })
	islandTeleportSection:AddButton({ Name = "Teleport to island B", Callback = function() teleportToIslandCode("B") end })
	islandTeleportSection:AddButton({ Name = "Teleport to island C", Callback = function() teleportToIslandCode("C") end })
	local currentCaptureIsland = nil
	local capturingCurrentIsland = false
	local function getValidLocalCharacter()
		local character = getLocalCharacter()
		if not character then return nil, nil, nil end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local root = character:FindFirstChild("HumanoidRootPart")
		if not humanoid or not root or humanoid.Health <= 0 then
			return character, humanoid, nil
		end
		return character, humanoid, root
	end
	local function isNearFlagPad(island)
		local _, _, root = getValidLocalCharacter()
		if not root then return false end
		local flagPad = getFlagPad(island)
		if not flagPad then return false end
		local flatRoot = Vector3.new(root.Position.X, 0, root.Position.Z)
		local flatPad = Vector3.new(flagPad.Position.X, 0, flagPad.Position.Z)
		return (flatRoot - flatPad).Magnitude <= 10
	end
	local function getIslandOwnerTeam(island)
		local teamValue = getModelTeamValue(island)
		if teamValue == nil or teamValue == "" or teamValue == "Neutral" or teamValue == "None" then
			return nil
		end
		return teamValue
	end
	local function isIslandNeutral(code)
		local island = getIslandModel(code)
		if not island then return false, nil, "missing" end
		local ownerTeam = getIslandOwnerTeam(island)
		if ownerTeam == nil then return true, nil, island end
		return false, ownerTeam, island
	end
	local function getNeutralIslandCodes()
		local neutral = {}
		for _, code in ipairs(ISLAND_CODES) do
			if isIslandNeutral(code) then table.insert(neutral, code) end
		end
		return neutral
	end
	local function getCurrentCaptureIslandCode()
		for _, code in ipairs(ISLAND_CODES) do
			local island = getIslandModel(code)
			if island and isNearFlagPad(island) then return code, island end
		end
		return nil, nil
	end
	local function teleportToCaptureIsland(code, force)
		local character = getLocalCharacter()
		if not character then return false end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local root = character:FindFirstChild("HumanoidRootPart")
		if not humanoid or not root or humanoid.Health <= 0 then return false end
		local island = getIslandModel(code)
		if not island then return false end
		if not force and getIslandOwnerTeam(island) ~= nil then return false end
		local targetPart = getFlagPad(island) or getFlagPost(island)
		if not targetPart then return false end
		setCharacterOrVehicleCFrame(character, targetPart.CFrame + Vector3.new(0, 3, 0))
		return true
	end
	local function waitUntilIslandCaptured(code, generation)
		local capturedTimer, leftPadTimer = 0, 0
		while Runtime.autoCaptureEnabled and generation == Runtime.captureGeneration do
			local neutral, ownerTeam, island = isIslandNeutral(code)
			if island == "missing" then return false, "missing" end
			if not neutral then
				capturedTimer = capturedTimer + 0.2
				if capturedTimer >= 1.25 then return true, ownerTeam end
			end
			local _, _, root = getValidLocalCharacter()
			if not root then return false, "dead" end
			if not isNearFlagPad(island) then
				leftPadTimer = leftPadTimer + 0.2
				if capturingCurrentIsland and code == currentCaptureIsland then
					pcall(function() teleportToCaptureIsland(code, true) end)
				end
				if leftPadTimer >= 1 then return false, "leftpad" end
			end
			task.wait(0.2)
		end
		return false, "stopped"
	end
	local function captureIsland(code, generation)
		local ok, result, reason = pcall(function()
			local neutral, ownerTeam, island = isIslandNeutral(code)
			if island == "missing" then return false, "missing" end
			if not neutral then return false, ownerTeam end
			local currentCode = getCurrentCaptureIslandCode()
			if currentCode and currentCode ~= code then return false, "busy" end
			if not currentCode then
				if not teleportToCaptureIsland(code) then return false, "failed" end
				task.wait(0.25)
			end
			if getCurrentCaptureIslandCode() ~= code then return false, "notonpad" end
			return waitUntilIslandCaptured(code, generation)
		end)
		if not ok then
			warn("Island capture failed for " .. tostring(code) .. ": " .. tostring(result))
			return false, "failed"
		end
		return result, reason
	end
	local function maintainCurrentCaptureIsland(generation)
		if Runtime.autoCaptureRunning then return end
		task.spawn(function()
			while Runtime.autoCaptureEnabled and Runtime.captureGeneration == generation do
				local storedIsland = currentCaptureIsland
				capturingCurrentIsland = storedIsland ~= nil
				if storedIsland and Runtime.autoCaptureEnabled and Runtime.captureGeneration == generation then
					pcall(function() teleportToCaptureIsland(storedIsland, true) end)
				end
				capturingCurrentIsland = false
				local waited = 0
				while waited < 14 and Runtime.autoCaptureEnabled and Runtime.captureGeneration == generation do
					task.wait(0.25)
					waited = waited + 0.25
				end
			end
		end)
	end
	local function autoCaptureMainLoop(generation)
		if Runtime.autoCaptureRunning then return end
		Runtime.autoCaptureRunning = true
		maintainCurrentCaptureIsland(generation)
		local lastNoIslandNotify = 0
		while Runtime.autoCaptureEnabled and generation == Runtime.captureGeneration do
			local _, _, root = getValidLocalCharacter()
			if not root then
				task.wait(1)
			else
				local currentCode = getCurrentCaptureIslandCode()
				if currentCode then
					local success, ownerTeam = captureIsland(currentCode, generation)
					if success and ownerTeam then
						notify("Island Capture", "Finished capturing island " .. currentCode .. " for " .. tostring(ownerTeam) .. ".", 2.5)
					end
					task.wait(0.35)
				else
					local neutralIslands = getNeutralIslandCodes()
					if #neutralIslands == 0 then
						if tick() - lastNoIslandNotify > 6 then
							notify("Island Capture", "No neutral islands to capture.", 2.5)
							lastNoIslandNotify = tick()
						end
						task.wait(1.5)
					else
						for _, code in ipairs(neutralIslands) do
							if not Runtime.autoCaptureEnabled or generation ~= Runtime.captureGeneration then break end
							local success, ownerTeam = captureIsland(code, generation)
							if success and ownerTeam then
								notify("Island Capture", "Finished capturing island " .. code .. " for " .. tostring(ownerTeam) .. ".", 2.5)
							end
							task.wait(0.35)
						end
						task.wait(1.5)
					end
				end
			end
		end
		Runtime.autoCaptureRunning = false
	end
	islandTeleportSection:AddLabel("God mode automatically enabled when capturing")
	islandTeleportSection:AddToggle({
		Name = "Auto Capture All Islands",
		Callback = function(enabled)
			Runtime.autoCaptureEnabled = enabled
			if enabled then
				if Runtime.autoCaptureRunning then return end
				Runtime.captureGeneration = Runtime.captureGeneration + 1
				local generation = Runtime.captureGeneration
				notify("Island Capture", "Auto capture enabled.", 2)
				task.spawn(function() autoCaptureMainLoop(generation) end)
				return
			end
			Runtime.captureGeneration = Runtime.captureGeneration + 1
			notify("Island Capture", "Auto capture disabled.", 2)
		end,
	})
	local teamTeleportSection = page:AddSection("Team Teleports")
	teamTeleportSection:AddLabel("Ships")
	local function findTeamShip(modelName)
		local team = LocalPlayer.Team
		if not team then return nil end
		for _, descendant in pairs(Workspace:GetDescendants()) do
			if descendant:IsA("Model") and descendant.Name == modelName and getModelTeamValue(descendant) == team.Name then
				return descendant
			end
		end
		return nil
	end
	local function teleportToTeamShip(modelName, heightOffset)
		local character = getLocalCharacter()
		if not character then return false end
		local ship = findTeamShip(modelName)
		if not ship then return false end
		local primary = ship.PrimaryPart or ship:FindFirstChildWhichIsA("BasePart")
		if not primary then return false end
		setCharacterOrVehicleCFrame(character, CFrame.new(primary.Position + Vector3.new(0, heightOffset, 0)))
		return true
	end
	teamTeleportSection:AddButton({
		Name = "Teleport to team carrier",
		Callback = function()
			if isInSupportedPlane() then
				teleportToTeamShip("Carrier", 100)
				return
			end
			fireTeleport("Carrier")
		end,
	})
	teamTeleportSection:AddButton({
		Name = "Teleport to team battleship",
		Callback = function()
			if isInSupportedPlane() then
				teleportToTeamShip("Battleship", 100)
				return
			end
			fireTeleport("Battleship")
		end,
	})
	teamTeleportSection:AddLabel("Harbor")
	teamTeleportSection:AddButton({
		Name = "Teleport to team harbor",
		Callback = function()
			local character = getLocalCharacter()
			local teamName = getLocalTeamName()
			if not isInSupportedPlane() then
				fireTeleport("Harbour")
				return
			end
			if character and teamName and TEAM_BASE_POSITIONS[teamName] then
				local basePosition = TEAM_BASE_POSITIONS[teamName]
				setCharacterOrVehicleCFrame(character, CFrame.new(basePosition.X, 90, basePosition.Z))
			end
		end,
	})
	local enemyTeleportSection = page:AddSection("Enemy Teleports")
	local trackedLocalTeam = LocalPlayer.Team
	local selectedEnemyBattleship, selectedEnemyCarrier = nil, nil
	trackConnection(LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
		trackedLocalTeam = LocalPlayer.Team
		if refreshEnemyShipDropdowns then refreshEnemyShipDropdowns() end
	end))
	local function isEnemyShipForTrackedTeam(model)
		local teamValue = getModelTeamValue(model)
		return teamValue ~= nil and trackedLocalTeam and teamValue ~= trackedLocalTeam.Name
	end
	local function getEnemyBattleshipOptions()
		local options = {}
		for _, descendant in pairs(Workspace:GetDescendants()) do
			if descendant:IsA("Model") and descendant.Name == "Battleship" and isEnemyShipForTrackedTeam(descendant) then
				local ownerName = getModelOwnerName(descendant)
				table.insert(options, ownerName and (ownerName .. "'s Battleship") or "Battleship")
			end
		end
		if #options == 0 then table.insert(options, "None") end
		return options
	end
	local function getEnemyCarrierOptions()
		local options = {}
		for _, descendant in pairs(Workspace:GetDescendants()) do
			if descendant:IsA("Model") and descendant.Name == "Carrier" and isEnemyShipForTrackedTeam(descendant) then
				local ownerName = getModelOwnerName(descendant)
				table.insert(options, ownerName and (ownerName .. "'s Carrier") or "Carrier")
			end
		end
		if #options == 0 then table.insert(options, "None") end
		return options
	end
	local function teleportToEnemyBattleship(displayName)
		for _, descendant in pairs(Workspace:GetDescendants()) do
			if descendant:IsA("Model") and descendant.Name == "Battleship" and isEnemyShipForTrackedTeam(descendant) then
				local ownerName = getModelOwnerName(descendant)
				local comparisonName = ownerName and (ownerName .. "'s Battleship") or "Battleship"
				if comparisonName == displayName then
					local heightOffset = isInSupportedPlane() and 100 or 10
					local position = getShipPrimaryPosition(descendant)
					if position then
						local character = getLocalCharacter()
						if character then
							setCharacterOrVehicleCFrame(character, CFrame.new(position + Vector3.new(0, heightOffset, 0)))
						end
					end
					return
				end
			end
		end
	end
	local function teleportToEnemyCarrier(displayName)
		for _, descendant in pairs(Workspace:GetDescendants()) do
			if descendant:IsA("Model") and descendant.Name == "Carrier" and isEnemyShipForTrackedTeam(descendant) then
				local ownerName = getModelOwnerName(descendant)
				local comparisonName = ownerName and (ownerName .. "'s Carrier") or "Carrier"
				if comparisonName == displayName then
					local heightOffset = isInSupportedPlane() and 100 or 20
					local position = getShipPrimaryPosition(descendant)
					if position then
						local character = getLocalCharacter()
						if character then
							setCharacterOrVehicleCFrame(character, CFrame.new(position + Vector3.new(0, heightOffset, 0)))
						end
					end
					return
				end
			end
		end
	end
	local function teleportToHarbourRemote() fireTeleport("Harbour") end
	local enemyBattleshipValues, enemyCarrierValues = {}, {}
	local enemyBattleshipDropdown = enemyTeleportSection:AddDropdown({
		Name = "Enemy battleships", Values = enemyBattleshipValues,
		Callback = function(name) selectedEnemyBattleship = name end,
	})
	enemyTeleportSection:AddButton({
		Name = "Teleport to enemy battleship",
		Callback = function()
			if selectedEnemyBattleship and selectedEnemyBattleship ~= "None" then
				notify("Teleporting", "Teleporting to: " .. selectedEnemyBattleship, 5)
				if not isInSupportedPlane() then
					teleportToHarbourRemote()
					task.wait(0.6)
				end
				teleportToEnemyBattleship(selectedEnemyBattleship)
				return
			end
			notify("Error", "No valid battleship selected.", 5)
		end,
	})
	local enemyCarrierDropdown = enemyTeleportSection:AddDropdown({
		Name = "Enemy carriers", Values = enemyCarrierValues,
		Callback = function(name) selectedEnemyCarrier = name end,
	})
	enemyTeleportSection:AddButton({
		Name = "Teleport to enemy carrier",
		Callback = function()
			if selectedEnemyCarrier and selectedEnemyCarrier ~= "None" then
				notify("Teleporting", "Teleporting to: " .. selectedEnemyCarrier, 5)
				if not isInSupportedPlane() then
					teleportToHarbourRemote()
					task.wait(0.6)
				end
				teleportToEnemyCarrier(selectedEnemyCarrier)
				return
			end
			notify("Error", "No valid carrier selected", 5)
		end,
	})
	enemyTeleportSection:AddLabel("Harbor")
	enemyTeleportSection:AddButton({
		Name = "Teleport to enemy harbor",
		Callback = function()
			local character = getLocalCharacter()
			local teamName = getLocalTeamName()
			local inPlane = isInSupportedPlane()
			if not inPlane then
				teleportToHarbourRemote()
				task.wait(0.4)
			end
			if character and teamName then
				local height = inPlane and 90 or 23
				if teamName == "USA" then
					setCharacterOrVehicleCFrame(character, CFrame.new(0, height, -8163))
				elseif teamName == "Japan" then
					setCharacterOrVehicleCFrame(character, CFrame.new(0, height, 8163))
				end
			end
		end,
	})
	local refreshEnemyShipDropdowns = function()
		selectedEnemyBattleship = refreshDropdownValues(enemyBattleshipValues, getEnemyBattleshipOptions(), enemyBattleshipDropdown, selectedEnemyBattleship)
		selectedEnemyCarrier = refreshDropdownValues(enemyCarrierValues, getEnemyCarrierOptions(), enemyCarrierDropdown, selectedEnemyCarrier)
	end
	refreshEnemyShipDropdowns()
	local enemyShipRefreshPending = false
	local function queueEnemyShipRefresh()
		if enemyShipRefreshPending then return end
		enemyShipRefreshPending = true
		task.delay(0.2, function()
			enemyShipRefreshPending = false
			if scriptActive and refreshEnemyShipDropdowns then refreshEnemyShipDropdowns() end
		end)
	end
	trackConnection(Workspace.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("Model") and (descendant.Name == "Carrier" or descendant.Name == "Battleship") then
			queueEnemyShipRefresh()
		end
	end))
	trackConnection(Workspace.DescendantRemoving:Connect(function(descendant)
		if descendant:IsA("Model") and (descendant.Name == "Carrier" or descendant.Name == "Battleship") then
			queueEnemyShipRefresh()
		end
	end))
	enemyTeleportSection:AddButton({
		Name = "Refresh ship dropdowns",
		Callback = function()
			refreshEnemyShipDropdowns()
			notify("Refreshed", "Enemy battleships and carriers updated.", 3)
		end,
	})
end
buildTeleport()
local function buildPlayer()
	local page = WindowRef:AddPage({ Name = "Player", Icon = "user", Description = "Respawn, god mode and stat modification." })
	local playerScriptsSection = page:AddSection("Player scripts")
	playerScriptsSection:AddToggle({
		Name = "Respawn where died", Default = false,
		Callback = function(enabled)
			Runtime.respawnWhereDied = enabled
			if enabled then
				task.spawn(function()
					while scriptActive and Runtime.respawnWhereDied do
						local character = getLocalCharacter()
						local humanoid = character and character:FindFirstChildOfClass("Humanoid")
						if humanoid and humanoid.Health <= 0 then
							local deathCFrame = character and getCharacterOrVehicleCFrame(character)
							task.wait(4)
							local newCharacter = getLocalCharacter()
							if scriptActive and Runtime.respawnWhereDied and newCharacter and deathCFrame then
								setCharacterOrVehicleCFrame(newCharacter, deathCFrame)
							end
						end
						task.wait(0.1)
					end
				end)
			end
		end,
	})
	local function teleportToHarbourAndRestore()
		local character = getLocalCharacter()
		if not character then return end
		local originalCFrame = getCharacterOrVehicleCFrame(character)
		if not originalCFrame then return end
		local position = originalCFrame.Position
		RemoteEvent:FireServer("Teleport", { "Harbour", "" })
		task.wait(0.1)
		setCharacterOrVehicleCFrame(character, CFrame.new(position))
		task.wait(0.3)
		setCharacterOrVehicleCFrame(character, CFrame.new(position))
	end
	playerScriptsSection:AddToggle({
		Name = "God mode (Toggle)", Default = false,
		Callback = function(enabled)
			Runtime.godMode = enabled
			if not enabled then return end
			task.spawn(function()
				while scriptActive and Runtime.godMode do
					while scriptActive and Runtime.godMode do
						local character = getLocalCharacter()
						local humanoid = character and character:FindFirstChildOfClass("Humanoid")
						if not humanoid or not humanoid.SeatPart then break end
						task.wait(0.2)
					end
					if not Runtime.godMode then return end
					teleportToHarbourAndRestore()
					local waited = 0
					while scriptActive and waited < 14 and Runtime.godMode do
						local character = getLocalCharacter()
						local humanoid = character and character:FindFirstChildOfClass("Humanoid")
						if humanoid and humanoid.SeatPart then
							task.wait(0.2)
						else
							task.wait(0.2)
							waited = waited + 0.2
						end
					end
				end
			end)
		end,
	})
	local playerModificationSection = page:AddSection("Player modification")
	playerModificationSection:AddTextbox({
		Name = "Walkspeed", Default = "16",
		Callback = function(text) Config.walkSpeed = math.clamp(tonumber(text) or 16, 0, 500) end,
	})
	playerModificationSection:AddTextbox({
		Name = "JumpPower", Default = "50",
		Callback = function(text) Config.jumpPower = math.clamp(tonumber(text) or 50, 0, 500) end,
	})
	trackConnection(RunService.Heartbeat:Connect(function()
		local humanoid = getLocalHumanoid()
		if humanoid then
			humanoid.WalkSpeed = Config.walkSpeed
			humanoid.JumpPower = Config.jumpPower
			humanoid.UseJumpPower = true
		end
	end))
	playerModificationSection:AddTextbox({
		Name = "Gravity", Default = "196.2",
		Callback = function(text) Workspace.Gravity = tonumber(text) or 196.2 end,
	})
end
buildPlayer()
local function buildESP()
	local page = WindowRef:AddPage({ Name = "ESP", Icon = "eye", Description = "Player and vehicle wall-hacks." })
	local enemyESPSection = page:AddSection("Boat/Submarine ESP")
	local playerDrawings, vehicleDrawings = {}, {}
	local function removeDrawingEntry(drawingsTable, key)
		if drawingsTable[key] then
			for _, drawing in pairs(drawingsTable[key]) do
				drawing.Visible = false
				pcall(function() drawing:Remove() end)
			end
			drawingsTable[key] = nil
		end
	end
	local function hideDrawingEntry(drawingsTable, key)
		if drawingsTable[key] then
			for _, drawing in pairs(drawingsTable[key]) do drawing.Visible = false end
		end
	end
	local function makeEntry()
		return {
			Box = Drawing.new("Square"), NameTag = Drawing.new("Text"), HealthText = Drawing.new("Text"),
			DistanceTag = Drawing.new("Text"), Tracer = Drawing.new("Line"),
		}
	end
	local function styleEntry(entry)
		entry.Box.Thickness = 2 entry.Box.Transparency = 1 entry.Box.Filled = false
		entry.NameTag.Size = 20 entry.NameTag.Center = true entry.NameTag.Outline = true
		entry.HealthText.Size = 18 entry.HealthText.Center = true entry.HealthText.Outline = true
		entry.DistanceTag.Size = 18 entry.DistanceTag.Center = true entry.DistanceTag.Outline = true
		entry.Tracer.Thickness = 2 entry.Tracer.Transparency = 1
	end
	local function getOrCreatePlayerDrawing(key)
		if not playerDrawings[key] then
			playerDrawings[key] = makeEntry()
			styleEntry(playerDrawings[key])
		end
		return playerDrawings[key]
	end
	local function getOrCreateVehicleDrawing(key)
		if not vehicleDrawings[key] then
			vehicleDrawings[key] = makeEntry()
			styleEntry(vehicleDrawings[key])
		end
		return vehicleDrawings[key]
	end
	local function getVehicleCategory(name)
		if name == "Submarine" then return "Submarine" end
		if PLANE_TYPES[name] then return "Plane" end
		return "Ship"
	end
	trackConnection(RunService.RenderStepped:Connect(function()
		if (Runtime.playerESP or Runtime.enemyESP) and (not Drawing or not Drawing.new) then return end
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				local character = player.Character
				local root = character and character:FindFirstChild("HumanoidRootPart")
				if Runtime.playerESP and root then
					local screenPosition, visible = CurrentCamera:WorldToViewportPoint(root.Position)
					local entry = getOrCreatePlayerDrawing(player)
					if visible then
						local distance = (CurrentCamera.CFrame.Position - root.Position).Magnitude
						local color = COLORS.Red
						if Runtime.espTeamColors and player.Team then color = player.TeamColor.Color end
						local whiteColor = COLORS.White
						local boxHalf = 0
						if Runtime.espBoxes then
							entry.Box.Size = Vector2.new(2000 / screenPosition.Z, 3000 / screenPosition.Z)
							entry.Box.Position = Vector2.new(screenPosition.X - entry.Box.Size.X / 2, screenPosition.Y - entry.Box.Size.Y / 2)
							entry.Box.Color = color
							entry.Box.Visible = true
							boxHalf = entry.Box.Size.Y / 2
						else
							entry.Box.Visible = false
						end
						if Runtime.espNameTags then
							entry.NameTag.Text = player.Name
							entry.NameTag.Position = Vector2.new(screenPosition.X, screenPosition.Y - boxHalf - 20)
							entry.NameTag.Color = Runtime.espTeamColors and color or whiteColor
							entry.NameTag.Visible = true
						else
							entry.NameTag.Visible = false
						end
						if Runtime.espHealthText and character:FindFirstChild("Humanoid") then
							entry.HealthText.Text = string.format("HP: %d", math.floor(character.Humanoid.Health))
							entry.HealthText.Position = Vector2.new(screenPosition.X, screenPosition.Y - boxHalf - 35)
							entry.HealthText.Color = COLORS.Green
							entry.HealthText.Visible = true
						else
							entry.HealthText.Visible = false
						end
						if Runtime.espDistance then
							entry.DistanceTag.Text = string.format("%d studs", math.floor(distance))
							entry.DistanceTag.Position = Vector2.new(screenPosition.X, screenPosition.Y + boxHalf + 5)
							entry.DistanceTag.Color = Runtime.espTeamColors and color or whiteColor
							entry.DistanceTag.Visible = true
						else
							entry.DistanceTag.Visible = false
						end
						if Runtime.espTracers then
							entry.Tracer.From = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y)
							entry.Tracer.To = Vector2.new(screenPosition.X, screenPosition.Y)
							entry.Tracer.Color = Runtime.espTeamColors and color or whiteColor
							entry.Tracer.Visible = true
						else
							entry.Tracer.Visible = false
						end
					else
						hideDrawingEntry(playerDrawings, player)
					end
				else
					hideDrawingEntry(playerDrawings, player)
				end
			end
		end
		if Runtime.enemyESP then
			for _, child in pairs(Workspace:GetChildren()) do
				local category = getVehicleCategory(child.Name)
				local categoryEnabled = (category == "Submarine" and Runtime.espSubmarinesOnly) or (category == "Plane" and Runtime.espPlanesOnly) or (category == "Ship" and Runtime.espShipsOnly)
				local validVehicle = child.Name == "Submarine" or child.Name == "Carrier" or child.Name == "Battleship" or child.Name == "Cruiser" or child.Name == "Heavy Cruiser" or child.Name == "Destroyer" or PLANE_TYPES[child.Name]
				if validVehicle and categoryEnabled then
					local teamValue = getModelTeamValue(child)
					if teamValue and teamValue ~= LocalPlayer.Team.Name then
						local primary = child.PrimaryPart or child:FindFirstChild("HumanoidRootPart") or child:FindFirstChildWhichIsA("BasePart")
						if primary then
							local screenPosition, visible = CurrentCamera:WorldToViewportPoint(primary.Position)
							local entry = getOrCreateVehicleDrawing(child)
							if visible then
								local label = child.Name
								local ownerName = getModelOwnerName(child)
								if ownerName then label = ownerName .. "'s " .. child.Name end
								local distance = (CurrentCamera.CFrame.Position - primary.Position).Magnitude
								local hp = 100
								if child:FindFirstChild("HP") then hp = child.HP.Value end
								entry.NameTag.Text = string.format("[%s] %d Studs\nHP: %d%%", label, math.floor(distance), hp)
								entry.NameTag.Position = Vector2.new(screenPosition.X, screenPosition.Y)
								entry.NameTag.Color = hp < 30 and Color3.fromRGB(240, 20, 20) or Color3.fromRGB(255, 180, 0)
								entry.NameTag.Visible = true
								entry.Box.Visible = false
								entry.HealthText.Visible = false
								entry.DistanceTag.Visible = false
								entry.Tracer.Visible = false
							else
								hideDrawingEntry(vehicleDrawings, child)
							end
						else
							hideDrawingEntry(vehicleDrawings, child)
						end
					else
						hideDrawingEntry(vehicleDrawings, child)
					end
				else
					hideDrawingEntry(vehicleDrawings, child)
				end
			end
		else
			for key in pairs(vehicleDrawings) do removeDrawingEntry(vehicleDrawings, key) end
		end
	end))
	trackConnection(Players.PlayerRemoving:Connect(function(player)
		removeDrawingEntry(playerDrawings, player)
	end))
	trackConnection(Workspace.ChildRemoved:Connect(function(child)
		removeDrawingEntry(vehicleDrawings, child)
	end))
	enemyESPSection:AddToggle({ Name = "Master Enemy ESP", Default = false, Callback = function(enabled) Runtime.enemyESP = enabled end })
	enemyESPSection:AddToggle({ Name = "Submarine Only", Default = false, Callback = function(enabled) Runtime.espSubmarinesOnly = enabled end })
	enemyESPSection:AddToggle({ Name = "Ships Only", Default = false, Callback = function(enabled) Runtime.espShipsOnly = enabled end })
	enemyESPSection:AddToggle({ Name = "Planes Only", Default = false, Callback = function(enabled) Runtime.espPlanesOnly = enabled end })
	page:AddSection("Enable/disable ESP"):AddToggle({
		Name = "Player ESP", Default = false,
		Callback = function(enabled)
			Runtime.playerESP = enabled
			if not enabled then
				for key in pairs(playerDrawings) do hideDrawingEntry(playerDrawings, key) end
			end
		end,
	})
	local espStyleSection = page:AddSection("Choose how you want your ESP")
	espStyleSection:AddToggle({ Name = "Boxes", Default = false, Callback = function(enabled) Runtime.espBoxes = enabled end })
	espStyleSection:AddToggle({ Name = "Name Tags", Default = false, Callback = function(enabled) Runtime.espNameTags = enabled end })
	espStyleSection:AddToggle({ Name = "Health Text", Default = false, Callback = function(enabled) Runtime.espHealthText = enabled end })
	espStyleSection:AddToggle({ Name = "Distance Indicators", Default = false, Callback = function(enabled) Runtime.espDistance = enabled end })
	espStyleSection:AddToggle({ Name = "Tracers", Default = false, Callback = function(enabled) Runtime.espTracers = enabled end })
	espStyleSection:AddToggle({ Name = "Team Colors", Default = false, Callback = function(enabled) Runtime.espTeamColors = enabled end })
	CleanupHooks.ESP = function()
		for key in pairs(playerDrawings) do removeDrawingEntry(playerDrawings, key) end
		for key in pairs(vehicleDrawings) do removeDrawingEntry(vehicleDrawings, key) end
	end
end
buildESP()
local function buildOther()
	local page = WindowRef:AddPage({ Name = "Other", Icon = "wrench", Description = "Client tools and miscellaneous tricks." })
	local clientToolsSection = page:AddSection("Client Tools")
	clientToolsSection:AddButton({ Name = "Get RPG", Callback = function() giveTool("RPG") end })
	clientToolsSection:AddButton({ Name = "Get Parachute", Callback = function() giveTool("Parachute") end })
	clientToolsSection:AddButton({ Name = "Get Binocular", Callback = function() giveTool("Binocular") end })
	local miscSection = page:AddSection("Misc")
	miscSection:AddLabel("You can walk on water and you can land planes on it.")
	miscSection:AddButton({
		Name = "Walk on water",
		Callback = function()
			local corners = {
				Vector3.new(-5114, 1, -8188), Vector3.new(-5118, 0, 8188),
				Vector3.new(5119, 2, 8190), Vector3.new(5126, 6, -8199),
			}
			local minX = math.min(corners[1].X, corners[2].X, corners[3].X, corners[4].X)
			local minZ = math.min(corners[1].Z, corners[2].Z, corners[3].Z, corners[4].Z)
			local maxX = math.max(corners[1].X, corners[2].X, corners[3].X, corners[4].X)
			local maxZ = math.max(corners[1].Z, corners[2].Z, corners[3].Z, corners[4].Z)
			local xTiles = math.ceil((maxX - minX) / 2048)
			local zTiles = math.ceil((maxZ - minZ) / 2048)
			for x = 1, xTiles do
				for z = 1, zTiles do
					local part = Instance.new("Part")
					part.Name = "Baseplate"
					part.Anchored = true
					part.Size = Vector3.new(2048, 1, 2048)
					part.Color = COLORS.Water
					part.Material = Enum.Material.Granite
					part.CFrame = CFrame.new(minX + (x - 0.5) * 2048, 0, minZ + (z - 0.5) * 2048)
					part.Parent = Workspace
				end
			end
		end,
	})
	pcall(function()
		removeTouchTransmitters(Workspace.JapanDock.Decoration.ConcreteBases)
		if Workspace.JapanDock.MainBody:FindFirstChild("TouchInterest") then
			Workspace.JapanDock.MainBody.TouchInterest:Destroy()
		end
	end)
	pcall(function()
		removeTouchTransmitters(Workspace.USDock.Decoration.ConcreteBases)
		if Workspace.USDock.MainBody:FindFirstChild("TouchInterest") then
			Workspace.USDock.MainBody.TouchInterest:Destroy()
		end
	end)
end
buildOther()
local function buildSettings()
	local page = WindowRef:AddPage({ Name = "Settings", Icon = "settings", Description = "Controls and script destruction." })
	local controlsSection = page:AddSection("Controls")
	controlsSection:AddParagraph({ Text = "Desktop: press RightShift to show/hide the window. The 4:3 window auto-fits and stays centered." })
	controlsSection:AddParagraph({ Text = "Mobile: use the hamburger button (top-left) to open the page drawer. Close with the X, reopen with the NW button." })
	local cleanupSection = page:AddSection("Destruction & Cleanup")
	cleanupSection:AddButton({
		Name = "Unload UI (Destroy)",
		Callback = function()
			if stopAllActiveLogic then stopAllActiveLogic(false) end
			if Global.NavalWarfareCleanup then
				pcall(function() Global.NavalWarfareCleanup:Fire() end)
				pcall(function() Global.NavalWarfareCleanup:Destroy() end)
				Global.NavalWarfareCleanup = nil
				Global.NavalWarfareConfig = nil
			end
			pcall(function() Library:Destroy() end)
		end,
	})
	cleanupSection:AddButton({
		Name = "Force Break Active Loops",
		Callback = function()
			if stopAllActiveLogic then stopAllActiveLogic(true) end
		end,
	})
end
buildSettings()
stopAllActiveLogic = function(showNotify)
	Config.loopKillEnabled = false
	Config.silentAimEnabled = false
	Config.rifleKillAuraEnabled = false
	Config.fastShootPCState = false
	Config.fastShootMobileState = false
	Config.viewingTarget = false
	Config.rpgAuraEnabled = false
	Config.autoRPG_PC_State = false
	Runtime.autoKillOppositeTeam = false
	Runtime.antiAirShoot = false
	Runtime.antiAirAimOnly = false
	Runtime.autoIslands = false
	Runtime.autoShips = false
	Runtime.fullAutoDefense = false
	Runtime.autoReloadPlane = false
	Runtime.vflyEnabled = false
	Runtime.autoDestroyPlanes = false
	Runtime.autoCaptureEnabled = false
	Runtime.autoCaptureRunning = false
	Runtime.godMode = false
	Runtime.respawnWhereDied = false
	Runtime.playerESP = false
	Runtime.enemyESP = false
	Runtime.autoBuyVehicle = false
	for _, cleanupFunction in pairs(CleanupHooks) do pcall(cleanupFunction) end
	if showNotify then notify("Stopped", "All active logic stopped.", 4) end
end
addCleanupCallback(function()
	if stopAllActiveLogic then stopAllActiveLogic(false) end
end)
notify("Naval Warfare", "v2.4.5 loaded clean. RightShift toggles the window.", 5)