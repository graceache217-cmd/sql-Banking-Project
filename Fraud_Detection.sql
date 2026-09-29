--10th Task
--More Than Five Transactions Within One Minute

USE TABLES;

WITH RapidTransactions AS
(
    SELECT
        t1.TransactionId,
        t1.AccountId,
        t1.TransactionDate,

        (
            SELECT COUNT(*)
            FROM Transactions t2
            WHERE t2.AccountId = t1.AccountId
              AND t2.TransactionDate BETWEEN
                  DATEADD(MINUTE, -1, t1.TransactionDate)
                  AND t1.TransactionDate
        ) AS TransactionCount

    FROM Transactions t1
)

SELECT
    CONCAT(c.FirstName, ' ', c.LastName) AS Customer,
    a.AccountNumber AS Account,
    'Rapid Transactions' AS RiskType,
    r.TransactionCount,
    CASE
        WHEN r.TransactionCount >= 10 THEN 'High'
        ELSE 'Medium'
    END AS RiskLevel

FROM RapidTransactions r

JOIN Accounts a
    ON r.AccountId = a.AccountID
JOIN Customers c
    ON a.CustomerID = c.CustomerId

WHERE r.TransactionCount > 5

ORDER BY r.TransactionCount DESC


--Large Transactions Above A Defined Treshold

SELECT
    a.CustomerID,
    t.AccountId,
    'Large Transaction' AS RiskType,
    1 AS TransactionCount,
    'High' AS RiskLevel,
    t.Amount,
    t.TransactionDate
FROM Transactions t
JOIN Accounts a
    ON t.AccountId = a.AccountID
WHERE t.Amount >= 200000


--Multiple Failed Transactions Followed By A Succeful Transaction

WITH TransactionHistory AS
(
    SELECT
        t.TransactionId,
        t.AccountId,
        t.TransactionDate,
        t.Status,

        LAG(t.Status, 1) OVER
        (
            PARTITION BY t.AccountId
            ORDER BY t.TransactionDate
        ) AS PreviousStatus,

        LAG(t.Status, 2) OVER
        (
            PARTITION BY t.AccountId
            ORDER BY t.TransactionDate
        ) AS PreviousStatus2,

        LAG(t.Status, 3) OVER
        (
            PARTITION BY t.AccountId
            ORDER BY t.TransactionDate
        ) AS PreviousStatus3

    FROM Transactions t
)
SELECT
    a.CustomerID,
    h.AccountId,
    'Failed Transactions Followed By Success' AS RiskType,
    3 AS TransactionCount,
    'High' AS RiskLevel
FROM TransactionHistory h
JOIN Accounts a
    ON h.AccountId = a.AccountID
WHERE h.Status = 'Successful'
  AND h.PreviousStatus = 'Failed'
  AND h.PreviousStatus2 = 'Failed'
  AND h.PreviousStatus3 = 'Failed'


--An Account Transferring Money To Multiple Beneficiaries Within A Short Period

SELECT
    a.CustomerID,
    t.AccountId,
    'Multiple Beneficiaries' AS RiskType,
    COUNT(DISTINCT t.BeneficiaryId)
        AS TransactionCount,
    'High' AS RiskLevel
FROM Transactions t
JOIN Accounts a
    ON t.AccountId = a.AccountID
WHERE t.TransactionType = 'Transfer'
GROUP BY
    a.CustomerID,
    t.AccountId,
    t.TransactionDate
HAVING COUNT(DISTINCT t.BeneficiaryId) = 2
