-- Power BI handoff views. Definitions reproduce the approved analyses in SQL files 02–06.
-- Rerun this script after database setup; source tables are never altered.

-- vw_findex_market_trends: source 02_findex_market_trends.sql, approved query 1.
DROP VIEW IF EXISTS vw_findex_market_trends;
CREATE VIEW vw_findex_market_trends AS
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

-- vw_findex_egypt_peer_2024: source 02_findex_market_trends.sql, approved query 2.
DROP VIEW IF EXISTS vw_findex_egypt_peer_2024;
CREATE VIEW vw_findex_egypt_peer_2024 AS
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

-- vw_findex_demographic_gaps_2024: source 03_demographic_gap_analysis.sql, approved query 1.
DROP VIEW IF EXISTS vw_findex_demographic_gaps_2024;
CREATE VIEW vw_findex_demographic_gaps_2024 AS
-- Egypt 2024 Findex subgroup differences, retaining sign and source proportions.
-- Subgroup labels match the loaded Findex data. Gaps are descriptive, not causal.
WITH selected AS (
    SELECT demographic_group, demographic_subgroup, indicator_code, indicator_name, value
    FROM findex
    WHERE country = 'Egypt' AND year = 2024
      AND demographic_group IN ('gender', 'income', 'age_cat', 'urbanicity')
      AND indicator_code IN ('account.t.d', 'g20.any', 'save.any.t.d',
                             'borrow.any.t.d', 'dig.acc', 'internet', 'con9a')
), paired AS (
    SELECT demographic_group, indicator_code, MAX(indicator_name) AS indicator_name,
           MAX(CASE WHEN demographic_subgroup IN ('men', 'richest 60%', 'age 25+', 'urban')
                    THEN value END) AS first_value,
           MAX(CASE WHEN demographic_subgroup IN ('women', 'poorest 40%', 'ages 15-24', 'rural')
                    THEN value END) AS second_value,
           COUNT(*) AS observed_subgroups
    FROM selected GROUP BY demographic_group, indicator_code
), complete_pairs AS (
    SELECT demographic_group, indicator_code, indicator_name, first_value, second_value,
           ROUND(100.0 * (first_value - second_value), 2) AS signed_gap_pp
    FROM paired
    WHERE observed_subgroups = 2 AND first_value IS NOT NULL AND second_value IS NOT NULL
)
SELECT demographic_group,
       CASE demographic_group WHEN 'gender' THEN 'men - women'
            WHEN 'income' THEN 'richest 60% - poorest 40%'
            WHEN 'age_cat' THEN 'age 25+ - ages 15-24'
            WHEN 'urbanicity' THEN 'urban - rural' END AS comparison,
       indicator_code, indicator_name, first_value, second_value, signed_gap_pp,
       RANK() OVER (
           PARTITION BY demographic_group
           ORDER BY ABS(signed_gap_pp) DESC
       ) AS gap_magnitude_rank
FROM complete_pairs
ORDER BY demographic_group, gap_magnitude_rank, indicator_code;

-- Matched indicators from both approved behavior-gap queries. Scope retains
-- national checkpoints and Egypt's reported 2024 demographic subgroups.
DROP VIEW IF EXISTS vw_findex_behavior_gaps;
CREATE VIEW vw_findex_behavior_gaps AS
WITH matched AS (
    SELECT a.country, a.country_role, a.year,
           a.demographic_group, a.demographic_subgroup,
           a.indicator_code AS first_indicator_code, a.value AS first_value,
           b.indicator_code AS second_indicator_code, b.value AS second_value
    FROM findex a
    JOIN findex b
      ON b.country = a.country AND b.year = a.year
     AND b.demographic_group = a.demographic_group
     AND b.demographic_subgroup = a.demographic_subgroup
    WHERE (a.indicator_code = 'account.t.d' AND b.indicator_code = 'g20.any')
       OR (a.indicator_code = 'save.any.t.d' AND b.indicator_code = 'fin17a.17a1.d')
       OR (a.indicator_code = 'borrow.any.t.d' AND b.indicator_code = 'fin22a.22a1.22g.d')
), scoped AS (
    SELECT CASE WHEN demographic_group = 'all' THEN 'national'
                ELSE 'egypt_demographic' END AS analysis_scope,
           country, country_role, year, demographic_group, demographic_subgroup,
           first_indicator_code, second_indicator_code, first_value, second_value
    FROM matched
    WHERE (demographic_group = 'all' AND demographic_subgroup = 'all'
           AND year IN (2017, 2021, 2024))
       OR (country = 'Egypt' AND year = 2024
           AND demographic_group IN ('gender', 'income', 'age_cat', 'urbanicity'))
)
SELECT analysis_scope, country, country_role, year,
       demographic_group, demographic_subgroup,
       CASE first_indicator_code
            WHEN 'account.t.d' THEN 'access_to_digital_usage_gap'
            WHEN 'save.any.t.d' THEN 'saving_formalization_gap'
            WHEN 'borrow.any.t.d' THEN 'borrowing_formalization_gap'
       END AS gap_name,
       first_indicator_code, second_indicator_code, first_value, second_value,
       ROUND(100.0 * (first_value - second_value), 2) AS signed_gap_pp
FROM scoped;

-- vw_findex_digital_readiness_2024: source 04_financial_behavior_gaps.sql, approved query 3.
DROP VIEW IF EXISTS vw_findex_digital_readiness_2024;
CREATE VIEW vw_findex_digital_readiness_2024 AS
-- Digital readiness and financial usage, side by side when all four observations exist.
-- Patterns do not establish causation. Columns are proportions, not percentage points.
SELECT country, country_role, year,
       MAX(CASE WHEN indicator_code = 'internet' THEN value END) AS internet_use,
       MAX(CASE WHEN indicator_code = 'con9a' THEN value END) AS smartphone_ownership,
       MAX(CASE WHEN indicator_code = 'dig.acc' THEN value END) AS digitally_enabled_account,
       MAX(CASE WHEN indicator_code = 'g20.any' THEN value END) AS digital_payment_usage
FROM findex
WHERE demographic_group = 'all' AND demographic_subgroup = 'all'
  AND year = 2024 AND indicator_code IN ('internet', 'con9a', 'dig.acc', 'g20.any')
GROUP BY country, country_role, year
HAVING COUNT(DISTINCT indicator_code) = 4
ORDER BY digital_payment_usage DESC;

-- vw_imf_infrastructure_2024: source 05_imf_infrastructure_analysis.sql, approved query 1.
DROP VIEW IF EXISTS vw_imf_infrastructure_2024;
CREATE VIEW vw_imf_infrastructure_2024 AS
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
SELECT indicator_name, unit, country, country_role, value, rank_desc, reporting_countries
FROM ranked ORDER BY indicator_name, rank_desc, country;

-- vw_imf_historical_checkpoints: source 05_imf_infrastructure_analysis.sql, approved query 2.
DROP VIEW IF EXISTS vw_imf_historical_checkpoints;
CREATE VIEW vw_imf_historical_checkpoints AS
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

-- vw_cbe_trends: source 06_cbe_egypt_context.sql, approved query 1.
DROP VIEW IF EXISTS vw_cbe_trends;
CREATE VIEW vw_cbe_trends AS
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
