USE [CreditCard-db];
GO

/***************************************************************************************************
-- CREDIT CARD CUSTOMER REPORT
-- Description: This script generates customer-centric KPIs and demographic analyses by leveraging
   a virtual view combining customer details with credit card transaction data.
-- Author: [Mushfikur Rahman]
-- Date: [09-06-2025]
***************************************************************************************************/

/***********************************************
-- SECTION 1: CREATE OR REPLACE VIRTUAL VIEW
-- Combines customer demographic data with transaction data
***********************************************/

IF OBJECT_ID('Virtual_Table', 'V') IS NOT NULL 
    DROP VIEW Virtual_Table;
GO

CREATE VIEW Virtual_Table AS 
SELECT
    c.Client_Num,
    cd.Education_Level,
    cd.Gender,
    cd.Marital_Status,
    cd.state_cd,
    c.Exp_Type,
    cd.Income,
    cd.Customer_Job,
    c.Customer_Acq_Cost,
    c.Use_Chip,
    c.Qtr,
    c.Card_Category,
    c.Annual_Fees,
    c.Total_Trans_Amt,
    c.Interest_Earned,
    -- Calculate total revenue per client as sum of fees, transactions, and interest
    (c.Annual_Fees + c.Total_Trans_Amt + c.Interest_Earned) AS revenue
FROM 
    customer_details cd
JOIN 
    credit_card_details c ON cd.Client_Num = c.Client_Num;


/***********************************************
-- SECTION 2: CUSTOMER KPIs
***********************************************/

-- 2.1 Total Revenue (sum of revenue across all customers)
SELECT 
    SUM(revenue) AS [Total Revenue]
FROM 
    Virtual_Table;

-- 2.2 Total Interest Earned
SELECT 
    SUM(Interest_Earned) AS [Total Interest]
FROM 
    Virtual_Table;

-- 2.3 Total Income of all customers (from customer_details table)
SELECT 
    SUM(Income) AS [Total Income]
FROM 
    customer_details;

-- 2.4 Average Customer Satisfaction Score (CSS)
SELECT 
    CAST(AVG(CAST(Cust_Satisfaction_Score AS DECIMAL(10, 2))) AS DECIMAL(10, 2)) AS CSS
FROM 
    customer_details;


/***********************************************
-- SECTION 3: CUSTOMER DEMOGRAPHIC ANALYSIS
***********************************************/

-- 3.1 Customer Age Group Distribution by Gender
SELECT
    CASE
        WHEN Customer_Age BETWEEN 20 AND 30 THEN '20-30'
        WHEN Customer_Age BETWEEN 31 AND 40 THEN '31-40'
        WHEN Customer_Age BETWEEN 41 AND 50 THEN '41-50'
        WHEN Customer_Age BETWEEN 51 AND 60 THEN '51-60'
        WHEN Customer_Age BETWEEN 61 AND 70 THEN '61-70'
        WHEN Customer_Age > 70 THEN '70+'
        ELSE 'Other'
    END AS [Age Group],
    Gender,
    COUNT(*) AS [People Count]
FROM 
    customer_details
GROUP BY
    Gender,
    CASE
        WHEN Customer_Age BETWEEN 20 AND 30 THEN '20-30'
        WHEN Customer_Age BETWEEN 31 AND 40 THEN '31-40'
        WHEN Customer_Age BETWEEN 41 AND 50 THEN '41-50'
        WHEN Customer_Age BETWEEN 51 AND 60 THEN '51-60'
        WHEN Customer_Age BETWEEN 61 AND 70 THEN '61-70'
        WHEN Customer_Age > 70 THEN '70+'
        ELSE 'Other'
    END
ORDER BY 
    [Age Group], Gender;


/***********************************************
-- SECTION 4: REVENUE ANALYSIS BY CUSTOMER ATTRIBUTES
***********************************************/

-- 4.1 Revenue, Transaction Amount, and Income by Customer Job
SELECT 
    Customer_Job, 
    SUM(revenue) AS [Total Revenue], 
    SUM(Total_Trans_Amt) AS [Total Transaction Amount], 
    SUM(Income) AS [Total Income]
FROM 
    Virtual_Table
GROUP BY 
    Customer_Job
ORDER BY 
    [Total Revenue] DESC;

-- 4.2 Top 5 States by Total Revenue with Gender Breakdown
SELECT
    v.state_cd,
    v.Gender,
    SUM(v.revenue) AS [Gender Revenue]
FROM 
    Virtual_Table v
JOIN 
    (
        SELECT TOP 5 state_cd
        FROM Virtual_Table
        GROUP BY state_cd
        ORDER BY SUM(revenue) DESC
    ) top_states ON v.state_cd = top_states.state_cd
GROUP BY 
    v.state_cd, v.Gender
ORDER BY 
    v.state_cd, v.Gender;

-- 4.3 Revenue by Marital Status and Gender
SELECT 
    Marital_Status, 
    SUM(revenue) AS [Total Revenue], 
    Gender
FROM 
    Virtual_Table
GROUP BY 
    Marital_Status, Gender
ORDER BY 
    [Total Revenue] DESC;

-- 4.4 Revenue by Income Groups and Gender
SELECT
    CASE
        WHEN Income < 10000 THEN 'Very Low'
        WHEN Income >= 10000 AND Income < 30000 THEN 'Low'
        WHEN Income >= 30000 AND Income < 60000 THEN 'Lower-Middle'
        WHEN Income >= 60000 AND Income < 100000 THEN 'Middle'
        WHEN Income >= 100000 AND Income < 150000 THEN 'Upper-Middle'
        WHEN Income >= 150000 THEN 'High'
    END AS Income_Group,
    Gender, 
    SUM(revenue) AS [Total Revenue]
FROM 
    Virtual_Table
GROUP BY
    Gender,
    CASE
        WHEN Income < 10000 THEN 'Very Low'
        WHEN Income >= 10000 AND Income < 30000 THEN 'Low'
        WHEN Income >= 30000 AND Income < 60000 THEN 'Lower-Middle'
        WHEN Income >= 60000 AND Income < 100000 THEN 'Middle'
        WHEN Income >= 100000 AND Income < 150000 THEN 'Upper-Middle'
        WHEN Income >= 150000 THEN 'High'
    END
ORDER BY 
    Income_Group DESC;

-- 4.5 Revenue by Education Level and Gender
SELECT 
    Education_Level, 
    SUM(revenue) AS [Total Revenue], 
    Gender
FROM 
    Virtual_Table
GROUP BY 
    Education_Level, Gender
ORDER BY 
    Education_Level;