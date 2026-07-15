# SQL Data Cleaning Pipeline

## Overview
This repository showcases a complete, end-to-end SQL data cleaning pipeline designed to clean, standardize, and prepare a real-world messy dataset for downstream analytics and visualization. 

Working with raw data directly can corrupt the source of truth; therefore, this project demonstrates best-practice data engineering workflows by creating staging environments, systematically resolving dirty data patterns, and validating the final output using MySQL.

---

## Dataset
The project utilizes the **[COVID-19 Layoffs Dataset](https://www.kaggle.com/datasets/swaptr/layoffs-2022)** hosted on Kaggle (compiled by swaptr). 
- **Raw Data File**: [`layoffs.csv`](file:///d:/Data-22-6-26/Projects/layoffs-data-cleaning/layoffs.csv) (excluded from Git version control to keep the repository lightweight).
- **Scope**: Contains global technology and multi-industry layoff records spanning the COVID-19 pandemic and post-pandemic periods.
- **Initial State**: Extremely messy, featuring duplicate records, inconsistent naming conventions, bad character encoding for foreign cities, unformatted text dates, and missing/blank fields.

---

## Cleaning Steps

### Remove Duplicates
- Since the dataset lacks a unique primary key, duplicate rows are identified by partitioning across all attributes: `company`, `location`, `industry`, `total_laid_off`, `percentage_laid_off`, `date`, `stage`, `country`, and `funds_raised`.
- Used the `ROW_NUMBER() OVER (...)` window function to rank occurrences.
- Filtered duplicate records (`row_num > 1`) and deleted them by creating a secondary clean staging table (`layoffs_staging3`), which was later renamed to [`layoffs_staging2`](file:///d:/Data-22-6-26/Projects/layoffs-data-cleaning/layoff_data_cleaning.sql#L431).

### Standardize Values
- **Trimming**: Removed leading and trailing whitespaces from the `company` and `location` columns using the `TRIM()` function.
- **Naming Harmonization**: Unified country naming variants (e.g., standardizing `UAE` and variants to `United Arab Emirates`).
- **Location Splitting**: Resolved combined location values (e.g., separating Raleigh/Luxembourg assignments for specific companies).

### Handle Missing Values
- Replaced blank text fields (`''`) with proper SQL `NULL` values.
- Populated missing `industry` fields by performing a self-join on `company` names to copy valid industry categories from other records of the same company (e.g., finding the industry for companies like Airbnb or Carvana).

### Convert Data Types
- Converted text-based date strings (formatted as `%m/%d/%Y`) into proper SQL `DATE` types using `STR_TO_DATE()`.
- Altered column schemas to modify data types from generic text to exact numbers (e.g., `INT` for `total_laid_off` and `DECIMAL(5,4)` for `percentage_laid_off`).

### Fix Encoding Issues
- Identified and corrected corrupted characters in foreign location names caused by improper character set encoding (e.g., mapping `DÃ¼sseldorf` to `Dusseldorf`, `FÃ¸rde` to `Forde`, `WrocÅ‚aw` to `Wroclaw`, etc.).

### Validate Cleaned Dataset
- Removed uninformative records where both `total_laid_off` and `percentage_laid_off` were `NULL`.
- Dropped the temporary `row_num` helper column.
- Ran quality control checks to count nulls per column and verify that zero duplicates remain.

---

## SQL Concepts Used

- **Window Functions & `ROW_NUMBER()`**: Partitioned rows to assign numbers and isolate duplicates.
- **Self Joins**: Joined the staging table to itself on `company` name to fill in blank values from matching records.
- **Date Functions (`STR_TO_DATE`)**: Parsed raw text formats into native database date formats.
- **Data Definition Language (DDL)**: Used `CREATE TABLE like`, `ALTER TABLE MODIFY COLUMN`, and `DROP/RENAME TABLE` to structure staging schemas.
- **Data Manipulation Language (DML)**: Performed updates (`UPDATE`), insertions (`INSERT INTO ... SELECT`), and deletions (`DELETE`).
- **Aggregate Functions & String Matching**: Utilized `COUNT(*)`, `SUM()`, `GROUP BY`, and `LIKE` to validate dataset integrity.

---

## Final Dataset
The resulting cleaned table [`layoffs_staging2`](file:///d:/Data-22-6-26/Projects/layoffs-data-cleaning/layoff_data_cleaning.sql#L431) features:
- Unified types (`DATE`, `INT`, `DECIMAL`) instead of generic text types.
- Fully normalized and trimmed string columns (no trailing whitespace or duplicate naming schemes).
- Corrected character encodings for global city names.
- Zero duplicate entries.
- Exclusion of data-less rows (where both laid off counts and percentages were missing).

---

## Key Learnings
1. **Staging Tables are Vital**: Always copy raw source data into staging tables before executing cleanup scripts. This preserves the original data for audit trails and recovery.
2. **Deterministic Deduplication**: When unique identifiers are missing, window functions are the most robust method for isolating duplicate records.
3. **Exploratory Data Analysis (EDA)**: Finding encoding issues (like `DÃ¼sseldorf`) and formatting discrepancies requires thorough preliminary query investigation (`SELECT DISTINCT`, `ORDER BY`) before writing updating scripts.
