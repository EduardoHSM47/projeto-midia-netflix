DROP TABLE IF EXISTS silver_netflix;

CREATE TABLE silver_netflix AS
SELECT * FROM bronze_netflix;

-- Executa todas as transformações

-- ===========================================
-- 1. Validar estrutura inicial
-- ===========================================
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'silver_netflix'
ORDER BY ordinal_position;

-- ===========================================
-- 2. Converter tipos de dados
-- ===========================================
ALTER TABLE silver_netflix
ALTER COLUMN date_added TYPE DATE
USING TO_DATE(TRIM(date_added), 'Month DD, YYYY');

ALTER TABLE silver_netflix
ALTER COLUMN release_year TYPE INTEGER;

-- ===========================================
-- 3. Corrigir inconsistências dos dados
-- ===========================================

-- Alguns registros possuem a duração na coluna rating.
-- Copia a duração para a coluna correta.
UPDATE silver_netflix
SET duration = rating
WHERE rating LIKE '%min%'
  AND duration IS NULL;

-- Após copiar, o rating passa a ser Unknown.
UPDATE silver_netflix
SET rating = 'Unknown'
WHERE rating LIKE '%min%';

-- ===========================================
-- 4. Tratar valores nulos
-- ===========================================

UPDATE silver_netflix
SET
    director = COALESCE(director, 'Unknown'),
    "cast" = COALESCE("cast", 'Unknown'),
    country = COALESCE(country, 'Unknown'),
    rating = COALESCE(rating, 'Unknown');

-- ===========================================
-- 5. Criar colunas derivadas
-- ===========================================

ALTER TABLE silver_netflix
ADD COLUMN duration_value INT,
ADD COLUMN duration_unit VARCHAR(20);

UPDATE silver_netflix
SET
    duration_value = CASE
        WHEN duration LIKE '%min%'
            THEN CAST(SPLIT_PART(duration, ' ', 1) AS INT)
        WHEN duration LIKE '%Season%'
            THEN CAST(SPLIT_PART(duration, ' ', 1) AS INT)
    END,

    duration_unit = CASE
        WHEN duration LIKE '%min%'
            THEN 'Minutes'
        WHEN duration LIKE '%Season%'
            THEN 'Seasons'
    END;

-- ===========================================
-- 6. Data quality checks
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