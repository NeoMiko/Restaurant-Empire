# Save Format v2

Format: UTF-8 JSON w `user://restaurant_empire_save.json`. Przed każdym zapisem
poprzednia poprawna zawartość trafia do `restaurant_empire_save.backup.json`.

## Gwarancje

- Każdy zapis ma `save_version: 2` i `last_save_unix`.
- Odczyt wymaga słownika z sekcją `currencies`.
- Błędny JSON jest odrzucany bez wyjątku; następnie próbowany jest backup.
- Migracja v0→v1→v2 uzupełnia brakujące `offline_pending`.
- `GameManager.apply_loaded` rekurencyjnie dodaje nowe domyślne pola, w tym
  `placed_decorations`, `prestige_tree`, `achievements`, `daily_quests`, `tutorial`
  i `lifetime_stats`, więc zapis v2 pozostaje kompatybilny bez podnoszenia wersji.
- Ujemne i przyszłe różnice czasu są zerowane, a offline ma limit 8 h.
- Autosave: 30 s, ważne akcje, pauza/tło, zamknięcie i debug Save.

## Przykład skrócony

```json
{
  "save_version": 2,
  "currencies": {"coins": 500, "diamonds": 25, "reputation": 0},
  "upgrades": {"kitchen_speed": 0},
  "garden": [{"status": "EMPTY", "crop_id": "", "remaining": 0.0}],
  "active_blessings": {},
  "placed_decorations": ["potted_plant"],
  "prestige_tree": {"golden_register": 1},
  "achievements": {"first_service": true},
  "daily_quests": {"day": 20660, "entries": {}},
  "tutorial": {"step": 2, "completed": false},
  "offline_pending": {"seconds": 0, "coins": 0, "xp": 0},
  "last_save_unix": 1784990000
}
```

Save jest celowo czytelny w prototypie i nie stanowi zabezpieczenia anti-cheat.
