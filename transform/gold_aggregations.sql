-- ===========================================
-- GOLD AGGREGATIONS
-- ===========================================


-- ===========================================
-- 1. CATÁLOGO POR GÊNERO
-- ===========================================

DROP TABLE IF EXISTS gold_catalogo_por_genero;

CREATE TABLE gold_catalogo_por_genero AS
SELECT
    d.genre_name,
    COUNT(*) AS total_conteudos
FROM bridge_show_genre b
JOIN dim_genre d
    ON b.genre_id = d.genre_id
GROUP BY d.genre_name
ORDER BY total_conteudos DESC;


-- ===========================================
-- 2. CONTEÚDO POR PAÍS E ANO
-- ===========================================

DROP TABLE IF EXISTS gold_conteudo_por_pais_ano;

CREATE TABLE gold_conteudo_por_pais_ano AS
SELECT
    c.country_name,
    s.release_year,
    COUNT(*) AS total_conteudos
FROM bridge_show_country b
JOIN dim_country c
    ON b.country_id = c.country_id
JOIN silver_netflix s
    ON b.show_id = s.show_id
GROUP BY
    c.country_name,
    s.release_year
ORDER BY
    s.release_year,
    total_conteudos DESC;


-- ===========================================
-- 3. LANÇAMENTOS POR ANO
-- ===========================================

DROP TABLE IF EXISTS gold_lancamentos_por_ano;

CREATE TABLE gold_lancamentos_por_ano AS
SELECT
    release_year,
    COUNT(*) FILTER (
        WHERE type = 'Movie'
    ) AS total_filmes,

    COUNT(*) FILTER (
        WHERE type = 'TV Show'
    ) AS total_series,

    COUNT(*) AS total_conteudos
FROM silver_netflix
GROUP BY release_year
ORDER BY release_year;


-- ===========================================
-- 4. TOP GÊNEROS POR DÉCADA
-- ===========================================

DROP TABLE IF EXISTS gold_top_generos_por_decada;

CREATE TABLE gold_top_generos_por_decada AS

WITH conteudo_genero AS (
    SELECT
        (s.release_year / 10) * 10 AS decada,
        d.genre_name,
        COUNT(*) AS total_conteudos
    FROM silver_netflix s
    JOIN bridge_show_genre b
        ON s.show_id = b.show_id
    JOIN dim_genre d
        ON b.genre_id = d.genre_id
    GROUP BY
        (s.release_year / 10) * 10,
        d.genre_name
),

ranking AS (
    SELECT
        decada,
        genre_name,
        total_conteudos,
        RANK() OVER (
            PARTITION BY decada
            ORDER BY total_conteudos DESC
        ) AS ranking
    FROM conteudo_genero
)

SELECT
    decada,
    genre_name,
    total_conteudos,
    ranking
FROM ranking
WHERE ranking <= 5
ORDER BY
    decada,
    ranking;