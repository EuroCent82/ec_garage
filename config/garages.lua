--- Garagen-Vorlage (read-only Fallback) + Laufzeit-GarageSeed

GarageConfigTemplate = {
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
        blipSprite = 357,
        blipColor = 3,
        blipLabel = 'Würfelpark',
        job = '',
        minGrade = 0,
        prop = {
            enabled = true,
            model = 'prop_park_ticket_01',
            x = 885.35,
            y = -42.18,
            z = 78.76,
            h = 238.0,
        },
    },
}

GarageSeed = GarageConfigTemplate
