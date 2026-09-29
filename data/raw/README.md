# Official raw data: retrieval and provenance

The raw downloads are intentionally excluded from this publication repository. The prepared CSVs, SQLite database, and eight dashboard input CSVs are included elsewhere in the project. Download the sources below into **this directory** to rerun notebooks 01–03 from the original inputs. Keep the exact local filenames expected by the notebooks.

## Files used

| Original local filename | Official source / edition | Original size | Publication decision |
|---|---|---:|---|
| `GlobalFindexDatabase2025.xlsx` | World Bank, Global Findex Database 2025 | 17,935,735 bytes (17.10 MiB) | Excluded to keep the repository light; the focused processed table is included. |
| `IMF_FAS_2025.csv` | International Monetary Fund, Financial Access Survey export used in notebook 02 | 132,662,325 bytes (126.52 MiB) | Excluded: exceeds the normal GitHub per-file limit. No Git LFS is required. |
| `Financial Inclusion and Payment Systems  Services Indicators.pdf` | Central Bank of Egypt, *Financial Inclusion and Payment Systems & Services Indicators*, December 2025 | 869,178 bytes (0.83 MiB) | Excluded as a source reference rather than an analytical deliverable; retrieve the official report. |
| `CBE_Financial_Inclusion_Progress_Dec2025.pdf` | Central Bank of Egypt, *Progress of Financial Inclusion Indicators in Egypt*, December 2025 | 110,384 bytes (0.11 MiB) | Excluded as a supporting cross-check; retrieve the official report. |

The main CBE PDF's local filename contains **two spaces** between `Systems` and `Services`. Notebook 03 records the published values directly; it does not parse either PDF programmatically. The PDFs are needed to audit the transcription, not to execute its code. Exclusion does not reflect an absence of provenance. The original downloads are preserved in the project's separate archival backup, which is not part of this repository.

## Retrieval instructions

### World Bank Global Findex 2025

Find the **Global Findex Database 2025** on the World Bank's official website and download the Excel database with country/year observations and demographic disaggregation. Save it as `GlobalFindexDatabase2025.xlsx` here. The version used has `Notes`, `Data`, `Series Table`, and `Updates` sheets. The `Data` sheet has technical codes in the first row and readable descriptions in the second row; notebook 01 deliberately skips that second row when loading the analytical table.

The source workbook contains this official [World Bank methodology link](https://www.worldbank.org/en/publication/globalfindex/methodology). It is a methodology reference, not a direct workbook download URL.

### IMF Financial Access Survey

On the IMF's official data portal, locate **Financial Access Survey (FAS)** and obtain the wide annual CSV export. Save it as `IMF_FAS_2025.csv`. The inspected file contains metadata including `COUNTRY`, `SERIES_CODE`, `SERIES_NAME`, `INDICATOR`, `UNIT`, and `SCALE`, followed by year columns. Notebook 02 uses the original IMF country labels, exact normalized series names, and columns for 2017, 2021, 2024, and 2025 during coverage checks.

The filename is the project's original local name, not proof that every observation is from 2025 or that the export is a frozen official release. The supplied processed snapshot includes observations through 2025 where reported. Retrieve a compatible export with the same schema; a current download may contain revisions.

### Central Bank of Egypt

On the CBE's official website, locate the following December 2025 publications by title:

- **Financial Inclusion and Payment Systems & Services Indicators**: the nine-page primary report. PDF page 2 supplies the overall, women, and youth inclusion series. Page 4 supplies registered mobile wallets and the 2025 transaction-value callout.
- **Progress of Financial Inclusion Indicators in Egypt**: the one-page supporting report used to cross-check the 2025 inclusion rates.

No direct IMF download or CBE report URLs were recorded in the inspected project metadata, so none are invented here. Use the official institutions and exact dataset/report names above.

## Original-file fingerprints

These SHA-256 values identify the inputs used for the validated snapshot. A different hash can indicate a revised release, export settings, or PDF packaging; it does not by itself establish a data error.

| File | SHA-256 |
|---|---|
| `GlobalFindexDatabase2025.xlsx` | `b6c991f8e46bcbd4b6423cc962d5b2fa030e3db99832b9016bb4f400f57c772f` |
| `IMF_FAS_2025.csv` | `4637c2a9617577f2e10d3466a162e42c95c8a31d5f5747cca06237d4bed8185f` |
| Primary CBE PDF | `986bb1eb83b75f2f154346b9ab56f37b3e526bfc007811d2eff5292eb629e14c` |
| CBE progress PDF | `5d4430da8db2dc76f62d5db4493dfb85cf7144a0953b5a872e64d0f91e5a6880` |

All downloaded raw files are ignored by Git; only this README is retained. The inclusion of derived analytical outputs does not relicense the institutions' original publications.

Return to the [project overview](../../README.md) or read the [methodology](../../docs/methodology.md).
