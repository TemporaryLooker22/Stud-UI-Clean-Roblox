--[[
	Example 02 - Full HUD: top navigation bar, left menu (wide button + 2x2 square tiles with notification badge),
	money counter with "+" button, friend boost line, bottom hotbar of item slots.
		require(game.ServerStorage.GlossyExamples.Hud)(UI, Icons, game.StarterGui)

	Layout rules (reference 1050x620, each root has its own WindowScale):
	  Top bar    : centered, 4px from top, scale 0.8; side buttons 179x65, center (primary) button 276x86.
	  Left menu  : 14px from left, vertically centered; wide 220x64 + 106x106 tiles, 8px gaps.
	  Money HUD  : bottom-left, 12px insets; Gotham 36 lime gradient + 39x38 "+".
	  Hotbar     : bottom-center, 12px above the bottom, 80x80 slots, 7px gap, CoreUISafeInsets.
]]
return function(UI, Icons, parent)
	-- ------------------------------------------------------------ top bar
	local top = UI.ScreenGui("BarreHaut", 4, { Parent = parent, Menu = false })
	local bar = UI.new("Frame", { Name = "Barre", BackgroundTransparency = 1, Size = UDim2.fromOffset(658, 86),
		Position = UDim2.new(0.5, 0, 0, 4), AnchorPoint = Vector2.new(0.5, 0) }, top)
	UI.new("UIScale", { Name = "WindowScale", Scale = 0.8 }, bar)
	UI.Button(bar, { Name = "Shops", Theme = "red", Size = Vector2.new(179, 65), Position = UDim2.fromOffset(89, 32),
		Text = "Shops", TextSize = 36, Icon = Icons.Get("Main/Shopping Cart/Red Shopping Cart 1st Outline"), Reflections = { "ShopsWide", "ShopsThinDark" } })
	UI.Button(bar, { Name = "MyFactory", Theme = "blue", Size = Vector2.new(276, 86), Position = UDim2.fromOffset(329, 43),
		Text = "My Factory", TextSize = 37, Icon = Icons.Get("Item/Egg/Egg 1st Outline"), Reflections = { "BlueB", "BlueDark" } })
	UI.Button(bar, { Name = "Pier", Theme = "green", Size = Vector2.new(179, 65), Position = UDim2.fromOffset(568, 32),
		Text = "Pier", TextSize = 36, Icon = Icons.Get("Item/Box/Box 1st Outline") })

	-- ------------------------------------------------------------ left menu
	local left = UI.ScreenGui("MenuGauche", 4, { Parent = parent, Menu = false })
	local panel = UI.new("Frame", { Name = "Panneau", BackgroundTransparency = 1, Size = UDim2.fromOffset(220, 292),
		Position = UDim2.new(0, 14, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5) }, left)
	UI.new("UIScale", { Name = "WindowScale" }, panel)
	local daily = UI.Button(panel, { Name = "DailyRewards", Theme = "meadow", Size = Vector2.new(220, 64), Position = UDim2.fromOffset(110, 32),
		Text = "Daily Rewards", TextSize = 30, TextThickness = 3.2 })
	UI.NotifBadge(daily)
	local tiles = {
		{ "Shop", "red", "Main/Shopping Cart/Red Shopping Cart 1st Outline", 53, 125 },
		{ "Pass", "yellow", "Currency/Ticket/Golden Ticket 1st Outline", 167, 125 },
		{ "Rebirth", "purple", "Main/Rebirth and Auto Open/Rebirth 1st Outline", 53, 239 },
		{ "Index", "blue", "Item/Book/Blue Book 1st Outline", 167, 239 },
	}
	for _, t in tiles do
		UI.Button(panel, { Name = t[1], Theme = t[2], Size = Vector2.new(106, 106), Position = UDim2.fromOffset(t[4], t[5]),
			Text = t[1], IconLayout = "Big", Icon = Icons.Get(t[3]), TextSize = 28 })
	end

	-- ------------------------------------------------------------ money HUD
	local money = UI.ScreenGui("HudArgent", 4, { Parent = parent, Menu = false })
	local hud = UI.new("Frame", { Name = "Hud", BackgroundTransparency = 1, Size = UDim2.fromOffset(267, 90),
		Position = UDim2.fromScale(0, 1), AnchorPoint = Vector2.new(0, 1) }, money)
	UI.new("UIScale", { Name = "WindowScale" }, hud)
	local row = UI.new("Frame", { Name = "LigneArgent", BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 40), Position = UDim2.fromOffset(12, 12) }, hud)
	UI.new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8),
		VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }, row)
	local amount = UI.new("Frame", { Name = "Argent", BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 40), LayoutOrder = 1 }, row)
	UI.MoneyText(amount, "$572,831")
	local slot = UI.new("Frame", { Name = "EmplacementPlus", BackgroundTransparency = 1, Size = UDim2.fromOffset(39, 38), LayoutOrder = 2 }, row)
	local plus = UI.Button(slot, { Name = "BoutonPlus", Style = "Glossy", Theme = "cash", Size = Vector2.new(39, 38), Studs = false })
	UI.OutlinedIcon(plus, UI.Assets.PlusBlack, UI.Assets.PlusWhite, { Size = UDim2.fromOffset(15, 15), Position = UDim2.fromOffset(19, 17), ZIndex = 4 })
	UI.ShadowText(hud, "Friend Boost: +0%", { Font = "Gotham", TextSize = 22, Stroke = Color3.fromRGB(24, 25, 21), Thickness = 3,
		AlignX = Enum.TextXAlignment.Left, Size = UDim2.fromOffset(240, 26), Position = UDim2.fromOffset(13, 58), AnchorPoint = Vector2.zero, ZIndex = 1 })

	-- ------------------------------------------------------------ hotbar
	local inv = UI.ScreenGui("Inventaire", 2, { Parent = parent, Menu = false, IgnoreGuiInset = false, ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets })
	local hot = UI.new("Frame", { Name = "Barre", BackgroundTransparency = 1, Size = UDim2.fromOffset(776, 167),
		Position = UDim2.new(0.5, 0, 1, -12), AnchorPoint = Vector2.new(0.5, 1) }, inv)
	UI.new("UIScale", { Name = "WindowScale" }, hot)
	UI.new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 7),
		HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Bottom, SortOrder = Enum.SortOrder.LayoutOrder }, hot)
	local items = { "Item/Egg/Egg 1st Outline", "Item/Box/Box 1st Outline", "Item/Chest/Chest 1st Outline", "Item/Magnet/Magnet 1st Outline",
		"Item/Potion/Green Potion 1st Outline", "Item/Crown/Crown 1st Outline" }
	for i, path in items do
		UI.ItemSlot(hot, { Name = "Case_" .. i, LayoutOrder = i, Size = Vector2.new(80, 80), Icon = Icons.Get(path),
			Title = (path:match("([^/]+) 1st") or "Item"), Quantity = "x" .. i, Selected = i == 2, TitleMax = 12 })
	end
	return top, left, money, inv
end
