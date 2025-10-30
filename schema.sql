-- Create tables:
CREATE TABLE IF NOT EXISTS Dragons (
    dragon_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    species TEXT,
    color TEXT,
    fire_power_level INT CHECK (fire_power_level BETWEEN 1 AND 100),
    valid_start TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    valid_end TIMESTAMPTZ DEFAULT '9999-12-31 23:59:59' NOT NULL,
    transaction_start TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    transaction_end TIMESTAMPTZ DEFAULT '9999-12-31 23:59:59' NOT NULL
);

CREATE TABLE IF NOT EXISTS DragonRiders (
    rider_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    age INT CHECK (age >= 10),
    rank TEXT,
    dragon_id INT REFERENCES Dragons(dragon_id) ON DELETE CASCADE,
    valid_start TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    valid_end TIMESTAMPTZ DEFAULT '9999-12-31 23:59:59' NOT NULL,
    transaction_start TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    transaction_end TIMESTAMPTZ DEFAULT '9999-12-31 23:59:59' NOT NULL
);

CREATE TABLE IF NOT EXISTS Squads (
    squad_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    leader_id INT REFERENCES DragonRiders(rider_id) ON DELETE CASCADE,
    valid_start TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    valid_end TIMESTAMPTZ DEFAULT '9999-12-31 23:59:59' NOT NULL,
    transaction_start TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    transaction_end TIMESTAMPTZ DEFAULT '9999-12-31 23:59:59' NOT NULL
);

CREATE TABLE IF NOT EXISTS Missions (
    mission_id SERIAL PRIMARY KEY,
    mission_name TEXT NOT NULL,
    location TEXT,
    difficulty_level INT CHECK (difficulty_level BETWEEN 1 AND 10),
    valid_start TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    valid_end TIMESTAMPTZ DEFAULT '9999-12-31 23:59:59' NOT NULL,
    transaction_start TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    transaction_end TIMESTAMPTZ DEFAULT '9999-12-31 23:59:59' NOT NULL
);

CREATE TABLE IF NOT EXISTS SquadMission (
    squad_id INT REFERENCES Squads(squad_id) ON DELETE CASCADE,
    mission_id INT REFERENCES Missions(mission_id) ON DELETE CASCADE,
    assigned_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status TEXT DEFAULT 'assigned',
    PRIMARY KEY (squad_id, mission_id),
    valid_start TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    valid_end TIMESTAMPTZ DEFAULT '9999-12-31 23:59:59' NOT NULL,
    transaction_start TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    transaction_end TIMESTAMPTZ DEFAULT '9999-12-31 23:59:59' NOT NULL
);

-- Create History Tables
CREATE TABLE IF NOT EXISTS Dragons_history (LIKE Dragons);
CREATE TABLE IF NOT EXISTS DragonRiders_history (LIKE DragonRiders);
CREATE TABLE IF NOT EXISTS Squads_history (LIKE Squads);
CREATE TABLE IF NOT EXISTS Missions_history (LIKE Missions);
CREATE TABLE IF NOT EXISTS SquadMission_history (LIKE SquadMission);

-- Create Triggers
CREATE OR REPLACE FUNCTION create_history_trigger(base_table text)
RETURNS void AS $BODY$
DECLARE
    history_table text := base_table || '_history';
    trigger_name text := base_table || '_history_trigger';
    sql text;
BEGIN
    EXECUTE format('DROP TRIGGER IF EXISTS %I ON %I;', trigger_name, base_table);

    sql := format($f$
        CREATE OR REPLACE FUNCTION %I()
        RETURNS TRIGGER AS $$
        BEGIN
            IF TG_OP = 'UPDATE' THEN
                OLD.transaction_end := CURRENT_TIMESTAMP;
                INSERT INTO %I SELECT OLD.*;
            ELSIF TG_OP = 'DELETE' THEN
                OLD.transaction_end := CURRENT_TIMESTAMP;
                INSERT INTO %I SELECT OLD.*;
                RETURN OLD;
            END IF;
            RETURN NULL;
        END;
        $$ LANGUAGE plpgsql;
    $f$, trigger_name, history_table, history_table);

    EXECUTE sql;

    EXECUTE format($f$
        CREATE TRIGGER %I
        AFTER UPDATE OR DELETE ON %I
        FOR EACH ROW
        EXECUTE FUNCTION %I();
    $f$, trigger_name, base_table, trigger_name);

    RAISE NOTICE 'History trigger created for table: %', base_table;
END;
$BODY$ LANGUAGE plpgsql;


-- CREATE TRIGGERS

SELECT create_history_trigger('dragons');
SELECT create_history_trigger('dragonriders');
SELECT create_history_trigger('squads');
SELECT create_history_trigger('missions');
SELECT create_history_trigger('squadmission');


-- Extensions: temporal_tables + periods


-- HELPERS !!
-- TRUNCATE TABLE
--     dragonriders,
--     dragonriders_history,
--     squads,
--     squads_history,
--     missions,
--     missions_history,
--     squadmission,
--     squadmission_history,
--     dragons,
--     dragons_history
-- RESTART IDENTITY CASCADE;