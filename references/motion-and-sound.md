# Motion & sound

All values come from the reference game's LocalScripts and are implemented in `src/StudMotion.luau`.
The feel of this style is: **instant press, springy release, bouncy open, fast close, things always slightly moving.**

## Buttons (`Motion.BindButton(button, hover, sounds)`)

| Event | Tween on `ButtonScale` | Sound |
|---|---|---|
| MouseEnter | → `hover` in 0.08 s Quad Out | "Survol" |
| MouseLeave | → 1 in 0.08 s Quad Out | — |
| MouseButton1Down | → **0.92** (HUD 0.94) in **0.05 s** Quad Out | "Clic" |
| MouseButton1Up | → hover (if still over) or 1 in **0.12 s Back Out** | — |

Hover factors: HUD bars 1.04 · menu buttons/tabs 1.05 · close X and slots 1.06.
Scale is always centered (AnchorPoint 0.5,0.5 on buttons) so nothing shifts.

## Windows (`Motion.Window(gui, fenetre)`)

| Phase | What happens |
|---|---|
| Open | sound "Ouverture"; hide every other ScreenGui (except TransitionUsine, Recompenses) and CoreGui (PlayerList, Chat, Backpack, Emotes, Health); `Fenetre.Visible = true`; scale factor 0.86 → 1 in **0.32 s Back Out**; position from +24 px → home in 0.32 s Quint Out; `Lighting.Flou_Menu` BlurEffect 0 → **18** in 0.3 s; camera FOV + **8** in 0.45 s Quad Out |
| Close | sound "Fermeture" at pitch 0.82; factor → 0.88 and +18 px in **0.16 s Quad In**; blur → 0 in 0.28 s; FOV back in 0.4 s; hide after 0.16 s; restore GUIs |
| Inputs | X button, Escape, gamepad ButtonB, respawn → close. Opening another menu closes the current one |
| Scale | `WindowScale.Scale = screenScale × animFactor` — both multiply, so the bounce works at every resolution |

Proximity-opened shops: a ground circle opens the menu when the character enters (radius ~3.6, +0.6 hysteresis) and
closes it when leaving; after a manual close the player must leave and re-enter.

## Idle motion (always running while visible)

| Element | Motion |
|---|---|
| Sunbursts ("Soleil") | rotate 20°/s, neighbours alternate direction; reward banner 30°/s |
| Shop header basket | rotation = base + 3·sin(1.6 t) |
| Notification "!" badge | Pulse scale = 1 + 0.08·max(0, sin(4 t)) |
| Claimable slot | Selection stroke thickness = 2.2 + 1.2·sin(6 t) |
| Rainbow items | sunburst color cycles through hues |

## Feedback

| Event | Effect |
|---|---|
| Purchase OK | sound "Achat"; floating text "+1 Straw Nest!" `#B4FF3C` rising 20–28 px and fading in 0.7–0.9 s |
| Refused | sound "Refus"; button shakes −5, +5, −3, +3, 0 px every 0.04 s; floating text in `#FF6E6E` ("Not enough money", "Sold out", "Buy X first", "Already owned") |
| Coming soon | floating text `#FFD25A` |
| New slot | pop-in UIScale 0.4 → 1, 0.35 s Back Out, sound "Carte" |
| Tab change | 0.15 s Quad Out: inactive tabs `GroupColor3/BackgroundColor3/ImageColor3 = #9696A6`, label `#D6D6E0`; active slides 6 px |
| Reward banner | sound "Achat"; UIScale screen×0.6 → ×0.85 (0.35 s Back Out) while dropping 40 px (Quint Out); wait 3.2 s; → ×0.5 (0.2 s Quad In), hide; queue the next one |
| Area change | full-screen black frame fade in (Quad In) / out (Quad Out) |

## Sounds (`Motion.SOUNDS`, `Motion.CreateSounds(gui.Sons)`)

| Name | SoundId | Volume | Speed |
|---|---|---|---|
| Survol (hover) | rbxassetid://6895079853 | 0.5 | 1 |
| Clic | rbxassetid://103866342467024 | 0.5 | 1 |
| Ouverture | rbxassetid://109359226723492 | 0.6 | 1 |
| Fermeture | rbxassetid://117813075686953 | 0.45 | 0.82 |
| Achat | rbxassetid://1319346243 | 0.55 | 1 |
| Carte | rbxassetid://109359226723492 | 0.18 | 1.6 |
| Refus | rbxasset://sounds/clickfast.wav | 0.4 | 1 |
| build: Pose / Retrait / Refus | rbxasset://sounds/switch.wav (0.9) / snap.mp3 (0.8) / clickfast.wav (0.6) | 0.35–0.5 | |

## Formatting helpers

- `Motion.Abbreviate(1234) → "$1.2K"`, `85000 → "$85K"`, `12000000 → "$12M"` (K/M/B/T, one decimal under 100, no ".0").
- `Motion.Duration(3723) → "1:02:03"`, `299 → "04:59"`.
- Money in the HUD keeps full digits with commas ("$572,831"); prices are abbreviated.
