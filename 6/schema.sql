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
