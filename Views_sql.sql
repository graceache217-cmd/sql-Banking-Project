--9th Task
--VW_CustomerAccounts

SELECT
    c.CustomerId,
    c.FirstName,
    c.LastName,
    c.Email,
    c.Phone,
    a.AccountId,
    a.AccountNumber,
    a.AccountType,
    a.Currency,
    a.Balance,
    a.Status,
    a.CreatedAt AS AccountCreatedAt
FROM Customers c
JOIN Accounts a
    ON c.CustomerId = a.CustomerID

--VW_CustomerTransactionSummary

SELECT
    c.CustomerId,
    c.FirstName,
    c.LastName,

    COUNT(t.TransactionId) AS TransactionCount,

    SUM(CASE
            WHEN t.TransactionType = 'Deposit'
            THEN t.Amount
            ELSE 0
        END
    ) AS TotalDeposits,

    SUM(CASE
            WHEN t.TransactionType = 'Withdrawal'
            THEN t.Amount
            ELSE 0
        END
    ) AS TotalWithdrawals

FROM Customers c
JOIN Accounts a
    ON c.CustomerId = a.CustomerID
LEFT JOIN Transactions t
    ON a.AccountID = t.AccountId

GROUP BY
    c.CustomerId,
    c.FirstName,
    c.LastName

--VW_ActiveLoans

SELECT
    l.CustomerId,
    c.FirstName,
    c.LastName,
    c.Phone,
    l.PrincipalAmount,
    l.InterestRate,
    l.TenureMonths,
    l.Status,
    l.StartDate,
    c.CreatedAt
FROM Loans l
JOIN Customers c
    ON l.CustomerId = c.CustomerId
WHERE l.Status = 'Active'

--VW_OverdueLoans

SELECT
    l.LoanId,
    c.CustomerId,
    c.FirstName,
    c.LastName,
    l.PrincipalAmount,
    r.Status,
    SUM(r.Amount) AS TotalPaid,

    l.PrincipalAmount -r.Amount AS OutstandingBalance,

    r.DueDate

FROM Loans l

INNER JOIN Customers c
    ON l.CustomerId = c.CustomerId

LEFT JOIN LoanRepayments r
    ON l.LoanId = r.LoanId

WHERE r.Status = 'Overdue'

GROUP BY
    l.LoanId,
    c.CustomerId,
    c.FirstName,
    c.LastName,
    l.principalAmount,
    r.Amount,
    r.DueDate,
    r.Status

--CustomerFinancialSummary

SELECT
    c.CustomerId,
    c.FirstName,
    c.LastName,
    a.Balance, 
    t.TransactionId AS NumberOfTransactions,
   
        SUM(CASE
                WHEN t.TransactionType = 'Deposit'
                THEN t.Amount
                ELSE 0
            END
        ), 0
    AS TotalDeposits,

        SUM(CASE
                WHEN t.TransactionType = 'Withdrawal'
                THEN t.Amount
                ELSE 0
            END
        ), 0
    AS TotalWithdrawals,

        (
            SELECT 
            l.PrincipalAmount
            FROM Loans l
            WHERE l.CustomerId = c.CustomerId
              AND l.Status IN ('Approved', 'Active')
        ), 0
   AS TotalAmount

FROM Customers c
JOIN Accounts a
    ON c.CustomerId = a.CustomerId
LEFT JOIN Transactions t
    ON a.AccountId = t.AccountId

GROUP BY
    c.CustomerId,
    c.FirstName,
    c.LastName,
    a.Balance,
    t.TransactionId