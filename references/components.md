# Components — exact anatomy

Each section gives: what it is, the `StudUI` call that builds it, and the instance tree with geometry
(`Size @ Position`, offsets in px, `ap` = AnchorPoint, `z` = ZIndex). Instance names are the reference game's
French names — keep them, runtime scripts look them up by name.

## Contents
1. Stud button (HUD / menu / action) — `UI.Button` Style "Stud"
2. Glossy button (purchase in cards) — Style "Glossy"
3. Chunky button (header actions, close, tabs) — Style "Chunky", `UI.CloseButton`
4. Reflections ("Reflets") — the glass streak technique
5. Window — `UI.Window`
6. Product card — `UI.ProductCard`
7. Item slot / reward card — `UI.ItemSlot`
8. Stud panel — `UI.StudPanel`
9. Inset box, progress bar, pill — `UI.InsetBox`, `UI.ProgressBar`, `UI.Pill`
10. Badges & small parts — `UI.RobuxBadge`, `UI.RobuxContent`, `UI.NotifBadge`, `UI.OutlinedIcon`, `UI.MoneyText`
11. Tooltip
12. Button state triad

---

## 1. Stud button

`UI.Button(parent, { Theme = "green", Size = Vector2.new(179, 65), Text = "Pier", Icon = id, TextSize = 36 })`

```
ImageButton  179x65  bg = theme.bord (2px visible outline)  AutoButtonColor=false  NO UICorner
├ Biseau        Frame (1,-4)x(0,4) @ (0,2)(1,-6)  z2   white + UIGradient(theme.biseau, 90)     ← the thickness
│               (height ≥ 80: lip 6 px, face (1,-10))
├ Face          CanvasGroup (1,-4)x(1,-8) @ (2,2)  z2  ClipsDescendants
│  ├ Fond          Frame full  z1  white + UIGradient "Degrade"(theme.fond, 90)
│  ├ Reflets       Frame full  z5  WHITE bg + stripes gradient (preset StudWide, 60.57°)
│  ├ Reflets       Frame full  z5  bg = theme.reflet (dark) + stripes (StudThinDark)   ← dark streak
│  ├ Studs         ImageLabel full z6  140544932962041 Tile 56x56, UIGradient T{0:1, .55:.9, 1:.45} rot 55
│  ├ LiseréInterne1 Frame (1,-2) centered z8  UIStroke white 1 @0.30 Border
│  ├ LiseréInterne2 Frame (1,-4) centered z8  UIStroke white 1 @0.72 Border
│  └ LueurBas      Frame (1,0)x(0,2) @ bottom ap(0,1) z8 white @0.60
├ Icone         ImageLabel 0.74h square @ (0.58h, 0.5,-2) rot -8 z8  Fit   ← tilted sticker icon
├ Ombre         TextLabel z9  text color = theme.texte, stroke theme.texte 3, Gotham Heavy, center -1
├ Texte         TextLabel z10 white, stroke theme.texte 3, center -3
└ ButtonScale   UIScale
```

Text area: with an icon, label starts at `1.05·h` and is centered in the remaining width; without, centered (w-18).
Layouts: `IconLayout = "Left"` (default, HUD bars), `"Big"` (106×106 menu tiles: icon 0.8·w at y = 0.38·h, label on the
bottom edge, size 28), `"Top"` (96×70 tabs: icon 40 px at y = 24, label 18 at bottom).
Primary action = bigger button (276×86 vs 179×65, icon 64 vs 50), never a different style.

## 2. Glossy button (purchase inside cards)

`UI.Button(card, { Style = "Glossy", Theme = "cash", Size = Vector2.new(142, 49), Text = "$100", FixedTextSize = 32 })`

```
ImageButton 142x49 bg bord, UICorner 5
├ Biseau   (1,-4)x(0,8) @ (2, h-10), corner 3, gradient biseau
├ Face     CanvasGroup (1,-4)x(1,-7) @ (2,2), corner 3
│  ├ Fond         gradient fond rotated **28°** (diagonal)
│  ├ Brillance    top 55% white, transparency 0.80/0.82 → 1 (classic gloss)
│  ├ Reflets      Glossy preset (62.2°) z3
│  ├ LisereInterne1  inset 2, corner 2, UIStroke 1.5 white + UIGradient tint (liserE)
│  └ LueurBas     2 px, theme.lueur @0.20
├ Texte    Montserrat Heavy 32, stroke theme.texte 2.6 (no Ombre)
└ ButtonScale
```
Robux variant: `Theme = "robux"`, no Text, then `UI.RobuxContent(button, 14)` (coin 36 px + green-gradient number 31).

## 3. Chunky button (header actions, close, category tabs)

