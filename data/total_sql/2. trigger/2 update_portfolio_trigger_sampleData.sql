

-- 매수/매도 테스트를 위한 사용자 세팅
INSERT INTO USERS (email, password_hash, username, full_name) VALUES
('seller@test.com', 'hash', 'seller', '판매자'),
('buyer@test.com', 'hash', 'buyer', '구매자');

-- 계좌 생성
INSERT INTO ACCOUNTS (user_id, account_type_id, account_number, balance, currency_id) VALUES 
((SELECT id FROM USERS WHERE username = 'seller'), 1, 'ACC004', 100000.00, 1),
((SELECT id FROM USERS WHERE username = 'buyer'), 1, 'ACC005', 100000.00, 1);

-- 포트폴리오 생성  
INSERT INTO PORTFOLIOS (user_id, account_id, portfolio_name) VALUES
((SELECT id FROM USERS WHERE username = 'seller'), 
(SELECT id FROM ACCOUNTS WHERE user_id = (SELECT id FROM USERS WHERE username = 'seller')), 
'기본 포트폴리오'),
((SELECT id FROM USERS WHERE username = 'buyer'),
(SELECT id FROM ACCOUNTS WHERE user_id = (SELECT id FROM USERS WHERE username = 'buyer')),
'기본 포트폴리오');

-- 판매자에게 코인 보유량 추가
INSERT INTO PORTFOLIO_HOLDINGS (
   portfolio_id, 
   coin_id,
   quantity,
   average_purchase_price
) VALUES (
   (SELECT id FROM PORTFOLIOS WHERE user_id = (SELECT id FROM USERS WHERE username = 'seller')),
   1,
   10.0,
   40000.00
);

-- 거래 생성
INSERT INTO TRADES (
   user_id,
   counterparty_user_id, 
   trade_type_id,
   trade_status_id,
   coin_id,
   quantity,
   price,
   total_amount
)
VALUES (
   (SELECT id FROM USERS WHERE username = 'buyer'),
   (SELECT id FROM USERS WHERE username = 'seller'),
   (SELECT trade_type_id FROM TRADE_TYPES WHERE type_name = 'BUY'),
   (SELECT id FROM TRADE_STATUSES WHERE status_name = 'COMPLETED'),
   1, 
   1.0,
   45000.00,
   45000.00
);

-- 거래 결과 확인
SELECT 
   u.username,
   ph.quantity as holding_quantity,
   ph.average_purchase_price,
   phi.action_type,
   phi.quantity as history_quantity,
   phi.price_at_action,
   a.balance as account_balance
FROM USERS u
JOIN PORTFOLIOS p ON u.id = p.user_id
LEFT JOIN PORTFOLIO_HOLDINGS ph ON p.id = ph.portfolio_id
LEFT JOIN PORTFOLIO_HISTORY phi ON p.id = phi.portfolio_id
JOIN ACCOUNTS a ON u.id = a.user_id
WHERE u.username IN ('buyer', 'seller')
ORDER BY phi.created_at DESC;


-- 구매자/판매자의 계좌 잔액 확인
SELECT 
    u.username,
    a.account_number,
    a.balance
FROM USERS u
JOIN ACCOUNTS a ON u.id = a.user_id
WHERE u.username IN ('seller', 'buyer');

-- 구매자/판매자의 포트폴리오 보유 현황 확인
SELECT 
    u.username,
    c.symbol as coin_symbol,
    ph.quantity,
    ph.average_purchase_price,
    (ph.quantity * ph.average_purchase_price) as total_value
FROM USERS u
JOIN PORTFOLIOS p ON u.id = p.user_id
LEFT JOIN PORTFOLIO_HOLDINGS ph ON p.id = ph.portfolio_id
LEFT JOIN COINS c ON ph.coin_id = c.id
WHERE u.username IN ('seller', 'buyer');

-- 각 사용자의 거래 내역 확인
SELECT 
    u.username,
    phi.action_type,
    c.symbol as coin_symbol,
    phi.quantity,
    phi.price_at_action,
    phi.created_at
FROM USERS u
JOIN PORTFOLIOS p ON u.id = p.user_id
JOIN PORTFOLIO_HISTORY phi ON p.id = phi.portfolio_id
JOIN COINS c ON phi.coin_id = c.id
WHERE u.username IN ('seller', 'buyer')
ORDER BY phi.created_at DESC;
