# Art Pack Integration — Design

Date: 2026-07-28

## Problem

`assets/` ships 67 sprites (SVG + PNG) from the "Medieval Asset Pack v2". Filenames already
match the identifiers in `data/configs/*.json`, so art can be looked up by data id. Today the
game draws everything with `draw_rect`/`draw_circle` primitives and coloured `StyleBoxFlat`
panels. A partial `ArtManager` autoload exists and is wired into the main menu, city grid and
HUD, but the remaining eight screens and the whole restaurant simulation are still primitives.

Two problems block a straight drop-in:

1. **Palette clash.** The pack is warm anime-medieval (background `#2A1B10`, panel `#EDD9A8`,
   outline `#2A1810`). `balance.json` currently themes the UI cold blue-teal (`#14222D` /
   `#203645`). Warm cel-shaded sprites on a cold slate background look pasted-on.
2. **Missing art.** The pack has no character sprites (guests, chef, waiter). Anything that
   moves on the restaurant floor still has to be drawn procedurally.

## Approach

Route every visual through `ArtManager`, re-theme to the pack palette, and upgrade the
procedural drawing that has no art to cover it so it reads as the same art direction rather
than as placeholder rectangles.

### 1. `ArtManager` (autoload)

Single lookup point. Responsibilities:

- `texture(id)` — resolve `assets/svg/<id>.svg`, fall back to `assets/png/<id>.png`, cache,
  warn once per missing id.
- `icon_rect(id, size, stretch)` / `apply_button_icon(button, id, width)` — Control helpers.
- `draw_icon(canvas, id, centre, size)` — `_draw()` helper so `Node2D` agents can use art.
- Semantic maps so data ids that have no same-named sprite still resolve: `upgrade_icon`,
  `stat_icon`, `role_icon`, `currency_icon`, `plot_icon`, `table_icon`.

SVG is the shipping format (230 KB vs 6.6 MB for the PNGs); `assets/png/` is excluded from
export. SVG imports get mipmaps enabled — sprites are authored at ~900 px and displayed at
40–260 px, and without mipmaps that downscale aliases badly.

### 2. Palette

Replace the `theme` block in `balance.json` with the pack palette, and restyle
`buildings[].color` and `crops[].color` into the same warm family. Add an `outline` key so
panels and buttons can carry the pack's `#2A1810` border, which is what visually binds flat UI
chrome to cel-shaded sprites.

### 3. Screen-by-screen

| Screen | Change |
| --- | --- |
| `base_screen` | Real toast `PanelContainer` (replaces a `set_meta("panel")` hack), outlined panel/button styles, `icon_row()` helper used by every list screen |
| `city` | Building cards rebuilt as icon-over-label cards instead of icon-left buttons |
| `restaurant_floor` | `kitchen_station`, `counter`, `entrance_door` and placed decorations drawn as sprites |
| `restaurant_table` | `table_free` / `table_reserved` / `table_occupied` / `table_waiting_for_cleaning` / `table_cleaning` by state |
| `chef_agent` / `waiter_agent` / `customer_agent` | No sprites exist. Outlined rounded bodies in palette colours, plus an art badge (`chef_speed`, `waiter_tray`, `customers`) and — for a seated guest — the icon of the dish they ordered |
| `garden` | `plot_empty` / `plot_growing` / `plot_ready` / `plot_locked` as plot backdrop, crop sprite overlaid, growth progress bar |
| `shop` | Seed/recipe/fertiliser/booster/decoration rows get their own sprite |
| `bazaar` | Crop sprite per row |
| `fairy` | Blessing sprite per row |
| `progression` | Prestige node / quest / achievement sprites |
| `office` | Role sprite per staff entry, rarity colour on the card |
| `main_menu`, `loading_screen`, `settings` | Art hero and icon-bearing buttons |

## Non-goals

- No new gameplay, balance or economy changes.
- No character sprites — the pack does not include them, and inventing them is out of scope.
- No scene-file (`.tscn`) restructuring; every screen builds its UI in `_ready()` and that
  stays.

## Verification

`Godot_v4.6.3-stable_win64.exe --headless` runs three existing suites: `tests/core_tests.tscn`,
`tests/restaurant_smoke.tscn`, `tests/scene_matrix.tscn`. All three must pass with no new
errors or warnings, and a headless editor pass must report zero script parse errors.

Those suites prove the screens instantiate; they cannot show whether the art *looks* right.
`tests/screenshots.tscn` closes that gap — it renders each screen to `tmp/screenshots/` and
runs without `--headless` because it needs a real rendering context. It forces the tutorial
closed, seeds four garden plots, and dwells sixteen seconds on the restaurant so the capture
catches a cook mid-order and occupied tables rather than an empty room.

`ArtManager` warns once per unresolved id, so a clean run with no `Missing art` output is
also proof that every id referenced across the screens actually maps to a sprite.
