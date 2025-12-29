


# Database Labs

Database Labs in YarSU, Semenov Evgeniy, PMI-32, Lab number 13.

<p align="center"> 
  <a href="#lab-1"><img alt="lab1" src="https://img.shields.io/badge/Lab1-g"></a>
  <a href="#lab-2-pgsql"><img alt="lab2" src="https://img.shields.io/badge/Lab2-g"></a>
  <a href="#lab-3-pgsql"><img alt="lab3" src="https://img.shields.io/badge/Lab3-g"></a>
  <a href="#lab-4-pgsql"><img alt="lab4" src="https://img.shields.io/badge/Lab4-g"></a>
  <a href="#lab-5-pgsql"><img alt="lab5" src="https://img.shields.io/badge/Lab5-g"></a>
  <a href="#lab-6-pgsql-age"><img alt="lab6" src="https://img.shields.io/badge/Lab6-g"></a>
  <a href="#lab-7-pgsql"><img alt="lab5" src="https://img.shields.io/badge/Lab7-g"></a>
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


## Lab 6 (PGSQL (AGE))
### Так как в PGSQL нет встроенной логики графов использовал extension Apache AGE
![graph](/6/graph.png)
### SQL create
```
CREATE EXTENSION IF NOT EXISTS age;
LOAD 'age';
SET search_path = ag_catalog, "$user", public;

SELECT drop_graph('lawyer_graph', true);

SELECT create_graph('lawyer_graph');

-- lawyer
SELECT *
FROM cypher('lawyer_graph', $$
    WITH [
        {id: '1', name: 'John Smith', phone: '+1234567890', address: '123 Main St, NY', start_date: '2015-03-15', qualification: 8.5, is_active: true},
        {id: '2', name: 'Emily Davis', phone: '+1234567891', address: '456 Oak Ave, LA', start_date: '2016-07-20', qualification: 9.2, is_active: true},
        {id: '3', name: 'Michael Brown', phone: '+1234567892', address: '789 Pine Rd, TX', start_date: '2014-01-10', qualification: 7.8, is_active: true},
        {id: '4', name: 'Sarah Wilson', phone: '+1234567893', address: '321 Elm St, CA', start_date: '2017-11-05', qualification: 9.0, is_active: true},
        {id: '5', name: 'David Johnson', phone: '+1234567894', address: '654 Maple Dr, FL', start_date: '2018-04-12', qualification: 8.0, is_active: true},
        {id: '6', name: 'Lisa Miller', phone: '+1234567895', address: '987 Cedar Ln, IL', start_date: '2019-09-03', qualification: 8.7, is_active: true},
        {id: '7', name: 'Robert Taylor', phone: '+1234567896', address: '246 Birch Ct, OH', start_date: '2013-08-22', qualification: 9.5, is_active: true},
        {id: '8', name: 'Jennifer White', phone: '+1234567897', address: '135 Willow Way, WA', start_date: '2020-02-14', qualification: 7.9, is_active: true},
        {id: '9', name: 'Thomas Lee', phone: '+1234567898', address: '111 Rose Blvd, AZ', start_date: '2016-12-08', qualification: 8.5, is_active: true},
        {id: '10', name: 'Susan Harris', phone: '+1234567899', address: '222 Lily Lane, OR', start_date: '2017-06-18', qualification: 8.8, is_active: true}
    ] AS lawyers
    UNWIND lawyers AS lawyer
    CREATE (l:Lawyer {
        id: lawyer.id,
        full_name: lawyer.name,
        phone: lawyer.phone,
        address: lawyer.address,
        start_date: lawyer.start_date,
        qualification: lawyer.qualification,
        is_active: lawyer.is_active
    })
    RETURN count(l) as lawyers_created
$$) as (count agtype);

-- Client
SELECT *
FROM cypher('lawyer_graph', $$
    WITH [
        {id: '1', full_name: 'Alex Johnson', passport_data: '1234567890', address: '101 Pine St, NY'},
        {id: '2', full_name: 'Maria Garcia', passport_data: '0987654321', address: '202 Oak Ave, LA'},
        {id: '3', full_name: 'James Wilson', passport_data: '1122334455', address: '303 Maple Dr, TX'},
        {id: '4', full_name: 'Linda Brown', passport_data: '5544332211', address: '404 Elm St, CA'},
        {id: '5', full_name: 'Paul Davis', passport_data: '9988776655', address: '505 Cedar Ln, FL'},
        {id: '6', full_name: 'Nancy Martinez', passport_data: '6677889900', address: '606 Birch Ct, IL'},
        {id: '7', full_name: 'Kevin Thompson', passport_data: '3344556677', address: '707 Willow Way, OH'},
        {id: '8', full_name: 'Julia Clark', passport_data: '8899001122', address: '808 Rose Blvd, WA'},
        {id: '9', full_name: 'Daniel Hall', passport_data: '2233445566', address: '909 Lily Lane, AZ'},
        {id: '10', full_name: 'Rachel Young', passport_data: '7788990011', address: '1010 Sunnyside Ave, OR'},
        {id: '11', full_name: 'Mark Novikov', passport_data: '9911223344', address: '777 Elm St, NY'},
        {id: '12', full_name: 'Anna Sergeeva', passport_data: '8822334455', address: '888 Oak Ave, LA'},
        {id: '13', full_name: 'Ivan Petrov', passport_data: '1122334499', address: '555 Spruce St, NY'},
        {id: '14', full_name: 'Oleg Volkov', passport_data: '9988776644', address: '444 Fir St, NY'}
    ] AS clients
    UNWIND clients AS client
    CREATE (c:Client {
        id: client.id,
        full_name: client.full_name,
        passport_data: client.passport_data,
        address: client.address
    })
    RETURN count(c) as clients_created
$$) as (count agtype);


-- CaseType
SELECT *
FROM cypher('lawyer_graph', $$
    WITH [
        {id: '1', name: 'Robbery'},
        {id: '2', name: 'Divorce'},
        {id: '3', name: 'Contract Dispute'},
        {id: '4', name: 'Land Ownership'},
        {id: '5', name: 'Employment Issue'},
        {id: '6', name: 'Patent Infringement'},
        {id: '7', name: 'Tax Evasion'},
        {id: '8', name: 'Bankruptcy Proceedings'},
        {id: '9', name: 'Pollution Case'},
        {id: '10', name: 'Visa Application'},
        {id: '11', name: 'Adoption'}
    ] AS case_types
    UNWIND case_types AS ct
    CREATE (t:CaseType {
        id: ct.id,
        name: ct.name
    })
    RETURN count(t) as casetypes_created
$$) as (count agtype);


-- Specialization
SELECT *
FROM cypher('lawyer_graph', $$
    WITH [
        {id: '1', name: 'Criminal Law'},
        {id: '2', name: 'Family Law'},
        {id: '3', name: 'Corporate Law'},
        {id: '4', name: 'Real Estate Law'},
        {id: '5', name: 'Labor Law'},
        {id: '6', name: 'Intellectual Property'},
        {id: '7', name: 'Tax Law'},
        {id: '8', name: 'Bankruptcy Law'},
        {id: '9', name: 'Environmental Law'},
        {id: '10', name: 'Immigration Law'},
        {id: '11', name: 'Maritime Law'}
    ] AS specializations
    UNWIND specializations AS spec
    CREATE (s:Specialization {
        id: spec.id,
        name: spec.name
    })
    RETURN count(s) as specializations_created
$$) as (count agtype);

-- Case
SELECT *
FROM cypher('lawyer_graph', $$
    WITH [
        {id: '1', start_date: '2023-01-10', end_date: '2023-06-15', max_sentence: 5, actual_sentence: 3, fine_amount: 10000, case_type_id: '1', client_id: '1'},
        {id: '2', start_date: '2023-02-20', end_date: '2023-08-10', max_sentence: 0, actual_sentence: 0, fine_amount: 0, case_type_id: '2', client_id: '2'},
        {id: '3', start_date: '2023-03-05', end_date: '2023-09-20', max_sentence: 10, actual_sentence: 7, fine_amount: 50000, case_type_id: '3', client_id: '3'},
        {id: '4', start_date: '2023-04-12', end_date: '2023-11-01', max_sentence: 3, actual_sentence: 1, fine_amount: 25000, case_type_id: '4', client_id: '4'},
        {id: '5', start_date: '2023-05-18', end_date: '2023-12-05', max_sentence: 0, actual_sentence: 0, fine_amount: 0, case_type_id: '5', client_id: '5'},
        {id: '6', start_date: '2023-06-22', end_date: '2024-01-10', max_sentence: 8, actual_sentence: 6, fine_amount: 30000, case_type_id: '6', client_id: '6'},
        {id: '7', start_date: '2023-07-03', end_date: '2024-02-15', max_sentence: 0, actual_sentence: 0, fine_amount: 0, case_type_id: '7', client_id: '7'},
        {id: '8', start_date: '2023-08-15', end_date: '2024-03-20', max_sentence: 12, actual_sentence: 9, fine_amount: 75000, case_type_id: '8', client_id: '8'},
        {id: '9', start_date: '2023-09-28', end_date: '2024-04-12', max_sentence: 0, actual_sentence: 0, fine_amount: 0, case_type_id: '9', client_id: '9'},
        {id: '10', start_date: '2023-10-10', end_date: '2024-05-05', max_sentence: 4, actual_sentence: 2, fine_amount: 15000, case_type_id: '10', client_id: '10'},
        {id: '11', start_date: '2022-01-10', end_date: '2022-06-15', max_sentence: 5, actual_sentence: 3, fine_amount: 10000, case_type_id: '1', client_id: '1'},
        {id: '12', start_date: '2022-02-20', end_date: '2022-08-10', max_sentence: 0, actual_sentence: 0, fine_amount: 0, case_type_id: '2', client_id: '2'},
        {id: '13', start_date: '2022-03-05', end_date: '2022-09-20', max_sentence: 10, actual_sentence: 7, fine_amount: 50000, case_type_id: '3', client_id: '3'},
        {id: '14', start_date: '2022-04-12', end_date: '2022-11-01', max_sentence: 3, actual_sentence: 1, fine_amount: 10000, case_type_id: '1', client_id: '4'},
        {id: '15', start_date: '2022-05-18', end_date: '2022-12-05', max_sentence: 0, actual_sentence: 0, fine_amount: 0, case_type_id: '2', client_id: '5'},
        {id: '16', start_date: '2022-06-22', end_date: '2023-01-10', max_sentence: 8, actual_sentence: 6, fine_amount: 0, case_type_id: '2', client_id: '6'},
        {id: '17', start_date: '2022-07-03', end_date: '2023-02-15', max_sentence: 0, actual_sentence: 0, fine_amount: 25000, case_type_id: '4', client_id: '7'},
        {id: '18', start_date: '2022-08-15', end_date: '2023-03-20', max_sentence: 12, actual_sentence: 9, fine_amount: 50000, case_type_id: '3', client_id: '8'},
        {id: '19', start_date: '2022-09-28', end_date: '2023-04-12', max_sentence: 0, actual_sentence: 0, fine_amount: 0, case_type_id: '5', client_id: '9'},
        {id: '20', start_date: '2022-10-10', end_date: '2023-05-05', max_sentence: 4, actual_sentence: 2, fine_amount: 10000, case_type_id: '1', client_id: '10'},
        {id: '21', start_date: '2024-01-10', end_date: '2024-03-01', max_sentence: 0, actual_sentence: 0, fine_amount: 0, case_type_id: '2', client_id: '12'},
        {id: '22', start_date: '2025-10-01', end_date: null, max_sentence: 4, actual_sentence: 0, fine_amount: 15000, case_type_id: '1', client_id: '13'},
        {id: '23', start_date: '2022-08-01', end_date: '2023-03-16', max_sentence: 5, actual_sentence: 2, fine_amount: 12000, case_type_id: '1', client_id: '14'},
        {id: '24', start_date: '2024-05-01', end_date: '2024-10-20', max_sentence: 8, actual_sentence: 0, fine_amount: 0, case_type_id: '6', client_id: '11'},
        {id: '25', start_date: '2024-06-01', end_date: '2024-09-15', max_sentence: 0, actual_sentence: 0, fine_amount: 500, case_type_id: '5', client_id: '12'},
        {id: '26', start_date: '2024-07-01', end_date: '2024-11-01', max_sentence: 0, actual_sentence: 0, fine_amount: 20000, case_type_id: '3', client_id: '3'},
        {id: '27', start_date: '2024-08-01', end_date: '2024-10-01', max_sentence: 0, actual_sentence: 0, fine_amount: 100, case_type_id: '5', client_id: '5'}
    ] AS cases
    UNWIND cases AS cs
    CREATE (c:Case {
        id: cs.id,
        start_date: cs.start_date,
        end_date: cs.end_date,
        max_sentence: cs.max_sentence,
        actual_sentence: cs.actual_sentence,
        fine_amount: cs.fine_amount,
        case_type_id: cs.case_type_id,
        client_id: cs.client_id
    })
    RETURN count(c) as cases_created
$$) as (count agtype);


-- lawyer -> Case
SELECT *
FROM cypher('lawyer_graph', $$
    WITH [
        {lawyer_id: '1', case_id: '1'},
        {lawyer_id: '1', case_id: '2'},
        {lawyer_id: '2', case_id: '3'},
        {lawyer_id: '2', case_id: '4'},
        {lawyer_id: '3', case_id: '5'},
        {lawyer_id: '3', case_id: '6'},
        {lawyer_id: '4', case_id: '7'},
        {lawyer_id: '4', case_id: '8'},
        {lawyer_id: '5', case_id: '9'},
        {lawyer_id: '5', case_id: '10'},
        {lawyer_id: '9', case_id: '8'},
        {lawyer_id: '1', case_id: '22'},
        {lawyer_id: '1', case_id: '23'},
        {lawyer_id: '2', case_id: '24'},
        {lawyer_id: '7', case_id: '25'},
        {lawyer_id: '2', case_id: '26'},
        {lawyer_id: '6', case_id: '27'}
    ] AS works_on
    UNWIND works_on AS wo
    MATCH (l:Lawyer {id: wo.lawyer_id})
    MATCH (c:Case {id: wo.case_id})
    CREATE (l)-[:WORKS_ON]->(c)
    RETURN count(*) as works_on_created
$$) as (count agtype);


-- lawyer -> Client
SELECT *
FROM cypher('lawyer_graph', $$
    WITH [
        {lawyer_id: '1', client_id: '1', hire_date: '2023-01-01'},
        {lawyer_id: '1', client_id: '2', hire_date: '2023-02-05'},
        {lawyer_id: '2', client_id: '3', hire_date: '2023-03-10'},
        {lawyer_id: '2', client_id: '4', hire_date: '2023-04-15'},
        {lawyer_id: '3', client_id: '5', hire_date: '2023-05-20'},
        {lawyer_id: '3', client_id: '6', hire_date: '2023-06-25'},
        {lawyer_id: '4', client_id: '7', hire_date: '2023-07-30'},
        {lawyer_id: '4', client_id: '8', hire_date: '2023-08-05'},
        {lawyer_id: '5', client_id: '9', hire_date: '2023-09-10'},
        {lawyer_id: '5', client_id: '10', hire_date: '2023-10-15'}
    ] AS represents
    UNWIND represents AS rep
    MATCH (l:Lawyer {id: rep.lawyer_id})
    MATCH (c:Client {id: rep.client_id})
    CREATE (l)-[r:REPRESENTS {hire_date: rep.hire_date}]->(c)
    RETURN count(r) as represents_created
$$) as (count agtype);


-- lawyer -> specialization
SELECT *
FROM cypher('lawyer_graph', $$
    WITH [
        {lawyer_id: '1', specialization_id: '1'},
        {lawyer_id: '1', specialization_id: '2'},
        {lawyer_id: '2', specialization_id: '3'},
        {lawyer_id: '2', specialization_id: '4'},
        {lawyer_id: '3', specialization_id: '5'},
        {lawyer_id: '3', specialization_id: '6'},
        {lawyer_id: '4', specialization_id: '7'},
        {lawyer_id: '4', specialization_id: '8'},
        {lawyer_id: '5', specialization_id: '9'},
        {lawyer_id: '5', specialization_id: '10'},
        {lawyer_id: '9', specialization_id: '8'}
    ] AS specializations
    UNWIND specializations AS spec
    MATCH (l:Lawyer {id: spec.lawyer_id})
    MATCH (s:Specialization {id: spec.specialization_id})
    CREATE (l)-[:HAS_SPECIALIZATION]->(s)
    RETURN count(*) as specializations_created
$$) as (count agtype);


-- Case -> CaseType
SELECT *
FROM cypher('lawyer_graph', $$
    MATCH (c:Case)
    WITH c, c.case_type_id as type_id
    MATCH (t:CaseType {id: type_id})
    CREATE (c)-[:HAS_TYPE]->(t)
    RETURN count(*) as has_type_created
$$) as (count agtype);


-- client -> Case
SELECT *
FROM cypher('lawyer_graph', $$
    MATCH (c:Case)
    WITH c, c.client_id as client_id
    MATCH (cl:Client {id: client_id})
    CREATE (c)-[:BELONGS_TO]->(cl)
    RETURN count(*) as belongs_to_created
$$) as (count agtype);
```

