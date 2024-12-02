package main.trading.service;

import main.trading.domain.Order;
import main.trading.domain.Trade;
import main.trading.repository.OrderRepository;
import main.trading.repository.TradeRepository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class TradingService {
    private final OrderRepository orderRepository;
    private final TradeRepository tradeRepository;

    public TradingService(OrderRepository orderRepository, TradeRepository tradeRepository) {
        this.orderRepository = orderRepository;
        this.tradeRepository = tradeRepository;
    }


    // TradingService.java
    public void createOrder(Order order) {

        if (order.getExpiresAt() != null) {
            throw new IllegalStateException("이미 체결된 주문이다");
        }

        Long orderId = orderRepository.saveOrder(order);
        order.setId(orderId);

        List<Order> matchingOrders = orderRepository.findMatchingOrders(order);

        for (Order matchingOrder : matchingOrders) {
            if (matchingOrder.getExpiresAt() != null) {
                continue;
            }

            if (order.getQuantity().compareTo(BigDecimal.ZERO) <= 0) {
                break;
            }

            // 가격이 일치하는 경우에만 거래 진행
            if (order.getPrice().compareTo(matchingOrder.getPrice()) == 0) {
                if (order.getQuantity().compareTo(BigDecimal.ZERO) <= 0) {
                    break;
                }

                BigDecimal tradeQuantity = order.getQuantity().min(matchingOrder.getQuantity());

                order.setQuantity(order.getQuantity().subtract(tradeQuantity));
                matchingOrder.setQuantity(matchingOrder.getQuantity().subtract(tradeQuantity));

                Trade trade = Trade.builder().userId(order.getUserId()).counterpartyUserId(matchingOrder.getUserId()).tradeTypeId(order.getType() == Order.OrderType.BUY ? 1L : 2L).tradeStatus("PENDING").coinId(order.getCoinId()).quantity(tradeQuantity).price(matchingOrder.getPrice()).totalAmount(tradeQuantity.multiply(matchingOrder.getPrice())).build();

                tradeRepository.save(trade);

                orderRepository.updateOrderStatus(order);
                orderRepository.updateOrderStatus(matchingOrder);

                orderRepository.updateExpiresAt(order);
                orderRepository.updateExpiresAt(matchingOrder);
            }
        }

    }
}
