-- 1. Create the Database
CREATE DATABASE IF NOT EXISTS Airline_Delay_DB;
USE Airline_Delay_DB;

-- 2. Create Dimension Table: Carriers
-- This stores the unique identity of each airline.
CREATE TABLE Dim_Carrier (
    carrier_id INT AUTO_INCREMENT PRIMARY KEY,
    carrier_code VARCHAR(10) UNIQUE,
    carrier_name VARCHAR(255)
);

-- 3. Create Dimension Table: Airports
-- This stores the unique identity of each airport.
CREATE TABLE Dim_Airport (
    airport_id INT AUTO_INCREMENT PRIMARY KEY,
    airport_code VARCHAR(10) UNIQUE,
    airport_name VARCHAR(255)
);

-- 4. Create Dimension Table: Time
-- This handles the temporal aspects of your analysis.
CREATE TABLE Dim_Time (
    time_id INT AUTO_INCREMENT PRIMARY KEY,
    full_date DATE UNIQUE,
    year INT,
    month INT,
    month_name VARCHAR(20)
);

-- 5. Create the Fact Table: Flight_Delays
-- This is the center of the star. It stores all the numbers and KPIs.
-- It connects to the Dimensions using "Foreign Keys".
CREATE TABLE Fact_Delays (
    fact_id INT AUTO_INCREMENT PRIMARY KEY,
    carrier_id INT,
    airport_id INT,
    time_id INT,
    
    -- Numerical Metrics
    arr_flights DECIMAL(10,2),
    arr_del15 DECIMAL(10,2),
    arr_cancelled DECIMAL(10,2),
    arr_diverted DECIMAL(10,2),
    arr_delay DECIMAL(10,2),
    arr_ontime DECIMAL(10,2),
    
    -- Delay Breakdowns
    carrier_ct DECIMAL(10,2),
    weather_ct DECIMAL(10,2),
    nas_ct DECIMAL(10,2),
    security_ct DECIMAL(10,2),
    late_aircraft_ct DECIMAL(10,2),
    
    -- Engineered KPIs (Stored as decimals for precision)
    OTP_Rate DECIMAL(10,4),
    Delay_Severity DECIMAL(10,4),
    is_anomaly TINYINT, -- 0 or 1
    
    -- Defining relationships (Foreign Key Constraints)
    FOREIGN KEY (carrier_id) REFERENCES Dim_Carrier(carrier_id),
    FOREIGN KEY (airport_id) REFERENCES Dim_Airport(airport_id),
    FOREIGN KEY (time_id) REFERENCES Dim_Time(time_id)
);

-- This clears the tables so the IDs start from 1 again
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE Fact_Delays;
TRUNCATE TABLE Dim_Carrier;
TRUNCATE TABLE Dim_Airport;
TRUNCATE TABLE Dim_Time;


-- 3. Re-enable foreign key constraints to maintain data integrity for the next load
SET FOREIGN_KEY_CHECKS = 1;

-- 4. Verification: Check if tables are empty (should return 0 for all)
SELECT 
    (SELECT COUNT(*) FROM Fact_Delays) AS Fact_Count,
    (SELECT COUNT(*) FROM Dim_Carrier) AS Carrier_Count,
    (SELECT COUNT(*) FROM Dim_Airport) AS Airport_Count,
    (SELECT COUNT(*) FROM Dim_Time) AS Time_Count;


-- Check the total row count
SELECT COUNT(*) FROM Fact_Delays;

-- The result must be exactly 171,223
SELECT COUNT(*) AS Total_SQL_Rows FROM Fact_Delays;

-- See a sample of your Star Schema joined together
SELECT 
    f.fact_id, 
    c.carrier_name, 
    a.airport_name, 
    t.full_date, 
    f.OTP_Rate
FROM Fact_Delays f
JOIN Dim_Carrier c ON f.carrier_id = c.carrier_id
JOIN Dim_Airport a ON f.airport_id = a.airport_id
JOIN Dim_Time t ON f.time_id = t.time_id
LIMIT 10;

-- Referential Integrity Check
SELECT 
    COUNT(*) - COUNT(carrier_id) AS Missing_Carrier_Links,
    COUNT(*) - COUNT(airport_id) AS Missing_Airport_Links,
    COUNT(*) - COUNT(time_id) AS Missing_Time_Links
FROM Fact_Delays;

-- KPI Mathematical Validation
SELECT 
    c.carrier_name, 
    SUM(f.arr_flights) AS Total_SQL_Flights,
    AVG(f.OTP_Rate) AS Avg_SQL_OTP_Rate
FROM Fact_Delays f
JOIN Dim_Carrier c ON f.carrier_id = c.carrier_id
WHERE c.carrier_code = 'DL'
GROUP BY c.carrier_name;

-- Dimension Uniqueness Audit
-- This should return 0 rows. If it returns rows, there are duplicates.
SELECT airport_code, COUNT(*) 
FROM Dim_Airport 
GROUP BY airport_code 
HAVING COUNT(*) > 1;


select * from fact_predictive_analytics;

select count(*) from fact_predictive_analytics;


select * from Fact_Delays;