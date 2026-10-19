# Layouts & screen archetypes

How screens are composed. Screenshot numbers refer to `assets/screenshots/`.

## Contents
1. ScreenGui stack (DisplayOrder, insets)
2. HUD placement
3. Window archetypes (recipes)
4. Spacing rules
5. Naming & wiring conventions

---

## 1. ScreenGui stack

| DisplayOrder | ScreenGui | Notes |
|---|---|---|
| 2 | Inventaire (hotbar) | `IgnoreGuiInset=false`, `ScreenInsets=CoreUISafeInsets` |
| 3 | Construction (build mode) | `ZIndexBehavior=Global`, CoreUISafeInsets |
| 4 | BarreHaut, HudArgent, MenuGauche | always-visible HUD |
| 5 | Survol (tooltips) | Global |
| 10 | shop windows, Index | one Fenetre each, hidden by default |
| 11 | Daily, Rebirth, Season Pass, Robux Shop | |
| 30 | TransitionUsine (full-screen fade) | never hidden by menus |
| 40 | Recompenses (reward banner) | never hidden by menus |

All: `ResetOnSpawn=false`, `IgnoreGuiInset=true` unless noted, `ScreenInsets=DeviceSafeInsets`, `ZIndexBehavior=Sibling`.
A menu ScreenGui contains: `Fenetre`, a `Sons` folder, a `Basculer` BindableEvent (open/close), a LocalScript.
`UI.ScreenGui(name, order)` creates exactly that skeleton.

## 2. HUD placement (screenshot 01, 11)

```
┌───────────────────────── [Shops 179x65][ My Factory 276x86 ][Pier 179x65] ─────────────────────────┐
│                          top-center, 4 px from top, WindowScale 0.8                               │
│ ┌Daily Rewards 220x64 (!)┐                                                     ┌ Place   ┐        │
│ ┌Shop 106┐ ┌Pass 106┐       14 px from left, vertically centered               │ Rotate  │ build  │
│ ┌Rebirth ┐ ┌Index   ┐       gaps 8 px                                           │ Shape   │ mode   │
│                                                                                │ Move    │ column │
│                                                                                │ Delete  │ 179x65 │
│ $572,831 [+]           ┌slot┐┌slot┐┌slot┐┌slot┐┌slot┐  hotbar 80x80 gap 7      │ Cancel  │ right  │
│ Friend Boost: +0%      bottom-center, 12 px above the bottom                   └─────────┘ -12px  │
└────────────────────────────────────────────────────────────────────────────────────────────────────┘
```
- Top bar: `Frame 658x86 @ (0.5,0,0,4) ap(.5,0)`, buttons centered at x = 89 / 329 / 568. The middle (primary) button is
  larger and blue; sides red and green. Each has a −8° icon sticker on the left.
- Left menu: `Frame 220x292 @ (0,14,0.5,0) ap(0,.5)`. Wide button on top with the red "!" badge on its top-right corner,
  then a 2×2 grid of square tiles (centers 53/167, 125/239) whose icon is huge (84 px) and overflows the top.
- Money: `Frame 267x90 @ (0,0,1,0) ap(0,1)`; money row at (12,12) h40 [Gotham 36 lime + 39×38 "+"]; Friend Boost at (13,58) Gotham 22;
  active boost pills (inset boxes 136×38) stack ABOVE the money (ap 0,1 at y −4).
- Build-mode column: `Frame 190x470 @ (1,-12,0.5,-10) ap(1,.5)`, stud buttons 179×65 every 113 px, icon left, label right
  (green Place, blue Rotate/Move, yellow Shape, red Delete/Cancel). Help pill: auto-width, h34, centered at y 92 under the top bar,
  RichText with `#FFD23F` for the object name and key hints in white: `Wood Conveyor <font color="#FFD23F">Straight</font>   [R] Rotate   [T] Shape   [Q] Cancel`.

## 3. Window archetypes

Every window = `UI.Window` + one body layout. Pick the closest archetype, keep its proportions.

### A. Product list shop (screens 02, 03, 04 — example 01)
662×448, image header (pink texture, basket swinging ±3°), "Restock" chunky orange + X, timer pill on the seam,
vertical list of 617×168 product cards. Variant without stock ("Upgrades Shop"): no Restock, no pill, stock line shows
"Available" (orange) / "Owned" (green) / "Locked" (gray) and owned/locked cards get `SetDisabled`.
Variant with categories ("Machine Shop"): column of 96×70 chunky tabs with icon-on-top OUTSIDE the right edge
(All purple, Sell orange, Hatch blue, Upgrade green, Sort pink). Active tab slides 6 px toward the window; others tinted.

