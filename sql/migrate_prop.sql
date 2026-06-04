-- Bestehende Installation: Prop-Spalte nachrüsten
ALTER TABLE `ec_garages`
    ADD COLUMN IF NOT EXISTS `prop` JSON NULL DEFAULT NULL AFTER `min_grade`;
