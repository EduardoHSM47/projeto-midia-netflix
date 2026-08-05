-- ===========================================
-- SILVER DIMENSIONS
-- ===========================================

-- ===========================================
-- 1. COUNTRY
-- ===========================================

DROP TABLE IF EXISTS bridge_show_country;
DROP TABLE IF EXISTS dim_country;

-- Dimensão de países
CREATE TABLE dim_country (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(100) UNIQUE NOT NULL
);

INSERT INTO dim_country (country_name)
SELECT DISTINCT
    TRIM(unnest(string_to_array(country, ','))) AS country_name
FROM silver_netflix
WHERE country <> 'Unknown'
ORDER BY country_name;

-- Bridge Show x Country
CREATE TABLE bridge_show_country (
    show_id VARCHAR(10),
    country_id INT,

    PRIMARY KEY (show_id, country_id),

    FOREIGN KEY (show_id)
        REFERENCES silver_netflix(show_id),

    FOREIGN KEY (country_id)
        REFERENCES dim_country(country_id)
);

INSERT INTO bridge_show_country (show_id, country_id)
SELECT DISTINCT
    s.show_id,
    c.country_id
FROM silver_netflix s
CROSS JOIN LATERAL unnest(string_to_array(s.country, ',')) AS pais(country_name)
JOIN dim_country c
    ON TRIM(pais.country_name) = c.country_name
WHERE s.country <> 'Unknown';

-- ===========================================
-- 2. DIRECTOR
-- ===========================================

DROP TABLE IF EXISTS bridge_show_director;
DROP TABLE IF EXISTS dim_director;

-- Dimensão de diretores
CREATE TABLE dim_director (
    director_id SERIAL PRIMARY KEY,
    director_name VARCHAR(255) UNIQUE NOT NULL
);

INSERT INTO dim_director (director_name)
SELECT DISTINCT
    TRIM(unnest(string_to_array(director, ','))) AS director_name
FROM silver_netflix
WHERE director <> 'Unknown'
ORDER BY director_name;

-- Bridge Show x Director
CREATE TABLE bridge_show_director (
    show_id VARCHAR(10),
    director_id INT,

    PRIMARY KEY (show_id, director_id),

    FOREIGN KEY (show_id)
        REFERENCES silver_netflix(show_id),

    FOREIGN KEY (director_id)
        REFERENCES dim_director(director_id)
);

INSERT INTO bridge_show_director (show_id, director_id)
SELECT DISTINCT
    s.show_id,
    d.director_id
FROM silver_netflix s
CROSS JOIN LATERAL unnest(string_to_array(s.director, ',')) AS dir(director_name)
JOIN dim_director d
    ON TRIM(dir.director_name) = d.director_name
WHERE s.director <> 'Unknown';

-- ===========================================
-- 3. ACTOR
-- ===========================================

DROP TABLE IF EXISTS bridge_show_actor;
DROP TABLE IF EXISTS dim_actor;

-- Dimensão de atores
CREATE TABLE dim_actor (
    actor_id SERIAL PRIMARY KEY,
    actor_name VARCHAR(255) UNIQUE NOT NULL
);

INSERT INTO dim_actor (actor_name)
SELECT DISTINCT
    TRIM(unnest(string_to_array("cast", ','))) AS actor_name
FROM silver_netflix
WHERE "cast" <> 'Unknown'
ORDER BY actor_name;

-- Bridge Show x Actor
CREATE TABLE bridge_show_actor (
    show_id VARCHAR(10),
    actor_id INT,

    PRIMARY KEY (show_id, actor_id),

    FOREIGN KEY (show_id)
        REFERENCES silver_netflix(show_id),

    FOREIGN KEY (actor_id)
        REFERENCES dim_actor(actor_id)
);

INSERT INTO bridge_show_actor (show_id, actor_id)
SELECT DISTINCT
    s.show_id,
    a.actor_id
FROM silver_netflix s
CROSS JOIN LATERAL unnest(string_to_array(s."cast", ',')) AS act(actor_name)
JOIN dim_actor a
    ON TRIM(act.actor_name) = a.actor_name
WHERE s."cast" <> 'Unknown';

-- ===========================================
-- 4. GENRE
-- ===========================================

DROP TABLE IF EXISTS bridge_show_genre;
DROP TABLE IF EXISTS dim_genre;

-- Dimensão de gêneros
CREATE TABLE dim_genre (
    genre_id SERIAL PRIMARY KEY,
    genre_name VARCHAR(100) UNIQUE NOT NULL
);

INSERT INTO dim_genre (genre_name)
SELECT DISTINCT
    TRIM(unnest(string_to_array(listed_in, ','))) AS genre_name
FROM silver_netflix
ORDER BY genre_name;

-- Bridge Show x Genre
CREATE TABLE bridge_show_genre (
    show_id VARCHAR(10),
    genre_id INT,

    PRIMARY KEY (show_id, genre_id),

    FOREIGN KEY (show_id)
        REFERENCES silver_netflix(show_id),

    FOREIGN KEY (genre_id)
        REFERENCES dim_genre(genre_id)
);

INSERT INTO bridge_show_genre (show_id, genre_id)
SELECT DISTINCT
    s.show_id,
    g.genre_id
FROM silver_netflix s
CROSS JOIN LATERAL unnest(string_to_array(s.listed_in, ',')) AS gen(genre_name)
JOIN dim_genre g
    ON TRIM(gen.genre_name) = g.genre_name;