# Restaurant Empire — prototyp Godot 4.6.3

Restaurant Empire jest mobilnym tycoonem 2D łączącym automatyczną restaurację,
ogród, handel, kolekcję pracowników, gacha i progresję offline. Wszystkie grafiki
są figurami generowanymi w Godot; logika nie zależy od placeholderów.

## Uruchomienie

Wymagany jest Godot 4.6.3 stable. Otwórz `project.godot` w edytorze lub uruchom:

```powershell
& "C:\Users\Kamil\OneDrive\Escritorio\Godot_v4.6.3-stable_win64.exe" `
  --path "C:\Users\Kamil\OneDrive\Escritorio\Restaurant Empire"
```

Główna scena to `res://scenes/bootstrap/boot.tscn`. Boot waliduje dane i otwiera
Main Menu. `New Game` zapisuje stan i przechodzi do City; `Continue` ładuje zapis,
backup oraz postęp offline.

## Sterowanie

- Mysz lub dotyk: wszystkie akcje.
- Android Back / przycisk `← City`: powrót do City.
- `F12` lub przycisk `DEBUG` w buildzie debug: panel deweloperski.
- `Speed x1/x2/x5/x10`: szybkość symulacji restauracji i aktywnego ogrodu.
- City → `Save & Main Menu`: bezpieczny zapis i wyjście do menu.

Minimalny hitbox głównych przycisków wynosi 64–82 px przy bazowej rozdzielczości
1920×1080. UI skaluje się przez `canvas_items` i działa w landscape.

## Działające systemy

- Main Menu, City, Restaurant, Garden, Bazaar, Shop, House, Fairy, Employment
  Office, Settings, Loading overlay i Debug Panel.
- Pula klientów oraz FSM od wejścia przez zamówienie, jedzenie i płatność do wyjścia.
- Cztery startowe stoliki, kolejka zamówień, kucharz, lada, FSM kelnera i auto-cleaner.
- Monety, diamenty, reputacja, bilety gacha i tokeny prestiżu przez EconomyManager.
- Trzynaście ulepszeń z kosztem `base × 1.15^level`.
- Dziesięć receptur, osiem upraw, 12 pól, nawozy lokalne i globalny time skip.
- Bazaar z niską/normalną/wysoką ceną oraz sprzedażą ilościową i całościową.
- Sklep: Seeds, Recipes, Fertilisers, używalne Boosters i Decorations.
- Sześć slotów dekoracji z pasywnymi bonusami do cierpliwości, napiwków i reputacji.
- Błogosławieństwa zapisane z czasem wygaśnięcia.
- Gacha 1/10, pity 50, rarity i duplikaty.
- Prestige od poziomu restauracji 5: reset ekonomii za trwałe tokeny i bonus dochodu.
- Zapis JSON v2, backup, migracja, autosave i bezpieczne odrzucenie uszkodzeń.
- Matematyczne naliczanie do ośmiu godzin offline.

## Panel debug

Panel jest ukryty w buildzie release. W edytorze i buildzie debug otwiera go `F12`
lub przycisk `DEBUG`. Udostępnia waluty, odblokowanie treści, save/load/reset,
x1–x10, spawn/clear klientów, ukończenie upraw, napełnienie inventory, test dwóch
godzin offline, FPS i liczbę obiektów. Reset wymaga potwierdzenia.

## Lokalizacja zapisu

`user://restaurant_empire_save.json`, na Windows domyślnie:

```text
%APPDATA%\Godot\app_userdata\Restaurant Empire\restaurant_empire_save.json
```

Backup: `restaurant_empire_save.backup.json`. Plik jest czytelnym JSON-em i nie
powinien zawierać sekretów.

## Testy

```powershell
$godot = "C:\Users\Kamil\OneDrive\Escritorio\Godot_v4.6.3-stable_win64.exe"
& $godot --headless --path . res://tests/core_tests.tscn
& $godot --headless --path . res://tests/scene_matrix.tscn
& $godot --headless --path . res://tests/restaurant_smoke.tscn
```

Oczekiwane wyniki: `CORE_TESTS_PASS checks=49`,
`SCENE_MATRIX_PASS scenes=11` i `RESTAURANT_SMOKE_PASS served>=1 coins>500`.

## Android

Projekt ma preset Android, GL Compatibility, landscape, immersive mode, ARMv7 i
ARM64. Template 4.6.3, ADB, build-tools 35.0.1 i platforma android-35 są obecne.
Lokalnemu SDK brakuje jednak wymaganych przez Godot 4.6 elementów: Command-line
Tools `latest`, CMake `3.10.2.4988404` i NDK `28.1.13356709`. Z tego powodu eksport
CLI poprawnie odrzuca konfigurację i APK nie powstał. Oficjalna lista wymagań:
https://docs.godotengine.org/en/4.6/tutorials/export/exporting_for_android.html

Po doinstalowaniu tych składników przez Android Studio można odtworzyć projekt
Gradle w repozytorium:

```powershell
& $godot --headless --path . --install-android-build-template
```

Następnie w `Editor > Editor Settings > Export > Android` ustaw ścieżki SDK i JDK
(OpenJDK 17 jest zalecany; obecny JDK 21 jest wspierany), a w
`Project > Export > Android` zweryfikuj debug keystore. Ustaw min SDK 24 / target
SDK 35 i uruchom `Export Project`. Alternatywnie po naprawie konfiguracji:

```powershell
& $godot --headless --path . --export-debug Android exports/RestaurantEmpire-debug.apk
```

## Podmiana placeholderów

Kolory są w `data/configs/balance.json`. Wizualizacje restauracji znajdują się w
`scripts/restaurant/*_floor.gd` i metodach `_draw()` aktorów. Docelowo należy
podmienić wyłącznie warstwę rysowania na Sprite2D/AnimationPlayer; identyfikatory,
FSM, kolejki i API scen pozostają bez zmian. Nowe dane dodaje się w JSON-ach bez
edycji logiki.

## Znane ograniczenia

Zobacz `docs/KNOWN_ISSUES.md`. Najważniejsze: proste ruchy po linii zamiast
NavigationAgent2D, brak docelowych assetów/audio, slotowy zamiast swobodnego tryb
rozmieszczania dekoracji oraz brakujące składniki lokalnego Android SDK.
