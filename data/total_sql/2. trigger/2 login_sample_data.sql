-- 로그인 실패/성공 시나리오 테스트
-- 사용자 1: 3회 실패 후 성공
INSERT INTO LOGIN_HISTORY (user_id, ip_address, login_status, failure_reason) VALUES
(1, '192.168.1.100', 'FAILED', '잘못된 비밀번호'),
(1, '192.168.1.100', 'FAILED', '잘못된 비밀번호'),
(1, '192.168.1.100', 'FAILED', '잘못된 비밀번호'),
(1, '192.168.1.100', 'SUCCESS', NULL);

-- 사용자 2: 5회 실패로 계정 잠금
INSERT INTO LOGIN_HISTORY (user_id, ip_address, login_status, failure_reason) VALUES
(2, '192.168.1.101', 'FAILED', '잘못된 비밀번호'),
(2, '192.168.1.101', 'FAILED', '잘못된 비밀번호'),
(2, '192.168.1.101', 'FAILED', '잘못된 비밀번호'),
(2, '192.168.1.101', 'FAILED', '잘못된 비밀번호'),
(2, '192.168.1.101', 'FAILED', '잘못된 비밀번호');

-- 결과 확인용 쿼리
SELECT 
    u.id,
    u.username,
    u.status,
    COUNT(CASE WHEN lh.login_status = 'FAILED' THEN 1 END) as failure_count,
    MAX(CASE WHEN lh.login_status = 'SUCCESS' THEN lh.login_timestamp END) as last_success_login
FROM USERS u
LEFT JOIN LOGIN_HISTORY lh ON u.id = lh.user_id
WHERE u.id IN (1, 2)
GROUP BY u.id, u.username, u.status;

-- 알림 확인
SELECT * FROM NOTIFICATION 
WHERE user_id = 2 
ORDER BY created_at DESC 
LIMIT 1;

-- 잠긴 계정 상태 확인
SELECT id, username, status 
FROM USERS 
WHERE username = 'jane_smith';

-- 계정 잠금 해제
UPDATE USERS 
SET status = 'ACTIVE', 
   updated_at = NOW()
WHERE username = 'jane_smith';

-- 로그인 성공 기록 추가 
INSERT INTO LOGIN_HISTORY (user_id, ip_address, login_status)
VALUES (2, '192.168.1.101', 'SUCCESS');

-- 상태 변경 확인
SELECT id, username, status
FROM USERS 
WHERE username = 'jane_smith';

-- 로그인 이력 확인
SELECT login_status, login_timestamp, ip_address
FROM LOGIN_HISTORY
WHERE user_id = 2
ORDER BY login_timestamp DESC
LIMIT 6;