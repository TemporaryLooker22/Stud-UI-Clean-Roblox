--!nonstrict
--[[
	GlossyMotion - motion, sound and responsive behaviour of the Glossy Block UI (client ModuleScript)
	===================================================================================================
	Every timing below is the exact value used by the reference game. Do not "improve" them: the snappy
	0.05s press + Back-Out release IS the feel of the style.

		local Motion = require(path.GlossyMotion)
		Motion.BindResponsive(win.WindowScale)             -- 1050x620 reference, clamp 0.52..1.18
		Motion.BindButton(button, 1.05, gui.Sons)          -- hover 1.05 / press 0.92 / Back release
		local menu = Motion.Window(gui, win.Fenetre)       -- open/close with bounce, blur, FOV, hide other GUIs
		menu.Open()
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")

local M = {}

M.HOVER = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
M.PRESS = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
M.RELEASE = TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
M.REFERENCE = Vector2.new(1050, 620)
M.MIN_SCALE, M.MAX_SCALE = 0.52, 1.18
M.BLUR, M.FOV_PLUS = 18, 8

-- Default sound set (ids from the reference game). Use M.CreateSounds(gui.Sons) to populate a "Sons" folder.
M.SOUNDS = {
	Survol = { "rbxassetid://6895079853", 0.5, 1 }, -- hover tick
	Clic = { "rbxassetid://103866342467024", 0.5, 1 }, -- press
	Ouverture = { "rbxassetid://109359226723492", 0.6, 1 }, -- window open (pop)
	Fermeture = { "rbxassetid://117813075686953", 0.45, 0.82 }, -- window close (pitched down)
	Achat = { "rbxassetid://1319346243", 0.55, 1 }, -- purchase success / reward banner
	Carte = { "rbxassetid://109359226723492", 0.18, 1.6 }, -- card pop (quiet, high pitch)
	Refus = { "rbxasset://sounds/clickfast.wav", 0.4, 1 }, -- refusal
}

function M.CreateSounds(folder: Instance)
	for name, s in M.SOUNDS do
		if not folder:FindFirstChild(name) then
			local snd = Instance.new("Sound")
			snd.Name = name; snd.SoundId = s[1]; snd.Volume = s[2]; snd.PlaybackSpeed = s[3]
			snd.Parent = folder
		end
	end
	return folder
end

local function play(sounds, name, speed)
	if not sounds then return end
	local s = sounds:FindFirstChild(name)
	if not s then return end
	if speed then s.PlaybackSpeed = speed end
	s:Play()
end
M.Play = play

--- Screen factor: min(vx/1050, vy/620) clamped to [0.52, 1.18].
function M.ScreenScale(): number
	local v = workspace.CurrentCamera.ViewportSize
	if v.X <= 0 or v.Y <= 0 then return 1 end
	return math.clamp(math.min(v.X / M.REFERENCE.X, v.Y / M.REFERENCE.Y), M.MIN_SCALE, M.MAX_SCALE)
end

--- Keeps a UIScale ("WindowScale") at size * ScreenScale() (* optional animated factor NumberValue).
function M.BindResponsive(uiScale: UIScale, size: number?, anim: NumberValue?)
	local camera = workspace.CurrentCamera
	local function update()
		uiScale.Scale = (size or 1) * M.ScreenScale() * (anim and anim.Value or 1)
	end
	camera:GetPropertyChangedSignal("ViewportSize"):Connect(update)
	if anim then anim.Changed:Connect(update) end
	update()
	return update
end

--- Hover / press / release on a button's "ButtonScale" (created if missing). hover: 1.04 HUD, 1.05 menus, 1.06 close/slots.
function M.BindButton(button: GuiButton, hover: number?, sounds: Instance?, onActivated: (() -> ())?)
	local sc = button:FindFirstChild("ButtonScale") or Instance.new("UIScale")
	sc.Name = "ButtonScale"; sc.Parent = button
	hover = hover or 1.05
	local over = false
	button.MouseEnter:Connect(function() over = true; play(sounds, "Survol"); TweenService:Create(sc, M.HOVER, { Scale = hover }):Play() end)
	button.MouseLeave:Connect(function() over = false; TweenService:Create(sc, M.HOVER, { Scale = 1 }):Play() end)
	button.MouseButton1Down:Connect(function() play(sounds, "Clic", 1); TweenService:Create(sc, M.PRESS, { Scale = 0.92 }):Play() end)
	button.MouseButton1Up:Connect(function() TweenService:Create(sc, M.RELEASE, { Scale = if over then hover else 1 }):Play() end)
	if onActivated then button.Activated:Connect(onActivated) end
	return sc
end

--- Refusal: horizontal shake -5,+5,-3,+3,0 px every 0.04s.
function M.Shake(obj: GuiObject)
	local p = obj.Position
	for i, dx in { -5, 5, -3, 3, 0 } do
		task.delay(i * 0.04, function() obj.Position = p + UDim2.fromOffset(dx, 0) end)
	end
end

--- Floating feedback text ("Bought!", "Not enough money") that rises ~28px and fades in 0.9s.
function M.Float(obj: GuiObject, text: string, color: Color3?)
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.AnchorPoint = Vector2.new(0.5, 1)
	t.Size = UDim2.fromOffset(260, 30)
	t.Position = UDim2.new(0.5, 0, 0, -2)
	t.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy)
	t.TextSize = 22
	t.Text = text
	t.TextColor3 = color or Color3.fromRGB(255, 110, 110)
	t.ZIndex = 60
	local st = Instance.new("UIStroke"); st.Color = Color3.fromRGB(17, 23, 26); st.Thickness = 2.6; st.Parent = t
	t.Parent = obj
	local info = TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(t, info, { Position = UDim2.new(0.5, 0, 0, -30), TextTransparency = 1 }):Play()
	TweenService:Create(st, info, { Transparency = 1 }):Play()
	task.delay(0.95, function() t:Destroy() end)
end

--- Pop-in of a slot / card that just appeared (UIScale 0 -> 1, Back Out 0.35).
function M.PopIn(obj: GuiObject, duration: number?)
	local sc = obj:FindFirstChild("ButtonScale") or obj:FindFirstChildOfClass("UIScale")
	if not sc then return end
	sc.Scale = 0.4
	TweenService:Create(sc, TweenInfo.new(duration or 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
end

--[[ Continuous idle effects, one RenderStepped loop. Register objects once:
	M.Spin(sunburst, 20, alternate)  -- degrees/second; neighbours alternate direction (i % 2)
	M.Sway(image, 3, 1.6)            -- rotation = base + 3*sin(t*1.6) (header basket)
	M.PulseScale(uiScale, 0.08, 4)   -- scale = 1 + 0.08*max(0, sin(t*4)) (notification "!")
	M.PulseStroke(stroke, 2.2, 1.2, 6) -- thickness = 2.2 + 1.2*sin(t*6) (claimable slot selection) ]]
local spins, sways, pulses, strokes = {}, {}, {}, {}
local loop
local function ensureLoop()
	if loop then return end
	loop = RunService.RenderStepped:Connect(function(dt)
		local t = os.clock()
		for obj, speed in spins do
			if obj.Parent then obj.Rotation = (obj.Rotation + speed * dt) % 360 else spins[obj] = nil end
		end
		for obj, s in sways do
			if obj.Parent then obj.Rotation = s.base + s.amp * math.sin(t * s.freq) else sways[obj] = nil end
		end
		for sc, s in pulses do
			if sc.Parent then sc.Scale = 1 + s.amp * math.max(0, math.sin(t * s.freq)) else pulses[sc] = nil end
		end
		for st, s in strokes do
			if st.Parent then st.Thickness = s.base + s.amp * math.sin(t * s.freq) else strokes[st] = nil end
		end
	end)
end
function M.Spin(img: GuiObject, speed: number?, reverse: boolean?) spins[img] = (speed or 20) * (if reverse then -1 else 1); ensureLoop() end
function M.SpinSunbursts(root: Instance, speed: number?)
	local i = 0
	for _, d in root:GetDescendants() do
		if d:IsA("ImageLabel") and d.Name == "Soleil" then i += 1; M.Spin(d, speed or 20, i % 2 == 0) end
	end
end
function M.Sway(img: GuiObject, amp: number?, freq: number?) sways[img] = { base = img.Rotation, amp = amp or 3, freq = freq or 1.6 }; ensureLoop() end
function M.PulseScale(sc: UIScale, amp: number?, freq: number?) pulses[sc] = { amp = amp or 0.08, freq = freq or 4 }; ensureLoop() end
function M.PulseStroke(st: UIStroke, base: number?, amp: number?, freq: number?) strokes[st] = { base = base or 2.2, amp = amp or 1.2, freq = freq or 6 }; ensureLoop() end
function M.StopIdle(obj) spins[obj] = nil; sways[obj] = nil; pulses[obj] = nil; strokes[obj] = nil end

--[[ Tabs: active tab is full color and slides 6px toward the window; inactive tabs are tinted #9696A6 through
	Face.GroupColor3 / Biseau.BackgroundColor3 / Icone.ImageColor3, label #D6D6E0. 0.15s Quad Out. ]]
function M.SelectTab(tabs: { GuiButton }, active: GuiButton, slide: number?, basePositions)
	local INFO = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local OFF, TEXT_OFF = Color3.fromRGB(150, 150, 166), Color3.fromRGB(214, 214, 224)
	for i, b in tabs do
		local on = b == active
		local base = basePositions and basePositions[i] or b.Position
		local goals = {
			{ b, { Position = base + UDim2.fromOffset(if on then -(slide or 6) else 0, 0) } },
			{ b:FindFirstChild("Face"), { GroupColor3 = if on then Color3.new(1, 1, 1) else OFF } },
			{ b:FindFirstChild("Biseau"), { BackgroundColor3 = if on then Color3.new(1, 1, 1) else OFF } },
			{ b:FindFirstChild("Icone"), { ImageColor3 = if on then Color3.new(1, 1, 1) else OFF } },
			{ b:FindFirstChild("Texte"), { TextColor3 = if on then Color3.new(1, 1, 1) else TEXT_OFF } },
		}
		for _, g in goals do if g[1] then TweenService:Create(g[1], INFO, g[2]):Play() end end
	end
end

--[[ Window controller (same behaviour for every menu):
	Open : Fenetre visible, WindowScale factor 0.86 -> 1 (Back Out 0.32) + slides up 24px (Quint Out 0.32),
	       Lighting.Flou_Menu blur 0 -> 18 (0.3), camera FOV +8 (0.45), every other ScreenGui and the CoreGui hidden,
	       sound "Ouverture".
	Close: factor -> 0.88 and down 18px (Quad In 0.16), blur -> 0 (0.28), FOV back (0.4), hide after 0.16s, restore GUIs,
	       sound "Fermeture" at 0.82 pitch. X button, Escape and gamepad B close. Only one menu open at a time.
	opts: Keep = { ScreenGui names never hidden }, Group = shared table to enforce one-menu-at-a-time ]]
local openMenu = nil
function M.Window(gui: ScreenGui, fenetre: Frame, opts)
	opts = opts or {}
	local player = Players.LocalPlayer
	local camera = workspace.CurrentCamera
	local scale = fenetre:FindFirstChild("WindowScale") or Instance.new("UIScale", fenetre)
	scale.Name = "WindowScale"
	local sounds = gui:FindFirstChild("Sons")
	local blur = Lighting:FindFirstChild("Flou_Menu")
	if not blur then
		blur = Instance.new("BlurEffect"); blur.Name = "Flou_Menu"; blur.Size = 0; blur.Parent = Lighting
	end
	local keep = opts.Keep or { TransitionUsine = true, Recompenses = true }
	local anim = Instance.new("NumberValue"); anim.Value = 1
	M.BindResponsive(scale, opts.Size or 1, anim)

	local menu = { Gui = gui, Fenetre = fenetre, IsOpen = false }
	local HOME = fenetre.Position
	local running, token, fov0 = {}, 0, nil
	local hidden, coreHidden = {}, {}
	local CORE = { Enum.CoreGuiType.PlayerList, Enum.CoreGuiType.Chat, Enum.CoreGuiType.Backpack, Enum.CoreGuiType.EmotesMenu, Enum.CoreGuiType.Health }

	local function tween(o, info, goal) local t = TweenService:Create(o, info, goal); table.insert(running, t); t:Play() end
	local function stop() for _, t in running do t:Cancel() end; table.clear(running) end
	local function hideOthers()
		for _, g in player:WaitForChild("PlayerGui"):GetChildren() do
			if g:IsA("ScreenGui") and g ~= gui and not keep[g.Name] and g.Enabled then g.Enabled = false; table.insert(hidden, g) end
		end
		for _, c in CORE do
			local ok, v = pcall(StarterGui.GetCoreGuiEnabled, StarterGui, c)
			if ok and v then coreHidden[c] = true; pcall(StarterGui.SetCoreGuiEnabled, StarterGui, c, false) end
		end
	end
	local function restore()
		for _, g in hidden do if g.Parent then g.Enabled = true end end
		for c in coreHidden do pcall(StarterGui.SetCoreGuiEnabled, StarterGui, c, true) end
		table.clear(hidden); table.clear(coreHidden)
	end

	function menu.Open()
		if menu.IsOpen then return end
		if openMenu and openMenu ~= menu then openMenu.Close() end
		menu.IsOpen = true; token += 1; stop()
		play(sounds, "Ouverture", 1)
		hideOthers()
		gui.Enabled = true
		fov0 = fov0 or camera.FieldOfView
		fenetre.Visible = true
		anim.Value = 0.86
		fenetre.Position = HOME + UDim2.fromOffset(0, 24)
		tween(anim, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Value = 1 })
		tween(fenetre, TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = HOME })
		tween(blur, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = M.BLUR })
		tween(camera, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { FieldOfView = fov0 + M.FOV_PLUS })
		openMenu = menu
		if opts.OnOpen then task.spawn(opts.OnOpen) end
	end

	function menu.Close()
		if not menu.IsOpen then return end
		menu.IsOpen = false; token += 1; stop()
		play(sounds, "Fermeture", 0.82)
		local j = token
		tween(anim, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Value = 0.88 })
		tween(fenetre, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = HOME + UDim2.fromOffset(0, 18) })
		tween(blur, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = 0 })
		tween(camera, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { FieldOfView = fov0 or 70 })
		if openMenu == menu then openMenu = nil end
		task.delay(0.16, function()
			if token ~= j then return end
			fenetre.Visible = false
			fenetre.Position = HOME
			if not openMenu then restore() end
		end)
		task.delay(0.42, function() if token == j then fov0 = nil end end)
	end

	function menu.Toggle(state: boolean?)
		if state == nil then state = not menu.IsOpen end
		if state then menu.Open() else menu.Close() end
	end

	fenetre.Visible = false
	local toggle = gui:FindFirstChild("Basculer")
	if toggle then toggle.Event:Connect(menu.Toggle) end
	local close = fenetre:FindFirstChild("Fermer", true)
	if close and close:IsA("GuiButton") then M.BindButton(close, 1.06, sounds, menu.Close) end
	UserInputService.InputBegan:Connect(function(input)
		if menu.IsOpen and (input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB) then menu.Close() end
	end)
	player.CharacterAdded:Connect(function() if menu.IsOpen then menu.Close() end end)
	return menu
