--11th Task
--to locate transactions belonging to an account

CREATE INDEX 
IX_Transactions_AccountId
ON Transactions(AccountId)

--Transactions within a period

SELECT *
FROM Transactions
WHERE AccountId = 10
   AND TransactionDate > ''
   AND TransactionDate< ''


CREATE INDEX IX_Transactions_AccountId_TransactionDate
ON Transactions(AccountId, TransactionDate)

--Fraud time query

CREATE INDEX IX_Transactions_FraudDetection
ON Transactions(AccountId, TransactionDate, BeneficiaryId)
