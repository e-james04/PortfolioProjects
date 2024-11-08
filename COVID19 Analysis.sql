-- Creating tables
CREATE TABLE covid_deaths(
	iso_code VARCHAR(10),
	continent VARCHAR(30),
	location VARCHAR(50),
	date DATE,
	population BIGINT,
	total_cases INTEGER,
	new_cases INTEGER,
	new_cases_smoothed REAL,
	total_deaths INTEGER,
	new_deaths INTEGER,
	new_deaths_smoothed REAL,
	total_cases_per_million REAL,
	new_cases_per_million REAL,
	new_cases_smoothed_per_million REAL,
	total_deaths_per_million REAL,
	new_deaths_per_million REAL,
	new_deaths_smoothed_per_million REAL,
	reproduction_rate REAL,
	icu_patients INTEGER,
	icu_patients_per_million REAL,
	hosp_patients INTEGER,
	hosp_patients_per_million REAL,
	weekly_icu_admissions INTEGER,
	weekly_icu_admissions_per_million REAL,
	weekly_hosp_admissions INTEGER,
	weekly_hosp_admissions_per_million REAL
	)
--

CREATE TABLE covid_vaccinations(
	iso_code VARCHAR(10),
	continent VARCHAR(30),
	location VARCHAR(50),
	date DATE,
	new_tests INTEGER,
	total_tests BIGINT,
	total_tests_per_thousand REAL,
	new_tests_per_thousand REAL,
	new_tests_smoothed REAL,
	new_tests_smoothed_per_thousand REAL,
	positive_rate REAL,
	tests_per_case REAL,
	tests_units VARCHAR(50),
	total_vaccinations BIGINT,
	people_vaccinated BIGINT,
	people_fully_vaccinated BIGINT,
	total_boosters INTEGER,
	new_vaccinations INTEGER,
	new_vaccinations_smoothed INTEGER,
	total_vaccinations_per_hundred REAL,
	people_vaccinated_per_hundred REAL,
	people_fully_vaccinated_per_hundred REAL,
	total_boosters_per_hundred REAL,
	new_vaccinations_smoothed_per_million INTEGER,
	new_people_vaccinated_smoothed INTEGER,
	new_people_vaccinated_smoothed_per_hundred REAL,
	stringency_index REAL,
	population_density REAL,
	median_age REAL,
	aged_65_older REAL,
	aged_70_older REAL,
	gdp_per_capita	REAL,
	extreme_poverty REAL,
	cardiovasc_death_rate REAL,
	diabetes_prevalence REAL,
	female_smokers REAL,
	male_smokers REAL,
	handwashing_facilities REAL,
	hospital_beds_per_thousand REAL,
	life_expectancy REAL,
	human_development_index REAL,
	excess_mortality_cumulative_absolute REAL,
	excess_mortality_cumulative REAL,
	excess_mortality REAL,
	excess_mortality_cumulative_per_million REAL
	)
--

--Total cases vs Total deaths
SELECT location, MAX(total_cases) AS max_cases,MAX(total_deaths) AS max_deaths
FROM covid_deaths
GROUP BY location

--

--Total cases vs Total deaths
SELECT location, date,total_cases,total_deaths,(CAST(total_deaths AS DECIMAL)/total_cases)*100
FROM covid_deaths
ORDER BY 1,2

--

--Likelyhood of death if you contract covid UK
SELECT location, date,total_cases,total_deaths,(CAST(total_deaths AS DECIMAL)/total_cases)*100
FROM covid_deaths
WHERE location = 'United Kingdom'
ORDER BY 1,2 

--

--Total cases Vs Population UK
--Population that contracted COVID
SELECT location, date, total_cases,population, (CAST(total_cases AS REAL)/population)*100 AS cases_pop_percent
FROM covid_deaths
WHERE location LIKE 'United K%'
ORDER BY 1,2

--

-- Countries with highest infection rate vs population
SELECT location, population, MAX(total_cases) AS max_infections, MAX((CAST(total_cases AS REAL)/population)*100) AS percent_pop_infection
FROM covid_deaths 
WHERE total_cases IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

--

-- Countries with highest death rate vs population
SELECT location, population, MAX(total_deaths) AS max_deaths, MAX((CAST(total_deaths AS REAL)/population)*100) AS percent_pop_infection
FROM covid_deaths 
WHERE total_deaths IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

--

-- Countries with highest death count
SELECT location, MAX(total_deaths) AS max_deaths
FROM covid_deaths
WHERE total_deaths IS NOT NULL AND continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

--

--  Global daily cases vs deaths
SELECT date,SUM(new_cases) AS global_daily_cases,SUM(new_deaths) AS global_daily_deaths,
SUM(CAST(new_deaths AS DECIMAL))/SUM(new_cases)*100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY date

--

--  TOTAL global cases vs deaths
SELECT SUM(new_cases) AS global_daily_cases,SUM(new_deaths) AS global_daily_deaths,
SUM(CAST(new_deaths AS DECIMAL))/SUM(new_cases)*100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL 

--

--  Rolling Vaccination counter
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location 
		ORDER BY dea."location",dea.date) AS rolling_vac_count
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--

--  Creating view example
CREATE VIEW country_deaths_rank AS
SELECT location, MAX(total_deaths) AS max_deaths
FROM covid_deaths
WHERE total_deaths IS NOT NULL AND continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

--

-- Fully Vaccinated Country ranking table
SELECT * 
FROM
(
	SELECT vac.location, dea.population, MAX(vac.people_fully_vaccinated) AS full_vac_total, 
		MAX(CAST(vac.people_fully_vaccinated AS decimal))/dea.population*100 AS full_vac_population_percent 
	FROM covid_vaccinations AS vac
	JOIN covid_deaths AS dea
	ON vac."location" = dea."location"
	WHERE vac.continent IS NOT NULL
	GROUP BY vac.location,dea.population
	ORDER BY 4 DESC
) AS sub1 
WHERE full_vac_population_percent IS NOT NULL

