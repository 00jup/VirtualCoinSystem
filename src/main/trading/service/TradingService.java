package main.trading.service;


import main.trading.domain.Order;
import main.trading.domain.Trade;
import main.trading.repository.OrderRepository;
import main.trading.repository.TradeRepository;
import java.math.BigDecimal;
import java.util.List;

public class TradingService {
    private final OrderRepository orderRepository;
    private final TradeRepository tradeRepository;

    public TradingService(OrderRepository orderRepository, TradeRepository tradeRepository) {
        this.orderRepository = orderRepository;
        this.tradeRepository = tradeRepository;
    }

    public void createOrder(Order order) {
        Long orderId = orderRepository.saveOrder(order);
        order.setId(orderId);

        List<Order> matchingOrders = orderRepository.findMatchingOrders(order);

        for (Order matchingOrder : matchingOrders) {
            if (order.getQuantity().compareTo(BigDecimal.ZERO) <= 0) {
                break;
            }

            BigDecimal tradeQuantity = order.getQuantity().min(matchingOrder.getQuantity());

            Trade trade = Trade.builder()
                    .userId(order.getUserId())
                    .tradeTypeId(order.getType() == Order.OrderType.BUY ? 1L : 2L)
                    .tradeStatus("PENDING")
                    .coinId(order.getCoinId())
                    .quantity(tradeQuantity)
                    .price(matchingOrder.getPrice())
                    .totalAmount(tradeQuantity.multiply(matchingOrder.getPrice()))
                    .build();

            System.out.println("Created Trade: " + trade.toString());  // 디버깅 로그 추가

            tradeRepository.save(trade);

            order.setQuantity(order.getQuantity().subtract(tradeQuantity));
            matchingOrder.setQuantity(matchingOrder.getQuantity().subtract(tradeQuantity));

            orderRepository.updateQuantity(order);
            orderRepository.updateQuantity(matchingOrder);
        }
    }
}