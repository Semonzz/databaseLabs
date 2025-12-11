


# Database Labs

Database Labs in YarSU, Semenov Evgeniy, PMI-32, Lab number 13.

<p align="center"> 
  <a href="#lab-1"><img alt="lab1" src="https://img.shields.io/badge/Lab1-g"></a>
  <a href="#lab-2-pgsql"><img alt="lab2" src="https://img.shields.io/badge/Lab2-g"></a>
  <a href="#lab-3-pgsql"><img alt="lab3" src="https://img.shields.io/badge/Lab3-g"></a>
  <a href="#lab-4-pgsql"><img alt="lab4" src="https://img.shields.io/badge/Lab4-g"></a>
  <a href="#lab-5-pgsql"><img alt="lab6" src="https://img.shields.io/badge/Lab6-g"></a>
</p>

## Lab 1
### ER-model:
![ER-model](/1/1.png)
### Relational model:
![REL-model](/1/2_1.png)


## Lab 2 (PGSQL)
### SQL create tables:
```
CREATE TABLE Specialization (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);


CREATE TABLE CaseType (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Lawyer (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(50) NOT NULL,
    phone VARCHAR(15),
    address VARCHAR(200),
    start_date DATE NOT NULL,
    qualification REAL CHECK (qualification >= 0),
    is_active BOOLEAN DEFAULT true
);


CREATE TABLE Client (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(50) NOT NULL,
    passport_data VARCHAR(20) NOT NULL UNIQUE,
    address VARCHAR(200)
);


CREATE TABLE "Case" (
    id SERIAL PRIMARY KEY,
    start_date DATE NOT NULL,
    end_date DATE,
    max_sentence INT CHECK (max_sentence >= 0),
    actual_sentence INT CHECK (actual_sentence >= 0),
    fine_amount INT CHECK (fine_amount >= 0),
    case_type_id INTEGER REFERENCES CaseType(id) ON DELETE RESTRICT,
    client_id INTEGER NOT NULL REFERENCES Client(id) ON DELETE RESTRICT
);


CREATE TABLE Lawyer_Client (
    lawyer_id INTEGER REFERENCES Lawyer(id) ON DELETE RESTRICT,
    client_id INTEGER REFERENCES Client(id) ON DELETE RESTRICT,
    hire_date DATE NOT NULL,
    PRIMARY KEY (lawyer_id, client_id)
);


CREATE TABLE Lawyer_Case (
    lawyer_id INTEGER REFERENCES Lawyer(id) ON DELETE RESTRICT,
    case_id INTEGER REFERENCES "Case"(id) ON DELETE RESTRICT,
    PRIMARY KEY (lawyer_id, case_id)
);


CREATE TABLE Lawyer_Specialization (
    lawyer_id INTEGER REFERENCES Lawyer(id) ON DELETE CASCADE,
    specialization_id INTEGER REFERENCES Specialization(id) ON DELETE RESTRICT,
    PRIMARY KEY (lawyer_id, specialization_id)
);
```
### Lawyer table:
![lawyer](/2/lawyer.png)
### Client table:
![client](/2/client.png)
### Case table:
![case](/2/case.png)
### Specialization table:
![spec](/2/specialization.png)
### Casetype table:
![casetype](/2/casetype.png)
### Lawyer_case table:
![l-case](/2/lawyer_case.png)
### Lawyer_client table:
![l-client](/2/lawyer_client.png)
### Lawyer_specialization table:
![L-s](/2/lawyer_specialization.png)
### Diagram
![Diagram](/2/diagram.png)

## Lab 3 (PGSQL)
[Part 1](/3/Семенов_ПМИ32.docx)
[Part 2](/3/Семенов_ПМИ32_2.docx)

## Lab 4 (PGSQL)
### PROCEDURE
a) Процедура без параметров, формирующая список клиентов, которые обращались в контору 2 и более раз
```
CREATE OR REPLACE PROCEDURE clients_two_or_more_cases()
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT c.id, c.full_name, COUNT(cs.id) as total
        FROM Client c
        JOIN "Case" cs ON c.id = cs.client_id
        GROUP BY c.id, c.full_name
        HAVING COUNT(cs.id) >= 2
    LOOP
        RAISE NOTICE 'ID: %, ФИО: %, Дел: %', r.id, r.full_name, r.total;
    END LOOP;
END;
$$;

CALL clients_two_or_more_cases();
```
![proc-a](/4/proc-a.png)

