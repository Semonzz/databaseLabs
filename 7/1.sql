SELECT * FROM Lawyer;

BEGIN;

-- Удалим юриста Susan Harris (id=10)
DELETE FROM Lawyer WHERE id = 10;
SELECT * FROM Lawyer WHERE id = 10;

-- ОТКАТ: данные восстановятся
ROLLBACK;

SELECT * FROM Lawyer WHERE id = 10;

-- Новая транзакция с точкой сохранения
BEGIN;

DELETE FROM Lawyer WHERE id = 10;
SELECT * FROM Lawyer WHERE id = 10;

SAVEPOINT sp1;

-- Удалим ещё одного юриста
DELETE FROM Lawyer WHERE id = 5;
SELECT id, full_name FROM Lawyer WHERE id IN (5, 10);

-- Откатимся к точке
ROLLBACK TO SAVEPOINT sp1;
SELECT * FROM Lawyer WHERE id IN (5, 10);

-- Откатимся полностью и зафиксируем
ROLLBACK;
SELECT * FROM Lawyer WHERE id IN (5, 10);

COMMIT;

-- Итог: оба юриста на месте
SELECT id, full_name FROM Lawyer WHERE id IN (5, 10);