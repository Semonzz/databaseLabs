TRUNCATE TABLE Lawyer_Case, Lawyer_Specialization, Lawyer_Client, "Case", Client, Lawyer, CaseType, Specialization
RESTART IDENTITY CASCADE;

INSERT INTO Lawyer (full_name, phone, address, start_date, qualification, is_active)
VALUES
    ('John Smith', '+1234567890', '123 Main St, NY', '2015-03-15', 8.5, true),
    ('Emily Davis', '+1234567891', '456 Oak Ave, LA', '2016-07-20', 9.2, true),
    ('Michael Brown', '+1234567892', '789 Pine Rd, TX', '2014-01-10', 7.8, true),
    ('Sarah Wilson', '+1234567893', '321 Elm St, CA', '2017-11-05', 9.0, true),
    ('David Johnson', '+1234567894', '654 Maple Dr, FL', '2018-04-12', 8.0, true),
    ('Lisa Miller', '+1234567895', '987 Cedar Ln, IL', '2019-09-03', 8.7, true),
    ('Robert Taylor', '+1234567896', '246 Birch Ct, OH', '2013-08-22', 9.5, true),
    ('Jennifer White', '+1234567897', '135 Willow Way, WA', '2020-02-14', 7.9, true),
    ('Thomas Lee', '+1234567898', '111 Rose Blvd, AZ', '2016-12-08', 8.5, true),
    ('Susan Harris', '+1234567899', '222 Lily Lane, OR', '2017-06-18', 8.8, true);

INSERT INTO Client (full_name, passport_data, address)
VALUES
    ('Alex Johnson', '1234567890', '101 Pine St, NY'),
    ('Maria Garcia', '0987654321', '202 Oak Ave, LA'),
    ('James Wilson', '1122334455', '303 Maple Dr, TX'),
    ('Linda Brown', '5544332211', '404 Elm St, CA'),
    ('Paul Davis', '9988776655', '505 Cedar Ln, FL'),
    ('Nancy Martinez', '6677889900', '606 Birch Ct, IL'),
    ('Kevin Thompson', '3344556677', '707 Willow Way, OH'),
    ('Julia Clark', '8899001122', '808 Rose Blvd, WA'),
    ('Daniel Hall', '2233445566', '909 Lily Lane, AZ'),
    ('Rachel Young', '7788990011', '1010 Sunnyside Ave, OR'),
    ('Mark Novikov', '9911223344', '777 Elm St, NY'),
    ('Anna Sergeeva', '8822334455', '888 Oak Ave, LA'),
    ('Ivan Petrov', '1122334499', '555 Spruce St, NY'),
    ('Oleg Volkov', '9988776644', '444 Fir St, NY');

INSERT INTO CaseType (name)
VALUES
    ('Robbery'),
    ('Divorce'),
    ('Contract Dispute'),
    ('Land Ownership'),
    ('Employment Issue'),
    ('Patent Infringement'),
    ('Tax Evasion'),
    ('Bankruptcy Proceedings'),
    ('Pollution Case'),
    ('Visa Application'),
    ('Adoption');

INSERT INTO "Case" (start_date, end_date, max_sentence, actual_sentence, fine_amount, case_type_id, client_id)
VALUES
    ('2023-01-10', '2023-06-15', 5, 3, 10000, 1, 1),
    ('2023-02-20', '2023-08-10', 0, 0, 0, 2, 2),
    ('2023-03-05', '2023-09-20', 10, 7, 50000, 3, 3),
    ('2023-04-12', '2023-11-01', 3, 1, 25000, 4, 4),
    ('2023-05-18', '2023-12-05', 0, 0, 0, 5, 5),
    ('2023-06-22', '2024-01-10', 8, 6, 30000, 6, 6),
    ('2023-07-03', '2024-02-15', 0, 0, 0, 7, 7),
    ('2023-08-15', '2024-03-20', 12, 9, 75000, 8, 8),
    ('2023-09-28', '2024-04-12', 0, 0, 0, 9, 9),
    ('2023-10-10', '2024-05-05', 4, 2, 15000, 10, 10),
    ('2022-01-10', '2022-06-15', 5, 3, 10000, 1, 1),
    ('2022-02-20', '2022-08-10', 0, 0, 0, 2, 2),
    ('2022-03-05', '2022-09-20', 10, 7, 50000, 3, 3),
    ('2022-04-12', '2022-11-01', 3, 1, 10000, 1, 4),
    ('2022-05-18', '2022-12-05', 0, 0, 0, 2, 5),
    ('2022-06-22', '2023-01-10', 8, 6, 0, 2, 6),
    ('2022-07-03', '2023-02-15', 0, 0, 25000, 4, 7),
    ('2022-08-15', '2023-03-20', 12, 9, 50000, 3, 8),
    ('2022-09-28', '2023-04-12', 0, 0, 0, 5, 9),
    ('2022-10-10', '2023-05-05', 4, 2, 10000, 1, 10),
    ('2024-01-10', '2024-03-01', 0, 0, 0, 2, 12),
    ('2025-10-01', NULL, 4, 0, 15000, 1, 13),
    ('2022-08-01', '2023-03-16', 5, 2, 12000, 1, 14),
    ('2024-05-01', '2024-10-20', 8, 0, 0, 6, 11),
    ('2024-06-01', '2024-09-15', 0, 0, 500, 5, 12),
    ('2024-07-01', '2024-11-01', 0, 0, 20000, 3, 3),
    ('2024-08-01', '2024-10-01', 0, 0, 100, 5, 5);

INSERT INTO Specialization (name)
VALUES
    ('Criminal Law'),
    ('Family Law'),
    ('Corporate Law'),
    ('Real Estate Law'),
    ('Labor Law'),
    ('Intellectual Property'),
    ('Tax Law'),
    ('Bankruptcy Law'),
    ('Environmental Law'),
    ('Immigration Law'),
    ('Maritime Law');

INSERT INTO Lawyer_Case (lawyer_id, case_id)
VALUES
    (1, 1),
    (1, 2),
    (2, 3),
    (2, 4),
    (3, 5),
    (3, 6),
    (4, 7),
    (4, 8),
    (5, 9),
    (5, 10),
    (9, 8),
    (1, 22),
    (1, 23),
    (2, 24),
    (7, 25),
	(2, 26),
	(6, 27);

INSERT INTO Lawyer_Client (lawyer_id, client_id, hire_date)
VALUES
    (1, 1, '2023-01-01'),
    (1, 2, '2023-02-05'),
    (2, 3, '2023-03-10'),
    (2, 4, '2023-04-15'),
    (3, 5, '2023-05-20'),
    (3, 6, '2023-06-25'),
    (4, 7, '2023-07-30'),
    (4, 8, '2023-08-05'),
    (5, 9, '2023-09-10'),
    (5, 10, '2023-10-15');

INSERT INTO Lawyer_Specialization (lawyer_id, specialization_id)
VALUES
    (1, 1),
    (1, 2),
    (2, 3),
    (2, 4),
    (3, 5),
    (3, 6),
    (4, 7),
    (4, 8),
    (5, 9),
    (5, 10),
    (9, 8);