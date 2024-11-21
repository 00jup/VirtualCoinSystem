package main.market.service;

import lombok.RequiredArgsConstructor;
import main.auth.config.DatabaseConnectionManager;
import main.market.domain.MarketData;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

@RequiredArgsConstructor
public class ChartService {
    private final DatabaseConnectionManager connectionManager;

    public List<MarketData> getHourlyOrderData() {
        List<MarketData> result = new ArrayList<>();
        String query = """
            SELECT 
                HOUR(created_at) as hour,
                COUNT(*) as order_count,
                SUM(quantity) as total_quantity,
                AVG(price) as avg_price
            FROM ORDERS 
            WHERE DATE(created_at) = '2024-03-20'
            GROUP BY HOUR(created_at)
            ORDER BY hour;
        """;

        try (Connection conn = connectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                MarketData data = new MarketData();
                data.setHour(rs.getInt("hour"));
                data.setOrderCount(rs.getInt("order_count"));
                data.setQuantity(rs.getDouble("total_quantity"));
                data.setPrice(rs.getDouble("avg_price"));
                result.add(data);
            }
        } catch (Exception e) {
            System.out.println("데이터 조회 중 오류 발생: " + e.getMessage());
        }
        return result;
    }
}