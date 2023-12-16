/***
Temp Table Clean-Up
***/



/***
TO ALTER housing_temp table to data type same as of project.

***/

## Replace empty and NA values in Building ID to NULL
UPDATE housing_temp
SET `Building ID` = NULL
WHERE `Building ID` IN ('N/A', '');

ALTER TABLE housing_temp
CHANGE COLUMN `Project ID` project_id INT,
CHANGE COLUMN `Project Name` project_name VARCHAR(60),
CHANGE COLUMN `Project Start Date` project_start_date VARCHAR(60),
CHANGE COLUMN `Project Completion Date` project_completion_date VARCHAR(60),
CHANGE COLUMN `Building ID` building_id INT, ## Added in this line for 'building' table
CHANGE COLUMN `Reporting Construction Type` reporting_construction_type VARCHAR(45),
CHANGE COLUMN `Extended Affordability Only` extended_affordability_only VARCHAR(45),
CHANGE COLUMN `Prevailing Wage Status` prevailing_wage_status VARCHAR(45),
CHANGE COLUMN `Extremely Low Income Units` extremely_low_income_units INT,
CHANGE COLUMN `Very Low Income Units` very_low_units INT,
CHANGE COLUMN `Low Income Units` low_income_units INT,
CHANGE COLUMN `Moderate Income Units` moderate_income_units INT,
CHANGE COLUMN `Middle Income Units` middle_income_units INT,
CHANGE COLUMN `Other Income Units` other_income_units INT,
CHANGE COLUMN `Studio Units` studio_units INT,
CHANGE COLUMN `1-BR Units` br_1_units INT,
CHANGE COLUMN `2-BR Units` br_2_units INT,
CHANGE COLUMN `3-BR Units` br_3_units INT,
CHANGE COLUMN `4-BR Units` br_4_units INT,
CHANGE COLUMN `5-BR Units` br_5_units INT,
CHANGE COLUMN `6-BR+ Units` br_6_plus_units INT,
CHANGE COLUMN `Unknown-BR Units` unknown_br_units INT,
CHANGE COLUMN `Counted Rental Units` rental_units INT,
CHANGE COLUMN `Counted Homeownership Units` homeownership_units INT,
CHANGE COLUMN `Total Units` Affordable_marketrate_units INT;

# This is to change the project_start_date column
UPDATE housing_temp
SET project_start_date = STR_TO_DATE(project_start_date, '%m/%d/%Y')
WHERE project_start_date IS NOT NULL;

#This is to change the project_completion_date colum
UPDATE housing_temp
SET project_completion_date = 
  CASE 
    WHEN project_completion_date IS NOT NULL AND project_completion_date <> '' THEN STR_TO_DATE(project_completion_date, '%m/%d/%Y')
    ELSE NULL
  END;



/***
TO ALTER schoolcrime1(2015-16 School data table)
***/

UPDATE schoolcrime1
SET `Major N` = NULL
WHERE `Major N` IN ('N/A', '');

UPDATE schoolcrime1
SET `Oth N` = NULL
WHERE `Oth N` IN ('N/A', '');

UPDATE schoolcrime1
SET `NoCrim N` = NULL
WHERE `NoCrim N` IN ('N/A', '');

UPDATE schoolcrime1
SET `Prop N` = NULL
WHERE `Prop N` IN ('N/A', '');

UPDATE schoolcrime1
SET `Vio N` = NULL
WHERE `Vio N` IN ('N/A', '');

UPDATE schoolcrime1
SET `# Schools` = NULL
WHERE `# Schools` = '';


ALTER TABLE schoolcrime1
CHANGE COLUMN `Building Name` building_name VARCHAR(100),
CHANGE COLUMN `School Year` schoolyear VARCHAR(45),
CHANGE COLUMN `# Schools` no_of_schools INT,
CHANGE COLUMN `Major N` major_crimes INT,
CHANGE COLUMN `Oth N` other_crimes INT,
CHANGE COLUMN `NoCrim N` non_criminal_crimes INT,
CHANGE COLUMN `Prop N` property_crimes INT,
CHANGE COLUMN `Vio N` violent_crimes INT,
CHANGE COLUMN `ENGroupA` engroup_A VARCHAR(10),
CHANGE COLUMN `RangeA` rangeA VARCHAR(45);



