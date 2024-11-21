package main.auth.service;

import main.auth.domain.User;
import main.auth.repository.UserRepository;

public class UserService {
    private final UserRepository userRepository;
    private static final int MAX_LOGIN_ATTEMPTS = 5;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public boolean register(String email, String password_hash, String confirmPassword, String username, String full_name, String phoneNumber) {
        if (!password_hash.equals(confirmPassword)) {
            System.out.println("비밀번호 불일치");
            return false;
        }
        System.out.println("confirmPassword = " + confirmPassword);
        System.out.println("password_hash = " + password_hash);

        if (userRepository.findByEmail(email) != null) {
            System.out.println("이미 존재하는 아이디다");
            return false;
        }

        User user = new User(null, email, password_hash, username, full_name, phoneNumber, "ACTIVE", false);
        userRepository.save(user);
        System.out.println("회원가입 완료");
        return true;
    }

    public boolean login(String email, String password_hash) {
        User user = userRepository.findByEmail(email);
        if (user != null && user.getPassword_hash().equals(password_hash)) {
            System.out.println("로그인 성공");
            return true;
        }
        return false;
    }
}