b) Процедура, на входе получающая ФИО адвоката и формирующая список его текущих дел
```
CREATE OR REPLACE PROCEDURE lawyer_current_cases(lawyer_name VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT c.id, c.start_date
        FROM "Case" c
        JOIN Lawyer_Case lc ON c.id = lc.case_id
        JOIN Lawyer l ON lc.lawyer_id = l.id
        WHERE l.full_name = lawyer_name AND c.end_date IS NULL
    LOOP
        RAISE NOTICE 'Дело ID: %, Начало: %', r.id, r.start_date;
    END LOOP;
END;
$$;

CALL lawyer_current_cases('John Smith');
```
![proc-b](/4/proc-b.png)

c) Процедура, на входе получающая ФИО адвоката, выходной параметр – количество его законченных дел
```
CREATE OR REPLACE PROCEDURE lawyer_completed_cases_simple(lawyer_name VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
    cnt INTEGER;
BEGIN
    SELECT COUNT(*) INTO cnt
    FROM "Case" c
    JOIN Lawyer_Case lc ON c.id = lc.case_id
    JOIN Lawyer l ON lc.lawyer_id = l.id
    WHERE l.full_name = lawyer_name AND c.end_date IS NOT NULL;
    
    RAISE NOTICE 'Завершенных дел: %', cnt;
END;
$$;

CALL lawyer_completed_cases_simple('John Smith');
```
![proc-c](/4/proc-c.png)

d) Процедура, вызывающая вложенную процедуру, которая подсчитывает текущую среднюю загруженность адвокатов (среднее кол-во дел). Вызывающая процедура выводит ФИО адвокатов с кол-вом дел меньше среднего
```
CREATE OR REPLACE PROCEDURE calculate_avg_cases(OUT average REAL)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT AVG(cnt) INTO average
    FROM (
        SELECT COUNT(lc.case_id) as cnt
        FROM Lawyer l
        LEFT JOIN Lawyer_Case lc ON l.id = lc.lawyer_id
        LEFT JOIN "Case" c ON lc.case_id = c.id AND c.end_date IS NULL
        WHERE l.is_active = true
        GROUP BY l.id
    ) t;
END;
$$;

CREATE OR REPLACE PROCEDURE lawyers_below_average()
LANGUAGE plpgsql
AS $$
DECLARE r RECORD; avg REAL;
BEGIN
    CALL calculate_avg_cases(avg);
    
    FOR r IN 
        SELECT l.full_name, COUNT(lc.case_id) as cnt
        FROM Lawyer l
        LEFT JOIN Lawyer_Case lc ON l.id = lc.lawyer_id
        LEFT JOIN "Case" c ON lc.case_id = c.id AND c.end_date IS NULL
        WHERE l.is_active = true
        GROUP BY l.id, l.full_name
        HAVING COUNT(lc.case_id) < avg
    LOOP
        RAISE NOTICE '% - % дел', r.full_name, r.cnt;
    END LOOP;
END;
$$;

CALL lawyers_below_average();
```
![proc-d](/4/proc-d.png)

### FUNCTION

a) Скалярная функция, на входе получающая ФИО адвоката и выдающая число клиентов, которые обращались к нему больше 1-го раза
```
CREATE OR REPLACE FUNCTION get_client_repeat_count(lawyer_full_name VARCHAR)
RETURNS INTEGER AS $$
DECLARE
    client_count INTEGER;
BEGIN
    SELECT COUNT(client_id)
    INTO client_count
    FROM (
        SELECT lc.client_id
        FROM Lawyer_Client lc
        JOIN Lawyer l ON l.id = lc.lawyer_id
        WHERE l.full_name = lawyer_full_name
        GROUP BY lc.client_id
        HAVING COUNT(*) > 1
    ) AS repeat_clients;
    
    RETURN client_count;
END;
$$ LANGUAGE plpgsql;

SELECT get_client_repeat_count('John Smith');
```
![func-a](/4/func-a.png)

b) Inline-функция, возвращающая для каждого адвоката количество дел с полученным сроком, равным максимальному
```
CREATE OR REPLACE FUNCTION get_max_sentence_cases()
RETURNS TABLE (
    lawyer_id INTEGER,
    full_name VARCHAR,
    case_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.id,
        l.full_name,
        COUNT(c.id)::BIGINT as case_count
    FROM Lawyer l
    JOIN Lawyer_Case lc ON l.id = lc.lawyer_id
    JOIN "Case" c ON lc.case_id = c.id
    WHERE c.actual_sentence = c.max_sentence
        AND c.actual_sentence > 0
    GROUP BY l.id, l.full_name;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_max_sentence_cases();
```
![func-b](/4/func-b.png)

