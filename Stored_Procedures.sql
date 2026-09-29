--8th Task
-- Stored Procedures

--Creat Customer

CREATE OR ALTER PROCEDURE CreateCustomer
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @Email VARCHAR(100),
    @Phone VARCHAR(20),
    @DateOfBirth DATE,
    @KycStatus VARCHAR(20) = 'Pending'
AS
BEGIN
    SET NOCOUNT ON

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
    (
        @FirstName,
        @LastName,
        @Email,
        @Phone,
        @DateOfBirth,
        @KYCStatus,
        GETDATE()
    );

    SELECT SCOPE_IDENTITY() AS CustomerId
END


--Open Account

CREATE OR ALTER PROCEDURE OpenAccount
    @CustomerId INT,
    @AccountNumber VARCHAR(20),
    @AccountType VARCHAR(20),
    @Currency VARCHAR(10) = 'NGN'
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Customers
        WHERE CustomerId = @CustomerId
    )
    BEGIN
        RAISERROR('Customer does not exist.', 16, 1)
        RETURN
    END;

    IF EXISTS
    (
        SELECT 1
        FROM Accounts
        WHERE AccountNumber = @AccountNumber
    )
    BEGIN
        RAISERROR('Account number already exists.', 16, 1)
        RETURN
    END;

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
    (
        @CustomerId,
        @AccountNumber,
        @AccountType,
        @Currency,
        0,
        'Active',
        GETDATE()
    );

    SELECT SCOPE_IDENTITY() AS AccountId
END

--Deposit Money

CREATE OR ALTER PROCEDURE DepositMoney
    @AccountID INT,
    @Amount DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON

    IF @Amount <= 0
    BEGIN
        RAISERROR('Deposit amount must be greater than zero.', 16, 1)
        RETURN
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM Accounts
        WHERE AccountId = @AccountId
    )
    BEGIN
        RAISERROR('Account does not exist.', 16, 1)
        RETURN
    END

    IF EXISTS
    (
        SELECT 1
        FROM Accounts
        WHERE AccountId = @AccountId
        AND Status <> 'Active'
    )
    BEGIN
        RAISERROR('Account is not active.', 16, 1)
        RETURN
    END

    UPDATE Accounts
    SET Balance = Balance + @Amount
    WHERE AccountId = @AccountId;

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
    SELECT
        @AccountId,
        'Deposit',
        @Amount,
        Currency,
        CONCAT('DEP-', NEWID()),
        'Successful',
        GETDATE()
    FROM Accounts
    WHERE AccountId = @AccountId

    END;
    GO


--Withdraw Money

CREATE OR ALTER PROCEDURE WithdrawMoney
    @AccountID INT,
    @Amount DECIMAL(18,2)

 AS
 BEGIN
    SET NOCOUNT ON

    IF @Amount <= 0
    BEGIN
        RAISERROR('Withdrawal amount must be greater than zero.', 16, 1)
        RETURN
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM Accounts
        WHERE AccountID = @AccountID
    )
    BEGIN
        RAISERROR('Account does not exist.', 16, 1)
        RETURN
    END

    IF EXISTS
    (
        SELECT 1
        FROM Accounts
        WHERE AccountID = @AccountID
        AND Status <> 'Active'
    )
    BEGIN
        RAISERROR('Account is not active.', 16, 1)
        RETURN
    END

    IF EXISTS
    (
        SELECT 1
        FROM Accounts
        WHERE AccountID = @AccountID
        AND Balance < @Amount
    )
    BEGIN
        RAISERROR('Insufficient funds.', 16, 1)
        RETURN
    END

    UPDATE Accounts
    SET Balance = Balance - @Amount
    WHERE AccountID = @AccountID

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
    SELECT
        AccountId,
        'Withdrawal',
        @Amount,
        Currency,
        CONCAT('WD-', NEWID()),
        'Successful',
        GETDATE()
    FROM Accounts
    WHERE AccountID = @AccountID
    END;
    GO


