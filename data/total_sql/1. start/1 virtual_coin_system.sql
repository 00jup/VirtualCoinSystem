DROP DATABASE virtual_coin_system;
-- 처음 실행할 때는 이거 빼고 하기

CREATE DATABASE virtual_coin_system;

USE virtual_coin_system;

-- ---1-1 사용자 관련 테이블: USERS
-- 기본 사용자 정보를 저장하는 테이블
CREATE TABLE USERS (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    status ENUM('ACTIVE', 'INACTIVE', 'SUSPENDED', 'DELETED') NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    verification_token VARCHAR(255),
    reset_password_token VARCHAR(255),
    INDEX idx_email (email),
    INDEX idx_username (username)
);

-- ---1-2 사용자 관련 테이블: USER_ADDRESSES
-- 사용자의 주소 정보를 저장하는 테이블
CREATE TABLE USER_ADDRESSES (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    address_type ENUM('HOME', 'OFFICE', 'OTHER') NOT NULL,
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES USERS(id),
    INDEX idx_user_addresses (user_id)
);


-- ---1-3-1 사용자 관련 테이블: ROLE_TYPE
-- N:N 이라서 분리한 ROLE TABLE
-- ROLE에 대한 분류
CREATE TABLE ROLE_TYPE (
    role_type_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

-- ---1-3-2 사용자 관련 테이블: USER_ROLES
-- 사용자의 역할 정보를 저장하는 테이블
CREATE TABLE USER_ROLES (
    user_id BIGINT NOT NULL,
    role_type_id BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, role_type_id),
    FOREIGN KEY (user_id) REFERENCES USERS(id),
    FOREIGN KEY (role_type_id) REFERENCES ROLE_TYPE(role_type_id)
);

-- ---1-4-1 사용자 관련 테이블: PERMISSION_TYPE
-- PERMSISSION에 대한 분류
CREATE TABLE PERMISSION_TYPE (
		permission_type_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    permission_name VARCHAR(50) NOT NULL UNIQUE
);

-- ---1-4-2 사용자 관련 테이블: USER_PERMISSIONS
-- 사용자별 권한 정보를 저장하는 테이블
CREATE TABLE USER_PERMISSIONS (
    user_id BIGINT NOT NULL,
    permission_type_id BIGINT NOT NULL,
    PRIMARY KEY (user_id, permission_type_id),
    FOREIGN KEY (user_id) REFERENCES USERS(id),
    FOREIGN KEY (permission_type_id) REFERENCES PERMISSION_TYPE(permission_type_id)
);

-- ---1-4-3 사용자 관련 테이블: ROLE_PERMISSIONS
CREATE TABLE ROLE_PERMISSIONS (
    role_type_id BIGINT NOT NULL,
    permission_type_id BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (role_type_id, permission_type_id),
    FOREIGN KEY (role_type_id) REFERENCES ROLE_TYPE(role_type_id),
    FOREIGN KEY (permission_type_id) REFERENCES PERMISSION_TYPE(permission_type_id)
);

-- ---1-5 사용자 관련 테이블: LOGIN_HISTORY
-- 사용자 로그인 기록을 저장하는 테이블
CREATE TABLE LOGIN_HISTORY (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    login_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45) NOT NULL,
    device_info VARCHAR(255),
    login_status ENUM('SUCCESS', 'FAILED') NOT NULL,
    failure_reason VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES USERS(id),
    INDEX idx_user_login (user_id, login_timestamp)
);


