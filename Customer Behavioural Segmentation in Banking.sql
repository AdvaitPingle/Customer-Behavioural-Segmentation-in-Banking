Select * From bank_transactions

SELECT TOP 10 * 
FROM bank_transactions;

-- Next Step: Checking for Missing Data
-- Now that we’ve validated the structure, let’s identify if there are any null or invalid values in the critical columns like , , , and . Run the following query:
SELECT 
    COUNT(*) AS TotalRows,
    SUM(CASE WHEN TransactionAmount_INR IS NULL THEN 1 ELSE 0 END) AS NullTransactionAmount,
    SUM(CASE WHEN CustAccountBalance IS NULL THEN 1 ELSE 0 END) AS NullAccountBalance,
    SUM(CASE WHEN CustomerDOB IS NULL THEN 1 ELSE 0 END) AS NullCustomerDOB,
    SUM(CASE WHEN CustLocation IS NULL THEN 1 ELSE 0 END) AS NullCustLocation,
    SUM(CASE WHEN CustGender IS NULL THEN 1 ELSE 0 END) AS NullCustGender
FROM bank_transactions;

-- Excluding Records with Missing Values:
-- For critical columns like  and , you can exclude rows with missing values in your queries if they’re few compared to the dataset size.

SELECT * 
FROM bank_transactions
WHERE CustAccountBalance IS NOT NULL 
  AND CustomerDOB IS NOT NULL;


  -- Basic Data Exploration
  -- Now that the structure is validated, let’s start with queries that derive basic customer demographics. First, segment customers by their age groups.
-- Query: Derive Age and Age Segments
-- Here’s the query to calculate age from  and classify customers into meaningful age groups:

SELECT 
    CustomerID,
    DATEDIFF(YEAR, CustomerDOB, GETDATE()) AS Age,
    CASE 
        WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) < 25 THEN 'Youth'
        WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) BETWEEN 25 AND 40 THEN 'Young Adult'
        WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) BETWEEN 41 AND 60 THEN 'Middle Aged'
        ELSE 'Senior'
    END AS AgeGroup
FROM bank_transactions;

-- Analyzing Financial Behavior Based on Age Groups
-- Now that we have segmented customers by age, the next step is to explore their financial behavior, specifically account balances and transaction amounts, for each age group.
-- Query: Average Account Balance and Total Transactions by Age Group
-- This query will calculate the average account balance and total transaction amounts for each age group:

SELECT 
    CASE 
        WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) < 25 THEN 'Youth'
        WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) BETWEEN 25 AND 40 THEN 'Young Adult'
        WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) BETWEEN 41 AND 60 THEN 'Middle Aged'
        ELSE 'Senior'
    END AS AgeGroup,
    COUNT(TransactionID) AS TotalTransactions,
    AVG(CustAccountBalance) AS AvgAccountBalance,
    SUM(TransactionAmount_INR) AS TotalTransactionAmount
FROM bank_transactions
GROUP BY 
    CASE 
        WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) < 25 THEN 'Youth'
        WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) BETWEEN 25 AND 40 THEN 'Young Adult'
        WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) BETWEEN 41 AND 60 THEN 'Middle Aged'
        ELSE 'Senior'
    END;



-- Next Query Let’s now explore location-based trends to understand regional financial behavior:
-- Query:

SELECT 
    CustLocation,
    COUNT(TransactionID) AS TotalTransactions,
    SUM(TransactionAmount_INR) AS TotalSpending,
    AVG(CustAccountBalance) AS AvgAccountBalance
FROM bank_transactions
GROUP BY CustLocation
ORDER BY TotalSpending DESC;

-- Let’s move to analyze gender-based trends to understand if there are any behavioral differences in transactions and account balances based on CustGender.

SELECT 
    CustGender,
    COUNT(TransactionID) AS TotalTransactions,
    SUM(TransactionAmount_INR) AS TotalSpending,
    AVG(CustAccountBalance) AS AvgAccountBalance
FROM bank_transactions
GROUP BY CustGender;

-- Let’s move forward by combining age and gender to analyze how different demographics behave. Here’s the next query:

SELECT 
    CASE 
        WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) < 25 THEN 'Youth'
        WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) BETWEEN 25 AND 40 THEN 'Young Adult'
        WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) BETWEEN 41 AND 60 THEN 'Middle Aged'
        ELSE 'Senior'
    END AS AgeGroup,
    CustGender,
    COUNT(TransactionID) AS TotalTransactions,
    SUM(TransactionAmount_INR) AS TotalSpending,
    AVG(CustAccountBalance) AS AvgAccountBalance
