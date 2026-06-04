# ec_garage — Datenbank (Laragon / MySQL)

Stand: lokale Prüfung über `C:\laragon\bin\mysql\mysql-8.4.7-winx64\bin\mysql.exe`.

## Welche DB nutzt dein Server?

| Datenbank | Framework | Fahrzeug-Tabelle | Einträge (Stand Prüfung) |
| --- | --- | --- | --- |
| **`esxlegacy_f9e16f`** | ESX Legacy | `owned_vehicles` | **1** (dein Kauf) |
| `qbcore_0e64ef` | QBCore | `player_vehicles` | 0 |
| `qbox_0e6853` | Qbox | `player_vehicles` | 0 |

**Fazit:** Dein gekauftes Fahrzeug liegt in **`esxlegacy_f9e16f.owned_vehicles`**.

| Feld | Wert |
| --- | --- |
| Kennzeichen | `QOB 772` |
| Owner | `char1:3821a23bbac7b97833445906c18529ab5a52a5cc` |
| `stored` | `1` (eingelagert) |
| `parking` | `SanAndreasAvenue` (Händler-Standard, noch nicht Würfelpark) |
| `mileage` | vorhanden |

## Brauchen wir neue Tabellen?

**Ja — für Garagen & Creator**, nicht für den Fahrzeug-Bestand selbst.

| Tabelle | Zweck |
| --- | --- |
| `ec_garages` | Garagen aus dem Creator (Name, Typ, Interaktion, Park-Modus, Blip) |
| `ec_garage_slots` | Spawn- und Park-Slots pro Garage |
| `ec_impound_lots` | Verwahrstellen (Impound-UI) |
| `ec_garage_vehicle_meta` | Anzeigename, Notiz, Favorit pro Kennzeichen |

**Nein — `owned_vehicles` ersetzen.** ESX bringt bereits mit:

- `stored` — 0 = draußen, 1 = in Garage
- `parking` — Garage-ID / Name (wir nutzen `wuerfelpark`)
- `pound` — Verwahrstelle
- `mileage` — Kilometer

Optional später: `ALTER` nur wenn du Felder direkt in `owned_vehicles` willst; Standard ist die separate Meta-Tabelle (kein Konflikt mit anderen Scripts).

## Installation

```powershell
cd dev
npm run db:inspect

# Schema + Würfelpark (gleiche DB wie dein ESX-Server):
& "C:\laragon\bin\mysql\mysql-8.4.7-winx64\bin\mysql.exe" -u root esxlegacy_f9e16f < sql/install.sql
& "C:\laragon\bin\mysql\mysql-8.4.7-winx64\bin\mysql.exe" -u root esxlegacy_f9e16f < sql/seed_wuerfelpark.sql

# Fahrzeug der Würfelpark-Garage zuweisen (optional):
& "C:\laragon\bin\mysql\mysql-8.4.7-winx64\bin\mysql.exe" -u root esxlegacy_f9e16f -e "UPDATE owned_vehicles SET parking='wuerfelpark', stored=1 WHERE plate='QOB 772';"
```

MySQL-Verbindung kommt vom Server (**oxmysql** / `mysql_connection_string` in `server.cfg` oder txAdmin) — nicht aus `config.lua`.
