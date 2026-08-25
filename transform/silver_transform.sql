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