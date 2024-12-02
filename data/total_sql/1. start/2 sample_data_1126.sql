
-- 1. USER SECTOR
INSERT INTO ROLE_TYPE (role_name) VALUES 
('ADMIN'), ('USER'), ('MANAGER');

INSERT INTO PERMISSION_TYPE (permission_name) VALUES
('READ'), ('WRITE'), ('DELETE'), ('TRADE');

INSERT INTO USERS (email, password_hash, username, full_name, phone_number, is_verified) VALUES
('john@example.com', 'hash1', 'john_doe', 'John Doe', '1234567890', true),
('jane@example.com', 'hash2', 'jane_smith', 'Jane Smith', '0987654321', true),
('bob@example.com', 'hash3', 'bob_wilson', 'Bob Wilson', '1122334455', true);

INSERT INTO USER_ROLES (user_id, role_type_id) VALUES
(1, 1), (2, 2), (3, 2);

INSERT INTO USER_PERMISSIONS (user_id, permission_type_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 4),
(2, 1), (2, 4),
(3, 1), (3, 4);

-- 2. COINS SECTOR
INSERT INTO COIN_CATEGORIES (category_name) VALUES
('CRYPTOCURRENCY'), ('TOKEN'), ('STABLE_COIN');

INSERT INTO COINS (symbol, name, description, category_id, is_active) VALUES
('BTC', 'Bitcoin', 'Digital gold', 1, true),
('ETH', 'Ethereum', 'Smart contract platform', 1, true),
('USDT', 'Tether', 'Stable coin', 3, true);

INSERT INTO COIN_CANDLESTICKS (coin_id, time_frame, open_price, close_price, high_price, low_price, volume, timestamp) VALUES
(1, '1H', 44800.00, 45000.00, 45200.00, 44700.00, 1000000, NOW()),
(2, '1H', 1980.00, 2000.00, 2020.00, 1975.00, 500000, NOW()),
(3, '1H', 0.99, 1.00, 1.01, 0.99, 2000000, NOW());

-- 3. PORTFOLIOS & ACCOUNTS SECTOR
INSERT INTO ACCOUNT_TYPES (type_name) VALUES
('SPOT'), ('MARGIN'), ('FUTURES');

INSERT INTO CURRENCIES (currency_code, currency_name, currency_symbol, is_fiat) VALUES
('USD', 'US Dollar', '$', true),
('EUR', 'Euro', '€', true),
('KRW', 'Korean Won', '₩', true);

INSERT INTO ACCOUNTS (user_id, account_type_id, account_number, balance, currency_id) VALUES
(1, 1, 'ACC001', 10000.00, (SELECT id FROM CURRENCIES WHERE currency_code = 'KRW')),
(2, 1, 'ACC002', 15000.00, (SELECT id FROM CURRENCIES WHERE currency_code = 'KRW')),
(3, 1, 'ACC003', 20000.00, (SELECT id FROM CURRENCIES WHERE currency_code = 'KRW'));

INSERT INTO PORTFOLIOS (user_id, account_id, portfolio_name) VALUES
(1, 1, 'Main Portfolio'),
(2, 2, 'Investment Portfolio'),
(3, 3, 'Trading Portfolio');

-- 4. ORDERS SECTOR
INSERT INTO ORDER_TYPES (type_name) VALUES
('MARKET'), ('LIMIT'), ('STOP_LIMIT');

-- INSERT INTO ORDER_STATUSES (status_name, description) VALUES
-- ('PENDING', 'Order is waiting to be processed'),
-- ('FILLED', 'Order has been completely filled'),
-- ('CANCELLED', 'Order has been cancelled');

INSERT INTO ORDER_BUYS (user_id, order_type_id, order_status, coin_id, quantity, price, total_amount) VALUES
(1, 1, 'PENDING', 1, 0.5, 45000.00, 22500.00),
(2, 2, 'PENDING', 2, 10, 2000.00, 20000.00);

INSERT INTO ORDER_SELLS (user_id, order_type_id, order_status, coin_id, quantity, price, total_amount) VALUES
(3, 1, 'PENDING', 1, 0.3, 46000.00, 13800.00),
(1, 2, 'PENDING', 2, 5, 2100.00, 10500.00);



-- 5. TRADE & CHECK SECTOR
-- INSERT INTO CHECK_TYPES (type_name) VALUES
-- ('BUY_ORDER_CHECK'), ('SELL_ORDER_CHECK');

-- INSERT INTO CHECK_STATUSES (status_name, description, display_order) VALUES
-- ('PENDING', 'Transaction verification pending', 1),
-- ('VERIFIED', 'Transaction verification completed', 2),
-- ('FAILED', 'Transaction verification failed', 3);

INSERT INTO TRADE_TYPES (type_name) VALUES
('BUY'), ('SELL');

INSERT INTO TRADE_STATUSES (status_name, description) VALUES
('PENDING', 'Trade in progress'),
('COMPLETED', 'Trade completed'),
('FAILED', 'Trade failed');