# Implementation Status

## Ukończone

- [x] Pełny odczyt czterech tomów GDD.
- [x] Godot 4.6.3, landscape 1920×1080, GL Compatibility.
- [x] Boot, Main Menu, Continue, Settings, Exit.
- [x] City Hub z dziewięcioma budynkami, Legacy Hall i blokadą reputacji.
- [x] Przejścia scen, loading overlay, powroty i pasek walut.
- [x] Restaurant: 4 stoliki, kucharz, cashier, kelner, cleaner i lada.
- [x] Pula klientów oraz pełne FSM klienta i kelnera.
- [x] FIFO kolejki do stolików i zamówień kuchni, gotowanie, dostawa, płatność i tip.
- [x] Grupy 1–6 osób, rzeczywiste miejsca, ilościowe zamówienia i skalowane płatności.
- [x] Kelner z tacą obsługującą wiele gotowych dań według Carry Capacity.
- [x] Wszystkie pięć walut przez EconomyManager, bez salda ujemnego.
- [x] 13 ulepszeń i formuła `base × 1.15^level`.
- [x] 10 receptur, 8 upraw i centralne dane.
- [x] Garden 4×3, sadzenie, timer, harvest i plot unlock.
- [x] Basic/Advanced/Instant Fertiliser i globalny Garden Time Skip.
- [x] Bazaar: stan, ilość, sell one/quantity/all, trzy pasma cen.
- [x] Shop: Seeds, Recipes, Fertilisers, używalne Boosters i Decorations.
- [x] Sześć slotów dekoracji, placement/removal i konfigurowalne bonusy pasywne.
- [x] Prestige: próg, nagroda, reset ekonomii i trwały bonus tokenów.
- [x] Legacy Hall: 5-node Prestige Tree, 3 daily quests i 5 achievements.
- [x] Lifetime stats zachowywane przez Prestige oraz blokady wielokrotnego claimu.
- [x] Globalny BAG, panel aktywnych efektów, tutorial 6 kroków i tooltipy ulepszeń.
- [x] House: limit 8 h, AFK selection i odbiór offline.
- [x] Fairy: sześć boostów, zapis i offline expiry bez stackowania.
- [x] Employment Office: 1/10, rarity, pity 50, duplikaty i kolekcja.
- [x] Save v2, backup, corruption fallback, migracja i lifecycle save.
- [x] Ukryty Debug Panel oraz x1/x2/x5/x10.
- [x] Audio buses Music/SFX/UI/Ambient.
- [x] Startup data validation, 71 testów core, 12 scen i restaurant smoke.
- [x] Debug APK wyeksportowany i uruchomiony w emulatorze Android.
- [x] Import i runtime test w Godot 4.6.3 bez błędów parsera ani wycieków.

## Częściowo ukończone

- [~] Grupa ma realny rozmiar, miejsca, ilość dań i płatność, ale wizualnie nadal
  korzysta z jednej kapsuły-reprezentanta z etykietą `xN`.
- [~] Dekoracje działają w sześciu slotach; brak swobodnego przeciągania po sali.
- [~] Audio routing i ustawienia działają, lecz brak docelowych plików audio.
- [~] Debug APK działa w emulatorze; fizyczne urządzenie i release AAB nie były jeszcze testowane.

## Jeszcze niewykonane (poza zakresem vertical slice)

- [ ] Docelowe sprite’y, animacje, VFX, muzyka i SFX.
- [ ] NavigationAgent2D dla zatłoczonego finalnego layoutu.
- [ ] Swobodny edytor placement dekoracji i osobne wizualne postacie każdego członka grupy.
- [ ] Weekly missions, sezony i live operations; daily quests i achievements już działają.
- [ ] Telemetria, cloud save, płatności i publikacja sklepu (celowo brak w prototypie).
- [ ] Podpisany release APK/AAB.