/***
TO ALTER schoolcrime2(2016-17 School data table)
***/

UPDATE schoolcrime2
SET `Major N` = NULL
WHERE `Major N` IN ('N/A', '');

UPDATE schoolcrime2
SET `Oth N` = NULL
WHERE `Oth N` IN ('N/A', '');

UPDATE schoolcrime2
SET `NoCrim N` = NULL
WHERE `NoCrim N` IN ('N/A', '');

UPDATE schoolcrime2
SET `Prop N` = NULL
WHERE `Prop N` IN ('N/A', '');

UPDATE schoolcrime2
SET `Vio N` = NULL
WHERE `Vio N` IN ('N/A', '');

ALTER TABLE schoolcrime2
CHANGE COLUMN `Building Name` building_name VARCHAR(150),
CHANGE COLUMN `# Schools` no_of_schools INT,
CHANGE COLUMN `School Year` schoolyear VARCHAR(45),
CHANGE COLUMN `Major N` major_crimes INT,
CHANGE COLUMN `Oth N` other_crimes INT,
CHANGE COLUMN `NoCrim N` non_criminal_crimes INT,
CHANGE COLUMN `Prop N` property_crimes INT,
CHANGE COLUMN `Vio N` violent_crimes INT,
CHANGE COLUMN `ENGroupA` engroup_A VARCHAR(10),
CHANGE COLUMN `RangeA` rangeA VARCHAR(45);


/***
Load BBL Table
***/

USE depa_final;

DELETE FROM bbl;

# Altering table structure to make bbl field UNIQUE toa void duplicates
ALTER TABLE bbl
ADD UNIQUE (bbl);


#Insert statement for BBL from housing_temp
INSERT IGNORE INTO depa_final.bbl(    
	bbl,
    community_board,
    council_district,
    census_tract,
    nta)
(SELECT DISTINCT
    BBL,
    `Community Board`,
    CASE WHEN `Council District` = '' THEN NULL ELSE `Council District` END AS `Council District`,
    `Census Tract`,
    `NTA - Neighborhood Tabulation Area`
FROM
    housing_temp
WHERE BBL IS NOT NULL AND BBL <> '');

#Schoolcrime1 does not have BBL field

#Insert statement for BBL from schoolcrime2
INSERT IGNORE INTO depa_final.bbl(    
	bbl,
    community_board,
    council_district,
    census_tract,
    nta)
(SELECT DISTINCT
    BBL,
    `Community Board`,
    CASE WHEN `Council District` = '' THEN NULL ELSE `Council District` END AS `Council District`,
    `Census Tract`,
    `NTA`
FROM
    schoolcrime2
WHERE BBL IS NOT NULL AND BBL <> '');


/***
Loading Address Table
***/

#In case you have loaded the address
DELETE FROM address;


#Altering schoolcrime1 to accomodate number column
ALTER TABLE schoolcrime1
ADD COLUMN number VARCHAR(45);

#Altering schoolcrime2 to accomodate number column
ALTER TABLE schoolcrime2
ADD COLUMN number VARCHAR(45),
ADD COLUMN Address VARCHAR(200);


#Parsing number and address field
UPDATE schoolcrime1
SET number = SUBSTRING_INDEX(address, ' ', 1),
address = TRIM(SUBSTRING(address, LENGTH(SUBSTRING_INDEX(address, ' ', 1)) + 1));


UPDATE schoolcrime2
SET number = SUBSTRING_INDEX(Geocode, ' ', 1),
address = TRIM(SUBSTRING(Geocode, LENGTH(SUBSTRING_INDEX(Geocode, ' ', 1)) + 1));

#SELECT * FROM schoolcrime2;