```
ImageButton bg bord, UICorner 6
├ Biseau (1,-4)x(0,10) @ (2, h-12), corner 4
├ Face   CanvasGroup (1,-4)x(1,-8), corner 4
│  ├ Fond (90°) ; Reflets ×1–3 (Close / RestockA,B,C) z2
│  ├ LueurBas 3 px theme.lueur @0.25
│  ├ LisereInterne1 inset 2 corner 3 stroke theme.liserE 1.5 @0.10
│  └ LisereInterne2 inset 5 corner 2 stroke white 1 @0.70
├ Ombre/Texte Montserrat Heavy (Ombre +1, Texte -1)
```
- Restock: 146×56, theme orange, text 31.
- Close: `UI.CloseButton(entete, {Position = UDim2.fromOffset(W-41, 37)})` — 55×55, "X" Montserrat 38, outline 3.2 `#14060A`.
- Category tab (machine shop): 96×70, icon on top (`IconLayout = "Top"`), label 18, stacked vertically at x = window right + gap.

## 4. Reflections ("Reflets")

A white full-size Frame whose UIGradient has a **transparency sequence with hard edges**: it stays at 1 (invisible)
then jumps to ~0.74–0.93 for a thin band, and back to 1, at nearly the same time value (Δ 0.001). Rotated ~60°.
That draws crisp diagonal glass streaks with zero images. A second layer with a dark background color
(theme.bord / black) draws a shadow streak. Each button uses a different band pattern so they never look cloned.

`UI.Stripes({{from, to, alpha}, ...})` builds the NumberSequence (max 4 bands = 18 keypoints, limit is 20).
Presets in `UI.ReflectionPresets`: StudWide, StudThinDark, ShopsWide, ShopsThinDark, BlueA, BlueB, BlueDark, Glossy,
HeaderFine, HeaderFineDark, Close, RestockA/B/C. Make your own by varying band positions in 0.25–0.75 and rotation 25–80°.

## 5. Window

`local win = UI.Window(gui, { Size = Vector2.new(W, H), Title = "Index", Header = "blue", Icon = id })`
returns `{ Fenetre, Entete, Corps, Fermer, Titre, Icone, WindowScale, HeaderHeight }`.

```
Fenetre  W x H  @ (0.5,0.5) ap(.5,.5)  Visible=false   + UIScale "WindowScale"
├ Corps        (W-5) x (H-Hh-2) @ (2, Hh)  #000 @0.5  corner 2  stroke #020403 2
├ LisereCorps  (W-9) x (H-Hh+17) @ (3, Hh-21)  stroke white 1.5 @0.62   ← thin 2nd frame peeking out
└ Entete       W x Hh  #070505 corner 4  z4
   ├ Face      (W-4)x(Hh-4) @ (2,2)  CanvasGroup: Fond (header gradient) + Reflets HeaderFine/Dark + Studs + 2 bevels + LueurBas
   │           (shops: ImageLabel 108268925256584 stretched instead)
   ├ Icone     96x96 @ (-14,-14) rot -10 z12   ← overflows the top-left corner (shops: "Panier" 92x76 @ (-5,1))
   ├ Titre     340x60 @ (86, 39) ap(0,.5) Montserrat Heavy 50, outline 4
   ├ [actions] Chunky / Stud buttons right-aligned before the X (CLAIM ALL 214x54, Premium Pass 230x54, Restock 146x56)
   └ Fermer    55x55 @ (W-41, 37)
```
Hh = 78 (stud header) or 81 (image header). Reference sizes: shops 662×448, Index 640×470, Daily 800×470,
Rebirth 600×452, Season Pass 860×490, Robux Shop 760×500.
Optional timer pill centered on the seam: `UI.Pill(win.Fenetre, text, {Width = 230, Position = UDim2.new(.5,0,0,Hh)})`.
Side tab column lives **outside** the window on the right (x = W+6) and the window is shifted left (`Position .5,-80`).

## 6. Product card

`UI.ProductCard(list, { Title, Rarity, Description, Stock, Icon, Robux = 14, Price = "$100" })` → 617×168 in a 662 window.

```
Frame 617x168 (transparent)
├ Interieur  608x159 @ (4,4) #1E2226 @0.72
├ BordNoir   617x168 stroke #040404 2.5
├ BordClair  612x163 @ (2,2) stroke white 2.2 @0.25
├ Panneau    153x152 @ (9,8) rarity panel image (Stretch)
├ Icone      140x140 centered on the panel
├ Nom        @ (172, 24) ap(0,.5) Montserrat 31, outline #110D20 2.8
├ Rarete     @ (172, 53) 25, rarity gradient, outline #0E0A18 2.2
├ Description @ (601, 84) ap(1,.5) right-aligned Montserrat **Bold** 21, outline #110D20 2.2, 2 lines max
├ Stock      @ (172, 144) 27, gradient #F8C32A→#E58515, outline #210700 2.6   ("Stock x6" / "No Stock" / "Available" / "Owned" / "Locked")
├ AchatRobux Glossy robux 142x49 @ (378,134)
└ AchatArgent Glossy cash 142x49 @ (532,134)
```
List: ScrollingFrame 648×358 @ (4,4), UIListLayout gap 9, padding top 18 left 13, scrollbar 6 white, AutomaticCanvasSize Y.
Sold out / locked: `Face.GroupTransparency = 0.45` on both buy buttons (`UI.SetDisabled`).

