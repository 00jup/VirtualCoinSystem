package main.auth.repository;

import main.auth.config.DatabaseConnectionManager;
import main.auth.domain.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;


public class UserRepository {
    private final DatabaseConnectionManager connectionManager;
    private static final String INSERT_USER = "INSERT INTO users (username, password) VALUES (?, ?)";
    private static final String SELECT_USER = "SELECT username, password_hash FROM users WHERE username = ?";
    private static final String UPDATE_USER = "UPDATE users SET password_hash = ? WHERE username = ?";
    private static final String DELETE_USER = "DELETE FROM users WHERE username = ?";

    public UserRepository(DatabaseConnectionManager connectionManager) {
        this.connectionManager = connectionManager;
    }


    public User findByEmail(String email) {
        String sql = "SELECT id, email, password_hash, username, full_name, phone_number, status, is_verified FROM users WHERE email = ?";

        try (Connection conn = connectionManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, email);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return new User(
                        rs.getLong("id"),
                        rs.getString("email"),
                        rs.getString("password_hash"),
                        rs.getString("username"),
                        rs.getString("full_name"),
                        rs.getString("phone_number"),
                        rs.getString("status"),
                        rs.getBoolean("is_verified")
                );
            }
            return null;
        } catch (SQLException e) {
            throw new RuntimeException("Failed to find user", e);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public void updatePassword(String username, String newPassword) {
        try (Connection conn = connectionManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(UPDATE_USER)) {
            pstmt.setString(1, newPassword);
            pstmt.setString(2, username);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Failed to update password", e);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public void deleteUser(String username) {
        try (Connection conn = connectionManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(DELETE_USER)) {
            pstmt.setString(1, username);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Failed to delete user", e);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
    public void save(User user) {
        String sql = "INSERT INTO users (email, password_hash, username, full_name, phone_number, status, is_verified) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = connectionManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, user.getEmail());
            pstmt.setString(2, user.getPassword_hash());
            pstmt.setString(3, user.getUsername());
            pstmt.setString(4, user.getFull_name());
            pstmt.setString(5, user.getPhone_number());
            pstmt.setString(6, "ACTIVE");
            pstmt.setBoolean(7, false);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Failed to save user", e);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}