--Transfer Money

CREATE OR ALTER PROCEDURE TransferMoney
    @FromAccountId INT,
    @ToAccountId INT,
    @Amount DECIMAL(18,2),
    @BeneficiaryId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

--VALIDATION

        IF @Amount <= 0
            THROW 50001, 'Transfer amount must be greater than zero.', 1;

        IF @FromAccountId = @ToAccountId
            THROW 50002, 'Source and destination accounts cannot be the same.', 1;

        IF NOT EXISTS
        (
            SELECT 1
            FROM Accounts
            WHERE AccountId = @FromAccountId
        )
            THROW 50003, 'Source account does not exist.', 1

        IF NOT EXISTS
        (
            SELECT 1
            FROM Accounts
            WHERE AccountId = @ToAccountId
        )
            THROW 50004, 'Destination account does not exist.', 1

        IF EXISTS
        (
            SELECT 1
            FROM Accounts
            WHERE AccountId = @FromAccountId
            AND Status <> 'Active'
        )
            THROW 50005, 'Source account is not active.', 1

        IF EXISTS
        (
            SELECT 1
            FROM Accounts
            WHERE AccountId = @ToAccountId
            AND Status <> 'Active'
        )
            THROW 50006, 'Destination account is not active.', 1

        IF EXISTS
        (
            SELECT 1
            FROM Accounts
            WHERE AccountId = @FromAccountId
            AND Balance < @Amount
        )
            THROW 50007, 'Insufficient funds.', 1

        IF @BeneficiaryId IS NOT NULL
           AND NOT EXISTS
           (
               SELECT 1
               FROM Beneficiaries
               WHERE BeneficiaryId = @BeneficiaryId
           )
            THROW 50008, 'Beneficiary does not exist.', 1


--TRANSACTION HANDLING

--BEGIN TRANSACTION

        BEGIN TRANSACTION

--DEBIT SORCE ACCOUNT

        UPDATE Accounts
        SET Balance = Balance - @Amount
        WHERE AccountId = @FromAccountId

--CREDIT DESTINATION ACCOUNT

        UPDATE Accounts
        SET Balance = Balance + @Amount
        WHERE AccountId = @ToAccountId

--RECORD DEBIT TRANSACTIONS

        INSERT INTO Transactions
        (
            AccountId,
            BeneficiaryId,
            TransactionType,
            Amount,
            Currency,
            Reference,
            Status,
            TransactionDate
        )
        SELECT
            AccountId,
            @BeneficiaryId,
            'Transfer',
            @Amount,
            Currency,
            CONCAT('TRF-', NEWID()),
            'Successful',
            GETDATE()
        FROM Accounts
        WHERE AccountId = @FromAccountId;

--RECORD CREDIT TRANSACTIONS

        INSERT INTO Transactions
        (
            AccountId,
            BeneficiaryId,
            TransactionType,
            Amount,
            Currency,
            Reference,
            Status,
            TransactionDate
        )
        SELECT
            9,
            @BeneficiaryId,
            'Transfer',
            @Amount,
            Currency,
            CONCAT('TRF-', NEWID()),
            'Successful',
            GETDATE()
        FROM Accounts
        WHERE AccountId = @ToAccountId;

--COMMIT

        COMMIT TRANSACTION;

        SELECT
            'Transfer successful.' AS Message,
            @FromAccountId AS FromAccountId,
            @ToAccountId AS ToAccountId,
            @Amount AS Amount

    END TRY

    BEGIN CATCH

--ROLLBACK IF

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION

        THROW
    END CATCH
END;
GO

--Apply For Loan

