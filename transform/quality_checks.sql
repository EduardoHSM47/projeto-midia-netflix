-- ===========================================
-- Data quality checks
-- ===========================================

-- Ainda existe duração na coluna rating?
SELECT *
FROM silver_netflix
WHERE rating LIKE '%min%';

-- Ainda existem registros sem duração?
SELECT *
FROM silver_netflix
WHERE duration IS NULL;

SELECT *
FROM silver_netflix
WHERE duration IS NOT NULL
  AND duration_unit IS NULL;


-- 1. Quantos NULL existiam antes e depois? 2634
SELECT COUNT(*) AS director_nulls
FROM bronze_netflix
WHERE director IS NULL;

-- 2634 diretores foram tratados para Unknown
SELECT COUNT(*) AS director_unknown
FROM silver_netflix
WHERE director = 'Unknown';

-- 2. Ainda existem ratings inválidos?
SELECT DISTINCT rating
FROM silver_netflix
ORDER BY rating;

-- 3. Existem registros inconsistentes?
SELECT *
FROM silver_netflix
WHERE duration IS NOT NULL
  AND duration_value IS NULL;

-- 4. Todos os filmes têm país?
SELECT COUNT(*)
FROM silver_netflix
WHERE country IS NULL;

-- 5. A data realmente virou DATE?
SELECT DISTINCT pg_typeof(date_added)
FROM silver_netflix;

SELECT
    MIN(release_year),
    MAX(release_year)
FROM silver_netflix;