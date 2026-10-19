--!nonstrict
--[[
	StudUI - Stud UI Clean Roblox kit for Roblox (ModuleScript)
	=========================================================
	Rebuilds, from scratch and without templates, every component of the "Stud UI" simulator style:
	chunky 3D stud buttons, glossy purchase buttons, stud-header windows, dark glass bodies, product cards,
	item slots with spinning sunbursts, stud panels, inset boxes, progress bars, pills, badges.

	All measurements are in OFFSET pixels for a 1050 x 620 reference screen. Scale whole roots with a
	UIScale named "WindowScale" driven by StudMotion.BindResponsive (never use Scale sizes for chrome).

	Instance names are kept identical to the reference game (French): Fenetre, Entete, Corps, Biseau, Face,
	Fond, Reflets, LueurBas, LiseréInterne1/2, Ombre, Texte, Icone, ... so runtime scripts written for the
	reference game (recolor, tabs, disabled state) keep working on generated UI.

	Quick start:
		local UI = require(path.StudUI)
		local gui = UI.ScreenGui("MenuShop", 11)
		local win = UI.Window(gui, { Size = Vector2.new(662, 448), Title = "Nest Shop", Header = "pink",
			Icon = UI.Assets.Basket })
		UI.Button(win.Entete, { Text = "Restock", Style = "Chunky", Theme = "orange", Size = Vector2.new(146, 56),
			Position = UDim2.fromOffset(511, 36) })
]]

local UI = {}

-- =====================================================================================================
-- 1. TOKENS
-- =====================================================================================================
local RGB = Color3.fromRGB
local WHITE = Color3.new(1, 1, 1)

--- ColorSequence from colors spread evenly, or from {time, color} pairs.
function UI.seq(...)
	local args = { ... }
	local kps = {}
	if type(args[1]) == "table" then
		for _, p in args do table.insert(kps, ColorSequenceKeypoint.new(p[1], p[2])) end
	else
		for i, c in args do table.insert(kps, ColorSequenceKeypoint.new((i - 1) / math.max(#args - 1, 1), c)) end
	end
	return ColorSequence.new(kps)
end
local seq = UI.seq

UI.Fonts = {
	-- HUD / always-visible chrome and stud-button labels
	Gotham = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy),
	-- everything inside windows (titles, names, prices, rarity)
	Heavy = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy),
	-- descriptions only (the single "breathing" text)
	Bold = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Bold),
}

UI.Assets = {
	Studs = "rbxassetid://140544932962041", -- 56x56 tileable stud pattern
	Sunburst = "rbxassetid://130563114903838", -- radial rays, used at 0.45-0.55 transparency, always spinning
	ShopHeader = "rbxassetid://108268925256584", -- pre-rendered pink stud header texture (shop windows)
	Basket = "rbxassetid://120530633952826", -- red shop basket (header icon of shops)
	RobuxCoin = "rbxassetid://83084350609799", -- green robux coin used inside purple Robux buttons
	RobuxIcon = "rbxassetid://132619664297815", -- CheckUIIcons Currency/Robux/Green Robux 1st Outline
	Check = "rbxassetid://75340450258025", -- CheckUIIcons UI/Checkmark/Checkmark 1st Outline
	Lock = "rbxassetid://99673707827333", -- CheckUIIcons Item/Lock/Lock 1st Outline
	PlusBlack = "rbxassetid://126154074031322",
	PlusWhite = "rbxassetid://74804085353767",
}

-- Text highlight colors (RichText <font color=...>) and semantic text colors
UI.Colors = {
	White = WHITE,
	Highlight = RGB(255, 210, 63), -- #FFD23F  dynamic value inside a sentence
	HighlightHex = "#FFD23F",
	Danger = RGB(255, 122, 122), -- #FF7A7A
	Multiplier = RGB(255, 222, 80), -- #FFDE50 "x2"
	Positive = RGB(96, 232, 122), -- #60E87A values / states in tooltips
	Secondary = RGB(226, 230, 236), -- #E2E6EC secondary tooltip text
	Tag = RGB(255, 170, 235), -- #FFAAEB small tag top-left of slots
	TagGold = RGB(255, 230, 120), -- #FFE678 tag variant for durations/quantities
	RobuxPrice = RGB(180, 255, 140), -- #B4FF8C price next to robux icon
	OldPrice = RGB(255, 70, 90), -- #FF465A struck-through price
	FloatError = RGB(255, 110, 110), -- floating feedback text
	FloatSuccess = RGB(180, 255, 60),
	FloatWarn = RGB(255, 210, 90),
	StrokeDark = RGB(12, 20, 26), -- #0C141A generic dark text outline
	StrokeSlot = RGB(10, 8, 6), -- #0A0806 slot text outline
	StrokeCard = RGB(17, 13, 32), -- #110D20 product card text outline (indigo)
	StrokeTitleStud = RGB(10, 22, 40), -- #0A1628 window title on stud header
	StrokeTitleImage = RGB(26, 26, 24), -- #1A1A18 window title on image header
	StrokePill = RGB(10, 12, 16), -- #0A0C10
	StrokeFloat = RGB(17, 23, 26),
	BodyGlass = RGB(0, 0, 0), -- window body, 0.5 transparency
	CardInner = RGB(30, 34, 38), -- #1E2226 @0.72 product card interior
	Slot = RGB(20, 18, 16), -- #141210 @0.35 item slot
	SlotStroke = RGB(4, 3, 2),
	SlotLine = RGB(235, 232, 228), -- #EBE8E4 slot inner line
	Selection = RGB(180, 255, 25), -- #B4FF19 selected slot stroke
	Inset = RGB(20, 30, 36), -- #141E24 inset box
	InsetStroke = RGB(8, 12, 14),
	InsetLine = RGB(75, 125, 145), -- #4B7D91 @0.45
	PillBg = RGB(28, 36, 44), -- #1C242C
	PillLine = RGB(110, 140, 165), -- #6E8CA5 @0.35
	BarBg = RGB(14, 22, 26),
	HeaderBase = RGB(7, 5, 5), -- #070505 header plate
}

