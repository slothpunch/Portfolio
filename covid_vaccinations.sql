
RENAME TABLE null_covid_vaccinations TO covid_vaccinations;

SELECT *
FROM covid_vaccinations
LIMIT 20;

COMMIT;

ALTER TABLE covid_vaccinations
DROP COLUMN MyUnknownColumn;

DELETE FROM covid_vaccinations 
WHERE
    location = 'Afghanistan'
    AND date IN ('19/02/2020','20/02/2020', '21/02/2020', '22/02/2020', '23/02/2020');

-- ROLLBACK;

-- Connect covid_deaths and covid_vaccinations
SELECT 
    *
FROM
    covid_deaths dea
        JOIN
    covid_vaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent != ''
LIMIT 20;

-- Error: Unknown column
SELECT
		dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, STR_TO_DATE(dea.date, '%d/%m/%Y')) AS Rolling_People_Vaccinated,
        (Rolling_People_Vaccinated/dea.population)*100 AS Vaccinated_Percentage
FROM
		covid_deaths dea
				JOIN
		covid_vaccinations vac ON dea.location = vac.location
				AND dea.date = vac.date
		WHERE
				dea.continent != '';

-- Using CTE 
WITH VacPer (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
AS (
SELECT
		dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, STR_TO_DATE(dea.date, '%d/%m/%Y')) AS Rolling_People_Vaccinated
        -- (Rolling_People_Vaccinated/dea.population)*100 AS Vaccinated_Percentage
FROM
		covid_deaths dea
				JOIN
		covid_vaccinations vac ON dea.location = vac.location
				AND dea.date = vac.date
		WHERE
				dea.continent != ''
		-- ORDER BY 2
)
SELECT *, (Rolling_People_Vaccinated/population)*100 AS Vaccinated_Percentage
FROM VacPer;


COMMIT;
-- TEMP Table
DROP TABLE IF EXISTS PercentagePopulationVaccinated;
CREATE TEMPORARY TABLE PercentagePopulationVaccinated 
(
	continent VARCHAR(255),
    location VARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccination NUMERIC, 
    Rolling_People_Vaccinated NUMERIC
);

INSERT INTO PercentagePopulationVaccinated
SELECT
		dea.continent,
		dea.location,
		STR_TO_DATE(dea.date, '%d/%m/%Y'),
		dea.population,
		vac.new_vaccinations,
		SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, STR_TO_DATE(dea.date, '%d/%m/%Y')) AS Rolling_People_Vaccinated
FROM
		covid_deaths dea
				JOIN
		covid_vaccinations vac ON dea.location = vac.location
				AND dea.date = vac.date;

SELECT *, (Rolling_People_Vaccinated/population)*100 AS Vaccinated_Percentage
FROM PercentagePopulationVaccinated;

-- Creating View to store data for later visulisation
CREATE VIEW PercentagePopulationVaccinated AS
SELECT
		dea.continent,
		dea.location,
		STR_TO_DATE(dea.date, '%d/%m/%Y'),
		dea.population,
		vac.new_vaccinations,
		SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, STR_TO_DATE(dea.date, '%d/%m/%Y')) AS Rolling_People_Vaccinated
FROM
		covid_deaths dea
				JOIN
		covid_vaccinations vac ON dea.location = vac.location
				AND dea.date = vac.date;
