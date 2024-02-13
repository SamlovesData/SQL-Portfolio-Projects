Select * 
FROM PortfolioProject1..CovidDeaths
Where continent is not null
order by 3,4

--Select * 
--FROM PortfolioProject1..CovidVaccinations
--order by 3,4


--Selecting the data we are going to use
select  Location,date, total_cases,total_deaths,new_cases, population
from PortfolioProject1..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- shows likelikihood of dying if you contract covid in your country 
select  Location,date, total_cases,total_deaths, (total_deaths/total_cases) *100 as DeathPercantage
from PortfolioProject1..CovidDeaths
where location like '%states%'
order by 1,2


--Looking at the total cases vs the population
-- shows what percentage of population has gotten covid
select  Location,date,population, total_cases, (total_cases/population) *100 as PercentofPopulationInfectected
from PortfolioProject1..CovidDeaths
where location like '%states%'
order by 1,2


--Looking at countries with highest infection rate compared to population 
select  Location,population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) *100 as PercentofPopulationInfectected
from PortfolioProject1..CovidDeaths

Group By location,population
order by PercentofPopulationInfectected desc


-- The Countries with the Hihgest Death Count Per Population.
select  Location,MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
Where continent is null
Group By location
order by TotalDeathCount desc



-- LET'S BREAK THINGS DOWN BY CONTINENT
select  continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
Where continent is null
Group By continent
order by TotalDeathCount desc




-- GLOBAL NUMBERS 

select   SUM(new_cases)AS TotalNewCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 as DeathPercantage
from PortfolioProject1..CovidDeaths
--where location like '%states%'
WHERE continent is not null 
--Group by date
order by 1,2

--Looking at Total Population vs Vaccinations 

Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM( cast(vac.new_vaccinations as int)) over (Partition by dea.Location Order By dea.Location, 
dea.Date) as RollingPeopleVaccinated

From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
Order By 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM( cast(vac.new_vaccinations as int)) over (Partition by dea.Location Order By dea.Location, 
dea.Date) as RollingPeopleVaccinated

From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--Order By 2,3
) 

SELECT *, (RollingPeopleVaccinated / Population) *100 as aVerage

From PopvsVac

-- TEMP TABLE 

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime,
Population numeric,
New_Vaccincations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated

Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM( cast(vac.new_vaccinations as int)) over (Partition by dea.Location Order By dea.Location, 
dea.Date) as RollingPeopleVaccinated

From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--Order By 2,3

Select * 
From #PercentPopulationVaccinated

--Creating view to store data later for visualizations 

Create View  PercentPopulationVaccinated as 
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM( cast(vac.new_vaccinations as int)) over (Partition by dea.Location Order By dea.Location, 
dea.Date) as RollingPeopleVaccinated

From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--Order By 2,3