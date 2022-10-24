
--SELECT * from [PORTFOLIO PROJECT]..[COVID VACC]
--order by 3,4
select * 
from [PORTFOLIO PROJECT]..COVIDDEATHS
where continent is not null
order by  3,4

SELECT location,DATE, total_cases,new_cases, total_deaths,population 
FROM [PORTFOLIO PROJECT]..COVIDDEATHS
where continent is not null
order by 1,2

--- Total Cases vs Total death--
SELECT location,date ,total_cases, total_deaths ,(total_deaths/total_cases)*100 as 'Deathpercentage'
FROM [PORTFOLIO PROJECT]..COVIDDEATHS
where continent is not null
order by 1,2
--cases in India and death percentage--
SELECT location,date ,total_cases, total_deaths ,(total_deaths/total_cases)*100 as 'Deathpercentage'
FROM [PORTFOLIO PROJECT]..COVIDDEATHS
where location like '%India%'
order by 1,2

--Total cases vs Population--
SELECT location,date ,total_cases,population,(total_cases/population)*100 as 'CasePercentage'
FROM [PORTFOLIO PROJECT]..COVIDDEATHS
order by 1,2
--Spain total cases vs Population--
SELECT location,date ,total_cases,population,(total_cases/population)*100 as 'CasePercentage'
FROM [PORTFOLIO PROJECT]..COVIDDEATHS
where location like 'Spain'
order by 1,2

-- Highest Infection Rate by countries Vs Population--
SELECT location,population,max(total_cases) as 'High Infection count',max((total_cases/population))*100 as '% of Population infected'
FROM [PORTFOLIO PROJECT]..COVIDDEATHS
group by population, location
order by "% of Population infected" desc

--- Highest death rate by country vs population in percent--
SELECT location,population,max(total_deaths) as 'Total death count',max((total_deaths/population))*100 as '% of Population death'
FROM [PORTFOLIO PROJECT]..COVIDDEATHS
--where location like '%States%'
group by population, location
order by "% of Population death" desc

-- Alternatively lets see in Count--
SELECT location,max(cast(total_deaths as int)) as 'Total death count'
FROM [PORTFOLIO PROJECT]..COVIDDEATHS
--where location like '%States%'
where continent is not null
group by population, location
order by "Total death count" desc

-- CONTINENT WISE ANALYSIS--
SELECT continent,SUM(cast(total_deaths as int)) as 'Total death count'
FROM [PORTFOLIO PROJECT]..COVIDDEATHS
WHERE continent IS not NULL
GROUP BY continent
order by "Total death count" desc

-- Continent with highes death count per population--


-- Global number--
-- Death count and no on each day with Percentage--
SELECT date ,Sum(new_cases) as 'Total Cases',sum(cast(new_deaths as int)) as 'Total Death',sum(cast(new_deaths as int))/Sum(new_cases)*100 as 'Deathpercentage'
FROM [PORTFOLIO PROJECT]..COVIDDEATHS
where continent is not null
group by date
order by 1,2

-- JOINING VACCINATION DATASET--
select * 
FROM [PORTFOLIO PROJECT]..CovidDeaths dea
join [PORTFOLIO PROJECT]..CovidVaccinations vac
on dea.location = vac.location
and dea.date= vac.date

-- Analyse Total Population vs Vaccination
select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.Date) as 'Vaccinated people count' 
FROM [PORTFOLIO PROJECT]..CovidDeaths dea
join [PORTFOLIO PROJECT]..CovidVaccinations vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
order by 2,3

-- using CTE METHOD TO CALCULATE PERCENTAGE OF VACCINATED VS POPULATION--
-- here we use this method to see increase of vaccination count in percent--
WITH PopvsVac (continent,location , date, population,new_vaccinations,Vaccinatedpeoplecount)
as
(
select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.Date) as Vaccinatedpeoplecount 
FROM [PORTFOLIO PROJECT]..CovidDeaths dea
join [PORTFOLIO PROJECT]..CovidVaccinations vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(Vaccinatedpeoplecount/population)*100 as '% of Vaccinate people'
From PopvsVac

--TEMP TABLE--
drop table if exists #VaccinationPopulationpercent
Create table #VaccinationPopulationpercent
(Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Vaccinatedpeoplecount numeric
)
select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.Date) as Vaccinatedpeoplecount 
FROM [PORTFOLIO PROJECT]..CovidDeaths dea
join [PORTFOLIO PROJECT]..CovidVaccinations vac
on dea.location = vac.location
and dea.date= vac.date
--where dea.continent is not null
--order by 2,3
Select *,(Vaccinatedpeoplecount/population)*100 as '% of Vaccinate people'
From #VaccinationPopulationpercent

-- CREATING VIEW FOR STORING DATA FOR VISUALIZATION--
Create View VaccinationPopulationpercent as 
select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.Date) as Vaccinatedpeoplecount 
FROM [PORTFOLIO PROJECT]..CovidDeaths dea
join [PORTFOLIO PROJECT]..CovidVaccinations vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
-- order by 2,3

select * 
from VaccinationPopulationpercent