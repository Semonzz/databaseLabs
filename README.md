
# Database Labs

Database Labs in YarSU, Semenov Evgeniy, PMI-32, Lab number 13.

## Lab 1
### ER-model:
![ER-model](https://github.com/Semonzz/databaseLabs/blob/main/1/1.png)
### Relational model:
![REL-model](https://github.com/Semonzz/databaseLabs/blob/main/1/2_1.png)


## Lab 2
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
    passport_data VARCHAR(20),
    address VARCHAR(200)
);


CREATE TABLE "Case" (
    number SERIAL PRIMARY KEY,
    start_date DATE NOT NULL,
    end_date DATE,
    max_sentence INT CHECK (max_sentence >= 0),
    actual_sentence INT CHECK (actual_sentence >= 0),
    fine_amount INT CHECK (fine_amount >= 0),
    case_type_id INTEGER REFERENCES CaseType(id) ON DELETE SET NULL,
    client_id INTEGER REFERENCES Client(id) ON DELETE CASCADE
);


CREATE TABLE Lawyer_Client (
    lawyer_id INTEGER REFERENCES Lawyer(id) ON DELETE CASCADE,
    client_id INTEGER REFERENCES Client(id) ON DELETE CASCADE,
    hire_date DATE NOT NULL,
    PRIMARY KEY (lawyer_id, client_id)
);


CREATE TABLE Lawyer_Case (
    lawyer_id INTEGER REFERENCES Lawyer(id) ON DELETE CASCADE,
    case_number INTEGER REFERENCES "Case"(number) ON DELETE CASCADE,
    PRIMARY KEY (lawyer_id, case_number)
);


CREATE TABLE Lawyer_Specialization (
    lawyer_id INTEGER REFERENCES Lawyer(id) ON DELETE CASCADE,
    specialization_id INTEGER REFERENCES Specialization(id) ON DELETE CASCADE,
    PRIMARY KEY (lawyer_id, specialization_id)
);
```
