-- ec_garage — Garagen-Definitionen + UI-Metadaten (oxmysql / mysql-async)
-- Fahrzeug-Bestand bleibt in owned_vehicles (ESX) bzw. player_vehicles (QBCore/Qbox).

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS `ec_garages` (
    `id` VARCHAR(64) NOT NULL,
    `name` VARCHAR(128) NOT NULL,
    `type` VARCHAR(16) NOT NULL DEFAULT 'land',
    `interact` JSON NOT NULL,
    `park_mode` VARCHAR(16) NOT NULL DEFAULT 'zone',
    `park_radius` DOUBLE NOT NULL DEFAULT 25,
    `park_zone` JSON NULL DEFAULT NULL,
    `blip_enabled` TINYINT(1) NOT NULL DEFAULT 1,
    `blip_sprite` INT NOT NULL DEFAULT 357,
    `blip_color` INT NOT NULL DEFAULT 3,
    `blip_label` VARCHAR(64) NULL DEFAULT NULL,
    `job` VARCHAR(32) NULL DEFAULT NULL,
    `min_grade` INT NOT NULL DEFAULT 0,
    `prop` JSON NULL DEFAULT NULL,
    `enabled` TINYINT(1) NOT NULL DEFAULT 1,
    `created_by` VARCHAR(128) NULL DEFAULT NULL,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_ec_garages_type` (`type`),
    KEY `idx_ec_garages_enabled` (`enabled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ec_garage_slots` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `garage_id` VARCHAR(64) NOT NULL,
    `slot_type` VARCHAR(16) NOT NULL,
    `x` DOUBLE NOT NULL,
    `y` DOUBLE NOT NULL,
    `z` DOUBLE NOT NULL,
    `h` DOUBLE NOT NULL DEFAULT 0,
    `sort_order` INT NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `idx_ec_garage_slots_garage` (`garage_id`, `slot_type`),
    CONSTRAINT `fk_ec_garage_slots_garage` FOREIGN KEY (`garage_id`) REFERENCES `ec_garages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ec_impound_lots` (
    `id` VARCHAR(64) NOT NULL,
    `name` VARCHAR(128) NOT NULL,
    `interact` JSON NOT NULL,
    `spawn_slots` JSON NOT NULL,
    `fee_base` INT UNSIGNED NOT NULL DEFAULT 500,
    `fee_per_day` INT UNSIGNED NOT NULL DEFAULT 100,
    `blip_enabled` TINYINT(1) NOT NULL DEFAULT 1,
    `enabled` TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- UI-Extras pro Kennzeichen (Name, Notiz, Favorit) — ohne owned_vehicles zu verändern
CREATE TABLE IF NOT EXISTS `ec_garage_vehicle_meta` (
    `plate` VARCHAR(12) NOT NULL,
    `custom_name` VARCHAR(64) NULL DEFAULT NULL,
    `note` VARCHAR(200) NULL DEFAULT NULL,
    `favorite` TINYINT(1) NOT NULL DEFAULT 0,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
