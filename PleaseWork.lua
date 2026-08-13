local mainapi = {
	Categories = {},
	GUIColor = {Hue = 0, Sat = 0, Value = 0.86},
	HeldKeybinds = {},
	Keybind = {'RightShift'},
	Loaded = false,
	Libraries = {},
	Modules = {},
	Place = game.PlaceId,
	Profile = 'default',
	Profiles = {},
	RainbowSpeed = {Value = 1},
	RainbowUpdateSpeed = {Value = 60},
	RainbowTable = {},
	Scale = {Value = 1},
	ThreadFix = setthreadidentity and true or false,
	ToggleNotifications = {},
	Version = '3.1.5',
	Windows = {}
}
local cloneref = cloneref or function(obj)
	return obj
end
local tweenService = cloneref(game:GetService('TweenService'))
local inputService = cloneref(game:GetService('UserInputService'))
local textService = cloneref(game:GetService('TextService'))
local guiService = cloneref(game:GetService('GuiService'))
local runService = cloneref(game:GetService('RunService'))
local httpService = cloneref(game:GetService('HttpService'))
local coreGui = cloneref(game:GetService('CoreGui'))
local fontsize = Instance.new('GetTextBoundsParams')
fontsize.Width = math.huge
local notifications
local clickgui
local scaledgui
local toolblur
local tooltip
local scale
local gui
local color = {}
local tween = {
	tweens = {},
	tweenstwo = {}
}
local uipallet = {
	Main = Color3.fromRGB(30, 30, 30),
	Secondary = Color3.fromRGB(41, 41, 41),
	Tertiary = Color3.fromRGB(52, 52, 52),
	Text = Color3.fromRGB(238, 238, 238),
	TextDim = Color3.fromRGB(150, 150, 150),
	Outline = Color3.fromRGB(214, 214, 214),
	Inner = Color3.fromRGB(60, 60, 60),
	Font = Font.fromEnum(Enum.Font.Gotham),
	FontSemiBold = Font.fromEnum(Enum.Font.GothamMedium),
	Tween = TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
}
local getcustomassets = {
	['volt/assets/add.png'] = 'rbxassetid://14368300605',
	['volt/assets/alert.png'] = 'rbxassetid://14368301329',
	['volt/assets/allowedicon.png'] = 'rbxassetid://14368302000',
	['volt/assets/allowedtab.png'] = 'rbxassetid://14368302875',
	['volt/assets/arrowmodule.png'] = 'rbxassetid://14473354880',
	['volt/assets/back.png'] = 'rbxassetid://14368303894',
	['volt/assets/bind.png'] = 'rbxassetid://14368304734',
	['volt/assets/bindbkg.png'] = 'rbxassetid://14368305655',
	['volt/assets/blatanticon.png'] = 'rbxassetid://14368306745',
	['volt/assets/blockedicon.png'] = 'rbxassetid://14385669108',
	['volt/assets/blockedtab.png'] = 'rbxassetid://14385672881',
	['volt/assets/blur.png'] = 'rbxassetid://14898786664',
	['volt/assets/blurnotif.png'] = 'rbxassetid://16738720137',
	['volt/assets/close.png'] = 'rbxassetid://14368309446',
	['volt/assets/closemini.png'] = 'rbxassetid://14368310467',
	['volt/assets/colorpreview.png'] = 'rbxassetid://14368311578',
	['volt/assets/combaticon.png'] = 'rbxassetid://14368312652',
	['volt/assets/customsettings.png'] = 'rbxassetid://14403726449',
	['volt/assets/dots.png'] = 'rbxassetid://14368314459',
	['volt/assets/edit.png'] = 'rbxassetid://14368315443',
	['volt/assets/expandicon.png'] = 'rbxassetid://14368353032',
	['volt/assets/expandright.png'] = 'rbxassetid://14368316544',
	['volt/assets/expandup.png'] = 'rbxassetid://14368317595',
	['volt/assets/friendstab.png'] = 'rbxassetid://14397462778',
	['volt/assets/guisettings.png'] = 'rbxassetid://14368318994',
	['volt/assets/guislider.png'] = 'rbxassetid://14368320020',
	['volt/assets/guisliderrain.png'] = 'rbxassetid://14368321288',
	['volt/assets/guiv4.png'] = 'rbxassetid://14368322199',
	['volt/assets/guivolt.png'] = 'rbxassetid://14657521312',
	['volt/assets/info.png'] = 'rbxassetid://14368324807',
	['volt/assets/inventoryicon.png'] = 'rbxassetid://14928011633',
	['volt/assets/legit.png'] = 'rbxassetid://14425650534',
	['volt/assets/legittab.png'] = 'rbxassetid://14426740825',
	['volt/assets/miniicon.png'] = 'rbxassetid://14368326029',
	['volt/assets/notification.png'] = 'rbxassetid://16738721069',
	['volt/assets/overlaysicon.png'] = 'rbxassetid://14368339581',
	['volt/assets/overlaystab.png'] = 'rbxassetid://14397380433',
	['volt/assets/pin.png'] = 'rbxassetid://14368342301',
	['volt/assets/profilesicon.png'] = 'rbxassetid://14397465323',
	['volt/assets/radaricon.png'] = 'rbxassetid://14368343291',
	['volt/assets/rainbow_1.png'] = 'rbxassetid://14368344374',
	['volt/assets/rainbow_2.png'] = 'rbxassetid://14368345149',
	['volt/assets/rainbow_3.png'] = 'rbxassetid://14368345840',
	['volt/assets/rainbow_4.png'] = 'rbxassetid://14368346696',
	['volt/assets/range.png'] = 'rbxassetid://14368347435',
	['volt/assets/rangearrow.png'] = 'rbxassetid://14368348640',
	['volt/assets/rendericon.png'] = 'rbxassetid://14368350193',
	['volt/assets/rendertab.png'] = 'rbxassetid://14397373458',
	['volt/assets/search.png'] = 'rbxassetid://14425646684',
	['volt/assets/targetinfoicon.png'] = 'rbxassetid://14368354234',
	['volt/assets/targetnpc1.png'] = 'rbxassetid://14497400332',
	['volt/assets/targetnpc2.png'] = 'rbxassetid://14497402744',
	['volt/assets/targetplayers1.png'] = 'rbxassetid://14497396015',
	['volt/assets/targetplayers2.png'] = 'rbxassetid://14497397862',
	['volt/assets/targetstab.png'] = 'rbxassetid://14497393895',
	['volt/assets/textguiicon.png'] = 'rbxassetid://14368355456',
	['volt/assets/textv4.png'] = 'rbxassetid://14368357095',
	['volt/assets/textvolt.png'] = 'rbxassetid://14368358200',
	['volt/assets/utilityicon.png'] = 'rbxassetid://14368359107',
	['volt/assets/volt.png'] = 'rbxassetid://14373395239',
	['volt/assets/warning.png'] = 'rbxassetid://14368361552',
	['volt/assets/worldicon.png'] = 'rbxassetid://14368362492'
}
local function getcustomasset(path)
	return getcustomassets[path] or ''
end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local function getfontsize(text, size, font)
	fontsize.Text = text
	fontsize.Size = size
	if typeof(font) == 'Font' then
		fontsize.Font = font
	end
	return textService:GetTextBoundsAsync(fontsize)
end
local function getTableSize(tab)
	local ind = 0
	for _ in tab do ind += 1 end
	return ind
end
local function loopClean(tab)
	for i, v in tab do
		if type(v) == 'table' then
			loopClean(v)
		end
		tab[i] = nil
	end
end
local function loadJson(path)
	local suc, res = pcall(function()
		return httpService:JSONDecode(readfile(path))
	end)
	return suc and type(res) == 'table' and res or nil
end
local function randomString()
	local array = {}
	for i = 1, math.random(10, 100) do
		array[i] = string.char(math.random(32, 126))
	end
	return table.concat(array)
end
local function removeTags(str)
	str = str:gsub('<br%s*/>', '\n')
	return str:gsub('<[^<>]*>', '')
end
local function checkKeybinds(compare, target, key)
	if type(target) == 'table' then
		if table.find(target, key) then
			for _, v in target do
				if not table.find(compare, v) then
					return false
				end
			end
			return true
		end
	end
	return false
end
local function addMaid(object)
	object.Connections = object.Connections or {}
	function object:Clean(callback)
		if typeof(callback) == 'Instance' then
			table.insert(self.Connections, {
				Disconnect = function()
					callback:ClearAllChildren()
					callback:Destroy()
				end
			})
		elseif type(callback) == 'function' then
			table.insert(self.Connections, {Disconnect = callback})
		else
			table.insert(self.Connections, callback)
		end
	end
end
local function addBlur(parent, notif)
	local blur = Instance.new('ImageLabel')
	blur.Name = 'Blur'
	blur.Size = UDim2.new(1, 89, 1, 52)
	blur.Position = UDim2.fromOffset(-48, -31)
	blur.BackgroundTransparency = 1
	blur.Image = getcustomasset('volt/assets/' .. (notif and 'blurnotif' or 'blur') .. '.png')
	blur.ScaleType = Enum.ScaleType.Slice
	blur.SliceCenter = Rect.new(52, 31, 261, 502)
	blur.ImageColor3 = Color3.new(0, 0, 0)
	blur.ImageTransparency = 0.4
	blur.ZIndex = -1
	blur.Parent = parent
	return blur
end
local function addCorner(parent, radius)
	local corner = Instance.new('UICorner')
	corner.CornerRadius = radius or UDim.new(0, 6)
	corner.Parent = parent
	return corner
end
local function addStroke(parent, strokecolor, thickness)
	local stroke = Instance.new('UIStroke')
	stroke.Color = strokecolor or uipallet.Inner
	stroke.Thickness = thickness or 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
end
local function addCloseButton(parent, offset)
	local close = Instance.new('ImageButton')
	close.Name = 'Close'
	close.Size = UDim2.fromOffset(24, 24)
	close.Position = UDim2.new(1, -35, 0, offset or 9)
	close.BackgroundColor3 = Color3.new(1, 1, 1)
	close.BackgroundTransparency = 1
	close.AutoButtonColor = false
	close.Image = getcustomasset('volt/assets/close.png')
	close.ImageColor3 = uipallet.TextDim
	close.ImageTransparency = 0.3
	close.Parent = parent
	addCorner(close, UDim.new(1, 0))
	close.MouseEnter:Connect(function()
		close.ImageTransparency = 0
		tween:Tween(close, uipallet.Tween, {BackgroundTransparency = 0.8})
	end)
	close.MouseLeave:Connect(function()
		close.ImageTransparency = 0.3
		tween:Tween(close, uipallet.Tween, {BackgroundTransparency = 1})
	end)
	return close
end
local function addTooltip(guielement, text)
	if not text then return end
	local function tooltipMoved(x, y)
		local right = x + 16 + tooltip.Size.X.Offset > (scale.Scale * 1920)
		tooltip.Position = UDim2.fromOffset(
			(right and x - (tooltip.Size.X.Offset * scale.Scale) - 16 or x + 16) / scale.Scale,
			((y + 11) - (tooltip.Size.Y.Offset / 2)) / scale.Scale
		)
		tooltip.Visible = toolblur.Visible
	end
	guielement.MouseEnter:Connect(function(x, y)
		local tooltipSize = getfontsize(text, tooltip.TextSize, uipallet.Font)
		tooltip.Size = UDim2.fromOffset(tooltipSize.X + 16, tooltipSize.Y + 12)
		tooltip.Text = text
		tooltipMoved(x, y)
	end)
	guielement.MouseMoved:Connect(tooltipMoved)
	guielement.MouseLeave:Connect(function()
		tooltip.Visible = false
	end)
end
local function hoverOn(trigger, obj, enterGoal, leaveGoal, info)
	trigger.MouseEnter:Connect(function()
		tween:Tween(obj, info or uipallet.Tween, enterGoal)
	end)
	trigger.MouseLeave:Connect(function()
		tween:Tween(obj, info or uipallet.Tween, leaveGoal)
	end)
end
local function rainbowStagger(labels, isOn, isActive)
	local dim = color.Light(uipallet.Main, 0.37)
	if isOn then
		labels[1].ImageColor3 = Color3.fromRGB(80, 220, 120)
		task.delay(0.1, function()
			if not isActive() then return end
			labels[2].ImageColor3 = Color3.fromRGB(245, 190, 60)
			task.delay(0.1, function()
				if not isActive() then return end
				labels[3].ImageColor3 = Color3.fromRGB(245, 80, 80)
			end)
		end)
	else
		labels[3].ImageColor3 = dim
		task.delay(0.1, function()
			if isActive() then return end
			labels[2].ImageColor3 = dim
			task.delay(0.1, function()
				if isActive() then return end
				labels[1].ImageColor3 = dim
			end)
		end)
	end
