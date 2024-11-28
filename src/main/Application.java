package main;

import main.account.service.AccountService;
import main.auth.config.DatabaseAuthInformation;
import main.auth.config.DatabaseConnectionManager;
import main.auth.domain.User;
import main.auth.repository.UserRepository;
import main.auth.service.UserService;
import main.market.controller.ChartController;
import main.market.service.ChartService;

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

        while (true) {
            System.out.println("\n1. 시간대별 주문 현황");
            System.out.println("2. 계좌 잔액 조회");
            System.out.println("3. 로그아웃");
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
                    return;
                default:
                    System.out.println("잘못된 선택이다");
            }
        }
    }

}