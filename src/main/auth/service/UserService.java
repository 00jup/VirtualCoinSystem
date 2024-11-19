package main.auth.service;

import main.auth.domain.User;
import main.auth.repository.UserRepository;

public class UserService {
    private final UserRepository userRepository;
    private static final int MAX_LOGIN_ATTEMPTS = 5;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public boolean register(String username, String password, String confirmPassword) {
        if (!password.equals(confirmPassword)) {
            System.out.println("비밀번호가 일치하지 않는다");
            return false;
        }

        if (userRepository.findByUsername(username) != null) {
            System.out.println("이미 존재하는 아이디다");
            return false;
        }

        userRepository.save(new User(username, password));
        System.out.println("회원가입 완료");
        return true;
    }

    public boolean login(String username, String password) {
        User user = userRepository.findByUsername(username);
        if (user != null && user.getPassword().equals(password)) {
            System.out.println("로그인 성공");
            return true;
        }
        return false;
    }
}