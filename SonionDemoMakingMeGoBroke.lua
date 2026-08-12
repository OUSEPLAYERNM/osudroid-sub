--=================================================================
-- VOLT V4 DEMO — runs against your patched library on GitHub
-- UI-only. No gameplay. Paste locally and execute.
--=================================================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/OUSEPLAYERNM/addada/main/Patched.lua"))()
if not Library.Loaded then Library:Initialize() end

local function notify(title, text, dur, type)
	Library:CreateNotification(title, text, dur, type)
end

--=================================================================
-- 1. SEARCH BAR (top center)
--=================================================================
Library:CreateSearch()

--=================================================================
-- 2. CATEGORIES
--=================================================================
local Combat = Library:CreateCategory({
	Name = "Combat",
	Icon = "rbxassetid://14368312652",
	Size = UDim2.fromOffset(13, 14),
})
local Render = Library:CreateCategory({
	Name = "Render",
	Icon = "rbxassetid://14368350193",
	Size = UDim2.fromOffset(15, 14),
})
local Utility = Library:CreateCategory({
	Name = "Utility",
	Icon = "rbxassetid://14368359107",
	Size = UDim2.fromOffset(15, 14),
})

--=================================================================
-- 3. COMBAT — every component type in one module
--=================================================================
local KillAura = Combat:CreateModule({
	Name = "KillAura",
	Tooltip = "Demo module with every component type",
})

KillAura:CreateToggle({
	Name = "Enabled",
	Default = true,
	Function = function(v) notify("KillAura", "Toggled: " .. tostring(v), 3, "info") end,
})
KillAura:CreateSlider({ Name = "Attack Range", Min = 1, Max = 30, Default = 12, Decimal = 1, Suffix = " studs" })
KillAura:CreateTwoSlider({ Name = "CPS Limit", Min = 1, Max = 20, DefaultMin = 8, DefaultMax = 14 })
KillAura:CreateDropdown({
	Name = "Priority",
	List = { "Distance", "Health", "Angle", "FOV" },
	Function = function(v) notify("KillAura", "Priority: " .. tostring(v), 2, "allowed") end,
})
KillAura:CreateTextList({ Name = "Whitelist", Placeholder = "Add username...", Color = Color3.fromRGB(5, 134, 105) })
KillAura:CreateColorSlider({ Name = "Tracer Color", DefaultHue = 0.33 })
KillAura:CreateFont({ Name = "Name Font", Blacklist = "Arial" })
KillAura:CreateTextBox({ Name = "Custom Suffix", Placeholder = "e.g. [BOT]" })
KillAura:CreateButton({ Name = "Reset Config", Function = function() notify("KillAura", "Config reset!", 3, "warning") end })
KillAura:CreateDivider("Advanced")
KillAura:CreateToggle({ Name = "Invisible Check", Darker = true })
KillAura:CreateToggle({ Name = "Teams Check", Darker = true, Default = true })
KillAura:CreateToggle({ Name = "Wall Check", Darker = true })

-- Filler modules to force the ScrollingFrame to scroll
for i = 1, 8 do
	local m = Combat:CreateModule({ Name = "Combat Mod " .. i })
	m:CreateToggle({ Name = "Feature " .. i })
	m:CreateSlider({ Name = "Power " .. i, Min = 0, Max = 100, Default = 50 })
end

--=================================================================
-- 4. RENDER
--=================================================================
local ESP = Render:CreateModule({ Name = "ESP", Tooltip = "Render demo" })
ESP:CreateToggle({ Name = "Enabled", Default = true })
ESP:CreateDropdown({ Name = "Mode", List = { "2D Box", "Outline", "Skeleton" } })
ESP:CreateColorSlider({ Name = "Visible Color", DefaultHue = 0.33 })
ESP:CreateColorSlider({ Name = "Hidden Color", DefaultHue = 0.0 })
ESP:CreateToggle({ Name = "Health Bar", Darker = true, Default = true })
ESP:CreateToggle({ Name = "Names", Darker = true, Default = true })

local Tracers = Render:CreateModule({ Name = "Tracers" })
Tracers:CreateToggle({ Name = "Enabled" })
Tracers:CreateDropdown({ Name = "Origin", List = { "Bottom", "Center", "Top" } })
Tracers:CreateSlider({ Name = "Transparency", Min = 0, Max = 1, Default = 0.5, Decimal = 10 })

