-- Add Extensions
CREATE EXTENSION periods;
CREATE EXTENSION temporal_tables;

-- Create Tables
CREATE TABLE IF NOT EXISTS kingdoms (
    kingdom_id SERIAL PRIMARY KEY,
    name       TEXT NOT NULL,
    ruler      TEXT,
    population INT,
    magic_level INT,
    valid_start TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_end   TIMESTAMPTZ NOT NULL DEFAULT '9999-12-31 23:59:59',
    sys_period  TSTZRANGE NOT NULL
);

CREATE TABLE IF NOT EXISTS wizards (
    wizard_id SERIAL PRIMARY KEY,
    name      TEXT NOT NULL,
    level     INT,
    school    TEXT,
    valid_start TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_end   TIMESTAMPTZ NOT NULL DEFAULT '9999-12-31 23:59:59',
    sys_period  TSTZRANGE NOT NULL
);

CREATE TABLE IF NOT EXISTS spells (
    spell_id SERIAL PRIMARY KEY,
    name     TEXT NOT NULL,
    type     TEXT,
    power    INT,
    valid_start TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_end   TIMESTAMPTZ NOT NULL DEFAULT '9999-12-31 23:59:59',
    sys_period  TSTZRANGE NOT NULL
);

CREATE TABLE IF NOT EXISTS artifacts (
    artifact_id SERIAL PRIMARY KEY,
    kingdom_id  INT REFERENCES kingdoms(kingdom_id)  ON DELETE CASCADE,
    name        TEXT NOT NULL,
    type        TEXT,
    power_level INT,
    valid_start TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_end   TIMESTAMPTZ NOT NULL DEFAULT '9999-12-31 23:59:59',
    sys_period  TSTZRANGE NOT NULL
);

CREATE TABLE wizardspells (
    wizard_id  INT REFERENCES wizards(wizard_id) ON DELETE CASCADE,
    spell_id   INT REFERENCES spells(spell_id) ON DELETE CASCADE,
    learned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_start TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_end   TIMESTAMPTZ NOT NULL DEFAULT '9999-12-31 23:59:59',
    sys_period  TSTZRANGE NOT NULL,
    PRIMARY KEY (wizard_id, spell_id, learned_at)
);

CREATE TABLE IF NOT EXISTS creatures (
    creature_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    danger_level INT NOT NULL,
    valid_start TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_end   TIMESTAMPTZ NOT NULL DEFAULT '9999-12-31 23:59:59',
    sys_period tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, 'infinity')
);

-- Create history tables
CREATE TABLE IF NOT EXISTS kingdoms_history (LIKE kingdoms);
CREATE TABLE IF NOT EXISTS wizards_history (LIKE wizards);
CREATE TABLE IF NOT EXISTS spells_history (LIKE spells);
CREATE TABLE IF NOT EXISTS artifacts_history (LIKE artifacts);
CREATE TABLE IF NOT EXISTS wizardspells_history (LIKE wizardspells);
CREATE TABLE IF NOT EXISTS creatures_history (LIKE creatures);

-- periods etension for period for syntax
SELECT periods.add_period('kingdoms', 'validity', 'valid_start', 'valid_end');
SELECT periods.add_period('artifacts', 'validity', 'valid_start', 'valid_end');
SELECT periods.add_period('wizards', 'validity', 'valid_start', 'valid_end');
SELECT periods.add_period('spells', 'validity', 'valid_start', 'valid_end');
SELECT periods.add_period('wizardspells', 'validity', 'valid_start', 'valid_end');
SELECT periods.add_period('creatures', 'validity', 'valid_start', 'valid_end');

-- temporal_tables extension use for automatic, trigger-based versioning
CREATE TRIGGER kingdoms_versioning
BEFORE INSERT OR UPDATE OR DELETE ON kingdoms
FOR EACH ROW EXECUTE PROCEDURE versioning('sys_period', 'kingdoms_history', true);

CREATE TRIGGER wizards_versioning
BEFORE INSERT OR UPDATE OR DELETE ON wizards
FOR EACH ROW EXECUTE PROCEDURE versioning('sys_period', 'wizards_history', true);

CREATE TRIGGER spells_versioning
BEFORE INSERT OR UPDATE OR DELETE ON spells
FOR EACH ROW EXECUTE PROCEDURE versioning('sys_period', 'spells_history', true);

CREATE TRIGGER artifacts_versioning
BEFORE INSERT OR UPDATE OR DELETE ON artifacts
FOR EACH ROW EXECUTE PROCEDURE versioning('sys_period', 'artifacts_history', true);

CREATE TRIGGER wizardspells_versioning
BEFORE INSERT OR UPDATE OR DELETE ON wizardspells
FOR EACH ROW EXECUTE PROCEDURE versioning('sys_period', 'wizardspells_history', true);

CREATE TRIGGER creatures_versioning
BEFORE INSERT OR UPDATE OR DELETE ON wizardspells
FOR EACH ROW EXECUTE PROCEDURE versioning('sys_period', 'creatures_history', true);

