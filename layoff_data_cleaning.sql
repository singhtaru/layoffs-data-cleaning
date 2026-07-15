-- select * from layoffs;

-- steps in data cleaning
-- 1. remove duplicates
-- 2. standardize the data
-- 3. null vallues or blank values
-- 4. remove unecessary columns and rows

-- creating table similar to layoffs since we dont work on the same table
drop table layoffs_staging;
create table layoffs_staging like layoffs;
select * from layoffs_staging;
insert layoffs_staging select * from layoffs;


SET SQL_SAFE_UPDATES = 0;
SELECT @@SQL_SAFE_UPDATES;


-- removing duplicates
SELECT *
FROM world_layoffs.layoffs_staging
;

-- groups rows that have the same values for: company, industry, total_laid_off, date 
-- if row_num=2 that means second occurence of the same row
SELECT company, industry, total_laid_off,`date`,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off,`date`) AS row_num
	FROM 
		world_layoffs.layoffs_staging;
        
SELECT *
FROM (
	SELECT company, industry, total_laid_off,`date`,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off,`date`
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging
) duplicates
WHERE 
	row_num > 1;
    
    
    
-- 1. deleting duplicate rows

ALTER TABLE world_layoffs.layoffs_staging ADD row_num INT;
SELECT * FROM world_layoffs.layoffs_staging;
drop table world_layoffs.layoffs_staging2;
CREATE TABLE `world_layoffs`.`layoffs_staging2` (
`company` text,
`location`text,
`industry`text,
`total_laid_off` text,
`percentage_laid_off` text,
`date` text,
`stage`text,
`country` text,
`funds_raised` int,
row_num INT
);

