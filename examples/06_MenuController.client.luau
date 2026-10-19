--[[
	Example 06 - Runtime controller (LocalScript placed inside a generated menu ScreenGui, e.g. MenuShop)
	Shows the standard wiring every menu of this style gets at runtime:
	  * responsive WindowScale + open/close animation, blur, FOV, other GUIs hidden (GlossyMotion.Window)
	  * sounds folder populated with the reference sound set
	  * hover / press / release on every 3D button
	  * spinning sunbursts, swinging header basket, pulsing notification badges
	  * purchase feedback: floating text + shake on refusal, faded Face for sold-out items
	  * tabs: inactive tint + 6px slide of the active tab
	Opening: fire the ScreenGui's "Basculer" BindableEvent (true / false / nil = toggle) from a HUD button.
	Tested in Play mode: open -> blur 18 / FOV +8 / other GUIs hidden, close -> everything restored.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UI = require(ReplicatedStorage:WaitForChild("GlossyUI"))
local Motion = require(ReplicatedStorage:WaitForChild("GlossyMotion"))

local gui = script.Parent
local fenetre = gui:WaitForChild("Fenetre")
local sounds = Motion.CreateSounds(gui:WaitForChild("Sons"))

local menu = Motion.Window(gui, fenetre)

-- idle motion
Motion.SpinSunbursts(fenetre, 20)
local basket = fenetre.Entete:FindFirstChild("Panier")
if basket then Motion.Sway(basket, 3, 1.6) end

-- every 3D button inside the window (the close button is already bound by Motion.Window)
for _, d in fenetre:GetDescendants() do
	if d:IsA("ImageButton") and d:FindFirstChild("ButtonScale") and d.Name ~= "Fermer" then
		Motion.BindButton(d, if d:FindFirstChild("Face") then 1.05 else 1.06, sounds)
	end
end

-- purchase buttons of product cards
local busy = false
for _, card in fenetre:GetDescendants() do
	local cash = card:IsA("Frame") and card:FindFirstChild("AchatArgent")
	if cash then
		cash.Activated:Connect(function()
			if busy then return end
			busy = true
			local ok = true -- replace with RemoteFunction:InvokeServer(card:GetAttribute("Produit"))
			busy = false
			if ok then
				Motion.Play(sounds, "Achat", 1)
				Motion.Float(cash, "+1 " .. card.Nom.Text .. "!", UI.Colors.FloatSuccess)
			else
				Motion.Play(sounds, "Refus")
				Motion.Shake(cash)
				Motion.Float(cash, "Not enough money", UI.Colors.FloatError)
			end
		end)
	end
end

-- sold-out look
local function setStock(card, n)
	card.Stock.Text = if n > 0 then "Stock x" .. n else "No Stock"
	for _, name in { "AchatRobux", "AchatArgent" } do
		local b = card:FindFirstChild(name)
		if b then UI.SetDisabled(b, n <= 0) end
	end
end
_ = setStock

-- tabs (if the window has an "Onglets" column)
local onglets = fenetre:FindFirstChild("Onglets")
if onglets then
	local tabs, base = {}, {}
	for _, b in onglets:GetChildren() do
		if b:IsA("ImageButton") then table.insert(tabs, b); table.insert(base, b.Position) end
	end
	local function choose(tab)
		Motion.SelectTab(tabs, tab, 6, base)
		local cat = tab:GetAttribute("Categorie")
		for _, c in fenetre:GetDescendants() do
			if c:GetAttribute("Categorie") and not c:IsA("ImageButton") then
				c.Visible = cat == "Tout" or c:GetAttribute("Categorie") == cat
			end
		end
	end
	for _, b in tabs do b.Activated:Connect(function() choose(b) end) end
	if tabs[1] then choose(tabs[1]) end
end

-- example: open the menu from a HUD button
-- player.PlayerGui.MenuGauche.Panneau.Shop.Activated:Connect(function() gui.Basculer:Fire() end)
_ = menu