end
local function makeDraggable(guielement, window)
	guielement.InputBegan:Connect(function(inputObj)
		if window and not window.Visible then return end
		if (inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch) and (inputObj.Position.Y - guielement.AbsolutePosition.Y < 40 or window) then
			local dragPosition = Vector2.new(
				guielement.AbsolutePosition.X - inputObj.Position.X,
				guielement.AbsolutePosition.Y - inputObj.Position.Y + guiService:GetGuiInset().Y
			) / scale.Scale
			local changed = inputService.InputChanged:Connect(function(input)
				if input.UserInputType == (inputObj.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
					local position = input.Position
					if inputService:IsKeyDown(Enum.KeyCode.LeftShift) then
						dragPosition = (dragPosition // 3) * 3
						position = (position // 3) * 3
					end
					guielement.Position = UDim2.fromOffset((position.X / scale.Scale) + dragPosition.X, (position.Y / scale.Scale) + dragPosition.Y)
				end
			end)
			local ended
			ended = inputObj.Changed:Connect(function()
				if inputObj.UserInputState == Enum.UserInputState.End then
					if changed then changed:Disconnect() end
					if ended then ended:Disconnect() end
				end
			end)
		end
	end)
end
local function newOptionBase(name, height, parent, darker, visible, tooltipText)
	local button = Instance.new('TextButton')
	button.Name = name
	button.Size = UDim2.new(1, 0, 0, height)
	button.BackgroundColor3 = color.Dark(parent.BackgroundColor3, darker and 0.02 or 0)
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Visible = visible == nil or visible
	button.Text = ''
	button.Parent = parent
	addTooltip(button, tooltipText)
	return button
end
local function newTitleLabel(parent, text, size, position, textcolor, textsize)
	local label = Instance.new('TextLabel')
	label.Name = 'Title'
	label.Size = size
	label.Position = position
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextColor3 = textcolor or uipallet.TextDim
	label.TextSize = textsize or 11
	label.FontFace = uipallet.Font
	label.Parent = parent
	return label
end
local function newTrack(parent, y, gradient, trackcolor)
	local bkg = Instance.new('Frame')
	bkg.Name = 'Slider'
	bkg.Size = UDim2.new(1, -20, 0, 4)
	bkg.Position = UDim2.fromOffset(10, y)
	bkg.BackgroundColor3 = trackcolor or Color3.new(1, 1, 1)
	bkg.BorderSizePixel = 0
	bkg.Parent = parent
	addCorner(bkg, UDim.new(1, 0))
	if gradient then
		local uigradient = Instance.new('UIGradient')
		uigradient.Color = gradient
		uigradient.Parent = bkg
	end
	local fill = bkg:Clone()
	fill.Name = 'Fill'
	fill.Size = UDim2.fromScale(0.5, 1)
	fill.Position = UDim2.new()
	fill.BackgroundTransparency = 1
	fill.Parent = bkg
	local knobholder = Instance.new('Frame')
	knobholder.Name = 'Knob'
	knobholder.Size = UDim2.fromOffset(24, 4)
	knobholder.Position = UDim2.fromScale(1, 0.5)
	knobholder.AnchorPoint = Vector2.new(0.5, 0.5)
	knobholder.BackgroundColor3 = parent.BackgroundColor3
	knobholder.BorderSizePixel = 0
	knobholder.Parent = fill
	local knob = Instance.new('Frame')
	knob.Name = 'Knob'
	knob.Size = UDim2.fromOffset(14, 14)
	knob.Position = UDim2.fromScale(0.5, 0.5)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.BackgroundColor3 = uipallet.Text
	knob.Parent = knobholder
	addCorner(knob, UDim.new(1, 0))
	addStroke(knob, uipallet.Main, 2)
	return bkg, fill, knobholder, knob
end
local function attachTrackDrag(button, bkg, miny, onmove, onend)
	button.InputBegan:Connect(function(inputObj)
		if (inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch) and (inputObj.Position.Y - button.AbsolutePosition.Y) > ((miny or 20) * scale.Scale) then
			local lastpos = math.clamp((inputObj.Position.X - bkg.AbsolutePosition.X) / bkg.AbsoluteSize.X, 0, 1)
			onmove(lastpos, inputObj, true)
			local changed = inputService.InputChanged:Connect(function(input)
				if input.UserInputType == (inputObj.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
					lastpos = math.clamp((input.Position.X - bkg.AbsolutePosition.X) / bkg.AbsoluteSize.X, 0, 1)
					onmove(lastpos, input)
				end
			end)
			local ended
			ended = inputObj.Changed:Connect(function()
				if inputObj.UserInputState == Enum.UserInputState.End then
					if changed then changed:Disconnect() end
					if ended then ended:Disconnect() end
					if onend then onend(lastpos) end
				end
			end)
		end
	end)
end
local function newWindow(name, width, height, parent, titleText, icon, iconSize, iconPos, onClose)
	local window = Instance.new('TextButton')
	window.Name = name
	window.Size = UDim2.fromOffset(width, height)
	window.BackgroundColor3 = uipallet.Main
	window.BorderSizePixel = 0
	window.AutoButtonColor = false
	window.Visible = false
	window.Text = ''
	window.Parent = parent
	addBlur(window)
	addCorner(window, UDim.new(0, 8))
	addStroke(window, uipallet.Outline, 1)
	local iconobj
	if icon then
		iconobj = Instance.new('ImageLabel')
		iconobj.Name = 'Icon'
		iconobj.Size = iconSize
		iconobj.Position = iconPos or UDim2.fromOffset(10, 14)
		iconobj.BackgroundTransparency = 1
		iconobj.Image = icon
		iconobj.Parent = window
	end
	newTitleLabel(window, titleText, UDim2.new(1, -36, 0, 20), UDim2.fromOffset(36, 11), uipallet.Text, 13)
	local close = addCloseButton(window)
	if onClose then
		close.MouseButton1Click:Connect(onClose)
	end
	return window, close
end
local function createMobileButton(buttonapi, position)
	local heldbutton = false
	local button = Instance.new('TextButton')
	button.Size = UDim2.fromOffset(44, 44)
	button.Position = UDim2.fromOffset(position.X, position.Y)
	button.AnchorPoint = Vector2.new(0.5, 0.5)
	button.BackgroundColor3 = buttonapi.Enabled and Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value) or Color3.fromRGB(30, 30, 36)
	button.BackgroundTransparency = 0.2
	button.Text = buttonapi.Name
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextScaled = true
	button.Font = Enum.Font.GothamMedium
	button.Parent = mainapi.gui
	local buttonconstraint = Instance.new('UITextSizeConstraint')
	buttonconstraint.MaxTextSize = 14
	buttonconstraint.Parent = button
	addCorner(button, UDim.new(1, 0))
	addStroke(button, uipallet.Inner, 1.5)
	button.MouseButton1Down:Connect(function()
		heldbutton = true
		local holdtime, holdpos = tick(), inputService:GetMouseLocation()
		repeat
			heldbutton = (inputService:GetMouseLocation() - holdpos).Magnitude < 6
			task.wait()
		until (tick() - holdtime) > 1 or not heldbutton
		if heldbutton then
			buttonapi.Bind = {}
			button:Destroy()
		end
	end)
	button.MouseButton1Up:Connect(function()
		heldbutton = false
	end)
	button.MouseButton1Click:Connect(function()
		buttonapi:Toggle()
		button.BackgroundColor3 = buttonapi.Enabled and Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value) or Color3.fromRGB(30, 30, 36)
	end)
	buttonapi.Bind = {Button = button}
end
do
	local res = isfile('volt/profiles/color.txt') and loadJson('volt/profiles/color.txt')
	if res then
		uipallet.Main = res.Main and Color3.fromRGB(unpack(res.Main)) or uipallet.Main
		uipallet.Text = res.Text and Color3.fromRGB(unpack(res.Text)) or uipallet.Text
		uipallet.Font = res.Font and Font.new(
			res.Font:find('rbxasset') and res.Font or string.format('rbxasset://fonts/families/%s.json', res.Font)
		) or uipallet.Font
		uipallet.FontSemiBold = Font.new(uipallet.Font.Family, Enum.FontWeight.SemiBold)
	end
	fontsize.Font = uipallet.Font
end
do
	function color.Dark(col, num)
		local h, s, v = col:ToHSV()
		return Color3.fromHSV(h, s, math.clamp(select(3, uipallet.Main:ToHSV()) > 0.5 and v + num or v - num, 0, 1))
	end
	function color.Light(col, num)
		local h, s, v = col:ToHSV()
		return Color3.fromHSV(h, s, math.clamp(select(3, uipallet.Main:ToHSV()) > 0.5 and v - num or v + num, 0, 1))
	end
	function mainapi:Color(h)
		local s = 0.75 + (0.15 * math.min(h / 0.03, 1))
		if h > 0.57 then
			s = 0.9 - (0.4 * math.min((h - 0.57) / 0.09, 1))
		end
		if h > 0.66 then
			s = 0.5 + (0.4 * math.min((h - 0.66) / 0.16, 1))
		end
		if h > 0.87 then
			s = 0.9 - (0.15 * math.min((h - 0.87) / 0.13, 1))
		end
		return h, s, 1
	end
	function mainapi:TextColor(h, s, v)
		if v >= 0.7 and (s < 0.6 or h > 0.04 and h < 0.56) then
			return Color3.new(0.12, 0.12, 0.14)
		end
		return Color3.new(1, 1, 1)
	end
end
do
	function tween:Tween(obj, tweeninfo, goal, tab)
		tab = tab or self.tweens
		if tab[obj] then
			tab[obj]:Cancel()
			tab[obj] = nil
		end
		if obj.Parent and obj.Visible then
			tab[obj] = tweenService:Create(obj, tweeninfo, goal)
			tab[obj].Completed:Once(function()
				if tab then
					tab[obj] = nil
					tab = nil
				end
			end)
			tab[obj]:Play()
		else
			for i, v in goal do
				obj[i] = v
			end
		end
	end
	function tween:Cancel(obj)
		if self.tweens[obj] then
			self.tweens[obj]:Cancel()
			self.tweens[obj] = nil
		end
	end
end
mainapi.Libraries = {
	color = color,
	getcustomasset = getcustomasset,
	getfontsize = getfontsize,
	tween = tween,
	uipallet = uipallet,
}
local components
components = {
	Button = function(optionsettings, children, api)
		local button = newOptionBase(optionsettings.Name .. 'Button', 34, children, optionsettings.Darker, optionsettings.Visible, optionsettings.Tooltip)
		local bkg = Instance.new('Frame')
		bkg.Size = UDim2.new(1, -20, 0, 28)
		bkg.Position = UDim2.fromOffset(10, 3)
		bkg.BackgroundColor3 = color.Light(uipallet.Main, 0.05)
		bkg.Parent = button
		addCorner(bkg)
		addStroke(bkg, uipallet.Inner, 1)
		local label = Instance.new('TextLabel')
		label.Size = UDim2.new(1, -4, 1, -4)
		label.Position = UDim2.fromOffset(2, 2)
		label.BackgroundColor3 = uipallet.Secondary
		label.Text = optionsettings.Name
		label.TextColor3 = uipallet.Text
		label.TextSize = 13
		label.FontFace = uipallet.Font
		label.Parent = bkg
		addCorner(label, UDim.new(0, 4))
		optionsettings.Function = optionsettings.Function or function() end
		hoverOn(button, bkg, {BackgroundColor3 = color.Light(uipallet.Main, 0.0875)}, {BackgroundColor3 = color.Light(uipallet.Main, 0.05)})
		button.MouseButton1Click:Connect(optionsettings.Function)
	end,
	ColorSlider = function(optionsettings, children, api)
		local optionapi = {
			Type = 'ColorSlider',
			Hue = optionsettings.DefaultHue or 0.44,
			Sat = optionsettings.DefaultSat or 1,
			Value = optionsettings.DefaultValue or 1,
			Opacity = optionsettings.DefaultOpacity or 1,
			Rainbow = false,
			Index = 0
		}
		local function createSlider(name, gradientColor)
			local slider = newOptionBase(optionsettings.Name .. 'Slider' .. name, 50, children, optionsettings.Darker, false)
			newTitleLabel(slider, name, UDim2.fromOffset(60, 30), UDim2.fromOffset(10, 2))
			local bkg, fill, knobholder, knob = newTrack(slider, 37, gradientColor)
			fill.Size = UDim2.fromScale(math.clamp(name == 'Saturation' and optionapi.Sat or name == 'Vibrance' and optionapi.Value or optionapi.Opacity, 0.04, 0.96), 1)
			hoverOn(slider, knob, {Size = UDim2.fromOffset(16, 16)}, {Size = UDim2.fromOffset(14, 14)})
			attachTrackDrag(slider, bkg, 20, function(pos)
				optionapi:SetValue(nil, name == 'Saturation' and pos or nil, name == 'Vibrance' and pos or nil, name == 'Opacity' and pos or nil)
			end)
			return slider
		end
		local slider = newOptionBase(optionsettings.Name .. 'Slider', 50, children, optionsettings.Darker, optionsettings.Visible, optionsettings.Tooltip)
		newTitleLabel(slider, optionsettings.Name, UDim2.fromOffset(60, 30), UDim2.fromOffset(10, 2))
		local valuebox = Instance.new('TextBox')
		valuebox.Name = 'Box'
		valuebox.Size = UDim2.fromOffset(60, 15)
		valuebox.Position = UDim2.new(1, -69, 0, 9)
		valuebox.BackgroundTransparency = 1
		valuebox.Visible = false
		valuebox.Text = ''
		valuebox.TextXAlignment = Enum.TextXAlignment.Right
		valuebox.TextColor3 = uipallet.Text
		valuebox.TextSize = 11
		valuebox.FontFace = uipallet.Font
		valuebox.ClearTextOnFocus = true
		valuebox.Parent = slider
		local rainbowTable = {}
		for i = 0, 1, 0.1 do
			table.insert(rainbowTable, ColorSequenceKeypoint.new(i, Color3.fromHSV(i, 1, 1)))
		end
		local bkg, fill, knobholder, knob = newTrack(slider, 39, ColorSequence.new(rainbowTable))
		fill.Size = UDim2.fromScale(math.clamp(optionapi.Hue, 0.04, 0.96), 1)
		local preview = Instance.new('ImageButton')
		preview.Name = 'Preview'
		preview.Size = UDim2.fromOffset(14, 14)
		preview.Position = UDim2.new(1, -24, 0, 9)
		preview.BackgroundTransparency = 1
		preview.Image = getcustomasset('volt/assets/colorpreview.png')
		preview.ImageColor3 = Color3.fromHSV(optionapi.Hue, optionapi.Sat, optionapi.Value)
		preview.ImageTransparency = 1 - optionapi.Opacity
		preview.Parent = slider
		local expandbutton = Instance.new('TextButton')
		expandbutton.Name = 'Expand'
		expandbutton.Size = UDim2.fromOffset(17, 13)
		expandbutton.Position = UDim2.new(0, getfontsize(optionsettings.Name, 11, uipallet.Font).X + 11, 0, 7)
		expandbutton.BackgroundTransparency = 1
		expandbutton.Text = ''
		expandbutton.Parent = slider
		local expand = Instance.new('ImageLabel')
		expand.Name = 'Expand'
		expand.Size = UDim2.fromOffset(9, 5)
		expand.Position = UDim2.fromOffset(4, 4)
		expand.BackgroundTransparency = 1
		expand.Image = getcustomasset('volt/assets/expandicon.png')
		expand.ImageColor3 = uipallet.TextDim
		expand.Parent = expandbutton
		local rainbow = Instance.new('TextButton')
		rainbow.Name = 'Rainbow'
		rainbow.Size = UDim2.fromOffset(14, 14)
		rainbow.Position = UDim2.new(1, -44, 0, 9)
		rainbow.BackgroundTransparency = 1
		rainbow.Text = ''
		rainbow.Parent = slider
		local rainbow1 = Instance.new('ImageLabel')
		rainbow1.Size = UDim2.fromOffset(14, 14)
		rainbow1.BackgroundTransparency = 1
		rainbow1.Image = getcustomasset('volt/assets/rainbow_1.png')
		rainbow1.ImageColor3 = color.Light(uipallet.Main, 0.37)
		rainbow1.Parent = rainbow
		local rainbow2 = rainbow1:Clone()
		rainbow2.Image = getcustomasset('volt/assets/rainbow_2.png')
		rainbow2.Parent = rainbow
		local rainbow3 = rainbow1:Clone()
		rainbow3.Image = getcustomasset('volt/assets/rainbow_3.png')
		rainbow3.Parent = rainbow
		local rainbow4 = rainbow1:Clone()
		rainbow4.Image = getcustomasset('volt/assets/rainbow_4.png')
		rainbow4.Parent = rainbow
		hoverOn(slider, knob, {Size = UDim2.fromOffset(16, 16)}, {Size = UDim2.fromOffset(14, 14)})
		optionsettings.Function = optionsettings.Function or function() end
		local satSlider = createSlider('Saturation', ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, optionapi.Value)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(optionapi.Hue, 1, optionapi.Value))
		}))
		local vibSlider = createSlider('Vibrance', ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(optionapi.Hue, optionapi.Sat, 1))
		}))
		local opSlider = createSlider('Opacity', ColorSequence.new({
			ColorSequenceKeypoint.new(0, color.Dark(uipallet.Main, 0.02)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(optionapi.Hue, optionapi.Sat, optionapi.Value))
		}))
		function optionapi:Save(tab)
			tab[optionsettings.Name] = {
				Hue = self.Hue,
				Sat = self.Sat,
				Value = self.Value,
				Opacity = self.Opacity,
				Rainbow = self.Rainbow
			}
		end
		function optionapi:Load(tab)
			if tab.Rainbow ~= self.Rainbow then
				self:Toggle()
			end
			if self.Hue ~= tab.Hue or self.Sat ~= tab.Sat or self.Value ~= tab.Value or self.Opacity ~= tab.Opacity then
				self:SetValue(tab.Hue, tab.Sat, tab.Value, tab.Opacity)
			end
		end
		function optionapi:SetValue(h, s, v, o)
			self.Hue = h or self.Hue
			self.Sat = s or self.Sat
			self.Value = v or self.Value
			self.Opacity = o or self.Opacity
			preview.ImageColor3 = Color3.fromHSV(self.Hue, self.Sat, self.Value)
			preview.ImageTransparency = 1 - self.Opacity
			satSlider.Slider.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, self.Value)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV(self.Hue, 1, self.Value))
			})
			vibSlider.Slider.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV(self.Hue, self.Sat, 1))
			})
			opSlider.Slider.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, color.Dark(uipallet.Main, 0.02)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV(self.Hue, self.Sat, self.Value))
			})
			if self.Rainbow then
				fill.Size = UDim2.fromScale(math.clamp(self.Hue, 0.04, 0.96), 1)
			else
				tween:Tween(fill, uipallet.Tween, {Size = UDim2.fromScale(math.clamp(self.Hue, 0.04, 0.96), 1)})
			end
			if s then
				tween:Tween(satSlider.Slider.Fill, uipallet.Tween, {Size = UDim2.fromScale(math.clamp(self.Sat, 0.04, 0.96), 1)})
			end
			if v then
				tween:Tween(vibSlider.Slider.Fill, uipallet.Tween, {Size = UDim2.fromScale(math.clamp(self.Value, 0.04, 0.96), 1)})
			end
			if o then
				tween:Tween(opSlider.Slider.Fill, uipallet.Tween, {Size = UDim2.fromScale(math.clamp(self.Opacity, 0.04, 0.96), 1)})
			end
			optionsettings.Function(self.Hue, self.Sat, self.Value, self.Opacity)
		end
		function optionapi:Toggle()
			self.Rainbow = not self.Rainbow
			if self.Rainbow then
				table.insert(mainapi.RainbowTable, self)
				rainbowStagger({rainbow1, rainbow2, rainbow3}, true, function()
					return self.Rainbow
				end)
			else
				local ind = table.find(mainapi.RainbowTable, self)
				if ind then
					table.remove(mainapi.RainbowTable, ind)
				end
				rainbowStagger({rainbow1, rainbow2, rainbow3}, false, function()
					return self.Rainbow
				end)
			end
		end
		local doubleClick = tick()
		preview.MouseButton1Click:Connect(function()
			preview.Visible = false
			valuebox.Visible = true
			valuebox:CaptureFocus()
			local text = Color3.fromHSV(optionapi.Hue, optionapi.Sat, optionapi.Value)
			valuebox.Text = math.round(text.R * 255) .. ', ' .. math.round(text.G * 255) .. ', ' .. math.round(text.B * 255)
		end)
		attachTrackDrag(slider, bkg, 20, function(pos, input, began)
			if began then
				if doubleClick > tick() then
					optionapi:Toggle()
				end
				doubleClick = tick() + 0.3
			end
			optionapi:SetValue(pos)
		end)
		hoverOn(expandbutton, expand, {ImageColor3 = uipallet.Text}, {ImageColor3 = uipallet.TextDim})
		expandbutton.MouseButton1Click:Connect(function()
			satSlider.Visible = not satSlider.Visible
			vibSlider.Visible = satSlider.Visible
			opSlider.Visible = satSlider.Visible
			expand.Rotation = satSlider.Visible and 180 or 0
		end)
		rainbow.MouseButton1Click:Connect(function()
			optionapi:Toggle()
		end)
		valuebox.FocusLost:Connect(function(enter)
			preview.Visible = true
			valuebox.Visible = false
			if enter then
				local commas = valuebox.Text:split(',')
				local suc, res = pcall(function()
					return tonumber(commas[1]) and Color3.fromRGB(tonumber(commas[1]), tonumber(commas[2]), tonumber(commas[3])) or Color3.fromHex(valuebox.Text)
				end)
				if suc then
					if optionapi.Rainbow then
						optionapi:Toggle()
					end
					optionapi:SetValue(res:ToHSV())
				end
			end
		end)
		slider:GetPropertyChangedSignal('Visible'):Connect(function()
			satSlider.Visible = expand.Rotation == 180 and slider.Visible
			vibSlider.Visible = satSlider.Visible
			opSlider.Visible = satSlider.Visible
		end)
		optionapi.Object = slider
		api.Options[optionsettings.Name] = optionapi
		return optionapi
	end,
	Dropdown = function(optionsettings, children, api)
		local optionapi = {
			Type = 'Dropdown',
			Value = optionsettings.List[1] or 'None',
			Index = 0
		}
		local dropdown = newOptionBase(optionsettings.Name .. 'Dropdown', 44, children, optionsettings.Darker, optionsettings.Visible, optionsettings.Tooltip or optionsettings.Name)
		local bkg = Instance.new('Frame')
		bkg.Name = 'BKG'
		bkg.Size = UDim2.new(1, -20, 1, -9)
		bkg.Position = UDim2.fromOffset(10, 4)
		bkg.BackgroundColor3 = color.Light(uipallet.Main, 0.034)
		bkg.Parent = dropdown
		addCorner(bkg, UDim.new(0, 6))
		addStroke(bkg, uipallet.Inner, 1)
		local button = Instance.new('TextButton')
		button.Name = 'Dropdown'
		button.Size = UDim2.new(1, -2, 1, -2)
		button.Position = UDim2.fromOffset(1, 1)
		button.BackgroundColor3 = uipallet.Secondary
		button.AutoButtonColor = false
		button.Text = ''
		button.Parent = bkg
		local title = Instance.new('TextLabel')
		title.Name = 'Title'
		title.Size = UDim2.new(1, 0, 0, 29)
		title.BackgroundTransparency = 1
		title.Text = optionsettings.Name .. ' - ' .. optionapi.Value
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.TextColor3 = uipallet.Text
		title.TextSize = 13
		title.TextTruncate = Enum.TextTruncate.AtEnd
		title.FontFace = uipallet.Font
		title.Parent = button
		addCorner(button, UDim.new(0, 6))
		local arrow = Instance.new('ImageLabel')
		arrow.Name = 'Arrow'
		arrow.Size = UDim2.fromOffset(8, 8)
		arrow.Position = UDim2.new(1, -17, 0, 11)
		arrow.BackgroundTransparency = 1
		arrow.Image = getcustomasset('volt/assets/expandright.png')
		arrow.ImageColor3 = uipallet.TextDim
		arrow.Rotation = 90
		arrow.Parent = button
		optionsettings.Function = optionsettings.Function or function() end
		local dropdownchildren
		function optionapi:Save(tab)
			tab[optionsettings.Name] = {Value = self.Value}
		end
		function optionapi:Load(tab)
			if self.Value ~= tab.Value then
				self:SetValue(tab.Value)
			end
		end
		function optionapi:Change(list)
			optionsettings.List = list or {}
			if not table.find(optionsettings.List, self.Value) then
				self:SetValue(self.Value)
			end
		end
		function optionapi:SetValue(val, mouse)
			self.Value = table.find(optionsettings.List, val) and val or optionsettings.List[1] or 'None'
			title.Text = optionsettings.Name .. ' - ' .. self.Value
			if dropdownchildren then
				arrow.Rotation = 90
				dropdownchildren:Destroy()
				dropdownchildren = nil
				dropdown.Size = UDim2.new(1, 0, 0, 44)
			end
			optionsettings.Function(self.Value, mouse)
		end
		button.MouseButton1Click:Connect(function()
			local rows = math.max(#optionsettings.List - 1, 0)
			if not dropdownchildren then
				arrow.Rotation = 270
				dropdown.Size = UDim2.new(1, 0, 0, 44 + rows * 28)
				dropdownchildren = Instance.new('Frame')
				dropdownchildren.Name = 'Children'
				dropdownchildren.Size = UDim2.new(1, 0, 0, rows * 28)
				dropdownchildren.Position = UDim2.fromOffset(0, 30)
				dropdownchildren.BackgroundTransparency = 1
				dropdownchildren.Parent = button
				local ind = 0
				for _, v in optionsettings.List do
					if v == optionapi.Value then continue end
					local dropdownoption = Instance.new('TextButton')
					dropdownoption.Name = v .. 'Option'
					dropdownoption.Size = UDim2.new(1, 0, 0, 28)
					dropdownoption.Position = UDim2.fromOffset(0, ind * 28)
					dropdownoption.BackgroundColor3 = uipallet.Secondary
					dropdownoption.BorderSizePixel = 0
					dropdownoption.AutoButtonColor = false
					dropdownoption.Text = '  ' .. v
					dropdownoption.TextXAlignment = Enum.TextXAlignment.Left
					dropdownoption.TextColor3 = uipallet.TextDim
					dropdownoption.TextSize = 13
					dropdownoption.TextTruncate = Enum.TextTruncate.AtEnd
					dropdownoption.FontFace = uipallet.Font
					dropdownoption.Parent = dropdownchildren
					hoverOn(dropdownoption, dropdownoption, {BackgroundColor3 = color.Light(uipallet.Main, 0.06)}, {BackgroundColor3 = uipallet.Secondary})
					dropdownoption.MouseButton1Click:Connect(function()
						optionapi:SetValue(v, true)
					end)
					ind += 1
				end
			else
				optionapi:SetValue(optionapi.Value, true)
			end
		end)
		hoverOn(dropdown, bkg, {BackgroundColor3 = color.Light(uipallet.Main, 0.0875)}, {BackgroundColor3 = color.Light(uipallet.Main, 0.034)})
		optionapi.Object = dropdown
		api.Options[optionsettings.Name] = optionapi
		return optionapi
	end,
	Font = function(optionsettings, children, api)
		local names = {}
		for _, v in Enum.Font:GetEnumItems() do
			if v.Name ~= optionsettings.Blacklist and v.Name ~= 'Unknown' then
				table.insert(names, v.Name)
			end
		end
		table.sort(names, function(a, b)
			return a:lower() < b:lower()
		end)
		table.insert(names, 1, 'Custom')
		local fonts = names
		local optionapi = {Value = uipallet.Font}
		local fontdropdown
		local fontbox
		optionsettings.Function = optionsettings.Function or function() end
		fontdropdown = components.Dropdown({
			Name = optionsettings.Name,
			List = fonts,
			Function = function(val)
				if fontbox then
					fontbox.Object.Visible = val == 'Custom' and fontdropdown.Object.Visible
				end
				if val ~= 'Custom' then
					pcall(function()
						optionapi.Value = Font.fromEnum(Enum.Font[val])
					end)
				else
					pcall(function()
						optionapi.Value = Font.fromId(tonumber(fontbox.Value))
					end)
				end
				optionsettings.Function(optionapi.Value)
			end,
			Darker = optionsettings.Darker,
			Visible = optionsettings.Visible
		}, children, api)
		optionapi.Object = fontdropdown.Object
		fontbox = components.TextBox({
			Name = optionsettings.Name .. ' Asset',
			Placeholder = 'font (rbxasset)',
			Function = function()
				if fontdropdown.Value == 'Custom' then
					pcall(function()
						optionapi.Value = Font.fromId(tonumber(fontbox.Value))
					end)
					optionsettings.Function(optionapi.Value)
				end
			end,
			Visible = false,
			Darker = true
		}, children, api)
		fontdropdown.Object:GetPropertyChangedSignal('Visible'):Connect(function()
			fontbox.Object.Visible = fontdropdown.Object.Visible and fontdropdown.Value == 'Custom'
		end)
		fontdropdown:SetValue(fonts[2] or 'Gotham')
		return optionapi
	end,
	Slider = function(optionsettings, children, api)
		local range = math.max(optionsettings.Max - optionsettings.Min, 0.0001)
		local optionapi = {
			Type = 'Slider',
			Value = optionsettings.Default or optionsettings.Min,
			Max = optionsettings.Max,
			Index = getTableSize(api.Options)
		}
		local slider = newOptionBase(optionsettings.Name .. 'Slider', 50, children, optionsettings.Darker, optionsettings.Visible, optionsettings.Tooltip)
		newTitleLabel(slider, optionsettings.Name, UDim2.fromOffset(60, 30), UDim2.fromOffset(10, 2))
		local valuebutton = Instance.new('TextButton')
		valuebutton.Name = 'Value'
		valuebutton.Size = UDim2.fromOffset(60, 15)
		valuebutton.Position = UDim2.new(1, -69, 0, 9)
		valuebutton.BackgroundTransparency = 1
		valuebutton.Text = optionapi.Value .. (optionsettings.Suffix and ' ' .. (type(optionsettings.Suffix) == 'function' and optionsettings.Suffix(optionapi.Value) or optionsettings.Suffix) or '')
		valuebutton.TextXAlignment = Enum.TextXAlignment.Right
		valuebutton.TextColor3 = uipallet.Text
		valuebutton.TextSize = 11
		valuebutton.FontFace = uipallet.Font
		valuebutton.Parent = slider
		local valuebox = Instance.new('TextBox')
		valuebox.Name = 'Box'
		valuebox.Size = valuebutton.Size
		valuebox.Position = valuebutton.Position
		valuebox.BackgroundTransparency = 1
		valuebox.Visible = false
		valuebox.Text = optionapi.Value
		valuebox.TextXAlignment = Enum.TextXAlignment.Right
		valuebox.TextColor3 = uipallet.Text
		valuebox.TextSize = 11
		valuebox.FontFace = uipallet.Font
		valuebox.ClearTextOnFocus = false
		valuebox.Parent = slider
		local bkg, fill, knobholder, knob = newTrack(slider, 37, nil, color.Light(uipallet.Main, 0.034))
		fill.BackgroundTransparency = 0
		fill.BackgroundColor3 = Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value)
		fill.Size = UDim2.fromScale(math.clamp((optionapi.Value - optionsettings.Min) / range, 0.04, 0.96), 1)
		knob.BackgroundColor3 = Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value)
		hoverOn(slider, knob, {Size = UDim2.fromOffset(16, 16)}, {Size = UDim2.fromOffset(14, 14)})
		optionsettings.Function = optionsettings.Function or function() end
		optionsettings.Decimal = optionsettings.Decimal or 1
		function optionapi:Save(tab)
			tab[optionsettings.Name] = {
				Value = self.Value,
				Max = self.Max
			}
		end
		function optionapi:Load(tab)
			local newval = tab.Value == tab.Max and tab.Max ~= self.Max and self.Max or tab.Value
			if self.Value ~= newval then
				self:SetValue(newval, nil, true)
			end
		end
		function optionapi:Color(hue, sat, val, rainbowcheck)
			fill.BackgroundColor3 = rainbowcheck and Color3.fromHSV(mainapi:Color((hue - (self.Index * 0.075)) % 1)) or Color3.fromHSV(hue, sat, val)
			knob.BackgroundColor3 = fill.BackgroundColor3
		end
		function optionapi:SetValue(value, pos, final)
			if tonumber(value) == math.huge or value ~= value then return end
			local check = self.Value ~= value
			self.Value = value
			tween:Tween(fill, uipallet.Tween, {
				Size = UDim2.fromScale(math.clamp(pos or math.clamp((value - optionsettings.Min) / range, 0, 1), 0.04, 0.96), 1)
			})
			valuebutton.Text = self.Value .. (optionsettings.Suffix and ' ' .. (type(optionsettings.Suffix) == 'function' and optionsettings.Suffix(self.Value) or optionsettings.Suffix) or '')
			if check or final then
				optionsettings.Function(value, final)
			end
		end
		attachTrackDrag(slider, bkg, 20, function(pos)
			optionapi:SetValue(math.floor((optionsettings.Min + range * pos) * optionsettings.Decimal) / optionsettings.Decimal, pos)
		end, function(pos)
			optionapi:SetValue(math.floor((optionsettings.Min + range * pos) * optionsettings.Decimal) / optionsettings.Decimal, pos, true)
		end)
		valuebutton.MouseButton1Click:Connect(function()
			valuebutton.Visible = false
			valuebox.Visible = true
			valuebox.Text = optionapi.Value
			valuebox:CaptureFocus()
		end)
		valuebox.FocusLost:Connect(function(enter)
			valuebutton.Visible = true
			valuebox.Visible = false
			if enter and tonumber(valuebox.Text) then
				optionapi:SetValue(tonumber(valuebox.Text), nil, true)
			end
		end)
		optionapi.Object = slider
		api.Options[optionsettings.Name] = optionapi
		return optionapi
	end,
	TargetsButton = function(optionsettings, children, api)
		local optionapi = {Enabled = false}
		local targetbutton = Instance.new('TextButton')
		targetbutton.Size = UDim2.fromOffset(98, 31)
		targetbutton.Position = optionsettings.Position
		targetbutton.BackgroundColor3 = color.Light(uipallet.Main, 0.05)
		targetbutton.AutoButtonColor = false
		targetbutton.Visible = optionsettings.Visible == nil or optionsettings.Visible
		targetbutton.Text = ''
		targetbutton.Parent = children
		addCorner(targetbutton)
		addTooltip(targetbutton, optionsettings.Tooltip)
		local bkg = Instance.new('Frame')
		bkg.Size = UDim2.new(1, -2, 1, -2)
		bkg.Position = UDim2.fromOffset(1, 1)
		bkg.BackgroundColor3 = uipallet.Secondary
		bkg.Parent = targetbutton
		addCorner(bkg)
		local icon = Instance.new('ImageLabel')
		icon.Size = optionsettings.IconSize
		icon.Position = UDim2.fromScale(0.5, 0.5)
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.BackgroundTransparency = 1
		icon.Image = optionsettings.Icon
		icon.ImageColor3 = color.Light(uipallet.Main, 0.37)
		icon.Parent = bkg
		optionsettings.Function = optionsettings.Function or function() end
		local tooltipicon
		function optionapi:Toggle()
			self.Enabled = not self.Enabled
			tween:Tween(bkg, uipallet.Tween, {
				BackgroundColor3 = self.Enabled and Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value) or uipallet.Secondary
			})
			tween:Tween(icon, uipallet.Tween, {
				ImageColor3 = self.Enabled and Color3.new(1, 1, 1) or color.Light(uipallet.Main, 0.37)
			})
			if tooltipicon then
				tooltipicon:Destroy()
			end
			if self.Enabled then
				tooltipicon = Instance.new('ImageLabel')
				tooltipicon.Size = optionsettings.ToolSize
				tooltipicon.BackgroundTransparency = 1
				tooltipicon.Image = optionsettings.ToolIcon
				tooltipicon.ImageColor3 = uipallet.Text
				tooltipicon.Parent = optionsettings.IconParent
			end
			optionsettings.Function(self.Enabled)
		end
		targetbutton.MouseEnter:Connect(function()
			if not optionapi.Enabled then
				tween:Tween(bkg, uipallet.Tween, {BackgroundColor3 = Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, math.max(mainapi.GUIColor.Value - 0.25, 0))})
				tween:Tween(icon, uipallet.Tween, {ImageColor3 = Color3.new(1, 1, 1)})
			end
		end)
		targetbutton.MouseLeave:Connect(function()
			if not optionapi.Enabled then
				tween:Tween(bkg, uipallet.Tween, {BackgroundColor3 = uipallet.Secondary})
				tween:Tween(icon, uipallet.Tween, {ImageColor3 = color.Light(uipallet.Main, 0.37)})
			end
		end)
		targetbutton.MouseButton1Click:Connect(function()
			optionapi:Toggle()
		end)
		optionapi.Object = targetbutton
		return optionapi
	end,
	Targets = function(optionsettings, children, api)
		local optionapi = {
			Type = 'Targets',
			Index = getTableSize(api.Options)
		}
		local textlist = newOptionBase('Targets', 50, children, optionsettings.Darker, optionsettings.Visible, optionsettings.Tooltip)
		local bkg = Instance.new('Frame')
		bkg.Name = 'BKG'
		bkg.Size = UDim2.new(1, -20, 1, -9)
		bkg.Position = UDim2.fromOffset(10, 4)
		bkg.BackgroundColor3 = color.Light(uipallet.Main, 0.034)
		bkg.Parent = textlist
		addCorner(bkg, UDim.new(0, 6))
		addStroke(bkg, uipallet.Inner, 1)
		local button = Instance.new('TextButton')
		button.Name = 'TextList'
		button.Size = UDim2.new(1, -2, 1, -2)
		button.Position = UDim2.fromOffset(1, 1)
		button.BackgroundColor3 = uipallet.Secondary
		button.AutoButtonColor = false
		button.Text = ''
		button.Parent = bkg
		local buttontitle = Instance.new('TextLabel')
		buttontitle.Name = 'Title'
		buttontitle.Size = UDim2.new(1, -5, 0, 15)
		buttontitle.Position = UDim2.fromOffset(5, 6)
		buttontitle.BackgroundTransparency = 1
		buttontitle.Text = 'Target:'
		buttontitle.TextXAlignment = Enum.TextXAlignment.Left
		buttontitle.TextColor3 = uipallet.Text
		buttontitle.TextSize = 14
		buttontitle.TextTruncate = Enum.TextTruncate.AtEnd
		buttontitle.FontFace = uipallet.Font
		buttontitle.Parent = button
		local items = buttontitle:Clone()
		items.Name = 'Items'
		items.Position = UDim2.fromOffset(5, 21)
		items.Text = 'Ignore none'
		items.TextColor3 = uipallet.TextDim
		items.TextSize = 11
		items.Parent = button
		addCorner(button, UDim.new(0, 4))
		local tool = Instance.new('Frame')
		tool.Size = UDim2.fromOffset(65, 12)
		tool.Position = UDim2.fromOffset(52, 8)
		tool.BackgroundTransparency = 1
		tool.Parent = button
		local toollist = Instance.new('UIListLayout')
		toollist.FillDirection = Enum.FillDirection.Horizontal
		toollist.Padding = UDim.new(0, 6)
		toollist.Parent = tool
		local window, close = newWindow('TargetsTextWindow', 220, 145, clickgui, 'Target settings', getcustomasset('volt/assets/targetstab.png'), UDim2.fromOffset(18, 12))
		optionapi.Window = window
		optionsettings.Function = optionsettings.Function or function() end
		local function ignoretext()
			local text = 'none'
			if optionapi.Invisible.Enabled then
				text = 'invisible'
			end
			if optionapi.Walls.Enabled then
				text = text == 'none' and 'behind walls' or text .. ', behind walls'
			end
			items.Text = 'Ignore ' .. text
			optionsettings.Function()
		end
		function optionapi:Save(tab)
			tab.Targets = {
				Players = self.Players.Enabled,
				NPCs = self.NPCs.Enabled,
				Invisible = self.Invisible.Enabled,
				Walls = self.Walls.Enabled
			}
		end
		function optionapi:Load(tab)
			if self.Players.Enabled ~= tab.Players then
				self.Players:Toggle()
			end
			if self.NPCs.Enabled ~= tab.NPCs then
				self.NPCs:Toggle()
			end
			if self.Invisible.Enabled ~= tab.Invisible then
				self.Invisible:Toggle()
			end
			if self.Walls.Enabled ~= tab.Walls then
				self.Walls:Toggle()
			end
		end
		function optionapi:Color(hue, sat, val, rainbowcheck)
			bkg.BackgroundColor3 = rainbowcheck and Color3.fromHSV(mainapi:Color((hue - (self.Index * 0.075)) % 1)) or Color3.fromHSV(hue, sat, val)
			if self.Players.Enabled then
				tween:Cancel(self.Players.Object.Frame)
				self.Players.Object.Frame.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
			end
			if self.NPCs.Enabled then
				tween:Cancel(self.NPCs.Object.Frame)
				self.NPCs.Object.Frame.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
			end
			if self.Invisible.Enabled then
				tween:Cancel(self.Invisible.Object.Knob)
				self.Invisible.Object.Knob.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
			end
			if self.Walls.Enabled then
				tween:Cancel(self.Walls.Object.Knob)
				self.Walls.Object.Knob.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
			end
		end
		optionapi.Players = components.TargetsButton({
			Position = UDim2.fromOffset(11, 45),
			Icon = getcustomasset('volt/assets/targetplayers1.png'),
			IconSize = UDim2.fromOffset(15, 16),
			IconParent = tool,
			ToolIcon = getcustomasset('volt/assets/targetplayers2.png'),
			ToolSize = UDim2.fromOffset(11, 12),
			Tooltip = 'Players',
			Function = optionsettings.Function
		}, window, tool)
		optionapi.NPCs = components.TargetsButton({
			Position = UDim2.fromOffset(112, 45),
			Icon = getcustomasset('volt/assets/targetnpc1.png'),
			IconSize = UDim2.fromOffset(12, 16),
			IconParent = tool,
			ToolIcon = getcustomasset('volt/assets/targetnpc2.png'),
			ToolSize = UDim2.fromOffset(9, 12),
			Tooltip = 'NPCs',
			Function = optionsettings.Function
		}, window, tool)
		optionapi.Invisible = components.Toggle({
			Name = 'Ignore invisible',
			Function = ignoretext
		}, window, {Options = {}})
		optionapi.Invisible.Object.Position = UDim2.fromOffset(0, 81)
		optionapi.Walls = components.Toggle({
			Name = 'Ignore behind walls',
			Function = ignoretext
		}, window, {Options = {}})
		optionapi.Walls.Object.Position = UDim2.fromOffset(0, 111)
		if optionsettings.Players then
			optionapi.Players:Toggle()
		end
		if optionsettings.NPCs then
			optionapi.NPCs:Toggle()
		end
		if optionsettings.Invisible then
			optionapi.Invisible:Toggle()
		end
		if optionsettings.Walls then
			optionapi.Walls:Toggle()
		end
		close.MouseButton1Click:Connect(function()
			window.Visible = false
		end)
		button.MouseButton1Click:Connect(function()
			window.Visible = not window.Visible
			tween:Cancel(bkg)
			bkg.BackgroundColor3 = window.Visible and Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value) or color.Light(uipallet.Main, 0.37)
		end)
		textlist.MouseEnter:Connect(function()
			if not optionapi.Window.Visible then
				tween:Tween(bkg, uipallet.Tween, {BackgroundColor3 = color.Light(uipallet.Main, 0.37)})
			end
		end)
		textlist.MouseLeave:Connect(function()
			if not optionapi.Window.Visible then
				tween:Tween(bkg, uipallet.Tween, {BackgroundColor3 = color.Light(uipallet.Main, 0.034)})
			end
		end)
		textlist:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
			if mainapi.ThreadFix then
				setthreadidentity(8)
			end
			local actualPosition = (textlist.AbsolutePosition + Vector2.new(0, 60)) / scale.Scale
			window.Position = UDim2.fromOffset(actualPosition.X + 220, actualPosition.Y)
		end)
		optionapi.Object = textlist
		api.Options.Targets = optionapi
		return optionapi
	end,
	TextBox = function(optionsettings, children, api)
		local optionapi = {
			Type = 'TextBox',
			Value = optionsettings.Default or '',
			Index = 0
		}
		local textbox = newOptionBase(optionsettings.Name .. 'TextBox', 58, children, optionsettings.Darker, optionsettings.Visible, optionsettings.Tooltip)
		local title = Instance.new('TextLabel')
		title.Size = UDim2.new(1, -10, 0, 20)
		title.Position = UDim2.fromOffset(10, 3)
		title.BackgroundTransparency = 1
		title.Text = optionsettings.Name
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.TextColor3 = uipallet.Text
		title.TextSize = 12
		title.FontFace = uipallet.Font
		title.Parent = textbox
		local bkg = Instance.new('Frame')
		bkg.Name = 'BKG'
		bkg.Size = UDim2.new(1, -20, 0, 29)
		bkg.Position = UDim2.fromOffset(10, 23)
		bkg.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
		bkg.Parent = textbox
		addCorner(bkg, UDim.new(0, 6))
		addStroke(bkg, uipallet.Inner, 1)
		local box = Instance.new('TextBox')
		box.Size = UDim2.new(1, -8, 1, 0)
		box.Position = UDim2.fromOffset(8, 0)
		box.BackgroundTransparency = 1
		box.Text = optionsettings.Default or ''
		box.PlaceholderText = optionsettings.Placeholder or 'Click to set'
		box.TextXAlignment = Enum.TextXAlignment.Left
		box.TextColor3 = uipallet.Text
		box.PlaceholderColor3 = uipallet.TextDim
		box.TextSize = 12
		box.FontFace = uipallet.Font
		box.ClearTextOnFocus = false
		box.Parent = bkg
		optionsettings.Function = optionsettings.Function or function() end
		function optionapi:Save(tab)
			tab[optionsettings.Name] = {Value = self.Value}
		end
		function optionapi:Load(tab)
			if self.Value ~= tab.Value then
				self:SetValue(tab.Value)
			end
		end
		function optionapi:SetValue(val, enter)
			self.Value = val
			box.Text = val
			optionsettings.Function(enter)
		end
		textbox.MouseButton1Click:Connect(function()
			box:CaptureFocus()
		end)
		box.FocusLost:Connect(function(enter)
			optionapi:SetValue(box.Text, enter)
		end)
		box:GetPropertyChangedSignal('Text'):Connect(function()
			optionapi:SetValue(box.Text)
		end)
		optionapi.Object = textbox
		api.Options[optionsettings.Name] = optionapi
		return optionapi
	end,
	TextList = function(optionsettings, children, api)
		local optionapi = {
			Type = 'TextList',
			List = optionsettings.Default or {},
			ListEnabled = optionsettings.Default or {},
			Objects = {},
			Window = {Visible = false},
			Index = getTableSize(api.Options)
		}
		optionsettings.Color = optionsettings.Color or Color3.fromRGB(80, 220, 120)
		local textlist = newOptionBase(optionsettings.Name .. 'TextList', 50, children, optionsettings.Darker, optionsettings.Visible, optionsettings.Tooltip)
		local bkg = Instance.new('Frame')
		bkg.Name = 'BKG'
		bkg.Size = UDim2.new(1, -20, 1, -9)
		bkg.Position = UDim2.fromOffset(10, 4)
		bkg.BackgroundColor3 = color.Light(uipallet.Main, 0.034)
		bkg.Parent = textlist
		addCorner(bkg, UDim.new(0, 6))
		addStroke(bkg, uipallet.Inner, 1)
		local button = Instance.new('TextButton')
		button.Name = 'TextList'
		button.Size = UDim2.new(1, -2, 1, -2)
		button.Position = UDim2.fromOffset(1, 1)
		button.BackgroundColor3 = uipallet.Secondary
		button.AutoButtonColor = false
		button.Text = ''
		button.Parent = bkg
		local buttonicon = Instance.new('ImageLabel')
		buttonicon.Name = 'Icon'
		buttonicon.Size = UDim2.fromOffset(14, 12)
		buttonicon.Position = UDim2.fromOffset(10, 14)
		buttonicon.BackgroundTransparency = 1
		buttonicon.Image = optionsettings.Icon or getcustomasset('volt/assets/allowedicon.png')
		buttonicon.Parent = button
		local buttontitle = Instance.new('TextLabel')
		buttontitle.Name = 'Title'
		buttontitle.Size = UDim2.new(1, -35, 0, 15)
		buttontitle.Position = UDim2.fromOffset(35, 6)
		buttontitle.BackgroundTransparency = 1
		buttontitle.Text = optionsettings.Name
		buttontitle.TextXAlignment = Enum.TextXAlignment.Left
		buttontitle.TextColor3 = uipallet.Text
		buttontitle.TextSize = 14
		buttontitle.TextTruncate = Enum.TextTruncate.AtEnd
		buttontitle.FontFace = uipallet.Font
		buttontitle.Parent = button
		local amount = buttontitle:Clone()
		amount.Name = 'Amount'
		amount.Size = UDim2.new(1, -13, 0, 15)
		amount.Position = UDim2.fromOffset(0, 6)
		amount.Text = '0'
		amount.TextXAlignment = Enum.TextXAlignment.Right
		amount.Parent = button
		local items = buttontitle:Clone()
		items.Name = 'Items'
		items.Position = UDim2.fromOffset(35, 21)
		items.Text = 'None'
		items.TextColor3 = uipallet.TextDim
		items.TextSize = 11
		items.Parent = button
		addCorner(button, UDim.new(0, 4))
		local window, close = newWindow(optionsettings.Name .. 'TextWindow', 220, 85, api.Legit and mainapi.Legit.Window or clickgui, optionsettings.Name, optionsettings.Tab or getcustomasset('volt/assets/allowedtab.png'), optionsettings.TabSize or UDim2.fromOffset(19, 16))
		optionapi.Window = window
		local addbkg = Instance.new('Frame')
		addbkg.Name = 'Add'
		addbkg.Size = UDim2.fromOffset(200, 31)
		addbkg.Position = UDim2.fromOffset(10, 45)
		addbkg.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
		addbkg.Parent = window
		addCorner(addbkg)
		local addbox = addbkg:Clone()
		addbox.Size = UDim2.new(1, -2, 1, -2)
		addbox.Position = UDim2.fromOffset(1, 1)
		addbox.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
		addbox.Parent = addbkg
		local addvalue = Instance.new('TextBox')
		addvalue.Size = UDim2.new(1, -35, 1, 0)
		addvalue.Position = UDim2.fromOffset(10, 0)
		addvalue.BackgroundTransparency = 1
		addvalue.Text = ''
		addvalue.PlaceholderText = optionsettings.Placeholder or 'Add entry...'
		addvalue.TextXAlignment = Enum.TextXAlignment.Left
		addvalue.TextColor3 = Color3.new(1, 1, 1)
		addvalue.TextSize = 14
		addvalue.FontFace = uipallet.Font
		addvalue.ClearTextOnFocus = false
		addvalue.Parent = addbkg
		local addbutton = Instance.new('ImageButton')
		addbutton.Name = 'AddButton'
		addbutton.Size = UDim2.fromOffset(16, 16)
		addbutton.Position = UDim2.new(1, -26, 0, 8)
		addbutton.BackgroundTransparency = 1
		addbutton.Image = getcustomasset('volt/assets/add.png')
		addbutton.ImageColor3 = optionsettings.Color
		addbutton.ImageTransparency = 0.3
		addbutton.Parent = addbkg
		optionsettings.Function = optionsettings.Function or function() end
		function optionapi:Save(tab)
			tab[optionsettings.Name] = {
				List = self.List,
				ListEnabled = self.ListEnabled
			}
		end
		function optionapi:Load(tab)
			self.List = tab.List or {}
			self.ListEnabled = tab.ListEnabled or {}
			self:ChangeValue()
		end
		function optionapi:Color(hue, sat, val, rainbowcheck)
			if window.Visible then
				bkg.BackgroundColor3 = rainbowcheck and Color3.fromHSV(mainapi:Color((hue - (self.Index * 0.075)) % 1)) or Color3.fromHSV(hue, sat, val)
			end
		end
		function optionapi:ChangeValue(val)
			if val then
				local ind = table.find(self.List, val)
				if ind then
					table.remove(self.List, ind)
					ind = table.find(self.ListEnabled, val)
					if ind then
						table.remove(self.ListEnabled, ind)
					end
				else
					table.insert(self.List, val)
					table.insert(self.ListEnabled, val)
				end
			end
			optionsettings.Function(self.List)
			for _, v in self.Objects do
				v:Destroy()
			end
			table.clear(self.Objects)
			window.Size = UDim2.fromOffset(220, 85 + (#self.List * 35))
			amount.Text = #self.List
			local enabledtext = 'None'
			for i, v in self.ListEnabled do
				if i == 1 then enabledtext = '' end
				enabledtext = enabledtext .. (i == 1 and v or ', ' .. v)
			end
			items.Text = enabledtext
			for i, v in self.List do
				local enabled = table.find(self.ListEnabled, v)
				local object = Instance.new('TextButton')
				object.Name = v
				object.Size = UDim2.fromOffset(200, 32)
				object.Position = UDim2.fromOffset(10, 47 + (i * 35))
				object.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
				object.AutoButtonColor = false
				object.Text = ''
				object.Parent = window
				addCorner(object)
				local objectbkg = Instance.new('Frame')
				objectbkg.Name = 'BKG'
				objectbkg.Size = UDim2.new(1, -2, 1, -2)
				objectbkg.Position = UDim2.fromOffset(1, 1)
				objectbkg.BackgroundColor3 = uipallet.Secondary
				objectbkg.Visible = false
				objectbkg.Parent = object
				addCorner(objectbkg)
				local objectdot = Instance.new('Frame')
				objectdot.Name = 'Dot'
				objectdot.Size = UDim2.fromOffset(10, 11)
				objectdot.Position = UDim2.fromOffset(10, 12)
				objectdot.BackgroundColor3 = enabled and optionsettings.Color or color.Light(uipallet.Main, 0.37)
				objectdot.Parent = object
				addCorner(objectdot, UDim.new(1, 0))
				local objectdotin = objectdot:Clone()
				objectdotin.Size = UDim2.fromOffset(8, 9)
				objectdotin.Position = UDim2.fromOffset(1, 1)
				objectdotin.BackgroundColor3 = enabled and optionsettings.Color or color.Light(uipallet.Main, 0.02)
				objectdotin.Parent = objectdot
				local objecttitle = Instance.new('TextLabel')
				objecttitle.Name = 'Title'
				objecttitle.Size = UDim2.new(1, -30, 1, 0)
				objecttitle.Position = UDim2.fromOffset(30, 0)
				objecttitle.BackgroundTransparency = 1
				objecttitle.Text = v
				objecttitle.TextXAlignment = Enum.TextXAlignment.Left
				objecttitle.TextColor3 = uipallet.Text
				objecttitle.TextSize = 14
				objecttitle.FontFace = uipallet.Font
				objecttitle.Parent = object
				local closemini = Instance.new('ImageButton')
				closemini.Name = 'Close'
				closemini.Size = UDim2.fromOffset(16, 16)
				closemini.Position = UDim2.new(1, -26, 0, 8)
				closemini.BackgroundColor3 = Color3.new(1, 1, 1)
				closemini.BackgroundTransparency = 1
				closemini.AutoButtonColor = false
				closemini.Image = getcustomasset('volt/assets/closemini.png')
				closemini.ImageColor3 = color.Light(uipallet.Text, 0.2)
				closemini.ImageTransparency = 0.5
				closemini.Parent = object
				addCorner(closemini, UDim.new(1, 0))
				closemini.MouseEnter:Connect(function()
					closemini.ImageTransparency = 0.3
					tween:Tween(closemini, uipallet.Tween, {BackgroundTransparency = 0.6})
				end)
				closemini.MouseLeave:Connect(function()
					closemini.ImageTransparency = 0.5
					tween:Tween(closemini, uipallet.Tween, {BackgroundTransparency = 1})
				end)
				closemini.MouseButton1Click:Connect(function()
					self:ChangeValue(v)
				end)
				object.MouseEnter:Connect(function()
					objectbkg.Visible = true
				end)
				object.MouseLeave:Connect(function()
					objectbkg.Visible = false
				end)
				object.MouseButton1Click:Connect(function()
					local ind = table.find(self.ListEnabled, v)
					if ind then
						table.remove(self.ListEnabled, ind)
						objectdot.BackgroundColor3 = color.Light(uipallet.Main, 0.37)
						objectdotin.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
					else
						table.insert(self.ListEnabled, v)
						objectdot.BackgroundColor3 = optionsettings.Color
						objectdotin.BackgroundColor3 = optionsettings.Color
					end
					local enabledtexttwo = 'None'
					for i2, v2 in self.ListEnabled do
						if i2 == 1 then enabledtexttwo = '' end
						enabledtexttwo = enabledtexttwo .. (i2 == 1 and v2 or ', ' .. v2)
					end
					items.Text = enabledtexttwo
					optionsettings.Function()
				end)
				table.insert(self.Objects, object)
			end
		end
		addbutton.MouseEnter:Connect(function()
			addbutton.ImageTransparency = 0
		end)
		addbutton.MouseLeave:Connect(function()
			addbutton.ImageTransparency = 0.3
		end)
		addbutton.MouseButton1Click:Connect(function()
			if not table.find(optionapi.List, addvalue.Text) then
				optionapi:ChangeValue(addvalue.Text)
				addvalue.Text = ''
			end
		end)
		addvalue.FocusLost:Connect(function(enter)
			if enter and not table.find(optionapi.List, addvalue.Text) then
				optionapi:ChangeValue(addvalue.Text)
				addvalue.Text = ''
			end
		end)
		hoverOn(addvalue, addbkg, {BackgroundColor3 = color.Light(uipallet.Main, 0.14)}, {BackgroundColor3 = color.Light(uipallet.Main, 0.02)})
		close.MouseButton1Click:Connect(function()
			window.Visible = false
		end)
		button.MouseButton1Click:Connect(function()
			window.Visible = not window.Visible
			tween:Cancel(bkg)
			bkg.BackgroundColor3 = window.Visible and Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value) or color.Light(uipallet.Main, 0.37)
		end)
		textlist.MouseEnter:Connect(function()
			if not optionapi.Window.Visible then
				tween:Tween(bkg, uipallet.Tween, {BackgroundColor3 = color.Light(uipallet.Main, 0.37)})
			end
		end)
		textlist.MouseLeave:Connect(function()
			if not optionapi.Window.Visible then
				tween:Tween(bkg, uipallet.Tween, {BackgroundColor3 = color.Light(uipallet.Main, 0.034)})
			end
		end)
		textlist:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
			if mainapi.ThreadFix then
				setthreadidentity(8)
			end
			local actualPosition = (textlist.AbsolutePosition - (api.Legit and mainapi.Legit.Window.AbsolutePosition or -guiService:GetGuiInset())) / scale.Scale
			window.Position = UDim2.fromOffset(actualPosition.X + 220, actualPosition.Y)
		end)
		if optionsettings.Default then
			optionapi:ChangeValue()
		end
		optionapi.Object = textlist
		api.Options[optionsettings.Name] = optionapi
		return optionapi
	end,
	Toggle = function(optionsettings, children, api)
		local optionapi = {
			Type = 'Toggle',
			Enabled = false,
			Index = getTableSize(api.Options)
		}
		local hovered = false
		local toggle = Instance.new('TextButton')
		toggle.Name = optionsettings.Name .. 'Toggle'
		toggle.Size = UDim2.new(1, 0, 0, 32)
		toggle.BackgroundColor3 = color.Dark(children.BackgroundColor3, optionsettings.Darker and 0.02 or 0)
		toggle.BorderSizePixel = 0
		toggle.AutoButtonColor = false
		toggle.Visible = optionsettings.Visible == nil or optionsettings.Visible
		toggle.Text = optionsettings.Name
		toggle.TextXAlignment = Enum.TextXAlignment.Left
		toggle.TextColor3 = uipallet.Text
		toggle.TextSize = 13
		toggle.FontFace = uipallet.Font
		toggle.Parent = children
		addTooltip(toggle, optionsettings.Tooltip)
		local knobholder = Instance.new('Frame')
		knobholder.Name = 'Knob'
		knobholder.Size = UDim2.fromOffset(24, 14)
		knobholder.Position = UDim2.new(1, -32, 0, 9)
		knobholder.BackgroundColor3 = color.Light(uipallet.Main, 0.14)
		knobholder.Parent = toggle
		addCorner(knobholder, UDim.new(1, 0))
		local knob = knobholder:Clone()
		knob.Size = UDim2.fromOffset(10, 10)
		knob.Position = UDim2.fromOffset(2, 2)
		knob.BackgroundColor3 = uipallet.Main
		knob.Parent = knobholder
		optionsettings.Function = optionsettings.Function or function() end
		function optionapi:Save(tab)
			tab[optionsettings.Name] = {Enabled = self.Enabled}
		end
		function optionapi:Load(tab)
			if self.Enabled ~= tab.Enabled then
				self:Toggle()
			end
		end
		function optionapi:Color(hue, sat, val, rainbowcheck)
			if self.Enabled then
				tween:Cancel(knobholder)
				knobholder.BackgroundColor3 = rainbowcheck and Color3.fromHSV(mainapi:Color((hue - (self.Index * 0.075)) % 1)) or Color3.fromHSV(hue, sat, val)
			end
		end
		function optionapi:Toggle()
			self.Enabled = not self.Enabled
			local rainbowcheck = mainapi.GUIColor.Rainbow and mainapi.RainbowMode.Value ~= 'Retro'
			tween:Tween(knobholder, uipallet.Tween, {
				BackgroundColor3 = self.Enabled and (rainbowcheck and Color3.fromHSV(mainapi:Color((mainapi.GUIColor.Hue - (self.Index * 0.075)) % 1)) or Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value)) or (hovered and color.Light(uipallet.Main, 0.37) or color.Light(uipallet.Main, 0.14))
			})
			tween:Tween(knob, uipallet.Tween, {
				Position = UDim2.fromOffset(self.Enabled and 12 or 2, 2)
			})
			optionsettings.Function(self.Enabled)
		end
		toggle.MouseEnter:Connect(function()
			hovered = true
			if not optionapi.Enabled then
				tween:Tween(knobholder, uipallet.Tween, {BackgroundColor3 = color.Light(uipallet.Main, 0.37)})
			end
		end)
		toggle.MouseLeave:Connect(function()
			hovered = false
			if not optionapi.Enabled then
				tween:Tween(knobholder, uipallet.Tween, {BackgroundColor3 = color.Light(uipallet.Main, 0.14)})
			end
		end)
		toggle.MouseButton1Click:Connect(function()
			optionapi:Toggle()
		end)
		if optionsettings.Default then
			optionapi:Toggle()
		end
		optionapi.Object = toggle
		api.Options[optionsettings.Name] = optionapi
		return optionapi
	end,
	TwoSlider = function(optionsettings, children, api)
		local range = math.max(optionsettings.Max - optionsettings.Min, 0.0001)
		local optionapi = {
			Type = 'TwoSlider',
			ValueMin = optionsettings.DefaultMin or optionsettings.Min,
			ValueMax = optionsettings.DefaultMax or optionsettings.Max,
			Max = optionsettings.Max,
			Index = getTableSize(api.Options)
		}
		local slider = newOptionBase(optionsettings.Name .. 'Slider', 50, children, optionsettings.Darker, optionsettings.Visible, optionsettings.Tooltip)
		newTitleLabel(slider, optionsettings.Name, UDim2.fromOffset(60, 30), UDim2.fromOffset(10, 2))
		local valuebutton = Instance.new('TextButton')
		valuebutton.Name = 'Value'
		valuebutton.Size = UDim2.fromOffset(60, 15)
		valuebutton.Position = UDim2.new(1, -69, 0, 9)
		valuebutton.BackgroundTransparency = 1
		valuebutton.Text = optionapi.ValueMax
		valuebutton.TextXAlignment = Enum.TextXAlignment.Right
		valuebutton.TextColor3 = uipallet.Text
		valuebutton.TextSize = 11
		valuebutton.FontFace = uipallet.Font
		valuebutton.Parent = slider
		local valuebutton2 = valuebutton:Clone()
		valuebutton2.Position = UDim2.new(1, -125, 0, 9)
		valuebutton2.Text = optionapi.ValueMin
		valuebutton2.Parent = slider
		local valuebox = Instance.new('TextBox')
		valuebox.Name = 'Box'
		valuebox.Size = valuebutton.Size
		valuebox.Position = valuebutton.Position
		valuebox.BackgroundTransparency = 1
		valuebox.Visible = false
		valuebox.Text = optionapi.ValueMin
		valuebox.TextXAlignment = Enum.TextXAlignment.Right
		valuebox.TextColor3 = uipallet.Text
		valuebox.TextSize = 11
		valuebox.FontFace = uipallet.Font
		valuebox.ClearTextOnFocus = false
		valuebox.Parent = slider
		local valuebox2 = valuebox:Clone()
		valuebox2.Position = valuebutton2.Position
		valuebox2.Parent = slider
		local bkg = Instance.new('Frame')
		bkg.Name = 'Slider'
		bkg.Size = UDim2.new(1, -20, 0, 4)
		bkg.Position = UDim2.fromOffset(10, 37)
		bkg.BackgroundColor3 = color.Light(uipallet.Main, 0.034)
		bkg.BorderSizePixel = 0
		bkg.Parent = slider
		addCorner(bkg, UDim.new(1, 0))
		local fill = bkg:Clone()
		fill.Name = 'Fill'
		fill.Position = UDim2.fromScale(math.clamp((optionapi.ValueMin - optionsettings.Min) / range, 0.04, 0.96), 0)
		fill.Size = UDim2.fromScale(math.clamp(math.clamp((optionapi.ValueMax - optionsettings.Min) / range, 0, 1), 0.04, 0.96) - fill.Position.X.Scale, 1)
		fill.BackgroundColor3 = Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value)
		fill.Parent = bkg
		local knobholder = Instance.new('Frame')
		knobholder.Name = 'Knob'
		knobholder.Size = UDim2.fromOffset(16, 4)
		knobholder.Position = UDim2.fromScale(0, 0.5)
		knobholder.AnchorPoint = Vector2.new(0.5, 0.5)
		knobholder.BackgroundColor3 = slider.BackgroundColor3
		knobholder.BorderSizePixel = 0
		knobholder.Parent = fill
		local knob = Instance.new('ImageLabel')
		knob.Name = 'Knob'
		knob.Size = UDim2.fromOffset(9, 16)
		knob.Position = UDim2.fromScale(0.5, 0.5)
		knob.AnchorPoint = Vector2.new(0.5, 0.5)
		knob.BackgroundTransparency = 1
		knob.Image = getcustomasset('volt/assets/range.png')
		knob.ImageColor3 = Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value)
		knob.Parent = knobholder
		local knobholdermax = knobholder:Clone()
		knobholdermax.Name = 'KnobMax'
		knobholdermax.Position = UDim2.fromScale(1, 0.5)
		knobholdermax.Parent = fill
		knobholdermax.Knob.Rotation = 180
		local arrow = Instance.new('ImageLabel')
		arrow.Name = 'Arrow'
		arrow.Size = UDim2.fromOffset(12, 6)
		arrow.Position = UDim2.new(1, -56, 0, 10)
		arrow.BackgroundTransparency = 1
		arrow.Image = getcustomasset('volt/assets/rangearrow.png')
		arrow.ImageColor3 = color.Light(uipallet.Main, 0.14)
		arrow.Parent = slider
		optionsettings.Function = optionsettings.Function or function() end
		optionsettings.Decimal = optionsettings.Decimal or 1
		local random = Random.new()
		function optionapi:Save(tab)
			tab[optionsettings.Name] = {ValueMin = self.ValueMin, ValueMax = self.ValueMax}
		end
		function optionapi:Load(tab)
			if self.ValueMin ~= tab.ValueMin then
				self:SetValue(false, tab.ValueMin)
			end
			if self.ValueMax ~= tab.ValueMax then
				self:SetValue(true, tab.ValueMax)
			end
		end
		function optionapi:Color(hue, sat, val, rainbowcheck)
			fill.BackgroundColor3 = rainbowcheck and Color3.fromHSV(mainapi:Color((hue - (self.Index * 0.075)) % 1)) or Color3.fromHSV(hue, sat, val)
			knob.ImageColor3 = fill.BackgroundColor3
			knobholdermax.Knob.ImageColor3 = fill.BackgroundColor3
		end
		function optionapi:GetRandomValue()
			return random:NextNumber(optionapi.ValueMin, optionapi.ValueMax)
		end
		function optionapi:SetValue(max, value)
			if tonumber(value) == math.huge or value ~= value then return end
			value = math.clamp(value, optionsettings.Min, optionsettings.Max)
			if max then
				self.ValueMax = math.max(value, self.ValueMin)
			else
				self.ValueMin = math.min(value, self.ValueMax)
			end
			valuebutton.Text = self.ValueMax
			valuebutton2.Text = self.ValueMin
			local size = math.clamp((self.ValueMin - optionsettings.Min) / range, 0.04, 0.96)
			tween:Tween(fill, TweenInfo.new(0.1), {
				Position = UDim2.fromScale(size, 0),
				Size = UDim2.fromScale(math.clamp(math.clamp((self.ValueMax - optionsettings.Min) / range, 0.04, 0.96) - size, 0, 1), 1)
			})
			optionsettings.Function(self.ValueMin, self.ValueMax)
		end
		hoverOn(knobholder, knob, {Size = UDim2.fromOffset(11, 18)}, {Size = UDim2.fromOffset(9, 16)})
		hoverOn(knobholdermax, knobholdermax.Knob, {Size = UDim2.fromOffset(11, 18)}, {Size = UDim2.fromOffset(9, 16)})
		slider.InputBegan:Connect(function(inputObj)
			if (inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch) and (inputObj.Position.Y - slider.AbsolutePosition.Y) > (20 * scale.Scale) then
				local maxCheck = (inputObj.Position.X - knobholdermax.AbsolutePosition.X) > -10
				local newPosition = math.clamp((inputObj.Position.X - bkg.AbsolutePosition.X) / bkg.AbsoluteSize.X, 0, 1)
				optionapi:SetValue(maxCheck, math.floor((optionsettings.Min + range * newPosition) * optionsettings.Decimal) / optionsettings.Decimal)
				local changed = inputService.InputChanged:Connect(function(input)
					if input.UserInputType == (inputObj.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
						local newPositiontwo = math.clamp((input.Position.X - bkg.AbsolutePosition.X) / bkg.AbsoluteSize.X, 0, 1)
						optionapi:SetValue(maxCheck, math.floor((optionsettings.Min + range * newPositiontwo) * optionsettings.Decimal) / optionsettings.Decimal)
					end
				end)
				local ended
				ended = inputObj.Changed:Connect(function()
					if inputObj.UserInputState == Enum.UserInputState.End then
						if changed then changed:Disconnect() end
						if ended then ended:Disconnect() end
					end
				end)
			end
		end)
		valuebutton.MouseButton1Click:Connect(function()
			valuebutton.Visible = false
			valuebox.Visible = true
			valuebox.Text = optionapi.ValueMax
			valuebox:CaptureFocus()
		end)
		valuebutton2.MouseButton1Click:Connect(function()
			valuebutton2.Visible = false
			valuebox2.Visible = true
			valuebox2.Text = optionapi.ValueMin
			valuebox2:CaptureFocus()
		end)
		valuebox.FocusLost:Connect(function(enter)
			valuebutton.Visible = true
			valuebox.Visible = false
			if enter and tonumber(valuebox.Text) then
				optionapi:SetValue(true, tonumber(valuebox.Text))
			end
		end)
		valuebox2.FocusLost:Connect(function(enter)
			valuebutton2.Visible = true
			valuebox2.Visible = false
			if enter and tonumber(valuebox2.Text) then
				optionapi:SetValue(false, tonumber(valuebox2.Text))
			end
		end)
		optionapi.Object = slider
		api.Options[optionsettings.Name] = optionapi
		return optionapi
	end,
	Divider = function(children, text)
		local divider = Instance.new('Frame')
		divider.Name = 'Divider'
		divider.Size = UDim2.new(1, 0, 0, 1)
		divider.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
		divider.BorderSizePixel = 0
		divider.Parent = children
		if text then
			local label = Instance.new('TextLabel')
			label.Name = 'DividerLabel'
			label.Size = UDim2.new(1, 0, 0, 27)
			label.BackgroundTransparency = 1
			label.Text = text:upper()
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextColor3 = uipallet.TextDim
			label.TextSize = 9
			label.FontFace = uipallet.Font
			label.Parent = children
			divider.Position = UDim2.fromOffset(0, 26)
			divider.Parent = label
		end
	end
}
mainapi.Components = setmetatable(components, {
	__newindex = function(self, ind, func)
		for _, v in mainapi.Modules do
			rawset(v, 'Create' .. ind, function(_, settings)
				return func(settings, v.Children, v)
			end)
		end
		if mainapi.Legit then
			for _, v in mainapi.Legit.Modules do
				rawset(v, 'Create' .. ind, function(_, settings)
					return func(settings, v.Children, v)
				end)
			end
		end
		rawset(self, ind, func)
	end
})
task.spawn(function()
	repeat
		local hue = tick() * (0.2 * mainapi.RainbowSpeed.Value) % 1
		for _, v in mainapi.RainbowTable do
			if v.Type == 'GUISlider' then
				v:SetValue(mainapi:Color(hue))
			else
				v:SetValue(hue)
			end
		end
		task.wait(1 / mainapi.RainbowUpdateSpeed.Value)
	until mainapi.Loaded == nil
end)
function mainapi:BlurCheck()
	if self.ThreadFix then
		setthreadidentity(8)
		runService:SetRobloxGuiFocused((clickgui.Visible or guiService:GetErrorType() ~= Enum.ConnectionError.OK) and self.Blur.Enabled)
	end
