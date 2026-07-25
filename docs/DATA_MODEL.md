# Data Model

## Konfiguracja

- `balance.json`: czasy, ekonomia, motyw, nawozy, boosty, gacha, ulepszenia i budynki.
- `recipes.json`: 10 receptur z ID, kategorią, czasem, ceną, kosztem, składnikami,
  levelem, reputacją, XP i popularnością.
- `crops.json`: 8 roślin z kosztem nasiona, wzrostem, plonem i wartością.
- `people.json`: typy klientów oraz pracownicy z rarity/statystykami.
- `shop.json`: mnożnik ceny receptur, działanie boosterów, dekoracje, bonusy i 6 slotów.

Każda kolekcja jest walidowana pod kątem wymaganych pól i duplikatów ID.
`RecipeData`, `CropData` oraz `EmployeeData` są Resource schemas gotowymi do
przejścia z JSON na `.tres` bez zmiany kontraktów gameplayu.

## Stan gracza

Główne sekcje: `currencies`, `player`, `unlocked_buildings`, `unlocked_recipes`,
`recipe_mastery`, `upgrades`, `inventory`, `garden`, `staff_collection`,
`pity_counter`, `active_blessings`, `placed_decorations`, `offline_pending`,
`market`, `settings`, `stats`, `last_save_unix` i `save_version`.

Pole ogrodu: `{status, crop_id, remaining, fertiliser}`. Czas pozostaje liczbą
sekund, co umożliwia x10 i arytmetyczny offline bez symulacji każdej sekundy.

## Wartości prototypowe

Czasy celowo skrócono: receptury 6–10 s, uprawy 30–180 s, jedzenie 5–8 s,
sprzątanie 2,5 s, spawn 4 s. Są to wartości testowe; tabele GDD (minuty/godziny)
pozostają referencją do późniejszego balansu produkcyjnego. Limit AFK 28 800 s,
growth ulepszeń 1,15 i gacha rates są zgodne z GDD. Prestige jest dostępny od
poziomu restauracji 5, przyznaje token za każde 5 poziomów i daje +5% dochodu za
token; próg, przelicznik i bonus znajdują się w `balance.json`.
