INSERT INTO Customers
(
    FirstName,
    LastName,
    Email,
    Phone,
    DateOfBirth,
    KycStatus,
    CreatedAt
)
VALUES
('Grace', 'Adeyemi', 'grace@example.com', '08012345678', '1998-05-12', 'Verified', '2020-05-02'),
('John', 'Okafor', 'john@example.com', '08023456789', '1995-08-20', 'Verified', '2022-07-12'),
('Mary', 'Bello', 'mary@example.com', '08034567890', '2000-02-15', 'Pending', '2020-01-06'),
('David', 'Adebayo', 'david@example.com', '08045678901', '1997-11-10', 'Verified', '2020-10-15');

INSERT INTO Accounts
(
    CustomerId,
    AccountNumber,
    AccountType,
    Currency,
    Balance,
    Status,
    CreatedAt
)
VALUES
(6, '1000000001', 'Savings', 'NGN', 250000.00, 'Active', '2020-05-02 09:00' ),
(6, '1000000002', 'Current', 'NGN', 500000.00, 'Active', '2020-05-02 09:45'),
(7, '1000000003', 'Savings', 'NGN', 150000.00, 'Active', '2022-07-12 11:15' ),
(8, '1000000004', 'Savings', 'NGN', 75000.00, 'Active', '2020-01-06 12:00'),
(9, '1000000005', 'Current', 'NGN', 300000.00, 'Active', '2020-10-15 14:30')

INSERT INTO Transactions
(
    AccountId,
    TransactionType,
    Amount,
    Currency,
    Reference,
    Status,
    TransactionDate
)
VALUES
(9, 'Deposit', 100000.00, 'NGN', 'TXN001', 'pending', '2020-05-02 10:00' ),
(10, 'Withdrawal', 25000.00, 'NGN', 'TXN002', 'Approved', '2020-06-02 13:15'),
(11, 'Deposit', 200000.00, 'NGN', 'TXN003', 'Approved', '2022-08-10 12:00'),
(12, 'Transfer', 50000.00, 'NGN', 'TXN004', 'Approved', '2020-01-16 14:10'),
(13, 'Payment', 15000.00, 'NGN', 'TXN005', 'Pending', '2020-12-12 10:00')

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
(6, 1000000.00, 12.50, 12, '2026-01-15', 'Active'),
(7, 500000.00, 10.00, 6, '2026-02-01', 'Active'),
(9, 750000.00, 15.00, 18, '2026-03-10', 'Approved')

INSERT INTO LoanRepayments
(
    LoanId,
    Amount,
    DueDate,
    PaidDate,
    Status
)
VALUES
(7, 90000.00, '2026-02-15', '2026-02-14', 'Paid'),
(7, 90000.00, '2026-03-15', '2026-03-15', 'Paid'),
(8, 90000.00, '2026-04-15', NULL, 'Overdue'),
(9, 90000.00, '2026-03-01', '2026-03-01', 'Paid'),
(9, 90000.00, '2026-04-01', NULL, 'Pending')

INSERT INTO Beneficiaries
(
    CustomerId,
    AccountNumber,
    BankCode,
    Name,
    Status
)
VALUES
(7, '2000000001', '058', 'John Okafor', 'Active'),
(8, '2000000002', '033', 'Mary Bello', 'Active'),
(9, '2000000003', '044', 'David Adebayo', 'Active'),
(6, '2000000004', '058', 'Grace Adeyemi', 'Blocked')

INSERT INTO AuditLogs
(
    EntityName,
    EntityId,
    Action,
    OldValue,
    NewValue,
    CreatedAt
)
VALUES
('Customers', 1, 'KYC_UPDATE',
 'Pending',
 'Verified', '2024-11-06 17:00'),

('Accounts', 1, 'BALANCE_UPDATE',
 '150000.00',
 '250000.00', '2024-07-16 06:15'), 
 
 ('Loans', 1, 'STATUS_UPDATE', 
 'Pending', 'Active', '2024-10-10 12:00')