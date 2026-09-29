# Methodology

## Objective and stakeholder scenario

This portfolio business case supports a hypothetical **Strategy & Growth team at a regional fintech or digital bank**. It examines financial access, digital usage, underserved segments, formalization, digital readiness, and supply-side infrastructure in Egypt and selected MENA markets. No real institution commissioned the project. Findings are descriptive evidence for further investigation, not causal estimates, customer-level targeting, forecasts, or market-size estimates.

The implementation is defined by the [five notebooks](../notebooks/) and [seven SQL scripts](../sql/). This document describes their existing logic rather than introducing alternative calculations.

## Country framework

| Role | Countries | Treatment |
|---|---|---|
| Main market | Egypt | Focal market; Egypt's source labels are standardized across datasets. |
| Selected peers | Morocco, Tunisia, Algeria, Jordan | Unweighted mean of reporting peers for each selected 2024 Findex indicator. |
| Advanced benchmark | Saudi Arabia | Separate comparator; excluded from the peer mean. |
| Supplementary benchmark | United Arab Emirates | Retained where available; detailed indicator coverage is weaker. Excluded from the peer mean and the six-market IMF ranking/checkpoint views. |

The six main comparison countries are Egypt, the four peers, and Saudi Arabia. `reporting_peers` and `reporting_countries` make the denominator visible. These are selected-market comparisons, not estimates for MENA as a whole. Peer membership is a project framework, not a statistically optimized match.

## Time framework

- **Findex preparation:** retains reported observations from 2011, 2014, 2017, 2021, and 2024. The 2025 workbook is the publication source; 2024 is an observation year.
- **Findex dashboard:** national trends use 2017, 2021, and 2024; demographic and readiness comparisons focus on 2024.
- **IMF preparation:** retains all observed years for five selected indicators, 2004–2025 in this snapshot. 2024 is the primary common comparison; 2025 reporting is incomplete, including missing Egypt observations.
- **IMF dashboard:** historical checkpoints are 2017, 2021, and 2024; rankings use reported 2024 values.
- **CBE:** overall and women's inclusion cover 2016–2025; youth covers 2020–2025; wallets cover 2019–2025; transaction value is a 2025 observation only.

`LAG` in Findex and IMF trend queries compares the previous **observed selected checkpoint**. It is not necessarily the previous calendar year and is not annualized. CBE's year-over-year change is returned only when `previous_year = year - 1`; otherwise it is NULL.

## Findex selection and preparation

Notebook 01 reads the `Data` sheet, retains technical indicator codes, filters seven markets, and reshapes wide indicator columns into a long observation table. The observation key is country × year × demographic group × demographic subgroup × indicator code. It keeps 2,812 observed values in 12 columns.

| Indicator code | Project label | Selection group |
|---|---|---|
| `account.t.d` | Account ownership | Historical |
| `fiaccount.t.d` | Financial institution account | Historical |
| `g20.any` | Made or received digital payment | Historical |
| `save.any.t.d` | Saved any money | Historical |
| `fin17a.17a1.d` | Saved formally | Historical |
| `borrow.any.t.d` | Borrowed any money | Historical |
| `fin22a.22a1.22g.d` | Borrowed formally | Historical |
| `fin24aP` | Able to raise emergency funds | Historical |
| `mobileaccount.t.d` | Mobile money account | 2024 deep dive |
| `merchant.pay` | Digital merchant payment | 2024 deep dive |
| `dig.acc` | Digitally enabled account | 2024 deep dive |
| `internet` | Internet use | 2024 deep dive |
| `con1` | Mobile phone ownership | 2024 deep dive |
| `con9a` | Smartphone ownership | 2024 deep dive |

The deep-dive grouping describes analytical emphasis; preparation retains earlier reported values for those indicators too. Values are source proportions on a 0–1 scale. Labels summarize the source definitions; the workbook's series descriptions remain the authority for question wording and reference periods. `g20.made` is inspected during discovery but is not one of the 14 final indicators.

