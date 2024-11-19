package main;
import main.auth.repository.UserRepository;

import java.util.Scanner;
import main.auth.service.UserService;

public class Application {
    private final Scanner scanner;
    private final main.auth.service.UserService userService;

    public Application() {
        this.scanner = new Scanner(System.in);
        this.userService = new main.auth.service.UserService(new UserRepository());
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
                    loggedIn = handleLogin();
                    break;
                case "2":
                    handleRegistration();
                    break;
                case "EXIT":
                    System.out.println("프로그램 종료");
                    return;
                default:
                    System.out.println("잘못된 선택이다");
            }
        }

        // 로그인 성공 후 다음 단계
        handlePostLogin();
    }

    private boolean handleLogin() {
        int attempts = 0;
        while (attempts < 5) {
            System.out.print("아이디 입력: ");
            String username = scanner.nextLine();
            System.out.print("비밀번호 입력: ");
            String password = scanner.nextLine();

            if (userService.login(username, password)) {
                return true;
            }

            System.out.println("로그인 실패 (" + (5 - ++attempts) + "번 남음)");

            if (attempts == 5) {
                System.out.print("회원가입 하시겠습니까? (y/n): ");
                if (scanner.nextLine().equalsIgnoreCase("y")) {
                    handleRegistration();
                } else {
                    System.out.println("프로그램 종료");
                    System.exit(0);
                }
            }
        }
        return false;
    }

    private void handleRegistration() {
        while (true) {
            System.out.print("아이디 입력: ");
            String username = scanner.nextLine();
            System.out.print("비밀번호 입력: ");
            String password = scanner.nextLine();
            System.out.print("비밀번호 확인: ");
            String confirmPassword = scanner.nextLine();

            if (userService.register(username, password, confirmPassword)) {
                break;
            }
        }
    }

    private void handlePostLogin() {
        System.out.println("로그인 성공 - 다음 단계 준비");
        // TODO: 추가 기능 구현
    }

}