package main.market.domain;

import lombok.Getter;
import lombok.Setter;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class MarketData {
    private int hour;
    private int orderCount;
    private double quantity;
    private double price;
}