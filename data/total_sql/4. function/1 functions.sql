-- DROP FUNCTION IF EXISTS calculate_trading_fee;
-- DROP FUNCTION IF EXISTS calculate_balance_in_currency;
-- DROP FUNCTION IF EXISTS calculate_portfolio_value;

DELIMITER //

-- 1. 코인 거래 수수료 계산 함수
CREATE FUNCTION calculate_trading_fee(
    p_amount DECIMAL(20, 8),
    p_user_id BIGINT
) RETURNS DECIMAL(20, 8)
DETERMINISTIC
BEGIN
    DECLARE base_fee_rate DECIMAL(5, 4);
    DECLARE final_fee_rate DECIMAL(5, 4);
    DECLARE monthly_trading_volume DECIMAL(20, 8);
    
    -- 기본 수수료율 설정 (0.1%)
    SET base_fee_rate = 0.001;
    
    -- 최근 30일 거래량 계산
    SELECT COALESCE(SUM(total_amount), 0) INTO monthly_trading_volume
    FROM TRADES
    WHERE user_id = p_user_id
    AND created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY);
    
    -- 거래량에 따른 할인율 적용
    IF monthly_trading_volume > 1000000 THEN
        SET final_fee_rate = base_fee_rate * 0.7; -- 30% 할인
    ELSEIF monthly_trading_volume > 500000 THEN
        SET final_fee_rate = base_fee_rate * 0.8; -- 20% 할인
    ELSEIF monthly_trading_volume > 100000 THEN
        SET final_fee_rate = base_fee_rate * 0.9; -- 10% 할인
    ELSE
        SET final_fee_rate = base_fee_rate;
    END IF;
    
    RETURN p_amount * final_fee_rate;
END//
DELIMITER;


DELIMITER //

DELIMITER //

CREATE FUNCTION calculate_balance_in_currency(
    p_user_id BIGINT,
    p_currency_id BIGINT
) 
RETURNS DECIMAL(20,8)
DETERMINISTIC
BEGIN
    DECLARE v_total_balance DECIMAL(20,8);
    
    -- 해당 사용자의 계좌 잔액 합계 조회
    SELECT COALESCE(SUM(
        CASE 
            WHEN a.currency_id = p_currency_id THEN a.balance
            ELSE a.balance * er.rate
        END
    ), 0)
    INTO v_total_balance
    FROM ACCOUNTS a
    LEFT JOIN EXCHANGE_RATES er ON 
        er.from_currency_id = a.currency_id 
        AND er.to_currency_id = p_currency_id
    WHERE a.user_id = p_user_id
    AND a.status = 'ACTIVE';
    
    RETURN v_total_balance;
END //

DELIMITER ;

-- 3. 포트폴리오 총 가치 계산 함수
DELIMITER //

CREATE FUNCTION calculate_portfolio_value(
    p_portfolio_id BIGINT,
    p_currency_id BIGINT
) RETURNS DECIMAL(20, 8)
DETERMINISTIC
BEGIN
    DECLARE total_value DECIMAL(20, 8) DEFAULT 0;
    
    -- 각 코인의 현재 가치를 최근 거래가로 계산하여 합산
    SELECT COALESCE(SUM(
        ph.quantity * (
            SELECT price 
            FROM TRADES 
            WHERE coin_id = ph.coin_id 
            ORDER BY created_at DESC 
            LIMIT 1
        )
    ), 0)
    INTO total_value
    FROM PORTFOLIO_HOLDINGS ph
    WHERE ph.portfolio_id = p_portfolio_id;
    
    -- 만약 target currency가 KRW이고 거래가가 USD라면 환율 적용
    IF p_currency_id = 2 THEN  -- KRW
        SET total_value = total_value * (
            SELECT rate 
            FROM EXCHANGE_RATES 
            WHERE from_currency_id = 1   -- USD
            AND to_currency_id = 2       -- KRW
            ORDER BY created_at DESC 
            LIMIT 1
        );
    END IF;
    
    RETURN total_value;
END//

DELIMITER ;