INSERT INTO `world_layoffs`.`layoffs_staging2`
(`company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised`,
`row_num`)
SELECT `company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
NULLIF(funds_raised, ''),
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging;
        
        
select * from world_layoffs.layoffs_staging2;


-- 2. standardize data
-- changing  data types
UPDATE layoffs_staging2
SET total_laid_off = NULL
WHERE total_laid_off = '';

ALTER TABLE layoffs_staging2
MODIFY COLUMN total_laid_off INT;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

UPDATE layoffs_staging2
SET percentage_laid_off = NULL
WHERE percentage_laid_off = '';

ALTER TABLE layoffs_staging2
MODIFY COLUMN percentage_laid_off DECIMAL(5,4);

-- Remove leading and trailing spaces
SELECT company
FROM layoffs_staging2
WHERE company != TRIM(company);

UPDATE layoffs_staging2
SET company = TRIM(company);

UPDATE layoffs_staging2
SET location = TRIM(location);

SELECT location
FROM layoffs_staging2
WHERE location != TRIM(location);



-- Look for inconsistent values
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;

SELECT *
FROM layoffs_staging2
WHERE country LIKE 'UAE%'
OR country LIKE 'United Arab Emirates%';

update layoffs_staging2
set country='United Arab Emirates%'
where country LIKE 'UAE%'
OR country LIKE 'United Arab Emirates%';


SELECT DISTINCT stage
FROM layoffs_staging2
ORDER BY stage;

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY location;

-- fixing encoding issues
SELECT DISTINCT location
FROM layoffs_staging2
WHERE location LIKE '%Ã%'
   OR location LIKE '%Å%';

UPDATE layoffs_staging2
SET location = 'Dusseldorf, Non-U.S.'
WHERE location = 'DÃ¼sseldorf, Non-U.S.';

UPDATE layoffs_staging2
SET location = 'Forde, Non-U.S.'
WHERE location = 'FÃ¸rde, Non-U.S.';

UPDATE layoffs_staging2
SET location = 'Florianopolis, Non-U.S.'
WHERE location = 'FlorianÃ³polis, Non-U.S.';

UPDATE layoffs_staging2
SET location = 'Malmo, Non-U.S.'
WHERE location = 'MalmÃ¶, Non-U.S.';

UPDATE layoffs_staging2
SET location = 'Wroclaw, Non-U.S.'
WHERE location = 'WrocÅ‚aw, Non-U.S.';

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY location;

SELECT DISTINCT location
FROM layoffs_staging2
WHERE location LIKE '%Ã%'
   OR location LIKE '%Å%';


SELECT *
FROM layoffs_staging2
WHERE location IN (
    'Luxembourg, Raleigh',
    'New Delhi, New York City',
    'Non-U.S.'
);

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

UPDATE world_layoffs.layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;


UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;


SELECT *
FROM layoffs_staging2
WHERE company = 'The Org';

INSERT INTO layoffs_staging2 (
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised,
    row_num
)
SELECT
    company,
    'New York City',
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised,
    row_num
FROM layoffs_staging2
WHERE company = 'The Org'
  AND location = 'New Delhi, New York City';

UPDATE layoffs_staging2
SET location = 'New Delhi'
WHERE company = 'The Org'
  AND location = 'New Delhi, New York City';
  
  
  
SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Kleos Space';

SELECT *
FROM layoffs_staging2
WHERE location LIKE '%,%';

INSERT INTO layoffs_staging2 (
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised,
    row_num
)
SELECT
    company,
    'Raleigh',
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised,
    row_num
FROM layoffs_staging2
WHERE company = 'Kleos Space'
  AND location = 'Luxembourg, Raleigh';
  
UPDATE layoffs_staging2
SET location = 'Luxembourg'
WHERE company = 'Kleos Space'
  AND location = 'Luxembourg, Raleigh';
  
  
  
  
  
-- 4. removing any columns or rows if needed
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;
  
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;
 
 SELECT COUNT(*)
FROM layoffs_staging2;


-- removing helper column
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
  
SELECT * 
FROM world_layoffs.layoffs_staging2 ;



-- final check for cleaned data
SELECT company,
       location,
       industry,
       total_laid_off,
       percentage_laid_off,
       `date`,
       stage,
       country,
       funds_raised,
       COUNT(*) AS cnt
FROM layoffs_staging2
GROUP BY company,
         location,
         industry,
         total_laid_off,
         percentage_laid_off,
         `date`,
         stage,
         country,
         funds_raised
HAVING COUNT(*) > 1;

SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY company,
                        location,
                        industry,
                        total_laid_off,
                        percentage_laid_off,
                        `date`,
                        stage,
                        country,
                        funds_raised
           ORDER BY company
       ) AS rn
FROM layoffs_staging2
WHERE company IN ('Beyond Meat', 'Cars24', 'Cazoo')
ORDER BY company, rn;

DELETE
FROM temp_duplicates
WHERE row_num > 1;


CREATE TABLE layoffs_staging3 AS
SELECT
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company,
                            location,
                            industry,
                            total_laid_off,
                            percentage_laid_off,
                            `date`,
                            stage,
                            country,
                            funds_raised
               ORDER BY company
           ) AS rn
    FROM layoffs_staging2
) t
WHERE rn = 1;

SELECT COUNT(*) FROM layoffs_staging2;

SELECT COUNT(*) FROM layoffs_staging3;

DROP TABLE layoffs_staging2;

RENAME TABLE layoffs_staging3 TO layoffs_staging2;


SELECT *
FROM layoffs_staging2
WHERE company = ''
   OR location = ''
   OR industry = ''
   OR country = ''
   OR stage = '';
   
SELECT
SUM(company IS NULL) AS company_nulls,
SUM(location IS NULL) AS location_nulls,
SUM(industry IS NULL) AS industry_nulls,
SUM(total_laid_off IS NULL) AS total_laid_off_nulls,
SUM(percentage_laid_off IS NULL) AS percentage_nulls,
SUM(`date` IS NULL) AS date_nulls,
SUM(stage IS NULL) AS stage_nulls,
SUM(country IS NULL) AS country_nulls,
SUM(funds_raised IS NULL) AS funds_nulls
FROM layoffs_staging2;


SELECT count(*)
FROM layoffs_staging2;