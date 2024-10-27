select Count(*)
from covid_deaths;

select Count(*)
from covid_vaccinations;

select date
from covid_vaccinations
ORDER BY date DESC;

SELECT 
	location, 
	date, 
    total_cases, 
    new_cases, 
    total_deaths, 
    population
FROM covid_deaths
WHERE continent <> ""
ORDER BY 1, 2;


-- Total cases vs Total deaths
-- Shows the liklihood of dying if you contract covid in your country
SELECT 
	location, 
	date, 
    total_cases, 
    total_deaths,
    ROUND((total_deaths / total_cases) * 100, 2) AS death_percentage
FROM covid_deaths
WHERE continent <> ""
AND location LIKE '%States%'
ORDER BY 1, 2;


-- Total cases vs population
-- Shows what percentage of the population contracted covid
SELECT 
	location,
    date,
    total_cases,
    population,
    ROUND((total_cases / population) * 100 ,2) AS percent_population_infected
FROM covid_deaths
WHERE location LIKE '%States%'
AND continent <> ""
ORDER BY 1, 2;


-- Countries with highest infection rate compared to the population
SELECT 
	location,
    population,
    MAX(total_cases) AS highest_infection_count,
    ROUND(MAX((total_cases / population) * 100), 2) AS percent_population_infected
FROM covid_deaths
WHERE continent <> ""
GROUP BY location, population
ORDER BY percent_population_infected DESC;


-- Continents with highest death count per popolation

-- Continents with highest death counts
SELECT 
	continent,
    MAX(total_deaths) AS total_death_count
FROM covid_deaths
WHERE continent <> ""
GROUP BY continent
ORDER BY total_death_count DESC;

-- Global Numbers

SELECT 
	date, 
    SUM(new_cases) AS total_cases, 
    SUM(new_deaths) AS total_deaths,
    ROUND(SUM(new_deaths) / SUM(new_cases), 2) AS death_percentage
FROM covid_deaths
WHERE continent <> ""
GROUP BY date
ORDER BY 1, 2;

SELECT 
	#date, 
    SUM(new_cases) AS total_cases, 
    SUM(new_deaths) AS total_deaths,
    ROUND(SUM(new_deaths) / SUM(new_cases), 2) AS death_percentage
FROM covid_deaths
WHERE continent <> ""
#GROUP BY date
ORDER BY 1, 2;


-- Total population vs vaccinations
SELECT 
	dea.continent, 
    dea.location, 
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccincated,
    (rolling_vaccinated / population) * 100
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent <> ""
#AND vac.new_vaccinations <> 0
ORDER BY 2, 3;
    
    
    
-- CTE
WITH popvsvac (continent, location, date, population, new_vaccinations, rolling_vaccinated) 
AS (
SELECT 
	dea.continent, 
    dea.location, 
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccincated
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent <> ""
#AND vac.new_vaccinations <> 0
#ORDER BY 2, 3
)

SELECT *, (rolling_vaccinated / population) * 100
FROM popvsvac;
    

-- TEMP TABLE
CREATE TEMPORARY TABLE percent_pop_vaccinated
(
continent VARCHAR(255),
location VARCHAR(255),
date DATE,
population FLOAT,
new_vaccinations FLOAT,
rolling_vaccinated FLOAT
);

INSERT INTO percent_pop_vaccinated
SELECT 
dea.continent, 
dea.location, 
dea.date,
dea.population,
vac.new_vaccinations,
MAX(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccincated
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent <> ""
;

SELECT *, (rolling_vaccinated / population) * 100
FROM percent_pop_vaccinated
;
    

-- Views for Viz

CREATE VIEW percent_pop_vaccinated AS
SELECT 
	dea.continent, 
    dea.location, 
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccincated
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent <> ""
AND vac.new_vaccinations <> 0
#ORDER BY 2, 3
;

CREATE VIEW deathpercentage AS
SELECT 
	date, 
    SUM(new_cases) AS total_cases, 
    SUM(new_deaths) AS total_deaths,
    ROUND(SUM(new_deaths) / SUM(new_cases), 2) AS death_percentage
FROM covid_deaths
WHERE continent <> ""
GROUP BY date
ORDER BY 1, 2;