### B. Collection grid + rarity tabs (screen 05 — example 05)
640×470 blue stud header (book icon), shifted −80 px. Body: grid of 140×126 item slots, gap 12, padding 12, 4 columns.
Right outside: 8 rarity tabs 150×42 (Common gray → Cosmic dark indigo), 49 px apart.

### C. Reward calendar (screen 06 — example 04)
800×470 blue header (calendar icon) + yellow "CLAIM ALL" with Robux badge. 3×2 grid of 184×184 stud panels
(cyan ×3, violet ×2, amber) + 198×378 rainbow hero tile. Each tile: DAY n / sunburst + icon / ITEM NAME! / state button.
Labels in UPPERCASE with "!" — this menu is the loudest.

### D. Upgrade / prestige (screen 07 — example 03)
600×452 purple header. Two lime stud panels "current → next" with a pale-blue arrow (rot 90), an inset requirements box
with a progress bar, then big CTA row: green "Rebirth" (236×74) · "OR" · purple "Skip" with Robux badge + yellow sub-label.

### E. Season pass (screen 08)
860×490 gold header (golden ticket icon) + yellow "Premium Pass" with Robux badge. Left fixed column: "Lvl." inset box,
cyan FREE stud panel, amber PREMIUM stud panel (ticket icons rot −12). Right: horizontal ScrollingFrame (scrollbar 8 px
`#FFD250`) of 112-wide level columns: number inset box + free slot 112×128 + premium slot. Bottom inset bar 843×70:
`Lvl <font color="#FFD23F">0</font>` (40), XP progress bar 330×36, purple SKIP (Robux badge), green CLAIM.

### F. Premium offers (screen 09)
760×500 pink header (basket). Vertical list (gap 14, padding 10/8, scrollbar 8 `#FF78B4`) of full-width stud-panel banners:
- Crate: cosmic gradient rot 20: big crate icon + sunburst left, "Exclusive Cosmic Crate!" title (34, outline 3.2),
  "=" then 5 content slots 86×92 with colored drop % above, purple "3 Crates" Robux button with struck old price, green "1 Crate".
- Starter pack: pink gradient rot 25, "+" then 3 slots, tilted "VALUE!" (yellow, rot −6), green Robux button.
- Boosts: blue panel with 2 inset boxes (icon 84, name, duration light-blue, green Robux button 116×52).
- Cash packs: money-green panel with 3 inset boxes (sunburst + growing cash icon, name, amount green, Robux button).
Robux buttons here use a stud button with the green robux icon on the left (`Icon = UI.Assets.RobuxIcon`).

### G. Reward banner (screen 10)
Not a window: gold stud panel 560×210 (width grows by 122 per card beyond 4) at top-center y 96, sunburst 420 @0.55 spinning
30°/s, "Reward!" title (40, outline 3.5), centered row of 112×120 reward slots (tag shows duration/quantity in `#FFE678`).
Drops in, stays 3.2 s, shrinks out (see motion reference). DisplayOrder 40.

## 4. Spacing rules

- Gaps are small and constant: 7 (hotbar), 8 (left menu, HUD rows), 9 (product list), 10 (tiles, reward cards), 12 (grids), 14 (offer banners).
- Window padding: list top 18 / left 13; grids 12; panels inside body start at 6–16 px.
- Things overlap on purpose: header icon overflows by 14 px, pill straddles the header seam, badges sit on corners,
  tab column touches the window edge, "OP"/"VALUE!" stickers rotate over edges. Overlap + rotation = playful.
- Text is centered except: window titles, product-card left column, money, HUD boost text (left) and descriptions (right).

## 5. Naming & wiring conventions

- Keep names: `Fenetre`, `Entete`, `Corps`, `LisereCorps`, `Fermer`, `Titre`, `Liste`, `Onglets`, `Carte_*`, `Case_*`,
  `Biseau`, `Face`, `Fond`, `Reflets`, `Studs`, `Texte`, `Ombre`, `Icone`, `ButtonScale`, `WindowScale`, `Sons`, `Basculer`.
- Data attributes on cards: `Produit` (inventory key), `Categorie` (for tabs), `Niveau`. Tabs carry `Categorie`.
- Open a menu from anywhere: `PlayerGui.MenuShop.Basculer:Fire()` (toggle) / `:Fire(true)` / `:Fire(false)`.
- Only one menu open at a time; opening hides every other ScreenGui except TransitionUsine and Recompenses.