end
addMaid(mainapi)
function mainapi:CreateGUI()
	local categoryapi = {
		Type = 'MainWindow',
		Buttons = {},
		Options = {}
	}
	local window = Instance.new('TextButton')
	window.Name = 'GUICategory'
	window.Position = UDim2.fromOffset(6, 60)
	window.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
	window.AutoButtonColor = false
	window.Text = ''
	window.Parent = clickgui
	addBlur(window)
	addCorner(window, UDim.new(0, 8))
	addStroke(window, uipallet.Outline, 1)
	makeDraggable(window)
	local logo = Instance.new('ImageLabel')
	logo.Name = 'VoltLogo'
	logo.Size = UDim2.fromOffset(62, 18)
	logo.Position = UDim2.fromOffset(11, 10)
	logo.BackgroundTransparency = 1
	logo.Image = getcustomasset('volt/assets/guivolt.png')
	logo.ImageColor3 = select(3, uipallet.Main:ToHSV()) > 0.5 and uipallet.Text or Color3.new(1, 1, 1)
	logo.Parent = window
	local logov5 = Instance.new('ImageLabel')
	logov5.Name = 'V5Logo'
	logov5.Size = UDim2.fromOffset(28, 16)
	logov5.Position = UDim2.new(1, 1, 0, 1)
	logov5.BackgroundTransparency = 1
	logov5.Image = getcustomasset('volt/assets/guiv4.png')
	logov5.Parent = logo
	local children = Instance.new('Frame')
	children.Name = 'Children'
	children.Size = UDim2.new(1, 0, 1, -37)
	children.Position = UDim2.fromOffset(0, 37)
	children.BackgroundTransparency = 1
	children.Parent = window
	local windowlist = Instance.new('UIListLayout')
	windowlist.SortOrder = Enum.SortOrder.LayoutOrder
	windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
	windowlist.Parent = children
	local settingsbutton = Instance.new('TextButton')
	settingsbutton.Name = 'Settings'
	settingsbutton.Size = UDim2.fromOffset(40, 40)
	settingsbutton.Position = UDim2.new(1, -40, 0, 0)
	settingsbutton.BackgroundTransparency = 1
	settingsbutton.Text = ''
	settingsbutton.Parent = window
	addTooltip(settingsbutton, 'Open settings')
	local settingsicon = Instance.new('ImageLabel')
	settingsicon.Size = UDim2.fromOffset(14, 14)
	settingsicon.Position = UDim2.fromOffset(15, 12)
	settingsicon.BackgroundTransparency = 1
	settingsicon.Image = getcustomasset('volt/assets/guisettings.png')
	settingsicon.ImageColor3 = color.Light(uipallet.Main, 0.37)
	settingsicon.Parent = settingsbutton
	local settingspane = Instance.new('TextButton')
	settingspane.Size = UDim2.fromScale(1, 1)
	settingspane.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
	settingspane.AutoButtonColor = false
	settingspane.Visible = false
	settingspane.Text = ''
	settingspane.Parent = window
	newTitleLabel(settingspane, 'Settings', UDim2.new(1, -36, 0, 20), UDim2.fromOffset(36, 11), uipallet.Text, 13)
	local close = addCloseButton(settingspane)
	local back = Instance.new('ImageButton')
	back.Name = 'Back'
	back.Size = UDim2.fromOffset(16, 16)
	back.Position = UDim2.fromOffset(11, 13)
	back.BackgroundTransparency = 1
	back.Image = getcustomasset('volt/assets/back.png')
	back.ImageColor3 = color.Light(uipallet.Main, 0.37)
	back.Parent = settingspane
	local settingsversion = Instance.new('TextLabel')
	settingsversion.Name = 'Version'
	settingsversion.Size = UDim2.new(1, 0, 0, 16)
	settingsversion.Position = UDim2.new(0, 0, 1, -16)
	settingsversion.BackgroundTransparency = 1
	settingsversion.Text = 'Volt UI ' .. mainapi.Version
	settingsversion.TextColor3 = uipallet.TextDim
	settingsversion.TextXAlignment = Enum.TextXAlignment.Right
	settingsversion.TextSize = 10
	settingsversion.FontFace = uipallet.Font
	settingsversion.Parent = settingspane
	addCorner(settingspane, UDim.new(0, 8))
	addStroke(settingspane, uipallet.Outline, 1)
	local settingschildren = Instance.new('Frame')
	settingschildren.Name = 'Children'
	settingschildren.Size = UDim2.new(1, 0, 1, -57)
	settingschildren.Position = UDim2.fromOffset(0, 41)
	settingschildren.BackgroundColor3 = uipallet.Main
	settingschildren.BorderSizePixel = 0
	settingschildren.Parent = settingspane
	local settingswindowlist = Instance.new('UIListLayout')
	settingswindowlist.SortOrder = Enum.SortOrder.LayoutOrder
	settingswindowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
	settingswindowlist.Parent = settingschildren
	categoryapi.Object = window
	function categoryapi:CreateBind()
		local optionapi = {Bind = {'RightShift'}}
		local button = Instance.new('TextButton')
		button.Size = UDim2.fromOffset(220, 40)
		button.BackgroundColor3 = uipallet.Main
		button.BorderSizePixel = 0
		button.AutoButtonColor = false
		button.Text = 'Rebind GUI'
		button.TextXAlignment = Enum.TextXAlignment.Left
		button.TextColor3 = uipallet.Text
		button.TextSize = 13
		button.FontFace = uipallet.Font
		button.Parent = settingschildren
		addTooltip(button, 'Change the bind of the GUI')
		local bind = Instance.new('TextButton')
		bind.Name = 'Bind'
		bind.Size = UDim2.fromOffset(20, 21)
		bind.Position = UDim2.new(1, -10, 0, 9)
		bind.AnchorPoint = Vector2.new(1, 0)
		bind.BackgroundColor3 = Color3.new(1, 1, 1)
		bind.BackgroundTransparency = 0.92
		bind.BorderSizePixel = 0
		bind.AutoButtonColor = false
		bind.Text = ''
		bind.Parent = button
		addTooltip(bind, 'Click to bind')
		addCorner(bind, UDim.new(0, 4))
		local icon = Instance.new('ImageLabel')
		icon.Name = 'Icon'
		icon.Size = UDim2.fromOffset(12, 12)
		icon.Position = UDim2.new(0.5, -6, 0, 5)
		icon.BackgroundTransparency = 1
		icon.Image = getcustomasset('volt/assets/bind.png')
		icon.ImageColor3 = uipallet.TextDim
		icon.Parent = bind
		local label = Instance.new('TextLabel')
		label.Name = 'Text'
		label.Size = UDim2.fromScale(1, 1)
		label.Position = UDim2.fromOffset(0, 1)
		label.BackgroundTransparency = 1
		label.Visible = false
		label.Text = ''
		label.TextColor3 = uipallet.TextDim
		label.TextSize = 12
		label.FontFace = uipallet.Font
		label.Parent = bind
		function optionapi:SetBind(tab)
			mainapi.Keybind = #tab <= 0 and mainapi.Keybind or table.clone(tab)
			self.Bind = mainapi.Keybind
			if mainapi.VoltButton then
				mainapi.VoltButton:Destroy()
				mainapi.VoltButton = nil
			end
			bind.Visible = true
			label.Visible = true
			icon.Visible = false
			label.Text = table.concat(mainapi.Keybind, ' + '):upper()
			bind.Size = UDim2.fromOffset(math.max(getfontsize(label.Text, label.TextSize, label.Font).X + 10, 20), 21)
		end
		bind.MouseEnter:Connect(function()
			label.Visible = false
			icon.Visible = true
			icon.Image = getcustomasset('volt/assets/edit.png')
			icon.ImageColor3 = uipallet.Text
		end)
		bind.MouseLeave:Connect(function()
			label.Visible = true
			icon.Visible = false
			icon.Image = getcustomasset('volt/assets/bind.png')
			icon.ImageColor3 = uipallet.TextDim
		end)
		bind.MouseButton1Click:Connect(function()
			mainapi.Binding = optionapi
		end)
		categoryapi.Options.Bind = optionapi
		return optionapi
	end
	function categoryapi:CreateButton(categorysettings)
		local optionapi = {
			Enabled = false,
			Index = getTableSize(categoryapi.Buttons)
		}
		local button = Instance.new('TextButton')
		button.Name = categorysettings.Name
		button.Size = UDim2.fromOffset(220, 40)
		button.BackgroundColor3 = uipallet.Main
		button.BorderSizePixel = 0
		button.AutoButtonColor = false
		button.Text = (categorysettings.Icon and string.rep(' ', 33) or string.rep(' ', 28)) .. categorysettings.Name
		button.TextXAlignment = Enum.TextXAlignment.Left
		button.TextColor3 = uipallet.Text
		button.TextSize = 13
		button.FontFace = uipallet.Font
		button.Parent = children
		local icon
		if categorysettings.Icon then
			icon = Instance.new('ImageLabel')
			icon.Name = 'Icon'
			icon.Size = categorysettings.Size
			icon.Position = UDim2.fromOffset(13, 13)
			icon.BackgroundTransparency = 1
			icon.Image = categorysettings.Icon
			icon.ImageColor3 = uipallet.TextDim
			icon.Parent = button
		end
		if categorysettings.Name == 'Profiles' then
			local label = Instance.new('TextLabel')
			label.Name = 'ProfileLabel'
			label.Size = UDim2.fromOffset(53, 24)
			label.Position = UDim2.new(1, -36, 0, 8)
			label.AnchorPoint = Vector2.new(1, 0)
			label.BackgroundColor3 = color.Light(uipallet.Main, 0.04)
			label.Text = 'default'
			label.TextColor3 = uipallet.TextDim
			label.TextSize = 12
			label.FontFace = uipallet.Font
			label.Parent = button
			addCorner(label)
			mainapi.ProfileLabel = label
		end
		local arrow = Instance.new('ImageLabel')
		arrow.Name = 'Arrow'
		arrow.Size = UDim2.fromOffset(4, 8)
		arrow.Position = UDim2.new(1, -20, 0, 16)
		arrow.BackgroundTransparency = 1
		arrow.Image = getcustomasset('volt/assets/expandright.png')
		arrow.ImageColor3 = color.Light(uipallet.Main, 0.37)
		arrow.Parent = button
		optionapi.Name = categorysettings.Name
		optionapi.Icon = icon
		optionapi.Object = button
		function optionapi:Toggle()
			self.Enabled = not self.Enabled
			tween:Tween(arrow, uipallet.Tween, {
				Position = UDim2.new(1, self.Enabled and -14 or -20, 0, 16)
			})
			button.TextColor3 = self.Enabled and Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value) or uipallet.Text
			if icon then
				icon.ImageColor3 = button.TextColor3
			end
			button.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
			categorysettings.Window.Visible = self.Enabled
		end
		button.MouseEnter:Connect(function()
			if not optionapi.Enabled then
				button.TextColor3 = uipallet.Text
				if icon then icon.ImageColor3 = uipallet.Text end
				button.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
			end
		end)
		button.MouseLeave:Connect(function()
			if not optionapi.Enabled then
				button.TextColor3 = uipallet.TextDim
				if icon then icon.ImageColor3 = uipallet.TextDim end
				button.BackgroundColor3 = uipallet.Main
			end
		end)
		button.MouseButton1Click:Connect(function()
			optionapi:Toggle()
		end)
		categoryapi.Buttons[categorysettings.Name] = optionapi
		return optionapi
	end
	function categoryapi:CreateDivider(text)
		return components.Divider(children, text)
	end
	function categoryapi:CreateOverlayBar()
		local optionapi = {Toggles = {}}
		local bar = Instance.new('Frame')
		bar.Name = 'Overlays'
		bar.Size = UDim2.fromOffset(220, 36)
		bar.BackgroundColor3 = uipallet.Main
		bar.BorderSizePixel = 0
		bar.Parent = children
		components.Divider(bar)
		local button = Instance.new('ImageButton')
		button.Size = UDim2.fromOffset(24, 24)
		button.Position = UDim2.new(1, -29, 0, 7)
		button.BackgroundTransparency = 1
		button.AutoButtonColor = false
		button.Image = getcustomasset('volt/assets/overlaysicon.png')
		button.ImageColor3 = color.Light(uipallet.Main, 0.37)
		button.Parent = bar
		addCorner(button, UDim.new(1, 0))
		addTooltip(button, 'Open overlays menu')
		local shadow = Instance.new('TextButton')
		shadow.Name = 'Shadow'
		shadow.Size = UDim2.new(1, 0, 1, -5)
		shadow.BackgroundColor3 = Color3.new()
		shadow.BackgroundTransparency = 1
		shadow.AutoButtonColor = false
		shadow.ClipsDescendants = true
		shadow.Visible = false
		shadow.Text = ''
		shadow.Parent = window
		addCorner(shadow)
		local overlaywindow = Instance.new('Frame')
		overlaywindow.Size = UDim2.fromOffset(220, 42)
		overlaywindow.Position = UDim2.fromScale(0, 1)
		overlaywindow.BackgroundColor3 = uipallet.Main
		overlaywindow.Parent = shadow
		addCorner(overlaywindow)
		local icon = Instance.new('ImageLabel')
		icon.Name = 'Icon'
		icon.Size = UDim2.fromOffset(14, 12)
		icon.Position = UDim2.fromOffset(10, 13)
		icon.BackgroundTransparency = 1
		icon.Image = getcustomasset('volt/assets/overlaystab.png')
		icon.ImageColor3 = uipallet.Text
		icon.Parent = overlaywindow
		newTitleLabel(overlaywindow, 'Overlays', UDim2.new(1, -36, 0, 38), UDim2.fromOffset(36, 0), uipallet.Text, 14)
		local overlayclose = addCloseButton(overlaywindow, 7)
		local divider = Instance.new('Frame')
		divider.Name = 'Divider'
		divider.Size = UDim2.new(1, 0, 0, 1)
		divider.Position = UDim2.fromOffset(0, 37)
		divider.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
		divider.BorderSizePixel = 0
		divider.Parent = overlaywindow
		local childrentoggle = Instance.new('Frame')
		childrentoggle.Position = UDim2.fromOffset(0, 38)
		childrentoggle.BackgroundTransparency = 1
		childrentoggle.Parent = overlaywindow
		local overlaylist = Instance.new('UIListLayout')
		overlaylist.SortOrder = Enum.SortOrder.LayoutOrder
		overlaylist.HorizontalAlignment = Enum.HorizontalAlignment.Center
		overlaylist.Parent = childrentoggle
		function optionapi:CreateToggle(togglesettings)
			local toggleapi = {
				Enabled = false,
				Index = getTableSize(optionapi.Toggles)
			}
			local hovered = false
			local toggle = Instance.new('TextButton')
			toggle.Name = togglesettings.Name .. 'Toggle'
			toggle.Size = UDim2.new(1, 0, 0, 40)
			toggle.BackgroundTransparency = 1
			toggle.AutoButtonColor = false
			toggle.Text = string.rep(' ', math.floor(33 * scale.Scale)) .. togglesettings.Name
			toggle.TextXAlignment = Enum.TextXAlignment.Left
			toggle.TextColor3 = uipallet.Text
			toggle.TextSize = 13
			toggle.FontFace = uipallet.Font
			toggle.Parent = childrentoggle
			local toggleicon = Instance.new('ImageLabel')
			toggleicon.Name = 'Icon'
			toggleicon.Size = togglesettings.Size
			toggleicon.Position = togglesettings.Position
			toggleicon.BackgroundTransparency = 1
			toggleicon.Image = togglesettings.Icon
			toggleicon.ImageColor3 = uipallet.Text
			toggleicon.Parent = toggle
			local knob = Instance.new('Frame')
			knob.Name = 'Knob'
			knob.Size = UDim2.fromOffset(24, 14)
			knob.Position = UDim2.new(1, -32, 0, 14)
			knob.BackgroundColor3 = color.Light(uipallet.Main, 0.14)
			knob.Parent = toggle
			addCorner(knob, UDim.new(1, 0))
			local knobmain = knob:Clone()
			knobmain.Size = UDim2.fromOffset(10, 10)
			knobmain.Position = UDim2.fromOffset(2, 2)
			knobmain.BackgroundColor3 = uipallet.Main
			knobmain.Parent = knob
			toggleapi.Object = toggle
			function toggleapi:Toggle()
				self.Enabled = not self.Enabled
				tween:Tween(knob, uipallet.Tween, {
					BackgroundColor3 = self.Enabled and Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value) or (hovered and color.Light(uipallet.Main, 0.37) or color.Light(uipallet.Main, 0.14))
				})
				tween:Tween(knobmain, uipallet.Tween, {
					Position = UDim2.fromOffset(self.Enabled and 12 or 2, 2)
				})
				togglesettings.Function(self.Enabled)
			end
			scale:GetPropertyChangedSignal('Scale'):Connect(function()
				toggle.Text = string.rep(' ', math.floor(33 * scale.Scale)) .. togglesettings.Name
			end)
			toggle.MouseEnter:Connect(function()
				hovered = true
				if not toggleapi.Enabled then
					tween:Tween(knob, uipallet.Tween, {BackgroundColor3 = color.Light(uipallet.Main, 0.37)})
				end
			end)
			toggle.MouseLeave:Connect(function()
				hovered = false
				if not toggleapi.Enabled then
					tween:Tween(knob, uipallet.Tween, {BackgroundColor3 = color.Light(uipallet.Main, 0.14)})
				end
			end)
			toggle.MouseButton1Click:Connect(function()
				toggleapi:Toggle()
			end)
			table.insert(optionapi.Toggles, toggleapi)
			return toggleapi
		end
		hoverOn(button, button, {ImageColor3 = uipallet.Text, BackgroundTransparency = 0.9}, {ImageColor3 = color.Light(uipallet.Main, 0.37), BackgroundTransparency = 1})
		button.MouseButton1Click:Connect(function()
			shadow.Visible = true
			tween:Tween(shadow, uipallet.Tween, {BackgroundTransparency = 0.5})
			tween:Tween(overlaywindow, uipallet.Tween, {Position = UDim2.new(0, 0, 1, -(overlaywindow.Size.Y.Offset))})
		end)
		local function hideshadow()
			tween:Tween(shadow, uipallet.Tween, {BackgroundTransparency = 1})
			tween:Tween(overlaywindow, uipallet.Tween, {Position = UDim2.fromScale(0, 1)})
			task.wait(0.2)
			shadow.Visible = false
		end
		overlayclose.MouseButton1Click:Connect(hideshadow)
		shadow.MouseButton1Click:Connect(hideshadow)
		overlaylist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			if mainapi.ThreadFix then
				setthreadidentity(8)
			end
			overlaywindow.Size = UDim2.fromOffset(220, math.min(37 + overlaylist.AbsoluteContentSize.Y / scale.Scale, 605))
			childrentoggle.Size = UDim2.fromOffset(220, overlaywindow.Size.Y.Offset - 5)
		end)
		mainapi.Overlays = optionapi
		return optionapi
	end
	function categoryapi:CreateSettingsDivider()
		components.Divider(settingschildren)
	end
	function categoryapi:CreateSettingsPane(categorysettings)
		local optionapi = {}
		local button = Instance.new('TextButton')
		button.Name = categorysettings.Name
		button.Size = UDim2.fromOffset(220, 40)
		button.BackgroundColor3 = uipallet.Main
		button.BorderSizePixel = 0
		button.AutoButtonColor = false
		button.Text = string.rep(' ', 28) .. categorysettings.Name
		button.TextXAlignment = Enum.TextXAlignment.Left
		button.TextColor3 = uipallet.Text
		button.TextSize = 13
		button.FontFace = uipallet.Font
		button.Parent = settingschildren
		local arrow = Instance.new('ImageLabel')
		arrow.Name = 'Arrow'
		arrow.Size = UDim2.fromOffset(4, 8)
		arrow.Position = UDim2.new(1, -20, 0, 16)
		arrow.BackgroundTransparency = 1
		arrow.Image = getcustomasset('volt/assets/expandright.png')
		arrow.ImageColor3 = color.Light(uipallet.Main, 0.37)
		arrow.Parent = button
		local panewindow = Instance.new('TextButton')
		panewindow.Size = UDim2.fromScale(1, 1)
		panewindow.BackgroundColor3 = uipallet.Main
		panewindow.AutoButtonColor = false
		panewindow.Visible = false
		panewindow.Text = ''
		panewindow.Parent = window
		newTitleLabel(panewindow, categorysettings.Name, UDim2.new(1, -36, 0, 20), UDim2.fromOffset(36, 11), uipallet.Text, 13)
		local paneclose = addCloseButton(panewindow)
		local paneback = Instance.new('ImageButton')
		paneback.Name = 'Back'
		paneback.Size = UDim2.fromOffset(16, 16)
		paneback.Position = UDim2.fromOffset(11, 13)
		paneback.BackgroundTransparency = 1
		paneback.Image = getcustomasset('volt/assets/back.png')
		paneback.ImageColor3 = color.Light(uipallet.Main, 0.37)
		paneback.Parent = panewindow
		addCorner(panewindow, UDim.new(0, 8))
		addStroke(panewindow, uipallet.Outline, 1)
		local panesettingschildren = Instance.new('Frame')
		panesettingschildren.Name = 'Children'
		panesettingschildren.Size = UDim2.new(1, 0, 1, -57)
		panesettingschildren.Position = UDim2.fromOffset(0, 41)
		panesettingschildren.BackgroundColor3 = uipallet.Main
		panesettingschildren.BorderSizePixel = 0
		panesettingschildren.Parent = panewindow
		local panedivider = Instance.new('Frame')
		panedivider.Name = 'Divider'
		panedivider.Size = UDim2.new(1, 0, 0, 1)
		panedivider.BackgroundColor3 = Color3.new(1, 1, 1)
		panedivider.BackgroundTransparency = 0.928
		panedivider.BorderSizePixel = 0
		panedivider.Parent = panesettingschildren
		local panewindowlist = Instance.new('UIListLayout')
		panewindowlist.SortOrder = Enum.SortOrder.LayoutOrder
		panewindowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
		panewindowlist.Parent = panesettingschildren
		for i, v in components do
			optionapi['Create' .. i] = function(_, settings)
				return v(settings, panesettingschildren, categoryapi)
			end
		end
		hoverOn(paneback, paneback, {ImageColor3 = uipallet.Text}, {ImageColor3 = color.Light(uipallet.Main, 0.37)})
		paneback.MouseButton1Click:Connect(function()
			panewindow.Visible = false
		end)
		hoverOn(button, button, {TextColor3 = uipallet.Text, BackgroundColor3 = color.Light(uipallet.Main, 0.02)}, {TextColor3 = uipallet.TextDim, BackgroundColor3 = uipallet.Main})
		button.MouseButton1Click:Connect(function()
			panewindow.Visible = true
		end)
		paneclose.MouseButton1Click:Connect(function()
			panewindow.Visible = false
		end)
		windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			if self.ThreadFix then
				setthreadidentity(8)
			end
			window.Size = UDim2.fromOffset(220, 45 + windowlist.AbsoluteContentSize.Y / scale.Scale)
			for _, v in categoryapi.Buttons do
				if v.Icon then
					v.Object.Text = string.rep(' ', math.floor(33 * scale.Scale)) .. v.Name
				end
			end
		end)
		return optionapi
	end
	function categoryapi:CreateGUISlider(optionsettings)
		local optionapi = {
			Type = 'GUISlider',
			Notch = 1,
			Hue = 0,
			Sat = 0,
			Value = 0.86,
			Rainbow = false,
			CustomColor = false
		}
		local slidercolors = {
			Color3.fromRGB(238, 238, 238),
			Color3.fromRGB(160, 160, 160),
			Color3.fromRGB(96, 96, 96),
			Color3.fromRGB(224, 96, 96),
			Color3.fromRGB(235, 170, 80),
			Color3.fromRGB(110, 200, 140),
			Color3.fromRGB(110, 160, 220)
		}
		local slidercolorpos = {4, 33, 62, 90, 119, 148, 177}
		local function createSlider(name, gradientColor)
			local slider = Instance.new('TextButton')
			slider.Name = optionsettings.Name .. 'Slider' .. name
			slider.Size = UDim2.fromOffset(220, 50)
			slider.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
			slider.BorderSizePixel = 0
			slider.AutoButtonColor = false
			slider.Visible = false
			slider.Text = ''
			slider.Parent = settingschildren
			newTitleLabel(slider, name, UDim2.fromOffset(60, 30), UDim2.fromOffset(10, 2))
			local holder, fill, knobframe, knob = newTrack(slider, 37, gradientColor)
			holder.Size = UDim2.fromOffset(200, 4)
			fill.Size = UDim2.fromScale(1, 1)
			knobframe.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
			if name == 'Custom color' then
				local reset = Instance.new('TextButton')
				reset.Size = UDim2.fromOffset(45, 20)
				reset.Position = UDim2.new(1, -52, 0, 5)
				reset.BackgroundTransparency = 1
				reset.Text = 'RESET'
				reset.TextColor3 = uipallet.TextDim
				reset.TextSize = 11
				reset.FontFace = uipallet.Font
				reset.Parent = slider
				reset.MouseButton1Click:Connect(function()
					optionapi:SetValue(nil, nil, nil, 1)
				end)
			end
			attachTrackDrag(slider, holder, 20, function(value)
				optionapi:SetValue(
					name == 'Custom color' and value or nil,
					name == 'Saturation' and value or nil,
					name == 'Vibrance' and value or nil
				)
			end)
			hoverOn(slider, knob, {Size = UDim2.fromOffset(16, 16)}, {Size = UDim2.fromOffset(14, 14)})
			return slider
		end
		local slider = Instance.new('TextButton')
		slider.Name = optionsettings.Name .. 'Slider'
		slider.Size = UDim2.fromOffset(220, 50)
		slider.BackgroundTransparency = 1
		slider.AutoButtonColor = false
		slider.Text = ''
		slider.Parent = settingschildren
		newTitleLabel(slider, optionsettings.Name, UDim2.fromOffset(60, 30), UDim2.fromOffset(10, 2))
		local holder = Instance.new('Frame')
		holder.Name = 'Slider'
		holder.Size = UDim2.fromOffset(200, 4)
		holder.Position = UDim2.fromOffset(10, 37)
		holder.BackgroundTransparency = 1
		holder.BorderSizePixel = 0
		holder.Parent = slider
		addCorner(holder, UDim.new(1, 0))
		local colornum = 0
		for i, swatch in slidercolors do
			local colorframe = Instance.new('Frame')
			colorframe.Size = UDim2.fromOffset(27 + (((i + 1) % 2) == 0 and 1 or 0), 4)
			colorframe.Position = UDim2.fromOffset(colornum, 0)
			colorframe.BackgroundColor3 = swatch
			colorframe.BorderSizePixel = 0
			colorframe.Parent = holder
			colornum += (colorframe.Size.X.Offset + 1)
		end
		local preview = Instance.new('ImageButton')
		preview.Name = 'Preview'
		preview.Size = UDim2.fromOffset(14, 14)
		preview.Position = UDim2.new(1, -24, 0, 10)
		preview.BackgroundTransparency = 1
		preview.Image = getcustomasset('volt/assets/colorpreview.png')
		preview.ImageColor3 = Color3.fromHSV(optionapi.Hue, optionapi.Sat, optionapi.Value)
		preview.Parent = slider
		local valuebox = Instance.new('TextBox')
		valuebox.Name = 'Box'
		valuebox.Size = UDim2.fromOffset(60, 15)
		valuebox.Position = UDim2.new(1, -69, 0, 9)
		valuebox.BackgroundTransparency = 1
		valuebox.Visible = false
		valuebox.Text = ''
		valuebox.TextXAlignment = Enum.TextXAlignment.Right
		valuebox.TextColor3 = uipallet.Text
		valuebox.TextSize = 11
		valuebox.FontFace = uipallet.Font
		valuebox.ClearTextOnFocus = true
		valuebox.Parent = slider
		local expandbutton = Instance.new('TextButton')
		expandbutton.Name = 'Expand'
		expandbutton.Size = UDim2.fromOffset(17, 13)
		expandbutton.Position = UDim2.new(0, getfontsize(optionsettings.Name, 11, uipallet.Font).X + 11, 0, 7)
		expandbutton.BackgroundTransparency = 1
		expandbutton.Text = ''
		expandbutton.Parent = slider
		local expandicon = Instance.new('ImageLabel')
		expandicon.Name = 'Expand'
		expandicon.Size = UDim2.fromOffset(9, 5)
		expandicon.Position = UDim2.fromOffset(4, 4)
		expandicon.BackgroundTransparency = 1
		expandicon.Image = getcustomasset('volt/assets/expandicon.png')
		expandicon.ImageColor3 = uipallet.TextDim
		expandicon.Parent = expandbutton
		local rainbow = Instance.new('TextButton')
		rainbow.Name = 'Rainbow'
		rainbow.Size = UDim2.fromOffset(14, 14)
		rainbow.Position = UDim2.new(1, -44, 0, 10)
		rainbow.BackgroundTransparency = 1
		rainbow.Text = ''
		rainbow.Parent = slider
		local rainbow1 = Instance.new('ImageLabel')
		rainbow1.Size = UDim2.fromOffset(14, 14)
		rainbow1.BackgroundTransparency = 1
		rainbow1.Image = getcustomasset('volt/assets/rainbow_1.png')
		rainbow1.ImageColor3 = color.Light(uipallet.Main, 0.37)
		rainbow1.Parent = rainbow
		local rainbow2 = rainbow1:Clone()
		rainbow2.Image = getcustomasset('volt/assets/rainbow_2.png')
		rainbow2.Parent = rainbow
		local rainbow3 = rainbow1:Clone()
		rainbow3.Image = getcustomasset('volt/assets/rainbow_3.png')
		rainbow3.Parent = rainbow
		local rainbow4 = rainbow1:Clone()
		rainbow4.Image = getcustomasset('volt/assets/rainbow_4.png')
		rainbow4.Parent = rainbow
		local knob = Instance.new('ImageLabel')
		knob.Name = 'Knob'
		knob.Size = UDim2.fromOffset(26, 12)
		knob.Position = UDim2.fromOffset(slidercolorpos[1] - 3, -4)
		knob.BackgroundTransparency = 1
		knob.Image = getcustomasset('volt/assets/guislider.png')
		knob.ImageColor3 = slidercolors[1]
		knob.Parent = holder
		optionsettings.Function = optionsettings.Function or function() end
		local rainbowTable = {}
		for i = 0, 1, 0.1 do
			table.insert(rainbowTable, ColorSequenceKeypoint.new(i, Color3.fromHSV(i, 1, 1)))
		end
		local colorSlider = createSlider('Custom color', ColorSequence.new(rainbowTable))
		local satSlider = createSlider('Saturation', ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, optionapi.Value)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(optionapi.Hue, 1, optionapi.Value))
		}))
		local vibSlider = createSlider('Vibrance', ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(optionapi.Hue, optionapi.Sat, 1))
		}))
		local normalknob = getcustomasset('volt/assets/guislider.png')
		local rainbowknob = getcustomasset('volt/assets/guisliderrain.png')
		local rainbowthread
		function optionapi:Save(tab)
			tab[optionsettings.Name] = {
				Hue = self.Hue,
				Sat = self.Sat,
				Value = self.Value,
				Notch = self.Notch,
				CustomColor = self.CustomColor,
				Rainbow = self.Rainbow
			}
		end
		function optionapi:Load(tab)
			if tab.Rainbow then
				self:Toggle()
			end
			if self.Rainbow or tab.CustomColor then
				self:SetValue(tab.Hue, tab.Sat, tab.Value)
			else
				self:SetValue(nil, nil, nil, tab.Notch)
			end
		end
		function optionapi:SetValue(h, s, v, n)
			if n then
				if self.Rainbow then
					self:Toggle()
				end
				self.CustomColor = false
				h, s, v = slidercolors[n]:ToHSV()
			else
				self.CustomColor = true
			end
			self.Hue = h or self.Hue
			self.Sat = s or self.Sat
			self.Value = v or self.Value
			self.Notch = n
			preview.ImageColor3 = Color3.fromHSV(self.Hue, self.Sat, self.Value)
			satSlider.Slider.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, self.Value)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV(self.Hue, 1, self.Value))
			})
			vibSlider.Slider.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV(self.Hue, self.Sat, 1))
			})
			if self.Rainbow or self.CustomColor then
				knob.Image = rainbowknob
				knob.ImageColor3 = Color3.new(1, 1, 1)
				tween:Tween(knob, uipallet.Tween, {Position = UDim2.fromOffset(slidercolorpos[1] - 3, -4)})
			else
				knob.Image = normalknob
				knob.ImageColor3 = Color3.fromHSV(self.Hue, self.Sat, self.Value)
				tween:Tween(knob, uipallet.Tween, {Position = UDim2.fromOffset(slidercolorpos[n or 1] - 3, -4)})
			end
			if self.Rainbow then
				if h then
					colorSlider.Slider.Fill.Size = UDim2.fromScale(math.clamp(self.Hue, 0.04, 0.96), 1)
				end
				if s then
					satSlider.Slider.Fill.Size = UDim2.fromScale(math.clamp(self.Sat, 0.04, 0.96), 1)
				end
				if v then
					vibSlider.Slider.Fill.Size = UDim2.fromScale(math.clamp(self.Value, 0.04, 0.96), 1)
				end
			else
				if h then
					tween:Tween(colorSlider.Slider.Fill, uipallet.Tween, {Size = UDim2.fromScale(math.clamp(self.Hue, 0.04, 0.96), 1)})
				end
				if s then
					tween:Tween(satSlider.Slider.Fill, uipallet.Tween, {Size = UDim2.fromScale(math.clamp(self.Sat, 0.04, 0.96), 1)})
				end
				if v then
					tween:Tween(vibSlider.Slider.Fill, uipallet.Tween, {Size = UDim2.fromScale(math.clamp(self.Value, 0.04, 0.96), 1)})
				end
			end
			optionsettings.Function(self.Hue, self.Sat, self.Value)
		end
		function optionapi:Toggle()
			self.Rainbow = not self.Rainbow
			if rainbowthread then
				task.cancel(rainbowthread)
			end
			if self.Rainbow then
				knob.Image = rainbowknob
				table.insert(mainapi.RainbowTable, self)
				rainbowStagger({rainbow1, rainbow2, rainbow3}, true, function()
					return self.Rainbow
				end)
			else
				self:SetValue(nil, nil, nil, 1)
				knob.Image = normalknob
				local ind = table.find(mainapi.RainbowTable, self)
				if ind then
					table.remove(mainapi.RainbowTable, ind)
				end
				rainbowStagger({rainbow1, rainbow2, rainbow3}, false, function()
					return self.Rainbow
				end)
			end
		end
		hoverOn(expandbutton, expandicon, {ImageColor3 = uipallet.Text}, {ImageColor3 = uipallet.TextDim})
		expandbutton.MouseButton1Click:Connect(function()
			colorSlider.Visible = not colorSlider.Visible
			satSlider.Visible = colorSlider.Visible
			vibSlider.Visible = satSlider.Visible
			expandicon.Rotation = satSlider.Visible and 180 or 0
		end)
		preview.MouseButton1Click:Connect(function()
			preview.Visible = false
			valuebox.Visible = true
			valuebox:CaptureFocus()
			local text = Color3.fromHSV(optionapi.Hue, optionapi.Sat, optionapi.Value)
			valuebox.Text = math.round(text.R * 255) .. ', ' .. math.round(text.G * 255) .. ', ' .. math.round(text.B * 255)
		end)
		slider.InputBegan:Connect(function(inputObj)
			if (inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch) and (inputObj.Position.Y - slider.AbsolutePosition.Y) > (20 * scale.Scale) then
				local notch = math.clamp(math.round((inputObj.Position.X - holder.AbsolutePosition.X) / scale.Scale / 27), 1, 7)
				optionapi:SetValue(nil, nil, nil, notch)
				local changed = inputService.InputChanged:Connect(function(input)
					if input.UserInputType == (inputObj.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
						optionapi:SetValue(nil, nil, nil, math.clamp(math.round((input.Position.X - holder.AbsolutePosition.X) / scale.Scale / 27), 1, 7))
					end
				end)
				local ended
				ended = inputObj.Changed:Connect(function()
					if inputObj.UserInputState == Enum.UserInputState.End then
						if changed then changed:Disconnect() end
						if ended then ended:Disconnect() end
					end
				end)
			end
		end)
		rainbow.MouseButton1Click:Connect(function()
			optionapi:Toggle()
		end)
		valuebox.FocusLost:Connect(function(enter)
			preview.Visible = true
			valuebox.Visible = false
			if enter then
				local commas = valuebox.Text:split(',')
				local suc, res = pcall(function()
					return tonumber(commas[1]) and Color3.fromRGB(tonumber(commas[1]), tonumber(commas[2]), tonumber(commas[3])) or Color3.fromHex(valuebox.Text)
				end)
				if suc then
					if optionapi.Rainbow then
						optionapi:Toggle()
					end
					optionapi:SetValue(res:ToHSV())
				end
			end
		end)
		optionapi.Object = slider
		categoryapi.Options[optionsettings.Name] = optionapi
		return optionapi
	end
	hoverOn(settingsbutton, settingsicon, {ImageColor3 = uipallet.Text}, {ImageColor3 = color.Light(uipallet.Main, 0.37)})
	settingsbutton.MouseButton1Click:Connect(function()
		settingspane.Visible = true
	end)
	close.MouseButton1Click:Connect(function()
		settingspane.Visible = false
	end)
	back.MouseButton1Click:Connect(function()
		settingspane.Visible = false
	end)
	windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		if self.ThreadFix then
			setthreadidentity(8)
		end
		window.Size = UDim2.fromOffset(220, 37 + windowlist.AbsoluteContentSize.Y / scale.Scale)
		for _, v in categoryapi.Buttons do
			if v.Icon then
				v.Object.Text = string.rep(' ', math.floor(36 * scale.Scale)) .. v.Name
			end
		end
	end)
	self.Categories.Main = categoryapi
	return categoryapi
