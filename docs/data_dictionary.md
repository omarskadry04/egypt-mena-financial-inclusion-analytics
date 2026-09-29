# Data dictionary

The tables below describe the analytical files as shipped. CSVs are UTF-8, have a header row, and do not contain a saved DataFrame index. Empty cells in lag/change fields represent unavailable values, not zero. The [methodology](methodology.md) defines country roles, indicator selection, and gap calculations.

## Dataset inventory and grain

| Dataset | Location | Rows | Observation grain |
|---|---|---:|---|
| Processed Findex | `data/processed/financial_inclusion_long_clean.csv` | 2,812 | Country × year × demographic group × subgroup × indicator |
| Processed IMF | `data/processed/imf_fas_long_clean.csv` | 488 | Country × year × indicator |
| IMF coverage | `data/processed/imf_fas_indicator_coverage.csv` | 40 | Candidate indicator × selected coverage year |
| CBE context | `data/processed/cbe_egypt_context.csv` | 34 | Egypt × year × metric |
| SQLite | `data/processed/financial_inclusion.db` | 3 tables; 8 views | Separate `findex`, `imf_fas`, and `cbe_context` tables plus analytical views |

Paths in this document are relative to the repository root. Processed-file and SQLite source-table column names match except for one inherited metadata alias: the shipped `imf_fas` table uses `source_country_code` where its CSV uses `country_code`. Notebook 04 rebuilds that field as `country_code`. The analytical SQL views do not reference it; the published database is preserved unchanged.

## Processed Findex

| Dataset | Field | Meaning | Unit | Important notes |
|---|---|---|---|---|
| Findex | `country` | Standardized country name | Text | Source `Egypt, Arab Rep.` becomes `Egypt`. |
| Findex | `country_code` | Source country identifier | Three-letter code | Retained from `codewb`. |
| Findex | `year` | Observation year | Calendar year | 2011, 2014, 2017, 2021, 2024 where reported. |
| Findex | `adult_population` | Source adult-population estimate | People | Context field; not used to weight the peer mean. |
| Findex | `region` | Source regional classification | Text | Retained from `regionwb24_hi`. |
| Findex | `income_group` | Source economy income classification | Text | Country classification, distinct from subgroup income splits. |
| Findex | `demographic_group` | Disaggregation dimension | Category | `all`, `gender`, `income`, `age_cat`, `urbanicity`, `education`, `laborforce`. |
| Findex | `demographic_subgroup` | Population represented by the observation | Category | For example `all`, `women`, `poorest 40%`, or `ages 15-24`. |
| Findex | `indicator_code` | Original technical indicator code | Text | Fourteen retained codes; see the methodology's indicator table. |
| Findex | `indicator_name` | Readable project label | Text | Used alongside the original code for traceability. |
| Findex | `value` | Observed indicator rate | Proportion, 0–1 | Multiply by 100 for percentage display. Missing source values are not retained as observations. |
| Findex | `country_role` | Role in the comparison framework | Category | Main market, Peer market, Advanced benchmark, Supplementary benchmark. |

## Processed IMF and coverage

| Dataset | Field | Meaning | Unit | Important notes |
|---|---|---|---|---|
| IMF | `country` | Standardized country name | Text | Egypt standardized from the IMF source label. |
| IMF | `year` | Observation year | Calendar year | Available selected-series observations span 2004–2025. |
| IMF | `indicator_name` | Exact selected IMF series name | Text | Includes the normalized denominator. |
| IMF | `value` | Observed supply-side measure | As specified by `unit` | Not a proportion; accounts and transactions do not count unique people. |
| IMF | `unit` | Normalized unit of measurement | Text | `per 100,000 adults` or `per 1,000 adults` for the final five indicators. |
| IMF | `source_series_code` | Original IMF series identifier | Text | Preserves source traceability. |
| IMF | `country_code` | Country component of series code | Three-letter code | Extracted from the first segment of `SERIES_CODE`. |
| Shipped SQLite `imf_fas` | `source_country_code` | Same country-code metadata under the original database alias | Three-letter code | Rebuilding with notebook 04 uses the CSV's `country_code` name; analytical values and export schemas are unaffected. |
| IMF | `source_country_name` | Original IMF country label | Text | For example `Egypt, Arab Republic of`. |
| IMF | `country_role` | Project comparison role | Category | Same roles as Findex. |
| IMF coverage | `indicator_name` | Candidate series assessed | Text | Ten candidates, including five ultimately selected. |
| IMF coverage | `year` | Coverage checkpoint | Calendar year | 2017, 2021, 2024, 2025. |
| IMF coverage | `Egypt, Arab Republic of`, `Morocco`, `Tunisia`, `Algeria`, `Jordan`, `Saudi Arabia`, `United Arab Emirates` | Whether a numeric observation exists for that country/indicator/year | Boolean | False means unavailable; these are availability flags, not financial values. |
| IMF coverage | `selected` | Whether the candidate enters the final IMF dataset | Boolean | Selection based on relevance and reporting coverage. |

