package main;

import main.auth.repository.UserRepository;
import main.auth.service.UserService;

import java.util.Scanner;

public class Application {
    private final Scanner scanner;
    private final AuthenticationController authController;
    private final UserService userService;


    public Application() {
        this.scanner = new Scanner(System.in);
        this.userService = new UserService(new UserRepository());
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
        System.out.println("로그인 성공 - 다음 단계 준비");
        // TODO: 추가 기능 구현
    }
}