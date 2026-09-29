CREATE TABLE Customers
(
     CustomerID INT IDENTITY(1,1) PRIMARY KEY,
     FirstName NVARCHAR(50) NOT NULL,
     LastName NVARCHAR(50) NOT NULL,
     Email VARCHAR(100) UNIQUE NOT NULL,
     Phone INT,
     DateofBirth DATE,
     KYCstatus VARCHAR(50) CHECK(KYCstatus IN ('Pending', 'Verified', 'Rejected')),
     CreatedAt DATETIME NOT NULL
)

CREATE TABLE Accounts
(
    AccountID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL FOREIGN KEY (CustomerId)
        REFERENCES Customers(CustomerId),
    AccountNumber VARCHAR(20) UNIQUE NOT NULL,
    AccountType VARCHAR(20) NOT NULL,
    Currency CHAR(3) NOT NULL DEFAULT 'NGN',
    Balance DECIMAL(18,2) NOT NULL DEFAULT '0.00',
    Status VARCHAR(20) NOT NULL DEFAULT 'Active',
    CreatedAt DATETIME NOT NULL
)

CREATE TABLE Transactions
(
    TransactionId INT IDENTITY(1,1) PRIMARY KEY,
    AccountId INT NOT NULL FOREIGN KEY REFERENCES Accounts(AccountId),
    TransactionType VARCHAR(20) NOT NULL CHECK(TransactionType IN ('Deposit', 'Withdrawal', 'Transfer', 'Payment')),
    Amount DECIMAL(18,2) NOT NULL,
    Currency CHAR(3) NOT NULL DEFAULT 'NGN',
    Reference VARCHAR(100) NOT NULL,
    Status VARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK (Status IN ('Pending', 'Approved')), 
    TransactionDate DATETIME NOT NULL
)

CREATE TABLE Loans 
(
    LoanId INT IDENTITY(1,1) PRIMARY KEY,
    CustomerId INT NOT NULL FOREIGN KEY (CustomerId)
        REFERENCES Customers(CustomerId),
    PrincipalAmount DECIMAL(18,2) NOT NULL CHECK (PrincipalAmount >= 0),
    InterestRate DECIMAL(5,2) NOT NULL  CHECK (InterestRate >= 0),
    TenureMonths INT NOT NULL CHECK (TenureMonths > 0),
    StartDate DATE NOT NULL,
    Status VARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK (Status IN
        ('Pending', 'Approved', 'Active', 'Completed', 'Defaulted', 'Rejected')),
)

CREATE TABLE LoanRepayments
(
    RepaymentId INT IDENTITY(1,1) PRIMARY KEY,
    LoanId INT NOT NULL FOREIGN KEY (LoanId)
        REFERENCES Loans(LoanId),
    Amount DECIMAL(18,2) NOT NULL CHECK (Amount > 0),
    DueDate DATE NOT NULL,
    PaidDate DATE NULL,
    Status VARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK(Status IN ('Pending', 'Paid', 'Overdue', 'Partial')),
)

CREATE TABLE Beneficiaries
(
    BeneficiaryId INT IDENTITY(1,1) PRIMARY KEY,
    CustomerId INT NOT NULL FOREIGN KEY (CustomerId)
        REFERENCES Customers(CustomerId),
    AccountNumber VARCHAR(20) NOT NULL,
    BankCode VARCHAR(20) NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Status VARCHAR(20) NOT NULL DEFAULT 'Active' CHECK (Status IN ('Active','Blocked')),
)

CREATE TABLE AuditLogs
(
    AuditId INT IDENTITY(1,1) PRIMARY KEY,
    EntityName VARCHAR(50) NOT NULL,
    EntityId INT NOT NULL,
    Action VARCHAR(50) NOT NULL,
    OldValue VARCHAR(100) NULL,
    NewValue VARCHAR(100) NULL,
    CreatedAt DATETIME NOT NULL 
);