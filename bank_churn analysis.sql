create database bankchurn; 
create table bank_churn (
rownumber serial,
customerid varchar (20) primary key,
surname varchar (20),
creditscore int,
geography varchar (20),
gender varchar (10),
age int,
tenure int,
balance decimal,
numofproducts int,
hascrcard boolean,
isactivemember boolean,
estimatedsalary decimal,
exited boolean		
);

alter table bank_churn
alter column surname type varchar (50);

copy bank_churn(rownumber, customerid, surname, creditscore, geography, gender, age, tenure, balance, numofproducts, hascrcard, isactivemember, exited)
from 'C:\bankchurn\bank_churn_dataset.csv'
delimiter ','
csv header;

-- customer churn percentage --
select count (*) filter (where exited = true) as total_customers_churned, count (*) as total_customers, ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2) AS "churn percentage"
from bank_churn order by "churn percentage" desc;

-- exploring data to see distinct countries --
select distinct geography from bank_churn;

-- geography-wise customer churn % --
select geography, 
      COUNT(*) FILTER (WHERE exited = TRUE) AS exited_customers,
      COUNT(*) FILTER (WHERE exited = FALSE) AS retained_customers,
	  COUNT (*) AS total_customers,
	  ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2) AS churn_percentage
from bank_churn
group by geography
order by churn_percentage desc;

-- balance exit count (ranges w concat) --
SELECT 
    CONCAT(
        FLOOR(balance / 10000) * 10000, 
        ' - ', 
        FLOOR(balance / 10000) * 10000 + 9999
    ) AS balance_range,
    COUNT(*) AS exited_count
FROM 
    bank_churn
WHERE 
    exited = TRUE
    AND balance <= 300000
GROUP BY 
    FLOOR(balance / 10000)
ORDER BY 
    FLOOR(balance / 10000);

-- balance exited vs stayed w exited count --
SELECT 
    FLOOR(balance / 10000) * 10000 AS balance_range_start,
    FLOOR(balance / 10000) * 10000 + 9999 AS balance_range_end,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_true_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS exited_false_count

FROM 
    bank_churn
WHERE 
    balance <= 300000

GROUP BY 
    FLOOR(balance / 10000)

ORDER BY 
    exited_true_count desc;	
	
-- balance exit vs stay w exit% --
SELECT 
    CONCAT(
        FLOOR(balance / 10000) * 10000, 
        ' - ', 
        FLOOR(balance / 10000) * 10000 + 9999
    ) AS balance_range,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS retained_count,
	count(*) as total_customers,
	ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2) AS churn_percentage
FROM 
    bank_churn
WHERE 
    balance <= 300000

GROUP BY 
    FLOOR(balance / 10000)

ORDER BY 
    churn_percentage desc;

-- estimated salary exited vs stayed --
SELECT 
    FLOOR(estimatedsalary / 10000) * 10000 AS salary_range_start,
    FLOOR(estimatedsalary / 10000) * 10000 + 9999 AS salary_range_end,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS stayed_count

FROM 
    bank_churn
WHERE 
    estimatedsalary <= 300000

GROUP BY 
    FLOOR(estimatedsalary / 10000)

ORDER BY 
    exited_count desc;

-- estimated salary exited vs stayed w exit% --
SELECT 
    CONCAT(
        FLOOR(estimatedsalary / 10000) * 10000, 
        ' - ', 
        FLOOR(estimatedsalary / 10000) * 10000 + 9999
    ) AS estimatedsalary_range,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS retained_count,
	count(*) as total_customers,
	ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2) AS churn_percentage
from bank_churn
WHERE 
    estimatedsalary <= 300000
GROUP BY 
    FLOOR(estimatedsalary / 10000)
ORDER BY 
    churn_percentage desc;

-- geo + age + balance + est.salary --
SELECT geography, 
    FLOOR(age / 10) * 10 AS age_range_start,
    FLOOR(age / 10) * 10 + 9 AS age_range_end,
    FLOOR(balance / 10000) * 10000 AS balance_range_start,
    FLOOR(balance / 10000) * 10000 + 9999 AS balance_range_end,
	FLOOR(estimatedsalary/ 10000) * 10000 AS salary_range_start,
    FLOOR(estimatedsalary / 10000) * 10000 + 9999 AS salary_range_end,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS retained_count,
	count(*) as total_customers,
	ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2) AS churn_percentage
