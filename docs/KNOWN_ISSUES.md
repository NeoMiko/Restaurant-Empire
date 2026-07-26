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
8. Polityka prywatności jest draftem: przed publikacją wymaga danych wydawcy,
   kontaktu i publicznego HTTPS URL, także w ekranie in-game.
9. Package ID nadal zawiera .prototype, a właściciel nie potwierdził, czy kod
   gry ma pozostać na obecnej licencji MIT, czy stać się proprietary.
10. Nie wykonano jeszcze weryfikacji nazwy w bazach znaków towarowych ani pełnych
    deklaracji Data safety, Target audience i IARC w Play Console.

Nie stwierdzono krytycznych błędów parsera, runtime ani wycieków w końcowych
przebiegach 71 testów core, matrycy 13 scen i restaurant smoke.
