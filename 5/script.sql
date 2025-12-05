CREATE USER user_manager WITH PASSWORD '1234567';
CREATE USER user_employee WITH PASSWORD '1234567';

CREATE ROLE role_manager;
CREATE ROLE role_employee;


GRANT role_manager TO user_manager;
GRANT role_employee TO user_employee;

GRANT USAGE ON SCHEMA public TO role_manager;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO role_manager;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO role_manager;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO role_manager;


GRANT CONNECT ON DATABASE lab TO user_manager, user_employee;

GRANT USAGE ON SCHEMA public TO role_employee;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO role_employee;


GRANT INSERT ON Client TO role_employee;

GRANT INSERT ON "Case" TO role_employee;

GRANT UPDATE (end_date) ON "Case" TO role_employee;

REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM role_employee;

REVOKE SELECT ON 
    Lawyer, 
    Client, 
    "Case", 
    CaseType,
    Lawyer_Case
FROM role_employee;

GRANT INSERT ON Client TO role_employee;
GRANT INSERT ON "Case" TO role_employee;

--------
DROP VIEW IF EXISTS  manager_clients_full;
CREATE OR REPLACE VIEW manager_clients_full AS
SELECT 
    id,
    full_name as "Full name",
    passport_data as "Passport",
    address as "Address"
FROM Client
ORDER BY id;

DROP VIEW IF EXISTS  employee_clients_masked;
CREATE OR REPLACE VIEW employee_clients_masked AS
SELECT 
    id,

    CASE 
        WHEN full_name LIKE '% %' 
        THEN LEFT(full_name, 1) || '. ' || SPLIT_PART(full_name, ' ', 2)
        ELSE LEFT(full_name, 1) || '.***'
    END as "Name",
    
    '******' || RIGHT(passport_data, 4) as "Passport",
    
    CASE 
        WHEN address LIKE '%,%' 
        THEN 'City:' || SPLIT_PART(address, ',', 2)
        ELSE 'Address is gidden'
    END as City
FROM Client
ORDER BY id;

---------------------

DROP FUNCTION IF EXISTS get_lawyer_details(INT);
CREATE OR REPLACE FUNCTION get_lawyer_details(input_lawyer_id INT DEFAULT NULL)
RETURNS TABLE (
    lawyer_id INT,
    full_name VARCHAR(50),
    phone VARCHAR(15),
    address VARCHAR(200),
    experience_years INT,
    qualification VARCHAR(20),
    status VARCHAR(20)
)
SECURITY DEFINER
AS $$
BEGIN
    IF current_user = 'user_manager' THEN
        RETURN QUERY SELECT l.id, l.full_name, l.phone, l.address,
            EXTRACT(YEAR FROM age(CURRENT_DATE, l.start_date))::INT,
            (l.qualification::VARCHAR || '/10')::VARCHAR(20),
            CASE WHEN l.is_active THEN 'Active' ELSE 'Inactive' END::VARCHAR(20)
        FROM Lawyer l WHERE input_lawyer_id IS NULL OR l.id = input_lawyer_id;
    ELSE
        RETURN QUERY SELECT l.id, l.full_name,
            CONCAT(LEFT(l.phone, 4), '****', RIGHT(l.phone, 3))::VARCHAR(15),
            CASE WHEN position(',' in l.address) > 0 
                THEN 'City: ' || TRIM(SPLIT_PART(l.address, ',', 2))
                ELSE 'Address hidden' END::VARCHAR(200),
            EXTRACT(YEAR FROM age(CURRENT_DATE, l.start_date))::INT,
            CASE WHEN l.qualification >= 9.0 THEN 'High'
                WHEN l.qualification >= 6.0 THEN 'Medium'
                ELSE 'Low' END::VARCHAR(20),
            'Employee'::VARCHAR(20)
        FROM Lawyer l WHERE input_lawyer_id IS NULL OR l.id = input_lawyer_id;
    END IF;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION get_lawyer_details(INT) TO role_manager, role_employee;


----------------------

GRANT SELECT ON manager_clients_full TO role_manager;
GRANT SELECT ON employee_clients_masked TO role_manager;

GRANT SELECT ON employee_clients_masked TO role_employee;

-----------------------
SET ROLE user_manager;

SELECT * FROM manager_clients_full WHERE id < 4;

SELECT * FROM employee_clients_masked WHERE id < 4;

SELECT id, full_name, passport_data FROM Client WHERE id < 4;

SELECT * FROM get_lawyer_details(1);

-----------
SET ROLE user_employee;

SELECT * FROM manager_clients_full WHERE id < 4;

SELECT * FROM employee_clients_masked WHERE id < 4;

SELECT id, full_name, passport_data FROM Client WHERE id < 4;

SELECT * FROM get_lawyer_details(1);

RESET ROLE;