c) Multi-statement-функция, выдающая список результатов работы каждого адвоката в виде: ФИО | общее количество дел | кол-во дел с условным сроком | кол-во дел со штрафом | кол-во дел с полученным сроком, равным максимальному
```
CREATE OR REPLACE FUNCTION get_lawyer_statistics()
RETURNS TABLE (
    full_name VARCHAR,
    total_cases INTEGER,
    conditional_cases INTEGER,
    fine_cases INTEGER,
    max_sentence_cases INTEGER
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH lawyer_data AS (
        SELECT 
            l.id,
            l.full_name,
            c.id as case_id,
            c.actual_sentence,
            c.fine_amount,
            c.max_sentence
        FROM Lawyer l
        LEFT JOIN Lawyer_Case lc ON l.id = lc.lawyer_id
        LEFT JOIN "Case" c ON lc.case_id = c.id
    )
    SELECT 
        ld.full_name,
        COUNT(DISTINCT ld.case_id)::INTEGER as total_cases,
        COUNT(DISTINCT CASE WHEN ld.actual_sentence = 0 THEN ld.case_id END)::INTEGER as conditional_cases,
        COUNT(DISTINCT CASE WHEN ld.fine_amount > 0 THEN ld.case_id END)::INTEGER as fine_cases,
        COUNT(DISTINCT CASE WHEN ld.actual_sentence = ld.max_sentence AND ld.actual_sentence > 0 THEN ld.case_id END)::INTEGER as max_sentence_cases
    FROM lawyer_data ld
    GROUP BY ld.id, ld.full_name
    ORDER BY ld.full_name;
END;
$$;

SELECT * FROM get_lawyer_statistics();
```
![func-c](/4/func-c.png)

### TRIGGER

a) Триггер любого типа на добавление дела – контора берется только за дела, у которых максимальный срок не превышает 25 лет
```
CREATE OR REPLACE FUNCTION check_max_sentence()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.max_sentence > 25 THEN
        RAISE EXCEPTION 'Максимальный срок не должен превышать 25 лет.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_sentence_before_insert
BEFORE INSERT ON "Case"
FOR EACH ROW
EXECUTE FUNCTION check_max_sentence();

INSERT INTO "Case" (start_date, max_sentence, case_type_id, client_id) 
VALUES ('2024-01-01', 30, 1, 1);
```
![trig-a](/4/trig-a.png)

b)  Последующий триггер на изменение полученного срока – полученный срок должен быть не больше максимального
```
CREATE OR REPLACE FUNCTION check_actual_sentence()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.actual_sentence > NEW.max_sentence THEN
        RAISE EXCEPTION 'Полученный срок не может быть больше максимального';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_actual_sentence_before_update
BEFORE UPDATE ON "Case"
FOR EACH ROW
EXECUTE FUNCTION check_actual_sentence();

UPDATE "Case" SET actual_sentence = 10 WHERE max_sentence = 5;
```
![trig-b](/4/trig-b.png)

c) Замещающий триггер на операцию удаления – при увольнении адвоката все его текущие дела передаются наименее загруженному адвокату (с наименьшим количеством текущих дел), все закрытые дела удаляются.
```
CREATE OR REPLACE FUNCTION handle_lawyer_delete()
RETURNS TRIGGER AS $$
DECLARE
    new_lawyer_id INTEGER;
BEGIN
    SELECT l.id INTO new_lawyer_id
    FROM Lawyer l
    WHERE l.id != OLD.id AND l.is_active = true
    ORDER BY (
        SELECT COUNT(*) FROM Lawyer_Case WHERE lawyer_id = l.id
    ) ASC
    LIMIT 1;
    
    IF new_lawyer_id IS NOT NULL THEN
        INSERT INTO Lawyer_Case (lawyer_id, case_id)
        SELECT new_lawyer_id, case_id
        FROM Lawyer_Case 
        WHERE lawyer_id = OLD.id
        ON CONFLICT DO NOTHING;
    END IF;

	DELETE FROM Lawyer_Case WHERE lawyer_id = OLD.id;
    DELETE FROM Lawyer_Client WHERE lawyer_id = OLD.id;
    DELETE FROM Lawyer_Specialization WHERE lawyer_id = OLD.id;
	
    DELETE FROM "Case" 
    WHERE id IN (
        SELECT lc.case_id 
        FROM Lawyer_Case lc 
        WHERE lc.lawyer_id = OLD.id
    ) 
    AND end_date IS NOT NULL;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_delete_lawyer
BEFORE DELETE ON Lawyer
FOR EACH ROW
EXECUTE FUNCTION handle_lawyer_delete();

DELETE FROM Lawyer WHERE id = 2;
```
BEFORE TRIGGER c:

![trig-c-1](/4/trig-c-1.png)

AFTER TRIGGER c:

![trig-c-2](/4/trig-c-2.png)

## Lab 5 (PGSQL)
[SCRIPT](/5/script.sql)
