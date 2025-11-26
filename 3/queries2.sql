--a
SELECT
    l.full_name AS lawyer,
    cl.full_name AS client
FROM Lawyer l
JOIN Lawyer_Case lc ON l.id = lc.lawyer_id
JOIN "Case" ca ON lc.case_id = ca.id
JOIN Client cl ON ca.client_id = cl.id
WHERE ca.end_date IS NULL;


-- b
SELECT l.full_name
FROM Lawyer l
WHERE l.id NOT IN (
    SELECT DISTINCT lc.lawyer_id
    FROM Lawyer_Case lc
    JOIN "Case" ca ON lc.case_id = ca.id
    WHERE ca.end_date IS NULL OR ca.end_date > CURRENT_DATE
);

-- c

SELECT DISTINCT
    cl.full_name,
    ca.end_date - ca.start_date AS "Max duration"
FROM "Case" ca
JOIN Client cl ON ca.client_id = cl.id
WHERE ca.end_date IS NOT NULL
  AND ca.end_date - ca.start_date = (
      SELECT MAX(end_date - start_date)
      FROM "Case"
      WHERE end_date IS NOT NULL
  );


--d

(
    SELECT l.full_name, 'max sentence reduction' AS reason
    FROM Lawyer l
    JOIN Lawyer_Case lc ON l.id = lc.lawyer_id
    JOIN "Case" ca ON lc.case_id = ca.id
    WHERE ca.max_sentence > 0
    GROUP BY l.id, l.full_name
    ORDER BY SUM(ca.max_sentence - ca.actual_sentence) DESC
    LIMIT 1
)
UNION ALL
(
    SELECT l.full_name, 'most acquittals' AS reason
    FROM Lawyer l
    JOIN Lawyer_Case lc ON l.id = lc.lawyer_id
    JOIN "Case" ca ON lc.case_id = ca.id
    WHERE ca.max_sentence > 0 AND ca.actual_sentence = 0
    GROUP BY l.id, l.full_name
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
UNION ALL
(
    SELECT l.full_name, 'lowest total fine' AS reason
    FROM Lawyer l
    JOIN Lawyer_Case lc ON l.id = lc.lawyer_id
    JOIN "Case" ca ON lc.case_id = ca.id
    WHERE ca.fine_amount > 0
    GROUP BY l.id, l.full_name
    ORDER BY SUM(ca.fine_amount) ASC
    LIMIT 1
);


-- e
SELECT l.full_name, COUNT(lc.case_id) AS cases_count
FROM Lawyer l
JOIN Lawyer_Case lc ON l.id = lc.lawyer_id
GROUP BY l.id, l.full_name
HAVING COUNT(lc.case_id) > (
    SELECT AVG(case_count)
    FROM (
        SELECT COUNT(case_id) AS case_count
        FROM Lawyer
        LEFT JOIN Lawyer_Case ON Lawyer.id = Lawyer_Case.lawyer_id
        GROUP BY Lawyer.id
    ) avg_sub
);