end
function mainapi:CreateCategory(categorysettings)
	local categoryapi = {
		Type = 'Category',
		Expanded = false
	}
	local window = Instance.new('TextButton')
	window.Name = categorysettings.Name .. 'Category'
	window.Size = UDim2.fromOffset(220, 41)
	window.Position = UDim2.fromOffset(236, 60)
	window.BackgroundColor3 = uipallet.Main
	window.AutoButtonColor = false
	window.Visible = false
	window.Text = ''
	window.Parent = clickgui
	addBlur(window)
	addCorner(window, UDim.new(0, 8))
	addStroke(window, uipallet.Outline, 1)
	makeDraggable(window)
	local icon = Instance.new('ImageLabel')
	icon.Name = 'Icon'
	icon.Size = categorysettings.Size
	icon.Position = UDim2.fromOffset(12, (icon.Size.X.Offset > 20 and 14 or 13))
	icon.BackgroundTransparency = 1
	icon.Image = categorysettings.Icon
	icon.ImageColor3 = uipallet.Text
	icon.Parent = window
	local title = Instance.new('TextLabel')
	title.Name = 'Title'
	title.Size = UDim2.new(1, -(categorysettings.Size.X.Offset > 18 and 40 or 33), 0, 41)
	title.Position = UDim2.fromOffset(math.abs(title.Size.X.Offset), 0)
	title.BackgroundTransparency = 1
	title.Text = categorysettings.Name
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = uipallet.Text
	title.TextSize = 13
	title.FontFace = uipallet.Font
	title.Parent = window
	local arrowbutton = Instance.new('TextButton')
	arrowbutton.Name = 'Arrow'
	arrowbutton.Size = UDim2.fromOffset(40, 40)
	arrowbutton.Position = UDim2.new(1, -40, 0, 0)
	arrowbutton.BackgroundTransparency = 1
	arrowbutton.Text = ''
	arrowbutton.Parent = window
	local arrow = Instance.new('ImageLabel')
	arrow.Name = 'Arrow'
	arrow.Size = UDim2.fromOffset(9, 4)
	arrow.Position = UDim2.fromOffset(20, 18)
	arrow.BackgroundTransparency = 1
	arrow.Image = getcustomasset('volt/assets/expandup.png')
	arrow.ImageColor3 = Color3.fromRGB(140, 140, 140)
	arrow.Rotation = 180
	arrow.Parent = arrowbutton
	local children = Instance.new('ScrollingFrame')
	children.Name = 'Children'
	children.Size = UDim2.new(1, 0, 1, -41)
	children.Position = UDim2.fromOffset(0, 41)
	children.BackgroundTransparency = 1
	children.BorderSizePixel = 0
	children.Visible = false
	children.ScrollBarThickness = 2
	children.ScrollBarImageTransparency = 0.75
	children.CanvasSize = UDim2.new()
	children.Parent = window
	local divider = Instance.new('Frame')
	divider.Name = 'Divider'
	divider.Size = UDim2.new(1, 0, 0, 1)
	divider.Position = UDim2.fromOffset(0, 41)
	divider.BackgroundColor3 = Color3.new(1, 1, 1)
	divider.BackgroundTransparency = 0.928
	divider.BorderSizePixel = 0
	divider.Visible = false
	divider.Parent = window
	local windowlist = Instance.new('UIListLayout')
	windowlist.SortOrder = Enum.SortOrder.LayoutOrder
	windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
	windowlist.Parent = children
	function categoryapi:CreateModule(modulesettings)
		mainapi:Remove(modulesettings.Name)
		local moduleapi = {
			Enabled = false,
			Options = {},
			Bind = {},
			Index = getTableSize(mainapi.Modules),
			ExtraText = modulesettings.ExtraText,
			Name = modulesettings.Name,
			Category = categorysettings.Name
		}
		local hovered = false
		local modulebutton = Instance.new('TextButton')
		modulebutton.Name = modulesettings.Name
		modulebutton.Size = UDim2.fromOffset(220, 40)
		modulebutton.BackgroundColor3 = uipallet.Main
		modulebutton.BorderSizePixel = 0
		modulebutton.AutoButtonColor = false
		modulebutton.Text = string.rep(' ', 30) .. modulesettings.Name
		modulebutton.TextXAlignment = Enum.TextXAlignment.Left
		modulebutton.TextColor3 = uipallet.Text
		modulebutton.TextSize = 13
		modulebutton.FontFace = uipallet.Font
		modulebutton.Parent = children
		local gradient = Instance.new('UIGradient')
		gradient.Rotation = 90
		gradient.Enabled = false
		gradient.Parent = modulebutton
		local modulechildren = Instance.new('Frame')
		local bind = Instance.new('TextButton')
		addTooltip(modulebutton, modulesettings.Tooltip)
		addTooltip(bind, 'Click to bind')
		bind.Name = 'Bind'
		bind.Size = UDim2.fromOffset(20, 21)
		bind.Position = UDim2.new(1, -36, 0, 9)
		bind.AnchorPoint = Vector2.new(1, 0)
		bind.BackgroundColor3 = Color3.new(1, 1, 1)
		bind.BackgroundTransparency = 0.92
		bind.BorderSizePixel = 0
		bind.AutoButtonColor = false
		bind.Visible = false
		bind.Text = ''
		addCorner(bind, UDim.new(0, 4))
		local bindicon = Instance.new('ImageLabel')
		bindicon.Name = 'Icon'
		bindicon.Size = UDim2.fromOffset(12, 12)
		bindicon.Position = UDim2.new(0.5, -6, 0, 5)
		bindicon.BackgroundTransparency = 1
		bindicon.Image = getcustomasset('volt/assets/bind.png')
		bindicon.ImageColor3 = uipallet.TextDim
		bindicon.Parent = bind
		local bindtext = Instance.new('TextLabel')
		bindtext.Size = UDim2.fromScale(1, 1)
		bindtext.Position = UDim2.fromOffset(0, 1)
		bindtext.BackgroundTransparency = 1
		bindtext.Visible = false
		bindtext.Text = ''
		bindtext.TextColor3 = uipallet.TextDim
		bindtext.TextSize = 12
		bindtext.FontFace = uipallet.Font
		bindtext.Parent = bind
		local bindcover = Instance.new('ImageLabel')
		bindcover.Name = 'Cover'
		bindcover.Size = UDim2.fromOffset(154, 40)
		bindcover.BackgroundTransparency = 1
		bindcover.Visible = false
		bindcover.Image = getcustomasset('volt/assets/bindbkg.png')
		bindcover.ScaleType = Enum.ScaleType.Slice
		bindcover.SliceCenter = Rect.new(0, 0, 141, 40)
		bindcover.Parent = modulebutton
		local bindcovertext = Instance.new('TextLabel')
		bindcovertext.Name = 'Text'
		bindcovertext.Size = UDim2.new(1, -10, 1, -3)
		bindcovertext.BackgroundTransparency = 1
		bindcovertext.Text = 'PRESS A KEY TO BIND'
		bindcovertext.TextColor3 = uipallet.Text
		bindcovertext.TextSize = 11
		bindcovertext.FontFace = uipallet.Font
		bindcovertext.Parent = bindcover
		bind.Parent = modulebutton
		local dotsbutton = Instance.new('TextButton')
		dotsbutton.Name = 'Dots'
		dotsbutton.Size = UDim2.fromOffset(25, 40)
		dotsbutton.Position = UDim2.new(1, -25, 0, 0)
		dotsbutton.BackgroundTransparency = 1
		dotsbutton.Text = ''
		dotsbutton.Parent = modulebutton
		local dots = Instance.new('ImageLabel')
		dots.Name = 'Dots'
		dots.Size = UDim2.fromOffset(3, 16)
		dots.Position = UDim2.fromOffset(4, 12)
		dots.BackgroundTransparency = 1
		dots.Image = getcustomasset('volt/assets/dots.png')
		dots.ImageColor3 = color.Light(uipallet.Main, 0.37)
		dots.Parent = dotsbutton
		modulechildren.Name = modulesettings.Name .. 'Children'
		modulechildren.Size = UDim2.new(1, 0, 0, 0)
		modulechildren.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
		modulechildren.BorderSizePixel = 0
		modulechildren.Visible = false
		modulechildren.Parent = children
		moduleapi.Children = modulechildren
		local modulelist = Instance.new('UIListLayout')
		modulelist.SortOrder = Enum.SortOrder.LayoutOrder
		modulelist.HorizontalAlignment = Enum.HorizontalAlignment.Center
		modulelist.Parent = modulechildren
		local moduledivider = Instance.new('Frame')
		moduledivider.Name = 'Divider'
		moduledivider.Size = UDim2.new(1, 0, 0, 1)
		moduledivider.Position = UDim2.new(0, 0, 1, -1)
		moduledivider.BackgroundColor3 = Color3.new(0.19, 0.19, 0.19)
		moduledivider.BackgroundTransparency = 0.52
		moduledivider.BorderSizePixel = 0
		moduledivider.Visible = false
		moduledivider.Parent = modulebutton
		modulesettings.Function = modulesettings.Function or function() end
		addMaid(moduleapi)
		function moduleapi:SetBind(tab, mouse)
			if tab.Mobile then
				createMobileButton(moduleapi, Vector2.new(tab.X, tab.Y))
				return
			end
			self.Bind = table.clone(tab)
			if mouse then
				bindcovertext.Text = #tab <= 0 and 'BIND REMOVED' or 'BOUND TO'
				bindcover.Size = UDim2.fromOffset(getfontsize(bindcovertext.Text, bindcovertext.TextSize).X + 20, 40)
				task.delay(1, function()
					bindcover.Visible = false
				end)
			end
			if #tab <= 0 then
				bindtext.Visible = false
				bindicon.Visible = true
				bind.Size = UDim2.fromOffset(20, 21)
			else
				bind.Visible = true
				bindtext.Visible = true
				bindicon.Visible = false
				bindtext.Text = table.concat(tab, ' + '):upper()
				bind.Size = UDim2.fromOffset(math.max(getfontsize(bindtext.Text, bindtext.TextSize, bindtext.Font).X + 10, 20), 21)
			end
		end
		function moduleapi:Toggle(multiple)
			if mainapi.ThreadFix then
				setthreadidentity(8)
			end
			self.Enabled = not self.Enabled
			moduledivider.Visible = self.Enabled
			gradient.Enabled = self.Enabled
			modulebutton.TextColor3 = (hovered or modulechildren.Visible) and uipallet.Text or uipallet.TextDim
			modulebutton.BackgroundColor3 = (hovered or modulechildren.Visible) and color.Light(uipallet.Main, 0.02) or uipallet.Main
			dots.ImageColor3 = self.Enabled and Color3.fromRGB(50, 50, 50) or color.Light(uipallet.Main, 0.37)
			bindicon.ImageColor3 = uipallet.TextDim
			bindtext.TextColor3 = uipallet.TextDim
			if not self.Enabled then
				for _, v in self.Connections do
					v:Disconnect()
				end
				table.clear(self.Connections)
			end
			if not multiple then
				mainapi:UpdateTextGUI()
			end
			task.spawn(modulesettings.Function, self.Enabled)
		end
		for i, v in components do
			moduleapi['Create' .. i] = function(_, optionsettings)
				return v(optionsettings, modulechildren, moduleapi)
			end
		end
		bind.MouseEnter:Connect(function()
			bindtext.Visible = false
			bindicon.Visible = true
			bindicon.Image = getcustomasset('volt/assets/edit.png')
			if not moduleapi.Enabled then bindicon.ImageColor3 = uipallet.Text end
		end)
		bind.MouseLeave:Connect(function()
			bindtext.Visible = #moduleapi.Bind > 0
			bindicon.Visible = not bindtext.Visible
			bindicon.Image = getcustomasset('volt/assets/bind.png')
			if not moduleapi.Enabled then
				bindicon.ImageColor3 = uipallet.TextDim
			end
		end)
		bind.MouseButton1Click:Connect(function()
			bindcovertext.Text = 'PRESS A KEY TO BIND'
			bindcover.Size = UDim2.fromOffset(getfontsize(bindcovertext.Text, bindcovertext.TextSize).X + 20, 40)
			bindcover.Visible = true
			mainapi.Binding = moduleapi
		end)
		dotsbutton.MouseButton1Click:Connect(function()
			modulechildren.Visible = not modulechildren.Visible
		end)
		dotsbutton.MouseButton2Click:Connect(function()
			modulechildren.Visible = not modulechildren.Visible
		end)
		modulebutton.MouseEnter:Connect(function()
			hovered = true
			if not moduleapi.Enabled and not modulechildren.Visible then
				modulebutton.TextColor3 = uipallet.Text
				modulebutton.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
			end
			bind.Visible = #moduleapi.Bind > 0 or hovered or modulechildren.Visible
		end)
		modulebutton.MouseLeave:Connect(function()
			hovered = false
			if not moduleapi.Enabled and not modulechildren.Visible then
				modulebutton.TextColor3 = uipallet.TextDim
				modulebutton.BackgroundColor3 = uipallet.Main
			end
			bind.Visible = #moduleapi.Bind > 0 or hovered or modulechildren.Visible
		end)
		modulebutton.MouseButton1Click:Connect(function()
			moduleapi:Toggle()
		end)
		modulebutton.MouseButton2Click:Connect(function()
			modulechildren.Visible = not modulechildren.Visible
		end)
		if inputService.TouchEnabled then
			local heldbutton = false
			modulebutton.MouseButton1Down:Connect(function()
				heldbutton = true
				local holdtime, holdpos = tick(), inputService:GetMouseLocation()
				repeat
					heldbutton = (inputService:GetMouseLocation() - holdpos).Magnitude < 3
					task.wait()
				until (tick() - holdtime) > 1 or not heldbutton or not clickgui.Visible
				if heldbutton and clickgui.Visible then
					if mainapi.ThreadFix then
						setthreadidentity(8)
					end
					clickgui.Visible = false
					tooltip.Visible = false
					mainapi:BlurCheck()
					for _, mobileButton in mainapi.Modules do
						if mobileButton.Bind.Button then
							mobileButton.Bind.Button.Visible = true
						end
					end
					local touchconnection
					touchconnection = inputService.InputBegan:Connect(function(inputType)
						if inputType.UserInputType == Enum.UserInputType.Touch then
							if mainapi.ThreadFix then
								setthreadidentity(8)
							end
							createMobileButton(moduleapi, inputType.Position + Vector3.new(0, guiService:GetGuiInset().Y, 0))
							clickgui.Visible = true
							mainapi:BlurCheck()
							for _, mobileButton in mainapi.Modules do
								if mobileButton.Bind.Button then
									mobileButton.Bind.Button.Visible = false
								end
							end
							touchconnection:Disconnect()
						end
					end)
				end
			end)
			modulebutton.MouseButton1Up:Connect(function()
				heldbutton = false
			end)
		end
		modulelist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			if mainapi.ThreadFix then
				setthreadidentity(8)
			end
			modulechildren.Size = UDim2.new(1, 0, 0, modulelist.AbsoluteContentSize.Y / scale.Scale)
		end)
		moduleapi.Object = modulebutton
		mainapi.Modules[modulesettings.Name] = moduleapi
		local sorting = {}
		for _, v in mainapi.Modules do
			sorting[v.Category] = sorting[v.Category] or {}
			table.insert(sorting[v.Category], v.Name)
		end
		for _, sort in sorting do
			table.sort(sort)
			for i, v in sort do
				mainapi.Modules[v].Index = i
				mainapi.Modules[v].Object.LayoutOrder = i
				mainapi.Modules[v].Children.LayoutOrder = i
			end
		end
		return moduleapi
	end
	function categoryapi:Expand()
		self.Expanded = not self.Expanded
		children.Visible = self.Expanded
		arrow.Rotation = self.Expanded and 0 or 180
		window.Size = UDim2.fromOffset(220, self.Expanded and math.min(41 + windowlist.AbsoluteContentSize.Y / scale.Scale, 601) or 41)
		divider.Visible = children.CanvasPosition.Y > 10 and children.Visible
	end
	arrowbutton.MouseButton1Click:Connect(function()
		categoryapi:Expand()
	end)
	arrowbutton.MouseButton2Click:Connect(function()
		categoryapi:Expand()
	end)
	hoverOn(arrowbutton, arrow, {ImageColor3 = Color3.fromRGB(220, 220, 220)}, {ImageColor3 = Color3.fromRGB(140, 140, 140)})
	children:GetPropertyChangedSignal('CanvasPosition'):Connect(function()
		if self.ThreadFix then
			setthreadidentity(8)
		end
		divider.Visible = children.CanvasPosition.Y > 10 and children.Visible
	end)
	window.InputBegan:Connect(function(inputObj)
		if inputObj.Position.Y < window.AbsolutePosition.Y + 41 and inputObj.UserInputType == Enum.UserInputType.MouseButton2 then
			categoryapi:Expand()
		end
	end)
	windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		if self.ThreadFix then
			setthreadidentity(8)
		end
		children.CanvasSize = UDim2.fromOffset(0, windowlist.AbsoluteContentSize.Y / scale.Scale)
		if categoryapi.Expanded then
			window.Size = UDim2.fromOffset(220, math.min(41 + windowlist.AbsoluteContentSize.Y / scale.Scale, 601))
		end
	end)
	categoryapi.Button = self.Categories.Main:CreateButton({
		Name = categorysettings.Name,
		Icon = categorysettings.Icon,
		Size = categorysettings.Size,
		Window = window
	})
	categoryapi.Object = window
	self.Categories[categorysettings.Name] = categoryapi
	return categoryapi
