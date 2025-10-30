-- Clean up existing data
--TRUNCATE kingdoms, wizards, spells, artifacts, wizardspells RESTART IDENTITY CASCADE;

-- Generation Scripts
CREATE OR REPLACE FUNCTION populate_kingdoms(n INT)
RETURNS VOID AS $BODY$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..n LOOP
        INSERT INTO kingdoms(name, ruler, population, magic_level)
        VALUES (
            'Kingdom_' || i,
            'Ruler_' || i,
            (random()*100000)::INT + 1000,
            (random()*10)::INT + 1
        );
    END LOOP;
END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION populate_wizards(n INT)
RETURNS VOID AS $BODY$
DECLARE
    i INT;
    schools TEXT[] := ARRAY['Fire', 'Ice', 'Necromancy', 'Illusion', 'Alteration'];
BEGIN
    FOR i IN 1..n LOOP
        INSERT INTO wizards(name, level, school)
        VALUES (
            'Wizard_' || i,
            (random()*20)::INT + 1,
            schools[(random()*array_length(schools,1))::INT + 1]

        );
    END LOOP;
END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION populate_spells(n INT)
RETURNS VOID AS $$
DECLARE
    i INT;
    types TEXT[] := ARRAY['Fire', 'Ice', 'Healing', 'Illusion', 'Necromancy'];
BEGIN
    FOR i IN 1..n LOOP
        INSERT INTO spells(name, type, power)
        VALUES (
            'Spell_' || i,
            types[(random()*array_length(types,1))::INT + 1],
            (random()*50)::INT + 1
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION populate_artifacts(n INT)
RETURNS VOID AS $$
DECLARE
    i INT;
    kingdom_count INT;
    types TEXT[] := ARRAY['Sword', 'Amulet', 'Ring', 'Staff', 'Crown'];
BEGIN
    SELECT COUNT(*) INTO kingdom_count FROM kingdoms;
    FOR i IN 1..n LOOP
        INSERT INTO artifacts(kingdom_id, name, type, power_level)
        VALUES (
            (floor(random()*kingdom_count)::INT + 1),
            'Artifact_' || i,
            types[(random()*array_length(types,1))::INT + 1],
            (random()*100)::INT + 1
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION populate_wizardspells(n INT)
RETURNS VOID AS $$
DECLARE
    i INT;
    wizard_count INT;
    spell_count INT;
BEGIN
    SELECT COUNT(*) INTO wizard_count FROM wizards;
    SELECT COUNT(*) INTO spell_count FROM spells;

    FOR i IN 1..n LOOP
        INSERT INTO wizardspells(wizard_id, spell_id, learned_at)
        VALUES (
            (floor(random()*wizard_count)::INT + 1),
            (floor(random()*spell_count)::INT + 1),
            current_timestamp - (random()*1000 || ' hours')::INTERVAL
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION populate_creatures(n INT)
RETURNS VOID AS $$
DECLARE
    i INT;
    types TEXT[] := ARRAY['Nazgul', 'Goblin', 'Fairy', 'Troll', 'Phoenix', 'Giant'];
BEGIN
    FOR i IN 1..n LOOP
        INSERT INTO creatures(name, type, danger_level)
        VALUES (
            'Creature_' || i,
            types[(floor(random() * array_length(types,1))::INT + 1)],
            (random() * 100)::INT + 1
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Populate tables
SELECT populate_kingdoms(5);
SELECT populate_wizards(10);
SELECT populate_spells(15);
SELECT populate_artifacts(20);
SELECT populate_wizardspells(30);
SELECT populate_creatures(30);

-- Simulate data changes over time

-- 30% chance a wizard will level up
UPDATE wizards
SET level = level + 1
WHERE random() < 0.3;

-- 20% artifacs obsolete
UPDATE artifacts
SET valid_end = current_timestamp,
    sys_period = tstzrange(lower(sys_period), current_timestamp)
WHERE name LIKE 'Artifact_%' AND random() < 0.2;

-- 50% chance to delete a creature
DELETE FROM creatures
WHERE random() < 0.5;


