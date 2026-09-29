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

-- Egypt 2024 coverage by segmentation: distinguish unavailable comparisons from zero gaps.
SELECT demographic_group, indicator_code, MAX(indicator_name) AS indicator_name,
       COUNT(DISTINCT demographic_subgroup) AS observed_subgroups
FROM findex
WHERE country = 'Egypt' AND year = 2024
  AND demographic_group IN ('gender', 'income', 'age_cat', 'urbanicity')
  AND indicator_code IN ('account.t.d', 'g20.any', 'save.any.t.d', 'borrow.any.t.d',
                         'dig.acc', 'internet', 'con9a')
GROUP BY demographic_group, indicator_code
ORDER BY demographic_group, indicator_code;
