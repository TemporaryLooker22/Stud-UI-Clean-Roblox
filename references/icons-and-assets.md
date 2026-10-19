# Icons & image assets

## 1. The icon library (`src/CheckUIIcons.luau`)

1022 HD (256 px) cartoon icons with real `rbxassetid`s, organised as `Category / Subcategory / Name`.
Categories: Animal, Currency, Exclusive, Food, Item, Main, Nature, Player, Social, UI.
Full browsable list with ids: `references/icon-catalog.md` (search it instead of opening the 130 KB Luau file).

### Install
Put `CheckUIIcons.luau` in `ReplicatedStorage` as a ModuleScript named `CheckUIIcons` (Rojo: `src/` maps directly).

### API
```lua
local Icons = require(ReplicatedStorage.CheckUIIcons)
Icons.Get("Item/Egg/Egg 1st Outline")          -- exact flat path (spaces) → "rbxassetid://95204264322969"
Icons.Get("Currency", "Robux", "Green_Robux_1st_Outline") -- nested form (underscores)
Icons.Search("robux")                           -- { {Path=..., AssetId=...}, ... }
Icons.Item.Egg.Egg_1st_Outline                  -- direct table access
```
Always pass an **exact** path to `Get`: if the path is not found it falls back to the first partial match while iterating
a hash map, which is not deterministic. Look the path up in `icon-catalog.md` first.

### Variant naming — which one to use
| Suffix | What it is | Use in this style |
|---|---|---|
| `… 1st Outline` | full-color icon with a thick dark cartoon outline | **default for everything** (buttons, headers, slots, badges). The reference game uses only Outline variants for colored icons |
| `… 1st` | full-color, no outline | only on very dark backgrounds where the outline is lost |
| `… 2nd` / `… 2nd Outline` | alternate drawing of the same object | variety (e.g. two different chests) |
| `… Black` / `… White` | flat silhouettes | `UI.OutlinedIcon` trick (Black as the 11 outline copies, White on top), tinting with ImageColor3, "undiscovered" silhouettes |
| `Golden …`, `Blue …`, `Purple …` | color variants | rarity / premium versions (Golden = premium / legendary) |

Note: `Social/Discord/*` actually contains gamepad drawings; `Social/Twitter/*` are birds.

### Icon placement rules
- Icons on buttons are **stickers**: rotated −8° (buttons), −10° (window headers), −12° (pass tracks), slightly overflowing
  the frame. Square menu tiles use an icon at 80 % of the tile width that pokes out of the top edge.
- Header icon 96 px at (−14, −14). Product icons 140 px on a 153 px rarity panel. Slot icons 62–73 % of the slot.
- `ScaleType = Fit` for icons; `Stretch` only for pre-rendered panels/headers.

### Icons used by the reference UI
| Where | Path |
|---|---|
| Shops nav button, Shop tile | Main/Shopping Cart/Red Shopping Cart 1st Outline |
| My Factory (primary nav) | Item/Egg/Egg 1st Outline |
| Pier nav, reward crates, Daily rewards | Item/Box/Box 1st Outline |
| Pass tile, Premium track, Season Pass header | Currency/Ticket/Golden Ticket 1st Outline |
| Free track | Currency/Ticket/Diamond Ticket 1st Outline |
| Rebirth tile/header, build "Rotate" | Main/Rebirth and Auto Open/Rebirth 1st Outline |
| Index tile/header | Item/Book/Blue Book 1st Outline |
| Daily Rewards header | Item/Calendar/Calendar 1st Outline |
| Robux price badge / Robux buttons | Currency/Robux/Green Robux 1st Outline |
| Money boost | Currency/Cash/Golden Cash 1st Outline ; cash packs Currency/Cash/Green Cash 1st Outline |
| Luck boost | Nature/Clover/Clover 1st Outline |
| Rebirth arrow, "Upgrade" tab | Main/Upgrade/Green Upgrade 1st Outline (tinted `#C8EBFF`, rot 90 for the arrow) |
| Claimed check | UI/Checkmark/Checkmark 1st Outline (also build "Place") |
| Locked | Item/Lock/Lock 1st Outline |
| build "Delete" / "Cancel" | Main/Trash Can/Trash Can 1st Outline / UI/X/X 1st Outline |
| Tabs All / Sell / Hatch / Sort | Main/Star/Golden Star 1st Outline / Currency/Coin/Golden Coin 1st Outline / Item/Cracked Egg/Cracked Egg 1st Outline / Main/Trade/Trade 1st Outline |
| money "+" | UI/Plus/Plus Black (outline copies) + UI/Plus/Plus White (top) |

## 2. Custom textures of the style (not in the icon library)

These are the reference creator's uploaded images. They load in experiences that can access them; if one does not load in
another place, re-upload a look-alike and replace the id in `UI.Assets` / `UI.Rarities`.

| Asset | Id | Use |
|---|---|---|
| Studs tile | rbxassetid://140544932962041 | 56×56 tile; overlay on stud buttons (gradient fade) and panels (@0.82) |
| Sunburst | rbxassetid://130563114903838 | rays behind every reward/slot icon, @0.45–0.55, spinning |
| Shop header | rbxassetid://108268925256584 | pre-rendered pink stud header for shop windows (Stretch) |
| Basket | rbxassetid://120530633952826 | shop header icon (92×76) and Robux Shop header |
| Robux coin | rbxassetid://83084350609799 | coin inside purple Glossy Robux buttons |
| Rarity panels | see design-tokens §6 | 8 pre-rendered stud squares, one per rarity |

## 3. Making a new icon fit the style
If a needed object is missing from the library, generate or draw it as: 256 px PNG, transparent background, chunky
cartoon shading (3 tones), **thick dark outline (~10 px at 256)**, slight 3/4 perspective, saturated colors. Then use it
exactly like an Outline icon (sticker rotation, Fit).
