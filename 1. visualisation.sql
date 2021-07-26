
-- 1. Total cases and total deaths in percentage
SELECT 
	SUM(new_cases) AS total_cases, 
    SUM(cast(new_deaths AS SIGNED)) AS total_deaths, 
    SUM(cast(new_deaths AS SIGNED))/SUM(new_cases)* 100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- 2. Total deats in each continent 
SELECT 
    location,
    SUM(CAST(new_deaths AS SIGNED)) AS total_death
FROM
    covid_deaths
WHERE
    continent IS NULL
        AND location NOT IN ('World' , 'European Union', 'International')
GROUP BY 1
ORDER BY 2 DESC;


-- 3. Total cases and population, people who have infected
SELECT 
    location,
    population,
    MAX(total_cases) AS highest_infection_count,
    (MAX(total_cases) / population) * 100 AS people_infected_rate
FROM
    covid_deaths
GROUP BY 1 , 2
ORDER BY 4 DESC;

-- 4. Infection rate in each country 
SELECT 
    location,
    population,
    STR_TO_DATE(date, '%d/%m/%Y') AS date,
    MAX(total_cases) AS hieghest_infection_count,
    MAX(total_cases / population) * 100 AS people_infected_rate
FROM
    covid_deaths
GROUP BY 1, 2, 3
ORDER BY 5 DESC;