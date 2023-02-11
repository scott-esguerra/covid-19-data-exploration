-- Covid deaths table

SELECT *
FROM `utopian-planet-312216.covid_data.covid_deaths`
ORDER BY 3,4

-- Covid vaccination table

SELECT *
FROM `utopian-planet-312216.covid_data.covid_vacs`
ORDER BY 3,4

-- Data that I'm going to use

SELECT continent, location, date, total_cases, new_cases, total_deaths, population
FROM `utopian-planet-312216.covid_data.covid_deaths`
ORDER BY 1,2

-- Looking at total cases vs total deaths (death rate)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_rate
FROM `utopian-planet-312216.covid_data.covid_deaths`
ORDER BY 1,2

-- In column 28, on 2020-03-22, there is a 2.94% chance for you to die if you have covid in Afghanistan

-- Let's look at PH

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_rate
FROM `utopian-planet-312216.covid_data.covid_deaths`
WHERE location like '%Philip%'
ORDER BY 1,2

-- Last March 2020, death percentage in PH was almost 9.4% (19 per 202 people)

-- Looking at total cases vs population
-- Show percentage of population who got covid in PH

SELECT location, date, population, total_cases, (total_cases/population)*100 AS case_rate
FROM `utopian-planet-312216.covid_data.covid_deaths`
WHERE location = 'Philippines'
ORDER BY 1,2

-- Countries with the highest case_rate compared to population (Jan 2020 - Mar 2021) using MAX() function

SELECT location, population, MAX(total_cases) AS highest_covid_case, (MAX(total_cases)/population)*100 AS case_rate
FROM `utopian-planet-312216.covid_data.covid_deaths`
GROUP BY location, population
ORDER BY case_rate DESC

-- Get the difference between population and total cases

SELECT location, population, MAX(total_cases) AS highest_covid_case, population - MAX(total_cases) AS difference
FROM `utopian-planet-312216.covid_data.covid_deaths`
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY difference DESC

-- Let's find PH

SELECT location, population, MAX(total_cases) AS highest_covid_case, (MAX(total_cases)/population)*100 AS case_rate
FROM `utopian-planet-312216.covid_data.covid_deaths`
WHERE location = 'Philippines'
GROUP BY location, population
ORDER BY case_rate DESC

-- Let's find PH (nesting queries)

SELECT location, population, highest_covid_case, case_rate
FROM (
  SELECT location, population, MAX(total_cases) AS highest_covid_case, (MAX(total_cases)/population)*100 AS case_rate
  FROM `utopian-planet-312216.covid_data.covid_deaths`
  GROUP BY location, population
  ORDER BY case_rate DESC
)
WHERE location = 'Philippines'

-- Countries with the highest death count per per population using MAX()
-- I used CAST() to convert total_deaths into int datatype

SELECT location, population, MAX(CAST(total_deaths AS int64)) AS highest_total_deaths
FROM `utopian-planet-312216.covid_data.covid_deaths`
WHERE continent is not null
GROUP BY location, population
ORDER BY highest_total_deaths DESC

-- Countries with the highest covid death rate per cases

SELECT location, population, MAX(total_cases) AS highest_total_cases, MAX(total_deaths) AS highest_total_deaths, (MAX(total_deaths)/MAX(total_cases))*100 as death_rate
FROM `utopian-planet-312216.covid_data.covid_deaths`
WHERE continent is not null
GROUP BY location, population
ORDER BY death_rate DESC



-- Breakdown by continents

-- By continent (highest total deaths)

SELECT location, population, MAX(CAST(total_deaths AS int64)) AS highest_total_deaths
FROM `utopian-planet-312216.covid_data.covid_deaths`
WHERE continent is null 
  AND location != 'World'
  AND location != 'International'
GROUP BY location, population
ORDER BY highest_total_deaths DESC

-- By continent (case_rate)

SELECT location, population, MAX(total_cases) AS highest_covid_case, (MAX(total_cases)/population)*100 AS case_rate
FROM `utopian-planet-312216.covid_data.covid_deaths`
WHERE continent is null
  AND location != 'World'
  AND location != 'International'
GROUP BY location, population
ORDER BY case_rate DESC



-- Global numbers per date (Jan 2020 - Mar 2021)

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS death_percentage
FROM `utopian-planet-312216.covid_data.covid_deaths`
WHERE continent is not null
GROUP BY date
ORDER BY 1,2  

-- Overall death rate per total cases (Jan 2020 - Mar 2021)

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS death_percentage
FROM `utopian-planet-312216.covid_data.covid_deaths`
WHERE continent is not null
ORDER BY 1,2



-- Use JOIN statement to join covid_deaths table and covid_vacs table

SELECT *
FROM `utopian-planet-312216.covid_data.covid_deaths` dea
JOIN `utopian-planet-312216.covid_data.covid_vacs` vac
  ON dea.location = vac.location
  AND dea.date = vac.date

-- Looking at total population vs vaccinations
-- Use JOIN statement to join covid_deaths table and covid_vacs table

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM `utopian-planet-312216.covid_data.covid_deaths` dea
JOIN `utopian-planet-312216.covid_data.covid_vacs` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3

-- It is understandable there are no values in new_vaccinations since the records below are just the start of the pandemic

-- Created people_vaccinated_increamenting column to show how the number of people that are vaccinated increases over time
-- Ordered by continent then location then date
-- Let's look at PH

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS people_vaccinated_increamenting
FROM `utopian-planet-312216.covid_data.covid_deaths` dea
JOIN `utopian-planet-312216.covid_data.covid_vacs` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is not null
  AND dea.location = 'Philippines'
ORDER BY 1,2,3

-- Calculating vaccination rate per poppulation
-- Using common table expressions (CTE) with "WITH" clause

WITH population_vs_vaccination AS (
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS people_vaccinated_increamenting
  FROM `utopian-planet-312216.covid_data.covid_deaths` dea
  JOIN `utopian-planet-312216.covid_data.covid_vacs` vac
    ON dea.location = vac.location
    AND dea.date = vac.date
  WHERE dea.continent is not null
  ORDER BY 1,2,3
)
SELECT *, (people_vaccinated_increamenting/population)*100 AS vacs_percentage
FROM population_vs_vaccination
WHERE location = 'Philippines'

-- CTE temp table "Population vs Vaccination"

CREATE TEMP TABLE population_vs_vaccination (Continent STRING, Location STRING, Date DATE, Population INT64, New_Vaccination INT64, Rolling_People_Vaccinated INT64) AS
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
  FROM `utopian-planet-312216.covid_data.covid_deaths` dea
  JOIN `utopian-planet-312216.covid_data.covid_vacs` vac
    ON dea.location = vac.location
    AND dea.date = vac.date
  WHERE dea.continent is not null
  ORDER BY 1,2,3;
SELECT *, (rolling_people_vaccinated/population)*100 AS vacs_percentage
FROM population_vs_vaccination
WHERE location = 'Philippines'



-- Creating view to store data for later visualization

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM `utopian-planet-312216.covid_data.covid_deaths` dea
JOIN `utopian-planet-312216.covid_data.covid_vacs` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3




