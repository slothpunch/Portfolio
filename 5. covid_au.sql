

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

-- How many people are tested everyday
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


-- vaccinated

    
    
    