--[[ Button themes. Keys:
	fond   = face gradient (vertical, 90deg) - the bright color
	biseau = bottom lip gradient - the 3D thickness
	bord   = ImageButton background = 2px outer outline (darkest tone of the hue) ; also the dark reflection streak
	texte  = text outline + drop-shadow color (very dark tint of the hue, NEVER pure black)
	lueur  = optional tint of the bottom glow line (Glossy/Chunky styles)
	liserE = optional inner bevel tint (Chunky style) / gradient (Glossy style)
]]
UI.ButtonThemes = {
	green = { fond = seq({ 0, RGB(243, 254, 85) }, { 0.22, RGB(200, 254, 3) }, { 0.33, RGB(174, 255, 0) }, { 0.8, RGB(72, 254, 0) }, { 1, RGB(50, 251, 16) }),
		biseau = seq({ 0, RGB(8, 131, 6) }, { 0.4, RGB(6, 138, 3) }, { 0.7, RGB(16, 133, 7) }, { 1, RGB(22, 102, 10) }),
		bord = RGB(15, 51, 4), texte = RGB(26, 36, 2), reflet = RGB(10, 58, 0) },
	red = { fond = seq({ 0, RGB(253, 2, 122) }, { 0.49, RGB(255, 0, 77) }, { 1, RGB(239, 2, 14) }),
		biseau = seq({ 0, RGB(140, 0, 0) }, { 0.7, RGB(132, 2, 8) }, { 1, RGB(98, 4, 7) }),
		bord = RGB(42, 4, 16), texte = RGB(38, 2, 10), reflet = RGB(0, 0, 0) },
	blue = { fond = seq({ 0, RGB(143, 227, 252) }, { 0.5, RGB(79, 180, 253) }, { 0.85, RGB(31, 142, 245) }, { 1, RGB(12, 120, 239) }),
		biseau = seq({ 0, RGB(2, 68, 125) }, { 0.6, RGB(1, 72, 130) }, { 0.8, RGB(6, 68, 119) }, { 1, RGB(9, 58, 90) }),
		bord = RGB(1, 46, 51), texte = RGB(2, 40, 38), reflet = RGB(0, 26, 64) },
	yellow = { fond = seq(RGB(255, 240, 130), RGB(255, 206, 50), RGB(255, 160, 0)),
		biseau = seq(RGB(170, 100, 0), RGB(120, 60, 0)), bord = RGB(60, 32, 0), texte = RGB(70, 40, 0), reflet = RGB(107, 74, 32) },
	purple = { fond = seq(RGB(226, 130, 255), RGB(170, 60, 255), RGB(120, 20, 230)),
		biseau = seq(RGB(90, 10, 150), RGB(60, 0, 110)), bord = RGB(30, 0, 50), texte = RGB(40, 0, 60), reflet = RGB(30, 0, 50) },
	gray = { fond = seq(RGB(230, 234, 240), RGB(190, 196, 206), RGB(150, 160, 176)),
		biseau = seq(RGB(90, 98, 110), RGB(60, 66, 76)), bord = RGB(30, 34, 40), texte = RGB(40, 44, 52), reflet = RGB(30, 34, 40) },
	meadow = { fond = seq({ 0, RGB(178, 255, 88) }, { 0.49, RGB(102, 222, 40) }, { 1, RGB(52, 176, 18) }),
		biseau = seq(RGB(34, 124, 8), RGB(20, 82, 4)), bord = RGB(10, 44, 2), texte = RGB(12, 40, 4), reflet = RGB(10, 44, 2) },
	-- header action button (Restock) - Chunky style
	orange = { fond = seq({ 0, RGB(254, 224, 130) }, { 0.2, RGB(252, 200, 97) }, { 0.42, RGB(241, 188, 92) }, { 0.66, RGB(233, 174, 80) }, { 0.82, RGB(248, 156, 56) }, { 1, RGB(251, 144, 48) }),
		biseau = seq(RGB(183, 122, 8), RGB(122, 70, 0)), bord = RGB(77, 41, 0), texte = RGB(47, 42, 10), reflet = RGB(107, 74, 32),
		lueur = RGB(250, 180, 60), liserE = RGB(252, 231, 154) },
	-- close button - Chunky style
	close = { fond = seq({ 0, RGB(249, 106, 172) }, { 0.28, RGB(248, 90, 151) }, { 0.55, RGB(247, 71, 124) }, { 0.8, RGB(246, 44, 88) }, { 1, RGB(245, 15, 34) }),
		biseau = seq(RGB(138, 10, 16), RGB(90, 4, 4)), bord = RGB(60, 10, 28), texte = RGB(20, 6, 10), reflet = RGB(60, 10, 28),
		lueur = RGB(255, 90, 98), liserE = RGB(247, 160, 203) },
	-- purchase buttons inside product cards - Glossy style (fond rotated 28deg)
	robux = { fond = seq({ 0, RGB(217, 60, 236) }, { 0.35, RGB(194, 44, 232) }, { 0.7, RGB(156, 26, 223) }, { 1, RGB(116, 20, 203) }),
		biseau = seq(RGB(106, 20, 140), RGB(44, 0, 60)), bord = RGB(42, 7, 49), texte = RGB(12, 38, 3), reflet = RGB(42, 7, 49),
		lueur = RGB(240, 178, 234), liserE = seq({ 0, RGB(234, 166, 244) }, { 0.5, RGB(234, 166, 244) }, { 1, RGB(226, 170, 214) }), brillance = 0.82 },
	cash = { fond = seq({ 0, RGB(238, 251, 58) }, { 0.35, RGB(198, 251, 32) }, { 0.7, RGB(146, 247, 22) }, { 1, RGB(98, 236, 18) }),
		biseau = seq(RGB(63, 164, 10), RGB(28, 98, 6)), bord = RGB(43, 52, 0), texte = RGB(20, 23, 13), reflet = RGB(43, 52, 0),
		lueur = RGB(180, 251, 112), liserE = seq({ 0, RGB(248, 251, 158) }, { 0.5, RGB(248, 251, 158) }, { 1, RGB(182, 251, 106) }), brillance = 0.80 },
}
-- French aliases used by the reference game's scripts
UI.ButtonThemes.vert = UI.ButtonThemes.green
UI.ButtonThemes.rouge = UI.ButtonThemes.red
UI.ButtonThemes.bleu = UI.ButtonThemes.blue
UI.ButtonThemes.jaune = UI.ButtonThemes.yellow
UI.ButtonThemes.violet = UI.ButtonThemes.purple
UI.ButtonThemes.gris = UI.ButtonThemes.gray

--- Rarity ladder (Index tabs, product cards, slot accents). text = gradient on the rarity label.
UI.Rarities = {
	Common = { order = 1, text = seq(RGB(217, 215, 227), RGB(173, 166, 180)), panel = "rbxassetid://89267995407736",
		tab = { fond = seq({ 0, RGB(236, 238, 242) }, { 0.49, RGB(198, 200, 208) }, { 1, RGB(160, 163, 172) }), biseau = seq(RGB(112, 114, 124), RGB(78, 80, 90)), bord = RGB(40, 42, 48), texte = RGB(30, 32, 38) } },
	Uncommon = { order = 2, text = seq(RGB(196, 247, 154), RGB(67, 194, 46)), panel = "rbxassetid://131137889121430",
		tab = { fond = seq({ 0, RGB(176, 255, 112) }, { 0.49, RGB(104, 226, 42) }, { 1, RGB(58, 190, 20) }), biseau = seq(RGB(40, 132, 10), RGB(24, 90, 4)), bord = RGB(14, 50, 4), texte = RGB(14, 44, 8) } },
	Rare = { order = 3, text = seq(RGB(132, 202, 232), RGB(61, 142, 224)), panel = "rbxassetid://105083838865206",
		tab = { fond = seq({ 0, RGB(126, 218, 255) }, { 0.49, RGB(52, 166, 255) }, { 1, RGB(20, 118, 240) }), biseau = seq(RGB(10, 80, 170), RGB(4, 54, 120)), bord = RGB(4, 30, 70), texte = RGB(6, 26, 56) } },
	Epic = { order = 4, text = seq(RGB(226, 176, 255), RGB(154, 62, 240)), panel = "rbxassetid://101084229455301",
		tab = { fond = seq({ 0, RGB(222, 146, 255) }, { 0.49, RGB(172, 72, 255) }, { 1, RGB(128, 30, 236) }), biseau = seq(RGB(88, 20, 170), RGB(58, 8, 118)), bord = RGB(34, 4, 70), texte = RGB(34, 8, 56) } },
	Legendary = { order = 5, text = seq(RGB(255, 226, 122), RGB(245, 162, 21)), panel = "rbxassetid://86850543324255",
		tab = { fond = seq({ 0, RGB(255, 236, 96) }, { 0.49, RGB(255, 182, 30) }, { 1, RGB(250, 128, 10) }), biseau = seq(RGB(190, 90, 0), RGB(128, 58, 0)), bord = RGB(70, 34, 0), texte = RGB(62, 30, 4) } },
	Mythic = { order = 6, text = seq(RGB(255, 154, 176), RGB(238, 47, 87)), panel = "rbxassetid://135658280761682",
		tab = { fond = seq({ 0, RGB(255, 124, 154) }, { 0.49, RGB(255, 42, 92) }, { 1, RGB(226, 10, 52) }), biseau = seq(RGB(150, 0, 30), RGB(100, 0, 20)), bord = RGB(60, 0, 14), texte = RGB(62, 4, 20) } },
	Divine = { order = 7, text = seq(RGB(168, 255, 240), RGB(23, 196, 176)), panel = "rbxassetid://71658771409468",
		tab = { fond = seq({ 0, RGB(176, 255, 240) }, { 0.49, RGB(62, 230, 212) }, { 1, RGB(20, 188, 178) }), biseau = seq(RGB(10, 128, 120), RGB(4, 84, 80)), bord = RGB(0, 44, 44), texte = RGB(4, 44, 44) } },
	Cosmic = { order = 8, text = seq(RGB(205, 188, 255), RGB(106, 69, 245)), panel = "rbxassetid://121878407812617",
		tab = { fond = seq({ 0, RGB(118, 98, 182) }, { 0.49, RGB(64, 44, 128) }, { 1, RGB(32, 20, 74) }), biseau = seq(RGB(24, 14, 60), RGB(14, 8, 40)), bord = RGB(8, 4, 20), texte = RGB(14, 6, 30) } },
}

--- Window header gradients (stud headers). "image" headers use UI.Assets.ShopHeader instead.
UI.HeaderThemes = {
	blue = seq(RGB(124, 214, 255), RGB(58, 166, 255), RGB(26, 112, 238)), -- Index, Daily Rewards
	purple = seq(RGB(206, 120, 255), RGB(150, 60, 240), RGB(105, 30, 200)), -- Rebirth
	gold = seq(RGB(255, 222, 80), RGB(255, 170, 30), RGB(245, 120, 10)), -- Season Pass
	pink = seq(RGB(255, 100, 180), RGB(255, 40, 110), RGB(225, 20, 60)), -- Shop (Robux)
	green = seq(RGB(178, 255, 88), RGB(102, 222, 40), RGB(52, 176, 18)), -- extension (not in reference)
}