CREATE OR ALTER PROCEDURE ApplyForLoan
    @CustomerId INT,
    @AccountID INT,
    @PrincipalAmount INT,
    @LoanAmount DECIMAL(18,2),
    @InterestRate DECIMAL(5,2),
    @TermMonths INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @LoanAmount <= 0
    BEGIN
        RAISERROR('Loan amount must be greater than zero.', 16, 1)
        RETURN
    END

    IF @TermMonths <= 0
    BEGIN
        RAISERROR('Loan term must be greater than zero.', 16, 1)
        RETURN
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM Customers
        WHERE CustomerId = @CustomerId
    )
    BEGIN
        RAISERROR('Customer does not exist.', 16, 1)
        RETURN
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM Accounts
        WHERE AccountID = @AccountID
        AND CustomerID = @CustomerID
    )
    BEGIN
        RAISERROR('Account does not belong to the customer.', 16, 1)
        RETURN
    END

    INSERT INTO Loans
    (
        CustomerId,
        PrincipalAmount,
        InterestRate,
        TenureMonths,
        Status,
        StartDate
    )
    VALUES
    (
        @CustomerId,
        @PrincipalAmount,
        @InterestRate,
        @TermMonths,
        'Pending',
        GETDATE()
    )

    SELECT SCOPE_IDENTITY() AS LoanId
END;
GO

--Approve loan

CREATE OR ALTER PROCEDURE ApproveLoan
    @LoanId INT
AS
BEGIN
    SET NOCOUNT ON

    IF NOT EXISTS
    (
        SELECT 1
        FROM Loans
        WHERE LoanId = @LoanId
    )
    BEGIN
        RAISERROR('Loan does not exist.', 16, 1)
        RETURN
    END

    IF EXISTS
    (
        SELECT 1
        FROM Loans
        WHERE LoanId = @LoanId
        AND Status <> 'Pending'
    )
    BEGIN
        RAISERROR('Only pending loans can be approved.', 16, 1)
        RETURN
    END

    UPDATE Loans
    SET Status = 'Approved',
        StartDate = GETDATE()
    WHERE LoanId = @LoanId

    SELECT
        'Loan approved successfully.' AS Message,
        @LoanId AS LoanId
END;
GO

--Loan Repayment

CREATE OR ALTER PROCEDURE MakeLoanRepayment
    @LoanId INT,
    @AccountID INT,
    @CustomerId INT,
    @Amount DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON

    IF @Amount <= 0
    BEGIN
        RAISERROR('Repayment amount must be greater than zero.', 16, 1)
        RETURN
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM Loans
        WHERE LoanId = @LoanId
        AND CustomerId = @CustomerId
        AND Status = 'Approved'
    )
    BEGIN
        RAISERROR('Approved loan not found for this account.', 16, 1)
        RETURN
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM Accounts
        WHERE AccountID = @AccountID
        AND Balance >= @Amount
        AND Status = 'Active'
    )
    BEGIN
        RAISERROR('Insufficient funds or inactive account.', 16, 1)
        RETURN
    END

    BEGIN TRY

        BEGIN TRANSACTION

        UPDATE Accounts
        SET Balance = Balance - @Amount
        WHERE AccountID = @AccountID

        INSERT INTO LoanRepayments
        (
            LoanId,
            Amount,
            PaidDate
        )
        VALUES
        (
            @LoanId,
            @Amount,
            GETDATE()
        );

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
        SELECT
            AccountId,
            'Loan Repayment',
            @Amount,
            Currency,
            CONCAT('LOAN-', NEWID()),
            'Successful',
            GETDATE()
        FROM Accounts
        WHERE AccountId = @AccountId

        COMMIT TRANSACTION

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION

        THROW

    END CATCH
END;
GO

-- Freeze Account

CREATE OR ALTER PROCEDURE FreezeAccount
    @AccountId INT
AS
BEGIN
    SET NOCOUNT ON

    IF NOT EXISTS
    (
        SELECT 1
        FROM Accounts
        WHERE AccountId = @AccountId
    )
    BEGIN
        RAISERROR('Account does not exist.', 16, 1)
        RETURN
    END

    UPDATE Accounts
    SET Status = 'Frozen'
    WHERE AccountId = @AccountId;

    SELECT
        'Account frozen successfully.' AS Message,
        @AccountId AS AccountId
END;
GO