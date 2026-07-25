# Known Issues

1. Android CLI export kończy się komunikatem `configuration errors` bez nazwy pola.
   SDK, ADB, build-tools, platforms, JDK i template 4.6.3 są wykryte. APK nie
   powstał; należy odczytać szczegół walidatora w oknie Export lokalnego edytora.
2. Klienci i pracownicy poruszają się po prostych odcinkach. Przy końcowych
   przeszkodach należy włączyć NavigationAgent2D.
3. Przy x10 i podstawowych ulepszeniach część klientów celowo traci cierpliwość;
   służy to testowaniu gałęzi `ANGRY_LEAVING`.
4. Pole `Table Capacity` zwiększa ekonomiczny wolumen grupy, ale placeholder grupy
   to jedna kapsuła klienta.
5. Zakupione dekoracje nie mają jeszcze trybu rozmieszczania; są poprawnie
   przechowywane w inventory/save.
6. Item Shop w City otwiera tę samą scenę Shop z pięcioma zakładkami.
7. JSON save nie jest szyfrowany i nie chroni przed ręczną modyfikacją.

Nie stwierdzono krytycznych błędów parsera ani runtime w końcowych testach core i
restaurant smoke.
