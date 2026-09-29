-- CBE Egypt context remains distinct from Findex: active transactional account
-- definitions and collection methods differ from Findex account ownership.
-- Rate changes are percentage points; wallet changes retain millions or EGP trillion.
WITH trends AS (
    SELECT country, metric_code, metric_name, segment, year, value, unit,
           LAG(year) OVER (PARTITION BY metric_code ORDER BY year) AS previous_year,
           LAG(value) OVER (PARTITION BY metric_code ORDER BY year) AS previous_value
    FROM cbe_context
)
SELECT metric_code, metric_name, segment, year, value, unit,
       previous_year,
       CASE WHEN previous_year = year - 1 THEN
           ROUND((value - previous_value) * CASE WHEN unit = 'proportion' THEN 100.0 ELSE 1.0 END, 3)
       END AS year_over_year_change,
       CASE WHEN unit = 'proportion' THEN 'percentage points' ELSE unit END AS change_unit
FROM trends ORDER BY metric_code, year;

-- Long-run observed change for each metric with at least two annual points.
WITH endpoints AS (
    SELECT metric_code, metric_name, unit, year, value,
           ROW_NUMBER() OVER (PARTITION BY metric_code ORDER BY year) AS first_rank,
           ROW_NUMBER() OVER (PARTITION BY metric_code ORDER BY year DESC) AS last_rank,
           COUNT(*) OVER (PARTITION BY metric_code) AS observed_years
    FROM cbe_context
), paired AS (
    SELECT metric_code, MAX(metric_name) AS metric_name, MAX(unit) AS unit,
           MAX(CASE WHEN first_rank = 1 THEN year END) AS first_year,
           MAX(CASE WHEN first_rank = 1 THEN value END) AS first_value,
           MAX(CASE WHEN last_rank = 1 THEN year END) AS last_year,
           MAX(CASE WHEN last_rank = 1 THEN value END) AS last_value,
           MAX(observed_years) AS observed_years
    FROM endpoints GROUP BY metric_code
)
SELECT metric_code, metric_name, first_year, first_value, last_year, last_value,
       observed_years,
       ROUND((last_value - first_value) * CASE WHEN unit = 'proportion' THEN 100.0 ELSE 1.0 END, 3) AS observed_change,
       CASE WHEN unit = 'proportion' THEN 'percentage points' ELSE unit END AS change_unit
FROM paired WHERE observed_years >= 2 ORDER BY metric_code;

-- The 2025 transaction value has its own unit and is not added to wallet counts.
SELECT metric_code, metric_name, year, value, unit, source, source_page
FROM cbe_context
WHERE metric_code = 'mobile_wallet_transaction_value';