## 7. Item slot / reward card

`UI.ItemSlot(parent, { Size = Vector2.new(80,80), Icon, Title, Quantity = "x1", Tag, Top = "60%", Check, Lock, Selected })`

```
ImageButton 80x80  #141210 @0.35  NO corner
├ UIStroke "Bord"   #040302 3 Border
├ Lisere   (1,-8) centered: UIStroke "Trait" #EBE8E4 1.4 @0.15 + UIStroke "Selection" #B4FF19 3 (Enabled when selected)
├ Rayons   (1,-6) centered, ClipsDescendants → Soleil 1.6x @ (.5,.42) transparency 0.45, spins 20°/s
├ Icone    0.62·min(w,h) @ (.5, .5, -6%)
├ Nom      bottom (1,-8)x18% @ (.5,1,-5) ap(.5,1)   outline #0A0806 2.4
├ Quantite top-right "x1" (15)          Etiquette top-left (16, pink #FFAAEB)
├ Coche / Cadenas 38/36 px bottom-right (hidden)
└ ButtonScale
```
Sizes: hotbar 80×80 (gap 7), reward card 112×120, pass 112×128, index 140×126, crate content 86×92.
Undiscovered: icon `ImageColor3 = 0,0,0`, sunburst transparency 0.8, name "???". Golden: sunburst `#FFC83C` @0.25.
Claimable: Selection enabled and its Thickness pulses `2.2 + 1.2·sin(6t)`.

## 8. Stud panel

`UI.StudPanel(parent, { Size, Position, Gradient = "cyan", Rotation = 90 })`:
white Frame + gradient "Degrade", corner 6, stroke `#0C141A` 3, `Studs` flat tile @0.82 inset 2, `Lisere` inset 2.5 corner 4
white 1.4 @0.35 Contextual. Content: big title (outline 3), spinning sunburst @0.55 behind a big icon, name, state button.
Daily tile 184×184 (gap 10), hero tile 198×378 rainbow rot 45 + "OP" sticker (pink, rot 18), rebirth card 236×112 lime,
shop offer banner 725×~220 (cosmic rot 20 / pink rot 25 / blue / money), reward banner 560×210 gold.

## 9. Inset box, progress bar, pill

- `UI.InsetBox` — recessed dark box (see tokens §8). Holds "Lvl." headers (112×38), requirements (563×128), HUD boosts
  (136×38: icon 32 + "x2" yellow + timer), bottom bars (843×70), shop sub-boxes (transparency 0.25).
- `UI.ProgressBar` — track 26–36 px high, fill `Remplissage` scale-X = progress, gradient gold→orange, gloss strip,
  centered value text ("$12K / $25K", "0/100 XP").
- `UI.Pill` — fixed width (timer 230×30) or auto width (build help: height 34, padding 18, text 18; hint: 28, padding 10, text 15).

## 10. Badges & small parts

- `UI.RobuxBadge(button, 49, oldPrice?)` — 74×30 frame at the button's top-right corner `(1,-24,0,0) ap(.5,.5)`, z20:
  green robux icon 28 + `#B4FF8C` price. Old price: red `#FF465A`, rot −8, 3 px strike bar, top-left.
- `UI.NotifBadge(button)` — 28 px red circle at `(1,-4,0,4)`, "!" Gotham 22, UIScale "Pulse" (1 + 0.08·max(0, sin 4t)).
- `UI.OutlinedIcon(parent, darkImg, whiteImg)` — ImageLabels can't have strokes: 11 dark copies offset ±1 px (+3 px below)
  + grey "Tranche" at +1 + white icon on top. Used for the money "+".
- `UI.MoneyText(frame, "$572,831")` — Gotham 36, gradient lime, outline `#0F3300` 3, extruded 2 px, AutomaticSize X,
  followed in a horizontal UIListLayout (gap 8) by a 39×38 Glossy cash "+" button.

## 11. Tooltip (hover over world objects)

No background at all. Vertical UIListLayout (padding 1) of GothamSSm Heavy labels with a pure black 2 px outline:
title 16 white, secondary 12 `#E2E6EC`, value/state 13–14 `#60E87A`. ScreenGui `ZIndexBehavior = Global`, follows the
mouse and is clamped to the viewport; a `Highlight` outlines the hovered object.

## 12. Button state triad (claim flows)

| State | Theme | Label | Extra |
|---|---|---|---|
| Claimable | green | CLAIM | slot Selection stroke pulses |
| Claimed | gray | CLAIMED | check icon `Coche` visible |
| Locked | red | LOCKED | lock icon `Cadenas` visible on slots |
| Skip (paid) | purple | SKIP | `UI.RobuxBadge` with the price |
| Unavailable / sold out | (unchanged) | — | `UI.SetDisabled(button, true)` → face @0.45 |
