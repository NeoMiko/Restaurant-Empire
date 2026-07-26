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
- `BAG`: zapisany ekwipunek; `Effects`: aktywne boosty, dekoracje i Legacy.
- `Speed x1/x2/x5/x10`: szybkość symulacji restauracji i aktywnego ogrodu.
- City → `Save & Main Menu`: bezpieczny zapis i wyjście do menu.

Minimalny hitbox głównych przycisków wynosi 64–82 px przy bazowej rozdzielczości
1920×1080. UI skaluje się przez `canvas_items` i działa w landscape.

## Działające systemy

- Main Menu, City, Restaurant, Garden, Bazaar, Shop, House, Fairy, Employment
  Office, Settings, Legal & Privacy, Loading overlay i Debug Panel.
- Pula klientów, grupy 1–6 osób oraz FSM od kolejki przez zamówienie i płatność do wyjścia.
- FIFO kolejki do stolików, prawdziwa liczba miejsc, zamówienia grupowe i kelner z tacą.
- Cztery startowe stoliki, kolejka kuchni, kucharz, lada i auto-cleaner.
- Monety, diamenty, reputacja, bilety gacha i tokeny prestiżu przez EconomyManager.
- Trzynaście ulepszeń z kosztem `base × 1.15^level`.
- Dziesięć receptur, osiem upraw, 12 pól, nawozy lokalne i globalny time skip.
- Bazaar z niską/normalną/wysoką ceną oraz sprzedażą ilościową i całościową.
- Sklep: Seeds, Recipes, Fertilisers, używalne Boosters i Decorations.
- Sześć slotów dekoracji z pasywnymi bonusami do cierpliwości, napiwków i reputacji.
- Błogosławieństwa zapisane z czasem wygaśnięcia.
- Gacha 1/10, pity 50, rarity i duplikaty.
- Prestige od poziomu restauracji 5 oraz Legacy Hall z pięcioma trwałymi ulepszeniami.
- Trzy daily quests, pięć achievements i trwałe statystyki między resetami.
- Globalny Inventory, panel aktywnych efektów oraz sześciostopniowy tutorial.
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

Oczekiwane wyniki: `CORE_TESTS_PASS checks=71`,
`SCENE_MATRIX_PASS scenes=13` i `RESTAURANT_SMOKE_PASS served>=1 coins>500`.

## Android

Projekt ma działający preset Android, GL Compatibility, landscape, immersive mode,
ARMv7 i ARM64. Eksport APK został wykonany i uruchomiony w emulatorze Android
(weryfikacja użytkownika z 2026-07-26). Preset zapisuje debug APK jeden katalog
powyżej projektu. Nieużywane uprawnienia sieciowe są wyłączone. Do publikacji
należy przygotować osobny release keystore i AAB.

Aby odtworzyć opcjonalny projekt Gradle w repozytorium:

```powershell
& $godot --headless --path . --install-android-build-template
```

Następnie w `Editor > Editor Settings > Export > Android` ustaw ścieżki SDK i JDK
(OpenJDK 17 jest zalecany; obecny JDK 21 jest wspierany), a w
`Project > Export > Android` zweryfikuj debug keystore. Ustaw min SDK 24 / target
SDK 35 i uruchom `Export Project`. Ten sam preset można wywołać z CLI:

```powershell
& $godot --headless --path . --export-debug Android exports/RestaurantEmpire-debug.apk
```

## Przygotowanie publikacji

W grze: `Settings → Legal, Privacy & Credits`. Pełne notice licencji Godot jest
w `docs/THIRD_PARTY_NOTICES.md`. Robocza polityka prywatności znajduje się w
`docs/PRIVACY_POLICY_DRAFT.md`, a działania wymagane w Google Play w
`docs/GOOGLE_PLAY_RELEASE_CHECKLIST.md`.

Przed publikacją trzeba uzupełnić nazwę wydawcy, e-mail i publiczny HTTPS URL
polityki, wybrać docelowy package ID oraz świadomie zdecydować, czy kod gry
pozostaje na obecnej licencji MIT. Dokumenty nie są poradą prawną.

## Podmiana placeholderów

Kolory są w `data/configs/balance.json`. Wizualizacje restauracji znajdują się w
`scripts/restaurant/*_floor.gd` i metodach `_draw()` aktorów. Docelowo należy
podmienić wyłącznie warstwę rysowania na Sprite2D/AnimationPlayer; identyfikatory,
FSM, kolejki i API scen pozostają bez zmian. Nowe dane dodaje się w JSON-ach bez
edycji logiki.

## Znane ograniczenia

Zobacz `docs/KNOWN_ISSUES.md`. Najważniejsze: proste ruchy po linii zamiast
NavigationAgent2D, grupy przedstawiane przez jedną kapsułę, brak docelowych
assetów/audio i slotowy zamiast swobodnego tryb rozmieszczania dekoracji.
