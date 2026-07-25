# Implementation Status

## Ukończone

- [x] Pełny odczyt czterech tomów GDD.
- [x] Godot 4.6.3, landscape 1920×1080, GL Compatibility.
- [x] Boot, Main Menu, Continue, Settings, Exit.
- [x] City Hub z ośmioma budynkami i blokadą reputacji.
- [x] Przejścia scen, loading overlay, powroty i pasek walut.
- [x] Restaurant: 4 stoliki, kucharz, cashier, kelner, cleaner i lada.
- [x] Pula klientów oraz pełne FSM klienta i kelnera.
- [x] FIFO zamówień, gotowanie, odbiór, dostawa, jedzenie, płatność, tip.
- [x] Wszystkie pięć walut przez EconomyManager, bez salda ujemnego.
- [x] 13 ulepszeń i formuła `base × 1.15^level`.
- [x] 10 receptur, 8 upraw i centralne dane.
- [x] Garden 4×3, sadzenie, timer, harvest i plot unlock.
- [x] Basic/Advanced/Instant Fertiliser i globalny Garden Time Skip.
- [x] Bazaar: stan, ilość, sell one/quantity/all, trzy pasma cen.
- [x] Shop: Seeds, Recipes, Fertilisers, używalne Boosters i Decorations.
- [x] Sześć slotów dekoracji, placement/removal i konfigurowalne bonusy pasywne.
- [x] Prestige: próg, nagroda, reset ekonomii i trwały bonus tokenów.
- [x] House: limit 8 h, AFK selection i odbiór offline.
- [x] Fairy: sześć boostów, zapis i offline expiry bez stackowania.
- [x] Employment Office: 1/10, rarity, pity 50, duplikaty i kolekcja.
- [x] Save v2, backup, corruption fallback, migracja i lifecycle save.
- [x] Ukryty Debug Panel oraz x1/x2/x5/x10.
- [x] Audio buses Music/SFX/UI/Ambient.
- [x] Startup data validation, 49 testów core, 11 scen i restaurant smoke.
- [x] Import i runtime test w Godot 4.6.3 bez błędów parsera ani wycieków.

## Częściowo ukończone

- [~] Table Capacity jest modelowane jako większy wolumen zamówienia grupowego;
  placeholder nadal pokazuje jednego reprezentanta grupy.
- [~] Waiter Carry Capacity tworzy równoległe sloty dostawy zamiast jednej animacji
  kelnera niosącego kilka talerzy.
- [~] Dekoracje działają w sześciu slotach; brak swobodnego przeciągania po sali.
- [~] Audio routing i ustawienia działają, lecz brak docelowych plików audio.
- [~] Android preset i template istnieją, lecz lokalnemu SDK brakuje Command-line
  Tools latest, CMake 3.10.2.4988404 i NDK 28.1.13356709; APK nie został utworzony.

## Jeszcze niewykonane (poza zakresem vertical slice)

- [ ] Docelowe sprite’y, animacje, VFX, muzyka i SFX.
- [ ] NavigationAgent2D dla zatłoczonego finalnego layoutu.
- [ ] Swobodny edytor placement dekoracji i finalny system wielu miejsc przy stole.
- [ ] Rozbudowane drzewo wydawania Prestige Tokens (sam reset i bonus już działają).
- [ ] Daily quests, weekly missions, sezony, achievements i live operations.
- [ ] Telemetria, cloud save, płatności i publikacja sklepu (celowo brak w prototypie).
- [ ] Podpisany release APK/AAB.
