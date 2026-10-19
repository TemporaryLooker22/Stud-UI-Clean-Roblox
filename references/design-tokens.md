# Design tokens — Stud UI Clean Roblox

Every value here was measured on the reference game (17 ScreenGuis, ~7,700 UI instances).
`src/StudUI.luau` already encodes all of them (`UI.Fonts`, `UI.Colors`, `UI.ButtonThemes`, `UI.Rarities`,
`UI.HeaderThemes`, `UI.PanelThemes`, `UI.TextGradients`, `UI.ReflectionPresets`). Use the module, and come back
here when you need to reason about a value or extend the palette.

## Contents
1. Scale & units
2. Typography
3. Text outline & extrusion rules
4. Text colors & RichText highlights
5. Button themes (4 colors each)
6. Rarity ladder
7. Header, panel and text gradients
8. Surfaces (dark glass, slots, inset boxes, pills)
9. Strokes, corners, z-index
10. Statistics of the reference UI

---

## 1. Scale & units

| Rule | Value |
|---|---|
| Reference screen | **1050 × 620** |
| Sizes / positions | **Offset pixels only** for all chrome. Scale is used only for anchors (`Position = UDim2.new(0.5, 0, 0.5, 0)`) and fills (`UDim2.fromScale(1,1)`) |
| Responsive | One `UIScale` named **`WindowScale`** per root: `Scale = size × clamp(min(vx/1050, vy/620), 0.52, 1.18)` |
| Per-root size factor | top bar `0.8`, reward banner `0.85`, everything else `1` |
| Per-button scale | one `UIScale` named **`ButtonScale`** on every clickable (hover/press only) |

Why: biseau lips of 4 px, 1 px bevel lines and 2 px outlines must stay crisp. Scale-based sizes would round them
differently on every device. A single UIScale per root keeps every proportion exact.

## 2. Typography

| Role | Font | Weight | Where |
|---|---|---|---|
| HUD / stud button labels | `GothamSSm` (`rbxasset://fonts/families/GothamSSm.json`) | **Heavy** | top bar, left menu, money, boosts, tooltips, construction buttons, LOCKED/CLAIM labels |
| Everything inside windows | `Montserrat` | **Heavy** | titles, names, prices, rarity, stock, pills, tabs, X |
| Descriptions only | `Montserrat` | **Bold** | product descriptions (the only "breathing" text) |

Usage counts in the reference: Montserrat Heavy 588, GothamSSm Heavy 100, Montserrat Bold 44. Nothing else.
Never use a Regular/Medium weight, never use SourceSans/Arial/Fredoka.

### Size scale (TextSize in px at 1050×620)
| Size | Use |
|---|---|
| 50 | window title |
| 36–38 | HUD nav labels, money counter, close "X" (38), big CTA (Rebirth 38) |
| 31–32 | product name, price on cash button, Restock, Robux number |
| 28–30 | square-tile label, wide menu button label, CLAIM ALL |
| 25–27 | rarity line, stock line, rarity tabs |
| 21–22 | description, Friend Boost, LOCKED/CLAIM on small buttons, floating feedback |
| 18 | pills (timer, build help), tab labels |
| 12–16 | slot names (12), quantities (15), tooltips (12–16), tags (16) |

Two modes coexist: fixed `TextSize` (430 labels) and `TextScaled` + `UITextSizeConstraint.MaxTextSize` (302 labels,
mostly in generated menus). Prefer fixed sizes for chrome you control; use scaled + Max for dynamic strings.

## 3. Text outline & extrusion rules

1. **Every** TextLabel has a `UIStroke` with `ApplyStrokeMode = Contextual`, `LineJoinMode = Round`.
2. Thickness: 2.0 (pills, tooltips) · 2.2 (rarity, description) · 2.4 (slots) · 2.6 (generic) · 2.8 (product name) · 3.0 (button labels) · 3.2 (big labels, X) · 3.5 (banner title) · 4.0 (window titles).
3. The outline color is **never pure black**. It is a very dark tint of the surface hue:

