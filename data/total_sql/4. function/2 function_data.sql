-- 기본 거래자 생성 
INSERT INTO USERS (email, password_hash, username, full_name) VALUES
('trader1@test.com', 'hash', 'trader1', 'Trader One'),
('trader2@test.com', 'hash', 'trader2', 'Trader Two'),
('trader3@test.com', 'hash', 'trader3', 'Trader Three');

-- 테스트용 거래자 생성
INSERT INTO USERS (email, password_hash, username, full_name) VALUES
('jup@example.com', 'hash', 'trader_jup', 'Test Trader');
SET @user_id = LAST_INSERT_ID();


-- 계좌 생성
INSERT INTO ACCOUNTS (
   user_id, 
   account_type_id, 
   account_number, 
   balance, 
   currency_id,
   status
) VALUES
(@user_id, 
(SELECT account_type_id FROM ACCOUNT_TYPES WHERE type_name = 'SPOT'), 
CONCAT('ACC_', @user_id, '_USD'), 
10000.00, 
(SELECT id FROM CURRENCIES WHERE currency_code = 'USD'),
'ACTIVE'
);
SET @account_id = LAST_INSERT_ID();

-- 포트폴리오 생성
INSERT INTO PORTFOLIOS (user_id, account_id, portfolio_name) VALUES
(@user_id, @account_id, 'Main Portfolio');
SET @portfolio_id = LAST_INSERT_ID();

-- 포트폴리오 보유량 추가
INSERT INTO PORTFOLIO_HOLDINGS (portfolio_id, coin_id, quantity, average_purchase_price) VALUES
(@portfolio_id, 1, 0.5, 44000.00),  
(@portfolio_id, 2, 2.0, 2400.00);   

-- 거래 내역 추가
INSERT INTO TRADES (
   user_id, 
   counterparty_user_id,
   trade_type_id, 
   trade_status_id, 
   coin_id, 
   quantity, 
   price, 
   total_amount
) VALUES 
(@user_id, 
(SELECT id FROM USERS WHERE username = 'trader2'), 
(SELECT trade_type_id FROM TRADE_TYPES WHERE type_name = 'BUY'),
(SELECT id FROM TRADE_STATUSES WHERE status_name = 'COMPLETED'),
1, 0.1, 45000.00, 4500.00),
(@user_id, 
(SELECT id FROM USERS WHERE username = 'trader3'),
(SELECT trade_type_id FROM TRADE_TYPES WHERE type_name = 'BUY'),
(SELECT id FROM TRADE_STATUSES WHERE status_name = 'COMPLETED'),
2, 1.0, 2500.00, 2500.00);


-- 함수 테스트
SELECT calculate_trading_fee(5000.00, @user_id) as trading_fee;
SELECT calculate_balance_in_currency(@user_id, 1) as total_balance_usd;
SELECT calculate_balance_in_currency(@user_id, 2) as total_balance_krw;
SELECT calculate_portfolio_value(@portfolio_id, 1) as portfolio_value_usd;
SELECT calculate_portfolio_value(@portfolio_id, 2) as portfolio_value_krw;