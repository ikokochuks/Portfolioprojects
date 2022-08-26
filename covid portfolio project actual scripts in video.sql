SELECT *
FROM [Portfolio Project]..CovidDeaths$
Where continent  is not Null
ORDER BY 3,4

--SELECT *
--FROM [Portfolio Project]..CovidVaccinations$
--ORDER BY 3,4

--Select data that we are going to be using

SELECT location, date,total_cases,new_cases,total_deaths,population
FROM [Portfolio Project]..CovidDeaths$
 WHERE continent  is not Null
order by 1,2

--Looking for total cases vs total death
--This show the liklihood of dying if you contract covid in your country 

SELECT location, date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage 
FROM [Portfolio Project]..CovidDeaths$
WHERE location like '%State%'
order by 1,2


----Looking at the total_case vs popluation 
--Shows what percentage of population got covid

SELECT location, date,population,total_cases,(total_cases/population)*100 as percentpopluationinfected
FROM [Portfolio Project]..CovidDeaths$
--WHERE location like '%State%'
order by 1,2

--Looking at countries with the highest infection rate compare to popluation 

SELECT location,population,Max(total_cases) as Highestpopluationcount,Max((total_cases/population))*100 as percentpopluationinfected
FROM [Portfolio Project]..CovidDeaths$
--WHERE location like '%State%'
Group by location,population
order by percentpopluationinfected Desc

--Showing the countries with the highest death count per popluation

SELECT location,Max( cast (total_deaths as int)) as Totaldeathcount
FROM [Portfolio Project]..CovidDeaths$
--WHERE location like '%State%'
Where continent is not null
Group by location
order by Totaldeathcount Desc

--Lets break things by continent 

--SELECT location,Max( cast (total_deaths as int)) as Totaldeathcount
--FROM [Portfolio Project]..CovidDeaths$
----WHERE location like '%State%'
--Where continent is null
--Group by location
--order by Totaldeathcount Desc

SELECT continent,Max( cast (total_deaths as int)) as Totaldeathcount
FROM [Portfolio Project]..CovidDeaths$
--WHERE location like '%State%'
Where continent is not null
Group by continent
order by Totaldeathcount Desc

--Showing the continent with the highest death count per population

SELECT continent,Max( cast (total_deaths as int)) as Totaldeathcount
FROM [Portfolio Project]..CovidDeaths$
--WHERE location like '%State%'
Where continent is not null
Group by continent
order by Totaldeathcount Desc

--Global Numbers

SELECT date,Sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage 
FROM [Portfolio Project]..CovidDeaths$
--WHERE location like '%State%'
Where continent is not null
Group by date
order by 1,2

--Overall death percentage accross the world

SELECT Sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage 
FROM [Portfolio Project]..CovidDeaths$
--WHERE location like '%State%'
Where continent is not null
--Group by date
order by 1,2

--Total number of people that has being vaccinated 

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
FROM [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
    ON dea.location=vac.location
	AND dea.date = vac.date
	WHERE dea.continent is not null
	order by 2,3

--Rolling people vaccinated 

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
FROM [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
    ON dea.location=vac.location
	AND dea.date = vac.date
	WHERE dea.continent is not null
    order by 2,3

--Total population vs total number of people vacinnated
--USE CTE
With popvsVac (contient,location, date,population,new_vaccinations,rollingpeoplevaccinated)
as
(

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
FROM [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
    ON dea.location=vac.location
	AND dea.date = vac.date
	WHERE dea.continent is not null
    --order by 2,3
)
SELECT *, (Rollingpeoplevaccinated/population)*100
FROM popvsvac


--Temp Table

Drop table if exists #Percentpopulationvaccinated
Create table #Percentpopulationvaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date Datetime,
Population Numeric,
New_vaccinations Numeric,
Rollingpeoplevaccinated Numeric,
)

Insert into #Percentpopulationvaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
FROM [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
    ON dea.location=vac.location
	AND dea.date = vac.date
	--WHERE dea.continent is not null
    --order by 2,3
SELECT *, (Rollingpeoplevaccinated/population)*100
FROM #Percentpopulationvaccinated

--Creating view to store for later visualization 
Create view Percentpopulationvaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
FROM [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
    ON dea.location=vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT *
FROM Percentpopulationvaccinated














