package main;

import main.auth.config.DatabaseAuthInformation;
import main.auth.config.DatabaseConnectionManager;
import main.auth.repository.UserRepository;
import main.auth.service.UserService;
import main.market.controller.ChartController;
import main.market.service.ChartService;

import java.util.Scanner;

public class Application {
    private final Scanner scanner;
    private final AuthenticationController authController;
    private final UserService userService;


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
                    loggedIn = authController.login();
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
        // DB 설정 초기화
        DatabaseAuthInformation dbInfo = new DatabaseAuthInformation();
        dbInfo.parse_auth_info("src/main/auth/config/mysql.auth");

        // 의존성 주입
        DatabaseConnectionManager connectionManager = new DatabaseConnectionManager(dbInfo);
        System.out.println("로그인 성공 - 다음 단계 준비");
        ChartController chartController = new ChartController(new ChartService(connectionManager));

        while (true) {
            System.out.println("\n1. 시간대별 주문 현황");
            System.out.println("2. 로그아웃");
            System.out.print("선택: ");

            String choice = scanner.nextLine();
            switch (choice) {
                case "1":
                    chartController.displayPriceChart();
                    break;
                case "2":
                    return;
                default:
                    System.out.println("잘못된 선택입니다.");
            }
        }

    }
}