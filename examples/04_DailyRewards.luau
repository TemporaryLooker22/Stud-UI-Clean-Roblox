--[[
	Example 04 - Daily Rewards (archetype "grid of colored stud tiles + one hero tile")
		require(game.ServerStorage.StudExamples.DailyRewards)(UI, Icons, game.StarterGui)

	Anatomy: blue stud header with a calendar icon, yellow "CLAIM ALL" stud button with a Robux badge in the header,
	3x2 grid of 184x184 stud panels (cyan, cyan, cyan, violet, violet, amber) + a 198x378 rainbow hero tile (rotation 45)
	for day 7 with a tilted pink "OP" sticker. Each tile: "DAY n", spinning sunburst behind the reward icon, name, and a
	state button (red LOCKED / green CLAIM / gray CLAIMED). Gaps: 10px.
]]
return function(UI, Icons, parent)
	local gui = UI.ScreenGui("MenuDaily", 11, { Parent = parent })
	local win = UI.Window(gui, { Size = Vector2.new(800, 470), Title = "Daily Rewards", Header = "blue",
		Icon = Icons.Get("Item/Calendar/Calendar 1st Outline") })
	local claimAll = UI.Button(win.Entete, { Name = "ToutReclamer", Theme = "yellow", Size = Vector2.new(214, 54),
		Position = UDim2.fromOffset(800 - 41 - 46 - 107, 37), Text = "CLAIM ALL", TextSize = 28, ZIndex = 9 })
	UI.RobuxBadge(claimAll, 49)

	local grid = UI.new("Frame", { Name = "Jours", BackgroundTransparency = 1, Size = UDim2.fromOffset(782, 378),
		Position = UDim2.fromOffset(6, 6), ZIndex = 2 }, win.Corps)
	local colors = { "cyan", "cyan", "cyan", "violet", "violet", "amber" }
	-- state per day: "claimed" | "claim" | "locked"
	local states = { "claimed", "claim", "locked", "locked", "locked", "locked", "locked" }
	local reward = Icons.Get("Item/Box/Box 1st Outline")
	for d = 1, 7 do
		local hero = d == 7
		local col, row = (d - 1) % 3, (d - 1) // 3
		local tile = UI.StudPanel(grid, {
			Name = "Jour_" .. d, ZIndex = 3,
			Size = if hero then UDim2.fromOffset(198, 378) else UDim2.fromOffset(184, 184),
			Position = if hero then UDim2.fromOffset(584, 0) else UDim2.fromOffset(col * 194, row * 194),
			Gradient = if hero then "rainbow" else colors[d], Rotation = if hero then 45 else 90,
		})
		UI.Text(tile, "DAY " .. d, { Name = "Jour", Size = UDim2.new(1, -12, 0, if hero then 52 else 34),
			Position = UDim2.new(0.5, 0, 0, if hero then 34 else 22), Max = if hero then 46 else 30, Thickness = 3, ZIndex = 7,
			Color = if hero then Color3.fromRGB(255, 236, 120) else Color3.new(1, 1, 1) })
		UI.Sunburst(tile, if hero then 230 else 150, { Position = UDim2.fromScale(0.5, if hero then 0.42 else 0.47), ZIndex = 4 })
		UI.Image(tile, reward, { Name = "Icone", Size = UDim2.fromOffset(if hero then 140 else 78, if hero then 140 else 78),
			Position = UDim2.fromScale(0.5, if hero then 0.42 else 0.47), ZIndex = 6 })
		UI.Text(tile, "ITEM NAME!", { Name = "Nom", Size = UDim2.new(1, -14, 0, if hero then 56 else 24),
			Position = UDim2.new(0.5, 0, 1, if hero then -112 else -60), Max = if hero then 30 else 20, ZIndex = 7 })
		local st = states[d]
		UI.Button(tile, { Name = "Bouton", ZIndex = 8,
			Theme = if st == "claim" then "green" elseif st == "claimed" then "gray" else "red",
			Text = if st == "claim" then "CLAIM" elseif st == "claimed" then "CLAIMED" else "LOCKED",
			Size = if hero then Vector2.new(174, 52) else Vector2.new(162, 42),
			Position = UDim2.new(0.5, 0, 1, if hero then -36 else -28), TextSize = if hero then 28 else 22 })
		if hero then
			UI.Text(tile, "OP", { Name = "OP", Size = UDim2.fromOffset(80, 50), Position = UDim2.new(1, -8, 0, -8), Rotation = 18, Max = 44,
				Color = Color3.fromRGB(255, 120, 150), Thickness = 3.5, ZIndex = 10 })
		end
	end
	return gui, win
end
