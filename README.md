# Egypt & MENA Digital Financial Inclusion Opportunity Analytics

**From Financial Access to Digital Usage: Identifying Underserved Segments and Market Opportunities**

An **end-to-end data analytics portfolio case study** asking whether account access translates into digital usage in Egypt and selected MENA markets. I prepared official public data, built a validated SQLite/SQL analytical layer, and developed a **four-page Power BI report**.

**Python · Pandas · SQL · SQLite · Power BI · Power Query · DAX · Jupyter Notebook**

[Key findings](#key-findings) · [What I built](#what-i-built) · [Validation](#validation) · [Reproduce the analysis](#how-to-reproduce)

## Dashboard Preview

![Executive Overview](powerbi/preview/executive-overview.png)

[View the four-page PDF](powerbi/Financial_Inclusion_Analytics_Preview.pdf) · [Download the Power BI report](powerbi/Financial_Inclusion_Analytics.pbix)

## Key Findings

The first three findings use **Egypt's 2024 Global Findex observations**; CBE provides separate 2025 context. **pp = percentage points.**

| Evidence | Business interpretation |
|---|---|
| Egypt's 2024 account ownership is **43.1%**, versus **36.3%** digital-payment usage. | The **6.8 percentage-point** difference compares population-level rates; it is not an individual conversion rate. |
| Digital-payment usage is **9.6 pp above** the selected peer mean. | Egypt outperforms the unweighted mean of Morocco, Tunisia, Algeria, and Jordan on this measure. |
| Any borrowing minus formal borrowing is **45.7 pp**; the saving formalization gap is **9.2 pp**. | These differences warrant further investigation; they are population-level comparisons, not addressable-market estimates. |
| CBE reports **77.6%** financial inclusion, **60.0 million** registered mobile wallets, and **EGP 4.0 trillion** in wallet transactions for 2025. | Recent administrative evidence adds Egypt-specific context. Registered wallets are neither unique people nor necessarily active users. |

**CBE's 77.6% and Findex's 43.1% are not directly equivalent.** CBE uses an active transactional-account definition with broader administrative coverage across banks, Egypt Post, mobile wallets, and prepaid cards. Findex is survey-based. The two rates are not a continuous series or a direct measure of growth between 2024 and 2025.

## Business Problem

Account ownership alone does not explain digital financial usage. For a **hypothetical Strategy & Growth team at a regional fintech or digital bank**, this portfolio case examines Egypt's development, regional position, demographic differences, and saving and borrowing formalization, alongside digital readiness and financial infrastructure. These patterns help prioritize further investigation; they do not establish product demand or causality.

<details>
<summary>Questions investigated</summary>

- How has inclusion evolved in Egypt, and does account access translate into digital usage?
- How does Egypt compare with selected MENA peers?
- Which demographic pairs show the largest measured differences?
- How large are saving and borrowing formalization gaps?
- How does digital readiness compare with financial usage?
- What do infrastructure indicators and recent CBE data add?

</details>

## Data Sources

| Source | Role |
|---|---|
| World Bank Global Findex 2025 | Consumer access, financial behavior, demographics, and digital readiness; primary dashboard comparisons use 2017, 2021, and 2024. |
| IMF Financial Access Survey | Supply-side infrastructure; reporting-country comparisons and historical checkpoints. |
| Central Bank of Egypt, December 2025 reports | Separate inclusion, wallet-registration, and transaction-value context. |

Raw downloads are **not bundled**. [Source filenames, retrieval instructions, and exclusions](data/raw/README.md) support reconstruction. Processed data and SQL-derived exports are included.

## Analytical Pipeline

Official public data → **Python/Pandas preparation** → processed datasets → **SQLite/SQL analysis** → eight reusable SQL views → validated CSV exports → **Power BI** → documented GitHub repository.

The three source families remain separate tables, preserving their different definitions. SQL produces all eight dashboard input CSVs; [notebook 05](notebooks/05_sql_to_powerbi_exports.ipynb) checks their equivalence to the approved SQL analyses.

## What I Built

| Layer | Implementation and evidence |
|---|---|
| Python/Pandas preparation | Inspected sources, filtered countries and indicators, and reshaped observations while retaining codes, units and demographic labels. CBE values were transcribed with source-page references. [Findex](notebooks/01_data_inspection.ipynb) · [IMF](notebooks/02_imf_fas_inspection.ipynb) · [CBE](notebooks/03_cbe_data_preparation.ipynb). |
| SQLite/SQL analysis | Built three source tables with unique observation-key indexes; seven SQL scripts cover trends, peer means, signed demographic gaps, formalization, digital readiness and infrastructure. [Database setup](notebooks/04_sql_database_setup.ipynb) · [SQL scripts](sql/). |
| Analytical handoff and reporting | Defined [eight SQL views](sql/07_powerbi_views.sql), validated their [CSV exports](powerbi/data/), and built the four-page report using Power Query and DAX. Power BI is the final reporting layer. |
| Documentation and reproducibility | Recorded source definitions, coverage, calculation rules and rerun steps in the [methodology](docs/methodology.md), [data dictionary](docs/data_dictionary.md) and [source-retrieval guide](data/raw/README.md). |

## Validation

- **Before analysis:** the notebooks check missingness, observation-key duplicates, schemas and source-specific value bounds. Missing observations are excluded without imputation; unavailable values remain distinct from zero.
- **Inside SQLite:** [SQL validation](sql/01_data_validation.sql) checks critical nulls, duplicate keys, ranges and coverage. Database setup verifies table read-backs and database integrity.
- **At the Power BI handoff:** [notebook 05](notebooks/05_sql_to_powerbi_exports.ipynb) compares all eight views with SQL 02–06, reopens each exported CSV to check its schema and values, and verifies that source-table rows remain unchanged.

**NULL observations remain unavailable rather than being converted to zero.** These checks validate the analytical workflow, not causal or commercial conclusions. [Validation details](docs/methodology.md#reproducibility-and-validation).

## Power BI Dashboard

The **Fintech Intelligence Brief** uses Egypt = teal, Saudi Arabia = benchmark navy, and peers = neutral grey. Within paired subgroup charts, teal and grey identify the first- and second-named groups.

- **Executive Overview:** access, usage, peer position, and major gaps.
- **Market & Digital Adoption:** regional trends, rankings, and digital readiness.
- **Underserved Segments:** signed comparisons and subgroup formalization gaps.
- **Infrastructure & Egypt Context:** IMF supply-side measures and separate CBE trends.

<details>
<summary>Explore the other three dashboard pages</summary>

![Market & Digital Adoption](powerbi/preview/market-digital-adoption.png)

![Underserved Segments](powerbi/preview/underserved-segments.png)

![Infrastructure & Egypt Context](powerbi/preview/infrastructure-egypt-context.png)

</details>

## Repository Structure

```text
├── README.md, .gitignore, requirements.txt
├── data/
│   ├── raw/README.md          # Source retrieval; downloads excluded
│   └── processed/            # Four CSVs and the validated SQLite database
├── notebooks/               # Five numbered preparation/export notebooks
├── sql/                     # Seven numbered validation/analysis/view scripts
├── powerbi/
│   ├── Financial_Inclusion_Analytics.pbix
│   ├── Financial_Inclusion_Analytics_Preview.pdf
│   ├── data/                # Eight SQL-derived CSVs
│   └── preview/             # Four final dashboard page images
└── docs/
    ├── methodology.md
    └── data_dictionary.md
```

## Methodology & Important Definitions

Egypt is the focal market; four selected peers form an **unweighted reporting-country mean**. Saudi Arabia is an advanced benchmark; UAE is supplementary because coverage varies. Rates are stored as proportions, while differences are percentage points. Subgroup gaps retain their direction. Historical changes compare observed checkpoints, not necessarily consecutive years. [Full definitions](docs/methodology.md).

## How to Reproduce

**Review without rerunning:** open the [PDF report](powerbi/Financial_Inclusion_Analytics_Preview.pdf), [notebooks](notebooks/), [SQLite database](data/processed/financial_inclusion.db) or [analytical exports](powerbi/data/). Raw downloads are not needed to inspect the included results.

1. Obtain the official source files listed in [data/raw/README.md](data/raw/README.md).
2. Create a Python environment and run `python -m pip install -r requirements.txt` from the repository root using the pinned [dependencies](requirements.txt). The [tested environment](docs/methodology.md#reproducibility-and-validation) is documented separately; Power BI Desktop is a separate Windows application. Start `jupyter notebook` and open the notebooks in `notebooks/`; their working directory must be `notebooks/`.
3. Run notebooks **01–03** in order to prepare the source tables.
4. Run **04** to rebuild SQLite. Execute SQL files **01–06** against `data/processed/financial_inclusion.db` using a SQLite client, inspecting each result set.
5. Run **05** to create the views from script 07, validate SQL equivalence, and export all eight Power BI CSVs.
6. Open the final PBIX in Power BI Desktop. Its imported snapshot is viewable immediately. When opening the PBIX on another computer, set the Power Query `DataFolder` parameter to the local repository's `powerbi/data` directory before refreshing. In **Transform data → Manage Parameters**, replace the generic default `C:\financial-inclusion-analytics\powerbi\data` with your local directory, for example `C:\Users\<user>\Documents\financial-inclusion-analytics\powerbi\data`. All eight CSV queries use this parameter. Preserve transformations and calculations.

To start from the included processed snapshot, skip notebooks 01–03. Rerunning the pipeline overwrites generated data; use a separate checkout if retaining the supplied snapshot. [Reproduction details and checks](docs/methodology.md#reproducibility-and-validation).

## Limitations

Descriptive comparisons do not establish causality or statistical significance. Coverage varies by country, year, indicator, and subgroup. Account counts can exceed people, registration is not activity, and source definitions differ. Future source revisions may change regenerated results; the included processed data fixes the portfolio's validated snapshot.