National trends and peer comparisons use `demographic_group = 'all'` and `demographic_subgroup = 'all'`. National trend indicators are account ownership, digital payments, any saving, and any borrowing. Digital readiness requires all four observations: internet use, smartphone ownership, digitally enabled account, and digital-payment usage; six countries meet that condition in 2024.

### Demographic dimensions and direction

Preparation preserves gender, income, age, urbanicity, education, and labor-force dimensions plus national observations. The SQL subgroup analysis uses four dimensions for Egypt in 2024:

| Dimension | First group | Second group |
|---|---|---|
| Gender | Men | Women |
| Income | Richest 60% | Poorest 40% |
| Age | Age 25+ | Ages 15–24 |
| Urbanicity | Urban | Rural |

Seven indicators are compared: account ownership, digital payments, any saving, any borrowing, digitally enabled accounts, internet use, and smartphone ownership. A pair is returned only when both subgroup values exist. `signed_gap_pp = 100 × (first_value − second_value)`, rounded to two decimals in SQL. Positive means the first group is higher; negative means the second group is higher. `RANK()` orders the absolute gap within each dimension, retaining ties and the original signed result. The dashboard's largest-gap comparison can therefore show different indicators for different dimensions.

## Behavioral and formalization gaps

Components must match on country, year, demographic group, and subgroup. Missing components do not produce a zero gap.

| Gap | Calculation in percentage points |
|---|---|
| Access → digital usage | `100 × (account.t.d − g20.any)` |
| Saving formalization | `100 × (save.any.t.d − fin17a.17a1.d)` |
| Borrowing formalization | `100 × (borrow.any.t.d − fin22a.22a1.22g.d)` |
| Egypt versus peer mean | `100 × (Egypt rate − unweighted mean of reporting selected peers)` |

SQL rounds these differences to two decimals. Dashboard headlines display one decimal. In 2024 Egypt's values are **6.8 pp**, **9.2 pp**, and **45.7 pp** for the three behavior gaps; digital payments are **+9.6 pp** versus peers. Account ownership is **43.1%** and digital-payment usage **36.3%**.

Rates and differences must not be confused: a stored `0.431...` is displayed as 43.1%, while a stored gap of `6.79` is displayed as 6.8 pp. Do not multiply an already-calculated `_pp` field by 100 again. These differences are between population rates; they do not identify individual non-users, disjoint populations, or a customer conversion funnel.

## IMF supply-side indicators and coverage

Notebook 02 inspects ten candidates and selects five normalized series. It retains IMF series codes and source country names, extracts numeric year columns, and produces 488 observed rows with a country × year × indicator key.

| Selected indicator | Original normalized unit | Main-country coverage, 2024 |
|---|---|---:|
| Commercial bank branches | Per 100,000 adults | 6 of 6 |
| Automated teller machines | Per 100,000 adults | 6 of 6 |
| Commercial-bank deposit accounts | Per 1,000 adults | 5 of 6; Tunisia unavailable |
| Registered mobile-money accounts | Per 1,000 adults | 4 of 6 |
| Mobile and internet banking transactions during the reference year | Per 1,000 adults | 4 of 6 |

The normalized denominator comes from the series name, not just IMF's broad `UNIT`/`SCALE` labels. Absolute counts and local-currency amounts are not selected. Account counts measure accounts, not unique people; registration does not establish activity. Transactions measure activity, with reporting definitions that can differ nationally. Rankings are descending within each indicator among reported values only. Different indicators can have different ranking denominators.

The 40-row coverage file records ten candidate indicators at four checkpoints (2017, 2021, 2024, 2025), country availability flags, and whether each candidate was selected. False means unavailable, not zero. It is supporting documentation rather than a main SQLite table. Connecting observed checkpoints in the dashboard does not add interpolated observations to the data.

## CBE context: a separate definition

