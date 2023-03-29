SELECT  *
FROM portfolioproject..['Covid deaths$']
WHERE continent is not null
Order by 3,4

SELECT * 
FROM portfolioproject..['Covid vaccinations$']
WHERE continent is not null
Order by 3,4

--Data Exploration --
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolioproject..['Covid deaths$']
WHERE continent is not null
Order by 1,2

--Total cases vs Total Deaths --

SELECT location, date, total_cases,total_deaths, (CAST(total_deaths AS float)/total_cases) *100 as DeathPercentage
FROM portfolioproject..['Covid deaths$']
Order by 1,2

--Death percentage in INDIA--

SELECT location, date, total_cases,total_deaths, (CAST(total_deaths AS float)/total_cases) *100 as DeathPercentage
FROM portfolioproject..['Covid deaths$']
WHERE location like '%India%'
Order by 1,2

-- Total cases vs Popluation --

SELECT location, date,  population, total_cases,(total_cases / population) *100 as Population_cases
FROM portfolioproject..['Covid deaths$']
Order by 1,2

--Highest cases by countries --

SELECT location,population, MAX(total_cases) as Highest_totalcases, MAX((total_cases / population)) *100 as Highest_cases
FROM portfolioproject..['Covid deaths$']
GROUP by location,Population
ORDER by Highest_cases DESC

--Lowest cases by countries --

SELECT location,population, MIN(total_cases) as lowest_totalcases, MIN((total_cases / population)) *100 as Lowest_cases
FROM portfolioproject..['Covid deaths$']
GROUP by location,Population
ORDER by lowest_cases DESC

-- Highest Death cases by countries --

SELECT location, population, MAX(CAST(total_deaths AS int)) as Highest_totaldeaths,MAX((total_deaths / population))*100 as Highest_deathpercent
FROM portfolioproject..['Covid deaths$']
WHERE continent is not null
GROUP by location,Population
ORDER by Highest_deathpercent DESC

-- Lowest Death cases by countries --

SELECT location, population, MIN(CAST(total_deaths AS int)) as lowest_totaldeaths,MIN((total_deaths / population))*100 as Lowest_deathpercent
FROM portfolioproject..['Covid deaths$']
GROUP by location,Population
ORDER by Lowest_deathpercent DESC

-- Exract By the Continent --

SELECT continent, MAX(CAST(total_deaths AS int)) as Total_totaldeaths
FROM portfolioproject..['Covid deaths$']
WHERE continent is not null
GROUP by continent
ORDER by Total_totaldeaths DESC

--Global Numbers --

SELECT SUM(new_cases) as totalcases , SUM(CAST(new_deaths AS int)) as totaldeaths, 
SUM(CAST(new_deaths AS int)) / NULLIF(SUM(new_cases),0)*100 AS deathpercentage
FROM portfolioproject..['Covid deaths$']
WHERE continent is not null
ORDER by 1,2

--Joining Two tables --

SELECT * 
FROM portfolioproject..['Covid deaths$']  dea
JOIN portfolioproject..['Covid vaccinations$'] vac 
     On dea.location = vac.location
	 and dea.date = vac.date

--Total Vaccinations vs Population

SELECT dea.continent,dea.date, dea.location, dea.population, vac.new_vaccinations
FROM portfolioproject..['Covid deaths$']  dea
JOIN portfolioproject..['Covid vaccinations$'] vac 
     On dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3

SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolioproject..['Covid deaths$']  dea
JOIN portfolioproject..['Covid vaccinations$'] vac 
     On dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE --

WITH PopvsVac (Continent, Location, Date, Population, New_vacinations, RollingPeopleVaccinated) as (
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolioproject..['Covid deaths$']  dea
JOIN portfolioproject..['Covid vaccinations$'] vac 
     On dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated / Population)*100 as Vaccinatedpeople
FROM PopvsVac
 

 -- TEMP TABLE --
 CREATE TABLE #PercentVaccinatedPopulation
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )
 Insert into #PercentVaccinatedPopulation
 SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolioproject..['Covid deaths$']  dea
JOIN portfolioproject..['Covid vaccinations$'] vac 
     On dea.location = vac.location
	 and dea.date = vac.date
SELECT *, (RollingPeopleVaccinated / Population)*100 as Vaccinatedpeople
FROM  #PercentVaccinatedPopulation


--Creating View to store data for later visualizations-- 

Create View PercentVaccinatedPopulation as
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolioproject..['Covid deaths$']  dea
JOIN portfolioproject..['Covid vaccinations$'] vac 
     On dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null

SELECT * 
FROM PercentVaccinatedPopulation