end

--[[ Reward banner: drops from 40px above with UIScale 0.6 -> 0.85 * screen (Back Out 0.35 + Quint Out 0.35),
	stays `duration` seconds (3.2), shrinks to 0.5 (Quad In 0.2) and hides. Sunburst spins at 30 deg/s. ]]
function M.ShowBanner(banner: GuiObject, duration: number?, sounds: Instance?)
	local sc = banner:FindFirstChild("WindowScale")
	local home = banner:GetAttribute("HomePosition") or banner.Position
	banner:SetAttribute("HomePosition", home)
	play(sounds, "Achat")
	sc.Scale = M.ScreenScale() * 0.6
	banner.Position = home - UDim2.fromOffset(0, 40)
	banner.Visible = true
	local sun = banner:FindFirstChild("Soleil")
	if sun then M.Spin(sun, 30) end
	TweenService:Create(sc, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = M.ScreenScale() * 0.85 }):Play()
	TweenService:Create(banner, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = home }):Play()
	task.wait(duration or 3.2)
	local t = TweenService:Create(sc, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = M.ScreenScale() * 0.5 })
	t:Play(); t.Completed:Wait()
	banner.Visible = false
end

--- "$1.2K" style abbreviation used on every price.
function M.Abbreviate(n: number, prefix: string?): string
	prefix = prefix or "$"
	for _, u in { { 1e12, "T" }, { 1e9, "B" }, { 1e6, "M" }, { 1e3, "K" } } do
		if n >= u[1] then
			local v = n / u[1]
			local s = if v >= 100 or v == math.floor(v) then ("%d"):format(math.floor(v)) else (("%.1f"):format(v):gsub("%.0$", ""))
			return prefix .. s .. u[2]
		end
	end
	return prefix .. math.floor(n)
end

--- "1:02:03" or "12:34"
function M.Duration(s: number): string
	s = math.max(0, math.floor(s))
	local h, m, sec = s // 3600, (s % 3600) // 60, s % 60
	if h > 0 then return ("%d:%02d:%02d"):format(h, m, sec) end
	return ("%02d:%02d"):format(m, sec)
end

return M
