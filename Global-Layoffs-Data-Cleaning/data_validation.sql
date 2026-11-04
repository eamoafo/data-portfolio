
-- =========================================================
-- GLOBAL LAYOFFS DATA CLEANING
-- Data Quality Validation
-- =========================================================
-- Database: world_layoffs
-- Final table: layoffs_deduplicated
-- Purpose: Verify the cleaned dataset's quality.
-- =========================================================

USE world_layoffs;

-- 1. Compare original and cleaned record counts
SELECT
    'Original Dataset' AS dataset,
    COUNT(*) AS total_records
FROM layoffs

UNION ALL

SELECT
    'Cleaned Dataset',
    COUNT(*)
FROM layoffs_deduplicated;


-- 2. Validate the final dataset
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT company) AS unique_companies,
    SUM(
        CASE WHEN industry IS NULL THEN 1 ELSE 0 END
    ) AS missing_industries,
    SUM(
        CASE
            WHEN total_laid_off IS NULL
             AND percentage_laid_off IS NULL
            THEN 1
            ELSE 0
        END
    ) AS incomplete_layoff_records
FROM layoffs_deduplicated;


-- 3. Check for remaining exact duplicates
SELECT
    COUNT(*) AS duplicate_groups
FROM (
    SELECT
        company,
        location,
        industry,
        total_laid_off,
        percentage_laid_off,
        `date`,
        stage,
        country,
        funds_raised_millions
    FROM layoffs_deduplicated
    GROUP BY
        company,
        location,
        industry,
        total_laid_off,
        percentage_laid_off,
        `date`,
        stage,
        country,
        funds_raised_millions
    HAVING COUNT(*) > 1
) AS duplicates;
