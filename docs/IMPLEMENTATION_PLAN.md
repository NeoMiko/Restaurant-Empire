# Restaurant Empire — Implementation Plan

## Source and target

Implementation follows all four volumes in `Restaurant Empire biblie.docx`.
The full 137 paragraphs and three data tables were read. Target: Godot 4.6.3,
GDScript, Android landscape, 1920×1080 scalable UI, GL Compatibility renderer.

All selected prototype values are centralized in `data/configs/*.json`.

## Architecture

- [x] Independent scenes coordinated by SceneManager.
- [x] Persistent state owned by GameManager.
- [x] Currency mutations routed only through EconomyManager.
- [x] EventBus signals decouple UI and simulations.
- [x] JSON content loaded and validated at startup.
- [x] Versioned save, backup, migration, autosave and lifecycle save.
- [x] Offline arithmetic capped at eight hours.
- [x] Restaurant FSMs and pooled customers.
- [x] Generated placeholder visuals separated from gameplay data.

## Stages

- [x] Stage 1: GDD analysis, Godot verification, structure and central data.
- [x] Stage 2: boot, menu, City, navigation, global HUD and save.
- [x] Stage 3: restaurant vertical slice and full customer service loop.
- [x] Stage 4: Garden, fertilisers, Bazaar and Shop.
- [x] Stage 5: House/offline, Fairy and Employment Office.
- [x] Stage 6: upgrades, Settings, responsive UI and Debug Panel.
- [x] Stage 7: data validation, 49 core checks, 11-scene matrix, smoke and docs.
- [x] Continuation: usable boosters, decoration slots and Prestige reset.
- [x] Expansion 3: group seating, FIFO entrance queue and multi-dish waiter tray.
- [x] Expansion 4: Prestige Tree, daily quests, achievements and lifetime stats.
- [x] Expansion 5: Inventory, active effects panel, tutorial and detailed tooltips.
- [x] Android debug APK exported and launched in an emulator (user verification).
- [x] Release preparation: in-app legal screen, Godot notice, privacy draft,
  minimal Android permissions and Google Play checklist.

## Verified results

- `Data validation: 0 errors, 10 recipes, 8 crops`
- `CORE_TESTS_PASS checks=71`
- `SCENE_MATRIX_PASS scenes=13`
- `RESTAURANT_SMOKE_PASS served=9 coins=889` (representative final run)
- Godot editor import and every gameplay scene parse without critical errors.
- Debug APK exports successfully and was launched in an Android emulator.