--- Stud panel gradients (Daily tiles, Rebirth cards, shop offers, reward banner)
UI.PanelThemes = {
	cyan = seq(RGB(0, 210, 255), RGB(0, 120, 255)),
	violet = seq(RGB(176, 32, 255), RGB(112, 0, 224)),
	amber = seq(RGB(255, 170, 0), RGB(224, 96, 0)),
	lime = seq(RGB(200, 255, 60), RGB(80, 210, 0)),
	green = seq(RGB(180, 255, 25), RGB(105, 225, 0)),
	magenta = seq(RGB(208, 0, 224), RGB(128, 0, 160)),
	pink = seq(RGB(255, 140, 220), RGB(200, 60, 255), RGB(140, 40, 230)), -- rotate 25
	cosmic = seq(RGB(130, 60, 255), RGB(255, 60, 180), RGB(255, 170, 40)), -- rotate 20
	blue = seq(RGB(90, 170, 255), RGB(30, 90, 230)),
	money = seq(RGB(120, 230, 110), RGB(30, 150, 60)),
	gold = seq(RGB(255, 222, 80), RGB(255, 150, 20)), -- reward banner
	rainbow = ColorSequence.new({ -- rotate 45, big "Day 7" tile
		ColorSequenceKeypoint.new(0.00, RGB(255, 30, 80)), ColorSequenceKeypoint.new(0.18, RGB(255, 140, 0)),
		ColorSequenceKeypoint.new(0.35, RGB(255, 230, 0)), ColorSequenceKeypoint.new(0.52, RGB(40, 230, 50)),
		ColorSequenceKeypoint.new(0.70, RGB(0, 210, 255)), ColorSequenceKeypoint.new(0.85, RGB(90, 60, 255)),
		ColorSequenceKeypoint.new(1.00, RGB(220, 0, 230)),
	}),
}

-- Text gradients
UI.TextGradients = {
	Money = seq({ 0, RGB(192, 255, 5) }, { 0.4, RGB(164, 255, 1) }, { 0.75, RGB(111, 255, 0) }, { 1, RGB(82, 249, 10) }),
	RobuxPrice = seq(RGB(194, 251, 24), RGB(88, 249, 8)),
	Stock = seq(RGB(248, 195, 42), RGB(229, 133, 21)), -- "Stock x6" / "Available"
	Owned = seq(RGB(196, 247, 154), RGB(67, 194, 46)),
	Locked = seq(RGB(217, 215, 227), RGB(150, 145, 160)),
	ProgressFill = seq(RGB(255, 210, 40), RGB(255, 120, 0)),
	NotifRed = seq(RGB(255, 82, 96), RGB(222, 10, 34)),
}

-- =====================================================================================================
-- 2. LOW LEVEL HELPERS
-- =====================================================================================================
local function new(class, props, parent)
	local i = Instance.new(class)
	for k, v in props do i[k] = v end
	if parent then i.Parent = parent end
	return i
end
UI.new = new

local function v2(v) -- accepts Vector2 or {x,y}
	if typeof(v) == "Vector2" then return v end
	return Vector2.new(v[1], v[2])
end

function UI.Corner(parent, px) return new("UICorner", { CornerRadius = UDim.new(0, px) }, parent) end

function UI.Stroke(parent, color, thickness, transparency, mode, name)
	return new("UIStroke", {
		Name = name or "UIStroke", Color = color, Thickness = thickness or 2, Transparency = transparency or 0,
		ApplyStrokeMode = mode or Enum.ApplyStrokeMode.Border, LineJoinMode = Enum.LineJoinMode.Round,
	}, parent)
end

function UI.Gradient(parent, colorSeq, rotation, name, transparency)
	return new("UIGradient", { Name = name or "UIGradient", Color = colorSeq, Rotation = rotation or 90,
		Transparency = transparency or NumberSequence.new(0) }, parent)
end

--- Hard-edged light stripes: bands = { {from, to, alpha}, ... } (alpha = transparency inside the band, 0.69-0.93).
--- This is how the "glass reflections" are made: a white full-size Frame + a UIGradient whose TRANSPARENCY
--- jumps between 1 and ~0.75 at nearly identical times. No images involved.
function UI.Stripes(bands)
	local E = 0.001
	local k = { NumberSequenceKeypoint.new(0, 1) }
	for _, b in bands do
		table.insert(k, NumberSequenceKeypoint.new(b[1], 1))
		table.insert(k, NumberSequenceKeypoint.new(b[1] + E, b[3]))
		table.insert(k, NumberSequenceKeypoint.new(b[2], b[3]))
		table.insert(k, NumberSequenceKeypoint.new(b[2] + E, 1))
	end
	table.insert(k, NumberSequenceKeypoint.new(1, 1))
	return NumberSequence.new(k)
end

-- Exact reflection presets measured on the reference UI (bands, rotation). Max 4 bands (NumberSequence = 20 pts).
UI.ReflectionPresets = {
	StudWide = { bands = { { 0.326, 0.391, 0.74 }, { 0.538, 0.572, 0.76 }, { 0.641, 0.694, 0.79 } }, rot = 60.57 },
	StudThinDark = { bands = { { 0.448, 0.494, 0.92 } }, rot = 60.57 },
	ShopsWide = { bands = { { 0.29, 0.31, 0.74 }, { 0.344, 0.42, 0.76 }, { 0.44, 0.46, 0.69 }, { 0.56, 0.65, 0.79 } }, rot = 60.57 },
	ShopsThinDark = { bands = { { 0.50, 0.56, 0.93 } }, rot = 60.57 },
	BlueA = { bands = { { 0.37, 0.39, 0.79 } }, rot = -68.25 },
	BlueB = { bands = { { 0.33, 0.35, 0.74 }, { 0.39, 0.435, 0.78 }, { 0.59, 0.64, 0.76 }, { 0.67, 0.69, 0.74 } }, rot = 64.18 },
	BlueDark = { bands = { { 0.55, 0.57, 0.90 } }, rot = -68.25 },
	Glossy = { bands = { { 0.28, 0.33, 0.80 }, { 0.34, 0.35, 0.82 }, { 0.54, 0.58, 0.84 }, { 0.59, 0.60, 0.86 } }, rot = 62.2 },
	HeaderFine = { bands = { { 0.287, 0.289, 0.74 }, { 0.293, 0.301, 0.76 }, { 0.304, 0.306, 0.69 }, { 0.317, 0.326, 0.79 } }, rot = 78.61 },
	HeaderFineDark = { bands = { { 0.31, 0.316, 0.93 }, { 0.363, 0.369, 0.93 }, { 0.415, 0.422, 0.93 }, { 0.468, 0.475, 0.93 } }, rot = 78.61 },
	Close = { bands = { { 0.002, 0.239, 0.86 }, { 0.242, 0.28, 0.86 } }, rot = 34.14 },
	RestockA = { bands = { { 0.002, 0.11, 0.76 }, { 0.115, 0.12, 0.84 } }, rot = 61.59 },
	RestockB = { bands = { { 0.73, 0.76, 0.55 }, { 0.78, 0.80, 0.70 } }, rot = 43.87 },
	RestockC = { bands = { { 0.76, 0.87, 0.86 } }, rot = -57.55 },
}

--- Adds a full-size reflection layer "Reflets". color = WHITE for light streaks, a dark tone for shadow streaks.
function UI.Reflection(parent, preset, color, zIndex)
	local p = type(preset) == "string" and UI.ReflectionPresets[preset] or preset
	local f = new("Frame", { Name = "Reflets", BackgroundColor3 = color or WHITE, BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1), ZIndex = zIndex or 5 }, parent)
	new("UIGradient", { Color = ColorSequence.new(WHITE), Transparency = UI.Stripes(p.bands), Rotation = p.rot }, f)
	return f
end

--- Tiled stud overlay that fades in toward the bottom-right (stud buttons / stud headers).
function UI.StudsOverlay(parent, zIndex)
	local s = new("ImageLabel", { Name = "Studs", BackgroundTransparency = 1, Image = UI.Assets.Studs,
		ScaleType = Enum.ScaleType.Tile, TileSize = UDim2.fromOffset(56, 56), Size = UDim2.fromScale(1, 1), ZIndex = zIndex or 6 }, parent)
	new("UIGradient", { Rotation = 55, Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.55, 0.9), NumberSequenceKeypoint.new(1, 0.45) }) }, s)
	return s
end

--- Flat stud texture for panels (constant 0.82 transparency, inset 2px).
function UI.StudsFlat(parent, zIndex, transparency)
	return new("ImageLabel", { Name = "Studs", BackgroundTransparency = 1, Image = UI.Assets.Studs, ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.fromOffset(56, 56), ImageTransparency = transparency or 0.82, Size = UDim2.new(1, -4, 1, -4),
		Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = zIndex or 2 }, parent)
end

local function inner(parent, name, inset, color, thickness, transparency, corner, z, mode)
	local f = new("Frame", { Name = name, BackgroundTransparency = 1, Size = UDim2.new(1, -inset, 1, -inset),
		Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = z or 8 }, parent)
	if corner then UI.Corner(f, corner) end
	local s = UI.Stroke(f, color, thickness, transparency, mode or Enum.ApplyStrokeMode.Border)
	return f, s
end
UI.InnerLine = inner

-- =====================================================================================================
-- 3. TEXT
-- =====================================================================================================
--[[ Outlined text. Every text in this style has a Contextual UIStroke 2.0-4.0 thick, tinted (not pure black).
	p: Name, Size (UDim2), Position, AnchorPoint, Color, Stroke (Color3), Thickness, Font ("Heavy"|"Gotham"|"Bold"|Font),
	   TextSize (number -> fixed) or Max (number -> TextScaled + UITextSizeConstraint), AlignX, AlignY, Rich, ZIndex,
	   Rotation, Gradient (ColorSequence, applied to the text fill), AutoX (AutomaticSize X) ]]
