

# Database Labs

Database Labs in YarSU, Semenov Evgeniy, PMI-32, Lab number 13.

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
    qualification REAL CHECK (qualification >= 0)
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
    case_type_id INTEGER REFERENCES CaseType(id) ON DELETE SET NULL,
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
    lawyer_id INTEGER REFERENCES Lawyer(id) ON DELETE RESTRICT,
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
