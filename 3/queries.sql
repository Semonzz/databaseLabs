-- 1.1
SELECT full_name, qualification, start_date
FROM Lawyer
ORDER BY qualification DESC, full_name ASC;

-- 1.2

SELECT full_name, qualification
FROM Lawyer
WHERE qualification > 8.5;

SELECT id, actual_sentence 
FROM "Case"
WHERE actual_sentence > 0;

-- 1.3
SELECT MAX(qualification) AS max_qualification
FROM Lawyer;

SELECT EXTRACT(YEAR FROM start_date) AS start_year, COUNT(*) AS lawyer_count
FROM Lawyer
WHERE EXTRACT(YEAR FROM start_date) = 2016
GROUP BY EXTRACT(YEAR FROM start_date);

-- 1.4
SELECT fine_amount, actual_sentence, COUNT(*) AS case_count
FROM "Case"
GROUP BY ROLLUP(fine_amount, actual_sentence)
ORDER BY fine_amount NULLS LAST, actual_sentence NULLS LAST;

-- 1.5
SELECT name
FROM Specialization
WHERE name NOT LIKE '%Law%';

SELECT id, name
FROM CaseType
WHERE name NOT ILIKE '%ivorce%'

-- 2.1
SELECT 
    c.id AS case_id,
    cl.full_name AS client_name,
    ct.name AS case_type_name,
    c.start_date,
    c.end_date
FROM "Case" c, Client cl, CaseType ct
WHERE c.client_id = cl.id
  AND c.case_type_id = ct.id;

SELECT 
    l.full_name AS lawyer_name,
    s.name AS specialization
FROM Lawyer l, Specialization s, Lawyer_Specialization ls
WHERE ls.lawyer_id = l.id
  AND ls.specialization_id = s.id;


-- 2.2
SELECT 
    c.id AS case_id,
    cl.full_name AS client_name,
    ct.name AS case_type_name,
    c.start_date,
    c.end_date
FROM "Case" c
INNER JOIN Client cl ON c.client_id = cl.id
INNER JOIN CaseType ct ON c.case_type_id = ct.id;

SELECT  
	l.full_name AS lawyer_name,
    s.name AS specialization
FROM Lawyer l
INNER JOIN Lawyer_Specialization ls ON ls.lawyer_id = l.id
INNER JOIN Specialization s ON ls.specialization_id = s.id;

-- 2.3
SELECT 
    l.full_name AS lawyer,
    cl.full_name AS client,
    lc.hire_date
FROM Lawyer l
LEFT JOIN Lawyer_Client lc ON l.id = lc.lawyer_id
LEFT JOIN Client cl ON lc.client_id = cl.id;

-- 2.4
SELECT 
    ct.name AS case_type,
    c.id AS case_id,
    c.start_date
FROM "Case" c
RIGHT JOIN CaseType ct ON c.case_type_id = ct.id;

SELECT 
    s.name AS specialization,
    l.full_name AS lawyer
FROM Lawyer l
RIGHT JOIN Lawyer_Specialization ls ON l.id = ls.lawyer_id
RIGHT JOIN Specialization s ON ls.specialization_id = s.id;

-- 2.5
SELECT 
    s.name AS specialization,
    AVG(l.qualification) AS avg_qualification
FROM Specialization s
LEFT JOIN Lawyer_Specialization ls ON s.id = ls.specialization_id
LEFT JOIN Lawyer l ON ls.lawyer_id = l.id
GROUP BY s.id, s.name;

SELECT 
    ct.name AS case_type,
    COUNT(c.id) AS case_count
FROM CaseType ct
LEFT JOIN "Case" c ON ct.id = c.case_type_id
GROUP BY ct.id, ct.name;

-- 2.6
SELECT 
    s.name AS specialization,
    AVG(l.qualification) AS avg_qualification
FROM Specialization s
LEFT JOIN Lawyer_Specialization ls ON s.id = ls.specialization_id
LEFT JOIN Lawyer l ON ls.lawyer_id = l.id
GROUP BY s.id, s.name
HAVING AVG(l.qualification) > 8;
 
SELECT 
    ct.name AS case_type,
    COUNT(c.id) AS case_count
