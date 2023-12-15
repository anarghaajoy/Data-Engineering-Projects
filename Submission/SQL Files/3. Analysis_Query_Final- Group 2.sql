-- Group 2 SQL Analysis Query --

-- 1.  What the bedroom counts are in different boroughs?
-- Why? Newcomers to NYC choosing what general area to begin house search. Depending on their family demographics, will need to be determined by bedroom count. 
SELECT ad.borough AS Borough_Name,
    SUM(pr.studio_units) AS Total_Number_of_Afford_Studios,
	SUM(pr.`br_1_units`) AS Total_Number_of_Afford_1Unit,
    SUM(pr.`br_2_units`) AS Total_Number_of_Afford_2Units,
    SUM(pr.`br_3_units`) AS Total_Number_of_Afford_3Units,
    SUM(pr.`br_4_units`) AS Total_Number_of_Afford_4Units,
    SUM(pr.`br_5_units`) AS Total_Number_of_Afford_5Units,
    SUM(pr.`br_6_plus_units`) AS Total_Number_of_Afford_6Units,
    SUM(pr.Affordable_marketrate_units) AS Total_Number_of_Units #note: this is affordable + non-affordable
FROM project pr
LEFT JOIN building bu ON bu.project_uid = pr.project_uid
LEFT JOIN address ad ON ad.address_id = bu.address_id
GROUP BY Borough_Name
;

-- 2. How many projects are ongoing vs. completed per council district?
SELECT count(project_id),
	#pr.project_start_date,
	bbl.council_district as district,
    #pr.project_completion_date as completion_date,
    CASE
		WHEN (pr.project_completion_date IS NULL 
        OR cast(pr.project_completion_date as nchar)  = ' ' )
        THEN 'ongoing_project'
		ELSE 'completed_project'
	END AS Project_Status
FROM project pr
LEFT JOIN building bu ON bu.project_uid = pr.project_uid
LEFT JOIN address ad ON ad.address_id = bu.address_id
LEFT JOIN bbl ON bbl.bbl_id = ad.bbl_id
GROUP BY district,
		Project_Status,
        bbl.council_district
ORDER BY district, Project_Status
;


-- 3. Project Cyclicality: How many affordable project/building/different size housing units were started in each month?
SELECT COUNT(project_id) AS Total_Number_of_Projects,
	COUNT(building_id) as Total_Number_of_Buildings,
    SUM(pr.studio_units) as Number_of_Studios,
	SUM(pr.`br_1_units`) as Number_of_1Unit,
    SUM(pr.`br_2_units`) as Number_of_2Units,
    SUM(pr.`br_3_units`) as Number_of_3Units,
    SUM(pr.`br_4_units`) as Number_of_4Units,
    SUM(pr.`br_5_units`) as Number_of_5Units,
    SUM(pr.`br_6_plus_units`) as Number_of_6Units,
    MONTH(pr.project_start_date) AS start_month
FROM project pr
JOIN building bu ON bu.project_uid = pr.project_uid
JOIN address ad ON ad.address_id = bu.address_id
JOIN bbl ON bbl.bbl_id = ad.bbl_id
WHERE 
	pr.project_start_date IS NOT NULL
GROUP BY
    start_month
ORDER BY start_month;
    

-- 4. Crime by Borough: Different school crimes by borough
SELECT 
	ad.Borough as borough,
    SUM(s.no_of_schools) as Number_of_Schools,
    SUM(s.`major_crimes`) as Major_Crimes,
    SUM(s.`non_criminal_crimes`) as Non_Criminal_Crimes,
    SUM(s.`property_crimes`) as Property_Crimes,
    SUM(s.`violent_crimes`) as Violent_Crimes,
    SUM(s.`other_crimes`) as Other_Crimes,
    s.schoolyear as School_Year
FROM schoolcrime AS s
#JOIN bbl ON bbl.bbl_id = s.bbl_id
JOIN address AS ad ON s.address_id = ad.address_id
group by borough, School_Year
ORDER BY borough, School_Year
;

SELECT address_id, schoolyear FROM schoolcrime;

SELECT * FROM address;