--=================================================================
-- 5. UTILITY
--=================================================================
local Fly = Utility:CreateModule({ Name = "Fly" })
Fly:CreateToggle({ Name = "Enabled" })
Fly:CreateSlider({ Name = "Speed", Min = 10, Max = 200, Default = 50, Suffix = " mph" })
Fly:CreateTwoSlider({ Name = "Height Clamp", Min = 0, Max = 100, DefaultMin = 10, DefaultMax = 60 })

local Speed = Utility:CreateModule({ Name = "Speed" })
Speed:CreateToggle({ Name = "Enabled" })
Speed:CreateSlider({ Name = "Multiplier", Min = 1, Max = 10, Default = 1, Decimal = 10, Suffix = "x" })

--=================================================================
-- 6. OVERLAY (Text GUI style) — auto-creates the overlay bar
--=================================================================
local TextGUI = Library:CreateOverlay({
	Name = "Text GUI",
	Icon = "rbxassetid://14368355456",
	Size = UDim2.fromOffset(16, 12),
	Position = UDim2.fromOffset(12, 14),
	Function = function(on) notify("Text GUI", "Overlay: " .. tostring(on), 2, "info") end,
})
TextGUI:CreateDropdown({ Name = "Sort", List = { "Alphabetical", "Length" } })
TextGUI:CreateToggle({ Name = "Watermark", Default = true })
TextGUI:CreateToggle({ Name = "Background" })
TextGUI:CreateColorSlider({ Name = "Text Color", DefaultHue = 0.46 })

--=================================================================
-- 7. CATEGORY LIST (Friends style)
--=================================================================
local Friends = Library:CreateCategoryList({
	Name = "Friends",
	Icon = "rbxassetid://14397462778",
	Size = UDim2.fromOffset(17, 16),
	Placeholder = "Roblox username",
	Color = Color3.fromRGB(5, 134, 105),
})
Friends:CreateToggle({ Name = "Use Friends", Default = true })
Friends:CreateColorSlider({ Name = "Friends Color", DefaultHue = 0.33, Darker = true })

--=================================================================
-- 8. SETTINGS PANES (independent sizing stress test)
--=================================================================
local Main = Library.Categories.Main
if Main.CreateSettingsDivider then Main:CreateSettingsDivider() end

local guipane = Main:CreateSettingsPane({ Name = "GUI" })
guipane:CreateToggle({ Name = "Show tooltips", Default = true, Function = function(on) print("tooltips:", on) end })
guipane:CreateToggle({ Name = "Blur background", Default = true, Function = function(on) print("blur:", on) end })
guipane:CreateButton({
	Name = "Print Save State",
	Function = function()
		print(game:GetService("HttpService"):JSONEncode(Library:SaveState()))
	end,
})

-- 15 controls in one pane to prove settings never overlap/clip
local stress = Main:CreateSettingsPane({ Name = "Stress Test" })
for i = 1, 12 do
	stress:CreateToggle({ Name = "Setting " .. i, Darker = (i % 2 == 0) })
end
stress:CreateSlider({ Name = "Padding", Min = 0, Max = 10, Default = 2 })
stress:CreateDropdown({ Name = "Mode", List = { "A", "B", "C", "D", "E" } })

-- Theme slider + rebind row (like the original V4 GUI settings)
Library.GUIColor = Main:CreateGUISlider({
	Name = "GUI Theme",
	Function = function(h, s, v)
		Library:UpdateGUI(h, s, v, true)
	end,
})
Main:CreateBind()

--=================================================================
-- 9. VISUAL POPULATION — open everything so you can verify
--=================================================================
Library:SetVisible(true)          -- open the click GUI
Combat.Button:Toggle()            -- open Combat category window
Combat:Expand()                   -- expand it (scrolling test)
KillAura.Children.Visible = true  -- show all KillAura options

-- Notification stack test
notify("Volt V4", "Library loaded successfully!", 5, "allowed")
notify("Volt V4", "RightShift (PC) or the logo button (mobile) toggles the GUI.", 6, "info")
notify("Demo", "Combat populated with 11 modules — scroll to verify.", 5, "info")

print("Volt V4 demo ready — GUI is open.")