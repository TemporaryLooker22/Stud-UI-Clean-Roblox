--[[
	Example 01 - Shop window (archetype "Nest Shop")
	Run once in Edit mode (command bar or MCP execute_luau) to generate the UI into StarterGui:
		local build = require(game.ServerStorage.StudExamples.ShopWindow)
		build(require(game.ReplicatedStorage.StudUI), require(game.ReplicatedStorage.CheckUIIcons), game.StarterGui)
	Then drive it at runtime with StudMotion (see 06_MenuController.client.luau).

	Anatomy: image header (pink stud texture) + swinging basket + "Restock" chunky orange button + X,
	timer pill straddling header/body, dark glass body, vertical list of product cards (617x168, gap 9).
]]
return function(UI, Icons, parent)
	local gui = UI.ScreenGui("MenuNestShop", 10, { Parent = parent })
	gui:SetAttribute("Boutique", "Nids")

	local win = UI.Window(gui, {
		Size = Vector2.new(662, 448),
		Title = "Nest Shop",
		Header = "image", -- pre-rendered pink stud header (UI.Assets.ShopHeader)
		Icon = UI.Assets.Basket,
	})

	-- header action: chunky orange "Restock" (146x56) left of the X
	UI.Button(win.Entete, {
		Name = "Restock", Style = "Chunky", Theme = "orange", Size = Vector2.new(146, 56),
		Position = UDim2.fromOffset(511, 36), Text = "Restock", FixedTextSize = 31, ZIndex = 8,
		Reflections = { "RestockA", "RestockB", "RestockC" },
	})

	-- timer pill centered on the header / body seam
	UI.Pill(win.Fenetre, 'New stock in <font color="#FFD23F">4:59</font>', {
		Width = 230, Height = 30, Position = UDim2.new(0.5, 0, 0, win.HeaderHeight), ZIndex = 20,
	})

	-- product list
	local list = UI.ScrollList(win.Corps, {
		Size = UDim2.fromOffset(648, 358), Position = UDim2.fromOffset(4, 4), Padding = 9, PadTop = 18, PadLeft = 13,
	})

	local products = {
		{ "Straw Nest", "Common", "Cozy straw bales with a\nlittle weathervane on top.", 14, "$100", "Item/Egg/Egg 1st Outline" },
		{ "Wood Nest", "Uncommon", "Sturdy planks and a\nturning waterwheel.", 24, "$300", "Item/Box/Box 1st Outline" },
		{ "Stone Nest", "Rare", "Solid rock walls that\nkeep eggs extra warm.", 49, "$1.2K", "Item/Chest/Chest 1st Outline" },
		{ "Gold Nest", "Legendary", "Pure gold. Eggs come out\nshinier than ever.", 199, "$85K", "Item/Crown/Crown 1st Outline" },
		{ "Cosmic Nest", "Cosmic", "Floats between the stars.\nNobody knows how.", 999, "$12M", "Nature/Planet/Golden Planet 1st Outline" },
	}
	for i, p in products do
		UI.ProductCard(list, {
			Name = "Carte_Niv" .. i, LayoutOrder = i, Title = p[1], Rarity = p[2], Description = p[3],
			Stock = "Stock x" .. (7 - i), Robux = p[4], Price = p[5], Icon = Icons.Get(p[6]), Product = "Nid_Niv" .. i,
		})
	end
	return gui, win
end
