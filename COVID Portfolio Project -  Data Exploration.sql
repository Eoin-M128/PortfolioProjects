/*
Covid-19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Covering Data Types

*/

SELECT * FROM 
PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER by 3,4


-- Select Data that we are going start with

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in the United Kingdom

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%kingdom%'
ORDER by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population has contracted Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as ContractionPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Kingdom%'
ORDER by 1,2


-- Looking at Countries with highest infection rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as ContractionPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER by ContractionPercentage desc


-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%kingdom%'
WHERE continent is not null
GROUP BY Location, Population
ORDER by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing the continents with the highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%kingdom%'
WHERE continent is null
GROUP BY location
ORDER by TotalDeathCount desc


-- THE DRILL DOWN EXCLUSIVE

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%kingdom%'
WHERE continent is not null
GROUP BY continent
ORDER by TotalDeathCount desc


-- GLOBAL NUMBERS 

SELECT  date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group by date
ORDER by 1,2

--Showing the total cases, deaths and the death percentage of confirmed cases

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER by 1,2


-- Looking at Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER 
(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER 
(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric, 
)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER 
(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating views to store data later for visualisations



CREATE View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER 
(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3





CREATE VIEW ContinentalDeathCount as
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent




CREATE VIEW WorldwideDeathPercentage as
SELECT  date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group by date




CREATE VIEW ContractionPercentage as
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as ContractionPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population