| Surface | Outline |
|---|---|
| red button | `#26020A` |
| blue button | `#022826` |
| green button | `#1A2402` |
| meadow (Daily) | `#0C2804` |
| yellow button | `#462800` |
| purple button | `#28003C` |
| gray button | `#282C34` |
| orange Restock | `#2F2A0A` |
| close X | `#14060A` |
| product card text | `#110D20` (indigo), rarity `#0E0A18`, stock `#210700` |
| panels / generic | `#0C141A` |
| slots | `#0A0806` |
| window title (stud header) | `#0A1628`; image header `#1A1A18` |
| money | `#0F3300` |
| pills | `#0A0C10` |
| tooltips | `#000000` (the only black, at 2 px) |

4. **Extrusion ("Ombre")**: important labels exist twice. `Ombre` = same text, `TextColor3` = outline color, same stroke,
   placed **2 px lower**, ZIndex n. `Texte` = white, ZIndex n+1. Stud buttons: Ombre at center −1, Texte at center −3.
   Chunky buttons: Ombre +1, Texte −1. Close X: X_Ombre at 0, X at −2. `UI.ShadowText` does this.

## 4. Text colors & RichText highlights

| Token | Hex | Use |
|---|---|---|
| White | `#FFFFFF` | 555 of 732 labels |
| Highlight | `#FFD23F` | dynamic value inside a sentence: `New stock in <font color="#FFD23F">4:59</font>`, `Lvl <font color="#FFD23F">0</font>` |
| Danger inline | `#FF7A7A` | `<font color="#FF7A7A">Middle-click</font> Remove` |
| Multiplier | `#FFDE50` | "x2" on boosts |
| Positive | `#60E87A` | tooltip values ("$2", "Producing") |
| Secondary | `#E2E6EC` | tooltip secondary lines |
| Tag | `#FFAAEB` | small tag top-left of slots (pink); gold variant `#FFE678`, golden `#FFD65A` |
| Robux price | `#B4FF8C` | number next to the green robux icon |
| Old price | `#FF465A` | struck-through, rotated −8°, 3 px bar |
| Sub-label yellow | `#FFE65A` | "[keep your stats]" |
| Premium label | `#FFEC78` | "PREMIUM", "DAY 7" `#FFEC78` |
| Light-blue body | `#DCEBF5` | requirement description |
| Float success / error / warn | `#B4FF3C` / `#FF6E6E` / `#FFD25A` | feedback text rising above a button |

## 5. Button themes

A 3D button is defined by four colors (`UI.ButtonThemes`). `fond` = bright face gradient (rotation 90; 28 for Glossy),
`biseau` = lip gradient, `bord` = ImageButton background (outline + dark reflection streak), `texte` = label outline & shadow.

| Theme | fond (top → bottom) | biseau | bord | texte | Used for |
|---|---|---|---|---|---|
| green | `#F3FE55` .22 `#C8FE03` .33 `#AEFF00` .8 `#48FE00` `#32FB10` | `#088306` .4 `#068A03` .7 `#108507` `#16660A` | `#0F3304` | `#1A2402` | Pier, Rebirth CTA, CLAIM, Place |
| red | `#FD027A` .49 `#FF004D` `#EF020E` | `#8C0000` .7 `#840208` `#620407` | `#2A0410` | `#26020A` | Shops, Shop tile, LOCKED, Delete, Cancel |
| blue | `#8FE3FC` .5 `#4FB4FD` .85 `#1F8EF5` `#0C78EF` | `#02447D` .6 `#014882` .8 `#064477` `#093A5A` | `#012E33` | `#022826` | My Factory (primary), Index tile, Move, Rotate |
| yellow | `#FFF082` `#FFCE32` `#FFA000` | `#AA6400` `#783C00` | `#3C2000` | `#462800` | CLAIM ALL, Premium Pass, Pass tile, Shape |
| purple | `#E282FF` `#AA3CFF` `#7814E6` | `#5A0A96` `#3C006E` | `#1E0032` | `#28003C` | Skip, Rebirth tile, Robux offers |
| gray | `#E6EAF0` `#BEC4CE` `#96A0B0` | `#5A626E` `#3C424C` | `#1E2228` | `#282C34` | CLAIMED / neutral |
| meadow | `#B2FF58` .49 `#66DE28` `#34B012` | `#227C08` `#145204` | `#0A2C02` | `#0C2804` | Daily Rewards wide button |
| orange (Chunky) | `#FEE082` .2 `#FCC861` .42 `#F1BC5C` .66 `#E9AE50` .82 `#F89C38` `#FB9030` | `#B77A08` `#7A4600` | `#4D2900` | `#2F2A0A` | Restock (header action); lueur `#FAB43C`, inner line `#FCE79A` |
| close (Chunky) | `#F96AAC` .28 `#F85A97` .55 `#F7477C` .8 `#F62C58` `#F50F22` | `#8A0A10` `#5A0404` | `#3C0A1C` | `#14060A` | X close; lueur `#FF5A62`, inner line `#F7A0CB` |
| robux (Glossy) | `#D93CEC` .35 `#C22CE8` .7 `#9C1ADF` `#7414CB` @28° | `#6A148C` `#2C003C` | `#2A0731` | — | Robux buy button in cards; liseré gradient `#EAA6F4`→`#E2AAD6`, lueur `#F0B2EA` |
| cash (Glossy) | `#EEFB3A` .35 `#C6FB20` .7 `#92F716` `#62EC12` @28° | `#3FA40A` `#1C6206` | `#2B3400` | `#14170D` | $ buy button in cards, money "+"; liseré `#F8FB9E`→`#B6FB6A`, lueur `#B4FB70` |

Semantics (keep them): **green = in-game money / confirm**, **purple = Robux / skip**, **red = shop / locked / destroy**,
**blue = primary navigation**, **yellow/orange = premium / restock / claim all**, **gray = done**.

## 6. Rarity ladder (`UI.Rarities`)

| Rarity | Label gradient | Tab fond (top/.49/bottom) | Tab bord | Panel image |
|---|---|---|---|---|
| Common | `#D9D7E3`→`#ADA6B4` | `#ECEEF2` `#C6C8D0` `#A0A3AC` | `#282A30` | `rbxassetid://89267995407736` |
| Uncommon | `#C4F79A`→`#43C22E` | `#B0FF70` `#68E22A` `#3ABE14` | `#0E3204` | `131137889121430` |
| Rare | `#84CAE8`→`#3D8EE0` | `#7EDAFF` `#34A6FF` `#1476F0` | `#041E46` | `105083838865206` |
| Epic | `#E2B0FF`→`#9A3EF0` | `#DE92FF` `#AC48FF` `#801EEC` | `#220446` | `101084229455301` |
| Legendary | `#FFE27A`→`#F5A215` | `#FFEC60` `#FFB61E` `#FA800A` | `#462200` | `86850543324255` |
| Mythic | `#FF9AB0`→`#EE2F57` | `#FF7C9A` `#FF2A5C` `#E20A34` | `#3C000E` | `135658280761682` |
| Divine | `#A8FFF0`→`#17C4B0` | `#B0FFF0` `#3EE6D4` `#14BCB2` | `#002C2C` | `71658771409468` |
| Cosmic | `#CDBCFF`→`#6A45F5` | `#7662B6` `#402C80` `#20144A` | `#080414` | `121878407812617` |

Panel images are pre-rendered stud squares in the rarity color (used at 153×152 behind the product icon).
Drop-chance colors above crate contents: `#FFFFFF`, `#8CFF78`, `#FFAA3C`, `#FF5A5A`, `#FF78FF`.

## 7. Header, panel and text gradients

**Window headers** (`UI.HeaderThemes`, vertical): blue `#7CD6FF #3AA6FF #1A70EE` (Index, Daily) · purple `#CE78FF #963CF0 #691EC8` (Rebirth) ·
gold `#FFDE50 #FFAA1E #F5780A` (Season Pass) · pink `#FF64B4 #FF286E #E1143C` (Robux Shop). Shops use the image header
`rbxassetid://108268925256584` (pink stud texture) on an 81 px header.

