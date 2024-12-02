-- 알림 유형 데이터
INSERT INTO NOTIFICATION_TYPE (type_name, description) VALUES 
('SECURITY_ALERT', '보안 관련 알림'),
('TRADE_ALERT', '거래 관련 알림'),
('PRICE_ALERT', '가격 변동 알림'),
('SYSTEM_ALERT', '시스템 알림'),
('ACCOUNT_ALERT', '계정 관련 알림'),
('DEPOSIT_ALERT', '입금 관련 알림'),
('WITHDRAWAL_ALERT', '출금 관련 알림'),
('PROMOTION_ALERT', '프로모션 알림'),
('KYC_ALERT', 'KYC 인증 관련 알림'),
('MAINTENANCE_ALERT', '시스템 점검 알림');

-- 알림 예시 데이터
INSERT INTO NOTIFICATION (user_id, notification_type_id, title, content, is_read) VALUES
-- 보안 알림
(1, (SELECT notification_type_id FROM NOTIFICATION_TYPE WHERE type_name = 'SECURITY_ALERT'), 
'2차 인증 설정 권장', '계정 보안을 위해 2차 인증을 설정해주세요.', false),

(2, (SELECT notification_type_id FROM NOTIFICATION_TYPE WHERE type_name = 'SECURITY_ALERT'),
'새로운 IP에서의 로그인 감지', '서울에서 새로운 로그인이 감지되었습니다.', false),

-- 거래 알림
(1, (SELECT notification_type_id FROM NOTIFICATION_TYPE WHERE type_name = 'TRADE_ALERT'),
'거래 체결 완료', 'BTC 0.1 매수 주문이 체결되었습니다.', true),

(3, (SELECT notification_type_id FROM NOTIFICATION_TYPE WHERE type_name = 'TRADE_ALERT'),
'거래 체결 완료', 'ETH 2.0 매도 주문이 체결되었습니다.', false),

-- 가격 알림
(1, (SELECT notification_type_id FROM NOTIFICATION_TYPE WHERE type_name = 'PRICE_ALERT'),
'가격 알림', 'BTC가 목표가 45,000 USD에 도달했습니다.', false),

(2, (SELECT notification_type_id FROM NOTIFICATION_TYPE WHERE type_name = 'PRICE_ALERT'),
'급격한 가격 변동', 'ETH 가격이 1시간 동안 10% 상승했습니다.', true),

-- 시스템 알림
(1, (SELECT notification_type_id FROM NOTIFICATION_TYPE WHERE type_name = 'SYSTEM_ALERT'),
'시스템 업데이트 예정', '내일 02:00-04:00 시스템 업데이트가 진행됩니다.', false),

(2, (SELECT notification_type_id FROM NOTIFICATION_TYPE WHERE type_name = 'SYSTEM_ALERT'),
'서비스 장애 복구', '이더리움 출금 지연 문제가 해결되었습니다.', true),

-- 계정 알림
(3, (SELECT notification_type_id FROM NOTIFICATION_TYPE WHERE type_name = 'ACCOUNT_ALERT'),
'계정 인증 레벨 상승', '계정 인증 레벨이 2로 상승했습니다.', false),

(1, (SELECT notification_type_id FROM NOTIFICATION_TYPE WHERE type_name = 'ACCOUNT_ALERT'),
'프로필 업데이트 필요', 'KYC 인증을 위해 추가 서류가 필요합니다.', false),

-- 입출금 알림
(2, (SELECT notification_type_id FROM NOTIFICATION_TYPE WHERE type_name = 'DEPOSIT_ALERT'),
'입금 확인', '1,000 USD 입금이 완료되었습니다.', true),

(3, (SELECT notification_type_id FROM NOTIFICATION_TYPE WHERE type_name = 'WITHDRAWAL_ALERT'),
'출금 처리 중', 'BTC 0.1 출금이 처리 중입니다.', false),

-- 프로모션 알림
(1, (SELECT notification_type_id FROM NOTIFICATION_TYPE WHERE type_name = 'PROMOTION_ALERT'),
'신규 이벤트 안내', '거래 수수료 50% 할인 이벤트가 시작되었습니다.', false),

(2, (SELECT notification_type_id FROM NOTIFICATION_TYPE WHERE type_name = 'PROMOTION_ALERT'),
'추천 이벤트', '친구 추천 시 거래 수수료 추가 할인!', true),

-- KYC 알림
(3, (SELECT notification_type_id FROM NOTIFICATION_TYPE WHERE type_name = 'KYC_ALERT'),
'KYC 인증 완료', 'Level 2 인증이 승인되었습니다.', false),

(1, (SELECT notification_type_id FROM NOTIFICATION_TYPE WHERE type_name = 'KYC_ALERT'),
'KYC 서류 반려', '제출하신 신분증 사진이 선명하지 않습니다.', true),

-- 시스템 점검 알림
(2, (SELECT notification_type_id FROM NOTIFICATION_TYPE WHERE type_name = 'MAINTENANCE_ALERT'),
'긴급 점검 안내', '금일 15:00-16:00 긴급 서버 점검이 진행됩니다.', false),

(3, (SELECT notification_type_id FROM NOTIFICATION_TYPE WHERE type_name = 'MAINTENANCE_ALERT'),
'정기 점검 안내', '매주 화요일 04:00-06:00는 정기 점검 시간입니다.', true);