## CBE context

| Dataset | Field | Meaning | Unit | Important notes |
|---|---|---|---|---|
| CBE | `country` | Country of the administrative series | Text | Always Egypt. |
| CBE | `year` | Year represented by the published label | Calendar year | Coverage varies by metric. |
| CBE | `metric_code` | Stable project metric identifier | Text | Five codes listed below. |
| CBE | `metric_name` | Readable metric label | Text | Retains the distinction between inclusion, wallet count, and value flow. |
| CBE | `segment` | Population or activity covered | Text | Citizens 15+, women 15+, youth 15–35, wallets, or transactions. |
| CBE | `value` | Transcribed published observation | As specified by `unit` | Rates converted from percentage labels to proportions; other units unchanged. |
| CBE | `unit` | Measure scale | Text | `proportion`, `million wallets`, or `EGP trillion`. |
| CBE | `source` | Primary report title and institution | Text | Central Bank of Egypt, December 2025. |
| CBE | `source_page` | Page used for transcription | PDF page number, 1-based | Page 2 for rates; page 4 for wallet measures. |
| CBE | `definition_note` | Metric-specific interpretation | Text | Active-account coverage, youth ages, and registration/flow distinctions. |

| Metric code | Coverage | Unit |
|---|---|---|
| `financial_inclusion_rate` | 2016–2025 | Proportion |
| `financial_inclusion_rate_women` | 2016–2025 | Proportion |
| `financial_inclusion_rate_youth` | 2020–2025 | Proportion |
| `registered_mobile_wallets` | 2019–2025 | Million wallets |
| `mobile_wallet_transaction_value` | 2025 | EGP trillion during the year |

CBE inclusion is **not equivalent to Findex account ownership**. Its youth age definition also differs from the Findex subgroup definition.

## Power BI analytical exports

All eight files in `powerbi/data/` are generated by notebook 05 from identically named SQLite views prefixed with `vw_`. Each view's schema is validated before export.

| Export filename | Rows | Grain / scope |
|---|---:|---|
| `findex_market_trends.csv` | 81 | Country × indicator × observed checkpoint; national values |
| `findex_egypt_peer_2024.csv` | 4 | One Egypt-versus-peer comparison per selected indicator, 2024 |
| `findex_demographic_gaps_2024.csv` | 28 | Egypt demographic dimension × indicator, 2024 |
| `findex_behavior_gaps.csv` | 84 | Scope × country × year × demographic subgroup × gap |
| `findex_digital_readiness_2024.csv` | 6 | Country, 2024; complete four-indicator observations |
| `imf_infrastructure_2024.csv` | 25 | Reporting main country × infrastructure indicator, 2024 |
| `imf_historical_checkpoints.csv` | 71 | Main country × indicator × observed checkpoint |
| `cbe_trends.csv` | 34 | Metric × year; Egypt only |

### Shared identifiers

| Dataset | Field | Meaning | Unit | Important notes |
|---|---|---|---|---|
| Exports containing it | `country` | Country represented | Text | CBE export is implicitly Egypt; demographic export is implicitly Egypt 2024. |
| Exports containing it | `country_role` | Comparison role | Category | Not a weighting variable. |
| Exports containing it | `year` | Observation year | Calendar year | Peer, demographic, and infrastructure 2024 exports have the year fixed by their view, rather than a year column. |
| Findex exports containing them | `indicator_code`, `indicator_name` | Source code and readable label | Text | Same definitions as processed Findex. |
| IMF exports | `indicator_name`, `unit` | Series definition and normalized scale | Text | Compare like indicators and retain their units. |

### Findex trend and peer fields

| Dataset | Field | Meaning | Unit | Important notes |
|---|---|---|---|---|
| Market trends | `value` | National rate at this checkpoint | Proportion | Four selected indicators; checkpoints 2017, 2021, 2024. |
| Market trends | `previous_year` | Prior reported selected checkpoint | Calendar year | NULL for the first observed checkpoint. |
| Market trends | `previous_value` | Rate at that checkpoint | Proportion | NULL when there is no prior observation. |
| Market trends | `change_from_previous_observed_pp` | `100 × (value − previous_value)` | Percentage points | Rounded to two decimals; not necessarily annual change. |
| Egypt peer comparison | `egypt_rate` | Egypt's national 2024 rate | Proportion | Not percentage points. |
| Egypt peer comparison | `reporting_peers` | Number of peers contributing an observation | Countries | Four for each included indicator in this snapshot. |
| Egypt peer comparison | `peer_mean` | Arithmetic mean of reporting selected-peer rates | Proportion | Morocco, Tunisia, Algeria, Jordan; excludes Egypt, Saudi Arabia, UAE. |
| Egypt peer comparison | `egypt_minus_peer_mean_pp` | `100 × (egypt_rate − peer_mean)` | Percentage points | Signed, rounded to two decimals. |