function UI.Text(parent, text, p)
	p = p or {}
	local font = p.Font
	if type(font) == "string" then font = UI.Fonts[font] end
	local t = new("TextLabel", {
		Name = p.Name or "Texte", BackgroundTransparency = 1, FontFace = font or UI.Fonts.Heavy, Text = text or "",
		RichText = p.Rich == true, TextColor3 = p.Color or WHITE,
		TextXAlignment = p.AlignX or Enum.TextXAlignment.Center, TextYAlignment = p.AlignY or Enum.TextYAlignment.Center,
		Size = p.Size or UDim2.fromScale(1, 1), Position = p.Position or UDim2.fromScale(0.5, 0.5),
		AnchorPoint = p.AnchorPoint or Vector2.new(0.5, 0.5), Rotation = p.Rotation or 0, ZIndex = p.ZIndex or 6,
	})
	if p.TextSize then
		t.TextSize = p.TextSize
	else
		t.TextScaled = true
		new("UITextSizeConstraint", { MaxTextSize = p.Max or 28, MinTextSize = p.Min or 1 }, t)
	end
	if p.AutoX then t.AutomaticSize = Enum.AutomaticSize.X end
	UI.Stroke(t, p.Stroke or UI.Colors.StrokeDark, p.Thickness or 2.6, 0, Enum.ApplyStrokeMode.Contextual)
	if p.Gradient then UI.Gradient(t, p.Gradient, 90) end
	t.Parent = parent
	return t
end

--[[ Extruded text: "Ombre" (same text, dark fill = stroke color, +offset px lower) under "Texte" (white).
	Used on every stud/chunky button label, HUD money, Friend Boost, X of the close button.
	p = UI.Text props + Offset (default 2: Ombre at +0, Texte at -2) ]]
function UI.ShadowText(parent, text, p)
	p = table.clone(p or {})
	local off = p.Offset or 2
	local base = p.Position or UDim2.fromScale(0.5, 0.5)
	local z = p.ZIndex or 9
	local sp = table.clone(p)
	sp.Name = p.ShadowName or "Ombre"; sp.Color = p.Stroke or UI.Colors.StrokeDark; sp.Position = base; sp.ZIndex = z; sp.Gradient = nil
	local ombre = UI.Text(parent, text, sp)
	local tp = table.clone(p)
	tp.Name = p.Name or "Texte"; tp.Position = base + UDim2.fromOffset(0, -off); tp.ZIndex = z + 1
	local texte = UI.Text(parent, text, tp)
	return texte, ombre
end

--- Big money counter (HUD): Gotham 36, lime gradient, dark green outline, 2px extrusion.
function UI.MoneyText(parent, text, p)
	p = p or {}
	return UI.ShadowText(parent, text, {
		Name = "Texte", Font = "Gotham", TextSize = p.TextSize or 36, Stroke = RGB(15, 51, 0), Thickness = 3,
		Gradient = UI.TextGradients.Money, AlignX = Enum.TextXAlignment.Left, Size = p.Size or UDim2.new(0, 0, 0, 40),
		Position = p.Position or UDim2.fromOffset(0, 2), AnchorPoint = Vector2.zero, AutoX = true, ZIndex = p.ZIndex or 1,
	})
end

function UI.Image(parent, image, p)
	p = p or {}
	return new("ImageLabel", { Name = p.Name or "Icone", BackgroundTransparency = 1, Image = image or "",
		ScaleType = p.ScaleType or Enum.ScaleType.Fit, Size = p.Size or UDim2.fromOffset(64, 64),
		Position = p.Position or UDim2.fromScale(0.5, 0.5), AnchorPoint = p.AnchorPoint or Vector2.new(0.5, 0.5),
		Rotation = p.Rotation or 0, ZIndex = p.ZIndex or 5, ImageTransparency = p.Transparency or 0,
		ImageColor3 = p.Color or WHITE }, parent)
end

--- Spinning-ready sunburst ("Soleil"). Rotate it with StudMotion.SpinSunbursts.
function UI.Sunburst(parent, size, p)
	p = p or {}
	return UI.Image(parent, UI.Assets.Sunburst, { Name = "Soleil", Size = typeof(size) == "UDim2" and size or UDim2.fromOffset(size, size),
		Position = p.Position or UDim2.fromScale(0.5, 0.47), Transparency = p.Transparency or 0.55, ZIndex = p.ZIndex or 4, Color = p.Color })
end

--[[ Faux outline for a flat icon (ImageLabel has no stroke): 11 dark copies offset by 1px (+3px below = thickness),
	a grey "Tranche" 1px lower, then the white icon on top. Reference: the "+" of the money HUD. ]]
function UI.OutlinedIcon(parent, imageDark, imageTop, p)
	p = p or {}
	local f = new("Frame", { Name = p.Name or "Plus", BackgroundTransparency = 1, Size = p.Size or UDim2.fromOffset(15, 15),
		Position = p.Position or UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = p.ZIndex or 4 }, parent)
	local offs = { { -1, -1 }, { 0, -1 }, { 1, -1 }, { -1, 0 }, { 1, 0 }, { -1, 1 }, { 0, 1 }, { 1, 1 }, { -1, 3 }, { 0, 3 }, { 1, 3 } }
	for i, o in offs do
		new("ImageLabel", { Name = "Contour" .. i, BackgroundTransparency = 1, Image = imageDark, ImageColor3 = p.OutlineColor or RGB(21, 23, 15),
			ScaleType = Enum.ScaleType.Fit, Size = UDim2.fromScale(1, 1), Position = UDim2.fromOffset(o[1], o[2]), ZIndex = f.ZIndex }, f)
	end
	new("ImageLabel", { Name = "Tranche", BackgroundTransparency = 1, Image = imageTop, ImageColor3 = p.SideColor or RGB(191, 195, 198),
		ScaleType = Enum.ScaleType.Fit, Size = UDim2.fromScale(1, 1), Position = UDim2.fromOffset(0, 1), ZIndex = f.ZIndex + 1 }, f)
	new("ImageLabel", { Name = "Icone", BackgroundTransparency = 1, Image = imageTop, ScaleType = Enum.ScaleType.Fit,
		Size = UDim2.fromScale(1, 1), ZIndex = f.ZIndex + 2 }, f)
	return f
end

-- =====================================================================================================
-- 4. BUTTONS
-- =====================================================================================================
local function themeOf(t)
	if type(t) == "table" then return t end
	return UI.ButtonThemes[t or "green"] or UI.Rarities[t] and UI.Rarities[t].tab or UI.ButtonThemes.green
end

--[[ 3D button. Three styles, all built from the same layers:
	ImageButton (bg = theme.bord -> 2px outline)
	 ├ Biseau   bottom lip, dark gradient (the thickness)
	 ├ Face     CanvasGroup inset 2px (GroupTransparency 0.45 = disabled, GroupColor3 = inactive tint)
	 │   ├ Fond        bright gradient (z1)
	 │   ├ Brillance   (Glossy) top 55% white gloss
	 │   ├ Reflets     diagonal hard-edged light / dark streaks (z5)
	 │   ├ Studs       (Stud) tiled studs fading to bottom-right (z6)
	 │   ├ LiseréInterne1/2  double inner bevel (z8)
	 │   └ LueurBas    2-3px bottom glow (z8)
	 ├ Icone    rotated -8deg, overflowing "sticker"
	 ├ Ombre/Texte  extruded label
	 └ ButtonScale (UIScale for hover/press)

	p: Name, Size (Vector2 px), Position (UDim2), AnchorPoint (default .5,.5), Theme (name|table), Style ("Stud"|"Glossy"|"Chunky"),
	   Text, TextSize (Max size, scaled) or FixedTextSize, Font, Icon (image), IconSize (fraction of height, .74),
	   IconLayout ("Left" default | "Top" | "Big" (square menu tile: big icon top, label bottom)), IconRotation (-8),
	   Studs (bool, default true for Stud style), Reflections ({preset names}), ZIndex, LayoutOrder ]]
