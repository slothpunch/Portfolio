

COMMIT;

ALTER TABLE covid_deaths
MODIFY COLUMN total_cases INT;

ALTER TABLE covid_deaths
MODIFY COLUMN total_deaths INT;

-- Infection Rate (total_cases/population)
SELECT 
    date,
    total_cases,
    (total_cases / population) * 100 AS infection_rate
FROM
    covid_deaths
WHERE
    location = 'Australia';
    
-- Death Rate (total_deaths/population)
SELECT 
    date,
    total_deaths,
    (total_deaths / population) * 100 AS death_rate
FROM
    covid_deaths
WHERE
    location = 'Australia';
    
-- Fataility Rate (total_deaths/total_cases)
SELECT 
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS fatality_rate
FROM
    covid_deaths
WHERE
    location = 'Australia';

ALTER TABLE covid_deaths
ADD COLUMN new_date DATE AFTER date;

UPDATE covid_deaths
SET new_date = STR_TO_DATE(date, '%d/%m/%Y');

SELECT * FROM covid_deaths LIMIT 10;

ALTER TABLE covid_deaths
DROP COLUMN date;

ALTER TABLE covid_deaths
RENAME COLUMN new_date TO date;

COMMIT;
---------------------------------------------------------------------------------------------------------

SELECT 
	*
FROM
    covid_vaccinations cv
        INNER JOIN
    covid_deaths cd ON cv.iso_code = cd.iso_code
    AND cv.date = cd.date
WHERE cv.location = 'Australia'
GROUP BY cv.date;


ALTER TABLE covid_vaccinations
ADD COLUMN new_date DATE AFTER date;

UPDATE covid_vaccinations
SET new_date = STR_TO_DATE(date, '%d/%m/%Y');

SELECT * FROM covid_vaccinations;

ALTER TABLE covid_vaccinations
DROP COLUMN date;

ALTER TABLE covid_vaccinations
RENAME COLUMN new_date TO date;

COMMIT;

-- new_tests and total_tests
SELECT 
    date,
    new_tests,
    SUM(new_tests) OVER (PARTITION BY location ORDER BY date) AS total_tests
FROM
    covid_vaccinations
WHERE 
	location = 'Australia'
ORDER BY date;

COMMIT;

UPDATE covid_vaccinations
SET new_tests = 143056.0
-- SET new_tests = NULL
WHERE location = 'Australia' AND date = '2020-03-22';

UPDATE covid_vaccinations
SET new_tests = 68205.0
-- SET new_tests = NULL
WHERE location = 'Australia' AND date = '2020-03-29';

UPDATE covid_vaccinations
SET new_tests = 85893.0
-- SET new_tests = NULL
WHERE location = 'Australia' AND date = '2020-04-05';

ROLLBACK;


-- How many people are tested everyday

-- Vaccinated rate
SELECT 
	date,
    population,
    new_vaccinations,
    total_vaccinations,
    people_fully_vaccinated
--     (people_fully_vaccinated/total_vaccinations) * 100 AS fully_vaccianted,
--     (total_vaccinations/population) * 100 AS vaccinated_population
FROM
    covid_vaccinations
WHERE
    location = 'Australia'
--         AND total_vaccinations > 1
ORDER BY date;







-- Create TMEP

DROP TABLE IF EXISTS VaccinationStatus;
CREATE TEMPORARY TABLE VaccinationStatus
(
	date DATE,
    population INT,
    new_vaccinations INT,
    total_vaccinations INT,
    people_vaccinated INT,
    people_fully_vaccinated INT
);

INSERT INTO VaccinationStatus
SELECT 
	date,
    population,
    new_vaccinations,
    total_vaccinations,
    people_vaccinated,
    people_fully_vaccinated
--     (people_fully_vaccinated/total_vaccinations) * 100 AS fully_vaccianted,
--     (total_vaccinations/population) * 100 AS vaccinated_population
FROM
    covid_vaccinations
WHERE
    location = 'Australia'
--         AND total_vaccinations > 1
ORDER BY date;

SELECT 
	*
FROM VaccinationStatus;

DELETE FROM VaccinationStatus
WHERE date IN ('2021-06-19', '2021-06-20', '2021-06-21', '2021-06-26', '2021-06-27', '2021-06-28', '2021-07-01');

DELETE FROM VaccinationStatus
WHERE date = '2021-08-02';

UPDATE VaccinationStatus
SET new_vaccinations = 358718
WHERE date = '2021-06-22';

UPDATE VaccinationStatus
SET new_vaccinations = 363068
WHERE date = '2021-06-29';

UPDATE VaccinationStatus
SET new_vaccinations = 324568
WHERE date = '2021-07-02';

SELECT 
	date,
    population,
	new_vaccinations,
    total_vaccinations,
    (total_vaccinations/population) * 100 AS total_vaccinated_rate,
    people_fully_vaccinated,
    (people_fully_vaccinated/population) * 100 AS fully_vaccinated_rate
FROM 
	VaccinationStatus
ORDER BY date DESC;








    