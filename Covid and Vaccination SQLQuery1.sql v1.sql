--SELECT *
--FROM CovidDeaths
--ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

--Select the data we are going to be using

SELECT location, date, total_cases,new_cases,total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--Looking at Total cases vs Total Death ratio in different locations
--Show the likelihood of Covid Death in a certain Country
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE LOCATION LIKE '%state%'
ORDER BY 1,2 

--Look at Total case VS Population
--Whow what percentage of population got Covid in Canada 
--It shows until 2021-04-30, about 3.25% percent of Canadian population got Covid

SELECT Location,date, total_cases, population, (total_cases/population)*100 as CasePercentage
FROM CovidDeaths
WHERE location = 'Canada'
ORDER BY 1,2

--Which country has the highest infection rate compared to populations?
--It shows Andorra has the highest infection rate at 17.13%

SELECT Location, MAX(total_cases/population)*100 as CasePercentage
FROM CovidDeaths
GROUP BY location
ORDER BY 2 DESC

--Show max death by region, using CAST function change nvarchar to int:
SELECT Location, MAX(CAST(total_deaths as int)) as Maxdeath
From CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY 2 DESC

--Join two table together
--Looking at toal population vs vaccination 
--This shows the total Candadian population and newly vaccinated population per day

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
FROM CovidDeaths as dea
	JOIN CovidVaccinations as vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null AND dea.location='Canada'
ORDER BY 1,2,3

--This shows the total Candadian population and the SUM of newly vaccinated population per day

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)  as SumVaccination
FROM CovidDeaths as dea
	JOIN CovidVaccinations as vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null 
ORDER BY 1,2,3


--USE CTE method
--Now we check the total population that are vaccinated compare the the population IN Canada
--With the below using CTE methon, we can see until 2021-04-30, 35.6% of Canadian population has been vaccinated


WITH CTE_PopVsVac (Continent, Location, Date, Population, new_vaccinations, SumVaccination)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)  as SumVaccination
FROM CovidDeaths as dea
	JOIN CovidVaccinations as vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null 
)
SELECT *, (SumVaccination/Population)*100 as VacPercentage
FROM CTE_PopVsVac
WHERE Location='Canada'



--USING TEMP table TO do the same thing above
--We can see until 2021-04-30, 35.6% of Canadian population has been vaccinated


DROP Table if exists #PercentPopVaccinated
CREATE TABLE #PercentPopVaccinated
(Continent nvarchar(50),
Location nvarchar(50),
Date datetime,
Population numeric,
New_vaccinations numeric,
SumVaccination numeric
)

INSERT INTO #PercentPopVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)  as SumVaccination
FROM CovidDeaths as dea
	JOIN CovidVaccinations as vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null 

SELECT *, (SumVaccination/Population)*100 as VacPercentage
FROM #PercentPopVaccinated
WHERE Location='Canada'



--Creating View to store data for visualization

CREATE VIEW PercentPopVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)  as SumVaccination
FROM CovidDeaths as dea
	JOIN CovidVaccinations as vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null 