-- ---1.5-1 알람 관련 테이블: NOTIFICATION_TYPE
-- 알림 유형을 정의하는 테이블
CREATE TABLE NOTIFICATION_TYPE (
    notification_type_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ---1.5-2 알람 관련 테이블: NOTIFICATION
-- 사용자별 알림 정보를 저장하는 테이블
CREATE TABLE NOTIFICATION (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    notification_type_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES USERS(id),
    FOREIGN KEY (notification_type_id) REFERENCES NOTIFICATION_TYPE(notification_type_id),
    INDEX idx_user_notification (user_id, created_at)
);

-- ---2-1 코인 관련 테이블: COIN_CATEGORIES
-- 코인 분류 정보를 저장하는 테이블
CREATE TABLE COIN_CATEGORIES (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE
);

-- ---2-2 코인 관련 테이블: COINS
-- 코인 기본 정보를 저장하는 테이블
CREATE TABLE COINS (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    symbol VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    logo_url VARCHAR(255),
    category_id BIGINT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_coin_symbol (symbol),
    FOREIGN KEY (category_id) REFERENCES COIN_CATEGORIES(id)
);


-- ---2-3 코인 관련 테이블: COIN_CANDLESTICKS
-- 코인 차트 데이터를 저장하는 테이블
CREATE TABLE COIN_CANDLESTICKS (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    coin_id BIGINT NOT NULL,
    time_frame ENUM('1M', '5M', '1H', '1D') NOT NULL,
    open_price DECIMAL(20, 8) NOT NULL,
    close_price DECIMAL(20, 8) NOT NULL,
    high_price DECIMAL(20, 8) NOT NULL,
    low_price DECIMAL(20, 8) NOT NULL,
    volume DECIMAL(20, 8) NOT NULL,
    timestamp DATETIME NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (coin_id) REFERENCES COINS(id),
    UNIQUE KEY unique_candlestick (coin_id, time_frame, timestamp),
    INDEX idx_candlesticks (coin_id, time_frame, timestamp)
);


-- ---3-1 계좌 및 금융 관련 테이블: ACCOUNT_TYPES
-- 사용자 계좌 유형을 정의하는 테이블
CREATE TABLE ACCOUNT_TYPES (
	account_type_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE
);

-- ---3-2 계좌 및 금융 관련 테이블: ACCOUNTS
-- 사용자의 계좌 정보를 저장하는 테이블
CREATE TABLE ACCOUNTS (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    account_type_id BIGINT NOT NULL,
    account_number VARCHAR(50) NOT NULL UNIQUE,
    balance DECIMAL(20, 8) NOT NULL DEFAULT 0,
    currency_id BIGINT NOT NULL,
    status ENUM('ACTIVE', 'FROZEN', 'CLOSED') NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES USERS(id),
    FOREIGN KEY (account_type_id) REFERENCES ACCOUNT_TYPES(account_type_id),
    INDEX idx_user_accounts (user_id)
);

-- ---3-3 계좌 및 금융 관련 테이블: ACCOUNT_HISTORY
-- 계좌 변동 내역을 저장하는 테이블
CREATE TABLE ACCOUNT_HISTORY (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    account_id BIGINT NOT NULL,
    transaction_type ENUM('DEPOSIT', 'WITHDRAWAL', 'TRANSFER', 'FEE', 'INTEREST') NOT NULL,
    amount DECIMAL(20, 8) NOT NULL,
    balance_after DECIMAL(20, 8) NOT NULL,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES ACCOUNTS(id),
    INDEX idx_account_history (account_id, created_at)
);

-- ---3-4 계좌 및 금융 관련 테이블: PORTFOLIOS
-- 사용자의 포트폴리오 정보를 저장하는 테이블
CREATE TABLE PORTFOLIOS (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    account_id BIGINT NOT NULL,
    portfolio_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES USERS(id),
    FOREIGN KEY (account_id) REFERENCES ACCOUNTS(id),
    UNIQUE KEY unique_user_portfolio (user_id, portfolio_name),
    INDEX idx_portfolio_account (account_id)
);

-- ---3-5 계좌 및 금융 관련 테이블: PORTFOLIO_HOLDINGS
-- 포트폴리오 내 보유 자산 정보를 저장하는 테이블
CREATE TABLE PORTFOLIO_HOLDINGS (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    portfolio_id BIGINT NOT NULL,
    coin_id BIGINT NOT NULL,
    quantity DECIMAL(20, 8) NOT NULL,
    average_purchase_price DECIMAL(20, 8) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (coin_id) REFERENCES COINS(id),
    FOREIGN KEY (portfolio_id) REFERENCES PORTFOLIOS(id),
    UNIQUE KEY unique_portfolio_coin (portfolio_id, coin_id)
);

-- ---3-6 계좌 및 금융 관련 테이블: PORTFOLIO_HISTORY
-- 포트폴리오 변동 내역을 저장하는 테이블
CREATE TABLE PORTFOLIO_HISTORY (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    portfolio_id BIGINT NOT NULL,
    coin_id BIGINT NOT NULL,
    action_type ENUM('BUY', 'SELL', 'TRANSFER_IN', 'TRANSFER_OUT') NOT NULL,
    quantity DECIMAL(20, 8) NOT NULL,
    price_at_action DECIMAL(20, 8) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (portfolio_id) REFERENCES PORTFOLIOS(id),
    INDEX idx_portfolio_history (portfolio_id, created_at)
);

-- ---4-1 거래 관련 테이블: TRADE_TYPES
-- 거래 유형을 정의하는 테이블
CREATE TABLE TRADE_TYPES (
    trade_type_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE
);

-- ---4-2 거래 관련 테이블: TRADE_STATUSES
-- 거래 상태를 정의하는 테이블
CREATE TABLE TRADE_STATUSES (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ---4-3 거래 관련 테이블: TRADES
-- 거래 정보를 저장하는 테이블
CREATE TABLE TRADES (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    counterparty_user_id BIGINT NOT NULL,
    trade_type_id BIGINT NOT NULL,
    trade_status_id BIGINT NOT NULL,
    coin_id BIGINT NOT NULL,
    quantity DECIMAL(20, 8) NOT NULL,
    price DECIMAL(20, 8) NOT NULL,
    total_amount DECIMAL(20, 8) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES USERS(id),
    FOREIGN KEY (counterparty_user_id) REFERENCES USERS(id),
    FOREIGN KEY (trade_type_id) REFERENCES TRADE_TYPES(trade_type_id),
    FOREIGN KEY (trade_status_id) REFERENCES TRADE_STATUSES(id),
    INDEX idx_user_trades (user_id, created_at)
);

-- ---4-4 거래 관련 테이블: TRADE_DETAILS
-- 거래 상세 정보를 저장하는 테이블
CREATE TABLE TRADE_DETAILS (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    trade_id BIGINT NOT NULL,
    execution_price DECIMAL(20, 8) NOT NULL,
    executed_quantity DECIMAL(20, 8) NOT NULL,
    execution_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (trade_id) REFERENCES TRADES(id),
    INDEX idx_trade_details (trade_id)
);

-- ---4-5 거래 관련 테이블: TRADE_FEES
-- 거래 수수료 정보를 저장하는 테이블
CREATE TABLE TRADE_FEES (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    trade_id BIGINT NOT NULL,
    fee_type ENUM('TRADING', 'WITHDRAWAL', 'DEPOSIT', 'OTHER') NOT NULL,
    fee_amount DECIMAL(20, 8) NOT NULL,
    currency_id BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (trade_id) REFERENCES TRADES(id),
    INDEX idx_trade_fees (trade_id)
);

-- ---4-6 거래 관련 테이블: TRADE_SETTLEMENTS
-- 거래 결제 정보를 저장하는 테이블
CREATE TABLE TRADE_SETTLEMENTS (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    trade_id BIGINT NOT NULL,
    settlement_status ENUM('PENDING', 'COMPLETED', 'FAILED') NOT NULL,
    settlement_amount DECIMAL(20, 8) NOT NULL,
    settlement_date TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (trade_id) REFERENCES TRADES(id),
    INDEX idx_trade_settlements (trade_id)
);

-- ---4-7 거래 관련 테이블: TRADE_HISTORY
-- 거래 이력을 저장하는 테이블
CREATE TABLE TRADE_HISTORY (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    trade_id BIGINT NOT NULL,
    status_change_from VARCHAR(50),
    status_change_to VARCHAR(50) NOT NULL,
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changed_by BIGINT NOT NULL,
    reason TEXT,
    FOREIGN KEY (trade_id) REFERENCES TRADES(id),
    FOREIGN KEY (changed_by) REFERENCES USERS(id),
    INDEX idx_trade_history (trade_id, changed_at)
);

-- ---5-1 주문 관련 테이블: ORDER_TYPES
-- 주문 유형을 정의하는 테이블
CREATE TABLE ORDER_TYPES (
    order_type_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE
);

-- ---5-2 주문 관련 테이블: ORDER_STATUSES
-- 주문 상태를 정의하는 테이블
-- CREATE TABLE ORDER_STATUSES (
--     id BIGINT AUTO_INCREMENT PRIMARY KEY,
--     status_name VARCHAR(50) NOT NULL UNIQUE,
--     description TEXT,
--     created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
-- );

-- ---5-3 주문 관련 테이블: ORDER_BUYS
-- 매수 주문 기본 정보를 저장하는 테이블
CREATE TABLE ORDER_BUYS (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    order_type_id BIGINT NOT NULL,
    -- order_status_id BIGINT NOT NULL,
	order_status ENUM('PENDING', 'FILLED', 'CANCELLED') NOT NULL,
    coin_id BIGINT NOT NULL,
    quantity DECIMAL(20, 8) NOT NULL,
    price DECIMAL(20, 8) NOT NULL,
    total_amount DECIMAL(20, 8) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES USERS(id),
    FOREIGN KEY (order_type_id) REFERENCES ORDER_TYPES(order_type_id),
    -- FOREIGN KEY (order_status_id) REFERENCES ORDER_STATUSES(id),
	FOREIGN KEY (coin_id) REFERENCES COINS(id),
    INDEX idx_user_buy_orders (user_id, created_at)
);

-- ---5-4 주문 관련 테이블: ORDER_SELLS
-- 매도 주문 기본 정보를 저장하는 테이블
CREATE TABLE ORDER_SELLS (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    order_type_id BIGINT NOT NULL,
    -- order_status_id BIGINT NOT NULL,
	order_status ENUM('PENDING', 'FILLED', 'CANCELLED') NOT NULL,
    coin_id BIGINT NOT NULL,
    quantity DECIMAL(20, 8) NOT NULL,
    price DECIMAL(20, 8) NOT NULL,
    total_amount DECIMAL(20, 8) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES USERS(id),
    FOREIGN KEY (order_type_id) REFERENCES ORDER_TYPES(order_type_id),
    -- FOREIGN KEY (order_status_id) REFERENCES ORDER_STATUSES(id),
    FOREIGN KEY (coin_id) REFERENCES COINS(id),
    INDEX idx_user_sell_orders (user_id, created_at)
);

-- ---5-5 주문 관련 테이블: ORDER_BUY_DETAILS
-- 매수 주문의 상세 정보를 저장하는 테이블
CREATE TABLE ORDER_BUY_DETAILS (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_buy_id BIGINT NOT NULL,
    price_type ENUM('MARKET', 'LIMIT', 'STOP_LIMIT') NOT NULL,
    stop_price DECIMAL(20, 8) NULL,
    filled_quantity DECIMAL(20, 8) DEFAULT 0,
    remaining_quantity DECIMAL(20, 8) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_buy_id) REFERENCES ORDER_BUYS(id),
    INDEX idx_buy_order_details (order_buy_id)
);

-- ---5-6 주문 관련 테이블: ORDER_SELL_DETAILS
-- 매도 주문의 상세 정보를 저장하는 테이블
CREATE TABLE ORDER_SELL_DETAILS (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_sell_id BIGINT NOT NULL,
    price_type ENUM('MARKET', 'LIMIT', 'STOP_LIMIT') NOT NULL,
    stop_price DECIMAL(20, 8) NULL,
    filled_quantity DECIMAL(20, 8) DEFAULT 0,
    remaining_quantity DECIMAL(20, 8) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_sell_id) REFERENCES ORDER_SELLS(id),
    INDEX idx_sell_order_details (order_sell_id)
);

