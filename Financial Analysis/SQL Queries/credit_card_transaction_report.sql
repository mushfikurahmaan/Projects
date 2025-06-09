USE [CreditCard-db];
GO

/***************************************************************************************************
-- CREDIT CARD TRANSACTION KPI REPORT
-- Description: This script calculates key performance indicators (KPIs) related to credit card 
   transactions, such as total revenue, interest, transaction amounts, and revenue breakdowns 
   by various dimensions using a virtual view.
-- Author: [Mushfikur Rahman]
-- Date: [09-06-2025]
***************************************************************************************************/


/***********************************
-- SECTION 1: OVERALL KPI METRICS
************************************/

-- 1. Total Revenue = Annual Fees + Total Transaction Amount + Interest Earned
SELECT 
    SUM(Annual_Fees + Total_Trans_Amt + Interest_Earned) AS [Total Revenue]
FROM 
    credit_card_details;

-- 2. Total Interest Earned from credit card transactions
SELECT 
    SUM(Interest_Earned) AS [Total Interest] 
FROM 
    credit_card_details;

-- 3. Total Transaction Amount
SELECT 
    SUM(Total_Trans_Amt) AS [Transaction Amount]
FROM 
    credit_card_details;


/***********************************************************
-- SECTION 2: REVENUE BREAKDOWN BY CARD CATEGORY
************************************************************/

-- Revenue, Interest, and Annual Fees by each Card Category
SELECT 
    Card_Category, 
    SUM(Annual_Fees + Total_Trans_Amt + Interest_Earned) AS [Revenue], 
    SUM(Interest_Earned) AS [Interest Earned], 
    SUM(Annual_Fees) AS [Annual Fees]
FROM 
    credit_card_details
GROUP BY 
    Card_Category
ORDER BY 
    [Revenue] DESC;


/*****************************************************
-- SECTION 3: CREATE A REUSABLE VIRTUAL VIEW
-- This view joins customer and transaction details 
-- and precomputes revenue for further analysis.
******************************************************/

-- Drop view if it already exists
IF OBJECT_ID('Virtual_Table', 'V') IS NOT NULL 
    DROP VIEW Virtual_Table;
GO

-- Create a unified view with customer and transaction data
CREATE VIEW Virtual_Table AS 
SELECT
    c.Client_Num,
    cd.Education_Level,
    cd.Gender,
    cd.state_cd,
    c.Exp_Type,
    cd.Customer_Job,
    c.Customer_Acq_Cost,
    c.Use_Chip,
    c.Qtr,
    c.Card_Category,
    c.Annual_Fees,
    c.Total_Trans_Amt,
    c.Interest_Earned,
    (c.Annual_Fees + c.Total_Trans_Amt + c.Interest_Earned) AS revenue
FROM 
    customer_details cd
JOIN 
    credit_card_details c ON cd.Client_Num = c.Client_Num;


/***********************************************************
-- SECTION 4: ANALYSIS USING THE VIRTUAL VIEW
************************************************************/

-- 4.1 Revenue by Expenditure Type
SELECT 
    Exp_Type,
    SUM(revenue) AS [Total Revenue]
FROM 
    Virtual_Table
GROUP BY 
    Exp_Type
ORDER BY 
    [Total Revenue] DESC;

-- 4.2 Revenue by Education Level
SELECT 
    Education_Level,
    SUM(revenue) AS [Total Revenue]
FROM 
    Virtual_Table
GROUP BY 
    Education_Level
ORDER BY 
    [Total Revenue] DESC;

-- 4.3 Revenue by Customer Job
SELECT 
    Customer_Job, 
    SUM(revenue) AS [Total Revenue]
FROM 
    Virtual_Table
GROUP BY 
    Customer_Job
ORDER BY 
    [Total Revenue] DESC;

-- 4.4 Customer Acquisition Cost by Card Category
SELECT 
    Card_Category, 
    SUM(Customer_Acq_Cost) AS [Acquisition Cost]
FROM 
    Virtual_Table
GROUP BY 
    Card_Category
ORDER BY 
    [Acquisition Cost] DESC;

-- 4.5 Revenue by Use of Chip (Yes/No)
SELECT 
    Use_Chip, 
    SUM(revenue) AS [Total Revenue]
FROM 
    Virtual_Table
GROUP BY 
    Use_Chip
ORDER BY 
    [Total Revenue] DESC;

-- 4.6 Revenue and Average Revenue by Quarter
SELECT 
    Qtr,
    SUM(revenue) AS [Total Revenue],
    AVG(revenue) AS [Average Revenue]
FROM 
    Virtual_Table
GROUP BY 
    Qtr
ORDER BY 
    Qtr;