FROM CaseType ct
LEFT JOIN "Case" c ON ct.id = c.case_type_id
GROUP BY ct.id, ct.name
HAVING COUNT(c.id) > 2;

-- 2.7
SELECT *
FROM "Case" c
WHERE c.id IN (
    SELECT lc.case_id
    FROM Lawyer_Case lc
    JOIN Lawyer l ON lc.lawyer_id = l.id
    WHERE l.qualification > 9.0
);

SELECT l.full_name
FROM Lawyer l
WHERE EXISTS (
    SELECT 1
    FROM Lawyer_Case lc
    WHERE lc.lawyer_id = l.id
);

-- 3.1
CREATE VIEW case_with_client_and_type AS
SELECT 
    c.id AS case_id,
    cl.full_name AS client_name,
    ct.name AS case_type_name,
    c.start_date,
    c.end_date
FROM "Case" c
INNER JOIN Client cl ON c.client_id = cl.id
INNER JOIN CaseType ct ON c.case_type_id = ct.id;

SELECT * FROM case_with_client_and_type
WHERE case_type_name = 'Employment Issue';

CREATE VIEW lawyer_specialization_list AS
SELECT  
    l.full_name AS lawyer_name,
    s.name AS specialization
FROM Lawyer l
INNER JOIN Lawyer_Specialization ls ON ls.lawyer_id = l.id
INNER JOIN Specialization s ON ls.specialization_id = s.id;

SELECT lawyer_name FROM lawyer_specialization_list
WHERE specialization = 'Criminal Law';

-- 3.2
WITH high_qual_lawyers AS (
    SELECT id
    FROM Lawyer
    WHERE qualification > 9.0
),
cases_by_top_lawyers AS (
    SELECT DISTINCT lc.case_id
    FROM Lawyer_Case lc
    INNER JOIN high_qual_lawyers hql ON lc.lawyer_id = hql.id
)
SELECT c.*
FROM "Case" c
INNER JOIN cases_by_top_lawyers ctl ON c.id = ctl.case_id;

WITH case_counts AS (
    SELECT 
        ct.name AS case_type,
        COUNT(c.id) AS case_count
    FROM CaseType ct
    LEFT JOIN "Case" c ON ct.id = c.case_type_id
    GROUP BY ct.id, ct.name
)
SELECT case_type, case_count
FROM case_counts
WHERE case_count > 2;

-- 4.1
SELECT 
    l.full_name AS lawyer_name,
    s.name AS specialization,
    l.qualification,
    RANK() OVER (PARTITION BY s.name ORDER BY l.qualification DESC) AS rnk
FROM Lawyer l
JOIN Lawyer_Specialization ls ON l.id = ls.lawyer_id
JOIN Specialization s ON ls.specialization_id = s.id
ORDER BY s.name, rnk;

SELECT 
    case_type,
    client,
    case_id,
    fine_amount
FROM (
    SELECT 
        ct.name AS case_type,
        cl.full_name AS client,
        c.id AS case_id,
        c.fine_amount,
        ROW_NUMBER() OVER (
            PARTITION BY ct.name 
            ORDER BY c.fine_amount DESC
        ) AS rn
    FROM "Case" c
    JOIN Client cl ON c.client_id = cl.id
    JOIN CaseType ct ON c.case_type_id = ct.id
    WHERE c.fine_amount > 0
) ranked
WHERE rn = 1
ORDER BY fine_amount DESC;

-- 5.1
SELECT c.id AS case_id, 'Robbery' AS source_type 
FROM "Case" c
JOIN CaseType ct ON c.case_type_id = ct.id
WHERE ct.name = 'Robbery'

UNION ALL

SELECT c.id AS case_id, 'Divorce' AS source_type 
FROM "Case" c
JOIN CaseType ct ON c.case_type_id = ct.id
WHERE ct.name = 'Divorce'
ORDER BY 1;


SELECT full_name FROM Lawyer
EXCEPT
SELECT l.full_name 
FROM Lawyer l
JOIN Lawyer_Case lc ON l.id = lc.lawyer_id
ORDER BY full_name;
