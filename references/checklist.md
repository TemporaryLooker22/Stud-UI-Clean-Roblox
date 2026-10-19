# Quality checklist & common mistakes

Run through this before calling a UI "done". Then take a screenshot and put it next to the matching reference
screenshot in `assets/screenshots/` — differences jump out immediately.

## Must-haves
- [ ] Sizes in **offset px** for a 1050×620 screen; every root has a `WindowScale` UIScale bound to the screen factor.
- [ ] Only Montserrat Heavy / GothamSSm Heavy (Montserrat Bold for descriptions). No other font or weight.
- [ ] **Every** text has a Contextual UIStroke 2–4 px in a dark *tint* of its background (not pure black, except tooltips).
- [ ] Button labels, HUD money, titles of buttons and X are **extruded** (Ombre 2 px under Texte).
- [ ] 3D buttons have all layers: outline (bg), Biseau, Face (CanvasGroup) with Fond gradient, Reflets (light + dark),
      bevel lines, LueurBas — and the Studs overlay for HUD/menu buttons. Use `UI.Button`, never a flat TextButton.
- [ ] Color semantics respected: green = money/confirm, purple = Robux/skip, red = shop/locked/destroy, blue = primary nav,
      yellow/orange = premium/claim-all/restock, gray = done.
- [ ] Icons from `CheckUIIcons`, "1st Outline" variants, rotated like stickers (−8/−10/−12°), overflowing their frame.
- [ ] Windows: stud or image header, icon overflowing top-left, Montserrat 50 title with 4 px outline, red Chunky X at W−41,
      translucent black body (@0.5) + thin white second frame (@0.62). World visible and blurred behind.
- [ ] Slots: translucent dark square, no corner, 3 px black border + light inner line, spinning sunburst behind the icon.
- [ ] Corners tiny (2–6 px) or none; only pills and badges are round.
- [ ] Motion wired: hover 1.04–1.06, press 0.92 in 0.05 s, Back-Out release, window bounce open / quick close, blur 18, FOV +8,
      sunbursts spinning, badges pulsing, sounds on hover/click/open/close/purchase/refusal.
- [ ] Prices abbreviated ($1.2K), dynamic values highlighted with `<font color="#FFD23F">`.

## Common mistakes (and why they break the style)
| Mistake | Fix |
|---|---|
| Using `UDim2.fromScale` sizes for buttons/windows | 1 px bevels and 4 px lips round differently per device; use offsets + WindowScale |
| Pure black text outline everywhere | looks like a generic "obby" UI; tint the outline with the surface hue |
| Rounded corners (12+ px) on buttons | this style is blocky; stud buttons have **no** corner, glossy ones 5, chunky 6 |
| Flat single-color buttons | the 3D lip + gradient + streaks are the identity; always build through `UI.Button` |
| Opaque dark window backgrounds | body is black @0.5 with blur behind — the world must show through |
| Icons perfectly straight and inside bounds | rotate −8°/−10° and let them overflow |
| Same reflection pattern on every button | vary presets / band positions so buttons don't look cloned |
| `TextScaled` without `UITextSizeConstraint` | giant text on big screens; always set MaxTextSize |
| Thin fonts (Regular/Medium), SourceSans, Arial | only Heavy weights |
| Forgetting `Face` as a CanvasGroup | disabled state and tab tint rely on `Face.GroupTransparency / GroupColor3` |
| Gradients with >20 keypoints | NumberSequence/ColorSequence limit is 20 — max 4 stripe bands per Reflets layer |
| Building UI at runtime every spawn | build once in Edit mode into StarterGui (ResetOnSpawn = false), animate at runtime |
| Calling `Icons.Get` with an approximate path | fuzzy fallback is non-deterministic; copy exact paths from icon-catalog.md |

## Performance notes
- This style is heavy (≈2 strokes per text, many gradients, 1 CanvasGroup per 3D button). Keep lists virtualised or capped
  (~50 cards), prefer one CanvasGroup per button only, and avoid CanvasGroups larger than the screen.
- CanvasGroup renders to a texture: never scale a button's UIScale above ~1.2 or it gets blurry.
- Run idle animations from the single RenderStepped loop in StudMotion (it skips destroyed objects).
- Mobile: at the 0.52 minimum scale, 12 px slot names become ~6 px — keep slot names ≥ 12 and use TextScaled with MinTextSize if needed.

## Verification with Roblox Studio MCP (if available)
1. Build the UI in Edit mode (execute_luau) into StarterGui.
2. Temporarily set the target `Fenetre.Visible = true` (remember the original value), `screen_capture`, compare with the
   reference screenshot, restore the original value.
3. For motion: start Play, run a client test (open/close, check `Lighting.Flou_Menu.Size == 18`, FOV +8, other GUIs hidden),
   read the console, stop Play.