**Stud panels** (`UI.PanelThemes`): cyan `#00D2FF→#0078FF` · violet `#B020FF→#7000E0` · amber `#FFAA00→#E06000` ·
lime `#C8FF3C→#50D200` · pink `#FF8CDC #C83CFF #8C28E6` (rot 25) · cosmic `#823CFF #FF3CB4 #FFAA28` (rot 20) ·
blue `#5AAAFF→#1E5AE6` · money `#78E66E→#1E963C` · gold `#FFDE50→#FF9614` (reward banner) · rainbow 7 stops (rot 45, hero tile).

**Text gradients** (`UI.TextGradients`, rotation 90): money `#C0FF05 .4 #A4FF01 .75 #6FFF00 #52F90A` · robux number
`#C2FB18→#58F908` · stock/available `#F8C32A→#E58515` · owned `#C4F79A→#43C22E` · locked `#D9D7E3→#9691A0` ·
progress fill `#FFD228→#FF7800` · notification `#FF5260→#DE0A22`.

## 8. Surfaces

| Surface | Background | Stroke | Inner line | Corner |
|---|---|---|---|---|
| Window body (`Corps`) | `#000000` @0.50 | `#020403` 2 Border | `LisereCorps` white 1.5 @0.62 (separate frame) | 2 |
| Header plate (`Entete`) | `#070505` | — | face inset 2 px | 4 |
| Product card | `#1E2226` @0.72 inset 4 | BordNoir `#040404` 2.5 | BordClair white 2.2 @0.25 inset 2 | 0 |
| Item slot | `#141210` @0.35 | Bord `#040302` 3 | Trait `#EBE8E4` 1.4 @0.15 inset 4 (+ Selection `#B4FF19` 3, disabled) | **0** |
| Inset box | `#141E24` @0.10 (0.15–0.25 variants) | `#080C0E` 2.5 | `#4B7D91` 1.2 @0.45 inset 2 | 6 (inner 4) |
| Progress track | `#0E161A` | `#080C0E` 2.5 | `#4B7D91` 1.2 @0.45 | 6; fill corner 5, gloss strip white @0.55 top 28% |
| Pill | `#1C242C` | `#0A0C10` 2.5 | `#6E8CA5` 1.2 @0.35 | height/2 (15 / 17) |
| Stud panel | white + gradient | `#0C141A` 3 | white 1.4 @0.35 inset 2.5 (Contextual) | 6 (inner 4) |
| Notification badge | gradient `#FF5260→#DE0A22` | `#1E040A` 2.6 | — | full circle |

The world stays visible behind windows: transparent body + `BlurEffect` "Flou_Menu" at 18 + FOV +8 while a menu is open.

## 9. Strokes, corners, z-index

- UIStroke thickness distribution: 3 (325) · 2.4 (214) · 2.6 (179) · 2.2 (176) · 1.4 (123) · 1 (116) · 1.5 (115) · 2.5 (101).
- Border-mode strokes = frames; Contextual-mode = text and inner lines of panels.
- Corners are tiny: 3 px (197), 2 (116), 4 (103), 5 (90), 6 (76). Round only: pills (13–17) and badges (`UDim.new(1,0)`).
  **Stud buttons and item slots have no UICorner at all** — sharp, blocky.
- ZIndex inside a component stays within 1–12: Fond 1 · Biseau/Face 2 · Reflets 5 · Studs 6 · bevels/LueurBas 8 ·
  Icone 8 · Ombre 9 · Texte 10 · header Titre 11 · header Icone 12. Overlays (pills, tabs) 20+, reward banner 50–56.
- `ZIndexBehavior = Sibling` everywhere except tooltips & build mode (`Global`).

## 10. Statistics of the reference UI (for sanity checks)

1688 Frame · 1507 UIStroke · 904 UIGradient · 732 TextLabel · 633 ImageLabel · 592 UICorner · 302 UITextSizeConstraint ·
277 UIScale · 257 ImageButton · 155 CanvasGroup · 82 Sound. A UI in this style is **stroke- and gradient-heavy**:
roughly 2 strokes per text, 1.3 gradients per button layer. If your output has few strokes/gradients, it is not this style.
