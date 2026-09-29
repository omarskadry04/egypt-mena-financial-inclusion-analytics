-- IMF FAS supply-side measures. Each ranked measure retains its original normalized unit.
-- Rank only reported 2024 values among the six main comparison countries.
WITH ranked AS (
    SELECT country, country_role, indicator_name, unit, value,
           RANK() OVER (PARTITION BY indicator_name ORDER BY value DESC) AS rank_desc,
           COUNT(*) OVER (PARTITION BY indicator_name) AS reporting_countries
    FROM imf_fas
    WHERE year = 2024
      AND country IN ('Egypt', 'Morocco', 'Tunisia', 'Algeria', 'Jordan', 'Saudi Arabia')
)
SELECT indicator_name, unit, country, value, rank_desc, reporting_countries
FROM ranked ORDER BY indicator_name, rank_desc, country;

-- Selected checkpoints: changes are in each indicator's stated unit; compare only observed pairs.
WITH checkpoints AS (
    SELECT country, country_role, year, indicator_name, unit, value,
           LAG(year) OVER (PARTITION BY country, indicator_name ORDER BY year) AS previous_year,
           LAG(value) OVER (PARTITION BY country, indicator_name ORDER BY year) AS previous_value
    FROM imf_fas
    WHERE year IN (2017, 2021, 2024)
      AND country IN ('Egypt', 'Morocco', 'Tunisia', 'Algeria', 'Jordan', 'Saudi Arabia')
)
SELECT country, country_role, indicator_name, unit, year, value,
       previous_year, previous_value,
       ROUND(value - previous_value, 3) AS change_from_previous_observed
FROM checkpoints ORDER BY indicator_name, country, year;

-- Supplementary UAE coverage in 2024; absence is not represented as zero.
SELECT country, indicator_name, unit, value
FROM imf_fas
WHERE country = 'United Arab Emirates' AND year = 2024
ORDER BY indicator_name;
