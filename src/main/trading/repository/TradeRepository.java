package main.trading.repository;

import main.auth.config.DatabaseConnectionManager;
import main.trading.domain.Trade;

import java.sql.*;
import java.math.BigDecimal;

public class TradeRepository {
    private final DatabaseConnectionManager connectionManager;

    public TradeRepository(DatabaseConnectionManager connectionManager) {
        this.connectionManager = connectionManager;
    }

    public void save(Trade trade) {
        String sql = "INSERT INTO TRADES (user_id, trade_type_id, trade_status_id, coin_id, " +  // trade_status -> trade_status_id
                "quantity, price, total_amount) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = connectionManager.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, trade.getUserId());
            pstmt.setLong(2, trade.getTradeTypeId());
            pstmt.setLong(3, 1L);  // PENDING status id
            pstmt.setLong(4, trade.getCoinId());
            pstmt.setBigDecimal(5, trade.getQuantity());
            pstmt.setBigDecimal(6, trade.getPrice());
            pstmt.setBigDecimal(7, trade.getTotalAmount());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            System.out.println("SQL State: " + e.getSQLState());
            System.out.println("Error Code: " + e.getErrorCode());
            System.out.println("Message: " + e.getMessage());
            throw new RuntimeException("거래 저장 실패", e);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}