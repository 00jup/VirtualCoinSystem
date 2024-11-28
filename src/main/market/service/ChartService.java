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
                MIN(price) as low_price,
                MAX(price) as high_price,
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
                data.setLowPrice(rs.getDouble("low_price"));
                data.setHighPrice(rs.getDouble("high_price"));
                data.setPrice(rs.getDouble("avg_price"));
                result.add(data);
            }
        } catch (Exception e) {
            System.out.println("데이터 조회 중 오류 발생: " + e.getMessage());
        }
        return result;
    }

    public void displayCandleStickChart() {
        List<MarketData> data = getHourlyOrderData();
        if (data.isEmpty()) {
            System.out.println("No data available");
            return;
        }

        // Chart Header
        System.out.println("\n시간대별 캔들스틱 차트");
        System.out.println("━".repeat(70));
        System.out.println("시간 | 주문 수 | BTC 수량 | 저가 - 고가 | 평균가");
        System.out.println("━".repeat(70));

        // Initialize previous average price for trend comparison
        double previousAvgPrice = 0;

        for (MarketData hourData : data) {
            // Determine trend indicator
            String trend = hourData.getPrice() > previousAvgPrice ? "▲" : "▼";
            String trendColor = hourData.getPrice() > previousAvgPrice ? "\u001B[32m" : "\u001B[31m"; // Green or Red

            // Format the candlestick bar
            String lowToHigh = String.format("%,.0f원 - %,.0f원", hourData.getLowPrice(), hourData.getHighPrice());

            System.out.printf(
                    "%02d시 | %6d | %9.4f | %-18s | %s%,.0f원%s %s\n",
                    hourData.getHour(),
                    hourData.getOrderCount(),
                    hourData.getQuantity(),
                    lowToHigh,
                    trendColor, hourData.getPrice(), "\u001B[0m",
                    trend
            );

            previousAvgPrice = hourData.getPrice();
        }
        System.out.println("━".repeat(70));
    }

    public String generateChartLines() {
        List<MarketData> data = getHourlyOrderData();
        if (data.isEmpty()) {
            return "No data available";
        }

        StringBuilder chartBuilder = new StringBuilder();
        chartBuilder.append("시간 | 거래량 | 평균가격\n");
        chartBuilder.append("------------------------\n");

        for (MarketData hourData : data) {
            StringBuilder bar = new StringBuilder();
            int barLength = hourData.getOrderCount() * 2;
            bar.append("█".repeat(Math.max(0, barLength)));

            chartBuilder.append(String.format("%02d시 |%s | %.4f BTC | %.0f원\n",
                    hourData.getHour(),
                    bar.toString(),
                    hourData.getQuantity(),
                    hourData.getPrice()
            ));
        }

        return chartBuilder.toString();
    }
}
