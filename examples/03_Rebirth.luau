--[[
	Example 03 - Rebirth window (archetype "stud-header window with panels")
		require(game.ServerStorage.GlossyExamples.Rebirth)(UI, Icons, game.StarterGui)

	Anatomy: purple stud header with the rebirth icon overflowing top-left (96px, -10deg), two lime stud panels
	"current -> next" with an arrow between them, an inset "Requirements" box holding a progress bar,
	then a big green "Rebirth" stud button, "OR", and a purple "Skip" button with a Robux badge and a yellow sub-label.
]]
return function(UI, Icons, parent)
	local gui = UI.ScreenGui("MenuRebirth", 11, { Parent = parent })
	local win = UI.Window(gui, { Size = Vector2.new(600, 452), Title = "Rebirth", Header = "purple",
		Icon = Icons.Get("Main/Rebirth and Auto Open/Rebirth 1st Outline") })
	local body = win.Corps

	for i, x in { 16, 343 } do
		local p = UI.StudPanel(body, { Name = if i == 1 then "Actuel" else "Suivant", Size = UDim2.fromOffset(236, 112),
			Position = UDim2.fromOffset(x, 14), Gradient = "lime", ZIndex = 3 })
		UI.Text(p, "Rebirth " .. i, { Name = "Rang", Size = UDim2.new(1, -16, 0, 30), Position = UDim2.new(0.5, 0, 0, 24), Max = 26, ZIndex = 7 })
		UI.Text(p, "X" .. i .. " Money", { Name = "Multi", Size = UDim2.new(1, -16, 0, 56), Position = UDim2.new(0.5, 0, 0, 72), Max = 46,
			Thickness = 3.2, ZIndex = 7 })
	end
	UI.Image(body, Icons.Get("Main/Upgrade/Green Upgrade 1st Outline"), { Name = "Fleche", Size = UDim2.fromOffset(62, 62),
		Position = UDim2.fromOffset(297, 70), Rotation = 90, Color = Color3.fromRGB(200, 235, 255), ZIndex = 5 })

	local req = UI.InsetBox(body, { Name = "Conditions", Size = UDim2.fromOffset(563, 128), Position = UDim2.fromOffset(16, 140) })
	UI.Text(req, "Requirements:", { Name = "Titre", Size = UDim2.new(1, -20, 0, 28), Position = UDim2.new(0.5, 0, 0, 20), Max = 24, ZIndex = 6 })
	UI.Text(req, 'Reach <font color="#FFD23F">$25K</font> to rebirth', { Name = "Description", Size = UDim2.new(1, -24, 0, 40),
		Position = UDim2.new(0.5, 0, 0, 58), Max = 19, Rich = true, Color = Color3.fromRGB(220, 235, 245), ZIndex = 6 })
	UI.ProgressBar(req, { Name = "Barre", Size = UDim2.new(1, -28, 0, 26), Position = UDim2.new(0.5, 0, 1, -22),
		AnchorPoint = Vector2.new(0.5, 0.5), Progress = 0.48, Text = "$12K / $25K", Max = 18, ZIndex = 6 })

	UI.Button(body, { Name = "Renaitre", Theme = "green", Size = Vector2.new(236, 74), Position = UDim2.fromOffset(134, 322),
		Text = "Rebirth", TextSize = 38 })
	UI.Text(body, "OR", { Name = "Ou", Size = UDim2.fromOffset(70, 40), Position = UDim2.fromOffset(297, 322), Max = 32 })
	local skip = UI.Button(body, { Name = "Passer", Theme = "purple", Size = Vector2.new(236, 74), Position = UDim2.fromOffset(461, 322),
		Text = "Skip", TextSize = 36, TextHeight = 0.5 })
	skip.Texte.Position += UDim2.fromOffset(0, -8)
	skip.Ombre.Position += UDim2.fromOffset(0, -8)
	UI.Text(skip, "[keep your stats]", { Name = "Sous", Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0.5, 0, 1, -18), Max = 17,
		Color = Color3.fromRGB(255, 230, 90), ZIndex = 12 })
	UI.RobuxBadge(skip, 19)
	return gui, win
end
