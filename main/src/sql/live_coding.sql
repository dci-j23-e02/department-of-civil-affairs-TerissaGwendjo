--Step 1: Create the Database Schema
--You will create three tables: Persons, Births, and Marriages.

CREATE TABLE Persons (
                         PersonID SERIAL PRIMARY KEY,
                         FirstName VARCHAR(100),
                         LastName VARCHAR(100),
                         DateOfBirth DATE
);

CREATE TABLE Births (
                        BirthID SERIAL PRIMARY KEY,
                        PersonID INT,
                        BirthDate DATE,
                        BirthPlace VARCHAR(255),
                        FOREIGN KEY (PersonID) REFERENCES Persons(PersonID)
);

CREATE TABLE Marriages (
                           MarriageID SERIAL PRIMARY KEY,
                           PersonID1 INT,
                           PersonID2 INT,
                           MarriageDate DATE,
                           MarriagePlace VARCHAR(255),
                           FOREIGN KEY (PersonID1) REFERENCES Persons(PersonID),
                           FOREIGN KEY (PersonID2) REFERENCES Persons(PersonID)
);


-- Insert sample data into the Persons, Births, and Marriages tables.

-- Insert Persons
INSERT INTO Persons (FirstName, LastName, DateOfBirth) VALUES ('Alice', 'Müller', '1990-01-01');
INSERT INTO Persons (FirstName, LastName, DateOfBirth) VALUES ('Bob', 'Schmidt', '1992-05-15');
INSERT INTO Persons (FirstName, LastName, DateOfBirth) VALUES ('Carol', 'Becker', '1995-07-23');

-- Insert Births
INSERT INTO Births (PersonID, BirthDate, BirthPlace) VALUES (1, '1990-01-01', 'Berlin');
INSERT INTO Births (PersonID, BirthDate, BirthPlace) VALUES (2, '1992-05-15', 'Munich');
INSERT INTO Births (PersonID, BirthDate, BirthPlace) VALUES (3, '1995-07-23', 'Cologne');

-- Insert Marriages
INSERT INTO Marriages (PersonID1, PersonID2, MarriageDate, MarriagePlace) VALUES (1, 2, '2015-08-30', 'Hamburg');

--Step 3: Query Optimization
--Create different types of indexes and observe their effects.

-- Single-Column Index on LastName in Persons
CREATE INDEX idx_lastname ON Persons(LastName);

-- Multi-Column Index on BirthDate and BirthPlace in Births
CREATE INDEX idx_birthdate_place ON Births(BirthDate, BirthPlace);

-- Unique Index on MarriageID in Marriages
CREATE UNIQUE INDEX idx_marriageid ON Marriages(MarriageID);


--Step 4: Query Analysis
--Use the EXPLAIN command to analyze the execution plan of a query.

EXPLAIN SELECT * FROM Persons WHERE LastName = 'Müller';


--Step 5: Advanced Querying
--Demonstrate the use of combined queries and subqueries.

-- Find all persons who are married and were born in Berlin
SELECT p.* FROM Persons p
                    JOIN Births b ON p.PersonID = b.PersonID
WHERE b.BirthPlace = 'Berlin' AND p.PersonID IN (
    SELECT PersonID1 FROM Marriages
    UNION
    SELECT PersonID2 FROM Marriages
);

--Task 6: Implement Partial Indexes
--Create a partial index on the Persons table to optimize queries for persons born after the year 2000.

CREATE INDEX idx_young_persons ON Persons(DateOfBirth)
    WHERE DateOfBirth >= '2000-01-01';


--Task 9: Query Optimization with EXPLAIN ANALYZE
--Run EXPLAIN ANALYZE on a complex query involving joins across the Persons, Births, and Marriages tables. Optimize the query based on the analysis.

EXPLAIN ANALYZE SELECT p.FirstName, p.LastName, b.BirthPlace, m.MarriagePlace
                FROM Persons p
                         JOIN Births b ON p.PersonID = b.PersonID
                         JOIN Marriages m ON p.PersonID = m.PersonID1 OR p.PersonID = m.PersonID2;


--Task 10: Implement and Query a View
--Create a view VitalRecords that combines data from Persons, Births, and Marriages. Write a query to retrieve all records from this view where the person's last name is 'Müller'.

CREATE VIEW VitalRecords AS
SELECT p.FirstName, p.LastName, b.BirthDate, b.BirthPlace, m.MarriageDate, m.MarriagePlace
FROM Persons p
         LEFT JOIN Births b ON p.PersonID = b.PersonID
         LEFT JOIN Marriages m ON p.PersonID = m.PersonID1 OR p.PersonID = m.PersonID2;

SELECT * FROM VitalRecords WHERE LastName = 'Müller';


--Task 12: Transaction Management
--Demonstrate the use of transactions in PostgreSQL with proper commit and rollback based on conditional logic. For example, insert a new person and their birth record within a transaction.

BEGIN;
INSERT INTO Persons (FirstName, LastName, DateOfBirth) VALUES ('Daniel', 'Wolf', '1998-12-12');
INSERT INTO Births (PersonID, BirthDate, BirthPlace) VALUES (currval('persons_personid_seq'), '1998-12-12', 'Stuttgart');
COMMIT;


--Task 14: Use of JSON Data Types
--Modify the Persons table to include a column Attributes of type JSONB. Insert sample data and write a query to find persons based on a key-value pair in the JSONB column.

ALTER TABLE Persons ADD COLUMN Attributes JSONB;
UPDATE Persons SET Attributes = '{"eyeColor": "blue", "height": 175}' WHERE PersonID = 1;

SELECT * FROM Persons WHERE Attributes ->> 'eyeColor' = 'blue';


--Task 15: Performance Tuning with Caching
--Discuss the role of caching in PostgreSQL. Implement a simulated caching strategy using a materialized view based on a complex query involving multiple joins and aggregation.

CREATE MATERIALIZED VIEW CachedVitalStats AS
SELECT p.LastName, COUNT(b.BirthID) AS NumberOfBirths
FROM Persons p
         JOIN Births b ON p.PersonID = b.PersonID
GROUP BY p.LastName;