SELECT *
FROM Project1.dbo.CovidDeaths
order by 3,4

SELECT *
FROM Project1..CovidVaccinations
order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Project1.dbo.CovidDeaths
order by 1,2

--comparison of total_cases vs total_deaths
--probability of dying if you contract covid in your country 
SELECT location, date, total_cases, total_deaths , (total_deaths/total_cases)*100 as Death_Percentage
FROM Project1.dbo.CovidDeaths
where location like '%states%'
order by 1,2

----comparison of total_cases vs population
----what percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as Population_Percentage
FROM Project1.dbo.CovidDeaths
order by 1,2

----looking at countries with highest contamination rate compared to population
SELECT location, population, MAX(total_cases) as HighestContamination_Count, MAX((total_cases/population))*100 as Population_Percentage
FROM Project1.dbo.CovidDeaths
GROUP BY location, population
order by Population_Percentage desc

----display continents with highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeath_Count
FROM Project1.dbo.CovidDeaths
where continent is not NULL
GROUP BY continent
order by TotalDeath_Count desc

----calculating global numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM Project1.dbo.CovidDeaths
where continent is not NULL
--GROUP BY date
order by 1,2

--total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT( bigint,vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) as RollingPeople_Vaccinated  
FROM Project1.dbo.CovidDeaths dea
JOIN Project1.dbo.CovidVaccinations vac
    On dea.location = vac.location and dea.date = vac.date
where dea.continent is not NULL
order by 2,3


--using CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeople_Vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT( bigint,vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) as RollingPeople_Vaccinated  
FROM Project1.dbo.CovidDeaths dea
JOIN Project1.dbo.CovidVaccinations vac
    On dea.location = vac.location and dea.date = vac.date
where dea.continent is not NULL
)
SELECT *, (RollingPeople_Vaccinated/population)*100 as Rolling_Percentage
FROM PopvsVac

--TEMP table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
( 
  Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  Population numeric,
  New_vaccinations numeric,
  RollingPeople_Vaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT( bigint,vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) as RollingPeople_Vaccinated  
FROM Project1.dbo.CovidDeaths dea
JOIN Project1.dbo.CovidVaccinations vac
    On dea.location = vac.location and dea.date = vac.date
--where dea.continent is not NULL
SELECT *, (RollingPeople_Vaccinated/population)*100 as Rolling_Percentage
FROM #PercentPopulationVaccinated


--creating view to store data for later visualizations
Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT( bigint,vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) as RollingPeople_Vaccinated  
FROM Project1.dbo.CovidDeaths dea
JOIN Project1.dbo.CovidVaccinations vac
    On dea.location = vac.location and dea.date = vac.date
where dea.continent is not NULL
