package main;

import main.auth.service.UserService;

import java.util.Scanner;

public class AuthenticationController {
    private final Scanner scanner;
    private final UserService userService;

    public AuthenticationController(UserService userService) {
        this.scanner = new Scanner(System.in);
        this.userService = userService;
    }

    public boolean login() {
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
                return handleFailedAttempts();
            }
        }
        return false;
    }

    public void register() {
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

    private boolean handleFailedAttempts() {
        System.out.print("회원가입 하시겠습니까? (y/n): ");
        if (scanner.nextLine().equalsIgnoreCase("y")) {
            register();
            return true;
        }
        return false;
    }
}