-- ---5-7 주문 관련 테이블: ORDER_BUY_RESERVATIONS
-- 매수 주문 예약 정보를 저장하는 테이블
CREATE TABLE ORDER_BUY_RESERVATIONS (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_buy_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    coin_id BIGINT NOT NULL,
    target_price DECIMAL(20, 8) NOT NULL,
    quantity DECIMAL(20, 8) NOT NULL,
    reservation_status ENUM('PENDING', 'EXECUTED', 'CANCELLED') NOT NULL,
    scheduled_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_buy_id) REFERENCES ORDER_BUYS(id),
    FOREIGN KEY (user_id) REFERENCES USERS(id),
    INDEX idx_buy_reservations (user_id, scheduled_at)
);

-- ---5-8 주문 관련 테이블: ORDER_SELL_RESERVATIONS
-- 매도 주문 예약 정보를 저장하는 테이블
CREATE TABLE ORDER_SELL_RESERVATIONS (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_sell_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    coin_id BIGINT NOT NULL,
    target_price DECIMAL(20, 8) NOT NULL,
    quantity DECIMAL(20, 8) NOT NULL,
    reservation_status ENUM('PENDING', 'EXECUTED', 'CANCELLED') NOT NULL,
    scheduled_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_sell_id) REFERENCES ORDER_SELLS(id),
    FOREIGN KEY (user_id) REFERENCES USERS(id),
    INDEX idx_sell_reservations (user_id, scheduled_at)
);