end
function mainapi:CreateOverlay(categorysettings)
	local window
	local categoryapi
	categoryapi = {
		Type = 'Overlay',
		Expanded = false,
		Button = self.Overlays:CreateToggle({
			Name = categorysettings.Name,
			Function = function(callback)
				window.Visible = callback and (clickgui.Visible or categoryapi.Pinned)
				if not callback then
					for _, v in categoryapi.Connections do
						v:Disconnect()
					end
					table.clear(categoryapi.Connections)
				end
				if categorysettings.Function then
					task.spawn(categorysettings.Function, callback)
				end
			end,
			Icon = categorysettings.Icon,
			Size = categorysettings.Size,
			Position = categorysettings.Position
		}),
		Pinned = false,
		Options = {}
	}
	window = Instance.new('TextButton')
	window.Name = categorysettings.Name .. 'Overlay'
	window.Size = UDim2.fromOffset(categorysettings.CategorySize or 220, 41)
	window.Position = UDim2.fromOffset(240, 46)
	window.BackgroundColor3 = uipallet.Main
	window.AutoButtonColor = false
	window.Visible = false
	window.Text = ''
	window.Parent = scaledgui
	local blur = addBlur(window)
	addCorner(window, UDim.new(0, 8))
	addStroke(window, uipallet.Outline, 1)
	makeDraggable(window)
	local icon = Instance.new('ImageLabel')
	icon.Name = 'Icon'
	icon.Size = categorysettings.Size
	icon.Position = UDim2.fromOffset(12, (icon.Size.X.Offset > 14 and 14 or 13))
	icon.BackgroundTransparency = 1
	icon.Image = categorysettings.Icon
	icon.ImageColor3 = uipallet.Text
	icon.Parent = window
	local title = Instance.new('TextLabel')
	title.Name = 'Title'
	title.Size = UDim2.new(1, -32, 0, 41)
	title.Position = UDim2.fromOffset(math.abs(title.Size.X.Offset), 0)
	title.BackgroundTransparency = 1
	title.Text = categorysettings.Name
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = uipallet.Text
	title.TextSize = 13
	title.FontFace = uipallet.Font
	title.Parent = window
	local pin = Instance.new('ImageButton')
	pin.Name = 'Pin'
	pin.Size = UDim2.fromOffset(16, 16)
	pin.Position = UDim2.new(1, -47, 0, 12)
	pin.BackgroundTransparency = 1
	pin.AutoButtonColor = false
	pin.Image = getcustomasset('volt/assets/pin.png')
	pin.ImageColor3 = uipallet.TextDim
	pin.Parent = window
	local dotsbutton = Instance.new('TextButton')
	dotsbutton.Name = 'Dots'
	dotsbutton.Size = UDim2.fromOffset(17, 40)
	dotsbutton.Position = UDim2.new(1, -17, 0, 0)
	dotsbutton.BackgroundTransparency = 1
	dotsbutton.Text = ''
	dotsbutton.Parent = window
	local dots = Instance.new('ImageLabel')
	dots.Name = 'Dots'
	dots.Size = UDim2.fromOffset(3, 16)
	dots.Position = UDim2.fromOffset(4, 12)
	dots.BackgroundTransparency = 1
	dots.Image = getcustomasset('volt/assets/dots.png')
	dots.ImageColor3 = color.Light(uipallet.Main, 0.37)
	dots.Parent = dotsbutton
	local customchildren = Instance.new('Frame')
	customchildren.Name = 'CustomChildren'
	customchildren.Size = UDim2.new(1, 0, 0, 200)
	customchildren.Position = UDim2.fromScale(0, 1)
	customchildren.BackgroundTransparency = 1
	customchildren.Parent = window
	local children = Instance.new('ScrollingFrame')
	children.Name = 'Children'
	children.Size = UDim2.new(1, 0, 1, -41)
	children.Position = UDim2.fromOffset(0, 41)
	children.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
	children.BorderSizePixel = 0
	children.Visible = false
	children.ScrollBarThickness = 2
	children.ScrollBarImageTransparency = 0.75
	children.CanvasSize = UDim2.new()
	children.Parent = window
	local windowlist = Instance.new('UIListLayout')
	windowlist.SortOrder = Enum.SortOrder.LayoutOrder
	windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
	windowlist.Parent = children
	addMaid(categoryapi)
	function categoryapi:Expand(check)
		if check and not blur.Visible then return end
		self.Expanded = not self.Expanded
		children.Visible = self.Expanded
		dots.ImageColor3 = self.Expanded and uipallet.Text or color.Light(uipallet.Main, 0.37)
		if self.Expanded then
			window.Size = UDim2.fromOffset(window.Size.X.Offset, math.min(41 + windowlist.AbsoluteContentSize.Y / scale.Scale, 601))
		else
			window.Size = UDim2.fromOffset(window.Size.X.Offset, 41)
		end
	end
	function categoryapi:Pin()
		self.Pinned = not self.Pinned
		pin.ImageColor3 = self.Pinned and uipallet.Text or uipallet.TextDim
	end
	function categoryapi:Update()
		window.Visible = self.Button.Enabled and (clickgui.Visible or self.Pinned)
		if self.Expanded then
			self:Expand()
		end
		if clickgui.Visible then
			window.Size = UDim2.fromOffset(window.Size.X.Offset, 41)
			window.BackgroundTransparency = 0
			blur.Visible = true
			icon.Visible = true
			title.Visible = true
			pin.Visible = true
			dotsbutton.Visible = true
		else
			window.Size = UDim2.fromOffset(window.Size.X.Offset, 0)
			window.BackgroundTransparency = 1
			blur.Visible = false
			icon.Visible = false
			title.Visible = false
			pin.Visible = false
			dotsbutton.Visible = false
		end
	end
	for i, v in components do
		categoryapi['Create' .. i] = function(self, optionsettings)
			return v(optionsettings, children, categoryapi)
		end
	end
	dotsbutton.MouseEnter:Connect(function()
		if not children.Visible then
			dots.ImageColor3 = uipallet.Text
		end
	end)
	dotsbutton.MouseLeave:Connect(function()
		if not children.Visible then
			dots.ImageColor3 = color.Light(uipallet.Main, 0.37)
		end
	end)
	dotsbutton.MouseButton1Click:Connect(function()
		categoryapi:Expand(true)
	end)
	dotsbutton.MouseButton2Click:Connect(function()
		categoryapi:Expand(true)
	end)
	pin.MouseButton1Click:Connect(function()
		categoryapi:Pin()
	end)
	window.MouseButton2Click:Connect(function()
		categoryapi:Expand(true)
	end)
	windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		if self.ThreadFix then
			setthreadidentity(8)
		end
		children.CanvasSize = UDim2.fromOffset(0, windowlist.AbsoluteContentSize.Y / scale.Scale)
		if categoryapi.Expanded then
			window.Size = UDim2.fromOffset(window.Size.X.Offset, math.min(41 + windowlist.AbsoluteContentSize.Y / scale.Scale, 601))
		end
	end)
	self:Clean(clickgui:GetPropertyChangedSignal('Visible'):Connect(function()
		categoryapi:Update()
	end))
	categoryapi:Update()
	categoryapi.Object = window
	categoryapi.Children = customchildren
	self.Categories[categorysettings.Name] = categoryapi
	return categoryapi
