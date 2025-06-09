
# 💳 Credit Card Transaction KPI Report

**Database Used:** `CreditCard-db`  
**Author:** *Mushfikur Rahman*  
**Date:** *09-06-2025*  
**Description:**  
This report calculates key performance indicators (KPIs) related to credit card transactions. It includes total revenue, interest, transaction volumes, and revenue breakdowns across various dimensions. A reusable virtual view is also created for extended analysis.

---

## 📊 SECTION 1: OVERALL KPI METRICS

### 1. Total Revenue = Annual Fees + Total Transaction Amount + Interest Earned
```sql
SELECT 
    SUM(Annual_Fees + Total_Trans_Amt + Interest_Earned) AS [Total Revenue]
FROM 
    credit_card_details;
```

### 2. Total Interest Earned from Credit Card Transactions
```sql
SELECT 
    SUM(Interest_Earned) AS [Total Interest] 
FROM 
    credit_card_details;
```

### 3. Total Transaction Amount
```sql
SELECT 
    SUM(Total_Trans_Amt) AS [Transaction Amount]
FROM 
    credit_card_details;
```

---

## 💼 SECTION 2: REVENUE BREAKDOWN BY CARD CATEGORY

### Revenue, Interest, and Annual Fees by Each Card Category
```sql
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
```

---

## 🧱 SECTION 3: CREATE A REUSABLE VIRTUAL VIEW

This view joins customer and transaction details and precomputes revenue for further analysis.

### Drop View if Already Exists
```sql
IF OBJECT_ID('Virtual_Table', 'V') IS NOT NULL 
    DROP VIEW Virtual_Table;
GO
```

### Create Unified View with Customer and Transaction Data
```sql
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
```

---

## 📈 SECTION 4: ANALYSIS USING THE VIRTUAL VIEW

### 4.1 Revenue by Expenditure Type
```sql
SELECT 
    Exp_Type,
    SUM(revenue) AS [Total Revenue]
FROM 
    Virtual_Table
GROUP BY 
    Exp_Type
ORDER BY 
    [Total Revenue] DESC;
```

### 4.2 Revenue by Education Level
```sql
SELECT 
    Education_Level,
    SUM(revenue) AS [Total Revenue]
FROM 
    Virtual_Table
GROUP BY 
    Education_Level
ORDER BY 
    [Total Revenue] DESC;
```

### 4.3 Revenue by Customer Job
```sql
SELECT 
    Customer_Job, 
    SUM(revenue) AS [Total Revenue]
FROM 
    Virtual_Table
GROUP BY 
    Customer_Job
ORDER BY 
    [Total Revenue] DESC;
```

### 4.4 Customer Acquisition Cost by Card Category
```sql
SELECT 
    Card_Category, 
    SUM(Customer_Acq_Cost) AS [Acquisition Cost]
FROM 
    Virtual_Table
GROUP BY 
    Card_Category
ORDER BY 
    [Acquisition Cost] DESC;
```

### 4.5 Revenue by Use of Chip (Yes/No)
```sql
SELECT 
    Use_Chip, 
    SUM(revenue) AS [Total Revenue]
FROM 
    Virtual_Table
GROUP BY 
    Use_Chip
ORDER BY 
    [Total Revenue] DESC;
```

### 4.6 Revenue and Average Revenue by Quarter
```sql
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
```

---

*End of Report*
