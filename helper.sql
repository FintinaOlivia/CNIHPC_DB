INSERT INTO kingdoms(name, ruler, population, magic_level, valid_start, valid_end, sys_period)
VALUES 
('Avaloria', 'King Arthus', 50000, 8, '2023-01-01', '2024-12-31', tstzrange('2023-01-01','2024-12-31')),
('Avaloria', 'King Arthus II', 52000, 9, '2025-01-01', '9999-12-31', tstzrange('2025-01-01','infinity')),
('Draconia', 'Queen Seraphine', 75000, 10, '2022-06-01', '2025-03-01', tstzrange('2022-06-01','2025-03-01')),
('Draconia', 'Queen Seraphine II', 77000, 10, '2025-03-02', '9999-12-31', tstzrange('2025-03-02','infinity'));

INSERT INTO Dragons(name, species, color, fire_power_level, valid_start, valid_end, transaction_start, transaction_end)
VALUES
('Smolder', 'Fire Drake', 'Red', 80, '2023-01-01', '2024-12-31', '2023-01-01', '2024-12-31'),
('Smolder', 'Fire Drake', 'Red', 85, '2025-01-01', '9999-12-31', '2025-01-01', '9999-12-31'),
('Frostwing', 'Ice Drake', 'Blue', 70, '2024-02-15', '9999-12-31', '2024-02-15', '9999-12-31'),
('Shadowfang', 'Night Drake', 'Black', 90, '2023-01-20', '2023-12-31', '2023-01-25', '2023-12-31'); -- late entry

INSERT INTO DragonRiders(name, age, rank, dragon_id, valid_start, valid_end, transaction_start, transaction_end)
VALUES
('Lyra', 18, 'Knight', 1, '2023-01-01', '2024-12-31', '2023-01-01', '2024-12-31'),
('Lyra', 19, 'Knight Captain', 1, '2025-01-01', '9999-12-31', '2025-01-01', '9999-12-31'),
('Kael', 22, 'Knight', 2, '2024-02-01', '9999-12-31', '2024-02-01', '9999-12-31'),
('Mira', 20, 'Apprentice', 3, '2023-01-15', '2023-12-31', '2023-01-20', '2023-12-31'); -- late entry

INSERT INTO Missions(mission_name, location, difficulty_level, valid_start, valid_end, transaction_start, transaction_end)
VALUES
('Rescue the Princess', 'Avaloria', 7, '2023-01-05', '2024-06-30', '2023-01-05', '2024-06-30'),
('Rescue the Princess', 'Avaloria', 8, '2024-07-01', '9999-12-31', '2024-07-02', '9999-12-31'), -- late transaction
('Slay the Ice Dragon', 'Draconia', 9, '2024-02-10', '9999-12-31', '2024-02-15', '9999-12-31'); -- late entry

INSERT INTO Squads(name, leader_id, valid_start, valid_end, transaction_start, transaction_end)
VALUES
('Alpha Squad', 1, '2023-01-01', '2024-12-31', '2023-01-01', '2024-12-31'),
('Alpha Squad', 1, '2025-01-01', '9999-12-31', '2025-01-01', '9999-12-31'),
('Beta Squad', 2, '2024-02-01', '9999-12-31', '2024-02-01', '9999-12-31');

INSERT INTO wizardspells(wizard_id, spell_id, learned_at, valid_start, valid_end, sys_period)
VALUES
(1, 1, '2023-01-05', '2023-01-05', '2024-12-31', tstzrange('2023-01-05','2024-12-31')),
(1, 1, '2025-01-05', '2025-01-05', '9999-12-31', tstzrange('2025-01-05','infinity')),
(2, 2, '2024-02-10', '2024-02-10', '9999-12-31', tstzrange('2024-02-10','infinity'));