end
function mainapi:CreateCategoryList(categorysettings)
	local categoryapi = {
		Type = 'CategoryList',
		Expanded = false,
		List = {},
		ListEnabled = {},
		Objects = {},
		Options = {}
	}
	categorysettings.Color = categorysettings.Color or Color3.fromRGB(80, 220, 120)
	local window = newWindow(categorysettings.Name .. 'CategoryList', 220, 45, clickgui, categorysettings.Name, categorysettings.Icon, categorysettings.Size, categorysettings.Position, function()
		if categoryapi.Button and categoryapi.Button.Enabled then
			categoryapi.Button:Toggle()
		end
	end)
	window.Position = UDim2.fromOffset(240, 46)
	makeDraggable(window)
	local arrowbutton = Instance.new('TextButton')
	arrowbutton.Name = 'Arrow'
	arrowbutton.Size = UDim2.fromOffset(40, 40)
	arrowbutton.Position = UDim2.new(1, -40, 0, 0)
	arrowbutton.BackgroundTransparency = 1
	arrowbutton.Text = ''
	arrowbutton.Parent = window
	local arrow = Instance.new('ImageLabel')
	arrow.Name = 'Arrow'
	arrow.Size = UDim2.fromOffset(9, 4)
	arrow.Position = UDim2.fromOffset(20, 19)
	arrow.BackgroundTransparency = 1
	arrow.Image = getcustomasset('volt/assets/expandup.png')
	arrow.ImageColor3 = Color3.fromRGB(140, 140, 140)
	arrow.Rotation = 180
	arrow.Parent = arrowbutton
	local children = Instance.new('ScrollingFrame')
	children.Name = 'Children'
	children.Size = UDim2.new(1, 0, 1, -45)
	children.Position = UDim2.fromOffset(0, 45)
	children.BackgroundTransparency = 1
	children.BorderSizePixel = 0
	children.Visible = false
	children.ScrollBarThickness = 2
	children.ScrollBarImageTransparency = 0.75
	children.CanvasSize = UDim2.new()
	children.Parent = window
	local childrentwo = Instance.new('Frame')
	childrentwo.BackgroundTransparency = 1
	childrentwo.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
	childrentwo.Visible = false
	childrentwo.Parent = children
	local settings = Instance.new('ImageButton')
	settings.Name = 'Settings'
	settings.Size = UDim2.fromOffset(16, 16)
	settings.Position = UDim2.new(1, -52, 0, 13)
	settings.BackgroundTransparency = 1
	settings.AutoButtonColor = false
	settings.Image = getcustomasset('volt/assets/customsettings.png')
	settings.ImageColor3 = uipallet.TextDim
	settings.Parent = window
	local divider = Instance.new('Frame')
	divider.Name = 'Divider'
	divider.Size = UDim2.new(1, 0, 0, 1)
	divider.Position = UDim2.fromOffset(0, 45)
	divider.BorderSizePixel = 0
	divider.Visible = false
	divider.BackgroundColor3 = Color3.new(1, 1, 1)
	divider.BackgroundTransparency = 0.928
	divider.Parent = window
	local windowlist = Instance.new('UIListLayout')
	windowlist.SortOrder = Enum.SortOrder.LayoutOrder
	windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
	windowlist.Padding = UDim.new(0, 3)
	windowlist.Parent = children
	local windowlisttwo = Instance.new('UIListLayout')
	windowlisttwo.SortOrder = Enum.SortOrder.LayoutOrder
	windowlisttwo.HorizontalAlignment = Enum.HorizontalAlignment.Center
	windowlisttwo.Parent = childrentwo
	local addbkg = Instance.new('Frame')
	addbkg.Name = 'Add'
	addbkg.Size = UDim2.fromOffset(200, 31)
	addbkg.Position = UDim2.fromOffset(10, 45)
	addbkg.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
	addbkg.Parent = children
	addCorner(addbkg)
	local addbox = addbkg:Clone()
	addbox.Size = UDim2.new(1, -2, 1, -2)
	addbox.Position = UDim2.fromOffset(1, 1)
	addbox.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
	addbox.Parent = addbkg
	local addvalue = Instance.new('TextBox')
	addvalue.Size = UDim2.new(1, -35, 1, 0)
	addvalue.Position = UDim2.fromOffset(10, 0)
	addvalue.BackgroundTransparency = 1
	addvalue.Text = ''
	addvalue.PlaceholderText = categorysettings.Placeholder or 'Add entry...'
	addvalue.TextXAlignment = Enum.TextXAlignment.Left
	addvalue.TextColor3 = Color3.new(1, 1, 1)
	addvalue.TextSize = 14
	addvalue.FontFace = uipallet.Font
	addvalue.ClearTextOnFocus = false
	addvalue.Parent = addbkg
	local addbutton = Instance.new('ImageButton')
	addbutton.Name = 'AddButton'
	addbutton.Size = UDim2.fromOffset(16, 16)
	addbutton.Position = UDim2.new(1, -26, 0, 8)
	addbutton.BackgroundTransparency = 1
	addbutton.Image = getcustomasset('volt/assets/add.png')
	addbutton.ImageColor3 = categorysettings.Color
	addbutton.ImageTransparency = 0.3
	addbutton.Parent = addbkg
	local cursedpadding = Instance.new('Frame')
	cursedpadding.Size = UDim2.fromOffset()
	cursedpadding.BackgroundTransparency = 1
	cursedpadding.Parent = children
	categorysettings.Function = categorysettings.Function or function() end
	function categoryapi:ChangeValue(val)
		if val then
			if categorysettings.Profiles then
				local ind = self:GetValue(val)
				if ind then
					if val ~= 'default' then
						table.remove(mainapi.Profiles, ind)
						if isfile('volt/profiles/' .. val .. mainapi.Place .. '.txt') and delfile then
							delfile('volt/profiles/' .. val .. mainapi.Place .. '.txt')
						end
					end
				else
					table.insert(mainapi.Profiles, {Name = val, Bind = {}})
				end
			else
				local ind = table.find(self.List, val)
				if ind then
					table.remove(self.List, ind)
					ind = table.find(self.ListEnabled, val)
					if ind then
						table.remove(self.ListEnabled, ind)
					end
				else
					table.insert(self.List, val)
					table.insert(self.ListEnabled, val)
				end
			end
		end
		categorysettings.Function()
		for _, v in self.Objects do
			v:Destroy()
		end
		table.clear(self.Objects)
		self.Selected = nil
		for i, v in (categorysettings.Profiles and mainapi.Profiles or self.List) do
			if categorysettings.Profiles then
				local object = Instance.new('TextButton')
				object.Name = v.Name
				object.Size = UDim2.fromOffset(200, 33)
				object.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
				object.AutoButtonColor = false
				object.Text = ''
				object.Parent = children
				addCorner(object)
				local objectstroke = Instance.new('UIStroke')
				objectstroke.Color = color.Light(uipallet.Main, 0.1)
				objectstroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				objectstroke.Enabled = false
				objectstroke.Parent = object
				local objecttitle = Instance.new('TextLabel')
				objecttitle.Name = 'Title'
				objecttitle.Size = UDim2.new(1, -10, 1, 0)
				objecttitle.Position = UDim2.fromOffset(10, 0)
				objecttitle.BackgroundTransparency = 1
				objecttitle.Text = v.Name
				objecttitle.TextXAlignment = Enum.TextXAlignment.Left
				objecttitle.TextColor3 = uipallet.TextDim
				objecttitle.TextSize = 14
				objecttitle.FontFace = uipallet.Font
				objecttitle.Parent = object
				local dotsbutton = Instance.new('TextButton')
				dotsbutton.Name = 'Dots'
				dotsbutton.Size = UDim2.fromOffset(25, 33)
				dotsbutton.Position = UDim2.new(1, -25, 0, 0)
				dotsbutton.BackgroundTransparency = 1
				dotsbutton.Text = ''
				dotsbutton.Parent = object
				local dots = Instance.new('ImageLabel')
				dots.Name = 'Dots'
				dots.Size = UDim2.fromOffset(3, 16)
				dots.Position = UDim2.fromOffset(10, 9)
				dots.BackgroundTransparency = 1
				dots.Image = getcustomasset('volt/assets/dots.png')
				dots.ImageColor3 = color.Light(uipallet.Main, 0.37)
				dots.Parent = dotsbutton
				local bind = Instance.new('TextButton')
				addTooltip(bind, 'Click to bind')
				bind.Name = 'Bind'
				bind.Size = UDim2.fromOffset(20, 21)
				bind.Position = UDim2.new(1, -30, 0, 6)
				bind.AnchorPoint = Vector2.new(1, 0)
				bind.BackgroundColor3 = Color3.new(1, 1, 1)
				bind.BackgroundTransparency = 0.92
				bind.BorderSizePixel = 0
				bind.AutoButtonColor = false
				bind.Visible = false
				bind.Text = ''
				addCorner(bind, UDim.new(0, 4))
				local bindicon = Instance.new('ImageLabel')
				bindicon.Name = 'Icon'
				bindicon.Size = UDim2.fromOffset(12, 12)
				bindicon.Position = UDim2.new(0.5, -6, 0, 5)
				bindicon.BackgroundTransparency = 1
				bindicon.Image = getcustomasset('volt/assets/bind.png')
				bindicon.ImageColor3 = uipallet.TextDim
				bindicon.Parent = bind
				local bindtext = Instance.new('TextLabel')
				bindtext.Size = UDim2.fromScale(1, 1)
				bindtext.Position = UDim2.fromOffset(0, 1)
				bindtext.BackgroundTransparency = 1
				bindtext.Visible = false
				bindtext.Text = ''
				bindtext.TextColor3 = uipallet.TextDim
				bindtext.TextSize = 12
				bindtext.FontFace = uipallet.Font
				bindtext.Parent = bind
				bind.MouseEnter:Connect(function()
					bindtext.Visible = false
					bindicon.Visible = true
					bindicon.Image = getcustomasset('volt/assets/edit.png')
					if v.Name ~= mainapi.Profile then
						bindicon.ImageColor3 = uipallet.Text
					end
				end)
				bind.MouseLeave:Connect(function()
					bindtext.Visible = #v.Bind > 0
					bindicon.Visible = not bindtext.Visible
					bindicon.Image = getcustomasset('volt/assets/bind.png')
					if v.Name ~= mainapi.Profile then
						bindicon.ImageColor3 = uipallet.TextDim
					end
				end)
				local bindcover = Instance.new('ImageLabel')
				bindcover.Name = 'Cover'
				bindcover.Size = UDim2.fromOffset(154, 33)
				bindcover.BackgroundTransparency = 1
				bindcover.Visible = false
				bindcover.Image = getcustomasset('volt/assets/bindbkg.png')
				bindcover.ScaleType = Enum.ScaleType.Slice
				bindcover.SliceCenter = Rect.new(0, 0, 141, 40)
				bindcover.Parent = object
				local bindcovertext = Instance.new('TextLabel')
				bindcovertext.Name = 'Text'
				bindcovertext.Size = UDim2.new(1, -10, 1, -3)
				bindcovertext.BackgroundTransparency = 1
				bindcovertext.Text = 'PRESS A KEY TO BIND'
				bindcovertext.TextColor3 = uipallet.Text
				bindcovertext.TextSize = 11
				bindcovertext.FontFace = uipallet.Font
				bindcovertext.Parent = bindcover
				bind.Parent = object
				dotsbutton.MouseEnter:Connect(function()
					if v.Name ~= mainapi.Profile then
						dots.ImageColor3 = uipallet.Text
					end
				end)
				dotsbutton.MouseLeave:Connect(function()
					if v.Name ~= mainapi.Profile then
						dots.ImageColor3 = color.Light(uipallet.Main, 0.37)
					end
				end)
				dotsbutton.MouseButton1Click:Connect(function()
					if v.Name ~= mainapi.Profile then
						categoryapi:ChangeValue(v.Name)
					end
				end)
				object.MouseButton1Click:Connect(function()
					mainapi:Save(v.Name)
					mainapi:Load(true)
				end)
				object.MouseEnter:Connect(function()
					bind.Visible = true
					if v.Name ~= mainapi.Profile then
						objectstroke.Enabled = true
						objecttitle.TextColor3 = uipallet.Text
					end
				end)
				object.MouseLeave:Connect(function()
					bind.Visible = #v.Bind > 0
					if v.Name ~= mainapi.Profile then
						objectstroke.Enabled = false
						objecttitle.TextColor3 = uipallet.TextDim
					end
				end)
				local function bindFunction(self, tab, mouse)
					v.Bind = table.clone(tab)
					if mouse then
						bindcovertext.Text = #tab <= 0 and 'BIND REMOVED' or 'BOUND TO ' .. table.concat(tab, ' + '):upper()
						bindcover.Size = UDim2.fromOffset(getfontsize(bindcovertext.Text, bindcovertext.TextSize).X + 20, 40)
						task.delay(1, function()
							bindcover.Visible = false
						end)
					end
					if #tab <= 0 then
						bindtext.Visible = false
						bindicon.Visible = true
						bind.Size = UDim2.fromOffset(20, 21)
					else
						bind.Visible = true
						bindtext.Visible = true
						bindicon.Visible = false
						bindtext.Text = table.concat(tab, ' + '):upper()
						bind.Size = UDim2.fromOffset(math.max(getfontsize(bindtext.Text, bindtext.TextSize, bindtext.Font).X + 10, 20), 21)
					end
				end
				bindFunction({}, v.Bind)
				bind.MouseButton1Click:Connect(function()
					bindcovertext.Text = 'PRESS A KEY TO BIND'
					bindcover.Size = UDim2.fromOffset(getfontsize(bindcovertext.Text, bindcovertext.TextSize).X + 20, 40)
					bindcover.Visible = true
					mainapi.Binding = {SetBind = bindFunction, Bind = v.Bind}
				end)
				if v.Name == mainapi.Profile then
					self.Selected = object
				end
				table.insert(self.Objects, object)
			else
				local enabled = table.find(self.ListEnabled, v)
				local object = Instance.new('TextButton')
				object.Name = v
				object.Size = UDim2.fromOffset(200, 32)
				object.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
				object.AutoButtonColor = false
				object.Text = ''
				object.Parent = children
				addCorner(object)
				local objectbkg = Instance.new('Frame')
				objectbkg.Name = 'BKG'
				objectbkg.Size = UDim2.new(1, -2, 1, -2)
				objectbkg.Position = UDim2.fromOffset(1, 1)
				objectbkg.BackgroundColor3 = uipallet.Secondary
				objectbkg.Visible = false
				objectbkg.Parent = object
				addCorner(objectbkg)
				local objectdot = Instance.new('Frame')
				objectdot.Name = 'Dot'
				objectdot.Size = UDim2.fromOffset(10, 11)
				objectdot.Position = UDim2.fromOffset(10, 12)
				objectdot.BackgroundColor3 = enabled and categorysettings.Color or color.Light(uipallet.Main, 0.37)
				objectdot.Parent = object
				addCorner(objectdot, UDim.new(1, 0))
				local objectdotin = objectdot:Clone()
				objectdotin.Size = UDim2.fromOffset(8, 9)
				objectdotin.Position = UDim2.fromOffset(1, 1)
				objectdotin.BackgroundColor3 = enabled and categorysettings.Color or color.Light(uipallet.Main, 0.02)
				objectdotin.Parent = objectdot
				local objecttitle = Instance.new('TextLabel')
				objecttitle.Name = 'Title'
				objecttitle.Size = UDim2.new(1, -30, 1, 0)
				objecttitle.Position = UDim2.fromOffset(30, 0)
				objecttitle.BackgroundTransparency = 1
				objecttitle.Text = v
				objecttitle.TextXAlignment = Enum.TextXAlignment.Left
				objecttitle.TextColor3 = uipallet.Text
				objecttitle.TextSize = 14
				objecttitle.FontFace = uipallet.Font
				objecttitle.Parent = object
				if mainapi.ThreadFix then
					setthreadidentity(8)
				end
				local objectclose = Instance.new('ImageButton')
				objectclose.Name = 'Close'
				objectclose.Size = UDim2.fromOffset(16, 16)
				objectclose.Position = UDim2.new(1, -23, 0, 8)
				objectclose.BackgroundColor3 = Color3.new(1, 1, 1)
				objectclose.BackgroundTransparency = 1
				objectclose.AutoButtonColor = false
				objectclose.Image = getcustomasset('volt/assets/closemini.png')
				objectclose.ImageColor3 = color.Light(uipallet.Text, 0.2)
				objectclose.ImageTransparency = 0.5
				objectclose.Parent = object
				addCorner(objectclose, UDim.new(1, 0))
				objectclose.MouseEnter:Connect(function()
					objectclose.ImageTransparency = 0.3
					tween:Tween(objectclose, uipallet.Tween, {BackgroundTransparency = 0.6})
				end)
				objectclose.MouseLeave:Connect(function()
					objectclose.ImageTransparency = 0.5
					tween:Tween(objectclose, uipallet.Tween, {BackgroundTransparency = 1})
				end)
				objectclose.MouseButton1Click:Connect(function()
					categoryapi:ChangeValue(v)
				end)
				object.MouseEnter:Connect(function()
					objectbkg.Visible = true
				end)
				object.MouseLeave:Connect(function()
					objectbkg.Visible = false
				end)
				object.MouseButton1Click:Connect(function()
					local ind = table.find(self.ListEnabled, v)
					if ind then
						table.remove(self.ListEnabled, ind)
						objectdot.BackgroundColor3 = color.Light(uipallet.Main, 0.37)
						objectdotin.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
					else
						table.insert(self.ListEnabled, v)
						objectdot.BackgroundColor3 = categorysettings.Color
						objectdotin.BackgroundColor3 = categorysettings.Color
					end
					categorysettings.Function()
				end)
				table.insert(self.Objects, object)
			end
		end
		mainapi:UpdateGUI(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value)
	end
	function categoryapi:Expand()
		self.Expanded = not self.Expanded
		children.Visible = self.Expanded
		arrow.Rotation = self.Expanded and 0 or 180
		window.Size = UDim2.fromOffset(220, self.Expanded and math.min(51 + windowlist.AbsoluteContentSize.Y / scale.Scale, 611) or 45)
		divider.Visible = children.CanvasPosition.Y > 10 and children.Visible
	end
	function categoryapi:GetValue(name)
		for i, v in mainapi.Profiles do
			if v.Name == name then
				return i
			end
		end
	end
	for i, v in components do
		categoryapi['Create' .. i] = function(self, optionsettings)
			return v(optionsettings, childrentwo, categoryapi)
		end
	end
	addbutton.MouseEnter:Connect(function()
		addbutton.ImageTransparency = 0
	end)
	addbutton.MouseLeave:Connect(function()
		addbutton.ImageTransparency = 0.3
	end)
	addbutton.MouseButton1Click:Connect(function()
		if not table.find(categoryapi.List, addvalue.Text) then
			categoryapi:ChangeValue(addvalue.Text)
			addvalue.Text = ''
		end
	end)
	hoverOn(arrowbutton, arrow, {ImageColor3 = Color3.fromRGB(220, 220, 220)}, {ImageColor3 = Color3.fromRGB(140, 140, 140)})
	arrowbutton.MouseButton1Click:Connect(function()
		categoryapi:Expand()
	end)
	arrowbutton.MouseButton2Click:Connect(function()
		categoryapi:Expand()
	end)
	addvalue.FocusLost:Connect(function(enter)
		if enter and not table.find(categoryapi.List, addvalue.Text) then
			categoryapi:ChangeValue(addvalue.Text)
			addvalue.Text = ''
		end
	end)
	hoverOn(addvalue, addbkg, {BackgroundColor3 = color.Light(uipallet.Main, 0.14)}, {BackgroundColor3 = color.Light(uipallet.Main, 0.02)})
	children:GetPropertyChangedSignal('CanvasPosition'):Connect(function()
		divider.Visible = children.CanvasPosition.Y > 10 and children.Visible
	end)
	hoverOn(settings, settings, {ImageColor3 = uipallet.Text}, {ImageColor3 = color.Light(uipallet.Main, 0.37)})
	settings.MouseButton1Click:Connect(function()
		childrentwo.Visible = not childrentwo.Visible
	end)
	window.InputBegan:Connect(function(inputObj)
		if inputObj.Position.Y < window.AbsolutePosition.Y + 41 and inputObj.UserInputType == Enum.UserInputType.MouseButton2 then
			categoryapi:Expand()
		end
	end)
	windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		if self.ThreadFix then
			setthreadidentity(8)
		end
		children.CanvasSize = UDim2.fromOffset(0, windowlist.AbsoluteContentSize.Y / scale.Scale)
		if categoryapi.Expanded then
			window.Size = UDim2.fromOffset(220, math.min(51 + windowlist.AbsoluteContentSize.Y / scale.Scale, 611))
		end
	end)
	windowlisttwo:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		if self.ThreadFix then
			setthreadidentity(8)
		end
		childrentwo.Size = UDim2.fromOffset(220, windowlisttwo.AbsoluteContentSize.Y)
	end)
	categoryapi.Button = self.Categories.Main:CreateButton({
		Name = categorysettings.Name,
		Icon = categorysettings.CategoryIcon,
		Size = categorysettings.CategorySize,
		Window = window
	})
	categoryapi.Object = window
	self.Categories[categorysettings.Name] = categoryapi
	return categoryapi
end
function mainapi:CreateSearch()
	local searchbkg = Instance.new('Frame')
	searchbkg.Name = 'Search'
	searchbkg.Size = UDim2.fromOffset(220, 37)
	searchbkg.Position = UDim2.new(0.5, 0, 0, 13)
	searchbkg.AnchorPoint = Vector2.new(0.5, 0)
	searchbkg.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
	searchbkg.Parent = clickgui
	local searchicon = Instance.new('ImageLabel')
	searchicon.Name = 'Icon'
	searchicon.Size = UDim2.fromOffset(14, 14)
	searchicon.Position = UDim2.new(1, -23, 0, 11)
	searchicon.BackgroundTransparency = 1
	searchicon.Image = getcustomasset('volt/assets/search.png')
	searchicon.ImageColor3 = color.Light(uipallet.Main, 0.37)
	searchicon.Parent = searchbkg
	local legiticon = Instance.new('ImageButton')
	legiticon.Name = 'Legit'
	legiticon.Size = UDim2.fromOffset(29, 16)
	legiticon.Position = UDim2.fromOffset(8, 11)
	legiticon.BackgroundTransparency = 1
	legiticon.Image = getcustomasset('volt/assets/legit.png')
	legiticon.Parent = searchbkg
	local legitdivider = Instance.new('Frame')
	legitdivider.Name = 'LegitDivider'
	legitdivider.Size = UDim2.fromOffset(2, 12)
	legitdivider.Position = UDim2.fromOffset(43, 13)
	legitdivider.BackgroundColor3 = color.Light(uipallet.Main, 0.14)
	legitdivider.BorderSizePixel = 0
	legitdivider.Parent = searchbkg
	addBlur(searchbkg)
	addCorner(searchbkg)
	addStroke(searchbkg, uipallet.Outline, 1)
	local search = Instance.new('TextBox')
	search.Size = UDim2.new(1, -50, 0, 37)
	search.Position = UDim2.fromOffset(50, 0)
	search.BackgroundTransparency = 1
	search.Text = ''
	search.PlaceholderText = ''
	search.TextXAlignment = Enum.TextXAlignment.Left
	search.TextColor3 = uipallet.Text
	search.TextSize = 12
	search.FontFace = uipallet.Font
	search.ClearTextOnFocus = false
	search.Parent = searchbkg
	local children = Instance.new('ScrollingFrame')
	children.Name = 'Children'
	children.Size = UDim2.new(1, 0, 1, -37)
	children.Position = UDim2.fromOffset(0, 34)
	children.BackgroundTransparency = 1
	children.BorderSizePixel = 0
	children.ScrollBarThickness = 2
	children.ScrollBarImageTransparency = 0.75
	children.CanvasSize = UDim2.new()
	children.Parent = searchbkg
	local divider = Instance.new('Frame')
	divider.Name = 'Divider'
	divider.Size = UDim2.new(1, 0, 0, 1)
	divider.Position = UDim2.fromOffset(0, 33)
	divider.BackgroundColor3 = Color3.new(1, 1, 1)
	divider.BackgroundTransparency = 0.928
	divider.BorderSizePixel = 0
	divider.Visible = false
	divider.Parent = searchbkg
	local windowlist = Instance.new('UIListLayout')
	windowlist.SortOrder = Enum.SortOrder.LayoutOrder
	windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
	windowlist.Parent = children
	children:GetPropertyChangedSignal('CanvasPosition'):Connect(function()
		divider.Visible = children.CanvasPosition.Y > 10 and children.Visible
	end)
	legiticon.MouseButton1Click:Connect(function()
		clickgui.Visible = false
		self.Legit.Window.Visible = true
		self.Legit.Window.Position = UDim2.new(0.5, -350, 0.5, -194)
	end)
	search:GetPropertyChangedSignal('Text'):Connect(function()
		for _, v in children:GetChildren() do
			if v:IsA('TextButton') then
				v:Destroy()
			end
		end
		if search.Text == '' then return end
		for i, v in self.Modules do
			if i:lower():find(search.Text:lower()) then
				local button = v.Object:Clone()
				button.Bind:Destroy()
				button.MouseButton1Click:Connect(function()
					v:Toggle()
				end)
				button.MouseButton2Click:Connect(function()
					v.Object.Parent.Parent.Visible = true
					local frame = v.Object.Parent
					local highlight = Instance.new('Frame')
					highlight.Size = UDim2.fromScale(1, 1)
					highlight.BackgroundColor3 = Color3.new(1, 1, 1)
					highlight.BackgroundTransparency = 0.6
					highlight.BorderSizePixel = 0
					highlight.Parent = v.Object
					tween:Tween(highlight, TweenInfo.new(0.5), {BackgroundTransparency = 1})
					task.delay(0.5, highlight.Destroy, highlight)
					frame.CanvasPosition = Vector2.new(0, (v.Object.LayoutOrder * 40) - (math.min(frame.CanvasSize.Y.Offset, 600) / 2))
				end)
				button.Parent = children
				task.spawn(function()
					repeat
						for _, v2 in {'Text', 'TextColor3', 'BackgroundColor3'} do
							button[v2] = v.Object[v2]
						end
						button.UIGradient.Color = v.Object.UIGradient.Color
						button.UIGradient.Enabled = v.Object.UIGradient.Enabled
						button.Dots.Dots.ImageColor3 = v.Object.Dots.Dots.ImageColor3
						task.wait()
					until not button.Parent
				end)
			end
		end
	end)
	windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		if self.ThreadFix then
			setthreadidentity(8)
		end
		children.CanvasSize = UDim2.fromOffset(0, windowlist.AbsoluteContentSize.Y / scale.Scale)
		searchbkg.Size = UDim2.fromOffset(220, math.min(37 + windowlist.AbsoluteContentSize.Y / scale.Scale, 437))
	end)
	self.Legit.Icon = legiticon
end
function mainapi:CreateLegit()
	local legitapi = {Modules = {}}
	local window = Instance.new('Frame')
	window.Name = 'LegitGUI'
	window.Size = UDim2.fromOffset(700, 389)
	window.Position = UDim2.new(0.5, -350, 0.5, -194)
	window.BackgroundColor3 = uipallet.Main
	window.Visible = false
	window.Parent = scaledgui
	addBlur(window)
	addCorner(window, UDim.new(0, 8))
	addStroke(window, uipallet.Outline, 1)
	makeDraggable(window)
	local modal = Instance.new('TextButton')
	modal.BackgroundTransparency = 1
	modal.Text = ''
	modal.Modal = true
	modal.Parent = window
	local icon = Instance.new('ImageLabel')
	icon.Name = 'Icon'
	icon.Size = UDim2.fromOffset(16, 16)
	icon.Position = UDim2.fromOffset(18, 13)
	icon.BackgroundTransparency = 1
	icon.Image = getcustomasset('volt/assets/legittab.png')
	icon.ImageColor3 = uipallet.Text
	icon.Parent = window
	local close = addCloseButton(window)
	local children = Instance.new('ScrollingFrame')
	children.Name = 'Children'
	children.Size = UDim2.fromOffset(684, 340)
	children.Position = UDim2.fromOffset(14, 41)
	children.BackgroundTransparency = 1
	children.BorderSizePixel = 0
	children.ScrollBarThickness = 2
	children.ScrollBarImageTransparency = 0.75
	children.CanvasSize = UDim2.new()
	children.Parent = window
	local windowlist = Instance.new('UIGridLayout')
	windowlist.SortOrder = Enum.SortOrder.LayoutOrder
	windowlist.FillDirectionMaxCells = 4
	windowlist.CellSize = UDim2.fromOffset(163, 114)
	windowlist.CellPadding = UDim2.fromOffset(6, 5)
	windowlist.Parent = children
	legitapi.Window = window
	table.insert(mainapi.Windows, window)
	function legitapi:CreateModule(modulesettings)
		mainapi:Remove(modulesettings.Name)
		local moduleapi = {
			Enabled = false,
			Options = {},
			Name = modulesettings.Name,
			Legit = true
		}
		local module = Instance.new('TextButton')
		module.Name = modulesettings.Name
		module.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
		module.Text = ''
		module.AutoButtonColor = false
		module.Parent = children
		addTooltip(module, modulesettings.Tooltip)
		addCorner(module)
		local title = Instance.new('TextLabel')
		title.Name = 'Title'
		title.Size = UDim2.new(1, -16, 0, 20)
		title.Position = UDim2.fromOffset(16, 81)
		title.BackgroundTransparency = 1
		title.Text = modulesettings.Name
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.TextColor3 = uipallet.TextDim
		title.TextSize = 13
		title.FontFace = uipallet.Font
		title.Parent = module
		local knob = Instance.new('Frame')
		knob.Name = 'Knob'
		knob.Size = UDim2.fromOffset(24, 14)
		knob.Position = UDim2.new(1, -57, 0, 14)
		knob.BackgroundColor3 = color.Light(uipallet.Main, 0.14)
		knob.Parent = module
		addCorner(knob, UDim.new(1, 0))
		local knobmain = knob:Clone()
		knobmain.Size = UDim2.fromOffset(10, 10)
		knobmain.Position = UDim2.fromOffset(2, 2)
		knobmain.BackgroundColor3 = uipallet.Main
		knobmain.Parent = knob
		local dotsbutton = Instance.new('TextButton')
		dotsbutton.Name = 'Dots'
		dotsbutton.Size = UDim2.fromOffset(14, 24)
		dotsbutton.Position = UDim2.new(1, -27, 0, 8)
		dotsbutton.BackgroundTransparency = 1
		dotsbutton.Text = ''
		dotsbutton.Parent = module
		local dots = Instance.new('ImageLabel')
		dots.Name = 'Dots'
		dots.Size = UDim2.fromOffset(2, 12)
		dots.Position = UDim2.fromOffset(6, 6)
		dots.BackgroundTransparency = 1
		dots.Image = getcustomasset('volt/assets/dots.png')
		dots.ImageColor3 = color.Light(uipallet.Main, 0.37)
		dots.Parent = dotsbutton
		local shadow = Instance.new('TextButton')
		shadow.Name = 'Shadow'
		shadow.Size = UDim2.new(1, 0, 1, -5)
		shadow.BackgroundColor3 = Color3.new()
		shadow.BackgroundTransparency = 1
		shadow.AutoButtonColor = false
		shadow.ClipsDescendants = true
		shadow.Visible = false
		shadow.Text = ''
		shadow.Parent = window
		addCorner(shadow)
		local settingspane = Instance.new('TextButton')
		settingspane.Size = UDim2.new(0, 220, 1, 0)
		settingspane.Position = UDim2.fromScale(1, 0)
		settingspane.BackgroundColor3 = uipallet.Main
		settingspane.AutoButtonColor = false
		settingspane.Text = ''
		settingspane.Parent = shadow
		local settingstitle = Instance.new('TextLabel')
		settingstitle.Name = 'Title'
		settingstitle.Size = UDim2.new(1, -36, 0, 20)
		settingstitle.Position = UDim2.fromOffset(36, 12)
		settingstitle.BackgroundTransparency = 1
		settingstitle.Text = modulesettings.Name
		settingstitle.TextXAlignment = Enum.TextXAlignment.Left
		settingstitle.TextColor3 = uipallet.Text
		settingstitle.TextSize = 13
		settingstitle.FontFace = uipallet.Font
		settingstitle.Parent = settingspane
		local back = Instance.new('ImageButton')
		back.Name = 'Back'
		back.Size = UDim2.fromOffset(16, 16)
		back.Position = UDim2.fromOffset(11, 13)
		back.BackgroundTransparency = 1
		back.Image = getcustomasset('volt/assets/back.png')
		back.ImageColor3 = color.Light(uipallet.Main, 0.37)
		back.Parent = settingspane
		addCorner(settingspane, UDim.new(0, 8))
		addStroke(settingspane, uipallet.Outline, 1)
		local settingschildren = Instance.new('ScrollingFrame')
		settingschildren.Name = 'Children'
		settingschildren.Size = UDim2.new(1, 0, 1, -45)
		settingschildren.Position = UDim2.fromOffset(0, 41)
		settingschildren.BackgroundColor3 = uipallet.Main
		settingschildren.BorderSizePixel = 0
		settingschildren.ScrollBarThickness = 2
		settingschildren.ScrollBarImageTransparency = 0.75
		settingschildren.CanvasSize = UDim2.new()
		settingschildren.Parent = settingspane
		local settingswindowlist = Instance.new('UIListLayout')
		settingswindowlist.SortOrder = Enum.SortOrder.LayoutOrder
		settingswindowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
		settingswindowlist.Parent = settingschildren
		if modulesettings.Size then
			local modulechildren = Instance.new('Frame')
			modulechildren.Size = modulesettings.Size
			modulechildren.BackgroundTransparency = 1
			modulechildren.Visible = false
			modulechildren.Parent = scaledgui
			makeDraggable(modulechildren, window)
			local objectstroke = Instance.new('UIStroke')
			objectstroke.Color = Color3.fromRGB(80, 220, 120)
			objectstroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			objectstroke.Thickness = 0
			objectstroke.Parent = modulechildren
			moduleapi.Children = modulechildren
		end
		modulesettings.Function = modulesettings.Function or function() end
		addMaid(moduleapi)
		function moduleapi:Toggle()
			moduleapi.Enabled = not moduleapi.Enabled
			if moduleapi.Children then
				moduleapi.Children.Visible = moduleapi.Enabled
			end
			title.TextColor3 = moduleapi.Enabled and color.Light(uipallet.Text, 0.2) or uipallet.TextDim
			module.BackgroundColor3 = moduleapi.Enabled and color.Light(uipallet.Main, 0.05) or module.BackgroundColor3
			tween:Tween(knob, uipallet.Tween, {
				BackgroundColor3 = moduleapi.Enabled and Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value) or color.Light(uipallet.Main, 0.14)
			})
			tween:Tween(knobmain, uipallet.Tween, {
				Position = UDim2.fromOffset(moduleapi.Enabled and 12 or 2, 2)
			})
			if not moduleapi.Enabled then
				for _, v in moduleapi.Connections do
					v:Disconnect()
				end
				table.clear(moduleapi.Connections)
			end
			task.spawn(modulesettings.Function, moduleapi.Enabled)
		end
		hoverOn(back, back, {ImageColor3 = uipallet.Text}, {ImageColor3 = color.Light(uipallet.Main, 0.37)})
		local function hidesettings()
			tween:Tween(shadow, uipallet.Tween, {BackgroundTransparency = 1})
			tween:Tween(settingspane, uipallet.Tween, {Position = UDim2.fromScale(1, 0)})
			task.wait(0.2)
			shadow.Visible = false
		end
		back.MouseButton1Click:Connect(hidesettings)
		shadow.MouseButton1Click:Connect(hidesettings)
		local function showsettings()
			shadow.Visible = true
			tween:Tween(shadow, uipallet.Tween, {BackgroundTransparency = 0.5})
			tween:Tween(settingspane, uipallet.Tween, {Position = UDim2.new(1, -220, 0, 0)})
		end
		dotsbutton.MouseButton1Click:Connect(showsettings)
		module.MouseButton2Click:Connect(showsettings)
		hoverOn(dotsbutton, dots, {ImageColor3 = uipallet.Text}, {ImageColor3 = color.Light(uipallet.Main, 0.37)})
		module.MouseEnter:Connect(function()
			if not moduleapi.Enabled then
				module.BackgroundColor3 = color.Light(uipallet.Main, 0.05)
			end
		end)
		module.MouseLeave:Connect(function()
			if not moduleapi.Enabled then
				module.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
			end
		end)
		module.MouseButton1Click:Connect(function()
			moduleapi:Toggle()
		end)
		settingswindowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			if mainapi.ThreadFix then
				setthreadidentity(8)
			end
			settingschildren.CanvasSize = UDim2.fromOffset(0, settingswindowlist.AbsoluteContentSize.Y / scale.Scale)
		end)
		for i, v in components do
			moduleapi['Create' .. i] = function(_, optionsettings)
				return v(optionsettings, settingschildren, moduleapi)
			end
		end
		moduleapi.Object = module
		legitapi.Modules[modulesettings.Name] = moduleapi
		local sorting = {}
		for _, v in legitapi.Modules do
			table.insert(sorting, v.Name)
		end
		table.sort(sorting)
		for i, v in sorting do
			legitapi.Modules[v].Object.LayoutOrder = i
		end
		return moduleapi
	end
	local function visibleCheck()
		for _, v in legitapi.Modules do
			if v.Children then
				local visible = clickgui.Visible
				for _, v2 in self.Windows do
					visible = visible or v2.Visible
				end
				v.Children.Visible = (not visible or window.Visible) and v.Enabled
			end
		end
	end
	close.MouseButton1Click:Connect(function()
		window.Visible = false
		clickgui.Visible = true
	end)
	self:Clean(clickgui:GetPropertyChangedSignal('Visible'):Connect(visibleCheck))
	window:GetPropertyChangedSignal('Visible'):Connect(function()
		self:UpdateGUI(self.GUIColor.Hue, self.GUIColor.Sat, self.GUIColor.Value)
		visibleCheck()
	end)
	windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		if self.ThreadFix then
			setthreadidentity(8)
		end
		children.CanvasSize = UDim2.fromOffset(0, windowlist.AbsoluteContentSize.Y / scale.Scale)
	end)
	self.Legit = legitapi
	return legitapi