FROM 
    bank_churn
WHERE 
    age <= 100 and balance <=300000 and estimatedsalary <=300000

GROUP BY FLOOR(estimatedsalary / 10000), floor(age/10), floor(balance/10000), geography

ORDER BY 
    churn_percentage desc;	

SELECT geography, 
    FLOOR(age / 10) * 10 AS age_range_start,
    FLOOR(age / 10) * 10 + 9 AS age_range_end,
    FLOOR(balance / 10000) * 10000 AS balance_range_start,
    FLOOR(balance / 10000) * 10000 + 9999 AS balance_range_end,
	FLOOR(estimatedsalary/ 10000) * 10000 AS salary_range_start,
    FLOOR(estimatedsalary / 10000) * 10000 + 9999 AS salary_range_end,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS retained_count,
	count(*) as total_customers
FROM 
    bank_churn
WHERE 
    age <= 100 and balance <=300000 and estimatedsalary <=300000

GROUP BY FLOOR(estimatedsalary / 10000), floor(age/10), floor(balance/10000), geography

ORDER BY 
    exited_count desc;	
	
-- geo + age + est.salary --
SELECT geography, 
    FLOOR(age / 10) * 10 AS age_range_start,
    FLOOR(age / 10) * 10 + 9 AS age_range_end,
	FLOOR(estimatedsalary/ 10000) * 10000 AS salary_range_start,
    FLOOR(estimatedsalary / 10000) * 10000 + 9999 AS salary_range_end,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS retained_count,
	count(*) as total_customers,
	ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2) AS churn_percentage
FROM 
    bank_churn
WHERE 
    age <= 100 and estimatedsalary <=300000

GROUP BY FLOOR(estimatedsalary / 10000), floor(age/10), geography

ORDER BY 
    churn_percentage desc;

-- geo + est. salary, exit count desc --
SELECT geography, 
	FLOOR(estimatedsalary/ 10000) * 10000 AS salary_range_start,
    FLOOR(estimatedsalary / 10000) * 10000 + 9999 AS salary_range_end,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS stayed_count
FROM 
    bank_churn
WHERE 
    estimatedsalary <=300000
GROUP BY FLOOR(estimatedsalary / 10000), geography
ORDER BY 
    exited_count desc;

-- geo salary churn% --
SELECT geography, 
	FLOOR(estimatedsalary/ 10000) * 10000 AS salary_range_start,
    FLOOR(estimatedsalary / 10000) * 10000 + 9999 AS salary_range_end,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS retained_count,
	count(*) as total_customers,
	ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2) AS churn_percentage
FROM 
    bank_churn
WHERE 
    estimatedsalary <=300000
GROUP BY FLOOR(estimatedsalary / 10000), geography
ORDER BY 
    churn_percentage desc;

-- geo balance churn% --
SELECT geography, 
	FLOOR(balance/ 10000) * 10000 AS balance_range_start,
    FLOOR(balance / 10000) * 10000 + 9999 AS balance_range_end,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS retained_count,
	count(*) as total_customers,
	ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2) AS churn_percentage
FROM 
    bank_churn
WHERE 
    balance <=300000
GROUP BY FLOOR(balance / 10000), geography
ORDER BY 
    churn_percentage desc;
	
-- combined attribute analysis 1. geo + age w exit% -- 	
SELECT geography, 
    CONCAT(
        FLOOR(age/10) * 10, 
        ' - ', 
        FLOOR(age/10) * 10 + 9
    ) AS age_range,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS retained_count,
	count (*) as total_customers,
	ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2) AS churn_percentage
FROM 
    bank_churn
WHERE 
    age <= 100 
GROUP BY floor(age/10), geography
ORDER BY 
    churn_percentage desc;

-- combined attribute analysis 6. gender + age --
SELECT gender, 
    CONCAT(
        FLOOR(age/10) * 10, 
        ' - ', 
        FLOOR(age/10) * 10 + 9
    ) AS age_range,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS retained_count,
	count (*) as total_customers,
	ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2) AS churn_percentage
FROM 
    bank_churn
WHERE 
    age <= 100 
GROUP BY floor(age/10), gender
ORDER BY 
    churn_percentage desc;


