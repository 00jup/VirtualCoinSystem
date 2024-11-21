package main.market.controller;

import lombok.RequiredArgsConstructor;
import main.market.domain.MarketData;
import main.market.service.ChartService;
import java.util.List;

@RequiredArgsConstructor
public class ChartController {
    private final ChartService chartService;

    public void displayPriceChart() {
        List<MarketData> data = chartService.getHourlyOrderData();
        if (data.isEmpty()) {
            System.out.println("데이터가 없습니다.");
            return;
        }

        System.out.println("\n시간대별 주문 현황:");
        System.out.println("시간 | 거래량 | 평균가격");
        System.out.println("------------------------");

        for (MarketData hourData : data) {
            StringBuilder bar = new StringBuilder();
            int barLength = hourData.getOrderCount() * 2;
            bar.append("█".repeat(Math.max(0, barLength)));

            System.out.printf("%02d시 |%s | %.4f BTC | %.0f원\n",
                    hourData.getHour(),
                    bar.toString(),
                    hourData.getQuantity(),
                    hourData.getPrice()
            );
        }
    }
}