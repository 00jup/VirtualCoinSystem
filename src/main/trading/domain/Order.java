package main.trading.domain;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import java.math.BigDecimal;
import java.time.LocalDateTime;

// Order.java
@Getter
@Setter
@AllArgsConstructor
@Builder
public class Order {
    private Long id;
    private Long userId;
    private Long orderTypeId;
    private Long orderStatusId;
    private Long coinId;
    private BigDecimal quantity;
    private BigDecimal price;
    private BigDecimal totalAmount;
    private LocalDateTime createdAt;
    private OrderType type;

    public enum OrderType {
        BUY, SELL
    }
}