-- age exit vs stay --
SELECT 
    FLOOR(age / 10) * 10 AS age_range_start,
    FLOOR(age / 10) * 10 + 9 AS age_range_end,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS stayed_count
FROM 
    bank_churn
WHERE 
    age <= 100 
GROUP BY floor(age/10)
ORDER BY 
    exited_count desc;

-- age exit vs stay w exit% --
SELECT 
    CONCAT(
        FLOOR(age/10) * 10, 
        ' - ', 
        FLOOR(age/10) * 10 + 9
    ) AS age_range,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS retained_count,
	count (*) as total_customers,
	ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2) AS churn_percentage
FROM 
    bank_churn
WHERE 
    age <= 100 
GROUP BY floor(age/10)
ORDER BY 
    churn_percentage desc;

-- gender exit vs stay w exit% --
select gender, COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS retained_count,
	count (*) as total_customers,
	ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2) AS churn_percentage
FROM 
    bank_churn 
GROUP BY gender
ORDER BY 
    churn_percentage desc;
	
-- combined attribute analysis 4. geo + gender --
select geography, gender, COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS retained_count,
	count (*) as total_customers,
	ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2) AS churn_percentage
FROM 
    bank_churn 
GROUP BY gender, geography
ORDER BY 
    churn_percentage desc;
	
-- geo exit vs stay counts --
select geography, count (*) filter (where exited = true) as exited_count, count (*) filter (where exited = false) as stayed_count from bank_churn group by geography order by exited_count desc;


-- geo + balance + salary --
SELECT geography, 
    FLOOR(balance / 10000) * 10000 AS balance_range_start,
    FLOOR(balance / 10000) * 10000 + 9999 AS balance_range_end,
	FLOOR(estimatedsalary/ 10000) * 10000 AS salary_range_start,
    FLOOR(estimatedsalary / 10000) * 10000 + 9999 AS salary_range_end,
	COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
	COUNT(*) FILTER (WHERE exited = FALSE) AS retained_count,
	count (*) as total_customers,
	ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2) AS churn_percentage
FROM 
    bank_churn
WHERE 
    balance <=300000 and estimatedsalary <=300000
GROUP BY FLOOR(estimatedsalary / 10000), floor(balance/10000), geography
ORDER BY 
    churn_percentage desc;
	
-- combined attribute analysis 5. gender + creditscore churn --
SELECT gender, 
    CONCAT(
        FLOOR(creditscore / 100) * 100, 
        ' - ', 
        FLOOR(creditscore / 100) * 100 + 99
    ) AS creditscore_range, 	
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS retained_count,
	count (*) as total_customers,
	ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2) AS churn_percentage
FROM 
    bank_churn
WHERE 
    creditscore <=1000

GROUP BY FLOOR(creditscore / 100), gender

ORDER BY 
    churn_percentage desc;

-- creditscore exit vs stay w exit% --
SELECT
    CONCAT(
        FLOOR(creditscore / 100) * 100, 
        ' - ', 
        FLOOR(creditscore / 100) * 100 + 99
    ) AS creditscore_range, 	
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS retained_count,
	count (*) as total_customers,
	ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2) AS churn_percentage
FROM 
    bank_churn
WHERE 
    creditscore <=1000

GROUP BY FLOOR(creditscore / 100)

ORDER BY 
    churn_percentage desc;

-- combined attribute analysis 7. geo + creditscore --
SELECT geography,
    CONCAT(
        FLOOR(creditscore / 100) * 100, 
        ' - ', 
        FLOOR(creditscore / 100) * 100 + 99
    ) AS creditscore_range, 	
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS retained_count,
	count (*) as total_customers,
	ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2) AS churn_percentage
FROM 
    bank_churn
WHERE 
    creditscore <=1000

GROUP BY FLOOR(creditscore / 100), geography

ORDER BY 
    churn_percentage desc;

-- hascrcard exit vs stay w exit% --
SELECT 
    hascrcard,
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS retained_count,
    ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2
    ) AS churn_percentage
FROM bank_churn
GROUP BY hascrcard
ORDER BY churn_percentage DESC;

-- exploring the different no.of products used by customers --
select distinct numofproducts from bank_churn order by numofproducts;

