-- Select Data that we are going to be starting with

SELECT 
    Location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    Portfolio.CovidDeaths_2
WHERE
    continent IS NOT NULL
ORDER BY 1 , 2;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT 
    Location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS DeathPercentage
FROM
    Portfolio.CovidDeaths_2
WHERE
    location LIKE '%India%'
        AND continent IS NOT NULL
ORDER BY 1 , 2;


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT 
    Location,
    date,
    Population,
    total_cases,
    (total_cases / population) * 100 AS PercentPopulationInfected
FROM
    Portfolio.CovidDeaths_2
ORDER BY 1 , 2;


-- Countries with Highest Infection Rate compared to Population

SELECT 
    Location,
    Population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM
    Portfolio.CovidDeaths_2
GROUP BY Location , Population
ORDER BY PercentPopulationInfected DESC;


-- Countries with Highest Death Count per Population

SELECT 
    Location, MAX((Total_deaths)) AS TotalDeathCount
FROM
    Portfolio.CovidDeaths_2
WHERE
    continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;


-- Showing contintents with the highest death count per population

SELECT 
    continent, MAX(Total_deaths) AS TotalDeathCount
FROM
    Portfolio.CovidDeaths_2
WHERE
    continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- GLOBAL NUMBERS

SELECT 
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    SUM(new_deaths) / SUM(New_Cases) * 100 AS DeathPercentage
FROM
    Portfolio.CovidDeaths_2
WHERE
    continent IS NOT NULL
ORDER BY 1 , 2;



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date)
 as RollingPeopleVaccinated
From Portfolio.CovidDeaths_2 dea
Join Portfolio.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Portfolio.CovidDeaths_2 dea
Join Portfolio.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated (
    Continent VARCHAR(255),
    Location VARCHAR(255),
    Date DATE,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

/*INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    (SELECT SUM(new_vaccinations) FROM CovidVaccinations WHERE location = dea.location AND date <= dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths_2 dea
JOIN CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date; */

SELECT 
    *,
    (RollingPeopleVaccinated / Population) * 100 AS PercentPopulationVaccinated
FROM
    PercentPopulationVaccinated;





-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinatedView as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Portfolio.CovidDeaths_2 dea
Join Portfolio.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;

SELECT 
    *
FROM
    PercentPopulationVaccinatedView;

