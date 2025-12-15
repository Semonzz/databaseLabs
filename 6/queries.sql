LOAD 'age';
SET search_path = ag_catalog, "$user", public;

--a
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

--b
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


--с Из-за особенностей AGE нельзя делать подзапрос в запросе, поэтому так
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


--d

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


--e

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