function UI.Button(parent, p)
	p = p or {}
	local style = p.Style or "Stud"
	local th = themeOf(p.Theme)
	local size = v2(p.Size or Vector2.new(179, 65))
	local w, h = size.X, size.Y
	local z = p.ZIndex or 1
	local b = new("ImageButton", {
		Name = p.Name or "Bouton", AutoButtonColor = false, BackgroundColor3 = th.bord, BorderSizePixel = 0, Image = "",
		Size = UDim2.fromOffset(w, h), Position = p.Position or UDim2.fromScale(0.5, 0.5),
		AnchorPoint = p.AnchorPoint or Vector2.new(0.5, 0.5), ZIndex = z, LayoutOrder = p.LayoutOrder or 0,
	})
	local corner = (style == "Glossy" and 5) or (style == "Chunky" and 6) or nil
	if corner then UI.Corner(b, corner) end

	-- lip & face geometry per style
	local lip = (style == "Glossy" and 8) or (style == "Chunky" and 10) or (h >= 80 and 6 or 4)
	local faceCut = (style == "Glossy" and 7) or (style == "Chunky" and 8) or (h >= 80 and 10 or 8)
	local biseau = new("Frame", { Name = "Biseau", BackgroundColor3 = WHITE, BorderSizePixel = 0, Size = UDim2.new(1, -4, 0, lip),
		Position = UDim2.new(0, 2, 1, -(lip + 2)), ZIndex = z + 1 }, b)
	UI.Gradient(biseau, th.biseau, 90)
	if corner then UI.Corner(biseau, corner - 2) end

	local face = new("CanvasGroup", { Name = "Face", BackgroundTransparency = 1, Size = UDim2.new(1, -4, 1, -faceCut),
		Position = UDim2.fromOffset(2, 2), ZIndex = z + 1 }, b)
	if corner then UI.Corner(face, corner - 2) end
	local fond = new("Frame", { Name = "Fond", BackgroundColor3 = WHITE, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 1 }, face)
	UI.Gradient(fond, th.fond, style == "Glossy" and 28 or 90, "Degrade")

	if style == "Stud" then
		local presets = p.Reflections or { "StudWide", "StudThinDark" }
		for i, name in presets do UI.Reflection(face, name, i == 1 and WHITE or (th.reflet or th.bord), 5) end
		if p.Studs ~= false then UI.StudsOverlay(face, 6) end
		inner(face, "LiseréInterne1", 2, WHITE, 1, 0.3, nil, 8)
		inner(face, "LiseréInterne2", 4, WHITE, 1, 0.72, nil, 8)
		new("Frame", { Name = "LueurBas", BackgroundColor3 = WHITE, BackgroundTransparency = 0.6, BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 2), Position = UDim2.fromScale(0, 1), AnchorPoint = Vector2.new(0, 1), ZIndex = 8 }, face)
	elseif style == "Glossy" then
		local br = new("Frame", { Name = "Brillance", BackgroundColor3 = WHITE, BorderSizePixel = 0, Size = UDim2.fromScale(1, 0.55), ZIndex = 2 }, face)
		new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(th.brillance or 0.8, 1) }, br)
		UI.Reflection(face, p.Reflections and p.Reflections[1] or "Glossy", WHITE, 3)
		local l1, s1 = inner(face, "LisereInterne1", 2, WHITE, 1.5, 0, 2, 4)
		if typeof(th.liserE) == "ColorSequence" then UI.Gradient(s1, th.liserE, 90) elseif th.liserE then s1.Color = th.liserE end
		new("Frame", { Name = "LueurBas", BackgroundColor3 = th.lueur or WHITE, BackgroundTransparency = 0.2, BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 2), Position = UDim2.fromScale(0, 1), AnchorPoint = Vector2.new(0, 1), ZIndex = 4 }, face)
	else -- Chunky
		local presets = p.Reflections or { "Close" }
		for i, name in presets do UI.Reflection(face, name, i == 2 and (th.reflet or th.bord) or WHITE, 2) end
		new("Frame", { Name = "LueurBas", BackgroundColor3 = th.lueur or WHITE, BackgroundTransparency = 0.25, BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 3), Position = UDim2.fromScale(0, 1), AnchorPoint = Vector2.new(0, 1), ZIndex = 3 }, face)
		local liser = typeof(th.liserE) == "Color3" and th.liserE or WHITE
		inner(face, "LisereInterne1", 2, liser, 1.5, 0.1, 3, 4)
		inner(face, "LisereInterne2", 5, WHITE, 1, 0.7, 2, 4)
	end

	-- icon
	local layout = p.IconLayout or "Left"
	local cx, tw, th_ = w / 2, w - 18, math.floor(h * (p.TextHeight or 0.62))
	local textY = 0.5
	if p.Icon then
		if layout == "Left" then
			local ti = math.floor(h * (p.IconSize or 0.74))
			UI.Image(b, p.Icon, { Name = "Icone", Size = UDim2.fromOffset(ti, ti), Position = UDim2.new(0, math.floor(h * 0.58), 0.5, -2),
				Rotation = p.IconRotation or -8, ZIndex = z + 7 })
			local start = math.floor(h * 1.05)
			cx, tw = (start + w - 10) / 2, w - 10 - start
		elseif layout == "Top" then -- tab button (96x70): icon on top, small label at bottom
			local ti = math.floor(math.min(w, h) * (p.IconSize or 0.57))
			UI.Image(b, p.Icon, { Name = "Icone", Size = UDim2.fromOffset(ti, ti), Position = UDim2.new(0.5, 0, 0, math.floor(h * 0.34)),
				Rotation = p.IconRotation or 0, ZIndex = z + 7 })
			th_ = 22; textY = nil
		elseif layout == "Big" then -- square menu tile (106x106): huge icon overflowing, label on the bottom edge
			local ti = math.floor(w * (p.IconSize or 0.8))
			UI.Image(b, p.Icon, { Name = "Icone", Size = UDim2.fromOffset(ti, ti), Position = UDim2.new(0.5, 0, 0, math.floor(h * 0.38)),
				Rotation = p.IconRotation or 0, ZIndex = z + 7 })
			th_ = 34; tw = w + 4; textY = nil
		end
	end

	if p.Text and p.Text ~= "" then
		local font = p.Font or (style == "Stud" and "Gotham" or "Heavy")
		local tp = {
			Font = font, Stroke = th.texte, Thickness = p.TextThickness or 3, ZIndex = z + 8,
			Size = UDim2.fromOffset(tw, th_), Max = p.TextSize or 30, TextSize = p.FixedTextSize,
			Offset = style == "Chunky" and 2 or 2,
		}
		if textY then
			tp.Position = UDim2.new(0, cx, 0.5, style == "Chunky" and 1 or -1)
		elseif layout == "Top" then
			tp.Position = UDim2.new(0.5, 0, 1, -17); tp.Max = p.TextSize or 18
		else -- Big
			tp.Position = UDim2.new(0.5, 0, 1, -18); tp.Max = p.TextSize or 28
		end
		if style == "Glossy" then
			-- glossy purchase buttons: no extrusion, single stroked label
			tp.Position = tp.Position + UDim2.fromOffset(0, -2); tp.Thickness = 2.6
			UI.Text(b, p.Text, tp)
		else
			UI.ShadowText(b, p.Text, tp)
		end
	end

	new("UIScale", { Name = "ButtonScale" }, b)
	b:SetAttribute("Theme", type(p.Theme) == "string" and p.Theme or "custom")
	b.Parent = parent
	return b
end

--- Re-color an existing 3D button (same contract as the reference game's ModuleMenus.Theme).
function UI.Recolor(b, theme)
	local th = themeOf(theme)
	b.BackgroundColor3 = th.bord
	b.Biseau.UIGradient.Color = th.biseau
	b.Face.Fond.Degrade.Color = th.fond
	for _, r in b.Face:GetChildren() do
		if r.Name == "Reflets" and r.BackgroundColor3 ~= WHITE then r.BackgroundColor3 = th.reflet or th.bord end
	end
	for _, n in { "Texte", "Ombre" } do
		local t = b:FindFirstChild(n)
		if t then t.UIStroke.Color = th.texte; if n == "Ombre" then t.TextColor3 = th.texte end end
	end
	if type(theme) == "string" then b:SetAttribute("Theme", theme) end
end

function UI.SetButtonText(b, text)
	for _, n in { "Texte", "Ombre" } do local t = b:FindFirstChild(n); if t then t.Text = text end end
end

--- Disabled / sold-out look: the whole face fades (this is why Face is a CanvasGroup).
function UI.SetDisabled(b, disabled)
	b.Face.GroupTransparency = disabled and 0.45 or 0
end

--- Square 55x55 close button with extruded "X" (Montserrat 38).
function UI.CloseButton(parent, p)
	p = p or {}
	local b = UI.Button(parent, { Name = p.Name or "Fermer", Style = "Chunky", Theme = "close", Size = Vector2.new(55, 55),
		Position = p.Position, AnchorPoint = p.AnchorPoint, ZIndex = p.ZIndex or 8, Reflections = { "Close" } })
	UI.ShadowText(b, "X", { Name = "X", ShadowName = "X_Ombre", Font = "Heavy", TextSize = 38, Stroke = RGB(20, 6, 10),
		Thickness = 3.2, Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0.5, 0.5), ZIndex = (p.ZIndex or 8) + 2 })
	return b
end

--[[ Robux price badge sitting on the top-right corner of a button: green robux icon + light-green price.
	oldPrice -> red struck-through price, rotated -8deg, top-left. ]]
function UI.RobuxBadge(button, price, oldPrice, icon)
	local f = new("Frame", { Name = "Robux", BackgroundTransparency = 1, Size = UDim2.fromOffset(74, 30),
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -24, 0, 0), ZIndex = 20 })
	UI.Image(f, icon or UI.Assets.RobuxIcon, { Name = "Icone", Size = UDim2.fromOffset(28, 28), Position = UDim2.new(0, 14, 0.5, 0), ZIndex = 21 })
	UI.Text(f, tostring(price), { Name = "Prix", Size = UDim2.new(0, 46, 1, 0), Position = UDim2.new(0, 30, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5), AlignX = Enum.TextXAlignment.Left, Max = 22, Color = UI.Colors.RobuxPrice, ZIndex = 21 })
	if oldPrice then
		local t = UI.Text(button, tostring(oldPrice), { Name = "AncienPrix", Size = UDim2.fromOffset(54, 24), Position = UDim2.new(0, 22, 0, 0),
			Max = 20, Color = UI.Colors.OldPrice, ZIndex = 21, Rotation = -8 })
		new("Frame", { Name = "Barre", BackgroundColor3 = UI.Colors.OldPrice, BorderSizePixel = 0, Size = UDim2.new(0.9, 0, 0, 3),
			Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 22 }, t)
	end
	f.Parent = button
	return f