-- numofproducts exit vs stay --
select numofproducts, 
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS stayed_count
FROM 
    bank_churn group by numofproducts order by exited_count desc;
select numofproducts, count (*) as customer_count from bank_churn group by numofproducts order by numofproducts asc;

-- numofproducts exit vs stay exit%	--
select numofproducts, 
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS retained_count,
	count (*) as total_customers,
	ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2) AS churn_percentage
FROM 
    bank_churn group by numofproducts order by churn_percentage desc;

-- combined attribute analysis 2. geo + numofproducts --
select geography, numofproducts, 
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS retained_count,
	count (*) as total_customers,
	ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2) AS churn_percentage
FROM 
    bank_churn group by numofproducts, geography order by churn_percentage desc;

-- combined attribute analysis 3. geo + isactivemember --
SELECT 
    geography, isactivemember,
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS retained_count,
    ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2
    ) AS churn_percentage
FROM bank_churn
GROUP BY isactivemember, geography
ORDER BY churn_percentage DESC;

-- isactivemember exit vs stay w exit% --
SELECT 
    isactivemember,
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS retained_count,
    ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2
    ) AS churn_percentage
FROM bank_churn
GROUP BY isactivemember
ORDER BY churn_percentage DESC;

-- tenure exit vs stay w exit% --
select tenure, count (*) as total_customers, COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count, COUNT(*) FILTER (WHERE exited = FALSE) AS retained_count, ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2) AS churn_percentage from bank_churn group by tenure order by churn_percentage desc;

-- summary stats for numerical variables --
-- estimatedsalary --
SELECT 
    AVG(estimatedsalary) AS mean_salary,
    PERCENTILE_CONT(0.5) 
        WITHIN GROUP (ORDER BY estimatedsalary) AS median_salary,
    MODE() 
        WITHIN GROUP (ORDER BY estimatedsalary) AS mode_salary,
    MIN(estimatedsalary) AS min_salary,
    MAX(estimatedsalary) AS max_salary,
    STDDEV(estimatedsalary) AS stddev_salary
FROM 
    bank_churn;

-- balance --
SELECT 
    AVG(balance) AS mean_balance,
    PERCENTILE_CONT(0.5) 
        WITHIN GROUP (ORDER BY balance) AS median_balance,
    MODE() 
        WITHIN GROUP (ORDER BY balance) AS mode_balance,
    MIN(balance) AS min_balance,
    MAX(balance) AS max_balance,
    STDDEV(balance) AS stddev_balance
FROM 
    bank_churn;

-- creditscore --
SELECT 
    AVG(creditscore) AS mean_creditscore,
    PERCENTILE_CONT(0.5) 
        WITHIN GROUP (ORDER BY creditscore) AS median_creditscore,
    MODE() 
        WITHIN GROUP (ORDER BY creditscore) AS mode_creditscore,
    MIN(creditscore) AS min_creditscore,
    MAX(creditscore) AS max_creditscore,
    STDDEV(creditscore) AS stddev_creditscore
FROM 
    bank_churn;	

-- age --
SELECT 
    AVG(age) AS mean_age,
    PERCENTILE_CONT(0.5) 
        WITHIN GROUP (ORDER BY age) AS median_age,
    MODE() 
        WITHIN GROUP (ORDER BY age) AS mode_age,
    MIN(age) AS min_age,
    MAX(age) AS max_age,
    STDDEV(age) AS stddev_age
FROM 
    bank_churn;	

-- tenure --
SELECT 
    AVG(tenure) AS mean_tenure,
    PERCENTILE_CONT(0.5) 
        WITHIN GROUP (ORDER BY tenure) AS median_tenure,
    MODE() 
        WITHIN GROUP (ORDER BY tenure) AS mode_tenure,
    MIN(tenure) AS min_tenure,
    MAX(tenure) AS max_tenure,
    STDDEV(tenure) AS stddev_tenure
FROM 
    bank_churn;

-- numofproducts --
SELECT 
    AVG(numofproducts) AS mean_numofproducts,
    PERCENTILE_CONT(0.5) 
        WITHIN GROUP (ORDER BY numofproducts) AS median_numofproducts,
    MODE() 
        WITHIN GROUP (ORDER BY numofproducts) AS mode_numofproducts,
    MIN(numofproducts) AS min_numofproducts,
    MAX(numofproducts) AS max_numofproducts,
    STDDEV(numofproducts) AS stddev_numofproducts
