package main;

import main.account.service.AccountService;
import main.auth.config.DatabaseAuthInformation;
import main.auth.config.DatabaseConnectionManager;
import main.auth.domain.User;
import main.auth.repository.UserRepository;
import main.auth.service.UserService;
import main.market.controller.ChartController;
import main.market.service.ChartService;
import main.trading.domain.Order;
import main.trading.repository.OrderRepository;
import main.trading.repository.TradeRepository;
import main.trading.service.TradingService;

import java.math.BigDecimal;
import java.util.Scanner;

public class Application {
    private final Scanner scanner;
    private final AuthenticationController authController;
    private final UserService userService;
    private User currentUser;

    public Application() {
        this.scanner = new Scanner(System.in);

        // DB 설정 초기화
        DatabaseAuthInformation dbInfo = new DatabaseAuthInformation();
        dbInfo.parse_auth_info("src/main/auth/config/mysql.auth");

        // 의존성 주입
        DatabaseConnectionManager connectionManager = new DatabaseConnectionManager(dbInfo);
        UserRepository userRepository = new UserRepository(connectionManager);
        this.userService = new UserService(userRepository);
        this.authController = new AuthenticationController(userService);
    }

    public void run() {
        boolean loggedIn = false;
        while (!loggedIn) {
            System.out.println("\n1. 로그인");
            System.out.println("2. 회원가입");
            System.out.println("EXIT. 종료");
            System.out.print("선택: ");

            String choice = scanner.nextLine();

            switch (choice.toUpperCase()) {
                case "1":
                    // 로그인 성공시 현재 사용자 정보 저장
                    currentUser = authController.loginAndGetUser();
                    loggedIn = (currentUser != null);
                    break;
                case "2":
                    authController.register();
                    break;
                case "EXIT":
                    System.out.println("프로그램 종료");
                    return;
                default:
                    System.out.println("잘못된 선택이다");
            }
        }

        handlePostLogin();
    }

    private void handlePostLogin() {
        if (currentUser == null) {
            System.out.println("로그인이 필요하다");
            return;
        }

        DatabaseAuthInformation dbInfo = new DatabaseAuthInformation();
        dbInfo.parse_auth_info("src/main/auth/config/mysql.auth");
        DatabaseConnectionManager connectionManager = new DatabaseConnectionManager(dbInfo);
        AccountService accountService = new AccountService(connectionManager);
        ChartController chartController = new ChartController(new ChartService(connectionManager));
        TradingService tradingService = new TradingService(
                new OrderRepository(connectionManager),
                new TradeRepository(connectionManager)
        );

        while (true) {
            System.out.println("\n1. 시간대별 주문 현황");
            System.out.println("2. 계좌 잔액 조회");
            System.out.println("3. 매수 주문");
            System.out.println("4. 매도 주문");
            System.out.println("5. 로그아웃");
            System.out.print("선택: ");

            String choice = scanner.nextLine();
            switch (choice) {
                case "1":
                    chartController.displayLiveChart();
                    break;
                case "2":
                    BigDecimal balance = accountService.getAccountBalance(currentUser.getId());
                    if (balance.compareTo(BigDecimal.ZERO) > 0) {
                        System.out.printf("현재 계좌 잔액: %,.2f원\n", balance);
                    } else {
                        System.out.println("계좌 정보를 찾을 수 없다");
                    }
                    break;
                case "3":
                    createBuyOrder(tradingService);
                    break;
                case "4":
                    createSellOrder(tradingService);
                    break;
                case "5":
                    return;
                default:
                    System.out.println("잘못된 선택이다");
            }
        }
    }

    private void createBuyOrder(TradingService tradingService) {
        System.out.print("코인 ID 입력: ");
        Long coinId = Long.parseLong(scanner.nextLine());

        System.out.print("수량 입력: ");
        BigDecimal quantity = new BigDecimal(scanner.nextLine());

        System.out.print("가격 입력: ");
        BigDecimal price = new BigDecimal(scanner.nextLine());

        Order buyOrder = Order.builder()
                .userId(currentUser.getId())
                .orderTypeId(1L) // LIMIT order type
                .orderStatusId(1L) // PENDING status
                .coinId(coinId)
                .quantity(quantity)
                .price(price)
                .totalAmount(quantity.multiply(price))
                .type(Order.OrderType.BUY)
                .build();

        tradingService.createOrder(buyOrder);
        System.out.println("매수 주문이 생성되었다");
    }

    private void createSellOrder(TradingService tradingService) {
        System.out.print("코인 ID 입력: ");
        Long coinId = Long.parseLong(scanner.nextLine());

        System.out.print("수량 입력: ");
        BigDecimal quantity = new BigDecimal(scanner.nextLine());

        System.out.print("가격 입력: ");
        BigDecimal price = new BigDecimal(scanner.nextLine());

        Order sellOrder = Order.builder()
                .userId(currentUser.getId())
                .orderTypeId(1L) // LIMIT order type
                .orderStatusId(1L) // PENDING status
                .coinId(coinId)
                .quantity(quantity)
                .price(price)
                .totalAmount(quantity.multiply(price))
                .type(Order.OrderType.SELL)
                .build();

        tradingService.createOrder(sellOrder);
        System.out.println("매도 주문이 생성되었다");
    }

}