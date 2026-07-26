# Known Issues

1. Debug APK eksportuje się i działa w emulatorze. Nie wykonano jeszcze pełnego
   testu na fizycznym urządzeniu ani podpisanego release AAB.
2. Klienci i pracownicy poruszają się po prostych odcinkach. Przy końcowych
   przeszkodach należy włączyć NavigationAgent2D.
3. Przy x10 i podstawowych ulepszeniach część klientów celowo traci cierpliwość;
   służy to testowaniu gałęzi `ANGRY_LEAVING`.
4. Grupa ma realną liczbę osób, miejsc, dań i płatność, ale wizualnie przedstawia
   ją jedna kapsuła z etykietą `xN`.
5. Dekoracje rozmieszcza się w sześciu stałych slotach; prototyp nie ma jeszcze
   swobodnego przeciągania i obracania mebli po sali.
6. Item Shop w City otwiera tę samą scenę Shop z pięcioma zakładkami.
7. JSON save nie jest szyfrowany i nie chroni przed ręczną modyfikacją.

Nie stwierdzono krytycznych błędów parsera, runtime ani wycieków w końcowych
przebiegach 71 testów core, matrycy 12 scen i restaurant smoke.