### Запросы
a)  Вывести для каждого адвоката список текущих клиентов (дела по которым еще не закончены)
```
SELECT *
FROM cypher('lawyer_graph', $$
    MATCH (l:Lawyer)-[:WORKS_ON]->(c:Case)-[:BELONGS_TO]->(cl:Client)
    WHERE c.end_date IS NULL OR c.end_date > '2025-12-15'
    RETURN 
        l.full_name as lawyer_name,
        cl.full_name as client_name,
        c.id as case_id
    ORDER BY l.full_name, cl.full_name
$$) as (lawyer_name agtype, client_name agtype, case_id agtype);
```
Старый вывод:

![a-old](/6/a-old.png)

Новый вывод:

![a-new](/6/a-new.png)


b)  Найти адвокатов, у которых на данный момент нет клиентов

```
SELECT *
FROM cypher('lawyer_graph', $$
    MATCH (l:Lawyer)
    WHERE NOT EXISTS {
        MATCH (l)-[:WORKS_ON]->(c:Case)
        WHERE c.end_date IS NULL OR c.end_date > '2025-12-15'
    }
    RETURN 
        l.full_name as lawyer_name
    ORDER BY l.full_name
$$) as (lawyer_name agtype);
```
Старый вывод:

![b-old](/6/b-old.png)

