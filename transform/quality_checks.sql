-- ===========================================
-- DATA QUALITY CHECKS
-- ===========================================

-- 1. Rating não deve conter valores de duração
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM silver_netflix
        WHERE rating LIKE '%min%'
    ) THEN
        RAISE EXCEPTION 'Quality check failed: duração encontrada na coluna rating';
    END IF;
END $$;


-- 2. Duration preenchida deve possuir duration_unit e duration_value
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM silver_netflix
        WHERE duration IS NOT NULL
          AND (duration_unit IS NULL OR duration_value IS NULL)
    ) THEN
        RAISE EXCEPTION 'Quality check failed: duration inconsistente';
    END IF;
END $$;


-- 3. Country não deve permanecer NULL após tratamento Silver
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM silver_netflix
        WHERE country IS NULL
    ) THEN
        RAISE EXCEPTION 'Quality check failed: country contém NULL';
    END IF;
END $$;


-- 4. Director não deve permanecer NULL após tratamento Silver
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM silver_netflix
        WHERE director IS NULL
    ) THEN
        RAISE EXCEPTION 'Quality check failed: director contém NULL';
    END IF;
END $$;


-- 5. show_id deve estar preenchido
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM silver_netflix
        WHERE show_id IS NULL
    ) THEN
        RAISE EXCEPTION 'Quality check failed: show_id contém NULL';
    END IF;
END $$;


-- 6. release_year deve estar dentro de uma faixa válida
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM silver_netflix
        WHERE release_year < 1900
           OR release_year > EXTRACT(YEAR FROM CURRENT_DATE)
    ) THEN
        RAISE EXCEPTION 'Quality check failed: release_year fora da faixa esperada';
    END IF;
END $$;