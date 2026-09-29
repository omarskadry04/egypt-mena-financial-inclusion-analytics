-- Validate each source table independently; every query should return interpretable diagnostics.
SELECT 'findex' AS source_table, COUNT(*) AS rows_loaded,
       COUNT(DISTINCT country) AS countries, MIN(year) AS first_year,
       MAX(year) AS last_year, COUNT(DISTINCT indicator_code) AS measures,
       MIN(value) AS minimum_value, MAX(value) AS maximum_value
FROM findex
UNION ALL
SELECT 'imf_fas', COUNT(*), COUNT(DISTINCT country), MIN(year), MAX(year),
       COUNT(DISTINCT indicator_name), MIN(value), MAX(value)
FROM imf_fas
UNION ALL
SELECT 'cbe_context', COUNT(*), COUNT(DISTINCT country), MIN(year), MAX(year),
       COUNT(DISTINCT metric_code), MIN(value), MAX(value)
FROM cbe_context;

-- Zero issues expected. SQLite COUNT(value) excludes NULLs.
SELECT 'findex' AS source_table,
       COUNT(*) - COUNT(country) + COUNT(*) - COUNT(year) +
       COUNT(*) - COUNT(demographic_group) + COUNT(*) - COUNT(demographic_subgroup) +
       COUNT(*) - COUNT(indicator_code) + COUNT(*) - COUNT(value) AS critical_null_cells,
       SUM(CASE WHEN value < 0 OR value > 1 THEN 1 ELSE 0 END) AS invalid_values
FROM findex
UNION ALL
SELECT 'imf_fas', COUNT(*) - COUNT(country) + COUNT(*) - COUNT(year) +
       COUNT(*) - COUNT(indicator_name) + COUNT(*) - COUNT(value),
       SUM(CASE WHEN value < 0 THEN 1 ELSE 0 END)
FROM imf_fas
UNION ALL
SELECT 'cbe_context', COUNT(*) - COUNT(country) + COUNT(*) - COUNT(year) +
       COUNT(*) - COUNT(metric_code) + COUNT(*) - COUNT(value),
       SUM(CASE WHEN value < 0 OR (unit = 'proportion' AND value > 1) THEN 1 ELSE 0 END)
FROM cbe_context;

-- Duplicate observation keys: no rows expected.
SELECT 'findex' AS source_table, country, year,
       demographic_group || ':' || demographic_subgroup || ':' || indicator_code AS measure_key,
       COUNT(*) AS occurrences
FROM findex
GROUP BY country, year, demographic_group, demographic_subgroup, indicator_code
HAVING COUNT(*) > 1
UNION ALL
SELECT 'imf_fas', country, year, indicator_name, COUNT(*)
FROM imf_fas GROUP BY country, year, indicator_name HAVING COUNT(*) > 1
UNION ALL
SELECT 'cbe_context', country, year, metric_code, COUNT(*)
FROM cbe_context GROUP BY country, year, metric_code HAVING COUNT(*) > 1;

-- Coverage and value ranges by measure retain the source-specific meanings and units.
SELECT 'findex' AS source_table, indicator_code AS measure, 'proportion' AS unit,
       COUNT(*) AS observations, COUNT(DISTINCT country) AS countries,
       MIN(year) AS first_year, MAX(year) AS last_year,
       MIN(value) AS minimum_value, MAX(value) AS maximum_value
FROM findex GROUP BY indicator_code
UNION ALL
SELECT 'imf_fas', indicator_name, unit, COUNT(*), COUNT(DISTINCT country),
       MIN(year), MAX(year), MIN(value), MAX(value)
FROM imf_fas GROUP BY indicator_name, unit
UNION ALL
SELECT 'cbe_context', metric_code, unit, COUNT(*), COUNT(DISTINCT country),
       MIN(year), MAX(year), MIN(value), MAX(value)
FROM cbe_context GROUP BY metric_code, unit
ORDER BY source_table, measure;
