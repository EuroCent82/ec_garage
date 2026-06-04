Config = {}

--- auto | esx | qbcore | qbox
Config.Framework = 'auto'

--- Framework-Fahrzeugtabellen (nur lesen/schreiben Bestand)
Config.VehicleTables = {
    esx = 'owned_vehicles',
    qbcore = 'player_vehicles',
    qbox = 'player_vehicles',
}

--- ESX: Spalte für Garage-Zuordnung
Config.EsxParkingColumn = 'parking'
Config.EsxStoredColumn = 'stored'
Config.EsxPoundColumn = 'pound'

--- QBCore/Qbox: garage + state (0=out, 1=garage, 2=impound)
Config.QbGarageColumn = 'garage'
Config.QbStateColumn = 'state'

--- Interaktion: target (ox_target / qb-target am Prop) | marker (E + Marker) | both
Config.InteractMode = 'target'

--- auto | ox_target | qb-target | none
Config.Target = 'auto'
Config.TargetDistance = 2.5
Config.TargetLabel = 'Garage öffnen'

--- Chat-Vorschläge bei /befehl (ec_chat oder chat:addSuggestion)
Config.ChatSuggestions = true

Config.Commands = {
    creategarage = {
        enabled = true,
        help = 'Garagen-Creator öffnen (Positionen, Blip, Props)',
    },
    garageui = {
        enabled = true,
        help = 'Garage-UI testweise öffnen',
        params = {
            { name = 'modus', help = 'land, air, water oder impound' },
        },
    },
    garagedebug = {
        enabled = true,
        help = 'Auspark-Slot-Marker ein/aus (admin/manager)',
    },
}

--- Creator: Framework-Gruppen mit Zugriff auf /creategarage (ESX: xPlayer.getGroup())
Config.CreatorGroups = {
    'admin',
    'manager',
}

--- Zusätzlich ACE (optional). Zugriff wenn Gruppe ODER ACE passt. Leer = nur CreatorGroups.
Config.CreatorAce = 'ec_garage.creator'

--- Standard-Garage-ID für Seed
Config.DefaultGarageId = 'wuerfelpark'

--- Garagen aus ec_garages / ec_garage_slots laden (false = nur config/garages.lua)
Config.UseDatabaseGarages = true

--- Prop exakt auf DB/Creator-Koordinaten (false). true = PlaceObjectOnGroundProperly (kann wegspringen).
Config.PropSnapToGround = false

--- Z per GetGroundZFor_3dCoord korrigieren (gegen Schweben), X/Y/H aus Config/DB bleiben.
Config.PropUseGroundZ = true

--- Fehlende Prop-Daten aus config/garages.lua (GarageConfigTemplate) ergänzen
Config.MergeGarageTemplate = true

--- Ausparken: Radius pro Slot (m), ob Spieler ins Fahrzeug gewarped wird
Config.SpawnSlotRadius = 4.0
Config.SpawnWarpIntoVehicle = true

--- Target-Farben für Admin/Manager (ox_target iconColor)
Config.TargetAdminColors = {
    edit = '#d8a15c',
    delete = '#ff7b72',
}

--- Garagen-IDs die nicht gelöscht werden können
Config.ProtectedGarageIds = {
    'wuerfelpark',
}

--- Debug: Auspark-Slots als Marker (grün = frei, rot = belegt)
Config.DebugSpawnMarkers = false
Config.DebugSpawnMarkersAdminOnly = true
Config.DebugSpawnDrawDistance = 80.0
