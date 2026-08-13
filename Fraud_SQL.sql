Use fraud_detection;
show tables;
Select Count(*) from customers;
Select * from customers;

Select Count(*) from loan_applications;
Select * from loan_applications;

Select Count(*) from fraud_cases;
Select * from fraud_cases;

Select Count(*) from credit_history;
Select * from credit_history;

Select Count(*) from transactions;
Select * from transactions;
-- ***********************Average*******************************
Select occupation, Avg(age) as avg_age from customers
group by occupation
order by avg_age Desc; 

-- **********************Second Highest value**********************************
Select occupation, max(age) as Max_age from customers
where age < (Select max(age) as Max_age from customers)
group by occupation
order by Max_age Desc;

Select * from customers
where age = (
Select max(age) from customers
where age < (Select max(age) as Max_age from customers));

-- ************************TOP 3 Customers By Amount**********************
Select * from customers;
Select * from loan_applications; 
Select * from fraud_cases; 

Select * from customers c
inner join loan_applications l
ON c.customer_id = l.customer_id
order by annual_income desc
limit 5;

Select distinct * from loan_applications l
Left join fraud_cases f
on l.loan_id = f.loan_id;

With CTE as (
	select *,
    row_number() over (order by l.loan_amount desc) as rn
    from customers c
    LEFT join loan_applications l
    on c.customer_id = l.customer_id
)
Select * from CTE; 

WITH CTE AS (
    SELECT
        c.*,
        l.customer_id AS loan_customer_id,
        l.loan_id,
        l.loan_amount,
        ROW_NUMBER() OVER (partition by c.occupation ORDER BY l.loan_amount DESC) AS rn
    FROM customers c
    LEFT JOIN loan_applications l
        ON c.customer_id = l.customer_id
)
SELECT * FROM CTE
where rn <=3;

-- ***************Account open date******************************************
Select *, date_format(account_open_date, '%d-%b-%Y') as Account_Opend from customers;

Select monthname(account_open_date, '%b') as month_accont from customers;

Select account_open_date, date_format(account_open_date, '%d-%b-%Y') from customers;

Select Max(account_open_date) from customers;

Select Min(account_open_date) from customers;

Select Count(*) from customers
where account_open_date >= current_date() - interval 150 day;

Select Count(*) from customers
where account_open_date between '2026-01-01' and '2026-02-20';

DESCRIBE customers;

DESCRIBE loan_applications;

Select * from Customers
Union
Select * from loan_applications;

Select date_format(account_open_date, '%b-%y') as Month_year, sum(annual_income) as Revenue from Customers
group by Month_year
order by Month_year desc;

SELECT
    DATE_FORMAT(account_open_date, '%b-%y') AS Month_year,
    SUM(annual_income) AS Revenue
FROM Customers
GROUP BY DATE_FORMAT(account_open_date, '%b-%y'),
         YEAR(account_open_date),
         MONTH(account_open_date)
ORDER BY YEAR(account_open_date) DESC,
         MONTH(account_open_date) DESC;
         
Select date_format(account_open_date, '%b-%y') as Month_Year, sum(annual_income) as revenue,
Round(Count(*)*100/ (Select Count(*) from Customers),2) as percenatage_monthly from Customers
Group by Month_Year
order by revenue desc;

SELECT
    Month_Year,
    Revenue,
    Revenue - LAG(Revenue) OVER (ORDER BY Yr, Mon) AS MoM_Difference
FROM (
    SELECT
        YEAR(account_open_date) AS Yr,
        MONTH(account_open_date) AS Mon,
        DATE_FORMAT(account_open_date, '%b-%Y') AS Month_Year,
        SUM(annual_income) AS Revenue
    FROM Customers
    GROUP BY
        YEAR(account_open_date),
        MONTH(account_open_date),
        DATE_FORMAT(account_open_date, '%b-%Y')
) t
ORDER BY Yr, Mon;

Select Gender, Count(*) as total_Customers,
	Round(Count(*) * 100 / (Select Count(*) from Customers),2) as percentage from Customers
Group by Gender;

-- Pratice ------
Select * from Customers;
Select * from credit_history;

-- Last 150 days records 
Select Count(*) from customers
where account_open_date >= current_date() - interval 150 day;

Select * from Customers c
inner join credit_history ch
On c.customer_id = ch. customer_id
where c.account_open_date >= current_date() - interval 150 day;

-- Max values, second Highest, Top3 values
Select Customer_id,occupation,Max(annual_income) as max_slary from Customers
group by occupation
order by max_slary desc;

Select * from customers c
inner join credit_history ch
On c.customer_id = ch.customer_id
where c.annual_income = (select max(c.annual_income) from customers)
limit 1; 


-- Second Highest
Select * from customers
where annual_income < (select max(annual_income) from customers)
limit 1; 

with CTE AS(
Select *,
		row_number() over ( partition by occupation order by annual_income desc) as rn from customers
)
Select * from CTE where rn = 2;

with CTE as(
	Select c.customer_id,c.customer_name, c.city, c.gender, c. annual_income,c.occupation,
	ch. credit_score, ch.existing_loans, ch.emi_amount,ch.delayed_payments,
    row_number() over (partition by c.occupation order by c. annual_income) as rn from customers c
    join credit_history ch
    on c.customer_id = ch.customer_id
)
select * from CTE where rn <= 3;

Select * from customers;

Select date_format(account_open_date, '%M-%Y') as month_over_month,
date_format(account_open_date, '%Y') as Year_over_Year,
sum(annual_income) from customers
Group by month_over_month, Year_over_Year
order by month_over_month asc;


-- who placed order first in every month ----
Select * from transactions
where day(date) = 1
order by year(date) desc;

WITH FirstTransaction AS (
    SELECT t.transaction_id, t.customer_id, c.customer_name, t.date AS transaction_date, t.amount,
        ROW_NUMBER() OVER ( PARTITION BY YEAR(t.date), MONTH(t.date) ORDER BY t.date ASC ) AS rn
    FROM transactions t
    JOIN customers c
        ON t.customer_id = c.customer_id
)
SELECT customer_id, customer_name, transaction_id, transaction_date, amount FROM FirstTransaction
WHERE rn = 1 ORDER BY transaction_date desc;
