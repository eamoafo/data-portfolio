-- ============================================================================
-- PROJECT: Global Layoffs Data Cleaning
-- DATABASE: MySQL
-- PURPOSE: Clean and prepare the layoffs dataset for analysis
-- SOURCE: Guided project based on Alex The Analyst's MySQL tutorial
-- NOTE: This is a formatted presentation of the SQL originally executed.
--       Run against a fresh copy of the source data; this is not a rerunnable
--       migration script. Review the validation notes in README.md.
-- ============================================================================

-- 0. Inspect source data
SELECT *
FROM layoffs;

-- Cleaning workflow:
-- 1. Remove duplicate records
-- 2. Standardize text and date values
-- 3. Address NULL and blank values
-- 4. Remove selected incomplete records and temporary columns


-- ============================================================================
-- 1. CREATE A STAGING TABLE
-- Work on a copy of the raw dataset to preserve the original table.
-- ============================================================================

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;


-- ============================================================================
-- 2. IDENTIFY AND REMOVE DUPLICATES
-- Use ROW_NUMBER() to identify repeated records.
-- ============================================================================

-- Initial duplicate check using selected columns.
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY company, industry, total_laid_off,
                        percentage_laid_off, `date`
       ) AS row_num
FROM layoffs_staging;

-- More comprehensive duplicate check using all source columns.
WITH duplicate_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off,
                            percentage_laid_off, `date`, stage, country,
                            funds_raised_millions
           ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Second staging table includes a helper column for duplicate removal.
CREATE TABLE `layoffs_staging2` (
    `company` TEXT,
    `location` TEXT,
    `industry` TEXT,
    `total_laid_off` INT DEFAULT NULL,
    `percentage_laid_off` TEXT,
    `date` TEXT,
    `stage` TEXT,
    `country` TEXT,
    `funds_raised_millions` INT DEFAULT NULL,
    `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Before loading, the table is initially empty.
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

INSERT INTO layoffs_staging2
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY company, location, industry, total_laid_off,
                        percentage_laid_off, `date`, stage, country,
                        funds_raised_millions
       ) AS row_num
FROM layoffs_staging;

-- Inspect rows flagged as duplicates.
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- Retain the first row from each identical group.
DELETE FROM layoffs_staging2
WHERE row_num > 1;

-- Spot-check one company.
SELECT *
FROM layoffs_staging2
WHERE company = 'casper';


-- ============================================================================
-- 3. STANDARDIZE DATA
-- Trim whitespace, harmonize industry labels, and convert date values.
-- ============================================================================

-- Examine leading/trailing whitespace in company names.
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Identify inconsistent industry labels.
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Inspect date parsing before changing the column type.
SELECT `date`,
       STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

-- Preserve the original executed sequence of date conversion.
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- ============================================================================
-- 4. INVESTIGATE AND HANDLE NULL OR BLANK VALUES
-- Populate known industries from other records for the same company.
-- ============================================================================

-- Rows without both a layoff count and a layoff percentage.
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- Missing industry labels.
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
   OR industry = '';

-- Inspect records for an example company.
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- Standardize blank industry values as NULL.
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Compare records from the same company to locate known industry values.
SELECT t1.industry, t2.industry
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
    ON t1.company = t2.company
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

-- Fill missing industries from other records for the same company.
UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;


-- ============================================================================
-- 5. REMOVE SELECTED ROWS AND TEMPORARY COLUMN
-- ============================================================================

-- Remove rows lacking both key layoff metrics.
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- Remove the duplicate-detection helper column.
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Final inspection of the cleaned staging table.
SELECT *
FROM layoffs_staging2;
