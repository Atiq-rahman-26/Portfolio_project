select*
from portfolio_project.dbo.coviddeaths
order by 3,4

--select*
--from portfolio_project..covidvaccination
--order by 3,4

--select data that we are going to be using

select *
from covid_death

select *
from portfolio_project.dbo.covidvaccination
order by 3,4

select *
from covid_death
where continent is not null
order by 1,2


--total cases vs total death
--likelihood of dying in BD

select location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 as death_percentage
from covid_death
where location like '%bangla%'
order by 1,2


--looking at the total cases vs population
--what percentage got covid in my country?

select location, date, population, total_cases, ( total_cases/population)*100 as death_percentage
from covid_death
where location like '%bangla%'
order by 1,2

--looking at countries at highest infection rate vs population

select location, population, max(total_cases) as infected, max(( total_cases/population))*100 as percent_infected
from covid_death
--where location like '%bangla%'
group by location, population
order by percent_infected desc


--how many people died? 
--showning countries with highest death count pop

select location, max(cast(total_deaths as int)) as total_death_count
from covid_death
--where location like '%bangla%'
where continent is not null
group by location, population
order by total_death_count desc

--down by continent


select location, max(cast(total_deaths as int)) as total_death_count
from covid_death
--where location like '%bangla%'
where continent is null
group by location
order by total_death_count desc



--continent wise death count

select continent, max(cast(total_deaths as int)) as total_death_count
from covid_death
--where location like '%bangla%'
where continent is not null
group by continent
order by total_death_count desc


--breaking global numbers


select  sum(new_cases) as total_cases, sum(cast(new_deaths as int))as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from covid_death
--where location like '%bangla%'
where continent is not null
--group by date
order by 1,2 



--total pop vs vaccination



select*
from covid_death as dea
join Covidvaccination vac
	on dea.location = vac.location
	and dea.date = vac.date


	--how many people got vaccinated!!
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccinated
from covid_death as dea
join Covidvaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3



--use cte



with popvsvac (continent, location, date, population, new_vaccinations, rolling_vaccinated )
as(
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations

, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccinated

from covid_death as dea
join Covidvaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3
)
select* , (rolling_vaccinated/ population)*100
from popvsvac






--temp table

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccination numeric,
rolling_vaccinated numeric
)

insert into #percentpopulationvaccinated
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations

, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccinated

from covid_death as dea
join Covidvaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3
select* , (rolling_vaccinated/ population)*100
from #percentpopulationvaccinated


create view percentpopulationvaccinated as
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations

, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccinated

from covid_death as dea
join Covidvaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3 


select *
from percentpopulationvaccinated