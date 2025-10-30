-- Clean up existing data
TRUNCATE kingdoms, wizards, spells, artifacts, wizardspells RESTART IDENTITY CASCADE;

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

-- Populate tables
SELECT populate_kingdoms(5);
SELECT populate_wizards(10);

UPDATE wizards
SET level = level + 1,
    sys_period = tstzrange(current_timestamp, 'infinity')
WHERE random() < 0.3;