-- ---5-9 주문 관련 테이블: ORDER_HISTORY
-- 주문 상태 변경 이력을 저장하는 테이블
CREATE TABLE ORDER_HISTORY (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_buy_id BIGINT NULL,
    order_sell_id BIGINT NULL,
    previous_status VARCHAR(50),
    new_status VARCHAR(50) NOT NULL,
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changed_by BIGINT NOT NULL,
    reason TEXT,
    FOREIGN KEY (order_buy_id) REFERENCES ORDER_BUYS(id),
    FOREIGN KEY (order_sell_id) REFERENCES ORDER_SELLS(id),
    FOREIGN KEY (changed_by) REFERENCES USERS(id),
    INDEX idx_buy_order_history (order_buy_id, changed_at),
    INDEX idx_sell_order_history (order_sell_id, changed_at)
);

-- ---5-1-1 화폐 관련 테이블: CURRENCIES
-- 지원하는 화폐 정보를 저장하는 테이블
CREATE TABLE CURRENCIES (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    currency_code VARCHAR(10) NOT NULL UNIQUE,
    currency_name VARCHAR(50) NOT NULL,
    currency_symbol VARCHAR(10),
    is_fiat BOOLEAN NOT NULL DEFAULT TRUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    decimal_places INT NOT NULL DEFAULT 2,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ---5-1-2 환율 테이블: EXCHANGE_RATES
CREATE TABLE EXCHANGE_RATES (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    from_currency_id BIGINT NOT NULL,
    to_currency_id BIGINT NOT NULL,
    rate DECIMAL(20, 8) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (from_currency_id) REFERENCES CURRENCIES(id),
    FOREIGN KEY (to_currency_id) REFERENCES CURRENCIES(id),
    INDEX idx_currency_pair (from_currency_id, to_currency_id)
);


-- ---6-1 거래 관 테이블: TRADING_HISTORYS
-- 모든 금융 거래를 추적하는 테이블
CREATE TABLE TRADING_HISTORYS (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    account_id BIGINT NOT NULL,
    trading_history_type_id BIGINT NOT NULL,
    amount DECIMAL(20, 8) NOT NULL,
    fee_amount DECIMAL(20, 8) DEFAULT 0,
    currency_id BIGINT NOT NULL,
    status_id BIGINT NOT NULL,
    trade_id BIGINT NULL,
    order_buy_id BIGINT NULL,
    order_sell_id BIGINT NULL,
    external_transaction_id VARCHAR(100) NULL,
    blockchain_tx_hash VARCHAR(255) NULL,
    description TEXT NULL,
    notes TEXT NULL,
    ip_address VARCHAR(45) NULL,
    user_agent VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_trading_historys_status_id (status_id),
    INDEX idx_trading_historys_account (account_id),
    INDEX idx_trading_historys_created_at (created_at)
);
