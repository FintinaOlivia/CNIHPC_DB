-- Clean up existing data
TRUNCATE SquadMission, Missions, Squads, DragonRiders, Dragons RESTART IDENTITY CASCADE;

-- Populate Dragons
INSERT INTO Dragons (name, species, color, fire_power_level)
SELECT
    'Dragon_' || i AS name,
    (ARRAY['Fire Drake', 'Ice Wyvern', 'Storm Serpent', 'Earth Wyrm', 'Shadow Drake'])[ceil(random() * 5)],
    (ARRAY['Red', 'Blue', 'Green', 'Black', 'White', 'Bronze'])[ceil(random() * 6)],
    (10 + floor(random() * 90))::INT  -- Fire power level 10–100
FROM generate_series(1, 15) AS s(i);

-- Populate DragonRiders
INSERT INTO DragonRiders (name, age, rank, dragon_id)
SELECT
    'Rider_' || i,
    (16 + floor(random() * 40))::INT,  -- Ages 16–55
    (ARRAY['Trainee', 'Rider', 'Captain', 'Commander'])[ceil(random() * 4)],
    (SELECT dragon_id FROM Dragons ORDER BY random() LIMIT 1)
FROM generate_series(1, 25) AS s(i);

-- Populate Squads and pick random leaders from existing riders
INSERT INTO Squads (name, leader_id)
SELECT
    'Squad_' || i,
    (SELECT rider_id FROM DragonRiders ORDER BY random() LIMIT 1)
FROM generate_series(1, 5) AS s(i);

-- Populate Missions
INSERT INTO Missions (mission_name, location, difficulty_level)
SELECT
    (ARRAY[
        'Patrol the Northern Peaks',
        'Escort the Sky Caravans',
        'Investigate the Ashlands',
        'Slay the Rogue Drake',
        'Deliver Supplies to Frosthold',
        'Scout the Shadow Frontier',
        'Defend Stormspire',
        'Rescue Trapped Riders'
    ])[ceil(random() * 8)],
    (ARRAY['Frostpeak', 'Skyhold', 'Ashlands', 'Stormspire', 'Shadowvale'])[ceil(random() * 5)],
    (1 + floor(random() * 10))::INT  -- Difficulty 1–10
FROM generate_series(1, 12) AS s(i);

-- Populate SquadMission (assign missions to squads)
INSERT INTO SquadMission (squad_id, mission_id, status)
SELECT
    s.squad_id,
    m.mission_id,
    (ARRAY['assigned', 'in-progress', 'completed'])[ceil(random() * 3)]
FROM Squads s
JOIN LATERAL (
    SELECT mission_id FROM Missions ORDER BY random() LIMIT (1 + floor(random() * 3))::INT
) m ON TRUE;


-- Simulate History Events (updates)

UPDATE Dragons
SET
    color = (ARRAY['Crimson', 'Azure', 'Emerald', 'Obsidian', 'Ivory'])[ceil(random() * 5)],
    fire_power_level = fire_power_level + (5 - floor(random() * 10))
WHERE random() < 0.25;

-- Some riders switch dragons (logs into DragonRiders_history)
UPDATE DragonRiders
SET
    dragon_id = (SELECT dragon_id FROM Dragons ORDER BY random() LIMIT 1)
WHERE random() < 0.3;  

-- Some squads change leaders
UPDATE Squads
SET
    leader_id = (SELECT rider_id FROM DragonRiders ORDER BY random() LIMIT 1)
WHERE random() < 0.4;

-- Some missions increase in difficulty or are completed
UPDATE Missions
SET
    difficulty_level = LEAST(10, difficulty_level + 1),
    location = (ARRAY['Frostpeak', 'Skyhold', 'Ashlands', 'Stormspire', 'Shadowvale'])[ceil(random() * 5)]
WHERE random() < 0.3;

-- Some squad missions update status
UPDATE SquadMission
SET
    status = CASE status
        WHEN 'assigned' THEN 'in-progress'
        WHEN 'in-progress' THEN 'completed'
        ELSE status
    END
WHERE random() < 0.5;