FROM 
    bank_churn;	

-- spain geography, creditscore, balance, number of products, estimated salary, age & gender --
select geography, creditscore, balance, numofproducts, estimatedsalary, age, gender from bank_churn where geography = 'Spain' and exited = true order by balance desc;

-- country-wise analysis
-- CHURN METRICS FOR SPAIN --

--1 --
    SELECT 
    geography, 
    FLOOR(estimatedsalary / 10000) * 10000 AS salary_range_start,
    FLOOR(estimatedsalary / 10000) * 10000 + 9999 AS salary_range_end,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS stayed_count,
    ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 
        2
    ) AS "exited percentage ((exit/exit+stay)*100)"
FROM 
    bank_churn
WHERE 
    estimatedsalary <= 300000 
    AND geography = 'Spain'
GROUP BY 
    geography, FLOOR(estimatedsalary / 10000)
ORDER BY 
    "exited percentage ((exit/exit+stay)*100)" DESC;

--2 --
SELECT 
    geography, 
    FLOOR(balance / 10000) * 10000 AS balance_range_start,
    FLOOR(balance / 10000) * 10000 + 9999 AS balance_range_end,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS stayed_count,
    ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 
        2
    ) AS "exited percentage ((exit/exit+stay)*100)"
FROM 
    bank_churn
WHERE 
    balance <= 300000 
    AND geography = 'Spain'
GROUP BY 
    geography, floor(balance/10000)
ORDER BY 
    "exited percentage ((exit/exit+stay)*100)" DESC;

--3 --
SELECT 
    geography, 
    CONCAT(
        FLOOR(creditscore / 100) * 100, 
        ' - ', 
        FLOOR(creditscore / 100) * 100 + 99
    ) AS creditscore_range,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS stayed_count,
    ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 
        2
    ) AS "exited percentage ((exit/exit+stay)*100)"
FROM 
    bank_churn
WHERE 
    creditscore <= 1000 
    AND geography = 'Spain'
GROUP BY 
    geography, floor(creditscore/100)
ORDER BY 
    "exited percentage ((exit/exit+stay)*100)" DESC;

--4 --
SELECT 
    geography, 
    FLOOR(age / 10) * 10 AS age_range_start,
    FLOOR(age / 10) * 10 + 9 AS age_range_end,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS stayed_count,
    ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 
        2
    ) AS "exited percentage ((exit/exit+stay)*100)"
FROM 
    bank_churn
WHERE 
    age <= 100
    AND geography = 'Spain'
GROUP BY 
    geography, floor(age/10)
ORDER BY 
    "exited percentage ((exit/exit+stay)*100)" DESC;

--5 --
SELECT 
    geography, gender,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS stayed_count,
    ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2) AS "exited percentage ((exit/exit+stay)*100)"
FROM 
    bank_churn
WHERE geography = 'Spain'
GROUP BY 
    geography, gender
ORDER BY 
    "exited percentage ((exit/exit+stay)*100)" DESC;

--6 --
SELECT 
    geography, numofproducts,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS stayed_count,
    ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2) AS "exited percentage ((exit/exit+stay)*100)"
FROM 
    bank_churn
WHERE geography = 'Spain'
GROUP BY 
    geography, numofproducts
ORDER BY 
    "exited percentage ((exit/exit+stay)*100)" DESC;


-- CHURN METRICS FOR FRANCE --
--1
SELECT 
    geography, 
    FLOOR(estimatedsalary / 10000) * 10000 AS salary_range_start,
    FLOOR(estimatedsalary / 10000) * 10000 + 9999 AS salary_range_end,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS stayed_count,
    ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 
        2
    ) AS "exited percentage ((exit/exit+stay)*100)"
FROM 
    bank_churn
WHERE 
    estimatedsalary <= 300000 
    AND geography = 'France'
GROUP BY 
    geography, FLOOR(estimatedsalary / 10000)
ORDER BY 
    "exited percentage ((exit/exit+stay)*100)" DESC;

--2
SELECT 
    geography, 
    FLOOR(balance / 10000) * 10000 AS balance_range_start,
    FLOOR(balance / 10000) * 10000 + 9999 AS balance_range_end,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS stayed_count,
    ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 
        2
    ) AS "exited percentage ((exit/exit+stay)*100)"
