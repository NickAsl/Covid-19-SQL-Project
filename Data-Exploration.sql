-- General Info : 
-- In this project im using various queries , to explore the data and create basic measurements in order to have a 
-- clear view about the result of Covid-19.  


SELECT *
FROM  PortofolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4



-- Selecting the data im going to use :

SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM PortofolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY Location


-- Shows Total Cases Vs Total Deaths or likelyhood of dying if you contract covid in each country:

SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortofolioProject.dbo.CovidDeaths
WHERE location like 'Greece' and continent is not null
ORDER BY Location

-- Shows Total Cases vs Population or what percentage of population got Covid in each country:

SELECT Location,date,population,total_cases,(total_cases/population)*100 as PercentagePopulationInfected
FROM PortofolioProject.dbo.CovidDeaths
WHERE location like 'Greece' and continent is not null
ORDER BY Location


-- Shows Countries with Highest Infection rate compared to Population:

SELECT Location,population,MAX(total_cases)AS HigherInfectionCount,MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortofolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY Location , population
ORDER BY PercentagePopulationInfected desc



-- Analysis per Continent which shows the continent with the Highest Death count:

SELECT continent,MAX(total_deaths) as TotalDeathCount
FROM PortofolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


-- Global cases , Deaths and DeathPercentage:

SELECT SUM(new_cases) as total_cases,SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM PortofolioProject.dbo.CovidDeaths
WHERE continent is not null


--Looking at Total Population vs Vaccinations

SELECT DEA.continent,DEA.location,DEA.date,DEA.population,vac.new_vaccinations , SUM(CONVERT(int,vac.new_vaccinations)) 
OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) as RollingPeopleVaccinated	 
FROM PortofolioProject.dbo.CovidDeaths DEA
JOIN PortofolioProject.dbo.CovidVaccinations VAC
	ON DEA.location = VAC.location
	and DEA.date = VAC.date

WHERE DEA.continent is not null
ORDER BY 2

---------------------------------------------------------------------------------------- 
 -- USE CTE:

 WITH  PopvsVac (Continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
 AS	
(
SELECT DEA.continent,DEA.location,DEA.date,DEA.population,vac.new_vaccinations , SUM(CONVERT(int,vac.new_vaccinations)) 
OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) as RollingPeopleVaccinated	 
FROM PortofolioProject.dbo.CovidDeaths DEA
JOIN PortofolioProject.dbo.CovidVaccinations VAC
	ON DEA.location = VAC.location
	and DEA.date = VAC.date

WHERE DEA.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)
FROM PopvsVac

-------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------

-- ΤEMP TABLE :

DROP TABLE IF EXISTS #PercentPopulationVaccinationed
Create Table  #PercentPopulationVaccinationed
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT  INTO #PercentPopulationVaccinationed
SELECT DEA.continent,DEA.location,DEA.date,DEA.Population,VAC.new_vaccinations
,SUM(Convert(int,vac.new_vaccinations))OVER (PARTITION BY DEA.location ORDER BY DEA.location,DEA.date) 
as RollingPeopleVaccinated
FROM PortofolioProject.dbo.CovidDeaths DEA
JOIN PortofolioProject.dbo.CovidVaccinations VAC
	ON DEA.location = VAC.location
	and DEA.date = VAC.date
WHERE DEA.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)
FROM #PercentPopulationVaccinationed

------------------------------------------------------------------------------------------------

-- Creating a View to store data for later visualizations:

CREATE VIEW PercentPopulationVaccinatined as
SELECT DEA.continent,DEA.location,DEA.date,DEA.Population,VAC.new_vaccinations
,SUM(Convert(int,vac.new_vaccinations))OVER (PARTITION BY DEA.location ORDER BY DEA.location,DEA.date) 
as RollingPeopleVaccinated
FROM PortofolioProject.dbo.CovidDeaths DEA
JOIN PortofolioProject.dbo.CovidVaccinations VAC
	ON DEA.location = VAC.location
	and DEA.date = VAC.date
WHERE DEA.continent is not null


SELECT *
FROM PercentPopulationVaccinatined