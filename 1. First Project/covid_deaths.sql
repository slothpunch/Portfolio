-- AUTSTRLAIA
SELECT * 
FROM covid_deaths
-- WHERE iso_code LIKE 'OWID%';
GROUP BY location;
COMMIT;
-- UPDATE covid_deaths 
-- SET 
--     continent = REPLACE(continent, ' ', NULL);

ROLLBACK;

-- Total cases and total deaths
SELECT location, date, population, total_cases, total_deaths
FROM covid_deaths
WHERE location = 'Australia';

-- Total cases and Total deaths in percentage
SELECT location, date, population, total_cases, total_deaths, (total_deaths/total_cases) * 100 as death_percentage
FROM covid_deaths
WHERE location = 'Australia';

-- Total cases and population, people who have infected
SELECT 
    location,
    population,
    MAX(total_cases),
    (MAX(total_cases) / population) * 100 AS people_infected_percentage
FROM
    covid_deaths
GROUP BY 1 , 2
ORDER BY 4 DESC;

-- Infection rate in each country 
SELECT location, population, MAX(total_cases) as Hieghest_Infection, MAX(total_cases/population) * 100 as people_infected
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC;

-- Highest death toll
SELECT 
    location,
    population,
    -- CAST(MAX(total_deaths) AS INT) <-- Not work. SIGNED is a signed 64-bit integer 
    CAST(MAX(total_deaths) AS SIGNED) AS Hieghest_Death,
    MAX(total_deaths / population) * 100 AS people_dead
FROM
    covid_deaths
WHERE continent != ''
GROUP BY 1, 2
ORDER BY 3 DESC;

COMMIT;

SELECT * FROM covid_deaths; # 95596

SELECT COUNT(*) FROM covid_deaths; # 95596

SELECT COUNT(*) FROM covid_deaths WHERE continent = ''; # 3135

SELECT COUNT(*) FROM covid_deaths WHERE continent != ''; # 92461 = 95596 - 3135


-- total deaths in continent 
SELECT iso_code, continent, location, CAST(total_deaths AS SIGNED)-- , MAX(CAST(total_deaths AS SIGNED)) AS Total_Death_Count
FROM covid_deaths
-- WHERE continent = ''
-- GROUP BY 1
ORDER BY 3, 4 DESC;

SELECT continent, MAX(CAST(total_deaths AS SIGNED)) AS Total_Death_Count
FROM covid_deaths
WHERE continent != ''
GROUP BY 1
ORDER BY 2 DESC;

-- All countries where their continent is Asia
SELECT continent, location, MAX(CAST(total_deaths AS SIGNED)) AS Total_Death_Count
FROM covid_deaths
WHERE continent = 'Asia'
GROUP BY 1, 2
ORDER BY 2;

SELECT 
    SUM(Total_Death_Count) AS AsiaTotalDeath
FROM
    (SELECT 
        continent,
            location,
            MAX(CAST(total_deaths AS SIGNED)) AS Total_Death_Count
    FROM
        covid_deaths
    WHERE
        continent = 'Asia'
    GROUP BY 1 , 2
    ORDER BY 2) a; -- Create a row called OWID_??? and add the result 

-- Global deaths and cases 
SELECT STR_TO_DATE(date,'%d/%m/%Y')-- means change d m Y to Y m d ?
FROM covid_deaths;

SELECT 
    STR_TO_DATE(date, '%d/%m/%Y') AS date,
    SUM(new_cases) AS Global_Total_Cases,
    SUM(new_deaths) AS Global_Total_Deaths,
    (SUM(new_deaths) / SUM(new_cases)) * 100 AS Death_Percentage
FROM
    covid_deaths
GROUP BY 1
ORDER BY 1;

SELECT 
    SUM(new_cases) AS Global_Total_Cases,
    SUM(new_deaths) AS Global_Total_Deaths,
    (SUM(new_deaths) / SUM(new_cases)) * 100 AS Death_Percentage
FROM
    covid_deaths;

-- --
