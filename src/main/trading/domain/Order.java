package main.trading.domain;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Setter
@AllArgsConstructor
@Builder
public class Order {
    private Long id;
    private Long userId;
    private Long orderTypeId;
    private String orderStatus;
    private Long coinId;
    private BigDecimal quantity;
    private BigDecimal price;
    private BigDecimal totalAmount;
    private LocalDateTime expiresAt;
    private OrderType type;

    public enum OrderType {
        BUY, SELL
    }
}