end
function mainapi:CreateNotification(title, text, duration, type)
	if not self.Notifications.Enabled then return end
	task.delay(0, function()
		if self.ThreadFix then
			setthreadidentity(8)
		end
		local i = #notifications:GetChildren() + 1
		local notification = Instance.new('ImageLabel')
		notification.Name = 'Notification'
		notification.Size = UDim2.fromOffset(math.max(getfontsize(removeTags(text), 14, uipallet.Font).X + 80, 266), 75)
		notification.Position = UDim2.new(1, 0, 1, -(29 + (78 * i)))
		notification.ZIndex = 5
		notification.BackgroundTransparency = 1
		notification.Image = getcustomasset('volt/assets/notification.png')
		notification.ScaleType = Enum.ScaleType.Slice
		notification.SliceCenter = Rect.new(7, 7, 9, 9)
		notification.Parent = notifications
		addBlur(notification, true)
		local iconshadow = Instance.new('ImageLabel')
		iconshadow.Name = 'Icon'
		iconshadow.Size = UDim2.fromOffset(60, 60)
		iconshadow.Position = UDim2.fromOffset(-5, -8)
		iconshadow.ZIndex = 5
		iconshadow.BackgroundTransparency = 1
		iconshadow.Image = getcustomasset('volt/assets/' .. (type or 'info') .. '.png')
		iconshadow.ImageColor3 = Color3.new()
		iconshadow.ImageTransparency = 0.5
		iconshadow.Parent = notification
		local icon = iconshadow:Clone()
		icon.Position = UDim2.fromOffset(-1, -1)
		icon.ImageColor3 = Color3.new(1, 1, 1)
		icon.ImageTransparency = 0
		icon.Parent = iconshadow
		local titlelabel = Instance.new('TextLabel')
		titlelabel.Name = 'Title'
		titlelabel.Size = UDim2.new(1, -56, 0, 20)
		titlelabel.Position = UDim2.fromOffset(46, 16)
		titlelabel.ZIndex = 5
		titlelabel.BackgroundTransparency = 1
		titlelabel.Text = "<stroke color='#FFFFFF' joins='round' thickness='0.3' transparency='0.5'>" .. title .. '</stroke>'
		titlelabel.TextXAlignment = Enum.TextXAlignment.Left
		titlelabel.TextYAlignment = Enum.TextYAlignment.Top
		titlelabel.TextColor3 = Color3.fromRGB(209, 209, 209)
		titlelabel.TextSize = 14
		titlelabel.RichText = true
		titlelabel.FontFace = uipallet.FontSemiBold
		titlelabel.Parent = notification
		local textshadow = titlelabel:Clone()
		textshadow.Name = 'Text'
		textshadow.Position = UDim2.fromOffset(47, 44)
		textshadow.Text = removeTags(text)
		textshadow.TextColor3 = Color3.new()
		textshadow.TextTransparency = 0.5
		textshadow.RichText = false
		textshadow.FontFace = uipallet.Font
		textshadow.Parent = notification
		local textlabel = textshadow:Clone()
		textlabel.Position = UDim2.fromOffset(-1, -1)
		textlabel.Text = text
		textlabel.TextColor3 = Color3.fromRGB(170, 170, 170)
		textlabel.TextTransparency = 0
		textlabel.RichText = true
		textlabel.Parent = textshadow
		local progress = Instance.new('Frame')
		progress.Name = 'Progress'
		progress.Size = UDim2.new(1, -13, 0, 2)
		progress.Position = UDim2.new(0, 3, 1, -4)
		progress.ZIndex = 5
		progress.BackgroundColor3 =
			type == 'alert' and Color3.fromRGB(245, 80, 80)
			or type == 'warning' and Color3.fromRGB(245, 190, 60)
			or Color3.fromRGB(220, 220, 220)
		progress.BorderSizePixel = 0
		progress.Parent = notification
		if tween.Tween then
			tween:Tween(notification, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
				AnchorPoint = Vector2.new(1, 0)
			}, tween.tweenstwo)
			tween:Tween(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
				Size = UDim2.fromOffset(0, 2)
			})
		end
		task.delay(duration, function()
			if tween.Tween then
				tween:Tween(notification, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
					AnchorPoint = Vector2.new(0, 0)
				}, tween.tweenstwo)
			end
			task.wait(0.2)
			notification:ClearAllChildren()
			notification:Destroy()
		end)
	end)
end
function mainapi:LoadOptions(object, savedoptions)
	for i, v in savedoptions do
		local option = object.Options[i]
		if not option then continue end
		option:Load(v)
	end
end
function mainapi:SaveOptions(object, savedoptions)
	if not savedoptions then return end
	savedoptions = {}
	for _, v in object.Options do
		if not v.Save then continue end
		v:Save(savedoptions)
	end
	return savedoptions
end
function mainapi:Remove(obj)
	local tab = (self.Modules[obj] and self.Modules or self.Legit.Modules[obj] and self.Legit.Modules or self.Categories)
	if tab and tab[obj] then
		local newobj = tab[obj]
		if self.ThreadFix then
			setthreadidentity(8)
		end
		for _, v in {'Object', 'Children', 'Toggle', 'Button'} do
			local childobj = typeof(newobj[v]) == 'table' and newobj[v].Object or newobj[v]
			if typeof(childobj) == 'Instance' then
				childobj:Destroy()
				childobj:ClearAllChildren()
			end
		end
		loopClean(newobj)
		tab[obj] = nil
	end
end
function mainapi:Save(newprofile)
	if not self.Loaded then return end
	local guidata = {
		Categories = {},
		Profile = newprofile or self.Profile,
		Profiles = self.Profiles,
		Keybind = self.Keybind
	}
	local savedata = {
		Modules = {},
		Categories = {},
		Legit = {}
	}
	for i, v in self.Categories do
		(v.Type ~= 'Category' and i ~= 'Main' and savedata or guidata).Categories[i] = {
			Enabled = i ~= 'Main' and v.Button.Enabled or nil,
			Expanded = v.Type ~= 'Overlay' and v.Expanded or nil,
			Pinned = v.Pinned,
			Position = {X = v.Object.Position.X.Offset, Y = v.Object.Position.Y.Offset},
			Options = mainapi:SaveOptions(v, v.Options),
			List = v.List,
			ListEnabled = v.ListEnabled
		}
	end
	for i, v in self.Modules do
		savedata.Modules[i] = {
			Enabled = v.Enabled,
			Bind = v.Bind.Button and {Mobile = true, X = v.Bind.Button.Position.X.Offset, Y = v.Bind.Button.Position.Y.Offset} or v.Bind,
			Options = mainapi:SaveOptions(v, true)
		}
	end
	for i, v in self.Legit.Modules do
		savedata.Legit[i] = {
			Enabled = v.Enabled,
			Position = v.Children and {X = v.Children.Position.X.Offset, Y = v.Children.Position.Y.Offset} or nil,
			Options = mainapi:SaveOptions(v, v.Options)
		}
	end
	writefile('volt/profiles/' .. game.GameId .. '.gui.txt', httpService:JSONEncode(guidata))
	writefile('volt/profiles/' .. self.Profile .. self.Place .. '.txt', httpService:JSONEncode(savedata))
end
function mainapi:Load(skipgui, profile)
	if not skipgui then
		self.GUIColor:SetValue(nil, nil, nil, 1)
	end
	local guidata = {}
	local savecheck = true
	if isfile('volt/profiles/' .. game.GameId .. '.gui.txt') then
		guidata = loadJson('volt/profiles/' .. game.GameId .. '.gui.txt')
		if not guidata then
			guidata = {Categories = {}}
			self:CreateNotification('Volt UI', 'Failed to load GUI settings.', 10, 'alert')
			savecheck = false
		end
		if not skipgui then
			self.Keybind = guidata.Keybind or self.Keybind
			for i, v in guidata.Categories do
				local object = self.Categories[i]
				if not object then continue end
				if object.Options and v.Options then
					self:LoadOptions(object, v.Options)
				end
				if v.Enabled then
					object.Button:Toggle()
				end
				if v.Pinned then
					object:Pin()
				end
				if v.Expanded and object.Expand then
					object:Expand()
				end
				if v.List and (#object.List > 0 or #v.List > 0) then
					object.List = v.List or {}
					object.ListEnabled = v.ListEnabled or {}
					object:ChangeValue()
				end
				if v.Position then
					object.Object.Position = UDim2.fromOffset(v.Position.X, v.Position.Y)
				end
			end
		end
	end
	self.Profile = profile or guidata.Profile or 'default'
	self.Profiles = guidata.Profiles or {{
		Name = 'default', Bind = {}
	}}
	self.Categories.Profiles:ChangeValue()
	if self.ProfileLabel then
		self.ProfileLabel.Text = #self.Profile > 10 and self.Profile:sub(1, 10) .. '...' or self.Profile
		self.ProfileLabel.Size = UDim2.fromOffset(getfontsize(self.ProfileLabel.Text, self.ProfileLabel.TextSize, self.ProfileLabel.Font).X + 16, 24)
	end
	if isfile('volt/profiles/' .. self.Profile .. self.Place .. '.txt') then
		local savedata = loadJson('volt/profiles/' .. self.Profile .. self.Place .. '.txt')
		if not savedata then
			savedata = {Categories = {}, Modules = {}, Legit = {}}
			self:CreateNotification('Volt UI', 'Failed to load ' .. self.Profile .. ' profile.', 10, 'alert')
			savecheck = false
		end
		for i, v in savedata.Categories do
			local object = self.Categories[i]
			if not object then continue end
			if object.Options and v.Options then
				self:LoadOptions(object, v.Options)
			end
			if v.Pinned ~= object.Pinned then
				object:Pin()
			end
			if v.Expanded ~= nil and v.Expanded ~= object.Expanded then
				object:Expand()
			end
			if object.Button and (v.Enabled or false) ~= object.Button.Enabled then
				object.Button:Toggle()
			end
			if v.List and (#object.List > 0 or #v.List > 0) then
				object.List = v.List or {}
				object.ListEnabled = v.ListEnabled or {}
				object:ChangeValue()
			end
			if v.Position then
				object.Object.Position = UDim2.fromOffset(v.Position.X, v.Position.Y)
			end
		end
		for i, v in savedata.Modules do
			local object = self.Modules[i]
			if not object then continue end
			if object.Options and v.Options then
				self:LoadOptions(object, v.Options)
			end
			if v.Enabled ~= object.Enabled then
				if skipgui then
					if self.ToggleNotifications.Enabled then self:CreateNotification('Module Toggled', i .. "<font color='#FFFFFF'> has been </font>" .. (v.Enabled and "<font color='#5AFF5A'>Enabled</font>" or "<font color='#FF5A5A'>Disabled</font>") .. "<font color='#FFFFFF'>!</font>", 0.75) end
				end
				object:Toggle(true)
			end
			object:SetBind(v.Bind or {})
			object.Object.Bind.Visible = #(v.Bind or {}) > 0
		end
		for i, v in savedata.Legit do
			local object = self.Legit.Modules[i]
			if not object then continue end
			if object.Options and v.Options then
				self:LoadOptions(object, v.Options)
			end
			if object.Enabled ~= v.Enabled then
				object:Toggle()
			end
			if v.Position and object.Children then
				object.Children.Position = UDim2.fromOffset(v.Position.X, v.Position.Y)
			end
		end
		self:UpdateTextGUI(true)
	else
		self:Save()
	end
	if self.Downloader then
		self.Downloader:Destroy()
		self.Downloader = nil
	end
	self.Loaded = savecheck
	self.Categories.Main.Options.Bind:SetBind(self.Keybind)
	if inputService.TouchEnabled and #self.Keybind == 1 and self.Keybind[1] == 'RightShift' then
		local button = Instance.new('TextButton')
		button.Size = UDim2.fromOffset(32, 32)
		button.Position = UDim2.new(1, -90, 0, 4)
		button.BackgroundColor3 = Color3.new()
		button.BackgroundTransparency = 0.5
		button.Text = ''
		button.Parent = gui
		local image = Instance.new('ImageLabel')
		image.Size = UDim2.fromOffset(26, 26)
		image.Position = UDim2.fromOffset(3, 3)
		image.BackgroundTransparency = 1
		image.Image = getcustomasset('volt/assets/volt.png')
		image.Parent = button
		local buttoncorner = Instance.new('UICorner')
		buttoncorner.Parent = button
		self.VoltButton = button
		button.MouseButton1Click:Connect(function()
			if self.ThreadFix then
				setthreadidentity(8)
			end
			for _, v in self.Windows do
				v.Visible = false
			end
			for _, mobileButton in self.Modules do
				if mobileButton.Bind.Button then
					mobileButton.Bind.Button.Visible = clickgui.Visible
				end
			end
			clickgui.Visible = not clickgui.Visible
			tooltip.Visible = false
			self:BlurCheck()
		end)
	end
end
function mainapi:Uninject()
	mainapi:Save()
	mainapi.Loaded = nil
	for _, v in self.Modules do
		if v.Enabled then
			v:Toggle()
		end
	end
	for _, v in self.Legit.Modules do
		if v.Enabled then
			v:Toggle()
		end
	end
	for _, v in self.Categories do
		if v.Type == 'Overlay' and v.Button.Enabled then
			v.Button:Toggle()
		end
	end
	for _, v in mainapi.Connections do
		pcall(function()
			v:Disconnect()
		end)
	end
	if mainapi.VoltButton then
		mainapi.VoltButton:Destroy()
		mainapi.VoltButton = nil
	end
	if mainapi.ThreadFix then
		setthreadidentity(8)
		clickgui.Visible = false
		mainapi:BlurCheck()
	end
	mainapi.gui:ClearAllChildren()
	mainapi.gui:Destroy()
	table.clear(mainapi.Connections)
	table.clear(mainapi.Libraries)
	loopClean(mainapi)
	shared.volt = nil
	shared.voltreload = nil
	shared.VoltIndependent = nil
end
gui = Instance.new('ScreenGui')
gui.Name = randomString()
gui.DisplayOrder = 9999999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.IgnoreGuiInset = true
gui.OnTopOfCoreBlur = true
if mainapi.ThreadFix then
	gui.Parent = cloneref(game:GetService('CoreGui'))
else
	gui.Parent = cloneref(game:GetService('Players')).LocalPlayer.PlayerGui
	gui.ResetOnSpawn = false
end
mainapi.gui = gui
scaledgui = Instance.new('Frame')
scaledgui.Name = 'ScaledGui'
scaledgui.Size = UDim2.fromScale(1, 1)
scaledgui.BackgroundTransparency = 1
scaledgui.Parent = gui
clickgui = Instance.new('Frame')
clickgui.Name = 'ClickGui'
clickgui.Size = UDim2.fromScale(1, 1)
clickgui.BackgroundTransparency = 1
clickgui.Visible = false
clickgui.Parent = scaledgui
local modal = Instance.new('TextButton')
modal.BackgroundTransparency = 1
modal.Modal = true
modal.Text = ''
modal.Parent = clickgui
local cursor = Instance.new('ImageLabel')
cursor.Size = UDim2.fromOffset(64, 64)
cursor.BackgroundTransparency = 1
cursor.Visible = false
cursor.Image = 'rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png'
cursor.Parent = gui
notifications = Instance.new('Folder')
notifications.Name = 'Notifications'
notifications.Parent = scaledgui
tooltip = Instance.new('TextLabel')
tooltip.Name = 'Tooltip'
tooltip.Position = UDim2.fromScale(-1, -1)
tooltip.ZIndex = 5
tooltip.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
tooltip.Visible = false
tooltip.Text = ''
tooltip.TextColor3 = uipallet.Text
tooltip.TextSize = 12
tooltip.FontFace = uipallet.Font
tooltip.Parent = scaledgui
toolblur = addBlur(tooltip)
addCorner(tooltip)
addStroke(tooltip, uipallet.Outline, 1)
local toolstrokebkg = Instance.new('Frame')
toolstrokebkg.Size = UDim2.new(1, -2, 1, -2)
toolstrokebkg.Position = UDim2.fromOffset(1, 1)
toolstrokebkg.ZIndex = 6
toolstrokebkg.BackgroundTransparency = 1
toolstrokebkg.Parent = tooltip
local toolstroke = Instance.new('UIStroke')
toolstroke.Color = color.Dark(uipallet.Main, 0.02)
toolstroke.Parent = toolstrokebkg
addCorner(toolstrokebkg, UDim.new(0, 4))
scale = Instance.new('UIScale')
scale.Scale = math.max(gui.AbsoluteSize.X / 1920, 0.6)
scale.Parent = scaledgui
mainapi.guiscale = scale
scaledgui.Size = UDim2.fromScale(1 / scale.Scale, 1 / scale.Scale)
mainapi:Clean(gui:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
	if mainapi.Scale.Enabled then
		scale.Scale = math.max(gui.AbsoluteSize.X / 1920, 0.6)
	end
end))
mainapi:Clean(scale:GetPropertyChangedSignal('Scale'):Connect(function()
	scaledgui.Size = UDim2.fromScale(1 / scale.Scale, 1 / scale.Scale)
	for _, v in scaledgui:GetDescendants() do
		if v:IsA('GuiObject') and v.Visible then
			v.Visible = false
			v.Visible = true
		end
	end
end))
mainapi:Clean(clickgui:GetPropertyChangedSignal('Visible'):Connect(function()
	mainapi:UpdateGUI(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value, true)
	if clickgui.Visible and inputService.MouseEnabled then
		repeat
			local visibleCheck = clickgui.Visible
			for _, v in mainapi.Windows do
				visibleCheck = visibleCheck or v.Visible
			end
			if not visibleCheck then break end
			cursor.Visible = not inputService.MouseIconEnabled
			if cursor.Visible then
				local mouseLocation = inputService:GetMouseLocation()
				cursor.Position = UDim2.fromOffset(mouseLocation.X - 31, mouseLocation.Y - 32)
			end
			task.wait()
		until mainapi.Loaded == nil
		cursor.Visible = false
	end
end))
mainapi:CreateGUI()
mainapi.Categories.Main:CreateDivider()
mainapi:CreateCategory({
	Name = 'Combat',
	Icon = getcustomasset('volt/assets/combaticon.png'),
	Size = UDim2.fromOffset(13, 14)
})
mainapi:CreateCategory({
	Name = 'Blatant',
	Icon = getcustomasset('volt/assets/blatanticon.png'),
	Size = UDim2.fromOffset(14, 14)
})
mainapi:CreateCategory({
	Name = 'Render',
	Icon = getcustomasset('volt/assets/rendericon.png'),
	Size = UDim2.fromOffset(15, 14)
})
mainapi:CreateCategory({
	Name = 'Utility',
	Icon = getcustomasset('volt/assets/utilityicon.png'),
	Size = UDim2.fromOffset(15, 14)
})
mainapi:CreateCategory({
	Name = 'World',
	Icon = getcustomasset('volt/assets/worldicon.png'),
	Size = UDim2.fromOffset(14, 14)
})
mainapi:CreateCategory({
	Name = 'Inventory',
	Icon = getcustomasset('volt/assets/inventoryicon.png'),
	Size = UDim2.fromOffset(15, 14)
})
mainapi:CreateCategory({
	Name = 'Minigames',
	Icon = getcustomasset('volt/assets/miniicon.png'),
	Size = UDim2.fromOffset(19, 12)
})
mainapi.Categories.Main:CreateDivider('misc')
local friends
local friendscolor = {
	Hue = 1,
	Sat = 1,
	Value = 1
}
local friendssettings = {
	Name = 'Friends',
	Icon = getcustomasset('volt/assets/friendstab.png'),
	Size = UDim2.fromOffset(17, 16),
	Placeholder = 'Roblox username',
	Color = Color3.fromRGB(80, 220, 120),
	Function = function()
		friends.Update:Fire()
		friends.ColorUpdate:Fire(friendscolor.Hue, friendscolor.Sat, friendscolor.Value)
	end
}
friends = mainapi:CreateCategoryList(friendssettings)
friends.Update = Instance.new('BindableEvent')
friends.ColorUpdate = Instance.new('BindableEvent')
friends:CreateToggle({
	Name = 'Recolor visuals',
	Darker = true,
	Default = true,
	Function = function()
		friends.Update:Fire()
		friends.ColorUpdate:Fire(friendscolor.Hue, friendscolor.Sat, friendscolor.Value)
	end
})
friendscolor = friends:CreateColorSlider({
	Name = 'Friends color',
	Darker = true,
	Function = function(hue, sat, val)
		for _, v in friends.Object.Children:GetChildren() do
			local dot = v:FindFirstChild('Dot')
			if dot and dot.BackgroundColor3 ~= color.Light(uipallet.Main, 0.37) then
				dot.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
				dot.Dot.BackgroundColor3 = dot.BackgroundColor3
			end
		end
		friendssettings.Color = Color3.fromHSV(hue, sat, val)
		friends.ColorUpdate:Fire(hue, sat, val)
	end
})
friends:CreateToggle({
	Name = 'Use friends',
	Darker = true,
	Default = true,
	Function = function()
		friends.Update:Fire()
		friends.ColorUpdate:Fire(friendscolor.Hue, friendscolor.Sat, friendscolor.Value)
	end
})
mainapi:Clean(friends.Update)
mainapi:Clean(friends.ColorUpdate)
mainapi:CreateCategoryList({
	Name = 'Profiles',
	Icon = getcustomasset('volt/assets/profilesicon.png'),
	Size = UDim2.fromOffset(17, 10),
	Position = UDim2.fromOffset(12, 16),
	Placeholder = 'Type name',
	Profiles = true
})
local targets
targets = mainapi:CreateCategoryList({
	Name = 'Targets',
	Icon = getcustomasset('volt/assets/friendstab.png'),
	Size = UDim2.fromOffset(17, 16),
	Placeholder = 'Roblox username',
	Function = function()
		targets.Update:Fire()
	end
})
targets.Update = Instance.new('BindableEvent')
mainapi:Clean(targets.Update)
mainapi:CreateLegit()
mainapi:CreateSearch()
mainapi.Categories.Main:CreateOverlayBar()
mainapi.Categories.Main:CreateSettingsDivider()
local general = mainapi.Categories.Main:CreateSettingsPane({Name = 'General'})
mainapi.MultiKeybind = general:CreateToggle({
	Name = 'Enable Multi-Keybinding',
	Tooltip = 'Allows multiple keys to be bound to a module (eg. G + H)'
})
general:CreateButton({
	Name = 'Reset current profile',
	Function = function()
		if isfile('volt/profiles/' .. mainapi.Profile .. mainapi.Place .. '.txt') and delfile then
			delfile('volt/profiles/' .. mainapi.Profile .. mainapi.Place .. '.txt')
		end
		mainapi:Load(true)
	end,
	Tooltip = 'This will set your profile to the default settings of Volt UI'
})
general:CreateButton({
	Name = 'Self destruct',
	Function = function()
		mainapi:Uninject()
	end,
	Tooltip = 'Removes Volt UI from the current game'
})
general:CreateButton({
	Name = 'Reload profiles',
	Function = function()
		mainapi:Load(true)
	end,
	Tooltip = 'Reloads Volt UI profiles from local storage'
})
local modules = mainapi.Categories.Main:CreateSettingsPane({Name = 'Modules'})
modules:CreateToggle({
	Name = 'Teams by server',
	Tooltip = 'Ignore players on your team designated by the server',
	Default = true,
	Function = function()
		if mainapi.Libraries.entity and mainapi.Libraries.entity.Running then
			mainapi.Libraries.entity.refresh()
		end
	end
})
modules:CreateToggle({
	Name = 'Use team color',
	Tooltip = 'Uses the TeamColor property on players for render modules',
	Default = true,
	Function = function()
		if mainapi.Libraries.entity and mainapi.Libraries.entity.Running then
			mainapi.Libraries.entity.refresh()
		end
	end
})
local guipane = mainapi.Categories.Main:CreateSettingsPane({Name = 'GUI'})
mainapi.Blur = guipane:CreateToggle({
	Name = 'Blur background',
	Function = function()
		mainapi:BlurCheck()
	end,
	Default = true,
	Tooltip = 'Blur the background of the GUI'
})
guipane:CreateToggle({
	Name = 'GUI bind indicator',
	Default = true,
	Tooltip = "Displays a message indicating your GUI upon injecting."
})
guipane:CreateToggle({
	Name = 'Show tooltips',
	Function = function(enabled)
		tooltip.Visible = false
		toolblur.Visible = enabled
	end,
	Default = true,
	Tooltip = 'Toggles visibility of these'
})
guipane:CreateToggle({
	Name = 'Show legit mode',
	Function = function(enabled)
		clickgui.Search.Legit.Visible = enabled
		clickgui.Search.LegitDivider.Visible = enabled
		clickgui.Search.TextBox.Size = UDim2.new(1, enabled and -50 or -10, 0, 37)
		clickgui.Search.TextBox.Position = UDim2.fromOffset(enabled and 50 or 10, 0)
	end,
	Default = true,
	Tooltip = 'Shows the button to change to Legit Mode'
})
local scaleslider = {Object = {}, Value = 1}
mainapi.Scale = guipane:CreateToggle({
	Name = 'Auto rescale',
	Default = true,
	Function = function(callback)
		scaleslider.Object.Visible = not callback
		if callback then
			scale.Scale = math.max(gui.AbsoluteSize.X / 1920, 0.6)
		else
			scale.Scale = scaleslider.Value
		end
	end,
	Tooltip = 'Automatically rescales the gui using the screens resolution'
})
scaleslider = guipane:CreateSlider({
	Name = 'Scale',
	Min = 0.1,
	Max = 2,
	Decimal = 10,
	Function = function(val, final)
		if final and not mainapi.Scale.Enabled then
			scale.Scale = val
		end
	end,
	Default = 1,
	Darker = true,
	Visible = false
})
mainapi.RainbowMode = guipane:CreateDropdown({
	Name = 'Rainbow Mode',
	List = {'Normal', 'Gradient', 'Retro'},
	Tooltip = 'Normal - Smooth color fade\nGradient - Gradient color fade\nRetro - Static color'
})
mainapi.RainbowSpeed = guipane:CreateSlider({
	Name = 'Rainbow speed',
	Min = 0.1,
	Max = 10,
	Decimal = 10,
	Default = 1,
	Tooltip = 'Adjusts the speed of rainbow values'
})
mainapi.RainbowUpdateSpeed = guipane:CreateSlider({
	Name = 'Rainbow update rate',
	Min = 1,
	Max = 144,
	Default = 60,
	Tooltip = 'Adjusts the update rate of rainbow values',
	Suffix = 'hz'
})
guipane:CreateButton({
	Name = 'Reset GUI positions',
	Function = function()
		for _, v in mainapi.Categories do
			v.Object.Position = UDim2.fromOffset(6, 42)
		end
	end,
	Tooltip = 'This will reset your GUI back to default'
})
guipane:CreateButton({
	Name = 'Sort GUI',
	Function = function()
		local priority = {
			GUICategory = 1,
			CombatCategory = 2,
			BlatantCategory = 3,
			RenderCategory = 4,
			UtilityCategory = 5,
			WorldCategory = 6,
			InventoryCategory = 7,
			MinigamesCategory = 8,
			FriendsCategory = 9,
			ProfilesCategory = 10
		}
		local categories = {}
		for _, v in mainapi.Categories do
			if v.Type ~= 'Overlay' then
				table.insert(categories, v)
			end
		end
		table.sort(categories, function(a, b)
			return (priority[a.Object.Name] or 99) < (priority[b.Object.Name] or 99)
		end)
		local ind = 0
		for _, v in categories do
			if v.Object.Visible then
				v.Object.Position = UDim2.fromOffset(6 + (ind % 8 * 230), 60 + (ind > 7 and 360 or 0))
				ind += 1
			end
		end
	end,
	Tooltip = 'Sorts GUI'
})
local notifpane = mainapi.Categories.Main:CreateSettingsPane({Name = 'Notifications'})
mainapi.Notifications = notifpane:CreateToggle({
	Name = 'Notifications',
	Function = function(enabled)
		if mainapi.ToggleNotifications.Object then
			mainapi.ToggleNotifications.Object.Visible = enabled
		end
	end,
	Tooltip = 'Shows notifications',
	Default = true
})
mainapi.ToggleNotifications = notifpane:CreateToggle({
	Name = 'Toggle alert',
	Tooltip = 'Notifies you if a module is enabled/disabled.',
	Default = true,
	Darker = true
})
mainapi.GUIColor = mainapi.Categories.Main:CreateGUISlider({
	Name = 'GUI Theme',
	Function = function(h, s, v)
		mainapi:UpdateGUI(h, s, v, true)
	end
})
mainapi.Categories.Main:CreateBind()
local textgui = mainapi:CreateOverlay({
	Name = 'Text GUI',
	Icon = getcustomasset('volt/assets/textguiicon.png'),
	Size = UDim2.fromOffset(16, 12),
	Position = UDim2.fromOffset(12, 14),
	Function = function()
		mainapi:UpdateTextGUI()
	end
})
local textguisort = textgui:CreateDropdown({
	Name = 'Sort',
	List = {'Alphabetical', 'Length'},
	Function = function()
		mainapi:UpdateTextGUI()
	end
})
local textguifont = textgui:CreateFont({
	Name = 'Font',
	Blacklist = 'Arial',
	Function = function()
		mainapi:UpdateTextGUI()
	end
})
local textguicolor
local textguicolordrop = textgui:CreateDropdown({
	Name = 'Color Mode',
	List = {'Match GUI color', 'Custom color'},
	Function = function(val)
		textguicolor.Object.Visible = val == 'Custom color'
		mainapi:UpdateTextGUI()
	end
})
textguicolor = textgui:CreateColorSlider({
	Name = 'Text GUI color',
	Function = function()
		mainapi:UpdateGUI(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value)
	end,
	Darker = true,
	Visible = false
})
local VoltTextScale = Instance.new('UIScale')
VoltTextScale.Parent = textgui.Children
local textguiscale = textgui:CreateSlider({
	Name = 'Scale',
	Min = 0,
	Max = 2,
	Decimal = 10,
	Default = 1,
	Function = function(val)
		VoltTextScale.Scale = val
		mainapi:UpdateTextGUI()
	end
})
local textguishadow = textgui:CreateToggle({
	Name = 'Shadow',
	Tooltip = 'Renders shadowed text.',
	Function = function()
		mainapi:UpdateTextGUI()
	end
})
local textguigradientv4
local textguigradient = textgui:CreateToggle({
	Name = 'Gradient',
	Tooltip = 'Renders a gradient',
	Function = function(callback)
		textguigradientv4.Object.Visible = callback
		mainapi:UpdateTextGUI()
	end
})
textguigradientv4 = textgui:CreateToggle({
	Name = 'V5 Gradient',
	Function = function()
		mainapi:UpdateTextGUI()
	end,
	Darker = true,
	Visible = false
})
local textguianimations = textgui:CreateToggle({
	Name = 'Animations',
	Tooltip = 'Use animations on text gui',
	Function = function()
		mainapi:UpdateTextGUI()
	end
})
local textguiwatermark = textgui:CreateToggle({
	Name = 'Watermark',
	Tooltip = 'Renders a Volt UI watermark',
	Function = function()
		mainapi:UpdateTextGUI()
	end
})
local textguibackgroundtransparency = {
	Value = 0.5,
	Object = {Visible = {}}
}
local textguibackgroundtint = {Enabled = false}
local textguibackground = textgui:CreateToggle({
	Name = 'Render background',
	Function = function(callback)
		textguibackgroundtransparency.Object.Visible = callback
		textguibackgroundtint.Object.Visible = callback
		mainapi:UpdateTextGUI()
	end
})
textguibackgroundtransparency = textgui:CreateSlider({
	Name = 'Transparency',
	Min = 0,
	Max = 1,
	Default = 0.5,
	Decimal = 10,
	Function = function()
		mainapi:UpdateTextGUI()
	end,
	Darker = true,
	Visible = false
})
textguibackgroundtint = textgui:CreateToggle({
	Name = 'Tint',
	Function = function()
		mainapi:UpdateTextGUI()
	end,
	Darker = true,
	Visible = false
})
local textguimoduleslist
local textguimodules = textgui:CreateToggle({
	Name = 'Hide modules',
	Tooltip = 'Allows you to blacklist certain modules from being shown.',
	Function = function(enabled)
		textguimoduleslist.Object.Visible = enabled
		mainapi:UpdateTextGUI()
	end
})
textguimoduleslist = textgui:CreateTextList({
	Name = 'Blacklist',
	Tooltip = 'Name of module to hide.',
	Icon = getcustomasset('volt/assets/blockedicon.png'),
	Tab = getcustomasset('volt/assets/blockedtab.png'),
	TabSize = UDim2.fromOffset(21, 16),
	Color = Color3.fromRGB(245, 80, 80),
	Function = function()
		mainapi:UpdateTextGUI()
	end,
	Visible = false,
	Darker = true
})
local textguirender = textgui:CreateToggle({
	Name = 'Hide render',
	Function = function()
		mainapi:UpdateTextGUI()
	end
})
local textguibox
local textguifontcustom
local textguicolorcustomtoggle
local textguicolorcustom
local textguitext = textgui:CreateToggle({
	Name = 'Add custom text',
	Function = function(enabled)
		textguibox.Object.Visible = enabled
		textguifontcustom.Object.Visible = enabled
		textguicolorcustomtoggle.Object.Visible = enabled
		textguicolorcustom.Object.Visible = textguicolorcustomtoggle.Enabled and enabled
		mainapi:UpdateTextGUI()
	end
})
textguibox = textgui:CreateTextBox({
	Name = 'Custom text',
	Function = function()
		mainapi:UpdateTextGUI()
	end,
	Darker = true,
	Visible = false
})
textguifontcustom = textgui:CreateFont({
	Name = 'Custom Font',
	Blacklist = 'Arial',
	Function = function()
		mainapi:UpdateTextGUI()
	end,
	Darker = true,
	Visible = false
})
textguicolorcustomtoggle = textgui:CreateToggle({
	Name = 'Set custom text color',
	Function = function(enabled)
		textguicolorcustom.Object.Visible = enabled
		mainapi:UpdateGUI(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value)
	end,
	Darker = true,
	Visible = false
})
textguicolorcustom = textgui:CreateColorSlider({
	Name = 'Color of custom text',
	Function = function()
		mainapi:UpdateGUI(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value)
	end,
	Darker = true,
	Visible = false
})
local VoltLabels = {}
local VoltLogo = Instance.new('ImageLabel')
VoltLogo.Name = 'Logo'
VoltLogo.Size = UDim2.fromOffset(80, 21)
VoltLogo.Position = UDim2.new(1, -142, 0, 3)
VoltLogo.BackgroundTransparency = 1
VoltLogo.BorderSizePixel = 0
VoltLogo.Visible = false
VoltLogo.BackgroundColor3 = Color3.new()
VoltLogo.Image = getcustomasset('volt/assets/textvolt.png')
VoltLogo.Parent = textgui.Children
local lastside = textgui.Children.AbsolutePosition.X > (gui.AbsoluteSize.X / 2)
mainapi:Clean(textgui.Children:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
	if mainapi.ThreadFix then
		setthreadidentity(8)
	end
	local newside = textgui.Children.AbsolutePosition.X > (gui.AbsoluteSize.X / 2)
	if lastside ~= newside then
		lastside = newside
		mainapi:UpdateTextGUI()
	end
end))
local VoltLogoV4 = Instance.new('ImageLabel')
VoltLogoV4.Name = 'Logo2'
VoltLogoV4.Size = UDim2.fromOffset(33, 18)
VoltLogoV4.Position = UDim2.new(1, 1, 0, 1)
VoltLogoV4.BackgroundColor3 = Color3.new()
VoltLogoV4.BackgroundTransparency = 1
VoltLogoV4.BorderSizePixel = 0
VoltLogoV4.Image = getcustomasset('volt/assets/textv4.png')
VoltLogoV4.Parent = VoltLogo
local VoltLogoShadow = VoltLogo:Clone()
VoltLogoShadow.Position = UDim2.fromOffset(1, 1)
VoltLogoShadow.ZIndex = 0
VoltLogoShadow.Visible = true
VoltLogoShadow.ImageColor3 = Color3.new()
VoltLogoShadow.ImageTransparency = 0.65
VoltLogoShadow.Parent = VoltLogo
VoltLogoShadow.Logo2.ZIndex = 0
VoltLogoShadow.Logo2.ImageColor3 = Color3.new()
VoltLogoShadow.Logo2.ImageTransparency = 0.65
local VoltLogoGradient = Instance.new('UIGradient')
VoltLogoGradient.Rotation = 90
VoltLogoGradient.Parent = VoltLogo
local VoltLogoGradient2 = Instance.new('UIGradient')
VoltLogoGradient2.Rotation = 90
VoltLogoGradient2.Parent = VoltLogoV4
local VoltLabelCustom = Instance.new('TextLabel')
VoltLabelCustom.Position = UDim2.fromOffset(5, 2)
VoltLabelCustom.BackgroundTransparency = 1
VoltLabelCustom.BorderSizePixel = 0
VoltLabelCustom.Visible = false
VoltLabelCustom.Text = ''
VoltLabelCustom.TextSize = 25
VoltLabelCustom.FontFace = textguifontcustom.Value
VoltLabelCustom.RichText = true
local VoltLabelCustomShadow = VoltLabelCustom:Clone()
VoltLabelCustom:GetPropertyChangedSignal('Position'):Connect(function()
	VoltLabelCustomShadow.Position = UDim2.new(
		VoltLabelCustom.Position.X.Scale,
		VoltLabelCustom.Position.X.Offset + 1,
		0,
		VoltLabelCustom.Position.Y.Offset + 1
	)
end)
VoltLabelCustom:GetPropertyChangedSignal('FontFace'):Connect(function()
	VoltLabelCustomShadow.FontFace = VoltLabelCustom.FontFace
end)
VoltLabelCustom:GetPropertyChangedSignal('Text'):Connect(function()
	VoltLabelCustomShadow.Text = removeTags(VoltLabelCustom.Text)
end)
VoltLabelCustom:GetPropertyChangedSignal('Size'):Connect(function()
	VoltLabelCustomShadow.Size = VoltLabelCustom.Size
end)
VoltLabelCustomShadow.TextColor3 = Color3.new()
VoltLabelCustomShadow.TextTransparency = 0.65
VoltLabelCustomShadow.Parent = textgui.Children
VoltLabelCustom.Parent = textgui.Children
local VoltLabelHolder = Instance.new('Frame')
VoltLabelHolder.Name = 'Holder'
VoltLabelHolder.Size = UDim2.fromScale(1, 1)
VoltLabelHolder.Position = UDim2.fromOffset(5, 37)
VoltLabelHolder.BackgroundTransparency = 1
VoltLabelHolder.Parent = textgui.Children
local VoltLabelSorter = Instance.new('UIListLayout')
VoltLabelSorter.HorizontalAlignment = Enum.HorizontalAlignment.Right
VoltLabelSorter.VerticalAlignment = Enum.VerticalAlignment.Top
VoltLabelSorter.SortOrder = Enum.SortOrder.LayoutOrder
VoltLabelSorter.Parent = VoltLabelHolder
local targetinfo
local targetinfoobj
local targetinfobcolor
targetinfoobj = mainapi:CreateOverlay({
	Name = 'Target Info',
	Icon = getcustomasset('volt/assets/targetinfoicon.png'),
	Size = UDim2.fromOffset(14, 14),
	Position = UDim2.fromOffset(12, 14),
	CategorySize = 240,
	Function = function(callback)
		if callback then
			task.spawn(function()
				repeat
					targetinfo:UpdateInfo()
					task.wait()
				until not targetinfoobj.Button or not targetinfoobj.Button.Enabled
			end)
		end
	end
})
local targetinfobkg = Instance.new('Frame')
targetinfobkg.Size = UDim2.fromOffset(240, 89)
targetinfobkg.BackgroundColor3 = color.Dark(uipallet.Main, 0.1)
targetinfobkg.BackgroundTransparency = 0.5
targetinfobkg.Parent = targetinfoobj.Children
local targetinfoblurobj = addBlur(targetinfobkg)
targetinfoblurobj.Visible = false
addCorner(targetinfobkg)
local targetinfoshot = Instance.new('ImageLabel')
targetinfoshot.Size = UDim2.fromOffset(26, 27)
targetinfoshot.Position = UDim2.fromOffset(19, 17)
targetinfoshot.BackgroundColor3 = uipallet.Main
targetinfoshot.Image = 'rbxthumb://type=AvatarHeadShot&id=1&w=420&h=420'
targetinfoshot.Parent = targetinfobkg
local targetinfoshotflash = Instance.new('Frame')
targetinfoshotflash.Size = UDim2.fromScale(1, 1)
targetinfoshotflash.BackgroundTransparency = 1
targetinfoshotflash.BackgroundColor3 = Color3.new(1, 0, 0)
targetinfoshotflash.Parent = targetinfoshot
addCorner(targetinfoshotflash)
local targetinfoshotblur = addBlur(targetinfoshot)
targetinfoshotblur.Visible = false
addCorner(targetinfoshot)
local targetinfoname = Instance.new('TextLabel')
targetinfoname.Size = UDim2.fromOffset(145, 20)
targetinfoname.Position = UDim2.fromOffset(54, 20)
targetinfoname.BackgroundTransparency = 1
targetinfoname.Text = 'Target name'
targetinfoname.TextXAlignment = Enum.TextXAlignment.Left
targetinfoname.TextYAlignment = Enum.TextYAlignment.Top
targetinfoname.TextScaled = true
targetinfoname.TextColor3 = color.Light(uipallet.Text, 0.4)
targetinfoname.TextStrokeTransparency = 1
targetinfoname.FontFace = uipallet.Font
local targetinfoshadow = targetinfoname:Clone()
targetinfoshadow.Position = UDim2.fromOffset(55, 21)
targetinfoshadow.TextColor3 = Color3.new()
targetinfoshadow.TextTransparency = 0.65
targetinfoshadow.Visible = false
targetinfoshadow.Parent = targetinfobkg
targetinfoname:GetPropertyChangedSignal('Size'):Connect(function()
	targetinfoshadow.Size = targetinfoname.Size
end)
targetinfoname:GetPropertyChangedSignal('Text'):Connect(function()
	targetinfoshadow.Text = targetinfoname.Text
end)
targetinfoname:GetPropertyChangedSignal('FontFace'):Connect(function()
	targetinfoshadow.FontFace = targetinfoname.FontFace
end)
targetinfoname.Parent = targetinfobkg
local targetinfohealthbkg = Instance.new('Frame')
targetinfohealthbkg.Name = 'HealthBKG'
targetinfohealthbkg.Size = UDim2.fromOffset(200, 9)
targetinfohealthbkg.Position = UDim2.fromOffset(20, 56)
targetinfohealthbkg.BackgroundColor3 = uipallet.Main
targetinfohealthbkg.BorderSizePixel = 0
targetinfohealthbkg.Parent = targetinfobkg
addCorner(targetinfohealthbkg, UDim.new(1, 0))
local targetinfohealth = targetinfohealthbkg:Clone()
targetinfohealth.Size = UDim2.fromScale(0.8, 1)
targetinfohealth.Position = UDim2.new()
targetinfohealth.BackgroundColor3 = Color3.fromHSV(1 / 2.5, 0.89, 0.75)
targetinfohealth.Parent = targetinfohealthbkg
targetinfohealth:GetPropertyChangedSignal('Size'):Connect(function()
	targetinfohealth.Visible = targetinfohealth.Size.X.Scale > 0.01
end)
local targetinfohealthextra = targetinfohealth:Clone()
targetinfohealthextra.Size = UDim2.new()
targetinfohealthextra.Position = UDim2.fromScale(1, 0)
targetinfohealthextra.AnchorPoint = Vector2.new(1, 0)
targetinfohealthextra.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
targetinfohealthextra.Visible = false
targetinfohealthextra.Parent = targetinfohealthbkg
targetinfohealthextra:GetPropertyChangedSignal('Size'):Connect(function()
	targetinfohealthextra.Visible = targetinfohealthextra.Size.X.Scale > 0.01
end)
local targetinfohealthblur = addBlur(targetinfohealthbkg)
targetinfohealthblur.SliceCenter = Rect.new(52, 31, 261, 510)
targetinfohealthblur.ImageColor3 = Color3.new()
targetinfohealthblur.Visible = false
local targetinfob = Instance.new('UIStroke')
targetinfob.Enabled = false
targetinfob.Color = Color3.fromHSV(0.44, 1, 1)
targetinfob.Parent = targetinfobkg
targetinfoobj:CreateFont({
	Name = 'Font',
	Blacklist = 'Arial',
	Function = function(val)
		targetinfoname.FontFace = val
	end
})
local targetinfobackgroundtransparency = {
	Value = 0.5,
	Object = {Visible = {}}
}
local targetinfodisplay = targetinfoobj:CreateToggle({
	Name = 'Use Displayname',
	Default = true
})
targetinfoobj:CreateToggle({
	Name = 'Render Background',
	Function = function(callback)
		targetinfobkg.BackgroundTransparency = callback and targetinfobackgroundtransparency.Value or 1
		targetinfoshadow.Visible = not callback
		targetinfoblurobj.Visible = callback
		targetinfohealthblur.Visible = not callback
		targetinfoshotblur.Visible = not callback
		targetinfobackgroundtransparency.Object.Visible = callback
	end,
	Default = true
})
targetinfobackgroundtransparency = targetinfoobj:CreateSlider({
	Name = 'Transparency',
	Min = 0,
	Max = 1,
	Default = 0.5,
	Decimal = 10,
	Function = function(val)
		targetinfobkg.BackgroundTransparency = val
	end,
	Darker = true
})
local targetinfocolor
local targetinfocolortoggle = targetinfoobj:CreateToggle({
	Name = 'Custom Color',
	Function = function(callback)
		targetinfocolor.Object.Visible = callback
		if callback then
			targetinfobkg.BackgroundColor3 = Color3.fromHSV(targetinfocolor.Hue, targetinfocolor.Sat, targetinfocolor.Value)
			targetinfoshot.BackgroundColor3 = Color3.fromHSV(targetinfocolor.Hue, targetinfocolor.Sat, math.max(targetinfocolor.Value - 0.1, 0.075))
			targetinfohealthbkg.BackgroundColor3 = targetinfoshot.BackgroundColor3
		else
			targetinfobkg.BackgroundColor3 = color.Dark(uipallet.Main, 0.1)
			targetinfoshot.BackgroundColor3 = uipallet.Main
			targetinfohealthbkg.BackgroundColor3 = uipallet.Main
		end
	end
})
targetinfocolor = targetinfoobj:CreateColorSlider({
	Name = 'Color',
	Function = function(hue, sat, val)
		if targetinfocolortoggle.Enabled then
			targetinfobkg.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
			targetinfoshot.BackgroundColor3 = Color3.fromHSV(hue, sat, math.max(val - 0.1, 0))
			targetinfohealthbkg.BackgroundColor3 = targetinfoshot.BackgroundColor3
		end
	end,
	Darker = true,
	Visible = false
})
targetinfoobj:CreateToggle({
	Name = 'Border',
	Function = function(callback)
		targetinfob.Enabled = callback
		targetinfobcolor.Object.Visible = callback
	end
})
targetinfobcolor = targetinfoobj:CreateColorSlider({
	Name = 'Border Color',
	Function = function(hue, sat, val, opacity)
		targetinfob.Color = Color3.fromHSV(hue, sat, val)
		targetinfob.Transparency = 1 - opacity
	end,
	Darker = true,
	Visible = false
})
local lasthealth = 0
local lastmaxhealth = 0
targetinfo = {
	Targets = {},
	Object = targetinfobkg,
	UpdateInfo = function(self)
		local entitylib = mainapi.Libraries
		if not entitylib then return end
		for i, v in self.Targets do
			if v < tick() then
				self.Targets[i] = nil
			end
		end
		local v, highest = nil, tick()
		for i, check in self.Targets do
			if check > highest then
				v = i
				highest = check
			end
		end
		targetinfobkg.Visible = v ~= nil or mainapi.gui.ScaledGui.ClickGui.Visible
		if v then
			targetinfoname.Text = v.Player and (targetinfodisplay.Enabled and v.Player.DisplayName or v.Player.Name) or v.Character and v.Character.Name or targetinfoname.Text
			targetinfoshot.Image = 'rbxthumb://type=AvatarHeadShot&id=' .. (v.Player and v.Player.UserId or 1) .. '&w=420&h=420'
			if not v.Character then
				v.Health = v.Health or 0
				v.MaxHealth = v.MaxHealth or 100
			end
			if v.Health ~= lasthealth or v.MaxHealth ~= lastmaxhealth then
				local percent = math.max(v.Health / v.MaxHealth, 0)
				tween:Tween(targetinfohealth, TweenInfo.new(0.3), {
					Size = UDim2.fromScale(math.min(percent, 1), 1), BackgroundColor3 = Color3.fromHSV(math.clamp(percent / 2.5, 0, 1), 0.89, 0.75)
				})
				tween:Tween(targetinfohealthextra, TweenInfo.new(0.3), {
					Size = UDim2.fromScale(math.clamp(percent - 1, 0, 0.8), 1)
				})
				if lasthealth > v.Health and self.LastTarget == v then
					tween:Cancel(targetinfoshotflash)
					targetinfoshotflash.BackgroundTransparency = 0.3
					tween:Tween(targetinfoshotflash, TweenInfo.new(0.5), {BackgroundTransparency = 1})
				end
				lasthealth = v.Health
				lastmaxhealth = v.MaxHealth
			end
			if not v.Character then table.clear(v) end
			self.LastTarget = v
		end
		return v
	end
}
mainapi.Libraries.targetinfo = targetinfo
function mainapi:UpdateTextGUI(afterload)
	if not afterload and not mainapi.Loaded then return end
	if textgui.Button.Enabled then
		local right = textgui.Children.AbsolutePosition.X > (gui.AbsoluteSize.X / 2)
		VoltLogo.Visible = textguiwatermark.Enabled
		VoltLogo.Position = right and UDim2.new(1 / VoltTextScale.Scale, -113, 0, 6) or UDim2.fromOffset(0, 6)
		VoltLogoShadow.Visible = textguishadow.Enabled
		VoltLabelCustom.Text = textguibox.Value
		VoltLabelCustom.FontFace = textguifontcustom.Value
		VoltLabelCustom.Visible = VoltLabelCustom.Text ~= '' and textguitext.Enabled
		VoltLabelCustomShadow.Visible = VoltLabelCustom.Visible and textguishadow.Enabled
		VoltLabelSorter.HorizontalAlignment = right and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Left
		VoltLabelHolder.Size = UDim2.fromScale(1 / VoltTextScale.Scale, 1)
		VoltLabelHolder.Position = UDim2.fromOffset(right and 3 or 0, 11 + (VoltLogo.Visible and VoltLogo.Size.Y.Offset or 0) + (VoltLabelCustom.Visible and 28 or 0) + (textguibackground.Enabled and 3 or 0))
		if VoltLabelCustom.Visible then
			local size = getfontsize(removeTags(VoltLabelCustom.Text), VoltLabelCustom.TextSize, VoltLabelCustom.FontFace)
			VoltLabelCustom.Size = UDim2.fromOffset(size.X, size.Y)
			VoltLabelCustom.Position = UDim2.new(right and 1 / VoltTextScale.Scale or 0, right and -size.X or 0, 0, (VoltLogo.Visible and 32 or 8))
		end
		local found = {}
		for _, v in VoltLabels do
			if v.Enabled then
				table.insert(found, v.Object.Name)
			end
			v.Object:Destroy()
		end
		table.clear(VoltLabels)
		local info = TweenInfo.new(0.3, Enum.EasingStyle.Exponential)
		for i, v in mainapi.Modules do
			if textguimodules.Enabled and table.find(textguimoduleslist.ListEnabled, i) then continue end
			if textguirender.Enabled and v.Category == 'Render' then continue end
			if v.Enabled or table.find(found, i) then
				local holder = Instance.new('Frame')
				holder.Name = i
				holder.Size = UDim2.fromOffset()
				holder.BackgroundTransparency = 1
				holder.ClipsDescendants = true
				holder.Parent = VoltLabelHolder
				local holderbackground
				local holdercolorline
				if textguibackground.Enabled then
					holderbackground = Instance.new('Frame')
					holderbackground.Size = UDim2.new(1, 3, 1, 0)
					holderbackground.BackgroundColor3 = color.Dark(uipallet.Main, 0.15)
					holderbackground.BackgroundTransparency = textguibackgroundtransparency.Value
					holderbackground.BorderSizePixel = 0
					holderbackground.Parent = holder
					local holderline = Instance.new('Frame')
					holderline.Size = UDim2.new(1, 0, 0, 1)
					holderline.Position = UDim2.new(0, 0, 1, -1)
					holderline.BackgroundColor3 = Color3.new()
					holderline.BackgroundTransparency = 0.928 + (0.072 * math.clamp((textguibackgroundtransparency.Value - 0.5) / 0.5, 0, 1))
					holderline.BorderSizePixel = 0
					holderline.Parent = holderbackground
					local holderline2 = holderline:Clone()
					holderline2.Name = 'Line'
					holderline2.Position = UDim2.new()
					holderline2.Parent = holderbackground
					holdercolorline = Instance.new('Frame')
					holdercolorline.Size = UDim2.new(0, 2, 1, 0)
					holdercolorline.Position = right and UDim2.new(1, -5, 0, 0) or UDim2.new()
					holdercolorline.BorderSizePixel = 0
					holdercolorline.Parent = holderbackground
				end
				local holdertext = Instance.new('TextLabel')
				holdertext.Position = UDim2.fromOffset(right and 3 or 6, 2)
				holdertext.BackgroundTransparency = 1
				holdertext.BorderSizePixel = 0
				holdertext.Text = i .. (v.ExtraText and " <font color='#A8A8A8'>" .. v.ExtraText() .. '</font>' or '')
				holdertext.TextSize = 15
				holdertext.FontFace = textguifont.Value
				holdertext.RichText = true
				local size = getfontsize(removeTags(holdertext.Text), holdertext.TextSize, holdertext.FontFace)
				holdertext.Size = UDim2.fromOffset(size.X, size.Y)
				if textguishadow.Enabled then
					local holderdrop = holdertext:Clone()
					holderdrop.Position = UDim2.fromOffset(holdertext.Position.X.Offset + 1, holdertext.Position.Y.Offset + 1)
					holderdrop.Text = removeTags(holdertext.Text)
					holderdrop.TextColor3 = Color3.new()
					holderdrop.Parent = holder
				end
				holdertext.Parent = holder
				local holdersize = UDim2.fromOffset(size.X + 10, size.Y + (textguibackground.Enabled and 5 or 3))
				if textguianimations.Enabled then
					if not table.find(found, i) then
						tween:Tween(holder, info, {Size = holdersize})
					else
						holder.Size = holdersize
						if not v.Enabled then
							tween:Tween(holder, info, {Size = UDim2.fromOffset()})
						end
					end
				else
					holder.Size = v.Enabled and holdersize or UDim2.fromOffset()
				end
				table.insert(VoltLabels, {
					Object = holder,
					Text = holdertext,
					Background = holderbackground,
					Color = holdercolorline,
					Enabled = v.Enabled
				})
			end
		end
		if textguisort.Value == 'Alphabetical' then
			table.sort(VoltLabels, function(a, b)
				return a.Text.Text < b.Text.Text
			end)
		else
			table.sort(VoltLabels, function(a, b)
				return a.Text.Size.X.Offset > b.Text.Size.X.Offset
			end)
		end
		for i, v in VoltLabels do
			if v.Color then
				v.Color.Parent.Line.Visible = i ~= 1
			end
			v.Object.LayoutOrder = i
		end
	end
	mainapi:UpdateGUI(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value, true)
