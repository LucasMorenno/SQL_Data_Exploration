create database COVID;
use COVID;

-- Imported 'coviddeaths' and 'covidvaccinations' tables, both based on data downloaded from https://ourworldindata.org/

select * from coviddeaths
where location = 'Brazil';

select Location, date, total_cases, new_cases, total_deaths, population
from coviddeaths;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths
where location = 'Brazil';

-- Looking at Total Cases vs Population
-- Shows waht percentage of population got Covid
select Location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
from coviddeaths
where location = 'Brazil';

-- Looking at Countries with Highest Infection Rate compared to Population

select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
from coviddeaths
group by location, population
order by PercentagePopulationInfected desc;

-- Showing Countries with Highest Death Count per Population
select Location, MAX(cast(total_deaths as SIGNED)) as TotalDeathCount 
from coviddeaths
where continent != ''
group by location
order by TotalDeathCount desc;

-- Showing Data by Continent
select continent, MAX(cast(total_deaths as SIGNED)) as TotalDeathCount 
from coviddeaths
where continent != ''
group by continent
order by TotalDeathCount desc;

-- Here it is possible to see that Total Deaths in North America is the same as in United States
-- It happened because the Total Deaths of North America was registered as a location called 'North America'
-- The real Total Deaths by continents is shown bellow

-- Showing Data by Continent 
select location, MAX(cast(total_deaths as SIGNED)) as TotalDeathCount 
from coviddeaths
where continent = ''
group by location
order by TotalDeathCount desc;

-- Global Numbers
select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as signed)) as TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
from coviddeaths
where continent != '' 
group by date
order by date;

-- Total Global Cases, Deaths and Percentage
select  SUM(new_cases) as TotalCases, SUM(cast(new_deaths as signed)) as TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
from coviddeaths
where continent != '' 
order by date;

-- Looking at Total Population vs Vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as signed)) over (partition by dea.location order by dea.location, dea.date) as accumulated_vaccination,
(SUM(cast(vac.new_vaccinations as signed)) over (partition by dea.location order by dea.location, dea.date)/population)*100 as percent_pop_vaccinated
from coviddeaths as dea
join covidvaccination as vac
on dea.location = vac.location 
and dea.date = vac.date
order by 2,3;

-- Creating a view of Percent Population Vaccinated in Brazil
create view percentpopvac as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as signed)) over (partition by dea.location order by dea.location, dea.date) as accumulated_vaccination,
(SUM(cast(vac.new_vaccinations as signed)) over (partition by dea.location order by dea.location, dea.date)/population)*100 as percent_pop_vaccinated
from coviddeaths as dea
join covidvaccination as vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.location = 'Brazil'
order by 2,3;