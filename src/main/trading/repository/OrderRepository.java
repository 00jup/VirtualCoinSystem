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

    public void updateExpiresAt(Order order) {
        String sql = order.getType() == Order.OrderType.BUY ?
                "UPDATE ORDER_BUYS SET expires_at = NOW() WHERE id = ?" :
                "UPDATE ORDER_SELLS SET expires_at = NOW() WHERE id = ?";

        try (Connection conn = connectionManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, order.getId());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("주문 만료시간 업데이트 실패", e);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public Long saveOrder(Order order) {
        String sql = order.getType() == Order.OrderType.BUY ?
                "INSERT INTO ORDER_BUYS (user_id, order_type_id, order_status, coin_id, quantity, price, total_amount) VALUES (?, ?, 'PENDING', ?, ?, ?, ?)" :
                "INSERT INTO ORDER_SELLS (user_id, order_type_id, order_status, coin_id, quantity, price, total_amount) VALUES (?, ?, 'PENDING', ?, ?, ?, ?)";

        try (Connection conn = connectionManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            pstmt.setLong(1, order.getUserId());
            pstmt.setLong(2, order.getOrderTypeId());
            pstmt.setLong(3, order.getCoinId());
            pstmt.setBigDecimal(4, order.getQuantity());
            pstmt.setBigDecimal(5, order.getPrice());
            pstmt.setBigDecimal(6, order.getTotalAmount());

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
                "SELECT * FROM ORDER_SELLS WHERE coin_id = ? AND price <= ? AND quantity > 0 AND expires_at IS NULL ORDER BY price ASC, created_at ASC" :
                "SELECT * FROM ORDER_BUYS WHERE coin_id = ? AND price >= ? AND quantity > 0 AND expires_at IS NULL ORDER BY price DESC, created_at ASC";

        List<Order> matchingOrders = new ArrayList<>();

        try (Connection conn = connectionManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, order.getCoinId());
            pstmt.setBigDecimal(2, order.getPrice());

            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Order matchingOrder = Order.builder()
                        .id(rs.getLong("id"))
                        .userId(rs.getLong("user_id"))
                        .orderTypeId(rs.getLong("order_type_id"))
                        .orderStatus(rs.getString("order_status"))
                        .coinId(rs.getLong("coin_id"))
                        .quantity(rs.getBigDecimal("quantity"))
                        .price(rs.getBigDecimal("price"))
                        .totalAmount(rs.getBigDecimal("total_amount"))
                        .type(order.getType() == Order.OrderType.BUY ? Order.OrderType.SELL : Order.OrderType.BUY)
                        .build();

//                 자기 자신의 주문은 제외
                if (!matchingOrder.getUserId().equals(order.getUserId())) {
                    matchingOrders.add(matchingOrder);
                }
            }
            return matchingOrders;
        } catch (SQLException e) {
            throw new RuntimeException("매칭 주문 조회 실패: " + e.getMessage(), e);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
    public void updateOrderStatus(Order order) {
        String sql = order.getType() == Order.OrderType.BUY ?
                "UPDATE ORDER_BUYS SET quantity = ?, order_status = ? WHERE id = ?" :
                "UPDATE ORDER_SELLS SET quantity = ?, order_status = ? WHERE id = ?";

        try (Connection conn = connectionManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            // BigDecimal을 0으로 변환
            BigDecimal quantity = order.getQuantity().compareTo(BigDecimal.ZERO) == 0 ?
                    BigDecimal.ZERO : order.getQuantity();

            String newStatus = quantity.compareTo(BigDecimal.ZERO) == 0 ? "FILLED" : "PENDING";

            pstmt.setBigDecimal(1, quantity);
            pstmt.setString(2, newStatus);
            pstmt.setLong(3, order.getId());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("주문 상태 업데이트 실패", e);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