end
function mainapi:UpdateGUI(hue, sat, val, default)
	if mainapi.Loaded == nil then return end
	if not default and mainapi.GUIColor.Rainbow then return end
	if textgui.Button.Enabled then
		VoltLogoGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(hue, sat, val)),
			ColorSequenceKeypoint.new(1, textguigradient.Enabled and Color3.fromHSV(mainapi:Color((hue - 0.075) % 1)) or Color3.fromHSV(hue, sat, val))
		})
		VoltLogoGradient2.Color = textguigradient.Enabled and textguigradientv4.Enabled and VoltLogoGradient.Color or ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
		})
		VoltLabelCustom.TextColor3 = textguicolorcustomtoggle.Enabled and Color3.fromHSV(textguicolorcustom.Hue, textguicolorcustom.Sat, textguicolorcustom.Value) or VoltLogoGradient.Color.Keypoints[2].Value
		local customcolor = textguicolordrop.Value == 'Custom color' and Color3.fromHSV(textguicolor.Hue, textguicolor.Sat, textguicolor.Value) or nil
		for i, v in VoltLabels do
			v.Text.TextColor3 = customcolor or (mainapi.GUIColor.Rainbow and Color3.fromHSV(mainapi:Color((hue - ((textguigradient and i + 2 or i) * 0.025)) % 1)) or VoltLogoGradient.Color.Keypoints[2].Value)
			if v.Color then
				v.Color.BackgroundColor3 = v.Text.TextColor3
			end
			if textguibackgroundtint.Enabled and v.Background then
				v.Background.BackgroundColor3 = color.Dark(v.Text.TextColor3, 0.75)
			end
		end
	end
	if not clickgui.Visible and not mainapi.Legit.Window.Visible then return end
	local rainbow = mainapi.GUIColor.Rainbow and mainapi.RainbowMode.Value ~= 'Retro'
	for i, v in mainapi.Categories do
		if i == 'Main' then
			v.Object.VoltLogo.V5Logo.ImageColor3 = Color3.fromHSV(hue, sat, val)
			for _, button in v.Buttons do
				if button.Enabled then
					button.Object.TextColor3 = rainbow and Color3.fromHSV(mainapi:Color((hue - (button.Index * 0.025)) % 1)) or Color3.fromHSV(hue, sat, val)
					if button.Icon then
						button.Icon.ImageColor3 = button.Object.TextColor3
					end
				end
			end
		end
		if v.Options then
			for _, option in v.Options do
				if option.Color then
					option:Color(hue, sat, val, rainbow)
				end
			end
		end
		if v.Type == 'CategoryList' then
			v.Object.Children.Add.AddButton.ImageColor3 = rainbow and Color3.fromHSV(mainapi:Color(hue % 1)) or Color3.fromHSV(hue, sat, val)
			if v.Selected then
				v.Selected.BackgroundColor3 = rainbow and Color3.fromHSV(mainapi:Color(hue % 1)) or Color3.fromHSV(hue, sat, val)
				v.Selected.Title.TextColor3 = mainapi.GUIColor.Rainbow and Color3.new(0.12, 0.12, 0.14) or mainapi:TextColor(hue, sat, val)
				v.Selected.Dots.Dots.ImageColor3 = v.Selected.Title.TextColor3
				v.Selected.Bind.Icon.ImageColor3 = v.Selected.Title.TextColor3
				v.Selected.Bind.TextLabel.TextColor3 = v.Selected.Title.TextColor3
			end
		end
	end
	for _, button in mainapi.Modules do
		if button.Enabled then
			button.Object.BackgroundColor3 = rainbow and Color3.fromHSV(mainapi:Color((hue - (button.Index * 0.025)) % 1)) or Color3.fromHSV(hue, sat, val)
			button.Object.TextColor3 = mainapi.GUIColor.Rainbow and Color3.new(0.12, 0.12, 0.14) or mainapi:TextColor(hue, sat, val)
			button.Object.UIGradient.Enabled = rainbow and mainapi.RainbowMode.Value == 'Gradient'
			if button.Object.UIGradient.Enabled then
				button.Object.BackgroundColor3 = Color3.new(1, 1, 1)
				button.Object.UIGradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(mainapi:Color((hue - (button.Index * 0.025)) % 1))),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(mainapi:Color((hue - ((button.Index + 1) * 0.025)) % 1)))
				})
			end
			button.Object.Bind.Icon.ImageColor3 = button.Object.TextColor3
			button.Object.Bind.TextLabel.TextColor3 = button.Object.TextColor3
			button.Object.Dots.Dots.ImageColor3 = button.Object.TextColor3
		end
		for _, option in button.Options do
			if option.Color then
				option:Color(hue, sat, val, rainbow)
			end
		end
	end
	for i, v in mainapi.Overlays.Toggles do
		if v.Enabled then
			tween:Cancel(v.Object.Knob)
			v.Object.Knob.BackgroundColor3 = rainbow and Color3.fromHSV(mainapi:Color((hue - (i * 0.075)) % 1)) or Color3.fromHSV(hue, sat, val)
		end
	end
	if mainapi.Legit.Icon then
		mainapi.Legit.Icon.ImageColor3 = Color3.fromHSV(hue, sat, val)
	end
	if mainapi.Legit.Window.Visible then
		for _, v in mainapi.Legit.Modules do
			if v.Enabled then
				tween:Cancel(v.Object.Knob)
				v.Object.Knob.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
			end
			for _, option in v.Options do
				if option.Color then
					option:Color(hue, sat, val, rainbow)
				end
			end
		end
	end
end
mainapi:Clean(notifications.ChildRemoved:Connect(function()
	for i, v in notifications:GetChildren() do
		if tween.Tween then
			tween:Tween(v, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
				Position = UDim2.new(1, 0, 1, -(29 + (78 * i)))
			})
		end
	end
end))
mainapi:Clean(inputService.InputBegan:Connect(function(inputObj)
	if not inputService:GetFocusedTextBox() and inputObj.KeyCode ~= Enum.KeyCode.Unknown then
		table.insert(mainapi.HeldKeybinds, inputObj.KeyCode.Name)
		if mainapi.Binding then return end
		if checkKeybinds(mainapi.HeldKeybinds, mainapi.Keybind, inputObj.KeyCode.Name) then
			if mainapi.ThreadFix then
				setthreadidentity(8)
			end
			for _, v in mainapi.Windows do
				v.Visible = false
			end
			clickgui.Visible = not clickgui.Visible
			tooltip.Visible = false
			mainapi:BlurCheck()
		end
		local toggled = false
		for i, v in mainapi.Modules do
			if checkKeybinds(mainapi.HeldKeybinds, v.Bind, inputObj.KeyCode.Name) then
				toggled = true
				if mainapi.ToggleNotifications.Enabled then
					mainapi:CreateNotification('Module Toggled', i .. "<font color='#FFFFFF'> has been </font>" .. (not v.Enabled and "<font color='#5AFF5A'>Enabled</font>" or "<font color='#FF5A5A'>Disabled</font>") .. "<font color='#FFFFFF'>!</font>", 0.75)
				end
				v:Toggle(true)
			end
		end
		if toggled then
			mainapi:UpdateTextGUI()
		end
		for _, v in mainapi.Profiles do
			if checkKeybinds(mainapi.HeldKeybinds, v.Bind, inputObj.KeyCode.Name) and v.Name ~= mainapi.Profile then
				mainapi:Save(v.Name)
				mainapi:Load(true)
				break
			end
		end
	end
end))
mainapi:Clean(inputService.InputEnded:Connect(function(inputObj)
	if not inputService:GetFocusedTextBox() and inputObj.KeyCode ~= Enum.KeyCode.Unknown then
		if mainapi.Binding then
			if not mainapi.MultiKeybind.Enabled then
				mainapi.HeldKeybinds = {inputObj.KeyCode.Name}
			end
			mainapi.Binding:SetBind(checkKeybinds(mainapi.HeldKeybinds, mainapi.Binding.Bind, inputObj.KeyCode.Name) and {} or mainapi.HeldKeybinds, true)
			mainapi.Binding = nil
		end
	end
	local ind = table.find(mainapi.HeldKeybinds, inputObj.KeyCode.Name)
	if ind then
		table.remove(mainapi.HeldKeybinds, ind)
	end
end))
return mainapi