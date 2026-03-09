CREATE DATABASE banking_analysis;
USE banking_analysis;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    age INT,
    address VARCHAR(200)
);

SELECT *
FROM customers;

CREATE TABLE account_activity (
    customer_id INT,
    account_balance DECIMAL(12,2),
    last_login DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

SELECT *
FROM account_activity;

CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    amount DECIMAL(12,2),
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

SELECT *
FROM transactions;

CREATE TABLE transaction_metadata (
    transaction_id INT,
    timestamp DATETIME,
    merchant_id INT
);

SELECT *
FROM transaction_metadata;

CREATE TABLE merchants (
    merchant_id INT PRIMARY KEY,
    merchant_name VARCHAR(100),
    location VARCHAR(100)
);

SELECT *
FROM merchants;

CREATE TABLE fraud_indicators (
    transaction_id INT,
    fraud_indicator INT
);

SELECT *
FROM fraud_indicators;

CREATE TABLE anomaly_scores (
    transaction_id INT,
    anomaly_score DECIMAL(5,3)
);

SELECT *
FROM anomaly_scores;

CREATE TABLE transaction_category (
    transaction_id INT,
    category VARCHAR(50)
);

SELECT *
FROM transaction_category;

CREATE TABLE suspicious_activity (
    customer_id INT,
    suspicious_flag INT
);

SELECT *
FROM suspicious_activity;


SELECT COUNT(*) 
FROM transactions;

SELECT SUM(amount)
FROM transactions;

SELECT *
FROM transactions
ORDER BY amount DESC
LIMIT 10;

SELECT *
FROM fraud_indicators
WHERE fraud_indicator = 1;

# FINDE FRAUDE TRANCATIONS DETAILS
SELECT t.transaction_id,
t.amount,
c.name
FROM transactions t
JOIN customers c
ON t.customer_id = c.customer_id
JOIN fraud_indicators f
ON t.transaction_id = f.transaction_id
WHERE f.fraud_indicator = 1;

# CUSTOMER WITH SUSCOINCES ACTIVITY
SELECT c.name,
s.suspicious_flag
FROM customers c
JOIN suspicious_activity s
ON c.customer_id = s.customer_id
WHERE s.suspicious_flag = 1;

# finde the top merchanrt trancsation
SELECT m.merchant_name,
COUNT(*) AS total_transactions
FROM transaction_metadata tm
JOIN merchants m
ON tm.merchant_id = m.merchant_id
GROUP BY m.merchant_name
ORDER BY total_transactions DESC
LIMIT 10;

# and finde avg trancation
SELECT AVG(amount)
FROM transactions;

# High Risk Transactions
SELECT t.transaction_id,
t.amount,
a.anomaly_score
FROM transactions t
JOIN anomaly_scores a
ON t.transaction_id = a.transaction_id
WHERE a.anomaly_score > 0.8;

# customer spinding money
SELECT c.name,
SUM(t.amount) AS total_spent
FROM customers c
JOIN transactions t
ON c.customer_id = t.customer_id
GROUP BY c.name
ORDER BY total_spent DESC
LIMIT 10;

DELIMITER $$
CREATE PROCEDURE total_transaction_amount()
BEGIN
    SELECT SUM(amount) AS total_amount
    FROM transactions;
END $$
DELIMITER ;

CALL total_transaction_amount();


# create a view for better look
CREATE VIEW fraud_analysis AS
SELECT t.transaction_id,
t.amount,
f.fraud_indicator,
a.anomaly_score
FROM transactions t
JOIN fraud_indicators f
ON t.transaction_id = f.transaction_id
JOIN anomaly_scores a
ON t.transaction_id = a.transaction_id;

SELECT * 
FROM fraud_analysis;
