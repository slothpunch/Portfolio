USE project;


#############
# Australia #
#############

# Change the table name coivd_19 to covid_19
ALTER TABLE coivd_19
RENAME TO covid_19;

# Change the data type of date from text to date
ALTER TABLE covid_19
MODIFY COLUMN date DATE;

COMMIT;

SELECT
	date,
    STR_TO_DATE(date, '%d/%m/%Y')
FROM covid_19
WHERE date LIKE('%/%');

UPDATE covid_19
SET date = STR_TO_DATE(date, '%d/%m/%Y')
WHERE date LIKE('%/%');

# Create a TEMP table 
DROP TABLE IF EXISTS au_vaccine;
CREATE TEMPORARY TABLE au_vaccine(
	iso_code text
	,continent text
	,population double 
	,location text
	,date date
	,total_cases double
	,new_cases double 
	,total_deaths text 
	,new_deaths text 
	,total_tests text 
	,new_tests text 
	,total_vaccinations text 
	,new_vaccinations text 
	,people_vaccinated text 
	,people_fully_vaccinated text
);

SELECT *
FROM au_vaccine;

COMMIT;

# Insert Australia data into the au_vaccine TEMP table. 555 rows
INSERT INTO au_vaccine
SELECT *
FROM covid_19
WHERE location = 'Australia';

SELECT *
FROM au_vaccine
ORDER BY date DESC;

COMMIT;

# DELETE FROM covid_19 WHERE date LIKE('2021-07%');


# 1. Infection Rate (total_cases/population * 100) --> 0.13%
SELECT
	date,
    total_cases,
    (total_cases/population) * 100 AS infection_rate
FROM au_vaccine
ORDER BY date DESC;

# 2. Case Fatality Rate ((deaths/total_cases) * 100) --> 2.65%
SELECT
	date,
    total_cases,  # 2021-07-31	34383
    total_deaths, # 2021-07-31	924	
    (total_deaths/total_cases) * 100 AS fatality_rate
FROM au_vaccine
ORDER BY date DESC;

# 3. New_tests and total_tests --> total_tests 13,499,808
SELECT
	date,
    new_tests,
    SUM(new_tests) OVER (PARTITION BY location ORDER BY date) AS total_tests
FROM au_vaccine
ORDER BY date DESC;

SELECT
	-- total 555
	COUNT(new_tests) -- 295 53% --> 47% missing.
FROM covid_vaccinations
WHERE 
	location = 'Australia';
    
SELECT 295/555;

# 4. Vaccination rate
SELECT
	date,
    -- total_vaccinations = people_vaccinated + people_fully_vaccinated
    total_vaccinations,
    CONCAT(ROUND((total_vaccinations/population) * 100, 2), '%') AS total_vaccinated_rate,
    -- first does
    people_vaccinated,
    CONCAT(ROUND((people_vaccinated/population) * 100, 2), '%') AS first_vaccin_dose_rate,
    -- second does
    people_fully_vaccinated,
    CONCAT(ROUND((people_fully_vaccinated/population) * 100, 2), '%') AS second_vaccin_dose_rate
FROM 
	au_vaccine
ORDER BY date DESC;

# 5. Total vaccination rate with a CTE
WITH vac_percent(date, population, new_vaccinations, vaccine_rollout)
AS (
SELECT
	date,
    population,
    new_vaccinations,
    SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY date) AS vaccine_rollout
    # (vaccine_rollout/population)*100
FROM
	au_vaccine
) SELECT 
	*, 
    ROUND((vaccine_rollout/population) * 100, 3) AS vaccine_percentage
FROM vac_percent;

# 6. VIEW cannot refer to a TEMP table 
CREATE VIEW vaccinations AS
SELECT
	date,
    -- total_vaccinations = people_vaccinated + people_fully_vaccinated
    total_vaccinations,
    CONCAT(ROUND((total_vaccinations/population) * 100, 2), '%') AS total_vaccinated_rate,
    -- first does
    people_vaccinated,
    CONCAT(ROUND((people_vaccinated/population) * 100, 2), '%') AS first_vaccin_dose_rate,
    -- second does
    people_fully_vaccinated,
    CONCAT(ROUND((people_fully_vaccinated/population) * 100, 2), '%') AS second_vaccin_dose_rate
FROM 
# 	au_vaccine
	covid_vaccinations
WHERE location = 'Australia'
ORDER BY date DESC;

# Call up the view that I've just made
SELECT * FROM vaccinations;

SELECT
	date,
    new_vaccinations,
    people_vaccinated,
    people_fully_vaccinated
FROM covid_vaccinations
WHERE 
	location = 'Australia'
ORDER BY 1 DESC;




