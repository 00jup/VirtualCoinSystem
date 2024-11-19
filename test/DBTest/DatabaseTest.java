package DBTest;

import main.auth.config.DatabaseAuthInformation;
import org.junit.Test;

import java.sql.*;

import static org.junit.Assert.fail;

public class DatabaseTest {

    @Test
    public void testDatabaseConnection() {
        try {
            // JDBC 드라이버 로드
            Class.forName("com.mysql.cj.jdbc.Driver");

            DatabaseAuthInformation dbAuth = new DatabaseAuthInformation();
            String authFilePath = "src/main/auth/MySQLAuthConfig/mysql.auth";
            if (dbAuth.parse_auth_info(authFilePath)) {
                try {
                    String jdbcUrl = String.format("jdbc:mysql://%s:%s/%s", dbAuth.getHost(), dbAuth.getPort(), dbAuth.getDatabase_name());

                    System.out.println("연결 시도 중... " + jdbcUrl);

                    Connection conn = DriverManager.getConnection(jdbcUrl, dbAuth.getUsername(), dbAuth.getPassword());

                    System.out.println("연결 성공!");

                    String query = "SELECT id, name FROM student WHERE id = 1000";
                    PreparedStatement pstmt = conn.prepareStatement(query);

                    ResultSet rs = pstmt.executeQuery();
                    while (rs.next()) {
                        System.out.println("id = " + rs.getString("id"));
                        System.out.println("name = " + rs.getString("name"));
                    }

                    pstmt.close();
                    rs.close();
                    conn.close();

                } catch (SQLException e) {
                    System.out.println("연결 실패: " + e.getMessage());
                    e.printStackTrace();
                    fail("데이터베이스 연결 또는 쿼리 실행 실패: " + e.getMessage());
                }
            } else {
                fail("인증 파일 파싱 실패");
            }
        } catch (ClassNotFoundException e) {
            System.out.println("MySQL JDBC Driver를 찾을 수 없습니다.");
            e.printStackTrace();
            fail("MySQL JDBC Driver 로드 실패: " + e.getMessage());
        }
    }

}