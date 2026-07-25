# Known Issues

1. Android CLI export jest zablokowany przez niekompletne lokalne SDK. Obecne są
   ADB, build-tools 35.0.1, android-35 i template 4.6.3, ale brakuje wymaganych
   Command-line Tools `latest`, CMake `3.10.2.4988404` oraz NDK `28.1.13356709`.
   APK nie powstał. Instalacja tych składników zmienia środowisko użytkownika i
   wymaga osobnej zgody; projekt gry nie jest od nich zależny podczas pracy w PC.
2. Klienci i pracownicy poruszają się po prostych odcinkach. Przy końcowych
   przeszkodach należy włączyć NavigationAgent2D.
3. Przy x10 i podstawowych ulepszeniach część klientów celowo traci cierpliwość;
   służy to testowaniu gałęzi `ANGRY_LEAVING`.
4. Pole `Table Capacity` zwiększa ekonomiczny wolumen grupy, ale placeholder grupy
   to jedna kapsuła klienta.
5. Dekoracje rozmieszcza się w sześciu stałych slotach; prototyp nie ma jeszcze
   swobodnego przeciągania i obracania mebli po sali.
6. Item Shop w City otwiera tę samą scenę Shop z pięcioma zakładkami.
7. JSON save nie jest szyfrowany i nie chroni przed ręczną modyfikacją.

Nie stwierdzono krytycznych błędów parsera, runtime ani wycieków w końcowych
przebiegach 49 testów core, matrycy 11 scen i restaurant smoke.