FROM 
    bank_churn
WHERE 
    balance <= 300000 
    AND geography = 'France'
GROUP BY 
    geography, floor(balance/10000)
ORDER BY 
    "exited percentage ((exit/exit+stay)*100)" DESC;

--3
SELECT 
    geography, 
    CONCAT(
        FLOOR(creditscore / 100) * 100, 
        ' - ', 
        FLOOR(creditscore / 100) * 100 + 99
    ) AS creditscore_range,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS stayed_count,
    ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 
        2
    ) AS "exited percentage ((exit/exit+stay)*100)"
FROM 
    bank_churn
WHERE 
    creditscore <= 1000 
    AND geography = 'France'
GROUP BY 
    geography, floor(creditscore/100)
ORDER BY 
    "exited percentage ((exit/exit+stay)*100)" DESC;

--4
SELECT 
    geography, 
    FLOOR(age / 10) * 10 AS age_range_start,
    FLOOR(age / 10) * 10 + 9 AS age_range_end,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS stayed_count,
    ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 
        2
    ) AS "exited percentage ((exit/exit+stay)*100)"
FROM 
    bank_churn
WHERE 
    age <= 100
    AND geography = 'France'
GROUP BY 
    geography, floor(age/10)
ORDER BY 
    "exited percentage ((exit/exit+stay)*100)" DESC;

--5
SELECT 
    geography, gender,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS stayed_count,
    ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2) AS "exited percentage ((exit/exit+stay)*100)"
FROM 
    bank_churn
WHERE geography = 'France'
GROUP BY 
    geography, gender
ORDER BY 
    "exited percentage ((exit/exit+stay)*100)" DESC;

--6
SELECT 
    geography, numofproducts,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS stayed_count,
    ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2) AS "exited percentage ((exit/exit+stay)*100)"
FROM 
    bank_churn
WHERE geography = 'France'
GROUP BY 
    geography, numofproducts
ORDER BY 
    "exited percentage ((exit/exit+stay)*100)" DESC;

-- CHURN METRICS FOR GERMANY --
--1
SELECT 
    geography, 
    FLOOR(estimatedsalary / 10000) * 10000 AS salary_range_start,
    FLOOR(estimatedsalary / 10000) * 10000 + 9999 AS salary_range_end,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS stayed_count,
    ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 
        2
    ) AS "exited percentage ((exit/exit+stay)*100)"
FROM 
    bank_churn
WHERE 
    estimatedsalary <= 300000 
    AND geography = 'Germany'
GROUP BY 
    geography, FLOOR(estimatedsalary / 10000)
ORDER BY 
    "exited percentage ((exit/exit+stay)*100)" DESC;

--2
SELECT 
    geography, 
    FLOOR(balance / 10000) * 10000 AS balance_range_start,
    FLOOR(balance / 10000) * 10000 + 9999 AS balance_range_end,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS stayed_count,
    ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 
        2
    ) AS "exited percentage ((exit/exit+stay)*100)"
FROM 
    bank_churn
WHERE 
    balance <= 300000 
    AND geography = 'Germany'
GROUP BY 
    geography, floor(balance/10000)
ORDER BY 
    "exited percentage ((exit/exit+stay)*100)" DESC;

--3
SELECT 
    geography, 
    CONCAT(
        FLOOR(creditscore / 100) * 100, 
        ' - ', 
        FLOOR(creditscore / 100) * 100 + 99
    ) AS creditscore_range,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS stayed_count,
    ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 
        2
    ) AS "exited percentage ((exit/exit+stay)*100)"
FROM 
    bank_churn
WHERE 
    creditscore <= 1000 
    AND geography = 'Germany'
GROUP BY 
    geography, floor(creditscore/100)
ORDER BY 
    "exited percentage ((exit/exit+stay)*100)" DESC;

--4
SELECT 
    geography, 
    FLOOR(age / 10) * 10 AS age_range_start,
    FLOOR(age / 10) * 10 + 9 AS age_range_end,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS stayed_count,
    ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 
        2
    ) AS "exited percentage ((exit/exit+stay)*100)"
FROM 
    bank_churn
WHERE 
    age <= 100
    AND geography = 'Germany'