### Demographic, behavior, and readiness fields

| Dataset | Field | Meaning | Unit | Important notes |
|---|---|---|---|---|
| Demographic gaps | `demographic_group` | Pairing dimension | Category | Gender, income, age, urbanicity. |
| Demographic gaps | `comparison` | Ordered subgroup labels | Text | First-named group minus second-named group. |
| Demographic gaps | `first_value`, `second_value` | Rates for the two named subgroups | Proportion | Different rows can represent different pairs. |
| Demographic gaps | `signed_gap_pp` | Difference between paired subgroup rates × 100 | Percentage points | Retains sign; complete pairs only. |
| Demographic gaps | `gap_magnitude_rank` | Rank of absolute signed gap within the dimension | Ordinal rank | `RANK()` retains ties; rank 1 identifies the largest measured difference. |
| Behavior gaps | `analysis_scope` | National or Egypt-subgroup analysis | Category | `national` or `egypt_demographic`. |
| Behavior gaps | `demographic_group`, `demographic_subgroup` | Matching population for both components | Category | National rows use `all` / `all`. |
| Behavior gaps | `gap_name` | Which matched-indicator difference is measured | Category | Access-to-digital-usage, saving-formalization, borrowing-formalization gap. |
| Behavior gaps | `first_indicator_code`, `second_indicator_code` | Ordered indicator components | Text | Access versus usage, any saving versus formal saving, or any borrowing versus formal borrowing. |
| Behavior gaps | `first_value`, `second_value` | Rates of those components within the same population | Proportion | Unlike the demographic export, these pair indicators rather than subgroups. |
| Behavior gaps | `signed_gap_pp` | `100 × (first_value − second_value)` | Percentage points | Rounded to two decimals; never interpreted as an individual-level funnel. |
| Digital readiness | `internet_use` | `internet` rate | Proportion | National 2024 observation. |
| Digital readiness | `smartphone_ownership` | `con9a` rate | Proportion | Smartphone ownership, not all mobile phones. |
| Digital readiness | `digitally_enabled_account` | `dig.acc` rate | Proportion | Distinct from account ownership. |
| Digital readiness | `digital_payment_usage` | `g20.any` rate | Proportion | Country included only when all four measures are observed. |

### IMF and CBE export fields

| Dataset | Field | Meaning | Unit | Important notes |
|---|---|---|---|---|
| IMF infrastructure | `value` | Reported 2024 supply-side measure | Per indicated adult denominator | Same underlying scale as processed IMF. |
| IMF infrastructure | `rank_desc` | Descending rank within indicator | Ordinal rank | Main comparison countries only; ties retained. |
| IMF infrastructure | `reporting_countries` | Countries with observations for the ranked indicator | Countries | 4, 5, or 6 depending on indicator in this snapshot. |
| IMF checkpoints | `value` | Observation at selected checkpoint | As specified by `unit` | No unit conversion or interpolation. |
| IMF checkpoints | `previous_year`, `previous_value` | Prior reported selected checkpoint and value | Year; original unit | NULL for first observed checkpoint. |
| IMF checkpoints | `change_from_previous_observed` | Current minus previous observed value | Same as `unit` | Rounded to three decimals; not a percentage-point change. |
| CBE trends | `metric_code`, `metric_name`, `segment` | Metric and population/activity definition | Text | Inherited from CBE context. |
| CBE trends | `value`, `unit` | Published measure and retained scale | Proportion, million wallets, EGP trillion | Definitions differ from Findex. |
| CBE trends | `previous_year` | Previous observation for the same metric | Calendar year | NULL for first observation. |
| CBE trends | `year_over_year_change` | Change only when the preceding observation is from year − 1 | As specified by `change_unit` | Rate differences multiplied by 100; other differences retain source units. Rounded to three decimals. |
| CBE trends | `change_unit` | Unit for the change column | Percentage points, million wallets, EGP trillion | The single transaction-value observation has no year-over-year change. |

No internal Power BI metadata is required to interpret these datasets. Return to the [project overview](../README.md).
