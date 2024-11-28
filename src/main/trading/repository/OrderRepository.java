package main.trading.repository;

import main.auth.config.DatabaseConnectionManager;
import main.trading.domain.Order;
import java.sql.*;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class OrderRepository {
    private final DatabaseConnectionManager connectionManager;

    public OrderRepository(DatabaseConnectionManager connectionManager) {
        this.connectionManager = connectionManager;
    }

    public Long saveOrder(Order order) {
        String sql = order.getType() == Order.OrderType.BUY ?
                "INSERT INTO ORDER_BUYS (user_id, order_type_id, order_status_id, coin_id, quantity, price, total_amount) VALUES (?, ?, ?, ?, ?, ?, ?)" :
                "INSERT INTO ORDER_SELLS (user_id, order_type_id, order_status_id, coin_id, quantity, price, total_amount) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = connectionManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            pstmt.setLong(1, order.getUserId());
            pstmt.setLong(2, order.getOrderTypeId());
            pstmt.setLong(3, order.getOrderStatusId());
            pstmt.setLong(4, order.getCoinId());
            pstmt.setBigDecimal(5, order.getQuantity());
            pstmt.setBigDecimal(6, order.getPrice());
            pstmt.setBigDecimal(7, order.getTotalAmount());

            pstmt.executeUpdate();

            ResultSet rs = pstmt.getGeneratedKeys();
            if (rs.next()) {
                return rs.getLong(1);
            }
            return null;
        } catch (SQLException e) {
            throw new RuntimeException("주문 저장 실패", e);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public List<Order> findMatchingOrders(Order order) {
        String sql = order.getType() == Order.OrderType.BUY ?
                "SELECT * FROM ORDER_SELLS WHERE coin_id = ? AND price <= ? AND quantity > 0 ORDER BY price ASC, created_at ASC" :
                "SELECT * FROM ORDER_BUYS WHERE coin_id = ? AND price >= ? AND quantity > 0 ORDER BY price DESC, created_at ASC";

        List<Order> matchingOrders = new ArrayList<>();

        try (Connection conn = connectionManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, order.getCoinId());
            pstmt.setBigDecimal(2, order.getPrice());

            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                matchingOrders.add(Order.builder()
                        .id(rs.getLong("id"))
                        .userId(rs.getLong("user_id"))
                        .orderTypeId(rs.getLong("order_type_id"))
                        .orderStatusId(rs.getLong("order_status_id"))
                        .coinId(rs.getLong("coin_id"))
                        .quantity(rs.getBigDecimal("quantity"))
                        .price(rs.getBigDecimal("price"))
                        .totalAmount(rs.getBigDecimal("total_amount"))
                        .type(order.getType() == Order.OrderType.BUY ? Order.OrderType.SELL : Order.OrderType.BUY)
                        .build());
            }
            return matchingOrders;
        } catch (SQLException e) {
            throw new RuntimeException("매칭 주문 조회 실패", e);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public void updateQuantity(Order order) {
        String sql = order.getType() == Order.OrderType.BUY ?
                "UPDATE ORDER_BUYS SET quantity = ? WHERE id = ?" :
                "UPDATE ORDER_SELLS SET quantity = ? WHERE id = ?";

        try (Connection conn = connectionManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setBigDecimal(1, order.getQuantity());
            pstmt.setLong(2, order.getId());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("주문 수량 업데이트 실패", e);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
