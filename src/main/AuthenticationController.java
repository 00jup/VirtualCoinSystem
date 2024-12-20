package main;

import main.auth.domain.User;
import main.auth.service.UserService;

import java.util.Scanner;

public class AuthenticationController {
    private final Scanner scanner;
    private final UserService userService;
    private User currentUser;

    public AuthenticationController(UserService userService) {
        this.scanner = new Scanner(System.in);
        this.userService = userService;
    }

    public User loginAndGetUser() {
        int attempts = 0;
        while (attempts < 5) {
            System.out.print("이메일 입력: ");
            String email = scanner.nextLine();
            System.out.print("비밀번호 입력: ");
            String password = scanner.nextLine();

            User user = userService.loginAndGetUser(email, password);
            if (user != null) {
                return user;
            }

            System.out.println("로그인 실패 (" + (5 - ++attempts) + "번 남음)");

            if (attempts == 5) {
                handleFailedAttempts();
                return null;
            }
        }
        return null;
    }

    public void register() {
        while (true) {
            System.out.print("이메일 입력: ");
            String email = scanner.nextLine();

            String password_hash;
            String confirmPassword;

            while (true) {
                System.out.print("비밀번호 입력: ");
                password_hash = scanner.nextLine();
                System.out.print("비밀번호 확인: ");
                confirmPassword = scanner.nextLine();

                if (password_hash.equals(confirmPassword)) {
                    break;
                }
                System.out.println("비밀번호가 일치하지 않습니다.");
            }

            System.out.print("name 입력: ");
            String username = scanner.nextLine();

            System.out.print("전화번호 입력: ");
            String phoneNumber = scanner.nextLine();

            System.out.print("full name 입력: ");
            String fullName = scanner.nextLine();

            if (userService.register(email, password_hash, confirmPassword, username, fullName, phoneNumber)) {
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
