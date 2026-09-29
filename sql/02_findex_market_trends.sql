-- National Findex trends. Rates are stored as proportions;
-- multiply rates by 100 for percentages, and differences by 100
-- for percentage-point changes.
-- UAE is reported separately as a supplementary benchmark where observations exist.
WITH national AS (
    SELECT country, country_role, year, indicator_code, indicator_name, value
    FROM findex
    WHERE demographic_group = 'all' AND demographic_subgroup = 'all'
      AND year IN (2017, 2021, 2024)
      AND indicator_code IN ('account.t.d', 'g20.any', 'save.any.t.d', 'borrow.any.t.d')
), observed AS (
    SELECT country, country_role, year, indicator_code, indicator_name, value,
           LAG(value) OVER (PARTITION BY country, indicator_code ORDER BY year) AS previous_value,
           LAG(year) OVER (PARTITION BY country, indicator_code ORDER BY year) AS previous_year
    FROM national
)
SELECT country, country_role, indicator_code, indicator_name, year, value,
       previous_year, previous_value,
       ROUND(100.0 * (value - previous_value), 2) AS change_from_previous_observed_pp
FROM observed
ORDER BY indicator_code, country, year;

-- Egypt's 2024 position relative to reporting peer markets (unweighted country mean).
WITH national_2024 AS (
    SELECT country, country_role, indicator_code, indicator_name, value
    FROM findex
    WHERE year = 2024 AND demographic_group = 'all' AND demographic_subgroup = 'all'
      AND indicator_code IN ('account.t.d', 'g20.any', 'save.any.t.d', 'borrow.any.t.d')
), peer_mean AS (
    SELECT indicator_code, COUNT(*) AS reporting_peers, AVG(value) AS peer_mean
    FROM national_2024
    WHERE country IN ('Morocco', 'Tunisia', 'Algeria', 'Jordan')
    GROUP BY indicator_code
)
SELECT e.indicator_code, e.indicator_name, e.value AS egypt_rate,
       p.reporting_peers, p.peer_mean,
       ROUND(100.0 * (e.value - p.peer_mean), 2) AS egypt_minus_peer_mean_pp
FROM national_2024 e
JOIN peer_mean p ON p.indicator_code = e.indicator_code
WHERE e.country = 'Egypt'
ORDER BY e.indicator_code;

-- Coverage-aware 2024 rankings among the six main comparison countries.
WITH ranked AS (
    SELECT country, indicator_code, indicator_name, value,
           RANK() OVER (PARTITION BY indicator_code ORDER BY value DESC) AS rank_desc,
           COUNT(*) OVER (PARTITION BY indicator_code) AS reporting_countries
    FROM findex
    WHERE year = 2024 AND demographic_group = 'all' AND demographic_subgroup = 'all'
      AND country IN ('Egypt', 'Morocco', 'Tunisia', 'Algeria', 'Jordan', 'Saudi Arabia')
      AND indicator_code IN ('account.t.d', 'g20.any', 'save.any.t.d', 'borrow.any.t.d')
)
SELECT indicator_code, indicator_name, country, value, rank_desc, reporting_countries
FROM ranked ORDER BY indicator_code, rank_desc, country;