end

--- Robux content for purple Glossy buttons inside product cards: coin + green-gradient number.
function UI.RobuxContent(button, price)
	local c = new("Frame", { Name = "Contenu", BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 36), Position = UDim2.new(0.5, -3, 0, math.floor(button.Size.Y.Offset * 0.47)),
		AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = button.ZIndex + 7 }, button)
	new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4),
		HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder }, c)
	UI.Image(c, UI.Assets.RobuxCoin, { Name = "Piece", Size = UDim2.fromOffset(36, 36), AnchorPoint = Vector2.zero, Position = UDim2.new(), ZIndex = c.ZIndex }).LayoutOrder = 1
	local t = UI.Text(c, tostring(price), { Name = "Texte", TextSize = 31, AutoX = true, Size = UDim2.fromOffset(0, 34), AnchorPoint = Vector2.zero,
		Position = UDim2.new(), Stroke = RGB(12, 38, 3), Thickness = 2.2, Gradient = UI.TextGradients.RobuxPrice, ZIndex = c.ZIndex + 1 })
	t.LayoutOrder = 2
	return c
end

--- Red circular notification badge "!" with a UIScale "Pulse" (animate with StudMotion.PulseScale(badge.Pulse)).
function UI.NotifBadge(parent, p)
	p = p or {}
	local f = new("Frame", { Name = p.Name or "Nouveau", BackgroundColor3 = WHITE, BorderSizePixel = 0, Size = UDim2.fromOffset(28, 28),
		Position = p.Position or UDim2.new(1, -4, 0, 4), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = p.ZIndex or 12 }, parent)
	new("UICorner", { CornerRadius = UDim.new(1, 0) }, f)
	UI.Gradient(f, UI.TextGradients.NotifRed, 90)
	UI.Stroke(f, RGB(30, 4, 10), 2.6)
	UI.Text(f, p.Text or "!", { Name = "TextLabel", Font = "Gotham", TextSize = 22, Position = UDim2.new(0.5, 0, 0.5, -1),
		Stroke = RGB(60, 4, 14), Thickness = 2, ZIndex = f.ZIndex + 1 })
	new("UIScale", { Name = "Pulse" }, f)
	return f
end

-- =====================================================================================================
-- 5. CONTAINERS
-- =====================================================================================================
--- Standard ScreenGui (+ empty "Sons" folder and "Basculer" BindableEvent used by StudMotion.Window).
function UI.ScreenGui(name, displayOrder, p)
	p = p or {}
	local g = new("ScreenGui", { Name = name, ResetOnSpawn = false, IgnoreGuiInset = p.IgnoreGuiInset ~= false,
		ZIndexBehavior = p.Global and Enum.ZIndexBehavior.Global or Enum.ZIndexBehavior.Sibling,
		ScreenInsets = p.ScreenInsets or Enum.ScreenInsets.DeviceSafeInsets, DisplayOrder = displayOrder or 10 })
	if p.Menu ~= false then
		new("Folder", { Name = "Sons" }, g)
		new("BindableEvent", { Name = "Basculer" }, g)
	end
	g.Parent = p.Parent
	return g
end

--[[ Colored stud panel ("panneau"): gradient + flat studs 0.82 + thick dark stroke 3 + inner white line @0.35.
	Used for Daily tiles, Rebirth cards, shop offer banners, the gold reward banner, FREE/PREMIUM tracks.
	p: Name, Size (UDim2), Position, AnchorPoint, Gradient (ColorSequence or UI.PanelThemes key), Rotation (90), Corner (6), Stroke (3), ZIndex ]]
function UI.StudPanel(parent, p)
	local grad = p.Gradient
	if type(grad) == "string" then grad = UI.PanelThemes[grad] end
	local z = p.ZIndex or 2
	local f = new("Frame", { Name = p.Name or "Panneau", BackgroundColor3 = WHITE, BorderSizePixel = 0, Size = p.Size,
		Position = p.Position or UDim2.new(), AnchorPoint = p.AnchorPoint or Vector2.zero, ZIndex = z, LayoutOrder = p.LayoutOrder or 0 })
	local c = p.Corner or 6
	UI.Corner(f, c)
	UI.Gradient(f, grad or UI.PanelThemes.cyan, p.Rotation or 90, "Degrade")
	UI.Stroke(f, UI.Colors.StrokeDark, p.Stroke or 3)
	UI.StudsFlat(f, z)
	inner(f, "Lisere", 5, WHITE, 1.4, 0.35, math.max(c - 2, 0), z, Enum.ApplyStrokeMode.Contextual)
	f.Parent = parent
	return f
end

--[[ Dark recessed box ("boite"): #141E24 @0.1, stroke #080C0E 2.5, inner line #4B7D91 1.2 @0.45, corner 6.
	Used for "Lvl." headers, requirements frame, HUD boost pills, bottom bars, shop sub-boxes (transparency 0.25). ]]
function UI.InsetBox(parent, p)
	local z = p.ZIndex or 3
	local f = new("Frame", { Name = p.Name or "Boite", BackgroundColor3 = p.Color or UI.Colors.Inset,
		BackgroundTransparency = p.Transparency or 0.1, BorderSizePixel = 0, Size = p.Size, Position = p.Position or UDim2.new(),
		AnchorPoint = p.AnchorPoint or Vector2.zero, ZIndex = z, LayoutOrder = p.LayoutOrder or 0 })
	UI.Corner(f, p.Corner or 6)
	UI.Stroke(f, UI.Colors.InsetStroke, 2.5)
	inner(f, "Lisere", 4, UI.Colors.InsetLine, 1.2, 0.45, math.max((p.Corner or 6) - 2, 0), z, Enum.ApplyStrokeMode.Contextual)
	f.Parent = parent
	return f
end

--- Progress bar: inset box, orange-gold fill (Remplissage.Size.X.Scale = progress) with a top gloss strip, centered value.
function UI.ProgressBar(parent, p)
	local b = UI.InsetBox(parent, { Name = p.Name or "Barre", Size = p.Size, Position = p.Position, AnchorPoint = p.AnchorPoint,
		Color = UI.Colors.BarBg, Transparency = 0, ZIndex = p.ZIndex })
	b.ClipsDescendants = true
	local fill = new("Frame", { Name = "Remplissage", BackgroundColor3 = WHITE, BorderSizePixel = 0,
		Size = UDim2.new(math.clamp(p.Progress or 0.5, 0, 1), 0, 1, 0), ZIndex = b.ZIndex + 1 }, b)
	UI.Corner(fill, 5)
	UI.Gradient(fill, p.Fill or UI.TextGradients.ProgressFill, 90)
	local gloss = new("Frame", { BackgroundColor3 = WHITE, BackgroundTransparency = 0.55, BorderSizePixel = 0,
		Size = UDim2.new(1, -6, 0.28, 0), Position = UDim2.fromOffset(3, 3), ZIndex = fill.ZIndex }, fill)
	UI.Corner(gloss, 3)
	UI.Text(b, p.Text or "0/100", { Name = "Valeur", Size = UDim2.new(1, -10, 0.82, 0), Max = p.Max or 22, ZIndex = b.ZIndex + 3, Rich = true })
	return b
end

--- Rounded info pill ("Minuteur"/"Aide"): #1C242C, stroke #0A0C10 2.5, inner line #6E8CA5 1.2 @0.35, RichText Montserrat 18.
function UI.Pill(parent, text, p)
	p = p or {}
	local h = p.Height or 30
	local z = p.ZIndex or 20
	local f = new("Frame", { Name = p.Name or "Minuteur", BackgroundColor3 = UI.Colors.PillBg, BorderSizePixel = 0,
		Size = p.Width and UDim2.fromOffset(p.Width, h) or UDim2.fromOffset(0, h), AutomaticSize = p.Width and Enum.AutomaticSize.None or Enum.AutomaticSize.X,
		Position = p.Position or UDim2.fromScale(0.5, 0), AnchorPoint = p.AnchorPoint or Vector2.new(0.5, 0.5), ZIndex = z }, parent)
	UI.Corner(f, math.floor(h / 2))
	UI.Stroke(f, UI.Colors.StrokePill, 2.5)
	if p.Width then
		inner(f, "Liseré", 4, UI.Colors.PillLine, 1.2, 0.35, math.floor(h / 2) - 2, z + 1)
		UI.Text(f, text, { Name = "Texte", Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0.5, 0, 0.5, -1), TextSize = p.TextSize or 18,
			Stroke = UI.Colors.StrokePill, Thickness = 2, Rich = true, ZIndex = z + 2 })
	else
		new("UIPadding", { PaddingLeft = UDim.new(0, 18), PaddingRight = UDim.new(0, 18) }, f)
		UI.Text(f, text, { Name = "Texte", Size = UDim2.fromScale(0, 1), Position = UDim2.new(), AnchorPoint = Vector2.zero, AutoX = true,
			TextSize = p.TextSize or 18, Stroke = UI.Colors.StrokePill, Thickness = 2, Rich = true, ZIndex = z + 2 })
	end
	return f