Новый вывод:

![b-new](/6/b-new.png)


c)  Найти клиентов с самыми «длинными» делами

```
--Из-за особенностей AGE нельзя делать подзапрос в запросе, поэтому так
SELECT DISTINCT full_name, t1.d AS max_duration
FROM (
    SELECT *
    FROM cypher('lawyer_graph', $$
        MATCH (c:Case)-[:BELONGS_TO]->(cl:Client)
        WHERE c.end_date IS NOT NULL
        RETURN c.id, cl.full_name, (c.end_date::date - c.start_date::date) AS d
    $$) AS (case_id agtype, full_name agtype, d agtype)
) AS t1
WHERE t1.d = (
    SELECT duration_days
    FROM cypher('lawyer_graph', $$
        MATCH (c:Case)
        WHERE c.end_date IS NOT NULL
        RETURN MAX(c.end_date::date - c.start_date::date) AS duration_days
    $$) AS (duration_days agtype)
);
```
Старый вывод:

![c-old](/6/c-old.png)

Новый вывод:

![c-new](/6/c-new.png)


d)  Найти наиболее успешных адвокатов (наибольшая разница между максимальным и полученным сроком, наибольшее кол-во оправданий,минимальная сумма штрафов)

```
SELECT (full_name), 'max sentence reduction' AS reason
FROM cypher('lawyer_graph', $$
    MATCH (l:Lawyer)-[:WORKS_ON]->(c:Case)
    WHERE c.max_sentence > 0
    RETURN l.full_name, SUM(c.max_sentence - c.actual_sentence) AS reduction
    ORDER BY reduction DESC
    LIMIT 1
$$) AS (full_name agtype, reduction agtype)

UNION ALL

SELECT full_name, 'most acquittals' AS reason
FROM cypher('lawyer_graph', $$
    MATCH (l:Lawyer)-[:WORKS_ON]->(c:Case)
    WHERE c.max_sentence > 0 AND c.actual_sentence = 0
    RETURN l.full_name, COUNT(*) AS acquittals
    ORDER BY acquittals DESC
    LIMIT 1
$$) AS (full_name agtype, acquittals agtype)

UNION ALL

SELECT full_name, 'lowest total fine' AS reason
FROM cypher('lawyer_graph', $$
    MATCH (l:Lawyer)-[:WORKS_ON]->(c:Case)
    WHERE c.fine_amount > 0
    RETURN l.full_name, SUM(c.fine_amount) AS total_fine
    ORDER BY total_fine ASC
    LIMIT 1
$$) AS (full_name agtype, total_fine agtype);

```
Старый вывод:

![d-old](/6/d-old.png)

Новый вывод:

![d-new](/6/d-new.png)



e)  Найти наиболее востребованных адвокатов (количество дел для которых > чем среднее количество дел на адвоката в конторе)


```
SELECT full_name, (cnt)::text::int AS cases_count
FROM cypher('lawyer_graph', $$
    MATCH (l:Lawyer)-[:WORKS_ON]->(c:Case)
    RETURN l.full_name, COUNT(c) AS cnt
$$) AS (full_name agtype, cnt agtype)
WHERE (cnt)::text::int > (
    SELECT AVG(cases_count) AS avg_cases
    FROM (
        SELECT (cnt2)::text::int AS cases_count
        FROM cypher('lawyer_graph', $$
            MATCH (l2:Lawyer)
            OPTIONAL MATCH (l2)-[:WORKS_ON]->(c2:Case)
            RETURN l2, COUNT(c2) AS cnt2
        $$) AS (l2 agtype, cnt2 agtype)
    ) AS avg_sub
);
```
Старый вывод:

![e-old](/6/e-old.png)

Новый вывод:

![e-new](/6/e-new.png)


## Lab 7 (PGSQL)
### Задание 1
[Отчёт](/7/1.docx)

Скрипт адания 1
```
SELECT * FROM Lawyer;

BEGIN;

DELETE FROM Lawyer WHERE id = 10;
SELECT * FROM Lawyer WHERE id = 10;

ROLLBACK;

SELECT * FROM Lawyer WHERE id = 10;

-- Новая транзакция
BEGIN;

DELETE FROM Lawyer WHERE id = 10;
SELECT * FROM Lawyer WHERE id = 10;

SAVEPOINT sp1;

DELETE FROM Lawyer WHERE id = 5;
SELECT id, full_name FROM Lawyer WHERE id IN (5, 10);

ROLLBACK TO SAVEPOINT sp1;
SELECT * FROM Lawyer WHERE id IN (5, 10);

ROLLBACK;
SELECT * FROM Lawyer WHERE id IN (5, 10);

COMMIT;

SELECT id, full_name FROM Lawyer WHERE id IN (5, 10);
```
### Задание 2
[Отчёт](/7/2.docx)

Скрипт задания 2
```
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
```