FROM bank_transactions
GROUP BY 
    CASE 
        WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) < 25 THEN 'Youth'
        WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) BETWEEN 25 AND 40 THEN 'Young Adult'
        WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) BETWEEN 41 AND 60 THEN 'Middle Aged'
        ELSE 'Senior'
    END,
    CustGender
ORDER BY AgeGroup, CustGender;


-- Now, let’s focus on transaction patterns by location and age group to uncover regional insights across demographics.

SELECT 
    CustLocation,
    CASE 
        WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) < 25 THEN 'Youth'
        WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) BETWEEN 25 AND 40 THEN 'Young Adult'
        WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) BETWEEN 41 AND 60 THEN 'Middle Aged'
        ELSE 'Senior'
    END AS AgeGroup,
    COUNT(TransactionID) AS TotalTransactions,
    SUM(TransactionAmount_INR) AS TotalSpending,
    AVG(CustAccountBalance) AS AvgAccountBalance
FROM bank_transactions
GROUP BY CustLocation,
         CASE 
            WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) < 25 THEN 'Youth'
            WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) BETWEEN 25 AND 40 THEN 'Young Adult'
            WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) BETWEEN 41 AND 60 THEN 'Middle Aged'
            ELSE 'Senior'
         END
ORDER BY CustLocation, AgeGroup;


-- Addressing Data Gaps
-- Cleanup for Missing Locations:
-- The  location entries (e.g., Middle Aged with 123 transactions) should be investigated for incomplete data.

SELECT *
FROM bank_transactions
WHERE CustLocation IS NULL;

-- Next Steps Let’s refine the analysis to address missing locations and understand their impact. Query: Investigate Missing Locations
-- Run this query to explore more details about rows with  locations:

SELECT 
    CustomerID, 
    CustomerDOB, 
    CustGender, 
    CustAccountBalance, 
    TransactionDate, 
    TransactionAmount_INR
FROM bank_transactions
WHERE CustLocation IS NULL;

-- Action Plan Let’s proceed with these steps:
-- Identify Proportions
-- Calculate what percentage of rows in your dataset have  locations to determine their overall impact.

SELECT 
    COUNT(*) AS TotalRows,
    SUM(CASE WHEN CustLocation IS NULL THEN 1 ELSE 0 END) AS NullLocationRows,
    (SUM(CASE WHEN CustLocation IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS NullLocationPercentage
FROM bank_transactions;

-- Demographic Insights for Missing Locations:
-- Explore demographic patterns among customers with  locations (e.g., by gender, age group).

SELECT 
    CustGender,
    CASE 
        WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) < 25 THEN 'Youth'
        WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) BETWEEN 25 AND 40 THEN 'Young Adult'
        WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) BETWEEN 41 AND 60 THEN 'Middle Aged'
        ELSE 'Senior'
    END AS AgeGroup,
    COUNT(*) AS TotalTransactions,
    AVG(CustAccountBalance) AS AvgAccountBalance,
    SUM(TransactionAmount_INR) AS TotalSpending
FROM bank_transactions
WHERE CustLocation IS NULL
GROUP BY CustGender,
         CASE 
             WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) < 25 THEN 'Youth'
             WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) BETWEEN 25 AND 40 THEN 'Young Adult'
             WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) BETWEEN 41 AND 60 THEN 'Middle Aged'
             ELSE 'Senior'
         END;

-- Analyze Transaction Patterns Over Time
-- Query: Peak Days for Transactions
-- Let’s identify which day of the week drives the most transactions:

SELECT 
    DATENAME(WEEKDAY, TransactionDate) AS DayOfWeek,
    COUNT(TransactionID) AS TotalTransactions,
    SUM(TransactionAmount_INR) AS TotalSpending
FROM bank_transactions
GROUP BY DATENAME(WEEKDAY, TransactionDate)
ORDER BY TotalTransactions DESC;

-- We’ve identified daily trends, so now let’s refine the time-based analysis by investigating:
-- Hourly Patterns: When are transactions most frequent during the day?
-- Monthly Trends: Which months show higher financial activity?

SELECT 
    DATEPART(HOUR, TransactionTime) AS HourOfDay,
    COUNT(TransactionID) AS TotalTransactions,
    SUM(TransactionAmount_INR) AS TotalSpending
FROM bank_transactions
GROUP BY DATEPART(HOUR, TransactionTime)
ORDER BY HourOfDay;

