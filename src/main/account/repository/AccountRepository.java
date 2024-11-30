package main.account.repository;

import main.auth.config.DatabaseConnectionManager;
import java.sql.*;
import java.math.BigDecimal;

public class AccountRepository {
    private final DatabaseConnectionManager connectionManager;

    public AccountRepository(DatabaseConnectionManager connectionManager) {
        this.connectionManager = connectionManager;
    }

    public void deposit(Long accountId, BigDecimal amount) {
        String updateSql = "UPDATE ACCOUNTS SET balance = balance + ? WHERE id = ?";
        String historySql = "INSERT INTO ACCOUNT_HISTORY (account_id, transaction_type, amount, balance_after) " +
                "VALUES (?, 'DEPOSIT', ?, (SELECT balance FROM ACCOUNTS WHERE id = ?))";

        try (Connection conn = connectionManager.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // 계좌 잔액 업데이트
                try (PreparedStatement pstmt = conn.prepareStatement(updateSql)) {
                    pstmt.setBigDecimal(1, amount);
                    pstmt.setLong(2, accountId);
                    pstmt.executeUpdate();
                }

                // 거래 내역 기록
                try (PreparedStatement pstmt = conn.prepareStatement(historySql)) {
                    pstmt.setLong(1, accountId);
                    pstmt.setBigDecimal(2, amount);
                    pstmt.setLong(3, accountId);
                    pstmt.executeUpdate();
                }

                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw new RuntimeException("입금 처리 실패", e);
            }
        } catch (SQLException e) {
            throw new RuntimeException("데이터베이스 연결 실패", e);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public void withdraw(Long accountId, BigDecimal amount) {
        String checkBalanceSql = "SELECT balance FROM ACCOUNTS WHERE id = ? FOR UPDATE";
        String updateSql = "UPDATE ACCOUNTS SET balance = balance - ? WHERE id = ? AND balance >= ?";
        String historySql = "INSERT INTO ACCOUNT_HISTORY (account_id, transaction_type, amount, balance_after) " +
                "VALUES (?, 'WITHDRAWAL', ?, (SELECT balance FROM ACCOUNTS WHERE id = ?))";

        try (Connection conn = connectionManager.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // 잔액 확인
                BigDecimal currentBalance;
                try (PreparedStatement pstmt = conn.prepareStatement(checkBalanceSql)) {
                    pstmt.setLong(1, accountId);
                    ResultSet rs = pstmt.executeQuery();
                    if (!rs.next()) {
                        throw new RuntimeException("계좌를 찾을 수 없다");
                    }
                    currentBalance = rs.getBigDecimal("balance");
                }

                if (currentBalance.compareTo(amount) < 0) {
                    throw new RuntimeException("잔액이 부족하다");
                }

                // 잔액 업데이트
                try (PreparedStatement pstmt = conn.prepareStatement(updateSql)) {
                    pstmt.setBigDecimal(1, amount);
                    pstmt.setLong(2, accountId);
                    pstmt.setBigDecimal(3, amount);
                    int updatedRows = pstmt.executeUpdate();
                    if (updatedRows == 0) {
                        throw new RuntimeException("출금 처리 실패");
                    }
                }

                // 거래 내역 기록
                try (PreparedStatement pstmt = conn.prepareStatement(historySql)) {
                    pstmt.setLong(1, accountId);
                    pstmt.setBigDecimal(2, amount);
                    pstmt.setLong(3, accountId);
                    pstmt.executeUpdate();
                }

                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw new RuntimeException("출금 처리 실패", e);
            }
        } catch (SQLException e) {
            throw new RuntimeException("데이터베이스 연결 실패", e);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public BigDecimal getBalance(Long accountId) {
        String sql = "SELECT balance FROM ACCOUNTS WHERE id = ?";

        try (Connection conn = connectionManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, accountId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getBigDecimal("balance");
            }
            throw new RuntimeException("계좌를 찾을 수 없다");
        } catch (SQLException e) {
            throw new RuntimeException("잔액 조회 실패", e);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}