end

--[[ Scroll list with padding + layout. p: Size, Position, Direction ("Y"|"X"), Padding (list gap), Grid (Vector2 cell) + GridGap,
	PadTop, PadLeft, PadRight, PadBottom, BarColor ]]
function UI.ScrollList(parent, p)
	local dirX = p.Direction == "X"
	local s = new("ScrollingFrame", { Name = p.Name or "Liste", BackgroundTransparency = 1, BorderSizePixel = 0, Size = p.Size,
		Position = p.Position or UDim2.fromOffset(4, 4), ScrollingDirection = dirX and Enum.ScrollingDirection.X or Enum.ScrollingDirection.Y,
		ScrollBarThickness = p.BarThickness or 6, ScrollBarImageColor3 = p.BarColor or WHITE, CanvasSize = UDim2.new(),
		AutomaticCanvasSize = dirX and Enum.AutomaticSize.X or Enum.AutomaticSize.Y, ZIndex = p.ZIndex or 2 }, parent)
	new("UIPadding", { PaddingTop = UDim.new(0, p.PadTop or 18), PaddingLeft = UDim.new(0, p.PadLeft or 13),
		PaddingRight = UDim.new(0, p.PadRight or 0), PaddingBottom = UDim.new(0, p.PadBottom or 7) }, s)
	if p.Grid then
		local g = v2(p.Grid)
		new("UIGridLayout", { CellSize = UDim2.fromOffset(g.X, g.Y), CellPadding = UDim2.fromOffset(p.GridGap or 12, p.GridGap or 12),
			SortOrder = Enum.SortOrder.LayoutOrder }, s)
	else
		new("UIListLayout", { FillDirection = dirX and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
			Padding = UDim.new(0, p.Padding or 9), SortOrder = Enum.SortOrder.LayoutOrder }, s)
	end
	return s
end

--[[ WINDOW ("Fenetre"). Returns a table { Fenetre, Entete, Corps, Fermer, Titre, Icone, WindowScale }.
	Geometry (header height Hh = 78 stud / 81 image):
	  Entete  (W x Hh) plate #070505 corner 4, z4  -> Face (W-4 x Hh-4) at (2,2): gradient + reflections + studs + bevels
	  Icone   96x96 at (-14,-14) rot -10 z12  (overflows the top-left corner: "sticker")
	  Titre   Montserrat 50 at (86, 39) left aligned, outline 4px
	  Fermer  55x55 at (W-41, Hh/2-2)
	  Corps   (W-5 x H-Hh-2) at (2, Hh) black @0.5, corner 2, stroke #020403 2
	  LisereCorps (W-9 x H-Hh+17) at (3, Hh-21) white 1.5 @0.62 (thin second frame)
	p: Size (Vector2), Title, Icon, Header ("blue"|"purple"|"gold"|"pink"|"green"|ColorSequence|"image"), HeaderImage,
	   IconSize, Close (bool, default true), Position, Visible (false) ]]
function UI.Window(gui, p)
	local size = v2(p.Size or Vector2.new(640, 470))
	local W, H = size.X, size.Y
	local imageHeader = p.Header == "image" or p.HeaderImage ~= nil
	local Hh = imageHeader and 81 or 78
	local fen = new("Frame", { Name = p.Name or "Fenetre", BackgroundTransparency = 1, Size = UDim2.fromOffset(W, H),
		Position = p.Position or UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Visible = p.Visible == true, ZIndex = 1 })
	local scale = new("UIScale", { Name = "WindowScale" }, fen)

	local corps = new("Frame", { Name = "Corps", BackgroundColor3 = UI.Colors.BodyGlass, BackgroundTransparency = 0.5, BorderSizePixel = 0,
		Size = UDim2.fromOffset(W - 5, H - Hh - 2), Position = UDim2.fromOffset(2, Hh), ZIndex = 1 }, fen)
	UI.Corner(corps, 2)
	UI.Stroke(corps, RGB(2, 4, 3), 2)
	local lisere = new("Frame", { Name = "LisereCorps", BackgroundTransparency = 1, Size = UDim2.fromOffset(W - 9, H - Hh + 17),
		Position = UDim2.fromOffset(3, Hh - 21), ZIndex = 1 }, fen)
	UI.Stroke(lisere, WHITE, 1.5, 0.62)

	local entete = new("Frame", { Name = "Entete", BackgroundColor3 = UI.Colors.HeaderBase, BorderSizePixel = 0,
		Size = UDim2.fromOffset(W, Hh), ZIndex = 4 }, fen)
	UI.Corner(entete, 4)
	if imageHeader then
		new("ImageLabel", { Name = "Face", BackgroundTransparency = 1, Image = p.HeaderImage or UI.Assets.ShopHeader,
			ScaleType = Enum.ScaleType.Stretch, Size = UDim2.fromOffset(W - 5, Hh - 4), Position = UDim2.fromOffset(2, 2), ZIndex = 5 }, entete)
	else
		local face = new("CanvasGroup", { Name = "Face", BackgroundTransparency = 1, Size = UDim2.fromOffset(W - 4, Hh - 4),
			Position = UDim2.fromOffset(2, 2), ZIndex = 5 }, entete)
		local grad = p.Header
		if type(grad) == "string" or grad == nil then grad = UI.HeaderThemes[grad or "blue"] end
		local fond = new("Frame", { Name = "Fond", BackgroundColor3 = WHITE, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 1 }, face)
		UI.Gradient(fond, grad, 90, "Degrade")
		UI.Reflection(face, "HeaderFine", WHITE, 5)
		UI.Reflection(face, "HeaderFineDark", RGB(0, 0, 0), 5)
		UI.StudsOverlay(face, 6)
		inner(face, "LiseréInterne1", 2, WHITE, 1, 0.3, nil, 8)
		inner(face, "LiseréInterne2", 4, WHITE, 1, 0.72, nil, 8)
		new("Frame", { Name = "LueurBas", BackgroundColor3 = WHITE, BackgroundTransparency = 0.6, BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 2), Position = UDim2.fromScale(0, 1), AnchorPoint = Vector2.new(0, 1), ZIndex = 8 }, face)
	end
	local icone
	if p.Icon then
		if imageHeader then -- shops: basket at (-5, 1), 92x76, no rotation (swings at runtime)
			icone = new("ImageLabel", { Name = "Panier", BackgroundTransparency = 1, Image = p.Icon, ScaleType = Enum.ScaleType.Stretch,
				Size = UDim2.fromOffset(92, 76), Position = UDim2.fromOffset(-5, 1), ZIndex = 12 }, entete)
		else
			local s = p.IconSize or 96
			icone = new("ImageLabel", { Name = "Icone", BackgroundTransparency = 1, Image = p.Icon, ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromOffset(s, s), Position = UDim2.fromOffset(-14, -14), Rotation = -10, ZIndex = 12 }, entete)
		end
	end
	local titre = UI.Text(entete, p.Title or "Title", { Name = "Titre", Size = UDim2.fromOffset(p.TitleWidth or 340, 60),
		Position = UDim2.fromOffset(p.Icon and (imageHeader and 84 or 86) or 24, imageHeader and 34 or 39), AnchorPoint = Vector2.new(0, 0.5),
		AlignX = Enum.TextXAlignment.Left, TextSize = 50, Thickness = 4,
		Stroke = imageHeader and UI.Colors.StrokeTitleImage or UI.Colors.StrokeTitleStud, ZIndex = 11 })
	local fermer
	if p.Close ~= false then
		fermer = UI.CloseButton(entete, { Position = UDim2.fromOffset(W - 41, imageHeader and 36 or 37) })
	end
	fen.Parent = gui
	return { Fenetre = fen, Entete = entete, Corps = corps, Fermer = fermer, Titre = titre, Icone = icone, WindowScale = scale,
		Width = W, Height = H, HeaderHeight = Hh }
end

-- =====================================================================================================
-- 6. CARDS & SLOTS
-- =====================================================================================================
--[[ Dark item slot / reward card ("Case"/"Carte"): translucent #141210 @0.35, NO corner, Bord #040302 3px, inner line
	#EBE8E4 1.4 @0.15 + hidden lime "Selection" stroke, spinning sunburst clipped inside, big icon, name at bottom,
	optional quantity top-right, tag top-left, check / lock overlay bottom-right.
	p: Name, Size (Vector2), Position, AnchorPoint, Icon, Title (name), Quantity ("x1"), Tag, TagColor, Top (text above the card,
	   e.g. drop chance "60%") + TopColor, Check (bool), Lock (bool), Selected (bool), ZIndex, Button (true -> ImageButton) ]]
