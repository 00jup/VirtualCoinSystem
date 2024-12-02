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
        String sql = "INSERT INTO TRADES (user_id, counterparty_user_id, trade_type_id, trade_status_id, coin_id, " +
                "quantity, price, total_amount) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = connectionManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, trade.getUserId());
            pstmt.setLong(2, trade.getCounterpartyUserId());
            pstmt.setLong(3, trade.getTradeTypeId());
            pstmt.setLong(4, 2L);  // COMPLETED status id
            pstmt.setLong(5, trade.getCoinId());
            pstmt.setBigDecimal(6, trade.getQuantity());
            pstmt.setBigDecimal(7, trade.getPrice());
            pstmt.setBigDecimal(8, trade.getTotalAmount());
            pstmt.executeUpdate();
            System.out.println("거래 체결 완료");
        } catch (SQLException e) {
            throw new RuntimeException("거래 저장 실패", e);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}