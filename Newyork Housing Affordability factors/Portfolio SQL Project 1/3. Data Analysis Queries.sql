-- Data Analysis Queries --

-- This analysis examines affordable housing in New York and its potential relationship with school crime. By querying housing and school incident data, 
-- we aim to uncover insights that inform policymakers on strategies for equity and safety in local communities.

-- Tools Used
-- WITH CTE, WINDOW FUNCTIONS, AGGREGATE FUNCTIONS, SQL JOINS, SUB-QUERIES, FUNCTIONS


-- 1.  What are the various projects completed as part of affordable housing in Newyork?
-- Why? Residents or Newcomers to Newyork can check directly for the completed projects and choose their favorite project.

SELECT DISTINCT project_name
FROM project
WHERE project_completion_date IS NOT NULL
;

-- 2.  What are the various construction type and their counts in various Boroughs?
-- Why? Residents or Newcomers can see the progress of affordable housing project completion in Newyork in various Boroughs and make decision on the area they want to choose

SELECT borough AS Borough_Name, 
	p.reporting_construction_type AS Construction_Type, 
	COUNT(p.reporting_construction_type) AS Type_count
FROM project p
LEFT JOIN building b ON b.project_uid = p.project_uid
LEFT JOIN address a ON a.address_id = b.address_id
WHERE borough IS NOT NULL
GROUP BY Borough_Name, Construction_Type
ORDER BY Borough_Name, Construction_Type
;

-- 3.  What are the count of 0-crime rate schools in each Borough?
-- Why? This helps residents identify count of low-crime schools in each borough and determine safer areas for housing.

SELECT borough,
	COUNT(school_name) AS school_count	
FROM schoolcrime s
JOIN address a ON s.address_id = a.address_id
WHERE borough IS NOT NULL AND borough != '' 
AND (IFNULL(s.major_crimes,0) + IFNULL(s.non_criminal_crimes,0) + IFNULL(s.property_crimes,0) + IFNULL(s.violent_crimes,0) + IFNULL(s.other_crimes,0))  = 0
GROUP BY borough
ORDER BY school_count DESC
;

-- 4.  What are the worst 3 highly ranked schools for crimes, count of total crimes in each Borough?
-- Why? This helps residents understand the maximum crime levels in the worst-crime rate schools within each borough.


WITH 
	ctetotalcrimes(school_name, Total_crimes, borough)
    AS
    (SELECT school_name, 
	(IFNULL(s.major_crimes,0) + IFNULL(s.non_criminal_crimes,0) + IFNULL(s.property_crimes,0) + IFNULL(s.violent_crimes,0) + IFNULL(s.other_crimes,0)) AS Total_crimes,
    borough
FROM schoolcrime s
JOIN address a ON s.address_id = a.address_id
WHERE borough IS NOT NULL AND borough != '')
    
SELECT school_name, 
	Total_crimes, 
    borough
FROM
	(
	SELECT school_name, 
		Total_crimes, 
		borough,
		DENSE_RANK() OVER(PARTITION BY borough ORDER BY Total_crimes DESC) AS r1
	FROM ctetotalcrimes) SUB
WHERE r1 <= 3
;

-- 5. What are number of housing projects in each Borough
-- Why? Helps the Newcomers to NewYork/Policymakers to compare if there is a relationship with schoolcrime and building affordable housing units comparing previous query results.


SELECT a.borough,
	COUNT(p.project_id) as housing_project_counts
FROM project p
LEFT JOIN building b ON b.project_uid = p.project_uid
LEFT JOIN address a ON a.address_id = b.address_id
WHERE a.borough IS NOT NULL
GROUP BY a.borough
ORDER BY housing_project_counts DESC
;


-- 6.  What are the basic counts of various house-forms in each borough?
-- Why? Newcomers to NewYork can check the basic count statistics and choose what general area to begin house search. Depending on their family demographics, will need to be determined by bedroom count.

SELECT a.borough AS Borough_Name,
    SUM(p.studio_units) AS Total_Afford_Studios,
	SUM(p.br_1_units) AS Total_Afford_1Unit,
    SUM(p.br_2_units) AS Total_Afford_2Units,
    SUM(p.br_3_units) AS Total_Afford_3Units,
    SUM(p.br_4_units) AS Total_Afford_4Units,
    SUM(p.br_5_units) AS Total_Afford_5Units,
    SUM(p.br_6_plus_units) AS Total_Afford_6Units,
    SUM(p.Affordable_marketrate_units) AS Total_Units #note: this is affordable + non-affordable
FROM project p
LEFT JOIN building b ON b.project_uid = p.project_uid
LEFT JOIN address a ON a.address_id = b.address_id
GROUP BY Borough_Name
;

-- 7. How many projects are ongoing vs. completed per council district?
-- Why? Residents or Newcomers can see the progress of affordable housing project completion in Newyork in various Council Districts and make decision on the area they want to choose

SELECT bbl.council_district as council_district,
    (CASE
		WHEN (p.project_completion_date IS NULL 
        OR cast(p.project_completion_date as nchar)  = ' ' )
        THEN 'ongoing_project'
		ELSE 'completed_project'
	END) AS Project_Status,
    count(project_id) AS Project_count
FROM project p
LEFT JOIN building b ON b.project_uid = p.project_uid
LEFT JOIN address a ON a.address_id = b.address_id
LEFT JOIN bbl ON bbl.bbl_id = a.bbl_id
GROUP BY council_district, Project_Status, council_district
ORDER BY council_district, Project_Status
;


-- 8. Project Cyclicality: How many affordable project/building/different size housing units were started in each month?
-- Why? Helps the policy makers/residents understand which months have more housing projects and which month has less projects. Points to the seasonality factor.

SELECT COUNT(project_id) AS Total_Projects,
	COUNT(building_id) as Total_Buildings,
    SUM(p.studio_units) as Number_of_Studios,
	SUM(p.br_1_units) as Number_of_1Unit,
    SUM(p.br_2_units) as Number_of_2Units,
    SUM(p.br_3_units) as Number_of_3Units,
    SUM(p.br_4_units) as Number_of_4Units,
    SUM(p.br_5_units) as Number_of_5Units,
    SUM(p.br_6_plus_units) as Number_of_6Units,
    MONTH(p.project_start_date) AS start_month
FROM project p
JOIN building b ON b.project_uid = p.project_uid
JOIN address a ON a.address_id = b.address_id
JOIN bbl ON bbl.bbl_id = a.bbl_id
WHERE 
	p.project_start_date IS NOT NULL
GROUP BY
    start_month
ORDER BY start_month;
    

-- 9. Crime by Borough: Different school crimes by borough
-- Why?  Gives the school crime data in each borough in 2015-2016, 2016-2017 academic years. Helps the residents and authoroites get informed about the crime range in each Borough
SELECT 
	a.Borough as borough,
    SUM(s.no_of_schools) as Number_of_Schools,
    SUM(s.major_crimes) as Major_Crimes,
    SUM(s.non_criminal_crimes) as Non_Criminal_Crimes,
    SUM(s.property_crimes) as Property_Crimes,
    SUM(s.violent_crimes) as Violent_Crimes,
    SUM(s.other_crimes) as Other_Crimes,
    s.schoolyear as School_Year
FROM schoolcrime AS s
JOIN address AS a ON s.address_id = a.address_id
WHERE a.Borough IS NOT NULL
group by borough, School_Year
ORDER BY borough, School_Year
;