function UI.ItemSlot(parent, p)
	local size = v2(p.Size or Vector2.new(80, 80))
	local z = p.ZIndex or 2
	local b = new(p.Button == false and "Frame" or "ImageButton", { Name = p.Name or "Carte", BackgroundColor3 = UI.Colors.Slot,
		BackgroundTransparency = 0.35, BorderSizePixel = 0, Size = UDim2.fromOffset(size.X, size.Y),
		Position = p.Position or UDim2.new(), AnchorPoint = p.AnchorPoint or Vector2.zero, ZIndex = z, LayoutOrder = p.LayoutOrder or 0 })
	if b:IsA("ImageButton") then b.AutoButtonColor = false; b.Image = "" end
	UI.Stroke(b, UI.Colors.SlotStroke, 3, 0, nil, "Bord")
	local lis = new("Frame", { Name = "Lisere", BackgroundTransparency = 1, Size = UDim2.new(1, -8, 1, -8), Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = z }, b)
	UI.Stroke(lis, UI.Colors.SlotLine, 1.4, 0.15, nil, "Trait")
	local sel = UI.Stroke(lis, UI.Colors.Selection, 3, 0, nil, "Selection")
	sel.Enabled = p.Selected == true
	local rayons = new("Frame", { Name = "Rayons", BackgroundTransparency = 1, ClipsDescendants = true, Size = UDim2.new(1, -6, 1, -6),
		Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = z }, b)
	UI.Sunburst(rayons, UDim2.fromScale(1.6, 1.6), { Position = UDim2.fromScale(0.5, 0.42), Transparency = 0.45, ZIndex = z })
	local ti = math.floor(math.min(size.X, size.Y) * (p.IconScale or 0.62))
	UI.Image(b, p.Icon or "", { Name = "Icone", Size = UDim2.fromOffset(ti, ti), Position = UDim2.new(0.5, 0, 0.5, -math.floor(size.Y * 0.06)), ZIndex = z + 2 })
	UI.Text(b, p.Title or "Item Name", { Name = "Nom", Size = UDim2.new(1, -8, 0, math.max(16, math.floor(size.Y * 0.18))),
		Position = UDim2.new(0.5, 0, 1, -5), AnchorPoint = Vector2.new(0.5, 1), Max = p.TitleMax or 20, Stroke = UI.Colors.StrokeSlot, Thickness = 2.4, ZIndex = z + 4 })
	local tag = UI.Text(b, p.Tag or "", { Name = "Etiquette", Size = UDim2.fromOffset(math.floor(size.X * 0.7), 16), Position = UDim2.fromOffset(9, 8),
		AnchorPoint = Vector2.zero, AlignX = Enum.TextXAlignment.Left, Max = 16, Color = p.TagColor or UI.Colors.Tag, Stroke = UI.Colors.StrokeSlot,
		Thickness = 2.4, ZIndex = z + 4 })
	tag.Visible = p.Tag ~= nil and p.Tag ~= ""
	if p.Quantity then
		UI.Text(b, p.Quantity, { Name = "Quantite", Size = UDim2.fromOffset(44, 20), Position = UDim2.new(1, -7, 0, 6), AnchorPoint = Vector2.new(1, 0),
			AlignX = Enum.TextXAlignment.Right, Max = 15, Stroke = UI.Colors.StrokeSlot, Thickness = 2.4, ZIndex = z + 4 })
	end
	if p.Top then
		UI.Text(b, p.Top, { Name = "Haut", Size = UDim2.new(1, 6, 0, 22), Position = UDim2.new(0.5, 0, 0, -13), Max = 20, Color = p.TopColor, ZIndex = z + 7 })
	end
	local coche = UI.Image(b, UI.Assets.Check, { Name = "Coche", Size = UDim2.fromOffset(38, 38), Position = UDim2.new(1, -16, 1, -16), ZIndex = z + 7 })
	coche.Visible = p.Check == true
	local cad = UI.Image(b, UI.Assets.Lock, { Name = "Cadenas", Size = UDim2.fromOffset(36, 36), Position = UDim2.new(1, -16, 1, -16), ZIndex = z + 7 })
	cad.Visible = p.Lock == true
	new("UIScale", { Name = "ButtonScale" }, b)
	b.Parent = parent
	return b
end

--[[ Product card for shop windows (617 x 168 in a 662-wide window): dark translucent interior, double frame (black outside,
	white @0.25 inside), rarity panel image on the left with the product icon, name / rarity (gradient) / stock (gradient)
	left column, description right-aligned (Montserrat Bold 21), two Glossy buy buttons bottom-right (Robux purple, cash lime).
	p: Name, Width (617), Title, Rarity ("Common".."Cosmic"), Description, Stock ("Stock x6"), Icon, Panel (image, default rarity panel),
	   Robux (number|nil), Price (string "$100"|nil), LayoutOrder ]]
function UI.ProductCard(parent, p)
	local W, H = p.Width or 617, p.Height or 168
	local r = UI.Rarities[p.Rarity or "Common"] or UI.Rarities.Common
	local c = new("Frame", { Name = p.Name or "Carte", BackgroundTransparency = 1, Size = UDim2.fromOffset(W, H), ZIndex = 2, LayoutOrder = p.LayoutOrder or 0 })
	new("Frame", { Name = "Interieur", BackgroundColor3 = UI.Colors.CardInner, BackgroundTransparency = 0.72, BorderSizePixel = 0,
		Size = UDim2.fromOffset(W - 9, H - 9), Position = UDim2.fromOffset(4, 4), ZIndex = 2 }, c)
	local bn = new("Frame", { Name = "BordNoir", BackgroundTransparency = 1, Size = UDim2.fromOffset(W, H), ZIndex = 3 }, c)
	UI.Stroke(bn, RGB(4, 4, 4), 2.5)
	local bc = new("Frame", { Name = "BordClair", BackgroundTransparency = 1, Size = UDim2.fromOffset(W - 5, H - 5), Position = UDim2.fromOffset(2, 2), ZIndex = 3 }, c)
	UI.Stroke(bc, WHITE, 2.2, 0.25)
	local panelH = H - 16
	UI.Image(c, p.Panel or r.panel, { Name = "Panneau", ScaleType = Enum.ScaleType.Stretch, Size = UDim2.fromOffset(panelH + 1, panelH),
		Position = UDim2.fromOffset(9, 8), AnchorPoint = Vector2.zero, ZIndex = 3 })
	UI.Image(c, p.Icon or "", { Name = "Icone", Size = UDim2.fromOffset(panelH - 12, panelH - 12), Position = UDim2.fromOffset(9 + panelH / 2, 8 + panelH / 2), ZIndex = 4 })
	local x = panelH + 20
	UI.Text(c, p.Title or "Product", { Name = "Nom", Size = UDim2.fromOffset(330, 36), Position = UDim2.fromOffset(x, 24), AnchorPoint = Vector2.new(0, 0.5),
		AlignX = Enum.TextXAlignment.Left, TextSize = 31, Stroke = UI.Colors.StrokeCard, Thickness = 2.8, ZIndex = 7 })
	UI.Text(c, p.Rarity or "Common", { Name = "Rarete", Size = UDim2.fromOffset(260, 30), Position = UDim2.fromOffset(x, 53), AnchorPoint = Vector2.new(0, 0.5),
		AlignX = Enum.TextXAlignment.Left, TextSize = 25, Stroke = RGB(14, 10, 24), Thickness = 2.2, Gradient = r.text, ZIndex = 7 })
	if p.Description then
		UI.Text(c, p.Description, { Name = "Description", Font = "Bold", Size = UDim2.fromOffset(430, 52), Position = UDim2.fromOffset(W - 16, 84),
			AnchorPoint = Vector2.new(1, 0.5), AlignX = Enum.TextXAlignment.Right, TextSize = 21, Stroke = UI.Colors.StrokeCard, Thickness = 2.2, ZIndex = 7 })
	end
	UI.Text(c, p.Stock or "Stock x1", { Name = "Stock", Size = UDim2.fromOffset(170, 32), Position = UDim2.fromOffset(x, H - 24), AnchorPoint = Vector2.new(0, 0.5),
		AlignX = Enum.TextXAlignment.Left, TextSize = 27, Stroke = RGB(33, 7, 0), Thickness = 2.6, Gradient = UI.TextGradients.Stock, ZIndex = 7 })
	if p.Robux then
		local br = UI.Button(c, { Name = "AchatRobux", Style = "Glossy", Theme = "robux", Size = Vector2.new(142, 49),
			Position = UDim2.fromOffset(W - 239, H - 34), ZIndex = 5 })
		UI.RobuxContent(br, p.Robux)
	end
	if p.Price then
		UI.Button(c, { Name = "AchatArgent", Style = "Glossy", Theme = "cash", Size = Vector2.new(142, 49), Position = UDim2.fromOffset(W - 85, H - 34),
			Text = p.Price, FixedTextSize = 32, ZIndex = 5 })
	end
	c:SetAttribute("Produit", p.Product or p.Name)
	c.Parent = parent
	return c
end

return UI