#Queries to change Borough to Borough names
UPDATE schoolcrime1
SET Borough = 'Brooklyn'
WHERE Borough = 'K';
UPDATE schoolcrime1
SET Borough = 'Manhattan'
WHERE Borough = 'M';
UPDATE schoolcrime1
SET Borough = 'Queens'
WHERE Borough = 'Q';
UPDATE schoolcrime1
SET Borough = 'Staten Island'
WHERE Borough = 'R';
UPDATE schoolcrime1
SET Borough = 'Bronx'
WHERE Borough = 'X';
UPDATE schoolcrime1
SET Borough = NULL
WHERE Borough = 'O';

UPDATE schoolcrime2
SET Borough = 'Brooklyn'
WHERE Borough = 'K';
UPDATE schoolcrime2
SET Borough = 'Manhattan'
WHERE Borough = 'M';
UPDATE schoolcrime2
SET Borough = 'Queens'
WHERE Borough = 'Q';
UPDATE schoolcrime2
SET Borough = 'Staten Island'
WHERE Borough = 'R';
UPDATE schoolcrime2
SET Borough = 'Bronx'
WHERE Borough = 'X';
UPDATE schoolcrime2
SET Borough = NULL
WHERE Borough = 'O';


# Altering table structure to make bbl field UNIQUE toa void duplicates
ALTER TABLE address
ADD UNIQUE (number,street);


#Insertion from schoolcrime1 to address
INSERT IGNORE INTO depa_final.address(    
	number,
    street,
    borough)
(SELECT DISTINCT
    number,
    Address,
    Borough
FROM schoolcrime1);

SELECT * FROM address;

#Insertion from schoolcrime2 to address
INSERT IGNORE INTO depa_final.address(    
	number,
    street,
    borough)
(SELECT DISTINCT
    number,
    Address,
    Borough
FROM schoolcrime2);

SELECT * FROM address;

#Insertion from housing_temp to address
INSERT IGNORE INTO depa_final.address(    
	number,
    street,
    borough,
    latitude,
    longitude,
    zipcode,
    bbl_id)
(SELECT DISTINCT
    h.Number,
    h.Street,
    h.Borough,
    h.Latitude,
    h.Longitude,
    h.Postcode,
    b.bbl_id
FROM housing_temp h, bbl b
WHERE h.bbl = b.bbl);


/***
Loading Project Table
***/

-- -------------------------------------
USE depa_final;
-- -----------------------------------------------------

INSERT INTO depa_final.project (    
	project_id,
    project_name,
    project_start_date,
    project_completion_date,
    reporting_construction_type,
    extended_affordability_only,
    prevailing_wage_status,
    extremely_low_income_units,
    very_low_units,
    low_income_units,
    moderate_income_units,
    middle_income_units,
    other_income_units,
    studio_units,
    br_1_units,
    br_2_units,
    br_3_units,
    br_4_units,
    br_5_units,
    br_6_plus_units,
    unknown_br_units,
    rental_units,
    homeownership_units,
    Affordable_marketrate_units
    )
(SELECT 
    h.project_id,
    h.project_name,
    h.project_start_date,
    h.project_completion_date,
    h.reporting_construction_type,
    h.extended_affordability_only,
    h.prevailing_wage_status,
    h.extremely_low_income_units,
    h.very_low_units,
    h.low_income_units,
    h.moderate_income_units,
    h.middle_income_units,
    h.other_income_units,
    h.studio_units,
    h.br_1_units,
    h.br_2_units,
    h.br_3_units,
    h.br_4_units,
    h.br_5_units,
    h.br_6_plus_units,
    h.unknown_br_units,
    h.rental_units,
    h.homeownership_units,
    h.Affordable_marketrate_units
FROM
    depa_final.housing_temp as h
WHERE h.project_name <> 'CONFIDENTIAL'
);

/***
Loading Building Table
***/

-- -------------------------------------
USE depa_final;
-- -----------------------------------------------------
DROP TABLE IF EXISTS building_temp;

