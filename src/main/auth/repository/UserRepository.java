package main.auth.repository;

import main.auth.domain.User;

import java.util.HashMap;
import java.util.Map;

public class UserRepository {
    private Map<String, User> users = new HashMap<>();

    public void save(User user) {
        users.put(user.getUsername(), user);
    }

    public User findByUsername(String username) {
        return users.get(username);
    }
}