CREATE OR REPLACE VIEW current_dragonriders AS
SELECT *
FROM DragonRiders
WHERE now() BETWEEN valid_start AND valid_end;

CREATE OR REPLACE VIEW mission_history AS
SELECT m.mission_id,
       m.mission_name,
       m.location,
       m.difficulty_level,
       m.transaction_start,
       m.transaction_end
FROM Missions m
ORDER BY m.mission_id, m.transaction_start;

CREATE OR REPLACE VIEW dragonrider_conflicts AS
SELECT *
FROM DragonRiders dr
WHERE dr.transaction_start > dr.valid_end
   OR dr.transaction_end < dr.valid_start;

CREATE OR REPLACE VIEW dragonriders_semester AS
SELECT *
FROM DragonRiders
WHERE tstzrange('2025-01-01', '2025-06-30', '[]') && tstzrange(valid_start, valid_end);

CREATE OR REPLACE VIEW dragons_as_of AS
SELECT *
FROM Dragons
WHERE '2025-03-01 12:00:00'::timestamptz
      BETWEEN transaction_start AND transaction_end;
