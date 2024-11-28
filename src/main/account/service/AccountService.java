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
        String sql = """
                    SELECT balance 
                    FROM USER_ACCOUNTS 
                    WHERE user_id = ? AND status = 'ACTIVE'
                    LIMIT 1
                """;

        try (Connection conn = connectionManager.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, userId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getBigDecimal("balance");
            }
            return BigDecimal.ZERO;
        } catch (SQLException e) {
            throw new RuntimeException("Failed to fetch account balance", e);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}