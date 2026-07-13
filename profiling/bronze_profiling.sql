/*====================================================
  1. ESTRUTURA DA TABELA
====================================================*/

-- Verificando schema
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'bronze_netflix'
ORDER BY ordinal_position;

-- Quantidade de registros
SELECT
    COUNT(*) AS total_linhas
FROM bronze_netflix;


/*====================================================
  2. INTEGRIDADE DOS DADOS
====================================================*/

-- Verificando se a chave primária possui duplicatas
SELECT
    show_id,
    COUNT(*) AS quantidade
FROM bronze_netflix
GROUP BY show_id
HAVING COUNT(*) > 1;

-- Verificando registros totalmente duplicados
SELECT
    *,
    COUNT(*)
FROM bronze_netflix
GROUP BY
    show_id,
    type,
    title,
    director,
    "cast",
    country,
    date_added,
    release_year,
    rating,
    duration,
    listed_in,
    description
HAVING COUNT(*) > 1;

-- Verificando nulos nas colunas críticas
SELECT
    COUNT(*) FILTER (WHERE show_id IS NULL) AS show_id_null,
    COUNT(*) FILTER (WHERE title IS NULL) AS title_null,
    COUNT(*) FILTER (WHERE type IS NULL) AS type_null,
    COUNT(*) FILTER (WHERE release_year IS NULL) AS release_year_null
FROM bronze_netflix;


/*====================================================
  3. QUALIDADE DOS DADOS
====================================================*/

-- Distribuição da coluna type
SELECT
    type,
    COUNT(*) AS quantidade
FROM bronze_netflix
GROUP BY type
ORDER BY quantidade DESC;

-- Distribuição da coluna rating
SELECT
    rating,
    COUNT(*) AS quantidade
FROM bronze_netflix
GROUP BY rating
ORDER BY quantidade DESC;

-- Distribuição da coluna listed_in
SELECT
    listed_in,
    COUNT(*) AS quantidade
FROM bronze_netflix
GROUP BY listed_in
ORDER BY quantidade DESC;

-- Distribuição da coluna duration
SELECT
    duration,
    COUNT(*) AS quantidade
FROM bronze_netflix
GROUP BY duration
ORDER BY quantidade DESC;

-- Distribuição da coluna country
SELECT
    country,
    COUNT(*) AS quantidade
FROM bronze_netflix
GROUP BY country
ORDER BY quantidade DESC;

-- Confirmando o padrão da coluna date_added
SELECT
    date_added
FROM bronze_netflix
LIMIT 20;

-- Percentual de nulos na coluna country
SELECT
    COUNT(*) FILTER (WHERE country IS NULL) AS country_null,
    ROUND(
        COUNT(*) FILTER (WHERE country IS NULL) * 100.0 / COUNT(*),
        2
    ) AS country_null_percent
FROM bronze_netflix;

-- Verificando espaços em branco nas colunas textuais
SELECT *
FROM bronze_netflix
WHERE title <> TRIM(title);

SELECT *
FROM bronze_netflix
WHERE director <> TRIM(director);

SELECT *
FROM bronze_netflix
WHERE country <> TRIM(country);

SELECT *
FROM bronze_netflix
WHERE listed_in <> TRIM(listed_in);


/*====================================================
  4. CONCLUSÕES DO DATA PROFILING
====================================================*/

/*
 show_id é único e pode ser utilizado como chave primária.

 Não foram encontrados registros duplicados.

 As colunas críticas (show_id, title, type e release_year)
não possuem valores nulos.

 Não foram encontrados espaços em branco nas colunas
textuais analisadas.

 A coluna rating apresenta inconsistências.
Foram encontrados registros contendo valores de duração
(66 min, 74 min e 84 min) na coluna rating.

 A coluna date_added está armazenada como texto e deverá
ser convertida para DATE.

 A coluna duration mistura minutos e temporadas e deverá
ser separada em duration_value e duration_unit.

 A coluna country possui valores múltiplos separados por
vírgula e apresenta valores nulos.

 A coluna listed_in possui múltiplos gêneros separados
por vírgula.

 A coluna rating será analisada durante a transformação
para possível padronização.
*/