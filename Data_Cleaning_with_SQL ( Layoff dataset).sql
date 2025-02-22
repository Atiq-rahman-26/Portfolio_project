

-- Data_cleaning --

select*
from layoffs ;

-- step that i am going to follow --
	-- 1.  Remove_duplicates --
	-- 2.  Standardize the data --
	-- 3.  Decision about blank/null --
	-- 4.  Remove unnecessary rows/column! --



-- creating a temp workstation --

CREATE TABLE layoffs_staging
like layoffs;

select *
from layoffs_staging ;

insert Layoffs_staging
select*
from layoffs;

select *,
row_number() over (
PARTITION BY company, industry, total_laid_off, percentage_laid_off, 'date') as row_num
from layoffs_staging ;


with duplicate_cte As
(
select *,
row_number() over (
PARTITION BY company, industry, total_laid_off, percentage_laid_off, 'date') as row_num
from layoffs_staging 
) 
select *
from duplicate_cte
where row_num >1;

select *
from layoffs_staging
where company = "oda" 

-- so they were not actually duplicates, rather different valid entries with same name

WITH duplicate_cte As
(
select *,
row_number() over (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) as row_num
from layoffs_staging 
) 
delete
from duplicate_cte
where row_num >1 ;

select *
from layoffs_staging
where company = "cazoo" ;






CREATE TABLE `layoffs_staging_2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging_2;

INSERT INTO layoffs_staging_2
select *,
row_number() over (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) as row_num
from layoffs_staging ;

DELETE
FROM layoffs_staging_2
WHERE row_num >1;

SELECT *
FROM layoffs_staging_2;

-- STANDARDIZING DATA--
  
SELECT DISTINCT (TRIM(company))
FROM layoffs_staging_2 ;

UPDATE layoffs_staging_2
SET company = TRIM(company) ;

SELECT DISTINCT industry
FROM layoffs_staging_2 
ORDER BY 1;

SELECT *
FROM layoffs_staging_2 
WHERE industry like 'crypto%';

UPDATE layoffs_staging_2
SET	industry = 'crypto'
WHERE industry like 'crypto%' ;

SELECT *
FROM layoffs_staging_2 ;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
from layoffs_staging_2
ORDER BY 1;


UPDATE layoffs_staging_2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country like 'United States%' ;

SELECT `date`
FROM layoffs_staging_2 ;

UPDATE layoffs_staging_2
SET `date` = str_to_date(`date`, '%m/%d/%Y' ) ;

ALTER TABLE layoffs_staging_2
MODIFY COLUMN `date` DATE;

select *
FROM layoffs_staging_2 
WHERE total_laid_off is NULL
AND percentage_laid_off is NULL;

UPDATE layoffs_staging_2
SET industry = NULL
WHERE industry = '';

select *
FROM layoffs_staging_2 
WHERE industry IS NULL
OR industry = '';


SELECT *
from layoffs_staging_2
WHERE company= 'airbnb';

SELECT *
FROM layoffs_staging_2  t1
JOIN layoffs_staging_2  t2
	on t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging_2  t1
JOIN layoffs_staging_2  t2
	on t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

DELETE
FROM layoffs_staging_2 
WHERE total_laid_off is NULL
AND percentage_laid_off is NULL;

SELECT *
FROM layoffs_staging_2 ;

Alter table layoffs_staging_2
drop column row_num ;
































