--[[
	Example 05 - Collection Index with rarity tabs (archetype "grid of slots + side tab column")
		require(game.ServerStorage.StudExamples.IndexWithTabs)(UI, Icons, game.StarterGui)

	Anatomy: blue stud header (book icon), dark body with a 4-column grid of 140x126 item slots (gap 12, padding 12),
	and OUTSIDE the window on the right a column of 150x42 stud tab buttons, one per rarity (Common -> Cosmic),
	each in its rarity colors. The window is shifted 80px left (Position .5,-80) to balance the tab column.
	At runtime use StudMotion.SelectTab to tint inactive tabs and slide the active one 6px toward the window.
	Undiscovered slots: icon black (ImageColor3 0,0,0), sunburst transparency 0.8, name "???".
]]
return function(UI, Icons, parent)
	local gui = UI.ScreenGui("Index", 10, { Parent = parent })
	local win = UI.Window(gui, { Size = Vector2.new(640, 470), Position = UDim2.new(0.5, -80, 0.5, 0), Title = "Index",
		Header = "blue", Icon = Icons.Get("Item/Book/Blue Book 1st Outline") })

	local grid = UI.ScrollList(win.Corps, { Size = UDim2.fromOffset(626, 382), Position = UDim2.fromOffset(4, 4),
		Grid = Vector2.new(140, 126), GridGap = 12, PadTop = 12, PadLeft = 12 })
	local pets = { "Animal/Cat/Cat 1st Outline", "Animal/Dog/Dog 1st Outline", "Animal/Bunny/Bunny 1st Outline",
		"Animal/Cat/Golden Cat 1st Outline", "", "", "", "" }
	for i, path in pets do
		local known = path ~= ""
		local s = UI.ItemSlot(grid, { Name = "Carte_" .. i, LayoutOrder = i, Size = Vector2.new(140, 126),
			Icon = known and Icons.Get(path) or Icons.Get("Animal/Dog/Dog 1st Outline"), IconScale = 0.73,
			Title = known and (path:match("([^/]+) 1st") or "Pet") or "???", Tag = if path:find("Golden") then "GOLDEN" else nil,
			TagColor = Color3.fromRGB(255, 214, 90) })
		if not known then
			s.Icone.ImageColor3 = Color3.new(0, 0, 0)
			s.Rayons.Soleil.ImageTransparency = 0.8
		end
	end

	local tabs = UI.new("Frame", { Name = "Onglets", BackgroundTransparency = 1, Size = UDim2.fromOffset(162, 392),
		Position = UDim2.fromOffset(646, 78) }, win.Fenetre)
	local order = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Divine", "Cosmic" }
	for i, rarity in order do
		local b = UI.Button(tabs, { Name = "Onglet_" .. i, Theme = rarity, Size = Vector2.new(150, 42),
			Position = UDim2.fromOffset(83, 21 + (i - 1) * 49), Text = rarity, TextSize = 26 })
		b:SetAttribute("Categorie", rarity)
	end
	return gui, win
end