GROUP BY 
    geography, floor(age/10)
ORDER BY 
    "exited percentage ((exit/exit+stay)*100)" DESC;

--5
SELECT 
    geography, gender,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS stayed_count,
    ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2) AS "exited percentage ((exit/exit+stay)*100)"
FROM 
    bank_churn
WHERE geography = 'Germany'
GROUP BY 
    geography, gender
ORDER BY 
    "exited percentage ((exit/exit+stay)*100)" DESC;

--6
SELECT 
    geography, numofproducts,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS stayed_count,
    ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2) AS "exited percentage ((exit/exit+stay)*100)"
FROM 
    bank_churn
WHERE geography = 'Germany'
GROUP BY 
    geography, numofproducts
ORDER BY 
    "exited percentage ((exit/exit+stay)*100)" DESC;
----------------
-- Spain geo, balance, salary exit vs stay, exit% --
SELECT geography, 
    FLOOR(balance / 10000) * 10000 AS balance_range_start,
    FLOOR(balance / 10000) * 10000 + 9999 AS balance_range_end,
	FLOOR(estimatedsalary/ 10000) * 10000 AS salary_range_start,
    FLOOR(estimatedsalary / 10000) * 10000 + 9999 AS salary_range_end,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS stayed_count,
	ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2) AS "exited percentage ((exit/exit+stay)*100)"
FROM 
    bank_churn
WHERE 
    geography = 'Spain' and balance <=300000 and estimatedsalary <=300000
GROUP BY FLOOR(estimatedsalary / 10000), floor(balance/10000), geography
ORDER BY 
   "exited percentage ((exit/exit+stay)*100)" desc;	

-- Spain geo, age, est.salary w exit% --
SELECT geography, 
    FLOOR(age / 10) * 10 AS age_range_start,
    FLOOR(age / 10) * 10 + 9 AS age_range_end,
	FLOOR(estimatedsalary/ 10000) * 10000 AS salary_range_start,
    FLOOR(estimatedsalary / 10000) * 10000 + 9999 AS salary_range_end,
    COUNT(*) FILTER (WHERE exited = TRUE) AS exited_count,
    COUNT(*) FILTER (WHERE exited = FALSE) AS stayed_count,
	ROUND(
        (COUNT(*) FILTER (WHERE exited = TRUE) * 100.0 / COUNT(*)), 2) AS "exited percentage ((exit/exit+stay)*100)"
FROM 
    bank_churn
WHERE 
    geography = 'Spain' and age <= 100 and estimatedsalary <=300000
GROUP BY FLOOR(estimatedsalary / 10000), floor(age/10), geography
ORDER BY 
   "exited percentage ((exit/exit+stay)*100)" desc;	
------------------------------------

-- FINAL QUERY

WITH customer_risk AS (
    SELECT 
        customerid,
        geography,
        age,
        creditscore,
        balance,
        estimatedsalary,
        numofproducts,
        isactivemember,
		hascrcard,
		tenure,
		gender,
        exited,

        -- risk scoring logic based on findings from report
        (CASE 
            WHEN isactivemember = FALSE THEN 2 ELSE 0 END +
         CASE 
            WHEN numofproducts = 1 THEN 2 
            WHEN numofproducts >= 3 THEN 3 
            ELSE 0 END +
         CASE 
            WHEN geography = 'Germany' THEN 2 ELSE 0 END +
         CASE 
            WHEN age BETWEEN 40 AND 69 THEN 2 ELSE 0 END
        ) AS churn_risk_score,

        -- window ranking
        ROW_NUMBER() OVER (
            PARTITION BY exited 
            ORDER BY 
                (CASE 
                    WHEN isactivemember = FALSE THEN 2 ELSE 0 END +
                 CASE 
                    WHEN numofproducts = 1 THEN 2 
                    WHEN numofproducts >= 3 THEN 3 
                    ELSE 0 END +
                 CASE 
                    WHEN geography = 'Germany' THEN 2 ELSE 0 END +
                 CASE 
                    WHEN age BETWEEN 40 AND 69 THEN 2 ELSE 0 END
                ) DESC
        ) AS risk_rank
    FROM bank_churn
)

SELECT *
FROM customer_risk
WHERE risk_rank <= 10
ORDER BY exited, risk_rank;