Notebook 03 transcribes printed labels and callouts from the December 2025 CBE report; it does not estimate positions on charts. Source pages and definition notes accompany every record. Inclusion percentages are divided by 100; registered-wallet counts remain **million wallets**, and transaction value remains **EGP trillion**. The table contains 34 observations across five metrics.

CBE measures citizens aged 15+ owning **active transactional accounts**, covering banks, Egypt Post, mobile wallets, and prepaid cards. Its youth group is **15–35**, unlike the Findex youth group of 15–24. CBE's administrative coverage and active-account definition differ from survey-based Findex account ownership.

Consequently, **77.6% CBE inclusion in 2025 is not a continuation of, or directly comparable adoption gap against, 43.1% Findex account ownership in 2024**. The dashboard deliberately separates CBE context. Registered wallets of **60.0 million** are not unique users, and **EGP 4.0 trillion** is transaction value during 2025, not an account balance or wallet count.

## Missing data and validation

Source observations with missing values are excluded from the processed long tables without imputation. Missing years remain absent. SQL joins and complete-pair conditions require observed components. First-observation lag fields and unavailable year-over-year changes remain NULL; blank CSV cells are converted to null in Power Query. No missing observation is converted to zero.

Coverage matrices may use zero counts or False availability flags for **coverage diagnostics**, not financial indicator values. Assertions check observation keys, duplicates, schemas, bounds, and CSV read-back equivalence. The three sources remain separate SQLite tables and dashboard fact tables, avoiding inappropriate joins across definitions.

## Reproducibility and validation

Use [requirements.txt](../requirements.txt) and the [raw-source instructions](../data/raw/README.md). The publication QA environment used Python 3.14.6, Pandas 3.0.3, OpenPyXL 3.1.5, IPython 9.15.0, and Notebook 7.5.7. `sqlite3`, `pathlib`, and `re` are standard-library modules. OpenPyXL supplies the Excel reader used by Pandas. Power BI Desktop is a separate Windows application, not a pip dependency.

1. Open notebooks with `notebooks/` as the kernel working directory. Run 01–03 sequentially after retrieving the source files. Notebook 03 can execute without the PDFs because its values are explicitly transcribed; obtain them to audit provenance.
2. Run 04 to create/replace `findex` (2,812 rows), `imf_fas` (488), and `cbe_context` (34), with unique observation-key indexes. This overwrites generated tables, so rerun in a separate copy if retaining the shipped snapshot.
3. Run SQL 01–06 against the SQLite file. Inspect each statement's results. Validation expects zero critical null/invalid-value issues and no duplicate keys. The scripts use CTEs and window functions, requiring SQLite with window-function support.
4. Run 05. It executes SQL 07 to recreate eight views, checks equivalence with SQL 02–06, exports the CSVs, and verifies their read-backs and unchanged source-table rows.
5. Open the final PBIX. It contains imported data and an embedded theme, so the removed authoring/build files are not required for viewing. To refresh after relocating the checkout, repoint its eight CSV sources through Power BI Desktop's **Data source settings → Change Source**. The preserved PBIX stores original local source locations; it does not auto-discover the checkout. Do not alter its transformations, model, measures, or visuals.

The included processed CSVs support a shorter reproduction path starting at notebook 04. The supplied database and Power BI exports also permit review without obtaining raw files. The preserved database contains an inherited IMF metadata alias, `source_country_code`; the CSV and notebook 04 use `country_code`. Rebuilding normalizes that field name to the CSV schema without affecting any analytical view. Database-file byte identity is not expected after a rebuild. Exact regeneration from newly downloaded inputs depends on obtaining the same source snapshot and schema; source revisions can change results or trigger the notebooks' assertions.

For publication QA, all five notebooks were executed in an isolated copy. The original notebooks, SQL, processed datasets, database, Power BI inputs, PBIX, and PDF were preserved rather than regenerated in the publication folder. Validation of the regenerated results is performed separately from file-integrity checks.

Return to the [overview](../README.md) or inspect the [data dictionary](data_dictionary.md).
