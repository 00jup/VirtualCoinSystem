package main.account.service;

import main.account.repository.AccountRepository;
import main.auth.config.DatabaseConnectionManager;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class AccountService {
    private final DatabaseConnectionManager connectionManager;
    private final AccountRepository accountRepository;

    public AccountService(DatabaseConnectionManager connectionManager) {
        this.connectionManager = connectionManager;
        this.accountRepository = new AccountRepository(connectionManager);
    }

    public void deposit(Long accountId, BigDecimal amount) {
        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("입금액은 0보다 커야 한다");
        }
        accountRepository.deposit(accountId, amount);
    }

    public void withdraw(Long accountId, BigDecimal amount) {
        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("출금액은 0보다 커야 한다");
        }
        accountRepository.withdraw(accountId, amount);
    }

    public BigDecimal getBalance(Long accountId) {
        return accountRepository.getBalance(accountId);
    }

    public void transfer(Long fromAccountId, Long toAccountId, BigDecimal amount) {
        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("이체액은 0보다 커야 한다");
        }

        try {
            withdraw(fromAccountId, amount);
            deposit(toAccountId, amount);
        } catch (Exception e) {
            throw new RuntimeException("이체 실패: " + e.getMessage());
        }
    }

    public BigDecimal getAccountBalance(Long userId) {
        String sql = """
                    SELECT balance 
                    FROM ACCOUNTS 
                    WHERE user_id = ? AND status = 'ACTIVE'
                    LIMIT 1
                """;

        try (Connection conn = connectionManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, userId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getBigDecimal("balance");
            }
            return BigDecimal.ZERO;
        } catch (SQLException e) {
            throw new RuntimeException("잔액 조회 실패", e);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}