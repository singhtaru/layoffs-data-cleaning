# World Layoffs Data Cleaning (SQL)

This repository contains a comprehensive SQL script and dataset for cleaning and standardizing global layoffs data. The project walks through a complete Data Cleaning pipeline in SQL, from identifying duplicate records to correcting encoding errors, standardizing column values, populating missing data, and trimming out uninformative entries.

## About the Dataset

The project utilizes the **[COVID-19 Layoffs Dataset](https://www.kaggle.com/datasets/swaptr/layoffs-2022)** from Kaggle. 

This dataset records global tech and multi-industry layoffs during and after the COVID-19 pandemic. It serves as a real-world messy dataset, containing common issues like:
- Duplicate rows
- Inconsistent naming (e.g., country names and formats like `UAE` vs `United Arab Emirates`)
- Bad character encoding (e.g., `DÃ¼sseldorf` instead of `Dusseldorf`)
- Missing or blank values in key columns like `industry` and `total_laid_off`

The target of this project is to clean, standardize, and prepare this raw data for downstream data analysis and visualization.

## Project Structure


- [`layoff_data_cleaning.sql`](file:///d:/Data-22-6-26/Projects/layoffs-data-cleaning/layoff_data_cleaning.sql): The SQL script containing step-by-step cleaning queries.
- [`layoffs.csv`](file:///d:/Data-22-6-26/Projects/layoffs-data-cleaning/layoffs.csv): The raw global layoffs dataset (excluded from version control).
- [`.gitignore`](file:///d:/Data-22-6-26/Projects/layoffs-data-cleaning/.gitignore): Configured to ignore the main dataset (`layoffs.csv`), temporary test files (`small.csv`, `test.csv`), and system files.


---

## Data Cleaning Workflow

The cleaning process is divided into four main phases:

### 1. Remove Duplicates
Duplicate records are identified by creating row numbers using window functions (`ROW_NUMBER() OVER (...)`) partitioned across all major data attributes:
- A staging table `layoffs_staging2` is created to contain the raw records with a temporary `row_num` helper column.
- Duplicates are filtered and resolved by keeping only rows where `row_num = 1`.
- A clean copy is then stored in `layoffs_staging3` and renamed back to `layoffs_staging2` after removing the helper column.

### 2. Standardize the Data
Data values and formats are standardized for consistency:
- **String Trimming**: Removed leading and trailing spaces from `company` and `location` columns.
- **Date Formatting**: Converted the text-based `date` column (format `%m/%d/%Y`) to a standard SQL `DATE` data type using `STR_TO_DATE()`.
- **Numeric Casting**: Converted columns like `total_laid_off` and `percentage_laid_off` to appropriate data types (`INT` and `DECIMAL(5,4)` respectively).
- **Encoding Correction**: Fixed corrupted characters in location columns (e.g., mapping `DÃ¼sseldorf` to `Dusseldorf`, `WrocÅ‚aw` to `Wroclaw`).
- **Country Harmonization**: Unified country naming variants (e.g., standardizing `UAE` and variants to `United Arab Emirates`).
- **Location Cleaning**: Split and resolved multi-city combinations (e.g., cleaning up Raleigh/Luxembourg assignments).

### 3. Handle Null and Blank Values
Nulls and missing information are populated or standardized:
- Standardized blank strings (`''`) to standard SQL `NULL` values.
- Populated missing `industry` fields by performing self-joins on `company` names to copy industry categories from valid entries.

### 4. Remove Unnecessary Rows and Columns
- Deleted records where both `total_laid_off` and `percentage_laid_off` are `NULL`, as they contain no actionable laying-off metrics.
- Dropped temporary row helper columns to produce the final clean, analysis-ready `layoffs_staging2` table.

---

## Final Validation

The script concludes with health-check queries:
- Grouping checks to ensure zero duplicate records remain.
- A summary count of remaining null fields across all columns to evaluate data quality.

## How to Use

1. Import [`layoffs.csv`](file:///d:/Data-22-6-26/Projects/layoffs-data-cleaning/layoffs.csv) into your database (e.g., MySQL).
2. Create the source `layoffs` table.
3. Run the cleaning queries in [`layoff_data_cleaning.sql`](file:///d:/Data-22-6-26/Projects/layoffs-data-cleaning/layoff_data_cleaning.sql) sequentially.
