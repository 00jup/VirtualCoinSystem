-- 테스트용 사용자 추가
INSERT INTO USERS (email, password_hash, username, full_name, status, is_verified) VALUES 
('test@test.com', 'hash123', 'test_user', 'Test User', 'ACTIVE', true);

-- 사용자 계정 생성 (1,000,000원 초기 잔액)
INSERT INTO ACCOUNTS (
    user_id, account_type_id, account_number, balance, currency_id, status
) VALUES (
    (SELECT id FROM USERS WHERE username = 'test_user'),
    1, 'ACC123456', 1000000.00, 1, 'ACTIVE'
);

-- 포트폴리오 생성
INSERT INTO PORTFOLIOS (
    user_id, account_id, portfolio_name
) VALUES (
    (SELECT id FROM USERS WHERE username = 'test_user'),
    (SELECT id FROM ACCOUNTS WHERE account_number = 'ACC123456'),
    '기본 포트폴리오'
);

-- 초기 코인 보유량 설정
INSERT INTO PORTFOLIO_HOLDINGS (
    portfolio_id, coin_id, quantity, average_purchase_price
) VALUES (
    (SELECT id FROM PORTFOLIOS WHERE user_id = (SELECT id FROM USERS WHERE username = 'test_user')),
    (SELECT id FROM COINS WHERE symbol = 'BTC'),
    0.1,
    55000.00
);

-- 캔들스틱 데이터 추가 (3일치)
INSERT INTO COIN_CANDLESTICKS (
    coin_id, time_frame, open_price, close_price, high_price, low_price, 
    volume, timestamp
) VALUES
-- BTC 데이터
((SELECT id FROM COINS WHERE symbol = 'BTC'), '1D', 55000.00, 56000.00, 57000.00, 54000.00, 100.00, '2024-03-01 00:00:00'),
((SELECT id FROM COINS WHERE symbol = 'BTC'), '1D', 56000.00, 58000.00, 59000.00, 55500.00, 120.00, '2024-03-02 00:00:00'),
((SELECT id FROM COINS WHERE symbol = 'BTC'), '1D', 58000.00, 57000.00, 58500.00, 56500.00, 110.00, '2024-03-03 00:00:00'),
-- ETH 데이터
((SELECT id FROM COINS WHERE symbol = 'ETH'), '1D', 2800.00, 2850.00, 2900.00, 2750.00, 1000.00, '2024-03-01 00:00:00'),
((SELECT id FROM COINS WHERE symbol = 'ETH'), '1D', 2850.00, 2900.00, 2950.00, 2800.00, 1200.00, '2024-03-02 00:00:00'),
((SELECT id FROM COINS WHERE symbol = 'ETH'), '1D', 2900.00, 2850.00, 2950.00, 2800.00, 1100.00, '2024-03-03 00:00:00');

-- 주문 내역 생성
INSERT INTO ORDER_BUYS (
    user_id, order_type_id, coin_id, quantity, price, total_amount, order_status, created_at
) VALUES
(
    (SELECT id FROM USERS WHERE username = 'test_user'),
    1,
    (SELECT id FROM COINS WHERE symbol = 'BTC'),
    0.05,
    55000.00,
    2750.00,
    'FILLED',
    '2024-03-01 10:00:00'
);

INSERT INTO ORDER_SELLS (
    user_id, order_type_id, coin_id, quantity, price, total_amount, order_status, created_at
) VALUES
(
    (SELECT id FROM USERS WHERE username = 'test_user'),
    1,
    (SELECT id FROM COINS WHERE symbol = 'BTC'),
    0.02,
    57000.00,
    1140.00,
    'FILLED',
    '2024-03-02 15:00:00'
);

-- 프로시저 테스트 실행
-- 1. 포트폴리오 성과 분석
CALL analyze_portfolio_performance(
    (SELECT id FROM USERS WHERE username = 'test_user'),
    '2024-03-01 00:00:00',
    '2024-03-03 23:59:59'
);

-- 2. 거래 내역 분석
CALL analyze_trading_history(
    (SELECT id FROM USERS WHERE username = 'test_user'),
    '2024-03-01 00:00:00',
    '2024-03-03 23:59:59'
);

-- 3. 거래 조건 검증 (매수)
CALL validate_trade_conditions(
    (SELECT id FROM USERS WHERE username = 'test_user'),
    (SELECT id FROM COINS WHERE symbol = 'BTC'),
    0.1,
    57000.00,
    'BUY',
    @is_valid,
    @message
);

SELECT @is_valid, @message;

-- 3. 거래 조건 검증 (매도)
CALL validate_trade_conditions(
    (SELECT id FROM USERS WHERE username = 'test_user'),
    (SELECT id FROM COINS WHERE symbol = 'BTC'),
    0.05,
    57000.00,
    'SELL',
    @is_valid,
    @message
);

SELECT @is_valid, @message;