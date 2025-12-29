-- Cценарий 1
SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
-- А
BEGIN;
SELECT qualification FROM Lawyer WHERE id = 7;
UPDATE Lawyer SET qualification = 10.0 WHERE id = 7;

-- В
BEGIN;
SELECT qualification FROM Lawyer WHERE id = 7;
UPDATE Lawyer SET qualification = 8.0 WHERE id = 7;

-- А
COMMIT;
SELECT qualification FROM Lawyer WHERE id = 7;

-- B
COMMIT;

-- A
SELECT qualification FROM Lawyer WHERE id = 7;


-- Cценарий 2
-- A
BEGIN;
UPDATE Lawyer SET full_name = 'TEST TESTOV' WHERE id = 7;

-- B
SELECT full_name FROM Lawyer WHERE id = 7;

-- A
ROLLBACK;

-- Сценарий 3
SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Сценарий 4

-- А
BEGIN;
SELECT qualification FROM Lawyer WHERE id = 7;

-- В
BEGIN;
UPDATE Lawyer SET qualification = 11.0 WHERE id = 7;
COMMIT;

-- А
SELECT qualification FROM Lawyer WHERE id = 7;
COMMIT;

-- Сценарий 5
SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- А
BEGIN;
SELECT qualification FROM Lawyer WHERE id = 7;

-- В
BEGIN;
UPDATE Lawyer SET qualification = 12.0 WHERE id = 7;
COMMIT;

-- А
SELECT qualification FROM Lawyer WHERE id = 7;
COMMIT;

-- Сценарий 6

-- А 
BEGIN;
SELECT * FROM Lawyer WHERE qualification >= 9.0;

-- В
BEGIN;
INSERT INTO Lawyer (full_name, phone, address, start_date, qualification)
VALUES ('TEST TESTOVICH', '+1111111111', 'MOSCOW', '2025-01-01', 9.2);
COMMIT;

-- А
SELECT * FROM Lawyer WHERE qualification >= 9.0;
COMMIT;

-- Сценарий 7
SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- А 
BEGIN;
SELECT * FROM Lawyer WHERE qualification >= 9.0;

-- В
BEGIN;
INSERT INTO Lawyer (full_name, phone, address, start_date, qualification)
VALUES ('TEST TESTOVICH2', '+1111111111', 'MOSCOW', '2025-01-01', 9.2);
COMMIT;

-- А
SELECT * FROM Lawyer WHERE qualification >= 9.0;
COMMIT;