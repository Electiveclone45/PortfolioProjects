SELECT *
FROM PortfolioProject.dbo.CovidDeaths$
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations$
--ORDER BY 3, 4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1, 2

-- Looking at the Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

SELECT total_cases, total_deaths
FROM PortfolioProject..CovidDeaths$


SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths as numeric)/CAST(total_cases as numeric))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
ORDER BY 1, 2

SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths as numeric)/CAST(total_cases as numeric))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE Location like '%Kingdom%'
ORDER BY 1, 2

SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths as numeric)/CAST(total_cases as numeric))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE Location like '%states%'
ORDER BY 1, 2

--Looking at Total Cases vs Population

SELECT Location, date, population, total_cases, (CAST(total_cases as numeric)/CAST(population as numeric))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE Location like '%states%'
ORDER BY 1, 2

SELECT Location, date, population, total_cases, (CAST(total_cases as numeric)/CAST(population as numeric))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE Location like '%stralia%'
ORDER BY 1, 2

-- Countries with highest infection rate compared to Population


SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX(CAST(total_cases as numeric)/CAST(population as numeric))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE Location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


-- Countries with highest death count compared to Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE Location like '%states%
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc

-- Broken down by continent


-- Showing the continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE Location like '%states%
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc



--Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE Location like '%states%'
WHERE continent	is not null
--GROUP BY date
ORDER BY 1, 2


--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3


--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac.

--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating view to store data for later visualisations

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated