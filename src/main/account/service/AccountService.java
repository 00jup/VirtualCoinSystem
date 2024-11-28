package main.account.service;

import main.auth.config.DatabaseConnectionManager;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.math.BigDecimal;

public class AccountService {
    private final DatabaseConnectionManager connectionManager;

    public AccountService(DatabaseConnectionManager connectionManager) {
        this.connectionManager = connectionManager;
    }

    public BigDecimal getAccountBalance(Long userId) {
        String sql = "SELECT balance FROM USER_ACCOUNTS WHERE user_id = ? AND status = 'ACTIVE' LIMIT 1";

        try (Connection conn = connectionManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, userId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getBigDecimal("balance");
            }
            return BigDecimal.ZERO;
        } catch (SQLException e) {
            throw new RuntimeException("잔액 조회 실패", e);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public BigDecimal getCoinBalance(Long userId, Long coinId) {
        String sql = """
            SELECT quantity 
            FROM PORTFOLIO_HOLDINGS ph
            JOIN PORTFOLIOS p ON ph.portfolio_id = p.id
            WHERE p.user_id = ? AND ph.coin_id = ?
        """;

        try (Connection conn = connectionManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, userId);
            pstmt.setLong(2, coinId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getBigDecimal("quantity");
            }
            return BigDecimal.ZERO;
        } catch (SQLException e) {
            throw new RuntimeException("코인 잔액 조회 실패", e);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public void increaseBalance(Long userId, BigDecimal amount) {
        String sql = "UPDATE USER_ACCOUNTS SET balance = balance + ? WHERE user_id = ? AND status = 'ACTIVE'";
        executeBalanceUpdate(sql, amount, userId, "잔액 증가 실패");
    }

    public void decreaseBalance(Long userId, BigDecimal amount) {
        String sql = "UPDATE USER_ACCOUNTS SET balance = balance - ? WHERE user_id = ? AND status = 'ACTIVE'";
        executeBalanceUpdate(sql, amount, userId, "잔액 감소 실패");
    }

    public void increaseCoinBalance(Long userId, Long coinId, BigDecimal quantity) {
        String sql = """
            INSERT INTO PORTFOLIO_HOLDINGS (portfolio_id, coin_id, quantity, average_purchase_price)
            SELECT p.id, ?, ?, 0
            FROM PORTFOLIOS p WHERE p.user_id = ?
            ON DUPLICATE KEY UPDATE quantity = quantity + ?
        """;
        executeCoinUpdate(sql, userId, coinId, quantity, "코인 잔액 증가 실패");
    }

    public void decreaseCoinBalance(Long userId, Long coinId, BigDecimal quantity) {
        String sql = """
            UPDATE PORTFOLIO_HOLDINGS ph
            JOIN PORTFOLIOS p ON ph.portfolio_id = p.id
            SET ph.quantity = ph.quantity - ?
            WHERE p.user_id = ? AND ph.coin_id = ?
        """;
        executeCoinUpdate(sql, userId, coinId, quantity, "코인 잔액 감소 실패");
    }

    private void executeBalanceUpdate(String sql, BigDecimal amount, Long userId, String errorMessage) {
        try (Connection conn = connectionManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setBigDecimal(1, amount);
            pstmt.setLong(2, userId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException(errorMessage, e);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private void executeCoinUpdate(String sql, Long userId, Long coinId, BigDecimal quantity, String errorMessage) {
        try (Connection conn = connectionManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            if (sql.contains("INSERT")) {
                pstmt.setLong(1, coinId);
                pstmt.setBigDecimal(2, quantity);
                pstmt.setLong(3, userId);
                pstmt.setBigDecimal(4, quantity);
            } else {
                pstmt.setBigDecimal(1, quantity);
                pstmt.setLong(2, userId);
                pstmt.setLong(3, coinId);
            }
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException(errorMessage, e);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}