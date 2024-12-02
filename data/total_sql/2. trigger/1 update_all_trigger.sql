DELIMITER //

CREATE TRIGGER after_trade_update_all
AFTER INSERT ON TRADES
FOR EACH ROW
BEGIN
   DECLARE v_seller_portfolio_id BIGINT;
   DECLARE v_buyer_portfolio_id BIGINT;
   DECLARE v_trade_type VARCHAR(10);
   
   -- 거래 타입 조회 (BUY/SELL)
   SELECT type_name INTO v_trade_type
   FROM TRADE_TYPES
   WHERE trade_type_id = NEW.trade_type_id;
   
   -- 구매자와 판매자의 포트폴리오 찾기
   SELECT id INTO v_buyer_portfolio_id
   FROM PORTFOLIOS
   WHERE user_id = NEW.user_id
   LIMIT 1;
   
   SELECT id INTO v_seller_portfolio_id 
   FROM PORTFOLIOS
   WHERE user_id = NEW.counterparty_user_id
   LIMIT 1;
   
   -- 구매자 포트폴리오: 코인 추가/업데이트
   INSERT INTO PORTFOLIO_HOLDINGS (portfolio_id, coin_id, quantity, average_purchase_price)
   VALUES (v_buyer_portfolio_id, NEW.coin_id, NEW.quantity, NEW.price)
   ON DUPLICATE KEY UPDATE
       quantity = quantity + NEW.quantity,
       average_purchase_price = ((quantity * average_purchase_price) + (NEW.quantity * NEW.price)) / (quantity + NEW.quantity);
       
   -- 판매자 포트폴리오: 코인 차감
   UPDATE PORTFOLIO_HOLDINGS
   SET quantity = quantity - NEW.quantity
   WHERE portfolio_id = v_seller_portfolio_id AND coin_id = NEW.coin_id;
   
   -- 구매자: 계좌에서 돈 차감
   UPDATE ACCOUNTS 
   SET balance = balance + NEW.total_amount
   WHERE user_id = NEW.user_id;
   
   -- 판매자: 계좌에 돈 입금
   UPDATE ACCOUNTS 
   SET balance = balance - NEW.total_amount
   WHERE user_id = NEW.counterparty_user_id;
   
   -- 보유량이 0이하면 포트폴리오에서 삭제
   DELETE FROM PORTFOLIO_HOLDINGS
   WHERE portfolio_id = v_seller_portfolio_id 
   AND coin_id = NEW.coin_id 
   AND quantity <= 0;
   
   -- 구매자 포트폴리오 히스토리
   INSERT INTO PORTFOLIO_HISTORY (portfolio_id, coin_id, action_type, quantity, price_at_action)
   VALUES (v_buyer_portfolio_id, NEW.coin_id, 'BUY', NEW.quantity, NEW.price);
   
   -- 판매자 포트폴리오 히스토리
   INSERT INTO PORTFOLIO_HISTORY (portfolio_id, coin_id, action_type, quantity, price_at_action)
   VALUES (v_seller_portfolio_id, NEW.coin_id, 'SELL', NEW.quantity, NEW.price);
   
   -- 구매자 계좌 거래 내역
   INSERT INTO ACCOUNT_HISTORY (
       account_id,
       transaction_type,
       amount,
       balance_after,
       description
   )
   SELECT 
       a.id,
       'WITHDRAWAL',
       NEW.total_amount,
       a.balance,
       CONCAT('코인 매수: ', NEW.quantity, ' 개')
   FROM ACCOUNTS a
   WHERE a.user_id = NEW.user_id;
   
   -- 판매자 계좌 거래 내역  
   INSERT INTO ACCOUNT_HISTORY (
       account_id,
       transaction_type, 
       amount,
       balance_after,
       description
   )
   SELECT 
       a.id,
       'DEPOSIT',
       NEW.total_amount,
       a.balance,
       CONCAT('코인 매도: ', NEW.quantity, ' 개')
   FROM ACCOUNTS a 
   WHERE a.user_id = NEW.counterparty_user_id;
   
END//

DELIMITER ;