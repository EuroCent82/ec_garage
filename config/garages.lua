--- Fallback/Ladevorschau bis DB-Sync aktiv ist (Creator-Format)
--- Produktiv: ec_garages + ec_garage_slots (sql/seed_wuerfelpark.sql)

GarageSeed = {
    {
        id = 'wuerfelpark',
        name = 'Würfelpark Garage',
        type = 'land',
        interact = { x = 884.88, y = -43.56, z = 78.76, h = 58.0 },
        spawnSlots = {
            { x = 895.20, y = -35.80, z = 78.76, h = 328.0 },
            { x = 899.50, y = -30.20, z = 78.76, h = 328.0 },
            { x = 903.80, y = -24.50, z = 78.76, h = 328.0 },
            { x = 908.10, y = -18.90, z = 78.76, h = 328.0 },
        },
        parkMode = 'zone',
        parkRadius = 42.0,
        parkSlots = {},
        blipEnabled = true,
        blipLabel = 'Würfelpark',
        job = '',
        minGrade = 0,
    },
}