## Create a temp table called building_temp to pull in information from other tables
CREATE TEMPORARY TABLE building_temp AS
SELECT
    h.building_id,
    h.project_completion_date,
    h.number,
    h.street,
    h.Affordable_marketrate_units,
    p.project_uid
FROM
    housing_temp h
JOIN
    project p ON h.project_id = p.project_id
WHERE
    h.project_completion_date = p.project_completion_date
    AND h.Affordable_marketrate_units = p.Affordable_marketrate_units;

## select * from building_temp;

## Add in the address_id column (empty) to building_temp
ALTER TABLE building_temp
ADD COLUMN address_id int after project_uid;

## Get address_id from the address table where the address number and street match
UPDATE building_temp bt
JOIN address a ON bt.number = a.number AND bt.street = a.street
SET bt.address_id = a.address_id;

## Insert into building table using the building_temp table
INSERT IGNORE INTO building (building_id, building_completion_date, project_uid, address_id)
SELECT building_id, project_completion_date, project_uid, address_id
FROM building_temp;

/***
Loading schoolcrime Table
***/

USE depa_final;

#DELETE FROM schoolcrime;

#Insert Schoolcrime1 (Does not have bbl)
INSERT IGNORE INTO depa_final.schoolcrime (
  building_code,
  address_id,
  school_name,
  schoolyear,
  no_of_schools,
  major_crimes,
  other_crimes,
  non_criminal_crimes,
  property_crimes,
  violent_crimes,
  engroup_A,
  rangeA
  ) 
(SELECT 
    c1.`Location Code`, 
    a.address_id,
    c1.`Location Name`,
    c1.schoolyear,
    c1.no_of_schools,
    CASE WHEN c1.major_crimes = 'N/A' THEN NULL
		ELSE c1.major_crimes END AS major_crimes,
	CASE WHEN c1.other_crimes = 'N/A' OR 'N/A' THEN NULL
		ELSE c1.other_crimes END AS other_crimes,
	CASE WHEN c1.non_criminal_crimes = 'N/A' THEN NULL
		ELSE c1.non_criminal_crimes END AS non_criminal_crimes,
	CASE WHEN c1.property_crimes = 'N/A' THEN NULL
		ELSE c1.property_crimes END AS property_crimes,
	CASE WHEN c1.violent_crimes = 'N/A' THEN NULL
		ELSE c1.violent_crimes END AS violent_crimes,
    c1.engroup_A,
    c1.rangeA
FROM
    depa_final.schoolcrime1 as c1, depa_final.address a
WHERE c1.number = a.number AND c1.Address = a.street);


#Insert Schoolcrime2
INSERT IGNORE INTO depa_final.schoolcrime (
  building_code,
  address_id, ##
  school_name,
  schoolyear,
  no_of_schools,
  major_crimes,
  other_crimes,
  non_criminal_crimes,
  property_crimes,
  violent_crimes,
  engroup_A,
  rangeA,
  bbl_id)
(SELECT 
    c2.`Location Code`,
    a.address_id, ##
    c2.`Location Name`,
    c2.schoolyear,
    c2.no_of_schools,
    CASE WHEN c2.major_crimes = 'N/A' THEN NULL
		ELSE c2.major_crimes END AS major_crimes,
	CASE WHEN c2.other_crimes = 'N/A' OR 'N/A' THEN NULL
		ELSE c2.other_crimes END AS other_crimes,
	CASE WHEN c2.non_criminal_crimes = 'N/A' THEN NULL
		ELSE c2.non_criminal_crimes END AS non_criminal_crimes,
	CASE WHEN c2.property_crimes = 'N/A' THEN NULL
		ELSE c2.property_crimes END AS property_crimes,
	CASE WHEN c2.violent_crimes = 'N/A' THEN NULL
		ELSE c2.violent_crimes END AS violent_crimes,
    c2.engroup_A,
    c2.rangeA,
    b.bbl_id
FROM
    schoolcrime2 as c2, bbl as b, depa_final.address a ##
WHERE c2.BBL = b.bbl AND c2.number = a.number AND c2.Address = a.street);

