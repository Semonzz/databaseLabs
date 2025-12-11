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

---------------------------------------------

DROP FUNCTION get_max_sentence_cases;

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

----------------------------------------

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