DELIMITER //

-- 1. 포트폴리오 성과 분석 프로시저 
CREATE PROCEDURE analyze_portfolio_performance(
    IN p_user_id BIGINT,
    IN p_start_datetime DATETIME,
    IN p_end_datetime DATETIME
)
BEGIN
    WITH portfolio_values AS (
        SELECT 
            p.id as portfolio_id,
            p.portfolio_name,
            ph.coin_id,
            ph.quantity,
            ph.average_purchase_price,
            cs.close_price as price,
            (ph.quantity * cs.close_price) as current_value,
            (ph.quantity * ph.average_purchase_price) as investment_value
        FROM PORTFOLIOS p
        JOIN PORTFOLIO_HOLDINGS ph ON p.id = ph.portfolio_id
        JOIN (
            SELECT coin_id, close_price 
            FROM COIN_CANDLESTICKS 
            WHERE timestamp BETWEEN p_start_datetime AND p_end_datetime
            AND time_frame = '1D'
        ) cs ON ph.coin_id = cs.coin_id
        WHERE p.user_id = p_user_id
    )
    SELECT 
        portfolio_id,
        portfolio_name,
        SUM(current_value) as total_value,
        CASE 
            WHEN SUM(investment_value) > 0 
            THEN ((SUM(current_value) - SUM(investment_value)) / SUM(investment_value) * 100)
            ELSE 0 
        END as roi_percentage,
        SUM(investment_value) as total_investment
    FROM portfolio_values
    GROUP BY portfolio_id, portfolio_name;
END //

-- 2. 거래 내역 분석 프로시저
CREATE PROCEDURE analyze_trading_history(
    IN p_user_id BIGINT,
    IN p_start_date DATETIME,
    IN p_end_date DATETIME
)
BEGIN
    WITH combined_orders AS (
        SELECT 
            'BUY' as trade_type,
            ob.created_at,
            ob.coin_id,
            c.symbol,
            ob.quantity,
            ob.price,
            ob.total_amount,
            ob.order_status
        FROM ORDER_BUYS ob
        JOIN COINS c ON ob.coin_id = c.id
        WHERE ob.user_id = p_user_id 
        AND ob.created_at BETWEEN p_start_date AND p_end_date
        
        UNION ALL
        
        SELECT 
            'SELL' as trade_type,
            os.created_at,
            os.coin_id,
            c.symbol,
            os.quantity,
            os.price,
            os.total_amount,
            os.order_status
        FROM ORDER_SELLS os
        JOIN COINS c ON os.coin_id = c.id
        WHERE os.user_id = p_user_id 
        AND os.created_at BETWEEN p_start_date AND p_end_date
    )
    SELECT 
        trade_type,
        created_at,
        symbol as coin_symbol,
        quantity,
        price,
        total_amount,
        order_status,
        SUM(CASE 
            WHEN trade_type = 'BUY' THEN -total_amount
            ELSE total_amount
        END) OVER (ORDER BY created_at) as running_balance
    FROM combined_orders
    ORDER BY created_at;
END //

-- 3. 매수/매도 전 조건 검증 프로시저
CREATE PROCEDURE validate_trade_conditions(
    IN p_user_id BIGINT,
    IN p_coin_id BIGINT,
    IN p_quantity DECIMAL(20, 8),
    IN p_price DECIMAL(20, 8),
    IN p_trade_type VARCHAR(10),
    OUT p_is_valid BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_account_balance DECIMAL(20, 8);
    DECLARE v_coin_balance DECIMAL(20, 8);
    DECLARE v_total_amount DECIMAL(20, 8);
    
    SET p_is_valid = FALSE;
    SET v_total_amount = p_quantity * p_price;
    
    SELECT balance INTO v_account_balance
    FROM ACCOUNTS
    WHERE user_id = p_user_id
    AND status = 'ACTIVE'
    LIMIT 1;
    
    SELECT COALESCE(SUM(ph.quantity), 0) INTO v_coin_balance
    FROM PORTFOLIO_HOLDINGS ph
    JOIN PORTFOLIOS p ON ph.portfolio_id = p.id
    WHERE p.user_id = p_user_id 
    AND ph.coin_id = p_coin_id;

    IF p_trade_type = 'BUY' THEN
        IF v_account_balance >= v_total_amount THEN
            SET p_is_valid = TRUE;
            SET p_message = '거래 가능하다';
        ELSE
            SET p_message = CONCAT('잔액이 부족하다. 필요금액: ', v_total_amount, ', 현재잔액: ', v_account_balance);
        END IF;
    ELSEIF p_trade_type = 'SELL' THEN
        IF v_coin_balance >= p_quantity THEN
            SET p_is_valid = TRUE;
            SET p_message = '거래 가능하다';
        ELSE
            SET p_message = CONCAT('보유량이 부족하다. 필요수량: ', p_quantity, ', 현재보유량: ', v_coin_balance);
        END IF;
    END IF;
END //

DELIMITER ;