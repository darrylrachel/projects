DROP TABLE IF EXISTS hcahps;

CREATE TABLE hcahps (
	`Facility ID` INT, 
	`Facility Name` VARCHAR(255), 
	Addres VARCHAR(255),	
	City_Town VARCHAR(255),	
	State VARCHAR(255),	
	`ZIP Code` INT,	
	County_Parish VARCHAR(255),	
	`Telephone Number` VARCHAR(255),	
	`HCAHPS Measure ID` VARCHAR(255),
	`HCAHPS Question` VARCHAR(255),
	`HCAHPS Answer Description` VARCHAR(255),
	`HCAHPS Answer Percent` FLOAT,
	`Number of Completed Surveys` INT,
	`Survey Response Rate Percent` FLOAT,
	Start_Date DATE,
	End_Date DATE
);

LOAD DATA LOCAL INFILE "C:/Users/Darryl/Documents/Courses/Data_Wizardry/HCAHPS Lesson Files/v1 HCAHPS 2022.csv" 
INTO TABLE hcahps 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS
(
	`Facility ID`, 
	`Facility Name`, 
	Addres,	
	City_Town,	
	State,	
	`ZIP Code`,	
	County_Parish,	
	`Telephone Number`,	
	`HCAHPS Measure ID`,
	`HCAHPS Question`,
	`HCAHPS Answer Description`,
	`HCAHPS Answer Percent`,
	`Number of Completed Surveys`,
	`Survey Response Rate Percent`,
	@Start_Date,
	@End_Date
) 
SET 
	Start_Date = STR_TO_DATE(@Start_Date, '%m/%d/%Y'),
	End_Date = STR_TO_DATE(@End_Date, '%m/%d/%Y');


SELECT COUNT(*)
FROM hcahps;


DROP TABLE IF EXISTS beds;

CREATE TABLE beds
(
	`Provider CCN` INT,
    `Hospital Name` VARCHAR(255),
    Fiscal_Year_Begin_Date DATE,
    Fiscal_Year_End_Date DATE,
    `number_of_beds` INT
);
		
LOAD DATA LOCAL INFILE 'C:/Users/Darryl/Documents/Courses/Data_Wizardry/HCAHPS Lesson Files/Hospital Beds.csv'
INTO TABLE beds
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS
(
	`Provider CCN`,
    `Hospital Name`,
    @Fiscal_Year_Begin_Date,
    @Fiscal_Year_End_Date,
    number_of_beds
)

SET 
	Fiscal_Year_Begin_Date = STR_TO_DATE(@Fiscal_Year_Begin_Date, '%m/%d/%Y'),
	Fiscal_Year_End_Date = STR_TO_DATE(@Fiscal_Year_End_Date, '%m/%d/%Y');

SELECT COUNT(*)
FROM beds;


WITH hospital_beds_prep
AS
(
SELECT 
	LPAD(CAST(`Provider CCN` AS CHAR), 6, '0') AS provider_ccn,
    `Hospital Name`,
    Fiscal_Year_Begin_Date,
	Fiscal_Year_End_Date,
    number_of_beds,
    ROW_NUMBER() OVER(PARTITION BY `Provider CCN` ORDER BY Fiscal_Year_End_Date DESC) AS row_num
FROM beds
)

# SELECT 
# 	provider_ccn, 
#     COUNT(*) AS Count_of_Rows
# FROM hospital_beds_prep
# WHERE row_num = 1
# GROUP BY provider_ccn
# ORDER BY COUNT(*) DESC;


SELECT *,
	LPAD(CAST(`Facility ID` AS CHAR), 6, '0') AS facility_id,
    Start_Date,
    End_Date
FROM hcahps AS hcahps
LEFT JOIN hospital_beds_prep AS beds
	ON hcahps.`Provider CCN` = beds.`Facility ID`;











