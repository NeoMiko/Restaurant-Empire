# Architecture

## Warstwy

1. `data/configs` — receptury, uprawy, ludzie, sklep, balans i kolory.
2. `DataManager` — ładowanie, lookup i walidacja identyfikatorów.
3. `GameManager` — jeden serializowalny słownik stanu gracza.
4. Managerowie domenowi — Economy, Save, Offline, Time, Scene, UI i Audio.
5. Sceny — prezentacja i lokalna orkiestracja systemu.
6. Aktorzy restauracji — małe FSM komunikujące się z kontrolerem Restaurant.

## Przepływ zdarzeń

UI wywołuje jawne API managera. Manager zmienia stan, publikuje sygnał w EventBus,
UI odświeża się, a SaveManager kolejkowuje zapis. Sceny nie modyfikują walut
bezpośrednio. Dane wizualne nie są wejściem dla logiki.

## Autoloady

- `EventBus`: sygnały aplikacji i debug.
- `DataManager`: JSON oraz walidacja startupowa.
- `TimeManager`: x1/x2/x5/x10 i bezpieczny unix time.
- `GameManager`: stan i merge brakujących pól po migracji.
- `EconomyManager`: wszystkie waluty, płatności i ulepszenia.
- `OfflineProgressManager`: arytmetyka AFK oraz timery upraw.
- `SaveManager`: save/backup/load/migrate/autosave/lifecycle.
- `SceneManager`: asynchroniczne przejścia i loading overlay.
- `UIManager`, `NotificationManager`, `AudioManager`, `DebugManager`.

## Restaurant

Restaurant posiada kolejkę zamówień i kolejkę gotowych dań. Pula 12 klientów
unika ciągłej alokacji. Każdy klient ma enum z 11 stanami. Kucharze pobierają FIFO,
a kelnerzy przechodzą `IDLE → TO_COUNTER → TO_TABLE → RETURNING`. Stoliki mają
`FREE/RESERVED/OCCUPIED/WAITING_FOR_CLEANING/CLEANING`.

`Kitchen Capacity` tworzy równoległych kucharzy, `Waiter Capacity` równoległe
sloty dostawy, a `Table Count` dodaje stoliki w czasie działania. Pozostałe bonusy
są obliczane przy wejściu w odpowiednią fazę, bez pollingu całej gry.

## Wydajność

Renderer to GL Compatibility. Brak shaderów i tekstur. Klienci są pulowani,
nieaktywni aktorzy nie przetwarzają klatek, stoliki uruchamiają `_process` tylko
podczas sprzątania, a poza aktywną sceną timery opierają się na różnicy czasu.
