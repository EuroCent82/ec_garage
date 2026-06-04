-- Würfelpark-Garage (Diamond Casino Parkplatz) — nach install.sql ausführen
-- Koordinaten: öffentlicher Parkplatz am Casino; im Creator feinjustierbar.

SET NAMES utf8mb4;

INSERT INTO `ec_garages` (
    `id`, `name`, `type`, `interact`, `park_mode`, `park_radius`,
    `blip_enabled`, `blip_sprite`, `blip_color`, `blip_label`, `enabled`, `created_by`
) VALUES (
    'wuerfelpark',
    'Würfelpark Garage',
    'land',
    JSON_OBJECT('x', 884.88, 'y', -43.56, 'z', 78.76, 'h', 58.0),
    'zone',
    42.0,
    1, 357, 3, 'Würfelpark', 1, 'seed'
) ON DUPLICATE KEY UPDATE
    `name` = VALUES(`name`),
    `interact` = VALUES(`interact`),
    `park_radius` = VALUES(`park_radius`),
    `blip_label` = VALUES(`blip_label`),
    `updated_at` = CURRENT_TIMESTAMP;

DELETE FROM `ec_garage_slots` WHERE `garage_id` = 'wuerfelpark';

INSERT INTO `ec_garage_slots` (`garage_id`, `slot_type`, `x`, `y`, `z`, `h`, `sort_order`) VALUES
    ('wuerfelpark', 'spawn', 895.20, -35.80, 78.76, 328.0, 1),
    ('wuerfelpark', 'spawn', 899.50, -30.20, 78.76, 328.0, 2),
    ('wuerfelpark', 'spawn', 903.80, -24.50, 78.76, 328.0, 3),
    ('wuerfelpark', 'spawn', 908.10, -18.90, 78.76, 328.0, 4);

-- Optional: dein gekauftes Fahrzeug der Würfelpark-Garage zuordnen (ESX: Spalte parking)
-- UPDATE `owned_vehicles` SET `parking` = 'wuerfelpark', `stored` = 1 WHERE `plate` = 'QOB 772';
