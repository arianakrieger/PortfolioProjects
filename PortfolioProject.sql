/*
COVID 19 Data Exploration Project

Skills used: Joins, CTE's, Converting Data Types, Temp Tables, Windows Functions, Aggregate Functions, Creating Views

*/

---------------------------------------------------------------------------------------------------------------------------

SELECT*
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
ORDER BY 3,4

/* Select data that we are going to be using */

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
ORDER BY 1,2

---------------------------------------------------------------------------------------------------------------------------

/* Looking at Total Cases vs Total Deaths */

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
AND continent IS NOT null
ORDER BY 1,2

---------------------------------------------------------------------------------------------------------------------------

/* Looking at Total Cases vs Population */

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
AND continent IS NOT null
ORDER BY 1,2

---------------------------------------------------------------------------------------------------------------------------

/* Looking at Countries with Highest Infection Rate Compared to Population */

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

---------------------------------------------------------------------------------------------------------------------------

/* Showing Countries with Highest Death Count per Population */

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
GROUP BY location
ORDER BY TotalDeathCount DESC

---------------------------------------------------------------------------------------------------------------------------

/* BREAKING THINGS DOWN BY CONTINENT */

/* Showing Continents with Highest Death Count per Population */

SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
GROUP BY continent
ORDER BY TotalDeathCount DESC

---------------------------------------------------------------------------------------------------------------------------

/* Global Numbers */

SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS int)) AS TotalDeaths, SUM(cast(new_deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
GROUP BY date
ORDER BY 1,2

---------------------------------------------------------------------------------------------------------------------------

/* Lookinjg at Total Population vs Vaccinations */

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT null
ORDER BY 2,3

---------------------------------------------------------------------------------------------------------------------------

/* Using CTE to Perform Calcuation on Partition By in Previous Query */

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT null
)
SELECT*,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac

---------------------------------------------------------------------------------------------------------------------------

/* Using Temp Table to Perform Calculation on Parition By in Previous Query*/

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null

SELECT*,(RollingPeopleVaccinated/Population)*100
FROM #PercentagePopulationVaccinated

---------------------------------------------------------------------------------------------------------------------------
/* Creating View to Store Data for later visualizations */

CREATE View PercentagePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
