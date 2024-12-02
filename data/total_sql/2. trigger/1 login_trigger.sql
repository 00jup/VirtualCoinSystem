DELIMITER //

-- 로그인 실패 체크 트리거
CREATE TRIGGER tr_check_login_failures
AFTER INSERT ON LOGIN_HISTORY
FOR EACH ROW
BEGIN
    DECLARE recent_failures INT;
    
    IF NEW.login_status = 'FAILED' THEN
        -- 서브쿼리로 최근 실패 횟수 확인
        SELECT COUNT(*) INTO recent_failures
        FROM LOGIN_HISTORY
        WHERE user_id = NEW.user_id
        AND login_status = 'FAILED'
        AND login_timestamp >= NOW() - INTERVAL 30 MINUTE;
        
        -- 실패 횟수가 5회 이상이면 계정 잠금
        IF recent_failures >= 5 THEN
            UPDATE USERS
            SET 
                status = 'SUSPENDED',
                updated_at = NOW()
            WHERE id = NEW.user_id;
            
            -- 알림 추가
            INSERT INTO NOTIFICATION (
                user_id,
                notification_type_id,
                title,
                content
            )
            VALUES (
                NEW.user_id,
                (SELECT notification_type_id FROM NOTIFICATION_TYPE WHERE type_name = 'SECURITY_ALERT'),
                '계정 잠금 알림',
                CONCAT('로그인 ', recent_failures, '회 실패로 인해 계정이 잠겼습니다. 고객센터에 문의하세요.')
            );
        END IF;
    END IF;
END //

-- 로그인 성공시 리셋 트리거
CREATE TRIGGER tr_reset_login_failures
AFTER INSERT ON LOGIN_HISTORY
FOR EACH ROW
BEGIN
    IF NEW.login_status = 'SUCCESS' THEN
        UPDATE USERS
        SET 
            status = 'ACTIVE',
            last_login_at = NOW(),
            updated_at = NOW()
        WHERE id = NEW.user_id;
    END IF;
END //

DELIMITER ;