-- Matched Findex measures only: missing components remain unavailable, not zero.
-- Differences are descriptive percentage-point gaps, not causal or mutually exclusive counts.
WITH matched AS (
    SELECT a.country, a.country_role, a.year, a.demographic_group, a.demographic_subgroup,
           a.indicator_code AS access_code, a.value AS access_value,
           u.indicator_code AS usage_code, u.value AS usage_value
    FROM findex a
    JOIN findex u
      ON u.country = a.country AND u.year = a.year
     AND u.demographic_group = a.demographic_group
     AND u.demographic_subgroup = a.demographic_subgroup
    WHERE (a.indicator_code = 'account.t.d' AND u.indicator_code = 'g20.any')
       OR (a.indicator_code = 'save.any.t.d' AND u.indicator_code = 'fin17a.17a1.d')
       OR (a.indicator_code = 'borrow.any.t.d' AND u.indicator_code = 'fin22a.22a1.22g.d')
), gaps AS (
    SELECT country, country_role, year, demographic_group, demographic_subgroup,
           CASE access_code WHEN 'account.t.d' THEN 'access_to_digital_usage_gap'
                WHEN 'save.any.t.d' THEN 'saving_formalization_gap'
                WHEN 'borrow.any.t.d' THEN 'borrowing_formalization_gap' END AS gap_name,
           access_code, usage_code, access_value, usage_value,
           ROUND(100.0 * (access_value - usage_value), 2) AS signed_gap_pp
    FROM matched
)
SELECT country, country_role, year, gap_name, access_code, usage_code,
       access_value, usage_value, signed_gap_pp
FROM gaps
WHERE demographic_group = 'all' AND demographic_subgroup = 'all'
  AND year IN (2017, 2021, 2024)
ORDER BY gap_name, country, year;

-- The same matched definitions for Egypt's 2024 reported demographic subgroups.
WITH pairs AS (
    SELECT a.demographic_group, a.demographic_subgroup, a.indicator_code AS first_code,
           a.value AS first_value, b.indicator_code AS second_code, b.value AS second_value
    FROM findex a
    JOIN findex b ON b.country = a.country AND b.year = a.year
      AND b.demographic_group = a.demographic_group
      AND b.demographic_subgroup = a.demographic_subgroup
    WHERE a.country = 'Egypt' AND a.year = 2024
      AND a.demographic_group IN ('gender', 'income', 'age_cat', 'urbanicity')
      AND ((a.indicator_code = 'account.t.d' AND b.indicator_code = 'g20.any')
        OR (a.indicator_code = 'save.any.t.d' AND b.indicator_code = 'fin17a.17a1.d')
        OR (a.indicator_code = 'borrow.any.t.d' AND b.indicator_code = 'fin22a.22a1.22g.d'))
)
SELECT demographic_group, demographic_subgroup,
       CASE first_code WHEN 'account.t.d' THEN 'access_to_digital_usage_gap'
            WHEN 'save.any.t.d' THEN 'saving_formalization_gap'
            ELSE 'borrowing_formalization_gap' END AS gap_name,
       first_value, second_value,
       ROUND(100.0 * (first_value - second_value), 2) AS signed_gap_pp
FROM pairs ORDER BY demographic_group, demographic_subgroup, gap_name;

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
