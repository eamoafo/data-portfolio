# Global Layoffs Data Cleaning Using MySQL

## Project Overview
This project focuses on cleaning and preparing a global company layoffs dataset using MySQL. The goal is to improve data quality and create a reliable dataset for further exploratory data analysis.

The project was completed in MySQL Workbench and covers duplicate removal, data standardization, handling missing values, and removing unnecessary records and columns.

## Business Problem
Raw data frequently contains duplicate records, inconsistent formatting, missing information, and incorrect data types. These issues can lead to misleading analytical results.

This project addresses these data quality issues to prepare the layoffs dataset for accurate analysis of layoff trends across companies, industries, and countries.

## Tools and Technologies
- MySQL
- MySQL Workbench
- GitHub
- SQL window functions, CTEs, joins, and data manipulation

## Data Cleaning Process

### 1. Removing Duplicates
- Created staging tables to preserve the original dataset.
- Used ROW_NUMBER() with PARTITION BY to identify duplicate records.
- Removed duplicate records using the row number assigned to each record.

### 2. Standardizing Data
- Used TRIM() to remove unnecessary spaces from company names.
- Standardized inconsistent industry classifications, including cryptocurrency-related labels.
- Converted date values using STR_TO_DATE() and updated the column data type to DATE.

### 3. Handling NULL and Blank Values
- Identified missing and blank industry information.
- Converted blank industry values into NULL values.
- Used a self-join to populate missing industries where matching company information was available.
- Removed records where both total layoffs and percentage laid off were missing.

### 4. Removing Unnecessary Columns
- Removed the temporary row_num column used for identifying duplicate records.
- Reviewed the resulting staging table after cleaning.

## SQL Skills Demonstrated
- ROW_NUMBER() and PARTITION BY
- Common Table Expressions (CTEs)
- INNER JOIN and self-joins
- UPDATE and DELETE
- ALTER TABLE
- TRIM() and STR_TO_DATE()
- NULL handling and data standardization

## Project Files
- global_layoffs_data_cleaning.sql — SQL script used for cleaning the dataset.

## Project Outcome

The MySQL data-cleaning workflow produced a deduplicated dataset prepared for exploratory data analysis.

### Data Quality Results

| Metric | Result |
|---|---:|
| Original dataset records | 2,361 |
| Final cleaned records | 1,995 |
| Unique companies | 1,628 |
| Exact duplicate groups remaining | 0 |
| Missing industry values | 1 |
| Records missing both layoff measures | 0 |

### Validation

The final dataset was validated using SQL queries to check record counts, duplicate groups, missing industry classifications, and incomplete layoff information.

The staging table contained repeated records during development. These were removed using ROW_NUMBER(), and a final GROUP BY validation confirmed that no exact duplicate groups remained.

The original dataset was preserved, and a backup of the staging table was created before the corrective deduplication process.

**Note:** The difference between the original and final record counts includes records removed for data-quality reasons and should not be interpreted solely as duplicate removal.


## Next Steps
Perform exploratory data analysis to investigate layoffs by industry, company, country, and time period.

## Acknowledgments
This is a guided learning project based on Alex The Analyst's MySQL Data Cleaning tutorial. The project documentation reflects my own learning and implementation.

Tutorial: https://www.youtube.com/watch?v=4UltKCnnnTA
