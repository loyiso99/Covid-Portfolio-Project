Select *
From [Portfolio Project]..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
order by 3,4

--Loooking at total cases vs total deaths
-- Shows the likelihood of dying if you contract covid ih your country

Select Location, date, total_cases, total_deaths, (cast(total_deaths as int)/cast(total_cases as int))*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where Location like 'South_Africa'
Order By 1, 2

-- Looking at the total  cases vs population
--Shows what percentage of population got Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
From [Portfolio Project]..CovidDeaths
Where Location like 'South_Africa'
Order By 1, 2

--What counties have highest infecion rates compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CovidPercentage
From [Portfolio Project]..CovidDeaths
--Where Location like 'South_Africa'
Group By Location, Population
Order By CovidPercentage desc


--Showing countries with highest death count per population

Select Location, Max(total_deaths) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where Location like 'South_Africa'
Where continent is not null
Group By Location
Order By TotalDeathCount  desc

--Showing poptulations with the highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where Location like 'South_Africa'
Where continent is not null
Group By continent 
Order By TotalDeathCount  desc



--Global Numbers
--Might not use this one

Select date, Sum(new_cases), Sum(cast(new_deaths as int))--, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
where continent is not null
Group by date
order by 1, 2


--Looking at total population vs vaccinations
--this is where we start using joins

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1, 2, 3


--Take note, Sum is to big to be a int, hence we cast it as a bigint
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as bigint)) over(partition by dea.location)
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1, 2, 3


--add an order by, by the partition so that is shows the totals as they are added daily. this is a rolling count

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as bigint)) over(partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1, 2, 3
)




--Use a CTE (TEMPORARY Table)

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccination)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as bigint)) over(partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1, 2, 3
)
Select *, (RollingPeopleVaccination/Population)*100
From PopvsVac



--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccination numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as bigint)) over(partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1, 2, 3
Select *, (RollingPeopleVaccination/Population)*100
From #PercentPopulationVaccinated




--Creating View to store data for later visualisations

Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as bigint)) over(partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1, 2, 3