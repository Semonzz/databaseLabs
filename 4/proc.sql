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

----------------------------------------------------

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

---------------------------------------------------


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

----------------------------------------------------

drop procedure lawyers_below_average;
 
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


