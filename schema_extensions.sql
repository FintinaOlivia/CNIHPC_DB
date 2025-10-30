-- Add Extensions
CREATE EXTENSION periods;
CREATE EXTENSION temporal_tables;

-- Create Tables
CREATE TABLE kingdoms (
    kingdom_id SERIAL PRIMARY KEY,
    name       TEXT NOT NULL,
    ruler      TEXT,
    population INT,
    magic_level INT,
    valid_start TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_end   TIMESTAMPTZ NOT NULL DEFAULT '9999-12-31 23:59:59',
    sys_period  TSTZRANGE NOT NULL
);

CREATE TABLE wizards (
    wizard_id SERIAL PRIMARY KEY,
    name      TEXT NOT NULL,
    level     INT,
    school    TEXT,
    valid_start TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_end   TIMESTAMPTZ NOT NULL DEFAULT '9999-12-31 23:59:59',
    sys_period  TSTZRANGE NOT NULL
);

CREATE TABLE spells (
    spell_id SERIAL PRIMARY KEY,
    name     TEXT NOT NULL,
    type     TEXT,
    power    INT,
    valid_start TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_end   TIMESTAMPTZ NOT NULL DEFAULT '9999-12-31 23:59:59',
    sys_period  TSTZRANGE NOT NULL
);

CREATE TABLE artifacts (
    artifact_id SERIAL PRIMARY KEY,
    kingdom_id  INT REFERENCES kingdoms(kingdom_id),
    name        TEXT NOT NULL,
    type        TEXT,
    power_level INT,
    valid_start TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_end   TIMESTAMPTZ NOT NULL DEFAULT '9999-12-31 23:59:59',
    sys_period  TSTZRANGE NOT NULL
);

CREATE TABLE wizardspells (
    wizard_id  INT REFERENCES wizards(wizard_id),
    spell_id   INT REFERENCES spells(spell_id),
    learned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_start TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_end   TIMESTAMPTZ NOT NULL DEFAULT '9999-12-31 23:59:59',
    sys_period  TSTZRANGE NOT NULL,
    PRIMARY KEY (wizard_id, spell_id, learned_at)
);

-- Create history tables
CREATE TABLE kingdoms_history   (LIKE kingdoms);
CREATE TABLE wizards_history    (LIKE wizards);
CREATE TABLE spells_history     (LIKE spells);
CREATE TABLE artifacts_history  (LIKE artifacts);
CREATE TABLE wizardspells_history (LIKE wizardspells);

-- periods etension for period for syntax
SELECT periods.add_period('kingdoms', 'validity', 'valid_start', 'valid_end');
SELECT periods.add_period('artifacts', 'validity', 'valid_start', 'valid_end');
SELECT periods.add_period('wizards', 'validity', 'valid_start', 'valid_end');
SELECT periods.add_period('spells', 'validity', 'valid_start', 'valid_end');
SELECT periods.add_period('wizardspells', 'validity', 'valid_start', 'valid_end');

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

