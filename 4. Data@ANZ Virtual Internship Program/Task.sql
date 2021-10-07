 /*
Background Information

This task is based on a synthesised transaction dataset containing 3 months’ worth of transactions for 100 hypothetical customers. It contains purchases, recurring transactions, and salary transactions.
The dataset is designed to simulate realistic transaction behaviours that are observed in ANZ’s real transaction data, so many of the insights you can gather from the tasks below will be genuine.

1. Load the transaction dataset below into an analysis tool of your choice (Excel, R, SAS, Tableau, or similar)
2. Start by doing some basic checks – are there any data issues? Does the data need to be cleaned?
3. Gather some interesting overall insights about the data. For example -- what is the average transaction amount? How many transactions do customers make each month, on average?
4. Segment the dataset by transaction date and time. Visualise transaction volume and spending over the course of an average day or week. Consider the effect of any outliers that may distort your analysis.
5. For a challenge – what insights can you draw from the location information provided in the dataset?
6. Put together 2-3 slides summarising your most interesting findings to ANZ management.

*/

USE project;

SELECT *
FROM anz_transaction
LIMIT 5;

# Change the date format
SELECT 
	date,
    STR_TO_DATE(date, '%d/%m/%Y')
FROM anz_transaction
LIMIT 5;

COMMIT;

UPDATE anz_transaction 
SET date = STR_TO_DATE(date, '%d/%m/%Y');

COMMIT;

# Add the name of days, weeks and months and separate date and time

# DAYNAME() finds the name of days, MONTHNAME() finds the name of months and WEEK() finds the week number.
SELECT
	date,
    DAYNAME(date) AS day_name,
    MONTHNAME(date) AS month_name,
    WEEK(date, 1) AS week_num,
    extraction,
    SUBSTR(extraction, POSITION('T' in extraction)+1, 2) AS hour
FROM anz_transaction;
-- GROUP BY WEEK(date, 1);

COMMIT;

# Create day_name, month_name and week_num columns 
ALTER TABLE anz_transaction
ADD COLUMN day_name VARCHAR(20);

ALTER TABLE anz_transaction
ADD COLUMN month_name VARCHAR(20);

ALTER TABLE anz_transaction
ADD COLUMN week_num VARCHAR(20);

ALTER TABLE anz_transaction
ADD COLUMN hour INT(2);

UPDATE anz_transaction
SET day_name = DAYNAME(date);

UPDATE anz_transaction
SET month_name = MONTHNAME(date);

UPDATE anz_transaction
SET week_num = WEEK(date,1);

UPDATE anz_transaction
SET hour = SUBSTR(extraction, POSITION('T' in extraction)+1, 2);

SELECT *
FROM anz_transaction;

COMMIT;

# See 
SELECT
		date,
        month_name,
		first_name,
        gender,
        age,
        amount,
		SUM(amount) OVER (PARTITION BY month_name ORDER BY month_name, date) month
FROM
	anz_transaction
WHERE month_name = 'August';

### transaction amount and volme###

# total/avg
SELECT 
    ROUND(SUM(amount), 2) AS total_amount, 
    ROUND(AVG(amount), 2) AS avg_amount,
    COUNT(transaction_id) AS transaction_count
FROM
    anz_transaction;

# monthly #
SELECT 
    date,
    month_name,
    ROUND(SUM(amount), 2) AS monthly_total_amount,
    ROUND(AVG(amount), 2) AS monthly_avg_amount,
    COUNT(transaction_id) AS count
FROM
    anz_transaction
GROUP BY month_name;

# weekly #
SELECT
		date,
        month_name,
        week_num,
        ROUND(SUM(amount),2) AS weekly_total_amount,
        ROUND(AVG(amount),2) AS weekly_avg_amount,
        COUNT(transaction_id) AS count
FROM
	anz_transaction
GROUP BY week_num;

# dayname #
SELECT
        day_name,
        ROUND(SUM(amount),2) AS daily_total_amount,
        ROUND(AVG(amount),2) AS daily_avg_amount,
        COUNT(transaction_id) AS count
FROM
	anz_transaction
GROUP BY day_name
ORDER BY FIELD(day_name, 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY');

# DAYOFWEEK starts from SUNDAY, but I want it to start from MONDAY
SELECT DAYOFWEEK(date)
FROM anz_transaction;

# daily #
SELECT 
    date,
    month_name,
    week_num,
    day_name,
    ROUND(SUM(amount), 2) AS daily_total_amount,
    ROUND(AVG(amount), 2) AS daily_avg_amount,
    COUNT(transaction_id) AS daily_trans_count
FROM
    anz_transaction
GROUP BY week_num , day_name;

# hourly #
SELECT 
	hour,
    ROUND(SUM(amount)) as amount,
    COUNT(transaction_id) as transaction_count
FROM anz_transaction
GROUP BY hour;


WITH daily_df(date, month_name, week_num, day_name, daily_total_amount, daily_avg_amount, daily_trans_count)
AS(
	SELECT
			date,
			month_name,
			week_num,
			day_name,
			ROUND(SUM(amount),2) AS daily_total_amount,
			ROUND(AVG(amount),2) AS daily_avg_amount,
			COUNT(transaction_id) AS daily_trans_count
	FROM
		anz_transaction
	GROUP BY week_num, day_name
) SELECT *, ROUND(AVG(daily_trans_count))
FROM daily_df
WHERE week_num = 31;



