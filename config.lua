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

--- Creator / Admin (ACE oder Gruppe — später im Server)
Config.CreatorAce = 'ec_garage.creator'

--- Standard-Garage-ID für Seed
Config.DefaultGarageId = 'wuerfelpark'
