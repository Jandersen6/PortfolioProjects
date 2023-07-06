select *
from SQLportfolio.dbo.CovidDeaths
Where continent is not null
order by 1,2

select *
from SQLportfolio.dbo.CovidVaccinations
Where continent is not null
order by 3,4


-- Looking at the Total Cases vs. Total Deaths
-- Shows the likelyhood of dying if you contract COVID

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from SQLportfolio.dbo.CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of Population contracted Covid

select Location, date, population, total_cases, (total_cases/population)*100 as PopulationInfectionPercentage
from SQLportfolio.dbo.CovidDeaths
Where location like 'United States'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationInfectionPercentage
from SQLportfolio.dbo.CovidDeaths
-- Where location like 'United States'
group by location, population
order by PopulationInfectionPercentage desc

-- Showing Death Rate per Continent

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from SQLportfolio.dbo.CovidDeaths
--Where location like 'United States'
Where continent is not null
group by continent
order by TotalDeathCount desc

-- Showing the Countries with the Highest Death Count per Population

select Location, MAX(total_deaths) as TotalDeathCount
from SQLportfolio.dbo.CovidDeaths
--Where location like 'United States'
Where continent is not null
group by location
order by TotalDeathCount desc

-- Breaking it down to the continent with the Highest Death Count

select location, MAX(total_deaths) as TotalDeathCount
From SQLportfolio.dbo.CovidDeaths
--Where location like 'United States'
Where continent is null
	and location not like '%income'
Group by location
Order by TotalDeathCount desc

-- GLOBAL NUMBERS

select SUM(CAST(new_cases as float)) as GlobalNewCases, SUM(CAST(new_deaths as float)) as GlobalNewDeaths, CASE WHEN SUM(CAST(new_deaths as float)) = 0 THEN 0
		ELSE SUM(CAST(new_deaths as float))/SUM(CAST(new_cases as float))*100 END as DeathPercentage -- total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from SQLportfolio.dbo.CovidDeaths
-- Where location like '%states%'
Where continent is not null
-- Group by date
order by 1,2

-- Looking at Total Population verses Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY CONVERT(varchar, getdate(), 1), dea.date) as VaccinationRollingCount --,
	 --(VaccinationRollingCount/population)*100
From SQLportfolio.dbo.CovidDeaths dea
Join SQLportfolio.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, VaccinationRollingCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY CONVERT(varchar, getdate(), 1), dea.date) as VaccinationRollingCount --,
	 --(VaccinationRollingCount/population)*100
From SQLportfolio.dbo.CovidDeaths dea
Join SQLportfolio.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (VaccinationRollingCount/population)*100
From PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
VaccinationRollingCount numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY CONVERT(varchar, getdate(), 1), dea.date) as VaccinationRollingCount --,
	 --(VaccinationRollingCount/population)*100
From SQLportfolio.dbo.CovidDeaths dea
Join SQLportfolio.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (VaccinationRollingCount/population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY CONVERT(varchar, getdate(), 1), dea.date) as VaccinationRollingCount --,
	 --(VaccinationRollingCount/population)*100
From SQLportfolio.dbo.CovidDeaths dea
Join SQLportfolio.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated