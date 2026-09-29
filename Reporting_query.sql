--4th Task

--Loan Application
INSERT INTO Loans
(
    CustomerId,
    PrincipalAmount,
    InterestRate,
    TenureMonths,
    StartDate,
    Status
)
VALUES
(7, 100000.00, 10.00, 3, '2026-05-10', 'Completed')

--Loan Approval

UPDATE Loans
SET Status = 'Approved'
WHERE CustomerId = 7
    AND Status = 'Completed'

UPDATE Loans
SET Status = 'Pending'
WHERE CustomerId = 9

--Loan Repayment

INSERT INTO LoanRepayments
(
    LoanId,
    Amount,
    DueDate,
    PaidDate,
    Status
)
VALUES
(7, 100000.00, '2026-02-15', '2026-08-09', 'Pending')

--Calculate Outstanding Balance

SELECT 
    l.LoanId,
    l.CustomerId,
    l.principalAmount - r.Amount AS OutstandingBalance,
    r.Amount AS TotalPaid
FROM Loans l
LEFT JOIN LoanRepayments r
      ON l.LoanId = r.LoanId

--Overdue Loan

SELECT
    l.LoanId,
    l.CustomerId,
    r.RepaymentId,
    r.DueDate,
    r.Amount,
    r.Status
FROM Loans l
JOIN LoanRepayments r
    ON l.LoanId = r.LoanId
WHERE r.Status = 'Overdue'


--Repayment History

SELECT
    c.CustomerId,
    c.FirstName,
    c.LastName,
    l.LoanId,
    l.PrincipalAmount,
    l.PrincipalAmount - r.Amount AS AmountOwed,
    r.Amount AS TotalPaid
FROM Customers c
JOIN Loans l
    ON c.CustomerId = l.CustomerId
LEFT JOIN LoanRepayments r
    ON l.LoanId = r.LoanId
WHERE r.Status IN('paid', 'Overdue', 'Pending')


--6th Task
--CTE Requirement

WITH AccountTransactionSummary AS
(
    SELECT
        AccountId,

        SUM(CASE
                WHEN TransactionType = 'Deposit'
                THEN Amount
                ELSE 0
            END) AS TotalDeposits,

        SUM(CASE
                WHEN TransactionType = 'Withdrawal'
                THEN Amount
                ELSE 0
            END) AS TotalWithdrawals,

        COUNT(TransactionId) AS NumberOfTransactions

    FROM Transactions
    GROUP BY AccountId
)

SELECT
    a.AccountId,
    a.AccountNumber,
    ats.TotalDeposits,
    ats.TotalWithdrawals,
    ats.NumberOfTransactions,
    a.Balance AS CurrentBalance

FROM Accounts a

LEFT JOIN AccountTransactionSummary ats
    ON a.AccountId = ats.AccountId

--7th Task
--Window Funtion Requiremant

WITH MonthlyCustomerTransactions AS
(
    SELECT
        c.CustomerId,
        c.FirstName,
        c.LastName,

        YEAR(t.TransactionDate) AS TransactionYear,
        MONTH(t.TransactionDate) AS TransactionMonth,

        SUM(t.Amount) AS TransactionVolume,
        COUNT(t.TransactionId) AS TransactionCount

    FROM Customers c
    JOIN Accounts a
        ON c.CustomerId = a.CustomerID

    JOIN Transactions t
        ON a.AccountID = t.AccountId

    GROUP BY
        c.CustomerId,
        c.FirstName,
        c.LastName,
        YEAR(t.TransactionDate),
        MONTH(t.TransactionDate)
)

SELECT
    CustomerId,
    FirstName,
    LastName,
    TransactionYear,
    TransactionMonth,
    TransactionVolume,
    TransactionCount,

    ROW_NUMBER() OVER
    (
        PARTITION BY TransactionYear, TransactionMonth
        ORDER BY TransactionVolume DESC
    ) AS RowNumber,

    RANK() OVER
    (
        PARTITION BY TransactionYear, TransactionMonth
        ORDER BY TransactionVolume DESC
    ) AS TransactionRank,

    DENSE_RANK() OVER
    (
        PARTITION BY TransactionYear, TransactionMonth
        ORDER BY TransactionVolume DESC
    ) AS DenseTransactionRank,

    LAG(TransactionVolume) OVER
    (
        PARTITION BY CustomerId
        ORDER BY TransactionYear, TransactionMonth
    ) AS PreviousMonthVolume

FROM MonthlyCustomerTransactions

ORDER BY
    TransactionYear,
    TransactionMonth,
    TransactionRank