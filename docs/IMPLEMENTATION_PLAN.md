# Restaurant Empire — Implementation Plan

## Source

The implementation follows all four volumes in `Restaurant Empire biblie.docx`.
The complete document was read: 137 paragraphs and 3 content tables. Target:
Godot 4.6.3, GDScript, Android landscape, scalable 1920×1080 UI and the GL
Compatibility mobile renderer.

## Architecture

- Independent screens coordinated by `SceneManager`.
- Persistent state owned by `GameManager`.
- Currency mutations routed only through `EconomyManager`.
- Event signals decouple UI and simulations.
- JSON balance/content loaded and validated at startup.
- Versioned save, backup, migration, autosave and lifecycle save.
- Offline arithmetic capped at eight hours.
- Restaurant finite-state machines and pooled customers.
- Placeholder visuals generated in Godot and separate from logic.

## Delivery stages

- [x] Stage 1: read GDD, verify Godot and define central data.
- [ ] Stage 2: boot, menu, city, navigation and save.
- [ ] Stage 3: complete restaurant vertical slice.
- [ ] Stage 4: garden, fertilisers, Bazaar and Shop.
- [ ] Stage 5: House/offline, Fairy and Employment Office.
- [ ] Stage 6: upgrades, settings, HUD and debug tools.
- [ ] Stage 7: tests, optimisation, docs and final runtime QA.

## Prototype assumptions

- Burger, Fries and Salad are initially unlocked.
- Twelve garden plots are visible; six begin unlocked and six come from upgrades.
- Ingredient cost is deducted as operating cost; crop stock remains optional in
  this prototype so the core restaurant loop cannot deadlock.
- Straight-line movement is used on the obstacle-free placeholder floor. Actor
  FSM APIs can later switch to `NavigationAgent2D`.
- Offline coins/XP are claimed in the House; crop timers advance on load.

## Verification

After each stage the project is imported and run with the exact executable:
`C:\Users\Kamil\OneDrive\Escritorio\Godot_v4.6.3-stable_win64.exe`.
