package main.auth.config;

import main.auth.config.DatabaseAuthInformation;

import java.sql.Connection;
import java.sql.DriverManager;

public class DatabaseConnectionManager {
    private final DatabaseAuthInformation dbInfo;

    public DatabaseConnectionManager(DatabaseAuthInformation dbInfo) {
        this.dbInfo = dbInfo;
    }

    public Connection getConnection() throws Exception {
        return DriverManager.getConnection(
                "jdbc:mysql://" + dbInfo.getHost() + ":" + dbInfo.getPort() + "/" + dbInfo.getDatabase_name(),
                dbInfo.getUsername(),
                dbInfo.getPassword()
        );
    }
}