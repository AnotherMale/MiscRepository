--Ensuring that data has been properly imported

Select *
From PortfolioProject1.. CovidDeaths
where continent is not null
order by 3,4

Select *
From PortfolioProject1.. CovidVaccinations
where continent is not null
order by 3,4

-- Querying for specific data

Select location, date, continent, total_cases, new_cases, total_deaths, population
From PortfolioProject1.. CovidDeaths
where continent is not null
order by 1,2

create view data_view as
Select location, date, continent, total_cases, new_cases, total_deaths, population
From PortfolioProject1.. CovidDeaths
where continent is not null

-- Daily probability of death if diagnosed with covid in the United States

Select location, date, continent, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProject1.. CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

create view death_percentage_view as
Select location, date, continent, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProject1.. CovidDeaths
Where location like '%states%'
and continent is not null

-- Daily probability of infection in the United States

Select location, date, continent, total_cases, population, (total_cases/population)*100 as infection_percentage
From PortfolioProject1.. CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

create view infection_percentage_view as
Select location, date, continent, total_cases, population, (total_cases/population)*100 as infection_percentage
From PortfolioProject1.. CovidDeaths
Where location like '%states%'
and continent is not null

-- Countries with highest total cases to population ratio

Select location, continent, MAX(total_cases) as max_infection_count, population, MAX(total_cases/population)*100 as max_infection_percentage
From PortfolioProject1.. CovidDeaths
where continent is not null
Group by location, population, continent
order by max_infection_percentage desc

create view max_infection_percentage_view as
Select location, continent, MAX(total_cases) as max_infection_count, population, MAX(total_cases/population)*100 as max_infection_percentage
From PortfolioProject1.. CovidDeaths
where continent is not null
Group by location, population, continent

-- Countries with highests total deaths

Select location, continent, MAX(cast(total_deaths as int)) as max_death_count
From PortfolioProject1.. CovidDeaths
where continent is not null
Group by location, continent
order by max_death_count desc

create view country_max_death_count_view as
Select location, continent, MAX(cast(total_deaths as int)) as max_death_count
From PortfolioProject1.. CovidDeaths
where continent is not null
Group by location, continent

-- Ordering continents by highest total deaths

Select location, MAX(cast(total_deaths as int)) as max_death_count
From PortfolioProject1.. CovidDeaths
where continent is null
Group by location
order by max_death_count desc

create view continent_max_death_count_view as
Select location, MAX(cast(total_deaths as int)) as max_death_count
From PortfolioProject1.. CovidDeaths
where continent is null
Group by location

-- Daily global statistics

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
From PortfolioProject1.. CovidDeaths
where continent is not null
group by date
order by 1,2

create view daily_global_statistics_view as 
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
From PortfolioProject1.. CovidDeaths
where continent is not null
group by date

-- Global statistics

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
From PortfolioProject1.. CovidDeaths
where continent is not null
order by 1,2

create view global_statistics_view as
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
From PortfolioProject1.. CovidDeaths
where continent is not null

-- Comparing rolling vaccinations to population

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as rolling_vaccinations
From PortfolioProject1.. CovidDeaths dea
Join PortfolioProject1.. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- CTE

With PopvsVac (continent, location, date, population, new_vaccinations, rolling_vaccinations)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as rolling_vaccinations
From PortfolioProject1.. CovidDeaths dea
Join PortfolioProject1.. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (rolling_vaccinations/population)*100
From PopvsVac

-- Inserting into temp table

drop table if exists vaccination_percentage
Create Table vaccination_percentage
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccinations numeric
)

Insert into vaccination_percentage
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as rolling_vaccinations
From PortfolioProject1.. CovidDeaths dea
Join PortfolioProject1.. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (rolling_vaccinations/population)*100
From vaccination_percentage

create view vaccination_percentage_view as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as rolling_vaccinations
From PortfolioProject1.. CovidDeaths dea
Join PortfolioProject1.. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null