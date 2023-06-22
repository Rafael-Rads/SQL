--select *
--from CovidVaccinations;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProjectoPortfolio..CovidDeaths
ORDER BY 1,2


-- Total de Casos vs Total de Mortes
-- Mostra a probabilidade de morre se voc� contrair COVID no Brasil
SELECT location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 as PorcentagemMortes
FROM ProjectoPortfolio..CovidDeaths
WHERE location like '%Brazil%'
ORDER BY 1,2

-- Mostra a porcentagem de pessoas que pegaram COVID no Brasil
SELECT location, date, total_cases, (total_cases/population)*100 as CasosPopula��o
FROM ProjectoPortfolio..CovidDeaths
WHERE location like '%Brazil%'
ORDER BY 4

-- Pa�ses com maiores taxas de infecc�es comparada com a popula��o
SELECT location, population, max(total_cases) as Popula��oInfectada, 
max((total_cases/population)*100)  PorcentagemPopInfec 
FROM ProjectoPortfolio..CovidDeaths
-- WHERE location LIKE '%Brazil%'
GROUP BY location, population
ORDER BY 4 desc
-- Brasil teve 6,89% da popula��o infectada pelo COVID

-- Mostrar o total de mortes por pa�ses
SELECT location, MAX(CAST(total_deaths as int)) as MortesTotais
FROM ProjectoPortfolio..CovidDeaths
WHERE continent IS NOT NULL
-- and location LIKE '%Brazil%'
GROUP BY location
ORDER BY 2 DESC

--- Mortes totais por continente
SELECT continent, MAX(CAST(total_deaths as int)) as MortesTotais
FROM ProjectoPortfolio..CovidDeaths
WHERE continent IS NOT NULL
-- and location LIKE '%Brazil%'
GROUP BY continent
ORDER BY 2 DESC

 --N�meros Globais

SELECT sum(new_cases) as CasosTotais, sum(cast(new_deaths as int)) as MortesTotais, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as PorcentagemMortes
FROM ProjectoPortfolio..CovidDeaths
WHERE continent IS NOT NULL
-- and location LIKE '%Brazil%'
-- GROUP BY date
ORDER BY 2

-- Popula��o total vs Popula��o vacinada
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) PessoasVacinadas
FROM ProjectoPortfolio..CovidDeaths Dea
JOIN ProjectoPortfolio..CovidVaccinations Vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, PessoasVacinadas)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) PessoasVacinadas
FROM ProjectoPortfolio..CovidDeaths Dea
JOIN ProjectoPortfolio..CovidVaccinations Vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL

)
SELECT *, (PessoasVacinadas/population)*100 as 
FROM PopvsVac

-- TEMP TABLE 

DROP TABLE IF EXISTS #PercentualPessoasVacinadas
CREATE TABLE #PercentualPessoasVacinadas
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PessoasVacinadas numeric
)

INSERT INTO #PercentualPessoasVacinadas
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) PessoasVacinadas
FROM ProjectoPortfolio..CovidDeaths Dea
JOIN ProjectoPortfolio..CovidVaccinations Vac
	ON dea.location = vac.location 
	and dea.date = vac.date

--

SELECT *, (PessoasVacinadas/population)*100
FROM #PercentualPessoasVacinadas

-- Cria��o de VIEW para armazenar dados para uma futura vizualua��o

--CREATE VIEW PercentualPessoasVacinadas as
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
--SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) PessoasVacinadas
--FROM ProjectoPortfolio..CovidDeaths Dea
--JOIN ProjectoPortfolio..CovidVaccinations Vac
--	ON dea.location = vac.location 
--	and dea.date = vac.date
--WHERE dea.continent IS NOT NULL

----
--SELECT * FROM PercentualPessoasVacinadas